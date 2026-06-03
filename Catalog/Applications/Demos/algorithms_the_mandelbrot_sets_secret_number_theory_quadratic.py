#!/usr/bin/env python3
"""
Algorithms for Mandelbrot Number Theory
========================================

Type-hinted implementations of the core algorithms connecting the Mandelbrot
iteration z_{n+1} = z_n^2 + c to number theory.
"""

from typing import Optional, List, Tuple, Dict
from math import gcd


def mandelbrot_iter(c: complex, n: int) -> complex:
    """Compute the n-th iterate of z → z² + c starting from 0.
    
    Args:
        c: The parameter value
        n: Number of iterations
    
    Returns:
        z_n = f_c^n(0)
    """
    z: complex = 0
    for _ in range(n):
        z = z * z + c
    return z


def mandelbrot_iter_mod(c: int, n: int, modulus: int) -> int:
    """Compute the n-th Mandelbrot iterate modulo `modulus`.
    
    Args:
        c: Parameter value in Z/modZ
        n: Number of iterations  
        modulus: The modulus
    
    Returns:
        f_c^n(0) mod modulus
    """
    z: int = 0
    for _ in range(n):
        z = (z * z + c) % modulus
    return z


def mandelbrot_orbit(c: complex, length: int) -> List[complex]:
    """Return the orbit (z_0, z_1, ..., z_{length-1}) of the Mandelbrot map.
    
    Args:
        c: The parameter value
        length: Number of orbit points to compute
    
    Returns:
        List of orbit values
    """
    orbit: List[complex] = [0]
    z: complex = 0
    for _ in range(length - 1):
        z = z * z + c
        orbit.append(z)
    return orbit


def find_orbit_period(c: int, modulus: int, max_iter: int = 1000) -> Optional[int]:
    """Find the minimal period of the Mandelbrot orbit mod `modulus`.
    
    The period is the smallest positive n such that f_c^n(0) ≡ 0 (mod modulus).
    
    Args:
        c: Parameter value
        modulus: The modulus
        max_iter: Maximum iterations to check
    
    Returns:
        The minimal period, or None if not found within max_iter
    """
    z: int = 0
    for n in range(1, max_iter + 1):
        z = (z * z + c) % modulus
        if z == 0:
            return n
    return None


def orbit_multiplier(c: complex, q: int) -> complex:
    """Compute the orbit multiplier ∏_{i=0}^{q-1} 2·z_i.
    
    For the Mandelbrot map f(z) = z² + c, the derivative is f'(z) = 2z,
    so the multiplier of a q-cycle through z_0 is ∏ f'(z_i) = ∏ 2z_i.
    
    Since z_0 = 0 always, the multiplier is always 0 for q ≥ 1.
    This is the superattracting property of the critical orbit.
    
    Args:
        c: Parameter value
        q: Cycle length
    
    Returns:
        The orbit multiplier (always 0 for q ≥ 1)
    """
    product: complex = 1
    z: complex = 0
    for _ in range(q):
        product *= 2 * z
        z = z * z + c
    return product


