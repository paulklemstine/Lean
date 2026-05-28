#!/usr/bin/env python3
"""
Algorithms for Spectral Embedding: Matrix Positivity to Lorentzian Leaves

Implements the constructive spectral embedding:
    A ↦ P_A(t, x₁,...,xₙ) = t² · Q_A(x)

and the verification algorithms for the Lorentzian leaf conditions.

Key algorithms:
1. spectral_embed: Construct the spectral embedding polynomial
2. check_leaf_conditions: Verify all Lorentzian leaf conditions
3. block_zero_extend: Construct the block-zero extension matrix
4. eigenvalue_inertia: Compute the inertia (n+, n0, n-) of a matrix
"""

from typing import Tuple, List, Dict, Optional
from fractions import Fraction
import numpy as np


def eigenvalue_inertia(A: np.ndarray, tol: float = 1e-10) -> Tuple[int, int, int]:
    """
    Compute the inertia (n+, n0, n-) of a symmetric matrix A.
    
    Args:
        A: Symmetric real matrix
        tol: Tolerance for zero eigenvalues
    
    Returns:
        (n_positive, n_zero, n_negative)
    
    Complexity: O(n³) via eigenvalue decomposition
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_pos = int(np.sum(eigenvalues > tol))
    n_neg = int(np.sum(eigenvalues < -tol))
    n_zero = len(eigenvalues) - n_pos - n_neg
    return n_pos, n_zero, n_neg


def block_zero_extend(A: np.ndarray) -> np.ndarray:
    """
    Construct the block-zero extension B of A.
    
    B = [[0, 0, ..., 0],
         [0,          ],
         [0,    A     ],
         [0,          ]]
    
    This is the matrix-level representation of the spectral embedding.
    The key property: HasAtMostOnePositiveEigenvalue(B) ⟺ HasAtMostOnePositiveEigenvalue(A).
    
    Args:
        A: n×n symmetric matrix
    
    Returns:
        (n+1)×(n+1) block-zero-extended matrix
    
    Complexity: O(n²) — copies A entries
    """
    n = A.shape[0]
    B = np.zeros((n + 1, n + 1))
    B[1:, 1:] = A
    return B


def spectral_embed_coefficients(A: np.ndarray) -> Dict[Tuple[int, ...], float]:
    """
    Construct the coefficients of the spectral embedding polynomial.
    
    P_A(t, x₁,...,xₙ) = t² · Q_A(x) = t² · ∑_{i,j} A_{ij} x_i x_j
    
    The monomial t² x_i x_j has coefficient A_{ij}.
    
    Args:
        A: n×n symmetric matrix
    
    Returns:
        Dictionary mapping exponent tuples to coefficients.
        Exponent tuple has length n+1: (deg_t, deg_x₁, ..., deg_xₙ)
    
    Complexity: O(n²) — iterates over matrix entries
    """
    n = A.shape[0]
    coeffs = {}
    
    for i in range(n):
        for j in range(n):
            if abs(A[i, j]) < 1e-15:
                continue
            exponent = [0] * (n + 1)
            exponent[0] = 2  # t²
            exponent[i + 1] += 1
            exponent[j + 1] += 1
            key = tuple(exponent)
            coeffs[key] = coeffs.get(key, 0) + A[i, j]
    
    # Remove near-zero coefficients
    return {k: v for k, v in coeffs.items() if abs(v) > 1e-15}


def spectral_embed_rational(A_rational: List[List[Fraction]]) -> Dict[Tuple[int, ...], Fraction]:
    """
    Exact rational coefficient construction.
    
    Given A with rational entries (as fractions), compute the exact
    rational coefficients of P_A.
    
    Args:
        A_rational: n×n matrix with Fraction entries
    
    Returns:
        Dictionary mapping exponent tuples to Fraction coefficients
    
    Complexity: O(n²)
    """
    n = len(A_rational)
    coeffs: Dict[Tuple[int, ...], Fraction] = {}
    
    for i in range(n):
        for j in range(n):
            if A_rational[i][j] == 0:
                continue
            exponent = [0] * (n + 1)
            exponent[0] = 2
            exponent[i + 1] += 1
            exponent[j + 1] += 1
            key = tuple(exponent)
            coeffs[key] = coeffs.get(key, Fraction(0)) + A_rational[i][j]
    
    return {k: v for k, v in coeffs.items() if v != 0}


def leaf_hessian_critical(A: np.ndarray) -> np.ndarray:
    """
    Compute the Hessian of the critical leaf ∂²P/∂t².
    
    The critical leaf is ∂²P_A/∂t² = 2·Q_A(x), which is a quadratic
    in variables (t, x₁, ..., xₙ). Its Hessian is:
    
    H = [[0, 0, ..., 0],
         [0,          ],
         [0,   2A     ],
         [0,          ]]
    
    This is exactly 2 · blockZeroExtend(A).
    
    Returns:
        (n+1)×(n+1) Hessian matrix
    
    Complexity: O(n²)
    """
    return 2 * block_zero_extend(A)


def leaf_hessian_mixed(A: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the Hessian of the mixed leaf ∂²P/∂t∂x_k.
    
    This leaf is a rank-≤2 matrix with nonzero entries only in
    the (0, k+1) and (k+1, 0) blocks.
    
    Returns:
        (n+1)×(n+1) Hessian matrix
    
    Complexity: O(n)
    """
    n = A.shape[0]
    H = np.zeros((n + 1, n + 1))
    for j in range(n):
        H[0, j + 1] = 2 * A[k, j]
        H[j + 1, 0] = 2 * A[k, j]
    return H


