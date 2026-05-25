#!/usr/bin/env python3
"""
Visualization: Singer Cycle Orbit on the Fano Plane

Shows how a Singer cycle in GL_3(F_2) acts on the projective plane PG(2,2),
the Fano plane. The orbit visits all 7 points, confirming no proper
projective subspace is preserved.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

from algorithms import mod_matrix_vec

# Singer cycle for GL_3(F_2): companion of x^3 + x + 1
A = [[0, 0, 1],
     [1, 0, 1],
     [0, 1, 0]]

# Generate orbit
v = [1, 0, 0]
orbit = []
current = v[:]
for _ in range(7):
    orbit.append(current[:])
    current = mod_matrix_vec(A, current, 2)

# Fano plane layout (7 points in a symmetric arrangement)
# Classic Fano plane: 6 points on circle + 1 center
angles = np.linspace(0, 2*np.pi, 7, endpoint=False)
positions = {
    (1,0,0): (0, 1.5),      # top
    (0,1,0): (-1.3, -0.75), # bottom-left  
    (0,0,1): (1.3, -0.75),  # bottom-right
    (1,1,0): (-0.65, 0.375),  # mid-left
    (0,1,1): (0, -0.75),    # bottom-center
    (1,1,1): (0.65, 0.375),   # mid-right
    (1,0,1): (0, 0.15),      # center
}

# Fano plane lines (each line has 3 points)
lines = [
    [(1,0,0), (0,1,0), (1,1,0)],
    [(1,0,0), (0,0,1), (1,0,1)],
    [(1,0,0), (1,1,1), (0,1,1)],
    [(0,1,0), (0,0,1), (0,1,1)],
    [(0,1,0), (1,1,1), (1,0,1)],
    [(0,0,1), (1,1,0), (1,1,1)],
    [(1,1,0), (0,1,1), (1,0,1)],
]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Fano plane with orbit path
ax1.set_aspect('equal')
ax1.set_title('Singer Cycle Orbit on the Fano Plane PG(2,2)', fontsize=14, fontweight='bold')

# Draw lines
for line in lines:
    pts = [positions[tuple(p)] for p in line]
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    ax1.plot(xs + [xs[0]], ys + [ys[0]], 'lightgray', linewidth=1.5, zorder=1)

# Draw inscribed circle (for the line through midpoints)
theta = np.linspace(0, 2*np.pi, 100)
cx, cy = positions[(1,0,1)]
# Draw orbit path
orbit_keys = [tuple(v) for v in orbit]
for i in range(len(orbit_keys)):
    p1 = positions[orbit_keys[i]]
    p2 = positions[orbit_keys[(i+1) % len(orbit_keys)]]
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    ax1.annotate('', xy=p2, xytext=p1,
                arrowprops=dict(arrowstyle='->', color=plt.cm.viridis(i/7),
                              lw=2.5, connectionstyle='arc3,rad=0.2'),
                zorder=2)

# Draw points
for pt, pos in positions.items():
    idx = orbit_keys.index(pt) if pt in orbit_keys else -1
    color = plt.cm.viridis(idx / 7) if idx >= 0 else 'gray'
    ax1.plot(pos[0], pos[1], 'o', markersize=20, color=color, 
             markeredgecolor='black', markeredgewidth=2, zorder=3)
    ax1.text(pos[0], pos[1], str(idx), ha='center', va='center', 
             fontsize=11, fontweight='bold', color='white', zorder=4)
    label = f"{''.join(map(str,pt))}"
    ax1.text(pos[0], pos[1] - 0.3, label, ha='center', va='top', fontsize=9)

ax1.set_xlim(-2, 2)
ax1.set_ylim(-1.5, 2.2)
ax1.axis('off')
ax1.text(0, -1.4, 'Numbers show orbit order (0→1→2→...→6→0)', 
         ha='center', fontsize=10, style='italic')

# Right: orbit vectors as a matrix
ax2.set_title('Orbit Vectors (Generator Matrix)', fontsize=14, fontweight='bold')
ax2.axis('off')

# Create table
cell_text = []
for i, v in enumerate(orbit):
    cell_text.append([f'A^{i}·e₁'] + [str(x) for x in v])

table = ax2.table(cellText=cell_text,
                  colLabels=['Vector', 'x₁', 'x₂', 'x₃'],
                  cellLoc='center',
                  loc='center')
table.auto_set_font_size(False)
table.set_fontsize(12)
table.scale(1.2, 1.8)

# Color the cells
for i in range(len(orbit)):
    color = plt.cm.viridis(i / 7)
    table[(i+1, 0)].set_facecolor((*color[:3], 0.3))
    for j in range(3):
        if orbit[i][j] == 1:
            table[(i+1, j+1)].set_facecolor('#E8F5E9')

ax2.text(0.5, 0.05, 'All 7 nonzero vectors of F₂³ appear in the orbit\n'
         '→ Orbit spans entire space (Theorem 2)',
         ha='center', va='center', transform=ax2.transAxes,
         fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('orbit_fano_plane.png', dpi=150, bbox_inches='tight')
print("Saved orbit_fano_plane.png")
