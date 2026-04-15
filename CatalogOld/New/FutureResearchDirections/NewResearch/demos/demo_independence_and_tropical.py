#!/usr/bin/env python3
"""
Independence & Tropical Factoring Demo
=======================================
Demonstrates CRT-based lens independence, p-adic tropical profiles,
and quantum search space reduction.
"""

import math
from itertools import product as cartesian_product

def gcd(a, b):
    while b: a, b = b, a % b
    return a

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True

def primes_up_to(B):
    return [p for p in range(2, B + 1) if is_prime(p)]

def padic_val(p, n):
    """p-adic valuation of n."""
    if n == 0: return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def factor(n):
    """Simple trial division."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors

def main():
    print("=" * 80)
    print("INDEPENDENCE & TROPICAL FACTORING DEMO")
    print("=" * 80)
    
    # §1. CRT Independence
    print("\n§1. CRT Independence of Residue Lenses")
    print("-" * 60)
    
    small_primes = primes_up_to(23)
    print(f"Small primes: {small_primes}")
    print(f"Count: {len(small_primes)} independent lenses")
    
    # Show CRT: residues mod distinct primes are independent
    N = 15  # = 3 × 5
    p, q = 3, 5
    
    print(f"\nExample: N = {N} = {p} × {q}")
    print(f"Looking for p = {p}:")
    for ell in small_primes[:5]:
        r = p % ell
        print(f"  p mod {ell} = {r}  →  eliminates {ell - 1}/{ell} of candidates mod {ell}")
    
    # Combined CRT constraint
    modulus = 1
    for ell in small_primes:
        modulus *= ell
    print(f"\nCombined modulus: {' × '.join(map(str, small_primes))} = {modulus:,}")
    print(f"CRT reduces search to 1/{modulus:,} of original space")
    print(f"But only 1/2^{len(small_primes)} = 1/{2**len(small_primes)} from binary constraints")
    
    # §2. Tropical Profile
    print("\n\n§2. Tropical Profile (p-adic Valuations)")
    print("-" * 60)
    
    test_numbers = [12, 60, 360, 2520, 15 * 77, 143 * 11]
    
    for n in test_numbers:
        profile_primes = primes_up_to(max(factor(n)) + 1)[:8]
        profile = [padic_val(p, n) for p in profile_primes]
        factored = ' × '.join(f"{f}" for f in sorted(factor(n)))
        labels = ', '.join(f"v_{p}={v}" for p, v in zip(profile_primes, profile) if v > 0)
        print(f"  N = {n:6d} = {factored:20s} | Profile: [{labels}]")
    
    # §3. Semiprime Tropical Constraint
    print("\n\n§3. Tropical Constraint for Semiprimes")
    print("-" * 60)
    
    semiprimes = [(3, 7), (11, 13), (101, 103), (997, 991)]
    
    for p, q in semiprimes:
        N = p * q
        print(f"\n  N = {N} = {p} × {q}")
        for ell in primes_up_to(13):
            vN = padic_val(ell, N)
            vp = padic_val(ell, p)
            vq = padic_val(ell, q)
            if vN > 0:
                print(f"    v_{ell}(N) = {vN} = v_{ell}({p}) + v_{ell}({q}) = {vp} + {vq}")
        print(f"    All other v_ℓ(N) = 0 (ℓ ≠ {p}, {q})")
    
    # §4. Smooth Number Tropical Filtration
    print("\n\n§4. Smooth Numbers via Tropical Filtration")
    print("-" * 60)
    
    for B in [5, 10, 20]:
        count = 0
        total = 1000
        for n in range(1, total + 1):
            if all(padic_val(p, n) == 0 for p in primes_up_to(100) if p > B):
                count += 1
        density = count / total
        print(f"  {B}-smooth numbers up to {total}: {count} ({density:.1%})")
    
    # §5. Newton Polygon / Perfect Square Detection
    print("\n\n§5. Perfect Square Detection via Tropical Profile")
    print("-" * 60)
    
    for n in [36, 49, 100, 144, 35, 50, 101, 143]:
        profile = [(p, padic_val(p, n)) for p in primes_up_to(20) if padic_val(p, n) > 0]
        all_even = all(v % 2 == 0 for _, v in profile)
        is_square = int(math.sqrt(n)) ** 2 == n
        status = "✓ Square" if is_square else "✗ Not square"
        odd_vals = [(p, v) for p, v in profile if v % 2 == 1]
        
        if odd_vals:
            witness = f"v_{odd_vals[0][0]} = {odd_vals[0][1]} (odd!)"
        else:
            witness = "all even"
        
        print(f"  N = {n:4d}: {status:15s} | Valuations: {witness}")
    
    # §6. Quantum Search Reduction
    print("\n\n§6. Quantum Search Space Reduction")
    print("-" * 60)
    
    n_bits = 1024
    k_lenses = 9
    
    classical_search = n_bits
    grover_search = n_bits / 2
    grover_with_lenses = (n_bits - k_lenses) / 2
    
    print(f"  RSA-2048 factor: {n_bits} bits")
    print(f"  Classical brute force: 2^{classical_search} operations")
    print(f"  Grover (no lenses): 2^{grover_search:.0f} queries ({grover_search:.0f} qubits)")
    print(f"  Grover (with {k_lenses} lenses): 2^{grover_with_lenses:.1f} queries ({grover_with_lenses:.1f} qubits)")
    print(f"  Qubits saved: {grover_search - grover_with_lenses:.1f}")
    print(f"  Physical qubits saved (d=21): {(grover_search - grover_with_lenses) * 882:.0f}")
    
    print("\n" + "=" * 80)
    print("KEY INSIGHT: Tropical valuations provide constraints orthogonal to")
    print("all other lenses. Combined with CRT independence, 9 primes give 9")
    print("independent bits, saving ~4-5 logical qubits in quantum search.")
    print("=" * 80)

if __name__ == "__main__":
    main()
