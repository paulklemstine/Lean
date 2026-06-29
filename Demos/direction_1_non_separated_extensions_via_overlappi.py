#!/usr/bin/env python3
"""
Applications of Overlap Support Theory

Real-world and mathematical applications of the overlap interaction
framework for graph Laplacians:

1. Electrical Network Analysis — computing effective resistances
2. Graph Jacobian Computation — classifying the sandpile group
3. Chip-Firing Analysis — understanding recurrent configurations
4. Spectral Clustering Quality — measuring subset cohesion
"""

import numpy as np
from typing import List, Tuple, Set
from itertools import combinations


# ─── Core infrastructure (self-contained) ───

class Graph:
    """Simple undirected graph."""
    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.edges = edges
        self.adj: Set[Tuple[int, int]] = set()
        for u, v in edges:
            self.adj.add((u, v))
            self.adj.add((v, u))

    def degree(self, v: int) -> int:
        return sum(1 for u in range(self.n) if (v, u) in self.adj)

    def is_adjacent(self, u: int, v: int) -> bool:
        return (u, v) in self.adj

    def laplacian(self) -> np.ndarray:
        L = np.zeros((self.n, self.n), dtype=int)
        for i in range(self.n):
            for j in range(self.n):
                if i == j:
                    L[i, j] = self.degree(i)
                elif self.is_adjacent(i, j):
                    L[i, j] = -1
        return L


def restricted_laplacian(G: Graph, S: List[int]) -> np.ndarray:
    L = G.laplacian()
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


def overlap_interaction_matrix(L_S: np.ndarray) -> np.ndarray:
    D = np.diag(np.diag(L_S))
    return L_S - D


