#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script demonstrates the five main theorems about the Counterpoint Quiver
of first-species counterpoint over the 12-tone equal temperament system.

All computations are self-contained — no external dependencies beyond the
Python standard library.
"""

from __future__ import annotations
from itertools import product
from typing import NamedTuple


# ─────────────────────────────────────────────────────────────────────
# Core Definitions
# ─────────────────────────────────────────────────────────────────────

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison (P1)",
    1: "Minor 2nd",
    2: "Major 2nd",
    3: "Minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "Minor 6th",
    9: "Major 6th",
    10: "Minor 7th",
    11: "Major 7th",
}

# Consonant intervals in first-species counterpoint (mod 12)
CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}

# Perfect consonances (stricter voice-leading rules)
PERFECT: set[int] = {0, 7}

# Imperfect consonances
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}


class VoiceLeading(NamedTuple):
    """A voice leading: bass motion and soprano motion, both in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval after applying a voice leading to a source interval."""
    return (source + vl.soprano - vl.bass) % 12


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """
    Check if a voice leading from source to target is permitted:
    1. Source is consonant
    2. Target is consonant
    3. VL maps source to target
    4. No parallel motion into a perfect consonance
    """
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings in Z/12Z × Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(12), repeat=2)]


def compose(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings (apply vl1 first, then vl2)."""
    return VoiceLeading((vl1.bass + vl2.bass) % 12, (vl1.soprano + vl2.soprano) % 12)


# ─────────────────────────────────────────────────────────────────────
# Theorem 1: Strong Connectivity
# ─────────────────────────────────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Demonstrate that every pair of consonant intervals has a permitted voice leading."""
    print("=" * 70)
    print("THEOREM 1: STRONG CONNECTIVITY")
    print("Between any two consonant intervals, a permitted voice leading exists.")
    print("=" * 70)

    all_vls = all_voice_leadings()
    consonant_sorted = sorted(CONSONANT)

    for i in consonant_sorted:
        for j in consonant_sorted:
            permitted = [vl for vl in all_vls if is_permitted(i, j, vl)]
            canonical = VoiceLeading(0, (j - i) % 12)
            assert len(permitted) > 0, f"No permitted VL from {i} to {j}!"
            assert is_permitted(i, j, canonical), f"Canonical VL fails for {i}->{j}!"
            print(
                f"  {INTERVAL_NAMES[i]:>15s} → {INTERVAL_NAMES[j]:<15s}: "
                f"{len(permitted):3d} permitted VLs  "
                f"(canonical: bass=0, soprano={canonical.soprano})"
            )

    print("\n✓ All 36 source-target pairs have at least one permitted voice leading.")
    print("✓ The Counterpoint Quiver has diameter 1.\n")


# ─────────────────────────────────────────────────────────────────────
# Theorem 2: Non-Composability
# ─────────────────────────────────────────────────────────────────────

def demo_non_composability() -> None:
    """Find explicit examples where composing two permitted VLs yields a forbidden one."""
    print("=" * 70)
    print("THEOREM 2: NON-COMPOSABILITY")
    print("Permitted voice leadings are NOT closed under composition.")
    print("=" * 70)

    all_vls = all_voice_leadings()
    counterexamples: list[tuple[int, int, int, VoiceLeading, VoiceLeading, VoiceLeading]] = []

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for vl1 in all_vls:
                    if not is_permitted(i, j, vl1):
                        continue
                    for vl2 in all_vls:
                        if not is_permitted(j, k, vl2):
                            continue
                        comp = compose(vl1, vl2)
                        if not is_permitted(i, k, comp):
                            counterexamples.append((i, j, k, vl1, vl2, comp))

    print(f"\n  Found {len(counterexamples)} composition failures out of all composable pairs.")
    print("\n  First 5 counterexamples:")
    for idx, (i, j, k, vl1, vl2, comp) in enumerate(counterexamples[:5]):
        print(f"\n  Example {idx + 1}:")
        print(f"    Step 1: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]} via (bass={vl1.bass}, sop={vl1.soprano}) ✓")
        print(f"    Step 2: {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]} via (bass={vl2.bass}, sop={vl2.soprano}) ✓")
        print(f"    Composed: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[k]} via (bass={comp.bass}, sop={comp.soprano}) ✗ FORBIDDEN")
        if k in PERFECT and is_parallel(comp):
            print(f"    Reason: parallel motion into {INTERVAL_NAMES[k]} (perfect consonance)")

    print("\n✓ Composition is NOT closed — the quiver does not form a category.\n")