def moebius(n: int) -> int:
    """Compute the Möbius function μ(n).
    
    μ(1) = 1
    μ(n) = (-1)^k if n is a product of k distinct primes
    μ(n) = 0 if n has a squared prime factor
    
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
            count: int = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            num_factors += 1
        d += 1
    if temp > 1:
        num_factors += 1
    return (-1) ** num_factors


def divisors(n: int) -> List[int]:
    """Return all positive divisors of n in sorted order.
    
    Args:
        n: Positive integer
    
    Returns:
        Sorted list of divisors
    """
    divs: List[int] = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def dynat_degree(n: int) -> int:
    """Compute the dynatomic degree via Möbius inversion.
    
    dynatDegree(n) = Σ_{d|n} μ(n/d) · 2^{d-1}
    
    This gives the degree of the n-th dynatomic polynomial Ψ_n,
    which is the Mandelbrot analogue of the n-th cyclotomic polynomial.
    
    The key identity: Σ_{d|n} dynatDegree(d) = 2^{n-1} = deg(P_n)
    mirrors the cyclotomic identity Σ_{d|n} φ(d) = n.
    
    Args:
        n: Period
    
    Returns:
        dynatDegree(n)
    """
    return sum(moebius(n // d) * (2 ** (d - 1)) for d in divisors(n))


def verify_gcd_theorem(c: int, m: int, n: int, modulus: int) -> bool:
    """Verify the Mandelbrot GCD theorem: if f^m(0) = 0 and f^n(0) = 0,
    then f^{gcd(m,n)}(0) = 0 (all mod modulus).
    
    Args:
        c: Parameter value
        m, n: Return times
        modulus: The modulus
    
    Returns:
        True if the theorem holds for these inputs
    """
    fm = mandelbrot_iter_mod(c, m, modulus)
    fn = mandelbrot_iter_mod(c, n, modulus)
    fg = mandelbrot_iter_mod(c, gcd(m, n), modulus)
    
    if fm != 0 or fn != 0:
        return True  # hypotheses not satisfied, theorem vacuously true
    return fg == 0


def is_mandelbrot_primality_witness(c: int, n: int) -> bool:
    """Check if c is a Mandelbrot primality witness for n.
    
    A witness requires:
    1. f_c^n(0) ≡ 0 (mod n)
    2. f_c^d(0) ≢ 0 (mod n) for all 0 < d < n
    
    Args:
        c: Parameter value in Z/nZ
        n: The number to test
    
    Returns:
        True if c is a valid witness
    """
    if mandelbrot_iter_mod(c, n, n) != 0:
        return False
    for d in range(1, n):
        if mandelbrot_iter_mod(c, d, n) == 0:
            return False
    return True


def find_all_witnesses(n: int) -> List[int]:
    """Find all Mandelbrot primality witnesses for n.
    
    Args:
        n: The number to find witnesses for
    
    Returns:
        List of witness values c ∈ {0, ..., n-1}
    """
    return [c for c in range(n) if is_mandelbrot_primality_witness(c, n)]


def mandelbrot_root_count_table(
    primes: List[int], 
    max_n: int = 5
) -> Dict[Tuple[int, int], int]:
    """Compute a table of Mandelbrot polynomial root counts mod p.
    
    For each prime p and period n, count #{c ∈ F_p : P_n(c) = 0}.
    
    Args:
        primes: List of primes to test
        max_n: Maximum period to check
    
    Returns:
        Dictionary mapping (p, n) to root count
    """
    table: Dict[Tuple[int, int], int] = {}
    for p in primes:
        for n in range(1, max_n + 1):
            count = sum(1 for c in range(p) if mandelbrot_iter_mod(c, n, p) == 0)
            table[(p, n)] = count
    return table


if __name__ == "__main__":
    # Verify the GCD theorem computationally
    print("Verifying GCD theorem for 1000 random cases...")
    import random
    random.seed(42)
    failures = 0
    for _ in range(1000):
        p = random.choice([3, 5, 7, 11, 13, 17, 19, 23, 29, 31])
        c = random.randint(0, p - 1)
        m = random.randint(1, 30)
        n = random.randint(1, 30)
        if not verify_gcd_theorem(c, m, n, p):
            failures += 1
            print(f"  FAILURE: c={c}, m={m}, n={n}, p={p}")
    print(f"  {1000 - failures}/1000 passed" + (" ✓" if failures == 0 else " ✗"))
    
    # Find witnesses
    print("\nMandelbrot primality witnesses:")
    for n in range(2, 20):
        witnesses = find_all_witnesses(n)
        if witnesses:
            print(f"  n={n:3d}: {len(witnesses)} witnesses: {witnesses[:5]}{'...' if len(witnesses) > 5 else ''}")
        else:
            print(f"  n={n:3d}: no witnesses")
    
    # Dynatomic degrees
    print("\nDynatomic degree table:")
    for n in range(1, 16):
        dd = dynat_degree(n)
        total = sum(dynat_degree(d) for d in divisors(n))
        print(f"  n={n:3d}: dynatDegree = {dd:8d}, Σ_{{d|n}} = {total:8d}, 2^{{n-1}} = {2**(n-1):8d}")
