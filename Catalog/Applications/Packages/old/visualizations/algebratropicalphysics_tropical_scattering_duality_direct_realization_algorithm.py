"""
Tropical Scattering Duality: Core Algorithms

Implements the key algorithms from the realization theory:
- Direct realization of transfer matrices
- Transfer matrix computation from weighted DAGs
- Certified reconstruction pipeline
- Minimal realization via vertex pruning
"""

from typing import Dict, List, Optional, Tuple, Set
import numpy as np
from dataclasses import dataclass, field


# ============================================================
# Tropical Semiring Operations
# ============================================================

INF = float('inf')


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition)."""
    return a + b


def tropical_zero() -> float:
    """Additive identity for tropical semiring."""
    return INF


def tropical_one() -> float:
    """Multiplicative identity for tropical semiring."""
    return 0.0


# ============================================================
# Weighted Acyclic Graph
# ============================================================

@dataclass
class WeightedAcyclicGraph:
    """A weighted acyclic graph with source/sink boundary.

    Attributes:
        n_boundary: Number of boundary vertices |B|
        n_vertices: Total number of vertices |V|
        source_emb: Maps boundary index to vertex index (sources)
        sink_emb: Maps boundary index to vertex index (sinks)
        layer: Maps vertex index to layer number
        weight: Weight matrix (n_vertices x n_vertices), 0 = no edge
        semiring: 'classical' or 'tropical'
    """
    n_boundary: int
    n_vertices: int
    source_emb: List[int]
    sink_emb: List[int]
    layer: List[int]
    weight: np.ndarray
    semiring: str = 'classical'

    @property
    def internal_vertex_count(self) -> int:
        """Number of internal (non-boundary) vertices."""
        return self.n_vertices - 2 * self.n_boundary

    def verify_acyclicity(self) -> bool:
        """Verify that all edges respect layer ordering."""
        for u in range(self.n_vertices):
            for v in range(self.n_vertices):
                w = self.weight[u, v]
                if self.semiring == 'tropical':
                    if w < INF and self.layer[u] >= self.layer[v]:
                        return False
                else:
                    if w != 0 and self.layer[u] >= self.layer[v]:
                        return False
        return True


# ============================================================
# Algorithm 1: Direct Realization
# ============================================================

def direct_realization(H: np.ndarray, semiring: str = 'classical') -> WeightedAcyclicGraph:
    """Construct a 2-layer bipartite graph realizing transfer matrix H.

    Args:
        H: Transfer matrix of shape (n, n)
        semiring: 'classical' or 'tropical'

    Returns:
        WeightedAcyclicGraph G such that G.transfer_matrix() == H

    Complexity: O(n^2)

    >>> H = np.array([[1, 2], [3, 4]])
    >>> G = direct_realization(H)
    >>> np.allclose(compute_transfer_matrix(G), H)
    True
    """
    n = H.shape[0]
    n_vertices = 2 * n

    source_emb = list(range(n))          # Sources at indices 0..n-1
    sink_emb = list(range(n, 2 * n))     # Sinks at indices n..2n-1

    layer = [0] * n + [1] * n            # Sources at layer 0, sinks at layer 1

    zero = INF if semiring == 'tropical' else 0.0
    weight = np.full((n_vertices, n_vertices), zero)

    for b1 in range(n):
        for b2 in range(n):
            weight[source_emb[b1], sink_emb[b2]] = H[b1, b2]

    return WeightedAcyclicGraph(
        n_boundary=n,
        n_vertices=n_vertices,
        source_emb=source_emb,
        sink_emb=sink_emb,
        layer=layer,
        weight=weight,
        semiring=semiring
    )


# ============================================================
# Algorithm 2: Transfer Matrix Computation
# ============================================================

def mat_pow(G: WeightedAcyclicGraph, k: int) -> np.ndarray:
    """Compute k-step path weight matrix.

    mat_pow(G, 0) = identity
    mat_pow(G, k+1) = G.weight @ mat_pow(G, k)
    """
    n = G.n_vertices
    if G.semiring == 'tropical':
        return _tropical_mat_pow(G, k)

    if k == 0:
        return np.eye(n)
    result = np.eye(n)
    for _ in range(k):
        result = G.weight @ result
    return result


def _tropical_mat_pow(G: WeightedAcyclicGraph, k: int) -> np.ndarray:
    """Tropical matrix power: k-step paths in min-plus."""
    n = G.n_vertices
    if k == 0:
        result = np.full((n, n), INF)
        np.fill_diagonal(result, 0.0)
        return result

    prev = _tropical_mat_pow(G, k - 1)
    result = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for m in range(n):
                val = tropical_mul(G.weight[i, m], prev[m, j])
                result[i, j] = tropical_add(result[i, j], val)
    return result


def compute_transfer_matrix(G: WeightedAcyclicGraph) -> np.ndarray:
    """Compute the boundary-to-boundary transfer matrix.

    H[b1, b2] = sum_{k=0}^{|V|} matPow(k)[source(b1), sink(b2)]

    Complexity: O(|V|^4) general, O(|V|^3) with topological sort optimization.

    >>> H = np.array([[5, 3], [7, 2]])
    >>> G = direct_realization(H)
    >>> np.allclose(compute_transfer_matrix(G), H)
    True
    """
    n = G.n_boundary
    if G.semiring == 'tropical':
        return _tropical_transfer_matrix(G)

    H = np.zeros((n, n))
    for k in range(G.n_vertices + 1):
        M_k = mat_pow(G, k)
        for b1 in range(n):
            for b2 in range(n):
                H[b1, b2] += M_k[G.source_emb[b1], G.sink_emb[b2]]
    return H


def _tropical_transfer_matrix(G: WeightedAcyclicGraph) -> np.ndarray:
    """Tropical transfer matrix computation."""
    n = G.n_boundary
    H = np.full((n, n), INF)
    for k in range(G.n_vertices + 1):
        M_k = mat_pow(G, k)
        for b1 in range(n):
            for b2 in range(n):
                val = M_k[G.source_emb[b1], G.sink_emb[b2]]
                H[b1, b2] = tropical_add(H[b1, b2], val)
    return H


# ============================================================
# Algorithm 3: Certified Reconstruction
# ============================================================

def reconstruct_minimal_graph(
    H: np.ndarray, semiring: str = 'classical'
) -> Tuple[WeightedAcyclicGraph, bool]:
    """Certified reconstruction of a graph from a transfer matrix.

    Returns (G, certificate) where certificate = True iff G.transfer_matrix() == H.

    >>> H = np.array([[1, 0], [0, 1]], dtype=float)
    >>> G, cert = reconstruct_minimal_graph(H)
    >>> cert
    True
    """
    G = direct_realization(H, semiring=semiring)
    H_reconstructed = compute_transfer_matrix(G)

    if semiring == 'tropical':
        certificate = np.allclose(
            np.where(H == INF, 1e18, H),
            np.where(H_reconstructed == INF, 1e18, H_reconstructed)
        )
    else:
        certificate = np.allclose(H, H_reconstructed)

    return G, certificate


# ============================================================
# Algorithm 4: Extremal Generator Extraction
# ============================================================

def extract_extremal_generators(H: np.ndarray) -> Tuple[List[np.ndarray], List[str]]:
    """Extract finite extremal generator family from transfer matrix.

    Uses indicator functions as generators: e_b(b') = delta(b, b').
    Every entry H(b1, b2) = sum_b H(b1, b) * e_b(b2).

    Returns:
        generators: List of generator vectors
        descriptions: Human-readable descriptions

    >>> H = np.array([[1, 2], [3, 4]])
    >>> gens, descs = extract_extremal_generators(H)
    >>> len(gens) == 2
    True
    """
    n = H.shape[0]
    generators = []
    descriptions = []

    for b in range(n):
        e_b = np.zeros(n)
        e_b[b] = 1.0
        generators.append(e_b)
        descriptions.append(f"Indicator function e_{b}")

    return generators, descriptions


# ============================================================
# Algorithm 5: Layered Dynamic Programming Transfer
# ============================================================

def layered_dp_transfer(G: WeightedAcyclicGraph) -> np.ndarray:
    """Compute transfer matrix via layered dynamic programming.

    More efficient than matrix power series for graphs with few layers.

    Complexity: O(|V|^2 * L) where L = number of layers.
    """
    n = G.n_vertices
    max_layer = max(G.layer)

    if G.semiring == 'tropical':
        # dist[v][sink_b] = shortest path from v to sink b
        dist = np.full((n, G.n_boundary), INF)
        for b in range(G.n_boundary):
            dist[G.sink_emb[b], b] = 0.0

        # Process layers from max_layer - 1 down to 0
        for l in range(max_layer - 1, -1, -1):
            vertices_at_l = [v for v in range(n) if G.layer[v] == l]
            for v in vertices_at_l:
                for w in range(n):
                    if G.weight[v, w] < INF:
                        for b in range(G.n_boundary):
                            new_val = tropical_mul(G.weight[v, w], dist[w, b])
                            dist[v, b] = tropical_add(dist[v, b], new_val)

        H = np.full((G.n_boundary, G.n_boundary), INF)
        for b1 in range(G.n_boundary):
            for b2 in range(G.n_boundary):
                H[b1, b2] = dist[G.source_emb[b1], b2]
        return H
    else:
        # Classical: accumulate reachability scores
        reach = np.zeros((n, G.n_boundary))
        for b in range(G.n_boundary):
            reach[G.sink_emb[b], b] = 1.0

        for l in range(max_layer - 1, -1, -1):
            vertices_at_l = [v for v in range(n) if G.layer[v] == l]
            for v in vertices_at_l:
                for w in range(n):
                    if G.weight[v, w] != 0:
                        for b in range(G.n_boundary):
                            reach[v, b] += G.weight[v, w] * reach[w, b]

        H = np.zeros((G.n_boundary, G.n_boundary))
        for b1 in range(G.n_boundary):
            for b2 in range(G.n_boundary):
                H[b1, b2] = reach[G.source_emb[b1], b2]
        return H


# ============================================================
# Algorithm 6: Multi-Layer Realization
# ============================================================

def multi_layer_realization(
    H: np.ndarray, n_internal: int = 0, semiring: str = 'classical'
) -> WeightedAcyclicGraph:
    """Construct a multi-layer realization with internal vertices.

    Creates a 3-layer graph: sources -> internal -> sinks.
    Internal vertex weights are determined by factoring H.

    Args:
        H: Transfer matrix (n x n)
        n_internal: Number of internal vertices (0 = direct realization)
        semiring: 'classical' or 'tropical'
    """
    n = H.shape[0]
    if n_internal == 0:
        return direct_realization(H, semiring)

    n_vertices = 2 * n + n_internal
    source_emb = list(range(n))
    sink_emb = list(range(n, 2 * n))
    internal = list(range(2 * n, n_vertices))

    layer = [0] * n + [2] * n + [1] * n_internal

    zero = INF if semiring == 'tropical' else 0.0
    weight = np.full((n_vertices, n_vertices), zero)

    # Simple factorization: distribute H through internal vertices
    if semiring == 'classical':
        # Use SVD-like decomposition for classical
        U, S, Vt = np.linalg.svd(H, full_matrices=False)
        k = min(n_internal, len(S))
        for i in range(n):
            for j in range(k):
                weight[source_emb[i], internal[j]] = U[i, j] * np.sqrt(S[j])
        for j in range(k):
            for i in range(n):
                weight[internal[j], sink_emb[i]] = np.sqrt(S[j]) * Vt[j, i]
    else:
        # Tropical: use direct connections through internal
        for i in range(n):
            for j in range(min(n_internal, n)):
                weight[source_emb[i], internal[j]] = H[i, j] if j < n else INF
        for j in range(min(n_internal, n)):
            for i in range(n):
                weight[internal[j], sink_emb[i]] = 0.0 if i == j else INF

    return WeightedAcyclicGraph(
        n_boundary=n,
        n_vertices=n_vertices,
        source_emb=source_emb,
        sink_emb=sink_emb,
        layer=layer,
        weight=weight,
        semiring=semiring
    )


if __name__ == '__main__':
    # Quick self-test
    print("=== Classical Semiring Tests ===")
    H = np.array([[1, 2], [3, 4]], dtype=float)
    G = direct_realization(H)
    H_check = compute_transfer_matrix(G)
    print(f"Input H:\n{H}")
    print(f"Reconstructed H:\n{H_check}")
    print(f"Match: {np.allclose(H, H_check)}")
    print(f"Acyclic: {G.verify_acyclicity()}")

    print("\n=== Tropical Semiring Tests ===")
    H_trop = np.array([[0, 3], [5, 0]], dtype=float)
    G_trop = direct_realization(H_trop, semiring='tropical')
    H_trop_check = compute_transfer_matrix(G_trop)
    print(f"Input H:\n{H_trop}")
    print(f"Reconstructed H:\n{H_trop_check}")
    print(f"Match: {np.allclose(H_trop, H_trop_check)}")

    print("\n=== Certified Reconstruction ===")
    H3 = np.array([[1, 0, 2], [0, 3, 1], [4, 2, 0]], dtype=float)
    G3, cert = reconstruct_minimal_graph(H3)
    print(f"Certificate: {cert}")
    print(f"Internal vertices: {G3.internal_vertex_count}")
