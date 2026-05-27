#!/usr/bin/env python3
"""
algorithms.py — Certified Lorentzian Stability Algorithms

Implements the verified algorithms from the Lean formalization:
1. Certified perturbation radius computation
2. Spectral gap estimation for Hessians
3. Lorentzianity checking with margin
"""

import numpy as np
from typing import Tuple, Optional
from itertools import combinations


def certified_perturbation_radius(epsilon: float, n: int) -> float:
    """
    Compute the certified perturbation radius for Lorentzian stability.
    
    Given a spectral gap epsilon and dimension n, returns the maximum
    entrywise perturbation delta such that Lorentzianity is preserved.
    
    This implements the 1/n law: delta = epsilon / n.
    
    Corresponds to Lean: certifiedPerturbationRadius
    
    Args:
        epsilon: Spectral gap (minimum negative eigenvalue magnitude on w-perp)
        n: Ambient dimension
        
    Returns:
        Certified maximum perturbation magnitude
        
    Example:
        >>> certified_perturbation_radius(1.0, 10)
        0.1
    """
    if n <= 0:
        return 0.0
    return epsilon / n


def old_certified_perturbation_radius(epsilon: float, n: int) -> float:
    """
    Old certified perturbation radius using the 1/n² law.
    
    This is the previous, suboptimal bound.
    
    Args:
        epsilon: Spectral gap
        n: Ambient dimension
        
    Returns:
        Old certified maximum perturbation magnitude
        
    Example:
        >>> old_certified_perturbation_radius(1.0, 10)
        0.01
    """
    if n <= 0:
        return 0.0
    return epsilon / (n ** 2)


