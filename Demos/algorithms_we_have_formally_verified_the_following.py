#!/usr/bin/env python3
"""
Perfect Cuboid Modular Sieve — Algorithms

Core algorithms for computing cuboid survivor counts and analyzing
the multiplicative structure of the modular sieve.

All algorithms operate over finite fields Z/nZ and exploit the
Chinese Remainder Theorem for efficient factorization.
"""

from typing import List, Tuple, Set, Dict
from math import gcd, prod, isqrt
from functools import reduce
from itertools import product as cartesian_product


def quadratic_residues(n: int) -> Set[int]:
    """
    Compute the set of quadratic residues mod n.
    
    A quadratic residue mod n is any element a such that
    x² ≡ a (mod n) has a solution.
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    Args:
        n: Positive integer modulus
        
    Returns:
        Set of quadratic residues mod n
        
    Example:
        >>> sorted(quadratic_residues(7))
        [0, 1, 2, 4]
    """
    return {(x * x) % n for x in range(n)}


def is_square_mod(a: int, n: int, qr_cache: Set[int] = None) -> bool:
    """
    Check if a is a quadratic residue mod n.
    
    Args:
        a: Integer to test
        n: Modulus
        qr_cache: Pre-computed quadratic residues (optional)
        
    Returns:
        True if a is a square mod n
        
    Example:
        >>> is_square_mod(2, 7)
        True
        >>> is_square_mod(3, 7)
        False
    """
    if qr_cache is None:
        qr_cache = quadratic_residues(n)
    return (a % n) in qr_cache


def is_cuboid_survivor(x: int, y: int, z: int, n: int,
                        qr_cache: Set[int] = None) -> bool:
    """
    Check if the triple (x, y, z) survives the cuboid sieve mod n.
    
    A triple survives if all four sums are quadratic residues mod n:
    - x² + y² (first face diagonal)
    - x² + z² (second face diagonal)  
    - y² + z² (third face diagonal)
    - x² + y² + z² (space diagonal)
    
    Time complexity: O(1) with precomputed QR cache, O(n) without
    
    Args:
        x, y, z: Triple coordinates mod n
        n: Modulus
        qr_cache: Pre-computed quadratic residues (optional)
        
    Returns:
        True if the triple survives all four conditions
        
    Example:
        >>> is_cuboid_survivor(0, 0, 0, 7)
        True
        >>> is_cuboid_survivor(1, 1, 1, 7)
        False
    """
    if qr_cache is None:
        qr_cache = quadratic_residues(n)
    
    x2, y2, z2 = (x * x) % n, (y * y) % n, (z * z) % n
    
    s1 = (x2 + y2) % n
    if s1 not in qr_cache:
        return False
    
    s2 = (x2 + z2) % n
    if s2 not in qr_cache:
        return False
    
    s3 = (y2 + z2) % n
    if s3 not in qr_cache:
        return False
    
    s4 = (x2 + y2 + z2) % n
    if s4 not in qr_cache:
        return False
    
    return True


def survivor_count(n: int) -> int:
    """
    Count the number of cuboid survivors mod n.
    
    Enumerates all triples (x, y, z) in (Z/nZ)³ and counts those
    satisfying all four quadratic residue conditions.
    
    Time complexity: O(n³)
    Space complexity: O(n)
    
    Args:
        n: Positive integer modulus
        
    Returns:
        Number of surviving triples mod n
        
    Example:
        >>> survivor_count(3)
        7
        >>> survivor_count(5)
        37
        >>> survivor_count(7)
        55
    """
    qr = quadratic_residues(n)
    count = 0
    for x in range(n):
        for y in range(n):
            for z in range(n):
                if is_cuboid_survivor(x, y, z, n, qr):
                    count += 1
    return count


def local_density(p: int) -> float:
    """
    Compute the local density factor at prime p.
    
    This is survivorCount(p) / p³, representing the fraction of
    residue classes that survive at this prime.
    
    Args:
        p: Prime number
        
    Returns:
        Local density as a float
        
    Example:
        >>> f"{local_density(7):.6f}"
        '0.160350'
    """
    return survivor_count(p) / (p ** 3)


def euler_product_density(primes: List[int]) -> float:
    """
    Compute the Euler product of local densities.
    
    By CRT multiplicativity, the survivor density at the product
    of coprime moduli equals the product of individual densities.
    
    This gives the fraction of residue classes that survive the
    combined sieve at all given primes.
    
    Time complexity: O(sum(p³) for p in primes)
    
    Args:
        primes: List of distinct primes
        
    Returns:
        Product of local densities
        
    Example:
        >>> f"{euler_product_density([3, 5, 7]):.8f}"
        '0.01230340'
    """
    density = 1.0
    for p in primes:
        density *= local_density(p)
    return density


def verify_crt_multiplicativity(m: int, n: int) -> Tuple[bool, int, int, int]:
    """
    Verify CRT multiplicativity: survivorCount(mn) = survivorCount(m) * survivorCount(n).
    
    Requires gcd(m, n) = 1.
    
    Args:
        m, n: Coprime positive integers
        
    Returns:
        Tuple of (is_valid, count_m, count_n, count_mn)
        
    Raises:
        ValueError: If m and n are not coprime
        
    Example:
        >>> verify_crt_multiplicativity(3, 5)
        (True, 7, 37, 259)
    """
    if gcd(m, n) != 1:
        raise ValueError(f"m={m} and n={n} are not coprime")
    
    cm = survivor_count(m)
    cn = survivor_count(n)
    cmn = survivor_count(m * n)
    
    return (cm * cn == cmn, cm, cn, cmn)


