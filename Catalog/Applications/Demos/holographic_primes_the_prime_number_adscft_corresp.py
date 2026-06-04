#!/usr/bin/env python3
"""
Holographic Spectral Algebra — Numerical Demonstrations

Demonstrates the key theorems of the Prime Spectral Algebra framework:
1. Holographic Reconstruction: S(n) = log(n)
2. Spectral Weight Additivity: Ω(a·b) = Ω(a) + Ω(b)
3. Holographic Defect & Squarefreeness
4. Spectral Interaction Energy
5. Depth Filtration Structure
"""

import math
from collections import Counter
from typing import Dict, List, Tuple


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    if n <= 1:
        return {}
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


def spectral_weight(n: int) -> int:
    """Ω(n) = total number of prime factors with multiplicity."""
    return sum(factorize(n).values())


def distinct_count(n: int) -> int:
    """ω(n) = number of distinct prime factors."""
    return len(factorize(n))


def holographic_defect(n: int) -> int:
    """δ(n) = Ω(n) - ω(n), measures departure from squarefreeness."""
    return spectral_weight(n) - distinct_count(n)


def spectral_entropy(n: int) -> float:
    """S(n) = Σ_p v_p(n) · log(p), the 'boundary observable'."""
    return sum(k * math.log(p) for p, k in factorize(n).items())


