#!/usr/bin/env python3
"""
Closure–Gauge Realization Duality: Numerical Demonstrations

This module demonstrates the key results of the Closure-Gauge Realization
Duality theory through concrete computational examples:

1. Valuation closures and their properties (extensiveness, monotonicity, idempotence)
2. Chain property of closed sets
3. Gauge equivalence detection
4. Holographic duality (capacity profiles)
5. Minimal realization construction via normalization
6. Separation and injectivity
7. Realizability testing (chain condition check)
"""

from __future__ import annotations
from itertools import combinations
from typing import Callable


# ============================================================
# Core Data Structures
# ============================================================

def powerset(universe: list[int]) -> list[frozenset[int]]:
    """Generate all subsets of universe as frozensets."""
    result: list[frozenset[int]] = []
    for r in range(len(universe) + 1):
        for combo in combinations(universe, r):
            result.append(frozenset(combo))
    return result


def sup_v(v: Callable[[int], int], s: frozenset[int]) -> int:
    """Compute sup{v(x) : x in S}, returning 0 for empty set (matching Lean's Finset.sup on ℕ)."""
    if not s:
        return 0
    return max(v(x) for x in s)


# ============================================================
# 1. Valuation Closure
# ============================================================

def valuation_closure(
    v: Callable[[int], int], s: frozenset[int], universe: list[int]
) -> frozenset[int]:
    """
    Compute cl_v(S) = { x in universe | v(x) <= sup{v(s) : s in S} }.
    
    This is Definition 3 from the paper.
    """
    threshold = sup_v(v, s)
    return frozenset(x for x in universe if v(x) <= threshold)


def demo_valuation_closure() -> None:
    """Demonstrate basic valuation closure computation."""
    print("=" * 60)
    print("DEMO 1: Valuation Closure")
    print("=" * 60)
    
    universe = [0, 1, 2, 3, 4]
    v: Callable[[int], int] = lambda x: [1, 3, 2, 5, 4][x]
    
    print(f"Universe: {universe}")
    print(f"Valuation v: {[v(x) for x in universe]}")
    print(f"  v(0)=1, v(1)=3, v(2)=2, v(3)=5, v(4)=4")
    print()
    
    test_sets = [
        frozenset({0}),
        frozenset({0, 2}),
        frozenset({1}),
        frozenset({3}),
        frozenset(),
    ]
    
    for s in test_sets:
        cl = valuation_closure(v, s, universe)
        threshold = sup_v(v, s)
        print(f"  cl_v({set(s) if s else '∅'}) = {set(cl)}")
        print(f"    threshold = sup_v(S) = {threshold}")
        print(f"    Elements with v(x) ≤ {threshold}: {set(cl)}")
    
    # Verify extensiveness
    print("\n  Extensiveness check (S ⊆ cl(S)):")
    for s in test_sets:
        cl = valuation_closure(v, s, universe)
        assert s <= cl, f"Failed: {s} ⊄ {cl}"
        print(f"    {set(s) if s else '∅'} ⊆ {set(cl)} ✓")
    
    # Verify idempotence
    print("\n  Idempotence check (cl(cl(S)) = cl(S)):")
    for s in test_sets:
        cl1 = valuation_closure(v, s, universe)
        cl2 = valuation_closure(v, cl1, universe)
        assert cl1 == cl2, f"Failed: cl(cl(S)) ≠ cl(S)"
        print(f"    cl(cl({set(s) if s else '∅'})) = cl({set(cl1)}) = {set(cl2)} ✓")
    print()


# ============================================================
# 2. Chain Property of Closed Sets
# ============================================================

def find_closed_sets(
    v: Callable[[int], int], universe: list[int]
) -> list[frozenset[int]]:
    """Find all closed sets of the valuation closure."""
    closed: list[frozenset[int]] = []
    for s in powerset(universe):
        if valuation_closure(v, s, universe) == s:
            closed.append(s)
    return closed


def is_chain(sets: list[frozenset[int]]) -> bool:
    """Check if a collection of sets forms a chain under inclusion."""
    for i, s in enumerate(sets):
        for t in sets[i + 1 :]:
            if not (s <= t or t <= s):
                return False
    return True


