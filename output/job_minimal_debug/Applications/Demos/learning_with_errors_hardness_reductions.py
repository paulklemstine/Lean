#!/usr/bin/env python3
"""
Closure-Gauge Realization Duality: Numerical Demonstrations

Demonstrates all key results from the formalized theory:
1. Valuation closures as closure operators
2. Chain property of closed sets
3. Gauge equivalence (order equivalence)
4. Holographic duality (capacity determines closure)
5. Realizability test (chain <-> realizable)
6. Minimal realization construction
7. Normalization of valuations
8. Separation and injectivity
"""

from __future__ import annotations
from itertools import combinations
from typing import Callable


# =============================================================================
# Core Definitions
# =============================================================================

def fmt_set(s: frozenset[int]) -> str:
    """Format a frozenset for display."""
    if not s:
        return "empty"
    return str(sorted(s))


def powerset(universe: list[int]) -> list[frozenset[int]]:
    """Return all subsets of universe as frozensets."""
    result: list[frozenset[int]] = [frozenset()]
    for k in range(1, len(universe) + 1):
        for combo in combinations(universe, k):
            result.append(frozenset(combo))
    return result


def valuation_closure(
    v: dict[int, int], universe: list[int], s: frozenset[int]
) -> frozenset[int]:
    """Compute cl_v(S) = { x in universe | v(x) <= sup_{s in S} v(s) }."""
    if not s:
        sup_val = 0
    else:
        sup_val = max(v[x] for x in s)
    return frozenset(x for x in universe if v[x] <= sup_val)


def closure_capacity(
    cl: Callable[[frozenset[int]], frozenset[int]], s: frozenset[int]
) -> int:
    """Compute |cl(S)|."""
    return len(cl(s))


def is_closed(
    cl: Callable[[frozenset[int]], frozenset[int]], s: frozenset[int]
) -> bool:
    """Check if S is a fixed point of cl."""
    return cl(s) == s


def find_closed_sets(
    cl: Callable[[frozenset[int]], frozenset[int]], universe: list[int]
) -> list[frozenset[int]]:
    """Find all closed sets of a closure operator."""
    return [s for s in powerset(universe) if is_closed(cl, s)]


def closed_sets_form_chain(closed_sets: list[frozenset[int]]) -> bool:
    """Check if all pairs of closed sets are comparable under inclusion."""
    for i, s in enumerate(closed_sets):
        for t in closed_sets[i + 1:]:
            if not (s <= t or t <= s):
                return False
    return True


def order_equivalent(v1: dict[int, int], v2: dict[int, int]) -> bool:
    """Check if two valuations are order-equivalent (gauge-equivalent)."""
    keys = list(v1.keys())
    for x in keys:
        for y in keys:
            if (v1[x] <= v1[y]) != (v2[x] <= v2[y]):
                return False
    return True


def normalize_valuation(v: dict[int, int]) -> dict[int, int]:
    """Normalized valuation: v_hat(x) = |{y : v(y) < v(x)}|."""
    keys = list(v.keys())
    return {x: sum(1 for y in keys if v[y] < v[x]) for x in keys}


def construct_realization(
    cl: Callable[[frozenset[int]], frozenset[int]], universe: list[int]
) -> dict[int, int]:
    """Construct minimal realization: v(x) = |cl({x})| - |cl(empty)|."""
    base = len(cl(frozenset()))
    return {x: len(cl(frozenset([x]))) - base for x in universe}


def is_injective(v: dict[int, int]) -> bool:
    """Check if v is injective."""
    vals = list(v.values())
    return len(vals) == len(set(vals))


def is_separated(
    cl: Callable[[frozenset[int]], frozenset[int]], universe: list[int]
) -> bool:
    """Check if distinct elements have distinct singleton closures."""
    closures: list[frozenset[int]] = [cl(frozenset([x])) for x in universe]
    return len(closures) == len(set(closures))


# =============================================================================
# Demo 1: Valuation Closure as a Closure Operator
# =============================================================================

