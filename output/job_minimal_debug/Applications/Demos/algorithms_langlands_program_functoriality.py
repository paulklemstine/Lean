#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Langlands functoriality:
Symmetric power transfer, Euler polynomial computation, and Hecke trace generation.

All algorithms correspond to formally verified Lean definitions.
"""

from typing import List, Tuple
import numpy as np


def symm_pow_roots(n: int, alpha: complex, beta: complex) -> List[complex]:
    """
    Compute the roots of the n-th symmetric power Euler factor.

    Given Satake parameters (alpha, beta) for a GL₂ datum, the Sym^n transfer
    has roots alpha^{n-i} * beta^i for i = 0, 1, ..., n.

    Verified in Lean: symmPowDatum, symmPow_roots_homogeneous

    Args:
        n: Symmetric power index (≥ 0)
        alpha: First Satake parameter
        beta: Second Satake parameter

    Returns:
        List of n+1 roots

    Example:
        >>> symm_pow_roots(2, 2, 3)
        [4, 6, 9]  # [α², αβ, β²]
    """
    return [alpha**(n - i) * beta**i for i in range(n + 1)]


def euler_poly_from_roots(roots: List[complex]) -> np.ndarray:
    """
    Compute the Euler polynomial ∏(X - r_i) from a list of roots.

    Uses iterative convolution with linear factors (X - r_i).
    This is the certified algorithm corresponding to LocalEulerDatum.eulerPoly.

    Complexity: O(d²) where d = len(roots)

    Args:
        roots: List of polynomial roots

    Returns:
        Coefficient array [a_0, a_1, ..., a_d] where poly = Σ a_i X^i

    Example:
        >>> euler_poly_from_roots([2, 3])
        array([6, -5, 1])  # (X-2)(X-3) = X² - 5X + 6
    """
    poly = np.array([1.0 + 0j])
    for r in roots:
        poly = np.convolve(poly, np.array([-r, 1.0]))
    return poly


def symm_pow_euler_coeffs(n: int, alpha: complex, beta: complex) -> np.ndarray:
    """
    Compute the coefficient list of the Sym^n Euler polynomial.

    This is the main computational deliverable: a verified algorithm for
    computing transferred local factors directly.

    Verified in Lean: eulerPoly_symmPowDatum

    Args:
        n: Symmetric power index
        alpha, beta: Satake parameters

    Returns:
        Coefficient array of ∏_{i=0}^{n} (X - α^{n-i}β^i)
    """
    roots = symm_pow_roots(n, alpha, beta)
    return euler_poly_from_roots(roots)


def hecke_trace_direct(alpha: complex, beta: complex, m: int) -> complex:
    """
    Compute the m-th Hecke trace directly: t_m = α^m + β^m.

    Verified in Lean: heckeTrace

    Args:
        alpha, beta: Satake parameters
        m: Index (≥ 0)

    Returns:
        α^m + β^m
    """
    return alpha**m + beta**m


def hecke_trace_sequence(alpha: complex, beta: complex, length: int) -> List[complex]:
    """
    Compute a sequence of Hecke traces using the recurrence:
        t_{m+2} = (α+β)·t_{m+1} - αβ·t_m

    This avoids computing large powers and is numerically more stable.

    Verified in Lean: heckeTrace_recurrence

    Complexity: O(length)

    Args:
        alpha, beta: Satake parameters
        length: Number of terms to compute

    Returns:
        List [t_0, t_1, ..., t_{length-1}]
    """
    if length <= 0:
        return []
    s = alpha + beta  # trace
    p = alpha * beta  # determinant

    result = [complex(2)]
    if length == 1:
        return result
    result.append(s)
    for m in range(2, length):
        result.append(s * result[-1] - p * result[-2])
    return result


def root_product(n: int, alpha: complex, beta: complex) -> complex:
    """
    Compute ∏_{i=0}^{n} α^{n-i}·β^i = (αβ)^{n(n+1)/2}.

    This is the determinant/central-character compatibility law.
    Verified in Lean: symmPow_root_product

    Args:
        n: Symmetric power index
        alpha, beta: Satake parameters

    Returns:
        Product of all roots
    """
    return (alpha * beta) ** (n * (n + 1) // 2)


def verify_self_duality(n: int, alpha: complex, tol: float = 1e-10) -> bool:
    """
    Verify that the roots of Sym^n(α, α⁻¹) are closed under inversion.

    Verified in Lean: symmPow_roots_inv_closed

    Args:
        n: Symmetric power index
        alpha: Satake parameter (nonzero)
        tol: Numerical tolerance

    Returns:
        True if the root set is closed under inversion
    """
    beta = 1.0 / alpha
    roots = symm_pow_roots(n, alpha, beta)
    for r in roots:
        inv_r = 1.0 / r
        if not any(abs(inv_r - s) < tol for s in roots):
            return False
    return True


def coefficient_palindromic_check(
    n: int, alpha: complex, tol: float = 1e-8
) -> Tuple[bool, List[complex]]:
    """
    Check if the Euler polynomial of Sym^n(α, α⁻¹) has palindromic
    coefficient magnitudes (a consequence of root inversion symmetry).

    Args:
        n: Symmetric power index
        alpha: Satake parameter

    Returns:
        (is_palindromic, coefficients)
    """
    coeffs = symm_pow_euler_coeffs(n, alpha, 1.0 / alpha)
    abs_coeffs = np.abs(coeffs)
    d = len(abs_coeffs)
    is_palin = all(
        abs(abs_coeffs[i] - abs_coeffs[d - 1 - i]) < tol * max(1, abs_coeffs[i])
        for i in range(d // 2 + 1)
    )
    return is_palin, coeffs.tolist()


# ─── Example usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Symmetric Power Euler Polynomial Coefficients ===\n")

    alpha, beta = 2.0, 3.0
    for n in range(1, 6):
        coeffs = symm_pow_euler_coeffs(n, alpha, beta)
        print(f"Sym^{n}({alpha}, {beta}): {np.real(coeffs).astype(int)}")

    print("\n=== Hecke Trace Sequence ===\n")
    traces = hecke_trace_sequence(2.0, 3.0, 10)
    for m, t in enumerate(traces):
        print(f"  t_{m} = {t.real:.0f}")

    print("\n=== Determinant Compatibility ===\n")
    for n in range(1, 8):
        prod_direct = np.prod(symm_pow_roots(n, 2.0, 3.0))
        prod_formula = root_product(n, 2.0, 3.0)
        print(f"  n={n}: direct = {prod_direct.real:.0f}, formula = {prod_formula.real:.0f}")

    print("\n=== Self-Duality Check (α=2, β=1/2) ===\n")
    for n in range(1, 8):
        ok = verify_self_duality(n, 2.0)
        print(f"  n={n}: self-dual = {ok}")

    print("\n=== Palindromic Coefficients (α=2, β=1/2) ===\n")
    for n in range(1, 7):
        is_pal, coeffs = coefficient_palindromic_check(n, 2.0)
        print(f"  n={n}: palindromic = {is_pal}")
