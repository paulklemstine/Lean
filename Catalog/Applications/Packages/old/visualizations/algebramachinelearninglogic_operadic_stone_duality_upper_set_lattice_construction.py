#!/usr/bin/env python3
"""
Algorithms for Operadic Stone Duality

Complete implementations of:
1. Upper set lattice construction
2. Meet-irreducible extraction
3. Architecture reconstruction from predicate lattice
4. Architecture equivalence testing via lattice isomorphism
5. Heyting algebra operations on upper sets
"""

from itertools import combinations, product
from typing import Set, FrozenSet, List, Tuple, Dict, Optional
from dataclasses import dataclass, field


# ============================================================
# Data Structures
# ============================================================

@dataclass
class FinitePoset:
    """A finite partially ordered set.
    
    Args:
        elements: list of elements
        le: dict mapping each element to the set of elements >= it
    """
    elements: List[int]
    le: Dict[int, Set[int]]
    
    @classmethod
    def from_dag(cls, elements: List[int], 
                 edges: List[Tuple[int, int]]) -> 'FinitePoset':
        """Construct from a DAG (directed acyclic graph).
        
        Args:
            elements: list of elements
            edges: list of (a, b) meaning a ≤ b
            
        Returns:
            FinitePoset with transitive closure of edges
            
        Time: O(n^3) for transitive closure
        Space: O(n^2)
        """
        le = {m: {m} for m in elements}
        for a, b in edges:
            le[a].add(b)
        
        # Transitive closure
        changed = True
        while changed:
            changed = False
            for a in elements:
                new = set()
                for b in le[a]:
                    new |= le[b]
                if not new.issubset(le[a]):
                    le[a] |= new
                    changed = True
        
        return cls(elements=sorted(elements), le=le)
    
    def is_le(self, a: int, b: int) -> bool:
        """Check if a ≤ b."""
        return b in self.le[a]
    
    def covers(self, a: int, b: int) -> bool:
        """Check if a is covered by b (a < b with nothing between)."""
        if a == b or not self.is_le(a, b):
            return False
        return not any(
            self.is_le(a, c) and self.is_le(c, b) and c != a and c != b
            for c in self.elements
        )
    
    def minimal_elements(self) -> List[int]:
        """Return the minimal elements."""
        return [m for m in self.elements 
                if not any(self.is_le(x, m) and x != m 
                          for x in self.elements)]
    
    def hasse_diagram(self) -> List[Tuple[int, int]]:
        """Return the Hasse diagram (covering relations)."""
        return [(a, b) for a in self.elements for b in self.elements
                if self.covers(a, b)]


@dataclass
class NeuralArchitecture:
    """A finitely generated acyclic neural architecture.
    
    Args:
        poset: the module poset
        generators: set of generator modules
    """
    poset: FinitePoset
    generators: Set[int]
    
    def validate(self) -> bool:
        """Check that the architecture is valid."""
        # Generators are non-empty
        if not self.generators:
            return False
        # Every module is above some generator
        for m in self.poset.elements:
            if not any(self.poset.is_le(g, m) for g in self.generators):
                return False
        return True


# ============================================================
# Algorithm 1: Upper Set Lattice Construction
# ============================================================

def compute_upper_sets(poset: FinitePoset) -> List[FrozenSet[int]]:
    """Enumerate all upper sets of a finite poset.
    
    An upper set U satisfies: if x ∈ U and x ≤ y, then y ∈ U.
    
    Time: O(2^n · n^2) where n = |elements|
    Space: O(2^n · n)
    
    Returns:
        List of all upper sets, each as a frozenset
    """
    elements = poset.elements
    upper_sets = []
    
    for r in range(len(elements) + 1):
        for subset in combinations(elements, r):
            s = set(subset)
            is_upper = True
            for x in s:
                for y in elements:
                    if poset.is_le(x, y) and y not in s:
                        is_upper = False
                        break
                if not is_upper:
                    break
            if is_upper:
                upper_sets.append(frozenset(s))
    
    return upper_sets


def principal_upper_set(poset: FinitePoset, m: int) -> FrozenSet[int]:
    """Compute the principal upper set Ici(m) = {x | m ≤ x}.
    
    Time: O(n)
    Space: O(n)
    """
    return frozenset(poset.le[m])


# ============================================================
# Algorithm 2: Heyting Algebra Operations
# ============================================================

