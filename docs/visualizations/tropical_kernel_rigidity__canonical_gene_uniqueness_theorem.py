"""
Visualization: The Uniqueness Theorem in Action

Shows the main result: under pairwise disjoint supports,
the canonical generators are unique up to permutation.
Illustrates the proof mechanism.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# ── Panel 1: Support Matching ──
ax = axes[0]
ax.set_title("Step 1: Support Matching\n(Injectivity from Disjointness)", fontsize=12, fontweight='bold')

# Draw two columns of "generators" with support sets
left_x, right_x = 1, 4
y_positions = [3, 2, 1]

# Left column: F generators
labels_F = ['F₁', 'F₂', 'F₃']
supports_F = ['{0,1}', '{2,3}', '{4,5}']
colors = ['#2196F3', '#FF5722', '#4CAF50']

# Right column: G generators (permuted)
labels_G = ['G₁', 'G₂', 'G₃']
supports_G = ['{2,3}', '{4,5}', '{0,1}']
perm = [2, 0, 1]  # G[perm[i]] matches F[i]

for i in range(3):
    # Left boxes
    rect = patches.FancyBboxPatch((left_x - 0.5, y_positions[i] - 0.3), 1.5, 0.6,
                                   boxstyle="round,pad=0.1", facecolor=colors[i], alpha=0.3)
    ax.add_patch(rect)
    ax.text(left_x + 0.25, y_positions[i], f'{labels_F[i]}\nsupport={supports_F[i]}',
            ha='center', va='center', fontsize=9, fontweight='bold')

    # Right boxes
    j = perm[i]
    rect2 = patches.FancyBboxPatch((right_x - 0.5, y_positions[i] - 0.3), 1.5, 0.6,
                                    boxstyle="round,pad=0.1", facecolor=colors[j], alpha=0.3)
    ax.add_patch(rect2)
    ax.text(right_x + 0.25, y_positions[i], f'{labels_G[i]}\nsupport={supports_G[i]}',
            ha='center', va='center', fontsize=9, fontweight='bold')

    # Matching arrows
    ax.annotate('', xy=(right_x - 0.55, y_positions[i]),
                xytext=(left_x + 0.8, y_positions[perm.index(i)]),
                arrowprops=dict(arrowstyle='->', color=colors[i],
                               lw=2, connectionstyle='arc3,rad=0.2'))

ax.text(2.625, 3.7, 'σ: support matching', fontsize=11, ha='center',
        fontweight='bold', style='italic')
ax.text(2.625, 0.2, 'σ injective ⟸ disjoint supports\nσ bijective ⟸ finite type',
        fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax.set_xlim(0, 5.5)
ax.set_ylim(-0.3, 4.2)
ax.axis('off')

# ── Panel 2: Value Agreement ──
ax = axes[1]
ax.set_title("Step 2: Value Agreement\n(Off-support zeroes force equality)", fontsize=12, fontweight='bold')

vertices = np.arange(6)
f1 = np.array([3, -2, 0, 0, 0, 0])
g3 = np.array([3, -2, 0, 0, 0, 0])  # G[σ(1)] should equal F[1]

width = 0.35
ax.bar(vertices - width/2, f1, width, color='#2196F3', alpha=0.7, label='F₁')
ax.bar(vertices + width/2, g3, width, color='#4CAF50', alpha=0.7, label='G[σ(1)] = G₃')

# Highlight support region
rect = patches.FancyBboxPatch((-0.5, -2.8), 2, 0.3,
                               boxstyle="round,pad=0.05", facecolor='#2196F3', alpha=0.2)
ax.add_patch(rect)
ax.text(0.5, -2.65, 'support', fontsize=8, ha='center', color='#2196F3')

# Highlight off-support region
rect2 = patches.FancyBboxPatch((1.7, -2.8), 4, 0.3,
                                boxstyle="round,pad=0.05", facecolor='gray', alpha=0.1)
ax.add_patch(rect2)
ax.text(3.5, -2.65, 'off-support (both = 0)', fontsize=8, ha='center', color='gray')

ax.set_xlabel("Vertex index")
ax.set_ylabel("Value")
ax.legend(fontsize=9)
ax.set_xticks(vertices)
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax.set_ylim(-3.2, 4)

# Add "= " markers
for v in range(6):
    if f1[v] == g3[v]:
        ax.text(v, max(f1[v], 0) + 0.3, '=', fontsize=14, ha='center',
                color='green', fontweight='bold')

# ── Panel 3: The Complete Picture ──
ax = axes[2]
ax.set_title("Result: Tropical Projective Equivalence\nG(σ(i)) = F(i) for all i, v", fontsize=12, fontweight='bold')

# Show the theorem statement visually
theorem_text = (
    "Given:\n"
    "  • F, G with disjoint supports\n"
    "  • Same support decomposition\n"
    "  • Agreement on matched supports\n"
    "\n"
    "Then: ∃ permutation σ s.t.\n"
    "  G(σ(i))(v) = F(i)(v)  ∀ i, v\n"
    "\n"
    "i.e., TropProjEquiv(F, G)\n"
    "     with constants c = 0"
)

ax.text(0.5, 0.5, theorem_text, transform=ax.transAxes,
        fontsize=12, ha='center', va='center',
        fontfamily='monospace',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#E3F2FD', alpha=0.9))

# Draw a checkmark
ax.text(0.5, 0.02, '✓ Machine-verified in Lean 4', transform=ax.transAxes,
        fontsize=11, ha='center', color='green', fontweight='bold')

ax.axis('off')

plt.tight_layout()
plt.savefig('viz_uniqueness_theorem.png', dpi=150, bbox_inches='tight')
print("Saved viz_uniqueness_theorem.png")