def smith_normal_form_diag(M: np.ndarray) -> List[int]:
    A = M.copy().astype(int)
    n, m = A.shape
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    A[[k, i]] = A[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        changed = True
        while changed:
            changed = False
            if A[k, k] < 0:
                A[k] = -A[k]
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        changed = True
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        changed = True
    return sorted([abs(int(A[i, i])) for i in range(min(n, m)) if A[i, i] != 0])


# ─── Application 1: Electrical Networks ───

def effective_resistance_analysis(G: Graph, S: List[int]):
    """Analyze the effective resistance structure of subset S.

    In an electrical network where each edge has unit resistance,
    the restricted Laplacian L_S encodes the conductance matrix
    seen at the terminals S. The overlap interaction matrix Ω_S
    captures mutual conductances between terminal pairs.
    """
    print("=" * 50)
    print("APPLICATION 1: Electrical Network Analysis")
    print("=" * 50)

    L_S = restricted_laplacian(G, S)
    Omega = overlap_interaction_matrix(L_S)
    D = np.diag(np.diag(L_S))

    print(f"\nGraph: {G.n} vertices, {len(G.edges)} edges")
    print(f"Terminal set S = {S}")
    print(f"\nConductance matrix L_S:")
    print(L_S)
    print(f"\nSelf-conductance (degrees) D_S:")
    print(D)
    print(f"\nMutual conductance (interaction) Ω_S:")
    print(Omega)

    # The diagonal entries represent total conductance at each terminal
    # The off-diagonal entries represent direct coupling
    for i in range(len(S)):
        total_cond = L_S[i, i]
        internal_cond = -sum(Omega[i, j] for j in range(len(S)) if j != i)
        external_cond = total_cond - internal_cond
        print(f"\n  Terminal {S[i]}:")
        print(f"    Total conductance: {total_cond}")
        print(f"    Internal coupling: {internal_cond} (edges within S)")
        print(f"    External coupling: {external_cond} (edges to V\\S)")

    # Energy interpretation
    print(f"\n  Unit potential difference test:")
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            x = np.zeros(len(S), dtype=int)
            x[i] = 1
            x[j] = -1
            power = int(x @ L_S @ x)
            self_power = int(x @ D @ x)
            interaction_power = int(x @ Omega @ x)
            print(f"    V({S[i]})=+1, V({S[j]})=-1: "
                  f"Power={power} = {self_power}(self) + {interaction_power}(interaction)")


# ─── Application 2: Graph Jacobian / Sandpile Group ───

def jacobian_analysis(G: Graph):
    """Compute the Jacobian (sandpile group) structure from different subsets.

    The Jacobian of a graph is the cokernel of its Laplacian (minus one
    row/column). The overlap theory shows how different subsets S give
    rise to different presentations of related quotient groups, all
    governed by the restricted Laplacian L_S and its Smith Normal Form.
    """
    print("\n" + "=" * 50)
    print("APPLICATION 2: Graph Jacobian Analysis")
    print("=" * 50)

    L = G.laplacian()
    print(f"\nGraph: {G.n} vertices, {len(G.edges)} edges")
    print(f"Laplacian:\n{L}")

    # Full Jacobian (delete vertex 0)
    L_reduced = L[1:, 1:]
    full_factors = smith_normal_form_diag(L_reduced)
    nontrivial = [f for f in full_factors if f > 1]
    print(f"\nFull Jacobian (reduced Laplacian, delete vertex 0):")
    print(f"  Invariant factors: {full_factors}")
    if nontrivial:
        print(f"  Jac(G) ≅ " + " ⊕ ".join(f"ℤ/{f}ℤ" for f in nontrivial))
    else:
        print(f"  Jac(G) ≅ 0 (tree)")

    # Subset-restricted cokernels
    print(f"\nRestricted cokernels for different subsets:")
    for r in range(2, G.n + 1):
        for S in combinations(range(G.n), r):
            S = list(S)
            L_S = restricted_laplacian(G, S)
            factors = smith_normal_form_diag(L_S)
            Omega = overlap_interaction_matrix(L_S)
            is_sep = np.array_equal(Omega, np.zeros_like(Omega))
            nontrivial = [f for f in factors if f > 1]
            sep_label = "SEP" if is_sep else "OVR"
            coker = " ⊕ ".join(f"ℤ/{f}ℤ" for f in nontrivial) if nontrivial else "0"
            print(f"  S={S} [{sep_label}]: factors={factors}, "
                  f"ℤ^{len(S)}/Im(L_S) has torsion {coker}")


# ─── Application 3: Spectral Clustering Quality ───

def clustering_quality(G: Graph, clusters: List[List[int]]):
    """Measure clustering quality using overlap energy decomposition.

    For a partition of vertices into clusters, the overlap theory
    decomposes the total Laplacian energy into:
    - Self-energy: how well-connected each cluster is internally
    - Interaction energy: cross-cluster coupling

    A good clustering maximizes internal connectivity (high self-energy
    on indicator vectors) relative to cross-cluster interaction.
    """
    print("\n" + "=" * 50)
    print("APPLICATION 3: Spectral Clustering Quality")
    print("=" * 50)

    print(f"\nGraph: {G.n} vertices, {len(G.edges)} edges")
    print(f"Clusters: {clusters}")

    L = G.laplacian()

    for idx, cluster in enumerate(clusters):
        if len(cluster) < 2:
            continue
        L_S = restricted_laplacian(G, cluster)
        D = np.diag(np.diag(L_S))
        Omega = overlap_interaction_matrix(L_S)

        # Use uniform indicator as test vector
        x = np.ones(len(cluster), dtype=int)
        E_total = int(x @ L_S @ x)
        E_self = int(x @ D @ x)
        E_int = int(x @ Omega @ x)

        # Internal edge count
        internal_edges = sum(1 for i in range(len(cluster))
                           for j in range(i+1, len(cluster))
                           if G.is_adjacent(cluster[i], cluster[j]))
        external_edges = sum(D[i, i] for i in range(len(cluster))) // 2 - internal_edges

        print(f"\n  Cluster {idx}: {cluster}")
        print(f"    Internal edges: {internal_edges}")
        print(f"    Cut edges (to rest): {E_total}")
        print(f"    Self-energy (uniform): {E_self}")
        print(f"    Interaction energy (uniform): {E_int}")
        print(f"    Cohesion ratio: {-E_int}/{E_self} = "
              f"{-E_int/E_self:.3f}" if E_self > 0 else "    Cohesion: N/A")


# ─── Main ───

if __name__ == "__main__":
    print("OVERLAP SUPPORT THEORY — APPLICATIONS\n")

    # Example 1: Electrical network on K4
    K4 = Graph(4, [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)])
    effective_resistance_analysis(K4, [0, 1, 2])

    # Example 2: Jacobian of Petersen-like graph
    C5 = Graph(5, [(0,1), (1,2), (2,3), (3,4), (4,0)])
    jacobian_analysis(C5)

    # Example 3: Clustering quality on a barbell graph
    barbell = Graph(6, [(0,1), (0,2), (1,2), (2,3), (3,4), (3,5), (4,5)])
    clustering_quality(barbell, [[0, 1, 2], [3, 4, 5]])

    # Example 4: Complete bipartite K_{2,3}
    K23 = Graph(5, [(0,2), (0,3), (0,4), (1,2), (1,3), (1,4)])
    print("\n" + "=" * 50)
    print("APPLICATION 4: Complete Bipartite K_{2,3}")
    print("=" * 50)
    jacobian_analysis(K23)

    print("\n\nAll applications completed successfully.")


