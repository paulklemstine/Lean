#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script demonstrates the key mathematical results from the formalization
of first-species counterpoint as a quiver (directed multigraph) over Z/12Z.

All computations are self-contained and verify the formally proven theorems.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ============================================================================
# Section 1: Core Definitions
# ============================================================================

# Consonant intervals in first-species counterpoint (mod 12)
CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
# Perfect consonances (subject to parallel-motion restriction)
PERFECT: set[int] = {0, 7}
# Imperfect consonances
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}

# Interval names for display
INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave (P)",
    1: "Minor 2nd",
    2: "Major 2nd",
    3: "Minor 3rd (i)",
    4: "Major 3rd (i)",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th (P)",
    8: "Minor 6th (i)",
    9: "Major 6th (i)",
    10: "Minor 7th",
    11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given a source interval and voice leading."""
    return (source + vl.soprano - vl.bass) % 12


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """
    Check if a voice leading from source to target is permitted.

    Rules:
    1. Both source and target must be consonant
    2. The voice leading must actually map source to target
    3. Parallel motion into perfect consonances is forbidden
    """
    if source not in CONSONANT:
        return False
    if target not in CONSONANT:
        return False
    if target_interval(source, vl) != target:
        return False
    if target in PERFECT and is_parallel(vl):
        return False
    return True


def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 possible voice leadings in Z/12Z × Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(12), repeat=2)]


# ============================================================================
# Section 2: Theorem Verification
# ============================================================================

def demo_strong_connectivity() -> None:
    """
    Theorem 4.1 (exists_permitted_voice_leading):
    Between any two consonant intervals, at least one permitted voice leading exists.
    """
    print("=" * 70)
    print("THEOREM: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    all_connected = True

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            permitted = [vl for vl in all_vls if is_permitted(i, j, vl)]
            status = "✓" if permitted else "✗"
            if not permitted:
                all_connected = False

            # Show the canonical voice leading (bass=0, soprano=j-i)
            canonical = VoiceLeading(0, (j - i) % 12)
            canonical_ok = is_permitted(i, j, canonical)

            name_i = INTERVAL_NAMES[i].split("(")[0].strip()
            name_j = INTERVAL_NAMES[j].split("(")[0].strip()
            print(f"  {status} {name_i:15s} → {name_j:15s}: "
                  f"{len(permitted):3d} permitted VLs  "
                  f"(canonical {'✓' if canonical_ok else '✗'})")

    print()
    print(f"  Result: {'ALL PAIRS CONNECTED ✓' if all_connected else 'GAPS FOUND ✗'}")
    print()


def demo_non_composability() -> None:
    """
    Theorem 4.2 (non_composability):
    Permitted voice leadings are NOT closed under composition.
    """
    print("=" * 70)
    print("THEOREM: Non-Composability of Permitted Voice Leadings")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()
    counterexample_found = False

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                # Find permitted VLs from i→j and j→k
                vls_ij = [vl for vl in all_vls if is_permitted(i, j, vl)]
                vls_jk = [vl for vl in all_vls if is_permitted(j, k, vl)]

                for v1 in vls_ij:
                    for v2 in vls_jk:
                        # Compose: total bass = v1.bass + v2.bass, etc.
                        composed = VoiceLeading(
                            (v1.bass + v2.bass) % 12,
                            (v1.soprano + v2.soprano) % 12
                        )
                        # Check if composition is permitted as a direct i→k step
                        if not is_permitted(i, k, composed):
                            if not counterexample_found:
                                name_i = INTERVAL_NAMES[i].split("(")[0].strip()
                                name_j = INTERVAL_NAMES[j].split("(")[0].strip()
                                name_k = INTERVAL_NAMES[k].split("(")[0].strip()
                                print(f"  COUNTEREXAMPLE FOUND:")
                                print(f"    Path: {name_i} → {name_j} → {name_k}")
                                print(f"    Step 1: bass +{v1.bass}, soprano +{v1.soprano}  "
                                      f"(permitted: True)")
                                print(f"    Step 2: bass +{v2.bass}, soprano +{v2.soprano}  "
                                      f"(permitted: True)")
                                print(f"    Composed: bass +{composed.bass}, soprano +{composed.soprano}")
                                print(f"    Source={i}, Target={k}, "
                                      f"Actual target={target_interval(i, composed)}")
                                print(f"    Is parallel: {is_parallel(composed)}")
                                print(f"    Target is perfect: {k in PERFECT}")
                                print(f"    Composition permitted: False")
                                counterexample_found = True

    if counterexample_found:
        # Count total violations
        violations = 0
        for i in sorted(CONSONANT):
            for j in sorted(CONSONANT):
                for k in sorted(CONSONANT):
                    vls_ij = [vl for vl in all_vls if is_permitted(i, j, vl)]
                    vls_jk = [vl for vl in all_vls if is_permitted(j, k, vl)]
                    for v1 in vls_ij:
                        for v2 in vls_jk:
                            composed = VoiceLeading(
                                (v1.bass + v2.bass) % 12,
                                (v1.soprano + v2.soprano) % 12
                            )
                            if not is_permitted(i, k, composed):
                                violations += 1
        print(f"\n  Total composition violations: {violations}")
    print()


def demo_self_loop_bottleneck() -> None:
    """
    Theorems 4.3–4.4 (perfect_self_loop_unique, imperfect_self_loops_all):
    Perfect consonances have 1 self-loop; imperfect have 12.
    """
    print("=" * 70)
    print("THEOREM: Self-Loop Bottleneck at Perfect Consonances")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()

    print(f"  {'Interval':<20s} {'Type':<12s} {'Self-loops':>10s}  Details")
    print(f"  {'─' * 20} {'─' * 12} {'─' * 10}  {'─' * 30}")

    for i in sorted(CONSONANT):
        self_loops = [vl for vl in all_vls if is_permitted(i, i, vl)]
        interval_type = "PERFECT" if i in PERFECT else "imperfect"
        name = INTERVAL_NAMES[i]

        # Show which self-loops they are
        loop_strs = [f"({vl.bass},{vl.soprano})" for vl in self_loops[:5]]
        detail = ", ".join(loop_strs)
        if len(self_loops) > 5:
            detail += f", ... ({len(self_loops)} total)"

        print(f"  {name:<20s} {interval_type:<12s} {len(self_loops):>10d}  {detail}")

    print()
    print("  Key insight: Perfect consonances admit 1/12th the self-loops")
    print("  of imperfect consonances — they are 'bottlenecks' in the quiver.")
    print()


def demo_voice_swap_asymmetry() -> None:
    """
    Theorem 4.5 (voice_swap_breaks_consonance):
    The involution i ↦ -i (mod 12) does NOT preserve the consonance set.
    """
    print("=" * 70)
    print("THEOREM: Voice-Swap Asymmetry")
    print("=" * 70)
    print()

    print(f"  {'Interval i':<20s} {'−i mod 12':>10s}  {'Name of −i':<20s}  {'Consonant?':>10s}")
    print(f"  {'─' * 20} {'─' * 10}  {'─' * 20}  {'─' * 10}")

    asymmetry_found = False
    for i in sorted(CONSONANT):
        neg_i = (12 - i) % 12
        is_cons = neg_i in CONSONANT
        name_i = INTERVAL_NAMES[i]
        name_neg = INTERVAL_NAMES[neg_i]
        marker = "" if is_cons else " ← BREAKS!"

        if not is_cons:
            asymmetry_found = True

        print(f"  {name_i:<20s} {neg_i:>10d}  {name_neg:<20s}  "
              f"{'Yes' if is_cons else 'NO':>10s}{marker}")

    print()
    if asymmetry_found:
        print("  The consonance set is NOT symmetric under voice exchange.")
        print("  Perfect 5th (7) maps to Perfect 4th (5), which is DISSONANT.")
        print("  This formalizes the privileged role of the bass voice.")
    print()


def demo_hom_set_cardinalities() -> None:
    """
    Theorems 4.6–4.7 (total_permitted_to_perfect/imperfect):
    Perfect consonances admit 61 incoming VLs; imperfect admit 72.
    """
    print("=" * 70)
    print("THEOREM: Hom-Set Cardinalities (Incoming Voice Leadings)")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()

    print(f"  {'Target':<20s} {'Type':<10s} ", end="")
    for i in sorted(CONSONANT):
        print(f"  from {i}", end="")
    print(f"  {'TOTAL':>8s}")

    print(f"  {'─' * 20} {'─' * 10} ", end="")
    for _ in CONSONANT:
        print(f"  {'─' * 6}", end="")
    print(f"  {'─' * 8}")

    for j in sorted(CONSONANT):
        name_j = INTERVAL_NAMES[j].split("(")[0].strip()
        jtype = "PERFECT" if j in PERFECT else "imperfect"
        print(f"  {name_j:<20s} {jtype:<10s} ", end="")

        total = 0
        for i in sorted(CONSONANT):
            count = sum(1 for vl in all_vls if is_permitted(i, j, vl))
            total += count
            print(f"  {count:>5d}", end="")

        print(f"  {total:>7d}")

    print()
    # Summary
    for j in sorted(CONSONANT):
        total = sum(1 for vl in all_vls for i in CONSONANT if is_permitted(i, j, vl))
        jtype = "perfect" if j in PERFECT else "imperfect"

    perf_totals = []
    imperf_totals = []
    for j in sorted(CONSONANT):
        total = sum(1 for vl in all_vls for i in CONSONANT if is_permitted(i, j, vl))
        if j in PERFECT:
            perf_totals.append(total)
        else:
            imperf_totals.append(total)

    print(f"  Perfect consonance incoming totals:   {perf_totals}")
    print(f"  Imperfect consonance incoming totals: {imperf_totals}")
    reduction = (1 - perf_totals[0] / imperf_totals[0]) * 100
    print(f"  Reduction: {reduction:.1f}% fewer incoming VLs to perfect consonances")
    print()


def demo_cost_function() -> None:
    """
    Theorems 5.1–5.3: Voice-leading cost as seminorm with lattice conservation.
    """
    print("=" * 70)
    print("THEOREM: Voice-Leading Cost Function Properties")
    print("=" * 70)
    print()

    # Example voice motions (2-voice counterpoint)
    m1 = [2, -3]   # bass up 2, soprano down 3
    m2 = [-1, 4]   # bass down 1, soprano up 4

    def cost(m: list[int]) -> int:
        return sum(abs(x) for x in m)

    def vec_add(a: list[int], b: list[int]) -> list[int]:
        return [x + y for x, y in zip(a, b)]

    def vec_meet(a: list[int], b: list[int]) -> list[int]:
        return [min(x, y) for x, y in zip(a, b)]

    def vec_join(a: list[int], b: list[int]) -> list[int]:
        return [max(x, y) for x, y in zip(a, b)]

    composed = vec_add(m1, m2)
    meet = vec_meet(m1, m2)
    join = vec_join(m1, m2)

    print(f"  m₁ = {m1}     cost = {cost(m1)}")
    print(f"  m₂ = {m2}    cost = {cost(m2)}")
    print()

    # Triangle inequality
    print(f"  Triangle inequality:")
    print(f"    m₁ + m₂ = {composed}     cost = {cost(composed)}")
    print(f"    cost(m₁+m₂) = {cost(composed)} ≤ "
          f"{cost(m1)} + {cost(m2)} = {cost(m1) + cost(m2)}  ✓")
    print()

    # Lattice-cost conservation
    print(f"  Lattice-cost conservation:")
    print(f"    m₁ ⊓ m₂ = {meet}    cost = {cost(meet)}")
    print(f"    m₁ ⊔ m₂ = {join}     cost = {cost(join)}")
    print(f"    cost(⊓) + cost(⊔) = {cost(meet)} + {cost(join)} = {cost(meet) + cost(join)}")
    print(f"    cost(m₁) + cost(m₂) = {cost(m1)} + {cost(m2)} = {cost(m1) + cost(m2)}")
    print(f"    Equal? {cost(meet) + cost(join) == cost(m1) + cost(m2)}  ✓")
    print()

    # Verify for many random-ish examples
    import random
    random.seed(42)
    violations = 0
    n_tests = 10000
    for _ in range(n_tests):
        n_voices = random.randint(2, 6)
        a = [random.randint(-10, 10) for _ in range(n_voices)]
        b = [random.randint(-10, 10) for _ in range(n_voices)]
        # Triangle inequality
        if cost(vec_add(a, b)) > cost(a) + cost(b):
            violations += 1
        # Lattice conservation
        if cost(vec_meet(a, b)) + cost(vec_join(a, b)) != cost(a) + cost(b):
            violations += 1
    print(f"  Stress test: {n_tests} random cases, {violations} violations  "
          f"{'✓' if violations == 0 else '✗'}")
    print()


def demo_full_quiver_statistics() -> None:
    """Complete statistics of the counterpoint quiver."""
    print("=" * 70)
    print("COMPLETE QUIVER STATISTICS")
    print("=" * 70)
    print()

    all_vls = all_voice_leadings()

    total_edges = 0
    edge_matrix: dict[tuple[int, int], int] = {}

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            count = sum(1 for vl in all_vls if is_permitted(i, j, vl))
            edge_matrix[(i, j)] = count
            total_edges += count

    print(f"  Vertices (consonant intervals): {len(CONSONANT)}")
    print(f"  Total edges (permitted VLs):    {total_edges}")
    print(f"  Edge density:                   {total_edges / (len(CONSONANT)**2 * 144):.3f}")
    print()

    # Adjacency matrix
    print("  Adjacency matrix (number of permitted VLs):")
    print(f"  {'':>8s}", end="")
    for j in sorted(CONSONANT):
        print(f"  {j:>5d}", end="")
    print()

    for i in sorted(CONSONANT):
        print(f"  {i:>8d}", end="")
        for j in sorted(CONSONANT):
            print(f"  {edge_matrix[(i, j)]:>5d}", end="")
        print()

    print()
    print(f"  Row sums (outgoing from each interval):")
    for i in sorted(CONSONANT):
        row_sum = sum(edge_matrix[(i, j)] for j in CONSONANT)
        name = INTERVAL_NAMES[i]
        print(f"    {name:<25s}: {row_sum}")

    print()
    print(f"  Column sums (incoming to each interval):")
    for j in sorted(CONSONANT):
        col_sum = sum(edge_matrix[(i, j)] for i in CONSONANT)
        name = INTERVAL_NAMES[j]
        itype = "(PERFECT)" if j in PERFECT else "(imperfect)"
        print(f"    {name:<25s} {itype:<12s}: {col_sum}")
    print()


# ============================================================================
# Section 3: Main
# ============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory                ║")
    print("║  Numerical Demonstrations of Formally Verified Results             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_cardinalities()
    demo_non_composability()
    demo_cost_function()
    demo_full_quiver_statistics()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
