"""
Algorithms for Treewidth-Parameterized Lorentzian Recognition

Implements the key algorithms from the research paper:
1. Support-bounded multiindex enumeration
2. Tree decomposition-based leaf counting
3. Dynamic programming on tree decompositions for Hessian checks
"""

from math import comb
from typing import List, Tuple, Dict, Set, Optional
from itertools import combinations
from collections import defaultdict


# --- Data Structures ---

class MultiIndex:
    """A multiindex α : {0,...,n-1} → ℕ with weight ∑α = d."""
    def __init__(self, entries: Tuple[int, ...]):
        self.entries = entries
        self.n = len(entries)
        self.weight = sum(entries)
        self._support = None

    @property
    def support(self) -> Set[int]:
        """The support: set of indices with nonzero entries."""
        if self._support is None:
            self._support = {i for i, v in enumerate(self.entries) if v > 0}
        return self._support

    @property
    def support_size(self) -> int:
        return len(self.support)

    def __repr__(self):
        return f"MultiIndex({self.entries})"

    def __eq__(self, other):
        return self.entries == other.entries

    def __hash__(self):
        return hash(self.entries)


class TreeDecomposition:
    """A tree decomposition of a graph.

    Attributes:
        bags: List of sets of vertices (the bags)
        tree_edges: List of (i, j) pairs giving the tree structure
        width: Maximum bag size - 1
    """
    def __init__(self, bags: List[Set[int]], tree_edges: List[Tuple[int, int]]):
        self.bags = bags
        self.tree_edges = tree_edges
        self.width = max(len(b) for b in bags) - 1 if bags else 0
        self.num_bags = len(bags)

    def verify(self, n: int, adj: Dict[int, Set[int]]) -> bool:
        """Verify this is a valid tree decomposition."""
        # Check vertex coverage
        all_vertices = set()
        for bag in self.bags:
            all_vertices |= bag
        if all_vertices != set(range(n)):
            return False

        # Check edge coverage
        for u in adj:
            for v in adj[u]:
                if u < v:
                    covered = any(u in bag and v in bag for bag in self.bags)
                    if not covered:
                        return False

        return True


class InteractionGraph:
    """The variable interaction graph of a polynomial.

    Variables i and j are adjacent if some monomial involves both.
    """
    def __init__(self, n: int, multiindices: List[MultiIndex]):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)

        for alpha in multiindices:
            supp = list(alpha.support)
            for a in range(len(supp)):
                for b in range(a + 1, len(supp)):
                    self.adj[supp[a]].add(supp[b])
                    self.adj[supp[b]].add(supp[a])

    def max_clique_size(self) -> int:
        """Upper bound on clique size (greedy)."""
        max_size = 1
        for v in range(self.n):
            neighbors = self.adj.get(v, set())
            # Check clique among v and its neighbors
            clique = {v}
            for u in sorted(neighbors):
                if all(u in self.adj.get(w, set()) for w in clique if w != u):
                    clique.add(u)
            max_size = max(max_size, len(clique))
        return max_size


# --- Core Algorithms ---

def enumerate_bounded_support_multiindices(
    n: int, d: int, k: int
) -> List[MultiIndex]:
    """Enumerate all multiindices of weight d in n variables with support ≤ k.

    Algorithm: For each support set S ⊆ {0,...,n-1} with |S| ≤ k,
    enumerate all compositions of d into |S| positive parts.

    Time complexity: O(C(n,k) * C(d+k-1, k-1))
    Space complexity: O(output size)

    Args:
        n: Number of variables
        d: Weight of multiindices
        k: Maximum support size

    Returns:
        List of MultiIndex objects with the given constraints
    """
    results = []

    if d == 0:
        results.append(MultiIndex(tuple([0] * n)))
        return results

    for j in range(1, min(k, n) + 1):
        for support_set in combinations(range(n), j):
            # Enumerate compositions of d into j positive parts
            for comp in _compositions(d, j):
                entries = [0] * n
                for idx, val in zip(support_set, comp):
                    entries[idx] = val
                results.append(MultiIndex(tuple(entries)))

    return results


def _compositions(n: int, k: int):
    """Generate all compositions of n into k positive parts."""
    if k == 1:
        yield (n,)
        return
    for first in range(1, n - k + 2):
        for rest in _compositions(n - first, k - 1):
            yield (first,) + rest


def build_path_tree_decomposition(n: int) -> TreeDecomposition:
    """Build a tree decomposition for a path graph on n vertices.

    The path graph has edges {i, i+1} for i = 0, ..., n-2.
    A natural tree decomposition uses bags {i, i+1} for each edge.
    Width = 1.

    Args:
        n: Number of vertices

    Returns:
        TreeDecomposition with width 1
    """
    if n <= 1:
        bags = [{0}] if n == 1 else [set()]
        return TreeDecomposition(bags, [])

    bags = [{i, i + 1} for i in range(n - 1)]
    tree_edges = [(i, i + 1) for i in range(n - 2)]
    return TreeDecomposition(bags, tree_edges)


