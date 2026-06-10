"""
Treewidth-Parameterized Certificate Compilation Algorithms

Implements the core algorithms for deletion/contraction certificate
compilation on bounded-treewidth graphs, including:
- Random bounded-treewidth graph generation
- Nice tree decomposition construction
- Certificate compilation with size tracking
- FPT bound computation and verification

Author: Harmonic Research
"""

from __future__ import annotations
import random
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Optional


# ============================================================
# Graph Representation
# ============================================================

@dataclass
class Graph:
    """Simple undirected graph with integer vertices."""
    n: int
    edges: set[tuple[int, int]] = field(default_factory=set)
    adj: dict[int, set[int]] = field(default_factory=lambda: defaultdict(set))

    def add_edge(self, u: int, v: int) -> None:
        """Add an undirected edge. Stores as (min, max) pair."""
        if u == v:
            return
        e = (min(u, v), max(u, v))
        if e not in self.edges:
            self.edges.add(e)
            self.adj[u].add(v)
            self.adj[v].add(u)

    @property
    def num_edges(self) -> int:
        return len(self.edges)

    @property
    def num_vertices(self) -> int:
        return self.n

    def delete_edge(self, u: int, v: int) -> 'Graph':
        """Return a new graph with edge (u,v) removed."""
        g = Graph(self.n)
        e = (min(u, v), max(u, v))
        for edge in self.edges:
            if edge != e:
                g.add_edge(*edge)
        return g

    def contract_edge(self, u: int, v: int) -> 'Graph':
        """Return a new graph with edge (u,v) contracted (v merged into u)."""
        g = Graph(self.n)
        e = (min(u, v), max(u, v))
        for a, b in self.edges:
            if (a, b) == e:
                continue
            a2 = u if a == v else a
            b2 = u if b == v else b
            if a2 != b2:
                g.add_edge(a2, b2)
        return g


# ============================================================
# Certificate Tree
# ============================================================

@dataclass
class CertTree:
    """Binary certificate tree for deletion/contraction recurrence.

    Each internal node represents a choice to delete or contract an edge.
    Leaves represent base cases.
    """
    edge: Optional[tuple[int, int]] = None  # None for leaves
    delete_child: Optional['CertTree'] = None
    contract_child: Optional['CertTree'] = None
    leaf_edges: Optional[set[tuple[int, int]]] = None

    @property
    def is_leaf(self) -> bool:
        return self.edge is None

    @property
    def size(self) -> int:
        """Total number of nodes."""
        if self.is_leaf:
            return 1
        return 1 + self.delete_child.size + self.contract_child.size

    @property
    def depth(self) -> int:
        """Maximum depth."""
        if self.is_leaf:
            return 0
        return 1 + max(self.delete_child.depth, self.contract_child.depth)

    @property
    def leaf_count(self) -> int:
        """Number of leaves."""
        if self.is_leaf:
            return 1
        return self.delete_child.leaf_count + self.contract_child.leaf_count


# ============================================================
# Bounded-Treewidth Graph Generation
# ============================================================

def generate_k_tree(n: int, k: int, seed: Optional[int] = None) -> tuple[Graph, list[set[int]]]:
    """Generate a random partial k-tree on n vertices with treewidth ≤ k.

    Algorithm:
    1. Start with a complete graph on k+1 vertices (a k-clique).
    2. For each new vertex, choose an existing k-clique and connect the
       new vertex to all k+1 vertices in the clique.
    3. Randomly delete some edges to create a partial k-tree.

    Args:
        n: Number of vertices (must be ≥ k+1)
        k: Target treewidth
        seed: Random seed for reproducibility

    Returns:
        (graph, bags): The graph and a list of bags forming a tree decomposition
    """
    if seed is not None:
        random.seed(seed)

    if n < k + 1:
        raise ValueError(f"Need n ≥ k+1, got n={n}, k={k}")

    g = Graph(n)
    bags: list[set[int]] = []

    # Start with complete graph on vertices 0..k
    initial_clique = set(range(k + 1))
    for i in range(k + 1):
        for j in range(i + 1, k + 1):
            g.add_edge(i, j)
    bags.append(initial_clique.copy())

    # Add vertices one at a time
    cliques = [initial_clique.copy()]
    for v in range(k + 1, n):
        # Choose a random existing clique
        parent_clique = random.choice(cliques)
        # Choose k vertices from the clique to connect to
        if len(parent_clique) > k:
            connect_to = set(random.sample(sorted(parent_clique), k))
        else:
            connect_to = parent_clique.copy()

        for u in connect_to:
            g.add_edge(v, u)

        new_clique = connect_to | {v}
        cliques.append(new_clique)
        bags.append(new_clique.copy())

    # Randomly delete some edges (make it a partial k-tree)
    edges_to_remove = []
    for e in list(g.edges):
        if random.random() < 0.2:  # 20% edge deletion
            edges_to_remove.append(e)
    for e in edges_to_remove:
        g.edges.discard(e)
        g.adj[e[0]].discard(e[1])
        g.adj[e[1]].discard(e[0])

    return g, bags


# ============================================================
# Certificate Compilation
# ============================================================