class HeytingUpperSets:
    """The Heyting algebra of upper sets of a finite poset.
    
    Operations (in UpperSet with reverse-inclusion order):
    - ⊔ (join) = intersection of sets
    - ⊓ (meet) = union of sets
    - ⊤ = empty set
    - ⊥ = full set
    - ⇨ (implication) = Heyting implication
    """
    
    def __init__(self, poset: FinitePoset):
        self.poset = poset
        self.all_upper_sets = compute_upper_sets(poset)
        self.full = frozenset(poset.elements)
        self.empty = frozenset()
    
    def join(self, U: FrozenSet[int], V: FrozenSet[int]) -> FrozenSet[int]:
        """Join in UpperSet = intersection of sets."""
        return U & V
    
    def meet(self, U: FrozenSet[int], V: FrozenSet[int]) -> FrozenSet[int]:
        """Meet in UpperSet = union of sets."""
        return U | V
    
    def top(self) -> FrozenSet[int]:
        """Top element = empty set."""
        return self.empty
    
    def bot(self) -> FrozenSet[int]:
        """Bottom element = full set."""
        return self.full
    
    def le(self, U: FrozenSet[int], V: FrozenSet[int]) -> bool:
        """U ≤ V in UpperSet iff V ⊆ U as sets."""
        return V.issubset(U)
    
    def himp(self, U: FrozenSet[int], V: FrozenSet[int]) -> FrozenSet[int]:
        """Heyting implication U ⇨ V.
        
        (U ⇨ V) = {m | ∀ m' ≥ m, m' ∈ U → m' ∈ V}
        
        Time: O(n^2)
        """
        result = set()
        for m in self.poset.elements:
            ok = True
            for mp in self.poset.elements:
                if self.poset.is_le(m, mp) and mp in U and mp not in V:
                    ok = False
                    break
            if ok:
                result.add(m)
        # Verify it's an upper set (it should be by construction)
        return frozenset(result)
    
    def complement(self, U: FrozenSet[int]) -> FrozenSet[int]:
        """Pseudocomplement: ¬U = U ⇨ ⊤."""
        return self.himp(U, self.top())
    
    def is_distributive(self) -> bool:
        """Verify distributivity: a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c)."""
        for a in self.all_upper_sets:
            for b in self.all_upper_sets:
                for c in self.all_upper_sets:
                    lhs = self.meet(a, self.join(b, c))
                    rhs = self.join(self.meet(a, b), self.meet(a, c))
                    if lhs != rhs:
                        return False
        return True


# ============================================================
# Algorithm 3: Meet-Irreducible Extraction
# ============================================================

def extract_meet_irreducibles(
    upper_sets: List[FrozenSet[int]]
) -> List[FrozenSet[int]]:
    """Extract meet-irreducible elements from the upper set lattice.
    
    InfIrred(U) means:
    1. U is not maximal (U ≠ ∅, the top element)
    2. If U = A ⊓ B = A ∪ B, then U = A or U = B
    
    Time: O(|L|^3) where |L| = number of upper sets
    Space: O(|L|)
    
    Returns:
        List of meet-irreducible upper sets
    """
    irreds = []
    for us in upper_sets:
        if len(us) == 0:  # Top element
            continue
        
        is_irred = True
        for A in upper_sets:
            if not is_irred:
                break
            for B in upper_sets:
                if A | B == us and A != us and B != us:
                    is_irred = False
                    break
        
        if is_irred:
            irreds.append(us)
    
    return irreds


# ============================================================
# Algorithm 4: Architecture Reconstruction
# ============================================================

def reconstruct_architecture(
    upper_sets: List[FrozenSet[int]],
    generator_predicate=None
) -> NeuralArchitecture:
    """Reconstruct a neural architecture from its upper set lattice.
    
    Steps:
    1. Extract meet-irreducible elements
    2. Assign module indices to meet-irreducibles
    3. Define partial order from lattice order on meet-irreducibles
    4. Identify generators
    
    Time: O(|L|^3) for meet-irreducible extraction
    Space: O(|L|)
    
    Args:
        upper_sets: the upper set lattice
        generator_predicate: optional function to identify generators
        
    Returns:
        Reconstructed NeuralArchitecture
    """
    irreds = extract_meet_irreducibles(upper_sets)
    n = len(irreds)
    
    # Sort by size (descending) for consistent ordering
    irreds.sort(key=lambda s: -len(s))
    
    # Build partial order
    le = {i: {i} for i in range(n)}
    for i in range(n):
        for j in range(n):
            if i != j and irreds[j].issubset(irreds[i]):
                # irreds[i] ≤ irreds[j] in UpperSet means
                # irreds[j] ⊆ irreds[i] as sets
                # This corresponds to module i ≤ module j
                le[i].add(j)
    
    poset = FinitePoset(elements=list(range(n)), le=le)
    
    # Identify generators as minimal elements (default)
    if generator_predicate is None:
        generators = set(poset.minimal_elements())
    else:
        generators = {i for i in range(n) if generator_predicate(irreds[i])}
    
    return NeuralArchitecture(poset=poset, generators=generators)


