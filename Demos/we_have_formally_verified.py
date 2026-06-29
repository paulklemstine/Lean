#!/usr/bin/env python3
"""
Perfect Cuboid Euler Product Sieve — Applications

Demonstrates real-world applications of the local density gap theorem
and the Euler product sieve framework.
"""

from math import prod, log, log2
from typing import List, Tuple
from algorithms import (
    sieve_of_eratosthenes,
    survivor_count_prime,
    local_density,
    projection_bound,
    quadratic_residues,
)


def application_1_search_space_reduction():
    """Application: Reducing the computational search space for perfect cuboids.
    
    When searching for perfect cuboids with edges up to N, one can skip
    triples (a,b,c) that fail local survivor conditions. The density gap
    tells us what fraction of candidates can be eliminated.
    """
    print("=" * 65)
    print("APPLICATION 1: SEARCH SPACE REDUCTION")
    print("=" * 65)
    print()
    print("When searching for perfect cuboids with edges up to N,")
    print("checking local conditions modulo small primes eliminates")
    print("most candidates before expensive integer arithmetic.\n")
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    cumulative_density = 1.0
    
    print(f"{'Primes used':>25}  {'Cumulative density':>20}  {'Reduction factor':>18}")
    print("-" * 65)
    
    for k in range(1, len(primes) + 1):
        p = primes[k - 1]
        d = local_density(p)
        cumulative_density *= d
        reduction = 1.0 / cumulative_density if cumulative_density > 0 else float('inf')
        label = f"3..{p}"
        print(f"  {label:>23s}  {cumulative_density:20.12f}  {reduction:18.1f}×")
    
    print(f"\nUsing primes 3–31, only {cumulative_density*100:.8f}% of")
    print(f"candidates survive. This is a {1/cumulative_density:.0f}× reduction.")
    print(f"For N = 10^12, this reduces ~10^36 candidates to ~{cumulative_density * 1e36:.2e}.")
    print()


def application_2_nonexistence_heuristic():
    """Application: Quantifying the heuristic probability of nonexistence.
    
    The Euler product framework gives a rigorous heuristic for the
    probability that a random triple is a perfect cuboid.
    """
    print("=" * 65)
    print("APPLICATION 2: NONEXISTENCE HEURISTIC")
    print("=" * 65)
    print()
    print("The Euler product of local densities gives a heuristic for")
    print("the expected number of perfect cuboids with edges ≤ N.\n")
    
    primes = [p for p in sieve_of_eratosthenes(50) if p >= 3]
    
    # Compute the partial Euler product
    partial_product = 1.0
    for p in primes:
        d = local_density(p)
        partial_product *= d
    
    print(f"Partial Euler product (primes 3..{primes[-1]}): {partial_product:.12e}")
    print()
    
    # Expected number of cuboids with edges ≤ N
    for log_N in [6, 9, 12, 15, 18]:
        N = 10 ** log_N
        expected = partial_product * N ** 3  # rough heuristic
        print(f"  N = 10^{log_N:2d}: expected cuboids ≈ {expected:.2e} "
              f"(using partial product only)")
    
    print()
    print("Note: The full infinite product would be much smaller.")
    print("The δ=3/10 gap means each prime eliminates ≥30% of survivors,")
    print(f"so the product over k primes is ≤ (7/10)^k.")
    
    # Show the (7/10)^k decay
    print(f"\n  {'k primes':>10}  {'(7/10)^k':>14}  {'equiv to 1 in':>16}")
    for k in [10, 20, 50, 100]:
        decay = (7/10) ** k
        print(f"  {k:10d}  {decay:14.6e}  {1/decay:16.0f}")
    print()


