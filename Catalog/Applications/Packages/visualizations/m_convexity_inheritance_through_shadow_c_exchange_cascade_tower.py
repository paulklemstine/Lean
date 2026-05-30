#!/usr/bin/env python3
"""
Visualization 1: Exchange Cascade Tower

Shows how the weighted derivative transforms a sequence at each level,
maintaining the exchange property (visualized as log-concavity of the
coefficient curve). Each level is plotted with its Newton polygon slopes.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Compute exchange cascade
def weighted_derivative(a):
    return [(k + 1) * a[k + 1] for k in range(len(a) - 1)]

n = 12
a_base = [float(comb(n, k)) for k in range(n + 1)]

cascade = [a_base]
for _ in range(5):
    if len(cascade[-1]) >= 2:
        cascade.append(weighted_derivative(cascade[-1]))

fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Exchange Cascade Tower: Weighted Derivative Inheritance',
             fontsize=14, fontweight='bold')

colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))

for idx, (ax, seq) in enumerate(zip(axes.flat, cascade)):
    x = np.arange(len(seq))
    
    # Plot sequence values
    ax.bar(x, seq, color=colors[idx], alpha=0.7, edgecolor='black', linewidth=0.5)
    
    # Mark the peak
    peak = np.argmax(seq)
    ax.bar(peak, seq[peak], color='red', alpha=0.9, edgecolor='black', linewidth=1)
    
    ax.set_title(f'Level {idx}: D$^{idx}$a  (peak at k={peak})', fontsize=11)
    ax.set_xlabel('Index k')
    ax.set_ylabel('Value')
    
    # Annotate with log-concavity status
    is_lc = True
    for k in range(1, len(seq) - 1):
        if seq[k]**2 < seq[k-1] * seq[k+1] - 1e-10:
            is_lc = False
            break
    
    status = '✓ Log-concave' if is_lc else '✗ Not log-concave'
    ax.text(0.95, 0.95, status, transform=ax.transAxes,
            ha='right', va='top', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightgreen' if is_lc else 'lightyellow'))

plt.tight_layout()
plt.savefig('viz_cascade_tower.png', dpi=150, bbox_inches='tight')
print("Saved: viz_cascade_tower.png")
