#!/usr/bin/env python3
"""
Closure–Gauge Realization Duality: Numerical Demonstrations
============================================================

This script demonstrates the key results of the closure-gauge realization
duality theory through concrete numerical examples on small finite sets.

Results demonstrated:
1. Valuation closure is a closure operator (extensive, monotone, idempotent)
2. Closed sets of valuation closures form a chain
3. Gauge uniqueness: equal closures imply order-equivalent valuations
4. Holographic duality: capacity profiles determine closures
5. Realizability iff chain property
6. Normalization preserves order equivalence
7. Separation iff injectivity
"""

from __future__ import annotations

from itertools import chain as iterchain, combinations
from typing import Callable, FrozenSet


# ---------------------------------------------------------------------------
# Core types and helpers
# ---------------------------------------------------------------------------

Element = int
Subset = FrozenSet[int]


def powerset(universe: list[int]) -> list[Subset]:
    """Return all subsets of universe as frozensets."""
    result: list[Subset] = []
    for r in range(len(universe) + 1):
        for combo in combinations(universe, r):
            result.append(frozenset(combo))
    return result


def sup_v(v: Callable[[int], int], s: Subset) -> int:
    """Supremum of v over s, with sup(∅) = 0."""
    if not s:
        return 0
    return max(v(x) for x in s)


# ---------------------------------------------------------------------------
# Valuation closure
# ---------------------------------------------------------------------------

def valuation_cl(
    v: Callable[[int], int], s: Subset, universe: list[int]
) -> Subset:
    """cl_v(S) = {x in universe | v(x) <= sup_{s in S} v(s)}."""
    threshold = sup_v(v, s)
    return frozenset(x for x in universe if v(x) <= threshold)


def is_extensive(
    v: Callable[[int], int], s: Subset, universe: list[int]
) -> bool:
    """Check S ⊆ cl_v(S)."""
    return s.issubset(valuation_cl(v, s, universe))


def is_monotone(
    v: Callable[[int], int],
    s: Subset,
    t: Subset,
    universe: list[int],
) -> bool:
    """Check S ⊆ T => cl_v(S) ⊆ cl_v(T)."""
    if not s.issubset(t):
        return True  # vacuously true
    return valuation_cl(v, s, universe).issubset(valuation_cl(v, t, universe))


def is_idempotent(
    v: Callable[[int], int], s: Subset, universe: list[int]
) -> bool:
    """Check cl_v(cl_v(S)) = cl_v(S)."""
    cl_s = valuation_cl(v, s, universe)
    return valuation_cl(v, cl_s, universe) == cl_s


# ---------------------------------------------------------------------------
# Closed sets and chain property
# ---------------------------------------------------------------------------

def closed_sets(
    v: Callable[[int], int], universe: list[int]
) -> list[Subset]:
    """Return all closed sets of cl_v."""
    result: list[Subset] = []
    for s in powerset(universe):
        if valuation_cl(v, s, universe) == s:
            result.append(s)
    return result


def is_chain(sets: list[Subset]) -> bool:
    """Check if a collection of sets forms a chain under inclusion."""
    for i, s in enumerate(sets):
        for t in sets[i + 1 :]:
            if not (s.issubset(t) or t.issubset(s)):
                return False
    return True


# ---------------------------------------------------------------------------
# Gauge equivalence
# ---------------------------------------------------------------------------

def order_equivalent(
    v1: Callable[[int], int],
    v2: Callable[[int], int],
    universe: list[int],
) -> bool:
    """Check if v1 and v2 are order-equivalent."""
    for x in universe:
        for y in universe:
            if (v1(x) <= v1(y)) != (v2(x) <= v2(y)):
                return False
    return True


# ---------------------------------------------------------------------------
# Capacity and holographic duality
# ---------------------------------------------------------------------------

def capacity_profile(
    cl_fn: Callable[[Subset], Subset], universe: list[int]
) -> dict[Subset, int]:
    """Compute cap(S) = |cl(S)| for all subsets S."""
    return {s: len(cl_fn(s)) for s in powerset(universe)}


# ---------------------------------------------------------------------------
# Normalization
# ---------------------------------------------------------------------------

