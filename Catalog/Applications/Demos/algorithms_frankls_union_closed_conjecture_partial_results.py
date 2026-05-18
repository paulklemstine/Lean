#!/usr/bin/env python3
"""
Algorithms for Frankl's Union-Closed Conjecture

Implements:
1. Union-closure generation (incremental and batch)
2. Frankl property verification
3. Canonical family enumeration with isomorphism reduction
4. Abundance analysis and frequency spectrum computation
5. Double-counting verification
"""

from itertools import combinations, permutations
from collections import defaultdict
from typing import Optional


class UnionClosedFamily:
    """Represents a union-closed family of finite sets.
    
    Provides efficient operations for computing abundance,
    verifying Frankl's property, and analyzing family structure.
    
    Time complexity:
        - Construction: O(n²) where n = |F|
        - Abundance query: O(n)
        - Frankl verification: O(n * |U|)
        - Union closure: O(n² * |U|) per iteration, O(n³ * |U|) total
    
    Space complexity: O(n * |U|)
    """
    
    def __init__(self, sets: list[frozenset]):
        """Initialize with a list of frozensets."""
        self.sets = set(sets)
        self._universe = frozenset()
        for s in self.sets:
            self._universe = self._universe | s
    
    @classmethod
    def from_generators(cls, generators: list[frozenset]) -> 'UnionClosedFamily':
        """Generate the union-closure from a set of generators.
        
        Algorithm: Fixed-point iteration
            1. Start with generator set G
            2. Repeat: add all pairwise unions
            3. Stop when no new sets are added
        
        Complexity: O(n³ * |U|) where n is the final family size
        """
        family = set(generators)
        changed = True
        iterations = 0
        while changed:
            changed = False
            iterations += 1
            new_sets = set()
            family_list = list(family)
            for i in range(len(family_list)):
                for j in range(i, len(family_list)):
                    union = family_list[i] | family_list[j]
                    if union not in family:
                        new_sets.add(union)
                        changed = True
            family |= new_sets
        
        result = cls(list(family))
        result._iterations = iterations
        return result
    
    @property
    def universe(self) -> frozenset:
        """The universe (union of all sets in the family)."""
        return self._universe
    
    @property
    def size(self) -> int:
        """Number of sets in the family."""
        return len(self.sets)
    
    def is_union_closed(self) -> bool:
        """Verify the family is union-closed. O(n² * |U|)."""
        for A in self.sets:
            for B in self.sets:
                if A | B not in self.sets:
                    return False
        return True
    
    def abundance(self, x) -> int:
        """Compute the abundance of element x. O(n)."""
        return sum(1 for s in self.sets if x in s)
    
    def coabundance(self, x) -> int:
        """Compute the coabundance of element x. O(n)."""
        return sum(1 for s in self.sets if x not in s)
    
    def all_abundances(self) -> dict:
        """Compute abundances for all elements. O(n * |U|)."""
        return {x: self.abundance(x) for x in self.universe}
    
    def frequency_spectrum(self) -> dict[int, list]:
        """Group elements by their abundance value."""
        spectrum = defaultdict(list)
        for x in self.universe:
            spectrum[self.abundance(x)].append(x)
        return dict(spectrum)
    
    def verify_frankl(self) -> tuple[bool, Optional[object], int]:
        """Verify Frankl's property.
        
        Returns: (satisfied, best_element, best_abundance)
        """
        if not self.universe:
            return False, None, 0
        
        abundances = self.all_abundances()
        best = max(abundances, key=abundances.get)
        best_ab = abundances[best]
        
        return 2 * best_ab >= self.size, best, best_ab
    
    def sum_of_sizes(self) -> int:
        """Compute ∑_{s ∈ F} |s|."""
        return sum(len(s) for s in self.sets)
    
    def sum_of_abundances(self) -> int:
        """Compute ∑_{x ∈ U} abundance(x)."""
        return sum(self.abundance(x) for x in self.universe)
    
    def verify_double_counting(self) -> bool:
        """Verify ∑|s| = ∑ abundance(x)."""
        return self.sum_of_sizes() == self.sum_of_abundances()
    
    def minimal_members(self) -> set[frozenset]:
        """Find inclusion-minimal nonempty members."""
        minimals = set()
        nonempty = {s for s in self.sets if len(s) > 0}
        for s in nonempty:
            if not any(t < s for t in nonempty):  # proper subset
                minimals.add(s)
        return minimals
    
    def maximal_member(self) -> frozenset:
        """The maximal member (= universe, for union-closed families)."""
        return self._universe
    
    def union_map_analysis(self, s: frozenset, x) -> dict:
        """Analyze the union map t ↦ s ∪ t for a fixed s and x ∈ s.
        
        This implements the key structural lemma: the union map sends
        sets not containing x to sets containing x.
        """
        if x not in s or s not in self.sets:
            return {'error': 'Invalid input'}
        
        not_containing_x = [t for t in self.sets if x not in t]
        images = {s | t for t in not_containing_x}
        containing_x = [t for t in self.sets if x in t]
        
        return {
            'sets_not_containing_x': len(not_containing_x),
            'image_size': len(images),
            'sets_containing_x': len(containing_x),
            'image_subset_check': all(img in self.sets and x in img for img in images),
            'abundance_lower_bound': len(images),
            'coabundance': len(not_containing_x),
        }


