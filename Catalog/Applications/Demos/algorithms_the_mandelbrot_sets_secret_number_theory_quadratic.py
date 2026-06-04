#!/usr/bin/env python3
"""
Algorithms for Mandelbrot Set Number Theory
=============================================
Type-hinted implementations of key algorithms connecting
quadratic iteration to number-theoretic structures.
"""

from typing import List, Tuple, Optional, Dict
import math


def quad_iter(c: complex, z: complex, n: int) -> complex:
    """
    Compute the n-th iterate of z -> z^2 + c.

    Parameters
    ----------
    c : complex - Parameter of the quadratic family
    z : complex - Starting point
    n : int - Number of iterations

    Returns
    -------
    complex - The value z_n = f_c^n(z)
    """
    for _ in range(n):
        z = z * z + c
    return z


def orbit(c: complex, z: complex, n: int) -> List[complex]:
    """
    Compute the orbit {z, f(z), f^2(z), ..., f^n(z)}.

    Returns list of length n+1 starting with z.
    """
    result = [z]
    for _ in range(n):
        z = z * z + c
        result.append(z)
    return result


def orbit_multiplier(c: complex, z: complex, n: int) -> complex:
    """
    Compute the orbit multiplier: (f^n)'(z) = 2^n * prod_{k=0}^{n-1} f^k(z).

    This is the derivative of the n-th iterate at z, computed via the chain rule.
    For z -> z^2 + c, f'(z) = 2z, so the chain rule gives:
    (f^n)'(z) = prod_{k=0}^{n-1} f'(f^k(z)) = prod_{k=0}^{n-1} 2*f^k(z) = 2^n * prod f^k(z).
    """
    product: complex = 1
    current = z
    for _ in range(n):
        product *= current
        current = current * current + c
    return (2 ** n) * product


