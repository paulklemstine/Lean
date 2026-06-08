#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory
===================================================
Numerical demonstrations of the Counterpoint Quiver for 12-TET first-species counterpoint.

This script reproduces and verifies the key theorems from the formal proofs:
  1. Strong connectivity of the quiver
  2. Non-composability of permitted voice leadings
  3. Self-loop bottleneck (12:1 ratio)
  4. Voice-swap asymmetry
  5. Hom-set computation (61 vs 72)
"""

from __future__ import annotations
from typing import NamedTuple


# ─── Definitions ──────────────────────────────────────────────────────────────

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT
N: int = 12

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    3: "Minor 3rd",
    4: "Major 3rd",
    7: "Perfect 5th",
    8: "Minor 6th",
    9: "Major 6th",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given a source and voice leading."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass % N == vl.soprano % N and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading is permitted in first-species counterpoint."""
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and is_parallel(vl))
    )


def all_permitted(source: int, target: int) -> list[VoiceLeading]:
    """Enumerate all permitted voice leadings from source to target."""
    result: list[VoiceLeading] = []
    for b in range(N):
        for s in range(N):
            vl = VoiceLeading(b, s)
            if is_permitted(source, target, vl):
                result.append(vl)
    return result


def canonical_vl(source: int, target: int) -> VoiceLeading:
    """The canonical voice leading: bass holds, soprano moves by target - source."""
    return VoiceLeading(0, (target - source) % N)


# ─── Theorem 1: Strong Connectivity ──────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Verify that every pair of consonant intervals has a permitted voice leading."""
    print("=" * 70)
    print("THEOREM 1: STRONG CONNECTIVITY")
    print("Between any two consonant intervals, a permitted voice leading exists.")
    print("=" * 70)

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            permitted = all_permitted(i, j)
            if not permitted:
                print(f"  FAIL: No permitted VL from {i} to {j}")
                all_connected = False

    # Show the canonical voice leading for each pair
    print(f"\n  Canonical voice leadings (bass holds, soprano adjusts):")
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            if i != j:
                vl = canonical_vl(i, j)
                assert is_permitted(i, j, vl), f"Canonical VL {vl} not permitted!"
                print(f"    {INTERVAL_NAMES[i]:15s} → {INTERVAL_NAMES[j]:15s}  "
                      f"VL = (bass=0, soprano={vl.soprano:2d})")

    print(f"\n  ✓ All {len(CONSONANT)}×{len(CONSONANT)} = "
          f"{len(CONSONANT)**2} pairs connected: {all_connected}")


# ─── Theorem 2: Non-Composability ────────────────────────────────────────────

def demo_non_composability() -> None:
    """Find explicit examples where composing two permitted VLs gives a forbidden one."""
    print("\n" + "=" * 70)
    print("THEOREM 2: NON-COMPOSABILITY")
    print("Permitted voice leadings are NOT closed under composition.")
    print("=" * 70)

    examples_found = 0
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for vl1 in all_permitted(i, j):
                    for vl2 in all_permitted(j, k):
                        # Compose: add motions
                        composed = VoiceLeading(
                            (vl1.bass + vl2.bass) % N,
                            (vl1.soprano + vl2.soprano) % N,
                        )
                        # Check if composed maps i to k
                        if target_interval(i, composed) == k:
                            if not is_permitted(i, k, composed):
                                if examples_found < 3:
                                    print(f"\n  Example {examples_found + 1}:")
                                    print(f"    Step 1: {INTERVAL_NAMES[i]} → "
                                          f"{INTERVAL_NAMES[j]} via VL{vl1}")
                                    print(f"    Step 2: {INTERVAL_NAMES[j]} → "
                                          f"{INTERVAL_NAMES[k]} via VL{vl2}")
                                    print(f"    Composed: VL{composed} from "
                                          f"{INTERVAL_NAMES[i]} → {INTERVAL_NAMES[k]}")
                                    print(f"    Composed is parallel: {is_parallel(composed)}")
                                    print(f"    Target {k} is perfect: {k in PERFECT}")
                                    print(f"    → FORBIDDEN! ✗")
                                examples_found += 1

    print(f"\n  ✓ Found {examples_found} composition violations (showed first 3)")


# ─── Theorem 3: Self-Loop Bottleneck ─────────────────────────────────────────

def demo_self_loop_bottleneck() -> None:
    """Count self-loops at perfect vs imperfect consonances."""
    print("\n" + "=" * 70)
    print("THEOREM 3: SELF-LOOP BOTTLENECK (12:1 RATIO)")
    print("Perfect consonances admit 1 self-loop; imperfect admit 12.")
    print("=" * 70)

    for i in sorted(CONSONANT):
        loops = all_permitted(i, i)
        kind = "PERFECT" if i in PERFECT else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[i]:15s} ({kind:9s}): {len(loops):2d} self-loops")
        if i in PERFECT:
            assert len(loops) == 1, f"Expected 1 self-loop at perfect {i}, got {len(loops)}"
            assert loops[0] == VoiceLeading(0, 0), "Only self-loop should be identity"
        else:
            assert len(loops) == 12, f"Expected 12 self-loops at imperfect {i}, got {len(loops)}"

    print(f"\n  ✓ Perfect self-loops: 1  |  Imperfect self-loops: 12  |  Ratio: 12:1")


