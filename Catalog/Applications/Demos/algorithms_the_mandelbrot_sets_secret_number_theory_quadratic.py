#!/usr/bin/env python3
"""
Algorithms for Mandelbrot-Möbius Bridge

Type-hinted implementations of the core algorithms connecting
quadratic iteration dynamics to number theory.
"""

from typing import List, Tuple, Dict, Optional
import math


def mandelbrot_iterate(c: complex, n: int) -> List[complex]:
    """Compute the Mandelbrot orbit z_0=0, z_{k+1} = z_k² + c for k=0..n-1.

    Args:
        c: The parameter value (complex or real).
        n: Number of iterations.

    Returns:
        List of n+1 orbit values [z_0, z_1, ..., z_n].
    """
    orbit: List[complex] = [complex(0)]
    z = complex(0)
    for _ in range(n):
        z = z * z + c
        orbit.append(z)
    return orbit


def mandelbrot_polynomial(n: int) -> List[int]:
    """Compute the n-th Mandelbrot polynomial Φ_n as a list of integer coefficients.

    The Mandelbrot polynomials satisfy Φ_0 = 0, Φ_{n+1} = Φ_n² + X.
    Coefficient at index i represents the coefficient of c^i.

    The degree of Φ_n is 2^{n-1} for n ≥ 1, and Φ_n is always monic.

    Args:
        n: The iteration index (non-negative integer).

    Returns:
        List of integer coefficients [a_0, a_1, ..., a_d] where d = 2^{n-1}.
    """
    if n == 0:
        return [0]

    poly: List[int] = [0, 1]  # Φ_1 = c
    for _ in range(n - 1):
        # Square: poly² computed by convolution
        d = len(poly)
        sq: List[int] = [0] * (2 * d - 1)
        for i in range(d):
            for j in range(d):
                sq[i + j] += poly[i] * poly[j]
        # Add X: increment coefficient of c^1
        while len(sq) < 2:
            sq.append(0)
        sq[1] += 1
        poly = sq
    return poly