def spectral_gap_of_matrix(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of a symmetric matrix for Lorentzian signature.
    
    The spectral gap is the magnitude of the least-negative eigenvalue
    on the orthogonal complement of the most-positive eigenvector.
    
    Args:
        A: Symmetric matrix (n x n)
        
    Returns:
        Tuple of (gap, witness_direction_w)
        
    Example:
        >>> A = np.array([[-1, 0], [0, -2]])
        >>> gap, w = spectral_gap_of_matrix(A)
        >>> gap
        1.0
    """
    n = A.shape[0]
    eigvals, eigvecs = np.linalg.eigh(A)
    
    # Sort eigenvalues in descending order
    idx = np.argsort(eigvals)[::-1]
    eigvals = eigvals[idx]
    eigvecs = eigvecs[:, idx]
    
    # The witness direction is the eigenvector of the largest eigenvalue
    w = eigvecs[:, 0]
    
    # The gap is the magnitude of the second eigenvalue (first negative one)
    if n < 2:
        return 0.0, w
    
    negative_eigs = eigvals[eigvals < 0]
    if len(negative_eigs) == 0:
        return 0.0, w
    
    gap = float(np.min(np.abs(negative_eigs)))
    return gap, w


def check_lorentzian_signature(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a symmetric matrix has at most one positive eigenvalue.
    
    Args:
        A: Symmetric matrix
        tol: Tolerance for eigenvalue positivity
        
    Returns:
        True if at most one eigenvalue is positive
        
    Example:
        >>> A = np.diag([1, -1, -1])
        >>> check_lorentzian_signature(A)
        True
    """
    eigvals = np.linalg.eigvalsh(A)
    return int(np.sum(eigvals > tol)) <= 1


def certified_lorentzian_radius(
    H: np.ndarray, 
    E_direction: np.ndarray
) -> float:
    """
    Compute the certified maximum t >= 0 such that H + t*E remains Lorentzian.
    
    Uses a combination of:
    1. Spectral gap computation for the base matrix H
    2. Operator norm estimation for the perturbation direction E
    3. The sharp 1/n bound for entrywise perturbations
    
    Corresponds to Lean: certifiedPerturbationRadius_sound
    
    Args:
        H: Base Hessian matrix (symmetric, Lorentzian signature)
        E_direction: Perturbation direction matrix
        
    Returns:
        Certified maximum scaling t
        
    Example:
        >>> H = np.diag([2, -1, -1])
        >>> E = np.ones((3, 3)) * 0.1
        >>> t = certified_lorentzian_radius(H, E)
        >>> t > 0
        True
    """
    n = H.shape[0]
    gap, _ = spectral_gap_of_matrix(H)
    
    if gap <= 0:
        return 0.0
    
    # Compute the quadratic form bound of E
    # |Q_E(v)| <= n * max|E_ij| * ||v||^2
    max_entry = np.max(np.abs(E_direction))
    
    if max_entry <= 0:
        return float('inf')
    
    # certified radius: gap / (n * max_entry)
    # because t * max_entry <= gap / n implies preservation
    return gap / (n * max_entry)


def bisection_lorentzian_radius(
    H: np.ndarray,
    E: np.ndarray,
    tol: float = 1e-8,
    max_iter: int = 100
) -> float:
    """
    Numerical bisection to find the destruction threshold.
    
    Finds the maximum t such that H + t*E has Lorentzian signature.
    
    Args:
        H: Base Hessian matrix
        E: Perturbation matrix
        tol: Convergence tolerance
        max_iter: Maximum iterations
        
    Returns:
        Approximate destruction threshold
    """
    lo, hi = 0.0, 10.0
    
    # First, find an upper bound where Lorentzianity is destroyed
    while check_lorentzian_signature(H + hi * E) and hi < 1e6:
        hi *= 2
    
    if hi >= 1e6:
        return float('inf')
    
    # Binary search
    for _ in range(max_iter):
        mid = (lo + hi) / 2
        if check_lorentzian_signature(H + mid * E):
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    
    return (lo + hi) / 2


def quadform_bound_sharp(A: np.ndarray, v: np.ndarray) -> float:
    """
    Compute the sharp quadratic form bound |Q_A(v)| <= n * B * ||v||^2.
    
    This implements the improved bound from the Lean theorem
    quadFormBound_of_entry_bound_sharp.
    
    Args:
        A: Matrix
        v: Vector
        
    Returns:
        The bound n * max|A_ij| * ||v||^2
    """
    n = A.shape[0]
    B = np.max(np.abs(A))
    sq_norm = np.sum(v ** 2)
    return n * B * sq_norm


def quadform_bound_old(A: np.ndarray, v: np.ndarray) -> float:
    """
    Compute the old (suboptimal) quadratic form bound |Q_A(v)| <= n^2 * B * ||v||^2.
    
    Args:
        A: Matrix
        v: Vector
        
    Returns:
        The bound n^2 * max|A_ij| * ||v||^2
    """
    n = A.shape[0]
    B = np.max(np.abs(A))
    sq_norm = np.sum(v ** 2)
    return n ** 2 * B * sq_norm


def elementary_symmetric_hessian(n: int, k: int, x: Optional[np.ndarray] = None) -> np.ndarray:
    """
    Compute the Hessian of e_k(x_1,...,x_n) at a point x.
    
    Args:
        n: Number of variables
        k: Degree of elementary symmetric polynomial
        x: Evaluation point (default: all ones)
        
    Returns:
        n x n Hessian matrix
    """
    if x is None:
        x = np.ones(n)
    
    H = np.zeros((n, n))
    if k < 2:
        return H
    
    for i in range(n):
        for j in range(n):
            if i != j:
                remaining = [l for l in range(n) if l != i and l != j]
                if k - 2 > len(remaining):
                    H[i, j] = 0.0
                elif k - 2 == 0:
                    H[i, j] = 1.0
                else:
                    val = 0.0
                    for subset in combinations(remaining, k - 2):
                        prod = 1.0
                        for idx in subset:
                            prod *= x[idx]
                        val += prod
                    H[i, j] = val
    return H


# Example usage
if __name__ == '__main__':
    print("=== Certified Lorentzian Stability Algorithms ===\n")
    
    # Example 1: Simple 3x3 Lorentzian matrix
    H = np.diag([3.0, -1.0, -1.0])
    gap, w = spectral_gap_of_matrix(H)
    print(f"Matrix: diag(3, -1, -1)")
    print(f"  Spectral gap: {gap}")
    print(f"  Witness direction: {w}")
    print(f"  Old certified radius (1/n²): {old_certified_perturbation_radius(gap, 3):.6f}")
    print(f"  New certified radius (1/n):  {certified_perturbation_radius(gap, 3):.6f}")
    
    # Example 2: Elementary symmetric polynomial
    print(f"\n--- e_3 in 6 variables ---")
    H = elementary_symmetric_hessian(6, 3)
    gap, w = spectral_gap_of_matrix(H)
    print(f"  Spectral gap: {gap:.4f}")
    print(f"  Old certified radius (1/n²): {old_certified_perturbation_radius(gap, 6):.6f}")
    print(f"  New certified radius (1/n):  {certified_perturbation_radius(gap, 6):.6f}")
    
    # Example 3: Certified radius with specific perturbation
    E = np.random.randn(6, 6)
    E = (E + E.T) / 2
    t_cert = certified_lorentzian_radius(H, E)
    t_num = bisection_lorentzian_radius(H, E)
    print(f"\n  Certified radius for random perturbation: {t_cert:.6f}")
    print(f"  Numerical destruction threshold:          {t_num:.6f}")
    print(f"  Ratio (numerical/certified):              {t_num/t_cert:.2f}x")
