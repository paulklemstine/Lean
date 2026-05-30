"""
Visualization: Toric Code on a Torus

Shows the structure of the toric code:
- The L×L lattice with periodic boundary conditions
- Vertex operators (X-stabilizers) and plaquette operators (Z-stabilizers)
- Winding cycles that represent logical operators
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))
fig.suptitle('Toric Code: Lattice, Stabilizers, and Logical Operators', 
             fontsize=14, fontweight='bold')

L = 4  # System size

# Panel 1: The lattice
ax1 = axes[0]
ax1.set_title(f'{L}×{L} Toric Code Lattice', fontsize=12)

# Draw edges (qubits)
for i in range(L):
    for j in range(L):
        # Horizontal edges
        ax1.plot([j, j+1], [i, i], 'b-', linewidth=1.5, alpha=0.7)
        # Vertical edges
        ax1.plot([j, j], [i, i+1], 'b-', linewidth=1.5, alpha=0.7)

# Draw vertices
for i in range(L+1):
    for j in range(L+1):
        ax1.plot(j % L + (1 if j == L else 0) * 0, 
                i % L + (1 if i == L else 0) * 0, 
                'ko', markersize=6)

# Show periodic boundary
for i in range(L):
    ax1.annotate('', xy=(L+0.3, i), xytext=(L+0.1, i),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax1.annotate('', xy=(i, L+0.3), xytext=(i, L+0.1),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

ax1.set_xlim(-0.5, L + 0.8)
ax1.set_ylim(-0.5, L + 0.8)
ax1.set_aspect('equal')
ax1.text(L + 0.5, L/2, '≡', fontsize=16, ha='center', va='center', color='red')
ax1.text(L/2, L + 0.5, '≡', fontsize=16, ha='center', va='center', color='red')

# Count resources
n_qubits = 2 * L**2
n_vertices = L**2
n_faces = L**2
ax1.text(0.5, -0.3, f'n={n_qubits} qubits, {n_vertices} vertices, {n_faces} faces',
         transform=ax1.transAxes, ha='center', fontsize=9,
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax1.set_xlabel('Column', fontsize=10)
ax1.set_ylabel('Row', fontsize=10)

# Panel 2: Stabilizers
ax2 = axes[1]
ax2.set_title('Stabilizer Operators', fontsize=12)

# Draw base lattice (light)
for i in range(L):
    for j in range(L):
        ax2.plot([j, j+1], [i, i], 'b-', linewidth=0.5, alpha=0.2)
        ax2.plot([j, j], [i, i+1], 'b-', linewidth=0.5, alpha=0.2)

# Highlight vertex operator at (1,1)
v_i, v_j = 1, 1
star_edges = [
    ([v_j, v_j+1], [v_i, v_i]),  # right
    ([v_j-1, v_j], [v_i, v_i]),  # left
    ([v_j, v_j], [v_i, v_i+1]),  # up
    ([v_j, v_j], [v_i-1, v_i]),  # down
]
for xs, ys in star_edges:
    ax2.plot(xs, ys, 'r-', linewidth=4, alpha=0.7)
ax2.plot(v_j, v_i, 'r*', markersize=15, label='Vertex op (X-type)')

# Highlight plaquette operator at (2,2)
p_i, p_j = 2, 2
plaq_edges = [
    ([p_j, p_j+1], [p_i, p_i]),     # bottom
    ([p_j, p_j+1], [p_i+1, p_i+1]), # top
    ([p_j, p_j], [p_i, p_i+1]),     # left
    ([p_j+1, p_j+1], [p_i, p_i+1]), # right
]
for xs, ys in plaq_edges:
    ax2.plot(xs, ys, 'g-', linewidth=4, alpha=0.7)
rect = patches.Rectangle((p_j+0.1, p_i+0.1), 0.8, 0.8, 
                          linewidth=0, facecolor='green', alpha=0.15)
ax2.add_patch(rect)
ax2.text(p_j+0.5, p_i+0.5, 'B_p', fontsize=11, ha='center', va='center',
         color='darkgreen', fontweight='bold')
ax2.text(v_j+0.15, v_i+0.15, 'A_v', fontsize=11, ha='left', va='bottom',
         color='darkred', fontweight='bold')

ax2.set_xlim(-0.5, L + 0.5)
ax2.set_ylim(-0.5, L + 0.5)
ax2.set_aspect('equal')
ax2.legend(loc='upper right', fontsize=8)
ax2.set_xlabel('Column', fontsize=10)
ax2.set_ylabel('Row', fontsize=10)

# Panel 3: Logical operators (winding cycles)
ax3 = axes[2]
ax3.set_title('Logical Operators (Winding Cycles)', fontsize=12)

# Draw base lattice (light)
for i in range(L):
    for j in range(L):
        ax3.plot([j, j+1], [i, i], 'b-', linewidth=0.5, alpha=0.2)
        ax3.plot([j, j], [i, i+1], 'b-', linewidth=0.5, alpha=0.2)

# Horizontal winding cycle at row 1
row = 1
for j in range(L):
    ax3.plot([j, j+1], [row, row], 'r-', linewidth=4, alpha=0.8)
ax3.annotate('', xy=(L+0.2, row), xytext=(L, row),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax3.text(L/2, row - 0.3, f'Horizontal cycle\n(weight = L = {L})',
         ha='center', fontsize=9, color='red')

# Vertical winding cycle at column 2
col = 2
for i in range(L):
    ax3.plot([col, col], [i, i+1], 'g-', linewidth=4, alpha=0.8)
ax3.annotate('', xy=(col, L+0.2), xytext=(col, L),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax3.text(col + 0.3, L/2, f'Vertical\ncycle\n(wt={L})',
         ha='left', fontsize=9, color='green')

ax3.set_xlim(-0.5, L + 0.8)
ax3.set_ylim(-0.5, L + 0.8)
ax3.set_aspect('equal')

# Code parameters box
params_text = f'[[n,k,d]] = [[{n_qubits}, 2, {L}]]\nCorrects {(L-1)//2} errors'
ax3.text(0.02, 0.98, params_text, transform=ax3.transAxes, fontsize=9,
         verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax3.set_xlabel('Column', fontsize=10)
ax3.set_ylabel('Row', fontsize=10)

plt.tight_layout()
plt.savefig('toric_code_torus.png', dpi=150, bbox_inches='tight')
plt.close()
