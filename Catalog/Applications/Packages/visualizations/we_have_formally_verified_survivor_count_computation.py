#!/usr/bin/env python3
"""
Perfect Cuboid Euler Product Sieve — Algorithms

Implements the core algorithms from the research paper with full type hints,
docstrings, complexity analysis, and example usage.
"""

from typing import List, Tuple, Dict, Optional
from math import isqrt, prod, log


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to `limit`.
    
    Time: O(n log log n), Space: O(n).
    
    >>> sieve_of_eratosthenes(30)
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(limit) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def quadratic_residues(p: int) -> set:
    """Return the set of quadratic residues modulo p (including 0).
    
    Time: O(p), Space: O(p).
    
    >>> sorted(quadratic_residues(7))
    [0, 1, 2, 4]
    """
    return {(x * x) % p for x in range(p)}


def survivor_count_prime(p: int) -> int:
    """Compute survivorCount(p) for a prime p.
    
    Counts triples (a, b, c) ∈ (Z/pZ)³ where all four sums
    a²+b², a²+c², b²+c², a²+b²+c² are quadratic residues.
    
    Time: O(p³), Space: O(p).
    
    >>> survivor_count_prime(3)
    7
    >>> survivor_count_prime(5)
    37
    >>> survivor_count_prime(7)
    55
    """
    qr = quadratic_residues(p)
    count = 0
    for a in range(p):
        a2 = (a * a) % p
        for b in range(p):
            ab2 = (a2 + b * b) % p
            if ab2 not in qr:
                continue
            for c in range(p):
                c2 = (c * c) % p
                ac2 = (a2 + c2) % p
                if ac2 not in qr:
                    continue
                bc2 = (b * b + c2) % p
                if bc2 not in qr:
                    continue
                abc2 = (ab2 + c2) % p
                if abc2 not in qr:
                    continue
                count += 1
    return count


def survivor_count_prime_optimized(p: int) -> int:
    """Optimized survivor count using precomputed tables.
    
    Time: O(p³), Space: O(p²).
    
    >>> survivor_count_prime_optimized(11)
    151
    >>> survivor_count_prime_optimized(13)
    349
    """
    qr = quadratic_residues(p)
    # Precompute for each pair (a², b²) whether a²+b² is a QR
    sq_table = [(i * i) % p for i in range(p)]
    count = 0
    for a in range(p):
        a2 = sq_table[a]
        for b in range(p):
            b2 = sq_table[b]
            ab = (a2 + b2) % p
            if ab not in qr:
                continue
            for c in range(p):
                c2 = sq_table[c]
                if ((a2 + c2) % p in qr and
                    (b2 + c2) % p in qr and
                    (ab + c2) % p in qr):
                    count += 1
    return count


def sq_pair_count(p: int) -> int:
    """Count pairs (a,b) in (Z/pZ)² with a²+b² a quadratic residue.
    
    Time: O(p²), Space: O(p).
    
    >>> sq_pair_count(3)
    5
    >>> sq_pair_count(5)
    17
    >>> sq_pair_count(7)
    25
    """
    qr = quadratic_residues(p)
    count = 0
    for a in range(p):
        for b in range(p):
            if (a * a + b * b) % p in qr:
                count += 1
    return count


def pythag_count(p: int) -> int:
    """Count Pythagorean triples (a,b,c) with a²+b²=c² in (Z/pZ)³.
    
    Time: O(p³), Space: O(1).
    
    >>> pythag_count(5)
    25
    >>> pythag_count(7)
    49
    """
    count = 0
    for a in range(p):
        for b in range(p):
            for c in range(p):
                if (a * a + b * b) % p == (c * c) % p:
                    count += 1
    return count


def zero_pair_count(p: int) -> int:
    """Count pairs (a,b) with a²+b² ≡ 0 (mod p).
    
    >>> zero_pair_count(3)
    1
    >>> zero_pair_count(5)
    9
    """
    count = 0
    for a in range(p):
        for b in range(p):
            if (a * a + b * b) % p == 0:
                count += 1
    return count


def local_density(p: int) -> float:
    """Compute the local survivor density at prime p.
    
    Returns survivorCount(p) / p³.
    
    >>> abs(local_density(3) - 7/27) < 1e-10
    True
    """
    return survivor_count_prime(p) / p ** 3


def euler_product_density(primes: List[int]) -> float:
    """Compute the product of local densities over a list of primes.
    
    By CRT multiplicativity, this equals the density of survivors
    modulo the product of the primes.
    
    Time: O(Σ p³) for computing individual survivor counts.
    
    >>> abs(euler_product_density([3, 5]) - (7 * 37) / (3**3 * 5**3)) < 1e-10
    True
    """
    return prod(local_density(p) for p in primes)


def projection_bound(p: int) -> float:
    """Upper bound on survivor density from the projection argument.
    
    Uses the fact that survivorCount(p) ≤ p · sqPairCount(p)
    and sqPairCount(p) ≤ (p² + 2p - 1) / 2.
    
    Returns the bound survivorCount(p)/p³ ≤ (p² + 2p - 1) / (2p²).
    
    >>> projection_bound(5)
    0.68
    """
    return (p ** 2 + 2 * p - 1) / (2 * p ** 2)


def density_table(max_prime: int = 50) -> List[Dict]:
    """Generate a table of survivor densities and bounds for primes up to max_prime.
    
    Returns list of dicts with keys: p, survivor_count, density, projection_bound, gap.
    """
    primes = [p for p in sieve_of_eratosthenes(max_prime) if p >= 3]
    results = []
    for p in primes:
        sc = survivor_count_prime(p)
        d = sc / p ** 3
        pb = projection_bound(p)
        results.append({
            'p': p,
            'survivor_count': sc,
            'density': d,
            'projection_bound': pb,
            'gap': 1 - d,
        })
    return results


def congruence_class_analysis(max_prime: int = 100, modulus: int = 4) -> Dict:
    """Analyze survivor densities stratified by congruence class of p.
    
    Tests Hypothesis 3: whether the density limit depends on p mod m.
    
    Returns dict mapping residue class to list of (p, density) pairs.
    """
    primes = [p for p in sieve_of_eratosthenes(max_prime) if p >= 3]
    classes: Dict[int, List[Tuple[int, float]]] = {}
    for p in primes:
        r = p % modulus
        sc = survivor_count_prime(p)
        d = sc / p ** 3
        classes.setdefault(r, []).append((p, d))
    return classes


if __name__ == "__main__":
    print("=== Density Table ===")
    table = density_table(30)
    print(f"{'p':>4}  {'sc(p)':>8}  {'density':>10}  {'proj_bound':>12}  {'gap':>10}")
    for row in table:
        print(f"{row['p']:4d}  {row['survivor_count']:8d}  "
              f"{row['density']:10.6f}  {row['projection_bound']:12.6f}  "
              f"{row['gap']:10.6f}")
    
    print("\n=== Congruence Class Analysis (mod 4) ===")
    classes = congruence_class_analysis(50, 4)
    for r in sorted(classes.keys()):
        data = classes[r]
        avg_density = sum(d for _, d in data) / len(data)
        print(f"  p ≡ {r} (mod 4): {len(data)} primes, avg density = {avg_density:.6f}")
        for p, d in data:
            print(f"    p = {p:3d}: density = {d:.6f}")
    
    print("\n=== Euler Product Decay ===")
    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for k in range(1, len(primes) + 1):
        subset = primes[:k]
        ep = euler_product_density(subset)
        primorial = prod(subset)
        print(f"  Primes {subset}: primorial = {primorial}, "
              f"product density = {ep:.10f}")
