#!/usr/bin/env python3
"""
Algorithms for EML Closure Systems

Implements the core algorithms for computing closures, cores, minimal generators,
Galois connections, and lattice structures for finite closure systems.

All algorithms come with complexity analysis and example usage.
"""

import itertools
from typing import FrozenSet, Set, List, Dict, Tuple, Optional, Callable
from collections import defaultdict


class FiniteClosureOperator:
    """
    A closure operator on a finite set, with algorithms for:
    - Closure computation
    - Closed set enumeration
    - Core computation
    - Minimal generator computation
    - Galois connection verification
    - Hasse diagram construction

    Time complexity:
    - closure(S): O(T_cl) where T_cl is the cost of the closure function
    - closed_sets(): O(2^n * T_cl) where n = |universe|
    - core(C): O(2^n * T_cl)
    - hasse_diagram(): O(k^2 * n) where k = number of closed sets

    Space complexity: O(2^n) for storing all subsets
    """

    def __init__(self, universe: FrozenSet, closure_fn: Callable[[FrozenSet], FrozenSet]):
        self.universe = universe
        self.n = len(universe)
        self._closure_fn = closure_fn
        self._closed_cache: Optional[List[FrozenSet]] = None

    def closure(self, S: FrozenSet) -> FrozenSet:
        """
        Compute cl(S).

        Time: O(T_cl)
        Space: O(n)
        """
        return self._closure_fn(S)

    def is_closed(self, S: FrozenSet) -> bool:
        """Check if S is a fixed point of the closure operator."""
        return self.closure(S) == S

    def all_subsets(self) -> List[FrozenSet]:
        """Generate all subsets of the universe."""
        result = []
        for r in range(self.n + 1):
            for combo in itertools.combinations(sorted(self.universe), r):
                result.append(frozenset(combo))
        return result

    def closed_sets(self) -> List[FrozenSet]:
        """
        Enumerate all closed sets by brute force.

        Time: O(2^n * T_cl)
        Space: O(2^n)

        For large universes, consider NextClosure (Ganter's algorithm) instead.
        """
        if self._closed_cache is not None:
            return self._closed_cache
        self._closed_cache = sorted(
            [S for S in self.all_subsets() if self.is_closed(S)],
            key=lambda s: (len(s), sorted(s))
        )
        return self._closed_cache

    def core(self, C: FrozenSet) -> FrozenSet:
        """
        Compute emlCore(C) = ⋂{A | C ⊆ cl(A)}.

        Time: O(2^n * T_cl)
        Space: O(2^n)
        """
        generators = [A for A in self.all_subsets() if C <= self.closure(A)]
        if not generators:
            return self.universe
        return frozenset.intersection(*generators)

    def minimal_generators_eq(self, C: FrozenSet) -> FrozenSet:
        """
        Compute minimalGeneratorsEq(C) = ⋂{A | cl(A) = C}.

        Time: O(2^n * T_cl)
        Space: O(2^n)
        """
        exact_gens = [A for A in self.all_subsets() if self.closure(A) == C]
        if not exact_gens:
            return self.universe
        return frozenset.intersection(*exact_gens)

    def irredundant_generators(self, C: FrozenSet) -> List[FrozenSet]:
        """
        Find all irredundant generating sets for C.
        A is irredundant if cl(A) = C and cl(A \ {a}) ≠ C for all a ∈ A.

        Time: O(2^n * n * T_cl)
        """
        result = []
        for A in self.all_subsets():
            if self.closure(A) != C:
                continue
            irredundant = True
            for a in A:
                if self.closure(A - {a}) == C:
                    irredundant = False
                    break
            if irredundant:
                result.append(A)
        return result

    def hasse_diagram(self) -> Dict[FrozenSet, List[FrozenSet]]:
        """
        Compute the Hasse diagram of the lattice of closed sets.
        Returns a dict mapping each closed set to its immediate successors.

        Time: O(k^2 * n) where k = number of closed sets
        Space: O(k^2)
        """
        closed = self.closed_sets()
        covers: Dict[FrozenSet, List[FrozenSet]] = {C: [] for C in closed}

        for i, C1 in enumerate(closed):
            for C2 in closed[i+1:]:
                if C1 < C2:
                    # Check if C2 covers C1 (no C3 with C1 ⊂ C3 ⊂ C2)
                    is_cover = True
                    for C3 in closed:
                        if C1 < C3 < C2:
                            is_cover = False
                            break
                    if is_cover:
                        covers[C1].append(C2)

        return covers

    def verify_galois_connection(self) -> Tuple[bool, Optional[str]]:
        """
        Verify cl(A) ⊆ C ↔ A ⊆ C for all A and closed C.

        Time: O(2^n * k * T_cl) where k = number of closed sets
        """
        closed = self.closed_sets()
        for A in self.all_subsets():
            cl_A = self.closure(A)
            for C in closed:
                lhs = cl_A <= C
                rhs = A <= C
                if lhs != rhs:
                    return False, f"Failed: A={set(A)}, C={set(C)}, cl(A)⊆C={lhs}, A⊆C={rhs}"
        return True, None

    def verify_moore_family(self) -> Tuple[bool, Optional[str]]:
        """
        Verify that closed sets are closed under arbitrary intersection.

        Time: O(k^2) where k = number of closed sets
        """
        closed = self.closed_sets()
        for i, C1 in enumerate(closed):
            for C2 in closed[i:]:
                inter = C1 & C2
                if not self.is_closed(inter):
                    return False, f"Failed: {set(C1)} ∩ {set(C2)} = {set(inter)} is not closed"
        return True, None

    def verify_core_hierarchy(self) -> Tuple[bool, Optional[str]]:
        """
        Verify: emlCore(C) ⊆ minGenEq(C) ⊆ C for all closed C.

        Time: O(k * 2^n * T_cl)
        """
        for C in self.closed_sets():
            core = self.core(C)
            mg = self.minimal_generators_eq(C)
            if not (core <= mg <= C):
                return False, f"Failed for C={set(C)}: core={set(core)}, mg={set(mg)}"
        return True, None

    def print_summary(self):
        """Print a comprehensive summary of the closure system."""
        print(f"Universe: {set(self.universe)} (n={self.n})")
        print(f"Total subsets: {2**self.n}")

        closed = self.closed_sets()
        print(f"Closed sets: {len(closed)}")
        for C in closed:
            print(f"  {set(C)}")

        print()
        gc_ok, gc_msg = self.verify_galois_connection()
        print(f"Galois connection: {'✓' if gc_ok else '✗'} {gc_msg or ''}")

        mf_ok, mf_msg = self.verify_moore_family()
        print(f"Moore family: {'✓' if mf_ok else '✗'} {mf_msg or ''}")

        ch_ok, ch_msg = self.verify_core_hierarchy()
        print(f"Core hierarchy: {'✓' if ch_ok else '✗'} {ch_msg or ''}")

        print()
        print("Hasse diagram (covers):")
        hasse = self.hasse_diagram()
        for C, successors in sorted(hasse.items(), key=lambda x: len(x[0])):
            if successors:
                for S in successors:
                    print(f"  {set(C)} → {set(S)}")

        print()
        print("Core analysis:")
        for C in closed:
            core = self.core(C)
            mg = self.minimal_generators_eq(C)
            irred = self.irredundant_generators(C)
            print(f"  C={set(C)}:")
            print(f"    core = {set(core)}")
            print(f"    minGenEq = {set(mg)}")
            print(f"    irredundant generators: {[set(g) for g in irred]}")


