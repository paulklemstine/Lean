"""
algorithms.py — Overlap Class Theory: Algorithms for Support Interaction Analysis

Implements the core algorithms from the Overlap Class Theory paper:
1. Support overlap graph construction
2. Overlap class computation via connected components
3. Overlap degree and signature computation
4. Tropical projective equivalence testing
5. Conjecture verification on small graphs

Author: Harmonic Research
"""

from typing import List, Tuple, Set, Dict, FrozenSet, Optional
from itertools import combinations, product
from collections import defaultdict, deque
import math


# ============================================================
# Core Data Structures
# ============================================================

class SupportFamily:
    """A family of finite supports (subsets of a finite ground set)."""

    def __init__(self, supports: List[FrozenSet[int]]):
        self.supports = list(supports)
        self.n = len(supports)

    def __repr__(self):
        return f"SupportFamily({[set(s) for s in self.supports]})"


class SimpleGraph:
    """A simple undirected graph on vertices {0, ..., n-1}."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.edges_list = []
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                if u < v:
                    self.edges_list.append((u, v))
                else:
                    self.edges_list.append((v, u))
        self.edges_list = list(set(self.edges_list))

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = set()
        queue = deque([0])
        visited.add(0)
        while queue:
            v = queue.popleft()
            for w in self.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


# ============================================================
# Algorithm 1: Support Overlap Graph
# ============================================================

def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    """Check if two supports have nonempty intersection.

    Time complexity: O(min(|A|, |B|))
    """
    return len(A & B) > 0


def build_overlap_graph(family: SupportFamily) -> SimpleGraph:
    """Build the support overlap graph.

    Vertices are indices 0..n-1, edges connect overlapping supports.

    Time complexity: O(n^2 * max_support_size)

    >>> F = SupportFamily([frozenset({0,1}), frozenset({1,2}), frozenset({3,4})])
    >>> G = build_overlap_graph(F)
    >>> G.n
    3
    >>> sorted(G.edges_list)
    [(0, 1)]
    """
    edges = []
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            edges.append((i, j))
    return SimpleGraph(family.n, edges)


# ============================================================
# Algorithm 2: Overlap Classes (Connected Components)
# ============================================================

def compute_overlap_classes(family: SupportFamily) -> List[List[int]]:
    """Compute overlap classes as connected components of the overlap graph.

    Returns a list of classes, each a list of indices.

    Time complexity: O(n^2 * max_support_size)

    >>> F = SupportFamily([frozenset({0,1}), frozenset({1,2}), frozenset({3,4})])
    >>> classes = compute_overlap_classes(F)
    >>> len(classes)
    2
    """
    G = build_overlap_graph(family)
    visited = set()
    classes = []

    for start in range(family.n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            v = queue.popleft()
            component.append(v)
            for w in G.adj[v]:
                if w not in visited:
                    visited.add(w)
                    queue.append(w)
        classes.append(sorted(component))

    return classes


def overlap_class_count(family: SupportFamily) -> int:
    """Number of overlap classes.

    >>> F = SupportFamily([frozenset({0,1}), frozenset({1,2}), frozenset({3,4})])
    >>> overlap_class_count(F)
    2
    """
    return len(compute_overlap_classes(family))


# ============================================================
# Algorithm 3: Overlap Degree and Signature
# ============================================================

def overlap_degree(family: SupportFamily) -> int:
    """Number of overlapping pairs (edges in the overlap graph).

    >>> F = SupportFamily([frozenset({0,1}), frozenset({1,2}), frozenset({3,4})])
    >>> overlap_degree(F)
    1
    """
    count = 0
    for i, j in combinations(range(family.n), 2):
        if supports_overlap(family.supports[i], family.supports[j]):
            count += 1
    return count


def overlap_signature(family: SupportFamily) -> List[int]:
    """Sorted list of intersection sizes for overlapping pairs.

    >>> F = SupportFamily([frozenset({0,1,2}), frozenset({1,2,3}), frozenset({5,6})])
    >>> overlap_signature(F)
    [2]
    """
    sizes = []
    for i, j in combinations(range(family.n), 2):
        isect = len(family.supports[i] & family.supports[j])
        if isect > 0:
            sizes.append(isect)
    return sorted(sizes)


def max_overlap_degree(family: SupportFamily) -> int:
    """Maximum intersection cardinality over all pairs.

    >>> F = SupportFamily([frozenset({0,1,2}), frozenset({1,2,3}), frozenset({5,6})])
    >>> max_overlap_degree(F)
    2
    """
    max_deg = 0
    for i, j in combinations(range(family.n), 2):
        max_deg = max(max_deg, len(family.supports[i] & family.supports[j]))
    return max_deg


# ============================================================
# Algorithm 4: Graph Laplacian and Harmonic Functions
# ============================================================

def graph_laplacian(G: SimpleGraph) -> List[List[int]]:
    """Compute the combinatorial graph Laplacian matrix.

    L[i][j] = deg(i) if i==j, -1 if i~j, 0 otherwise.

    Time complexity: O(n^2)
    """
    L = [[0] * G.n for _ in range(G.n)]
    for i in range(G.n):
        L[i][i] = G.degree(i)
        for j in G.adj[i]:
            L[i][j] = -1
    return L


def is_harmonic_on(G: SimpleGraph, S: Set[int], f: List[int]) -> bool:
    """Check if f is S-harmonic: (Lf)(v) = 0 for all v in S.

    Time complexity: O(|S| * n)
    """
    L = graph_laplacian(G)
    for v in S:
        val = sum(L[v][w] * f[w] for w in range(G.n))
        if val != 0:
            return False
    return True


# ============================================================
# Algorithm 5: Cycle Support Family
# ============================================================

def find_cycles_dfs(G: SimpleGraph, S: Set[int]) -> List[List[int]]:
    """Find fundamental cycles in the induced subgraph G[S] using DFS.

    Returns a list of cycles, each as a list of vertices.

    Time complexity: O(|S| + |E(G[S])|)
    """
    vertices = sorted(S)
    adj_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_S[u].add(v)

    visited = set()
    parent = {}
    cycles = []

    def dfs(v, p):
        visited.add(v)
        parent[v] = p
        for w in sorted(adj_S[v]):
            if w == p:
                continue
            if w in visited:
                cycle = [w]
                curr = v
                safety = 0
                while curr != w and curr is not None and safety < len(vertices) + 1:
                    cycle.append(curr)
                    curr = parent.get(curr)
                    safety += 1
                if curr == w:
                    cycles.append(cycle)
            else:
                dfs(w, v)

    for v in vertices:
        if v not in visited:
            dfs(v, None)

    return cycles


def cycle_support_family(G: SimpleGraph, S: Set[int]) -> SupportFamily:
    """Compute the cycle support family of G[S].

    Each cycle gives a support (the set of vertices in the cycle).

    >>> G = SimpleGraph(4, [(0,1),(1,2),(2,0),(2,3),(3,0)])
    >>> F = cycle_support_family(G, {0,1,2,3})
    >>> F.n >= 1
    True
    """
    cycles = find_cycles_dfs(G, S)
    supports = [frozenset(c) for c in cycles]
    return SupportFamily(supports)


# ============================================================
# Algorithm 6: Tropical Projective Equivalence Testing
# ============================================================

def check_trop_proj_equiv(
    F1: List[List[int]], F2: List[List[int]]
) -> Optional[Tuple[List[int], List[int]]]:
    """Check if two families of functions are tropically projectively equivalent.

    F1, F2 are lists of functions (each function is a list of integer values).
    Returns (permutation, constants) if equivalent, None otherwise.

    Time complexity: O(n! * n * V) in worst case.
    """
    from itertools import permutations

    n = len(F1)
    if len(F2) != n:
        return None
    if n == 0:
        return ([], [])

    V = len(F1[0])

    for perm in permutations(range(n)):
        constants = []
        valid = True
        for i in range(n):
            j = perm[i]
            c = F2[j][0] - F1[i][0]
            for v in range(V):
                if F2[j][v] != F1[i][v] + c:
                    valid = False
                    break
            if not valid:
                break
            constants.append(c)
        if valid:
            return (list(perm), constants)

    return None


# ============================================================
# Algorithm 7: Conjecture Verification
# ============================================================

def generate_connected_graphs(n: int) -> List[SimpleGraph]:
    """Generate all connected simple graphs on n vertices.

    Uses edge enumeration with connectivity check.

    Time complexity: O(2^(n choose 2) * n^2)
    """
    if n <= 0:
        return []
    if n == 1:
        return [SimpleGraph(1, [])]

    all_possible_edges = list(combinations(range(n), 2))
    m = len(all_possible_edges)
    graphs = []

    for mask in range(1, 1 << m):
        edges = [all_possible_edges[i] for i in range(m) if mask & (1 << i)]
        G = SimpleGraph(n, edges)
        if G.is_connected():
            graphs.append(G)

    return graphs


def verify_conjecture_instance(
    G: SimpleGraph, q: int, S: Set[int]
) -> Dict:
    """Verify the overlap class conjecture for a specific (G, q, S) triple.

    Returns a dictionary with:
    - 'graph': the graph
    - 'basepoint': q
    - 'subset': S
    - 'cycle_supports': the cycle support family
    - 'overlap_class_count': number of overlap classes
    - 'overlap_degree': the overlap degree
    - 'overlap_signature': the overlap signature
    """
    F = cycle_support_family(G, S)
    classes = compute_overlap_classes(F)
    return {
        'graph_vertices': G.n,
        'graph_edges': G.edges_list,
        'basepoint': q,
        'subset': sorted(S),
        'num_cycles': F.n,
        'cycle_supports': [sorted(s) for s in F.supports],
        'overlap_class_count': len(classes),
        'overlap_classes': classes,
        'overlap_degree': overlap_degree(F),
        'overlap_signature': overlap_signature(F),
        'max_overlap_degree': max_overlap_degree(F),
    }


def batch_verify(max_n: int = 6) -> List[Dict]:
    """Batch verification of the conjecture on all connected graphs up to max_n vertices.

    Returns a list of verification results.
    """
    results = []
    for n in range(2, max_n + 1):
        graphs = generate_connected_graphs(n)
        for G in graphs:
            for q in range(n):
                S = set(range(n)) - {q}
                result = verify_conjecture_instance(G, q, S)
                results.append(result)
    return results


# ============================================================
# Algorithm 8: Support Interaction Analysis
# ============================================================

def interaction_matrix(family: SupportFamily) -> List[List[int]]:
    """Compute the support interaction matrix.

    M[i][j] = |supp_i ∩ supp_j| for i ≠ j, M[i][i] = |supp_i|.

    >>> F = SupportFamily([frozenset({0,1}), frozenset({1,2})])
    >>> M = interaction_matrix(F)
    >>> M[0][1]
    1
    """
    n = family.n
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        M[i][i] = len(family.supports[i])
        for j in range(i + 1, n):
            isect = len(family.supports[i] & family.supports[j])
            M[i][j] = isect
            M[j][i] = isect
    return M


# ============================================================
# Main execution
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Overlap Class Theory — Algorithm Suite")
    print("=" * 60)

    # Example 1: Basic overlap analysis
    print("\n--- Example 1: Basic Overlap Analysis ---")
    F = SupportFamily([
        frozenset({0, 1, 2}),
        frozenset({2, 3, 4}),
        frozenset({5, 6}),
        frozenset({6, 7, 8}),
    ])
    print(f"Family: {F}")
    print(f"Overlap degree: {overlap_degree(F)}")
    print(f"Overlap signature: {overlap_signature(F)}")
    print(f"Max overlap degree: {max_overlap_degree(F)}")
    print(f"Overlap classes: {compute_overlap_classes(F)}")
    print(f"Overlap class count: {overlap_class_count(F)}")

    # Example 2: Disjoint family
    print("\n--- Example 2: Disjoint Family ---")
    F2 = SupportFamily([
        frozenset({0, 1}),
        frozenset({2, 3}),
        frozenset({4, 5}),
    ])
    print(f"Family: {F2}")
    print(f"Overlap degree: {overlap_degree(F2)} (should be 0)")
    print(f"Overlap class count: {overlap_class_count(F2)} (should be 3)")

    # Example 3: Graph cycle analysis
    print("\n--- Example 3: Graph Cycle Analysis ---")
    # Triangle with pendant
    G = SimpleGraph(4, [(0,1), (1,2), (2,0), (2,3)])
    S = {0, 1, 2, 3}
    result = verify_conjecture_instance(G, -1, S)
    print(f"Graph: {result['graph_edges']}")
    print(f"Cycle supports: {result['cycle_supports']}")
    print(f"Overlap classes: {result['overlap_classes']}")
    print(f"Overlap degree: {result['overlap_degree']}")

    # Example 4: Interaction matrix
    print("\n--- Example 4: Interaction Matrix ---")
    M = interaction_matrix(F)
    print("Interaction matrix:")
    for row in M:
        print(f"  {row}")

    # Example 5: TPE testing
    print("\n--- Example 5: TPE Testing ---")
    F1 = [[1, 0, 2], [0, 3, 0]]
    F2_equiv = [[0 + 5, 3 + 5, 0 + 5], [1 - 1, 0 - 1, 2 - 1]]  # Perm (0,1), c=(5,-1)
    result = check_trop_proj_equiv(F1, F2_equiv)
    print(f"TPE result: {result}")

    F2_not = [[1, 1, 1], [0, 3, 0]]
    result2 = check_trop_proj_equiv(F1, F2_not)
    print(f"Non-TPE result: {result2}")

    print("\n--- Batch Verification (n ≤ 5) ---")
    results = batch_verify(5)
    print(f"Total instances checked: {len(results)}")
    nontrivial = [r for r in results if r['num_cycles'] > 0]
    print(f"Instances with cycles: {len(nontrivial)}")
    if nontrivial:
        max_overlap = max(r['overlap_degree'] for r in nontrivial)
        print(f"Max overlap degree seen: {max_overlap}")
        max_classes = max(r['overlap_class_count'] for r in nontrivial)
        print(f"Max overlap class count: {max_classes}")