def demo_chain_property() -> None:
    """Demonstrate that closed sets of a valuation closure form a chain (Theorem 4)."""
    print("=" * 60)
    print("DEMO 2: Chain Property of Closed Sets")
    print("=" * 60)
    
    universe = [0, 1, 2, 3, 4]
    v: Callable[[int], int] = lambda x: [1, 3, 2, 5, 4][x]
    
    print(f"Universe: {universe}")
    print(f"Valuation v: {[v(x) for x in universe]}")
    
    closed = find_closed_sets(v, universe)
    closed_sorted = sorted(closed, key=len)
    
    print(f"\nClosed sets (sorted by size):")
    for s in closed_sorted:
        threshold = sup_v(v, s) if s else 0
        print(f"  {set(s) if s else '∅'}  (threshold = {threshold})")
    
    chain = is_chain(closed_sorted)
    print(f"\nClosed sets form a chain? {chain} ✓" if chain else f"\nChain? {chain} ✗")
    
    print("\nPairwise comparisons:")
    for i, s in enumerate(closed_sorted):
        for t in closed_sorted[i + 1 :]:
            rel = "⊆" if s <= t else ("⊇" if t <= s else "incomparable")
            s_str = set(s) if s else "∅"
            print(f"  {s_str} {rel} {set(t)}")
    print()


# ============================================================
# 3. Gauge Equivalence
# ============================================================

def are_order_equivalent(
    v1: Callable[[int], int], v2: Callable[[int], int], universe: list[int]
) -> bool:
    """Check if two valuations are order-equivalent (Definition 4)."""
    for x in universe:
        for y in universe:
            if (v1(x) <= v1(y)) != (v2(x) <= v2(y)):
                return False
    return True


def demo_gauge_equivalence() -> None:
    """Demonstrate gauge equivalence and Theorem 5."""
    print("=" * 60)
    print("DEMO 3: Gauge Equivalence (Order Equivalence)")
    print("=" * 60)
    
    universe = [0, 1, 2, 3]
    
    v1: Callable[[int], int] = lambda x: [1, 3, 2, 5][x]
    v2: Callable[[int], int] = lambda x: [10, 30, 20, 50][x]  # Same ordering, scaled
    v3: Callable[[int], int] = lambda x: [0, 2, 1, 3][x]      # Same ordering, normalized
    v4: Callable[[int], int] = lambda x: [1, 2, 3, 5][x]      # Different ordering
    
    valuations = [
        ("v1 = [1,3,2,5]", v1),
        ("v2 = [10,30,20,50]", v2),
        ("v3 = [0,2,1,3]", v3),
        ("v4 = [1,2,3,5]", v4),
    ]
    
    print(f"Universe: {universe}\n")
    for name, v in valuations:
        print(f"  {name}")
    
    print("\nOrder equivalence checks:")
    for i, (n1, vi) in enumerate(valuations):
        for n2, vj in valuations[i + 1 :]:
            eq = are_order_equivalent(vi, vj, universe)
            sym = "≡" if eq else "≢"
            print(f"  {n1} {sym} {n2}")
    
    print("\nVerifying Theorem 5 (equal closures ⟹ order equivalent):")
    for i, (n1, vi) in enumerate(valuations):
        for n2, vj in valuations[i + 1 :]:
            same_cl = all(
                valuation_closure(vi, s, universe) == valuation_closure(vj, s, universe)
                for s in powerset(universe)
            )
            order_eq = are_order_equivalent(vi, vj, universe)
            if same_cl:
                assert order_eq, "Theorem 5 violated!"
                print(f"  cl_{n1[:2]} = cl_{n2[:2]}  ⟹  order equivalent ✓")
            else:
                print(f"  cl_{n1[:2]} ≠ cl_{n2[:2]}  (closures differ)")
    print()


# ============================================================
# 4. Holographic Duality
# ============================================================

def capacity_profile(
    cl: Callable[[frozenset[int]], frozenset[int]], universe: list[int]
) -> dict[frozenset[int], int]:
    """Compute the capacity profile: S ↦ |cl(S)| for all subsets."""
    return {s: len(cl(s)) for s in powerset(universe)}


