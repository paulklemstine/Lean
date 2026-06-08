#!/usr/bin/env python3
"""
Sonic Mathematics: Numerical Demonstrations of Counterpoint as Category Theory

Self-contained Python script demonstrating the key mathematical results from
the formalization of first-species counterpoint. All functions are inlined
with type hints.

Results demonstrated:
  1. The Counterpoint Quiver: strong connectivity, edge counts
  2. Self-loop asymmetry: perfect vs imperfect consonances
  3. Hom-set cardinalities: 61 vs 72 incoming edges
  4. Voice-swap asymmetry: negation does not preserve consonance
  5. Non-composability: two valid steps can compose into a forbidden one
  6. Voice-leading cost: seminorm properties, L¹-lattice identity
  7. Ascending sublattice properties
"""

from __future__ import annotations
from itertools import product
from typing import NamedTuple


# ── Section 1: Interval Classes and Consonance ─────────────────────────

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}
N: int = 12  # chromatic pitch classes


def mod12(x: int) -> int:
    """Reduce an integer modulo 12 to the canonical representative in [0, 11]."""
    return x % N


def target_interval(source: int, bass_motion: int, soprano_motion: int) -> int:
    """Compute the target interval given source interval and voice motions.

    If bass moves by b and soprano moves by s, the new interval is
    source + s - b (mod 12).
    """
    return mod12(source + soprano_motion - bass_motion)


def is_parallel(bass: int, soprano: int) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return mod12(bass) == mod12(soprano) and mod12(bass) != 0


class VoiceLeading(NamedTuple):
    bass: int
    soprano: int


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check whether a voice leading from source to target is permitted.

    Rules:
      1. Both source and target must be consonant
      2. The voice leading must actually produce the target interval
      3. Parallel motion into a perfect consonance is forbidden
    """
    if mod12(source) not in CONSONANT or mod12(target) not in CONSONANT:
        return False
    if target_interval(source, vl.bass, vl.soprano) != mod12(target):
        return False
    if mod12(target) in PERFECT and is_parallel(vl.bass, vl.soprano):
        return False
    return True


# ── Section 2: The Counterpoint Quiver ──────────────────────────────────

def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings in ZMod 12 × ZMod 12."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def hom_set(source: int, target: int) -> list[VoiceLeading]:
    """All permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


def print_separator(title: str) -> None:
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


