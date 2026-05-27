"""
Visualization 1: Newton Inequality Ratios for Lorentzian Specializations

Visualizes the Newton ratio a_m^2 / (a_{m-1} * a_{m+1}) for bivariate
specialization coefficients of various Lorentzian polynomial families.
The ratio is always >= 1 for log-concave sequences, and the bridge theorem
guarantees this for Lorentzian specializations.

This creates a heatmap showing Newton ratios across different polynomial
families and indices, revealing the strength of the Lorentzian constraint.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def product_of_linear_forms(d, weights=None):
    if weights is None:
        weights = [(i + 1) / (d + 1) for i in range(d)]
    coeffs = [1.0]
    for w in weights:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c * (1 - w)
            new_coeffs[i + 1] += c * w
        coeffs = new_coeffs
    return coeffs


def newton_ratios(seq):
    ratios = []
    for m in range(1, len(seq) - 1):
        denom = seq[m - 1] * seq[m + 1]
        if denom > 0:
            ratios.append(seq[m] ** 2 / denom)
        else:
            ratios.append(float('inf'))
    return ratios


def ratio_transform(seq):
    return [seq[m + 1] / seq[m] if seq[m] != 0 else 0 for m in range(len(seq) - 1)]


d = 10
families = {
    'Binomial C(10,m)': [float(math.comb(d, m)) for m in range(d + 1)],
    'Uniform weights': product_of_linear_forms(d),
    'Linear weights': product_of_linear_forms(d, [(i+1)/(d+1) for i in range(d)]),
    'Quadratic weights': product_of_linear_forms(d, [(i+1)**2/(d+1)**2 for i in range(d)]),
    '(2x+y)^10': [math.comb(d, m) * 2**m for m in range(d + 1)],
    '(3x+y)^10': [math.comb(d, m) * 3**m for m in range(d + 1)],
}

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Newton Inequality Ratios: a_m² / (a_{m-1}·a_{m+1})\n'
             'Values ≥ 1 confirm log-concavity (Bridge Theorem)', fontsize=14)

for idx, (name, coeffs) in enumerate(families.items()):
    ax = axes[idx // 3][idx % 3]
    ratios = newton_ratios(coeffs)
    indices = list(range(1, len(ratios) + 1))

    colors = ['#2196F3' if r >= 1 else '#F44336' for r in ratios]
    ax.bar(indices, [r - 1 for r in ratios], bottom=1, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1, label='LC threshold')
    ax.set_xlabel('Index m')
    ax.set_ylabel('Newton ratio')
    ax.set_title(name, fontsize=11)
    ax.set_ylim(0.9, max(ratios) * 1.1 if ratios else 2)

plt.tight_layout()
plt.savefig('newton_ratios.png', dpi=150, bbox_inches='tight')
print("Saved newton_ratios.png")