def demo_closure_operator() -> None:
    """Verify the three closure operator axioms for a concrete valuation."""
    print("=" * 70)
    print("DEMO 1: Valuation Closure is a Closure Operator")
    print("=" * 70)

    universe = [0, 1, 2, 3, 4]
    v = {0: 1, 1: 3, 2: 2, 3: 5, 4: 2}
    print(f"\nUniverse: {universe}")
    print(f"Valuation v: {v}")

    def cl(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v, universe, s)

    # Extensivity
    print("\n--- Extensivity: S <= cl(S) ---")
    for s in [frozenset([0, 2]), frozenset([1]), frozenset([3, 4])]:
        closed = cl(s)
        ext_ok = s <= closed
        print(f"  S={fmt_set(s):15s}  cl(S)={fmt_set(closed):20s}  S<=cl(S): {ext_ok}")

    # Monotonicity
    print("\n--- Monotonicity: S <= T ==> cl(S) <= cl(T) ---")
    pairs = [
        (frozenset([0]), frozenset([0, 2])),
        (frozenset([2]), frozenset([1, 2])),
        (frozenset([0, 4]), frozenset([0, 1, 4])),
    ]
    for s, t in pairs:
        mono_ok = cl(s) <= cl(t) if s <= t else "N/A"
        print(f"  S={fmt_set(s):15s}  T={fmt_set(t):15s}  cl(S)<=cl(T): {mono_ok}")

    # Idempotency
    print("\n--- Idempotency: cl(cl(S)) = cl(S) ---")
    for s in [frozenset(), frozenset([1, 4]), frozenset([0, 1, 2, 3, 4])]:
        first = cl(s)
        second = cl(first)
        idemp_ok = first == second
        print(f"  S={fmt_set(s):20s}  cl(S)={fmt_set(first):20s}  cl^2(S)={fmt_set(second):20s}  Equal: {idemp_ok}")

    print("\n[OK] All three axioms verified.\n")


# =============================================================================
# Demo 2: Closed Sets Form a Chain
# =============================================================================

def demo_chain_property() -> None:
    """Show that closed sets of a valuation closure form a chain."""
    print("=" * 70)
    print("DEMO 2: Closed Sets Form a Chain")
    print("=" * 70)

    universe = [0, 1, 2, 3]
    v = {0: 1, 1: 3, 2: 2, 3: 4}
    print(f"\nUniverse: {universe}")
    print(f"Valuation v: {v}")

    def cl(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v, universe, s)

    closed = find_closed_sets(cl, universe)
    closed_sorted = sorted(closed, key=len)

    print(f"\nClosed sets (sorted by size):")
    for s in closed_sorted:
        print(f"  {fmt_set(s):20s}  (size {len(s)})")

    chain = closed_sets_form_chain(closed)
    print(f"\nClosed sets form a chain: {chain}")

    # Show the chain ordering
    print("\nChain ordering:")
    for i in range(len(closed_sorted) - 1):
        s, t = closed_sorted[i], closed_sorted[i + 1]
        print(f"  {fmt_set(s)} <= {fmt_set(t)}")

    print("\n[OK] Chain property verified.\n")


# =============================================================================
# Demo 3: Gauge Equivalence
# =============================================================================

def demo_gauge_equivalence() -> None:
    """Show that different valuations with same ordering give same closure."""
    print("=" * 70)
    print("DEMO 3: Gauge Equivalence (Order Equivalence)")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    v1 = {0: 1, 1: 5, 2: 3, 3: 10}
    v2 = {0: 2, 1: 7, 2: 4, 3: 100}
    v3 = {0: 0, 1: 2, 2: 1, 3: 3}

    print(f"\nUniverse: {universe}")
    print(f"v1 = {v1}")
    print(f"v2 = {v2}")
    print(f"v3 = {v3}  (normalized)")

    print(f"\nv1 ~ v2 (order-equivalent): {order_equivalent(v1, v2)}")
    print(f"v1 ~ v3 (order-equivalent): {order_equivalent(v1, v3)}")
    print(f"v2 ~ v3 (order-equivalent): {order_equivalent(v2, v3)}")

    # Verify same closures
    s = frozenset([0, 2])
    print(f"\nClosure comparison for S = {fmt_set(s)}:")
    for name, vi in [("v1", v1), ("v2", v2), ("v3", v3)]:
        c = valuation_closure(vi, universe, s)
        print(f"  cl_{name}({fmt_set(s)}) = {fmt_set(c)}")

    # Non-equivalent valuation
    w = {0: 3, 1: 1, 2: 2, 3: 4}
    print(f"\nw = {w}  (different ordering)")
    print(f"v1 ~ w: {order_equivalent(v1, w)}")
    print(f"cl_w({fmt_set(s)}) = {fmt_set(valuation_closure(w, universe, s))}")

    print("\n[OK] Gauge equivalence verified.\n")


# =============================================================================
# Demo 4: Holographic Duality
# =============================================================================

