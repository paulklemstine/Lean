#!/usr/bin/env python3
"""
Berggren Zeta Function Explorer

Explores the zeta function ζ_B(s) = Σ_{PPT (a,b,c)} c^{-s}
including density estimates, convergence, and Euler product structure.
"""

from math import gcd, pi, log, sqrt

def generate_ppts(max_c):
    """Generate all primitive Pythagorean triples with hypotenuse ≤ max_c."""
    ppts = []
    max_m = int(sqrt(max_c)) + 1
    for m in range(2, max_m):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue  # m and n must have different parity
            if gcd(m, n) != 1:
                continue  # must be coprime
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            ppts.append((min(a,b), max(a,b), c))
    return sorted(ppts, key=lambda t: t[2])

print("=" * 70)
print("BERGGREN ZETA FUNCTION EXPLORER")
print("=" * 70)

# Section 1: PPT Density
print("\n--- PPT Counting Function π_PPT(N) ---\n")
limits = [100, 500, 1000, 5000, 10000, 50000]
print(f"{'N':>10} {'π_PPT(N)':>10} {'N/(2π)':>10} {'Ratio':>10}")
print("-" * 45)

for N in limits:
    ppts = generate_ppts(N)
    count = len(ppts)
    predicted = N / (2 * pi)
    ratio = count / predicted if predicted > 0 else 0
    print(f"{N:>10} {count:>10} {predicted:>10.1f} {ratio:>10.4f}")

# Section 2: Zeta function values
print("\n--- Berggren Zeta Function ζ_B(s) ---\n")
ppts = generate_ppts(50000)
s_values = [1.0, 1.1, 1.2, 1.5, 2.0, 3.0, 4.0, 5.0]

print(f"{'s':>6} {'ζ_B(s)':>12} {'Terms used':>12}")
print("-" * 35)

for s in s_values:
    zeta = sum(c**(-s) for a, b, c in ppts)
    print(f"{s:>6.1f} {zeta:>12.6f} {len(ppts):>12}")

# Section 3: Convergence analysis
print("\n--- Convergence Analysis for s=1 ---")
print("ζ_B(1) diverges logarithmically since π_PPT(N) ~ N/(2π)\n")

partial_sums = []
Ns = [10, 50, 100, 500, 1000, 5000, 10000, 50000]
for N in Ns:
    ppts_N = generate_ppts(N)
    zeta1 = sum(1.0/c for a, b, c in ppts_N)
    predicted = log(N) / (2 * pi)
    partial_sums.append((N, zeta1, predicted))
    print(f"  N={N:>6}: Σ 1/c = {zeta1:.4f}, ln(N)/(2π) = {predicted:.4f}, ratio = {zeta1/predicted:.4f}")

# Section 4: ζ_B(2) exploration
print("\n--- ζ_B(2) = Σ 1/c² Exploration ---\n")
ppts_big = generate_ppts(100000)
zeta2 = sum(1.0/c**2 for a, b, c in ppts_big)
print(f"  ζ_B(2) ≈ {zeta2:.8f} (using c ≤ 100,000)")
print(f"  This is a rapidly convergent series.")
print(f"  Comparison: 1/π² = {1/pi**2:.8f}")
print(f"  ζ_B(2) / (1/π²) = {zeta2 * pi**2:.8f}")

# Section 5: Euler product hints
print("\n--- Euler Product Structure ---\n")
print("Hypotenuse factors and their contribution:\n")

from collections import Counter

hyp_factors = Counter()
for a, b, c in ppts:
    # Factor the hypotenuse
    n = c
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    for f in set(factors):
        hyp_factors[f] += 1

print(f"{'Prime':>8} {'Count':>8} {'≡1 mod 4?':>10}")
print("-" * 30)
for p in sorted(hyp_factors.keys())[:20]:
    mod4 = "✓" if p % 4 == 1 else ("(2)" if p == 2 else "✗")
    print(f"{p:>8} {hyp_factors[p]:>8} {mod4:>10}")

# Section 6: Multiple representations
print("\n--- Multiple PPT Representations (same hypotenuse) ---\n")
from collections import defaultdict
hyp_groups = defaultdict(list)
for a, b, c in ppts:
    hyp_groups[c].append((a, b, c))

multi_reps = {c: triples for c, triples in hyp_groups.items() if len(triples) > 1}
print(f"{'c':>6} {'#reps':>6} {'Factorization':>20} {'Triples'}")
print("-" * 70)
for c in sorted(multi_reps.keys())[:15]:
    triples = multi_reps[c]
    # Factor c
    n = c
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    fact_str = "·".join(str(f) for f in factors)
    triple_str = ", ".join(f"({a},{b})" for a, b, _ in triples)
    print(f"{c:>6} {len(triples):>6} {fact_str:>20} {triple_str}")

# Section 7: Information entropy
print("\n--- Information Entropy of PPT Distribution ---\n")
total = len(ppts)
hyp_probs = {c: len(triples)/total for c, triples in hyp_groups.items()}
entropy = -sum(p * log(p) for p in hyp_probs.values() if p > 0)
print(f"  Total PPTs (c ≤ 50000): {total}")
print(f"  Distinct hypotenuses: {len(hyp_groups)}")
print(f"  Shannon entropy: {entropy:.4f} nats")
print(f"  Max entropy (uniform): {log(len(hyp_groups)):.4f} nats")
print(f"  Entropy ratio: {entropy/log(len(hyp_groups)):.4f}")

print("\n--- Key Findings ---")
print(f"1. π_PPT(N) ~ N/(2π) with ratio approaching 1.0000")
print(f"2. ζ_B(s) converges for s > 1, diverges logarithmically at s = 1")
print(f"3. ζ_B(2) ≈ {zeta2:.6f}")
print(f"4. All prime hypotenuses are ≡ 1 (mod 4)")
print(f"5. Multiple representations arise from composite hypotenuses with")
print(f"   multiple prime factors ≡ 1 (mod 4)")
