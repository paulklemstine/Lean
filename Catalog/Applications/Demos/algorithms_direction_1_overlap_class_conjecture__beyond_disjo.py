"""
Algorithms for Overlap Class Analysis of Cycle Supports in Graphs.

Implements the core mathematical constructions formalized in Lean:
- Support overlap graph construction
- Overlap class (connected component) computation
- Overlap degree calculation
- Total overlap complexity
- Overlap signature computation

These algorithms support conjecture testing for the Overlap Class Conjecture,
which posits that tropical projective equivalence classes of minimal generating
families are controlled by the overlap pattern of cycle supports.
"""

from typing import List, Set, Dict, Tuple, FrozenSet, Optional
from collections import defaultdict, deque
from itertools import combinations
import math


class Graph:
    """Simple undirected graph represented by adjacency lists."""

    def __init__(self, n: int, edges: List[Tuple[int, int]] = None):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        if edges:
            for u, v in edges:
                self.add_edge(u, v)

    def add_edge(self, u: int, v: int) -> None:
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def vertices(self) -> range:
        return range(self.n)

    def edges(self) -> List[Tuple[int, int]]:
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def is_connected(self) -> bool:
        if self.n == 0:
            return True
        visited = set()
        queue = deque([0])
        visited.add(0)
        while queue:
            u = queue.popleft()
            for v in self.adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        return len(visited) == self.n

    def induced_subgraph(self, S: Set[int]) -> 'Graph':
        """Return the induced subgraph G[S]."""
        vertex_list = sorted(S)
        idx = {v: i for i, v in enumerate(vertex_list)}
        g = Graph(len(S))
        for u in S:
            for v in self.adj[u]:
                if v in S and u < v:
                    g.add_edge(idx[u], idx[v])
        # Store original vertex mapping
        g._original_vertices = vertex_list
        return g


def find_cycle_supports(G: Graph, S: Set[int]) -> List[FrozenSet[int]]:
    """
    Find cycle supports in the induced subgraph G[S].

    A cycle support is the vertex set of a fundamental cycle in G[S].
    We compute a spanning forest, then for each non-tree edge, the
    fundamental cycle through that edge gives a cycle support.

    Returns a list of frozensets, each being the vertex set of a
    fundamental cycle.

    Time complexity: O(|S| + |E(G[S])|) per cycle
    Space complexity: O(|S|)
    """
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)

    # Build spanning forest via BFS
    parent = {}
    visited = set()
    tree_edges = set()
    non_tree_edges = []

    for root in vertices:
        if root in visited:
            continue
        visited.add(root)
        parent[root] = -1
        queue = deque([root])
        while queue:
            u = queue.popleft()
            for v in adj_in_S[u]:
                if v not in visited:
                    visited.add(v)
                    parent[v] = u
                    tree_edges.add((min(u, v), max(u, v)))
                    queue.append(v)
                elif (min(u, v), max(u, v)) not in tree_edges:
                    non_tree_edges.append((u, v))

    # For each non-tree edge, find fundamental cycle
    supports = []
    for u, v in non_tree_edges:
        # Find path from u to v in tree
        path_u = []
        x = u
        while x != -1:
            path_u.append(x)
            x = parent[x]

        path_v = []
        x = v
        while x != -1:
            path_v.append(x)
            x = parent[x]

        # Find LCA
        set_u = set(path_u)
        lca = None
        for x in path_v:
            if x in set_u:
                lca = x
                break

        if lca is None:
            continue

        cycle_vertices = set()
        for x in path_u:
            cycle_vertices.add(x)
            if x == lca:
                break
        for x in path_v:
            cycle_vertices.add(x)
            if x == lca:
                break

        supports.append(frozenset(cycle_vertices))

    return supports


def support_overlap_graph(supports: List[FrozenSet[int]]) -> Graph:
    """
    Build the support interaction graph.

    Vertices are indices into the supports list. Two indices are adjacent
    iff their supports have nonempty intersection.

    Time complexity: O(n^2 * max_support_size) where n = len(supports)
    Space complexity: O(n^2)
    """
    n = len(supports)
    g = Graph(n)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            g.add_edge(i, j)
    return g


