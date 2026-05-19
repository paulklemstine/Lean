"""
Spectral Proof Universality — Algorithms

Core algorithms for computing spectral invariants of proof graphs
and testing universality hypotheses.
"""

import numpy as np
from numpy.linalg import eigh, eigvalsh
from typing import List, Tuple, Dict, Optional
from collections import defaultdict


def compute_adjacency_matrix(
    edges: List[Tuple[int, int]], n: int
) -> np.ndarray:
    """
    Construct the adjacency matrix of a simple undirected graph.

    Args:
        edges: List of (i, j) pairs representing undirected edges.
        n: Number of vertices.

    Returns:
        n×n symmetric numpy array with 0/1 entries.

    Time complexity: O(n² + |E|)
    Space complexity: O(n²)
    """
    A = np.zeros((n, n), dtype=float)
    for (i, j) in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def compute_eigenvalues(A: np.ndarray) -> np.ndarray:
    """
    Compute eigenvalues of a symmetric matrix.

    Uses LAPACK's divide-and-conquer algorithm (dsyevd).

    Args:
        A: n×n symmetric real matrix.

    Returns:
        Array of n real eigenvalues in ascending order.

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    return eigvalsh(A)


def empirical_spectral_moments(
    A: np.ndarray, max_k: int = 10
) -> Dict[int, float]:
    """
    Compute empirical spectral moments μ_k = (1/n) Σ λ_i^k.

    Equivalent to normalizedTrace(A^k) by the spectral trace identity.

    Args:
        A: n×n symmetric real matrix.
        max_k: Maximum moment order.

    Returns:
        Dictionary mapping k to μ_k.

    Time complexity: O(n³) for eigenvalue computation + O(n·max_k) for moments.
    """
    eigenvalues = eigvalsh(A)
    n = len(eigenvalues)
    return {k: float(np.sum(eigenvalues**k) / n) for k in range(max_k + 1)}


def normalized_trace_sequence(
    A: np.ndarray, max_k: int = 10
) -> Dict[int, float]:
    """
    Compute normalized traces tr(A^k)/n via matrix multiplication.

    This is the "walk-counting" approach: no eigenvalue computation needed.

    Args:
        A: n×n matrix.
        max_k: Maximum power.

    Returns:
        Dictionary mapping k to tr(A^k)/n.

    Time complexity: O(n³ · max_k)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    result = {}
    Ak = np.eye(n)
    for k in range(max_k + 1):
        result[k] = float(np.trace(Ak) / n)
        Ak = Ak @ A
    return result


def closed_walk_count(A: np.ndarray, k: int) -> int:
    """
    Count closed walks of length k in a graph.

    Uses the identity: number of closed walks of length k = tr(A^k).

    Args:
        A: Adjacency matrix (0/1 symmetric).
        k: Walk length.

    Returns:
        Total number of closed walks of length k.

    Time complexity: O(n³ · log(k)) using matrix exponentiation,
                     or O(n³ · k) using iterative multiplication.
    """
    Ak = np.linalg.matrix_power(A, k)
    return int(round(np.trace(Ak)))


def spectral_perturbation_distance(
    A: np.ndarray, B: np.ndarray, max_k: int = 10
) -> Dict[int, float]:
    """
    Compute normalized trace differences |tr(A^k)/n - tr(B^k)/n|
    for k = 0, ..., max_k.

    By the perturbation bound theorem, these are bounded by
    2 * R^k when all eigenvalues have |λ| ≤ R.

    Args:
        A, B: n×n symmetric real matrices.
        max_k: Maximum power.

    Returns:
        Dictionary mapping k to |normalizedTrace(A^k) - normalizedTrace(B^k)|.
    """
    mom_A = normalized_trace_sequence(A, max_k)
    mom_B = normalized_trace_sequence(B, max_k)
    return {k: abs(mom_A[k] - mom_B[k]) for k in range(max_k + 1)}


def kolmogorov_distance(A: np.ndarray, B: np.ndarray) -> float:
    """
    Kolmogorov (sup-norm CDF) distance between empirical spectral measures.

    Args:
        A, B: Symmetric real matrices.

    Returns:
        sup_x |F_A(x) - F_B(x)| where F_A, F_B are empirical CDFs
        of eigenvalues.

    Time complexity: O(n log n + m log m) for n, m = dimensions.
    """
    ev_A = np.sort(eigvalsh(A))
    ev_B = np.sort(eigvalsh(B))
    n_A, n_B = len(ev_A), len(ev_B)

    all_vals = np.sort(np.concatenate([ev_A, ev_B]))
    max_diff = 0.0
    for x in all_vals:
        cdf_A = np.searchsorted(ev_A, x, side='right') / n_A
        cdf_B = np.searchsorted(ev_B, x, side='right') / n_B
        max_diff = max(max_diff, abs(cdf_A - cdf_B))
    return max_diff