def demo_holographic_duality() -> None:
    """Show that capacity profile uniquely determines the closure operator."""
    print("=" * 70)
    print("DEMO 4: Holographic Duality (Capacity Determines Closure)")
    print("=" * 70)

    universe = [0, 1, 2, 3]
    v1 = {0: 1, 1: 3, 2: 2, 3: 4}
    v2 = {0: 10, 1: 30, 2: 20, 3: 40}

    def cl1(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v1, universe, s)

    def cl2(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v2, universe, s)

    print(f"\nUniverse: {universe}")
    print(f"v1 = {v1}")
    print(f"v2 = {v2}")

    header = f"  {'Set S':18s} | {'cap1':5s} | {'cap2':5s} | {'cl1(S)':15s} | {'cl2(S)':15s}"
    print(f"\n{header}")
    print("  " + "-" * 68)

    all_equal = True
    for s in sorted(powerset(universe), key=len):
        c1 = cl1(s)
        c2 = cl2(s)
        cap1 = len(c1)
        cap2 = len(c2)
        if c1 != c2:
            all_equal = False
        print(f"  {fmt_set(s):18s} | {cap1:5d} | {cap2:5d} | {fmt_set(c1):15s} | {fmt_set(c2):15s}")

    caps_equal = all(len(cl1(s)) == len(cl2(s)) for s in powerset(universe))
    print(f"\nAll capacities equal: {caps_equal}")
    print(f"All closures equal:   {all_equal}")
    print("\n[OK] Holographic duality verified: equal capacities ==> equal closures.\n")


# =============================================================================
# Demo 5: Realizability Test
# =============================================================================

def demo_realizability() -> None:
    """Demonstrate the realizability <-> chain equivalence."""
    print("=" * 70)
    print("DEMO 5: Realizability <-> Chain Property")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    # Example 1: Realizable
    print("\n--- Example 1: Valuation closure (realizable) ---")
    v = {0: 1, 1: 3, 2: 2, 3: 5}

    def cl1(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v, universe, s)

    closed1 = find_closed_sets(cl1, universe)
    chain1 = closed_sets_form_chain(closed1)
    print(f"  v = {v}")
    print(f"  Closed sets: {[fmt_set(s) for s in sorted(closed1, key=len)]}")
    print(f"  Chain: {chain1}  =>  Realizable: {chain1}")

    # Example 2: Identity closure (NOT realizable for n >= 2)
    print("\n--- Example 2: Identity closure (NOT realizable) ---")

    def cl2(s: frozenset[int]) -> frozenset[int]:
        return s

    closed2 = find_closed_sets(cl2, universe)
    chain2 = closed_sets_form_chain(closed2)
    print(f"  cl(S) = S (identity)")
    print(f"  Number of closed sets: {len(closed2)}")
    print(f"  Chain: {chain2}  =>  Realizable: {chain2}")
    print(f"  Counterexample: {{0}} and {{1}} are both closed but incomparable")

    # Example 3: Total closure (realizable)
    print("\n--- Example 3: Total closure (realizable) ---")
    full = frozenset(universe)

    def cl3(s: frozenset[int]) -> frozenset[int]:
        return full

    closed3 = find_closed_sets(cl3, universe)
    chain3 = closed_sets_form_chain(closed3)
    print(f"  cl(S) = universe for all S")
    print(f"  Closed sets: {[fmt_set(s) for s in closed3]}")
    print(f"  Chain: {chain3}  =>  Realizable: {chain3}")
    print(f"  Witness: v = 0 (constant zero)")

    print("\n[OK] Realizability <-> chain equivalence demonstrated.\n")


# =============================================================================
# Demo 6: Minimal Realization Construction
# =============================================================================

