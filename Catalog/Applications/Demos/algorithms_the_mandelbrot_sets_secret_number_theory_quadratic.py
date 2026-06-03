#!/usr/bin/env python3
"""
Mandelbrot Number Theory — Core Algorithms

Type-hinted implementations of the key algorithms connecting
Mandelbrot iteration to number theory.
"""

from typing import Optional


def mandelbrot_iterate(c: complex, n: int) -> complex:
    """
    Compute f_c^n(0) where f_c(z) = z^2 + c.

    Algorithm: Simple iteration starting from z = 0.
    Complexity: O(n) multiplications in the base ring.

    Args:
        c: Parameter of the quadratic map
        n: Number of iterations

    Returns:
        The n-th iterate of 0 under z -> z^2 + c
    """
    z: complex = 0
    for _ in range(n):
        z = z * z + c
    return z


def mandelbrot_iterate_mod(c: int, n: int, m: int) -> int:
    """
    Compute f_c^n(0) mod m where f_c(z) = z^2 + c.

    Algorithm: Modular iteration to prevent coefficient blowup.
    Complexity: O(n) multiplications mod m.

    Args:
        c: Parameter (integer)
        n: Number of iterations
        m: Modulus

    Returns:
        f_c^n(0) mod m
    """
    z: int = 0
    for _ in range(n):
        z = (z * z + c) % m
    return z


def orbit_period(c: int, m: int, max_steps: Optional[int] = None) -> Optional[int]:
    """
    Find the minimal period of the Mandelbrot orbit of 0 mod m.

    The minimal period is the smallest positive n such that f_c^n(0) ≡ 0 (mod m).
    Returns None if no such n exists within max_steps.

    Algorithm: Iterate and check for return to 0.
    Complexity: O(period) iterations, guaranteed ≤ m by pigeonhole if the orbit is periodic.

    Args:
        c: Parameter (integer)
        m: Modulus
        max_steps: Maximum iterations to try (default: m^2)

    Returns:
        Minimal period, or None if not found
    """
    if max_steps is None:
        max_steps = m * m
    z: int = 0
    for step in range(1, max_steps + 1):
        z = (z * z + c) % m
        if z == 0:
            return step
    return None


def orbit_signature(c: int, primes: list[int]) -> dict[int, Optional[int]]:
    """
    Compute the Mandelbrot orbit signature of c.

    The signature is the function p ↦ orbit_period(c, p) for each prime p.
    Two integers with the same signature have identical Mandelbrot dynamics
    modulo every prime in the list.

    Algorithm: Compute orbit_period for each prime independently.

    Args:
        c: Integer parameter
        primes: List of primes to compute the signature at

    Returns:
        Dictionary mapping each prime to the orbit period (or None)
    """
    return {p: orbit_period(c, p) for p in primes}


def mandelbrot_polynomial(n: int) -> list[int]:
    """
    Compute the n-th Mandelbrot polynomial P_n as a list of integer coefficients.

    P_0 = 0, P_{n+1} = P_n^2 + X.
    Returns [a_0, a_1, ..., a_d] representing a_0 + a_1*X + ... + a_d*X^d.

    The degree of P_n is 2^{n-1} for n ≥ 1 (Degree Growth Theorem).

    Algorithm: Polynomial squaring by convolution, then adding X.
    Complexity: O(n · 4^n) arithmetic operations.

    Args:
        n: Index of the Mandelbrot polynomial

    Returns:
        List of integer coefficients
    """
    if n == 0:
        return [0]
    p: list[int] = [0, 1]  # P_1 = X
    for _ in range(n - 1):
        # Square: convolve p with itself
        deg = len(p) - 1
        sq: list[int] = [0] * (2 * deg + 1)
        for i in range(len(p)):
            for j in range(len(p)):
                sq[i + j] += p[i] * p[j]
        # Add X
        while len(sq) < 2:
            sq.append(0)
        sq[1] += 1
        p = sq
    return p


def moebius_function(n: int) -> int:
    """
    Compute the Möbius function μ(n).

    μ(1) = 1
    μ(n) = 0 if n has a squared prime factor
    μ(n) = (-1)^k if n is a product of k distinct primes

    Args:
        n: Positive integer

    Returns:
        μ(n) ∈ {-1, 0, 1}
    """
    if n == 1:
        return 1
    num_factors: int = 0
    d: int = 2
    temp: int = n
    while d * d <= temp:
        if temp % d == 0:
            num_factors += 1
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        num_factors += 1
    return (-1) ** num_factors


def integer_divisors(n: int) -> list[int]:
    """Return all positive divisors of n in sorted order."""
    divs: list[int] = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def dynatomic_degree(n: int) -> int:
    """
    Compute the degree of the n-th dynatomic polynomial for the Mandelbrot family.

    By Möbius inversion on deg(P_n) = 2^{n-1}:
        dynatDegree(n) = Σ_{d|n} μ(n/d) · 2^{d-1}

    This equals the number of parameters c ∈ F_p with exact orbit period n,
    for sufficiently large primes p.

    Args:
        n: Period

    Returns:
        Degree of the n-th dynatomic polynomial
    """
    return sum(
        moebius_function(n // d) * (2 ** (d - 1))
        for d in integer_divisors(n)
    )


def count_exact_period_mod_p(n: int, p: int) -> int:
    """
    Count elements c ∈ Z/pZ with exact Mandelbrot orbit period n.

    Args:
        n: Target period
        p: Prime modulus

    Returns:
        Number of c ∈ {0, 1, ..., p-1} with orbit period exactly n
    """
    count: int = 0
    for c in range(p):
        period = orbit_period(c, p, max_steps=p * p)
        if period == n:
            count += 1
    return count


def verify_dynatomic_conjecture(max_period: int, test_primes: list[int]) -> dict:
    """
    Verify the dynatomic degree conjecture: for large enough primes p,
    the number of c ∈ F_p with exact period n equals dynatDegree(n).

    Args:
        max_period: Maximum period to test
        test_primes: Primes to test against

    Returns:
        Dictionary with results for each (period, prime) pair
    """
    results: dict = {}
    for n in range(1, max_period + 1):
        dd = dynatomic_degree(n)
        results[n] = {"dynatomic_degree": dd, "counts": {}}
        for p in test_primes:
            count = count_exact_period_mod_p(n, p)
            results[n]["counts"][p] = {
                "count": count,
                "matches": count == dd
            }
    return results


if __name__ == "__main__":
    # Quick self-test
    assert mandelbrot_iterate(0, 5) == 0
    assert mandelbrot_iterate(-1, 2) == 0
    assert mandelbrot_iterate(-1, 1) == -1

    assert orbit_period(0, 7) == 1  # c=0 always has period 1
    assert orbit_period(-1 % 7, 7) == 2  # c=-1 has period 2

    assert mandelbrot_polynomial(1) == [0, 1]
    assert mandelbrot_polynomial(2) == [0, 1, 1]

    assert dynatomic_degree(1) == 1
    assert dynatomic_degree(2) == 1
    assert dynatomic_degree(3) == 3
    assert dynatomic_degree(4) == 6
    assert dynatomic_degree(5) == 15

    print("All self-tests passed.")
