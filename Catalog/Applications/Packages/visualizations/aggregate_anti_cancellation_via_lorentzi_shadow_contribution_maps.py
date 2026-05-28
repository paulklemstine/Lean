#!/usr/bin/env python3
"""
Visualization: Pair Shadows and Aggregate Shadows for Hessian Operators

Visualizes the core geometric concept: how second-derivative shadows combine
under weighted aggregation, and why sign coherence prevents cancellation.

Creates a heatmap showing the "contribution map" — for each monomial in the
aggregate shadow, which variable pairs contribute, and with what sign.
"""

import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction
from collections import defaultdict
from itertools import combinations


def poly_pderiv(coeffs, n, var):
    """Partial derivative of polynomial (dict exponent->coeff) w.r.t. var."""
    result = {}
    for exp, c in coeffs.items():
        if exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            ne = tuple(ne)
            new_c = c * exp[var]
            result[ne] = result.get(ne, 0) + new_c
    return {e: c for e, c in result.items() if c != 0}


def compute_contributions(coeffs, n, A):
    """For each monomial, compute contributions from each (i,j) pair."""
    contribs = defaultdict(lambda: defaultdict(float))
    for i in range(n):
        for j in range(n):
            if A[i][j] == 0:
                continue
            d1 = poly_pderiv(coeffs, n, j)
            d2 = poly_pderiv(d1, n, i)
            for exp, c in d2.items():
                contribs[exp][(i, j)] = A[i][j] * c
    return dict(contribs)


# --- Example 1: Nonneg coefficients, positive weights ---
n = 3
coeffs_good = {
    (2, 1, 0): 3, (1, 2, 0): 2, (1, 1, 1): 4,
    (2, 0, 1): 1, (0, 2, 1): 2, (0, 1, 2): 1,
}
A_good = [[1, 1, 1], [1, 2, 1], [1, 1, 1]]

# --- Example 2: Mixed coefficients (cancellation possible) ---
coeffs_bad = {
    (2, 1, 0): 3, (1, 2, 0): -2, (1, 1, 1): 4,
    (2, 0, 1): -1, (0, 2, 1): 2, (0, 1, 2): -1,
}

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

for ax_idx, (coeffs, title, cmap) in enumerate([
    (coeffs_good, "Nonneg Coefficients\n(No Cancellation — Theorem Guarantees)", "YlGn"),
    (coeffs_bad, "Mixed Coefficients\n(Cancellation Possible)", "RdBu_r"),
]):
    contribs = compute_contributions(coeffs, n, A_good)
    
    if not contribs:
        continue
    
    # Sort monomials and pairs
    monomials = sorted(contribs.keys())
    pairs = sorted({p for m in contribs for p in contribs[m]})
    
    # Build contribution matrix
    mat = np.zeros((len(monomials), len(pairs)))
    for mi, m in enumerate(monomials):
        for pi, p in enumerate(pairs):
            mat[mi, pi] = contribs[m].get(p, 0)
    
    # Compute sums
    sums = mat.sum(axis=1)
    
    # Plot
    ax = axes[ax_idx]
    vmax = max(abs(mat.max()), abs(mat.min()), 1)
    im = ax.imshow(mat, aspect='auto', cmap=cmap, vmin=-vmax, vmax=vmax)
    
    # Labels
    ax.set_xticks(range(len(pairs)))
    ax.set_xticklabels([f"({p[0]},{p[1]})" for p in pairs], rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(len(monomials)))
    ylabels = []
    for mi, m in enumerate(monomials):
        cancelled = "  ✗ CANCELLED" if sums[mi] == 0 and any(mat[mi] != 0) else ""
        ylabels.append(f"{m}  (Σ={sums[mi]:.0f}){cancelled}")
    ax.set_yticklabels(ylabels, fontsize=8)
    
    ax.set_xlabel("Variable Pair (i, j)", fontsize=11)
    ax.set_ylabel("Monomial β in Aggregate Shadow", fontsize=11)
    ax.set_title(title, fontsize=13, fontweight='bold')
    
    # Annotate cells
    for mi in range(len(monomials)):
        for pi in range(len(pairs)):
            val = mat[mi, pi]
            if val != 0:
                color = 'white' if abs(val) > vmax * 0.6 else 'black'
                ax.text(pi, mi, f"{val:.0f}", ha='center', va='center',
                        fontsize=7, color=color, fontweight='bold')
    
    plt.colorbar(im, ax=ax, shrink=0.8, label="A(i,j) · coeff_β(∂ᵢ∂ⱼp)")

fig.suptitle("Aggregate Anti-Cancellation: Contribution Maps\n"
             "Each cell shows the weighted contribution of pair (i,j) to monomial β",
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("shadow_contributions.png", dpi=150, bbox_inches='tight')
print("Saved shadow_contributions.png")
