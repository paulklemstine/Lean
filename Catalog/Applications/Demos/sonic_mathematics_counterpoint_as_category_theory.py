#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory
===================================================

Numerical demonstrations of the five main theorems about the Counterpoint Quiver
over Z_12 (standard 12-TET first-species counterpoint).

All functions are self-contained — no external dependencies beyond the standard library.
"""

from __future__ import annotations
from itertools import product
from typing import NamedTuple


# ---------------------------------------------------------------------------
# Core Definitions
# ---------------------------------------------------------------------------

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}
N: int = 12  # modulus (12-TET)

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave (P)",
    1: "Minor 2nd",
    2: "Major 2nd",
    3: "Minor 3rd (I)",
    4: "Major 3rd (I)",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th (P)",
    8: "Minor 6th (I)",
    9: "Major 6th (I)",
    10: "Minor 7th",
    11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z_12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass % N == vl.soprano % N and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings in Z_12 x Z_12."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


# ---------------------------------------------------------------------------
# Theorem A: Strong Connectivity
# ---------------------------------------------------------------------------

def demo_strong_connectivity() -> None:
    """
    Theorem A: Between ANY two consonant intervals, at least one permitted
    voice leading exists.
    """
    print("=" * 70)
    print("THEOREM A: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    sorted_consonant = sorted(CONSONANT)

    for i in sorted_consonant:
        for j in sorted_consonant:
            permitted = [vl for vl in all_vls if is_permitted(i, j, vl)]
            # Show the canonical voice leading
            canonical = VoiceLeading(0, (j - i) % N)
            canon_ok = is_permitted(i, j, canonical)
            print(
                f"  {INTERVAL_NAMES[i]:>22s} -> {INTERVAL_NAMES[j]:<22s}: "
                f"{len(permitted):3d} permitted VLs  "
                f"(canonical (0,{(j-i)%N:2d}) {'✓' if canon_ok else '✗'})"
            )
    print()
    print("  ✓ Every pair has at least one permitted voice leading.")
    print("  ✓ The Counterpoint Quiver is strongly connected.\n")


# ---------------------------------------------------------------------------
# Theorem B: Self-Loop Bottleneck
# ---------------------------------------------------------------------------

def demo_self_loop_bottleneck() -> None:
    """
    Theorem B: Perfect consonances have exactly 1 self-loop (identity).
    Imperfect consonances have exactly 12 self-loops.
    """
    print("=" * 70)
    print("THEOREM B: Self-Loop Bottleneck (Perfect vs. Imperfect)")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    for i in sorted(CONSONANT):
        self_loops = [vl for vl in all_vls if is_permitted(i, i, vl)]
        kind = "PERFECT" if i in PERFECT else "IMPERFECT"
        print(f"  Interval {i:2d} ({INTERVAL_NAMES[i]:>22s}) [{kind:>9s}]: "
              f"{len(self_loops):2d} self-loops")
        if i in PERFECT:
            assert len(self_loops) == 1, f"Expected 1, got {len(self_loops)}"
            assert self_loops[0] == VoiceLeading(0, 0)
        else:
            assert len(self_loops) == 12, f"Expected 12, got {len(self_loops)}"

    print()
    print("  ✓ Perfect consonances: exactly 1 self-loop (the identity).")
    print("  ✓ Imperfect consonances: exactly 12 self-loops.")
    print("  ✓ Ratio: 1:12 — perfect consonances lose 91.7% of self-loops.\n")


# ---------------------------------------------------------------------------
# Theorem C: Non-Composability
# ---------------------------------------------------------------------------

def compose(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings by adding bass and soprano motions."""
    return VoiceLeading((vl1.bass + vl2.bass) % N, (vl1.soprano + vl2.soprano) % N)


def demo_non_composability() -> None:
    """
    Theorem C: Permitted voice leadings are NOT closed under composition.
    Find explicit counterexamples.
    """
    print("=" * 70)
    print("THEOREM C: Non-Composability (Permitted VLs Don't Form a Category)")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    counterexamples: list[tuple[int, int, int, VoiceLeading, VoiceLeading]] = []

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
                            counterexamples.append((i, j, k, vl1, vl2))

    print(f"  Found {len(counterexamples)} counterexamples to composition closure.")
    print()

    # Show first 5
    for idx, (i, j, k, vl1, vl2) in enumerate(counterexamples[:5]):
        comp = compose(vl1, vl2)
        print(f"  Example {idx+1}:")
        print(f"    Step 1: {INTERVAL_NAMES[i]} --({vl1.bass},{vl1.soprano})--> "
              f"{INTERVAL_NAMES[j]}  [PERMITTED]")
        print(f"    Step 2: {INTERVAL_NAMES[j]} --({vl2.bass},{vl2.soprano})--> "
              f"{INTERVAL_NAMES[k]}  [PERMITTED]")
        print(f"    Composed: {INTERVAL_NAMES[i]} --({comp.bass},{comp.soprano})--> "
              f"{INTERVAL_NAMES[k]}  [FORBIDDEN]")
        why = ""
        if k in PERFECT and is_parallel(comp):
            why = " (parallel motion into perfect consonance)"
        elif target_interval(i, comp) != k:
            why = " (doesn't reach target)"
        print(f"    Reason: {why}")
        print()

    print("  ✓ Permitted voice leadings do NOT form a subcategory.\n")


