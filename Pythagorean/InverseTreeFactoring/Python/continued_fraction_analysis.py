#!/usr/bin/env python3
"""
Continued Fraction Analysis of Pythagorean Tree Descent

Investigates the relationship between:
1. The descent path (branch sequence) in the Berggren tree
2. The continued fraction expansion of √N, m/n, and related quantities
3. The Euclid parameter ratios at each descent level

Key finding: The 2×2 Berggren matrices M₁, M₂, M₃ act on the Euclid parameter
space (m, n) as Möbius transformations. The descent path encodes the same
information as the continued fraction expansion of m/n, but in a ternary
(rather than binary/Stern-Brocot) representation related to the theta group Γ_θ.
"""

import math
from typing import List, Tuple
import sys

sys.path.insert(0, '.')
from inverse_tree_factoring import (
    trivial_triple, parent, full_descent, 
    continued_fraction, convergents
)

# ============================================================================
# Euclid Parameters
# ============================================================================

def euclid_params(a: int, b: int, c: int) -> Tuple[int, int]:
    """
    Extract Euclid parameters (m, n) from a primitive Pythagorean triple (a, b, c).
    
    A primitive triple has the form:
    a = m² - n², b = 2mn, c = m² + n²  (if a is odd)
    or a = 2mn, b = m² - n², c = m² + n²  (if a is even)
    
    where m > n > 0, gcd(m,n) = 1, m-n odd.
    """
    # c = m² + n², a = m² - n² (if a odd), b = 2mn
    if a % 2 == 1:
        # a = m² - n², b = 2mn, c = m² + n²
        # m² = (c + a) / 2, n² = (c - a) / 2
        m_sq = (c + a) // 2
        n_sq = (c - a) // 2
        m = int(math.isqrt(m_sq))
        n = int(math.isqrt(n_sq))
        if m * m == m_sq and n * n == n_sq:
            return (m, n)
    
    if b % 2 == 1:
        # b is the odd leg
        m_sq = (c + b) // 2
        n_sq = (c - b) // 2
        m = int(math.isqrt(m_sq))
        n = int(math.isqrt(n_sq))
        if m * m == m_sq and n * n == n_sq:
            return (m, n)
    
    # If a is even: a = 2mn, b = m² - n²
    if a % 2 == 0:
        m_sq = (c + b) // 2
        n_sq = (c - b) // 2
        m = int(math.isqrt(m_sq))
        n = int(math.isqrt(n_sq))
        if m * m == m_sq and n * n == n_sq:
            return (m, n)
    
    return (0, 0)  # Couldn't extract

# ============================================================================
# 2×2 Berggren Matrices on Euclid Parameters
# ============================================================================

def M1_inv(m: int, n: int) -> Tuple[int, int]:
    """Inverse of M₁ = [[2,-1],[1,0]]: M₁⁻¹ = [[0,1],[-1,2]]"""
    return (n, -m + 2*n)

def M2_inv(m: int, n: int) -> Tuple[int, int]:
    """Inverse of M₂ = [[2,1],[1,0]]: M₂⁻¹ = [[0,1],[1,-2]]"""
    # M₂ = [[2,1],[1,0]], det = -1
    # M₂⁻¹ = [[0,-1],[-1,2]]  (det = -1)
    return (-n, -m + 2*n)

def M3_inv(m: int, n: int) -> Tuple[int, int]:
    """Inverse of M₃ = [[1,2],[0,1]]: M₃⁻¹ = [[1,-2],[0,1]]"""
    return (m - 2*n, n)

# ============================================================================
# Analysis
# ============================================================================

def trace_euclid_params(N: int) -> List[Tuple[int, int, float]]:
    """
    Trace the Euclid parameters (m, n) and their ratio m/n
    at each level of the descent.
    """
    path = full_descent(N)
    params = []
    
    for (a, b, c), branch in path:
        m, n = euclid_params(a, b, c)
        if n > 0:
            ratio = m / n
        else:
            ratio = float('inf')
        params.append((m, n, ratio))
    
    return params