def leaf_hessian_pure(A: np.ndarray, k: int, l: int) -> np.ndarray:
    """
    Compute the Hessian of the pure x-leaf ∂²P/∂x_k∂x_l.
    
    This leaf is a rank-≤1 matrix with at most one nonzero entry: H[0,0] = 4·A[k,l].
    
    Returns:
        (n+1)×(n+1) Hessian matrix
    
    Complexity: O(1) (plus O(n²) for allocation)
    """
    n = A.shape[0]
    H = np.zeros((n + 1, n + 1))
    H[0, 0] = 4 * A[k, l]
    return H


def check_all_leaves(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Dict]:
    """
    Check all Lorentzian leaf conditions for the spectral embedding P_A.
    
    For a degree-4 polynomial in n+1 variables, there are (n+1+1 choose 2) = (n+2)(n+1)/2
    degree-2 leaves. We check each one has at most one positive eigenvalue.
    
    Algorithm:
    1. Check critical leaf ∂²P/∂t² (controls the eigenvalue property of A)
    2. Check mixed leaves ∂²P/∂t∂x_k (always have at most 1 pos. eigenvalue)
    3. Check pure leaves ∂²P/∂x_k∂x_l (always have at most 1 pos. eigenvalue)
    
    Args:
        A: n×n symmetric matrix
        tol: Tolerance for eigenvalue positivity
    
    Returns:
        (all_ok, details_dict)
    
    Complexity: O(n³) total (dominated by the critical leaf eigenvalue check)
    """
    n = A.shape[0]
    details = {
        'critical_leaf': None,
        'mixed_leaves': [],
        'pure_leaves': [],
        'total_leaves': 0,
        'failed_leaves': 0
    }
    all_ok = True
    total = 0
    
    # Critical leaf
    H_crit = leaf_hessian_critical(A)
    inertia_crit = eigenvalue_inertia(H_crit, tol)
    ok_crit = inertia_crit[0] <= 1
    details['critical_leaf'] = {
        'inertia': inertia_crit,
        'ok': ok_crit
    }
    if not ok_crit:
        all_ok = False
        details['failed_leaves'] += 1
    total += 1
    
    # Mixed leaves
    for k in range(n):
        H_mix = leaf_hessian_mixed(A, k)
        inertia_mix = eigenvalue_inertia(H_mix, tol)
        ok_mix = inertia_mix[0] <= 1
        details['mixed_leaves'].append({
            'k': k,
            'inertia': inertia_mix,
            'ok': ok_mix
        })
        if not ok_mix:
            all_ok = False
            details['failed_leaves'] += 1
        total += 1
    
    # Pure leaves
    for k in range(n):
        for l in range(k, n):
            H_pure = leaf_hessian_pure(A, k, l)
            inertia_pure = eigenvalue_inertia(H_pure, tol)
            ok_pure = inertia_pure[0] <= 1
            details['pure_leaves'].append({
                'k': k, 'l': l,
                'inertia': inertia_pure,
                'ok': ok_pure
            })
            if not ok_pure:
                all_ok = False
                details['failed_leaves'] += 1
            total += 1
    
    details['total_leaves'] = total
    return all_ok, details


