#!/usr/bin/env python3
"""
algorithms.py — Certified Perturbation Tolerance Algorithms

Implements the sharp perturbation tolerance algorithm and its
verification pipeline, based on the theorem:

  If J has spectral gap ε and E has |E_ij| ≤ ε/(2n),
  then J + E preserves signature/definiteness.

Algorithms:
1. sharp_certified_tolerance — compute safe perturbation bound
2. verify_perturbation_safe — check if a perturbation is certified safe
3. spectral_gap_certificate — compute spectral gap with error bounds
4. robustness_report — full robustness analysis of a coupling matrix
"""

from typing import Tuple, Optional, Dict, Any
import numpy as np
from numpy.linalg import eigvalsh


def sharp_certified_tolerance(epsilon: float, n: int) -> float:
    """
    Compute the sharp certified perturbation tolerance.

    Given a spectral gap ε and dimension n, returns the maximum
    entrywise perturbation δ that provably preserves signature:

        δ = ε / (2n)

    This is the dimension-optimal bound, improving the crude ε/(2n²).

    Parameters
    ----------
    epsilon : float
        Spectral gap (minimum |eigenvalue|) of the matrix.
    n : int
        Matrix dimension.

    Returns
    -------
    float
        Safe entrywise perturbation tolerance.

    Complexity
    ----------
    Time: O(1)
    Space: O(1)

    Examples
    --------
    >>> sharp_certified_tolerance(1.0, 10)
    0.05
    >>> sharp_certified_tolerance(2.0, 100)
    0.01
    """
    if n <= 0:
        raise ValueError("Dimension must be positive")
    if epsilon < 0:
        raise ValueError("Spectral gap must be non-negative")
    return epsilon / (2.0 * n)


def crude_certified_tolerance(epsilon: float, n: int) -> float:
    """
    Compute the crude (pre-improvement) perturbation tolerance.

    Uses the old bound δ = ε/(2n²), which is n times too conservative.

    Parameters
    ----------
    epsilon : float
        Spectral gap.
    n : int
        Matrix dimension.

    Returns
    -------
    float
        Conservative perturbation tolerance.
    """
    if n <= 0:
        raise ValueError("Dimension must be positive")
    return epsilon / (2.0 * n * n)


