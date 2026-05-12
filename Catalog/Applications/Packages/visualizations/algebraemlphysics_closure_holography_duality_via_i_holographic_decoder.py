"""
Algorithms for Finite Closure Holography Duality.

Implements the holographic decoder, membership test, capacity computation,
and related algorithms for finite closure systems.
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set, Optional


# Type alias for clarity
Element = int
Subset = frozenset


class ClosureSystem:
    """A finite closure system on elements {0, 1, ..., n-1}.

    The closure operator is specified as a callable that maps frozensets to frozensets.
    """

    def __init__(self, n: int, cl: Callable[[Subset], Subset]):
        """
        Args:
            n: Number of elements (universe is {0, ..., n-1})
            cl: Closure operator mapping frozensets to frozensets
        """
        self.n = n
        self.universe = frozenset(range(n))
        self._cl = cl
        self._validate()

    def _validate(self):
        """Validate closure axioms on small test cases."""
        empty = frozenset()
        univ = self.universe
        # Check extensivity on empty and universe
        assert empty <= self.cl(empty), "Extensivity fails on empty set"
        assert univ <= self.cl(univ), "Extensivity fails on universe"
        # Check idempotence on universe
        assert self.cl(self.cl(univ)) == self.cl(univ), "Idempotence fails on universe"

    def cl(self, X: Subset) -> Subset:
        """Compute the closure of X."""
        return self._cl(X)

    def capacity(self, X: Subset) -> int:
        """Compute the closure capacity: |cl(X)|."""
        return len(self.cl(X))

    def is_closed(self, X: Subset) -> bool:
        """Check if X is a closed set (fixpoint of cl)."""
        return self.cl(X) == X

    def membership_test(self, X: Subset, x: int) -> bool:
        """Holographic membership test: x ∈ cl(X) iff cap(X) = cap(X ∪ {x}).

        This is the key boundary observable that detects bulk membership
        without computing the closure explicitly.
        """
        return self.capacity(X) == self.capacity(X | frozenset([x]))

    def all_closed_sets(self) -> list[Subset]:
        """Enumerate all closed sets of the closure system."""
        closed = []
        for r in range(self.n + 1):
            for subset in combinations(range(self.n), r):
                s = frozenset(subset)
                if self.is_closed(s):
                    closed.append(s)
        # Also check full closure of universe
        cl_univ = self.cl(self.universe)
        if cl_univ not in closed:
            closed.append(cl_univ)
        return sorted(closed, key=lambda s: (len(s), sorted(s)))

    def capacity_profile(self) -> dict[Subset, int]:
        """Compute the full capacity profile: X ↦ cap(X) for all X ⊆ B."""
        profile = {}
        for r in range(self.n + 1):
            for subset in combinations(range(self.n), r):
                s = frozenset(subset)
                profile[s] = self.capacity(s)
        return profile

    def is_cardinality_separated(self) -> bool:
        """Check if distinct closed sets have distinct cardinalities."""
        closed = self.all_closed_sets()
        cards = [len(s) for s in closed]
        return len(cards) == len(set(cards))

    def holographic_decode_exact(self) -> Subset:
        """Exact holographic decoder: find minimum-cardinality generating set.

        Returns G ⊆ B of minimum cardinality such that cl(G) = cl(B).

        Complexity: O(2^n * T_cl) where T_cl is the closure computation time.
        """
        target = self.cl(self.universe)
        best = self.universe
        for r in range(self.n + 1):
            for subset in combinations(range(self.n), r):
                G = frozenset(subset)
                if self.cl(G) == target:
                    if len(G) < len(best):
                        best = G
                    if len(G) == r:
                        # Found one of this size, can't do better at this r
                        return best
        return best

    def holographic_decode_greedy(self) -> Subset:
        """Greedy holographic decoder: polynomial-time approximation.

        Removes elements one at a time, keeping those whose removal
        would change the closure.

        Complexity: O(n * T_cl). Produces a minimal (not minimum) generating set.
        """
        target = self.cl(self.universe)
        G = set(self.universe)
        for x in sorted(self.universe):
            candidate = frozenset(G - {x})
            if self.cl(candidate) == target:
                G = G - {x}
        return frozenset(G)

    def entanglement_rank(self, X: Subset) -> int:
        """Compute the entanglement rank: min |G| such that cl(G) = cl(X)."""
        target = self.cl(X)
        for r in range(len(X) + 1):
            for subset in combinations(range(self.n), r):
                G = frozenset(subset)
                if self.cl(G) == target:
                    return r
        return len(X)  # Fallback (should not reach here)

    def verify_holographic_duality(self, other: 'ClosureSystem') -> bool:
        """Verify that this system and another have the same capacity profile,
        and if so, check that they have the same closure function."""
        if self.n != other.n:
            return False
        for r in range(self.n + 1):
            for subset in combinations(range(self.n), r):
                s = frozenset(subset)
                if self.capacity(s) != other.capacity(s):
                    return False  # Different profiles
        # Same profile — verify same closure (should hold by theorem)
        for r in range(self.n + 1):
            for subset in combinations(range(self.n), r):
                s = frozenset(subset)
                if self.cl(s) != other.cl(s):
                    raise AssertionError("Holographic duality violated!")
        return True


# --- Factory functions for common closure systems ---

def identity_closure(n: int) -> ClosureSystem:
    """The discrete/identity closure system: cl(X) = X for all X."""
    return ClosureSystem(n, lambda X: X)


def topological_closure(n: int, topology: list[Subset]) -> ClosureSystem:
    """Closure system from a topology (family of closed sets).

    cl(X) = intersection of all closed sets containing X.
    """
    def cl(X: Subset) -> Subset:
        result = frozenset(range(n))
        for closed_set in topology:
            if X <= closed_set:
                result = result & closed_set
        return result
    return ClosureSystem(n, cl)


def transitive_closure(n: int, edges: list[tuple[int, int]]) -> ClosureSystem:
    """Closure system from directed graph reachability.

    cl(X) = set of all vertices reachable from X via directed edges.
    """
    adj = {i: set() for i in range(n)}
    for u, v in edges:
        adj[u].add(v)

    def cl(X: Subset) -> Subset:
        reached = set(X)
        frontier = list(X)
        while frontier:
            u = frontier.pop()
            for v in adj.get(u, []):
                if v not in reached:
                    reached.add(v)
                    frontier.append(v)
        return frozenset(reached)

    return ClosureSystem(n, cl)


def matroid_closure(n: int, rank: int) -> ClosureSystem:
    """Uniform matroid U(rank, n) closure system.

    cl(X) = X if |X| < rank, else {0, ..., n-1}.
    """
    def cl(X: Subset) -> Subset:
        if len(X) >= rank:
            return frozenset(range(n))
        return X
    return ClosureSystem(n, cl)


def linear_closure(n: int, dependencies: list[tuple[Subset, int]]) -> ClosureSystem:
    """Closure system from linear dependencies.

    Each dependency (S, x) means: if S ⊆ X, then x ∈ cl(X).
    """
    def cl(X: Subset) -> Subset:
        result = set(X)
        changed = True
        while changed:
            changed = False
            for prereqs, consequent in dependencies:
                if prereqs <= result and consequent not in result:
                    result.add(consequent)
                    changed = True
        return frozenset(result)
    return ClosureSystem(n, cl)


if __name__ == "__main__":
    # Example: transitive closure on 5 vertices
    print("=== Transitive Closure System ===")
    C = transitive_closure(5, [(0, 1), (1, 2), (2, 3), (3, 4)])
    print(f"Universe: {set(C.universe)}")
    print(f"cl({{0}}) = {set(C.cl(frozenset([0])))}")
    print(f"cl({{2}}) = {set(C.cl(frozenset([2])))}")
    print(f"cap({{0}}) = {C.capacity(frozenset([0]))}")
    print(f"Minimum generator: {set(C.holographic_decode_exact())}")
    print(f"Greedy generator: {set(C.holographic_decode_greedy())}")
    print(f"Cardinality separated: {C.is_cardinality_separated()}")
    print()

    # Example: uniform matroid
    print("=== Uniform Matroid U(3, 5) ===")
    M = matroid_closure(5, 3)
    print(f"cl({{0, 1}}) = {set(M.cl(frozenset([0, 1])))}")
    print(f"cl({{0, 1, 2}}) = {set(M.cl(frozenset([0, 1, 2])))}")
    print(f"Minimum generator: {set(M.holographic_decode_exact())}")
    print(f"Entanglement rank of {{0,1,2,3}}: {M.entanglement_rank(frozenset([0,1,2,3]))}")
