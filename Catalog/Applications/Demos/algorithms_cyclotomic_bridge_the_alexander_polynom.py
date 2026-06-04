#!/usr/bin/env python3
"""
Cyclotomic-Alexander Bridge: Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from typing import List, Dict, Tuple, Optional
from math import gcd
from functools import reduce


def alexander_polynomial(n: int) -> List[int]:
    """
    Compute the Alexander polynomial of the torus knot T(2,n).

    A_n(X) = sum_{i=0}^{n-1} (-1)^i X^i

    Args:
        n: The parameter of the torus knot T(2,n), should be odd.

    Returns:
        List of coefficients [a_0, a_1, ..., a_{n-1}] where a_i is
        the coefficient of X^i.
    """
    return [(-1) ** i for i in range(n)]


def cyclotomic_polynomial(n: int) -> List[int]:
    """
    Compute the n-th cyclotomic polynomial Phi_n(X).

    Uses the recursive formula: Phi_n(X) = (X^n - 1) / prod_{d|n, d<n} Phi_d(X)

    Args:
        n: Positive integer.

    Returns:
        List of coefficients [a_0, a_1, ..., a_phi(n)].
    """
    if n == 1:
        return [-1, 1]  # X - 1

    # Build X^n - 1
    xn_minus_1: List[int] = [0] * (n + 1)
    xn_minus_1[0] = -1
    xn_minus_1[n] = 1

    # Divide by all Phi_d for proper divisors d of n
    result = list(xn_minus_1)
    for d in range(1, n):
        if n % d == 0:
            phi_d = cyclotomic_polynomial(d)
            result = _exact_poly_div(result, phi_d)

    # Remove trailing zeros
    while len(result) > 1 and result[-1] == 0:
        result.pop()

    return result


def _exact_poly_div(dividend: List[int], divisor: List[int]) -> List[int]:
    """
    Exact polynomial division assuming divisor divides dividend.

    Args:
        dividend: Coefficients of the dividend polynomial.
        divisor: Coefficients of the divisor polynomial.

    Returns:
        Coefficients of the quotient polynomial.
    """
    result = list(dividend)
    deg_diff = len(result) - len(divisor)

    for i in range(deg_diff, -1, -1):
        coeff = result[i + len(divisor) - 1] // divisor[-1]
        for j in range(len(divisor)):
            result[i + j] -= coeff * divisor[j]
        result[i + len(divisor) - 1] = coeff

    return result[:deg_diff + 1]


def poly_multiply(a: List[int], b: List[int]) -> List[int]:
    """Multiply two polynomials given as coefficient lists."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ca in enumerate(a):
        for j, cb in enumerate(b):
            result[i + j] += ca * cb
    return result


def divisors(n: int) -> List[int]:
    """Return sorted list of positive divisors of n."""
    divs: List[int] = []
    for d in range(1, int(n ** 0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def euler_totient(n: int) -> int:
    """Compute Euler's totient function phi(n)."""
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def verify_negation_bridge(p: int) -> bool:
    """
    Verify Phi_{2p}(X) = Phi_p(-X) for odd prime p.

    The negation bridge states that composing the p-th cyclotomic
    polynomial with X -> -X yields the 2p-th cyclotomic polynomial.

    Args:
        p: An odd prime.

    Returns:
        True if the identity holds.
    """
    phi_2p = cyclotomic_polynomial(2 * p)
    phi_p = cyclotomic_polynomial(p)

    # Compose with -X: coefficient of X^i gets multiplied by (-1)^i
    phi_p_neg = [(-1) ** i * c for i, c in enumerate(phi_p)]

    return phi_2p == phi_p_neg


def verify_product_decomposition(n: int) -> bool:
    """
    Verify X^n + 1 = prod_{d|n} Phi_{2d}(X) for odd n.

    Args:
        n: An odd positive integer.

    Returns:
        True if the decomposition holds.
    """
    # Target: X^n + 1
    target = [1] + [0] * (n - 1) + [1]

    # Compute product of Phi_{2d} for all divisors d of n
    product: List[int] = [1]
    for d in divisors(n):
        phi_2d = cyclotomic_polynomial(2 * d)
        product = poly_multiply(product, phi_2d)

    return product == target


def seifert_genus(p: int) -> int:
    """
    Compute the Seifert genus of torus knot T(2,p).

    g(T(2,p)) = (p-1)/2 = phi(2p)/2

    Args:
        p: An odd prime.

    Returns:
        The Seifert genus.
    """
    return (p - 1) // 2


def knot_determinant(n: int) -> int:
    """
    Compute the knot determinant of T(2,n).

    det(T(2,n)) = |A_n(-1)| = n

    Args:
        n: Parameter of the torus knot.

    Returns:
        The knot determinant.
    """
    coeffs = alexander_polynomial(n)
    val = sum((-1) ** i * c for i, c in enumerate(coeffs))
    return abs(val)


def spectral_classify(b: int) -> str:
    """
    Classify the spectral type of palindromic quadratic X^2 + bX + 1.

    Args:
        b: The middle coefficient.

    Returns:
        "crystalline" if |b| < 2 (roots on unit circle),
        "metallic" if |b| > 2 (real roots),
        "degenerate" if |b| = 2 (repeated roots).
    """
    if b * b < 4:
        return "crystalline"
    elif b * b > 4:
        return "metallic"
    else:
        return "degenerate"


def galois_group_order(n: int) -> int:
    """
    Compute |Gal(Q(zeta_n)/Q)| = phi(n).

    Args:
        n: A positive integer.

    Returns:
        The order of the Galois group.
    """
    return euler_totient(n)


if __name__ == "__main__":
    # Quick verification of all algorithms
    print("Verifying negation bridge for primes 3, 5, 7, 11, 13:")
    for p in [3, 5, 7, 11, 13]:
        print(f"  p={p}: {verify_negation_bridge(p)}")

    print("\nVerifying product decomposition for odd n = 3, 5, 9, 15, 21:")
    for n in [3, 5, 9, 15, 21]:
        print(f"  n={n}: {verify_product_decomposition(n)}")

    print("\nSeifert genus and Galois group order:")
    for p in [3, 5, 7, 11, 13]:
        g = seifert_genus(p)
        gal = galois_group_order(2 * p)
        print(f"  T(2,{p}): genus={g}, |Gal|={gal}, deg(A_p)={p-1}")