def spectral_interaction(n: int) -> int:
    """I(n) = Ω(n)² - Σ_p v_p(n)², cross-prime interaction energy."""
    f = factorize(n)
    omega = sum(f.values())
    return omega ** 2 - sum(k ** 2 for k in f.values())


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree."""
    return all(v <= 1 for v in factorize(n).values())


# ============================================================
# Demo 1: Holographic Reconstruction Theorem
# S(n) = log(n) for all n ≥ 1
# ============================================================
print("=" * 70)
print("DEMO 1: Holographic Reconstruction Theorem")
print("  S(n) = Σ_p v_p(n)·log(p) = log(n)")
print("=" * 70)

test_values = [1, 2, 3, 6, 12, 30, 60, 100, 360, 1000, 2520, 10080]
for n in test_values:
    S = spectral_entropy(n)
    log_n = math.log(n) if n > 0 else 0.0
    error = abs(S - log_n)
    f = factorize(n)
    spectrum_str = " · ".join(f"{p}^{k}" for p, k in sorted(f.items())) if f else "1"
    print(f"  n = {n:>6} = {spectrum_str:>20}  |  S(n) = {S:.10f}  log(n) = {log_n:.10f}  error = {error:.1e}")

# ============================================================
# Demo 2: Spectral Weight Additivity
# Ω(a·b) = Ω(a) + Ω(b)
# ============================================================
print("\n" + "=" * 70)
print("DEMO 2: Spectral Weight Additivity")
print("  Ω(a·b) = Ω(a) + Ω(b)")
print("=" * 70)

pairs = [(6, 10), (12, 15), (8, 27), (30, 42), (100, 7), (2, 2)]
for a, b in pairs:
    w_ab = spectral_weight(a * b)
    w_a = spectral_weight(a)
    w_b = spectral_weight(b)
    print(f"  Ω({a}·{b}) = Ω({a*b}) = {w_ab}  =  Ω({a}) + Ω({b}) = {w_a} + {w_b} = {w_a + w_b}  ✓" if w_ab == w_a + w_b else f"  FAIL!")

# ============================================================
# Demo 3: Holographic Defect & Squarefreeness
# δ(n) = 0 ⟺ n is squarefree
# ============================================================
print("\n" + "=" * 70)
print("DEMO 3: Holographic Defect Characterizes Squarefreeness")
print("  δ(n) = Ω(n) - ω(n) = 0  ⟺  n is squarefree")
print("=" * 70)

for n in range(2, 31):
    d = holographic_defect(n)
    sqf = is_squarefree(n)
    marker = "✓ squarefree" if sqf else f"✗ not squarefree (δ={d})"
    print(f"  n = {n:>3}  Ω={spectral_weight(n)}  ω={distinct_count(n)}  δ={d}  {marker}")

# ============================================================
# Demo 4: Spectral Interaction Energy
# I(n) = 0 for prime powers, > 0 for multi-prime composites
# ============================================================
print("\n" + "=" * 70)
print("DEMO 4: Spectral Interaction Energy")
print("  I(n) = Ω(n)² - Σ v_p(n)²  (0 for prime powers)")
print("=" * 70)

examples = [2, 4, 8, 16, 6, 12, 30, 60, 210, 2310]
for n in examples:
    I = spectral_interaction(n)
    f = factorize(n)
    label = "prime power" if len(f) <= 1 else f"{len(f)} primes"
    print(f"  n = {n:>5}  I(n) = {I:>3}  ({label})")

# ============================================================
# Demo 5: Spectral Weight Bound
# Ω(n) ≤ log₂(n) for n ≥ 1
# ============================================================
print("\n" + "=" * 70)
print("DEMO 5: Spectral Weight Bound")
print("  Ω(n) ≤ ⌊log₂(n)⌋")
print("=" * 70)

# Find the tightest cases (powers of 2 saturate the bound)
for k in range(1, 20):
    n = 2 ** k
    w = spectral_weight(n)
    log2n = int(math.log2(n))
    ratio = w / log2n if log2n > 0 else 0
    print(f"  n = 2^{k:>2} = {n:>7}  Ω(n) = {w:>2}  log₂(n) = {log2n:>2}  ratio = {ratio:.3f}")

# ============================================================
# Demo 6: Depth Filtration Structure
# ============================================================
print("\n" + "=" * 70)
print("DEMO 6: Depth Filtration at p=2")
print("  F_k(2) = {n : v_2(n) ≥ k}")
print("=" * 70)

N = 100
for k in range(5):
    members = [n for n in range(1, N + 1) if factorize(n).get(2, 0) >= k]
    print(f"  F_{k}(2) ∩ [1,{N}]: {len(members)} elements, first 10: {members[:10]}...")

# ============================================================
# Demo 7: Chebyshev θ as Spectral Entropy of Primorial
# ============================================================
print("\n" + "=" * 70)
print("DEMO 7: Chebyshev θ(n) = S(primorial(n))")
print("=" * 70)

def primes_up_to(n):
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]

for n in [10, 20, 50, 100, 200, 500]:
    primes = primes_up_to(n)
    theta = sum(math.log(p) for p in primes)
    primorial = 1
    for p in primes:
        primorial *= p
    S_primorial = spectral_entropy(primorial) if primorial > 0 else 0
    print(f"  n = {n:>3}  θ(n) = {theta:.6f}  S(∏p≤n p) = {S_primorial:.6f}  match: {abs(theta - S_primorial) < 1e-10}")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Spectral Interaction Energy and Depth Filtration

Shows cross-prime correlation structure and the nested filtration layers.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def factorize(n):
    if n <= 1:
        return {}
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


def spectral_interaction(n):
    f = factorize(n)
    omega = sum(f.values())
    return omega ** 2 - sum(k ** 2 for k in f.values())


def spectral_weight(n):
    return sum(factorize(n).values())


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Interaction energy scatter
ax1 = axes[0, 0]
N = 500
ns = list(range(2, N + 1))
interactions = [spectral_interaction(n) for n in ns]
weights = [spectral_weight(n) for n in ns]
num_factors = [len(factorize(n)) for n in ns]

scatter = ax1.scatter(ns, interactions, c=num_factors, cmap='viridis',
                      s=8, alpha=0.7, vmin=1, vmax=5)
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('I(n)', fontsize=11)
ax1.set_title('Spectral Interaction Energy I(n)', fontsize=12)
plt.colorbar(scatter, ax=ax1, label='ω(n) = distinct primes')

# Plot 2: I(n) vs Ω(n) with prime-power zeros highlighted
ax2 = axes[0, 1]
prime_powers = [n for n in ns if len(factorize(n)) <= 1]
multi_prime = [n for n in ns if len(factorize(n)) > 1]

ax2.scatter([spectral_weight(n) for n in multi_prime],
            [spectral_interaction(n) for n in multi_prime],
            s=10, alpha=0.5, c='steelblue', label='Multi-prime')
ax2.scatter([spectral_weight(n) for n in prime_powers],
            [spectral_interaction(n) for n in prime_powers],
            s=20, alpha=0.8, c='red', marker='x', label='Prime powers (I=0)')
ax2.set_xlabel('Ω(n)', fontsize=11)
ax2.set_ylabel('I(n)', fontsize=11)
ax2.set_title('I(n) vs Ω(n): Prime Powers Have Zero Interaction', fontsize=12)
ax2.legend(fontsize=9)

# Plot 3: Depth filtration nesting at p=2
ax3 = axes[1, 0]
M = 100
for k in range(5):
    layer = [n for n in range(1, M + 1) if factorize(n).get(2, 0) >= k]
    y_vals = [k] * len(layer)
    ax3.scatter(layer, y_vals, s=15, alpha=0.6, label=f'F_{k}(2)')

ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Depth k', fontsize=11)
ax3.set_title('Depth Filtration F_k(2): nested layers at p=2', fontsize=12)
ax3.set_yticks(range(5))
ax3.legend(fontsize=9, ncol=2)

# Plot 4: Holographic defect distribution
ax4 = axes[1, 1]
defects = [spectral_weight(n) - len(factorize(n)) for n in range(2, 1001)]
max_d = max(defects)
bins = range(max_d + 2)
ax4.hist(defects, bins=bins, color='teal', alpha=0.7, edgecolor='black', align='left')
sqfree_count = sum(1 for d in defects if d == 0)
total = len(defects)
ax4.axvline(x=0, color='red', linestyle='--', linewidth=2,
            label=f'δ=0 (squarefree): {sqfree_count}/{total} = {sqfree_count/total:.1%}')
ax4.set_xlabel('Holographic Defect δ(n)', fontsize=11)
ax4.set_ylabel('Count', fontsize=11)
ax4.set_title('Distribution of δ(n) for n ∈ [2, 1000]', fontsize=12)
ax4.legend(fontsize=9)

plt.tight_layout()
plt.savefig('spectral_interaction.png', dpi=150, bbox_inches='tight')
print("Saved spectral_interaction.png")


#!/usr/bin/env python3
"""
Visualization: Holographic Reconstruction Theorem

