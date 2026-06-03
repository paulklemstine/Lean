#!/usr/bin/env python3
"""
Retrocausal Mathematics: Core Algorithms

Type-hinted implementations of the key mathematical structures:
1. Heyting algebras (general and 3-element)
2. Nucleus construction and fixed-point computation
3. Galois connection from adjoint operators
4. Temporal modalities (box and diamond)
5. CPT triple verification
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import TypeVar, Generic, Callable, Set, FrozenSet, Dict, List, Tuple, Optional

T = TypeVar('T')


# ============================================================
# Heyting Algebra
# ============================================================

@dataclass
class HeytingAlgebra(Generic[T]):
    """A finite Heyting algebra specified by its elements and operations."""
    elements: List[T]
    le: Callable[[T, T], bool]
    sup: Callable[[T, T], T]
    inf: Callable[[T, T], T]
    himp: Callable[[T, T], T]
    bot: T
    top: T

    def compl(self, a: T) -> T:
        """Heyting complement: ¬a = a ⇨ ⊥."""
        return self.himp(a, self.bot)

    def lem_holds(self, a: T) -> bool:
        """Check if a ⊔ ¬a = ⊤."""
        return self.sup(a, self.compl(a)) == self.top

    def verify_adjunction(self) -> bool:
        """Verify: c ⊓ a ≤ b ⟺ c ≤ a ⇨ b for all a, b, c."""
        for a in self.elements:
            for b in self.elements:
                for c in self.elements:
                    lhs = self.le(self.inf(c, a), b)
                    rhs = self.le(c, self.himp(a, b))
                    if lhs != rhs:
                        return False
        return True


def three_element_heyting() -> HeytingAlgebra[int]:
    """The 3-element chain {0 < 1 < 2} as a Heyting algebra."""
    return HeytingAlgebra(
        elements=[0, 1, 2],
        le=lambda a, b: a <= b,
        sup=max,
        inf=min,
        himp=lambda a, b: 2 if a <= b else b,
        bot=0,
        top=2,
    )


# ============================================================
# Nucleus
# ============================================================

@dataclass
class Nucleus(Generic[T]):
    """A nucleus on a semilattice: extensive, idempotent, meet-preserving."""
    j: Callable[[T], T]
    elements: List[T]
    inf: Callable[[T, T], T]
    le: Callable[[T, T], bool]

    def is_valid(self) -> bool:
        """Verify all nucleus axioms."""
        for a in self.elements:
            # Extensive
            if not self.le(a, self.j(a)):
                return False
            # Idempotent
            if self.j(self.j(a)) != self.j(a):
                return False
            for b in self.elements:
                # Meet preservation
                if self.j(self.inf(a, b)) != self.inf(self.j(a), self.j(b)):
                    return False
        return True

    def fixed_points(self) -> List[T]:
        """Return the fixed points of the nucleus."""
        return [a for a in self.elements if self.j(a) == a]

    def fixed_point_count(self) -> int:
        """Count fixed points."""
        return len(self.fixed_points())


def enumerate_nuclei_powerset(n: int) -> List[Nucleus[FrozenSet[int]]]:
    """Enumerate all nuclei on the power set P(Fin(n))."""
    from itertools import combinations, product as iproduct

    universe = frozenset(range(n))
    subsets: List[FrozenSet[int]] = []
    for r in range(n + 1):
        for combo in combinations(range(n), r):
            subsets.append(frozenset(combo))

    def le(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
        return a.issubset(b)

    def inf(a: FrozenSet[int], b: FrozenSet[int]) -> FrozenSet[int]:
        return a & b

    nuclei: List[Nucleus[FrozenSet[int]]] = []

    # For small n, enumerate all functions j: subsets → subsets
    for values in iproduct(subsets, repeat=len(subsets)):
        j_dict = dict(zip(subsets, values))
        j_func = lambda x, d=j_dict: d[x]
        nuc = Nucleus(j=j_func, elements=subsets, inf=inf, le=le)
        if nuc.is_valid():
            nuclei.append(nuc)

    return nuclei


# ============================================================
# Galois Connection
# ============================================================

@dataclass
class GaloisConnection(Generic[T]):
    """A Galois connection T ⊣ R on a partially ordered set."""
    T_func: Callable[[T], T]
    R_func: Callable[[T], T]
    elements: List[T]
    le: Callable[[T, T], bool]

    def verify(self) -> bool:
        """Verify: T(a) ≤ b ⟺ a ≤ R(b)."""
        for a in self.elements:
            for b in self.elements:
                lhs = self.le(self.T_func(a), b)
                rhs = self.le(a, self.R_func(b))
                if lhs != rhs:
                    return False
        return True

    def box(self, a: T) -> T:
        """□a = R(T(a))."""
        return self.R_func(self.T_func(a))

    def diamond(self, a: T) -> T:
        """◇a = T(R(a))."""
        return self.T_func(self.R_func(a))

    def verify_s4_box(self) -> bool:
        """□□a = □a for all a."""
        return all(self.box(self.box(a)) == self.box(a) for a in self.elements)

    def verify_s4_diamond(self) -> bool:
        """◇◇a = ◇a for all a."""
        return all(self.diamond(self.diamond(a)) == self.diamond(a)
                   for a in self.elements)

    def verify_left_coherence(self) -> bool:
        """T(R(T(a))) = T(a) for all a."""
        return all(
            self.T_func(self.R_func(self.T_func(a))) == self.T_func(a)
            for a in self.elements
        )

    def verify_right_coherence(self) -> bool:
        """R(T(R(a))) = R(a) for all a."""
        return all(
            self.R_func(self.T_func(self.R_func(a))) == self.R_func(a)
            for a in self.elements
        )

    def temporal_em(self, a: T, compl: Callable[[T], T], top: T,
                    sup: Callable[[T, T], T]) -> bool:
        """Check R(T(a)) ⊔ R(T(aᶜ)) = ⊤."""
        return sup(self.box(a), self.box(compl(a))) == top


# ============================================================
# CPT Triple
# ============================================================

@dataclass
class CPTTriple(Generic[T]):
    """A CPT triple: three involutions on a type."""
    C: Callable[[T], T]
    P: Callable[[T], T]
    T_op: Callable[[T], T]  # 'T' conflicts with TypeVar
    elements: List[T]

    def verify_involutions(self) -> Tuple[bool, bool, bool]:
        """Check C², P², T² = id."""
        c_inv = all(self.C(self.C(x)) == x for x in self.elements)
        p_inv = all(self.P(self.P(x)) == x for x in self.elements)
        t_inv = all(self.T_op(self.T_op(x)) == x for x in self.elements)
        return c_inv, p_inv, t_inv

    def compose(self, x: T) -> T:
        """CPT(x) = C(P(T(x)))."""
        return self.C(self.P(self.T_op(x)))

    def is_cpt_involutive(self) -> bool:
        """Check if CPT is an involution."""
        return all(self.compose(self.compose(x)) == x for x in self.elements)

    def cpt_equals_tpc(self) -> bool:
        """Check if CPT = TPC."""
        def tpc(x: T) -> T:
            return self.T_op(self.P(self.C(x)))
        return all(self.compose(x) == tpc(x) for x in self.elements)

    def pairwise_commute(self) -> Tuple[bool, bool, bool]:
        """Check pairwise commutativity of C, P, T."""
        cp = all(self.C(self.P(x)) == self.P(self.C(x)) for x in self.elements)
        ct = all(self.C(self.T_op(x)) == self.T_op(self.C(x)) for x in self.elements)
        pt = all(self.P(self.T_op(x)) == self.T_op(self.P(x)) for x in self.elements)
        return cp, ct, pt


# ============================================================
# Algorithm: Retrocausal Heyting Implication
# ============================================================

def retrocausal_himp(
    nucleus_j: Callable[[T], T],
    himp: Callable[[T, T], T],
    a: T, b: T
) -> T:
    """
    Compute the retrocausal Heyting implication: j(a ⇨ b).

    Algorithm:
    1. Compute the base Heyting implication a ⇨ b
    2. Apply the nucleus j to close under temporal completion
    
    This is the key operation that lifts intuitionistic implication
    through the temporal closure operator.
    """
    return nucleus_j(himp(a, b))


def verify_retrocausal_adjunction(
    ha: HeytingAlgebra[T],
    nucleus_j: Callable[[T], T],
) -> bool:
    """
    Verify the nucleus Heyting adjunction on fixed points:
    c ⊓ a ≤ b ⟺ c ≤ j(a ⇨ b) for fixed points a, b, c.
    """
    fixed = [x for x in ha.elements if nucleus_j(x) == x]
    for a in fixed:
        for b in fixed:
            for c in fixed:
                lhs = ha.le(ha.inf(c, a), b)
                rhs = ha.le(c, retrocausal_himp(nucleus_j, ha.himp, a, b))
                if lhs != rhs:
                    return False
    return True


if __name__ == "__main__":
    # Quick self-test
    ha = three_element_heyting()
    assert ha.verify_adjunction(), "Adjunction failed"
    assert not ha.lem_holds(1), "LEM should fail for mid"
    assert ha.lem_holds(0), "LEM should hold for bot"
    assert ha.lem_holds(2), "LEM should hold for top"
    print("All algorithm self-tests passed.")
