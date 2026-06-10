"""
Algorithms for Spectral Gap Analysis of Discrete Curvature Flow.

Implements the core computational methods from the spectral gap convergence
theory, including variance computation, Dirichlet energy estimation, greedy
curvature flow, and spectral gap estimation.
"""

import numpy as np
from typing import Tuple, List, Optional


def compute_variance(curvature: np.ndarray) -> float:
    """Compute the curvature variance: sum of squared deviations from mean.

    Args:
        curvature: Array of curvature values at each vertex.

    Returns:
        Variance V = sum_i (K_i - K_bar)^2.

    Example:
        >>> compute_variance(np.array([1.0, 2.0, 3.0]))
        2.0
    """
    mean = np.mean(curvature)
    return float(np.sum((curvature - mean) ** 2))


def compute_dirichlet_energy(curvature: np.ndarray, edges: List[Tuple[int, int]]) -> float:
    """Compute the Dirichlet energy: sum of squared differences across edges.

    Args:
        curvature: Array of curvature values at each vertex.
        edges: List of (i, j) pairs representing edges.

    Returns:
        Dirichlet energy E = sum_{(i,j) in edges} (K_i - K_j)^2.

    Example:
        >>> compute_dirichlet_energy(np.array([1.0, 3.0, 2.0]), [(0,1), (1,2)])
        5.0
    """
    energy = 0.0
    for i, j in edges:
        energy += (curvature[i] - curvature[j]) ** 2
    return energy


def estimate_spectral_gap(curvature: np.ndarray, edges: List[Tuple[int, int]]) -> float:
    """Estimate the Poincaré constant (spectral gap) as E/V.

    The Poincaré inequality states p * V <= E, so p <= E/V.
    The ratio E/V gives a lower bound on the spectral gap.

    Args:
        curvature: Array of curvature values at each vertex.
        edges: List of (i, j) pairs representing edges.

    Returns:
        Estimated spectral gap E/V, or inf if V = 0.

    Example:
        >>> K = np.array([1.0, 3.0, 2.0])
        >>> estimate_spectral_gap(K, [(0,1), (1,2), (0,2)])
        3.0
    """
    V = compute_variance(curvature)
    if V < 1e-15:
        return float('inf')
    E = compute_dirichlet_energy(curvature, edges)
    return E / V