def normalize(
    v: Callable[[int], int], universe: list[int]
) -> Callable[[int], int]:
    """Normalized valuation: v_hat(x) = |{y : v(y) < v(x)}|."""
    def v_hat(x: int) -> int:
        return sum(1 for y in universe if v(y) < v(x))
    return v_hat


# ---------------------------------------------------------------------------
# Realizability check for an arbitrary closure
# ---------------------------------------------------------------------------

def discrete_cl(s: Subset, universe: list[int]) -> Subset:
    """Discrete (identity) closure: cl(S) = S."""
    return s


def total_cl(s: Subset, universe: list[int]) -> Subset:
    """Total closure: cl(S) = universe."""
    return frozenset(universe)


def get_closed_sets_of_cl(
    cl_fn: Callable[[Subset], Subset], universe: list[int]
) -> list[Subset]:
    """Find all closed sets of an arbitrary closure function."""
    return [s for s in powerset(universe) if cl_fn(s) == s]


# ---------------------------------------------------------------------------
# Demo 1: Closure operator properties
# ---------------------------------------------------------------------------

def demo_closure_operator() -> None:
    """Demonstrate that valuation closure is a closure operator."""
    print("=" * 70)
    print("DEMO 1: Valuation Closure is a Closure Operator")
    print("=" * 70)

    universe = [0, 1, 2, 3, 4]
    v_values = {0: 3, 1: 1, 2: 5, 3: 1, 4: 2}
    v: Callable[[int], int] = lambda x: v_values[x]

    print(f"\nUniverse: {universe}")
    print(f"Valuation v: {v_values}")
    print()

    all_subsets = powerset(universe)

    # Check extensiveness
    ext_ok = all(is_extensive(v, s, universe) for s in all_subsets)
    print(f"Extensive (S ⊆ cl(S) for all S):  {ext_ok}")

    # Check monotonicity
    mono_ok = all(
        is_monotone(v, s, t, universe)
        for s in all_subsets
        for t in all_subsets
    )
    print(f"Monotone (S⊆T ⟹ cl(S)⊆cl(T)):   {mono_ok}")

    # Check idempotence
    idem_ok = all(is_idempotent(v, s, universe) for s in all_subsets)
    print(f"Idempotent (cl(cl(S)) = cl(S)):    {idem_ok}")

    # Show some examples
    print("\nExamples:")
    for s_list in [[], [1], [1, 4], [0, 1, 2, 3, 4]]:
        s = frozenset(s_list)
        cl_s = valuation_cl(v, s, universe)
        print(f"  cl({sorted(s)}) = {sorted(cl_s)}  [sup = {sup_v(v, s)}]")


# ---------------------------------------------------------------------------
# Demo 2: Chain property
# ---------------------------------------------------------------------------

def demo_chain_property() -> None:
    """Demonstrate that closed sets form a chain."""
    print("\n" + "=" * 70)
    print("DEMO 2: Closed Sets Form a Chain")
    print("=" * 70)

    universe = [0, 1, 2, 3, 4]
    v_values = {0: 3, 1: 1, 2: 5, 3: 1, 4: 2}
    v: Callable[[int], int] = lambda x: v_values[x]

    print(f"\nValuation v: {v_values}")

    cs = closed_sets(v, universe)
    print(f"\nClosed sets ({len(cs)} total):")
    for s in sorted(cs, key=len):
        print(f"  {sorted(s)} (sup = {sup_v(v, s)})")

    chain_ok = is_chain(cs)
    print(f"\nClosed sets form a chain: {chain_ok}")

    # Compare with discrete closure
    print("\n--- Contrast: Discrete closure on {0, 1, 2} ---")
    small_univ = [0, 1, 2]
    disc_cs = get_closed_sets_of_cl(
        lambda s: discrete_cl(s, small_univ), small_univ
    )
    print(f"Closed sets: {[sorted(s) for s in sorted(disc_cs, key=len)]}")
    print(f"Form a chain: {is_chain(disc_cs)}")
    print("=> Discrete closure is NOT gauge-realizable (for n ≥ 2)")


# ---------------------------------------------------------------------------
# Demo 3: Gauge uniqueness
# ---------------------------------------------------------------------------