# ============================================================================
# Algorithm: NextClosure (Ganter's Algorithm)
# ============================================================================

def next_closure(universe: List, closure_fn: Callable, current: FrozenSet) -> Optional[FrozenSet]:
    """
    Ganter's NextClosure algorithm: compute the lexicographically next closed set.

    Given a closed set 'current', finds the next closed set in lectical order.
    This is much more efficient than brute force for large universes.

    Time per call: O(n * T_cl)
    Total for all closed sets: O(k * n * T_cl) where k = number of closed sets

    Args:
        universe: sorted list of elements
        closure_fn: closure function
        current: current closed set

    Returns:
        Next closed set, or None if current is the last one
    """
    n = len(universe)
    for i in range(n - 1, -1, -1):
        elem = universe[i]
        if elem in current:
            continue
        # Try adding element i and closing
        candidate = frozenset({elem}) | frozenset(x for x in current if universe.index(x) < i)
        closed_candidate = closure_fn(candidate)
        # Check if the added elements all have index ≥ i
        valid = all(universe.index(x) >= i for x in closed_candidate - candidate)
        if valid:
            return closed_candidate
    return None


def enumerate_closed_sets_ganter(universe: List, closure_fn: Callable) -> List[FrozenSet]:
    """
    Enumerate all closed sets using Ganter's NextClosure algorithm.

    Time: O(k * n * T_cl)
    Space: O(k * n)
    """
    current = closure_fn(frozenset())
    result = [current]
    while True:
        nxt = next_closure(universe, closure_fn, current)
        if nxt is None:
            break
        result.append(nxt)
        current = nxt
    return result


