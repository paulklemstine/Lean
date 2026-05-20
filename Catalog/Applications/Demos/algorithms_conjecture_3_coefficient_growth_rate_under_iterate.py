#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for computing and bounding coefficients
of symmetric power Euler factors.

Implements:
  1. Root generation for Sym^n transfer
  2. Polynomial construction via iterative folding
  3. Coefficient extraction via elementary symmetric polynomials
  4. Transfer exponent computation with concavity verification
  5. Theoretical bound evaluation
  6. Tropical envelope computation

All algorithms match the formally verified Lean definitions.
"""

from math import comb, log
from itertools import combinations
from typing import Optional


def transfer_exponent(n: int, k: int) -> int:
    """
    Compute the transfer exponent E(n,k) = k*n - k*(k-1)//2.

    This represents the maximal weight sum obtainable by choosing k elements
    from {n, n-1, ..., 1, 0}. Equivalently, it is the support function of
    the k-th weight polytope slice.

    Formally verified in Lean as `SymmEuler.transferExponent`.

    Args:
        n: The symmetric power degree
        k: The coefficient index

    Returns:
        The transfer exponent E(n,k)

    Examples:
        >>> transfer_exponent(4, 2)
        7
        >>> transfer_exponent(3, 4)
        6
    """
    return k * n - k * (k - 1) // 2


def transfer_exponent_full(n: int) -> int:
    """
    E(n, n+1) = n*(n+1)//2.

    Formally verified as `SymmEuler.transferExponent_full`.

    Examples:
        >>> transfer_exponent_full(4)
        10
        >>> transfer_exponent(4, 5) == transfer_exponent_full(4)
        True
    """
    return n * (n + 1) // 2


def verify_concavity(n: int) -> list[tuple[int, int, int, int, bool]]:
    """
    Verify E(n,k) + E(n,k+2) ≤ 2*E(n,k+1) for all valid k.

    Formally verified as `SymmEuler.transferExponent_concave`.
    The deficit is always exactly 1.

    Args:
        n: The symmetric power degree

    Returns:
        List of (k, E(n,k)+E(n,k+2), 2*E(n,k+1), deficit, is_concave)

    Examples:
        >>> all(ok for _, _, _, _, ok in verify_concavity(10))
        True
    """
    results = []
    for k in range(n):  # k + 2 ≤ n + 1 ⟺ k ≤ n - 1
        lhs = transfer_exponent(n, k) + transfer_exponent(n, k + 2)
        rhs = 2 * transfer_exponent(n, k + 1)
        deficit = rhs - lhs
        results.append((k, lhs, rhs, deficit, lhs <= rhs))
    return results


def symm_euler_roots(alpha: complex, beta: complex, n: int) -> list[complex]:
    """
    Generate the Satake root multiset {α^n, α^{n-1}β, ..., β^n}.

    These are the eigenvalues of the Sym^n transfer of the unramified
    GL₂ parameter (α, β).

    Args:
        alpha: First Satake parameter
        beta: Second Satake parameter
        n: Symmetric power degree

    Returns:
        List of n+1 roots

    Examples:
        >>> symm_euler_roots(2, 1, 2)
        [4, 2, 1]
    """
    return [alpha ** (n - j) * beta ** j for j in range(n + 1)]


def symm_euler_coefficients(
    alpha: complex, beta: complex, n: int
) -> list[complex]:
    """
    Compute all coefficients of P_n(T) = ∏_{j=0}^{n} (1 - r_j T) by folding.

    This is the primary algorithm: O(n²) time, O(n) space.

    Args:
        alpha: First Satake parameter
        beta: Second Satake parameter
        n: Symmetric power degree

    Returns:
        Coefficients [c_0, c_1, ..., c_{n+1}]

    Examples:
        >>> coeffs = symm_euler_coefficients(2, 1, 1)
        >>> abs(coeffs[0] - 1) < 1e-10
        True
        >>> abs(coeffs[1] - (-3)) < 1e-10
        True
        >>> abs(coeffs[2] - 2) < 1e-10
        True
    """
    roots = symm_euler_roots(alpha, beta, n)
    coeffs = [complex(1)]
    for r in roots:
        new_coeffs = [complex(0)] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c
            new_coeffs[i + 1] -= c * r
        coeffs = new_coeffs
    return coeffs


def symm_euler_coeff_subset(
    alpha: complex, beta: complex, n: int, k: int
) -> complex:
    """
    Compute c_{n,k} via the elementary symmetric polynomial formula:
      c_{n,k} = (-1)^k Σ_{|S|=k, S⊆{0,...,n}} ∏_{j∈S} α^{n-j} β^j

    This matches the formal definition `SymmEuler.symmEulerCoeff`.
    Complexity: O(C(n+1,k) · k) time.

    Args:
        alpha, beta: Satake parameters
        n: Symmetric power degree
        k: Coefficient index

    Returns:
        The coefficient c_{n,k}
    """
    roots = symm_euler_roots(alpha, beta, n)
    total = complex(0)
    for subset in combinations(range(n + 1), k):
        prod = complex(1)
        for j in subset:
            prod *= roots[j]
        total += prod
    return ((-1) ** k) * total


def coefficient_bound(n: int, k: int, M: float) -> float:
    """
    Compute the sharp theoretical bound: C(n+1,k) · M^{E(n,k)}.

    Valid when min(|α|, |β|) ≤ 1.
    Formally verified as `SymmEuler.symmEuler_coeff_bound_sharp`.

    Args:
        n: Symmetric power degree
        k: Coefficient index
        M: max(|α|, |β|) ≥ 1

    Returns:
        Upper bound on |c_{n,k}|

    Examples:
        >>> coefficient_bound(2, 1, 2.0)
        12.0
    """
    E = transfer_exponent(n, k)
    return comb(n + 1, k) * M ** E


def coefficient_bound_crude(n: int, k: int, M: float) -> float:
    """
    Compute the crude bound: C(n+1,k) · M^{kn}.

    Always valid (no assumption on min(|α|,|β|)).
    Formally verified as `SymmEuler.symmEuler_coeff_bound`.

    Args:
        n: Symmetric power degree
        k: Coefficient index
        M: max(|α|, |β|)

    Returns:
        Upper bound on |c_{n,k}|
    """
    return comb(n + 1, k) * M ** (k * n)


def max_coefficient_bound(n: int, M: float) -> float:
    """
    Compute the maximum coefficient bound:
      C(n+1, ⌊(n+1)/2⌋) · M^{n(n+1)/2}

    Formally verified as `SymmEuler.symmEuler_maxCoeff_bound`.

    Args:
        n: Symmetric power degree
        M: max(|α|, |β|) ≥ 1

    Returns:
        Upper bound on max_k |c_{n,k}|
    """
    central_binom = comb(n + 1, (n + 1) // 2)
    E_max = n * (n + 1) // 2
    return central_binom * M ** E_max


def tropical_transfer_envelope(
    M: float, n: int, k: int
) -> Optional[float]:
    """
    Compute the tropical transfer envelope:
      log C(n+1,k) + E(n,k) · log M

    Formally verified as `SymmEuler.tropicalTransferEnvelope`.

    Args:
        M: max(|α|, |β|) > 0
        n: Symmetric power degree
        k: Coefficient index

    Returns:
        Tropical envelope value, or None if undefined
    """
    binom = comb(n + 1, k)
    if binom == 0 or M <= 0:
        return None
    E = transfer_exponent(n, k)
    return log(binom) + E * log(M)


def full_analysis(
    alpha: complex, beta: complex, n: int
) -> dict:
    """
    Complete analysis of the symmetric power Euler factor.

    Returns a dictionary with:
      - roots: the root multiset
      - coefficients: all coefficients
      - norms: coefficient norms
      - bounds_sharp: sharp bounds (when applicable)
      - bounds_crude: crude bounds
      - max_norm: maximum coefficient norm
      - max_bound: maximum coefficient bound
      - transfer_exponents: E(n,k) profile
      - ratios: |c_{n,k}| / bound ratios

    Args:
        alpha, beta: Satake parameters
        n: Symmetric power degree

    Returns:
        Analysis dictionary
    """
    M = max(abs(alpha), abs(beta))
    m = min(abs(alpha), abs(beta))
    sharp_applies = m <= 1.0

    roots = symm_euler_roots(alpha, beta, n)
    coeffs = symm_euler_coefficients(alpha, beta, n)
    norms = [abs(c) for c in coeffs]

    exponents = [transfer_exponent(n, k) for k in range(n + 2)]

    if sharp_applies:
        bounds = [coefficient_bound(n, k, M) for k in range(n + 2)]
    else:
        bounds = [coefficient_bound_crude(n, k, M) for k in range(n + 2)]

    ratios = [
        norms[k] / bounds[k] if bounds[k] > 0 else 0.0
        for k in range(n + 2)
    ]

    return {
        "alpha": alpha,
        "beta": beta,
        "n": n,
        "M": M,
        "min_norm": m,
        "sharp_applies": sharp_applies,
        "roots": roots,
        "coefficients": coeffs,
        "norms": norms,
        "bounds": bounds,
        "transfer_exponents": exponents,
        "ratios": ratios,
        "max_norm": max(norms),
        "max_bound": max_coefficient_bound(n, M) if sharp_applies else None,
    }


if __name__ == "__main__":
    # Quick self-test
    print("Self-test of algorithms.py")
    print("=" * 40)

    # Verify transfer exponent properties
    for n in range(1, 20):
        assert transfer_exponent(n, n + 1) == transfer_exponent_full(n)
        concavity = verify_concavity(n)
        assert all(ok for _, _, _, _, ok in concavity), f"Concavity failed at n={n}"
        assert all(d == 1 for _, _, _, d, _ in concavity), f"Deficit ≠ 1 at n={n}"

    # Verify coefficient computation consistency
    for alpha, beta in [(2 + 1j, 0.5 - 0.3j), (1.5, 0.7), (3, 1 / 3)]:
        for n in range(1, 8):
            coeffs_fold = symm_euler_coefficients(alpha, beta, n)
            for k in range(n + 2):
                c_subset = symm_euler_coeff_subset(alpha, beta, n, k)
                assert abs(coeffs_fold[k] - c_subset) < 1e-8, \
                    f"Mismatch at α={alpha}, β={beta}, n={n}, k={k}"

    # Verify bounds
    for alpha, beta in [(2.0, 0.5), (3.0, 1 / 3), (1.5, 0.8)]:
        M = max(abs(alpha), abs(beta))
        for n in range(1, 10):
            coeffs = symm_euler_coefficients(alpha, beta, n)
            for k in range(n + 2):
                assert abs(coeffs[k]) <= coefficient_bound(n, k, M) + 1e-10, \
                    f"Bound violated at α={alpha}, β={beta}, n={n}, k={k}"

    print("All self-tests passed ✓")