# ─── Theorem 4: Voice-Swap Asymmetry ─────────────────────────────────────────

def demo_voice_swap_asymmetry() -> None:
    """Show that the involution i ↦ -i (mod 12) does not preserve consonance."""
    print("\n" + "=" * 70)
    print("THEOREM 4: VOICE-SWAP ASYMMETRY")
    print("The involution i ↦ -i (swapping voices) breaks consonance.")
    print("=" * 70)

    print(f"\n  {'Interval':15s} {'Semitones':>10s} {'Complement':>11s} {'Complement consonant?':>22s}")
    print(f"  {'-'*15} {'-'*10} {'-'*11} {'-'*22}")

    broken = []
    for i in sorted(CONSONANT):
        complement = (-i) % N
        is_cons = complement in CONSONANT
        marker = "✓" if is_cons else "✗ BROKEN"
        print(f"  {INTERVAL_NAMES[i]:15s} {i:10d} {complement:11d} {marker:>22s}")
        if not is_cons:
            broken.append((i, complement))

    print(f"\n  ✓ Voice-swap breaks consonance at: "
          f"{', '.join(f'{INTERVAL_NAMES[i]}({i})→{c}' for i, c in broken)}")
    print(f"  The perfect fifth (7) maps to the perfect fourth (5), which is dissonant.")
    print(f"  This formalizes the asymmetric role of the bass voice.")


# ─── Theorem 5: Hom-Set Computation ──────────────────────────────────────────

def demo_hom_set_computation() -> None:
    """Compute the full hom-set table and verify 61 vs 72."""
    print("\n" + "=" * 70)
    print("THEOREM 5: HOM-SET COMPUTATION (61 vs 72)")
    print("Perfect consonances admit 61 incoming VLs; imperfect admit 72.")
    print("=" * 70)

    consonant_sorted = sorted(CONSONANT)

    # Build and display hom-set size table
    print(f"\n  Hom-set sizes |Hom(i, j)|:")
    header = "  Src \\ Tgt |" + "".join(f" {j:3d}" for j in consonant_sorted) + " | Row Total"
    print(f"  {'-' * len(header)}")
    print(header)
    print(f"  {'-' * len(header)}")

    col_totals: dict[int, int] = {j: 0 for j in consonant_sorted}
    total_edges = 0

    for i in consonant_sorted:
        row: list[int] = []
        row_total = 0
        for j in consonant_sorted:
            count = len(all_permitted(i, j))
            row.append(count)
            col_totals[j] += count
            row_total += count
        total_edges += row_total
        row_str = "".join(f" {c:3d}" for c in row)
        print(f"  {i:5d}      |{row_str} | {row_total:5d}")

    print(f"  {'-' * len(header)}")
    col_str = "".join(f" {col_totals[j]:3d}" for j in consonant_sorted)
    print(f"  Col Total |{col_str} | {total_edges:5d}")

    # Verify the theorem
    for j in consonant_sorted:
        expected = 61 if j in PERFECT else 72
        actual = col_totals[j]
        status = "✓" if actual == expected else "✗"
        kind = "Perfect" if j in PERFECT else "Imperfect"
        print(f"\n  {status} {INTERVAL_NAMES[j]:15s} ({kind}): "
              f"{actual} incoming VLs (expected {expected})")

    print(f"\n  Total edges in Counterpoint Quiver: {total_edges}")
    print(f"  = 2 × 61 + 4 × 72 = 122 + 288 = 410 ✓" if total_edges == 410 else "")


# ─── Bonus: Quiver Density Analysis ──────────────────────────────────────────

def demo_quiver_density() -> None:
    """Analyze the density of the Counterpoint Quiver vs the unconstrained quiver."""
    print("\n" + "=" * 70)
    print("BONUS: QUIVER DENSITY ANALYSIS")
    print("=" * 70)

    total_permitted = 0
    total_possible = 0

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            permitted_count = len(all_permitted(i, j))
            total_permitted += permitted_count
            total_possible += N  # 12 possible VLs (one per bass motion)

    print(f"\n  Total permitted voice leadings:   {total_permitted}")
    print(f"  Total possible voice leadings:    {total_possible}")
    print(f"  Density (permitted / possible):   {total_permitted / total_possible:.4f}")
    print(f"  Edges removed by parallel rule:   {total_possible - total_permitted}")
    print(f"  Fraction removed:                 "
          f"{(total_possible - total_permitted) / total_possible:.4f}")
    print(f"\n  The parallel-fifths/octaves rule removes only "
          f"{total_possible - total_permitted} of {total_possible} possible edges,")
    print(f"  yet creates a profound 12:1 asymmetry in the self-loop structure.")


# ─── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print("╔" + "═" * 68 + "╗")
    print("║   SONIC MATHEMATICS: COUNTERPOINT AS CATEGORY THEORY              ║")
    print("║   Numerical Demonstrations of the Counterpoint Quiver             ║")
    print("╚" + "═" * 68 + "╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_computation()
    demo_quiver_density()

    print("\n" + "=" * 70)
    print("All theorems verified numerically. ✓")
    print("=" * 70)


if __name__ == "__main__":
    main()