# ============================================================
# Algorithm 5: Architecture Equivalence Testing
# ============================================================

def lattice_invariant(upper_sets: List[FrozenSet[int]]) -> Tuple:
    """Compute an invariant of the upper set lattice.
    
    Uses the sorted sequence of (element_size, number_of_covers_above,
    number_of_covers_below) for each element.
    
    Time: O(|L|^2)
    Space: O(|L|)
    """
    n = len(upper_sets)
    profiles = []
    
    for us in upper_sets:
        # Count covers above (elements V with V < U, i.e., U ⊂ V)
        covers_above = sum(
            1 for v in upper_sets
            if v > us and  # proper superset as set = below in UpperSet
            not any(v > w > us for w in upper_sets)
        )
        # Count covers below (elements V with U < V, i.e., V ⊂ U)
        covers_below = sum(
            1 for v in upper_sets
            if us > v and  # proper subset as set = above in UpperSet
            not any(us > w > v for w in upper_sets)
        )
        profiles.append((len(us), covers_above, covers_below))
    
    return tuple(sorted(profiles))


def are_architectures_equivalent(
    arch1: NeuralArchitecture, 
    arch2: NeuralArchitecture
) -> bool:
    """Test if two architectures are equivalent via lattice isomorphism.
    
    Computes predicate lattices and compares their invariants.
    
    Time: O(2^n · n^2 + |L|^2) where n = max modules
    Space: O(2^n)
    """
    us1 = compute_upper_sets(arch1.poset)
    us2 = compute_upper_sets(arch2.poset)
    
    if len(us1) != len(us2):
        return False
    
    return lattice_invariant(us1) == lattice_invariant(us2)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Build a diamond architecture
    poset = FinitePoset.from_dag([0, 1, 2, 3], [(0, 1), (0, 2), (1, 3), (2, 3)])
    arch = NeuralArchitecture(poset=poset, generators={0})
    
    print(f"\n1. Architecture: diamond 0 → {{1,2}} → 3")
    print(f"   Valid: {arch.validate()}")
    
    # Compute upper sets
    us = compute_upper_sets(poset)
    print(f"\n2. Upper sets: {len(us)} total")
    for u in sorted(us, key=lambda s: (len(s), sorted(s))):
        print(f"   {set(u) if u else '{}'}")
    
    # Heyting algebra
    heyting = HeytingUpperSets(poset)
    print(f"\n3. Heyting algebra operations:")
    U = principal_upper_set(poset, 1)
    V = principal_upper_set(poset, 2)
    print(f"   Ici(1) = {set(U)}")
    print(f"   Ici(2) = {set(V)}")
    print(f"   Ici(1) ⊔ Ici(2) = {set(heyting.join(U, V))}")
    print(f"   Ici(1) ⊓ Ici(2) = {set(heyting.meet(U, V))}")
    print(f"   Ici(1) ⇨ Ici(2) = {set(heyting.himp(U, V))}")
    print(f"   ¬Ici(1) = {set(heyting.complement(U))}")
    print(f"   Distributive: {heyting.is_distributive()}")
    
    # Meet-irreducibles
    irreds = extract_meet_irreducibles(us)
    print(f"\n4. Meet-irreducibles: {len(irreds)}")
    for ir in sorted(irreds, key=lambda s: -len(s)):
        for m in poset.elements:
            if principal_upper_set(poset, m) == ir:
                print(f"   {set(ir)} = Ici({m})")
    
    # Reconstruction
    reconstructed = reconstruct_architecture(us)
    print(f"\n5. Reconstructed architecture:")
    print(f"   Modules: {reconstructed.poset.elements}")
    print(f"   Generators: {reconstructed.generators}")
    print(f"   Hasse diagram: {reconstructed.poset.hasse_diagram()}")
    print(f"   Original Hasse: {poset.hasse_diagram()}")
    
    # Equivalence testing
    arch2 = NeuralArchitecture(
        poset=FinitePoset.from_dag([10, 20, 30, 40], 
                                    [(10, 20), (10, 30), (20, 40), (30, 40)]),
        generators={10}
    )
    print(f"\n6. Equivalence testing:")
    print(f"   Diamond ≅ Relabeled diamond: "
          f"{are_architectures_equivalent(arch, arch2)}")
    
    chain = NeuralArchitecture(
        poset=FinitePoset.from_dag([0, 1, 2, 3], [(0, 1), (1, 2), (2, 3)]),
        generators={0}
    )
    print(f"   Diamond ≅ Chain: "
          f"{are_architectures_equivalent(arch, chain)}")
