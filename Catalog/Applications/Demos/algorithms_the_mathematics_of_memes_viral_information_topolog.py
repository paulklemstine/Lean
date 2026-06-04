"""
Viral Information Topology: Core Algorithms

Type-hinted implementations of sheaf cohomology computations on graphs.
"""

from typing import Dict, List, Optional, Set, Tuple
import numpy as np
from collections import defaultdict, deque


class Graph:
    """Simple undirected graph with integer vertices."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.edges = []
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.append((min(u, v), max(u, v)))
        self.edges = list(set(self.edges))

    def neighbors(self, v: int) -> Set[int]:
        return self.adj[v]

    def degree(self, v: int) -> int:
        return len(self.adj[v])


class TwistedSheaf:
    """Twisted meme sheaf: each directed edge (i,j) carries a twist factor."""

    def __init__(self, graph: Graph, twists: Dict[Tuple[int, int], float]):
        self.graph = graph
        self.twists = twists

    @classmethod
    def constant(cls, graph: Graph) -> "TwistedSheaf":
        """The constant sheaf: all twists are 1."""
        twists = {}
        for u, v in graph.edges:
            twists[(u, v)] = 1.0
            twists[(v, u)] = 1.0
        return cls(graph, twists)

    def twist(self, u: int, v: int) -> float:
        return self.twists.get((u, v), 1.0)


def connected_components(g: Graph) -> List[Set[int]]:
    """Compute connected components via BFS. O(V + E)."""
    visited: Set[int] = set()
    components: List[Set[int]] = []

    for v in range(g.n):
        if v not in visited:
            component: Set[int] = set()
            queue = deque([v])
            while queue:
                u = queue.popleft()
                if u in visited:
                    continue
                visited.add(u)
                component.add(u)
                for w in g.neighbors(u):
                    if w not in visited:
                        queue.append(w)
            components.append(component)

    return components


def h0_dimension(g: Graph) -> int:
    """Compute dim H⁰ for the constant sheaf.

    For the constant sheaf, dim H⁰ = number of connected components.
    This is O(V + E) via BFS.
    """
    return len(connected_components(g))


def coboundary_matrix(g: Graph) -> np.ndarray:
    """Build the coboundary matrix δ: ℝ^V → ℝ^E.

    δ(f)(e) = f(tgt(e)) - f(src(e)) for each oriented edge e.
    Orient edges as (min, max).

    Returns matrix of shape (|E|, |V|).
    """
    m = len(g.edges)
    delta = np.zeros((m, g.n))
    for idx, (u, v) in enumerate(g.edges):
        delta[idx, u] = -1.0
        delta[idx, v] = 1.0
    return delta


def graph_laplacian(g: Graph) -> np.ndarray:
    """Build the graph Laplacian L = δᵀδ.

    L(i,j) = deg(i) if i=j, -1 if adj(i,j), 0 otherwise.

    Returns matrix of shape (|V|, |V|).
    """
    L = np.zeros((g.n, g.n))
    for i in range(g.n):
        L[i, i] = g.degree(i)
        for j in g.neighbors(i):
            L[i, j] = -1.0
    return L


def h0_via_laplacian(g: Graph, tol: float = 1e-10) -> int:
    """Compute dim H⁰ via nullity of the Laplacian.

    This demonstrates the Spectral-Cohomological Bridge:
    dim H⁰ = dim ker(L) = multiplicity of eigenvalue 0.
    """
    L = graph_laplacian(g)
    eigenvalues = np.linalg.eigvalsh(L)
    return int(np.sum(np.abs(eigenvalues) < tol))


def h1_dimension(g: Graph) -> int:
    """Compute dim H¹ for the constant sheaf.

    By rank-nullity: dim H¹ = |E| - rank(δ) = |E| - (|V| - dim H⁰)
                    = |E| - |V| + dim H⁰ = cycle rank + dim H⁰ - dim H⁰
                    = |E| - |V| + (number of components)
    This is the cycle rank (first Betti number).
    """
    num_components = h0_dimension(g)
    return len(g.edges) - g.n + num_components


def euler_characteristic(g: Graph) -> int:
    """Compute χ = |V| - |E| = dim H⁰ - dim H¹."""
    return g.n - len(g.edges)


def virality_index(total_interp: int, h1_dim: int) -> float:
    """Compute the virality index: total_interp / (1 + h1_dim)."""
    return total_interp / (1 + h1_dim)


def walk_monodromy(sheaf: TwistedSheaf, walk: List[int]) -> float:
    """Compute the monodromy of a twisted sheaf along a walk.

    walk is a list of vertices [v0, v1, ..., vk].
    Monodromy = product of twist(vi, vi+1) for i = 0, ..., k-1.
    """
    mono = 1.0
    for i in range(len(walk) - 1):
        mono *= sheaf.twist(walk[i], walk[i + 1])
    return mono


def spanning_tree_dfs(g: Graph, root: int = 0) -> Tuple[List[Tuple[int, int]], List[Tuple[int, int]]]:
    """DFS spanning tree. Returns (tree_edges, non_tree_edges)."""
    visited: Set[int] = set()
    tree_edges: List[Tuple[int, int]] = []
    stack = [root]
    parent: Dict[int, int] = {root: -1}

    while stack:
        v = stack.pop()
        if v in visited:
            continue
        visited.add(v)
        if parent[v] != -1:
            tree_edges.append((min(parent[v], v), max(parent[v], v)))
        for w in g.neighbors(v):
            if w not in visited:
                parent[w] = v
                stack.append(w)

    tree_edge_set = set(tree_edges)
    non_tree = [e for e in g.edges if e not in tree_edge_set]
    return tree_edges, non_tree


def fundamental_cycle_monodromies(g: Graph, sheaf: TwistedSheaf) -> List[float]:
    """Compute monodromy around each fundamental cycle.

    For each non-tree edge, find the fundamental cycle via the spanning tree
    and compute its monodromy. O(V + E) total.
    """
    tree_edges, non_tree_edges = spanning_tree_dfs(g)

    # Build tree adjacency for path finding
    tree_adj: Dict[int, Set[int]] = defaultdict(set)
    for u, v in tree_edges:
        tree_adj[u].add(v)
        tree_adj[v].add(u)

    def tree_path(start: int, end: int) -> List[int]:
        """BFS path in tree."""
        parent: Dict[int, int] = {start: -1}
        queue = deque([start])
        while queue:
            v = queue.popleft()
            if v == end:
                path = []
                while v != -1:
                    path.append(v)
                    v = parent[v]
                return path[::-1]
            for w in tree_adj[v]:
                if w not in parent:
                    parent[w] = v
                    queue.append(w)
        return []

    monodromies = []
    for u, v in non_tree_edges:
        # Fundamental cycle: tree path u -> v, then edge v -> u
        path = tree_path(u, v)
        path.append(u)  # Close the cycle
        mono = walk_monodromy(sheaf, path)
        monodromies.append(mono)

    return monodromies


def is_flat(g: Graph, sheaf: TwistedSheaf, tol: float = 1e-10) -> bool:
    """Check if a twisted sheaf is flat (all monodromies = 1)."""
    monos = fundamental_cycle_monodromies(g, sheaf)
    return all(abs(m - 1.0) < tol for m in monos)


def propagation_step(g: Graph, f: np.ndarray) -> np.ndarray:
    """One step of meme propagation: each vertex averages neighbors."""
    result = np.copy(f)
    for v in range(g.n):
        nbrs = list(g.neighbors(v))
        if nbrs:
            result[v] = np.mean(f[list(nbrs)])
    return result


def propagation_equilibrium(g: Graph, f0: np.ndarray,
                             max_steps: int = 1000,
                             tol: float = 1e-10) -> Tuple[np.ndarray, int]:
    """Run propagation to equilibrium. Returns (equilibrium, steps)."""
    f = np.copy(f0)
    for step in range(max_steps):
        f_new = propagation_step(g, f)
        if np.max(np.abs(f_new - f)) < tol:
            return f_new, step + 1
        f = f_new
    return f, max_steps


def erdos_renyi(n: int, p: float, seed: Optional[int] = None) -> Graph:
    """Generate an Erdős-Rényi random graph G(n, p)."""
    rng = np.random.default_rng(seed)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return Graph(n, edges)


if __name__ == "__main__":
    # Quick demo
    g = Graph(6, [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5)])
    print(f"Graph: {g.n} vertices, {len(g.edges)} edges")
    print(f"Connected components: {len(connected_components(g))}")
    print(f"dim H⁰ = {h0_dimension(g)}")
    print(f"dim H¹ = {h1_dimension(g)}")
    print(f"χ = {euler_characteristic(g)}")
    print(f"dim H⁰ (Laplacian) = {h0_via_laplacian(g)}")
    print(f"Virality index = {virality_index(g.n, h1_dimension(g)):.4f}")
