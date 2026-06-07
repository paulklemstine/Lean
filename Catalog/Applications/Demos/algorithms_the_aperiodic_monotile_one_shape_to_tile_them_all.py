#!/usr/bin/env python3
"""
Algorithms for Substitution Tiling Systems.

Type-hinted implementations of the core algorithms from the substitution
spectrum theory of aperiodic monotiles.
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def substitution_iterate(
    matrix: NDArray[np.int64],
    k: int,
    j: int
) -> NDArray[np.int64]:
    """
    Compute tile count vector after k substitution steps.
    
    Args:
        matrix: n×n substitution matrix M
        k: number of substitution steps
        j: starting tile type index
    
    Returns:
        Vector of tile counts c where c[i] = (M^k)[i, j]
    """
    n = matrix.shape[0]
    Mk = np.linalg.matrix_power(matrix, k)
    return Mk[:, j]


def total_area(
    matrix: NDArray[np.int64],
    area: NDArray[np.float64],
    k: int,
    j: int
) -> float:
    """
    Compute total area after k substitution steps starting from tile j.
    
    By the Area Growth Law (Theorem 3.1), this equals
    expansion^(2k) * area[j].
    
    Args:
        matrix: n×n substitution matrix
        area: positive area vector
        k: substitution steps
        j: starting tile type
    
    Returns:
        Total area of the patch
    """
    counts = substitution_iterate(matrix, k, j)
    return float(np.dot(counts.astype(float), area))


def verify_eigenvector(
    matrix: NDArray[np.int64],
    area: NDArray[np.float64],
    expansion: float,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Verify the area eigenvector condition: M^T * area = expansion^2 * area.
    
    Args:
        matrix: n×n substitution matrix
        area: candidate area vector
        expansion: candidate expansion factor
        tol: tolerance for floating point comparison
    
    Returns:
        (is_valid, max_error) tuple
    """
    lhs = matrix.T.astype(float) @ area
    rhs = expansion**2 * area
    max_error = float(np.max(np.abs(lhs - rhs)))
    return max_error < tol, max_error


def compute_expansion_factor(
    matrix: NDArray[np.int64]
) -> Tuple[float, NDArray[np.float64]]:
    """
    Compute the expansion factor (sqrt of dominant eigenvalue) and
    Perron eigenvector of a substitution matrix.
    
    Args:
        matrix: n×n substitution matrix with non-negative entries
    
    Returns:
        (expansion_factor, perron_eigenvector) tuple
    """
    eigenvalues, eigenvectors = np.linalg.eig(matrix.T.astype(float))
    
    # Find the dominant eigenvalue (largest real part)
    idx = np.argmax(np.real(eigenvalues))
    dominant_eigenvalue = float(np.real(eigenvalues[idx]))
    perron_eigenvector = np.real(eigenvectors[:, idx])
    
    # Normalize eigenvector to have positive entries
    if perron_eigenvector[0] < 0:
        perron_eigenvector = -perron_eigenvector
    
    expansion = np.sqrt(dominant_eigenvalue)
    return expansion, perron_eigenvector


def is_rationally_commensurable(
    area: NDArray[np.float64],
    j0: int = 0,
    tol: float = 1e-8,
    max_denom: int = 1000
) -> Tuple[bool, Optional[List[Tuple[int, int]]]]:
    """
    Check if area ratios are approximately rational.
    
    Uses continued fraction approximation to test if area[i]/area[j0]
    is close to a rational number with small denominator.
    
    Args:
        area: area vector
        j0: reference tile index
        tol: tolerance for rational approximation
        max_denom: maximum denominator to consider
    
    Returns:
        (is_commensurable, ratios) where ratios[i] = (p, q) with
        area[i]/area[j0] ≈ p/q
    """
    from fractions import Fraction
    
    ratios: List[Tuple[int, int]] = []
    for i in range(len(area)):
        r = area[i] / area[j0]
        frac = Fraction(r).limit_denominator(max_denom)
        error = abs(r - float(frac))
        ratios.append((frac.numerator, frac.denominator))
        if error > tol:
            return False, ratios
    
    return True, ratios


