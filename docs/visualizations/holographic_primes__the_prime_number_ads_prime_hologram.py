#!/usr/bin/env python3
"""
Visualization 3: The Prime Hologram — Boundary Area vs Bulk Volume

Visualizes the Chebyshev function θ(x) = ∑_{p≤x} log(p) (boundary area)
against x (bulk volume), the von Mangoldt reconstruction formula,
and the prime reciprocal divergence (infinite boundary capacity).
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def von_mangoldt(n):
    if n <= 1:
        return 0.0
    for p in range(2, n + 1):
        if p * p > n:
            break
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return math.log(p) if m == 1 else 0.0
    return math.log(n)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("The Prime Hologram: Boundary-Bulk Correspondence",
             fontsize=16, fontweight='bold')

# Plot 1: Chebyshev θ(x) vs x
ax1 = axes[0, 0]
x_max = 10000
primes = sieve_of_eratosthenes(x_max)

# Compute θ(x) at integer points (using cumulative sum)
theta_vals = np.zeros(x_max + 1)
for p in primes:
    theta_vals[p:] += math.log(p)

x_range = np.arange(1, x_max + 1)
ax1.plot(x_range, theta_vals[1:], 'b-', linewidth=1.5,
         label='θ(x) (boundary area)')
ax1.plot(x_range, x_range, 'r--', linewidth=1.5,
         label='x (bulk volume)')
ax1.fill_between(x_range, theta_vals[1:], x_range, alpha=0.1, color='blue')
ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel('Value', fontsize=11)
ax1.set_title('θ(x) ∼ x: Boundary Area ≈ Bulk Volume (PNT)', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: θ(x)/x ratio
ax2 = axes[0, 1]
ratios = theta_vals[1:] / x_range
ax2.plot(x_range[9:], ratios[9:], 'g-', linewidth=1.5)
ax2.axhline(y=1, color='r', linestyle='--', linewidth=1, label='PNT limit')
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('θ(x) / x', fontsize=11)
ax2.set_title('Boundary/Bulk Ratio → 1', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.7, 1.1)

# Plot 3: Von Mangoldt reconstruction for first 100 integers
ax3 = axes[1, 0]
n_range = range(1, 101)
lambda_vals = [von_mangoldt(n) for n in n_range]

# Color code: primes (red), prime powers (orange), composites (gray)
colors = []
for n in n_range:
    lam = von_mangoldt(n)
    if lam == 0:
        colors.append('#cccccc')
    elif n in primes:
        colors.append('#e74c3c')
    else:
        colors.append('#f39c12')

ax3.bar(list(n_range), lambda_vals, color=colors, width=0.8)
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Λ(n)', fontsize=11)
ax3.set_title('Von Mangoldt Λ(n): boundary weights', fontsize=12)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#e74c3c', label='Prime p: Λ(p)=log(p)'),
    Patch(facecolor='#f39c12', label='Prime power pᵏ: Λ(pᵏ)=log(p)'),
    Patch(facecolor='#cccccc', label='Other: Λ(n)=0'),
]
ax3.legend(handles=legend_elements, fontsize=9, loc='upper right')
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Prime reciprocal sum divergence
ax4 = axes[1, 1]
N_values = np.logspace(1, 5, 200).astype(int)
N_values = sorted(set(N_values))
all_primes_large = sieve_of_eratosthenes(max(N_values))

recip_sums = []
loglog_vals = []
for N in N_values:
    ps = [p for p in all_primes_large if p <= N]
    recip_sums.append(sum(1.0/p for p in ps) if ps else 0)
    loglog_vals.append(math.log(math.log(N)) if N > 1 else 0)

ax4.plot(N_values, recip_sums, 'b-', linewidth=2,
         label='∑_{p≤N} 1/p (holographic entropy)')
ax4.plot(N_values, loglog_vals, 'r--', linewidth=2,
         label='log log N')
# Mertens constant
M = 0.2615  # Meissel-Mertens constant
mertens_vals = [math.log(math.log(N)) + M if N > 1 else 0 for N in N_values]
ax4.plot(N_values, mertens_vals, 'g:', linewidth=1.5,
         label='log log N + M (Mertens)')
ax4.set_xscale('log')
ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('Partial sum', fontsize=11)
ax4.set_title('∑ 1/p → ∞: Infinite Boundary Capacity', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('prime_hologram.png', dpi=150, bbox_inches='tight')
print("Saved: prime_hologram.png")
