"""
Poincaré Threshold: Core Algorithms

Implements the key algorithms from the Poincaré threshold theory:
- Rips complex construction
- Betti number computation via boundary matrices
- Poincaré threshold search
- Covering/packing number estimation
"""

from typing import List, Tuple, Dict, Optional, Set, FrozenSet
import numpy as np
from itertools import combinations
from collections import defaultdict


def distance_matrix(points: np.ndarray) -> np.ndarray:
    """Compute the pairwise distance matrix for a set of points.

    Args:
        points: Array of shape (n, d) representing n points in R^d.

    Returns:
        Symmetric matrix D of shape (n, n) where D[i,j] = ||x_i - x_j||.
    """
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def rips_edges(dist_mat: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """Return all Rips edges at scale epsilon.

    Args:
        dist_mat: Pairwise distance matrix.
        epsilon: Scale parameter.

    Returns:
        List of (i, j) pairs with i < j and d(i,j) <= epsilon.
    """
    n = dist_mat.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if dist_mat[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def rips_simplices(dist_mat: np.ndarray, epsilon: float, max_dim: int = 2) -> Dict[int, List[Tuple[int, ...]]]:
    """Compute the Rips complex at scale epsilon up to dimension max_dim.

    Args:
        dist_mat: Pairwise distance matrix.
        epsilon: Scale parameter.
        max_dim: Maximum simplex dimension to compute.

    Returns:
        Dictionary mapping dimension k to list of k-simplices (as sorted tuples of vertex indices).
    """
    n = dist_mat.shape[0]
    simplices: Dict[int, List[Tuple[int, ...]]] = {0: [(i,) for i in range(n)]}

    # Build edge set
    edges = rips_edges(dist_mat, epsilon)
    if max_dim >= 1:
        simplices[1] = edges

    # Build higher simplices by clique enumeration
    for dim in range(2, max_dim + 1):
        if dim - 1 not in simplices:
            break
        prev = simplices[dim - 1]
        # Build adjacency for fast lookup
        adj: Set[FrozenSet[int]] = {frozenset(e) for e in edges}
        new_simplices = []
        for simplex in prev:
            # Try extending with each vertex > max(simplex)
            max_v = max(simplex)
            for v in range(max_v + 1, n):
                # Check if v is adjacent to all vertices in simplex
                if all(frozenset({u, v}) in adj for u in simplex):
                    # Check all pairwise distances
                    new_simp = tuple(sorted(simplex + (v,)))
                    if all(dist_mat[new_simp[a], new_simp[b]] <= epsilon
                           for a in range(len(new_simp))
                           for b in range(a + 1, len(new_simp))):
                        new_simplices.append(new_simp)
        if new_simplices:
            simplices[dim] = new_simplices

    return simplices


def boundary_matrix_mod2(simplices_k: List[Tuple[int, ...]], simplices_k_minus_1: List[Tuple[int, ...]]) -> np.ndarray:
    """Compute the boundary matrix over Z/2Z.

    Args:
        simplices_k: List of k-simplices.
        simplices_k_minus_1: List of (k-1)-simplices.

    Returns:
        Binary matrix B where B[i,j] = 1 iff simplices_k_minus_1[i] is a face of simplices_k[j].
    """
    face_to_idx = {s: i for i, s in enumerate(simplices_k_minus_1)}
    m = len(simplices_k_minus_1)
    n_cols = len(simplices_k)
    B = np.zeros((m, n_cols), dtype=int)

    for j, sigma in enumerate(simplices_k):
        for omit in range(len(sigma)):
            face = sigma[:omit] + sigma[omit + 1:]
            if face in face_to_idx:
                B[face_to_idx[face], j] = 1

    return B % 2


def rank_mod2(matrix: np.ndarray) -> int:
    """Compute the rank of a matrix over Z/2Z using Gaussian elimination.

    Args:
        matrix: Binary matrix.

    Returns:
        Rank over Z/2.
    """
    if matrix.size == 0:
        return 0
    M = matrix.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = -1
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot == -1:
            continue
        # Swap
        M[[rank, pivot]] = M[[pivot, rank]]
        # Eliminate
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


def betti_numbers(simplices: Dict[int, List[Tuple[int, ...]]], max_dim: int = 2) -> List[int]:
    """Compute Betti numbers β_0, β_1, ..., β_{max_dim} from a simplicial complex.

    Uses the formula β_k = dim(ker(∂_k)) - dim(im(∂_{k+1})) = (n_k - rank(∂_k)) - rank(∂_{k+1})

    Args:
        simplices: Dictionary of simplices by dimension.
        max_dim: Maximum Betti number to compute.

    Returns:
        List [β_0, β_1, ..., β_{max_dim}].
    """
    betti = []
    for k in range(max_dim + 1):
        n_k = len(simplices.get(k, []))

        # Rank of ∂_k
        if k == 0 or k - 1 not in simplices or k not in simplices:
            rank_dk = 0
        else:
            B_k = boundary_matrix_mod2(simplices[k], simplices[k - 1])
            rank_dk = rank_mod2(B_k)

        # Rank of ∂_{k+1}
        if k + 1 not in simplices or k not in simplices:
            rank_dk1 = 0
        else:
            B_k1 = boundary_matrix_mod2(simplices[k + 1], simplices[k])
            rank_dk1 = rank_mod2(B_k1)

        beta_k = n_k - rank_dk - rank_dk1
        betti.append(max(0, beta_k))
    return betti


def sphere_signature(n: int) -> List[int]:
    """Return the Betti signature of the n-sphere.

    Args:
        n: Dimension of the sphere.

    Returns:
        List of Betti numbers [β_0, β_1, ..., β_n].
    """
    sig = [0] * (n + 1)
    sig[0] = 1
    sig[n] = 1
    return sig


def poincare_threshold(points: np.ndarray, target_signature: List[int],
                       num_scales: int = 100) -> Optional[float]:
    """Compute the Poincaré threshold for a target Betti signature.

    Args:
        points: Array of shape (n, d).
        target_signature: Target Betti numbers [β_0, ..., β_k].
        num_scales: Number of scale values to test.

    Returns:
        The approximate Poincaré threshold, or None if not found.
    """
    D = distance_matrix(points)
    max_dim = len(target_signature) - 1

    # Get all unique pairwise distances as candidate scales
    upper_tri = D[np.triu_indices_from(D, k=1)]
    scales = np.sort(np.unique(upper_tri))

    if len(scales) > num_scales:
        scales = np.linspace(scales[0], scales[-1], num_scales)

    for eps in scales:
        simps = rips_simplices(D, eps, max_dim=max_dim)
        betti = betti_numbers(simps, max_dim=max_dim)
        if betti == target_signature:
            return float(eps)

    return None


def connectivity_threshold(points: np.ndarray) -> float:
    """Compute the connectivity threshold using minimum spanning tree.

    The connectivity threshold equals the maximum edge weight in the MST.

    Args:
        points: Array of shape (n, d).

    Returns:
        The connectivity threshold.
    """
    D = distance_matrix(points)
    n = D.shape[0]

    # Kruskal's algorithm
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((D[i, j], i, j))
    edges.sort()

    # Union-Find
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        px, py = find(x), find(y)
        if px == py:
            return False
        parent[px] = py
        return True

    max_edge = 0.0
    count = 0
    for w, u, v in edges:
        if union(u, v):
            max_edge = w
            count += 1
            if count == n - 1:
                break

    return max_edge


def covering_radius(points: np.ndarray, centers: np.ndarray) -> float:
    """Compute the covering radius: max over points of min distance to a center.

    Args:
        points: Array of shape (n, d) — the set to cover.
        centers: Array of shape (m, d) — the centers of covering balls.

    Returns:
        The covering radius.
    """
    # For each point, find distance to nearest center
    diffs = points[:, np.newaxis, :] - centers[np.newaxis, :, :]
    dists = np.sqrt(np.sum(diffs ** 2, axis=-1))
    min_dists = np.min(dists, axis=1)
    return float(np.max(min_dists))


def packing_number(points: np.ndarray, epsilon: float) -> int:
    """Estimate the packing number: max size of an epsilon-separated subset.

    Uses a greedy algorithm (which gives a 2-approximation for the covering number).

    Args:
        points: Array of shape (n, d).
        epsilon: Separation distance.

    Returns:
        Size of a maximal epsilon-separated subset.
    """
    D = distance_matrix(points)
    n = D.shape[0]
    selected = []
    remaining = set(range(n))

    while remaining:
        # Pick any remaining point
        p = next(iter(remaining))
        selected.append(p)
        # Remove all points within epsilon
        to_remove = {q for q in remaining if D[p, q] <= epsilon}
        remaining -= to_remove

    return len(selected)
