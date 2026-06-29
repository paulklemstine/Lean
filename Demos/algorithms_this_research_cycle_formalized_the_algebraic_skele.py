"""
Algorithms for the Hecke Eigenvalue Recursion and Tropical Dequantization.

This module implements the core algorithms formalized in Lean 4:
- The Hecke eigenvalue recursion h(n) for GL₂
- The tropical Hecke recursion (max-plus analog)
- The Maslov dequantization bridge
- Cassini-Hecke identity verification
"""

from typing import List, Tuple, Callable
import math


def hecke_seq(a: int, q: int, n: int) -> int:
    """Compute the n-th term of the Hecke eigenvalue recursion.

    Given trace parameter a and determinant parameter q,
    computes h(n) where:
      h(0) = 1
      h(1) = a
      h(n+2) = a * h(n+1) - q * h(n)

    For the Langlands correspondence:
      a = a_p (Hecke eigenvalue at prime p)
      q = p^(k-1) (weight k)
      h(n) = a_{p^n} (eigenvalue at p^n)

    Args:
        a: Trace parameter (Hecke eigenvalue at prime)
        q: Determinant parameter (p^{k-1})
        n: Power index

    Returns:
        The n-th Hecke recursion value
    """
    if n == 0:
        return 1
    if n == 1:
        return a
    prev2, prev1 = 1, a
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, a * prev1 - q * prev2
    return prev1


def hecke_seq_list(a: int, q: int, n: int) -> List[int]:
    """Compute the first n+1 terms of the Hecke recursion."""
    if n < 0:
        return []
    result = [1]
    if n == 0:
        return result
    result.append(a)
    for i in range(2, n + 1):
        result.append(a * result[-1] - q * result[-2])
    return result


def verify_cassini_identity(a: int, q: int, n: int) -> Tuple[int, int]:
    """Verify the Cassini-Hecke identity: h(n+1)² - h(n+2)*h(n) = q^(n+1).

    Returns (lhs, rhs) which should be equal.
    """
    vals = hecke_seq_list(a, q, n + 2)
    lhs = vals[n + 1] ** 2 - vals[n + 2] * vals[n]
    rhs = q ** (n + 1)
    return lhs, rhs


def trop_hecke_seq(a: int, q: int, n: int) -> int:
    """Compute the n-th term of the tropical Hecke recursion.

    In the tropical (max-plus) semiring:
      h(0) = 0
      h(1) = a
      h(n+2) = max(a + h(n+1), q + h(n))

    Args:
        a: Tropical trace parameter
        q: Tropical determinant parameter
        n: Index

    Returns:
        The n-th tropical Hecke value
    """
    if n == 0:
        return 0
    if n == 1:
        return a
    prev2, prev1 = 0, a
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, max(a + prev1, q + prev2)
    return prev1


def maslov_hecke_seq(t: float, a: float, q: float, n: int) -> float:
    """Compute the Maslov-deformed Hecke sequence.

    Uses soft-max: softmax_t(x,y) = (t*max(x,y) + min(x,y)) / (t+1)

    At t→∞: approaches max(x,y) (tropical)
    At t=1: computes (max+min)/2 = average (classical analog)
    At t=0: computes min(x,y)

    Args:
        t: Deformation parameter (≥ 0)
        a: Trace parameter
        q: Determinant parameter
        n: Index

    Returns:
        The n-th Maslov-deformed Hecke value
    """
    if n == 0:
        return 0.0
    if n == 1:
        return a
    prev2, prev1 = 0.0, a
    for _ in range(2, n + 1):
        x = a + prev1
        y = q + prev2
        if t + 1 == 0:
            val = min(x, y)
        else:
            val = (t * max(x, y) + min(x, y)) / (t + 1)
        prev2, prev1 = prev1, val
    return prev1


def hecke_growth_analysis(a: int, q: int, max_n: int = 20) -> dict:
    """Analyze the growth rate of the Hecke sequence.

    Computes the sequence and checks whether |h(n)|² ≤ (n+1)² * q^n
    (Ramanujan bound) holds.

    Args:
        a: Trace parameter
        q: Determinant parameter
        max_n: Maximum index to check

    Returns:
        Dictionary with analysis results
    """
    vals = hecke_seq_list(a, q, max_n)
    discriminant = a ** 2 - 4 * q
    ramanujan_regime = discriminant <= 0

    bound_holds = []
    for n in range(max_n + 1):
        lhs = vals[n] ** 2
        rhs = (n + 1) ** 2 * (q ** n if q > 0 else 0)
        bound_holds.append(lhs <= rhs)

    return {
        "a": a,
        "q": q,
        "discriminant": discriminant,
        "ramanujan_regime": ramanujan_regime,
        "sequence": vals,
        "bound_holds": bound_holds,
        "all_bounded": all(bound_holds),
        "conjecture_consistent": ramanujan_regime == all(bound_holds),
    }


def euler_factor_coefficients(a: int, q: int, n: int) -> List[int]:
    """Compute the coefficients of the Euler factor expansion.

    The local L-factor is:
      L_p(s) = (1 - a*p^{-s} + q*p^{-2s})^{-1}
             = sum_{n≥0} h(n) * p^{-ns}

    This returns [h(0), h(1), ..., h(n)].
    """
    return hecke_seq_list(a, q, n)


def verify_euler_product_identity(a: int, q: int, N: int) -> bool:
    """Verify the generating function identity.

    Checks that the n-th coefficient of (1 - aX + qX²) * Σ h(k)X^k
    equals δ_{n,0} for n = 0, ..., N.
    """
    vals = hecke_seq_list(a, q, N)

    for n in range(N + 1):
        if n == 0:
            coeff = vals[0]
            expected = 1
        elif n == 1:
            coeff = vals[1] - a * vals[0]
            expected = 0
        else:
            coeff = vals[n] - a * vals[n - 1] + q * vals[n - 2]
            expected = 0
        if coeff != expected:
            return False
    return True
