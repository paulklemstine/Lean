"""
Visualization 2: Filtration Structure of the Arithmetic Simplicial Complex

Visualizes the hierarchical structure of ASC(X, p) showing how simplices
at different filtration levels capture increasingly fine arithmetic information.

This script produces a heatmap showing simplex counts by dimension and
filtration level, alongside a schematic of the ASC construction.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Simulated simplex counts by (dimension, filtration level) for p = 7
# Rows: simplex dimension (0=vertices, 1=edges, 2=triangles, 3=tetrahedra)
# Columns: filtration level (codimension 0, 1, 2, 3, 4)
simplex_counts = {
    7: np.array([
        [0, 0, 0, 0, 400],    # dim 0: vertices all at max codim
        [0, 0, 50, 200, 800],  # dim 1: edges
        [0, 10, 80, 300, 500],  # dim 2: triangles
        [5, 30, 100, 200, 300],  # dim 3: tetrahedra
    ]),
    11: np.array([
        [0, 0, 0, 0, 1600],
        [0, 0, 200, 800, 3200],
        [0, 40, 320, 1200, 2000],
        [20, 120, 400, 800, 1200],
    ]),
    13: np.array([
        [0, 0, 0, 0, 2800],
        [0, 0, 350, 1400, 5600],
        [0, 70, 560, 2100, 3500],
        [35, 210, 700, 1400, 2100],
    ]),
}

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Filtration Structure of ASC(X, p) for the Fermat Quintic',
             fontsize=16, fontweight='bold')

primes_to_show = [7, 11, 13]
dim_labels = ['Vertices\n(dim 0)', 'Edges\n(dim 1)', 'Triangles\n(dim 2)', 'Tetrahedra\n(dim 3)']
filt_labels = ['codim 0', 'codim 1', 'codim 2', 'codim 3', 'codim 4']

for idx, p in enumerate(primes_to_show):
    ax = axes[idx]
    data = simplex_counts[p]

    # Normalize by row for visualization
    row_sums = data.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1
    normalized = data / row_sums

    im = ax.imshow(normalized, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)

    # Add text annotations with actual counts
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            val = data[i, j]
            color = 'white' if normalized[i, j] > 0.5 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=9, color=color, fontweight='bold')

    ax.set_xticks(range(5))
    ax.set_xticklabels(filt_labels, fontsize=9, rotation=30, ha='right')
    ax.set_yticks(range(4))
    ax.set_yticklabels(dim_labels, fontsize=10)
    ax.set_title(f'p = {p}\n(~{p**3+p**2+p+1} points)', fontsize=13)

# Colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
cbar = fig.colorbar(im, cax=cbar_ax)
cbar.set_label('Fraction of simplices at each filtration level', fontsize=11)

plt.tight_layout(rect=[0, 0, 0.9, 0.93])
plt.savefig('viz_filtration_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration_structure.png")
