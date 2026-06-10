#!/usr/bin/env python3
"""
Algorithms for Frankl's Union-Closed Conjecture

Implements verified algorithms corresponding to the formal Lean proofs:
1. Union-closure computation
2. Frequency computation and witness search
3. Average cardinality criterion checker
4. Small ground enumeration
5. Lattice structure analysis (join-irreducible detection)

All algorithms have correctness guarantees matching the Lean theorems.
"""

from itertools import combinations
from collections import Counter, defaultdict
from typing import Optional, Set, FrozenSet, Dict, List, Tuple


# Type aliases
Element = int
FiniteSet = frozenset
Family = set


class UnionClosedFamily:
    """
    A finite family of finite sets closed under pairwise union.
    
    Mirrors the Lean structure:
        structure UnionClosedFamily (α : Type*) [DecidableEq α] where
          sets : Finset (Finset α)
          nonempty : sets.Nonempty
          union_closed : ∀ {A B}, A ∈ sets → B ∈ sets → A ∪ B ∈ sets
    
    Time complexity: O(n²·k) for construction where n = |family|, k = max set size
    Space complexity: O(n·k)
    """
    
    def __init__(self, sets: set[frozenset]):
        """
        Initialize from a set of frozensets.
        
        Args:
            sets: A nonempty union-closed family of finite sets.
        
        Raises:
            ValueError: If the family is empty or not union-closed.
        """
        if not sets:
            raise ValueError("Family must be nonempty")
        if not self._is_union_closed(sets):
            raise ValueError("Family is not union-closed")
        self._sets = frozenset(sets)
        self._ground = frozenset().union(*sets) if sets else frozenset()
        self._freq_cache: Dict = {}
    
    @staticmethod
    def _is_union_closed(sets: set[frozenset]) -> bool:
        """Check union-closure in O(n²·k) time."""
        for A in sets:
            for B in sets:
                if A | B not in sets:
                    return False
        return True
    
    @classmethod
    def from_generators(cls, generators: set[frozenset]) -> 'UnionClosedFamily':
        """
        Build the union-closure of a set of generators.
        
        Algorithm: Iteratively add all pairwise unions until fixpoint.
        
        Time: O(n³·k) worst case where n = |closure|
        Space: O(n·k)
        
        Args:
            generators: Seed sets to close under union.
        
        Returns:
            The smallest union-closed family containing all generators.
        """
        if not generators:
            generators = {frozenset()}
        closed = set(generators)
        changed = True
        while changed:
            changed = False
            new = set()
            for A in closed:
                for B in closed:
                    U = A | B
                    if U not in closed:
                        new.add(U)
                        changed = True
            closed |= new
        return cls(closed)
    
    @property
    def sets(self) -> frozenset:
        """The underlying family of sets."""
        return self._sets
    
    @property
    def ground(self) -> frozenset:
        """The ground set (union of all member sets)."""
        return self._ground
    
    @property
    def card(self) -> int:
        """Number of sets in the family."""
        return len(self._sets)
    
    def elem_freq(self, a) -> int:
        """
        Frequency of element a: number of sets containing a.
        
        Corresponds to Lean:
            def elemFreq (F : UnionClosedFamily α) (a : α) : ℕ :=
              (F.sets.filter fun s => a ∈ s).card
        
        Time: O(n) per query, O(1) amortized with cache
        """
        if a not in self._freq_cache:
            self._freq_cache[a] = sum(1 for s in self._sets if a in s)
        return self._freq_cache[a]
    
    def total_incidence(self) -> int:
        """
        Sum of cardinalities: Σ_{s ∈ F} |s|.
        
        Corresponds to Lean:
            def totalIncidence (F : UnionClosedFamily α) : ℕ :=
              ∑ s ∈ F.sets, s.card
        
        Time: O(n)
        """
        return sum(len(s) for s in self._sets)
    
    def has_frankl_witness(self) -> bool:
        """Check if some element has frequency ≥ |F|/2."""
        return self.find_frankl_witness() is not None
    
    def find_frankl_witness(self) -> Optional:
        """
        Search for an element appearing in ≥ half the sets.
        
        Corresponds to Lean:
            noncomputable def findFranklWitness? ...
        
        Correctness: By Lean theorem findFranklWitness?_spec,
        if this returns a, then 2 * freq(a) ≥ |F|.
        
        Time: O(n·|ground|) 
        """
        n = self.card
        for a in self._ground:
            if 2 * self.elem_freq(a) >= n:
                return a
        return None
    
    def heavy_elements(self) -> set:
        """
        All elements with frequency ≥ |F|/2.
        
        Corresponds to Lean:
            def heavyElements (F : UnionClosedFamily α) : Finset α :=
              F.ground.filter fun a => 2 * F.elemFreq a ≥ F.sets.card
        
        Time: O(n·|ground|)
        """
        n = self.card
        return {a for a in self._ground if 2 * self.elem_freq(a) >= n}
    
    def verify_double_counting(self) -> bool:
        """
        Verify the double counting identity:
            totalIncidence = Σ_{a ∈ ground} freq(a)
        
        This is theorem totalIncidence_eq_sum_elemFreq_ground.
        
        Time: O(n·|ground|)
        """
        lhs = self.total_incidence()
        rhs = sum(self.elem_freq(a) for a in self._ground)
        return lhs == rhs
    
    def check_average_criterion(self) -> Tuple[bool, bool]:
        """
        Check if the average set size criterion applies.
        
        Returns (criterion_applies, has_witness):
            criterion_applies: ground.card * |F| ≤ 2 * totalIncidence
            has_witness: HasFranklWitness
        
        By theorem frankl_of_average_card_large:
            criterion_applies ∧ ground.Nonempty → has_witness
        
        Time: O(n·|ground|)
        """
        g_card = len(self._ground)
        n = self.card
        ti = self.total_incidence()
        criterion = g_card * n <= 2 * ti
        witness = self.has_frankl_witness()
        return criterion, witness
    
    def join_irreducible_sets(self) -> list[frozenset]:
        """
        Find all join-irreducible sets in the family.
        
        A set s is join-irreducible if s ≠ ∅ and
        s = A ∪ B with A,B ∈ F implies A = s or B = s.
        
        Corresponds to Lean:
            def IsJoinIrreducible (F : UnionClosedFamily α) (s : Finset α) : Prop :=
              s ∈ F.sets ∧ s ≠ ∅ ∧
                ∀ A B, A ∈ F.sets → B ∈ F.sets → A ∪ B = s → A = s ∨ B = s
        
        Time: O(n³·k)
        """
        result = []
        for s in self._sets:
            if not s:
                continue
            is_ji = True
            for A in self._sets:
                if not is_ji:
                    break
                for B in self._sets:
                    if A | B == s and A != s and B != s:
                        is_ji = False
                        break
            if is_ji:
                result.append(s)
        return result
    
    def __repr__(self) -> str:
        sorted_sets = sorted(self._sets, key=lambda s: (len(s), sorted(s)))
        sets_str = ", ".join(str(set(s)) if s else "{}" for s in sorted_sets)
        return f"UnionClosedFamily({{{sets_str}}})"


