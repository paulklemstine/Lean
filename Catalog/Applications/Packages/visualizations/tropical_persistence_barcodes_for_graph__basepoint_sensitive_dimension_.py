"""
Visualization: Tropical Kernel Dimension Landscape

This script creates a heatmap showing how the tropical kernel dimension
varies across different basepoint choices and filtration stages for a
fixed graph. It reveals the basepoint-sensitivity of the tropical
persistence barcode.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (
    Graph, tropical_kernel_dim, induced_cycle_rank,
    q_visible_component_count
)

# Build a moderately interesting graph
# Petersen-like: 8 vertices with mixed connectivity
V = set(range(8))
E = {
    (0, 1), (1, 2), (2, 3), (3, 0),  # outer square
    (4, 5), (5, 6), (6, 7), (7, 4),  # inner square
    (0, 4), (1, 5), (2, 6), (3, 7),  # connecting spokes
}
G = Graph(V, E)

# For each basepoint q, compute dimension sequence along canonical filtration
n = len(V)
basepoints = list(range(n))

# Use a canonical filtration that adds vertices 0,1,...,n-1 (excluding q)
dim_matrix = np.zeros((n, n), dtype=int)  # basepoint x filtration_step
cr_matrix = np.zeros((n, n), dtype=int)
qv_matrix = np.zeros((n, n), dtype=int)

for qi, q in enumerate(basepoints):
    available = sorted(V - {q})
    filt = [set()]
    for v in available:
        filt.append(filt[-1] | {v})

    for step, S in enumerate(filt):
        if step < n:
            dim_matrix[qi, step] = tropical_kernel_dim(G, q, S)
            cr_matrix[qi, step] = induced_cycle_rank(G, S)
            qv_matrix[qi, step] = q_visible_component_count(G, q, S)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Tropical kernel dimension
im0 = axes[0].imshow(dim_matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
axes[0].set_title('Tropical Kernel Dimension δ(S)', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Filtration Step')
axes[0].set_ylabel('Basepoint q')
axes[0].set_yticks(range(n))
plt.colorbar(im0, ax=axes[0], label='δ')

# Cycle rank component
im1 = axes[1].imshow(cr_matrix, cmap='Blues', aspect='auto', interpolation='nearest')
axes[1].set_title('Cycle Rank β₁(G[S])', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Filtration Step')
axes[1].set_ylabel('Basepoint q')
axes[1].set_yticks(range(n))
plt.colorbar(im1, ax=axes[1], label='β₁')

# q-Visible component count
im2 = axes[2].imshow(qv_matrix, cmap='Greens', aspect='auto', interpolation='nearest')
axes[2].set_title('q-Visible Components κ_q(S)', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Filtration Step')
axes[2].set_ylabel('Basepoint q')
axes[2].set_yticks(range(n))
plt.colorbar(im2, ax=axes[2], label='κ_q')

fig.suptitle('Basepoint-Sensitive Tropical Persistence Landscape\n'
             '(Cube Graph: 8 vertices, 12 edges)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_dimension_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_dimension_landscape.png")
