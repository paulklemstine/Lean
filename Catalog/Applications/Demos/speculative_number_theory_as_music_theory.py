#!/usr/bin/env python3
"""
Spectral Arithmetic: Numerical Demonstrations

Computes spectral weights, consonance distances, and verifies
the main theorems with concrete examples.
"""

from fractions import Fraction
from typing import Dict, List, Tuple
import math


def prime_factorization(n: int) -> Dict[int, int]:
    """Return prime factorization as {prime: exponent}."""
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


def spectral_weight(n: int) -> Fraction:
    """Compute the spectral weight of n: Σ v_p(n)/p over prime factors p."""
    if n <= 0:
        return Fraction(0)
    factors = prime_factorization(n)
    return sum(Fraction(exp, p) for p, exp in factors.items())


def consonance_dist(m: int, n: int) -> Fraction:
    """Consonance distance between m and n."""
    lcm = (m * n) // math.gcd(m, n) if m > 0 and n > 0 else 0
    gcd = math.gcd(m, n)
    return spectral_weight(lcm) - spectral_weight(gcd)


def big_omega(n: int) -> int:
    """Number of prime factors with multiplicity."""
    return sum(prime_factorization(n).values()) if n > 1 else 0


def harmonic_rank(n: int) -> int:
    """Number of distinct prime factors."""
    return len(prime_factorization(n))


def spectral_density(p: int, N: int) -> Fraction:
    """Average of v_p(k)/p over k = 1..N."""
    if N == 0:
        return Fraction(0)
    total = sum(Fraction(prime_factorization(k).get(p, 0), p) for k in range(1, N + 1))
    return total / N


# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 1: Basic Spectral Weights
# ═══════════════════════════════════════════════════════════════
print("=" * 60)
print("SPECTRAL ARITHMETIC: NUMERICAL DEMONSTRATIONS")
print("=" * 60)

print("\n§1. Spectral Weights of Small Numbers")
print("-" * 40)
for n in range(1, 31):
    sw = spectral_weight(n)
    factors = prime_factorization(n)
    factor_str = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))
    if not factor_str:
        factor_str = "1"
    print(f"  sw({n:2d}) = {str(sw):>8s}  ({factor_str})")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 2: Complete Additivity Verification
# ═══════════════════════════════════════════════════════════════
print("\n§2. Complete Additivity: sw(m·n) = sw(m) + sw(n)")
print("-" * 40)
test_pairs = [(2, 3), (4, 6), (6, 6), (12, 15), (8, 9), (4, 4), (2, 2)]
for m, n in test_pairs:
    lhs = spectral_weight(m * n)
    rhs = spectral_weight(m) + spectral_weight(n)
    check = "✓" if lhs == rhs else "✗"
    coprime = "coprime" if math.gcd(m, n) == 1 else "NOT coprime"
    print(f"  sw({m}·{n}) = sw({m*n}) = {lhs} = {spectral_weight(m)} + {spectral_weight(n)} {check} ({coprime})")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 3: Musical Intervals Ranked by Consonance
# ═══════════════════════════════════════════════════════════════
print("\n§3. Musical Intervals Ranked by Consonance Distance")
print("-" * 40)
intervals = [
    ("Unison", 1, 1),
    ("Octave", 2, 1),
    ("Fifth", 3, 2),
    ("Fourth", 4, 3),
    ("Major third", 5, 4),
    ("Minor third", 6, 5),
    ("Major sixth", 5, 3),
    ("Minor sixth", 8, 5),
    ("Major second", 9, 8),
    ("Minor seventh", 16, 9),
    ("Tritone", 45, 32),
]
ranked = sorted(intervals, key=lambda x: consonance_dist(x[1], x[2]))
for name, m, n in ranked:
    cd = consonance_dist(m, n)
    print(f"  {name:15s} ({m}:{n}): consonance dist = {str(cd):>8s} ≈ {float(cd):.4f}")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 4: Upper Bound sw(n) ≤ Ω(n)/2
# ═══════════════════════════════════════════════════════════════
print("\n§4. Upper Bound: sw(n) ≤ Ω(n)/2")
print("-" * 40)
for n in [2, 4, 6, 8, 12, 16, 24, 30, 60, 120, 360, 1024]:
    sw = spectral_weight(n)
    omega = big_omega(n)
    bound = Fraction(omega, 2)
    tight = "TIGHT" if sw == bound else f"gap = {float(bound - sw):.4f}"
    print(f"  n={n:4d}: sw = {str(sw):>8s}, Ω/2 = {str(bound):>4s} ({tight})")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 5: Spectral Density Conjecture
# ═══════════════════════════════════════════════════════════════
print("\n§5. Spectral Density δ_p(N) → 1/(p(p-1)) as N → ∞")
print("-" * 40)
for p in [2, 3, 5, 7]:
    target = Fraction(1, p * (p - 1))
    for N in [100, 1000, 10000]:
        sd = spectral_density(p, N)
        print(f"  δ_{p}({N:5d}) = {float(sd):.6f}  (target: {float(target):.6f})")
    print()

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 6: Powers of 2 as Weight Maximizers
# ═══════════════════════════════════════════════════════════════
print("§6. Powers of 2 Maximize Weight (among same Ω)")
print("-" * 40)
for omega_target in [2, 3, 4]:
    candidates = []
    for n in range(2, 500):
        if big_omega(n) == omega_target:
            candidates.append((n, spectral_weight(n)))
    candidates.sort(key=lambda x: -x[1])
    top5 = candidates[:5]
    print(f"  Ω = {omega_target}: Top 5 by spectral weight:")
    for n, sw in top5:
        factors = prime_factorization(n)
        factor_str = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))
        print(f"    n = {n:4d} ({factor_str}): sw = {str(sw):>8s}")
    print()

