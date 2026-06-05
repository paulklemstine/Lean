#!/usr/bin/env python3
"""
Algorithms for Dreamtime Algebra: Aboriginal Kinship Systems as Group Theory
============================================================================
Type-hinted implementations of the core algorithms.
"""

from typing import Tuple, List, Set, Dict, Optional, FrozenSet
from itertools import product
from dataclasses import dataclass


# Type aliases
Section = Tuple[int, ...]


@dataclass
class DreamtimeAlgebra:
    """A Dreamtime algebra: (Z/2Z)^n with distinguished marriage and descent generators.

    Attributes:
        n: dimension (number of generators of the underlying group)
        marry_gen: marriage generator σ (element of (Z/2Z)^n)
        descent_gen: descent generator δ (element of (Z/2Z)^n)
    """
    n: int
    marry_gen: Section
    descent_gen: Section

    def __post_init__(self) -> None:
        assert len(self.marry_gen) == self.n
        assert len(self.descent_gen) == self.n
        assert self.marry_gen != tuple(0 for _ in range(self.n)), "Marriage generator must be nontrivial"
        assert self.descent_gen != tuple(0 for _ in range(self.n)), "Descent generator must be nontrivial"
        assert self.marry_gen != self.descent_gen, "Marriage and descent must be distinct"

    @property
    def zero(self) -> Section:
        return tuple(0 for _ in range(self.n))

    @property
    def dreamtime_gen(self) -> Section:
        """The Dreamtime element τ = σ + δ."""
        return add_mod2(self.marry_gen, self.descent_gen)

    @property
    def sections(self) -> List[Section]:
        """All sections (elements of the group)."""
        return list(product(range(2), repeat=self.n))

    @property
    def num_sections(self) -> int:
        return 2 ** self.n

    def marriage_map(self, g: Section) -> Section:
        """Map section g to its marriage partner's section."""
        return add_mod2(g, self.marry_gen)

    def descent_map(self, g: Section) -> Section:
        """Map section g to the child's section."""
        return add_mod2(g, self.descent_gen)

    def dreamtime_op(self, g: Section) -> Section:
        """The Dreamtime operator: marriage then descent."""
        return add_mod2(add_mod2(g, self.marry_gen), self.descent_gen)

    def moiety(self, g: Section) -> FrozenSet[Section]:
        """The moiety containing section g."""
        return frozenset({g, self.marriage_map(g)})

    def patrilineal_orbit(self, g: Section) -> FrozenSet[Section]:
        """The patrilineal orbit of section g."""
        return frozenset({g, self.descent_map(g)})

    def is_marriage_compatible(self, g: Section, h: Section) -> bool:
        """Check if g and h are marriage-compatible."""
        return h == self.marriage_map(g)

    def dual(self) -> 'DreamtimeAlgebra':
        """The dual system: swap marriage and descent."""
        return DreamtimeAlgebra(self.n, self.descent_gen, self.marry_gen)

    def twist(self) -> 'DreamtimeAlgebra':
        """The twisted system: use Dreamtime element as marriage generator."""
        return DreamtimeAlgebra(self.n, self.dreamtime_gen, self.descent_gen)

    def kinship_elements(self) -> List[Section]:
        """The four kinship elements: {0, σ, δ, τ}."""
        return [self.zero, self.marry_gen, self.descent_gen, self.dreamtime_gen]

    def marriage_pairs(self) -> List[Tuple[Section, Section]]:
        """All marriage pairs (unordered)."""
        seen: Set[Section] = set()
        pairs = []
        for g in self.sections:
            if g not in seen:
                h = self.marriage_map(g)
                pairs.append((g, h))
                seen.add(g)
                seen.add(h)
        return pairs

    def all_moieties(self) -> List[FrozenSet[Section]]:
        """All moieties."""
        seen: Set[FrozenSet[Section]] = set()
        result = []
        for g in self.sections:
            m = self.moiety(g)
            if m not in seen:
                seen.add(m)
                result.append(m)
        return result

    def generation_trace(self, start: Section, num_generations: int) -> List[Section]:
        """Trace patrilineal descent for multiple generations."""
        trace = [start]
        current = start
        for _ in range(num_generations):
            current = self.descent_map(current)
            trace.append(current)
        return trace


def add_mod2(a: Section, b: Section) -> Section:
    """Add two elements in (Z/2Z)^n."""
    return tuple((x + y) % 2 for x, y in zip(a, b))


