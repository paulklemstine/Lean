"""
Visualization: Noise Degradation of Lorentzian Gap Certificate

Shows how the Lorentzian gap degrades as noise is added to a measurement
distribution. This demonstrates the certificate's sensitivity: a robust
code maintains a positive gap under moderate noise, but the gap collapses
when noise destroys the distance structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


# === Inline all needed functions ===

def layer_weight(mu, n, k):
    return sum(v for s, v in mu.items() if len(s) == k)

def all_layer_weights(mu, n):
    return [layer_weight(mu, n, k) for k in range(n + 1)]

def lorentzian_gap(weights):
    n = len(weights) - 1
    min_gap = float('inf')
    for k in range(1, n):
        denom = weights[k - 1] * weights[k + 1]
        if denom > 1e-15:
            gap_k = weights[k] ** 2 / denom - 1
            min_gap = min(min_gap, gap_k)
    return min_gap if min_gap != float('inf') else 0.0

def make_hypergraph_product(n):
    target_k = int(n * 0.5)
    sigma = max(1, n * 0.1)
    dist_gap = max(2, n // 4)
    mu = {}
    total = 0.0
    for k in range(n + 1):
        if 0 < k < dist_gap:
            continue
        w = np.exp(-0.5 * ((k - target_k) / sigma) ** 2) * comb(n, k)
        if w > 1e-15:
            for s in combinations(range(n), k):
                mu[frozenset(s)] = w / comb(n, k)
            total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def make_repetition(n):
    mu = {}
    total = 0.0
    for k in range(min(3, n + 1)):
        w = (n + 1 - k) * comb(n, k)
        for s in combinations(range(n), k):
            mu[frozenset(s)] = w / comb(n, k)
        total += w
    if total > 0:
        for s in mu:
            mu[s] /= total
    return mu

def add_noise(mu, n, noise_level):
    uniform_weight = 1.0 / (2 ** n)
    noisy = {}
    for k in range(n + 1):
        for s in combinations(range(n), k):
            fs = frozenset(s)
            original = mu.get(fs, 0.0)
            noisy[fs] = (1 - noise_level) * original + noise_level * uniform_weight
    return noisy


# === Computation ===

n = 7
noise_levels = np.linspace(0, 0.5, 25)

families = {
    'Hypergraph Product (good)': make_hypergraph_product(n),
    'Repetition Code (poor)': make_repetition(n),
}

colors = {'Hypergraph Product (good)': '#2196F3', 'Repetition Code (poor)': '#F44336'}

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Gap vs noise
ax1 = axes[0]
for name, mu in families.items():
    gaps = []
    for noise in noise_levels:
        noisy_mu = add_noise(mu, n, noise)
        weights = all_layer_weights(noisy_mu, n)
        gap = lorentzian_gap(weights)
        gaps.append(gap)
    ax1.plot(noise_levels, gaps, color=colors[name], linewidth=2.5, label=name)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
ax1.set_xlabel('Noise level ε', fontsize=12)
ax1.set_ylabel('Lorentzian gap', fontsize=12)
ax1.set_title('Gap Degradation Under Noise', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Certified distance vs noise
ax2 = axes[1]
for name, mu in families.items():
    dists = []
    for noise in noise_levels:
        noisy_mu = add_noise(mu, n, noise)
        weights = all_layer_weights(noisy_mu, n)
        cert_dist = 0
        for k in range(1, n + 1):
            if weights[k] > 1e-10:
                cert_dist = k
                break
        dists.append(cert_dist)
    ax2.plot(noise_levels, dists, color=colors[name], linewidth=2.5, label=name)

ax2.set_xlabel('Noise level ε', fontsize=12)
ax2.set_ylabel('Certified distance', fontsize=12)
ax2.set_title('Distance Certificate Under Noise', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=0)

plt.suptitle(f'Noise Sensitivity of Lorentzian Certificates (n={n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('noise_degradation.png', dpi=150, bbox_inches='tight')
print("Saved noise_degradation.png")
