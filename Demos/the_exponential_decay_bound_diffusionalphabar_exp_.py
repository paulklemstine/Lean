#!/usr/bin/env python3
"""
Closure–Gauge Realization Duality: Numerical Demonstrations

This module demonstrates the key results of the Closure–Gauge Realization
Duality theory with concrete finite examples.

Key results demonstrated:
1. Valuation closure construction and verification of closure axioms
2. Chain property of closed sets
3. Gauge uniqueness (order-equivalent valuations produce same closure)
4. Holographic duality (capacity determines closure)
5. Minimal realization via normalization
6. Realizability test via chain condition
7. Separation and injectivity correspondence
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List


# ============================================================
# Core Types and Utilities
# ============================================================

# Type aliases (compatible with Python 3.11)
Element = int
Subset = FrozenSet[int]
Valuation = Dict[int, int]
ClosureFn = Callable[[FrozenSet[int]], FrozenSet[int]]


def powerset(universe: list[Element]) -> list[Subset]:
    """Generate all subsets of a universe as frozensets."""
    result: list[Subset] = [frozenset()]
    for r in range(1, len(universe) + 1):
        for combo in combinations(universe, r):
            result.append(frozenset(combo))
    return result


def sup_val(v: Valuation, s: Subset) -> int:
    """Compute sup_{x in S} v(x), returning 0 for empty set."""
    if not s:
        return 0
    return max(v[x] for x in s)


# ============================================================
# Valuation Closure Construction
# ============================================================

def valuation_closure(v: Valuation, universe: list[Element]) -> ClosureFn:
    """
    Build the valuation closure operator cl_v.

    cl_v(S) = {x in universe | v(x) <= sup_{s in S} v(s)}
    """
    univ_set = frozenset(universe)

    def cl(s: Subset) -> Subset:
        threshold = sup_val(v, s)
        return frozenset(x for x in univ_set if v[x] <= threshold)

    return cl


def verify_closure_axioms(
    cl: ClosureFn, universe: list[Element]
) -> dict[str, bool]:
    """Verify extensiveness, monotonicity, and idempotence."""
    subsets = powerset(universe)

    # Extensiveness: S ⊆ cl(S)
    extensive = all(s <= cl(s) for s in subsets)

    # Monotonicity: S ⊆ T => cl(S) ⊆ cl(T)
    monotone = True
    for s in subsets:
        for t in subsets:
            if s <= t and not (cl(s) <= cl(t)):
                monotone = False
                break

    # Idempotence: cl(cl(S)) = cl(S)
    idempotent = all(cl(cl(s)) == cl(s) for s in subsets)

    return {
        "extensive": extensive,
        "monotone": monotone,
        "idempotent": idempotent,
    }


# ============================================================
# Closed Sets and Chain Property
# ============================================================

def find_closed_sets(cl: ClosureFn, universe: list[Element]) -> list[Subset]:
    """Find all closed sets: S such that cl(S) = S."""
    return [s for s in powerset(universe) if cl(s) == s]


def is_chain(sets: list[Subset]) -> bool:
    """Check if a collection of sets forms a chain under inclusion."""
    for i, s in enumerate(sets):
        for t in sets[i + 1 :]:
            if not (s <= t or t <= s):
                return False
    return True


# ============================================================
# Gauge Equivalence
# ============================================================

def is_order_equivalent(v1: Valuation, v2: Valuation) -> bool:
    """Check if two valuations are order-equivalent."""
    elements = list(v1.keys())
    for x in elements:
        for y in elements:
            if (v1[x] <= v1[y]) != (v2[x] <= v2[y]):
                return False
    return True


def normalize_valuation(v: Valuation) -> Valuation:
    """
    Compute the normalized valuation:
    v_hat(x) = |{y : v(y) < v(x)}|
    """
    elements = list(v.keys())
    return {
        x: sum(1 for y in elements if v[y] < v[x]) for x in elements
    }


# ============================================================
# Capacity and Holographic Duality
# ============================================================

def capacity_profile(
    cl: ClosureFn, universe: list[Element]
) -> dict[Subset, int]:
    """Compute the capacity of every subset: cap(S) = |cl(S)|."""
    return {s: len(cl(s)) for s in powerset(universe)}


def closures_equal(
    cl1: ClosureFn, cl2: ClosureFn, universe: list[Element]
) -> bool:
    """Check if two closure operators are identical."""
    return all(cl1(s) == cl2(s) for s in powerset(universe))


# ============================================================
# Realizability Test
# ============================================================

def is_gauge_realizable(cl: ClosureFn, universe: list[Element]) -> bool:
    """Test if a closure operator is gauge-realizable (chain condition)."""
    closed = find_closed_sets(cl, universe)
    return is_chain(closed)


def reconstruct_valuation(
    cl: ClosureFn, universe: list[Element]
) -> Valuation:
    """
    Reconstruct a gauge valuation from a chain closure:
    v(x) = |cl({x})| - |cl(∅)|
    """
    base = len(cl(frozenset()))
    return {x: len(cl(frozenset([x]))) - base for x in universe}


# ============================================================
# Demo 1: Basic Valuation Closure
# ============================================================

def demo_basic_valuation_closure() -> None:
    """Demonstrate valuation closure construction and axiom verification."""
    print("=" * 65)
    print("DEMO 1: Basic Valuation Closure")
    print("=" * 65)

    universe = [0, 1, 2, 3]
    v: Valuation = {0: 1, 1: 3, 2: 2, 3: 5}
    cl = valuation_closure(v, universe)

    print(f"\nUniverse: {universe}")
    print(f"Valuation: {v}")
    print()

    # Show some closures
    test_sets: list[Subset] = [
        frozenset(),
        frozenset([0]),
        frozenset([2]),
        frozenset([1]),
        frozenset([0, 2]),
        frozenset([1, 3]),
    ]
    for s in test_sets:
        c = cl(s)
        print(f"  cl({set(s) if s else '{}'}) = {set(c) if c else '{}'}"
              f"  (sup = {sup_val(v, s)})")

    print()
    axioms = verify_closure_axioms(cl, universe)
    for name, holds in axioms.items():
        status = "✓" if holds else "✗"
        print(f"  {status} {name}")


# ============================================================
# Demo 2: Chain Property
# ============================================================

def demo_chain_property() -> None:
    """Demonstrate that closed sets of valuation closures form chains."""
    print("\n" + "=" * 65)
    print("DEMO 2: Chain Property of Closed Sets")
    print("=" * 65)

    universe = [0, 1, 2, 3, 4]
    v: Valuation = {0: 2, 1: 5, 2: 1, 3: 3, 4: 5}
    cl = valuation_closure(v, universe)

    closed = find_closed_sets(cl, universe)
    print(f"\nValuation: {v}")
    print(f"Number of closed sets: {len(closed)}")
    print("Closed sets (sorted by size):")
    for s in sorted(closed, key=len):
        sup = sup_val(v, s)
        label = str(set(s)) if s else "{}"
        print(f"  {label:>20}  (level ≤ {sup})")

    chain = is_chain(closed)
    print(f"\nClosed sets form a chain: {'✓ YES' if chain else '✗ NO'}")


# ============================================================
# Demo 3: Gauge Uniqueness
# ============================================================

def demo_gauge_uniqueness() -> None:
    """Demonstrate that order-equivalent valuations produce same closure."""
    print("\n" + "=" * 65)
    print("DEMO 3: Gauge Uniqueness")
    print("=" * 65)

    universe = [0, 1, 2]

    # Two order-equivalent valuations with same min (same ranking: 0 < 2 < 1)
    v1: Valuation = {0: 1, 1: 7, 2: 3}
    v2: Valuation = {0: 1, 1: 12, 2: 5}
    v3: Valuation = {0: 10, 1: 12, 2: 11}

    # A non-equivalent valuation (different ranking)
    v4: Valuation = {0: 5, 1: 3, 2: 7}

    cl1 = valuation_closure(v1, universe)
    cl2 = valuation_closure(v2, universe)
    cl3 = valuation_closure(v3, universe)
    cl4 = valuation_closure(v4, universe)

    print(f"\nv1 = {v1}  (ranking: 0 < 2 < 1)")
    print(f"v2 = {v2}  (ranking: 0 < 2 < 1)")
    print(f"v3 = {v3}  (ranking: 0 < 2 < 1, shifted)")
    print(f"v4 = {v4}  (ranking: 1 < 0 < 2)")

    pairs = [
        ("v1", "v2", v1, v2, cl1, cl2),
        ("v1", "v3", v1, v3, cl1, cl3),
        ("v1", "v4", v1, v4, cl1, cl4),
    ]
    print()
    for n1, n2, va, vb, ca, cb in pairs:
        oe = is_order_equivalent(va, vb)
        ce = closures_equal(ca, cb, universe)
        print(f"  {n1} vs {n2}: order-equiv = {oe}, "
              f"same closure = {ce}")


# ============================================================
# Demo 4: Holographic Duality
# ============================================================

def demo_holographic_duality() -> None:
    """Demonstrate that capacity profiles determine closures."""
    print("\n" + "=" * 65)
    print("DEMO 4: Holographic Duality")
    print("=" * 65)

    universe = [0, 1, 2, 3]
    v: Valuation = {0: 1, 1: 3, 2: 2, 3: 4}
    cl = valuation_closure(v, universe)

    cap = capacity_profile(cl, universe)

    print(f"\nValuation: {v}")
    print("\nCapacity profile (sample):")
    for s in sorted(cap, key=lambda s: (len(s), sorted(s))):
        if len(s) <= 2:
            label = set(s) if s else "{}"
            print(f"  cap({label!s:>12}) = {cap[s]}")

    # Verify: closed iff capacity = cardinality
    print("\nCapacity characterization of closed sets:")
    closed = find_closed_sets(cl, universe)
    for s in sorted(powerset(universe), key=lambda s: (len(s), sorted(s))):
        if len(s) <= 3:
            is_cl = s in closed
            label = set(s) if s else "{}"
            print(f"  {label!s:>12}: |S|={len(s)}, cap={cap[s]}, "
                  f"closed={'✓' if is_cl else ' '}")


# ============================================================
# Demo 5: Realizability and Reconstruction
# ============================================================

def demo_realizability() -> None:
    """Demonstrate realizability test and reconstruction."""
    print("\n" + "=" * 65)
    print("DEMO 5: Realizability Test & Reconstruction")
    print("=" * 65)

    universe = [0, 1, 2, 3]

    # A realizable closure (from valuation)
    v_orig: Valuation = {0: 3, 1: 1, 2: 5, 3: 1}
    cl_real = valuation_closure(v_orig, universe)

    print(f"\n--- Realizable Closure ---")
    print(f"Original valuation: {v_orig}")
    realizable = is_gauge_realizable(cl_real, universe)
    print(f"Chain condition: {'✓ YES' if realizable else '✗ NO'}")

    if realizable:
        v_recon = reconstruct_valuation(cl_real, universe)
        cl_recon = valuation_closure(v_recon, universe)
        same = closures_equal(cl_real, cl_recon, universe)
        oe = is_order_equivalent(v_orig, v_recon)
        print(f"Reconstructed valuation: {v_recon}")
        print(f"Closures match: {'✓' if same else '✗'}")
        print(f"Order-equivalent to original: {'✓' if oe else '✗'}")

    # A non-realizable closure (discrete / identity)
    print(f"\n--- Non-Realizable Closure (Identity on 4 elements) ---")

    def cl_discrete(s: Subset) -> Subset:
        return s

    realizable2 = is_gauge_realizable(cl_discrete, universe)
    print(f"Chain condition: {'✓ YES' if realizable2 else '✗ NO'}")
    closed2 = find_closed_sets(cl_discrete, universe)
    print(f"Number of closed sets: {len(closed2)}")
    print("Incomparable pair: {0} and {1}")


# ============================================================
# Demo 6: Normalization
# ============================================================

def demo_normalization() -> None:
    """Demonstrate valuation normalization preserves order."""
    print("\n" + "=" * 65)
    print("DEMO 6: Valuation Normalization")
    print("=" * 65)

    universe = [0, 1, 2, 3, 4]
    v: Valuation = {0: 100, 1: 7, 2: 42, 3: 7, 4: 999}

    v_norm = normalize_valuation(v)

    print(f"\nOriginal:   {v}")
    print(f"Normalized: {v_norm}")
    print(f"Order-equivalent: {'✓' if is_order_equivalent(v, v_norm) else '✗'}")

    cl_orig = valuation_closure(v, universe)
    cl_norm = valuation_closure(v_norm, universe)
    same_cl = closures_equal(cl_orig, cl_norm, universe)
    print(f"Same closure: {'✓' if same_cl else '✗'}")
    if not same_cl:
        print(f"  (Closures may differ on ∅ when normalization"
              f" shifts minimum to 0)"
              f"\n  cl_orig(∅) = {set(cl_orig(frozenset()))}"
              f"  vs  cl_norm(∅) = {set(cl_norm(frozenset()))}")
        # But on nonempty sets they agree:
        nonempty_agree = all(
            cl_orig(s) == cl_norm(s)
            for s in powerset(universe) if s
        )
        print(f"  Agree on all nonempty sets: "
              f"{'✓' if nonempty_agree else '✗'}")
    

    print(f"\nNormalized rank (distinct values): "
          f"{len(set(v_norm.values()))}")
    print(f"Original rank (distinct values):   "
          f"{len(set(v.values()))}")


# ============================================================
# Demo 7: Separation and Injectivity
# ============================================================

def demo_separation() -> None:
    """Demonstrate separation ↔ injectivity correspondence."""
    print("\n" + "=" * 65)
    print("DEMO 7: Separation ↔ Injectivity")
    print("=" * 65)

    universe = [0, 1, 2, 3]

    # Injective valuation
    v_inj: Valuation = {0: 1, 1: 2, 2: 3, 3: 4}
    cl_inj = valuation_closure(v_inj, universe)
    inj = len(set(v_inj.values())) == len(v_inj)
    sep_inj = all(
        cl_inj(frozenset([a])) != cl_inj(frozenset([b]))
        for a in universe
        for b in universe
        if a != b
    )

    print(f"\nInjective valuation: {v_inj}")
    print(f"  Injective: {'✓' if inj else '✗'}")
    print(f"  Separated: {'✓' if sep_inj else '✗'}")

    # Non-injective valuation
    v_noninj: Valuation = {0: 2, 1: 5, 2: 2, 3: 7}
    cl_noninj = valuation_closure(v_noninj, universe)
    inj2 = len(set(v_noninj.values())) == len(v_noninj)
    sep2 = all(
        cl_noninj(frozenset([a])) != cl_noninj(frozenset([b]))
        for a in universe
        for b in universe
        if a != b
    )

    print(f"\nNon-injective valuation: {v_noninj}")
    print(f"  Injective: {'✓' if inj2 else '✗'}")
    print(f"  Separated: {'✓' if sep2 else '✗'}")
    print(f"  cl({{0}}) = {set(cl_noninj(frozenset([0])))}")
    print(f"  cl({{2}}) = {set(cl_noninj(frozenset([2])))}")
    print(f"  (v(0)=v(2)=2, so cl({{0}})=cl({{2}}))")


# ============================================================
# Demo 8: Scaling — Larger Example
# ============================================================

def demo_scaling() -> None:
    """Demonstrate the theory on a larger example (8 elements)."""
    print("\n" + "=" * 65)
    print("DEMO 8: Scaling to 8 Elements")
    print("=" * 65)

    universe = list(range(8))
    v: Valuation = {0: 3, 1: 1, 2: 7, 3: 4, 4: 2, 5: 7, 6: 5, 7: 6}
    cl = valuation_closure(v, universe)

    axioms = verify_closure_axioms(cl, universe)
    closed = find_closed_sets(cl, universe)
    chain = is_chain(closed)

    print(f"\nUniverse: {universe}")
    print(f"Valuation: {v}")
    print(f"Closure axioms: {axioms}")
    print(f"Number of closed sets: {len(closed)}")
    print(f"Chain property: {'✓' if chain else '✗'}")

    # Reconstruction
    v_recon = reconstruct_valuation(cl, universe)
    v_norm = normalize_valuation(v)
    print(f"\nOriginal:      {v}")
    print(f"Normalized:    {v_norm}")
    print(f"Reconstructed: {v_recon}")
    print(f"All order-equivalent: "
          f"{'✓' if is_order_equivalent(v, v_recon) and is_order_equivalent(v, v_norm) else '✗'}")


# ============================================================
# Main
# ============================================================

def main() -> None:
    """Run all demonstrations."""
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  Closure–Gauge Realization Duality: Numerical Demonstrations ║")
    print("╚═══════════════════════════════════════════════════════════════╝")

    demo_basic_valuation_closure()
    demo_chain_property()
    demo_gauge_uniqueness()
    demo_holographic_duality()
    demo_realizability()
    demo_normalization()
    demo_separation()
    demo_scaling()

    print("\n" + "=" * 65)
    print("All demonstrations complete.")
    print("=" * 65)


if __name__ == "__main__":
    main()