def application_3_sieve_implementation():
    """Application: A practical sieve for ruling out cuboid candidates.
    
    Shows how to implement a multi-prime sieve that efficiently
    eliminates impossible cuboid triples.
    """
    print("=" * 65)
    print("APPLICATION 3: PRACTICAL MULTI-PRIME SIEVE")
    print("=" * 65)
    print()
    
    # Build lookup tables for several primes
    sieve_primes = [3, 5, 7, 11, 13]
    lookup_tables = {}
    
    for p in sieve_primes:
        qr = quadratic_residues(p)
        survivors = set()
        for a in range(p):
            for b in range(p):
                for c in range(p):
                    a2, b2, c2 = a*a % p, b*b % p, c*c % p
                    if ((a2+b2) % p in qr and (a2+c2) % p in qr and
                        (b2+c2) % p in qr and (a2+b2+c2) % p in qr):
                        survivors.add((a, b, c))
        lookup_tables[p] = survivors
        print(f"  Sieve mod {p:2d}: {len(survivors):6d} / {p**3:6d} survivors "
              f"({len(survivors)/p**3*100:5.1f}%)")
    
    # Demonstrate sieving a range
    print(f"\n  Sieving triples (a,b,c) with 1 ≤ a,b,c ≤ 100:")
    N = 100
    total = N ** 3
    surviving = 0
    
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            for c in range(1, N + 1):
                passes_all = True
                for p in sieve_primes:
                    if (a % p, b % p, c % p) not in lookup_tables[p]:
                        passes_all = False
                        break
                if passes_all:
                    surviving += 1
    
    print(f"    Total candidates: {total:,}")
    print(f"    Survivors after sieve: {surviving:,}")
    print(f"    Elimination rate: {(1 - surviving/total)*100:.2f}%")
    print()


def application_4_character_sum_geometry():
    """Application: Visualizing the character-sum structure.
    
    Shows how the survivor predicate decomposes into quadratic
    character evaluations, revealing the finite-field geometry.
    """
    print("=" * 65)
    print("APPLICATION 4: QUADRATIC CHARACTER GEOMETRY")
    print("=" * 65)
    print()
    
    for p in [7, 11, 13]:
        qr = quadratic_residues(p)
        nqr = set(range(1, p)) - qr
        
        print(f"  p = {p}:")
        print(f"    QR: {sorted(qr)}")
        print(f"    NQR: {sorted(nqr)}")
        
        # Count how the quartic fiber factors distribute
        # W² = (r²s²+1)(s²+r²)
        both_sq = 0
        both_nsq = 0
        mixed = 0
        zero_cases = 0
        
        for r in range(p):
            for s in range(p):
                f1 = (r*r*s*s + 1) % p
                f2 = (s*s + r*r) % p
                
                if f1 == 0 or f2 == 0:
                    zero_cases += 1
                elif f1 in qr and f2 in qr:
                    both_sq += 1
                elif f1 in nqr and f2 in nqr:
                    both_nsq += 1
                else:
                    mixed += 1
        
        total_nonzero = both_sq + both_nsq + mixed
        print(f"    Quartic factors (r²s²+1, s²+r²):")
        print(f"      Both QR: {both_sq:4d} ({both_sq/p**2*100:.1f}%) → product is QR")
        print(f"      Both NQR: {both_nsq:4d} ({both_nsq/p**2*100:.1f}%) → product is QR")
        print(f"      Mixed: {mixed:4d} ({mixed/p**2*100:.1f}%) → product is NQR")
        print(f"      Zero: {zero_cases:4d}")
        print(f"    Product is QR: {(both_sq+both_nsq)/p**2*100:.1f}% of (r,s) pairs")
        print()


def application_5_primorial_extinction():
    """Application: Demonstrating primorial extinction law."""
    print("=" * 65)
    print("APPLICATION 5: PRIMORIAL EXTINCTION LAW")
    print("=" * 65)
    print()
    print("The survivor density along primorials tends to zero:")
    print("survivorCount(p₁···pₖ) / (p₁···pₖ)³ → 0 as k → ∞\n")
    
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    primorial = 1
    density_product = 1.0
    
    print(f"{'k':>3}  {'p_k':>4}  {'primorial':>12}  {'density':>16}  {'−log₂(density)':>16}")
    print("-" * 55)
    
    for k, p in enumerate(primes, 1):
        sc = survivor_count_prime(p)
        d = sc / p ** 3
        density_product *= d
        primorial *= p
        bits = -log2(density_product) if density_product > 0 else float('inf')
        print(f"{k:3d}  {p:4d}  {primorial:12d}  {density_product:16.10e}  {bits:16.2f}")
    
    print(f"\nAfter {len(primes)} primes: density ≈ {density_product:.4e}")
    print(f"This is roughly 2^{-log2(density_product):.1f} times smaller than 1.")
    print(f"Each prime contributes about {-log2(density_product)/len(primes):.2f} bits of entropy loss.")
    print()


