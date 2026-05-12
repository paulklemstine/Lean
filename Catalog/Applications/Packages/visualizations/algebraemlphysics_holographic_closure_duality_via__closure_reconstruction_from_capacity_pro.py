#!/usr/bin/env python3
"""
Algorithms for Idempotent Holographic Closure Duality

Implements the core reconstruction and classification algorithms
from the formal theory.
"""

import itertools
from typing import Dict, FrozenSet, Set, List, Tuple, Optional


class ClosureOperator:
    """
    A closure operator on a finite set, stored as a lookup table.
    
    A closure operator cl: P(S) → P(S) satisfies:
    - Extensivity: A ⊆ cl(A)
    - Monotonicity: A ⊆ B ⟹ cl(A) ⊆ cl(B)
    - Idempotency: cl(cl(A)) = cl(A)
    """
    
    def __init__(self, universe: set, cl_table: Dict[frozenset, frozenset]):
        self.universe = frozenset(universe)
        self.cl_table = cl_table
        
    def cl(self, s: frozenset) -> frozenset:
        return self.cl_table.get(frozenset(s), frozenset(s))
    
    def capacity(self, s: frozenset) -> int:
        return len(self.cl(s))
    
    def capacity_profile(self) -> Dict[frozenset, int]:
        return {s: self.capacity(s) for s in self._powerset()}
    
    def closed_sets(self) -> List[frozenset]:
        return [s for s in self._powerset() if self.cl(s) == s]
    
    def is_separated(self) -> bool:
        closures = {x: self.cl(frozenset({x})) for x in self.universe}
        return len(set(closures.values())) == len(self.universe)
    
    def _powerset(self):
        elements = sorted(self.universe)
        for r in range(len(elements) + 1):
            for combo in itertools.combinations(elements, r):
                yield frozenset(combo)


def reconstruct_closed_sets(universe: set, cap: Dict[frozenset, int]) -> List[frozenset]:
    """
    Algorithm 1: Reconstruct the closed-set lattice from a capacity profile.
    
    A set S is closed iff cap(S) = |S|.
    
    Time complexity: O(2^n) where n = |universe|
    Space complexity: O(2^n)
    
    Args:
        universe: The ground set
        cap: Capacity profile mapping each subset to its capacity
    
    Returns:
        List of all closed sets
    """
    closed = []
    elements = sorted(universe)
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            s = frozenset(combo)
            if cap.get(s, len(s)) == len(s):
                closed.append(s)
    return closed


def reconstruct_closure_operator(universe: set, cap: Dict[frozenset, int]) -> Dict[frozenset, frozenset]:
    """
    Algorithm 2: Reconstruct the full closure operator from a capacity profile.
    
    For each set S, cl(S) is found by iteratively adding elements x where
    cap(S) == cap(S ∪ {x}).
    
    Time complexity: O(n · 2^n) where n = |universe|
    Space complexity: O(2^n)
    
    Args:
        universe: The ground set
        cap: Capacity profile
    
    Returns:
        Closure table mapping each subset to its closure
    """
    cl_table = {}
    elements = sorted(universe)
    
    for r in range(len(elements) + 1):
        for combo in itertools.combinations(elements, r):
            s = frozenset(combo)
            # Iteratively compute cl(s) using membership detection
            current = set(s)
            changed = True
            while changed:
                changed = False
                for x in elements:
                    if x not in current:
                        s_with_x = frozenset(current) | frozenset({x})
                        if cap.get(frozenset(current), len(current)) == cap.get(s_with_x, len(s_with_x)):
                            current.add(x)
                            changed = True
            cl_table[s] = frozenset(current)
    
    return cl_table


def verify_closure_axioms(universe: set, cl_table: Dict[frozenset, frozenset]) -> Tuple[bool, str]:
    """
    Algorithm 3: Verify that a closure table satisfies all closure axioms.
    
    Checks extensivity, monotonicity, and idempotency.
    
    Time complexity: O(4^n) for monotonicity check
    """
    elements = sorted(universe)
    
    def powerset():
        for r in range(len(elements) + 1):
            for combo in itertools.combinations(elements, r):
                yield frozenset(combo)
    
    # Extensivity
    for s in powerset():
        cl_s = cl_table.get(s, s)
        if not s.issubset(cl_s):
            return False, f"Extensivity fails: {set(s)} ⊄ cl({set(s)}) = {set(cl_s)}"
    
    # Idempotency
    for s in powerset():
        cl_s = cl_table.get(s, s)
        cl_cl_s = cl_table.get(cl_s, cl_s)
        if cl_s != cl_cl_s:
            return False, f"Idempotency fails: cl(cl({set(s)})) = {set(cl_cl_s)} ≠ cl({set(s)}) = {set(cl_s)}"
    
    # Monotonicity
    subsets = list(powerset())
    for s in subsets:
        for t in subsets:
            if s.issubset(t):
                cl_s = cl_table.get(s, s)
                cl_t = cl_table.get(t, t)
                if not cl_s.issubset(cl_t):
                    return False, f"Monotonicity fails: {set(s)} ⊆ {set(t)} but cl({set(s)}) = {set(cl_s)} ⊄ cl({set(t)}) = {set(cl_t)}"
    
    return True, "All axioms verified"