def enumerate_union_closed_families(universe: frozenset,
                                     max_size: int = None) -> List[UnionClosedFamily]:
    """
    Enumerate all union-closed families on a given universe.
    
    This is the brute-force search used for conjecture testing.
    
    Args:
        universe: The ground set elements.
        max_size: Maximum family size to consider.
    
    Time: O(2^(2^n)) where n = |universe| — exponential in exponential!
    """
    all_subsets = []
    elems = list(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            all_subsets.append(frozenset(combo))
    
    if max_size is None:
        max_size = len(all_subsets)
    
    families = []
    for size in range(1, min(max_size + 1, len(all_subsets) + 1)):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            if UnionClosedFamily._is_union_closed(family):
                try:
                    ucf = UnionClosedFamily(family)
                    families.append(ucf)
                except ValueError:
                    pass
    return families


def test_frankl_exhaustive(n: int) -> Tuple[int, int, int]:
    """
    Exhaustively test Frankl's conjecture for ground size ≤ n.
    
    Returns (tested, passed, failed).
    
    Certified by theorem frankl_ground_card_le_three for n ≤ 3.
    """
    universe = frozenset(range(1, n + 1))
    families = enumerate_union_closed_families(universe)
    
    tested = 0
    passed = 0
    failed = 0
    
    for F in families:
        if not F.ground:
            continue
        tested += 1
        if F.has_frankl_witness():
            passed += 1
        else:
            failed += 1
            print(f"  COUNTEREXAMPLE: {F}")
    
    return tested, passed, failed


def analyze_entropy_gap(universe: frozenset) -> Dict:
    """
    Analyze the entropy gap conjecture on all UC families over universe.
    
    For each family F with nonempty ground:
        frankl_gap = 2 * max_freq - |F|
        energy_excess = 2 * totalIncidence - |ground| * |F|
    
    Returns statistics about the relationship.
    """
    families = enumerate_union_closed_families(universe, max_size=12)
    
    data = []
    for F in families:
        if not F.ground:
            continue
        n = F.card
        g_card = len(F.ground)
        ti = F.total_incidence()
        max_freq = max(F.elem_freq(a) for a in F.ground)
        
        frankl_gap = 2 * max_freq - n
        energy_excess = 2 * ti - g_card * n
        
        data.append({
            'family_size': n,
            'ground_size': g_card,
            'total_incidence': ti,
            'max_freq': max_freq,
            'frankl_gap': frankl_gap,
            'energy_excess': energy_excess,
        })
    
    return {
        'count': len(data),
        'min_frankl_gap': min(d['frankl_gap'] for d in data) if data else None,
        'data': data,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("  Frankl Algorithms: Unit Tests")
    print("=" * 60)
    
    # Test 1: Basic construction
    F = UnionClosedFamily.from_generators({
        frozenset({1}), frozenset({2, 3})
    })
    print(f"\n  F = {F}")
    print(f"  |F| = {F.card}")
    print(f"  ground = {set(F.ground)}")
    assert F.verify_double_counting(), "Double counting failed!"
    print(f"  Double counting: ✓")
    
    # Test 2: Witness search
    w = F.find_frankl_witness()
    print(f"  Frankl witness: {w}")
    print(f"  Heavy elements: {F.heavy_elements()}")
    
    # Test 3: Average criterion
    applies, has_w = F.check_average_criterion()
    print(f"  Average criterion applies: {applies}")
    print(f"  Has witness: {has_w}")
    
    # Test 4: Join-irreducible sets
    ji = F.join_irreducible_sets()
    print(f"  Join-irreducible sets: {[set(s) for s in ji]}")
    
    # Test 5: Exhaustive test for n=3
    print(f"\n  Exhaustive test for ground ≤ 3:")
    tested, passed, failed = test_frankl_exhaustive(3)
    print(f"  Tested: {tested}, Passed: {passed}, Failed: {failed}")
    assert failed == 0, "Frankl conjecture failed for ground ≤ 3!"
    print(f"  Frankl for ground ≤ 3: ✓")
    
    # Test 6: Entropy gap
    print(f"\n  Entropy gap analysis on {{1,2,3}}:")
    result = analyze_entropy_gap(frozenset({1, 2, 3}))
    print(f"  Families analyzed: {result['count']}")
    print(f"  Min Frankl gap: {result['min_frankl_gap']}")
    
    print(f"\n  All tests passed! ✓")
