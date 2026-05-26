#!/usr/bin/env python3
"""
Visualization: Exceptional Spectral Atlas Heatmap

Visualizes the local character-ratio bounds as a heatmap across
torus types (rows) and field sizes (columns) for each exceptional type.
This is a preview of the Exceptional Spectral Atlas.

SELF-CONTAINED: All functions are inlined. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

# ─── Generate atlas data ────────────────────────────────────────────────────

def generate_atlas_data(num_types, rank, q_values, seed=42):
    """Generate a synthetic local-bound matrix: rows=torus types, cols=q values."""
    rng = random.Random(seed)
    C_t = [rng.uniform(0.3, rank * 0.7) for _ in range(num_types)]
    matrix = np.zeros((num_types, len(q_values)))
    for j, q in enumerate(q_values):
        for i in range(num_types):
            matrix[i, j] = C_t[i] / q
    return matrix

q_values = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 19, 23, 25, 27, 31]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

types_data = [
    ("F₄", 25, 4, "#2196F3"),
    ("E₆", 25, 6, "#4CAF50"),
    ("E₇", 60, 7, "#FF9800"),
    ("E₈", 112, 8, "#F44336"),
]

for idx, (name, n_types, rank, color) in enumerate(types_data):
    ax = axes[idx // 2][idx % 2]

    # For visualization, show only first 30 torus types for readability
    show_types = min(n_types, 30)
    matrix = generate_atlas_data(n_types, rank, q_values, seed=42+idx)[:show_types]

    im = ax.imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                   vmin=0, vmax=np.max(matrix))

    ax.set_xlabel("Field size q", fontsize=11)
    ax.set_ylabel("Torus type index", fontsize=11)
    ax.set_title(f"{name} — Local Bounds Atlas\n({n_types} torus types, showing {show_types})",
                 fontsize=12, fontweight='bold')

    # Set tick labels
    ax.set_xticks(range(0, len(q_values), 2))
    ax.set_xticklabels([str(q_values[i]) for i in range(0, len(q_values), 2)], fontsize=9)

    if show_types <= 30:
        ax.set_yticks(range(0, show_types, max(1, show_types // 10)))

    plt.colorbar(im, ax=ax, label='Local bound', shrink=0.8)

    # Mark the global bound (worst row) for each q
    for j in range(len(q_values)):
        worst_type = np.argmax(matrix[:, j])
        ax.plot(j, worst_type, 'k*', markersize=8, alpha=0.7)

plt.suptitle("Exceptional Spectral Atlas\n(★ marks the maximizing torus type for each q)",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("spectral_atlas_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: spectral_atlas_visualization.png")