if __name__ == "__main__":
    application_1_search_space_reduction()
    application_2_nonexistence_heuristic()
    application_3_sieve_implementation()
    application_4_character_sum_geometry()
    application_5_primorial_extinction()


#!/usr/bin/env python3
"""
Perfect Cuboid Euler Product Sieve — Demonstrations

Concrete numerical examples illustrating the theorems proved in our
formal verification. Every computation here corresponds to a certified
result in the companion proof files.
"""

from math import gcd
from functools import reduce


def is_square_mod(x: int, n: int) -> bool:
    """Check whether x is a quadratic residue modulo n (including 0)."""
    x %= n
    return any((k * k) % n == x for k in range(n))


def is_cuboid_survivor(a: int, b: int, c: int, n: int) -> bool:
    """Check whether (a, b, c) satisfies all four cuboid QR conditions mod n."""
    a2, b2, c2 = a * a, b * b, c * c
    return (
        is_square_mod(a2 + b2, n) and
        is_square_mod(a2 + c2, n) and
        is_square_mod(b2 + c2, n) and
        is_square_mod(a2 + b2 + c2, n)
    )


def survivor_count(n: int) -> int:
    """Count the number of cuboid survivors modulo n."""
    count = 0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if is_cuboid_survivor(a, b, c, n):
                    count += 1
    return count


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


def demo_certified_counts():
    """Demonstrate certified survivor counts at small primes."""
    print("=" * 60)
    print("CERTIFIED SURVIVOR COUNTS AT SMALL PRIMES")
    print("=" * 60)
    certified = {
        3: 7, 5: 37, 7: 55, 11: 151, 13: 349,
        17: 817, 19: 487, 23: 1079, 29: 3277, 31: 2431,
    }
    print(f"{'p':>4}  {'survivorCount(p)':>16}  {'p³':>8}  {'density':>10}  {'1−density':>10}")
    print("-" * 60)
    for p, sc in certified.items():
        computed = survivor_count(p)
        assert computed == sc, f"Mismatch at p={p}: {computed} ≠ {sc}"
        density = sc / p ** 3
        gap = 1 - density
        print(f"{p:4d}  {sc:16d}  {p**3:8d}  {density:10.6f}  {gap:10.6f}")
    print()


def demo_density_gap():
    """Demonstrate the uniform density gap δ = 3/10."""
    print("=" * 60)
    print("UNIFORM DENSITY GAP VERIFICATION")
    print("=" * 60)
    print("Theorem: For all odd primes p, survivorCount(p) ≤ (7/10)·p³")
    print("Equivalently, δ = 3/10 is a uniform entropy gap.\n")
    
    primes = [p for p in range(3, 50) if is_prime(p)]
    all_pass = True
    print(f"{'p':>4}  {'sc(p)':>8}  {'(7/10)p³':>10}  {'gap?':>6}  {'10·sc≤3·p³?':>12}")
    print("-" * 50)
    for p in primes:
        sc = survivor_count(p)
        bound_7_10 = 7 * p ** 3 / 10
        bound_3_10 = 3 * p ** 3 / 10
        ok = 10 * sc <= 7 * p ** 3
        strong = 10 * sc <= 3 * p ** 3
        all_pass = all_pass and ok
        print(f"{p:4d}  {sc:8d}  {bound_7_10:10.1f}  {'✓' if ok else '✗':>6}  {'✓' if strong else '✗':>12}")
    
    print(f"\nAll primes ≤ 47 satisfy the gap: {'YES' if all_pass else 'NO'}")
    print()


def demo_pythagorean_count():
    """Demonstrate that #{(a,b,c) : a²+b²=c²} = p² over ZMod p."""
    print("=" * 60)
    print("PYTHAGOREAN TRIPLE COUNT = p²")
    print("=" * 60)
    print("Theorem: For odd primes p, #{(a,b,c) ∈ (Z/pZ)³ : a²+b²=c²} = p²\n")
    
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        if not is_prime(p):
            continue
        count = sum(
            1 for a in range(p) for b in range(p) for c in range(p)
            if (a * a + b * b) % p == (c * c) % p
        )
        print(f"  p = {p:2d}:  count = {count:5d},  p² = {p*p:5d},  match = {'✓' if count == p*p else '✗'}")
    print()


