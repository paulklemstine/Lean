"""
Algorithms for Protein Folding as Persistent Homology Optimization.

Implements:
1. Vietoris-Rips filtration from distance matrix
2. Total persistence computation
3. p-total persistence computation
4. Topological gradient estimation
5. Persistence entropy computation
"""

from typing import List, Tuple
import numpy as np


def compute_distance_matrix(coords: np.ndarray) -> np.ndarray:
    """Compute pairwise Euclidean distance matrix from Cα coordinates.

    Args:
        coords: (n, 3) array of atom positions.

    Returns:
        (n, n) symmetric distance matrix with zero diagonal.
    """
    n = coords.shape[0]
    diff = coords[:, np.newaxis, :] - coords[np.newaxis, :, :]
    return np.sqrt(np.sum(diff**2, axis=-1))


def vietoris_rips_filtration(
    dist_matrix: np.ndarray, max_epsilon: float, num_steps: int = 100
) -> List[Tuple[float, int]]:
    """Compute the Vietoris-Rips filtration contact count at each threshold.

    Args:
        dist_matrix: (n, n) distance matrix.
        max_epsilon: Maximum filtration threshold.
        num_steps: Number of threshold steps.

    Returns:
        List of (epsilon, contact_count) pairs.
    """
    thresholds = np.linspace(0, max_epsilon, num_steps)
    result = []
    for eps in thresholds:
        contacts = np.sum(dist_matrix <= eps) - dist_matrix.shape[0]  # exclude diagonal
        result.append((eps, int(contacts)))
    return result


def compute_persistence_intervals(
    dist_matrix: np.ndarray,
) -> List[Tuple[float, float]]:
    """Compute persistence intervals using a simplified union-find approach.

    This computes H0 (connected component) persistence intervals from the
    distance matrix using Kruskal's-like algorithm.

    Args:
        dist_matrix: (n, n) distance matrix.

    Returns:
        List of (birth, death) tuples for H0 persistence intervals.
    """
    n = dist_matrix.shape[0]
    # Get all edges sorted by distance
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((dist_matrix[i, j], i, j))
    edges.sort()

    # Union-Find
    parent = list(range(n))
    rank = [0] * n
    birth = [0.0] * n  # Each component born at time 0

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True

    intervals = []
    for dist, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            # The younger component dies
            younger = rj if birth[ri] <= birth[rj] else ri
            intervals.append((birth[younger], dist))
            union(i, j)

    return intervals


def total_persistence(intervals: List[Tuple[float, float]]) -> float:
    """Compute total persistence: sum of (death - birth) over all intervals.

    Args:
        intervals: List of (birth, death) pairs.

    Returns:
        Total persistence value.
    """
    return sum(d - b for b, d in intervals)


def p_total_persistence(intervals: List[Tuple[float, float]], p: int = 1) -> float:
    """Compute p-total persistence: sum of (death - birth)^p.

    Args:
        intervals: List of (birth, death) pairs.
        p: Power exponent (default 1).

    Returns:
        p-total persistence value.
    """
    return sum((d - b) ** p for b, d in intervals)


def persistence_entropy(intervals: List[Tuple[float, float]]) -> float:
    """Compute persistence entropy: Shannon entropy of normalized persistences.

    Args:
        intervals: List of (birth, death) pairs.

    Returns:
        Persistence entropy value.
    """
    persistences = [d - b for b, d in intervals]
    total = sum(persistences)
    if total == 0:
        return 0.0
    weights = [p / total for p in persistences]
    return -sum(w * np.log(w) if w > 0 else 0.0 for w in weights)


def topological_gradient(
    coords: np.ndarray, delta: float = 0.01
) -> np.ndarray:
    """Estimate the topological gradient of total persistence.

    Uses finite differences: perturb each coordinate by delta,
    recompute total persistence, estimate partial derivative.

    Args:
        coords: (n, 3) array of atom positions.
        delta: Perturbation size.

    Returns:
        (n, 3) gradient array.
    """
    n = coords.shape[0]
    grad = np.zeros_like(coords)
    base_dm = compute_distance_matrix(coords)
    base_intervals = compute_persistence_intervals(base_dm)
    base_tp = total_persistence(base_intervals)

    for i in range(n):
        for j in range(3):
            perturbed = coords.copy()
            perturbed[i, j] += delta
            dm = compute_distance_matrix(perturbed)
            intervals = compute_persistence_intervals(dm)
            tp = total_persistence(intervals)
            grad[i, j] = (tp - base_tp) / delta

    return grad


def gradient_dimension(n: int) -> int:
    """Number of independent pairwise distances for n atoms.

    This is n*(n-1)/2, the dimension of the contact-map gradient space.

    Args:
        n: Number of atoms.

    Returns:
        Gradient dimension.
    """
    return n * (n - 1) // 2


def topological_similarity(
    intervals1: List[Tuple[float, float]],
    intervals2: List[Tuple[float, float]],
) -> float:
    """Compute topological similarity: |TP(B1) - TP(B2)|.

    Args:
        intervals1: First barcode intervals.
        intervals2: Second barcode intervals.

    Returns:
        Absolute difference in total persistence.
    """
    return abs(total_persistence(intervals1) - total_persistence(intervals2))


def generate_random_decoy(n: int, radius: float = 10.0) -> np.ndarray:
    """Generate a random protein decoy configuration.

    Args:
        n: Number of atoms.
        radius: Radius of the bounding sphere.

    Returns:
        (n, 3) array of random positions.
    """
    coords = np.random.randn(n, 3)
    coords *= radius / np.max(np.linalg.norm(coords, axis=1))
    return coords


def generate_extended_chain(n: int, bond_length: float = 3.8) -> np.ndarray:
    """Generate an extended linear chain configuration.

    Args:
        n: Number of atoms.
        bond_length: Distance between consecutive atoms (Å).

    Returns:
        (n, 3) array of positions along x-axis.
    """
    coords = np.zeros((n, 3))
    coords[:, 0] = np.arange(n) * bond_length
    return coords
