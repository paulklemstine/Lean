"""
Algorithms for Quantum Algorithmic Phase Transitions via Lorentzian Polynomials

This module implements the core computational procedures for:
1. Computing Lorentzian stability radii
2. Estimating certified algorithmic thresholds
3. Analyzing quadratic form signatures
4. Simulating noise degradation of quantum sampling proxies

All algorithms correspond to formally verified theorems in the Lean formalization.
"""

import numpy as np
from typing import Tuple, Optional, List, Dict
from dataclasses import dataclass


@dataclass
class LorentzianData:
    """Data package for a matrix with Lorentzian (gapped) signature.

    Attributes:
        matrix: The symmetric matrix A (Hessian proxy)
        gap: The certified spectral gap ε > 0
        witness: The witness direction w for the orthogonal complement bound
    """
    matrix: np.ndarray
    gap: float
    witness: np.ndarray


def compute_quadratic_form(A: np.ndarray, v: np.ndarray) -> float:
    """Compute the quadratic form Q_A(v) = v^T A v.

    Args:
        A: n×n symmetric matrix
        v: n-dimensional vector

    Returns:
        The value v^T A v
    """
    return float(v @ A @ v)


def sq_norm(v: np.ndarray) -> float:
    """Compute squared Euclidean norm ||v||^2."""
    return float(np.sum(v ** 2))


def check_gapped_signature(A: np.ndarray, epsilon: float) -> Tuple[bool, Optional[np.ndarray]]:
    """Check if matrix A has gapped Lorentzian signature with margin ε.

    A matrix has gapped Lorentzian signature with margin ε if there exists
    a witness direction w such that for all v orthogonal to w,
    Q_A(v) ≤ -ε * ||v||^2.

    This is equivalent to: A has at most one eigenvalue > -ε.

    Args:
        A: n×n symmetric matrix
        epsilon: gap margin

    Returns:
        (is_gapped, witness) where witness is the direction of the
        most positive eigenvalue, or None if not gapped.

    Time complexity: O(n^3) for eigendecomposition
    Space complexity: O(n^2)
    """
    n = A.shape[0]
    eigenvalues, eigenvectors = np.linalg.eigh(A)

    # Sort eigenvalues in descending order
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Check: at most one eigenvalue > -ε
    count_above = np.sum(eigenvalues > -epsilon)

    if count_above <= 1:
        # Witness is the eigenvector of the largest eigenvalue
        witness = eigenvectors[:, 0]
        return True, witness
    else:
        return False, None


