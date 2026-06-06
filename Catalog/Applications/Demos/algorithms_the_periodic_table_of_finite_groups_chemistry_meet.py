#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Group Genome framework.

Provides type-hinted implementations of:
1. Chemical classification of finite groups
2. Derived depth computation
3. Genome construction and comparison
4. Stability hierarchy verification
"""

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import List, Set, FrozenSet, Dict, Tuple, Optional, Callable
from math import gcd
from functools import reduce


# ============================================================
# Algorithm 1: Permutation Group Representation
# ============================================================

class Permutation:
    """A permutation on {0, 1, ..., n-1}."""

    def __init__(self, mapping: List[int]):
        self.n = len(mapping)
        self.mapping = tuple(mapping)
        assert set(mapping) == set(range(self.n))

    def __call__(self, i: int) -> int:
        return self.mapping[i]

    def __mul__(self, other: Permutation) -> Permutation:
        """Composition: (self * other)(i) = self(other(i))."""
        assert self.n == other.n
        return Permutation([self(other(i)) for i in range(self.n)])

    def inverse(self) -> Permutation:
        inv = [0] * self.n
        for i, j in enumerate(self.mapping):
            inv[j] = i
        return Permutation(inv)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Permutation):
            return NotImplemented
        return self.mapping == other.mapping

    def __hash__(self) -> int:
        return hash(self.mapping)

    def __repr__(self) -> str:
        return f"Perm({list(self.mapping)})"

    @staticmethod
    def identity(n: int) -> Permutation:
        return Permutation(list(range(n)))

    def order(self) -> int:
        """Order of this permutation."""
        p = self
        e = Permutation.identity(self.n)
        k = 1
        while p != e:
            p = p * self
            k += 1
        return k


class PermGroup:
    """A permutation group given by generators."""

    def __init__(self, n: int, generators: List[Permutation]):
        self.n = n
        self.generators = generators
        self._elements: Optional[Set[Permutation]] = None

    @property
    def elements(self) -> Set[Permutation]:
        if self._elements is None:
            self._elements = self._enumerate()
        return self._elements

    def _enumerate(self) -> Set[Permutation]:
        """Generate all group elements by closure under multiplication."""
        elts: Set[Permutation] = {Permutation.identity(self.n)}
        queue = list(self.generators)
        while queue:
            g = queue.pop()
            if g not in elts:
                new_elts = set()
                for h in elts:
                    for prod in [g * h, h * g]:
                        if prod not in elts:
                            new_elts.add(prod)
                            queue.append(prod)
                elts.add(g)
                elts |= new_elts
        return elts

    def order(self) -> int:
        return len(self.elements)

    def is_abelian(self) -> bool:
        elts = list(self.elements)
        for i, a in enumerate(elts):
            for b in elts[i+1:]:
                if a * b != b * a:
                    return False
        return True

    def commutator_subgroup(self) -> PermGroup:
        """Compute [G, G] = ⟨aba⁻¹b⁻¹ | a, b ∈ G⟩."""
        commutators = set()
        for a in self.elements:
            for b in self.elements:
                c = a * b * a.inverse() * b.inverse()
                commutators.add(c)
        return PermGroup(self.n, list(commutators))


# ============================================================
# Algorithm 2: Derived Series and Derived Depth
# ============================================================

def derived_series(G: PermGroup, max_steps: int = 20) -> List[PermGroup]:
    """
    Compute the derived series G = G^(0) ⊇ G^(1) ⊇ G^(2) ⊇ ...

    Pseudocode:
        series = [G]
        while |series[-1]| > 1 and len(series) < max_steps:
            series.append(commutator_subgroup(series[-1]))
        return series
    """
    series = [G]
    for _ in range(max_steps):
        current = series[-1]
        if current.order() <= 1:
            break
        next_term = current.commutator_subgroup()
        series.append(next_term)
        if next_term.order() == current.order():
            break  # Stabilized (non-solvable)
    return series


def derived_depth(G: PermGroup) -> Optional[int]:
    """
    Compute the derived depth of G.
    Returns None if G is not solvable.

    Pseudocode:
        for n = 0, 1, 2, ...:
            if G^(n) = {e}: return n
        if series stabilizes at non-trivial group: return None
    """
    series = derived_series(G)
    for i, term in enumerate(series):
        if term.order() == 1:
            return i
    return None  # Not solvable


# ============================================================
# Algorithm 3: Chemical Classification
# ============================================================

class ChemicalClass(Enum):
    VACUUM = auto()
    NOBLE_GAS = auto()
    ALKALI = auto()
    ALKALINE_EARTH = auto()
    HALOGEN = auto()
    TRANSITION_METAL = auto()
    COMPOUND = auto()


def is_cyclic(G: PermGroup) -> bool:
    """Check if G is cyclic."""
    n = G.order()
    return any(g.order() == n for g in G.elements)


def is_nilpotent_by_center(G: PermGroup, max_steps: int = 20) -> bool:
    """
    Check nilpotency via upper central series.
    A finite group is nilpotent iff the upper central series reaches G.

    Simplified check: for small groups, a finite group is nilpotent
    iff it is the direct product of its Sylow subgroups.
    Here we use the derived series test: nilpotent groups are solvable
    and the lower central series terminates.
    """
    if G.is_abelian():
        return True

    # Check via lower central series
    current = G
    for _ in range(max_steps):
        # Compute [G, current]
        commutators = set()
        for a in G.elements:
            for b in current.elements:
                c = a * b * a.inverse() * b.inverse()
                commutators.add(c)
        next_term = PermGroup(G.n, list(commutators))
        if next_term.order() == 1:
            return True
        if next_term.order() == current.order():
            return False
        current = next_term
    return False


def is_simple(G: PermGroup) -> bool:
    """Check if G is simple (no proper normal subgroups)."""
    if G.order() <= 2:
        return G.order() == 2  # Trivially: Z/2Z is simple
    elts = G.elements
    e = Permutation.identity(G.n)

    # Check all subsets (expensive, only for small groups)
    # Simplified: check known normal subgroup candidates
    for g in elts:
        if g == e:
            continue
        # Generate the normal closure of {g}
        normal_closure = {e}
        queue = [g]
        while queue:
            h = queue.pop()
            if h not in normal_closure:
                normal_closure.add(h)
                for a in elts:
                    conj = a * h * a.inverse()
                    if conj not in normal_closure:
                        queue.append(conj)
                    prod = h * conj
                    if prod not in normal_closure:
                        queue.append(prod)
                    inv = h.inverse()
                    if inv not in normal_closure:
                        queue.append(inv)
        if 1 < len(normal_closure) < len(elts):
            return False
    return True


def classify_group(G: PermGroup) -> ChemicalClass:
    """
    Classify a permutation group into its chemical class.

    Pseudocode:
        if |G| ≤ 1: return VACUUM
        if is_simple(G) and not is_abelian(G): return TRANSITION_METAL
        if not is_solvable(G): return COMPOUND
        if not is_nilpotent(G): return HALOGEN
        if not is_abelian(G): return ALKALINE_EARTH
        if is_cyclic(G): return NOBLE_GAS
        return ALKALI
    """
    if G.order() <= 1:
        return ChemicalClass.VACUUM

    abelian = G.is_abelian()
    simple = is_simple(G)

    if simple and not abelian:
        return ChemicalClass.TRANSITION_METAL

    depth = derived_depth(G)
    solvable = depth is not None

    if not solvable:
        return ChemicalClass.COMPOUND

    nilpotent = is_nilpotent_by_center(G)

    if not nilpotent:
        return ChemicalClass.HALOGEN

    if not abelian:
        return ChemicalClass.ALKALINE_EARTH

    if is_cyclic(G):
        return ChemicalClass.NOBLE_GAS

    return ChemicalClass.ALKALI


# ============================================================
# Algorithm 4: Group Genome Construction
# ============================================================

@dataclass
class GroupGenome:
    """Complete chemical fingerprint of a finite group."""
    name: str
    order: int
    chem_class: ChemicalClass
    is_solvable: bool
    is_nilpotent: bool
    is_abelian: bool
    is_cyclic: bool
    is_simple: bool
    derived_depth: Optional[int]
    derived_series_orders: List[int] = field(default_factory=list)

    def similarity(self, other: GroupGenome) -> float:
        """Genome similarity score (0 to 1)."""
        matches = 0
        total = 5
        if self.chem_class == other.chem_class: matches += 1
        if self.is_solvable == other.is_solvable: matches += 1
        if self.is_nilpotent == other.is_nilpotent: matches += 1
        if self.is_abelian == other.is_abelian: matches += 1
        if self.is_cyclic == other.is_cyclic: matches += 1
        return matches / total


def compute_genome(G: PermGroup, name: str = "G") -> GroupGenome:
    """
    Compute the complete genome of a permutation group.

    Pseudocode:
        1. Compute order, abelianness, cyclicity, simplicity
        2. Compute derived series → depth, solvability
        3. Check nilpotency
        4. Classify into chemical class
        5. Bundle into genome tuple
    """
    series = derived_series(G)
    series_orders = [term.order() for term in series]
    depth = None
    for i, term in enumerate(series):
        if term.order() == 1:
            depth = i
            break

    return GroupGenome(
        name=name,
        order=G.order(),
        chem_class=classify_group(G),
        is_solvable=depth is not None,
        is_nilpotent=is_nilpotent_by_center(G),
        is_abelian=G.is_abelian(),
        is_cyclic=is_cyclic(G),
        is_simple=is_simple(G),
        derived_depth=depth,
        derived_series_orders=series_orders,
    )


# ============================================================
# Built-in group constructors
# ============================================================

def cyclic_group(n: int) -> PermGroup:
    """Construct the cyclic group Z/nZ as a permutation group."""
    gen = Permutation([(i + 1) % n for i in range(n)])
    return PermGroup(n, [gen])


def symmetric_group(n: int) -> PermGroup:
    """Construct S_n."""
    if n <= 1:
        return PermGroup(max(n, 1), [Permutation.identity(max(n, 1))])
    # Generators: (0 1) and (0 1 2 ... n-1)
    transposition = list(range(n))
    transposition[0], transposition[1] = 1, 0
    cycle = [(i + 1) % n for i in range(n)]
    return PermGroup(n, [Permutation(transposition), Permutation(cycle)])


def dihedral_group(n: int) -> PermGroup:
    """Construct the dihedral group D_n of order 2n."""
    # Rotation: (0 1 2 ... n-1)
    rotation = [(i + 1) % n for i in range(n)]
    # Reflection: reverse
    reflection = list(range(n - 1, -1, -1))
    return PermGroup(n, [Permutation(rotation), Permutation(reflection)])


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Group Genome Algorithm Demo")
    print("=" * 50)

    groups = [
        ("Z/1Z", cyclic_group(1)),
        ("Z/3Z", cyclic_group(3)),
        ("Z/5Z", cyclic_group(5)),
        ("S₃ = D₃", dihedral_group(3)),
        ("D₄", dihedral_group(4)),
        ("S₄", symmetric_group(4)),
    ]

    for name, G in groups:
        genome = compute_genome(G, name)
        print(f"\n{name}:")
        print(f"  Order: {genome.order}")
        print(f"  Class: {genome.chem_class.name}")
        print(f"  Solvable: {genome.is_solvable}, Nilpotent: {genome.is_nilpotent}")
        print(f"  Abelian: {genome.is_abelian}, Cyclic: {genome.is_cyclic}")
        print(f"  Simple: {genome.is_simple}")
        print(f"  Derived depth: {genome.derived_depth}")
        print(f"  Derived series orders: {genome.derived_series_orders}")