# ── Demo 1: Strong Connectivity ────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Verify that every pair of consonant intervals has at least one
    permitted voice leading (Theorem 3.1: exists_permitted_voice_leading)."""
    print_separator("DEMO 1: Strong Connectivity of the Counterpoint Quiver")

    interval_names: dict[int, str] = {
        0: "Unison",   3: "Min 3rd",  4: "Maj 3rd",
        7: "Perf 5th", 8: "Min 6th",  9: "Maj 6th",
    }

    all_connected = True
    print(f"{'Source':<12} {'Target':<12} {'# VLs':>8}  {'Connected':>10}")
    print("-" * 50)

    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            vls = hom_set(src, tgt)
            connected = len(vls) > 0
            all_connected = all_connected and connected
            print(f"{interval_names[src]:<12} {interval_names[tgt]:<12} {len(vls):>8}  {'✓' if connected else '✗':>10}")

    print(f"\nAll pairs connected: {'YES ✓' if all_connected else 'NO ✗'}")
    print("→ The counterpoint quiver is strongly connected.")


# ── Demo 2: Self-Loop Asymmetry ────────────────────────────────────────

def demo_self_loop_asymmetry() -> None:
    """Verify that perfect consonances have 1 self-loop and imperfect have 12
    (Theorems: perfect_self_loop_unique, imperfect_self_loops_all)."""
    print_separator("DEMO 2: Self-Loop Asymmetry (Perfect vs Imperfect)")

    interval_names: dict[int, str] = {
        0: "Unison (P)", 3: "Min 3rd (I)", 4: "Maj 3rd (I)",
        7: "Perf 5th (P)", 8: "Min 6th (I)", 9: "Maj 6th (I)",
    }

    print(f"{'Interval':<16} {'Type':<12} {'Self-loops':>10}")
    print("-" * 42)

    for i in sorted(CONSONANT):
        loops = hom_set(i, i)
        itype = "Perfect" if i in PERFECT else "Imperfect"
        print(f"{interval_names[i]:<16} {itype:<12} {len(loops):>10}")

    print("\n→ Perfect consonances: exactly 1 self-loop (the identity).")
    print("→ Imperfect consonances: all 12 self-loops permitted.")
    print("   This is the categorical signature of the parallel-motion rule.")


# ── Demo 3: Hom-Set Cardinalities ──────────────────────────────────────

def demo_hom_set_counts() -> None:
    """Compute total incoming voice leadings for perfect vs imperfect targets
    (Theorems: total_permitted_to_perfect, total_permitted_to_imperfect)."""
    print_separator("DEMO 3: Hom-Set Cardinalities — The Perfect Consonance Bottleneck")

    for target_type, target_set in [("Perfect", PERFECT), ("Imperfect", IMPERFECT)]:
        for tgt in sorted(target_set):
            total = sum(len(hom_set(src, tgt)) for src in sorted(CONSONANT))
            name = {0: "Unison", 7: "Perf 5th", 3: "Min 3rd",
                    4: "Maj 3rd", 8: "Min 6th", 9: "Maj 6th"}[tgt]
            print(f"  Total incoming to {name:<12} ({target_type:<10}): {total}")

    perf_total = sum(
        len(hom_set(src, tgt))
        for tgt in PERFECT for src in CONSONANT
    ) // len(PERFECT)
    imp_total = sum(
        len(hom_set(src, tgt))
        for tgt in IMPERFECT for src in CONSONANT
    ) // len(IMPERFECT)

    print(f"\n  Average incoming to perfect consonance:   {perf_total}")
    print(f"  Average incoming to imperfect consonance: {imp_total}")
    print(f"  Ratio: {perf_total/imp_total:.3f} (≈15% reduction for perfect)")
    print("\n→ Perfect consonances are harder to reach: a measurable bottleneck.")


# ── Demo 4: Voice-Swap Asymmetry ───────────────────────────────────────

def demo_voice_swap() -> None:
    """Show that negation mod 12 does not preserve consonance
    (Theorem: voice_swap_breaks_consonance)."""
    print_separator("DEMO 4: Voice-Swap Asymmetry")

    print(f"{'Interval i':<15} {'−i mod 12':>10} {'Consonant?':>12} {'Preserved?':>12}")
    print("-" * 52)

    for i in sorted(CONSONANT):
        neg_i = mod12(-i)
        is_cons = neg_i in CONSONANT
        preserved = "✓" if is_cons else "✗ BROKEN"
        name = {0: "Unison(0)", 3: "Min3(3)", 4: "Maj3(4)",
                7: "Perf5(7)", 8: "Min6(8)", 9: "Maj6(9)"}[i]
        print(f"{name:<15} {neg_i:>10} {str(is_cons):>12} {preserved:>12}")

    print("\n→ The perfect fifth (7) maps to perfect fourth (5), which is NOT consonant.")
    print("   Voice-swapping breaks consonance. The bass voice has a privileged role.")


# ── Demo 5: Non-Composability ──────────────────────────────────────────

def demo_non_composability() -> None:
    """Find concrete examples where two permitted voice leadings compose
    into a forbidden one (Theorem: non_composability)."""
    print_separator("DEMO 5: Non-Composability of Permitted Voice Leadings")

    examples_found = 0
    max_examples = 5

    for i in sorted(CONSONANT):
        if examples_found >= max_examples:
            break
        for j in sorted(CONSONANT):
            if examples_found >= max_examples:
                break
            for k in sorted(CONSONANT):
                if examples_found >= max_examples:
                    break
                vls_ij = hom_set(i, j)
                vls_jk = hom_set(j, k)
                for vl1 in vls_ij:
                    if examples_found >= max_examples:
                        break
                    for vl2 in vls_jk:
                        if examples_found >= max_examples:
                            break
                        # Compose: bass motions add, soprano motions add
                        comp = VoiceLeading(
                            mod12(vl1.bass + vl2.bass),
                            mod12(vl1.soprano + vl2.soprano)
                        )
                        # Check if composition is NOT permitted from i to k
                        if not is_permitted(i, k, comp):
                            examples_found += 1
                            print(f"  Example {examples_found}:")
                            print(f"    Step 1: {i} → {j} via ({vl1.bass}, {vl1.soprano}) ✓ permitted")
                            print(f"    Step 2: {j} → {k} via ({vl2.bass}, {vl2.soprano}) ✓ permitted")
                            print(f"    Composed: {i} → {k} via ({comp.bass}, {comp.soprano}) ✗ FORBIDDEN")
                            why = "parallel into perfect" if (mod12(k) in PERFECT and is_parallel(comp.bass, comp.soprano)) else "target not consonant"
                            print(f"    Reason: {why}\n")

    if examples_found > 0:
        print(f"→ Found {examples_found} counterexamples. Permitted voice leadings do NOT compose.")
        print("   The counterpoint quiver fails to form a category.")
    else:
        print("→ No counterexamples found (unexpected).")


# ── Demo 6: Voice-Leading Cost Seminorm ─────────────────────────────────

def voice_leading_cost(m: list[int]) -> int:
    """L¹ norm of a voice motion vector: cost(m) = Σ|mᵢ|."""
    return sum(abs(x) for x in m)


def componentwise_min(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice meet: componentwise minimum."""
    return [min(a, b) for a, b in zip(m1, m2)]


