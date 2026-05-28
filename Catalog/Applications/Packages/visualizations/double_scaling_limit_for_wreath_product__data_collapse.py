#!/usr/bin/env python3
"""
Visualization: Data Collapse and Critical Exponent Identification

Shows data collapse analysis for identifying the critical exponent α_c.
At the correct α_c, curves from different k values collapse onto a
single universal curve — the crossover profile F(λ).
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p  # = 2.0

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

alpha_candidates = [1.0, 1.5, 2.0, 2.5]
k_test = [8, 15, 30, 60, 120]
colors_k = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

for idx, alpha in enumerate(alpha_candidates):
    ax = axes[idx // 2, idx % 2]

    for k, color in zip(k_test, colors_k):
        lambdas = []
        rescaled = []

        for m in range(1, max(2, int(5 * k**alpha))):
            delta = compute_defect(k, m, C, p, q)
            lam = m / k**alpha
            if lam > 5:
                break
            R = (k**alpha / m) * delta if m > 0 else 0
            lambdas.append(lam)
            rescaled.append(R)

        if lambdas:
            ax.plot(lambdas, rescaled, '-', color=color, linewidth=1.5,
                    label=f'k={k}', alpha=0.8)

    # Mark whether this is the critical exponent
    is_critical = abs(alpha - alpha_c) < 0.01
    title_suffix = " ← COLLAPSE!" if is_critical else ""
    border_color = '#2ca02c' if is_critical else '#cccccc'

    ax.set_xlabel('λ = m / k^α', fontsize=11)
    ax.set_ylabel('R_α = k^α/m · Δ', fontsize=11)
    ax.set_title(f'α = {alpha:.1f}{title_suffix}', fontsize=12,
                 fontweight='bold' if is_critical else 'normal',
                 color='#2ca02c' if is_critical else 'black')
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim([0, 5])

    if is_critical:
        ax.axhline(y=C, color='black', linestyle=':', linewidth=1.5,
                   alpha=0.7, label=f'F(λ) = {C}')
        for spine in ax.spines.values():
            spine.set_edgecolor('#2ca02c')
            spine.set_linewidth(3)

plt.suptitle('Data Collapse Analysis: Finding the Critical Exponent\n'
             f'True α_c = {alpha_c:.1f} — Perfect collapse identifies the transition',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('data_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved data_collapse.png")