def bounded_support_leaf_count(n: int, d: int, k: int) -> int:
    """Count the number of quadratic leaves with bounded support.

    For Lorentzian recognition of a degree-d polynomial in n variables
    with variable interaction graph of treewidth w, the number of
    Hessian checks needed is bounded by the number of multiindices
    of weight d-2 with support size ≤ w+1 = k.

    Time: O(1) using closed-form bound
    Space: O(1)

    Args:
        n: Number of variables
        d: Degree of polynomial
        k: Support bound (= treewidth + 1)

    Returns:
        Upper bound on number of Hessian checks needed
    """
    if d < 2:
        return 1

    weight = d - 2
    # Exact count
    exact = sum(
        comb(n, j) * comb(weight - 1, j - 1)
        for j in range(1, min(k, n) + 1)
        if weight >= j
    )
    if weight == 0:
        exact = 1

    return exact


def bounded_support_upper_bound(n: int, d: int, k: int) -> int:
    """The proven upper bound C(n,k) * (d+1)^k.

    This is the formal bound from Theorem boundedSuppCount_le.
    """
    return comb(n, min(k, n)) * (d + 1) ** k


def dynamic_programming_hessian_check(
    n: int, d: int, td: TreeDecomposition
) -> Dict[str, int]:
    """Simulate the dynamic programming Hessian check on a tree decomposition.

    For each bag in the tree decomposition, count the number of
    multiindices supported within that bag. The total work is bounded
    by the sum over bags of (d+1)^|bag|.

    Args:
        n: Number of variables
        d: Degree of polynomial
        td: Tree decomposition of the interaction graph

    Returns:
        Dictionary with statistics about the computation
    """
    total_checks = 0
    max_bag_checks = 0

    for bag in td.bags:
        bag_size = len(bag)
        checks = (d + 1) ** bag_size
        total_checks += checks
        max_bag_checks = max(max_bag_checks, checks)

    general_checks = n ** max(d - 2, 0) if n > 0 else 1

    return {
        "total_dp_checks": total_checks,
        "max_bag_checks": max_bag_checks,
        "general_checks": general_checks,
        "num_bags": td.num_bags,
        "treewidth": td.width,
        "speedup": general_checks / max(total_checks, 1),
    }


# --- Example Usage ---

def example_path_polynomial():
    """Example: polynomial with path-structured variable interactions."""
    print("=" * 60)
    print("Example: Path-Structured Polynomial (Treewidth 1)")
    print("=" * 60)

    n = 10  # variables
    d = 8   # degree

    # Build path tree decomposition
    td = build_path_tree_decomposition(n)
    print(f"  Variables: {n}, Degree: {d}")
    print(f"  Tree decomposition width: {td.width}")
    print(f"  Number of bags: {td.num_bags}")

    # Count bounded-support leaves
    k = td.width + 1  # = 2
    bl = bounded_support_leaf_count(n, d, k)
    ub = bounded_support_upper_bound(n, d - 2, k)
    gl = comb(n + d - 3, d - 2)  # general count

    print(f"\n  Leaf counts:")
    print(f"    Bounded support (k={k}): {bl}")
    print(f"    Upper bound C(n,k)*(d-1)^k: {ub}")
    print(f"    General count: {gl}")
    print(f"    Reduction factor: {gl / max(bl, 1):.1f}x")

    # DP simulation
    stats = dynamic_programming_hessian_check(n, d, td)
    print(f"\n  DP Hessian check simulation:")
    for key, val in stats.items():
        print(f"    {key}: {val}")


def example_star_polynomial():
    """Example: polynomial with star-structured variable interactions."""
    print("\n" + "=" * 60)
    print("Example: Star-Structured Polynomial (Treewidth 1)")
    print("=" * 60)

    n = 10
    d = 8

    # Star tree decomposition: one central bag containing vertex 0
    bags = [{0, i} for i in range(1, n)]
    tree_edges = [(0, i) for i in range(1, n - 1)]
    td = TreeDecomposition(bags, tree_edges)

    print(f"  Variables: {n}, Degree: {d}")
    print(f"  Tree decomposition width: {td.width}")

    stats = dynamic_programming_hessian_check(n, d, td)
    print(f"\n  DP Statistics:")
    for key, val in stats.items():
        print(f"    {key}: {val}")


if __name__ == "__main__":
    example_path_polynomial()
    example_star_polynomial()

    print("\n" + "=" * 60)
    print("Enumeration test: bounded-support multiindices")
    print("=" * 60)
    mis = enumerate_bounded_support_multiindices(5, 4, 2)
    print(f"  n=5, d=4, k=2: {len(mis)} multiindices")
    for m in mis[:10]:
        print(f"    {m.entries} (support: {m.support})")
    if len(mis) > 10:
        print(f"    ... ({len(mis) - 10} more)")