#!/usr/bin/env python3
"""
Demo: Overlap Support Theory for Graph Laplacians

Demonstrates the key theorems from the overlap support theory:
1. Restricted Laplacian decomposition L_S = D_S + Omega_S
2. Separation <=> zero interaction matrix
3. Energy decomposition: overlap = self + interaction
4. Smith Normal Form of the restricted Laplacian
5. Comparison of separated vs non-separated subsets

Requires: numpy, sympy
"""

import numpy as np
from itertools import combinations
from collections import defaultdict


def graph_laplacian(adj, n):
    """Compute the graph Laplacian from adjacency list."""
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i != j and (i, j) in adj:
                L[i, j] = -1
                L[i, i] += 1
    return L


def restricted_laplacian(L, S):
    """Extract the restricted Laplacian L_S (principal submatrix)."""
    S = sorted(S)
    n = len(S)
    L_S = np.zeros((n, n), dtype=int)
    for a, i in enumerate(S):
        for b, j in enumerate(S):
            L_S[a, b] = L[i, j]
    return L_S


def diagonal_degree_mat(L_S):
    """Extract diagonal part D_S."""
    n = L_S.shape[0]
    D = np.zeros((n, n), dtype=int)
    for i in range(n):
        D[i, i] = L_S[i, i]
    return D


def overlap_interaction_mat(L_S):
    """Extract off-diagonal interaction matrix Omega_S."""
    return L_S - diagonal_degree_mat(L_S)


def is_separated(adj, S):
    """Check if S is a separated (independent) set."""
    S = list(S)
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if (S[i], S[j]) in adj:
                return False
    return True


def overlap_energy(L_S, x):
    """Compute the quadratic form x^T L_S x."""
    return int(x @ L_S @ x)


def self_energy(L_S, x):
    """Compute the self-energy x^T D_S x."""
    D = diagonal_degree_mat(L_S)
    return int(x @ D @ x)


def interaction_energy(L_S, x):
    """Compute the interaction energy x^T Omega_S x."""
    Omega = overlap_interaction_mat(L_S)
    return int(x @ Omega @ x)


