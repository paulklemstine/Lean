#!/usr/bin/env python3
"""
Certified Algorithms for Certificate Density Computation

Implements the Möbius inversion formula for computing the exact certificate
density δ_n(q) = I(q,n)/(q^n-1) for GL_n(𝔽_q), with complexity analysis.

All algorithms are certified: their outputs are linked to the formal
orbit-stabilizer counting argument via the necklace formula.
"""

from fractions import Fraction
from typing import List, Tuple
import math


def sieve_moebius(N: int) -> List[int]:
    """
    Compute μ(n) for n = 0, 1, ..., N using a sieve.

    Time: O(N log log N)   Space: O(N)

    Returns:
        mu: list where mu[n] = μ(n) for 0 ≤ n ≤ N
    """
    mu = [0] * (N + 1)
    mu[1] = 1
    # Sieve of Eratosthenes-style
    is_prime = [True] * (N + 1)
    primes = []
    for i in range(2, N + 1):
        if is_prime[i]:
            primes.append(i)
            mu[i] = -1  # prime has one factor
        for p in primes:
            if i * p > N:
                break
            is_prime[i * p] = False
            if i % p == 0:
                mu[i * p] = 0  # p^2 divides i*p
                break
            else:
                mu[i * p] = -mu[i]
    return mu


def divisors(n: int) -> List[int]:
    """
    Compute all positive divisors of n.

    Time: O(√n)   Space: O(d(n)) where d(n) is the number of divisors
    """
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def moebius(n: int) -> int:
    """
    Compute the Möbius function μ(n) directly.

    Time: O(√n)   Space: O(1)
    """
    if n <= 0:
        return 0
    if n == 1:
        return 1
    num_factors = 0
    temp = n
    d = 2
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


def necklace_sum(q: int, n: int) -> int:
    """
    Compute the necklace sum N(q,n) = Σ_{d|n} μ(n/d) · q^d.

    This equals n · I(q,n) where I(q,n) is the count of irreducible
    monic polynomials of degree n over 𝔽_q.

    Time: O(d(n) · n)   Space: O(d(n))

    Args:
        q: field size (prime power, q ≥ 2)
        n: polynomial degree (n ≥ 1)

    Returns:
        The necklace sum as an integer.

    >>> necklace_sum(2, 1)
    2
    >>> necklace_sum(2, 2)
    2
    >>> necklace_sum(2, 6)
    54
    """
    return sum(moebius(n // d) * q**d for d in divisors(n))


def irreducible_count(q: int, n: int) -> Fraction:
    """
    Compute I(q,n) = (1/n) · N(q,n), the exact count of irreducible
    monic polynomials of degree n over 𝔽_q.

    Returns a Fraction (always an integer for valid inputs).

    >>> irreducible_count(2, 1)
    Fraction(2, 1)
    >>> irreducible_count(2, 6)
    Fraction(9, 1)
    """
    return Fraction(necklace_sum(q, n), n)


def certificate_density_exact(q: int, n: int) -> Fraction:
    """
    Compute the exact certificate density δ_n(q) = I(q,n) / (q^n - 1).

    This is the proportion of elements in GL_n(𝔽_q) whose characteristic
    polynomial is irreducible (Singer cycle certificates).

    Time: O(d(n) · n)   Space: O(d(n))

    Args:
        q: field size (q ≥ 2)
        n: matrix dimension (n ≥ 2)

    Returns:
        Exact density as a Fraction.

    >>> certificate_density_exact(2, 2)
    Fraction(1, 3)
    """
    return irreducible_count(q, n) / (q**n - 1)


def certificate_density_asymptotic(n: int) -> float:
    """
    The asymptotic certificate density: 1/n.

    This is the leading term, valid as q → ∞ for fixed n.
    """
    return 1.0 / n


def density_error_bound(q: int, n: int) -> float:
    """
    The proven error bound: |δ_n(q) - 1/n| ≤ 1/q^(n//2).

    This bound follows from the function-field prime number theorem.
    """
    return 1.0 / q**(n // 2)


def gl_order(q: int, n: int) -> int:
    """
    Compute |GL_n(𝔽_q)| = ∏_{i=0}^{n-1} (q^n - q^i).

    Time: O(n)   Space: O(1)

    >>> gl_order(2, 2)
    6
    >>> gl_order(2, 3)
    168
    """
    order = 1
    for i in range(n):
        order *= (q**n - q**i)
    return order


def density_table(q_values: List[int], n_values: List[int]) -> List[dict]:
    """
    Compute a table of certificate densities for given q and n values.

    Returns list of dicts with keys: q, n, exact_density, asymptotic, error, bound, ratio
    """
    results = []
    for q in q_values:
        for n in n_values:
            exact = float(certificate_density_exact(q, n))
            asymp = certificate_density_asymptotic(n)
            error = abs(exact - asymp)
            bound = density_error_bound(q, n)
            results.append({
                'q': q, 'n': n,
                'exact_density': exact,
                'asymptotic': asymp,
                'error': error,
                'bound': bound,
                'ratio': error / bound if bound > 0 else 0,
                'irreducible_count': int(irreducible_count(q, n)),
                'gl_order': gl_order(q, n)
            })
    return results


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("Certificate Density Table")
    print("=" * 80)
    results = density_table([2, 3, 5, 7], list(range(2, 9)))
    print(f"{'q':>3} {'n':>3} {'I(q,n)':>8} {'δ_n(q)':>12} {'1/n':>8} {'|error|':>12} {'bound':>12} {'ratio':>8}")
    print("-" * 80)
    for r in results:
        print(f"{r['q']:>3} {r['n']:>3} {r['irreducible_count']:>8} "
              f"{r['exact_density']:>12.8f} {r['asymptotic']:>8.5f} "
              f"{r['error']:>12.8f} {r['bound']:>12.8f} {r['ratio']:>8.4f}")
