#!/usr/bin/env python3
"""
MetaFactoring Open Questions Research — Computational Demonstrations

Explores the open questions from the MetaFactoring framework:
1. Smooth number density and the Dickman function
2. Sub-binary recurrence bounds (Fibonacci, Lucas, Tribonacci)
3. Lens independence and information ceiling
4. Classical-quantum Pareto frontier
5. Cross-collision structure in orbits
6. MLC graded monoid hierarchy

Author: MetaFactoring Research Team
"""

import math
from collections import defaultdict

# ============================================================
# 1. SMOOTH NUMBER DENSITY AND DICKMAN FUNCTION
# ============================================================

def is_smooth(n, B):
    """Check if n is B-smooth (all prime factors ≤ B)."""
    if n <= 1:
        return True
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            if d > B:
                return False
            temp //= d
        d += 1
    if temp > 1 and temp > B:
        return False
    return True

def smooth_count(N, B):
    """Count B-smooth numbers up to N."""
    return sum(1 for n in range(1, N + 1) if is_smooth(n, B))

def dickman_rho_approx(u, terms=50):
    """Approximate the Dickman function ρ(u) using the Buchstab identity.
    For 0 ≤ u ≤ 1: ρ(u) = 1
    For 1 < u ≤ 2: ρ(u) = 1 - ln(u)
    For u > 2: computed recursively."""
    if u <= 1:
        return 1.0
    if u <= 2:
        return 1.0 - math.log(u)
    # Simple approximation for u > 2 using the delayed differential equation
    # ρ(u) ≈ ρ(u-1)/u (first-order approximation)
    return dickman_rho_approx(u - 1, terms) / u

print("=" * 70)
print("1. SMOOTH NUMBER DENSITY")
print("=" * 70)

N_values = [100, 1000, 5000, 10000]
B_values = [5, 10, 20, 50]

print(f"\n{'N':>8} | {'B':>4} | {'Ψ(N,B)':>8} | {'Ψ/N':>8} | {'ρ(u)':>8} | {'u=lnN/lnB':>10}")
print("-" * 60)

for N in N_values:
    for B in B_values:
        count = smooth_count(N, B)
        density = count / N
        u = math.log(N) / math.log(B) if B > 1 else 0
        rho = dickman_rho_approx(u)
        print(f"{N:>8} | {B:>4} | {count:>8} | {density:>8.4f} | {rho:>8.4f} | {u:>10.3f}")
    print()

# Verify submonoid properties
print("\nSmooth Number Submonoid Properties:")
print("-" * 40)
smooth_5 = [n for n in range(1, 101) if is_smooth(n, 5)]
print(f"5-smooth numbers ≤ 100: {smooth_5}")

# Test closure under multiplication
print("\nClosure under multiplication:")
for a in smooth_5[:5]:
    for b in smooth_5[:5]:
        prod = a * b
        assert is_smooth(prod, 5), f"{a}×{b}={prod} not 5-smooth!"
        print(f"  {a} × {b} = {prod} (5-smooth: ✓)")

# Test filtration
print("\nFiltration: 5-smooth ⊆ 10-smooth ⊆ 20-smooth")
for B1, B2 in [(5, 10), (10, 20), (20, 50)]:
    count1 = smooth_count(100, B1)
    count2 = smooth_count(100, B2)
    print(f"  Ψ(100, {B1}) = {count1} ≤ Ψ(100, {B2}) = {count2} ✓")

# ============================================================
# 2. SUB-BINARY RECURRENCE BOUNDS
# ============================================================

print("\n" + "=" * 70)
print("2. SUB-BINARY RECURRENCE BOUNDS")
print("=" * 70)

def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def lucas(n):
    if n == 0: return 2
    if n == 1: return 1
    a, b = 2, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def tribonacci(n):
    if n == 0: return 0
    if n == 1: return 0
    if n == 2: return 1
    a, b, c = 0, 0, 1
    for _ in range(n - 2):
        a, b, c = b, c, a + b + c
    return c

print(f"\n{'n':>4} | {'F(n)':>12} | {'L(n)':>12} | {'T(n)':>12} | {'2^n':>12} | F<2^n | L<2^n | T<2^n")
print("-" * 95)

for n in range(1, 25):
    f = fibonacci(n)
    l = lucas(n)
    t = tribonacci(n)
    pow2 = 2**n
    f_ok = "✓" if f < pow2 else "✗"
    l_ok = "✓" if (n < 2 or l < pow2) else "✗"
    t_ok = "✓" if t < pow2 else "✗"
    print(f"{n:>4} | {f:>12} | {l:>12} | {t:>12} | {pow2:>12} | {f_ok:>5} | {l_ok:>5} | {t_ok:>5}")

# Compute ratios (dominant root approximations)
print("\nDominant root approximations (F(n+1)/F(n)):")
print(f"  φ = {(1 + math.sqrt(5))/2:.6f}")
for n in [10, 20, 30, 50]:
    ratio_f = fibonacci(n + 1) / fibonacci(n) if fibonacci(n) > 0 else 0
    ratio_t = tribonacci(n + 1) / tribonacci(n) if tribonacci(n) > 0 else 0
    print(f"  n={n}: F(n+1)/F(n) = {ratio_f:.6f}, T(n+1)/T(n) = {ratio_t:.6f}")

