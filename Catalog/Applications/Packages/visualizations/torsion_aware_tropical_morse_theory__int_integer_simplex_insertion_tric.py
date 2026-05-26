"""
Visualization: The Integer Simplex Insertion Trichotomy

Visualizes the three cases of the simplex insertion trichotomy over ℤ
using a lattice diagram showing how the boundary vector relates to
the existing boundary submodule.

The three cases:
1. BIRTH_FREE: ∂σ ∈ B (vector is in the span)
2. KILL_FREE: ∂σ primitive mod B (vector extends the lattice rank)
3. CHANGE_TORSION: ∂σ ∈ Sat(B) \ B (vector in saturation but not span)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

def draw_lattice_case(ax, case_num, title, subtitle):
    """Draw a lattice diagram for one case of the trichotomy."""
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)
    ax.set_aspect('equal')
    ax.set_title(f'Case {case_num}: {title}\n{subtitle}', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.15)
    ax.set_xlabel('$e_1$', fontsize=12)
    ax.set_ylabel('$e_2$', fontsize=12)

    # Draw integer lattice points
    for i in range(6):
        for j in range(6):
            ax.plot(i, j, 'o', color='#cccccc', markersize=3, zorder=1)

# Case 1: Birth Free — ∂σ ∈ B
ax = axes[0]
draw_lattice_case(ax, 1, 'Free Birth', '∂σ ∈ B (redundant)')

# Draw submodule B = span{(1,0), (0,2)}
# Lattice points in B
for a in range(-2, 8):
    for b in range(-1, 4):
        x, y = a, 2*b
        if 0 <= x <= 5 and 0 <= y <= 5:
            ax.plot(x, y, 's', color='#4CAF50', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(1, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
ax.text(0.5, -0.4, 'b₁=(1,0)', ha='center', fontsize=9, color='#2E7D32')

ax.annotate('', xy=(0, 2), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
ax.text(-0.7, 1, 'b₂=(0,2)', ha='center', fontsize=9, color='#2E7D32', rotation=90)

# ∂σ = (2,0) = 2·b₁ ∈ B
ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(1, 0.4, '∂σ=(2,0)∈B', ha='center', fontsize=11, color='#E91E63', fontweight='bold')

ax.text(2.5, 4.5, 'Result:\nNew cycle in H_d\nH_{d-1} unchanged',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))

# Case 2: Kill Free — ∂σ primitive
ax = axes[1]
draw_lattice_case(ax, 2, 'Free Kill', '∂σ primitive mod B')

# B = span{(2,0)}
for a in range(-1, 4):
    x, y = 2*a, 0
    if 0 <= x <= 5:
        ax.plot(x, y, 's', color='#2196F3', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2.5))
ax.text(1, -0.4, 'b₁=(2,0)', ha='center', fontsize=9, color='#1565C0')

# ∂σ = (0,1) — primitive, not in Sat(B)
ax.annotate('', xy=(0, 1), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(0.8, 1.3, '∂σ=(0,1)\nprimitive', ha='center', fontsize=11,
        color='#E91E63', fontweight='bold')

# Show saturation = same as B (1-dimensional)
ax.fill_between([-0.5, 5.5], [-0.1, -0.1], [0.1, 0.1],
                alpha=0.1, color='#1565C0', label='Sat(B)')

ax.text(2.5, 4.5, 'Result:\nKills free class in H_{d-1}\nH_d unchanged',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#E3F2FD', alpha=0.8))

# Case 3: Torsion Change — ∂σ in Sat(B) \ B
ax = axes[2]
draw_lattice_case(ax, 3, 'Torsion Change', '∂σ ∈ Sat(B) \\ B')

# B = span{(2,0)}
for a in range(-1, 4):
    x, y = 2*a, 0
    if 0 <= x <= 5:
        ax.plot(x, y, 's', color='#FF9800', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E65100', lw=2.5))
ax.text(1, -0.4, 'b₁=(2,0)', ha='center', fontsize=9, color='#E65100')

# Saturation = span_ℚ{(2,0)} ∩ ℤ² = span{(1,0)}
for a in range(0, 6):
    ax.plot(a, 0, 'D', color='#FF9800', markersize=6, alpha=0.3, zorder=2)

# ∂σ = (1,0) — in saturation (2·(1,0) = (2,0) ∈ B) but not in B
ax.annotate('', xy=(1, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(1.8, 0.8, '∂σ=(1,0)\n2·∂σ∈B but ∂σ∉B', ha='center', fontsize=10,
        color='#E91E63', fontweight='bold')

# Show the saturation gap
ax.annotate('Saturation\ngap!', xy=(1, 0.1), xytext=(3, 2),
            fontsize=10, color='#BF360C', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#BF360C', lw=1.5))

ax.text(2.5, 4.5, 'Result:\nTorsion in H_{d-1} changes\n+ free birth in H_d',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#FFF3E0', alpha=0.8))

plt.suptitle('Integer Simplex Insertion Trichotomy: Three Arithmetic Events',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_trichotomy.png', dpi=150, bbox_inches='tight')
print("Saved viz_trichotomy.png")
