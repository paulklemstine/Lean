"""
Algorithms for Manifold Detection via Persistent Homology

Implements the key algorithms from the Poincaré Threshold theory:
1. Vietoris-Rips graph construction
2. Connectivity threshold computation (via MST)
3. Betti number estimation via boundary matrices
4. Poincaré threshold detection
"""

from typing import List, Tuple, Dict, Set, Optional
import numpy as np
from itertools import combinations


def pairwise_distances(points: np.ndarray) -> np.ndarray:
    """Compute pairwise Euclidean distance matrix.

    Args:
        points: (n, d) array of n points in R^d

    Returns:
        (n, n) symmetric distance matrix
    """
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def rips_graph(dist_matrix: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """Construct the 1-skeleton of the Vietoris-Rips complex at scale epsilon.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: scale parameter

    Returns:
        List of edges (i, j) with i < j and d(i,j) <= epsilon
    """
    n = dist_matrix.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if dist_matrix[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def connected_components(n: int, edges: List[Tuple[int, int]]) -> List[Set[int]]:
    """Find connected components using union-find.

    Args:
        n: number of vertices
        edges: list of edges

    Returns:
        List of connected components (sets of vertex indices)
    """
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        px, py = find(x), find(y)
        if px == py:
            return
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1

    for i, j in edges:
        union(i, j)

    components: Dict[int, Set[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in components:
            components[root] = set()
        components[root].add(i)

    return list(components.values())


def connectivity_threshold(dist_matrix: np.ndarray) -> float:
    """Compute the connectivity threshold via Kruskal's MST algorithm.

    The connectivity threshold is the maximum edge weight in the minimum
    spanning tree — the smallest epsilon at which the Rips graph is connected.

    Args:
        dist_matrix: (n, n) pairwise distance matrix

    Returns:
        The connectivity threshold epsilon_0
    """
    n = dist_matrix.shape[0]
    if n <= 1:
        return 0.0

    # Extract all edges and sort by weight
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()

    # Kruskal's algorithm
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        px, py = find(x), find(y)
        if px == py:
            return False
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1
        return True

    max_edge = 0.0
    edges_added = 0
    for w, i, j in edges:
        if union(i, j):
            max_edge = w
            edges_added += 1
            if edges_added == n - 1:
                break

    return max_edge


def rips_simplices(dist_matrix: np.ndarray, epsilon: float,
                   max_dim: int = 2) -> Dict[int, List[Tuple[int, ...]]]:
    """Enumerate all simplices of the Rips complex up to dimension max_dim.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: scale parameter
        max_dim: maximum simplex dimension to enumerate

    Returns:
        Dictionary mapping dimension k to list of (k+1)-tuples of vertex indices
    """
    n = dist_matrix.shape[0]
    simplices: Dict[int, List[Tuple[int, ...]]] = {}

    # 0-simplices: all vertices
    simplices[0] = [(i,) for i in range(n)]

    # Higher simplices: check if all pairwise distances <= epsilon
    for dim in range(1, max_dim + 1):
        simplices[dim] = []
        for combo in combinations(range(n), dim + 1):
            is_simplex = True
            for a, b in combinations(combo, 2):
                if dist_matrix[a, b] > epsilon:
                    is_simplex = False
                    break
            if is_simplex:
                simplices[dim].append(combo)

    return simplices


def betti_numbers_from_simplices(
    simplices: Dict[int, List[Tuple[int, ...]]],
    max_dim: int = 2
) -> List[int]:
    """Compute Betti numbers from the simplex list using boundary matrices.

    Uses the rank-nullity theorem: β_k = dim(ker ∂_k) - dim(im ∂_{k+1})

    Args:
        simplices: dictionary from rips_simplices
        max_dim: maximum dimension to compute

    Returns:
        List of Betti numbers [β_0, β_1, ..., β_{max_dim}]
    """
    betti = []

    for k in range(max_dim + 1):
        if k not in simplices or len(simplices[k]) == 0:
            betti.append(0)
            continue

        # Compute rank of ∂_k (boundary from k to k-1)
        if k == 0:
            rank_dk = 0
        else:
            boundary_k = _boundary_matrix(simplices, k)
            rank_dk = int(np.linalg.matrix_rank(boundary_k))

        # Compute rank of ∂_{k+1} (boundary from k+1 to k)
        if k + 1 not in simplices or len(simplices[k + 1]) == 0:
            rank_dk1 = 0
        else:
            boundary_k1 = _boundary_matrix(simplices, k + 1)
            rank_dk1 = int(np.linalg.matrix_rank(boundary_k1))

        nullity_k = len(simplices[k]) - rank_dk
        beta_k = nullity_k - rank_dk1
        betti.append(max(0, beta_k))

    return betti


def _boundary_matrix(simplices: Dict[int, List[Tuple[int, ...]]],
                     k: int) -> np.ndarray:
    """Compute the k-th boundary matrix ∂_k : C_k → C_{k-1}.

    Args:
        simplices: dictionary of simplices by dimension
        k: dimension (must be >= 1)

    Returns:
        Matrix of shape (num_{k-1}-simplices, num_k-simplices)
    """
    k_simplices = simplices[k]
    km1_simplices = simplices[k - 1]

    # Create index lookup for (k-1)-simplices
    idx_map = {s: i for i, s in enumerate(km1_simplices)}

    matrix = np.zeros((len(km1_simplices), len(k_simplices)), dtype=float)

    for j, simplex in enumerate(k_simplices):
        for face_idx in range(len(simplex)):
            face = tuple(v for i, v in enumerate(simplex) if i != face_idx)
            if face in idx_map:
                sign = (-1) ** face_idx
                matrix[idx_map[face], j] = sign

    return matrix


def poincare_threshold(points: np.ndarray, target_dim: int,
                       num_scales: int = 100) -> Optional[float]:
    """Compute the Poincaré threshold: smallest epsilon where Betti numbers
    match those of S^{target_dim}.

    Target Betti signature for S^d: β_0 = 1, β_d = 1, all others 0.

    Args:
        points: (n, d) array of points
        target_dim: dimension of target sphere
        num_scales: number of epsilon values to test

    Returns:
        The Poincaré threshold, or None if not found
    """
    dist_matrix = pairwise_distances(points)
    max_dist = np.max(dist_matrix)

    epsilons = np.linspace(0.01, max_dist, num_scales)

    target_betti = [0] * (target_dim + 1)
    target_betti[0] = 1
    target_betti[target_dim] = 1

    for eps in epsilons:
        simplices = rips_simplices(dist_matrix, eps, max_dim=target_dim)
        betti = betti_numbers_from_simplices(simplices, max_dim=target_dim)

        if betti == target_betti:
            return float(eps)

    return None


def sphere_betti(dim: int) -> List[int]:
    """Return the Betti signature of S^dim.

    Args:
        dim: dimension of the sphere

    Returns:
        List [β_0, β_1, ..., β_dim] where β_0 = β_dim = 1, others 0
    """
    betti = [0] * (dim + 1)
    betti[0] = 1
    betti[dim] = 1
    return betti


def euler_characteristic(betti: List[int]) -> int:
    """Compute the Euler characteristic from Betti numbers.

    χ = Σ (-1)^k β_k

    Args:
        betti: list of Betti numbers

    Returns:
        Euler characteristic
    """
    return sum((-1) ** k * b for k, b in enumerate(betti))


def theoretical_poincare_threshold(n: int, d: int, C: float = 1.0) -> float:
    """Compute the theoretical Poincaré threshold prediction.

    Conjectured scaling: ε* = C · d^{1/2} · n^{-1/d}

    Args:
        n: number of points
        d: dimension
        C: constant (default 1.0)

    Returns:
        Predicted Poincaré threshold
    """
    return C * np.sqrt(d) * n ** (-1.0 / d)


def sample_sphere(n: int, d: int, seed: int = 42) -> np.ndarray:
    """Sample n points uniformly from the unit d-sphere S^d in R^{d+1}.

    Uses Gaussian projection method.

    Args:
        n: number of points
        d: dimension of sphere (embedded in R^{d+1})
        seed: random seed

    Returns:
        (n, d+1) array of points on S^d
    """
    rng = np.random.default_rng(seed)
    points = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms
