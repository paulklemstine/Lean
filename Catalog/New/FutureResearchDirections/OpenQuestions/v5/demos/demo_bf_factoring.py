#!/usr/bin/env python3
"""
Brahmagupta-Fibonacci Factoring Algorithm Demo
===============================================
Demonstrates factoring via two sum-of-two-squares representations.

If N = a² + b² = c² + d² with distinct representations,
then gcd(N, ad-bc) yields a nontrivial factor.
"""

from math import gcd, isqrt
from itertools import product
import time

def find_two_square_reps(N, max_reps=2):
    """Find representations of N as a sum of two squares."""
    reps = []
    for a in range(1, isqrt(N) + 1):
        b2 = N - a*a
        if b2 < 0:
            break
        b = isqrt(b2)
        if b*b == b2 and a <= b:
            reps.append((a, b))
            if len(reps) >= max_reps:
                return reps
    return reps

def bf_factor(N):
    """Factor N using Brahmagupta-Fibonacci method."""
    reps = find_two_square_reps(N)
    if len(reps) < 2:
        return None, None, reps
    
    (a, b), (c, d) = reps[0], reps[1]
    
    # Cross-GCD factor extraction
    t1 = abs(a*d - b*c)
    t2 = abs(a*d + b*c)
    
    g1 = gcd(N, t1)
    g2 = gcd(N, t2)
    
    for g in [g1, g2]:
        if 1 < g < N:
            return g, N // g, reps
    
    return None, None, reps

def demo_factoring():
    """Demonstrate BF factoring on various composites."""
    print("=" * 70)
    print("BRAHMAGUPTA-FIBONACCI FACTORING DEMO")
    print("=" * 70)
    print()
    
    # Test cases: products of primes ≡ 1 mod 4
    test_cases = [
        5 * 13,        # 65
        5 * 29,        # 145
        13 * 17,       # 221
        5 * 41,        # 205
        13 * 29,       # 377
        17 * 29,       # 493
        29 * 37,       # 1073
        41 * 53,       # 2173
        61 * 73,       # 4453
        89 * 97,       # 8633
        101 * 137,     # 13837
        197 * 241,     # 47477
        313 * 401,     # 125513
        509 * 613,     # 312017
        701 * 809,     # 567109
        1009 * 1013,   # 1022117
    ]
    
    successes = 0
    total = len(test_cases)
    
    print(f"{'N':>12} {'Reps Found':>12} {'Factor 1':>10} {'Factor 2':>10} {'Status':>10}")
    print("-" * 60)
    
    for N in test_cases:
        start = time.time()
        p, q, reps = bf_factor(N)
        elapsed = time.time() - start
        
        if p is not None:
            successes += 1
            print(f"{N:>12} {len(reps):>12} {p:>10} {q:>10} {'✓':>10}")
        else:
            print(f"{N:>12} {len(reps):>12} {'—':>10} {'—':>10} {'✗':>10}")
    
    print("-" * 60)
    print(f"Success rate: {successes}/{total} = {100*successes/total:.1f}%")
    print()

def demo_cross_gcd_analysis():
    """Analyze the cross-GCD structure for factoring."""
    print("=" * 70)
    print("CROSS-GCD ANALYSIS")
    print("=" * 70)
    print()
    
    N = 5 * 13  # = 65
    reps = find_two_square_reps(N)
    
    print(f"N = {N}")
    print(f"Representations as sum of two squares:")
    for i, (a, b) in enumerate(reps):
        print(f"  Rep {i+1}: {a}² + {b}² = {a*a} + {b*b} = {N}")
    
    if len(reps) >= 2:
        (a, b), (c, d) = reps[0], reps[1]
        print(f"\nCross terms:")
        print(f"  ad - bc = {a}·{d} - {b}·{c} = {a*d - b*c}")
        print(f"  ad + bc = {a}·{d} + {b}·{c} = {a*d + b*c}")
        print(f"\n  N | (ad-bc)(ad+bc) = {(a*d-b*c)*(a*d+b*c)} "
              f"{'✓' if (a*d-b*c)*(a*d+b*c) % N == 0 else '✗'}")
        print(f"\nGCD extraction:")
        print(f"  gcd(N, |ad-bc|) = gcd({N}, {abs(a*d-b*c)}) = {gcd(N, abs(a*d-b*c))}")
        print(f"  gcd(N, |ad+bc|) = gcd({N}, {abs(a*d+b*c)}) = {gcd(N, abs(a*d+b*c))}")
    print()

