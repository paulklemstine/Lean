#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Numerical demonstrations of the key results:
1. Product witnesses in random pseudo-prime systems
2. Density of product-free vs random sets
3. Factorization length spectra
4. Residue class distribution
"""

import random
import math
from collections import defaultdict

random.seed(42)

def cramer_random_primes(N: int) -> set:
    """Generate a Cramér random pseudo-prime set up to N.
    Each integer n ≥ 2 is included independently with probability 1/log(n)."""
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / math.log(n):
            S.add(n)
    return S

def find_product_witnesses(S: set, N: int) -> list:
    """Find triples (a, b, a*b) where all three are in S."""
    witnesses = []
    S_list = sorted(S)
    for i, a in enumerate(S_list):
        for b in S_list[i:]:
            if a * b > N:
                break
            if a * b in S:
                witnesses.append((a, b, a * b))
    return witnesses

def counting_function(S: set, n: int) -> int:
    """π_S(n): count of elements in S up to n."""
    return sum(1 for x in S if x <= n)

def residue_class_counts(S: set, q: int) -> dict:
    """Count elements of S in each residue class mod q."""
    counts = defaultdict(int)
    for x in S:
        counts[x % q] += 1
    return dict(counts)


# === Demonstration 1: Product Witnesses ===
print("=" * 70)
print("DEMO 1: Product Witnesses in Cramér Random Primes")
print("=" * 70)

for N in [100, 1000, 10000]:
    S = cramer_random_primes(N)
    witnesses = find_product_witnesses(S, N)
    print(f"\nN = {N}:")
    print(f"  |S| = {len(S)}, expected ≈ {N / math.log(N):.1f}")
    print(f"  Product witnesses found: {len(witnesses)}")
    if witnesses:
        print(f"  First 5: {witnesses[:5]}")

    # Check real primes for comparison
    real_primes = set()
    sieve = [True] * (N + 1)
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    real_primes = {i for i in range(2, N + 1) if sieve[i]}

    real_witnesses = find_product_witnesses(real_primes, N)
    print(f"  Real primes |P| = {len(real_primes)}, witnesses: {len(real_witnesses)}")


# === Demonstration 2: Unique Factorization Failure ===
print("\n" + "=" * 70)
print("DEMO 2: Multiple Factorizations in Random Systems")
print("=" * 70)

def s_factorizations(S: set, n: int, max_depth: int = 10) -> list:
    """Find all S-factorizations of n (multisets of S-elements with product n)."""
    if max_depth == 0:
        return []
    results = []
    if n in S:
        results.append([n])
    S_sorted = sorted(x for x in S if 2 <= x <= n // 2)
    for a in S_sorted:
        if n % a == 0:
            sub_facts = s_factorizations(S, n // a, max_depth - 1)
            for sf in sub_facts:
                if sf and a <= sf[0]:  # avoid duplicates
                    results.append([a] + sf)
    return results

S = cramer_random_primes(200)
witnesses = find_product_witnesses(S, 200)
if witnesses:
    a, b, c = witnesses[0]
    print(f"\nProduct witness: {a} × {b} = {c}")
    facts = s_factorizations(S, c)
    print(f"S-factorizations of {c}:")
    for f in facts[:10]:
        print(f"  {' × '.join(map(str, f))} = {c}")


# === Demonstration 3: Counting Function Comparison ===
print("\n" + "=" * 70)
print("DEMO 3: Counting Function π_S(n) vs n/log(n)")
print("=" * 70)

N = 10000
S = cramer_random_primes(N)
checkpoints = [100, 500, 1000, 2000, 5000, 10000]
print(f"\n{'n':>8} | {'π_S(n)':>8} | {'n/ln(n)':>8} | {'ratio':>8}")
print("-" * 42)
for n in checkpoints:
    pi_s = counting_function(S, n)
    expected = n / math.log(n)
    ratio = pi_s / expected if expected > 0 else 0
    print(f"{n:>8} | {pi_s:>8} | {expected:>8.1f} | {ratio:>8.3f}")


# === Demonstration 4: Residue Class Equidistribution ===
print("\n" + "=" * 70)
print("DEMO 4: Dirichlet Survival — Residue Classes mod 6")
print("=" * 70)

N = 50000
S = cramer_random_primes(N)
rc = residue_class_counts(S, 6)
print(f"\nRandom pseudo-primes mod 6 (N={N}):")
for r in sorted(rc.keys()):
    print(f"  ≡ {r} (mod 6): {rc[r]} elements")

# Real primes for comparison
sieve = [True] * (N + 1)
for i in range(2, int(N**0.5) + 1):
    if sieve[i]:
        for j in range(i*i, N + 1, i):
            sieve[j] = False
real_primes = {i for i in range(2, N + 1) if sieve[i]}
rc_real = residue_class_counts(real_primes, 6)
print(f"\nReal primes mod 6 (N={N}):")
for r in sorted(rc_real.keys()):
    print(f"  ≡ {r} (mod 6): {rc_real[r]} elements")


# === Demonstration 5: Shadow Size Computation ===
print("\n" + "=" * 70)
print("DEMO 5: Shadow Exclusion — Density Constraint")
print("=" * 70)

N = 1000
S = cramer_random_primes(N)
S_list = sorted(S)
if 2 in S:
    shadow_2 = {2 * k for k in S if 2 * k <= N}
    overlap = shadow_2 & S
    print(f"\nS has {len(S)} elements, 2 ∈ S: True")
    print(f"Shadow(S, 2, {N}) has {len(shadow_2)} elements")
    print(f"Overlap |Shadow ∩ S| = {len(overlap)} (these are product witnesses)")
    if overlap:
        print(f"  Witnesses: {sorted(overlap)[:10]}...")
    print(f"Product-free? {'Yes' if len(overlap) == 0 else 'No'}")
else:
    print(f"\n2 ∉ S in this sample, picking another element...")
    p = min(S)
    shadow_p = {p * k for k in S if p * k <= N}
    overlap = shadow_p & S
    print(f"Shadow(S, {p}, {N}) has {len(shadow_p)} elements")
    print(f"Overlap = {len(overlap)}")


# === Demonstration 6: Factorization Length Spectrum ===
print("\n" + "=" * 70)
print("DEMO 6: Factorization Length Spectrum")
print("=" * 70)

N = 200
S = cramer_random_primes(N)
length_hist = defaultdict(int)
multi_fact_count = 0

for n in range(4, N + 1):
    facts = s_factorizations(S, n, max_depth=5)
    lengths = set(len(f) for f in facts)
    if len(lengths) > 1:
        multi_fact_count += 1
        for l in lengths:
            length_hist[l] += 1

print(f"\nNumbers in [4, {N}] with multiple factorization lengths: {multi_fact_count}")
print("Length spectrum (length → count of numbers with that length):")
for l in sorted(length_hist.keys()):
    print(f"  Length {l}: {length_hist[l]} numbers")


print("\n" + "=" * 70)
print("CONCLUSION: Random pseudo-primes inevitably produce product witnesses,")
print("destroying unique factorization. The PNT and Dirichlet's theorem survive")
print("because they depend only on density, not multiplicative structure.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Factorization Length Spectrum and Density Comparison

Shows the factorization length spectrum in random vs real prime systems,
and the density (counting function) comparison.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
import random
from collections import defaultdict

def cramer_random_primes(N, seed=None):
    if seed is not None:
        random.seed(seed)
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / math.log(n):
            S.add(n)
    return S

def sieve_of_eratosthenes(N):
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return {i for i in range(2, N + 1) if is_prime[i]}

def enumerate_factorizations(S, n, max_depth=8):
    if max_depth <= 0:
        return []
    results = []
    if n in S:
        results.append([n])
    S_sorted = sorted(x for x in S if 2 <= x * x <= n)
    for a in S_sorted:
        if n % a == 0:
            remainder = n // a
            sub_facts = enumerate_factorizations(S, remainder, max_depth - 1)
            for sf in sub_facts:
                if sf and a <= sf[0]:
                    results.append([a] + sf)
    return results

N = 5000
S_random = cramer_random_primes(N, seed=42)
S_real = sieve_of_eratosthenes(N)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Top-left: Counting function comparison
ax = axes[0, 0]
ns = np.arange(10, N + 1)
pi_random = np.array([sum(1 for x in S_random if x <= n) for n in ns])
pi_real = np.array([sum(1 for x in S_real if x <= n) for n in ns])
pi_theory = ns / np.log(ns)

ax.plot(ns, pi_random, color='#e74c3c', alpha=0.7, linewidth=1.5,
       label='Cramér random π_S(n)')
ax.plot(ns, pi_real, color='#2ecc71', linewidth=2,
       label='Real primes π(n)')
ax.plot(ns, pi_theory, 'k--', linewidth=1.5,
       label='n/ln(n)')
ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('Counting function', fontsize=13)
ax.set_title('PNT Survives: Both Follow n/ln(n)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Top-right: Residue class distribution mod 6
ax = axes[0, 1]
classes = [1, 5]  # coprime to 6
for a in classes:
    counts_random = [sum(1 for x in S_random if x <= n and x % 6 == a)
                     for n in range(10, 2001, 50)]
    counts_real = [sum(1 for x in S_real if x <= n and x % 6 == a)
                   for n in range(10, 2001, 50)]
    ns_sub = list(range(10, 2001, 50))
    ax.plot(ns_sub, counts_random, alpha=0.7, linewidth=1.5,
           label=f'Random ≡{a} (mod 6)')
    ax.plot(ns_sub, counts_real, '--', linewidth=2,
           label=f'Primes ≡{a} (mod 6)')

ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('Count in residue class', fontsize=13)
ax.set_title('Dirichlet Survives: Equidistribution mod 6', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom-left: Factorization length spectrum (small N)
ax = axes[1, 0]
N_small = 150
S_small = cramer_random_primes(N_small, seed=42)

length_counts_random = defaultdict(int)
multi_fact_numbers = []
for n in range(4, N_small + 1):
    facts = enumerate_factorizations(S_small, n)
    lengths = set(len(f) for f in facts)
    for l in lengths:
        length_counts_random[l] += 1
    if len(lengths) > 1:
        multi_fact_numbers.append(n)

lengths_list = sorted(length_counts_random.keys())
counts_list = [length_counts_random[l] for l in lengths_list]

bars = ax.bar(lengths_list, counts_list, color='#9b59b6', alpha=0.8,
             edgecolor='#2c3e50')
ax.set_xlabel('Factorization Length', fontsize=13)
ax.set_ylabel('Numbers with this length', fontsize=13)
ax.set_title(f'Length Spectrum (Random S, N={N_small})\n'
            f'{len(multi_fact_numbers)} numbers have multiple lengths',
            fontsize=14)
ax.grid(True, alpha=0.3, axis='y')

# Bottom-right: Shadow exclusion visualization
ax = axes[1, 1]
N_shadow = 100
S_shadow = cramer_random_primes(N_shadow, seed=7)
S_list = sorted(S_shadow)

# Plot elements of S
ax.scatter(S_list, [1]*len(S_list), c='#3498db', s=30, zorder=3,
          label='S (pseudo-primes)')

# For element 2 if present, show shadow
if 2 in S_shadow:
    shadow = sorted(2*k for k in S_shadow if 2*k <= N_shadow)
    ax.scatter(shadow, [0.5]*len(shadow), c='#e74c3c', s=30,
              marker='^', zorder=3, label='Shadow (2·S)')
    overlap = sorted(x for x in shadow if x in S_shadow)
    if overlap:
        ax.scatter(overlap, [0.75]*len(overlap), c='#f39c12', s=80,
                  marker='*', zorder=4, label=f'Overlap ({len(overlap)} witnesses)')

ax.set_xlabel('n', fontsize=13)
ax.set_yticks([0.5, 0.75, 1.0])
ax.set_yticklabels(['Shadow', 'Overlap', 'S'])
ax.set_title(f'Shadow Exclusion (p=2, N={N_shadow})', fontsize=14)
ax.legend(fontsize=10, loc='upper right')
ax.grid(True, alpha=0.3, axis='x')
ax.set_ylim(0.3, 1.2)

plt.tight_layout()
plt.savefig('viz_density_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_density_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Product Witnesses in Random vs Real Primes

Shows how random pseudo-prime systems inevitably accumulate product
witnesses (a, b, a*b all in S) while real primes have exactly zero.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
import random

def sieve_of_eratosthenes(N):
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return {i for i in range(2, N + 1) if is_prime[i]}

def cramer_random_primes(N, seed=None):
    if seed is not None:
        random.seed(seed)
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / math.log(n):
            S.add(n)
    return S

def count_product_witnesses(S, N):
    count = 0
    S_sorted = sorted(S)
    for i, a in enumerate(S_sorted):
        if a * a > N:
            break
        for b in S_sorted[i:]:
            if a * b > N:
                break
            if a * b in S:
                count += 1
    return count

# Generate data
Ns = np.array([50, 100, 200, 500, 1000, 2000, 5000])
trials = 50

random_witnesses_mean = []
random_witnesses_std = []

for N in Ns:
    w_list = []
    for t in range(trials):
        S = cramer_random_primes(int(N), seed=1000*int(N) + t)
        w_list.append(count_product_witnesses(S, int(N)))
    random_witnesses_mean.append(np.mean(w_list))
    random_witnesses_std.append(np.std(w_list))

random_witnesses_mean = np.array(random_witnesses_mean)
random_witnesses_std = np.array(random_witnesses_std)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Product witness count vs N
ax1.errorbar(Ns, random_witnesses_mean, yerr=random_witnesses_std,
            fmt='o-', color='#e74c3c', linewidth=2, markersize=8,
            label='Cramér random primes', capsize=5)
ax1.axhline(y=0, color='#2ecc71', linewidth=3, linestyle='--',
           label='Real primes (always 0)')

# Theoretical curve: ~N/log³N
theory = Ns / np.log(Ns)**3
scale = random_witnesses_mean[-1] / theory[-1]
ax1.plot(Ns, theory * scale, 'k:', linewidth=1.5,
        label=r'$\sim N/\log^3 N$ (theoretical)')

ax1.set_xscale('log')
ax1.set_yscale('log')
ax1.set_xlabel('N', fontsize=14)
ax1.set_ylabel('Product Witnesses', fontsize=14)
ax1.set_title('Product Witnesses: Random vs Real Primes', fontsize=15)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)

# Right: Fraction of random sets that are product-free
pf_fractions = []
for N in Ns:
    pf_count = 0
    for t in range(trials):
        S = cramer_random_primes(int(N), seed=2000*int(N) + t)
        if count_product_witnesses(S, int(N)) == 0:
            pf_count += 1
    pf_fractions.append(pf_count / trials)

ax2.bar(range(len(Ns)), pf_fractions, color='#3498db', alpha=0.8,
       edgecolor='#2c3e50')
ax2.set_xticks(range(len(Ns)))
ax2.set_xticklabels([str(int(N)) for N in Ns], rotation=45)
ax2.set_xlabel('N', fontsize=14)
ax2.set_ylabel('Fraction Product-Free', fontsize=14)
ax2.set_title('Probability of Product-Freeness\n(Cramér Random Model)', fontsize=15)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3, axis='y')

# Add annotation
ax2.annotate('Product-freeness collapses\nas N → ∞',
            xy=(4, pf_fractions[4] if len(pf_fractions) > 4 else 0),
            xytext=(2, 0.6),
            arrowprops=dict(arrowstyle='->', color='red', lw=2),
            fontsize=12, color='red')

plt.tight_layout()
plt.savefig('viz_product_witnesses.png', dpi=150, bbox_inches='tight')
print("Saved viz_product_witnesses.png")
