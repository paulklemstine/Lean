"""
Visualization: The Comedy Polytope
====================================
Visualizes the set of achievable (tension, surprise, arc) triples
as defined by the triangle inequality constraints. The comedy polytope
is a convex cone in R³ — this script shows its cross-section at arc=1,
which is a triangle in the (tension, surprise) plane.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Polygon

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: 2D cross-section at arc = 1 ---
ax = axes[0]
ax.set_title("Comedy Polytope Cross-Section (arc = 1)", fontsize=13, fontweight='bold')

# The constraints for arc c = 1:
# a + b >= 1, a + 1 >= b, b + 1 >= a
# and a, b >= 0
# This gives: a >= 0, b >= 0, a + b >= 1, b <= a + 1, a <= b + 1

# Plot the feasible region
resolution = 500
a_vals = np.linspace(0, 2, resolution)
b_vals = np.linspace(0, 2, resolution)
A, B = np.meshgrid(a_vals, b_vals)

# Constraints
mask = (A >= 0) & (B >= 0) & (A + B >= 1) & (B <= A + 1) & (A <= B + 1)

ax.contourf(A, B, mask.astype(float), levels=[0.5, 1.5], 
            colors=['#3498db'], alpha=0.3)
ax.contour(A, B, mask.astype(float), levels=[0.5], 
           colors=['#2c3e50'], linewidths=2)

# Mark key points
# Vertices of the polytope cross-section
vertices = [(0, 1), (1, 0), (1, 2), (2, 1)]
for v in vertices:
    ax.plot(*v, 'ko', markersize=6)
    ax.annotate(f'({v[0]},{v[1]})', v, textcoords="offset points", 
                xytext=(8, 8), fontsize=9)

# Mark special triples
special = [
    ((0.5, 0.5), "Degenerate\n(collinear)", '#e74c3c'),
    ((1, 1), "Equilateral-like", '#27ae60'),
    ((0.3, 0.8), "High surprise\nefficiency", '#8e44ad'),
]
for pt, label, color in special:
    ax.plot(*pt, 'o', color=color, markersize=10, zorder=5)
    ax.annotate(label, pt, textcoords="offset points",
                xytext=(10, -15), fontsize=8, color=color, fontweight='bold')

ax.set_xlabel("Tension (setup → expectation)", fontsize=11)
ax.set_ylabel("Surprise (expectation → punchline)", fontsize=11)
ax.set_xlim(-0.1, 2.2)
ax.set_ylim(-0.1, 2.2)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Add constraint labels
ax.text(0.15, 0.15, 'a + b < 1\n(excluded)', fontsize=9, 
        color='#e74c3c', style='italic', ha='center')

# --- Right panel: Defect heatmap ---
ax2 = axes[1]
ax2.set_title("Triangle Defect Heatmap (arc = 1)", fontsize=13, fontweight='bold')

defect = np.where(mask, A + B - 1, np.nan)
im = ax2.pcolormesh(A, B, defect, cmap='YlOrRd', shading='auto')
cbar = plt.colorbar(im, ax=ax2, label='Defect = tension + surprise − arc')

# Zero-defect line (where a + b = 1)
a_line = np.linspace(0, 1, 100)
ax2.plot(a_line, 1 - a_line, 'w--', linewidth=2, label='Defect = 0\n(geodesic jokes)')
ax2.legend(loc='upper right', fontsize=9)

ax2.set_xlabel("Tension", fontsize=11)
ax2.set_ylabel("Surprise", fontsize=11)
ax2.set_xlim(0, 2)
ax2.set_ylim(0, 2)
ax2.set_aspect('equal')

plt.suptitle("The Comedy Polytope: Geometry of Achievable Humor",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("comedy_polytope.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: comedy_polytope.png")