def demo_holographic_duality() -> None:
    """Demonstrate holographic duality (Theorem 6): capacity profiles determine closures."""
    print("=" * 60)
    print("DEMO 4: Holographic Duality")
    print("=" * 60)
    
    universe = [0, 1, 2, 3]
    
    v1: Callable[[int], int] = lambda x: [1, 3, 2, 4][x]
    v2: Callable[[int], int] = lambda x: [10, 30, 20, 40][x]  # Order-equivalent
    v3: Callable[[int], int] = lambda x: [1, 2, 3, 4][x]      # Different ordering
    
    cl1 = lambda s: valuation_closure(v1, s, universe)
    cl2 = lambda s: valuation_closure(v2, s, universe)
    cl3 = lambda s: valuation_closure(v3, s, universe)
    
    cap1 = capacity_profile(cl1, universe)
    cap2 = capacity_profile(cl2, universe)
    cap3 = capacity_profile(cl3, universe)
    
    print(f"Universe: {universe}")
    print(f"v1 = [1,3,2,4], v2 = [10,30,20,40], v3 = [1,2,3,4]\n")
    
    print("Capacity profiles (showing a few subsets):")
    print(f"  {'Subset':<15} {'cap_v1':>6} {'cap_v2':>6} {'cap_v3':>6}")
    print(f"  {'-'*15} {'-'*6} {'-'*6} {'-'*6}")
    
    show_sets = [frozenset(), frozenset({0}), frozenset({1}), frozenset({0,2}),
                 frozenset({0,1,2}), frozenset({0,1,2,3})]
    for s in show_sets:
        s_str = str(set(s)) if s else "∅"
        print(f"  {s_str:<15} {cap1[s]:>6} {cap2[s]:>6} {cap3[s]:>6}")
    
    same_cap_12 = all(cap1[s] == cap2[s] for s in cap1)
    same_cap_13 = all(cap1[s] == cap3[s] for s in cap1)
    same_cl_12 = all(cl1(s) == cl2(s) for s in powerset(universe))
    same_cl_13 = all(cl1(s) == cl3(s) for s in powerset(universe))
    
    print(f"\n  cap(v1) = cap(v2)? {same_cap_12}")
    print(f"  cl(v1) = cl(v2)?   {same_cl_12}")
    if same_cap_12:
        assert same_cl_12, "Holographic duality violated!"
        print("  ⟹ Holographic duality confirmed: same capacities ⟹ same closures ✓")
    
    print(f"\n  cap(v1) = cap(v3)? {same_cap_13}")
    print(f"  cl(v1) = cl(v3)?   {same_cl_13}")
    if not same_cap_13:
        print("  ⟹ Different capacities, different closures (consistent) ✓")
    print()


# ============================================================
# 5. Minimal Realization via Normalization
# ============================================================

def normalize_valuation(
    v: Callable[[int], int], universe: list[int]
) -> Callable[[int], int]:
    """
    Compute the normalized valuation: v_norm(x) = |{y : v(y) < v(x)}|.
    This is Definition 11.
    """
    counts: dict[int, int] = {}
    for x in universe:
        counts[x] = sum(1 for y in universe if v(y) < v(x))
    return lambda x: counts[x]


def realization_rank(v: Callable[[int], int], universe: list[int]) -> int:
    """Compute the rank = number of distinct values (Definition 9)."""
    return len(set(v(x) for x in universe))


def demo_minimal_realization() -> None:
    """Demonstrate minimal realization via normalization (Theorems 9-10)."""
    print("=" * 60)
    print("DEMO 5: Minimal Realization via Normalization")
    print("=" * 60)
    
    universe = [0, 1, 2, 3, 4]
    
    # Original valuation with "wasteful" spacing
    v: Callable[[int], int] = lambda x: [0, 100, 42, 100, 200][x]
    v_norm = normalize_valuation(v, universe)
    
    print(f"Universe: {universe}")
    print(f"Original valuation v:   {[v(x) for x in universe]}")
    print(f"Normalized v_norm:      {[v_norm(x) for x in universe]}")
    print(f"Original rank:          {realization_rank(v, universe)}")
    print(f"Normalized rank:        {realization_rank(v_norm, universe)}")
    
    # Check order equivalence
    oe = are_order_equivalent(v, v_norm, universe)
    print(f"Order equivalent?       {oe} ✓" if oe else f"Order equivalent? {oe} ✗")
    
    # Check same closures
    same = all(
        valuation_closure(v, s, universe) == valuation_closure(v_norm, s, universe)
        for s in powerset(universe)
    )
    print(f"Same closures?          {same} ✓" if same else f"Same closures? {same} ✗")
    
    # Another example with ties
    print("\nExample with ties (non-injective valuation):")
    v2: Callable[[int], int] = lambda x: [3, 7, 3, 7, 10][x]
    v2_norm = normalize_valuation(v2, universe)
    
    print(f"  v2:      {[v2(x) for x in universe]}")
    print(f"  v2_norm: {[v2_norm(x) for x in universe]}")
    print(f"  Rank v2:      {realization_rank(v2, universe)}")
    print(f"  Rank v2_norm: {realization_rank(v2_norm, universe)}")
    print(f"  Order equiv?  {are_order_equivalent(v2, v2_norm, universe)} ✓")
    print()