def mobius(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = prime_factorization(n)
    for _, exp in factors:
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def prime_factorization(n: int) -> List[Tuple[int, int]]:
    """Return prime factorization as list of (prime, exponent) pairs."""
    factors: List[Tuple[int, int]] = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            exp += 1
            n //= d
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def divisors(n: int) -> List[int]:
    """Return sorted list of positive divisors of n."""
    divs: List[int] = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def dynatomic_point_count(n: int) -> int:
    """
    Compute Ψ(n) = Σ_{d|n} μ(n/d) · 2^d.

    This counts the number of periodic points of EXACT period n
    for the generic quadratic map z -> z^2 + c.

    For prime p: Ψ(p) = 2^p - 2 (by Fermat's little theorem, this is divisible by p).
    The number of distinct primitive orbits of period n is Ψ(n)/n.
    """
    return sum(mobius(n // d) * (2 ** d) for d in divisors(n))


def necklace_count(n: int) -> int:
    """
    Count the number of primitive n-orbits = Ψ(n)/n.

    This equals the number of binary necklaces of length n,
    connecting Mandelbrot dynamics to combinatorics.
    """
    psi = dynatomic_point_count(n)
    assert psi % n == 0, f"Ψ({n}) = {psi} is not divisible by {n}"
    return psi // n


def farey_mediant(p1: int, q1: int, p2: int, q2: int) -> Tuple[int, int]:
    """
    Compute the Farey mediant of p1/q1 and p2/q2.

    In the Mandelbrot set, if p1/q1 and p2/q2 are Farey neighbors,
    the bulb between them has rotation number (p1+p2)/(q1+q2).
    """
    return (p1 + p2, q1 + q2)


def stern_brocot_path(p: int, q: int) -> List[str]:
    """
    Find the path in the Stern-Brocot tree to the fraction p/q.

    Returns a sequence of 'L' and 'R' moves, which corresponds
    to the external angle binary expansion in the Mandelbrot set.
    """
    path: List[str] = []
    lo_p, lo_q = 0, 1
    hi_p, hi_q = 1, 0
    while True:
        med_p = lo_p + hi_p
        med_q = lo_q + hi_q
        if med_p * q == p * med_q:
            break
        elif p * med_q < med_p * q:
            path.append('L')
            hi_p, hi_q = med_p, med_q
        else:
            path.append('R')
            lo_p, lo_q = med_p, med_q
    return path


def fibonacci_periods(n_terms: int = 15) -> List[int]:
    """
    Generate the sequence of periods appearing in the Mandelbrot set's
    principal antenna via iterated Farey mediation.

    The sequence is: 1, 2, 3, 5, 8, 13, 21, ... (Fibonacci numbers).
    """
    fibs = [1, 1]
    for _ in range(n_terms):
        fibs.append(fibs[-1] + fibs[-2])
    return fibs


def escape_time(c: complex, max_iter: int = 1000, bailout: float = 2.0) -> int:
    """
    Compute the escape time of the Mandelbrot iteration for parameter c.

    Returns the first n such that |z_n| > bailout, or max_iter if bounded.
    This implements the escape criterion: if |z_n| > max(|c|, 2), the orbit
    diverges monotonically (proved in our Lean formalization).
    """
    z: complex = 0
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > bailout:
            return n
    return max_iter


def find_superattracting_center(
    period: int,
    initial_guess: complex,
    max_newton: int = 100,
    tol: float = 1e-14
) -> Optional[complex]:
    """
    Find the superattracting center of a hyperbolic component of given period.

    Uses Newton's method on the equation f^period(0, c) = 0 in the c-parameter.
    At a superattracting center, the critical point 0 is periodic with the given period.
    """
    c = initial_guess
    for _ in range(max_newton):
        # Compute f^period(0, c) and its derivative w.r.t. c
        z: complex = 0
        dz_dc: complex = 0  # d(z_n)/dc
        for _ in range(period):
            dz_dc = 2 * z * dz_dc + 1
            z = z * z + c
        if abs(dz_dc) < 1e-30:
            return None
        c_new = c - z / dz_dc
        if abs(c_new - c) < tol:
            return c_new
        c = c_new
    return c


def classify_bulb_symmetry(q: int) -> Dict[str, any]:
    """
    Classify the symmetry of a period-q bulb.

    For the 1/q bulb (q prime): dihedral symmetry D_q.
    For composite q: the symmetry group depends on the factorization.

    Returns a dict with symmetry information.
    """
    factors = prime_factorization(q)
    is_prime = len(factors) == 1 and factors[0][1] == 1

    return {
        "period": q,
        "is_prime_period": is_prime,
        "factorization": factors,
        "symmetry": f"D_{q}" if is_prime else f"Product({','.join(f'D_{p}^{e}' for p, e in factors)})",
        "primitive_orbits": necklace_count(q),
        "dynatomic_degree": dynatomic_point_count(q),
    }


if __name__ == "__main__":
    print("Dynatomic point counts and orbit counts:")
    print(f"{'n':>4} {'Ψ(n)':>8} {'orbits':>8} {'factorization':>20}")
    print("-" * 44)
    for n in range(1, 21):
        psi = dynatomic_point_count(n)
        orbs = necklace_count(n)
        facts = prime_factorization(n)
        fact_str = " × ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in facts) if facts else "1"
        print(f"{n:4d} {psi:8d} {orbs:8d} {fact_str:>20}")

    print("\nSuperattracting centers:")
    guesses = {1: 0+0j, 2: -1+0j, 3: -1.75+0j, 4: -1.31+0j, 5: -1.625+0j}
    for period, guess in guesses.items():
        center = find_superattracting_center(period, guess)
        if center is not None:
            z = quad_iter(center, 0, period)
            print(f"  Period {period}: c = {center:.10f}, |f^{period}(0)| = {abs(z):.2e}")

    print("\nBulb symmetry classification:")
    for q in range(2, 13):
        info = classify_bulb_symmetry(q)
        print(f"  q={q:2d}: {info['symmetry']:>20}, "
              f"{info['primitive_orbits']} orbits, "
              f"{'PRIME' if info['is_prime_period'] else 'composite'}")
