#!/usr/bin/env python3
"""
Visualization: Information-Theoretic Bridge — Entropy of Prime Distributions

Shows how Shannon entropy of the prime distribution in the fractal metric
approaches the maximum entropy (log n), connecting information theory to the
Prime Number Theorem.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def prime_fractal_embed(n):
    if n >= 2:
        return 1.0 / math.log(n)
    return 0.0


def shannon_entropy(weights):
    return -sum(w * math.log(w) if w > 0 else 0 for w in weights)


def prime_distribution_entropy(N, num_bins):
    primes = sieve_of_eratosthenes(N)
    if not primes:
        return 0.0, []
    max_val = prime_fractal_embed(2)
    bin_width = max_val / num_bins
    counts = [0] * num_bins
    for p in primes:
        val = prime_fractal_embed(p)
        idx = min(int(val / bin_width), num_bins - 1)
        counts[idx] += 1
    total = sum(counts)
    if total == 0:
        return 0.0, counts
    weights = [c / total if c > 0 else 0 for c in counts]
    return shannon_entropy([w for w in weights if w > 0]), counts


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# ─── Panel 1: Entropy vs N ───
ax1 = axes[0]
num_bins = 20
Ns = list(range(50, 10001, 50))
entropies = []
for N in Ns:
    H, _ = prime_distribution_entropy(N, num_bins)
    entropies.append(H)

H_max = math.log(num_bins)
ax1.plot(Ns, entropies, 'b-', linewidth=1.5, label='H(primes)', alpha=0.8)
ax1.axhline(y=H_max, color='r', linestyle='--', alpha=0.5, label=f'H_max = log({num_bins}) = {H_max:.3f}')
ax1.fill_between(Ns, entropies, H_max, alpha=0.1, color='red')

ax1.set_xlabel('N (primes up to N)', fontsize=11)
ax1.set_ylabel('Shannon Entropy H', fontsize=11)
ax1.set_title('Entropy of Prime Distribution\n(Information-Theoretic Bridge)', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: Histogram of primes in fractal bins ───
ax2 = axes[1]
N = 10000
_, counts = prime_distribution_entropy(N, num_bins)
bin_edges = np.linspace(0, prime_fractal_embed(2), num_bins + 1)
bin_centers = [(bin_edges[i] + bin_edges[i+1])/2 for i in range(num_bins)]
bar_width = bin_edges[1] - bin_edges[0]

colors = plt.cm.viridis(np.linspace(0.2, 0.8, num_bins))
ax2.bar(bin_centers, counts, width=bar_width * 0.9, color=colors, edgecolor='white', linewidth=0.5)
ax2.set_xlabel('φ(p) = 1/log(p)', fontsize=11)
ax2.set_ylabel('Number of primes', fontsize=11)
ax2.set_title(f'Prime Distribution in Fractal Metric\n(N = {N}, {num_bins} bins)', fontsize=12, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')

# ─── Panel 3: Entropy ratio convergence ───
ax3 = axes[2]
bin_counts = [5, 10, 20, 50, 100]
for nb in bin_counts:
    Ns_small = list(range(100, 5001, 100))
    ratios = []
    for N in Ns_small:
        H, _ = prime_distribution_entropy(N, nb)
        H_max_b = math.log(nb)
        ratios.append(H / H_max_b if H_max_b > 0 else 0)
    ax3.plot(Ns_small, ratios, linewidth=1.2, alpha=0.8, label=f'{nb} bins')

ax3.axhline(y=1.0, color='k', linestyle='--', alpha=0.3)
ax3.set_xlabel('N', fontsize=11)
ax3.set_ylabel('H / H_max (entropy ratio)', fontsize=11)
ax3.set_title('Entropy Convergence to Maximum\n(PNT ↔ Uniform Distribution)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=8, title='Bins')
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0.5, 1.05)

plt.tight_layout()
plt.savefig('entropy_bridge_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: entropy_bridge_visualization.png")
