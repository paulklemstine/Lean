#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script demonstrates the five main theorems about the Counterpoint Quiver
of first-species counterpoint over 12-TET, as formalized in
Novelty/CounterpointCategory.lean.

All computations are self-contained; no external libraries are required.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ---------------------------------------------------------------------------
# Core definitions (matching the Lean formalization)
# ---------------------------------------------------------------------------

N = 12  # 12-tone equal temperament

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison (P1)",
    1: "minor 2nd",
    2: "Major 2nd",
    3: "minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "minor 6th",
    9: "Major 6th",
    10: "minor 7th",
    11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    bass: int    # bass motion in semitones mod 12
    soprano: int # soprano motion in semitones mod 12


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading is permitted in the standard 12-TET system."""
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings over Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def permitted_from_to(source: int, target: int) -> list[VoiceLeading]:
    """All permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


# ---------------------------------------------------------------------------
# Demonstration 1: Strong Connectivity
# ---------------------------------------------------------------------------

def demo_strong_connectivity() -> None:
    """Theorem 3.4: Between any two consonant intervals, ≥1 permitted VL exists."""
    print("=" * 70)
    print("THEOREM 1: Strong Connectivity")
    print("Between any two consonant intervals, a permitted voice leading exists.")
    print("=" * 70)

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            vls = permitted_from_to(i, j)
            marker = "✓" if vls else "✗"
            if not vls:
                all_connected = False
            # Show the canonical VL
            canonical = VoiceLeading(0, (j - i) % N)
            is_canon_ok = is_permitted(i, j, canonical)
            print(f"  {INTERVAL_NAMES[i]:>14s} → {INTERVAL_NAMES[j]:<14s}: "
                  f"{len(vls):3d} permitted VLs  {marker}  "
                  f"(canonical (0,{(j-i)%N:2d}) {'works' if is_canon_ok else 'FAILS'})")

    print(f"\n  All pairs connected: {all_connected}  ✓\n")


# ---------------------------------------------------------------------------
# Demonstration 2: Non-Composability
# ---------------------------------------------------------------------------