def kinship_spectrum(n: int) -> List[Section]:
    """Compute the kinship spectrum of (Z/2Z)^n.

    Returns all nonzero elements (each has order 2).
    |Spec_K((Z/2Z)^n)| = 2^n - 1.
    """
    zero = tuple(0 for _ in range(n))
    return [g for g in product(range(2), repeat=n) if g != zero]


def enumerate_dreamtime_algebras(n: int) -> List[DreamtimeAlgebra]:
    """Enumerate all Dreamtime algebras on (Z/2Z)^n.

    Returns all ordered pairs (σ, δ) of distinct nonzero elements.
    Count = (2^n - 1)(2^n - 2).
    """
    spectrum = kinship_spectrum(n)
    algebras = []
    for m in spectrum:
        for d in spectrum:
            if m != d:
                algebras.append(DreamtimeAlgebra(n, m, d))
    return algebras


def can_build_dreamtime(group_orders: List[int]) -> bool:
    """Check if Z_{n1} × Z_{n2} × ... has enough elements of order 2.

    A Dreamtime algebra needs ≥ 2 distinct nontrivial elements of order 2.
    """
    # Count elements of order dividing 2 in the product group
    # Element (g1, ..., gk) has order dividing 2 iff each gi has order dividing 2 in Z_{ni}
    count = 1
    for n in group_orders:
        # Elements of order dividing 2 in Z_n: those g with 2g ≡ 0 mod n
        # These are g = 0 and g = n/2 (if n is even)
        order2_count = 1 + (1 if n % 2 == 0 else 0)
        count *= order2_count
    # Subtract 1 for the identity
    return (count - 1) >= 2


def verify_alternating_generations(D: DreamtimeAlgebra) -> bool:
    """Verify the alternating generations theorem for a given system."""
    for g in D.sections:
        child = D.descent_map(g)
        grandchild = D.descent_map(child)
        if grandchild != g:
            return False
    return True


def verify_klein_four_closure(D: DreamtimeAlgebra) -> bool:
    """Verify that the kinship elements form a Klein four-group."""
    elts = D.kinship_elements()
    elt_set = set(elts)
    # Check closure under addition
    for a in elts:
        for b in elts:
            s = add_mod2(a, b)
            if s not in elt_set:
                return False
    return True


def classify_groups_admitting_dreamtime(max_order: int) -> Dict[int, bool]:
    """For each n ≤ max_order, check if Z_n admits a Dreamtime algebra."""
    result = {}
    for n in range(2, max_order + 1):
        result[n] = can_build_dreamtime([n])
    return result


# ===== Concrete Systems =====

KARIERA = DreamtimeAlgebra(n=2, marry_gen=(1, 0), descent_gen=(0, 1))
ARANDA = DreamtimeAlgebra(n=3, marry_gen=(1, 0, 0), descent_gen=(0, 1, 0))


if __name__ == "__main__":
    print("=== Kariera System ===")
    print(f"Sections: {KARIERA.num_sections}")
    print(f"Marriage pairs: {KARIERA.marriage_pairs()}")
    print(f"Alternating generations: {verify_alternating_generations(KARIERA)}")
    print(f"Klein four closure: {verify_klein_four_closure(KARIERA)}")

    print("\n=== Aranda System ===")
    print(f"Sections: {ARANDA.num_sections}")
    print(f"Marriage pairs: {ARANDA.marriage_pairs()}")
    print(f"Alternating generations: {verify_alternating_generations(ARANDA)}")
    print(f"Klein four closure: {verify_klein_four_closure(ARANDA)}")

    print("\n=== Kinship Spectrum ===")
    for n in range(1, 5):
        spec = kinship_spectrum(n)
        print(f"  |Spec_K((Z₂)^{n})| = {len(spec)} = 2^{n} - 1")

    print("\n=== Dreamtime Algebra Count ===")
    for n in range(2, 5):
        algebras = enumerate_dreamtime_algebras(n)
        print(f"  (Z₂)^{n}: {len(algebras)} algebras = (2^{n}-1)(2^{n}-2)")

    print("\n=== Group Classification ===")
    classification = classify_groups_admitting_dreamtime(12)
    for n, can in classification.items():
        print(f"  Z_{n}: {'✓' if can else '✗'}")

    print("\n=== Triality ===")
    print(f"  Original: σ={KARIERA.marry_gen}, δ={KARIERA.descent_gen}")
    d = KARIERA.dual()
    print(f"  Dual:     σ={d.marry_gen}, δ={d.descent_gen}")
    t = KARIERA.twist()
    print(f"  Twist:    σ={t.marry_gen}, δ={t.descent_gen}")