def compile_certificate(g: Graph, max_depth: int = 50) -> CertTree:
    """Compile a deletion/contraction certificate for graph g.

    Recursively applies deletion/contraction to each edge,
    building a binary certificate tree.

    Args:
        g: Input graph
        max_depth: Maximum recursion depth (prevents stack overflow)

    Returns:
        CertTree: The compiled certificate
    """
    if not g.edges or max_depth <= 0:
        return CertTree(leaf_edges=g.edges.copy())

    # Choose an edge to branch on
    edge = next(iter(g.edges))
    u, v = edge

    # Delete branch
    g_del = g.delete_edge(u, v)
    del_cert = compile_certificate(g_del, max_depth - 1)

    # Contract branch
    g_con = g.contract_edge(u, v)
    con_cert = compile_certificate(g_con, max_depth - 1)

    return CertTree(
        edge=edge,
        delete_child=del_cert,
        contract_child=con_cert
    )


def compile_certificate_with_decomp(
    g: Graph, bags: list[set[int]], k: int
) -> CertTree:
    """Compile a certificate guided by a tree decomposition.

    Processes edges bag-by-bag, reducing branching by limiting
    active edges at each step.

    Args:
        g: Input graph
        bags: Tree decomposition bags
        k: Treewidth bound

    Returns:
        CertTree: The compiled certificate
    """
    # Collect edges per bag
    edge_bags: dict[tuple[int, int], int] = {}
    for idx, bag in enumerate(bags):
        bag_list = sorted(bag)
        for i, u in enumerate(bag_list):
            for v in bag_list[i + 1:]:
                e = (u, v)
                if e in g.edges and e not in edge_bags:
                    edge_bags[e] = idx

    # Order edges by bag index
    ordered_edges = sorted(edge_bags.keys(), key=lambda e: edge_bags[e])

    return _compile_ordered(g, ordered_edges, 0)


def _compile_ordered(g: Graph, edges: list[tuple[int, int]], idx: int) -> CertTree:
    """Helper: compile certificate processing edges in order."""
    if idx >= len(edges):
        return CertTree(leaf_edges=set())

    edge = edges[idx]
    u, v = edge

    if edge not in g.edges:
        # Edge already removed by prior contraction
        return _compile_ordered(g, edges, idx + 1)

    g_del = g.delete_edge(u, v)
    del_cert = _compile_ordered(g_del, edges, idx + 1)

    g_con = g.contract_edge(u, v)
    con_cert = _compile_ordered(g_con, edges, idx + 1)

    return CertTree(edge=edge, delete_child=del_cert, contract_child=con_cert)


# ============================================================
# FPT Bound Computation
# ============================================================

def max_active_edges(k: int) -> int:
    """Maximum active edges for bag width k: C(k+1, 2) = k*(k+1)//2."""
    return k * (k + 1) // 2


def cert_branching_bound(k: int) -> int:
    """Certificate branching bound: 2^(k²+k)."""
    return 2 ** (k ** 2 + k)


def fpt_cert_bound(num_edges: int, k: int) -> int:
    """FPT certificate bound: m * 2^(k²+k)."""
    return num_edges * cert_branching_bound(k)


def bell_number(n: int) -> int:
    """Compute the n-th Bell number using the Bell triangle."""
    if n == 0:
        return 1
    # Bell triangle
    triangle = [[0] * (n + 1) for _ in range(n + 1)]
    triangle[0][0] = 1
    for i in range(1, n + 1):
        triangle[i][0] = triangle[i - 1][i - 1]
        for j in range(1, i + 1):
            triangle[i][j] = triangle[i][j - 1] + triangle[i - 1][j - 1]
    return triangle[n][0]


# ============================================================
# Verification
# ============================================================

def verify_certificate_bound(g: Graph, cert: CertTree, k: int) -> dict:
    """Verify that the certificate satisfies the FPT bound.

    Returns a dictionary with:
    - cert_size: actual certificate size
    - fpt_bound: theoretical FPT bound
    - ratio: cert_size / fpt_bound
    - satisfies_bound: whether the bound is satisfied
    """
    m = g.num_edges
    bound = fpt_cert_bound(m, k)
    cert_size = cert.size

    return {
        'cert_size': cert_size,
        'leaf_count': cert.leaf_count,
        'depth': cert.depth,
        'num_edges': m,
        'treewidth': k,
        'fpt_bound': bound,
        'ratio': cert_size / bound if bound > 0 else float('inf'),
        'satisfies_bound': cert_size <= bound
    }


if __name__ == '__main__':
    # Quick demonstration
    print("=== Treewidth Certificate Compilation ===\n")

    for k in [1, 2, 3]:
        print(f"\n--- Treewidth k = {k} ---")
        g, bags = generate_k_tree(20, k, seed=42)
        cert = compile_certificate_with_decomp(g, bags, k)
        result = verify_certificate_bound(g, cert, k)

        print(f"  Vertices: {g.num_vertices}")
        print(f"  Edges: {result['num_edges']}")
        print(f"  Certificate size: {result['cert_size']}")
        print(f"  Certificate depth: {result['depth']}")
        print(f"  Leaf count: {result['leaf_count']}")
        print(f"  FPT bound: {result['fpt_bound']}")
        print(f"  Ratio (cert/bound): {result['ratio']:.6f}")
        print(f"  Satisfies bound: {result['satisfies_bound']}")

    print("\n\n=== Bell Number Comparison ===")
    for k in range(1, 7):
        b = bell_number(k + 1)
        bound = cert_branching_bound(k)
        print(f"  k={k}: Bell(k+1)={b}, 2^(k²+k)={bound}, ratio={b/bound:.6f}")