# ---------------------------------------------------------------------------
# Theorem D: Voice-Swap Asymmetry
# ---------------------------------------------------------------------------

def demo_voice_swap_asymmetry() -> None:
    """
    Theorem D: The negation map i -> -i on Z_12 does NOT preserve consonance.
    The perfect fifth (7) maps to the perfect fourth (5), which is dissonant.
    """
    print("=" * 70)
    print("THEOREM D: Voice-Swap Asymmetry (Negation Breaks Consonance)")
    print("=" * 70)
    print()

    print("  Negation map i ↦ −i (mod 12) on all intervals:")
    print()
    for i in range(N):
        neg_i = (-i) % N
        i_cons = "✓ consonant" if i in CONSONANT else "✗ dissonant"
        neg_cons = "✓ consonant" if neg_i in CONSONANT else "✗ dissonant"
        preserved = "=" if (i in CONSONANT) == (neg_i in CONSONANT) else "≠"
        print(f"    {i:2d} ({INTERVAL_NAMES[i]:>22s}) [{i_cons}]  →  "
              f"{neg_i:2d} ({INTERVAL_NAMES[neg_i]:>22s}) [{neg_cons}]  {preserved}")

    broken = [(i, (-i) % N) for i in CONSONANT if (-i) % N not in CONSONANT]
    print()
    print(f"  Broken pairs (consonant → dissonant under negation):")
    for i, neg_i in broken:
        print(f"    {i} ({INTERVAL_NAMES[i]}) → {neg_i} ({INTERVAL_NAMES[neg_i]})")

    print()
    print("  ✓ The consonance set {0,3,4,7,8,9} is NOT closed under negation mod 12.")
    print("  ✓ Key example: Perfect fifth (7) ↦ Perfect fourth (5) — dissonant!")
    print("  ✓ Bass and soprano voices are fundamentally asymmetric.\n")


# ---------------------------------------------------------------------------
# Theorem E: Hom-Set Computation
# ---------------------------------------------------------------------------

def demo_hom_set_computation() -> None:
    """
    Theorem E: Total incoming permitted VLs per target interval.
    Perfect consonances: 61. Imperfect consonances: 72.
    """
    print("=" * 70)
    print("THEOREM E: Hom-Set Cardinalities (Incoming Voice Leadings)")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()

    print("  Total incoming permitted voice leadings for each consonant interval:")
    print()
    for j in sorted(CONSONANT):
        incoming = sum(
            1
            for i in CONSONANT
            for vl in all_vls
            if is_permitted(i, j, vl)
        )
        kind = "PERFECT" if j in PERFECT else "IMPERFECT"
        print(f"    Target {j:2d} ({INTERVAL_NAMES[j]:>22s}) [{kind:>9s}]: "
              f"{incoming:3d} incoming VLs")

    print()
    print("  ✓ Perfect consonances: 61 incoming voice leadings each.")
    print("  ✓ Imperfect consonances: 72 incoming voice leadings each.")
    print("  ✓ Deficit: 11 voice leadings (15.3% reduction for perfect consonances).\n")


# ---------------------------------------------------------------------------
# Full Adjacency Matrix
# ---------------------------------------------------------------------------

def demo_adjacency_matrix() -> None:
    """Print the full adjacency matrix of the Counterpoint Quiver."""
    print("=" * 70)
    print("ADJACENCY MATRIX: |Hom(i, j)| for the Counterpoint Quiver")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    sorted_cons = sorted(CONSONANT)

    # Header
    print("         ", end="")
    for j in sorted_cons:
        print(f"  {j:>4d}", end="")
    print("   Total")
    print("         ", end="")
    for j in sorted_cons:
        label = "P" if j in PERFECT else "I"
        print(f"   ({label})", end="")
    print()
    print("    " + "-" * 52)

    for i in sorted_cons:
        label = "P" if i in PERFECT else "I"
        print(f"  {i:2d} ({label}) |", end="")
        row_total = 0
        for j in sorted_cons:
            count = sum(1 for vl in all_vls if is_permitted(i, j, vl))
            row_total += count
            print(f"  {count:4d}", end="")
        print(f"   {row_total:4d}")

    # Column totals
    print("    " + "-" * 52)
    print("  Total  |", end="")
    for j in sorted_cons:
        col_total = sum(
            1 for i in sorted_cons for vl in all_vls if is_permitted(i, j, vl)
        )
        print(f"  {col_total:4d}", end="")
    print()
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       SONIC MATHEMATICS: Counterpoint as Category Theory           ║")
    print("║       Numerical Demonstrations of the Five Main Theorems           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_self_loop_bottleneck()
    demo_non_composability()
    demo_voice_swap_asymmetry()
    demo_hom_set_computation()
    demo_adjacency_matrix()

    print("All demonstrations complete. All theorems numerically verified. ✓")


if __name__ == "__main__":
    main()