# ─────────────────────────────────────────────────────────────────────
# Theorem 3: Perfect Consonance Bottleneck (Self-Loops & Hom-Sets)
# ─────────────────────────────────────────────────────────────────────

def demo_bottleneck() -> None:
    """Demonstrate the self-loop dichotomy and hom-set computation."""
    print("=" * 70)
    print("THEOREM 3: PERFECT CONSONANCE BOTTLENECK")
    print("Perfect consonances are arrival-restricted.")
    print("=" * 70)

    all_vls = all_voice_leadings()

    print("\n  Self-loop counts (voice leadings from an interval to itself):")
    print("  " + "-" * 50)
    for i in sorted(CONSONANT):
        self_loops = [vl for vl in all_vls if is_permitted(i, i, vl)]
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"    {INTERVAL_NAMES[i]:>15s} ({kind:>9s}): {len(self_loops):2d} self-loops")
        if i in PERFECT:
            assert len(self_loops) == 1, f"Expected 1 self-loop at perfect consonance {i}"
            assert self_loops[0] == VoiceLeading(0, 0), "Only self-loop should be identity"
        else:
            assert len(self_loops) == 12, f"Expected 12 self-loops at imperfect consonance {i}"

    print("\n  ✓ Perfect consonances: 1 self-loop each (identity only)")
    print("  ✓ Imperfect consonances: 12 self-loops each (all transpositions)")
    print(f"  ✓ Ratio: 12:1 — maximum possible asymmetry")

    print("\n  Total incoming voice leadings (from all consonant sources):")
    print("  " + "-" * 50)
    for j in sorted(CONSONANT):
        incoming = sum(
            1 for i in CONSONANT for vl in all_vls if is_permitted(i, j, vl)
        )
        kind = "PERFECT" if j in PERFECT else "imperfect"
        print(f"    → {INTERVAL_NAMES[j]:>15s} ({kind:>9s}): {incoming:3d} incoming VLs")
        if j in PERFECT:
            assert incoming == 61, f"Expected 61 for perfect, got {incoming}"
        else:
            assert incoming == 72, f"Expected 72 for imperfect, got {incoming}"

    print("\n  ✓ Perfect consonances: 61 incoming each")
    print("  ✓ Imperfect consonances: 72 incoming each")
    print(f"  ✓ Deficit: 72 - 61 = 11 = n - 1 (the number of nonzero parallel motions)")

    total_edges = 2 * 61 + 4 * 72
    print(f"\n  Total edges in Counterpoint Quiver: {total_edges}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Theorem 4: Voice-Swap Asymmetry
# ─────────────────────────────────────────────────────────────────────

def demo_voice_swap() -> None:
    """Demonstrate that negation mod 12 does not preserve consonance."""
    print("=" * 70)
    print("THEOREM 4: VOICE-SWAP ASYMMETRY")
    print("The involution i ↦ -i (mod 12) does NOT preserve consonance.")
    print("=" * 70)

    print("\n  Interval mapping under voice swap (i ↦ -i mod 12):")
    print("  " + "-" * 60)
    swap_preserves = True
    for i in range(12):
        neg_i = (-i) % 12
        i_cons = "consonant" if i in CONSONANT else "dissonant"
        neg_cons = "consonant" if neg_i in CONSONANT else "dissonant"
        marker = ""
        if (i in CONSONANT) != (neg_i in CONSONANT):
            marker = " ← BREAKS CONSONANCE"
            swap_preserves = False
        if i in CONSONANT or neg_i in CONSONANT:
            print(
                f"    {INTERVAL_NAMES[i]:>15s} ({i:2d}, {i_cons:>9s}) "
                f"↦ {INTERVAL_NAMES[neg_i]:<15s} ({neg_i:2d}, {neg_cons:>9s}){marker}"
            )

    assert not swap_preserves
    print(f"\n  ✓ σ(7) = 5: Perfect fifth ↦ Perfect fourth (dissonant!)")
    print(f"  ✓ The bass voice is privileged — swapping voices changes consonance.")

    # Show which pairs ARE preserved
    print("\n  Preserved pairs (both consonant):")
    for i in sorted(CONSONANT):
        neg_i = (-i) % 12
        if neg_i in CONSONANT:
            print(f"    {INTERVAL_NAMES[i]} ↔ {INTERVAL_NAMES[neg_i]}")

    print()


# ─────────────────────────────────────────────────────────────────────
# Bonus: Full Quiver Adjacency Matrix
# ─────────────────────────────────────────────────────────────────────

def demo_adjacency_matrix() -> None:
    """Print the full adjacency matrix of the Counterpoint Quiver."""
    print("=" * 70)
    print("BONUS: ADJACENCY MATRIX OF THE COUNTERPOINT QUIVER")
    print("Entry (i,j) = number of permitted voice leadings from i to j")
    print("=" * 70)

    all_vls = all_voice_leadings()
    consonant_sorted = sorted(CONSONANT)

    # Header
    print(f"\n{'':>18s}", end="")
    for j in consonant_sorted:
        print(f"  {j:>4d}", end="")
    print("  │ Row sum")
    print("  " + "-" * 62)

    for i in consonant_sorted:
        kind_i = "P" if i in PERFECT else "I"
        print(f"  {INTERVAL_NAMES[i]:>13s} ({kind_i})", end="")
        row_sum = 0
        for j in consonant_sorted:
            count = sum(1 for vl in all_vls if is_permitted(i, j, vl))
            row_sum += count
            print(f"  {count:>4d}", end="")
        print(f"  │ {row_sum:>4d}")

    print("  " + "-" * 62)
    print(f"{'Col sum':>18s}", end="")
    grand_total = 0
    for j in consonant_sorted:
        col_sum = sum(
            1 for i in CONSONANT for vl in all_vls if is_permitted(i, j, vl)
        )
        grand_total += col_sum
        print(f"  {col_sum:>4d}", end="")
    print(f"  │ {grand_total:>4d}")
    print(f"\n  Total edges: {grand_total}")
    print(f"  P = Perfect consonance, I = Imperfect consonance\n")


# ─────────────────────────────────────────────────────────────────────
# Bonus: Generalization to n-TET
# ─────────────────────────────────────────────────────────────────────

def demo_generalization(n: int, consonant: set[int], perfect: set[int]) -> None:
    """Run the bottleneck analysis for an arbitrary n-TET system."""
    print("=" * 70)
    print(f"GENERALIZATION: {n}-TET Counterpoint System")
    print(f"  Consonant: {sorted(consonant)}")
    print(f"  Perfect:   {sorted(perfect)}")
    print("=" * 70)

    all_vls = [VoiceLeading(b, s) for b, s in product(range(n), repeat=2)]

    for j in sorted(consonant):
        incoming = 0
        for i in consonant:
            for vl in all_vls:
                tgt = (i + vl.soprano - vl.bass) % n
                par = vl.bass == vl.soprano and vl.bass != 0
                if i in consonant and tgt == j and not (j in perfect and par):
                    incoming += 1
        kind = "PERFECT" if j in perfect else "imperfect"
        print(f"    Incoming to interval {j:2d} ({kind:>9s}): {incoming:3d}")

    print()


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║   Numerical Demonstrations of the Five Main Theorems               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_bottleneck()
    demo_non_composability()
    demo_voice_swap()
    demo_adjacency_matrix()

    # Demonstrate generalization to 19-TET
    # Using a plausible consonance set for 19-TET (approximating just intonation)
    consonant_19 = {0, 5, 6, 11, 13, 14}  # ~unison, ~m3, ~M3, ~P5, ~m6, ~M6
    perfect_19 = {0, 11}  # ~unison, ~P5
    demo_generalization(19, consonant_19, perfect_19)

    print("All assertions passed. ✓")


if __name__ == "__main__":
    main()
