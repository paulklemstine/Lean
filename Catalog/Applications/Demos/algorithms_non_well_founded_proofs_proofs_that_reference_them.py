#!/usr/bin/env python3
"""
Algorithms for Non-Well-Founded Proof Systems

Type-hinted implementations of the core algorithms for computing
circularity gaps, classifying propositions, and analyzing proof systems.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, FrozenSet, Iterator, List, Optional, Set, Tuple


# Type aliases
PropSet = FrozenSet[int]
DeriveFn = Callable[[PropSet], PropSet]


@dataclass(frozen=True)
class ProofSystem:
    """A proof system over finite propositions.

    Attributes:
        universe: The set of all propositions.
        derive: Monotone derivation operator.
    """
    universe: PropSet
    derive: DeriveFn

    def verify_monotonicity(self, sample_size: int = 100) -> bool:
        """Spot-check monotonicity: S ⊆ T → derive(S) ⊆ derive(T)."""
        import random
        elems = sorted(self.universe)
        for _ in range(sample_size):
            k1 = random.randint(0, len(elems))
            k2 = random.randint(k1, len(elems))
            s = frozenset(random.sample(elems, k1))
            t = s | frozenset(random.sample(elems, min(k2, len(elems))))
            if not self.derive(s) <= self.derive(t):
                return False
        return True


@dataclass(frozen=True)
class CircularityAnalysis:
    """Complete analysis of a proof system's circularity structure."""
    lfp: PropSet
    gfp: PropSet
    gap: PropSet
    safe_elements: PropSet
    self_referential_elements: PropSet
    lfp_depth: dict[int, int]  # element -> iteration step when it entered lfp
    gfp_depth: dict[int, int]  # element -> iteration step when it left gfp approx


def compute_lfp(derive: DeriveFn, universe: PropSet,
                max_iter: int = 1000) -> Tuple[PropSet, List[PropSet]]:
    """Compute the least fixed point by ascending Kleene iteration.

    Returns:
        (lfp, trace) where trace[i] = derive^i(∅).
    """
    trace: List[PropSet] = [frozenset()]
    current = frozenset()
    for _ in range(max_iter):
        next_val = derive(current)
        trace.append(next_val)
        if next_val == current:
            return current, trace
        current = next_val
    return current, trace


def compute_gfp(derive: DeriveFn, universe: PropSet,
                max_iter: int = 1000) -> Tuple[PropSet, List[PropSet]]:
    """Compute the greatest fixed point by descending Kleene iteration.

    Returns:
        (gfp, trace) where trace[i] = derive^i(universe).
    """
    trace: List[PropSet] = [universe]
    current = universe
    for _ in range(max_iter):
        next_val = derive(current)
        trace.append(next_val)
        if next_val == current:
            return current, trace
        current = next_val
    return current, trace


def compute_circularity_gap(ps: ProofSystem) -> Tuple[PropSet, PropSet, PropSet]:
    """Compute the circularity gap.

    Returns:
        (gap, lfp, gfp) where gap = gfp \\ lfp.
    """
    lfp, _ = compute_lfp(ps.derive, ps.universe)
    gfp, _ = compute_gfp(ps.derive, ps.universe)
    return gfp - lfp, lfp, gfp


def classify_element(derive: DeriveFn, a: int,
                      universe: PropSet) -> Tuple[bool, bool]:
    """Classify an element as safe and/or self-referential.

    Returns:
        (is_safe, is_self_referential)
    """
    # Check safety: a ∈ derive(S) → a ∈ S for all S ⊆ universe
    is_safe = True
    for mask in range(1 << len(universe)):
        elems = sorted(universe)
        s = frozenset(elems[i] for i in range(len(elems)) if mask & (1 << i))
        if a in derive(s) and a not in s:
            is_safe = False
            break

    # Check self-referentiality
    is_selfref = is_safe and (a in derive(frozenset([a])))
    return is_safe, is_selfref


