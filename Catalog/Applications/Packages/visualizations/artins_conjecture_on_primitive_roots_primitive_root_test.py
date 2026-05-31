"""
Algorithms for Artin's Conjecture on Primitive Roots

Type-hinted implementations of key algorithms for:
1. Testing whether an integer is a primitive root mod p
2. Computing primitive roots mod p
3. Computing the Artin constant approximation
4. Counting primes where a given integer is a primitive root
"""

from typing import List, Tuple, Optional
from math import gcd, isqrt, log
from functools import reduce


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test (deterministic for n < 3.3×10^24)."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    # Test witnesses
    witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for a in witnesses:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def prime_factors(n: int) -> List[int]:
    """Return the list of distinct prime factors of n."""
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def multiplicative_order(a: int, n: int) -> int:
    """Compute the multiplicative order of a modulo n.

    Assumes gcd(a, n) = 1. Uses the factorization of φ(n) for efficiency.
    """
    if gcd(a, n) != 1:
        raise ValueError(f"gcd({a}, {n}) != 1")
    # Compute Euler's totient
    phi = euler_totient(n)
    order = phi
    for p in prime_factors(phi):
        while order % p == 0 and pow(a, order // p, n) == 1:
            order //= p
    return order


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


def is_primitive_root(a: int, p: int) -> bool:
    """Test whether a is a primitive root modulo prime p.

    Uses the efficient criterion: a is a primitive root mod p iff
    a^((p-1)/q) ≢ 1 (mod p) for every prime factor q of p-1.
    """
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")
    if p == 2:
        return a % 2 == 1
    a_mod = a % p
    if a_mod == 0:
        return False
    for q in prime_factors(p - 1):
        if pow(a_mod, (p - 1) // q, p) == 1:
            return False
    return True


def find_primitive_root(p: int) -> int:
    """Find the smallest primitive root modulo prime p."""
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")
    if p == 2:
        return 1
    for g in range(2, p):
        if is_primitive_root(g, p):
            return g
    return -1  # Should never reach here


def is_perfect_square(n: int) -> bool:
    """Test whether an integer is a perfect square."""
    if n < 0:
        return False
    s = isqrt(n)
    return s * s == n


def is_artin_candidate(a: int) -> bool:
    """Test whether a is an Artin candidate (not ±1 and not a perfect square)."""
    if a == 1 or a == -1:
        return False
    if a >= 0:
        return not is_perfect_square(a)
    return not is_perfect_square(-a)  # -k^2 is never a square for k>0 unless k=0


def artin_primes(a: int, bound: int) -> List[int]:
    """Find all primes p ≤ bound for which a is a primitive root mod p."""
    result = []
    for p in range(2, bound + 1):
        if is_prime(p) and gcd(abs(a), p) == 1:
            if is_primitive_root(a % p, p):
                result.append(p)
    return result


def artin_constant_approx(num_primes: int = 1000) -> float:
    """Approximate the Artin constant C = ∏_q (1 - 1/(q(q-1))) over primes q.

    The Artin constant ≈ 0.3739558136...
    """
    product = 1.0
    count = 0
    n = 2
    while count < num_primes:
        if is_prime(n):
            product *= (1.0 - 1.0 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def artin_density(a: int, bound: int) -> Tuple[int, int, float]:
    """Compute the density of primes where a is a primitive root.

    Returns (count, total_primes, ratio) for primes up to bound.
    """
    primes = artin_primes(a, bound)
    total = sum(1 for p in range(2, bound + 1) if is_prime(p))
    count = len(primes)
    ratio = count / total if total > 0 else 0.0
    return count, total, ratio


def safe_primes(bound: int) -> List[Tuple[int, int]]:
    """Find safe primes p = 2q+1 where q is also prime, up to bound.

    For safe primes, the primitive root test reduces to checking just
    two conditions (Legendre symbol and one power test).
    """
    result = []
    for q in range(2, bound):
        if is_prime(q):
            p = 2 * q + 1
            if p <= bound and is_prime(p):
                result.append((p, q))
    return result


if __name__ == "__main__":
    # Quick self-test
    print("Artin constant approximation:", artin_constant_approx(10000))
    print("Primitive roots of 2 up to 100:", artin_primes(2, 100))
    print("Safe primes up to 100:", safe_primes(100))
    print("Density of 2 as primitive root up to 10000:", artin_density(2, 10000))