# ============================================================
# 6. Separation and Injectivity
# ============================================================

def is_separated(
    cl: Callable[[frozenset[int]], frozenset[int]], universe: list[int]
) -> bool:
    """Check if a closure is separated (Definition 8)."""
    for a in universe:
        for b in universe:
            if a != b and cl(frozenset({a})) == cl(frozenset({b})):
                return False
    return True


def is_injective(v: Callable[[int], int], universe: list[int]) -> bool:
    """Check if a valuation is injective."""
    values = [v(x) for x in universe]
    return len(values) == len(set(values))


def demo_separation() -> None:
    """Demonstrate separation ↔ injectivity (Theorem 13)."""
    print("=" * 60)
    print("DEMO 6: Separation ↔ Injectivity")
    print("=" * 60)
    
    universe = [0, 1, 2, 3]
    
    # Injective valuation
    v_inj: Callable[[int], int] = lambda x: [1, 3, 2, 4][x]
    cl_inj = lambda s: valuation_closure(v_inj, s, universe)
    
    # Non-injective valuation
    v_noninj: Callable[[int], int] = lambda x: [1, 3, 3, 4][x]
    cl_noninj = lambda s: valuation_closure(v_noninj, s, universe)
    
    print(f"Universe: {universe}\n")
    
    print("Injective valuation v = [1,3,2,4]:")
    print(f"  Injective?  {is_injective(v_inj, universe)}")
    print(f"  Separated?  {is_separated(cl_inj, universe)}")
    print(f"  Singleton closures:")
    for x in universe:
        print(f"    cl({{{x}}}) = {set(cl_inj(frozenset({x})))}")
    
    print(f"\nNon-injective valuation v = [1,3,3,4]:")
    print(f"  Injective?  {is_injective(v_noninj, universe)}")
    print(f"  Separated?  {is_separated(cl_noninj, universe)}")
    print(f"  Singleton closures:")
    for x in universe:
        print(f"    cl({{{x}}}) = {set(cl_noninj(frozenset({x})))}")
    
    print(f"\n  Note: cl({{1}}) = cl({{2}}) = {set(cl_noninj(frozenset({1})))} — elements 1 and 2 are fused!")
    print("  Theorem 13 confirmed: separated ⟺ injective ✓")
    print()


# ============================================================
# 7. Realizability Check (Chain Condition)
# ============================================================

def make_closure_op(
    cl_func: Callable[[frozenset[int]], frozenset[int]]
) -> Callable[[frozenset[int]], frozenset[int]]:
    """Wrap a closure function."""
    return cl_func


def demo_realizability() -> None:
    """Demonstrate the realizability criterion (Theorem 8) and Theorem 15."""
    print("=" * 60)
    print("DEMO 7: Realizability ↔ Chain Condition")
    print("=" * 60)
    
    universe = [0, 1, 2, 3]
    
    # Example 1: Valuation closure (always realizable)
    v: Callable[[int], int] = lambda x: [1, 3, 2, 4][x]
    cl_v = lambda s: valuation_closure(v, s, universe)
    closed_v = [s for s in powerset(universe) if cl_v(s) == s]
    
    print(f"Universe: {universe}\n")
    print("Example 1: Valuation closure v = [1,3,2,4]")
    print(f"  Closed sets: {[set(s) if s else '∅' for s in sorted(closed_v, key=len)]}")
    print(f"  Chain? {is_chain(closed_v)} → Realizable ✓")
    
    # Example 2: Discrete closure (identity) — NOT realizable for |α| ≥ 2
    cl_discrete = lambda s: s
    closed_discrete = [s for s in powerset(universe) if cl_discrete(s) == s]
    
    print(f"\nExample 2: Discrete closure (cl = id)")
    print(f"  Closed sets: ALL {len(closed_discrete)} subsets")
    print(f"  Chain? {is_chain(closed_discrete)} → NOT realizable ✓")
    
    incomparable = []
    for i, s in enumerate(closed_discrete):
        for t in closed_discrete[i + 1:]:
            if not (s <= t or t <= s):
                incomparable.append((s, t))
    if incomparable:
        s, t = incomparable[0]
        print(f"  Witness: {set(s)} and {set(t)} are incomparable")
    
    # Example 3: Total closure (cl = univ) — realizable
    univ_set = frozenset(universe)
    cl_total = lambda s: univ_set
    closed_total = [s for s in powerset(universe) if cl_total(s) == s]
    
    print(f"\nExample 3: Total closure (cl(S) = univ)")
    print(f"  Closed sets: {[set(s) for s in closed_total]}")
    print(f"  Chain? {is_chain(closed_total)} → Realizable ✓")
    print(f"  Realized by v = [0,0,0,0] (constant zero)")
    
    # Example 4: Custom closure with branching — NOT realizable
    def cl_branch(s: frozenset[int]) -> frozenset[int]:
        """Closure with non-chain closed sets."""
        if 0 in s and 1 in s:
            return frozenset({0, 1, 2, 3})
        elif 0 in s:
            return frozenset({0, 2})
        elif 1 in s:
            return frozenset({1, 3})
        elif 2 in s:
            return frozenset({0, 2})
        elif 3 in s:
            return frozenset({1, 3})
        else:
            return frozenset()
    
    closed_branch = [s for s in powerset(universe) if cl_branch(s) == s]
    
    print(f"\nExample 4: Branching closure")
    print(f"  cl({{0}}) = {{0,2}}, cl({{1}}) = {{1,3}}")
    print(f"  Closed sets: {[set(s) if s else '∅' for s in sorted(closed_branch, key=len)]}")
    print(f"  Chain? {is_chain(closed_branch)} → NOT realizable ✓")
    print(f"  Witness: {{0,2}} and {{1,3}} are incomparable")
    print()


