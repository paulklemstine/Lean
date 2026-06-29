#!/usr/bin/env python3
"""
algorithms.py — Verified Recognition Algorithms for Lorentzian Polynomials

Implements the spectral recognition algorithm for Lorentzian polynomials,
corresponding to the formally verified recursive spectral certificate
from the Lean formalization.

Algorithm:
1. Enumerate all iterated partial derivatives of p down to degree 2
2. Extract each quadratic leaf
3. Compute its Hessian matrix
4. Check the "at most one positive eigenvalue" condition
5. Return either a certificate of Lorentzianity or a failing leaf

Time complexity: O(n^(d-2) · n² · T_eigen) where T_eigen is eigenvalue computation
Space complexity: O(n²) for each Hessian matrix

References:
- Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
"""

import numpy as np
from typing import Optional, Tuple
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class LorentzianCertificate:
    """A recursive Lorentzian certificate.

    Contains the polynomial data, degree, and proof trace showing
    all quadratic leaves have Lorentzian Hessian signature.
    """
    n: int  # number of variables
    d: int  # degree
    coefficients: dict  # exponent tuple -> coefficient
    leaf_signatures: list  # list of (alpha, eigenvalues) pairs
    is_lorentzian: bool
    failing_leaf: Optional[Tuple] = None


@dataclass
class SpectralTestResult:
    """Result of the spectral test on a single quadratic leaf."""
    alpha: tuple  # derivative multiindex
    hessian: np.ndarray  # Hessian matrix
    eigenvalues: np.ndarray  # eigenvalues
    n_positive: int  # number of positive eigenvalues
    is_lorentzian: bool  # at most one positive eigenvalue


# ============================================================
# Core Algorithm: Spectral Recognizer
# ============================================================

def multiindices(n: int, d: int):
    """Generate all multiindices α ∈ ℕⁿ with |α| = d.

    Yields tuples of length n with nonneg integer entries summing to d.

    Time: O(C(n+d-1, d)) iterations
    Space: O(n) per iteration (generator)
    """
    if n == 0:
        if d == 0:
            yield ()
        return
    for first in range(d + 1):
        for rest in multiindices(n - 1, d - first):
            yield (first,) + rest


def partial_derivative_coefficients(
    coefficients: dict, n: int, var: int
) -> dict:
    """Compute coefficients of ∂p/∂x_var.

    For each monomial c·x^α with α[var] > 0,
    the derivative contributes c·α[var]·x^(α - e_var).

    Time: O(|support|)
    Space: O(|support|)
    """
    new_coeffs = {}
    for alpha, c in coefficients.items():
        if alpha[var] > 0:
            new_alpha = list(alpha)
            new_alpha[var] -= 1
            new_alpha = tuple(new_alpha)
            new_coeffs[new_alpha] = new_coeffs.get(new_alpha, 0.0) + c * alpha[var]
    return new_coeffs


def iterated_partial_derivative_coefficients(
    coefficients: dict, n: int, alpha: tuple
) -> dict:
    """Compute coefficients of ∂^α p.

    Applies ∂/∂xᵢ exactly α[i] times for each i.

    Time: O(|α| · |support|)
    Space: O(|support|)
    """
    result = coefficients
    for var in range(n):
        for _ in range(alpha[var]):
            result = partial_derivative_coefficients(result, n, var)
    return result


def compute_hessian(
    coefficients: dict, n: int
) -> np.ndarray:
    """Compute the Hessian matrix of a polynomial at the origin.

    H[i][j] = constant coefficient of ∂²p/∂xᵢ∂xⱼ.
    For a homogeneous degree-2 polynomial, this captures all information.

    Time: O(n² · |support|)
    Space: O(n²)
    """
    H = np.zeros((n, n))
    for i in range(n):
        di = partial_derivative_coefficients(coefficients, n, i)
        for j in range(n):
            dij = partial_derivative_coefficients(di, n, j)
            zero_alpha = tuple([0] * n)
            H[i][j] = dij.get(zero_alpha, 0.0)
    return H


