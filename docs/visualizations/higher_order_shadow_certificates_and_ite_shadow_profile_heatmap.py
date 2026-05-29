#!/usr/bin/env python3
"""
Visualization: Shadow Profile Heatmap

Visualizes how the support shadow evolves across derivative orders.
For a random polynomial in 3 variables, shows |Shadow_γ(S)| for each
derivative direction γ at each order k, as a heatmap.

This illustrates the central principle: derivative supports are
combinatorially determined by support shadows.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from fractions import Fraction

# Inline all needed functions
def le_mi(a, b): return all(x <= y for x, y in zip(a, b))
def sub_mi(a, b): return tuple(x - y for x, y in zip(a, b))

def shadow_along(S, gamma):
    return frozenset(sub_mi(a, gamma) for a in S if le_mi(gamma, a))

def enumerate_multi_indices(k, n):
    if n == 0: return [()] if k == 0 else []
    if n == 1: return [(k,)]
    result = []
    for i in range(k + 1):
        for rest in enumerate_multi_indices(k - i, n - 1):
            result.append((i,) + rest)
    return result

def total_shadow_order(k, S, n_vars):
    result = set()
    for gamma in enumerate_multi_indices(k, n_vars):
        result.update(shadow_along(S, gamma))
    return frozenset(result)

def random_sparse_poly(n_vars, max_deg, n_terms, seed=42):
    random.seed(seed)
    poly = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exp = tuple(random.randint(0, max_deg) for _ in range(n_vars))
        if exp not in poly:
            c = random.randint(-10, 10)
            if c != 0: poly[exp] = c
        attempts += 1
    return frozenset(poly.keys())

# Generate data
n_vars = 3
max_deg = 6
n_terms = 15
S = random_sparse_poly(n_vars, max_deg, n_terms)

max_order = 7
shadow_sizes = []
gamma_labels_per_order = []

for k in range(max_order + 1):
    gammas = enumerate_multi_indices(k, n_vars)
    sizes = [len(shadow_along(S, g)) for g in gammas]
    shadow_sizes.append(sizes)
    gamma_labels_per_order.append([str(g) for g in gammas])

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Total shadow profile
orders = list(range(max_order + 1))
total_sizes = [len(total_shadow_order(k, S, n_vars)) for k in orders]
n_gammas = [len(enumerate_multi_indices(k, n_vars)) for k in orders]

ax1.bar(orders, total_sizes, color='steelblue', alpha=0.8, label='Total shadow size')
ax1.plot(orders, [len(S)] * len(orders), 'r--', label=f'Original support ({len(S)})')
ax1.set_xlabel('Derivative Order k', fontsize=12)
ax1.set_ylabel('|Shadow^(k)(S)|', fontsize=12)
ax1.set_title('Total Shadow Size by Derivative Order', fontsize=14)
ax1.legend(fontsize=11)
ax1.set_xticks(orders)

# Right: Heatmap of per-gamma shadow sizes for orders 1-4
max_gammas = max(len(shadow_sizes[k]) for k in range(1, min(5, max_order + 1)))
heatmap_data = np.zeros((4, max_gammas))
y_labels = []
x_labels_full = []

for idx, k in enumerate(range(1, 5)):
    sizes = shadow_sizes[k]
    labels = gamma_labels_per_order[k]
    for j, s in enumerate(sizes):
        heatmap_data[idx, j] = s
    y_labels.append(f'Order {k}')
    if len(labels) > len(x_labels_full):
        x_labels_full = labels + [''] * (max_gammas - len(labels))

im = ax1_right = ax2.imshow(heatmap_data, cmap='YlOrRd', aspect='auto',
                              interpolation='nearest')
ax2.set_xlabel('Derivative Direction γ', fontsize=12)
ax2.set_ylabel('Order', fontsize=12)
ax2.set_title('Shadow Size per Derivative Direction', fontsize=14)
ax2.set_yticks(range(4))
ax2.set_yticklabels(y_labels)

# Only label up to 15 x-ticks to avoid crowding
n_xticks = min(15, max_gammas)
ax2.set_xticks(range(n_xticks))
ax2.set_xticklabels(x_labels_full[:n_xticks], rotation=45, ha='right', fontsize=8)

plt.colorbar(im, ax=ax2, label='|Shadow_γ(S)|')

plt.suptitle(f'Higher-Order Shadow Structure (3 vars, {len(S)} terms, deg≤{max_deg})',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
