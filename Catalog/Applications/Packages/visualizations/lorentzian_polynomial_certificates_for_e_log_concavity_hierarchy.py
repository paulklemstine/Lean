#!/usr/bin/env python3
"""
Visualization 3: Log-Concavity Hierarchy

Visualizes the k-fold log-concavity hierarchy, showing how successive
ratio sequences become "more concave" at each level, and how this
hierarchy connects to the Lorentzian polynomial structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Compute ratio sequences iteratively
def ratio_seq(seq):
    return [seq[i + 1] / seq[i] for i in range(len(seq) - 1) if abs(seq[i]) > 1e-15]

def is_log_concave(seq):
    for i in range(len(seq) - 2):
        if seq[i + 1]**2 < seq[i] * seq[i + 2] - 1e-10:
            return False
    return True

# Panel 1: Binomial coefficients and their ratio sequences
ax = axes[0, 0]
d = 10
seq = [float(comb(d, k)) for k in range(d + 1)]
seqs = [seq]
names = [f'C({d},k)']
for level in range(3):
    seq = ratio_seq(seq)
    if len(seq) < 2:
        break
    seqs.append(seq)
    names.append(f'Ratio level {level + 1}')

colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63']
for i, (s, name) in enumerate(zip(seqs, names)):
    x = np.arange(len(s))
    ax.plot(x, s, 'o-', color=colors[i], linewidth=2, markersize=6, label=name)

ax.set_xlabel('Index k', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title(f'Log-Concavity Hierarchy: C({d}, k)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Ratio monotonicity visualization
ax = axes[0, 1]
d = 8
seq = [float(comb(d, k)) for k in range(d + 1)]
ratios = ratio_seq(seq)

x = np.arange(len(ratios))
colors_bar = ['#4CAF50' if i == 0 or ratios[i] <= ratios[i-1] + 1e-10 else '#F44336'
              for i in range(len(ratios))]
bars = ax.bar(x, ratios, color=colors_bar, alpha=0.8, edgecolor='black', linewidth=0.5)
ax.plot(x, ratios, 'ko-', markersize=5, linewidth=1.5)

ax.set_xlabel('Index k', fontsize=12)
ax.set_ylabel('Ratio a(k+1)/a(k)', fontsize=12)
ax.set_title(f'Ratio Monotonicity: C({d}, k)\n(Green = nonincreasing ✓)', fontsize=13, fontweight='bold')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='ratio = 1 (peak)')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Comparison of log-concave vs non-log-concave
ax = axes[1, 0]
test_seqs = {
    'C(8,k) — log-concave': [float(comb(8, k)) for k in range(9)],
    'Fibonacci — log-concave': [1, 1, 2, 3, 5, 8, 13, 21, 34],
    '[1,3,2,7,1] — NOT l.c.': [1, 3, 2, 7, 1, 8, 2, 5, 3],
}

for name, seq in test_seqs.items():
    lc = is_log_concave(seq)
    marker = 'o' if lc else 'x'
    ls = '-' if lc else '--'
    ax.plot(range(len(seq)), seq, f'{marker}{ls}', linewidth=2, markersize=7,
            label=f'{name} {"✓" if lc else "✗"}')

ax.set_xlabel('Index k', fontsize=12)
ax.set_ylabel('a(k)', fontsize=12)
ax.set_title('Log-Concavity Test', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Exchange inequality heatmap for binomial coefficients
ax = axes[1, 1]
d = 8
seq = [float(comb(d, k)) for k in range(d + 1)]
n = len(seq)
matrix = np.full((n - 1, n - 1), np.nan)
for i in range(n - 1):
    for j in range(i, n - 1):
        val = seq[i] * seq[j + 1] - seq[i + 1] * seq[j]
        matrix[i, j] = val

vmax = np.nanmax(np.abs(matrix))
if vmax == 0:
    vmax = 1
im = ax.imshow(matrix, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
               origin='upper', aspect='equal')
plt.colorbar(im, ax=ax, shrink=0.8, label='a[i]·a[j+1] − a[i+1]·a[j]')

# All should be ≤ 0 for log-concave
all_nonpos = all(seq[i] * seq[j + 1] <= seq[i + 1] * seq[j] + 1e-10
                 for i in range(n - 1) for j in range(i, n - 1))
ax.set_xlabel('j', fontsize=12)
ax.set_ylabel('i', fontsize=12)
ax.set_title(f'Exchange Certificate: C({d},k)\n{"✓ All ≤ 0" if all_nonpos else "✗ Violations"}',
             fontsize=13, fontweight='bold')

plt.suptitle('The Log-Concavity → Exchange Certificate Pipeline',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('logconcavity_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved logconcavity_hierarchy.png")
