"""
Visualization: Support Separation and Tropical Kernel Rigidity

Illustrates the core mathematical concept: when function families have
pairwise disjoint supports, their values on each support region are
independent, leading to uniqueness of generators up to permutation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Functions with disjoint supports
ax = axes[0]
ax.set_title("Disjoint Support Generators", fontsize=13, fontweight='bold')
x = np.arange(12)

# Three generators with disjoint supports
f1 = np.array([3, -2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])
f2 = np.array([0, 0, 0, 0, 2, -1, 3, 0, 0, 0, 0, 0])
f3 = np.array([0, 0, 0, 0, 0, 0, 0, 0, -1, 4, -2, 1])

colors = ['#2196F3', '#FF5722', '#4CAF50']
labels = ['Generator 1', 'Generator 2', 'Generator 3']

for i, (f, c, l) in enumerate(zip([f1, f2, f3], colors, labels)):
    bars = ax.bar(x + i * 0.25 - 0.25, f, width=0.25, color=c, alpha=0.8, label=l)

# Highlight support regions
for region, color in [((0, 3), '#2196F3'), ((4, 7), '#FF5722'), ((8, 12), '#4CAF50')]:
    rect = patches.FancyBboxPatch((region[0] - 0.4, -3), region[1] - region[0] - 0.2, 0.3,
                                   boxstyle="round,pad=0.05", facecolor=color, alpha=0.15)
    ax.add_patch(rect)

ax.set_xlabel("Vertex index")
ax.set_ylabel("Function value")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax.set_ylim(-3.5, 5.5)

# Panel 2: Why min-plus combination is constant on each support
ax = axes[1]
ax.set_title("Tropical Combination = Constant\non Each Support Region", fontsize=13, fontweight='bold')

# On support of f1, f2=f3=0, so min(f1+c1, f2+c2, f3+c3) = min(f1+c1, c2, c3)
# If c2, c3 > max(f1)+c1, then min = f1+c1 (determined by f1 alone)
c1, c2, c3 = 0, 5, 7

trop_comb = np.minimum(np.minimum(f1 + c1, f2 + c2), f3 + c3)

ax.bar(x, trop_comb, color='purple', alpha=0.7, label=f'min(F₁+{c1}, F₂+{c2}, F₃+{c3})')

# Show that on each support, value is determined by one generator
for region, gen_name, color in [((0, 3), 'F₁', '#2196F3'),
                                  ((4, 7), 'F₂', '#FF5722'),
                                  ((8, 12), 'F₃', '#4CAF50')]:
    mid = (region[0] + region[1]) / 2
    ax.annotate(f'Determined\nby {gen_name}', xy=(mid, -2.5), fontsize=9,
                ha='center', color=color, fontweight='bold')

ax.set_xlabel("Vertex index")
ax.set_ylabel("Tropical combination value")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

# Panel 3: Uniqueness — any alternative must match
ax = axes[2]
ax.set_title("Uniqueness: Alternative Family\nMust Be a Permutation", fontsize=13, fontweight='bold')

# Alternative family (just permuted)
g1 = f2.copy()  # = f2
g2 = f3.copy()  # = f3
g3 = f1.copy()  # = f1

width = 0.35
bars1 = ax.bar(x - width/2, f1 + f2 + f3, width, color='#2196F3', alpha=0.5, label='Original F')
bars2 = ax.bar(x + width/2, g1 + g2 + g3, width, color='#FF5722', alpha=0.5, label='Alternative G (permuted)')

# Mark that they're the same
for i in range(12):
    if (f1 + f2 + f3)[i] == (g1 + g2 + g3)[i] and (f1 + f2 + f3)[i] != 0:
        ax.plot(i, (f1 + f2 + f3)[i] + 0.3, 'g*', markersize=8)

ax.set_xlabel("Vertex index")
ax.set_ylabel("Sum of generators")
ax.legend(fontsize=9)
ax.set_xticks(x)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

# Add annotation
ax.text(6, 4.5, 'G = σ(F) for some\npermutation σ',
        fontsize=11, ha='center', style='italic',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_support_separation.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_separation.png")