def canonical_representative(family: set[frozenset], universe_size: int) -> tuple[frozenset, ...]:
    """Compute a canonical representative under element permutations.
    
    Algorithm: Try all permutations of the universe and return
    the lexicographically smallest representation.
    
    Complexity: O(|U|! * n * |U|) — only feasible for small universes.
    """
    universe = list(range(universe_size))
    best = None
    
    for perm in permutations(universe):
        mapping = {old: new for old, new in zip(universe, perm)}
        mapped = frozenset(
            frozenset(mapping[x] for x in s) 
            for s in family
        )
        canonical = tuple(sorted(tuple(sorted(s)) for s in mapped))
        if best is None or canonical < best:
            best = canonical
    
    return best


def enumerate_canonical_families(universe_size: int, 
                                  max_family_size: Optional[int] = None) -> list[set[frozenset]]:
    """Enumerate canonical representatives of union-closed families.
    
    Algorithm: Canonical augmentation
        1. Generate all subsets of the power set
        2. Check union-closure
        3. Reduce modulo element permutations
        4. Return canonical representatives
    
    This is a simplified version; a production implementation would use
    McKay's canonical augmentation for efficiency.
    """
    all_subsets = []
    universe = list(range(universe_size))
    for r in range(universe_size + 1):
        for combo in combinations(universe, r):
            all_subsets.append(frozenset(combo))
    
    seen = set()
    families = []
    
    for size in range(1, (max_family_size or len(all_subsets)) + 1):
        for combo in combinations(all_subsets, size):
            family = set(combo)
            
            # Check union-closed
            is_uc = True
            for A in family:
                if not is_uc:
                    break
                for B in family:
                    if A | B not in family:
                        is_uc = False
                        break
            
            if not is_uc:
                continue
            
            # Check has nonempty member
            if not any(len(s) > 0 for s in family):
                continue
            
            # Get canonical form
            canon = canonical_representative(family, universe_size)
            if canon not in seen:
                seen.add(canon)
                families.append(family)
    
    return families


def verify_frankl_exhaustive(universe_size: int, max_family_size: Optional[int] = None) -> dict:
    """Exhaustively verify Frankl's property for all union-closed families
    over a given universe size.
    
    Returns a dictionary with verification results.
    """
    families = enumerate_canonical_families(universe_size, max_family_size)
    
    results = {
        'universe_size': universe_size,
        'total_families': len(families),
        'all_satisfy': True,
        'counterexamples': [],
        'abundance_distribution': defaultdict(int),
    }
    
    for family in families:
        ucf = UnionClosedFamily(list(family))
        satisfied, best, best_ab = ucf.verify_frankl()
        
        if not satisfied:
            results['all_satisfy'] = False
            results['counterexamples'].append(family)
        
        results['abundance_distribution'][best_ab] += 1
    
    return results


if __name__ == "__main__":
    print("Frankl's Union-Closed Conjecture: Algorithm Demonstrations")
    print("=" * 60)
    
    # Demo 1: Union closure from generators
    print("\n--- Union Closure Generation ---")
    generators = [frozenset({0, 1}), frozenset({1, 2}), frozenset({0, 3})]
    ucf = UnionClosedFamily.from_generators(generators)
    print(f"Generators: {[set(g) for g in generators]}")
    print(f"Closure size: {ucf.size}")
    print(f"Universe: {set(ucf.universe)}")
    print(f"Union-closed: {ucf.is_union_closed()}")
    print(f"Double-counting identity: {ucf.verify_double_counting()}")
    
    satisfied, best, best_ab = ucf.verify_frankl()
    print(f"Frankl's property: {satisfied} (best element: {best}, abundance: {best_ab}/{ucf.size})")
    
    # Demo 2: Frequency spectrum
    print("\n--- Frequency Spectrum ---")
    spectrum = ucf.frequency_spectrum()
    for ab, elements in sorted(spectrum.items()):
        print(f"  Abundance {ab}: elements {elements}")
    
    # Demo 3: Union map analysis
    print("\n--- Union Map Analysis ---")
    minimals = ucf.minimal_members()
    print(f"Minimal members: {[set(m) for m in minimals]}")
    for m in minimals:
        for x in sorted(m):
            analysis = ucf.union_map_analysis(m, x)
            print(f"  s={set(m)}, x={x}: coabundance={analysis['coabundance']}, "
                  f"image_size={analysis['image_size']}, "
                  f"abundance={ucf.abundance(x)}")
            break
        break
    
    # Demo 4: Exhaustive verification
    print("\n--- Exhaustive Verification ---")
    for n in range(1, 4):
        results = verify_frankl_exhaustive(n)
        print(f"  Universe size {n}: {results['total_families']} canonical families, "
              f"all satisfy Frankl: {results['all_satisfy']}")
    
    print("\nAll algorithm demonstrations complete.")