def compose(v1: VoiceLeading, v2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings: total motion is sum of individual motions."""
    return VoiceLeading((v1.bass + v2.bass) % N, (v1.soprano + v2.soprano) % N)


def demo_non_composability() -> None:
    """Theorem 4.2: Permitted VLs are not closed under composition."""
    print("=" * 70)
    print("THEOREM 2: Non-Composability")
    print("Two individually permitted VLs can compose into a forbidden one.")
    print("=" * 70)

    counterexamples = 0
    example_shown = False

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for v1 in permitted_from_to(i, j):
                    for v2 in permitted_from_to(j, k):
                        comp = compose(v1, v2)
                        if target_interval(i, comp) == k and not is_permitted(i, k, comp):
                            counterexamples += 1
                            if not example_shown:
                                print(f"\n  Example: {INTERVAL_NAMES[i]} → "
                                      f"{INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]}")
                                print(f"    v1 = (bass={v1.bass}, soprano={v1.soprano}) "
                                      f"— permitted ✓")
                                print(f"    v2 = (bass={v2.bass}, soprano={v2.soprano}) "
                                      f"— permitted ✓")
                                print(f"    v2∘v1 = (bass={comp.bass}, soprano={comp.soprano})"
                                      f" — {'parallel' if is_parallel(comp) else 'not parallel'}"
                                      f", target {'perfect' if k in PERFECT else 'imperfect'}"
                                      f" → FORBIDDEN ✗")
                                example_shown = True

    print(f"\n  Total counterexamples to closure: {counterexamples}")
    print(f"  Permitted VLs form a subcategory: {counterexamples == 0}\n")


# ---------------------------------------------------------------------------
# Demonstration 3: Self-Loop Bottleneck
# ---------------------------------------------------------------------------

def demo_self_loop_bottleneck() -> None:
    """Theorems 5.1 & 5.2: Perfect consonances have 1 self-loop; imperfect have 12."""
    print("=" * 70)
    print("THEOREM 3: Perfect Consonance Bottleneck (Self-Loops)")
    print("Perfect consonances admit 1 self-loop; imperfect admit 12.")
    print("=" * 70)

    for i in sorted(CONSONANT):
        self_loops = permitted_from_to(i, i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:>14s} ({kind:>9s}): {len(self_loops):2d} self-loops")
        if len(self_loops) <= 3:
            for vl in self_loops:
                print(f"    → (bass={vl.bass}, soprano={vl.soprano})")

    print()


# ---------------------------------------------------------------------------
# Demonstration 4: Voice-Swap Asymmetry
# ---------------------------------------------------------------------------

def demo_voice_swap() -> None:
    """Theorem 6.2: Negation mod 12 does not preserve the consonance set."""
    print("=" * 70)
    print("THEOREM 4: Voice-Swap Asymmetry")
    print("The involution i ↦ −i (mod 12) does not preserve consonances.")
    print("=" * 70)

    print(f"\n  Consonant intervals C = {sorted(CONSONANT)}")
    print(f"  Voice-swap image  σ(C) = {sorted({(-i) % N for i in CONSONANT})}")

    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        preserved = neg_i in CONSONANT
        print(f"  σ({INTERVAL_NAMES[i]:>14s} = {i:2d}) = {neg_i:2d} "
              f"({INTERVAL_NAMES[neg_i]:>14s}) → "
              f"{'consonant ✓' if preserved else 'DISSONANT ✗'}")

    swapped = {(-i) % N for i in CONSONANT}
    print(f"\n  C is σ-invariant: {CONSONANT == swapped}")
    print(f"  Broken element: 7 (P5) ↦ 5 (P4, dissonant)\n")


# ---------------------------------------------------------------------------
# Demonstration 5: Hom-Set Cardinalities
# ---------------------------------------------------------------------------

def demo_hom_sets() -> None:
    """Theorems 5.4 & 5.5: Perfect consonances receive 61 incoming VLs; imperfect 72."""
    print("=" * 70)
    print("THEOREM 5: Hom-Set Cardinalities")
    print("Perfect targets receive 61 incoming VLs; imperfect receive 72.")
    print("=" * 70)

    for j in sorted(CONSONANT):
        total_incoming = sum(len(permitted_from_to(i, j)) for i in sorted(CONSONANT))
        kind = "PERFECT" if j in PERFECT else "imperfect"
        deficit = 72 - total_incoming
        print(f"  Target {INTERVAL_NAMES[j]:>14s} ({kind:>9s}): "
              f"{total_incoming} incoming VLs"
              f"{f'  (deficit = {deficit})' if deficit else ''}")

    # Breakdown by source for one perfect consonance
    print(f"\n  Breakdown for target = Perfect 5th (7):")
    for i in sorted(CONSONANT):
        n_vl = len(permitted_from_to(i, 7))
        print(f"    from {INTERVAL_NAMES[i]:>14s}: {n_vl:2d} voice leadings"
              f"{'  ← only identity (parallel forbidden)' if i == 7 else ''}")

    print()


# ---------------------------------------------------------------------------
# Bonus: Full Quiver Statistics
# ---------------------------------------------------------------------------

def demo_quiver_summary() -> None:
    """Summary statistics of the entire counterpoint quiver."""
    print("=" * 70)
    print("BONUS: Full Counterpoint Quiver Statistics")
    print("=" * 70)

    total_edges = 0
    edge_matrix: dict[tuple[int, int], int] = {}
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            n = len(permitted_from_to(i, j))
            edge_matrix[(i, j)] = n
            total_edges += n

    print(f"\n  Vertices (consonant intervals): {len(CONSONANT)}")
    print(f"  Total directed edges (permitted VLs): {total_edges}")
    print(f"  Max possible edges (no restrictions): {len(CONSONANT)**2 * N}")
    print(f"  Restriction ratio: {total_edges}/{len(CONSONANT)**2 * N} "
          f"= {total_edges / (len(CONSONANT)**2 * N):.4f}")

    # Adjacency matrix (edge counts)
    print(f"\n  Edge-count matrix (rows = source, cols = target):")
    header = "      " + "".join(f"{j:>5d}" for j in sorted(CONSONANT))
    print(header)
    for i in sorted(CONSONANT):
        row = f"  {i:3d} " + "".join(f"{edge_matrix[(i,j)]:>5d}" for j in sorted(CONSONANT))
        print(row)

    # Row sums (outgoing) and column sums (incoming)
    print(f"\n  Outgoing VLs per source:")
    for i in sorted(CONSONANT):
        out = sum(edge_matrix[(i, j)] for j in CONSONANT)
        print(f"    {INTERVAL_NAMES[i]:>14s}: {out}")

    print(f"\n  Incoming VLs per target:")
    for j in sorted(CONSONANT):
        inc = sum(edge_matrix[(i, j)] for i in CONSONANT)
        print(f"    {INTERVAL_NAMES[j]:>14s}: {inc}")

    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     SONIC MATHEMATICS: Counterpoint as Category Theory             ║")
    print("║     Numerical Demonstrations of the Counterpoint Quiver            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap()
    demo_hom_sets()
    demo_quiver_summary()

    print("All demonstrations complete.")
    print("These results match the formally verified theorems in")
    print("Novelty/CounterpointCategory.lean.")


if __name__ == "__main__":
    main()