def demo_quartic_factorization():
    """Demonstrate the quartic fiber factorization over Z/pZ."""
    print("=" * 60)
    print("QUARTIC FIBER FACTORIZATION")
    print("=" * 60)
    print("Identity: r²s⁴ + (r⁴+1)s² + r² = (r²s²+1)(s²+r²)")
    print("Verified over Z/pZ for small primes:\n")
    
    for p in [5, 7, 11, 13]:
        ok = True
        for r in range(p):
            for s in range(p):
                lhs = (r**2 * s**4 + (r**4 + 1) * s**2 + r**2) % p
                rhs = ((r**2 * s**2 + 1) * (s**2 + r**2)) % p
                if lhs != rhs:
                    ok = False
                    break
            if not ok:
                break
        print(f"  p = {p:2d}: {'✓ all (r,s) match' if ok else '✗ MISMATCH FOUND'}")
    print()


def demo_bridge_theorem():
    """Demonstrate the bridge theorem: perfect cuboids → local survivors."""
    print("=" * 60)
    print("BRIDGE THEOREM ILLUSTRATION")
    print("=" * 60)
    print("If (x,y,z) is a perfect cuboid with integer diagonals,")
    print("then (x mod n, y mod n, z mod n) is a survivor for every n.\n")
    print("No perfect cuboid is known, but Euler bricks exist:")
    print("  (44, 117, 240) with face diags (125, 244, 267)")
    
    x, y, z = 44, 117, 240
    face1 = x**2 + y**2  # 125² = 15625
    face2 = x**2 + z**2  # 244² = 59536
    face3 = y**2 + z**2  # 267² = 71289
    space = x**2 + y**2 + z**2  # must be square for perfect cuboid
    
    print(f"  x²+y² = {face1} = {int(face1**0.5)}² {'✓' if int(face1**0.5)**2==face1 else '✗'}")
    print(f"  x²+z² = {face2} = {int(face2**0.5)}² {'✓' if int(face2**0.5)**2==face2 else '✗'}")
    print(f"  y²+z² = {face3} = {int(face3**0.5)}² {'✓' if int(face3**0.5)**2==face3 else '✗'}")
    print(f"  x²+y²+z² = {space} (not a perfect square → not a perfect cuboid)")
    print()
    
    # Check survivors for the Euler brick (first 3 conditions only)
    print("  Euler brick local survivors (first 3 conditions only):")
    for n in [3, 5, 7, 11]:
        a, b, c = x % n, y % n, z % n
        s1 = is_square_mod(a**2 + b**2, n)
        s2 = is_square_mod(a**2 + c**2, n)
        s3 = is_square_mod(b**2 + c**2, n)
        print(f"    mod {n:2d}: ({a},{b},{c}) → face diag checks: {s1}, {s2}, {s3}")
    print()


def demo_euler_product_decay():
    """Show exponential decay along primorials."""
    print("=" * 60)
    print("EULER PRODUCT DECAY ALONG PRIMORIALS")
    print("=" * 60)
    print("CRT: survivorCount(m·n) = survivorCount(m)·survivorCount(n)")
    print("for coprime m, n. The density along primorials decays.\n")
    
    primes = [3, 5, 7, 11, 13]
    primorial = 1
    print(f"{'primes used':>25}  {'primorial':>10}  {'density':>12}  {'product bound':>14}")
    print("-" * 65)
    
    product_bound = 1.0
    for p in primes:
        sc = survivor_count(p)
        density = sc / p ** 3
        product_bound *= density
        primorial *= p
        # For the primorial, the density is the product of local densities (by CRT)
        print(f"  ×{p:<2d} → {str(primes[:primes.index(p)+1]):>20s}  {primorial:10d}  "
              f"         -   {product_bound:14.8f}")
    
    print(f"\n  After {len(primes)} primes, product density bound = {product_bound:.8f}")
    print(f"  That's about {product_bound * 100:.4f}% of all triples surviving.")
    print(f"  The density decays exponentially in the number of primes used.")
    print()


if __name__ == "__main__":
    demo_certified_counts()
    demo_density_gap()
    demo_pythagorean_count()
    demo_quartic_factorization()
    demo_bridge_theorem()
    demo_euler_product_decay()
