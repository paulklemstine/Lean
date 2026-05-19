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