# ============================================================================
# Pseudocode Documentation
# ============================================================================

PSEUDOCODE = """
Algorithm: VerifyGaloisConnection(cl, Universe)
================================================
Input: Closure operator cl on finite Universe
Output: True if cl(A) ⊆ C ↔ A ⊆ C for all A and closed C

1. Compute ClosedSets = {S ⊆ Universe | cl(S) = S}
2. For each A ⊆ Universe:
   a. Compute cl(A)
   b. For each C ∈ ClosedSets:
      i.  If cl(A) ⊆ C and A ⊄ C: return False
      ii. If A ⊆ C and cl(A) ⊄ C: return False
3. Return True

Complexity: O(2^n · k · T_cl) time, O(2^n) space


Algorithm: ComputeCore(C, cl, Universe)
=======================================
Input: Set C, closure operator cl, finite Universe
Output: emlCore(C) = ⋂{A | C ⊆ cl(A)}

1. Initialize result = Universe
2. For each A ⊆ Universe:
   a. If C ⊆ cl(A):
      b. result = result ∩ A
3. Return result

Complexity: O(2^n · T_cl) time, O(n) space


Algorithm: NextClosure(current, Universe, cl) [Ganter 1984]
===========================================================
Input: Current closed set, sorted Universe, closure cl
Output: Lexicographically next closed set, or None

1. For i = n-1 down to 0:
   a. Let elem = Universe[i]
   b. If elem ∈ current: continue
   c. candidate = {elem} ∪ {x ∈ current | index(x) < i}
   d. closed = cl(candidate)
   e. If all new elements have index ≥ i: return closed
2. Return None

Complexity: O(n · T_cl) per call
"""


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("EML Closure System Algorithms")
    print("=" * 60)
    print()

    # Example: Boolean closure with implication
    universe = frozenset({1, 2, 3, 4})

    def closure(S: FrozenSet) -> FrozenSet:
        """Closure with rules: 1→2, 3→4, {2,4}→{1,2,3,4}."""
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 1 in result and 2 not in result:
                result.add(2); changed = True
            if 3 in result and 4 not in result:
                result.add(4); changed = True
            if 2 in result and 4 in result:
                result.update({1, 3}); changed = True
        return frozenset(result)

    cs = FiniteClosureOperator(universe, closure)
    cs.print_summary()

    print()
    print("-" * 60)
    print("Ganter's NextClosure Algorithm")
    print("-" * 60)
    sorted_universe = sorted(universe)
    ganter_closed = enumerate_closed_sets_ganter(sorted_universe, closure)
    print(f"Closed sets found by NextClosure: {len(ganter_closed)}")
    for C in ganter_closed:
        print(f"  {set(C)}")

    brute_closed = cs.closed_sets()
    print(f"Matches brute force: {set(map(frozenset, ganter_closed)) == set(brute_closed)}")

    print()
    print("-" * 60)
    print(PSEUDOCODE)
