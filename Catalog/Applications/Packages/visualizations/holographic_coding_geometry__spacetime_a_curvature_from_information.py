#!/usr/bin/env python3
"""
Visualization: Curvature Landscape from Information

Visualizes how the syndrome defect (discrete curvature) varies as the
entropy profile interpolates between modular (flat) and strongly submodular
(curved). Shows the phase transition from flat to curved geometry as
a function of the concavity parameter.

This directly illustrates the central thesis: geometry emerges from
information constraints.
"""

import itertools
import math
import numpy as np
import matplotlib.pyplot as plt


def all_subsets(n):
    elements = list(range(n))
    result = []
    for r in range(n + 1):
        for combo in itertools.combinations(elements, r):
            result.append(frozenset(combo))
    return result


def syndrome_defect(S, X, Y):
    return S(X) + S(Y) - S(X & Y) - S(X | Y)


def parametric_entropy(alpha):
    """
    Returns S_alpha(X) = |X|^alpha.
    - alpha = 1: modular (flat, zero curvature)
    - alpha < 1: submodular (positive curvature, concave)
    - alpha > 1: supermodular (would violate submodularity)
    """
    def S(X):
        return len(X) ** alpha
    return S


n = 4
subsets = all_subsets(n)

# ─── Plot 1: Total curvature vs concavity parameter ───

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

alphas = np.linspace(0.1, 1.5, 100)
total_curvatures = []
max_curvatures = []
min_curvatures = []

for alpha in alphas:
    S = parametric_entropy(alpha)
    defects = []
    for X in subsets:
        for Y in subsets:
            d = syndrome_defect(S, X, Y)
            defects.append(d)
    total_curvatures.append(sum(d for d in defects if d > 0))
    max_curvatures.append(max(defects))
    min_curvatures.append(min(defects))

ax = axes[0]
ax.plot(alphas, total_curvatures, "b-", linewidth=2, label="Total positive curvature")
ax.axvline(x=1.0, color="red", linestyle="--", alpha=0.7, label="α = 1 (flat/modular)")
ax.fill_between(alphas, 0, total_curvatures, alpha=0.15, color="blue")
ax.set_xlabel("Concavity parameter α", fontsize=11)
ax.set_ylabel("Total curvature (Σ defects)", fontsize=11)
ax.set_title("Phase Transition:\nFlat → Curved Geometry", fontsize=12, fontweight="bold")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ─── Plot 2: Max/min defect vs alpha ───

ax2 = axes[1]
ax2.plot(alphas, max_curvatures, "r-", linewidth=2, label="Max defect")
ax2.plot(alphas, min_curvatures, "b-", linewidth=2, label="Min defect")
ax2.axhline(y=0, color="gray", linestyle="-", alpha=0.5)
ax2.axvline(x=1.0, color="red", linestyle="--", alpha=0.7, label="α = 1 (flat)")
ax2.fill_between(alphas, min_curvatures, max_curvatures, alpha=0.1, color="purple")
ax2.set_xlabel("Concavity parameter α", fontsize=11)
ax2.set_ylabel("Defect value", fontsize=11)
ax2.set_title("Defect Range:\nSubmodular vs Supermodular", fontsize=12, fontweight="bold")
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ─── Plot 3: Entropy profile comparison ───

ax3 = axes[2]
k_vals = np.linspace(0, n, 100)
for alpha in [0.3, 0.5, 0.7, 1.0, 1.3]:
    s_vals = k_vals ** alpha
    style = "--" if alpha > 1 else "-"
    ax3.plot(k_vals, s_vals, style, linewidth=2,
             label=f"α = {alpha}" + (" (modular)" if alpha == 1.0 else ""))

# Mark the submodular and supermodular regions
ax3.fill_between(k_vals, k_vals, k_vals**0.3, alpha=0.05, color="green",
                  label="Submodular region")

ax3.set_xlabel("Region size |X|", fontsize=11)
ax3.set_ylabel("Entropy S(X) = |X|^α", fontsize=11)
ax3.set_title("Entropy Profiles:\nConcavity Controls Curvature", fontsize=12, fontweight="bold")
ax3.legend(fontsize=8, loc="upper left")
ax3.grid(True, alpha=0.3)

plt.suptitle("Curvature from Information: How Entropy Shape Determines Geometry",
             fontsize=14, fontweight="bold", y=1.02)
plt.tight_layout()
plt.savefig("viz_curvature_landscape.png", dpi=150, bbox_inches="tight")
print("Saved: viz_curvature_landscape.png")
