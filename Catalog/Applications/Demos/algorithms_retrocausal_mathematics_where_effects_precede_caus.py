#!/usr/bin/env python3
"""
Retrocausal Nucleus Theory — Algorithms

Type-hinted implementations of the core algorithms:
1. Retrocausal closure computation
2. Fixed-point enumeration
3. Temporal implication evaluation
4. CPT composition
"""

from typing import Callable, TypeVar, Set, FrozenSet, Tuple, List, Optional
from dataclasses import dataclass

T = TypeVar('T')


@dataclass
class GaloisConnection:
    """A Galois connection between power set lattices over a finite universe."""
    universe: FrozenSet[int]
    l: Callable[[FrozenSet[int]], FrozenSet[int]]  # Left adjoint (forward)
    u: Callable[[FrozenSet[int]], FrozenSet[int]]  # Right adjoint (backward)

    def verify(self) -> bool:
        """Verify the Galois connection property: l(a) ⊆ b ⟺ a ⊆ u(b)."""
        all_sets = self._all_subsets()
        for a in all_sets:
            for b in all_sets:
                if a.issubset(self.u(b)) != self.l(a).issubset(b):
                    return False
        return True

    def _all_subsets(self) -> List[FrozenSet[int]]:
        """Generate all subsets of the universe."""
        result = [frozenset()]
        for x in self.universe:
            result = result + [s | {x} for s in result]
        return result


@dataclass
class RetrocausalNucleus:
    """A retrocausal nucleus on a power set lattice."""
    gc: GaloisConnection

    def j(self, s: FrozenSet[int]) -> FrozenSet[int]:
        """The retrocausal closure: j = R ∘ T."""
        return self.gc.u(self.gc.l(s))

    def is_fixed_point(self, s: FrozenSet[int]) -> bool:
        """Check if s is a fixed point of j."""
        return self.j(s) == s

    def fixed_points(self) -> List[FrozenSet[int]]:
        """Enumerate all fixed points."""
        return [s for s in self.gc._all_subsets() if self.is_fixed_point(s)]

    def verify_nucleus_property(self) -> bool:
        """Verify j(a ∩ b) = j(a) ∩ j(b) for all a, b."""
        all_sets = self.gc._all_subsets()
        for a in all_sets:
            for b in all_sets:
                if self.j(a & b) != self.j(a) & self.j(b):
                    return False
        return True

    def verify_idempotent(self) -> bool:
        """Verify j(j(a)) = j(a) for all a."""
        return all(self.j(self.j(s)) == self.j(s) for s in self.gc._all_subsets())

    def verify_extensive(self) -> bool:
        """Verify a ⊆ j(a) for all a."""
        return all(s.issubset(self.j(s)) for s in self.gc._all_subsets())

    def verify_temporal_coherence(self) -> bool:
        """Verify T∘R∘T = T and R∘T∘R = R for all elements."""
        all_sets = self.gc._all_subsets()
        T, R = self.gc.l, self.gc.u
        for s in all_sets:
            if T(R(T(s))) != T(s):
                return False
            if R(T(R(s))) != R(s):
                return False
        return True


def temporal_implication(
    nu: RetrocausalNucleus,
    a: FrozenSet[int],
    b: FrozenSet[int],
    himp: Callable[[FrozenSet[int], FrozenSet[int]], FrozenSet[int]]
) -> FrozenSet[int]:
    """Compute the temporal implication a →_τ b = R(T(a) ⇨ T(b))."""
    return nu.gc.u(himp(nu.gc.l(a), nu.gc.l(b)))


def temporal_excluded_middle(
    nu: RetrocausalNucleus,
    a: FrozenSet[int]
) -> bool:
    """Check if j(a) ∪ j(aᶜ) = universe."""
    compl = nu.gc.universe - a
    return (nu.j(a) | nu.j(compl)) == nu.gc.universe


@dataclass
class CPTSystem:
    """A CPT system: three involutions on a finite set."""
    C: Callable[[tuple], tuple]
    P: Callable[[tuple], tuple]
    Tr: Callable[[tuple], tuple]

    def cpt(self, a: tuple) -> tuple:
        """The CPT composition."""
        return self.C(self.P(self.Tr(a)))

    def verify_involutions(self, elements: List[tuple]) -> bool:
        """Verify C, P, T are involutions."""
        for f in [self.C, self.P, self.Tr]:
            if not all(f(f(a)) == a for a in elements):
                return False
        return True

    def verify_commutativity(self, elements: List[tuple]) -> bool:
        """Verify pairwise commutativity."""
        for f, g in [(self.C, self.P), (self.C, self.Tr), (self.P, self.Tr)]:
            if not all(f(g(a)) == g(f(a)) for a in elements):
                return False
        return True

    def verify_cpt_involution(self, elements: List[tuple]) -> bool:
        """Verify CPT ∘ CPT = id."""
        return all(self.cpt(self.cpt(a)) == a for a in elements)


def build_projection_nucleus(n: int, keep: FrozenSet[int]) -> RetrocausalNucleus:
    """
    Build a retrocausal nucleus on P({0,...,n-1}) by projection.

    T(S) = S ∩ keep (projection onto a subset)
    R(U) = U ∪ (universe \ keep) (right adjoint: add back the complement)
    
    This satisfies the nucleus property because T preserves meets:
    T(A ∩ B) = (A ∩ B) ∩ keep = (A ∩ keep) ∩ (B ∩ keep) = T(A) ∩ T(B)
    """
    universe = frozenset(range(n))
    complement = universe - keep

    def T(s: FrozenSet[int]) -> FrozenSet[int]:
        return s & keep

    def R(s: FrozenSet[int]) -> FrozenSet[int]:
        return s | complement

    gc = GaloisConnection(universe=universe, l=T, u=R)
    return RetrocausalNucleus(gc=gc)


if __name__ == "__main__":
    # Demo: build and verify a retrocausal nucleus
    nu = build_projection_nucleus(3, frozenset({0, 1}))

    print("Galois connection verified:", nu.gc.verify())
    print("Nucleus property verified:", nu.verify_nucleus_property())
    print("Idempotent verified:", nu.verify_idempotent())
    print("Extensive verified:", nu.verify_extensive())
    print("Temporal coherence verified:", nu.verify_temporal_coherence())

    print("\nFixed points:")
    for fp in nu.fixed_points():
        print(f"  {set(fp) if fp else '∅'}")

    print("\nTemporal excluded middle:")
    for s in nu.gc._all_subsets():
        print(f"  j({set(s) if s else '∅'}) ∪ j(complement) = universe: {temporal_excluded_middle(nu, s)}")

    # CPT demo
    cpt = CPTSystem(
        C=lambda a: (1 - a[0], a[1], a[2]),
        P=lambda a: (a[0], 1 - a[1], a[2]),
        Tr=lambda a: (a[0], a[1], 1 - a[2])
    )
    elements = [(i, j, k) for i in range(2) for j in range(2) for k in range(2)]
    print("\nCPT system on (Z/2)³:")
    print(f"  Involutions: {cpt.verify_involutions(elements)}")
    print(f"  Commutativity: {cpt.verify_commutativity(elements)}")
    print(f"  CPT involution: {cpt.verify_cpt_involution(elements)}")
