#!/usr/bin/env python3
"""
MetaFactoring Phase II Demo: Tropical Lens & p-adic Valuations

Demonstrates the 8th lens — using p-adic valuations (tropical morphisms)
to constrain integer factorization.
"""

import math
from collections import defaultdict

def p_adic_valuation(n, p):
    """Compute v_p(n): the p-adic valuation of n."""
    if n == 0 or p < 2:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def tropical_profile(n, primes=None):
    """Compute the tropical profile: vector of v_p(n) for small primes."""
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    return {p: p_adic_valuation(n, p) for p in primes}

def verify_tropical_additivity(a, b, primes=None):
    """Verify v_p(a*b) = v_p(a) + v_p(b) for all primes p."""
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13]
    product = a * b
    print(f"\n{'='*60}")
    print(f"Tropical Additivity Verification: a={a}, b={b}, a*b={product}")
    print(f"{'='*60}")
    for p in primes:
        va = p_adic_valuation(a, p)
        vb = p_adic_valuation(b, p)
        vab = p_adic_valuation(product, p)
        status = "✓" if vab == va + vb else "✗"
        print(f"  v_{p}({a}*{b}) = {vab} = {va} + {vb} = v_{p}({a}) + v_{p}({b})  {status}")

def tropical_factoring_demo(N):
    """
    Demonstrate how tropical constraints narrow factoring.
    For N = p*q, the tropical profile of N must decompose as a sum.
    """
    print(f"\n{'='*60}")
    print(f"Tropical Factoring Constraints for N = {N}")
    print(f"{'='*60}")
    
    profile_N = tropical_profile(N)
    print(f"\nTropical profile of {N}:")
    for p, v in profile_N.items():
        if v > 0:
            print(f"  v_{p}({N}) = {v}")
    
    # Find all factorizations
    print(f"\nAll factorizations N = a × b with tropical decomposition:")
    for a in range(2, int(math.sqrt(N)) + 1):
        if N % a == 0:
            b = N // a
            profile_a = tropical_profile(a)
            profile_b = tropical_profile(b)
            print(f"\n  {N} = {a} × {b}")
            for p in [2, 3, 5, 7, 11, 13]:
                va = profile_a.get(p, 0)
                vb = profile_b.get(p, 0)
                if va + vb > 0:
                    print(f"    v_{p}: {va} + {vb} = {va+vb}")

def semiprime_tropical_demo():
    """For semiprimes N=pq (p,q distinct primes), the tropical profile is very sparse."""
    print(f"\n{'='*60}")
    print(f"Semiprime Tropical Profiles")
    print(f"{'='*60}")
    
    semiprimes = [(3, 7), (5, 11), (7, 13), (11, 23), (13, 29), (17, 31)]
    for p, q in semiprimes:
        N = p * q
        print(f"\n  N = {p} × {q} = {N}")
        print(f"    v_{p}(N) = 1, v_{q}(N) = 1, all others = 0")
        print(f"    → Only 1 tropical decomposition: (1,0) + (0,1) at primes {p},{q}")

def tropical_independence_demo():
    """Show that p^v_p(n) | n for various n and p."""
    print(f"\n{'='*60}")
    print(f"Tropical Independence: p^v_p(n) | n")
    print(f"{'='*60}")
    
    examples = [360, 720, 1000, 2520, 5040]
    for n in examples:
        print(f"\n  n = {n}:")
        for p in [2, 3, 5, 7]:
            v = p_adic_valuation(n, p)
            if v > 0:
                pk = p ** v
                divides = n % pk == 0
                print(f"    {p}^{v} = {pk} | {n}  {'✓' if divides else '✗'}")

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  MetaFactoring Phase II: Tropical Lens Demonstration    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # 1. Verify tropical additivity
    verify_tropical_additivity(12, 18)
    verify_tropical_additivity(60, 42)
    
    # 2. Tropical factoring constraints
    tropical_factoring_demo(210)  # 2 × 3 × 5 × 7
    tropical_factoring_demo(143)  # 11 × 13 (semiprime)
    
    # 3. Semiprime analysis
    semiprime_tropical_demo()
    
    # 4. Independence
    tropical_independence_demo()
    
    print(f"\n{'='*60}")
    print("KEY INSIGHT: The tropical lens provides constraints invisible")
    print("to the other 8 lenses — the prime power decomposition structure")
    print("of factors. For semiprimes, the constraint is maximally tight:")
    print("exactly 2 primes have valuation 1, all others 0.")
    print(f"{'='*60}")