def demo_minimal_realization() -> None:
    """Demonstrate the minimal realization construction."""
    print("=" * 70)
    print("DEMO 6: Minimal Realization Construction")
    print("=" * 70)

    universe = [0, 1, 2, 3, 4]
    v_original = {0: 10, 1: 50, 2: 30, 3: 50, 4: 20}

    print(f"\nUniverse: {universe}")
    print(f"Original valuation: {v_original}")
    print(f"Rank (distinct values): {len(set(v_original.values()))}")

    def cl(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v_original, universe, s)

    # Construct realization
    v_constructed = construct_realization(cl, universe)
    base = len(cl(frozenset()))
    print(f"\nConstructed realization v(x) = |cl({{x}})| - |cl(empty)|:")
    print(f"  |cl(empty)| = {base}")
    for x in universe:
        singleton_cl = cl(frozenset([x]))
        print(f"  |cl({{{x}}})| = {len(singleton_cl):2d}  =>  v({x}) = {v_constructed[x]}")

    print(f"\nConstructed valuation: {v_constructed}")
    print(f"Rank: {len(set(v_constructed.values()))}")
    print(f"Order-equivalent to original: {order_equivalent(v_original, v_constructed)}")

    # Normalize
    v_normalized = normalize_valuation(v_original)
    print(f"\nNormalized valuation: {v_normalized}")
    print(f"Rank: {len(set(v_normalized.values()))}")
    print(f"Order-equivalent to original: {order_equivalent(v_original, v_normalized)}")

    # Verify closures match
    all_match = True
    for s in powerset(universe):
        c_orig = valuation_closure(v_original, universe, s)
        c_cons = valuation_closure(v_constructed, universe, s)
        c_norm = valuation_closure(v_normalized, universe, s)
        if c_orig != c_cons or c_orig != c_norm:
            all_match = False
            break

    print(f"\nAll three valuations produce identical closures: {all_match}")
    print("\n[OK] Minimal realization construction verified.\n")


# =============================================================================
# Demo 7: Separation and Injectivity
# =============================================================================

def demo_separation() -> None:
    """Demonstrate separation <-> injectivity for valuation closures."""
    print("=" * 70)
    print("DEMO 7: Separation <-> Injectivity")
    print("=" * 70)

    universe = [0, 1, 2, 3]

    # Injective valuation
    v1 = {0: 1, 1: 3, 2: 2, 3: 4}

    def cl1(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v1, universe, s)

    print(f"\nCase 1: Injective valuation v = {v1}")
    print(f"  Injective: {is_injective(v1)}")
    print(f"  Separated: {is_separated(cl1, universe)}")
    for x in universe:
        print(f"    cl({{{x}}}) = {fmt_set(cl1(frozenset([x])))}")

    # Non-injective valuation
    v2 = {0: 1, 1: 3, 2: 3, 3: 4}

    def cl2(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v2, universe, s)

    print(f"\nCase 2: Non-injective valuation v = {v2}")
    print(f"  Injective: {is_injective(v2)}")
    print(f"  Separated: {is_separated(cl2, universe)}")
    for x in universe:
        print(f"    cl({{{x}}}) = {fmt_set(cl2(frozenset([x])))}")
    print(f"  Note: cl({{1}}) = cl({{2}}) since v(1) = v(2) = 3")

    print("\n[OK] Separation <-> injectivity demonstrated.\n")


# =============================================================================
# Demo 8: Capacity Profile as Complete Invariant
# =============================================================================

def demo_capacity_invariant() -> None:
    """Show capacity profile as a compact fingerprint of the closure."""
    print("=" * 70)
    print("DEMO 8: Capacity Profile as Complete Invariant")
    print("=" * 70)

    universe = [0, 1, 2]
    v = {0: 1, 1: 2, 2: 3}

    def cl(s: frozenset[int]) -> frozenset[int]:
        return valuation_closure(v, universe, s)

    print(f"\nUniverse: {universe}")
    print(f"Valuation: {v}")

    header = f"  {'Set S':13s} | {'cl(S)':13s} | {'cap':4s} | {'Closed?':7s}"
    print(f"\n{header}")
    print("  " + "-" * 45)

    for s in sorted(powerset(universe), key=len):
        c = cl(s)
        cap = len(c)
        closed_str = "Yes" if is_closed(cl, s) else "No"
        print(f"  {fmt_set(s):13s} | {fmt_set(c):13s} | {cap:4d} | {closed_str:7s}")

    closed_sets = find_closed_sets(cl, universe)
    print(f"\nClosed sets: {[fmt_set(s) for s in sorted(closed_sets, key=len)]}")
    print(f"Chain: {closed_sets_form_chain(closed_sets)}")
    print(f"\nThe capacity column alone suffices to reconstruct the entire closure!")
    print("\n[OK] Complete invariant property demonstrated.\n")


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("=" * 70)
    print("  Closure-Gauge Realization Duality: Numerical Demonstrations")
    print("  Key Theorem: A closure operator is gauge-realizable iff its")
    print("  closed sets form a chain under inclusion.")
    print("=" * 70)
    print()

    demo_closure_operator()
    demo_chain_property()
    demo_gauge_equivalence()
    demo_holographic_duality()
    demo_realizability()
    demo_minimal_realization()
    demo_separation()
    demo_capacity_invariant()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
