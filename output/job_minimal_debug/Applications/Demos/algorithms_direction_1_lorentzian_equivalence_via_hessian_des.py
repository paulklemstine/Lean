#!/usr/bin/env python3
"""
algorithms.py — Algorithmic implementations for Hessian Descent Certificate Theory

Implements the core algorithms for checking Lorentzian polynomial properties
through discrete coefficient inequalities rather than spectral computation.

Key algorithms:
  - check_hessian_descent_certificate: O(n^2 * M) certificate checker
  - check_lorentzian_eigenvalue: O(n^3) spectral checker (for comparison)
  - generate_derivative_leaves: compute all quadratic derivative leaves
  - verify_full_descent: check certificate at all derivative levels
"""

import numpy as np
from typing import Dict, Tuple, List, Optional, Set
from itertools import combinations_with_replacement


def multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices (α₁,...,αₙ) with Σαᵢ = d.

    Time: O(C(n+d-1, d)) — the number of such indices.
    Space: O(n * C(n+d-1, d)).

    Args:
        n: number of variables
        d: total degree

    Returns:
        List of tuples, each summing to d.

    Example:
        >>> multiindices(2, 2)
        [(0, 2), (1, 1), (2, 0)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


def check_mixed_lc(coeffs: Dict[Tuple, float], n: int, d: int,
                   tol: float = 1e-10) -> Tuple[bool, Optional[str]]:
    """Check mixed directional log-concavity for polynomial coefficients.

    For every multi-index α of degree d-2 and every pair i, j:
        c(α + eᵢ + eᵢ) · c(α + eⱼ + eⱼ) ≤ c(α + eᵢ + eⱼ)²

    Time complexity: O(n² · |{α : |α| = d-2}|) = O(n² · C(n+d-3, d-2))
    Space complexity: O(|coeffs|)

    Args:
        coeffs: polynomial coefficients indexed by multi-index tuples
        n: number of variables
        d: total degree
        tol: numerical tolerance

    Returns:
        (passed, violation_msg) where violation_msg describes the first failure
    """
    if d < 2:
        return True, None

    def get(idx):
        return coeffs.get(tuple(idx), 0.0)

    for alpha in multiindices(n, d - 2):
        alpha_list = list(alpha)
        for i in range(n):
            for j in range(i, n):  # symmetry: only check i ≤ j
                idx_ii = alpha_list.copy()
                idx_ii[i] += 2
                idx_jj = alpha_list.copy()
                idx_jj[j] += 2
                idx_ij = alpha_list.copy()
                idx_ij[i] += 1
                idx_ij[j] += 1

                lhs = get(idx_ii) * get(idx_jj)
                rhs = get(idx_ij) ** 2

                if lhs > rhs + tol:
                    return False, (f"Violation at α={alpha}, i={i}, j={j}: "
                                   f"{get(idx_ii):.6f}*{get(idx_jj):.6f} = {lhs:.6f} > "
                                   f"{get(idx_ij):.6f}² = {rhs:.6f}")
    return True, None


def check_axis_lc(coeffs: Dict[Tuple, float], n: int, d: int,
                  tol: float = 1e-10) -> Tuple[bool, Optional[str]]:
    """Check axis directional log-concavity.

    For every α and direction i:
        c(α + 2eᵢ) · c(α) ≤ c(α + eᵢ)²

    Time complexity: O(n · Σ_{k=0}^{d} |{α : |α| = k}|) = O(n · C(n+d, d+1))

    Args:
        coeffs: polynomial coefficients
        n: number of variables
        d: total degree
        tol: numerical tolerance

    Returns:
        (passed, violation_msg)
    """
    def get(idx):
        return coeffs.get(tuple(idx), 0.0)

    for deg in range(d - 1):
        for alpha in multiindices(n, deg):
            alpha_list = list(alpha)
            for i in range(n):
                if deg + 2 > d:
                    continue
                idx_1 = alpha_list.copy()
                idx_1[i] += 1
                idx_2 = alpha_list.copy()
                idx_2[i] += 2

                c0 = get(alpha_list)
                c1 = get(idx_1)
                c2 = get(idx_2)

                if c2 * c0 > c1 ** 2 + tol:
                    return False, (f"Violation at α={alpha}, i={i}: "
                                   f"{c2:.6f}*{c0:.6f} > {c1:.6f}²")
    return True, None


def check_exchange_support(coeffs: Dict[Tuple, float], n: int, d: int,
                           tol: float = 1e-12) -> Tuple[bool, Optional[str]]:
    """Check exchange-closed support (M-convexity).

    For α, β in support with α(i) > β(i), ∃ j with β(j) > α(j) and
    α - eᵢ + eⱼ in support.

    Time complexity: O(|supp|² · n²) in the worst case.

    Args:
        coeffs: polynomial coefficients
        n: number of variables
        d: total degree
        tol: threshold for "in support"

    Returns:
        (passed, violation_msg)
    """
    support = [k for k, v in coeffs.items()
               if abs(v) > tol and sum(k) == d]

    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j] and alpha[i] >= 1:
                            new = list(alpha)
                            new[i] -= 1
                            new[j] += 1
                            if tuple(new) in coeffs and abs(coeffs[tuple(new)]) > tol:
                                found = True
                                break
                    if not found:
                        return False, (f"Exchange failure: α={alpha}, β={beta}, "
                                       f"i={i}, no valid j found")
    return True, None