def full_analysis(ps: ProofSystem) -> CircularityAnalysis:
    """Perform complete circularity analysis of a proof system.

    Computes lfp, gfp, gap, safety classification, and depth measures.
    """
    lfp, lfp_trace = compute_lfp(ps.derive, ps.universe)
    gfp, gfp_trace = compute_gfp(ps.derive, ps.universe)
    gap = gfp - lfp

    # Classify elements
    safe = set()
    selfref = set()
    for a in ps.universe:
        s, sr = classify_element(ps.derive, a, ps.universe)
        if s:
            safe.add(a)
        if sr:
            selfref.add(a)

    # Compute lfp depth (when element first appears in ascending sequence)
    lfp_depth: dict[int, int] = {}
    for a in lfp:
        for i, step in enumerate(lfp_trace):
            if a in step:
                lfp_depth[a] = i
                break

    # Compute gfp depth (when element first disappears in descending sequence)
    gfp_depth: dict[int, int] = {}
    for a in ps.universe - gfp:
        for i, step in enumerate(gfp_trace):
            if a not in step:
                gfp_depth[a] = i
                break

    return CircularityAnalysis(
        lfp=lfp,
        gfp=gfp,
        gap=gap,
        safe_elements=frozenset(safe),
        self_referential_elements=frozenset(selfref),
        lfp_depth=lfp_depth,
        gfp_depth=gfp_depth,
    )


def find_post_fixed_points(ps: ProofSystem) -> List[PropSet]:
    """Find all post-fixed points (self-consistent theories).

    For small universes only (exponential in |universe|).
    """
    elems = sorted(ps.universe)
    result: List[PropSet] = []
    for mask in range(1 << len(elems)):
        s = frozenset(elems[i] for i in range(len(elems)) if mask & (1 << i))
        if s <= ps.derive(s):
            result.append(s)
    return result


def verify_union_closure(ps: ProofSystem,
                         post_fixed: List[PropSet]) -> bool:
    """Verify that post-fixed points are closed under union (Theorem 7)."""
    for i, s1 in enumerate(post_fixed):
        for s2 in post_fixed[i + 1:]:
            union = s1 | s2
            if not union <= ps.derive(union):
                return False
    return True


# ============================================================
# Factory functions for common proof systems
# ============================================================

def identity_system(n: int) -> ProofSystem:
    """Create the identity proof system on {0, ..., n-1}."""
    universe = frozenset(range(n))
    return ProofSystem(universe=universe, derive=lambda s: s)


def constant_system(n: int, axioms: PropSet) -> ProofSystem:
    """Create a constant proof system."""
    universe = frozenset(range(n))
    return ProofSystem(universe=universe, derive=lambda s: axioms)


def union_axiom_system(n: int, axioms: PropSet) -> ProofSystem:
    """Create a union-axiom proof system."""
    universe = frozenset(range(n))
    return ProofSystem(universe=universe, derive=lambda s: s | axioms)


def induction_system(n: int) -> ProofSystem:
    """Create an induction-like system: 0 is axiom, x → x+1."""
    universe = frozenset(range(n))
    def derive(s: PropSet) -> PropSet:
        result = s | frozenset([0])
        for x in s:
            if x + 1 < n:
                result = result | frozenset([x + 1])
        return result
    return ProofSystem(universe=universe, derive=derive)


if __name__ == "__main__":
    # Quick self-test
    ps = identity_system(5)
    analysis = full_analysis(ps)
    print(f"Identity system (n=5):")
    print(f"  lfp = {sorted(analysis.lfp)}")
    print(f"  gfp = {sorted(analysis.gfp)}")
    print(f"  gap = {sorted(analysis.gap)}")
    print(f"  safe = {sorted(analysis.safe_elements)}")
    print(f"  self-ref = {sorted(analysis.self_referential_elements)}")
    assert analysis.gap == ps.universe
    assert analysis.safe_elements == ps.universe
    assert analysis.self_referential_elements == ps.universe
    print("  ✓ All assertions passed")

    ps2 = constant_system(5, frozenset([0, 1]))
    analysis2 = full_analysis(ps2)
    print(f"\nConstant system (n=5, axioms={{0,1}}):")
    print(f"  lfp = {sorted(analysis2.lfp)}")
    print(f"  gfp = {sorted(analysis2.gfp)}")
    print(f"  gap = {sorted(analysis2.gap)}")
    assert len(analysis2.gap) == 0
    print("  ✓ Gap is empty (as expected)")

    ps3 = induction_system(8)
    analysis3 = full_analysis(ps3)
    print(f"\nInduction system (n=8):")
    print(f"  lfp = {sorted(analysis3.lfp)}")
    print(f"  gfp = {sorted(analysis3.gfp)}")
    print(f"  gap = {sorted(analysis3.gap)}")
    print(f"  lfp_depth = {analysis3.lfp_depth}")
    assert len(analysis3.gap) == 0
    print("  ✓ Gap is empty (complete induction)")