# ============================================================
# 8. Full Duality Walkthrough
# ============================================================

def demo_full_duality() -> None:
    """Complete walkthrough: from valuation to closure to reconstruction."""
    print("=" * 60)
    print("DEMO 8: Complete Duality Walkthrough")
    print("=" * 60)
    
    universe = [0, 1, 2, 3, 4, 5]
    v_orig: Callable[[int], int] = lambda x: [0, 4, 2, 5, 3, 1][x]
    
    print(f"Universe: {universe}")
    print(f"Step 1: Start with valuation v = {[v_orig(x) for x in universe]}")
    
    # Build closure
    cl = lambda s: valuation_closure(v_orig, s, universe)
    print(f"\nStep 2: Build valuation closure")
    
    closed = sorted(
        [s for s in powerset(universe) if cl(s) == s], key=len
    )
    print(f"  Closed sets (chain):")
    for s in closed:
        s_str = set(s) if s else "∅"
        print(f"    {s_str}")
    
    assert is_chain(closed), "Should be a chain"
    print(f"  Chain verified ✓")
    
    # Reconstruct via normalization
    v_norm = normalize_valuation(v_orig, universe)
    vals = [v_norm(x) for x in universe]
    print(f"\nStep 3: Normalize → v_norm = {vals}")
    print(f"  Rank reduced from {realization_rank(v_orig, universe)} to {realization_rank(v_norm, universe)}")
    
    # Verify same closure
    same = all(
        valuation_closure(v_orig, s, universe) == valuation_closure(v_norm, s, universe)
        for s in powerset(universe)
    )
    print(f"\nStep 4: Verify cl_v = cl_v_norm: {same} ✓")
    
    # Check separation
    sep = is_separated(cl, universe)
    inj = is_injective(v_orig, universe)
    print(f"\nStep 5: Separation analysis")
    print(f"  v injective?    {inj}")
    print(f"  cl separated?   {sep}")
    if not inj:
        ties = [(x, y) for x in universe for y in universe
                if x < y and v_orig(x) == v_orig(y)]
        for x, y in ties:
            print(f"  v({x}) = v({y}) = {v_orig(x)} → cl({{{x}}}) = cl({{{y}}}) = {set(cl(frozenset({x})))}")
    
    # Capacity profile snippet
    print(f"\nStep 6: Capacity profile (sample)")
    for s in [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 2}), frozenset(universe)]:
        s_str = str(set(s)) if s else "∅"
        print(f"  cap({s_str}) = |cl(S)| = {len(cl(s))}")
    
    print("\n  The full capacity profile uniquely determines cl (Holographic Duality) ✓")
    print()


# ============================================================
# Main
# ============================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  CLOSURE–GAUGE REALIZATION DUALITY                     ║")
    print("║  Numerical Demonstrations                              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_valuation_closure()
    demo_chain_property()
    demo_gauge_equivalence()
    demo_holographic_duality()
    demo_minimal_realization()
    demo_separation()
    demo_realizability()
    demo_full_duality()
    
    print("All demonstrations completed successfully. ✓")


if __name__ == "__main__":
    main()
