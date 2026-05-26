#!/usr/bin/env python3
"""
Visualization 3: Directional Exchange Certificate Heatmap

Visualizes which pairs (x, y) of feasible points satisfy the DLC condition
(existence of an improving exchange from x when f(y) < f(x)). Shows the
structure of the certificate as a heatmap over the exchange family.

Self-contained — all functions defined inline.
"""

import itertools
import numpy as np
import matplotlib.pyplot as plt


def make_bases(n, r):
    bases = []
    for subset in itertools.combinations(range(n), r):
        v = tuple(1 if i in subset else 0 for i in range(n))
        bases.append(v)
    return bases


def has_improving_exchange(x, bases_set, n, f):
    """Check if x has any improving exchange neighbor."""
    fx = f(x)
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            y = list(x)
            y[i] += 1
            y[j] -= 1
            y = tuple(y)
            if y in bases_set and f(y) < fx - 1e-15:
                return True
    return False


# Setup
n, r = 5, 2
bases = make_bases(n, r)
bases_set = set(bases)
num_bases = len(bases)

# Objective
weights = np.array([4.0, 2.0, 0.0, -2.0, -4.0])
f = lambda x: float(sum(weights[i] * x[i] for i in range(n)))

# Sort bases by objective value
f_vals = [f(b) for b in bases]
sorted_indices = np.argsort(f_vals)
bases_sorted = [bases[i] for i in sorted_indices]
f_vals_sorted = [f_vals[i] for i in sorted_indices]

# Build DLC matrix
# dlc_matrix[i, j] = 1 if f(bases[j]) < f(bases[i]) and x=bases[i] has improving exchange
# dlc_matrix[i, j] = -1 if f(bases[j]) < f(bases[i]) and NO improving exchange (DLC violation)
# dlc_matrix[i, j] = 0 otherwise
dlc_matrix = np.zeros((num_bases, num_bases))

for i in range(num_bases):
    for j in range(num_bases):
        if f_vals_sorted[j] < f_vals_sorted[i] - 1e-12:
            if has_improving_exchange(bases_sorted[i], bases_set, n, f):
                dlc_matrix[i, j] = 1  # DLC satisfied
            else:
                dlc_matrix[i, j] = -1  # DLC violated

# Also build exchange adjacency
adj_matrix = np.zeros((num_bases, num_bases))
for i in range(num_bases):
    for j in range(num_bases):
        if i == j:
            continue
        diff = tuple(bases_sorted[j][k] - bases_sorted[i][k] for k in range(n))
        plus = sum(1 for d in diff if d == 1)
        minus = sum(1 for d in diff if d == -1)
        if plus == 1 and minus == 1:
            adj_matrix[i, j] = 1

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: DLC certificate heatmap
cmap1 = plt.cm.RdYlGn
im1 = axes[0].imshow(dlc_matrix, cmap=cmap1, aspect='auto',
                       vmin=-1, vmax=1, interpolation='nearest')
axes[0].set_title('DLC Certificate Matrix', fontsize=13, fontweight='bold')
axes[0].set_xlabel('Target y (sorted by f)', fontsize=11)
axes[0].set_ylabel('Source x (sorted by f)', fontsize=11)
plt.colorbar(im1, ax=axes[0], label='1=satisfied, -1=violated, 0=N/A')

# Add labels
labels = []
for b in bases_sorted:
    selected = [k for k in range(n) if b[k] == 1]
    labels.append('{' + ','.join(map(str, selected)) + '}')

if num_bases <= 15:
    axes[0].set_xticks(range(num_bases))
    axes[0].set_xticklabels(labels, rotation=90, fontsize=7)
    axes[0].set_yticks(range(num_bases))
    axes[0].set_yticklabels(labels, fontsize=7)

# Plot 2: Exchange adjacency
im2 = axes[1].imshow(adj_matrix, cmap='Blues', aspect='auto', interpolation='nearest')
axes[1].set_title('Exchange Adjacency', fontsize=13, fontweight='bold')
axes[1].set_xlabel('Basis index (sorted by f)', fontsize=11)
axes[1].set_ylabel('Basis index (sorted by f)', fontsize=11)
plt.colorbar(im2, ax=axes[1], label='Connected by exchange')

# Plot 3: Objective landscape
axes[2].bar(range(num_bases), f_vals_sorted, color='steelblue', alpha=0.8)
axes[2].set_xlabel('Basis index (sorted)', fontsize=11)
axes[2].set_ylabel('f(x)', fontsize=11)
axes[2].set_title('Objective Values (sorted)', fontsize=13, fontweight='bold')

# Mark global minimum
min_idx = np.argmin(f_vals_sorted)
axes[2].bar(min_idx, f_vals_sorted[min_idx], color='gold', edgecolor='red', linewidth=2)

if num_bases <= 15:
    axes[2].set_xticks(range(num_bases))
    axes[2].set_xticklabels(labels, rotation=90, fontsize=7)

plt.suptitle(f'Directional Exchange Certificate Analysis — U({r},{n})',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_dlc_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_dlc_heatmap.png")
