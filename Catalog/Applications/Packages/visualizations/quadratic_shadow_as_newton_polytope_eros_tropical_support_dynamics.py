"""
Visualization: Tropical Second-Derivative Support Map

Shows how the tropical second derivative transforms the support of a
polynomial. For each point in the shadow, visualizes which derivative
directions (i,j) connect it to the original support, creating a
"derivative flow" diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import combinations_with_replacement, product


# ──────────── Self-contained algorithms ────────────

def quadratic_increments(n):
    result = []
    for i in range(n):
        beta = [0] * n; beta[i] = 2; result.append(tuple(beta))
    for i, j in combinations_with_replacement(range(n), 2):
        if i != j:
            beta = [0] * n; beta[i] = 1; beta[j] = 1; result.append(tuple(beta))
    return result

def discrete_quad_shadow(S, n):
    increments = quadratic_increments(n)
    shadow = set()
    for alpha in S:
        for beta in increments:
            u = tuple(a - b for a, b in zip(alpha, beta))
            if all(x >= 0 for x in u): shadow.add(u)
    return shadow


# ──────────── Visualization ────────────

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Support: degree-4 full triangle in 2D
S = set()
for i in range(5):
    for j in range(5 - i):
        S.add((i, j))

n = 2
shadow = discrete_quad_shadow(S, n)
increments = quadratic_increments(n)

# Color map for derivative directions
colors = {(2, 0): '#e41a1c', (0, 2): '#377eb8', (1, 1): '#4daf4a'}
labels = {(2, 0): '∂²/∂x²', (0, 2): '∂²/∂y²', (1, 1): '∂²/∂x∂y'}

# Left: Support with derivative arrows
ax = axes[0]
S_arr = np.array(list(S))
ax.scatter(S_arr[:, 0], S_arr[:, 1], c='royalblue', s=100, zorder=5,
           edgecolors='black', linewidths=0.5, label='Support S')

# Draw arrows from support to shadow
for alpha in sorted(S):
    for beta in increments:
        u = tuple(a - b for a, b in zip(alpha, beta))
        if all(x >= 0 for x in u) and u in shadow:
            color = colors.get(beta, 'gray')
            ax.annotate('', xy=u, xytext=alpha,
                        arrowprops=dict(arrowstyle='->', color=color, alpha=0.2, lw=0.8))

# Legend entries for derivative types
for beta, label in labels.items():
    ax.plot([], [], '-', color=colors[beta], label=label, linewidth=2)

ax.set_title('Derivative Flow: Support → Shadow\n(arrows show ∂ᵢ∂ⱼ connections)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2); ax.legend(fontsize=9, loc='upper right')
ax.set_xlim(-0.5, 5); ax.set_ylim(-0.5, 5)

# Right: Shadow with heatmap of derivative richness
ax = axes[1]

# Compute richness: how many derivatives produce each shadow point
richness = {}
for u in shadow:
    count = 0
    for beta in increments:
        alpha = tuple(a + b for a, b in zip(u, beta))
        if alpha in S:
            count += 1
    richness[u] = count

shadow_arr = np.array(list(shadow))
rich_vals = [richness[tuple(p)] for p in shadow_arr]

scatter = ax.scatter(shadow_arr[:, 0], shadow_arr[:, 1], c=rich_vals, cmap='YlOrRd',
                     s=150, zorder=5, edgecolors='black', linewidths=0.5, vmin=1, vmax=max(rich_vals))
plt.colorbar(scatter, ax=ax, label='Derivative richness (# sources)')

# Annotate richness
for u, r in richness.items():
    ax.annotate(str(r), u, textcoords="offset points", xytext=(0, 8),
                ha='center', fontsize=7, fontweight='bold')

ax.set_title('Tropical Hessian Support\n(color = derivative richness)', fontsize=11, fontweight='bold')
ax.set_aspect('equal'); ax.grid(True, alpha=0.2)
ax.set_xlim(-0.5, 5); ax.set_ylim(-0.5, 5)

fig.suptitle('Tropical Second Derivative: Support Dynamics',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_support_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tropical_support_dynamics.png")