print("=" * 60)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Spectral Weight Landscape

Generates a scatter plot of spectral weights for n = 1..500,
colored by harmonic rank (number of distinct prime factors).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def prime_factorization(n):
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
    if n <= 0:
        return 0.0
    factors = prime_factorization(n)
    return sum(exp / p for p, exp in factors.items())


def harmonic_rank(n):
    return len(prime_factorization(n))


def big_omega(n):
    return sum(prime_factorization(n).values()) if n > 1 else 0


# Generate data
N = 500
ns = list(range(1, N + 1))
weights = [spectral_weight(n) for n in ns]
ranks = [harmonic_rank(n) for n in ns]
omegas = [big_omega(n) for n in ns]

# ═══════════════════════════════════════════════════════
# Plot 1: Spectral Weight Landscape
# ═══════════════════════════════════════════════════════
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

ax1 = axes[0, 0]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
for rank in range(5):
    mask = [r == rank for r in ranks]
    x = [n for n, m in zip(ns, mask) if m]
    y = [w for w, m in zip(weights, mask) if m]
    label = f"ω(n) = {rank}" if rank < 4 else f"ω(n) ≥ {rank}"
    ax1.scatter(x, y, c=colors[rank], s=8, alpha=0.7, label=label)

# Highlight powers of 2
pow2 = [2**k for k in range(1, 10) if 2**k <= N]
pow2_w = [spectral_weight(n) for n in pow2]
ax1.scatter(pow2, pow2_w, c='red', s=50, marker='*', zorder=5, label='Powers of 2')

ax1.set_xlabel('n')
ax1.set_ylabel('Spectral Weight sw(n)')
ax1.set_title('Spectral Weight Landscape')
ax1.legend(fontsize=8)
ax1.grid(alpha=0.3)

# ═══════════════════════════════════════════════════════
# Plot 2: sw(n) vs Ω(n)/2 (Upper Bound)
# ═══════════════════════════════════════════════════════
ax2 = axes[0, 1]
ax2.scatter(ns, weights, c='blue', s=5, alpha=0.5, label='sw(n)')
upper_bounds = [o / 2 for o in omegas]
ax2.scatter(ns, upper_bounds, c='red', s=5, alpha=0.3, label='Ω(n)/2')
ax2.set_xlabel('n')
ax2.set_ylabel('Value')
ax2.set_title('Spectral Weight vs Upper Bound Ω(n)/2')
ax2.legend()
ax2.grid(alpha=0.3)

# ═══════════════════════════════════════════════════════
# Plot 3: Musical Intervals
# ═══════════════════════════════════════════════════════
ax3 = axes[1, 0]
intervals = [
    ("Unison", 1, 1), ("Octave", 2, 1), ("Fifth", 3, 2),
    ("Fourth", 4, 3), ("Maj 3rd", 5, 4), ("Min 3rd", 6, 5),
    ("Maj 6th", 5, 3), ("Min 6th", 8, 5), ("Maj 2nd", 9, 8),
    ("Min 7th", 16, 9), ("Tritone", 45, 32),
]
import math
cds = []
for name, m, n in intervals:
    g = math.gcd(m, n)
    l = (m * n) // g
    cd = spectral_weight(l) - spectral_weight(g)
    cds.append((name, cd))

cds.sort(key=lambda x: x[1])
names = [c[0] for c in cds]
values = [c[1] for c in cds]

bars = ax3.barh(range(len(names)), values, color=plt.cm.RdYlGn_r(
    np.linspace(0, 1, len(names))))
ax3.set_yticks(range(len(names)))
ax3.set_yticklabels(names, fontsize=9)
ax3.set_xlabel('Consonance Distance')
ax3.set_title('Musical Intervals by Consonance')
ax3.invert_yaxis()
ax3.grid(alpha=0.3, axis='x')

# ═══════════════════════════════════════════════════════
# Plot 4: Spectral Density Convergence
# ═══════════════════════════════════════════════════════
ax4 = axes[1, 1]
primes_to_plot = [2, 3, 5, 7]
Ns = list(range(10, 501, 5))
for p in primes_to_plot:
    densities = []
    target = 1 / (p * (p - 1))
    for Nval in Ns:
        total = 0
        for k in range(1, Nval + 1):
            v = 0
            m = k
            while m % p == 0:
                v += 1
                m //= p
            total += v / p
        densities.append(total / Nval)
    ax4.plot(Ns, densities, label=f'δ_{p}(N)', linewidth=1.5)
    ax4.axhline(y=target, color='gray', linestyle='--', alpha=0.5)

ax4.set_xlabel('N')
ax4.set_ylabel('Spectral Density δ_p(N)')
ax4.set_title('Spectral Density Convergence')
ax4.legend()
ax4.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_arithmetic.png', dpi=150, bbox_inches='tight')
print("Saved spectral_arithmetic.png")