def demo_gauge_uniqueness() -> None:
    """Demonstrate that equal closures imply order-equivalent valuations."""
    print("\n" + "=" * 70)
    print("DEMO 3: Gauge Uniqueness — Equal Closures ⟹ Order Equivalence")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    v1_vals = {0: 2, 1: 5, 2: 1, 3: 5}
    v2_vals = {0: 10, 1: 100, 2: 3, 3: 100}
    v1: Callable[[int], int] = lambda x: v1_vals[x]
    v2: Callable[[int], int] = lambda x: v2_vals[x]

    print(f"\nv₁: {v1_vals}")
    print(f"v₂: {v2_vals}")

    # Check closures match
    closures_match = all(
        valuation_cl(v1, s, universe) == valuation_cl(v2, s, universe)
        for s in powerset(universe)
    )
    print(f"\nClosures match (cl_v₁ = cl_v₂): {closures_match}")

    oe = order_equivalent(v1, v2, universe)
    print(f"Order-equivalent: {oe}")

    # Show the ordering
    print("\nOrdering comparison:")
    for x in universe:
        for y in universe:
            if x < y:
                print(
                    f"  v₁({x})={v1(x)} ≤ v₁({y})={v1(y)}? {v1(x) <= v1(y)}  |  "
                    f"v₂({x})={v2(x)} ≤ v₂({y})={v2(y)}? {v2(x) <= v2(y)}"
                )


# ---------------------------------------------------------------------------
# Demo 4: Holographic duality
# ---------------------------------------------------------------------------

def demo_holographic_duality() -> None:
    """Demonstrate that capacity profiles determine closures."""
    print("\n" + "=" * 70)
    print("DEMO 4: Holographic Duality — Capacity Determines Closure")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    v1_vals = {0: 1, 1: 3, 2: 2, 3: 4}
    v2_vals = {0: 10, 1: 30, 2: 20, 3: 40}
    v1: Callable[[int], int] = lambda x: v1_vals[x]
    v2: Callable[[int], int] = lambda x: v2_vals[x]

    cl1 = lambda s: valuation_cl(v1, s, universe)
    cl2 = lambda s: valuation_cl(v2, s, universe)

    cap1 = capacity_profile(cl1, universe)
    cap2 = capacity_profile(cl2, universe)

    caps_match = all(cap1[s] == cap2[s] for s in cap1)
    closures_match = all(cl1(s) == cl2(s) for s in powerset(universe))

    print(f"\nv₁: {v1_vals}")
    print(f"v₂: {v2_vals}")
    print(f"\nCapacity profiles match: {caps_match}")
    print(f"Closures match: {closures_match}")
    print(f"=> Holographic duality confirmed: equal capacities ⟹ equal closures")

    # Show some capacities
    print("\nSample capacity values:")
    for s_list in [[], [0], [0, 2], [1, 3], [0, 1, 2, 3]]:
        s = frozenset(s_list)
        print(
            f"  cap({sorted(s)}) = {cap1[s]}  "
            f"[cl = {sorted(cl1(s))}]"
        )


# ---------------------------------------------------------------------------
# Demo 5: Normalization
# ---------------------------------------------------------------------------

def demo_normalization() -> None:
    """Demonstrate normalization preserves order equivalence."""
    print("\n" + "=" * 70)
    print("DEMO 5: Normalization Preserves Order Equivalence")
    print("=" * 70)

    universe = [0, 1, 2, 3, 4]
    v_values = {0: 100, 1: 7, 2: 42, 3: 7, 4: 255}
    v: Callable[[int], int] = lambda x: v_values[x]
    v_hat = normalize(v, universe)

    print(f"\nOriginal v:   {v_values}")
    v_hat_values = {x: v_hat(x) for x in universe}
    print(f"Normalized v̂: {v_hat_values}")

    oe = order_equivalent(v, v_hat, universe)
    print(f"\nOrder-equivalent: {oe}")

    # Show distinct values (rank)
    orig_rank = len(set(v_values.values()))
    norm_rank = len(set(v_hat_values.values()))
    print(f"Original rank: {orig_rank}")
    print(f"Normalized rank: {norm_rank}")
    print("=> Normalization is a minimal realization (uses fewest distinct values)")


