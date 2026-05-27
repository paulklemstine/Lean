#!/usr/bin/env python3
"""
Visualization 3: Newton Inequalities and the Reversed Cauchy-Schwarz

Shows the Newton inequality a_m^2 >= a_{m-1} * a_{m+1} for coefficient
sequences of Lorentzian polynomials. Plots the "surplus" (a_m^2 - a_{m-1}*a_{m+1})
for different polynomial families, illustrating that the inequality is
always satisfied with nonnegative surplus.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def product_coeffs(weights, d):
    """Compute bivariate specialization coefficients of a product of linear forms."""
    coeffs = [0.0] * (d + 1)
    for m in range(d + 1):
        total = 0.0
        for S in combinations(range(d), m):
            S_set = set(S)
            prod_val = 1.0
            for i in range(d):
                prod_val *= weights[i][0] if i in S_set else weights[i][1]
            total += prod_val
        coeffs[m] = total
    return coeffs


def newton_surplus(seq):
    """Compute a_m^2 - a_{m-1}*a_{m+1} for each interior index."""
    return [seq[m] ** 2 - seq[m - 1] * seq[m + 1]
            for m in range(1, len(seq) - 1)]


# Generate three families
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Family 1: Binomial coefficients
for d in [6, 8, 10, 14]:
    coeffs = [comb(d, m) for m in range(d + 1)]
    surplus = newton_surplus(coeffs)
    # Normalize by max
    if max(surplus) > 0:
        surplus_norm = [s / max(surplus) for s in surplus]
    else:
        surplus_norm = surplus
    axes[0].plot(range(1, len(surplus) + 1), surplus_norm,
                 'o-', label=f'd={d}', markersize=4, linewidth=1.5)
axes[0].axhline(y=0, color='red', linestyle='--', alpha=0.5)
axes[0].set_title("Binomial Coefficients\nC(d, m)", fontsize=12, fontweight='bold')
axes[0].set_xlabel("Index m")
axes[0].set_ylabel("Normalized surplus\n(a_m² − a_{m−1}·a_{m+1})")
axes[0].legend(fontsize=9)
axes[0].grid(alpha=0.3)

# Family 2: Products of linear forms
np.random.seed(42)
for d in [5, 8, 10, 12]:
    weights = [(np.random.uniform(0.5, 3.0), np.random.uniform(0.5, 3.0))
               for _ in range(d)]
    coeffs = product_coeffs(weights, d)
    surplus = newton_surplus(coeffs)
    if max(surplus) > 0:
        surplus_norm = [s / max(surplus) for s in surplus]
    else:
        surplus_norm = surplus
    axes[1].plot(range(1, len(surplus) + 1), surplus_norm,
                 's-', label=f'd={d}', markersize=4, linewidth=1.5)
axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5)
axes[1].set_title("Products of Linear Forms\nΠ(uᵢx + vᵢy)", fontsize=12, fontweight='bold')
axes[1].set_xlabel("Index m")
axes[1].legend(fontsize=9)
axes[1].grid(alpha=0.3)

# Family 3: Matroid basis profiles
for n, r in [(8, 4), (10, 5), (12, 6), (14, 7)]:
    ps = n // 2
    coeffs = []
    for m in range(r + 1):
        if m <= ps and r - m <= n - ps:
            coeffs.append(comb(ps, m) * comb(n - ps, r - m))
        else:
            coeffs.append(0)
    # Remove zeros
    while coeffs and coeffs[-1] == 0:
        coeffs.pop()
    while coeffs and coeffs[0] == 0:
        coeffs.pop(0)

    if len(coeffs) >= 3:
        surplus = newton_surplus(coeffs)
        if max(surplus) > 0:
            surplus_norm = [s / max(surplus) for s in surplus]
        else:
            surplus_norm = surplus
        axes[2].plot(range(1, len(surplus) + 1), surplus_norm,
                     '^-', label=f'U({r},{n})', markersize=4, linewidth=1.5)

axes[2].axhline(y=0, color='red', linestyle='--', alpha=0.5)
axes[2].set_title("Matroid Basis Profiles\nC(k,m)·C(n−k,r−m)", fontsize=12, fontweight='bold')
axes[2].set_xlabel("Index m")
axes[2].legend(fontsize=9)
axes[2].grid(alpha=0.3)

fig.suptitle("Newton Inequality Surplus: a_m² − a_{m−1}·a_{m+1} ≥ 0",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_newton_inequalities.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_newton_inequalities.png")
