#!/usr/bin/env python3
"""
Visualization: Threshold Rounding as Tropical Projection

This script visualizes the core geometric insight: threshold rounding
acts as a projection from the fractional feasible region onto integral
transversals. We show:
1. The threshold boundary in 2D assignment space
2. How different fractional points map to the same integral transversal
3. The monotonicity structure of the threshold operator
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import PatchCollection

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Threshold regions in 2D
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Threshold Regions in 2D\n(τ = 1/2, rank d = 2)", fontsize=12, fontweight='bold')

tau = 0.5
# Draw the four threshold regions
colors = ['#e8f4f8', '#b3d9e8', '#6bb3d1', '#2185a8']
labels = ['T = ∅', 'T = {v₂}', 'T = {v₁}', 'T = {v₁,v₂}']

# Region T = ∅: [0,τ) × [0,τ)
rect1 = patches.Rectangle((0, 0), tau, tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[0], alpha=0.7)
ax.add_patch(rect1)
ax.text(tau/4, tau/4, 'T = ∅', ha='center', va='center', fontsize=9)

# Region T = {v₁}: [τ,1] × [0,τ)
rect2 = patches.Rectangle((tau, 0), 1-tau, tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[2], alpha=0.7)
ax.add_patch(rect2)
ax.text(tau + (1-tau)/2, tau/4, 'T = {v₁}', ha='center', va='center', fontsize=9)

# Region T = {v₂}: [0,τ) × [τ,1]
rect3 = patches.Rectangle((0, tau), tau, 1-tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[1], alpha=0.7)
ax.add_patch(rect3)
ax.text(tau/4, tau + (1-tau)/2, 'T = {v₂}', ha='center', va='center', fontsize=9)

# Region T = {v₁,v₂}: [τ,1] × [τ,1]
rect4 = patches.Rectangle((tau, tau), 1-tau, 1-tau, linewidth=1, edgecolor='gray',
                           facecolor=colors[3], alpha=0.7)
ax.add_patch(rect4)
ax.text(tau + (1-tau)/2, tau + (1-tau)/2, 'T = {v₁,v₂}', ha='center', va='center',
        fontsize=9, color='white')

# Draw threshold lines
ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', alpha=0.8)
ax.axvline(x=tau, color='red', linewidth=2, linestyle='--', alpha=0.8)

# Draw the feasibility constraint: x₁ + x₂ ≥ 1 for single edge {v₁, v₂}
xs = np.linspace(0, 1, 100)
ax.fill_between(xs, 1 - xs, 1, alpha=0.15, color='green')
ax.plot(xs, np.maximum(1 - xs, 0), 'g-', linewidth=2, label='x₁ + x₂ = 1')

# Sample points
points = [(0.7, 0.6), (0.3, 0.8), (0.6, 0.4), (0.9, 0.2)]
for p in points:
    ax.plot(*p, 'ko', markersize=6)
    ax.annotate(f'({p[0]:.1f},{p[1]:.1f})', p, textcoords="offset points",
                xytext=(5, 5), fontsize=7)

# Mark indicator (retraction) points
ax.plot(1, 1, 'r*', markersize=15, label='Indicator χ_{v₁,v₂}')
ax.plot(1, 0, 'r*', markersize=15)
ax.plot(0, 1, 'r*', markersize=15)

ax.set_xlim(-0.05, 1.1)
ax.set_ylim(-0.05, 1.1)
ax.set_xlabel('x(v₁)', fontsize=11)
ax.set_ylabel('x(v₂)', fontsize=11)
ax.legend(loc='upper right', fontsize=8)
ax.set_aspect('equal')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Monotonicity visualization
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Monotonicity: x ≤ y ⟹ T(x) ⊆ T(y)\n(coordinatewise order)", fontsize=12, fontweight='bold')

tau = 1/3
# Show two points x ≤ y and their threshold sets
x_point = np.array([0.2, 0.4, 0.1, 0.5, 0.35])
y_point = np.array([0.4, 0.5, 0.3, 0.6, 0.4])

vertices = ['v₀', 'v₁', 'v₂', 'v₃', 'v₄']
x_pos = np.arange(len(vertices))
width = 0.35

bars_x = ax.bar(x_pos - width/2, x_point, width, label='x(v)', color='#6bb3d1', alpha=0.8)
bars_y = ax.bar(x_pos + width/2, y_point, width, label='y(v)', color='#2185a8', alpha=0.8)

ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', label=f'τ = 1/3')

# Mark threshold memberships
for i in range(len(vertices)):
    if x_point[i] >= tau:
        ax.text(i - width/2, x_point[i] + 0.02, '∈T(x)', ha='center', fontsize=7, color='#6bb3d1')
    if y_point[i] >= tau:
        ax.text(i + width/2, y_point[i] + 0.02, '∈T(y)', ha='center', fontsize=7, color='#2185a8')

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('Assignment value', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels(vertices)
ax.legend(fontsize=9)
ax.set_ylim(0, 0.8)

# Add T(x) ⊆ T(y) annotation
Tx = {v for v, val in zip(vertices, x_point) if val >= tau}
Ty = {v for v, val in zip(vertices, y_point) if val >= tau}
ax.text(0.5, -0.12, f'T(x) = {Tx}  ⊆  T(y) = {Ty}', transform=ax.transAxes,
        ha='center', fontsize=10, style='italic')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 3: Retraction property
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[2]
ax.set_title("Retraction: T_τ(χ_S) = S\n(threshold fixes integral points)", fontsize=12, fontweight='bold')

# Show the indicator function and its threshold set for different τ
S = {0, 2, 4}  # The set S
n = 6
vertices_idx = list(range(n))
chi_S = [1 if i in S else 0 for i in vertices_idx]

tau_values = [0.1, 0.3, 0.5, 0.7, 1.0]
colors_tau = plt.cm.viridis(np.linspace(0.2, 0.9, len(tau_values)))

bar_width = 0.6
ax.bar(vertices_idx, chi_S, bar_width, color=['#2185a8' if i in S else '#e8f4f8'
       for i in vertices_idx], edgecolor='gray', linewidth=1)

for i, tau_val in enumerate(tau_values):
    ax.axhline(y=tau_val, color=colors_tau[i], linewidth=1.5, linestyle='--',
               alpha=0.7, label=f'τ = {tau_val}')
    # All return S since 0 < τ ≤ 1
    T = {v for v in vertices_idx if chi_S[v] >= tau_val}
    # Add small annotation
    ax.text(n + 0.2, tau_val, f'T = {T}', fontsize=7, va='center', color=colors_tau[i])

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('χ_S(v)', fontsize=11)
ax.set_xticks(vertices_idx)
ax.set_xticklabels([f'v{i}' for i in vertices_idx])
ax.legend(loc='center right', fontsize=7, bbox_to_anchor=(1.45, 0.5))
ax.set_ylim(-0.1, 1.3)
ax.set_xlim(-0.5, n + 1.5)

# Annotate S
ax.text(0.5, -0.12, f'S = {S}: T_τ(χ_S) = S for all τ ∈ (0, 1]',
        transform=ax.transAxes, ha='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('threshold_visualization.png', dpi=150, bbox_inches='tight')
print("Saved threshold_visualization.png")