def greedy_step(curvature: np.ndarray, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Perform one greedy curvature flow step.

    Finds the edge with maximum curvature discrepancy and equalizes
    the curvature at its endpoints (averaging).

    Args:
        curvature: Array of curvature values at each vertex.
        edges: List of (i, j) pairs representing edges.

    Returns:
        Updated curvature array after one greedy step.

    Example:
        >>> K = np.array([0.0, 4.0, 2.0])
        >>> greedy_step(K, [(0,1), (1,2)])
        array([2., 2., 2.])
    """
    K = curvature.copy()
    if len(edges) == 0:
        return K

    # Find edge with maximum discrepancy
    max_diff = 0.0
    best_edge = edges[0]
    for i, j in edges:
        diff = abs(K[i] - K[j])
        if diff > max_diff:
            max_diff = diff
            best_edge = (i, j)

    # Equalize curvature at the endpoints
    i, j = best_edge
    avg = (K[i] + K[j]) / 2.0
    K[i] = avg
    K[j] = avg
    return K


def run_curvature_flow(
    curvature: np.ndarray,
    edges: List[Tuple[int, int]],
    num_steps: int,
    track_dirichlet: bool = False
) -> dict:
    """Run greedy curvature flow for a given number of steps.

    Args:
        curvature: Initial curvature array.
        edges: List of (i, j) pairs representing edges.
        num_steps: Number of greedy steps to perform.
        track_dirichlet: If True, also track Dirichlet energy.

    Returns:
        Dictionary with keys:
        - 'variances': list of variance values at each step
        - 'curvatures': final curvature array
        - 'dirichlet_energies': list of Dirichlet energies (if tracked)
        - 'spectral_gaps': list of E/V ratios (if tracked)

    Example:
        >>> K = np.array([0.0, 4.0, 2.0, 6.0])
        >>> edges = [(0,1), (1,2), (2,3), (0,3)]
        >>> result = run_curvature_flow(K, edges, 10)
        >>> result['variances'][-1] < result['variances'][0]
        True
    """
    K = curvature.copy()
    variances = [compute_variance(K)]
    dirichlet_energies = []
    spectral_gaps = []

    if track_dirichlet:
        E = compute_dirichlet_energy(K, edges)
        dirichlet_energies.append(E)
        V = variances[0]
        spectral_gaps.append(E / V if V > 1e-15 else float('inf'))

    for step in range(num_steps):
        K = greedy_step(K, edges)
        V = compute_variance(K)
        variances.append(V)

        if track_dirichlet:
            E = compute_dirichlet_energy(K, edges)
            dirichlet_energies.append(E)
            spectral_gaps.append(E / V if V > 1e-15 else float('inf'))

    result = {
        'variances': variances,
        'curvatures': K,
    }
    if track_dirichlet:
        result['dirichlet_energies'] = dirichlet_energies
        result['spectral_gaps'] = spectral_gaps

    return result


def estimate_contraction_rate(variances: List[float], n: int) -> List[float]:
    """Estimate the empirical spectral gap constant C_hat at each step.

    Computes C_hat_k = n^2 * (1 - V(k+1)/V(k)) for each step k.
    If the spectral gap conjecture holds, C_hat_k should be bounded
    below by a positive constant.

    Args:
        variances: List of variance values.
        n: Number of vertices.

    Returns:
        List of C_hat values, one per step transition.
    """
    c_hats = []
    for k in range(len(variances) - 1):
        if variances[k] > 1e-15:
            ratio = variances[k + 1] / variances[k]
            c_hat = n ** 2 * (1.0 - ratio)
            c_hats.append(c_hat)
        else:
            c_hats.append(float('inf'))
    return c_hats


def certified_stopping_criterion(
    n: int,
    V0: float,
    epsilon: float,
    C: float
) -> int:
    """Compute the certified number of steps to reach variance ≤ epsilon.

    From the exponential convergence theorem:
    V(k) ≤ (1 - C/n²)^k * V(0) ≤ epsilon
    ⟹ k ≥ (n²/C) * ln(V(0)/epsilon)

    Args:
        n: Number of vertices.
        V0: Initial variance.
        epsilon: Target variance threshold.
        C: Spectral gap constant.

    Returns:
        Minimum number of steps N to guarantee V(N) ≤ epsilon.

    Example:
        >>> certified_stopping_criterion(100, 10.0, 0.01, 0.5)
        138156
    """
    if V0 <= epsilon:
        return 0
    if C <= 0:
        raise ValueError("Spectral gap constant C must be positive")
    N = int(np.ceil((n ** 2 / C) * np.log(V0 / epsilon)))
    return max(N, 1)


def generate_cycle_graph(n: int) -> List[Tuple[int, int]]:
    """Generate edges of a cycle graph on n vertices.

    Args:
        n: Number of vertices.

    Returns:
        List of edges [(0,1), (1,2), ..., (n-2,n-1), (n-1,0)].
    """
    return [(i, (i + 1) % n) for i in range(n)]


def generate_grid_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Generate a triangulated m x m grid (genus 0 triangulation).

    Creates an m×m grid of vertices with each square divided into
    two triangles, giving a planar triangulation.

    Args:
        m: Grid dimension (m x m vertices).

    Returns:
        Tuple of (number of vertices, list of edges).
    """
    n = m * m
    edges = set()
    for i in range(m):
        for j in range(m):
            v = i * m + j
            # Right neighbor
            if j + 1 < m:
                edges.add((v, v + 1))
            # Bottom neighbor
            if i + 1 < m:
                edges.add((v, v + m))
            # Diagonal (for triangulation)
            if i + 1 < m and j + 1 < m:
                edges.add((v, v + m + 1))
    return n, list(edges)


def generate_torus_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Generate a triangulated m x m torus (genus 1 triangulation).

    Creates an m×m grid with periodic boundary conditions (torus topology).

    Args:
        m: Grid dimension.

    Returns:
        Tuple of (number of vertices, list of edges).
    """
    n = m * m
    edges = set()
    for i in range(m):
        for j in range(m):
            v = i * m + j
            # Right neighbor (periodic)
            right = i * m + ((j + 1) % m)
            edges.add((min(v, right), max(v, right)))
            # Bottom neighbor (periodic)
            bottom = ((i + 1) % m) * m + j
            edges.add((min(v, bottom), max(v, bottom)))
            # Diagonal (periodic)
            diag = ((i + 1) % m) * m + ((j + 1) % m)
            edges.add((min(v, diag), max(v, diag)))
    return n, list(edges)


if __name__ == "__main__":
    # Quick demonstration
    print("=== Spectral Gap Algorithms Demo ===\n")

    # Generate a small grid triangulation
    n, edges = generate_grid_triangulation(5)
    print(f"Grid triangulation: {n} vertices, {len(edges)} edges")

    # Random initial curvature
    np.random.seed(42)
    K = np.random.randn(n) * 2.0

    # Run flow
    result = run_curvature_flow(K, edges, 200, track_dirichlet=True)

    print(f"Initial variance: {result['variances'][0]:.6f}")
    print(f"Final variance:   {result['variances'][-1]:.6f}")
    print(f"Reduction ratio:  {result['variances'][-1] / result['variances'][0]:.2e}")

    # Estimate spectral gap
    c_hats = estimate_contraction_rate(result['variances'], n)
    valid_c_hats = [c for c in c_hats if c < float('inf') and c > 0]
    if valid_c_hats:
        print(f"\nEmpirical spectral gap C_hat:")
        print(f"  Min:    {min(valid_c_hats):.4f}")
        print(f"  Median: {np.median(valid_c_hats):.4f}")
        print(f"  Max:    {max(valid_c_hats):.4f}")

    # Certified stopping criterion
    C_est = min(valid_c_hats) if valid_c_hats else 0.1
    N_cert = certified_stopping_criterion(n, result['variances'][0], 1e-6, C_est)
    print(f"\nCertified steps to reach V < 1e-6: {N_cert}")
