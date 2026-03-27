"""
EXPERIMENT 5: Deep Pisano Analysis & The Fibonacci Residue Conjecture
=====================================================================
Deeper analysis of when Fibonacci mod m visits all residues.
Conjecture: Coverage = 1.0 iff m has a specific prime factorization pattern.
"""
import math
from collections import Counter

def pisano_period(m):
    if m == 1: return 1
    a, b = 0, 1
    for i in range(1, 6 * m * m + 1):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return i
    return -1

def fibonacci_residues(m):
    """Return set of residues visited by Fibonacci mod m."""
    period = pisano_period(m)
    residues = set()
    a, b = 0, 1
    for _ in range(period):
        residues.add(a)
        a, b = b, (a + b) % m
    return residues

def prime_factorization(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

# Extended analysis up to m=200
print("Full coverage moduli (Fibonacci visits ALL residues mod m):")
full_coverage = []
for m in range(2, 201):
    residues = fibonacci_residues(m)
    if len(residues) == m:
        factors = prime_factorization(m)
        full_coverage.append(m)
        print(f"  m={m:>4}, factorization={factors}, π(m)={pisano_period(m)}")

print(f"\nFull list: {full_coverage}")

# Analyze which primes appear
print("\n\nPrime factors appearing in full-coverage moduli:")
prime_factors_seen = Counter()
for m in full_coverage:
    for p in prime_factorization(m):
        prime_factors_seen[p] += 1
print(prime_factors_seen)

# Check: is it exactly {m : all prime factors of m are in {2,3,5,7} and specific power conditions}?
print("\n\nHypothesis: full coverage iff m divides some specific highly composite number?")
# Check if all full-coverage m divide some large number
from functools import reduce
lcm_all = reduce(math.lcm, full_coverage)
print(f"LCM of all full-coverage m ≤ 200: {lcm_all}")
print(f"Factorization of LCM: {prime_factorization(lcm_all)}")

# Check which prime powers have full coverage
print("\n\nPrime power analysis:")
for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    for k in range(1, 6):
        pk = p ** k
        if pk > 200:
            break
        residues = fibonacci_residues(pk)
        coverage = len(residues) / pk
        print(f"  p^k = {p}^{k} = {pk:>5}: coverage = {coverage:.4f} ({len(residues)}/{pk})")

# NOVEL: Study the "Fibonacci shadow" - which residues are NEVER visited?
print("\n\nFibonacci Shadows (residues never visited):")
for m in [11, 13, 16, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
    residues = fibonacci_residues(m)
    shadow = set(range(m)) - residues
    period = pisano_period(m)
    print(f"  m={m:>3}: shadow = {sorted(shadow)} ({len(shadow)} values), period={period}")

# Check if shadow values have special number-theoretic properties
print("\n\nShadow analysis for m=p (primes):")
for p in [11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]:
    residues = fibonacci_residues(p)
    shadow = sorted(set(range(p)) - residues)
    # Are shadow values quadratic residues or non-residues?
    qr = set()
    for x in range(1, p):
        qr.add((x * x) % p)
    shadow_qr = [s for s in shadow if s in qr]
    shadow_nqr = [s for s in shadow if s not in qr and s > 0]
    print(f"  p={p:>3}: |shadow|={len(shadow):>3}, QR in shadow: {len(shadow_qr)}, NQR in shadow: {len(shadow_nqr)}")