def check_hessian_descent_certificate(
    coeffs: Dict[Tuple, float], n: int, d: int,
    tol: float = 1e-10
) -> Dict[str, any]:
    """Full Hessian descent certificate check.

    Checks all three conditions:
    1. Mixed directional log-concavity
    2. Axis directional log-concavity
    3. Exchange-closed support

    Pseudocode:
        FUNCTION CheckCertificate(f, n, d):
            FOR each α with |α| = d-2:
                FOR each pair (i, j):
                    IF c(α+2eᵢ)·c(α+2eⱼ) > c(α+eᵢ+eⱼ)²:
                        RETURN FAIL("mixed LC")
            FOR each α, each i:
                IF c(α+2eᵢ)·c(α) > c(α+eᵢ)²:
                    RETURN FAIL("axis LC")
            FOR each (α, β) in supp × supp:
                FOR each i with α(i) > β(i):
                    IF no j with β(j) > α(j) and α-eᵢ+eⱼ ∈ supp:
                        RETURN FAIL("exchange")
            RETURN PASS

    Time: O(n² · C(n+d-3,d-2) + |supp|² · n²)
    Space: O(|coeffs|)

    Returns:
        Dict with keys: 'passed', 'mixed_lc', 'axis_lc', 'exchange', 'details'
    """
    result = {
        'passed': False,
        'mixed_lc': False,
        'axis_lc': False,
        'exchange': False,
        'details': []
    }

    mlc_ok, mlc_msg = check_mixed_lc(coeffs, n, d, tol)
    result['mixed_lc'] = mlc_ok
    if mlc_msg:
        result['details'].append(mlc_msg)

    alc_ok, alc_msg = check_axis_lc(coeffs, n, d, tol)
    result['axis_lc'] = alc_ok
    if alc_msg:
        result['details'].append(alc_msg)

    exch_ok, exch_msg = check_exchange_support(coeffs, n, d, tol)
    result['exchange'] = exch_ok
    if exch_msg:
        result['details'].append(exch_msg)

    result['passed'] = mlc_ok and alc_ok and exch_ok
    return result


