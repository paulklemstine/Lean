#!/usr/bin/env python3
"""
Visualization 2: Ratio Transform Cascade

Visualizes the iterated ratio transform of a function, showing how
the shape evolves at each depth level. This makes visible the
"discrete curvature peeling" process that defines the depth filtration.

For a 1D function f, plots f, R(f), R²(f), ... side by side,
with annotations showing where log-concavity fails.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb


def compute_ratio_cascade(coeffs, num_levels=4, max_n=10):
    """Compute iterated ratio transforms of a 1D coefficient sequence."""
    levels = [coeffs[:]]

    current = coeffs[:]
    for level in range(num_levels):
        ratios = []
        for n in range(len(current) - 1):
            if abs(current[n]) > 1e-15:
                ratios.append(current[n + 1] / current[n])
            else:
                ratios.append(0.0)
        levels.append(ratios)
        current = ratios

    return levels


def check_log_concavity(seq):
    """Find violations of log-concavity in a sequence."""
    violations = []
    for n in range(len(seq) - 2):
        if seq[n + 1] ** 2 < seq[n] * seq[n + 2] - 1e-12:
            violations.append(n + 1)
    return violations


# Example functions to visualize
examples = [
    {
        "name": "Geometric (infinite depth)",
        "coeffs": [2**n for n in range(12)],
        "color": "#2196F3"
    },
    {
        "name": "Binomial C(8,k) (depth 1)",
        "coeffs": [float(comb(8, k)) for k in range(9)] + [0]*3,
        "color": "#4CAF50"
    },
    {
        "name": "[1, 3, 2, 1] (depth exactly 1)",
        "coeffs": [1, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        "color": "#FF5722"
    },
    {
        "name": "Triangular [1, 2, 1] (high depth)",
        "coeffs": [1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "color": "#9C27B0"
    },
]

fig, axes = plt.subplots(len(examples), 4, figsize=(16, 3.5 * len(examples)))

level_names = ['f', 'R(f)', 'R²(f)', 'R³(f)']

for row, example in enumerate(examples):
    cascade = compute_ratio_cascade(example["coeffs"], num_levels=3)

    for col in range(4):
        ax = axes[row, col]
        if col < len(cascade):
            seq = cascade[col]
            n_vals = list(range(len(seq)))

            # Plot the sequence
            ax.bar(n_vals, seq, color=example["color"], alpha=0.7, edgecolor='black',
                   linewidth=0.5)

            # Check and highlight log-concavity violations
            violations = check_log_concavity(seq)
            if violations:
                for v in violations:
                    ax.axvspan(v - 0.5, v + 0.5, color='red', alpha=0.2)
                    ax.plot(v, seq[v], 'rv', markersize=10)

            # Formatting
            if col == 0:
                ax.set_ylabel(example["name"], fontsize=9, fontweight='bold')

            if row == 0:
                ax.set_title(level_names[col], fontsize=13, fontweight='bold')

            ax.set_xlabel('n', fontsize=9)

            # Add log-concavity status
            if len(seq) >= 3:
                is_lc = len(violations) == 0
                status = "✓ LC" if is_lc else "✗ LC fails"
                color = 'green' if is_lc else 'red'
                ax.text(0.95, 0.95, status, transform=ax.transAxes,
                       ha='right', va='top', fontsize=9, color=color,
                       fontweight='bold',
                       bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                                alpha=0.8))
        else:
            ax.set_visible(False)

        ax.set_xlim(-0.5, 10.5)
        ax.grid(True, alpha=0.3)

plt.suptitle('Ratio Transform Cascade: Peeling Away Layers of Curvature',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ratio_cascade.png', dpi=150, bbox_inches='tight')
print("Saved ratio_cascade.png")
