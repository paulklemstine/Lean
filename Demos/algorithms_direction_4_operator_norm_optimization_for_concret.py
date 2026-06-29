#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Spectral Compression Optimization

Implements:
1. RMS amplification computation
2. Anisotropy ratio computation
3. Candidate compression map ranking
4. Optimal balanced compression design
"""

import numpy as np
from numpy.linalg import norm, svd
from typing import List, Tuple, Optional


def compute_rms_amplification(A: np.ndarray) -> float:
    """Compute the RMS amplification of a linear map represented by matrix A.
    
    rmsAmp(A) = sqrt(||A||_F^2 / k)
    
    where k = A.shape[1] is the input dimension and ||A||_F is the Frobenius norm.
    
    This equals sqrt((1/k) * sum_i ||A e_i||^2) for the standard basis.
    
    Complexity: O(k*m) where A is m×k.
    
    Args:
        A: Matrix representing the linear map (m × k).
    
    Returns:
        The RMS amplification (nonnegative real).
    
    Example:
        >>> compute_rms_amplification(np.eye(3))
        1.0
        >>> compute_rms_amplification(np.ones((1, 4)))
        1.0
    """
    k = A.shape[1]
    frobenius_sq = np.sum(A ** 2)
    return np.sqrt(frobenius_sq / k)


def compute_operator_norm(A: np.ndarray) -> float:
    """Compute the operator norm (spectral norm) of matrix A.
    
    ||A||_op = max singular value of A.
    
    Complexity: O(min(m,k) * m * k) via SVD.
    
    Args:
        A: Matrix (m × k).
    
    Returns:
        The operator norm (nonnegative real).
    """
    return float(norm(A, ord=2))


def compute_anisotropy_ratio(A: np.ndarray) -> float:
    """Compute the anisotropy ratio: ||A||_op / rmsAmp(A).
    
    By our main theorem, this is always in [1, sqrt(k)].
    
    Ratio = 1 means the map is isotropic (all singular values equal).
    Ratio = sqrt(k) means maximally anisotropic (rank-1 case).
    
    Args:
        A: Matrix (m × k).
    
    Returns:
        The anisotropy ratio (≥ 1).
    """
    rms = compute_rms_amplification(A)
    if rms < 1e-15:
        return 1.0
    return compute_operator_norm(A) / rms


def compute_singular_value_spectrum(A: np.ndarray) -> np.ndarray:
    """Compute the full singular value spectrum of A.
    
    Args:
        A: Matrix (m × k).
    
    Returns:
        Array of singular values in descending order.
    """
    return svd(A, compute_uv=False)


def rank_candidates_by_anisotropy(
    candidates: List[Tuple[str, np.ndarray]]
) -> List[Tuple[str, float, float, float]]:
    """Rank candidate compression maps by anisotropy ratio.
    
    Lower anisotropy ratio = better (more isotropic = tighter correctness bound).
    
    Algorithm:
        1. For each candidate, compute rmsAmp and operator norm.
        2. Compute anisotropy ratio.
        3. Sort by ratio (ascending).
    
    Complexity: O(n * min(m,k) * m * k) for n candidates of size m×k.
    
    Args:
        candidates: List of (name, matrix) pairs.
    
    Returns:
        Sorted list of (name, operator_norm, rms_amp, anisotropy_ratio),
        ordered by anisotropy ratio (best first).
    
    Example:
        >>> candidates = [
        ...     ("Identity", np.eye(4)),
        ...     ("Sum", np.ones((1, 4)))
        ... ]
        >>> results = rank_candidates_by_anisotropy(candidates)
        >>> results[0][0]  # Best candidate
        'Identity'
    """
    results = []
    for name, A in candidates:
        op = compute_operator_norm(A)
        rms = compute_rms_amplification(A)
        ratio = compute_anisotropy_ratio(A)
        results.append((name, op, rms, ratio))
    
    results.sort(key=lambda x: x[3])
    return results


def design_balanced_diagonal(
    k: int,
    target_rms: float
) -> np.ndarray:
    """Design an optimal balanced diagonal compression map.
    
    Returns a k×k diagonal matrix with all entries equal to target_rms,
    which minimizes operator norm at fixed RMS amplification.
    
    By the equipartition principle, this achieves anisotropy ratio = 1.
    
    Args:
        k: Dimension.
        target_rms: Desired RMS amplification.
    
    Returns:
        k×k diagonal matrix with entries all equal to target_rms.
    """
    return np.diag(np.full(k, target_rms))


def design_optimal_block_diagonal(
    block_sizes: List[int],
    target_rms: float
) -> np.ndarray:
    """Design an optimal block-diagonal compression map.
    
    Each block is a scaled identity (balanced within block).
    The scaling is uniform across blocks for overall isotropy.
    
    Args:
        block_sizes: List of block dimensions.
        target_rms: Desired overall RMS amplification.
    
    Returns:
        Block-diagonal matrix with optimal (balanced) structure.
    """
    total_k = sum(block_sizes)
    blocks = [np.eye(b) * target_rms for b in block_sizes]
    return _block_diag(blocks)


def _block_diag(blocks: List[np.ndarray]) -> np.ndarray:
    """Create a block diagonal matrix from a list of blocks."""
    sizes = [b.shape[0] for b in blocks]
    total = sum(sizes)
    result = np.zeros((total, total))
    offset = 0
    for b in blocks:
        n = b.shape[0]
        result[offset:offset+n, offset:offset+n] = b
        offset += n
    return result


def compute_correctness_threshold(
    A: np.ndarray,
    delta: float,
    method: str = "rms"
) -> float:
    """Compute the correctness threshold for a compression map.
    
    Two methods:
    - "opnorm": B = ||A||_op * delta  (standard bound)
    - "rms":    B = sqrt(k) * rmsAmp(A) * delta  (our new bound)
    
    The RMS bound is always >= the operator norm bound, but has the advantage
    of being computable from basis images alone and revealing the spectral
    structure of the compression map.
    
    Args:
        A: Compression matrix (m × k).
        delta: Noise bound.
        method: "opnorm" or "rms".
    
    Returns:
        The correctness threshold B.
    """
    k = A.shape[1]
    if method == "opnorm":
        return compute_operator_norm(A) * delta
    elif method == "rms":
        return np.sqrt(k) * compute_rms_amplification(A) * delta
    else:
        raise ValueError(f"Unknown method: {method}")


def find_minimum_anisotropy_diagonal(
    k: int,
    target_frobenius: float,
    num_trials: int = 10000
) -> Tuple[np.ndarray, float]:
    """Find the diagonal map minimizing operator norm at fixed Frobenius norm.
    
    By the equipartition principle (formally verified), the minimum is achieved
    by the balanced diagonal with all entries equal.
    
    This function verifies computationally that random perturbations cannot
    improve upon the balanced solution.
    
    Args:
        k: Dimension.
        target_frobenius: Fixed Frobenius norm.
        num_trials: Number of random trials.
    
    Returns:
        (best_diagonal_entries, best_operator_norm)
    """
    # Optimal: balanced
    balanced_entry = target_frobenius / np.sqrt(k)
    best_d = np.full(k, balanced_entry)
    best_opnorm = balanced_entry  # For balanced diagonal, opnorm = entry value
    
    # Try random perturbations
    for _ in range(num_trials):
        d = np.abs(np.random.randn(k))
        d = d * (target_frobenius / np.sqrt(np.sum(d**2)))
        opnorm = np.max(np.abs(d))
        if opnorm < best_opnorm:
            best_d = d.copy()
            best_opnorm = opnorm
    
    return best_d, best_opnorm


if __name__ == "__main__":
    print("Algorithms Module — Example Usage")
    print("=" * 50)
    
    # Example 1: Compare candidates
    print("\n1. Ranking compression candidates:")
    candidates = [
        ("Identity 4×4", np.eye(4)),
        ("Sum functional", np.ones((1, 4))),
        ("Balanced diagonal", np.diag([2, 2, 2, 2])),
        ("Unbalanced diagonal", np.diag([4, 2, 1, 0.5])),
        ("Random", np.random.randn(4, 4)),
    ]
    
    results = rank_candidates_by_anisotropy(candidates)
    print(f"  {'Name':>25}  {'||·||_op':>8}  {'rmsAmp':>8}  {'ratio':>8}")
    print("  " + "-" * 55)
    for name, op, rms, ratio in results:
        print(f"  {name:>25}  {op:>8.4f}  {rms:>8.4f}  {ratio:>8.4f}")
    
    # Example 2: Optimal design
    print("\n2. Optimal balanced design (k=8, target rmsAmp=3.0):")
    D = design_balanced_diagonal(8, 3.0)
    print(f"  Diagonal entries: {np.diag(D)}")
    print(f"  ||D||_op = {compute_operator_norm(D):.4f}")
    print(f"  rmsAmp   = {compute_rms_amplification(D):.4f}")
    print(f"  Ratio    = {compute_anisotropy_ratio(D):.4f}")
    
    # Example 3: Verify equipartition
    print("\n3. Verifying equipartition (k=6, Frobenius=6.0):")
    best_d, best_op = find_minimum_anisotropy_diagonal(6, 6.0, 50000)
    balanced_op = 6.0 / np.sqrt(6)
    print(f"  Balanced operator norm: {balanced_op:.6f}")
    print(f"  Best found:            {best_op:.6f}")
    print(f"  Balanced is optimal:   {abs(best_op - balanced_op) < 0.01}")