def compare_cf_and_descent(N: int):
    """
    Compare the continued fraction expansion of various quantities
    with the descent branch sequence.
    """
    path = full_descent(N)
    branches = [p[1] for p in path[1:]]
    params = trace_euclid_params(N)
    
    print(f"\n{'='*70}")
    print(f"ANALYSIS FOR N = {N}")
    print(f"{'='*70}")
    
    # Starting Euclid parameters
    m0, n0 = (N + 1) // 2, (N - 1) // 2
    
    print(f"\nTrivial triple Euclid params: m={m0}, n={n0}")
    print(f"m/n = {m0}/{n0} = {m0/n0:.10f}")
    print(f"CF(m/n) = {continued_fraction(m0, n0)}")
    
    # sqrt(N)
    s = int(math.isqrt(N))
    print(f"\n√{N} ≈ {math.sqrt(N):.10f}")
    # Integer CF of sqrt(N)
    cf_sqrt = []
    mi, di, ai = 0, 1, s
    cf_sqrt.append(ai)
    for _ in range(20):
        mi = ai * di - mi
        di = (N - mi * mi) // di
        if di == 0:
            break
        ai = (s + mi) // di
        cf_sqrt.append(ai)
        if ai == 2 * s:
            break
    print(f"CF(√{N}) = {cf_sqrt}")
    
    # Branch sequence
    print(f"\nDescent branch sequence (length {len(branches)}):")
    print(f"  {''.join(str(b) for b in branches)}")
    
    # Run-length encoding
    runs = []
    if branches:
        cur, cnt = branches[0], 1
        for b in branches[1:]:
            if b == cur:
                cnt += 1
            else:
                runs.append((cur, cnt))
                cur, cnt = b, 1
        runs.append((cur, cnt))
    print(f"  Run-length: {runs}")
    print(f"  Run lengths only: {[r[1] for r in runs]}")
    
    # Euclid parameter ratios along descent
    print(f"\nEuclid parameter ratios along descent:")
    print(f"  {'Depth':>5} {'m':>8} {'n':>8} {'m/n':>12} {'Branch':>8}")
    for i, ((m, n, ratio), (_, branch)) in enumerate(zip(params, path)):
        if i > 20:
            print(f"  ... ({len(params) - 20} more)")
            break
        print(f"  {i:5d} {m:8d} {n:8d} {ratio:12.6f} {branch:8d}")
    
    # Check if run lengths match CF partial quotients
    run_lengths = [r[1] for r in runs]
    print(f"\n  Run lengths: {run_lengths}")
    print(f"  CF(m₀/n₀): {continued_fraction(m0, n0)}")
    print(f"  CF(√N):     {cf_sqrt}")

def statistical_analysis():
    """
    Statistical analysis of descent depth vs min(p,q) for many semiprimes.
    """
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return [i for i in range(2, n+1) if is_prime[i]]
    
    primes = [p for p in sieve(100) if p > 2 and p % 2 == 1]
    
    print(f"\n{'='*70}")
    print("STATISTICAL ANALYSIS: Descent Depth vs min(p,q)")
    print(f"{'='*70}")
    
    ratios = []
    
    print(f"\n{'N':>8} {'p':>5} {'q':>5} {'depth':>7} {'min(p,q)':>9} {'ratio':>8}")
    print("-" * 50)
    
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            N = p * q
            if N > 5000:
                continue
            
            path = full_descent(N)
            
            # Find depth where factor is first found
            d_star = None
            for d, ((a, b, c), _) in enumerate(path):
                ga = math.gcd(abs(a), N)
                gb = math.gcd(abs(b), N)
                if (1 < ga < N) or (1 < gb < N):
                    d_star = d
                    break
            
            if d_star is not None:
                ratio = d_star / min(p, q)
                ratios.append(ratio)
                print(f"{N:8d} {p:5d} {q:5d} {d_star:7d} {min(p,q):9d} {ratio:8.4f}")
    
    if ratios:
        avg = sum(ratios) / len(ratios)
        median = sorted(ratios)[len(ratios) // 2]
        print(f"\nAverage ratio d*/min(p,q): {avg:.4f}")
        print(f"Median ratio:             {median:.4f}")
        print(f"π/4 ≈                     {math.pi/4:.4f}")
        print(f"Samples:                  {len(ratios)}")

# ============================================================================
# Demo
# ============================================================================

def demo():
    print("=" * 70)
    print("CONTINUED FRACTION ANALYSIS OF PYTHAGOREAN TREE DESCENT")
    print("=" * 70)
    
    for N in [77, 143, 221, 323, 667]:
        compare_cf_and_descent(N)
    
    statistical_analysis()


if __name__ == '__main__':
    demo()