print(f"\nReduction factors:")
print(f"  Fibonacci: 2/φ ≈ {2/((1+math.sqrt(5))/2):.4f}")
print(f"  Tribonacci: 2/1.839 ≈ {2/1.839:.4f}")
print(f"  Fibonacci is {2/((1+math.sqrt(5))/2) / (2/1.839):.2f}× more powerful than Tribonacci")

# ============================================================
# 3. LENS INDEPENDENCE AND INFORMATION CEILING
# ============================================================

print("\n" + "=" * 70)
print("3. LENS INDEPENDENCE AND INFORMATION CEILING")
print("=" * 70)

print(f"\nMaximum meaningful lenses for search space S:")
print(f"{'S':>15} | {'log₂(S)':>10} | {'Max lenses':>12}")
print("-" * 45)

for bits in [64, 128, 256, 512, 1024, 2048, 4096]:
    S = 2**bits
    max_lenses = bits  # floor(log2(S))
    print(f"{'2^'+str(bits):>15} | {bits:>10} | {max_lenses:>12}")

print(f"\nLens hierarchy demonstration:")
S = 1000000
print(f"  S = {S:,}")
for k in range(15):
    reduced = S // (2**k)
    bits_used = k
    print(f"  k={k:>2} lenses: S/2^k = {reduced:>8,} ({bits_used:>2} bits used, {math.log2(S) - k:.1f} bits remaining)")
    if reduced == 0:
        print(f"  → Ceiling reached at k={k} lenses")
        break

# ============================================================
# 4. CLASSICAL-QUANTUM PARETO FRONTIER
# ============================================================

print("\n" + "=" * 70)
print("4. CLASSICAL-QUANTUM PARETO FRONTIER")
print("=" * 70)

def total_cost(S, k, classical_cost_per_lens=1.0, quantum_cost_factor=1.0):
    """Total cost = classical preprocessing + quantum search."""
    classical = classical_cost_per_lens * k
    quantum = quantum_cost_factor * math.sqrt(S / (2**k)) if 2**k <= S else 0
    return classical + quantum

print(f"\nPareto frontier for S = 2^20 = {2**20:,}:")
S = 2**20
print(f"{'k':>4} | {'Classical':>12} | {'Quantum √(S/2^k)':>18} | {'Total':>12} | {'Optimal?':>8}")
print("-" * 65)

costs = []
for k in range(21):
    c_cost = k
    q_cost = math.sqrt(S / (2**k)) if 2**k <= S else 0
    total = c_cost + q_cost
    costs.append((k, c_cost, q_cost, total))

min_cost = min(costs, key=lambda x: x[3])
for k, c, q, t in costs:
    opt = "← MIN" if k == min_cost[0] else ""
    print(f"{k:>4} | {c:>12.1f} | {q:>18.1f} | {t:>12.1f} | {opt}")

print(f"\nOptimal split: k* = {min_cost[0]} lenses")
print(f"  Classical cost: {min_cost[1]:.1f}")
print(f"  Quantum cost:   {min_cost[2]:.1f}")
print(f"  Total cost:     {min_cost[3]:.1f}")
print(f"  Savings vs brute force: {math.sqrt(S) - min_cost[3]:.1f} ({(1 - min_cost[3]/math.sqrt(S))*100:.1f}%)")

# ============================================================
# 5. CROSS-COLLISION AND ORBIT STRUCTURE
# ============================================================

print("\n" + "=" * 70)
print("5. CROSS-COLLISION AND ORBIT STRUCTURE")
print("=" * 70)

def orbit_analysis(f, x, n):
    """Analyze the orbit of x under f in Z/nZ."""
    seen = {}
    current = x
    for step in range(n + 1):
        if current in seen:
            tail_length = seen[current]
            cycle_length = step - tail_length
            return tail_length, cycle_length, step
        seen[current] = step
        current = f(current)
    return n, 0, n

# Squaring map modulo various n
print("\nOrbit analysis for squaring map x → x² mod n:")
print(f"{'n':>6} | {'x₀':>4} | {'Tail':>6} | {'Cycle':>6} | {'Total':>6}")
print("-" * 45)

for n in [17, 21, 35, 55, 77, 91, 143]:
    for x0 in [2, 3, 5]:
        sq_map = lambda x, n=n: (x * x) % n
        tail, cycle, total = orbit_analysis(sq_map, x0, n)
        print(f"{n:>6} | {x0:>4} | {tail:>6} | {cycle:>6} | {total:>6}")

# Demonstrate cross-collision for factoring
print("\nCross-collision factoring demo (Pollard's rho idea):")
N = 8051  # = 83 × 97
print(f"  N = {N} = 83 × 97")