Demonstrates that S(n) = Σ_p v_p(n)·log(p) = log(n) exactly,
by showing the spectral decomposition of log(n) into prime components.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def factorize(n):
    if n <= 1:
        return {}
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


# Select interesting numbers
numbers = [2, 3, 4, 5, 6, 8, 10, 12, 15, 16, 20, 24, 30, 36, 48, 60, 72, 90, 120, 180, 360]

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Plot 1: Stacked bar chart showing spectral decomposition of log(n)
ax1 = axes[0]
prime_colors = {2: '#e41a1c', 3: '#377eb8', 5: '#4daf4a', 7: '#984ea3',
                11: '#ff7f00', 13: '#a65628', 17: '#f781bf', 19: '#999999',
                23: '#66c2a5', 29: '#fc8d62', 31: '#8da0cb'}

all_primes = sorted(set(p for n in numbers for p in factorize(n)))

bottoms = [0.0] * len(numbers)
for p in all_primes:
    contributions = []
    for n in numbers:
        f = factorize(n)
        contributions.append(f.get(p, 0) * math.log(p))
    color = prime_colors.get(p, '#333333')
    ax1.bar(range(len(numbers)), contributions, bottom=bottoms, color=color,
            label=f'p={p}', alpha=0.85, width=0.7)
    bottoms = [b + c for b, c in zip(bottoms, contributions)]

# Overlay log(n) as dots
log_vals = [math.log(n) for n in numbers]
ax1.scatter(range(len(numbers)), log_vals, color='black', zorder=5, s=20, label='log(n)')