def spectral_gap_certificate(J: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of a symmetric matrix with eigenvalue certificate.

    Parameters
    ----------
    J : np.ndarray
        Symmetric matrix (n×n).

    Returns
    -------
    Tuple[float, np.ndarray]
        (spectral_gap, eigenvalues) where spectral_gap = min(|λ_i|).

    Complexity
    ----------
    Time: O(n³)  [eigenvalue decomposition]
    Space: O(n²)
    """
    assert J.shape[0] == J.shape[1], "Matrix must be square"
    assert np.allclose(J, J.T), "Matrix must be symmetric"

    eigenvalues = eigvalsh(J)
    gap = float(np.min(np.abs(eigenvalues)))
    return gap, eigenvalues


def verify_perturbation_safe(
    J: np.ndarray,
    E: np.ndarray,
    use_sharp: bool = True
) -> Dict[str, Any]:
    """
    Verify whether a perturbation E is certifiably safe for matrix J.

    Uses either the sharp bound ε/(2n) or the crude bound ε/(2n²).

    Parameters
    ----------
    J : np.ndarray
        Original symmetric coupling matrix.
    E : np.ndarray
        Symmetric perturbation matrix.
    use_sharp : bool
        If True, use the sharp ε/(2n) bound. If False, use ε/(2n²).

    Returns
    -------
    Dict[str, Any]
        Dictionary with keys:
        - 'certified_safe': bool — whether the perturbation is certified safe
        - 'max_entry': float — max |E_ij|
        - 'tolerance': float — computed safe tolerance
        - 'spectral_gap': float — spectral gap of J
        - 'margin': float — tolerance - max_entry (positive = safe)

    Complexity
    ----------
    Time: O(n³) for eigenvalue computation + O(n²) for entry check
    Space: O(n²)
    """
    n = J.shape[0]
    gap, eigenvalues = spectral_gap_certificate(J)

    max_entry = float(np.max(np.abs(E)))

    if use_sharp:
        tolerance = sharp_certified_tolerance(gap, n)
    else:
        tolerance = crude_certified_tolerance(gap, n)

    return {
        'certified_safe': max_entry <= tolerance,
        'max_entry': max_entry,
        'tolerance': tolerance,
        'spectral_gap': gap,
        'eigenvalues': eigenvalues,
        'margin': tolerance - max_entry,
        'method': 'sharp (ε/2n)' if use_sharp else 'crude (ε/2n²)',
    }


def robustness_report(J: np.ndarray) -> Dict[str, Any]:
    """
    Full robustness analysis of a coupling matrix.

    Computes spectral gap, both tolerance levels, improvement factor,
    signature, and practical recommendations.

    Parameters
    ----------
    J : np.ndarray
        Symmetric coupling matrix.

    Returns
    -------
    Dict[str, Any]
        Comprehensive robustness report.

    Complexity
    ----------
    Time: O(n³)
    Space: O(n²)
    """
    n = J.shape[0]
    gap, eigenvalues = spectral_gap_certificate(J)

    n_pos = int(np.sum(eigenvalues > 1e-10))
    n_neg = int(np.sum(eigenvalues < -1e-10))
    n_zero = n - n_pos - n_neg

    sharp_tol = sharp_certified_tolerance(gap, n)
    crude_tol = crude_certified_tolerance(gap, n)

    return {
        'dimension': n,
        'spectral_gap': gap,
        'eigenvalues': eigenvalues.tolist(),
        'signature': (n_pos, n_neg, n_zero),
        'sharp_tolerance': sharp_tol,
        'crude_tolerance': crude_tol,
        'improvement_factor': n,
        'wasted_region_pct': (1 - crude_tol / sharp_tol) * 100 if sharp_tol > 0 else 0,
        'is_positive_definite': n_neg == 0 and n_zero == 0,
        'is_negative_definite': n_pos == 0 and n_zero == 0,
        'is_lorentzian': n_pos <= 1 and n_zero == 0,
        'residual_gap_after_sharp_pert': gap / 2,
    }


def certified_perturbation_envelope(
    J: np.ndarray,
    directions: Optional[np.ndarray] = None,
    n_directions: int = 100,
) -> Dict[str, Any]:
    """
    Compute the certified perturbation envelope: for each direction
    in matrix space, find the maximum safe perturbation magnitude.

    Parameters
    ----------
    J : np.ndarray
        Symmetric coupling matrix.
    directions : np.ndarray, optional
        Specific perturbation directions to test (each n×n symmetric).
    n_directions : int
        Number of random directions if not specified.

    Returns
    -------
    Dict[str, Any]
        Envelope data including directional tolerances.
    """
    n = J.shape[0]
    gap, _ = spectral_gap_certificate(J)
    sharp_tol = sharp_certified_tolerance(gap, n)

    if directions is None:
        directions = []
        for _ in range(n_directions):
            D = np.random.randn(n, n)
            D = (D + D.T) / 2
            # Normalize to have max entry = 1
            max_val = np.max(np.abs(D))
            if max_val > 0:
                D = D / max_val
            directions.append(D)

    results = []
    for D in directions:
        max_entry = np.max(np.abs(D))
        if max_entry > 0:
            max_safe_scale = sharp_tol / max_entry
        else:
            max_safe_scale = float('inf')
        results.append({
            'max_entry': max_entry,
            'max_safe_scale': max_safe_scale,
        })

    return {
        'spectral_gap': gap,
        'sharp_tolerance': sharp_tol,
        'n_directions': len(directions),
        'directional_results': results,
        'min_safe_scale': min(r['max_safe_scale'] for r in results),
    }


# Example usage
if __name__ == "__main__":
    print("Sharp Perturbation Scale — Algorithm Demonstrations")
    print("=" * 55)

    # Example 1: Simple positive definite matrix
    n = 10
    J = np.eye(n) * 2.0
    report = robustness_report(J)

    print(f"\nExample 1: {n}×{n} scaled identity (2I)")
    print(f"  Spectral gap: {report['spectral_gap']:.4f}")
    print(f"  Sharp tolerance: {report['sharp_tolerance']:.6f}")
    print(f"  Crude tolerance: {report['crude_tolerance']:.6f}")
    print(f"  Improvement: {report['improvement_factor']}×")
    print(f"  Wasted region: {report['wasted_region_pct']:.1f}%")

    # Example 2: Ising coupling matrix
    n = 8
    J_ising = -np.ones((n, n)) + (n + 1) * np.eye(n)
    report2 = robustness_report(J_ising)

    print(f"\nExample 2: {n}×{n} Ising coupling matrix")
    print(f"  Spectral gap: {report2['spectral_gap']:.4f}")
    print(f"  Signature: {report2['signature']}")
    print(f"  Sharp tolerance: {report2['sharp_tolerance']:.6f}")
    print(f"  Crude tolerance: {report2['crude_tolerance']:.6f}")
    print(f"  Improvement: {report2['improvement_factor']}×")

    # Example 3: Verify a specific perturbation
    E = np.random.uniform(-0.05, 0.05, (n, n))
    E = (E + E.T) / 2
    result_sharp = verify_perturbation_safe(J_ising, E, use_sharp=True)
    result_crude = verify_perturbation_safe(J_ising, E, use_sharp=False)

    print(f"\nExample 3: Perturbation verification")
    print(f"  Max |E_ij|: {result_sharp['max_entry']:.6f}")
    print(f"  Sharp: {'SAFE' if result_sharp['certified_safe'] else 'UNSAFE'} "
          f"(margin: {result_sharp['margin']:.6f})")
    print(f"  Crude: {'SAFE' if result_crude['certified_safe'] else 'UNSAFE'} "
          f"(margin: {result_crude['margin']:.6f})")