def check_lorentzian_eigenvalue(A: np.ndarray, tol: float = 1e-10) -> Dict[str, any]:
    """Spectral Lorentzian check (for comparison).

    Computes eigenvalues and checks at most one is positive.

    Time: O(n³) for eigenvalue decomposition.
    Space: O(n²).

    Args:
        A: symmetric matrix
        tol: tolerance for positive eigenvalue

    Returns:
        Dict with eigenvalues, Lorentzian status, number of positive eigenvalues
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    n_positive = np.sum(eigenvalues > tol)

    return {
        'eigenvalues': eigenvalues,
        'is_lorentzian': n_positive <= 1,
        'n_positive': int(n_positive),
        'largest_eigenvalue': float(eigenvalues[0]),
        'second_largest': float(eigenvalues[1]) if len(eigenvalues) > 1 else None
    }


def generate_derivative_leaves(coeffs: Dict[Tuple, float], n: int, d: int
                                ) -> List[Dict[Tuple, float]]:
    """Generate all quadratic derivative leaves of a degree-d polynomial.

    Each leaf is obtained by differentiating d-2 times.
    The leaf is itself a degree-2 polynomial.

    Time: O(C(n+d-3, d-2) · n² · d)

    Args:
        coeffs: polynomial coefficients
        n: number of variables
        d: total degree

    Returns:
        List of (alpha, leaf_coeffs) where alpha is the differentiation multi-index
    """
    if d < 2:
        return [coeffs]

    leaves = []
    for alpha in multiindices(n, d - 2):
        # Compute the quadratic leaf: derivative of order alpha
        leaf = {}
        for beta in multiindices(n, 2):
            # The coefficient of x^beta in D^alpha f
            # equals (alpha+beta)! / beta! * c(alpha+beta)
            full_idx = tuple(a + b for a, b in zip(alpha, beta))
            if full_idx in coeffs:
                # Multinomial coefficient
                factor = 1.0
                for k in range(n):
                    for m in range(alpha[k]):
                        factor *= (beta[k] + alpha[k] - m)
                leaf[beta] = coeffs[full_idx] * factor
        leaves.append((alpha, leaf))

    return leaves


def verify_full_descent(coeffs: Dict[Tuple, float], n: int, d: int
                        ) -> Dict[str, any]:
    """Verify the Hessian descent certificate at all derivative levels.

    Checks that every quadratic derivative leaf satisfies the mixed LC condition.

    Time: O(C(n+d-3, d-2) · n²)
    """
    if d < 2:
        return {'passed': True, 'n_leaves': 0, 'failures': []}

    leaves = generate_derivative_leaves(coeffs, n, d)
    failures = []

    for alpha, leaf_coeffs in leaves:
        mlc_ok, msg = check_mixed_lc(leaf_coeffs, n, 2)
        if not mlc_ok:
            failures.append({'alpha': alpha, 'message': msg})

    return {
        'passed': len(failures) == 0,
        'n_leaves': len(leaves),
        'failures': failures
    }


# Example usage
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Example 1: Rank-1 quadratic (always Lorentzian)
    print("Example 1: Rank-1 quadratic u = [1, 2, 3]")
    u = np.array([1.0, 2.0, 3.0])
    A = np.outer(u, u)
    coeffs = {}
    n = 3
    for i in range(n):
        idx = [0] * n; idx[i] = 2
        coeffs[tuple(idx)] = A[i, i]
    for i in range(n):
        for j in range(i + 1, n):
            idx = [0] * n; idx[i] = 1; idx[j] = 1
            coeffs[tuple(idx)] = 2 * A[i, j]

    cert = check_hessian_descent_certificate(coeffs, n, 2)
    spec = check_lorentzian_eigenvalue(A)
    print(f"  Certificate: {cert['passed']}")
    print(f"  Spectral: {spec['is_lorentzian']}")
    print(f"  Eigenvalues: {np.round(spec['eigenvalues'], 4)}")
    print()

    # Example 2: Counterexample matrix
    print("Example 2: Counterexample matrix [[1,1,1],[1,1,-1],[1,-1,1]]")
    A2 = np.array([[1, 1, 1], [1, 1, -1], [1, -1, 1]], dtype=float)
    spec2 = check_lorentzian_eigenvalue(A2)
    print(f"  Spectral: {spec2['is_lorentzian']}")
    print(f"  Eigenvalues: {np.round(spec2['eigenvalues'], 4)}")
    print(f"  #positive: {spec2['n_positive']}")
    print()

    # Example 3: Higher degree polynomial
    print("Example 3: Degree-4 polynomial in 3 variables")
    coeffs4 = {}
    for alpha in multiindices(3, 4):
        # Lorentzian-compatible coefficients (products of linear forms)
        c = 1.0
        for v in alpha:
            c *= (v + 1)
        coeffs4[alpha] = c
    descent = verify_full_descent(coeffs4, 3, 4)
    print(f"  Full descent check: {descent['passed']}")
    print(f"  Number of leaves: {descent['n_leaves']}")
    print(f"  Failures: {len(descent['failures'])}")