# ---------------------------------------------------------------------------
# Demo 6: Separation and injectivity
# ---------------------------------------------------------------------------

def demo_separation() -> None:
    """Demonstrate separation iff injectivity."""
    print("\n" + "=" * 70)
    print("DEMO 6: Separation ↔ Injectivity")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    # Injective valuation
    v_inj_vals = {0: 1, 1: 2, 2: 3, 3: 4}
    v_inj: Callable[[int], int] = lambda x: v_inj_vals[x]

    # Non-injective valuation
    v_noninj_vals = {0: 1, 1: 2, 2: 2, 3: 4}
    v_noninj: Callable[[int], int] = lambda x: v_noninj_vals[x]

    print(f"\n--- Injective valuation: {v_inj_vals} ---")
    singletons_inj = {
        x: sorted(valuation_cl(v_inj, frozenset([x]), universe))
        for x in universe
    }
    for x, cl_x in singletons_inj.items():
        print(f"  cl({{ {x} }}) = {cl_x}")
    all_distinct = len(set(map(frozenset, singletons_inj.values()))) == len(universe)
    print(f"  All singleton closures distinct (separated): {all_distinct}")

    print(f"\n--- Non-injective valuation: {v_noninj_vals} ---")
    singletons_noninj = {
        x: sorted(valuation_cl(v_noninj, frozenset([x]), universe))
        for x in universe
    }
    for x, cl_x in singletons_noninj.items():
        print(f"  cl({{ {x} }}) = {cl_x}")
    all_distinct_2 = len(set(map(frozenset, singletons_noninj.values()))) == len(universe)
    print(f"  All singleton closures distinct (separated): {all_distinct_2}")
    print(f"  v(1) = v(2) = {v_noninj(1)} => cl({{1}}) = cl({{2}})")


# ---------------------------------------------------------------------------
# Demo 7: Realizability characterization
# ---------------------------------------------------------------------------

def demo_realizability() -> None:
    """Demonstrate realizability iff chain property."""
    print("\n" + "=" * 70)
    print("DEMO 7: Realizability ↔ Chain Property")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    # Total closure: always realizable
    print("\n--- Total closure cl(S) = universe ---")
    total_cs = get_closed_sets_of_cl(
        lambda s: total_cl(s, universe), universe
    )
    print(f"Closed sets: {[sorted(s) for s in sorted(total_cs, key=len)]}")
    print(f"Chain: {is_chain(total_cs)}")
    print(f"Realizable: YES (v = constant 0)")

    # Valuation closure: always realizable by construction
    v_vals = {0: 1, 1: 3, 2: 2, 3: 3}
    v: Callable[[int], int] = lambda x: v_vals[x]
    print(f"\n--- Valuation closure with v = {v_vals} ---")
    val_cs = closed_sets(v, universe)
    print(f"Closed sets: {[sorted(s) for s in sorted(val_cs, key=len)]}")
    print(f"Chain: {is_chain(val_cs)}")
    print(f"Realizable: YES (by definition)")

    # Discrete closure: not realizable for n >= 2
    print(f"\n--- Discrete closure cl(S) = S on {universe} ---")
    disc_cs = get_closed_sets_of_cl(
        lambda s: discrete_cl(s, universe), universe
    )
    print(f"Number of closed sets: {len(disc_cs)} (all 2^{len(universe)} subsets)")
    print(f"Chain: {is_chain(disc_cs)}")
    print(f"Realizable: NO (closed sets don't form a chain)")

    # Custom non-chain closure
    print(f"\n--- Custom closure: cl adds element 0 to every set ---")
    custom_cl = lambda s: s | frozenset([0]) if s else frozenset([0])
    custom_cs = get_closed_sets_of_cl(
        lambda s: custom_cl(s), universe
    )
    print(f"Closed sets: {[sorted(s) for s in sorted(custom_cs, key=len)]}")
    print(f"Chain: {is_chain(custom_cs)}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Closure–Gauge Realization Duality: Numerical Demonstrations       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_closure_operator()
    demo_chain_property()
    demo_gauge_uniqueness()
    demo_holographic_duality()
    demo_normalization()
    demo_separation()
    demo_realizability()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
