#!/usr/bin/env python3
"""
Visualization: Information Loss in the Global Projection

Shows how the map from primewise birth spectrum to global birth set
loses information. Plots the spectral entropy of various profiles
versus their global entropy, illustrating that many different primewise
spectra can collapse to the same global signature.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log2
from itertools import combinations


# ---------- Inline functions ----------

def prime_factors(n):
    if n <= 1:
        return set()
    factors = set()
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return factors


def global_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}


def p_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}


def spectral_entropy(orders_at, primes):
    counts = {}
    total = 0
    for p in primes:
        c = len(p_birth_set(p, orders_at))
        if c > 0:
            counts[p] = c
            total += c
    if total == 0:
        return 0.0
    entropy = 0.0
    for c in counts.values():
        prob = c / total
        entropy -= prob * log2(prob)
    return entropy


def global_entropy(orders_at):
    g = global_birth_set(orders_at)
    n = len(g)
    if n <= 1:
        return 0.0
    return log2(n)


# ---------- Generate profiles ----------

primes = [2, 3, 5]
divisors = [2, 3, 5, 6, 10, 15, 30]
levels = [0, 1, 2, 3]

profiles = []
labels = []

# Generate profiles with 1-2 nonempty levels, single orders
for l1 in levels:
    for d1 in divisors:
        orders = {l: set() for l in levels}
        orders[l1] = {d1}
        profiles.append(orders)
        labels.append(f"L{l1}:{d1}")

        for l2 in levels:
            if l2 <= l1:
                continue
            for d2 in divisors:
                orders2 = {l: set() for l in levels}
                orders2[l1] = {d1}
                orders2[l2] = {d2}
                profiles.append(orders2)
                labels.append(f"L{l1}:{d1},L{l2}:{d2}")

# Compute entropies
global_ents = [global_entropy(p) for p in profiles]
spectral_ents = [spectral_entropy(p, primes) for p in profiles]
global_sets = [frozenset(global_birth_set(p)) for p in profiles]

# Color by global birth set
unique_globals = sorted(set(global_sets), key=lambda x: (len(x), sorted(x)))
color_map = {}
colors_list = plt.cm.Set2(np.linspace(0, 1, max(len(unique_globals), 1)))
for i, gs in enumerate(unique_globals):
    color_map[gs] = colors_list[i % len(colors_list)]

point_colors = [color_map[gs] for gs in global_sets]

# ---------- Plot ----------

fig, ax = plt.subplots(figsize=(10, 7))

scatter = ax.scatter(global_ents, spectral_ents, c=point_colors,
                     s=40, alpha=0.7, edgecolors='gray', linewidth=0.3)

# Identity line
max_val = max(max(global_ents, default=0), max(spectral_ents, default=0)) + 0.2
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='H_spectral = H_global')

# Highlight the witness pair
F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}
for name, orders, marker in [("F ({2}@1, {6}@3)", F_orders, 's'),
                               ("G ({3}@1, {6}@3)", G_orders, 'D')]:
    ge = global_entropy(orders)
    se = spectral_entropy(orders, primes)
    ax.scatter([ge], [se], marker=marker, s=200, edgecolors='red',
               facecolors='yellow', linewidth=2.5, zorder=5)
    ax.annotate(name, (ge, se), textcoords='offset points',
                xytext=(10, 10), fontsize=9, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red'))

ax.set_xlabel('Global Entropy  H(global birth set)', fontsize=12)
ax.set_ylabel('Spectral Entropy  H(primewise spectrum)', fontsize=12)
ax.set_title('Information Content: Global vs Primewise\n'
             'Points above the diagonal carry information lost by the global projection',
             fontsize=13, fontweight='bold')

# Add legend for global birth set classes
legend_elements = []
for gs in unique_globals[:8]:
    import matplotlib.patches as mpatches
    patch = mpatches.Patch(color=color_map[gs],
                           label=f'global = {{{", ".join(map(str, sorted(gs)))}}}')
    legend_elements.append(patch)
ax.legend(handles=legend_elements, loc='upper left', fontsize=8, title='Global birth set')

ax.set_xlim(-0.1, max_val)
ax.set_ylim(-0.1, max_val)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('information_loss_plot.png', dpi=150, bbox_inches='tight')
print("Saved: information_loss_plot.png")