def spectral_data(
    matrix: NDArray[np.int64]
) -> dict:
    """
    Compute complete spectral data of a substitution matrix.
    
    Returns a dictionary with:
    - trace: matrix trace
    - determinant: matrix determinant
    - eigenvalues: sorted eigenvalues (descending)
    - expansion_factor: sqrt of dominant eigenvalue
    - perron_eigenvector: normalized Perron eigenvector
    - is_pisot_like: whether subdominant eigenvalues have |λ| < 1
    """
    eigenvalues = sorted(np.real(np.linalg.eigvals(matrix.astype(float))), reverse=True)
    expansion, perron_ev = compute_expansion_factor(matrix)
    
    # Normalize Perron eigenvector
    perron_ev = perron_ev / perron_ev[0] if perron_ev[0] != 0 else perron_ev
    
    # Check Pisot-like property
    is_pisot = all(0 < abs(ev) < 1 for ev in eigenvalues[1:]) and eigenvalues[0] > 1
    
    return {
        "trace": float(np.trace(matrix)),
        "determinant": float(np.linalg.det(matrix.astype(float))),
        "eigenvalues": eigenvalues,
        "expansion_factor": expansion,
        "perron_eigenvector": perron_ev.tolist(),
        "is_pisot_like": is_pisot,
    }


def hat_spectrum_system(t: float) -> Tuple[NDArray[np.int64], NDArray[np.float64], float]:
    """
    Construct the hat spectrum substitution system at parameter t ∈ [0, 1].
    
    All systems share the same matrix M = [[4,6],[2,4]] and have
    area vectors proportional to [1, √3], scaled by (1+t).
    
    Args:
        t: parameter in [0, 1]
    
    Returns:
        (matrix, area, expansion) triple
    """
    matrix = np.array([[4, 6], [2, 4]], dtype=np.int64)
    area = (1 + t) * np.array([1.0, np.sqrt(3)])
    expansion = 1 + np.sqrt(3)
    return matrix, area, expansion


def frequency_convergence_rate(
    matrix: NDArray[np.int64],
    j: int,
    k_max: int = 20
) -> List[float]:
    """
    Compute the rate of convergence of tile frequencies to the Perron
    eigenvector direction.
    
    The convergence rate is governed by the ratio |λ₂/λ₁| where λ₁, λ₂
    are the dominant and subdominant eigenvalues.
    
    Args:
        matrix: substitution matrix
        j: starting tile type
        k_max: maximum number of steps
    
    Returns:
        List of distances from Perron direction at each step
    """
    _, perron_ev = compute_expansion_factor(matrix)
    perron_direction = perron_ev / np.linalg.norm(perron_ev)
    
    errors: List[float] = []
    for k in range(1, k_max + 1):
        counts = substitution_iterate(matrix, k, j).astype(float)
        if np.linalg.norm(counts) > 0:
            direction = counts / np.linalg.norm(counts)
            # Angular distance
            cos_angle = abs(np.dot(direction, perron_direction))
            error = np.arccos(min(cos_angle, 1.0))
            errors.append(float(error))
        else:
            errors.append(float('inf'))
    
    return errors


if __name__ == "__main__":
    # Example usage
    M = np.array([[4, 6], [2, 4]], dtype=np.int64)
    
    print("=== Hat Matrix Spectral Data ===")
    data = spectral_data(M)
    for key, val in data.items():
        print(f"  {key}: {val}")
    
    print("\n=== Eigenvector Verification ===")
    area = np.array([1.0, np.sqrt(3)])
    valid, error = verify_eigenvector(M, area, 1 + np.sqrt(3))
    print(f"  Valid: {valid}, max error: {error:.2e}")
    
    print("\n=== Rational Commensurability Check ===")
    is_comm, ratios = is_rationally_commensurable(area)
    print(f"  Commensurable: {is_comm}")
    print(f"  Approximate ratios: {ratios}")
    
    print("\n=== Frequency Convergence ===")
    errors = frequency_convergence_rate(M, 0, k_max=10)
    for k, err in enumerate(errors, 1):
        print(f"  k={k}: angular error = {err:.6e}")
