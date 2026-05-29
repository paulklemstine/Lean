"""
Visualization 3: Cognitive Complexity Hierarchy

Visualizes the monotonicity of the cognitive level assignment and
the information-theoretic bounds. Shows how the proved theorems
constrain the space of possible cognitive processes.
"""

import matplotlib.pyplot as plt
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ─── Left: Cognitive Level Step Function (Monotonicity) ────────

crossings = np.arange(0, 15)
level_names = ['Trivial', 'Simple', 'Moderate', 'Complex']
level_colors = ['#95a5a6', '#3498db', '#2ecc71', '#e74c3c']

def cog_level(k):
    if k == 0: return 0
    elif k <= 2: return 1
    elif k <= 5: return 2
    else: return 3

levels = [cog_level(k) for k in crossings]

# Step function
for i in range(len(crossings) - 1):
    ax1.fill_between([crossings[i], crossings[i+1]],
                     [levels[i], levels[i]],
                     alpha=0.3, color=level_colors[levels[i]])
    ax1.plot([crossings[i], crossings[i+1]], [levels[i], levels[i]],
             color=level_colors[levels[i]], linewidth=3)

# Transition markers
transitions = [(0, 1, 1), (2, 3, 2), (5, 6, 3)]
for x1, x2, new_level in transitions:
    ax1.annotate('', xy=(x2, new_level), xytext=(x1, new_level - 1),
                arrowprops=dict(arrowstyle='->', color='black', lw=2))

# Labels
for i, name in enumerate(level_names):
    positions = [k for k in crossings if cog_level(k) == i]
    if positions:
        mid = (min(positions) + max(positions)) / 2
        ax1.text(mid, i + 0.15, name, ha='center', va='bottom',
                fontsize=11, fontweight='bold', color=level_colors[i])

ax1.set_xlabel('Crossing Number', fontsize=12)
ax1.set_ylabel('Cognitive Level Rank', fontsize=12)
ax1.set_title('Cognitive Hierarchy is Monotone\n(Proved: a ≤ b → rank(a) ≤ rank(b))',
             fontsize=13, fontweight='bold')
ax1.set_yticks([0, 1, 2, 3])
ax1.set_yticklabels(level_names)
ax1.grid(True, alpha=0.3, axis='x')
ax1.set_xlim(-0.5, 14.5)
ax1.set_ylim(-0.3, 3.8)

# ─── Right: Writhe Parity Theorem ────────────────────────────

ax2_data = []
for k in range(0, 11):
    feasible = [w for w in range(-k, k + 1) if (w - k) % 2 == 0]
    infeasible = [w for w in range(-k, k + 1) if (w - k) % 2 != 0]
    for w in feasible:
        ax2.scatter(k, w, s=60, c='#2ecc71', alpha=0.7, edgecolors='white', linewidth=0.5)
    for w in infeasible:
        ax2.scatter(k, w, s=20, c='#e74c3c', alpha=0.3, marker='x')

# Boundary
k_range = np.arange(0, 11)
ax2.plot(k_range, k_range, 'k--', alpha=0.4, linewidth=1)
ax2.plot(k_range, -k_range, 'k--', alpha=0.4, linewidth=1)

# Legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2ecc71', markersize=10,
           label='Feasible (writhe ≡ crossings mod 2)'),
    Line2D([0], [0], marker='x', color='#e74c3c', markersize=8,
           label='Infeasible (parity violation)'),
]
ax2.legend(handles=legend_elements, fontsize=9, loc='upper left')

ax2.set_xlabel('Crossing Number k', fontsize=12)
ax2.set_ylabel('Writhe w', fontsize=12)
ax2.set_title('Writhe Parity Constraint\n(Proved: w ≡ k mod 2)',
             fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 10.5)

plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy.png")
