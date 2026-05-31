"""
Algorithms for Artin's Conjecture on Primitive Roots

Implementations of key algorithms for computing primitive roots,
testing the Artin conjecture computationally, and estimating densities.
"""

from typing import List, Tuple, Optional
import math


def is_prime(n: int) -> bool:
    """Test primality using trial division."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
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

    Returns the smallest positive integer k such that a^k ≡ 1 (mod n).
    Assumes gcd(a, n) = 1.
    """
    if math.gcd(a, n) != 1:
        raise ValueError(f"gcd({a}, {n}) != 1")
    order = 1
    current = a % n
    while current != 1:
        current = (current * a) % n
        order += 1
    return order


def is_primitive_root(a: int, p: int) -> bool:
    """Test if a is a primitive root modulo prime p.

    Uses the efficient test: a is a primitive root mod p iff
    a^((p-1)/q) ≢ 1 (mod p) for every prime q dividing p-1.

    Args:
        a: Integer to test
        p: Prime modulus

    Returns:
        True if a is a primitive root mod p
    """
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")
    a_mod = a % p
    if a_mod == 0:
        return False

    factors = prime_factors(p - 1)
    for q in factors:
        if pow(a_mod, (p - 1) // q, p) == 1:
            return False
    return True


def is_perfect_square(n: int) -> bool:
    """Test if integer n is a perfect square."""
    if n < 0:
        return False
    s = int(math.isqrt(n))
    return s * s == n


def is_artin_candidate(a: int) -> bool:
    """Test if integer a is an Artin candidate (not ±1, not a perfect square)."""
    if a == 1 or a == -1:
        return False
    if a >= 0:
        return not is_perfect_square(a)
    return not is_perfect_square(-a)  # -n^2 is never a perfect square in Z


def artin_set(a: int, bound: int) -> List[int]:
    """Compute the Artin set A(a) = {p prime : a is a primitive root mod p} up to bound.

    Args:
        a: Integer base
        bound: Upper bound for primes to check

    Returns:
        List of primes p ≤ bound for which a is a primitive root mod p
    """
    result = []
    for p in range(2, bound + 1):
        if is_prime(p) and p > abs(a):
            if is_primitive_root(a, p):
                result.append(p)
    return result


def artin_density(a: int, bound: int) -> float:
    """Compute the density of primes p ≤ bound for which a is a primitive root.

    Args:
        a: Integer base
        bound: Upper bound for primes

    Returns:
        Ratio |A(a) ∩ [2, bound]| / π(bound)
    """
    primes = [p for p in range(2, bound + 1) if is_prime(p)]
    if not primes:
        return 0.0
    artin_primes = [p for p in primes if p > abs(a) and is_primitive_root(a, p)]
    return len(artin_primes) / len(primes)


def artin_constant_approx(num_primes: int = 100) -> float:
    """Approximate the Artin constant C = ∏_q prime (1 - 1/(q(q-1))).

    The Artin constant is approximately 0.3739558136...

    Args:
        num_primes: Number of primes to use in the product

    Returns:
        Approximation of the Artin constant
    """
    product = 1.0
    count = 0
    n = 2
    while count < num_primes:
        if is_prime(n):
            product *= (1 - 1.0 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def safe_primes(bound: int) -> List[Tuple[int, int]]:
    """Find all safe primes p = 2q + 1 with p ≤ bound.

    A safe prime is a prime p such that (p-1)/2 is also prime.

    Args:
        bound: Upper bound

    Returns:
        List of (p, q) pairs where p = 2q + 1, both p and q prime
    """
    result = []
    for q in range(2, bound // 2 + 1):
        if is_prime(q):
            p = 2 * q + 1
            if p <= bound and is_prime(p):
                result.append((p, q))
    return result


def primitive_root_index(a: int, p: int) -> int:
    """Compute the primitive root index of a modulo p.

    The index is (p-1) / ord_p(a), measuring how far a is from
    being a primitive root. Index 1 means a is a primitive root.

    Args:
        a: Integer (coprime to p)
        p: Prime modulus

    Returns:
        The index (p-1) / multiplicative_order(a, p)
    """
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")
    a_mod = a % p
    if a_mod == 0:
        raise ValueError(f"{a} ≡ 0 (mod {p})")
    ord_a = multiplicative_order(a_mod, p)
    return (p - 1) // ord_a


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


def count_primitive_roots(p: int) -> int:
    """Count the number of primitive roots modulo prime p.

    By theory, this equals φ(p-1).

    Args:
        p: Prime

    Returns:
        Number of primitive roots mod p
    """
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")
    return euler_totient(p - 1)


def primitive_root_density_ratio(p: int) -> float:
    """Compute φ(p-1)/(p-1), the fraction of units that are primitive roots.

    Args:
        p: Prime ≥ 3

    Returns:
        The density ratio
    """
    return euler_totient(p - 1) / (p - 1)
