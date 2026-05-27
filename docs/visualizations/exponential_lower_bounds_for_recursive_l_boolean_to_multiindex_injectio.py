#!/usr/bin/env python3
"""
Visualization: Boolean-to-Multiindex Injection

Visualizes the injection from {0,1}^m into multiindices of weight m in (m+1)
variables. Shows how Boolean assignments map to lattice points, demonstrating
the constructive proof that multiindex count ≥ 2^m.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from math import comb


def bool_to_multiindex(m, b):
    """Inject b ∈ {0,1}^m into a multiindex α ∈ ℕ^{m+1} with |α| = m."""
    ct = sum(1 for x in b if x)
    return (m - ct,) + tuple(int(x) for x in b)


def enumerate_multiindices_3(d):
    """Enumerate multiindices of weight d in 3 variables."""
    for a in range(d + 1):
        for b in range(d - a + 1):
            yield (a, b, d - a - b)


# Create figure with 3 panels
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Injection for m=2 (3 variables, weight 2)
ax1 = axes[0]
m = 2
all_multiindices = list(enumerate_multiindices_3(m))

# Plot all multiindices
for alpha in all_multiindices:
    ax1.scatter(alpha[1], alpha[2], c='lightgray', s=200, zorder=1, edgecolors='gray')
    ax1.annotate(f'({alpha[0]},{alpha[1]},{alpha[2]})',
                 (alpha[1], alpha[2]), textcoords="offset points",
                 xytext=(10, 5), fontsize=8, color='gray')

# Highlight injection image
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for idx, b in enumerate(product([False, True], repeat=m)):
    alpha = bool_to_multiindex(m, b)
    b_str = "".join("1" if x else "0" for x in b)
    ax1.scatter(alpha[1], alpha[2], c=colors[idx], s=300, zorder=2,
                edgecolors='black', linewidths=2)
    ax1.annotate(f'b={b_str}', (alpha[1], alpha[2]),
                 textcoords="offset points", xytext=(-25, -20),
                 fontsize=9, fontweight='bold', color=colors[idx])

ax1.set_xlabel('α₁', fontsize=13)
ax1.set_ylabel('α₂', fontsize=13)
ax1.set_title(f'm=2: {{0,1}}² → multiindices (weight 2, 3 vars)\n'
              f'{2**m} injected / {comb(m+2, m)} total', fontsize=12)
ax1.set_xlim(-0.5, m + 0.5)
ax1.set_ylim(-0.5, m + 0.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Coverage ratio as m grows
ax2 = axes[1]
ms = list(range(1, 15))
injection_sizes = [2**m for m in ms]
total_sizes = [comb(2*m, m) for m in ms]
coverage_ratios = [2**m / comb(2*m, m) for m in ms]

ax2.bar(ms, coverage_ratios, color='steelblue', alpha=0.8, edgecolor='black')
ax2.axhline(y=1.0, color='red', linestyle='--', label='Full coverage')
ax2.set_xlabel('Parameter m', fontsize=13)
ax2.set_ylabel('Coverage Ratio (2^m / C(2m,m))', fontsize=13)
ax2.set_title('Injection Coverage: Fraction of\nMultiindices Hit by Injection', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Injection structure visualization
ax3 = axes[2]
m = 5
bools = list(product([False, True], repeat=m))

# Create a grid showing the injection mapping
# x-axis: Boolean index (0 to 2^m-1)
# y-axis: multiindex components
data = np.zeros((m + 1, 2**m))
for j, b in enumerate(bools):
    alpha = bool_to_multiindex(m, b)
    for i in range(m + 1):
        data[i, j] = alpha[i]

im = ax3.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax3.set_xlabel(f'Boolean assignment index (0 to {2**m-1})', fontsize=12)
ax3.set_ylabel('Multiindex component', fontsize=13)
ax3.set_yticks(range(m + 1))
ax3.set_yticklabels([f'α₀ (slack)'] + [f'α_{i+1} = b_{i}' for i in range(m)])
ax3.set_title(f'm={m}: Injection Structure\n(color = component value)', fontsize=12)
plt.colorbar(im, ax=ax3, label='Value')

plt.tight_layout()
plt.savefig('viz_injection.png', dpi=150, bbox_inches='tight')
print("Saved viz_injection.png")