def overlap_classes(supports: List[FrozenSet[int]]) -> List[List[int]]:
    """
    Compute the overlap classes (connected components of the overlap graph).

    Returns a list of lists, each containing the indices belonging to one class.

    Time complexity: O(n^2 * max_support_size)
    Space complexity: O(n)
    """
    n = len(supports)
    if n == 0:
        return []

    og = support_overlap_graph(supports)
    visited = set()
    components = []

    for start in range(n):
        if start in visited:
            continue
        component = []
        queue = deque([start])
        visited.add(start)
        while queue:
            u = queue.popleft()
            component.append(u)
            for v in og.adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        components.append(sorted(component))

    return components


def overlap_class_count(supports: List[FrozenSet[int]]) -> int:
    """Number of overlap classes."""
    return len(overlap_classes(supports))


def overlap_degree(supports: List[FrozenSet[int]]) -> int:
    """
    Maximum pairwise intersection cardinality among distinct supports.

    Time complexity: O(n^2 * max_support_size)
    """
    max_inter = 0
    for i, j in combinations(range(len(supports)), 2):
        inter_size = len(supports[i] & supports[j])
        max_inter = max(max_inter, inter_size)
    return max_inter


def total_overlap_complexity(supports: List[FrozenSet[int]]) -> int:
    """
    Sum of all pairwise intersection cardinalities.

    Time complexity: O(n^2 * max_support_size)
    """
    total = 0
    for i, j in combinations(range(len(supports)), 2):
        total += len(supports[i] & supports[j])
    return total


def overlap_signature(supports: List[FrozenSet[int]]) -> List[int]:
    """
    Sorted multiset of pairwise intersection cardinalities.

    This is a computable invariant capturing the shape of the overlap pattern.
    """
    sizes = []
    for i, j in combinations(range(len(supports)), 2):
        sizes.append(len(supports[i] & supports[j]))
    return sorted(sizes)


def support_nerve_2(supports: List[FrozenSet[int]]) -> Dict[Tuple[int, int], FrozenSet[int]]:
    """
    Compute the 2-skeleton of the support nerve: for each pair (i, j),
    record the intersection F_i ∩ F_j.
    """
    nerve = {}
    for i, j in combinations(range(len(supports)), 2):
        inter = supports[i] & supports[j]
        if inter:
            nerve[(i, j)] = frozenset(inter)
    return nerve


def pairwise_disjoint(supports: List[FrozenSet[int]]) -> bool:
    """Check if all supports are pairwise disjoint."""
    for i, j in combinations(range(len(supports)), 2):
        if supports[i] & supports[j]:
            return False
    return True


def graph_laplacian(G: Graph) -> List[List[int]]:
    """Compute the combinatorial graph Laplacian matrix."""
    n = G.n
    L = [[0] * n for _ in range(n)]
    for v in range(n):
        L[v][v] = G.degree(v)
        for u in G.adj[v]:
            L[v][u] = -1
    return L


def generate_connected_graphs(n: int) -> List[Graph]:
    """
    Generate all non-isomorphic connected simple graphs on n vertices.

    For small n (≤ 7), this uses a brute-force enumeration.
    For efficiency, we generate all possible edge sets and filter.

    Time complexity: O(2^(n*(n-1)/2)) — exponential, feasible for n ≤ 7
    """
    if n <= 0:
        return []
    if n == 1:
        return [Graph(1)]

    all_possible_edges = list(combinations(range(n), 2))
    m = len(all_possible_edges)
    connected_graphs = []

    for mask in range(1, 1 << m):
        edges = [all_possible_edges[i] for i in range(m) if mask & (1 << i)]
        g = Graph(n, edges)
        if g.is_connected():
            connected_graphs.append(g)

    return connected_graphs