def check_lorentzian_signature(
    H: np.ndarray, tol: float = 1e-10
) -> SpectralTestResult:
    """Check if a Hessian matrix has at most one positive eigenvalue.

    Uses eigenvalue decomposition of the symmetric matrix H.

    Time: O(n³) for eigenvalue computation
    Space: O(n²)

    Args:
        H: Symmetric matrix (Hessian)
        tol: Tolerance for considering eigenvalue positive

    Returns:
        SpectralTestResult with eigenvalues and signature
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    n_positive = int(np.sum(eigenvalues > tol))
    return SpectralTestResult(
        alpha=(),  # filled by caller
        hessian=H,
        eigenvalues=eigenvalues,
        n_positive=n_positive,
        is_lorentzian=(n_positive <= 1),
    )


def spectral_recognizer(
    coefficients: dict,
    n: int,
    d: int,
    verbose: bool = False,
) -> LorentzianCertificate:
    """The main spectral recognition algorithm for Lorentzian polynomials.

    Given a homogeneous polynomial p of degree d in n variables (specified
    by its coefficients), determines whether p is recursively Lorentzian
    by checking all quadratic leaves.

    Algorithm:
    1. Check nonneg coefficients
    2. If d < 2, return trivially Lorentzian
    3. For each multiindex α with |α| = d-2:
       a. Compute the iterated derivative ∂^α p
       b. Form the Hessian matrix
       c. Check eigenvalue signature
    4. Return certificate or failing leaf

    Time complexity: O(n^(d-2) · n² · n³) = O(n^(d+3))
      - n^(d-2) quadratic leaves
      - n² entries per Hessian
      - n³ for eigenvalue computation per leaf

    Space complexity: O(n² + |support|)

    Correctness:
      - Sound by `spectralRecognizer_sound` (Lean theorem)
      - Complete by `spectralRecognizer_complete` (Lean theorem)

    Args:
        coefficients: dict mapping exponent tuples to coefficients
        n: number of variables
        d: degree of the polynomial
        verbose: print diagnostic information

    Returns:
        LorentzianCertificate with the result and proof trace
    """
    # Step 1: Check nonneg coefficients
    for alpha, c in coefficients.items():
        if c < -1e-12:
            return LorentzianCertificate(
                n=n, d=d,
                coefficients=coefficients,
                leaf_signatures=[],
                is_lorentzian=False,
                failing_leaf=None,
            )

    # Step 2: Trivial cases
    if d < 2:
        return LorentzianCertificate(
            n=n, d=d,
            coefficients=coefficients,
            leaf_signatures=[],
            is_lorentzian=True,
        )

    # Step 3: Check all quadratic leaves
    leaf_signatures = []
    deriv_order = d - 2

    for alpha in multiindices(n, deriv_order):
        # Compute iterated derivative
        leaf_coeffs = iterated_partial_derivative_coefficients(
            coefficients, n, alpha
        )

        # Compute Hessian
        H = compute_hessian(leaf_coeffs, n)

        # Check signature
        result = check_lorentzian_signature(H)
        result.alpha = alpha
        leaf_signatures.append((alpha, result.eigenvalues.tolist()))

        if verbose:
            print(f"  Leaf α={alpha}: eigenvalues={result.eigenvalues}, "
                  f"Lorentzian={result.is_lorentzian}")

        if not result.is_lorentzian:
            return LorentzianCertificate(
                n=n, d=d,
                coefficients=coefficients,
                leaf_signatures=leaf_signatures,
                is_lorentzian=False,
                failing_leaf=(alpha, result.eigenvalues.tolist()),
            )

    # Step 4: All leaves passed
    return LorentzianCertificate(
        n=n, d=d,
        coefficients=coefficients,
        leaf_signatures=leaf_signatures,
        is_lorentzian=True,
    )


def principal_minor_check(
    H: np.ndarray, tol: float = 1e-10
) -> bool:
    """Alternative Lorentzian signature check via principal minors (Sylvester criterion).

    For a symmetric matrix to have at most one positive eigenvalue, we need:
    - All 2×2 principal minors involving the first row/column to have
      specific sign patterns.

    This provides an O(n²) check for the signature condition without
    computing eigenvalues (O(n³)).

    Note: This is a necessary condition check. For exact certification,
    eigenvalue computation may still be needed.

    Time: O(n²)
    Space: O(1)
    """
    n = H.shape[0]
    if n <= 1:
        return True

    # Check all 2x2 principal minors: det([[H[i,i], H[i,j]], [H[j,i], H[j,j]]])
    # For Lorentzian signature, all 2x2 principal minors should be ≤ 0
    for i in range(n):
        for j in range(i + 1, n):
            minor = H[i, i] * H[j, j] - H[i, j] * H[j, i]
            if minor > tol:
                return False  # More than one positive eigenvalue

    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Spectral Recognition Algorithm for Lorentzian Polynomials")
    print("=" * 60)

    # Example 1: e_2(x,y,z) = xy + xz + yz (Lorentzian)
    print("\n--- Example 1: e₂(x,y,z) = xy + xz + yz ---")
    coeffs = {
        (1, 1, 0): 1.0,
        (1, 0, 1): 1.0,
        (0, 1, 1): 1.0,
    }
    cert = spectral_recognizer(coeffs, n=3, d=2, verbose=True)
    print(f"Result: {'Lorentzian' if cert.is_lorentzian else 'Not Lorentzian'}")

    # Example 2: x² + y² (Not Lorentzian)
    print("\n--- Example 2: x² + y² ---")
    coeffs = {(2, 0): 1.0, (0, 2): 1.0}
    cert = spectral_recognizer(coeffs, n=2, d=2, verbose=True)
    print(f"Result: {'Lorentzian' if cert.is_lorentzian else 'Not Lorentzian'}")
    if cert.failing_leaf:
        print(f"Failing leaf: α={cert.failing_leaf[0]}, "
              f"eigenvalues={cert.failing_leaf[1]}")

    # Example 3: e_3(x,y,z,w) (Lorentzian)
    print("\n--- Example 3: e₃(x,y,z,w) ---")
    from itertools import combinations
    coeffs = {}
    for subset in combinations(range(4), 3):
        alpha = [0, 0, 0, 0]
        for i in subset:
            alpha[i] = 1
        coeffs[tuple(alpha)] = 1.0
    cert = spectral_recognizer(coeffs, n=4, d=3, verbose=True)
    print(f"Result: {'Lorentzian' if cert.is_lorentzian else 'Not Lorentzian'}")
    print(f"Leaves checked: {len(cert.leaf_signatures)}")

    # Example 4: Complexity analysis
    print("\n--- Complexity Analysis ---")
    for n in [2, 3, 4]:
        for d in [2, 3, 4, 5]:
            n_leaves = sum(1 for _ in multiindices(n, max(0, d - 2)))
            bound = n ** max(0, d - 2)
            print(f"  n={n}, d={d}: leaves={n_leaves}, bound n^(d-2)={bound}")

    print("\nAlgorithm demonstration complete.")