def compute_lorentzian_gap(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute the Lorentzian gap of a symmetric matrix.

    The gap is the distance from the second-largest eigenvalue to zero,
    negated: gap = -λ_2 where λ_1 ≥ λ_2 ≥ ... ≥ λ_n.

    If the matrix is Lorentzian (at most one positive eigenvalue),
    the gap measures how robustly Lorentzian it is.

    Args:
        A: n×n symmetric matrix

    Returns:
        (gap, witness_direction)

    Time complexity: O(n^3)
    """
    n = A.shape[0]
    eigenvalues, eigenvectors = np.linalg.eigh(A)

    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    if n >= 2:
        gap = -eigenvalues[1]  # gap = -λ_2
    else:
        gap = float('inf')

    witness = eigenvectors[:, 0]
    return gap, witness


def estimate_lorentzian_radius(
    A: np.ndarray,
    grid: List[float],
    gap: Optional[float] = None
) -> Optional[float]:
    """Certified search procedure for Lorentzian stability radius lower bound.

    For a matrix A with gap ε, returns the largest r in the grid such that
    every perturbation E with ||E||_op ≤ r preserves Lorentzian signature.

    By the residual gap theorem, any r < ε is valid.

    Args:
        A: n×n symmetric matrix
        grid: list of candidate radii to test
        gap: pre-computed gap (computed if None)

    Returns:
        Largest certified radius from grid, or None if none is valid.

    Correctness guarantee (formally verified):
        If estimate_lorentzian_radius returns r, then for all E with
        QuadFormBound(E) ≤ r, the perturbed matrix A + E remains
        algorithmically separated.

    Time complexity: O(n^3 + |grid|)
    """
    if gap is None:
        gap, _ = compute_lorentzian_gap(A)

    valid = [r for r in grid if 0 < r < gap]

    if not valid:
        return None
    return max(valid)


def certified_threshold(A: np.ndarray) -> float:
    """Compute the certified algorithmic threshold for a matrix.

    This is the maximum perturbation radius that preserves algorithmic
    separation (positive spectral gap proxy). By Theorem 1, this is
    at least gap/2 where gap is the Lorentzian gap.

    Args:
        A: n×n symmetric matrix

    Returns:
        Certified threshold value

    Time complexity: O(n^3)
    """
    gap, _ = compute_lorentzian_gap(A)
    return gap / 2  # Conservative certified bound


def simulate_noise_degradation(
    A: np.ndarray,
    noise_levels: np.ndarray,
    num_samples: int = 100
) -> Dict[str, np.ndarray]:
    """Simulate how noise degrades the Lorentzian structure.

    For each noise level η, generates random perturbations and measures:
    - The residual Lorentzian gap
    - The fraction of perturbations that preserve Lorentzian structure
    - The average spectral gap proxy

    Args:
        A: n×n symmetric matrix (base Hessian)
        noise_levels: array of noise magnitudes to test
        num_samples: number of random perturbations per noise level

    Returns:
        Dictionary with keys 'noise', 'avg_gap', 'survival_rate', 'min_gap'

    Time complexity: O(|noise_levels| * num_samples * n^3)
    """
    n = A.shape[0]
    base_gap, _ = compute_lorentzian_gap(A)

    results = {
        'noise': noise_levels,
        'avg_gap': np.zeros_like(noise_levels),
        'survival_rate': np.zeros_like(noise_levels),
        'min_gap': np.zeros_like(noise_levels),
    }

    for idx, eta in enumerate(noise_levels):
        gaps = []
        survived = 0

        for _ in range(num_samples):
            # Random symmetric perturbation
            E = np.random.randn(n, n)
            E = (E + E.T) / 2
            # Scale to have operator norm ≈ eta
            E = E / np.linalg.norm(E, ord=2) * eta

            perturbed = A + E
            gap, _ = compute_lorentzian_gap(perturbed)
            gaps.append(gap)
            if gap > 0:
                survived += 1

        results['avg_gap'][idx] = np.mean(gaps)
        results['survival_rate'][idx] = survived / num_samples
        results['min_gap'][idx] = np.min(gaps)

    return results


def matching_hessian_proxy(adj_matrix: np.ndarray) -> np.ndarray:
    """Construct the matching polynomial Hessian proxy from an adjacency matrix.

    For a graph with adjacency matrix adj, the adjacency matrix itself has
    Lorentzian signature: at most one positive eigenvalue (the spectral radius).
    For K_n: eigenvalues are n-1 (once), -1 (n-1 times), giving gap = 1.

    Args:
        adj_matrix: n×n binary adjacency matrix (symmetric)

    Returns:
        n×n Hessian proxy matrix
    """
    return adj_matrix.astype(float)


def permanent_proxy_hessian(A: np.ndarray) -> np.ndarray:
    """Construct a Hessian proxy from a PSD matrix for permanent-type polynomials.

    For a PSD matrix A, the proxy Hessian is -A, which is negative semi-definite
    and thus Lorentzian. This models the Hessian of the permanent generating
    polynomial evaluated at the all-ones vector.

    Args:
        A: n×n positive semi-definite matrix

    Returns:
        n×n negative semi-definite Hessian proxy
    """
    return -A


def compute_phase_diagram(
    A: np.ndarray,
    noise_range: Tuple[float, float] = (0, 2),
    num_points: int = 200
) -> Dict[str, np.ndarray]:
    """Compute the full phase diagram showing quantum-classical transition.

    Maps out the boundary between the algorithmically separated (quantum hard)
    regime and the classically simulable regime as a function of noise.

    Args:
        A: n×n symmetric matrix (base Hessian)
        noise_range: (min, max) noise levels to scan
        num_points: number of points in the noise scan

    Returns:
        Dictionary with noise levels, gaps, and phase boundary markers
    """
    noise_levels = np.linspace(noise_range[0], noise_range[1], num_points)
    base_gap, _ = compute_lorentzian_gap(A)
    certified_r = certified_threshold(A)

    # Theoretical prediction: gap degrades as gap - noise
    theoretical_gap = np.maximum(base_gap - noise_levels, 0)

    # Empirical simulation
    sim_results = simulate_noise_degradation(A, noise_levels, num_samples=50)

    return {
        'noise': noise_levels,
        'theoretical_gap': theoretical_gap,
        'empirical_gap': sim_results['avg_gap'],
        'survival_rate': sim_results['survival_rate'],
        'certified_radius': certified_r,
        'base_gap': base_gap,
        'critical_point': base_gap,  # Theoretical phase transition
    }


if __name__ == "__main__":
    # Example: 4x4 negative definite matrix (matching polynomial proxy)
    n = 4
    # Complete graph K4 adjacency
    adj = np.ones((n, n)) - np.eye(n)
    A = matching_hessian_proxy(adj)

    print("=== Matching Hessian Proxy (K4) ===")
    print(f"Matrix:\n{A}")

    gap, witness = compute_lorentzian_gap(A)
    print(f"\nLorentzian gap: {gap:.4f}")
    print(f"Witness direction: {witness}")

    is_gapped, _ = check_gapped_signature(A, gap)
    print(f"Has gapped signature: {is_gapped}")

    radius = certified_threshold(A)
    print(f"Certified threshold: {radius:.4f}")

    # Grid-based estimation
    grid = [0.1 * i for i in range(1, 20)]
    est_radius = estimate_lorentzian_radius(A, grid)
    print(f"Grid-estimated radius: {est_radius}")

    # Noise degradation
    print("\n=== Noise Degradation ===")
    noise_levels = np.array([0, 0.1, 0.5, 1.0, 1.5, 2.0])
    results = simulate_noise_degradation(A, noise_levels, num_samples=50)
    for i, eta in enumerate(noise_levels):
        print(f"  η={eta:.1f}: avg_gap={results['avg_gap'][i]:.3f}, "
              f"survival={results['survival_rate'][i]:.2f}")