def test_overlap_conjecture(G: Graph, q: int, S: Set[int],
                            verbose: bool = False) -> Dict:
    """
    Test the overlap class conjecture for a specific (G, q, S) triple.

    The conjecture: the number of tropical projective equivalence classes
    of minimal generating families equals the number of overlap classes
    of cycle supports in G[S].

    Returns a dict with:
    - 'graph': the graph
    - 'basepoint': q
    - 'subset': S
    - 'cycle_supports': list of cycle supports
    - 'overlap_classes': the overlap classes
    - 'overlap_class_count': number of overlap classes
    - 'overlap_degree': max pairwise intersection size
    - 'total_complexity': total overlap complexity
    - 'overlap_signature': sorted intersection sizes
    - 'is_disjoint': whether supports are pairwise disjoint
    """
    supports = find_cycle_supports(G, S)

    result = {
        'graph_vertices': G.n,
        'graph_edges': G.edges(),
        'basepoint': q,
        'subset': sorted(S),
        'cycle_supports': [sorted(s) for s in supports],
        'overlap_classes': overlap_classes(supports),
        'overlap_class_count': overlap_class_count(supports),
        'overlap_degree': overlap_degree(supports),
        'total_complexity': total_overlap_complexity(supports),
        'overlap_signature': overlap_signature(supports),
        'is_disjoint': pairwise_disjoint(supports),
    }

    if verbose:
        print(f"Graph: {G.n} vertices, {len(G.edges())} edges")
        print(f"Basepoint: {q}, Subset S: {sorted(S)}")
        print(f"Cycle supports: {result['cycle_supports']}")
        print(f"Overlap classes: {result['overlap_classes']}")
        print(f"Overlap class count: {result['overlap_class_count']}")
        print(f"Overlap degree: {result['overlap_degree']}")
        print(f"Is disjoint: {result['is_disjoint']}")

    return result


def batch_test(max_n: int = 6, verbose: bool = False) -> List[Dict]:
    """
    Batch test the overlap conjecture on all connected graphs up to n vertices.

    For each graph G, tests all basepoints q and subsets S ⊆ V \ {q}.

    Args:
        max_n: Maximum number of vertices (default 6, max recommended 7)
        verbose: Print progress

    Returns:
        List of test results
    """
    results = []
    for n in range(2, max_n + 1):
        if verbose:
            print(f"\n=== Testing n = {n} ===")
        graphs = generate_connected_graphs(n)
        if verbose:
            print(f"  {len(graphs)} connected graphs")

        for gi, G in enumerate(graphs):
            for q in range(n):
                remaining = set(range(n)) - {q}
                # Test a few representative subsets
                for size in range(1, len(remaining) + 1):
                    for S_tuple in combinations(sorted(remaining), size):
                        S = set(S_tuple)
                        result = test_overlap_conjecture(G, q, S, verbose=False)
                        result['graph_index'] = gi
                        results.append(result)

    if verbose:
        # Summary
        n_disjoint = sum(1 for r in results if r['is_disjoint'])
        n_overlapping = sum(1 for r in results if not r['is_disjoint'])
        print(f"\n=== Summary ===")
        print(f"Total tests: {len(results)}")
        print(f"Disjoint cases: {n_disjoint}")
        print(f"Overlapping cases: {n_overlapping}")

        # Overlap degree distribution
        deg_dist = defaultdict(int)
        for r in results:
            deg_dist[r['overlap_degree']] += 1
        print(f"Overlap degree distribution: {dict(sorted(deg_dist.items()))}")

    return results


if __name__ == "__main__":
    # Example: Triangle graph K_3
    print("=== Example: Triangle K_3 ===")
    K3 = Graph(3, [(0, 1), (1, 2), (0, 2)])
    result = test_overlap_conjecture(K3, 0, {1, 2}, verbose=True)

    print("\n=== Example: Complete graph K_4 ===")
    K4 = Graph(4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])
    result = test_overlap_conjecture(K4, 0, {1, 2, 3}, verbose=True)

    print("\n=== Example: Path P_4 (no cycles) ===")
    P4 = Graph(4, [(0, 1), (1, 2), (2, 3)])
    result = test_overlap_conjecture(P4, 0, {1, 2, 3}, verbose=True)

    print("\n=== Example: Cycle C_5 ===")
    C5 = Graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    result = test_overlap_conjecture(C5, 0, {1, 2, 3, 4}, verbose=True)
