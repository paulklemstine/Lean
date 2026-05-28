#!/usr/bin/env python3
"""
Visualization 1: Hessian Shadow Heatmap

Visualizes the quadratic shadow of a polynomial's support as a heatmap.
For a 2-variable polynomial, shows which (i,j) Hessian entries have
nonzero support, and the predicted support sizes.

This demonstrates the core theorem: over characteristic zero, the
shadow prediction is exact — no cancellations occur.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cartesian_product


def compute_quad_leaf(support, n_vars, i, j):
    result = set()
    for alpha in support:
        if alpha[i] < 1:
            continue
        mid = list(alpha)
        mid[i] -= 1
        if mid[j] < 1:
            continue
        mid[j] -= 1
        result.add(tuple(mid))
    return result


def compute_shadow(support, n_vars):
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


# Generate example supports
n_vars = 4
max_deg = 5

# Sparse support
sparse_support = {(5, 0, 0, 0), (0, 5, 0, 0), (0, 0, 5, 0), (0, 0, 0, 5),
                  (2, 2, 1, 0), (1, 0, 2, 2), (0, 1, 1, 3)}

# Dense support (all monomials up to degree 3)
dense_support = set()
for degs in cartesian_product(range(4), repeat=n_vars):
    if sum(degs) <= 3:
        dense_support.add(degs)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, (support, title) in enumerate([
    (sparse_support, "Sparse Support (7 monomials)"),
    (dense_support, f"Dense Support ({len(dense_support)} monomials)")
]):
    # Compute per-pair leaf sizes
    matrix = np.zeros((n_vars, n_vars))
    for i in range(n_vars):
        for j in range(n_vars):
            leaf = compute_quad_leaf(support, n_vars, i, j)
            matrix[i, j] = len(leaf)

    ax = axes[idx]
    im = ax.imshow(matrix, cmap='YlOrRd', aspect='equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel("Variable j (∂ⱼ)", fontsize=11)
    ax.set_ylabel("Variable i (∂ᵢ)", fontsize=11)
    ax.set_xticks(range(n_vars))
    ax.set_yticks(range(n_vars))
    ax.set_xticklabels([f"x{k}" for k in range(n_vars)])
    ax.set_yticklabels([f"x{k}" for k in range(n_vars)])

    # Annotate cells
    for i in range(n_vars):
        for j in range(n_vars):
            val = int(matrix[i, j])
            color = 'white' if val > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=12, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax, label='# nonzero coefficients')

    # Shadow stats
    shadow = compute_shadow(support, n_vars)
    total = int(matrix.sum())
    ax.text(0.5, -0.15, f"|Sh₂(S)| = {len(shadow)}, total entries = {total}",
            transform=ax.transAxes, ha='center', fontsize=10,
            style='italic')

plt.suptitle("Hessian Shadow Structure: Predicted Support Sizes\n"
             "(Over ℚ, these predictions are exact — Theorem 1)",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_shadow_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
