"""
Algorithms for Artin's Conjecture on Primitive Roots

Implements:
1. Primitive root testing via prime factorization
2. Artin counting function π_a(x)
3. Artin sieve weight computation
4. Safe prime detection and primitive root criterion
"""

from math import gcd, isqrt, log
from typing import List, Tuple, Optional
from collections import defaultdict


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test (deterministic for n < 3.3 * 10^24)."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    # Witnesses sufficient for n < 3.3 * 10^24
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
    """Return the distinct prime factors of n."""
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


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    for p in prime_factors(n):
        result -= result // p
    return result


def multiplicative_order(a: int, n: int) -> int:
    """Compute the multiplicative order of a modulo n.
    
    Returns the smallest positive integer k such that a^k ≡ 1 (mod n).
    Requires gcd(a, n) = 1.
    """
    if gcd(a, n) != 1:
        raise ValueError(f"gcd({a}, {n}) != 1")
    order = 1
    current = a % n
    while current != 1:
        current = (current * a) % n
        order += 1
    return order


def is_primitive_root(a: int, p: int) -> bool:
    """Test if a is a primitive root modulo prime p.
    
    Uses the efficient prime-factor test: a is a primitive root mod p iff
    a^((p-1)/q) ≢ 1 (mod p) for every prime q | (p-1).
    
    This is the algorithmic form of our theorem `primroot_test'`.
    """
    if not is_prime(p) or p < 2:
        raise ValueError(f"{p} is not prime")
    if a % p == 0:
        return False
    n = p - 1
    for q in prime_factors(n):
        if pow(a, n // q, p) == 1:
            return False
    return True


def artin_counting_function(a: int, x: int) -> int:
    """Compute π_a(x): the number of primes p ≤ x for which a is a primitive root.
    
    This is the computational version of our formal `artinCountingFunction`.
    """
    count = 0
    for p in range(3, x + 1):
        if is_prime(p) and is_primitive_root(a, p):
            count += 1
    return count


def artin_sieve_weight(p: int) -> float:
    """Compute the Artin sieve weight φ(p-1)/(p-1) for a prime p.
    
    This measures the density of primitive roots in (Z/pZ)*.
    Corresponds to our formal `artinSieveWeight`.
    """
    if not is_prime(p) or p < 3:
        return 0.0
    return euler_totient(p - 1) / (p - 1)


def is_safe_prime(p: int) -> Tuple[bool, Optional[int]]:
    """Check if p is a safe prime (p = 2q+1 with q prime).
    
    Returns (is_safe, q) where q is the Sophie Germain prime if p is safe.
    Safe primes are central to our `safe_prime_primroot_criterion`.
    """
    if not is_prime(p) or p < 5:
        return False, None
    q = (p - 1) // 2
    if is_prime(q):
        return True, q
    return False, None


def primitive_root_power_set(g: int, p: int) -> List[int]:
    """Compute the primitive root power set: {k : g^k is a primitive root mod p}.
    
    Corresponds to our formal `primRootPowerSet`. By our theorem
    `power_is_primroot_iff_coprime`, this equals {k : gcd(k, p-1) = 1}.
    """
    if not is_primitive_root(g, p):
        raise ValueError(f"{g} is not a primitive root mod {p}")
    n = p - 1
    return [k for k in range(n) if gcd(k, n) == 1]


def artin_constant_approximation(num_primes: int = 1000) -> float:
    """Approximate the Artin constant C = ∏_q prime (1 - 1/(q(q-1))).
    
    The Artin constant ≈ 0.3739558136... governs the density of primes
    for which a non-square, non-±1 integer is a primitive root (under GRH).
    """
    product = 1.0
    count = 0
    n = 2
    while count < num_primes:
        if is_prime(n):
            product *= (1 - 1 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def artin_density_ratio(a: int, x: int) -> float:
    """Compute π_a(x) / π(x), the observed density of Artin primes.
    
    Under GRH, this should converge to the Artin constant (with corrections).
    """
    pi_a = artin_counting_function(a, x)
    pi_x = sum(1 for p in range(2, x + 1) if is_prime(p))
    if pi_x == 0:
        return 0.0
    return pi_a / pi_x


def verify_order_formula(p: int) -> bool:
    """Verify our theorem order_of_power_eq computationally.
    
    For a generator g of (Z/pZ)*, verify that ord(g^k) = (p-1)/gcd(p-1, k)
    for all k in {0, ..., p-2}.
    """
    if not is_prime(p):
        return False
    # Find a primitive root
    g = None
    for a in range(2, p):
        if is_primitive_root(a, p):
            g = a
            break
    if g is None:
        return False
    
    n = p - 1
    for k in range(n):
        gk = pow(g, k, p)
        if gk == 0:
            continue
        actual_order = multiplicative_order(gk, p)
        predicted_order = n // gcd(n, k) if k > 0 else 1
        if actual_order != predicted_order:
            return False
    return True


def verify_coprime_criterion(p: int) -> bool:
    """Verify our theorem power_is_primroot_iff_coprime computationally.
    
    For a generator g of (Z/pZ)*, verify that g^k is a primitive root
    iff gcd(k, p-1) = 1.
    """
    if not is_prime(p) or p < 3:
        return False
    g = None
    for a in range(2, p):
        if is_primitive_root(a, p):
            g = a
            break
    if g is None:
        return False
    
    n = p - 1
    for k in range(n):
        gk = pow(g, k, p)
        is_pr = is_primitive_root(gk, p) if gk != 0 else False
        coprime = gcd(k, n) == 1
        if is_pr != coprime:
            return False
    return True


def verify_product_of_primroots(p: int) -> bool:
    """Verify our theorem product_of_primroots_eq computationally.
    
    Check that the product of all primitive roots mod p is ≡ 1 (mod p) for p ≥ 5.
    """
    if not is_prime(p) or p < 5:
        return False
    product = 1
    for a in range(1, p):
        if is_primitive_root(a, p):
            product = (product * a) % p
    return product == 1


if __name__ == "__main__":
    # Quick self-test
    print("=== Artin's Conjecture Algorithms ===\n")
    
    # Test primitive root detection
    print("Primitive roots mod 7:", [a for a in range(1, 7) if is_primitive_root(a, 7)])
    print("Primitive roots mod 13:", [a for a in range(1, 13) if is_primitive_root(a, 13)])
    
    # Artin constant
    C = artin_constant_approximation(10000)
    print(f"\nArtin constant (10000 primes): {C:.10f}")
    print(f"Expected: 0.3739558136...")
    
    # Verify theorems
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31]:
        assert verify_order_formula(p), f"Order formula failed for p={p}"
        assert verify_coprime_criterion(p), f"Coprime criterion failed for p={p}"
        if p >= 5:
            assert verify_product_of_primroots(p), f"Product theorem failed for p={p}"
    print("\nAll theorem verifications passed!")
