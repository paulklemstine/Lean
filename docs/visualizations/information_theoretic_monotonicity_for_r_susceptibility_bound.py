#!/usr/bin/env python3
"""
Visualization 3: Susceptibility Bound — Statistical Physics Bridge

Visualizes the spin susceptibility χ = Σ_{i≠j} |Cov(X_i, X_j)| alongside
the certified bound ε·(Σp_i)² from the Lean theorem susceptibility_le_of_robust.
Shows the bridge between Lorentzian negativity and statistical mechanics:
the gap ε acts as repulsive curvature limiting magnetic response.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import log, comb


def compute_profile(n, r, eps_pert=0.0):
    """Compute susceptibility and bound for (perturbed) uniform matroid."""
    weights = {}
    for s in combinations(range(n), r):
        fs = frozenset(s)
        weights[fs] = 1.0 + eps_pert * (1.0 if 0 in s else 0.0)
    total = sum(weights.values())
    weights = {s: w/total for s, w in weights.items()}

    def cp(i):
        return sum(w for s, w in weights.items() if i in s)

    def cov(i, j):
        pij = sum(w for s, w in weights.items() if i in s and j in s)
        return pij - cp(i) * cp(j)

    chi = sum(abs(cov(i, j)) for i in range(n) for j in range(n) if i != j)
    gap = max(abs(cov(i, j)) / (cp(i) * cp(j))
              for i in range(n) for j in range(i+1, n)
              if cp(i) > 0 and cp(j) > 0)
    sum_p = sum(cp(i) for i in range(n))
    bound = gap * sum_p**2

    return chi, bound, gap


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Susceptibility Bounds: Lorentzian Geometry → Statistical Mechanics',
             fontsize=13, fontweight='bold')

# Plot 1: Susceptibility vs bound for different matroids
ax1 = axes[0]
matroids = [(4, 2), (5, 2), (5, 3), (6, 2), (6, 3), (7, 3)]
chis = []
bounds = []
labels = []
for n, r in matroids:
    chi, bound, gap = compute_profile(n, r)
    chis.append(chi)
    bounds.append(bound)
    labels.append(f'U({n},{r})')

x = np.arange(len(matroids))
width = 0.35
ax1.bar(x - width/2, chis, width, label='χ (actual)', color='steelblue', alpha=0.8)
ax1.bar(x + width/2, bounds, width, label='ε·(Σpᵢ)² (bound)', color='coral', alpha=0.8)
ax1.set_xticks(x)
ax1.set_xticklabels(labels, fontsize=9)
ax1.set_ylabel('Value')
ax1.set_title('Susceptibility vs Certified Bound')
ax1.legend()

# Plot 2: Ratio χ/bound as perturbation grows
ax2 = axes[1]
n, r = 6, 3
eps_values = np.linspace(0.01, 5.0, 50)
ratios = []
gaps_list = []
for eps in eps_values:
    chi, bound, gap = compute_profile(n, r, eps)
    ratios.append(chi / bound if bound > 0 else 0)
    gaps_list.append(gap)

ax2.plot(eps_values, ratios, 'b-', linewidth=2)
ax2.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Bound = χ')
ax2.set_xlabel('Perturbation strength')
ax2.set_ylabel('χ / bound')
ax2.set_title(f'Tightness ratio for perturbed U({n},{r})')
ax2.set_ylim(0, 1.2)
ax2.legend()

# Plot 3: Gap growth under perturbation
ax3 = axes[2]
ax3.plot(eps_values, gaps_list, 'g-', linewidth=2, label='ε (gap)')
ax3.set_xlabel('Perturbation strength')
ax3.set_ylabel('Robustness gap ε')
ax3.set_title('Gap Evolution Under Perturbation')
ax3.legend()

plt.tight_layout()
plt.savefig('viz_susceptibility.png', dpi=150, bbox_inches='tight')
print("Saved viz_susceptibility.png")