ax1.set_xticks(range(len(numbers)))
ax1.set_xticklabels([str(n) for n in numbers], rotation=45)
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Holographic Reconstruction: log(n) = Σ v_p(n)·log(p)', fontsize=13)
ax1.legend(fontsize=8, ncol=3)

# Plot 2: Chebyshev θ(n) vs n and n/log(n)
ax2 = axes[1]

def primes_up_to(n):
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]

N = 500
ns = list(range(2, N + 1))
thetas = []
cumulative = 0.0
prime_set = set(primes_up_to(N))
for n in ns:
    if n in prime_set:
        cumulative += math.log(n)
    thetas.append(cumulative)

ax2.plot(ns, thetas, 'b-', linewidth=2, label='θ(n) = Σ_{p≤n} log(p)')
ax2.plot(ns, ns, 'r--', linewidth=1.5, alpha=0.7, label='y = n (PNT prediction)')
ax2.fill_between(ns, thetas, [n for n in ns], alpha=0.1, color='red')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('Value', fontsize=12)
ax2.set_title('Chebyshev θ(n) ≈ n  (Prime Number Theorem)', fontsize=13)
ax2.legend(fontsize=11)

plt.tight_layout()
plt.savefig('holographic_reconstruction.png', dpi=150, bbox_inches='tight')
print("Saved holographic_reconstruction.png")


#!/usr/bin/env python3
"""
Visualization: Holographic Spectrum of Natural Numbers

Generates a heatmap showing the prime factorization "spectrum" of
natural numbers, with spectral weight and defect overlays.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def factorize(n):
    if n <= 1:
        return {}
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


def spectral_weight(n):
    return sum(factorize(n).values())


def holographic_defect(n):
    f = factorize(n)
    return sum(f.values()) - len(f)


def spectral_entropy(n):
    return sum(k * math.log(p) for p, k in factorize(n).items())


# Parameters
N = 200
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

# Build spectrum matrix
spectrum = np.zeros((len(primes), N))
for j in range(1, N + 1):
    f = factorize(j)
    for i, p in enumerate(primes):
        spectrum[i, j - 1] = f.get(p, 0)

fig, axes = plt.subplots(3, 1, figsize=(16, 12), gridspec_kw={'height_ratios': [3, 1, 1]})

# Plot 1: Spectrum heatmap
ax1 = axes[0]
im = ax1.imshow(spectrum, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                extent=[0.5, N + 0.5, len(primes) - 0.5, -0.5])
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels([str(p) for p in primes])
ax1.set_ylabel('Prime p', fontsize=12)
ax1.set_xlabel('Natural number n', fontsize=12)
ax1.set_title('Holographic Prime Spectrum: v_p(n) for n = 1,...,200', fontsize=14)
plt.colorbar(im, ax=ax1, label='Valuation v_p(n)')

# Plot 2: Spectral weight Ω(n) vs log₂(n)
ax2 = axes[1]
ns = list(range(1, N + 1))
weights = [spectral_weight(n) for n in ns]
log2s = [math.log2(n) if n > 0 else 0 for n in ns]
ax2.scatter(ns, weights, s=3, c='steelblue', alpha=0.7, label='Ω(n)')
ax2.plot(ns, log2s, 'r-', linewidth=1.5, alpha=0.8, label='log₂(n)')
ax2.set_ylabel('Weight', fontsize=12)
ax2.set_xlabel('n', fontsize=12)
ax2.set_title('Spectral Weight Ω(n) ≤ log₂(n) (Holographic Bound)', fontsize=12)
ax2.legend(fontsize=10)

# Plot 3: Holographic defect
ax3 = axes[2]
defects = [holographic_defect(n) for n in ns]
colors = ['green' if d == 0 else 'red' for d in defects]
ax3.bar(ns, defects, color=colors, width=1.0, alpha=0.7)
ax3.set_ylabel('δ(n)', fontsize=12)
ax3.set_xlabel('n', fontsize=12)
ax3.set_title('Holographic Defect δ(n) = Ω(n) - ω(n)  (green = squarefree)', fontsize=12)

plt.tight_layout()
plt.savefig('holographic_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved holographic_spectrum.png")
