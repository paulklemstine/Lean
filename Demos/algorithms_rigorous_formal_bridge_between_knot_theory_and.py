#!/usr/bin/env python3
"""
Algorithms for Torus Knot Spectral Analysis

Type-hinted implementations of the core algorithms connecting
torus knot Alexander polynomials to cyclotomic structure and OAM spectra.
"""

from typing import List, Tuple, Dict, Optional, Set
from math import gcd, sqrt, pi, log
from functools import reduce


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def divisors(n: int) -> List[int]:
    """Return all positive divisors of n in sorted order."""
    divs: Set[int] = set()
    for i in range(1, int(sqrt(n)) + 1):
        if n % i == 0:
            divs.add(i)
            divs.add(n // i)
    return sorted(divs)


def alternating_polynomial(n: int) -> List[int]:
    """
    Compute A_n(X) = Σ_{k=0}^{n-1} (-1)^k X^k.
    
    Returns coefficients [a_0, a_1, ..., a_{n-1}] where A_n = Σ a_k X^k.
    This is the Alexander polynomial of the torus knot T(2,n) for odd n.
    
    Args:
        n: Positive integer (use odd n for torus knot interpretation)
    
    Returns:
        List of integer coefficients
    """
    return [(-1)**k for k in range(n)]


def polynomial_multiply(p: List[float], q: List[float]) -> List[float]:
    """Multiply two polynomials represented as coefficient lists."""
    if not p or not q:
        return []
    result = [0.0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            result[i + j] += a * b
    return result


def polynomial_divide(p: List[float], q: List[float]) -> Tuple[List[float], List[float]]:
    """
    Polynomial long division. Returns (quotient, remainder).
    Both polynomials given as coefficient lists [a_0, a_1, ...].
    """
    # Convert to high-degree-first for division
    p_rev = list(reversed(p))
    q_rev = list(reversed(q))
    
    if len(p_rev) < len(q_rev):
        return [], list(p)
    
    quotient = [0.0] * (len(p_rev) - len(q_rev) + 1)
    remainder = list(p_rev)
    
    for i in range(len(quotient)):
        coeff = remainder[i] / q_rev[0]
        quotient[i] = coeff
        for j in range(len(q_rev)):
            remainder[i + j] -= coeff * q_rev[j]
    
    # Convert back to low-degree-first
    quot_result = list(reversed(quotient))
    rem_result = list(reversed(remainder[len(quotient):]))
    
    # Clean trailing zeros
    while quot_result and abs(quot_result[-1]) < 1e-10:
        quot_result.pop()
    while rem_result and abs(rem_result[-1]) < 1e-10:
        rem_result.pop()
    
    return quot_result, rem_result


def cyclotomic_polynomial(n: int) -> List[int]:
    """
    Compute the n-th cyclotomic polynomial Φ_n(X) via Möbius inversion.
    
    Uses the identity X^n - 1 = ∏_{d|n} Φ_d(X) and divides out
    all proper-divisor cyclotomic polynomials.
    
    Args:
        n: Positive integer
    
    Returns:
        List of integer coefficients of Φ_n(X)
    """
    if n == 1:
        return [-1, 1]  # X - 1
    
    # Start with X^n - 1
    poly: List[float] = [-1.0] + [0.0] * (n - 1) + [1.0]
    
    for d in range(1, n):
        if n % d == 0:
            div_poly = [float(c) for c in cyclotomic_polynomial(d)]
            poly, rem = polynomial_divide(poly, div_poly)
            assert all(abs(r) < 1e-8 for r in rem), f"Non-exact division at d={d}"
    
    return [int(round(c)) for c in poly]


def cyclotomic_factorization(n: int) -> Dict[int, List[int]]:
    """
    Compute the cyclotomic factorization of A_n(X) for odd n.
    
    For odd n, A_n(X) = (X^n + 1)/(X + 1) = ∏_{d|2n, d∤n, d>2} Φ_d(X).
    
    Returns a dict mapping cyclotomic index d -> Φ_d coefficients.
    
    Args:
        n: Odd positive integer ≥ 3
    
    Returns:
        Dict mapping each cyclotomic factor index to its polynomial
    """
    assert n % 2 == 1 and n >= 3, "n must be odd and >= 3"
    
    factors: Dict[int, List[int]] = {}
    divs_2n = divisors(2 * n)
    
    for d in divs_2n:
        if d <= 2:
            continue  # Skip Φ_1 = X-1 and Φ_2 = X+1
        if (2 * n) % d == 0 and n % d != 0:
            factors[d] = cyclotomic_polynomial(d)
    
    return factors


def spectral_classify(b: int) -> str:
    """
    Classify the OAM spectrum of a palindromic quadratic t² + bt + 1.
    
    Args:
        b: The linear coefficient
    
    Returns:
        Classification string: "crystalline", "metallic", or "degenerate"
    """
    disc = b * b - 4
    if disc < 0:
        return "crystalline"
    elif disc > 0:
        return "metallic"
    else:
        return "degenerate"


def oam_mode_positions(n: int) -> List[float]:
    """
    Compute OAM mode angular positions for T(2,n) torus knot.
    
    The modes are at angles 2πk/(2n) for k coprime to 2n and k odd
    (corresponding to primitive (2n)-th roots of unity that are not
    n-th roots of unity).
    
    Args:
        n: Odd integer ≥ 3
    
    Returns:
        Sorted list of angles in [0, 2π)
    """
    assert n % 2 == 1 and n >= 3
    
    angles: List[float] = []
    for k in range(1, 2 * n):
        if gcd(k, 2 * n) == 1 or (k % 2 == 1 and gcd(k, n) == 1):
            # Check if e^{2πik/(2n)} is a root of A_n
            pass
    
    # More directly: roots of A_n are the primitive (2d)-th roots of unity
    # for each d in the cyclotomic factorization
    factors = cyclotomic_factorization(n)
    for d in factors:
        for k in range(1, d):
            if gcd(k, d) == 1:
                angle = 2 * pi * k / d
                if angle not in angles:
                    angles.append(angle)
    
    return sorted(angles)


def oam_mode_count(n: int) -> int:
    """
    Compute the number of OAM modes for T(2,n).
    
    This equals n-1 = deg(A_n) = Σ φ(2d) over the cyclotomic factors.
    
    Args:
        n: Odd integer ≥ 3
    
    Returns:
        Number of OAM modes
    """
    return n - 1


def mahler_measure(coeffs: List[int]) -> float:
    """
    Compute the logarithmic Mahler measure of a polynomial.
    
    m(p) = log|a_d| + Σ max(0, log|α_i|) where α_i are roots.
    For cyclotomic polynomials, m(p) = 0.
    
    Args:
        coeffs: Polynomial coefficients [a_0, a_1, ...]
    
    Returns:
        Logarithmic Mahler measure
    """
    import cmath
    
    if len(coeffs) <= 1:
        return log(abs(coeffs[0])) if coeffs else 0.0
    
    # Find roots using numpy if available, otherwise companion matrix
    try:
        import numpy as np
        roots = np.roots(coeffs[::-1])
        leading = abs(coeffs[-1])
        return log(leading) + sum(max(0, log(abs(r))) for r in roots)
    except ImportError:
        # Fallback: numerical estimate via Jensen's formula
        n_points = 1000
        total = 0.0
        for k in range(n_points):
            theta = 2 * pi * k / n_points
            z = complex(cos(theta), sin(theta))
            val = sum(c * z**i for i, c in enumerate(coeffs))
            total += log(max(abs(val), 1e-300))
        return total / n_points


def spectral_gap(n: int) -> float:
    """
    Compute the minimum angular gap between adjacent OAM modes for T(2,n).
    
    For the T(2,n) torus knot, the minimum gap is π/n.
    
    Args:
        n: Odd integer ≥ 3
    
    Returns:
        Minimum angular gap in radians
    """
    return pi / n


if __name__ == "__main__":
    # Demonstrate key algorithms
    print("=== Alternating Polynomials ===")
    for n in [3, 5, 7]:
        print(f"A_{n} = {alternating_polynomial(n)}")
    
    print("\n=== Cyclotomic Factorization ===")
    for n in [3, 5, 7, 15]:
        factors = cyclotomic_factorization(n)
        print(f"A_{n} = " + " · ".join(
            f"Φ_{d}" for d in sorted(factors.keys())))
        total_deg = sum(len(f) - 1 for f in factors.values())
        print(f"  Total degree: {total_deg} = {n-1}")
    
    print("\n=== Spectral Classification ===")
    for b in [-3, -1, 0, 1, 3]:
        cls = spectral_classify(b)
        disc = b*b - 4
        print(f"b = {b:+d}: disc = {disc:+d}, class = {cls}")
    
    print("\n=== OAM Mode Counts ===")
    for n in [3, 5, 7, 9, 11, 15]:
        count = oam_mode_count(n)
        gap = spectral_gap(n)
        print(f"T(2,{n}): {count} modes, gap = π/{n} = {gap:.4f} rad")
    
    print("\n=== Mahler Measures ===")
    knots = {
        "Trefoil (Φ_6)": [1, -1, 1],
        "Cinquefoil (Φ_10)": [1, -1, 1, -1, 1],
        "Figure-eight": [1, -3, 1],
    }
    for name, coeffs in knots.items():
        m = mahler_measure(coeffs)
        print(f"{name}: m = {m:.6f}" + 
              (" [cyclotomic → 0]" if abs(m) < 0.01 else ""))