def componentwise_max(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice join: componentwise maximum."""
    return [max(a, b) for a, b in zip(m1, m2)]


def demo_seminorm() -> None:
    """Verify seminorm properties and the L¹-lattice identity
    (Theorems: cost_seminorm_properties, cost_meet_join_eq)."""
    print_separator("DEMO 6: Voice-Leading Cost — Seminorm & L¹-Lattice Identity")

    # Test vectors (2-voice motions)
    test_pairs: list[tuple[list[int], list[int]]] = [
        ([3, -1], [1, 4]),
        ([-2, 5], [3, -3]),
        ([0, 0], [7, -2]),
        ([4, 4], [-4, -4]),
        ([1, -6], [2, 3]),
    ]

    print("── Triangle Inequality: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂)")
    print(f"{'m₁':<15} {'m₂':<15} {'cost(m₁+m₂)':>12} {'cost(m₁)+cost(m₂)':>20} {'Valid':>6}")
    print("-" * 72)

    for m1, m2 in test_pairs:
        m_sum = [a + b for a, b in zip(m1, m2)]
        c_sum = voice_leading_cost(m_sum)
        c_add = voice_leading_cost(m1) + voice_leading_cost(m2)
        valid = c_sum <= c_add
        print(f"{str(m1):<15} {str(m2):<15} {c_sum:>12} {c_add:>20} {'✓' if valid else '✗':>6}")

    print("\n── L¹-Lattice Identity: cost(m₁ ∧ m₂) + cost(m₁ ∨ m₂) = cost(m₁) + cost(m₂)")
    print(f"{'m₁':<12} {'m₂':<12} {'meet':<12} {'join':<12} {'LHS':>6} {'RHS':>6} {'Equal':>6}")
    print("-" * 68)

    all_equal = True
    for m1, m2 in test_pairs:
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        lhs = voice_leading_cost(meet) + voice_leading_cost(join)
        rhs = voice_leading_cost(m1) + voice_leading_cost(m2)
        eq = lhs == rhs
        all_equal = all_equal and eq
        print(f"{str(m1):<12} {str(m2):<12} {str(meet):<12} {str(join):<12} {lhs:>6} {rhs:>6} {'✓' if eq else '✗':>6}")

    print(f"\nAll identities hold: {'YES ✓' if all_equal else 'NO ✗'}")

    print("\n── Absolute Homogeneity: cost(c·m) = |c|·cost(m)")
    m = [3, -2, 1]
    for c in [-3, -1, 0, 1, 2, 5]:
        cm = [c * x for x in m]
        lhs = voice_leading_cost(cm)
        rhs = abs(c) * voice_leading_cost(m)
        print(f"  c={c:>3}, m={m}, cost(c·m)={lhs:>3}, |c|·cost(m)={rhs:>3}  {'✓' if lhs == rhs else '✗'}")

    print("\n── Zero characterization: cost(m) = 0 ⟺ m = 0")
    for m in [[0, 0], [0, 0, 0], [1, 0], [0, -1]]:
        c = voice_leading_cost(m)
        is_zero = all(x == 0 for x in m)
        print(f"  m={str(m):<12} cost={c:>2}  m=0? {is_zero}  cost=0? {c==0}  ⟺ holds: {'✓' if is_zero == (c==0) else '✗'}")

    print("\n→ Voice-leading cost is a seminorm (in fact, a norm) on ℤⁿ.")


# ── Demo 7: Ascending Sublattice ────────────────────────────────────────

def demo_ascending_sublattice() -> None:
    """Verify ascending motions form a sublattice and cost simplification
    (Theorems: ascending_meet, ascending_join, ascending_cost_eq_sum)."""
    print_separator("DEMO 7: The Ascending Motion Sublattice")

    ascending_pairs: list[tuple[list[int], list[int]]] = [
        ([1, 3], [2, 1]),
        ([0, 5, 2], [3, 0, 4]),
        ([4, 4], [1, 7]),
    ]

    print("── Closure under meet and join")
    print(f"{'m₁':<15} {'m₂':<15} {'meet':<15} {'join':<15} {'meet asc':>9} {'join asc':>9}")
    print("-" * 80)

    for m1, m2 in ascending_pairs:
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        meet_asc = all(x >= 0 for x in meet)
        join_asc = all(x >= 0 for x in join)
        print(f"{str(m1):<15} {str(m2):<15} {str(meet):<15} {str(join):<15} {'✓' if meet_asc else '✗':>9} {'✓' if join_asc else '✗':>9}")

    print("\n── Cost simplification: for ascending m, cost(m) = Σmᵢ")
    for m1, m2 in ascending_pairs:
        for m in [m1, m2]:
            c = voice_leading_cost(m)
            s = sum(m)
            print(f"  m={str(m):<15}  cost={c:>3}  sum={s:>3}  equal: {'✓' if c == s else '✗'}")

    print("\n── Meet cost ≤ original costs (ascending_meet_cost_le)")
    for m1, m2 in ascending_pairs:
        meet = componentwise_min(m1, m2)
        c_meet = voice_leading_cost(meet)
        c1 = voice_leading_cost(m1)
        c2 = voice_leading_cost(m2)
        print(f"  m₁={str(m1):<12} m₂={str(m2):<12}  cost(meet)={c_meet:>3} ≤ cost(m₁)={c1:>3}: {'✓' if c_meet <= c1 else '✗'}  ≤ cost(m₂)={c2:>3}: {'✓' if c_meet <= c2 else '✗'}")

    print("\n→ Ascending motions form a sublattice with simplified cost computation.")


# ── Demo 8: Full Quiver Statistics ──────────────────────────────────────

def demo_quiver_statistics() -> None:
    """Print a comprehensive summary of the counterpoint quiver."""
    print_separator("DEMO 8: Full Quiver Statistics")

    total_edges = 0
    edge_matrix: dict[tuple[int, int], int] = {}

    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            count = len(hom_set(src, tgt))
            edge_matrix[(src, tgt)] = count
            total_edges += count

    # Print adjacency matrix
    header = "     " + "".join(f"{t:>6}" for t in sorted(CONSONANT))
    print(f"Adjacency matrix (|Hom(row, col)|):\n{header}")
    for src in sorted(CONSONANT):
        row = f"{src:>3}  " + "".join(f"{edge_matrix[(src, tgt)]:>6}" for tgt in sorted(CONSONANT))
        print(row)

    print(f"\nTotal edges in quiver: {total_edges}")
    print(f"Vertices: {len(CONSONANT)}")
    print(f"Max possible edges (no constraints): {len(CONSONANT)**2 * N**2}")
    print(f"Edge density: {total_edges / (len(CONSONANT)**2 * N**2):.4f}")

    # Incoming totals
    print(f"\nIncoming edge totals by target:")
    for tgt in sorted(CONSONANT):
        total_in = sum(edge_matrix[(src, tgt)] for src in sorted(CONSONANT))
        ttype = "P" if tgt in PERFECT else "I"
        print(f"  Interval {tgt:>2} ({ttype}): {total_in:>4} incoming")


# ── Main ────────────────────────────────────────────────────────────────

def main() -> None:
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory                 ║")
    print("║  Numerical demonstrations of formally verified results              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_strong_connectivity()
    demo_self_loop_asymmetry()
    demo_hom_set_counts()
    demo_voice_swap()
    demo_non_composability()
    demo_seminorm()
    demo_ascending_sublattice()
    demo_quiver_statistics()

    print_separator("ALL DEMONSTRATIONS COMPLETE")
    print("All numerical results match the formally verified theorems.")
    print("The counterpoint quiver has been fully characterized.")


if __name__ == "__main__":
    main()
