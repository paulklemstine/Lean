"""
Visualization: Lorentzian Gap Scaling Across Code Families

Visualizes the central falsifiable conjecture: good QLDPC codes should
exhibit polynomial gap decay (moderate log-log slope), while poor-distance
codes show much steeper decay. This is the key experimental signature of
the Lorentzian certificate framework.
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

def make_balanced_product(n):
    target_k = n // 2
    sigma = max(1, n * 0.05)
    dist_gap = max(3, n // 3)
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

def make_punctured_surface(n):
    dist_gap = max(1, int(np.sqrt(n)))
    target_k = n // 2
    sigma = max(1, n * 0.15)
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


# === Computation ===

sizes = [4, 5, 6, 7, 8]
families = {
    'Hypergraph Product': make_hypergraph_product,
    'Balanced Product': make_balanced_product,
    'Repetition Code': make_repetition,
    'Punctured Surface': make_punctured_surface,
}

colors = {
    'Hypergraph Product': '#2196F3',
    'Balanced Product': '#4CAF50',
    'Repetition Code': '#F44336',
    'Punctured Surface': '#FF9800',
}

markers = {
    'Hypergraph Product': 'o',
    'Balanced Product': 's',
    'Repetition Code': 'x',
    'Punctured Surface': '^',
}

results = {}
for name, gen in families.items():
    gaps = []
    for n in sizes:
        mu = gen(n)
        weights = all_layer_weights(mu, n)
        gap = lorentzian_gap(weights)
        gaps.append(gap)
    results[name] = gaps


# === Plotting ===

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Gap vs System Size (log scale)
ax1 = axes[0]
for name, gaps in results.items():
    positive_mask = [g > 1e-15 for g in gaps]
    plot_sizes = [s for s, m in zip(sizes, positive_mask) if m]
    plot_gaps = [g for g, m in zip(gaps, positive_mask) if m]
    if plot_sizes:
        ax1.semilogy(plot_sizes, plot_gaps,
                     color=colors[name], marker=markers[name],
                     linewidth=2, markersize=8, label=name)

# Reference line: 1/n^2
ref_sizes = np.array(sizes, dtype=float)
ax1.semilogy(ref_sizes, 1.0 / ref_sizes**2, 'k--', alpha=0.5,
             linewidth=1, label=r'$1/n^2$ reference')

ax1.set_xlabel('System size n', fontsize=12)
ax1.set_ylabel('Lorentzian gap', fontsize=12)
ax1.set_title('Gap Surrogate vs System Size', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Log-log plot
ax2 = axes[1]
for name, gaps in results.items():
    positive_mask = [g > 1e-15 for g in gaps]
    plot_sizes = [s for s, m in zip(sizes, positive_mask) if m]
    plot_gaps = [g for g, m in zip(gaps, positive_mask) if m]
    if len(plot_sizes) >= 2:
        log_n = np.log(np.array(plot_sizes, dtype=float))
        log_gap = np.log(np.array(plot_gaps))
        ax2.plot(log_n, log_gap,
                 color=colors[name], marker=markers[name],
                 linewidth=2, markersize=8, label=name)

        # Fit and annotate slope
        slope = np.polyfit(log_n, log_gap, 1)[0]
        ax2.annotate(f'slope={slope:.1f}',
                     xy=(log_n[-1], log_gap[-1]),
                     xytext=(10, 0), textcoords='offset points',
                     fontsize=9, color=colors[name])

ax2.set_xlabel('log(n)', fontsize=12)
ax2.set_ylabel('log(gap)', fontsize=12)
ax2.set_title('Log-Log Scaling Analysis', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.suptitle('Lorentzian Gap Surrogate: Scaling Across Code Families',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gap_scaling.png', dpi=150, bbox_inches='tight')
print("Saved gap_scaling.png")