def verify_equivalence(A: np.ndarray, tol: float = 1e-10) -> Dict:
    """
    Verify the spectral embedding equivalence for a given matrix.
    
    Checks both:
    1. HasAtMostOnePositiveEigenvalue(A) 
    2. AllLeavesLorentzian(P_A)
    
    and verifies they agree.
    
    Returns:
        Dictionary with verification results
    """
    inertia_A = eigenvalue_inertia(A, tol)
    at_most_one = inertia_A[0] <= 1
    
    all_leaves_ok, leaf_details = check_all_leaves(A, tol)
    
    return {
        'matrix_inertia': inertia_A,
        'at_most_one_positive': at_most_one,
        'all_leaves_lorentzian': all_leaves_ok,
        'equivalence_holds': at_most_one == all_leaves_ok,
        'n_leaves': leaf_details['total_leaves'],
        'n_failed_leaves': leaf_details['failed_leaves'],
        'leaf_details': leaf_details
    }


def coefficient_size_bound(n: int) -> Dict:
    """
    Compute bounds on the spectral embedding construction size.
    
    For an n×n matrix:
    - Number of monomials: O(n²) 
    - Number of variables: n+1
    - Polynomial degree: 4 (fixed)
    - Number of leaves to check: O(n²)
    
    Returns:
        Dictionary with size bounds
    """
    return {
        'n': n,
        'n_variables': n + 1,
        'degree': 4,
        'max_monomials': n * n,  # Upper bound on distinct monomials
        'n_leaves_total': 1 + n + n * (n + 1) // 2,
        'construction_ops': n * n,  # O(n²) to construct coefficients
        'critical_check_ops': n ** 3,  # O(n³) for eigenvalue check
        'total_ops': n ** 3,  # Dominated by eigenvalue decomposition
    }


if __name__ == "__main__":
    # Example usage
    print("Spectral Embedding Algorithms")
    print("=" * 50)
    
    # Example: 3×3 matrix with exactly 1 positive eigenvalue
    A = np.array([
        [2.0, 1.0, 0.0],
        [1.0, -1.0, 0.5],
        [0.0, 0.5, -3.0]
    ])
    
    print("\nInput matrix A:")
    print(A)
    
    print("\nCoefficients of P_A:")
    coeffs = spectral_embed_coefficients(A)
    for exponent, coeff in sorted(coeffs.items()):
        vars_str = " ".join(
            f"{'t' if i==0 else f'x{i}'}^{e}" 
            for i, e in enumerate(exponent) if e > 0
        )
        print(f"  {coeff:+8.4f} · {vars_str}")
    
    print("\nVerification:")
    result = verify_equivalence(A)
    print(f"  Matrix inertia (n+, n0, n-): {result['matrix_inertia']}")
    print(f"  At most 1 positive eigenvalue: {result['at_most_one_positive']}")
    print(f"  All leaves Lorentzian: {result['all_leaves_lorentzian']}")
    print(f"  Equivalence holds: {result['equivalence_holds']}")
    
    print("\nSize bounds for n=10:")
    bounds = coefficient_size_bound(10)
    for k, v in bounds.items():
        print(f"  {k}: {v}")