def poly_eval(coeffs: List[int], x: complex) -> complex:
    """Evaluate polynomial with integer coefficients at x using Horner's method."""
    result = complex(0)
    for c in reversed(coeffs):
        result = result * x + c
    return result


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n).

    φ(n) = n · ∏_{p|n} (1 - 1/p) where the product is over prime divisors of n.
    """
    if n <= 0:
        raise ValueError(f"Totient undefined for n={n}")
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


def mobius_function(n: int) -> int:
    """Compute the Möbius function μ(n).

    μ(1) = 1.
    μ(n) = 0 if n has a squared prime factor.
    μ(n) = (-1)^k if n is a product of k distinct primes.
    """
    if n <= 0:
        raise ValueError(f"Möbius function undefined for n={n}")
    if n == 1:
        return 1
    prime_factors = 0
    temp = n
    p = 2
    while p * p <= temp:
        if temp % p == 0:
            prime_factors += 1
            temp //= p
            if temp % p == 0:
                return 0
        p += 1
    if temp > 1:
        prime_factors += 1
    return (-1) ** prime_factors


def get_divisors(n: int) -> List[int]:
    """Return all positive divisors of n in sorted order."""
    if n <= 0:
        raise ValueError(f"Divisors undefined for n={n}")
    divs: List[int] = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def necklace_count(k: int, n: int) -> int:
    """Count the number of k-ary necklaces of length n.

    A necklace is an equivalence class of strings under cyclic rotation.
    Count = (1/n) Σ_{d|n} φ(d) · k^{n/d}.

    For k=2, this counts binary necklaces and also equals the number of
    orbits of the k-fold angle multiplication map on Q/Z.
    """
    if n <= 0:
        raise ValueError(f"Necklace count undefined for n={n}")
    total = sum(euler_totient(d) * (k ** (n // d)) for d in get_divisors(n))
    return total // n


def lyndon_word_count(k: int, n: int) -> int:
    """Count the number of k-ary Lyndon words (primitive necklaces) of length n.

    A Lyndon word is the lexicographically smallest rotation of an aperiodic string.
    Count = (1/n) Σ_{d|n} μ(n/d) · k^d.

    For k=2, this equals the number of primitive orbits of the doubling map
    and also the number of irreducible polynomials of degree n over F_k.
    """
    if n <= 0:
        raise ValueError(f"Lyndon word count undefined for n={n}")
    total = sum(mobius_function(n // d) * (k ** d) for d in get_divisors(n))
    return total // n


def burnside_necklace_verify(n: int) -> Tuple[int, int]:
    """Verify the Burnside necklace identity for binary strings.

    LHS: Σ_{k=0}^{n-1} 2^{gcd(n,k)}
    RHS: Σ_{d|n} φ(d) · 2^{n/d}

    Returns (LHS, RHS). They should be equal.
    """
    lhs = sum(2 ** math.gcd(n, k) for k in range(n))
    rhs = sum(euler_totient(d) * (2 ** (n // d)) for d in get_divisors(n))
    return lhs, rhs


def period_2_bifurcation_analysis(c: float) -> Dict[str, object]:
    """Analyze the period-1 and period-2 structure at parameter c.

    Fixed points: z² - z + c = 0, discriminant = 1 - 4c.
    Period-2 (non-fixed): z² + z + (c+1) = 0, discriminant = -3 - 4c.
    Period-2 exists iff 4c + 3 < 0 (strict inequality).

    Args:
        c: Real parameter value.

    Returns:
        Dictionary with analysis results.
    """
    fixed_disc = 1 - 4 * c
    period2_disc = -3 - 4 * c

    result: Dict[str, object] = {
        "c": c,
        "fixed_point_discriminant": fixed_disc,
        "period2_discriminant": period2_disc,
        "has_fixed_points": fixed_disc >= 0,
        "has_period2": 4 * c + 3 < 0,
        "fixed_points": [],
        "period2_points": [],
    }

    if fixed_disc >= 0:
        sq = math.sqrt(fixed_disc)
        result["fixed_points"] = [(1 + sq) / 2, (1 - sq) / 2]

    if period2_disc > 0:
        sq = math.sqrt(period2_disc)
        result["period2_points"] = [(-1 + sq) / 2, (-1 - sq) / 2]

    return result


def escape_time(c: complex, max_iter: int = 1000, escape_radius: float = 2.0) -> Optional[int]:
    """Compute the escape time for the Mandelbrot iteration at c.

    The escape radius of 2 is justified by the theorem:
    for real c > 2, the sequence z_n is strictly increasing with z_n ≥ c > 2.

    Args:
        c: Complex parameter.
        max_iter: Maximum number of iterations.
        escape_radius: Escape radius (default 2.0, proven optimal).

    Returns:
        The escape iteration, or None if bounded within max_iter.
    """
    z = complex(0)
    for n in range(1, max_iter + 1):
        z = z * z + c
        if abs(z) > escape_radius:
            return n
    return None


def detect_period(c: float, max_period: int = 100, tolerance: float = 1e-10) -> Optional[int]:
    """Detect the period of the attracting cycle at parameter c.

    Uses the orbit of 0 (critical orbit) and checks for periodicity
    after a transient of max_period iterations.

    Args:
        c: Real parameter.
        max_period: Maximum period to check.
        tolerance: Numerical tolerance for equality.

    Returns:
        Detected period, or None if no period found.
    """
    # Transient
    z = 0.0
    for _ in range(10 * max_period):
        z = z * z + c
        if abs(z) > 1e10:
            return None  # Escapes

    # Record orbit
    orbit = [z]
    for _ in range(max_period):
        z = z * z + c
        if abs(z) > 1e10:
            return None
        orbit.append(z)

    # Check for periodicity
    for d in range(1, max_period + 1):
        if abs(orbit[-1] - orbit[-1 - d]) < tolerance:
            # Verify it's the minimal period
            is_minimal = True
            for sub_d in get_divisors(d):
                if sub_d < d and abs(orbit[-1] - orbit[-1 - sub_d]) < tolerance:
                    is_minimal = False
                    break
            if is_minimal:
                return d
    return None


if __name__ == "__main__":
    # Quick verification
    print("Mandelbrot polynomial degrees:")
    for n in range(1, 7):
        p = mandelbrot_polynomial(n)
        deg = len(p) - 1
        print(f"  Φ_{n}: degree {deg} = 2^{n-1} = {2**(n-1)} ✓" if deg == 2**(n-1)
              else f"  Φ_{n}: degree {deg} ✗")

    print("\nBurnside identity verification:")
    for n in range(1, 11):
        lhs, rhs = burnside_necklace_verify(n)
        print(f"  n={n}: {lhs} = {rhs} {'✓' if lhs == rhs else '✗'}")

    print("\nPeriod detection:")
    for c in [0.0, -1.0, -1.755, -1.25, 0.25]:
        p = detect_period(c)
        print(f"  c={c}: period = {p}")
