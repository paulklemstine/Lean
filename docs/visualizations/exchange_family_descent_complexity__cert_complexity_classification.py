#!/usr/bin/env python3
"""
Visualization: Descent Complexity Classification

Shows the three complexity regimes (polynomial, exponential, factorial)
and how exchange families fall into different classes based on their
worst-case descent length relative to dimension.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("Descent Complexity Classification", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: Complexity regime boundaries
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = axes[0]

d = np.linspace(2, 10, 100)

# Three regimes
poly1 = d
poly2 = d ** 2
poly3 = d ** 3
exp2 = 2 ** d
factorial = np.array([np.math.factorial(int(x)) for x in np.floor(d)])

ax1.semilogy(d, poly1, '-', color='#2ecc71', linewidth=2.5, label='Polynomial(1): d')
ax1.semilogy(d, poly2, '-', color='#27ae60', linewidth=2.5, label='Polynomial(2): d²')
ax1.semilogy(d, poly3, '-', color='#1e8449', linewidth=2.5, label='Polynomial(3): d³')
ax1.semilogy(d, exp2, '--', color='#e74c3c', linewidth=2.5, label='Exponential(2): 2^d')
ax1.semilogy(np.floor(d), factorial, ':', color='#8e44ad', linewidth=2.5, label='Factorial: d!')

# Shade regions
ax1.fill_between(d, 1, poly2, alpha=0.05, color='green')
ax1.fill_between(d, poly2, exp2, alpha=0.05, color='orange')
ax1.fill_between(d, exp2, 1e8, alpha=0.05, color='red')

# Example families as points
examples = [
    (3, 3, "Matroid\nbasis", '#2ecc71'),
    (5, 20, "Greedy\nsearch", '#27ae60'),
    (4, 50, "LP\nrelaxation", '#f39c12'),
    (6, 200, "SAT\nlocal", '#e74c3c'),
    (5, 120, "Klee-\nMinty", '#8e44ad'),
]

for dx, wdl, name, color in examples:
    ax1.plot(dx, wdl, 'o', color=color, markersize=12, zorder=5,
             markeredgecolor='black', markeredgewidth=1.5)
    ax1.annotate(name, (dx, wdl), textcoords="offset points",
                 xytext=(12, 0), fontsize=9, ha='left',
                 fontweight='bold')

ax1.set_xlabel('Dimension d', fontsize=12)
ax1.set_ylabel('Worst Descent Length (log)', fontsize=12)
ax1.set_title('Complexity Regime Boundaries', fontsize=13)
ax1.legend(fontsize=9, loc='upper left')
ax1.set_ylim(1, 1e6)
ax1.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Gap ratio heatmap
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = axes[1]

dims = np.arange(2, 11)
depths = np.arange(0, 6)

# Compute WDL / d^k ratios for hypothetical families
# Assume WDL ~ 0.5 * d^(d/3) for illustration
gap_ratios = np.zeros((len(depths), len(dims)))
for i, k in enumerate(depths):
    for j, d in enumerate(dims):
        wdl = int(0.5 * d ** (d / 3.0))
        bound = d ** k if k > 0 else 1
        ratio = min(wdl / bound, 1.0) if bound > 0 else 0
        gap_ratios[i, j] = ratio

im = ax2.imshow(gap_ratios, aspect='auto', cmap='RdYlGn_r', vmin=0, vmax=1,
                origin='lower')
ax2.set_xticks(range(len(dims)))
ax2.set_xticklabels(dims)
ax2.set_yticks(range(len(depths)))
ax2.set_yticklabels(depths)
ax2.set_xlabel('Dimension d', fontsize=12)
ax2.set_ylabel('Certificate Depth k', fontsize=12)
ax2.set_title('Gap Ratio: WDL / d^k', fontsize=13)

cbar = fig.colorbar(im, ax=ax2, shrink=0.8)
cbar.set_label('Ratio (closer to 0 = larger gap)', fontsize=10)

# Annotate with values
for i in range(len(depths)):
    for j in range(len(dims)):
        val = gap_ratios[i, j]
        color = 'white' if val > 0.5 else 'black'
        ax2.text(j, i, f'{val:.2f}', ha='center', va='center',
                 fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig("complexity_classes.png", dpi=150, bbox_inches='tight')
print("Saved complexity_classes.png")
