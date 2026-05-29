#!/usr/bin/env python3
"""
Visualization: Syndrome Defect Heatmap

Visualizes the syndrome defect (discrete curvature) for all pairs of subsets
of a 3-element boundary set under different entropy profiles.

The heatmap reveals which region pairs interact (positive curvature) and
which are informationally independent (zero curvature / flat geometry).
"""

import itertools
import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def all_subsets(n):
    elements = list(range(n))
    result = []
    for r in range(n + 1):
        for combo in itertools.combinations(elements, r):
            result.append(frozenset(combo))
    return result


def syndrome_defect(S, X, Y):
    return S(X) + S(Y) - S(X & Y) - S(X | Y)


def subset_label(X):
    if not X:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(X)) + "}"


def make_heatmap(ax, S, title, subsets, labels):
    n = len(subsets)
    matrix = np.zeros((n, n))
    for i, X in enumerate(subsets):
        for j, Y in enumerate(subsets):
            matrix[i, j] = syndrome_defect(S, X, Y)

    vmax = max(matrix.max(), 0.01)
    im = ax.imshow(matrix, cmap="YlOrRd", vmin=0, vmax=vmax, aspect="equal")
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha="right", fontsize=7)
    ax.set_yticklabels(labels, fontsize=7)
    ax.set_title(title, fontsize=10, fontweight="bold")
    ax.set_xlabel("Region Y", fontsize=8)
    ax.set_ylabel("Region X", fontsize=8)

    # Annotate cells
    for i in range(n):
        for j in range(n):
            val = matrix[i, j]
            color = "white" if val > vmax * 0.6 else "black"
            ax.text(j, i, f"{val:.2f}", ha="center", va="center",
                    fontsize=5, color=color)

    return im


# Set up
n = 3
subsets = all_subsets(n)
labels = [subset_label(X) for X in subsets]

# Four entropy profiles
profiles = {
    "S(X) = |X|  (modular/flat)": lambda X: float(len(X)),
    "S(X) = √|X|  (submodular)": lambda X: math.sqrt(len(X)),
    "S(X) = log(1+|X|)": lambda X: math.log(1 + len(X)),
    "S(X) = min(|X|, 2)": lambda X: min(float(len(X)), 2.0),
}

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("Syndrome Defect Heatmaps — Discrete Curvature on {0, 1, 2}",
             fontsize=14, fontweight="bold", y=0.98)

for ax, (title, S) in zip(axes.flat, profiles.items()):
    im = make_heatmap(ax, S, title, subsets, labels)

# Add colorbar
fig.subplots_adjust(right=0.88, hspace=0.35, wspace=0.35)
cbar_ax = fig.add_axes([0.91, 0.15, 0.02, 0.7])
fig.colorbar(im, cax=cbar_ax, label="Syndrome Defect (curvature)")

plt.savefig("viz_defect_heatmap.png", dpi=150, bbox_inches="tight")
print("Saved: viz_defect_heatmap.png")