def bounded_lipschitz_distance(
    A: np.ndarray, B: np.ndarray, num_test_functions: int = 100
) -> float:
    """
    Approximate bounded-Lipschitz distance between empirical spectral measures.

    Uses random 1-Lipschitz functions bounded by 1 as test functions.

    Args:
        A, B: Symmetric real matrices.
        num_test_functions: Number of random test functions.

    Returns:
        Approximate sup over 1-Lipschitz, 1-bounded functions f of
        |∫f dμ_A - ∫f dμ_B|.
    """
    ev_A = eigvalsh(A)
    ev_B = eigvalsh(B)
    n_A, n_B = len(ev_A), len(ev_B)

    max_dist = 0.0
    np.random.seed(0)
    for _ in range(num_test_functions):
        # Random 1-Lipschitz function: f(x) = max(0, min(1, a*x + b))
        # with |a| ≤ 1
        a = np.random.uniform(-1, 1)
        b = np.random.uniform(-3, 3)
        f = lambda x, a=a, b=b: np.clip(a * x + b, -1, 1)
        int_A = np.mean(f(ev_A))
        int_B = np.mean(f(ev_B))
        max_dist = max(max_dist, abs(int_A - int_B))
    return max_dist


def extract_rooted_neighborhood(
    A: np.ndarray, root: int, radius: int
) -> np.ndarray:
    """
    Extract the adjacency matrix of the ball of given radius around root.

    This implements the local neighborhood extraction needed for
    Benjamini-Schramm convergence.

    Args:
        A: n×n adjacency matrix.
        root: Root vertex index.
        radius: Neighborhood radius.

    Returns:
        Adjacency matrix of the induced subgraph on the r-neighborhood.
    """
    n = A.shape[0]
    visited = {root}
    frontier = {root}

    for _ in range(radius):
        new_frontier = set()
        for v in frontier:
            for w in range(n):
                if A[v, w] > 0 and w not in visited:
                    new_frontier.add(w)
                    visited.add(w)
        frontier = new_frontier

    vertices = sorted(visited)
    k = len(vertices)
    idx_map = {v: i for i, v in enumerate(vertices)}
    sub_A = np.zeros((k, k))
    for v in vertices:
        for w in vertices:
            sub_A[idx_map[v], idx_map[w]] = A[v, w]
    return sub_A


def motif_frequency_vector(
    A: np.ndarray, radius: int = 2
) -> Dict[str, float]:
    """
    Compute the distribution of rooted neighborhoods of given radius.

    Two rooted neighborhoods are considered equivalent if they are
    isomorphic as rooted graphs. We use a simple canonical form
    (sorted degree sequence of the subgraph) as a proxy.

    Args:
        A: n×n adjacency matrix.
        radius: Neighborhood radius.

    Returns:
        Dictionary mapping canonical neighborhood types to their frequencies.
    """
    n = A.shape[0]
    motif_counts: Dict[str, int] = defaultdict(int)

    for root in range(n):
        sub_A = extract_rooted_neighborhood(A, root, radius)
        # Simple canonical form: sorted degree sequence
        degrees = tuple(sorted(int(d) for d in np.sum(sub_A, axis=1)))
        motif_counts[str(degrees)] += 1

    total = sum(motif_counts.values())
    return {k: v / total for k, v in sorted(motif_counts.items())}


def degree_bound(A: np.ndarray) -> int:
    """Maximum degree of the graph."""
    return int(np.max(np.sum(A, axis=1)))


def spectral_radius(A: np.ndarray) -> float:
    """Spectral radius: max |λ_i|."""
    return float(np.max(np.abs(eigvalsh(A))))


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Build a sample graph
    edges = [(0,1), (1,2), (2,3), (3,4), (4,0), (0,2)]
    n = 5
    A = compute_adjacency_matrix(edges, n)

    print("Adjacency matrix:")
    print(A)
    print(f"\nEigenvalues: {compute_eigenvalues(A).round(4)}")
    print(f"Degree bound: {degree_bound(A)}")
    print(f"Spectral radius: {spectral_radius(A):.4f}")

    print("\nSpectral moments:")
    moments = empirical_spectral_moments(A, 6)
    traces = normalized_trace_sequence(A, 6)
    for k in range(7):
        print(f"  k={k}: moment={moments[k]:.6f}, trace={traces[k]:.6f}")

    print(f"\nClosed walks of length 3: {closed_walk_count(A, 3)}")
    print(f"Closed walks of length 4: {closed_walk_count(A, 4)}")

    print("\nMotif frequencies (radius 1):")
    for motif, freq in motif_frequency_vector(A, 1).items():
        print(f"  {motif}: {freq:.3f}")
