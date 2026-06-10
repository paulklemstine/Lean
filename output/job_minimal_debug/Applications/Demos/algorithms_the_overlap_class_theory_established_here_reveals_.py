#!/usr/bin/env python3
"""
Algorithms for Overlap Spectrum Theory

Implements efficient algorithms for computing overlap equivalence classes,
the overlap spectrum, the overlap Laplacian, and related invariants.

All algorithms have documented time and space complexity.
"""

from collections import defaultdict
from typing import TypeVar, Optional
import heapq

T = TypeVar('T')


class UnionFind:
    """
    Disjoint-set data structure with path compression and union by rank.
    
    Time complexity: O(α(n)) amortized per operation, where α is the 
    inverse Ackermann function (effectively constant).
    Space complexity: O(n)
    """
    
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n
        self.num_components = n
    
    def find(self, x: int) -> int:
        """Find root with path compression. Amortized O(α(n))."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if merge happened. Amortized O(α(n))."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        self.size[px] += self.size[py]
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.num_components -= 1
        return True
    
    def get_components(self) -> list[list[int]]:
        """Return all components. O(n)."""
        groups = defaultdict(list)
        for i in range(len(self.parent)):
            groups[self.find(i)].append(i)
        return list(groups.values())
    
    def component_sizes(self) -> list[int]:
        """Return sorted list of component sizes (the overlap spectrum). O(n)."""
        sizes = defaultdict(int)
        for i in range(len(self.parent)):
            sizes[self.find(i)] += 1
        return sorted(sizes.values(), reverse=True)


def compute_overlap_classes(family: list[set]) -> list[list[int]]:
    """
    Compute overlap equivalence classes using union-find.
    
    Algorithm:
    1. Initialize union-find with n elements
    2. For each pair (i,j) with i < j, check if F[i] ∩ F[j] ≠ ∅
    3. If so, union(i, j)
    4. Return connected components
    
    Time complexity: O(n² × max|F[i]|) for intersection checks + O(n × α(n)) for UF
    Space complexity: O(n + Σ|F[i]|)
    
    Args:
        family: List of sets (the support family)
    Returns:
        List of overlap classes (each class is a list of indices)
    """
    n = len(family)
    uf = UnionFind(n)
    
    # Optimization: build element-to-sets index for faster overlap detection
    element_index: dict = defaultdict(list)
    for i, s in enumerate(family):
        for elem in s:
            element_index[elem].append(i)
    
    # Union all pairs sharing an element
    for elem, indices in element_index.items():
        for k in range(1, len(indices)):
            uf.union(indices[0], indices[k])
    
    return uf.get_components()


def compute_overlap_spectrum(family: list[set]) -> list[int]:
    """
    Compute the overlap spectrum: the integer partition of n given by class sizes.
    
    Time complexity: O(n² × max|F[i]|) or O(n × max|F[i]| × α(n)) with index
    Space complexity: O(n + Σ|F[i]|)
    
    Args:
        family: List of sets
    Returns:
        Sorted list of class sizes (descending), forming an integer partition of n
    """
    n = len(family)
    if n == 0:
        return []
    
    uf = UnionFind(n)
    element_index: dict = defaultdict(list)
    for i, s in enumerate(family):
        for elem in s:
            element_index[elem].append(i)
    
    for elem, indices in element_index.items():
        for k in range(1, len(indices)):
            uf.union(indices[0], indices[k])
    
    return uf.component_sizes()


def compute_overlap_degree(family: list[set]) -> int:
    """
    Count the number of overlapping pairs.
    
    Time complexity: O(n × max|F[i]| + E) where E = number of edges
    Space complexity: O(n + Σ|F[i]|)
    """
    n = len(family)
    edges = set()
    element_index: dict = defaultdict(list)
    for i, s in enumerate(family):
        for elem in s:
            element_index[elem].append(i)
    
    for elem, indices in element_index.items():
        for a in range(len(indices)):
            for b in range(a + 1, len(indices)):
                i, j = min(indices[a], indices[b]), max(indices[a], indices[b])
                edges.add((i, j))
    
    return len(edges)


def compute_overlap_complexity(family: list[set]) -> int:
    """
    Compute the overlap complexity: sum of |F[i] ∩ F[j]| over all i < j.
    
    Time complexity: O(n² × max|F[i]|)
    Space complexity: O(max|F[i]|)
    """
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(family[i] & family[j])
    return total


def compute_vertex_degrees(family: list[set]) -> list[int]:
    """
    Compute vertex degrees in the overlap graph.
    
    Time complexity: O(n × max|F[i]|)
    Space complexity: O(n + Σ|F[i]|)
    """
    n = len(family)
    neighbors: list[set[int]] = [set() for _ in range(n)]
    element_index: dict = defaultdict(list)
    
    for i, s in enumerate(family):
        for elem in s:
            element_index[elem].append(i)
    
    for elem, indices in element_index.items():
        for a in range(len(indices)):
            for b in range(a + 1, len(indices)):
                neighbors[indices[a]].add(indices[b])
                neighbors[indices[b]].add(indices[a])
    
    return [len(nb) for nb in neighbors]


def compute_overlap_laplacian(family: list[set]) -> list[list[int]]:
    """
    Compute the overlap Laplacian matrix L where:
    - L[i][i] = degree of vertex i
    - L[i][j] = -1 if i ≠ j and F[i] ∩ F[j] ≠ ∅
    - L[i][j] = 0 otherwise
    
    Time complexity: O(n² + n × max|F[i]|)
    Space complexity: O(n²)
    
    Verified property: Row sums are zero (laplacian_row_sum_zero).
    Verified property: Trace = 2 × overlap_degree (handshaking lemma).
    """
    n = len(family)
    L = [[0] * n for _ in range(n)]
    
    # Build adjacency
    element_index: dict = defaultdict(list)
    for i, s in enumerate(family):
        for elem in s:
            element_index[elem].append(i)
    
    adj: list[set[int]] = [set() for _ in range(n)]
    for elem, indices in element_index.items():
        for a in range(len(indices)):
            for b in range(a + 1, len(indices)):
                adj[indices[a]].add(indices[b])
                adj[indices[b]].add(indices[a])
    
    for i in range(n):
        L[i][i] = len(adj[i])
        for j in adj[i]:
            L[i][j] = -1
    
    return L


def verify_handshaking(family: list[set]) -> bool:
    """Verify the handshaking lemma: sum of vertex degrees = 2 × edge count."""
    degs = compute_vertex_degrees(family)
    edges = compute_overlap_degree(family)
    return sum(degs) == 2 * edges


def verify_laplacian_row_sums(family: list[set]) -> bool:
    """Verify all Laplacian row sums are zero."""
    L = compute_overlap_laplacian(family)
    return all(sum(row) == 0 for row in L)


def max_pairwise_intersection(family: list[set]) -> int:
    """Compute the maximum pairwise intersection size."""
    n = len(family)
    if n <= 1:
        return 0
    return max(len(family[i] & family[j])
               for i in range(n) for j in range(i + 1, n))


def test_degree_one_conjecture(family: list[set]) -> Optional[bool]:
    """
    Test the overlap degree one conjecture for a given family.
    
    Conjecture: When maxPairwiseIntersection ≤ 1,
    classCount + ovDegree = n.
    
    Returns None if precondition not met, True if holds, False if refuted.
    """
    if max_pairwise_intersection(family) > 1:
        return None
    n = len(family)
    cc = len(compute_overlap_classes(family))
    od = compute_overlap_degree(family)
    return cc + od == n


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Overlap Spectrum Theory — Algorithm Demonstrations\n")
    
    # Example 1: Mixed family
    family = [{1, 2, 3}, {3, 4, 5}, {6, 7}, {7, 8, 9}, {10}]
    
    print(f"Family: {family}")
    print(f"Overlap classes: {compute_overlap_classes(family)}")
    print(f"Overlap spectrum: {compute_overlap_spectrum(family)}")
    print(f"Overlap degree: {compute_overlap_degree(family)}")
    print(f"Overlap complexity: {compute_overlap_complexity(family)}")
    print(f"Vertex degrees: {compute_vertex_degrees(family)}")
    print(f"Handshaking verified: {verify_handshaking(family)}")
    print(f"Laplacian row sums zero: {verify_laplacian_row_sums(family)}")
    
    print("\nLaplacian matrix:")
    L = compute_overlap_laplacian(family)
    for row in L:
        print(f"  {row}")
    
    print(f"\nDegree one conjecture test: {test_degree_one_conjecture(family)}")
    
    # Example 2: Stress test handshaking
    import random
    random.seed(42)
    print("\nStress testing handshaking lemma on 1000 random families...")
    all_pass = True
    for trial in range(1000):
        n = random.randint(1, 8)
        fam = [set(random.sample(range(20), random.randint(1, 6))) for _ in range(n)]
        if not verify_handshaking(fam):
            print(f"  FAILED on trial {trial}: {fam}")
            all_pass = False
            break
    print(f"  All 1000 tests passed!" if all_pass else "  Some tests failed!")
    
    # Example 3: Conjecture mass test
    print("\nMass testing degree-one conjecture...")
    tested = 0
    passed = 0
    failed = 0
    for trial in range(5000):
        n = random.randint(2, 7)
        fam = [set(random.sample(range(15), random.randint(1, 4))) for _ in range(n)]
        result = test_degree_one_conjecture(fam)
        if result is not None:
            tested += 1
            if result:
                passed += 1
            else:
                failed += 1
                if failed <= 3:
                    print(f"  Counterexample: {fam}")
    
    print(f"  Tested {tested} families with max intersection ≤ 1")
    print(f"  Passed: {passed}, Failed: {failed}")
    if failed > 0:
        print("  CONJECTURE REFUTED!")
    else:
        print("  Conjecture holds for all tested cases.")