def demo_sigma1_factoring():
    """Demonstrate factoring via σ₁ (sum of divisors)."""
    print("=" * 70)
    print("σ₁-BASED FACTORING DEMO")
    print("=" * 70)
    print()
    print("For N = pq (semiprime): σ₁(N) = (p+1)(q+1) = N + p + q + 1")
    print("Therefore: p + q = σ₁(N) - N - 1")
    print("Combined with pq = N: solve x² - (p+q)x + N = 0")
    print()
    
    def sigma1(n):
        return sum(d for d in range(1, n+1) if n % d == 0)
    
    test_semiprimes = [(3,5), (7,11), (13,17), (23,29), (31,37), (41,43)]
    
    print(f"{'N':>8} {'σ₁(N)':>8} {'p+q':>6} {'p':>5} {'q':>5} {'Check':>7}")
    print("-" * 45)
    
    for p, q in test_semiprimes:
        N = p * q
        s = sigma1(N)
        pq_sum = s - N - 1
        # Solve x² - (p+q)x + N = 0
        disc = pq_sum * pq_sum - 4 * N
        if disc >= 0:
            sqrt_disc = isqrt(disc)
            if sqrt_disc * sqrt_disc == disc:
                p_found = (pq_sum + sqrt_disc) // 2
                q_found = (pq_sum - sqrt_disc) // 2
                check = "✓" if p_found * q_found == N else "✗"
                print(f"{N:>8} {s:>8} {pq_sum:>6} {q_found:>5} {p_found:>5} {check:>7}")
    print()

def demo_fibonacci_factoring():
    """Demonstrate Fibonacci-based factoring connections."""
    print("=" * 70)
    print("FIBONACCI FACTORING CONNECTIONS")
    print("=" * 70)
    print()
    
    def fib(n):
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a
    
    # Cassini's identity
    print("Cassini's Identity: F(n+1)² - F(n)·F(n+2) = (-1)ⁿ")
    print("-" * 50)
    for n in range(1, 12):
        fn = fib(n)
        fn1 = fib(n+1)
        fn2 = fib(n+2)
        cassini = fn1*fn1 - fn*fn2
        print(f"  n={n:>2}: F({n+1})²-F({n})·F({n+2}) = {fn1}²-{fn}·{fn2} = {cassini} = (-1)^{n}")
    
    print()
    print("F(p)² mod p for primes (should be 1):")
    print("-" * 40)
    primes = [3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        fp = fib(p)
        print(f"  p={p:>2}: F({p})² mod {p} = {(fp*fp) % p}")
    
    print()
    print("F(2n) = F(n)·(2F(n+1) - F(n)): Factorization of even-index Fibonacci")
    print("-" * 60)
    for n in range(2, 10):
        f2n = fib(2*n)
        fn = fib(n)
        fn1 = fib(n+1)
        factor = 2*fn1 - fn
        print(f"  F({2*n}) = {f2n} = F({n})·(2F({n+1})-F({n})) = {fn}·{factor}")
    print()

def demo_energy_landscape():
    """Visualize the factoring energy landscape."""
    print("=" * 70)
    print("FACTORING ENERGY LANDSCAPE")
    print("=" * 70)
    print()
    
    N = 221  # 13 × 17
    print(f"N = {N} = 13 × 17")
    print(f"Divisors: {[d for d in range(1, N+1) if N % d == 0]}")
    print()
    print("Energy E(x) = N mod x for x = 1..30:")
    print("-" * 60)
    
    for x in range(1, 31):
        energy = N % x
        bar = "█" * (energy // 3)
        marker = " ← FACTOR" if energy == 0 else ""
        print(f"  x={x:>3}: E={energy:>4} {bar}{marker}")
    
    # Phase transition analysis
    print()
    print("Phase transition: fraction of x with E(x) ≤ t")
    print("-" * 40)
    for t in [0, 1, 5, 10, 20, 50, 100]:
        count = sum(1 for x in range(1, N+1) if N % x <= t)
        frac = count / N
        print(f"  t={t:>3}: {count:>4}/{N} = {frac:.4f}")
    print()

if __name__ == "__main__":
    demo_bf_factoring = demo_factoring
    demo_bf_factoring()
    demo_cross_gcd_analysis()
    demo_sigma1_factoring()
    demo_fibonacci_factoring()
    demo_energy_landscape()