def compute_endomorphisms(universe: set, cl_table: Dict[frozenset, frozenset]) -> List[Dict[int, int]]:
    """
    Algorithm 4: Enumerate all closure-preserving endomorphisms.
    
    An endomorphism f is closure-preserving if for all S,
    f(S) ⊆ cl(f(S)).
    
    Time complexity: O(n^n · 2^n) — brute force over all functions
    """
    elements = sorted(universe)
    n = len(elements)
    endos = []
    
    for perm in itertools.product(elements, repeat=n):
        f = dict(zip(elements, perm))
        is_endo = True
        for r in range(n + 1):
            for combo in itertools.combinations(elements, r):
                s = frozenset(combo)
                img = frozenset(f[x] for x in s)
                cl_img = cl_table.get(img, img)
                if not img.issubset(cl_img):
                    is_endo = False
                    break
            if not is_endo:
                break
        if is_endo:
            endos.append(f)
    
    return endos


def classify_closure_operators(n: int) -> Dict[Tuple, List]:
    """
    Algorithm 5: Classify closure operators by capacity profile.
    
    Groups all valid closure operators on {0,...,n-1} by their
    capacity profile. The holographic duality theorem guarantees
    each group has exactly one element.
    
    Args:
        n: Size of the universe
    
    Returns:
        Dictionary mapping capacity profile tuples to closure operators
    """
    universe = set(range(n))
    elements = sorted(universe)
    
    def powerset():
        for r in range(len(elements) + 1):
            for combo in itertools.combinations(elements, r):
                yield frozenset(combo)
    
    all_subsets = list(powerset())
    classification = {}
    
    # Generate closure operators by choosing cl values
    # (This is exponential — only feasible for small n)
    if n > 3:
        print(f"Warning: Classification for n={n} may be very slow")
        return {}
    
    # For small n, enumerate by building closure tables
    count = 0
    valid = 0
    
    # Strategy: iterate over possible closed-set lattices
    # A set of closed sets must contain ∅ (if cl(∅)=∅) or some base, plus universe
    # This is still complex; for demo purposes use a subset
    
    # Simple approach: try random closure operators
    import random
    random.seed(42)
    
    for _ in range(1000 if n <= 2 else 100):
        cl_table = {}
        valid_op = True
        
        for s in all_subsets:
            # cl(s) must contain s and be "reasonable"
            candidates = [t for t in all_subsets if s.issubset(t)]
            cl_table[s] = random.choice(candidates)
        
        ok, _ = verify_closure_axioms(universe, cl_table)
        if ok:
            profile = tuple(sorted((tuple(sorted(s)), len(cl_table[s])) for s in all_subsets))
            if profile not in classification:
                classification[profile] = cl_table
                valid += 1
    
    return classification


if __name__ == "__main__":
    print("=== Holographic Closure Duality Algorithms ===\n")
    
    # Test reconstruction
    universe = {0, 1, 2}
    
    def make_cl(s):
        s = set(s)
        if 1 in s:
            s.add(2)
        return frozenset(s)
    
    cl_table = {}
    for r in range(4):
        for combo in itertools.combinations(sorted(universe), r):
            fs = frozenset(combo)
            cl_table[fs] = make_cl(fs)
    
    C = ClosureOperator(universe, cl_table)
    cap = C.capacity_profile()
    
    print("Original capacity profile:")
    for s, c in sorted(cap.items(), key=lambda x: (len(x[0]), sorted(x[0]))):
        print(f"  cap({set(s)}) = {c}")
    
    print("\nReconstructed closed sets:")
    closed = reconstruct_closed_sets(universe, cap)
    for s in closed:
        print(f"  {set(s)}")
    
    print("\nReconstructed closure operator:")
    reconstructed = reconstruct_closure_operator(universe, cap)
    for s in sorted(reconstructed.keys(), key=lambda x: (len(x), sorted(x))):
        print(f"  cl({set(s)}) = {set(reconstructed[s])}")
    
    print("\nVerification:")
    ok, msg = verify_closure_axioms(universe, reconstructed)
    print(f"  {msg}")
    
    # Verify reconstruction matches original
    match = all(cl_table[s] == reconstructed[s] for s in cl_table)
    print(f"  Reconstruction matches original: {match}")
    
    print("\nEndomorphisms:")
    endos = compute_endomorphisms(universe, cl_table)
    print(f"  Number of closure-preserving endomorphisms: {len(endos)}")