def survivor_list(n: int) -> List[Tuple[int, int, int]]:
    """
    List all cuboid survivor triples mod n.
    
    Args:
        n: Positive integer modulus
        
    Returns:
        List of surviving (x, y, z) triples
        
    Example:
        >>> len(survivor_list(3))
        7
    """
    qr = quadratic_residues(n)
    survivors = []
    for x in range(n):
        for y in range(n):
            for z in range(n):
                if is_cuboid_survivor(x, y, z, n, qr):
                    survivors.append((x, y, z))
    return survivors


def face_diagonal_survivor_count(n: int) -> int:
    """
    Count triples surviving only the three face-diagonal conditions
    (without the space diagonal constraint).
    
    This measures the additional filtering power of the space diagonal.
    
    Args:
        n: Positive integer modulus
        
    Returns:
        Number of face-diagonal survivors
        
    Example:
        >>> face_diagonal_survivor_count(7)
        79
    """
    qr = quadratic_residues(n)
    count = 0
    for x in range(n):
        for y in range(n):
            for z in range(n):
                x2, y2, z2 = (x*x) % n, (y*y) % n, (z*z) % n
                if ((x2+y2) % n in qr and 
                    (x2+z2) % n in qr and 
                    (y2+z2) % n in qr):
                    count += 1
    return count


def space_diagonal_reduction(p: int) -> Tuple[int, int, float]:
    """
    Compute the additional filtering from the space diagonal at prime p.
    
    Returns:
        Tuple of (face_survivors, full_survivors, reduction_fraction)
        
    Example:
        >>> space_diagonal_reduction(7)
        (79, 55, 0.3037974683544304)
    """
    face = face_diagonal_survivor_count(p)
    full = survivor_count(p)
    reduction = (face - full) / face if face > 0 else 0.0
    return (face, full, reduction)


def quartic_fiber_evaluate(r: float, s: float) -> float:
    """
    Evaluate the quartic fiber RHS: r²s⁴ + (r⁴ + 1)s² + r².
    
    For a perfect cuboid parametrization with u = (r²+1)/(2r),
    v = (s²+1)/(2s), the space diagonal equation reduces to
    W² = quartic_fiber(r, s) where W = 2rsw.
    
    Args:
        r, s: Rational parameters (both nonzero)
        
    Returns:
        Value of the quartic fiber polynomial
    """
    return r**2 * s**4 + (r**4 + 1) * s**2 + r**2


def conic_fiber_evaluate(r: float, t: float) -> float:
    """
    Evaluate the conic fiber RHS: r²t² + (r⁴+1)t + r².
    
    This is the quartic fiber after the substitution t = s².
    
    Args:
        r: Rational parameter (nonzero)
        t: Square of s parameter
        
    Returns:
        Value of the conic fiber polynomial
    """
    return r**2 * t**2 + (r**4 + 1) * t + r**2


def compute_prime_table(max_prime: int = 50) -> List[Dict]:
    """
    Compute a comprehensive table of survivor data for primes up to max_prime.
    
    Args:
        max_prime: Upper bound for prime search
        
    Returns:
        List of dictionaries with prime data
        
    Example:
        >>> table = compute_prime_table(10)
        >>> table[0]['prime']
        2
    """
    def is_prime(n):
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
    
    results = []
    for p in range(2, max_prime + 1):
        if not is_prime(p):
            continue
        count = survivor_count(p)
        cube = p ** 3
        face_count = face_diagonal_survivor_count(p)
        results.append({
            'prime': p,
            'survivor_count': count,
            'cube': cube,
            'density': count / cube,
            'face_survivors': face_count,
            'space_kills': face_count - count,
            'space_kill_rate': (face_count - count) / face_count if face_count > 0 else 0,
        })
    
    return results


if __name__ == "__main__":
    print("Computing prime table...")
    table = compute_prime_table(31)
    
    print(f"\n{'p':>4} {'Count':>6} {'p³':>6} {'Density':>8} {'Face':>6} "
          f"{'Space kills':>11} {'Kill%':>6}")
    print("-" * 55)
    for row in table:
        print(f"{row['prime']:>4} {row['survivor_count']:>6} {row['cube']:>6} "
              f"{row['density']:>8.4f} {row['face_survivors']:>6} "
              f"{row['space_kills']:>11} {row['space_kill_rate']:>6.1%}")
    
    print("\nEuler product density decay:")
    primes = [row['prime'] for row in table if row['prime'] >= 3]
    cumulative = 1.0
    for p in primes:
        d = local_density(p)
        cumulative *= d
        print(f"  After p={p:>2}: density = {cumulative:.10f}")
    
    print(f"\nFinal density after {len(primes)} primes: {cumulative:.12f}")
    print(f"Search reduction factor: {1/cumulative:.0f}×")
