#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Hessian Descent Certificate checking.

Implements:
1. Mixed directional log-concavity checker
2. Pairwise determinant condition checker
3. Exchange support verifier
4. Full Hessian descent certificate checker
5. Lorentzian eigenvalue test

All algorithms work with sparse coefficient representations of
homogeneous multivariate polynomials.
"""

import numpy as np
from math import comb
from typing import Dict, Tuple, List, Optional


def generate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all n-tuples of nonneg integers summing to d.

    Args:
        n: Number of variables
        d: Total degree

    Returns:
        List of multi-indices (tuples) with entries summing to d.

    Time complexity: O(C(n+d-1, d)) — the number of such tuples.
    """
    if n == 0:
        return [()]
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in generate_multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


def check_mixed_log_concavity(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
    tol: float = 1e-10
) -> Tuple[bool, List]:
    """Check mixed directional log-concavity for a coefficient function.

    For every multi-index α and directions i, j:
        c(α + eᵢ + eᵢ) · c(α + eⱼ + eⱼ) ≤ c(α + eᵢ + eⱼ)²

    Args:
        coeffs: Dictionary mapping multi-index tuples to coefficients.
        n: Number of variables.
        tol: Numerical tolerance for inequality checking.

    Returns:
        (is_satisfied, violations) where violations is a list of
        (alpha, i, j, lhs, rhs) tuples for failed inequalities.

    Time complexity: O(|support| · n²) per base index.
    """
    violations = []

    # Collect all unique base indices (α values)
    all_indices = set(coeffs.keys())
    max_deg = max(sum(idx) for idx in all_indices) if all_indices else 0

    # For each multi-index in the coefficient map, check all derived inequalities
    base_degrees = set()
    for idx in all_indices:
        deg = sum(idx)
        if deg >= 2:
            base_degrees.add(deg - 2)

    for base_deg in base_degrees:
        for alpha in generate_multiindices(n, base_deg):
            for i in range(n):
                for j in range(n):
                    idx_ii = list(alpha)
                    idx_ii[i] += 2
                    idx_jj = list(alpha)
                    idx_jj[j] += 2
                    idx_ij = list(alpha)
                    idx_ij[i] += 1
                    idx_ij[j] += 1

                    c_ii = coeffs.get(tuple(idx_ii), 0.0)
                    c_jj = coeffs.get(tuple(idx_jj), 0.0)
                    c_ij = coeffs.get(tuple(idx_ij), 0.0)

                    if c_ii * c_jj > c_ij ** 2 + tol:
                        violations.append((alpha, i, j, c_ii * c_jj, c_ij ** 2))

    return len(violations) == 0, violations


def check_pairwise_det_condition(
    matrix: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, List]:
    """Check pairwise determinant condition: A(i,i)·A(j,j) ≤ A(i,j)².

    This is the necessary condition for Lorentzian signature,
    and is sufficient only for n ≤ 2.

    Args:
        matrix: Symmetric n×n matrix.
        tol: Numerical tolerance.

    Returns:
        (is_satisfied, violations)

    Time complexity: O(n²)
    """
    n = matrix.shape[0]
    violations = []
    for i in range(n):
        for j in range(n):
            if matrix[i, i] * matrix[j, j] > matrix[i, j] ** 2 + tol:
                violations.append((i, j, matrix[i, i] * matrix[j, j],
                                   matrix[i, j] ** 2))
    return len(violations) == 0, violations


def check_lorentzian_eigenvalues(
    matrix: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, np.ndarray]:
    """Check if a symmetric matrix has at most one positive eigenvalue.

    Args:
        matrix: Symmetric n×n real matrix.
        tol: Threshold for counting an eigenvalue as positive.

    Returns:
        (is_lorentzian, eigenvalues)

    Time complexity: O(n³) — eigenvalue decomposition.
    """
    eigenvalues = np.linalg.eigvalsh(matrix)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1, eigenvalues


def check_exchange_support(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
    tol: float = 1e-12
) -> Tuple[bool, List]:
    """Check the M-convexity exchange property on support.

    For any α, β in support with α(i) > β(i), there exists j with
    β(j) > α(j) such that α - eᵢ + eⱼ is in support.

    Args:
        coeffs: Coefficient dictionary.
        n: Number of variables.
        tol: Threshold for "in support".

    Returns:
        (is_exchange_closed, violations)

    Time complexity: O(|support|² · n²)
    """
    support = [idx for idx, c in coeffs.items() if abs(c) > tol]
    support_set = set(support)
    violations = []

    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            new_alpha = list(alpha)
                            new_alpha[i] -= 1
                            new_alpha[j] += 1
                            if tuple(new_alpha) in support_set:
                                found = True
                                break
                    if not found:
                        violations.append((alpha, beta, i))

    return len(violations) == 0, violations


def full_certificate_check(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
    tol: float = 1e-10
) -> Dict[str, any]:
    """Run the full Hessian descent certificate check.

    Checks:
    1. Nonnegativity of coefficients
    2. Mixed directional log-concavity
    3. Exchange support property

    Args:
        coeffs: Coefficient dictionary.
        n: Number of variables.
        tol: Numerical tolerance.

    Returns:
        Dictionary with test results.
    """
    results = {}

    # Check nonnegativity
    all_nonneg = all(c >= -tol for c in coeffs.values())
    results['nonneg'] = all_nonneg

    # Check mixed log-concavity
    mixed_ok, mixed_viols = check_mixed_log_concavity(coeffs, n, tol)
    results['mixed_lc'] = mixed_ok
    results['mixed_violations'] = len(mixed_viols)

    # Check exchange support
    exch_ok, exch_viols = check_exchange_support(coeffs, n, tol)
    results['exchange'] = exch_ok
    results['exchange_violations'] = len(exch_viols)

    # Overall certificate
    results['certificate'] = all_nonneg and mixed_ok and exch_ok

    return results


def construct_lorentzian_polynomial(
    weights: np.ndarray,
    degree: int
) -> Dict[Tuple[int, ...], float]:
    """Construct a Lorentzian polynomial as a power of a linear form.

    f = (w₁x₁ + w₂x₂ + ... + wₙxₙ)^d

    Args:
        weights: Positive weight vector of length n.
        degree: Degree d.

    Returns:
        Coefficient dictionary.
    """
    n = len(weights)
    coeffs = {}
    for alpha in generate_multiindices(n, degree):
        coeff = 1.0
        remaining = degree
        for k in range(n):
            coeff *= comb(remaining, alpha[k])
            remaining -= alpha[k]
            coeff *= weights[k] ** alpha[k]
        coeffs[alpha] = coeff
    return coeffs


if __name__ == "__main__":
    print("Hessian Descent Certificate — Algorithm Library")
    print("=" * 50)

    # Example: (x + 2y + 3z)³
    w = np.array([1.0, 2.0, 3.0])
    coeffs = construct_lorentzian_polynomial(w, 3)
    result = full_certificate_check(coeffs, 3)

    print(f"\nPolynomial: (x + 2y + 3z)³")
    print(f"Certificate check results:")
    for key, val in result.items():
        print(f"  {key}: {val}")