def smith_normal_form(M):
    """Compute Smith Normal Form of integer matrix M via row/column operations.
    Returns (D, invariant_factors) where D is the diagonal form."""
    A = M.copy().astype(int)
    n, m = A.shape
    for k in range(min(n, m)):
        # Find nonzero pivot in submatrix A[k:, k:]
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    # Swap rows and columns to bring pivot to (k,k)
                    A[[k, i]] = A[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        # Reduce: make A[k,k] divide all entries in row k and column k
        changed = True
        while changed:
            changed = False
            # Make A[k,k] positive
            if A[k, k] < 0:
                A[k] = -A[k]
            # Column operations
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        changed = True
            # Row operations
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        changed = True
    invariant_factors = []
    for i in range(min(n, m)):
        d = abs(A[i, i])
        if d != 0:
            invariant_factors.append(d)
    return A, sorted(invariant_factors)


def enumerate_connected_graphs(n):
    """Enumerate connected simple graphs on n vertices (small n only)."""
    all_edges = [(i, j) for i in range(n) for j in range(i + 1, n)]
    graphs = []
    for r in range(n - 1, len(all_edges) + 1):
        for edge_set in combinations(all_edges, r):
            adj = set()
            for i, j in edge_set:
                adj.add((i, j))
                adj.add((j, i))
            # Check connectivity via BFS
            visited = {0}
            queue = [0]
            while queue:
                v = queue.pop(0)
                for u in range(n):
                    if u not in visited and (v, u) in adj:
                        visited.add(u)
                        queue.append(u)
            if len(visited) == n:
                graphs.append((edge_set, adj))
    return graphs


def nonempty_subsets(n):
    """All nonempty subsets of {0, ..., n-1}."""
    for r in range(1, n + 1):
        for S in combinations(range(n), r):
            yield set(S)


def demo_single_graph(edges, adj, n, name="Graph"):
    """Run the full demo on a single graph."""
    print(f"\n{'='*60}")
    print(f"  {name} on {n} vertices")
    print(f"  Edges: {edges}")
    print(f"{'='*60}")

    L = graph_laplacian(adj, n)
    print(f"\nGraph Laplacian L:")
    print(L)

    for S in nonempty_subsets(n):
        if len(S) < 2:
            continue  # Skip singletons (trivial)

        S_list = sorted(S)
        L_S = restricted_laplacian(L, S)
        D_S = diagonal_degree_mat(L_S)
        Omega_S = overlap_interaction_mat(L_S)
        sep = is_separated(adj, S)

        print(f"\n--- Subset S = {S_list} ---")
        print(f"  Separated: {sep}")
        print(f"  L_S = \n{L_S}")
        print(f"  D_S = \n{D_S}")
        print(f"  Omega_S = \n{Omega_S}")

        # Theorem 1: L_S = D_S + Omega_S
        assert np.array_equal(L_S, D_S + Omega_S), "Decomposition failed!"
        print(f"  ✓ L_S = D_S + Omega_S (decomposition theorem)")

        # Theorem 2: Separated <=> Omega_S = 0
        if sep:
            assert np.array_equal(Omega_S, np.zeros_like(Omega_S)), \
                "Separated but Omega_S != 0!"
            print(f"  ✓ Separated => Omega_S = 0")
        else:
            assert not np.array_equal(Omega_S, np.zeros_like(Omega_S)), \
                "Not separated but Omega_S = 0!"
            print(f"  ✓ Not separated => Omega_S ≠ 0")

        # Theorem 3: Energy decomposition
        x = np.array([(-1)**i * (i + 1) for i in range(len(S_list))], dtype=int)
        E = overlap_energy(L_S, x)
        E_self = self_energy(L_S, x)
        E_int = interaction_energy(L_S, x)
        assert E == E_self + E_int, "Energy decomposition failed!"
        print(f"  ✓ Energy({x}) = {E} = {E_self} + {E_int} (self + interaction)")
        assert E >= 0, "Energy is negative!"
        print(f"  ✓ Energy ≥ 0 (positive semidefiniteness)")

        # Theorem 4: Symmetry
        assert np.array_equal(L_S, L_S.T), "L_S not symmetric!"
        assert np.array_equal(Omega_S, Omega_S.T), "Omega_S not symmetric!"
        print(f"  ✓ L_S and Omega_S are symmetric")

        # Smith Normal Form
        D_snf, inv_factors = smith_normal_form(L_S)
        if D_snf is not None:
            print(f"  SNF invariant factors: {inv_factors}")
            if inv_factors:
                cokernel_desc = " ⊕ ".join(
                    [f"ℤ/{d}ℤ" if d > 1 else "0" for d in inv_factors]
                )
            else:
                cokernel_desc = "0"
            print(f"  Cokernel ≅ ℤ^{len(S_list)} / Im(L_S) structure: {cokernel_desc}")


def demo_comparison():
    """Compare separated vs non-separated subsets on the same graph."""
    print("\n" + "=" * 60)
    print("  COMPARISON: Separated vs Non-Separated on Same Graph")
    print("=" * 60)

    # Path graph P4: 0-1-2-3
    n = 4
    edges = [(0, 1), (1, 2), (2, 3)]
    adj = set()
    for i, j in edges:
        adj.add((i, j))
        adj.add((j, i))

    L = graph_laplacian(adj, n)
    print(f"\nPath graph P4: 0—1—2—3")
    print(f"Laplacian:\n{L}")

    # Separated subset: {0, 2} (no edge between them)
    S_sep = {0, 2}
    L_sep = restricted_laplacian(L, S_sep)
    Omega_sep = overlap_interaction_mat(L_sep)
    print(f"\nSeparated subset S = {{0, 2}}:")
    print(f"  L_S = \n{L_sep}")
    print(f"  Omega_S = \n{Omega_sep}")
    print(f"  Omega_S is zero: {np.array_equal(Omega_sep, np.zeros_like(Omega_sep))}")

    # Non-separated subset: {1, 2} (edge between them)
    S_nonsep = {1, 2}
    L_nonsep = restricted_laplacian(L, S_nonsep)
    Omega_nonsep = overlap_interaction_mat(L_nonsep)
    print(f"\nNon-separated subset S = {{1, 2}}:")
    print(f"  L_S = \n{L_nonsep}")
    print(f"  Omega_S = \n{Omega_nonsep}")
    print(f"  Omega_S is zero: {np.array_equal(Omega_nonsep, np.zeros_like(Omega_nonsep))}")

    # Same framework explains both!
    for label, L_S in [("Separated {0,2}", L_sep), ("Non-separated {1,2}", L_nonsep)]:
        x = np.array([1, -1], dtype=int)
        E = overlap_energy(L_S, x)
        E_self = self_energy(L_S, x)
        E_int = interaction_energy(L_S, x)
        print(f"\n  {label}: E={E}, E_self={E_self}, E_int={E_int}")
        _, inv = smith_normal_form(L_S)
        print(f"  SNF invariant factors: {inv}")

    print("\n  → Both cases handled by the SAME decomposition framework!")
    print("  → Separation is simply the zero-interaction special case.")


def demo_enumeration(max_n=5):
    """Enumerate graphs and check all theorems systematically."""
    print("\n" + "=" * 60)
    print(f"  SYSTEMATIC CHECK: All connected graphs, n ≤ {max_n}")
    print("=" * 60)

    total_checks = 0
    total_separated = 0
    total_nonseparated = 0

    for n in range(2, max_n + 1):
        graphs = enumerate_connected_graphs(n)
        print(f"\n  n = {n}: {len(graphs)} connected graphs")

        for edges, adj in graphs:
            L = graph_laplacian(adj, n)
            for S in nonempty_subsets(n):
                if len(S) < 2:
                    continue
                S_list = sorted(S)
                L_S = restricted_laplacian(L, S)
                D_S = diagonal_degree_mat(L_S)
                Omega_S = overlap_interaction_mat(L_S)

                # Check decomposition
                assert np.array_equal(L_S, D_S + Omega_S)

                # Check separation characterization
                sep = is_separated(adj, S)
                omega_zero = np.array_equal(Omega_S, np.zeros_like(Omega_S))
                assert sep == omega_zero, \
                    f"Separation/Omega mismatch: S={S_list}, sep={sep}, omega_zero={omega_zero}"

                # Check energy decomposition and nonnegativity
                for trial in range(3):
                    x = np.random.randint(-5, 6, size=len(S_list))
                    E = overlap_energy(L_S, x)
                    E_self = self_energy(L_S, x)
                    E_int = interaction_energy(L_S, x)
                    assert E == E_self + E_int
                    assert E >= 0, f"Negative energy! E={E}, x={x}, S={S_list}"

                # Check symmetry
                assert np.array_equal(L_S, L_S.T)
                assert np.array_equal(Omega_S, Omega_S.T)

                total_checks += 1
                if sep:
                    total_separated += 1
                else:
                    total_nonseparated += 1

    print(f"\n  Total subset checks: {total_checks}")
    print(f"  Separated: {total_separated}, Non-separated: {total_nonseparated}")
    print(f"  ALL CHECKS PASSED ✓")


if __name__ == "__main__":
    print("=" * 60)
    print("  OVERLAP SUPPORT THEORY — DEMONSTRATION")
    print("  Graph Laplacian Decomposition & Energy Analysis")
    print("=" * 60)

    # Demo 1: Specific example graphs
    # Triangle graph K3
    demo_single_graph(
        edges=[(0, 1), (1, 2), (0, 2)],
        adj={(0,1),(1,0),(1,2),(2,1),(0,2),(2,0)},
        n=3, name="Complete graph K3"
    )

    # Path graph P4
    demo_single_graph(
        edges=[(0, 1), (1, 2), (2, 3)],
        adj={(0,1),(1,0),(1,2),(2,1),(2,3),(3,2)},
        n=4, name="Path graph P4"
    )

    # Demo 2: Separated vs Non-separated comparison
    demo_comparison()

    # Demo 3: Systematic enumeration
    demo_enumeration(max_n=5)

    print("\n" + "=" * 60)
    print("  DEMO COMPLETE — All theorems verified computationally")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Energy Landscape of the Laplacian Quadratic Form

Produces a heatmap showing the overlap energy E(x) = x^T L_S x
as a function of two-component vectors x = (a, b) for different
subsets S of a graph. Demonstrates positive semidefiniteness and
how the energy landscape changes from separated to non-separated regimes.
"""

import numpy as np
import matplotlib.pyplot as plt


# ─── Self-contained infrastructure ───

def graph_laplacian(n, edges):
    adj = set()
    for u, v in edges:
        adj.add((u, v))
        adj.add((v, u))
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = sum(1 for u in range(n) if (i, u) in adj)
            elif (i, j) in adj:
                L[i, j] = -1
    return L


def restricted_lap(L, S):
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


# ─── Setup ───

# Path graph P5: 0—1—2—3—4
edges = [(0, 1), (1, 2), (2, 3), (3, 4)]
L = graph_laplacian(5, edges)

subsets = [
    ([0, 4], "S={0,4} (Separated, far apart)"),
    ([0, 2], "S={0,2} (Separated, medium)"),
    ([0, 1], "S={0,1} (Non-separated, adjacent)"),
    ([1, 2], "S={1,2} (Non-separated, central)"),
]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Overlap Energy Landscape: x^T L_S x\n'
             '(Path Graph P₅, 2-vertex subsets)', fontsize=14, fontweight='bold')

a_range = np.linspace(-3, 3, 100)
b_range = np.linspace(-3, 3, 100)
A, B = np.meshgrid(a_range, b_range)

for idx, (S, title) in enumerate(subsets):
    ax = axes[idx // 2, idx % 2]
    L_S = restricted_lap(L, S)

    # Compute energy for each (a, b)
    # E = a^2 * L_S[0,0] + 2*a*b*L_S[0,1] + b^2 * L_S[1,1]
    E = A**2 * L_S[0, 0] + 2 * A * B * L_S[0, 1] + B**2 * L_S[1, 1]

    # Plot
    levels = np.linspace(0, 30, 16)
    cs = ax.contourf(A, B, E, levels=levels, cmap='viridis')
    ax.contour(A, B, E, levels=levels, colors='white', linewidths=0.3, alpha=0.5)
    plt.colorbar(cs, ax=ax, label='Energy')

    ax.set_title(title, fontsize=10)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_aspect('equal')

    # Mark the zero-energy line if it exists
    ax.plot(0, 0, 'ro', markersize=5)

    # Add matrix annotation
    ax.text(0.02, 0.98, f'L_S = [{L_S[0,0]}, {L_S[0,1]}; {L_S[1,0]}, {L_S[1,1]}]',
            transform=ax.transAxes, fontsize=8, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Overlap Interaction Matrices and Energy Landscapes

Produces a 2x2 figure showing:
1. Top-left: Interaction matrix heatmap for a separated subset
2. Top-right: Interaction matrix heatmap for a non-separated subset
3. Bottom-left: Energy decomposition bar chart
4. Bottom-right: SNF invariant factor comparison

Demonstrates visually that separation = zero interaction,
while non-separated subsets have rich off-diagonal structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ─── Self-contained graph infrastructure ───

def graph_laplacian(n, edges):
    adj = set()
    for u, v in edges:
        adj.add((u, v))
        adj.add((v, u))
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = sum(1 for u in range(n) if (i, u) in adj)
            elif (i, j) in adj:
                L[i, j] = -1
    return L, adj


def restricted_lap(L, S):
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


def interaction_mat(L_S):
    return L_S - np.diag(np.diag(L_S))


def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if (S[i], S[j]) in adj:
                return False
    return True


def snf_factors(M):
    A = M.copy().astype(int)
    n, m = A.shape
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    A[[k, i]] = A[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        changed = True
        while changed:
            changed = False
            if A[k, k] < 0:
                A[k] = -A[k]
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        changed = True
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        changed = True
    return sorted([abs(int(A[i, i])) for i in range(min(n, m)) if A[i, i] != 0])


# ─── Build the figure ───

# Graph: Complete graph K5
n = 5
edges_K5 = [(i, j) for i in range(5) for j in range(i+1, 5)]
L_K5, adj_K5 = graph_laplacian(n, edges_K5)

# Separated subset: {0, 2} in path graph P5
edges_P5 = [(0, 1), (1, 2), (2, 3), (3, 4)]
L_P5, adj_P5 = graph_laplacian(5, edges_P5)

# Choose subsets
S_sep = [0, 2, 4]  # Separated in P5
S_nonsep = [0, 1, 2]  # Non-separated in P5 (edges 0-1, 1-2)

L_sep = restricted_lap(L_P5, S_sep)
L_nonsep = restricted_lap(L_P5, S_nonsep)
Omega_sep = interaction_mat(L_sep)
Omega_nonsep = interaction_mat(L_nonsep)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Overlap Support Theory: Separated vs Non-Separated Subsets\n'
             '(Path Graph P₅: 0—1—2—3—4)', fontsize=14, fontweight='bold')

# Top-left: Separated interaction matrix
ax1 = axes[0, 0]
im1 = ax1.imshow(Omega_sep, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax1.set_title(f'Interaction Ω_S\nS = {{{", ".join(map(str, S_sep))}}} (Separated)', fontsize=11)
ax1.set_xlabel('Vertex index in S')
ax1.set_ylabel('Vertex index in S')
for i in range(len(S_sep)):
    for j in range(len(S_sep)):
        ax1.text(j, i, str(Omega_sep[i, j]), ha='center', va='center', fontsize=14,
                color='black' if abs(Omega_sep[i, j]) < 0.5 else 'white')
plt.colorbar(im1, ax=ax1, shrink=0.8)

# Top-right: Non-separated interaction matrix
ax2 = axes[0, 1]
im2 = ax2.imshow(Omega_nonsep, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax2.set_title(f'Interaction Ω_S\nS = {{{", ".join(map(str, S_nonsep))}}} (Non-Separated)', fontsize=11)
ax2.set_xlabel('Vertex index in S')
ax2.set_ylabel('Vertex index in S')
for i in range(len(S_nonsep)):
    for j in range(len(S_nonsep)):
        ax2.text(j, i, str(Omega_nonsep[i, j]), ha='center', va='center', fontsize=14,
                color='black' if abs(Omega_nonsep[i, j]) < 0.5 else 'white')
plt.colorbar(im2, ax=ax2, shrink=0.8)

# Bottom-left: Energy decomposition comparison
ax3 = axes[1, 0]
x_test = np.array([1, -1, 1], dtype=int)
energies = []
for label, L_S in [('Separated', L_sep), ('Non-Sep', L_nonsep)]:
    E = int(x_test @ L_S @ x_test)
    D = np.diag(np.diag(L_S))
    Omega = L_S - D
    E_self = int(x_test @ D @ x_test)
    E_int = int(x_test @ Omega @ x_test)
    energies.append((label, E, E_self, E_int))

x_pos = np.arange(2)
width = 0.25
bars1 = ax3.bar(x_pos - width, [e[2] for e in energies], width, label='Self-energy', color='#2196F3')
bars2 = ax3.bar(x_pos, [e[3] for e in energies], width, label='Interaction', color='#FF5722')
bars3 = ax3.bar(x_pos + width, [e[1] for e in energies], width, label='Total', color='#4CAF50')
ax3.set_xticks(x_pos)
ax3.set_xticklabels([e[0] for e in energies])
ax3.set_ylabel('Energy')
ax3.set_title('Energy Decomposition\n(test vector x = [1, -1, 1])', fontsize=11)
ax3.legend()
ax3.axhline(y=0, color='black', linewidth=0.5)

# Bottom-right: SNF invariant factors
ax4 = axes[1, 1]
factors_sep = snf_factors(L_sep)
factors_nonsep = snf_factors(L_nonsep)

# Pad to same length
max_len = max(len(factors_sep), len(factors_nonsep))
f_sep = factors_sep + [0] * (max_len - len(factors_sep))
f_nonsep = factors_nonsep + [0] * (max_len - len(factors_nonsep))

x_pos2 = np.arange(max_len)
width2 = 0.35
ax4.bar(x_pos2 - width2/2, f_sep, width2, label='Separated', color='#2196F3', alpha=0.8)
ax4.bar(x_pos2 + width2/2, f_nonsep, width2, label='Non-Separated', color='#FF5722', alpha=0.8)
ax4.set_xlabel('Factor index')
ax4.set_ylabel('Invariant factor value')
ax4.set_title('Smith Normal Form\nInvariant Factors', fontsize=11)
ax4.legend()
ax4.set_xticks(x_pos2)

plt.tight_layout()
plt.savefig('overlap_visualization.png', dpi=150, bbox_inches='tight')
print("Saved overlap_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Smith Normal Form Invariant Factors Across All Subsets

For a fixed graph, computes the SNF invariant factors of the restricted
Laplacian for every nonempty subset S, and displays how the algebraic
structure (cokernel type) varies with subset choice and separation status.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ─── Self-contained infrastructure ───

def graph_laplacian(n, edges):
    adj = set()
    for u, v in edges:
        adj.add((u, v))
        adj.add((v, u))
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            if i == j:
                L[i, j] = sum(1 for u in range(n) if (i, u) in adj)
            elif (i, j) in adj:
                L[i, j] = -1
    return L, adj


def restricted_lap(L, S):
    k = len(S)
    return np.array([[L[S[a], S[b]] for b in range(k)] for a in range(k)], dtype=int)


def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if (S[i], S[j]) in adj:
                return False
    return True


def snf_factors(M):
    A = M.copy().astype(int)
    n, m = A.shape
    for k in range(min(n, m)):
        found = False
        for i in range(k, n):
            for j in range(k, m):
                if A[i, j] != 0:
                    A[[k, i]] = A[[i, k]]
                    A[:, [k, j]] = A[:, [j, k]]
                    found = True
                    break
            if found:
                break
        if not found:
            break
        changed = True
        while changed:
            changed = False
            if A[k, k] < 0:
                A[k] = -A[k]
            for j in range(k + 1, m):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        A[:, [k, j]] = A[:, [j, k]]
                        changed = True
            for i in range(k + 1, n):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i] -= q * A[k]
                    if A[i, k] != 0:
                        A[[k, i]] = A[[i, k]]
                        changed = True
    return sorted([abs(int(A[i, i])) for i in range(min(n, m)) if A[i, i] != 0])


# ─── Build the figure ───

# Cycle graph C6
n = 6
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0)]
L, adj = graph_laplacian(n, edges)

# Collect data for all subsets of size ≥ 2
data_sep = []  # (subset_str, max_factor)
data_nonsep = []

all_subsets = []
for r in range(2, n + 1):
    for S in combinations(range(n), r):
        S = list(S)
        L_S = restricted_lap(L, S)
        factors = snf_factors(L_S)
        sep = is_separated(adj, S)
        max_f = max(factors) if factors else 0
        det = int(np.prod(factors)) if factors else 0
        entry = {
            'S': S,
            'factors': factors,
            'max_factor': max_f,
            'det': det,
            'sep': sep,
            'size': len(S),
        }
        all_subsets.append(entry)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('SNF Structure Across Subsets of Cycle Graph C₆\n'
             '(Blue = Separated, Red = Non-Separated)', fontsize=13, fontweight='bold')

# Plot 1: Max invariant factor vs subset size
ax1 = axes[0]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    ax1.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               entry['max_factor'],
               c=color, marker=marker, alpha=0.6, s=40)
ax1.set_xlabel('Subset size |S|')
ax1.set_ylabel('Max invariant factor')
ax1.set_title('Largest Invariant Factor')
# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3', markersize=8, label='Separated'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#FF5722', markersize=8, label='Non-separated'),
]
ax1.legend(handles=legend_elements)

# Plot 2: Determinant (product of factors) vs subset size
ax2 = axes[1]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    ax2.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               entry['det'],
               c=color, marker=marker, alpha=0.6, s=40)
ax2.set_xlabel('Subset size |S|')
ax2.set_ylabel('det(L_S) = ∏ factors')
ax2.set_title('Determinant of L_S')
ax2.legend(handles=legend_elements)

# Plot 3: Number of distinct invariant factors > 1
ax3 = axes[2]
for entry in all_subsets:
    color = '#2196F3' if entry['sep'] else '#FF5722'
    marker = 'o' if entry['sep'] else 's'
    nontrivial = sum(1 for f in entry['factors'] if f > 1)
    ax3.scatter(entry['size'] + np.random.uniform(-0.15, 0.15),
               nontrivial,
               c=color, marker=marker, alpha=0.6, s=40)
ax3.set_xlabel('Subset size |S|')
ax3.set_ylabel('# nontrivial factors (> 1)')
ax3.set_title('Torsion Rank')
ax3.legend(handles=legend_elements)

plt.tight_layout()
plt.savefig('snf_analysis.png', dpi=150, bbox_inches='tight')
print("Saved snf_analysis.png")