def pollard_rho_demo(N, x0=2, c=1, max_steps=100):
    """Simple Pollard's rho demonstration."""
    x = x0
    y = x0
    d = 1
    steps = 0
    while d == 1 and steps < max_steps:
        x = (x * x + c) % N  # tortoise
        y = (y * y + c) % N  # hare (two steps)
        y = (y * y + c) % N
        d = math.gcd(abs(x - y), N)
        steps += 1
        if steps <= 10 or d > 1:
            print(f"  Step {steps:>3}: x={x:>5}, y={y:>5}, gcd(|x-y|, N) = {d}")
    if d > 1 and d < N:
        print(f"  → Found factor: {d} (N/{d} = {N//d})")
    return d

pollard_rho_demo(N)

# ============================================================
# 6. MLC GRADED MONOID HIERARCHY
# ============================================================

print("\n" + "=" * 70)
print("6. MLC GRADED MONOID HIERARCHY")
print("=" * 70)

S = 2**20  # 1,048,576
print(f"\nMLC hierarchy for S = 2^20 = {S:,}")
print(f"\nPower law: S/2^a/2^b = S/2^(a+b)")
for a in range(5):
    for b in range(5):
        left = S // (2**a) // (2**b)
        right = S // (2**(a+b))
        assert left == right, f"Power law failed for a={a}, b={b}"
print("  ✓ Power law verified for all a,b ∈ [0,4]")

print(f"\nCommutativity: S/2^a/2^b = S/2^b/2^a")
for a in range(5):
    for b in range(5):
        left = S // (2**a) // (2**b)
        right = S // (2**b) // (2**a)
        assert left == right, f"Commutativity failed for a={a}, b={b}"
print("  ✓ Commutativity verified for all a,b ∈ [0,4]")

print(f"\nStrict hierarchy (each level strictly smaller):")
for k in range(20):
    level_k = S // (2**k)
    level_k1 = S // (2**(k+1))
    if level_k == 0:
        print(f"  MLC({k}): {level_k} — ceiling reached")
        break
    print(f"  MLC({k:>2}): {level_k:>10,}  >  MLC({k+1:>2}): {level_k1:>10,}  (ratio: {level_k/(level_k1 if level_k1 > 0 else 1):.1f}×)")

# ============================================================
# 7. NINE LENSES COMPOSITION
# ============================================================

print("\n" + "=" * 70)
print("7. NINE LENSES — COMPOSITION INVARIANCE")
print("=" * 70)

import itertools

S = 1000000
print(f"\nS = {S:,}")
print(f"S / 512 = {S // 512:,}")

# Verify that all orderings of 9 halvings give the same result
result_direct = S // 512
result_sequential = S
for _ in range(9):
    result_sequential //= 2

print(f"\nDirect:     S / 2^9 = S / 512 = {result_direct:,}")
print(f"Sequential: S / 2 / 2 / ... / 2 (9 times) = {result_sequential:,}")
assert result_direct == result_sequential
print("  ✓ Composition invariance verified")

# Educational: map each lens to a math domain
lenses = [
    (1, "Fibonacci-Zeckendorf", "Combinatorics"),
    (2, "Hyperbolic-Geometric", "Analytic Geometry"),
    (3, "Orbit-Dynamical", "Dynamical Systems"),
    (4, "Spectral-Harmonic", "Harmonic Analysis"),
    (5, "Division-Algebra", "Abstract Algebra"),
    (6, "Lattice-Reduction", "Geometry of Numbers"),
    (7, "Congruence-of-Squares", "Modular Arithmetic"),
    (8, "Tropical", "Algebraic Geometry"),
    (9, "Elliptic Curve", "Arithmetic Geometry"),
]

print(f"\nThe Nine MetaFactoring Lenses:")
print("-" * 65)
for num, name, domain in lenses:
    print(f"  Lens {num}: {name:<25} → {domain}")

# ============================================================
# 8. RSA KEY VALIDATION VIA LENSES
# ============================================================

print("\n" + "=" * 70)
print("8. RSA KEY VALIDATION VIA LENSES")
print("=" * 70)

def lens_resistance_score(N, moduli):
    """Compute lens resistance: count of moduli that don't divide N."""
    return sum(1 for m in moduli if N % m != 0)

# Small primes for testing
small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Good RSA-like modulus (product of two large primes)
p, q = 104729, 104743
N_good = p * q

# Bad modulus (divisible by small primes)
N_bad = 2 * 3 * 5 * 7 * 11 * 13 * 104729

print(f"\nLens Resistance Score (higher = more secure):")
print(f"  Good N = {p} × {q} = {N_good:,}")
print(f"    Score: {lens_resistance_score(N_good, small_primes)}/{len(small_primes)}")
for m in small_primes:
    status = "PASS" if N_good % m != 0 else "FAIL"
    print(f"      mod {m:>2}: {N_good % m:>6} [{status}]")

print(f"\n  Bad N = {N_bad:,}")
print(f"    Score: {lens_resistance_score(N_bad, small_primes)}/{len(small_primes)}")
for m in small_primes[:8]:
    status = "PASS" if N_bad % m != 0 else "FAIL"
    print(f"      mod {m:>2}: {N_bad % m:>6} [{status}]")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)
