"""
Visualization: Graph Laplacian Structure and Chip-Firing Dynamics

Shows:
1. (Left) Heatmap of the Laplacian matrix of K₆
2. (Right) Chip-firing evolution on a cycle graph

This visualizes the key algebraic structure underlying the universality
phenomenon: the Laplacian governs both chip-firing dynamics (tropical
geometry) and the critical group (number theory).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


# === Self-contained helper functions ===

def _laplacian(adj):
    return np.diag(adj.sum(axis=1).astype(int)) - adj.astype(int)

def _make_complete(n):
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)

def _make_cycle(n):
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        A[i][(i+1) % n] = 1
        A[(i+1) % n][i] = 1
    return A


# === Create figure ===
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Panel 1: Laplacian heatmap of K₆
ax1 = axes[0]
K6 = _make_complete(6)
L6 = _laplacian(K6)

# Custom colormap: blue for negative, white for zero, red for positive
cmap = plt.cm.RdBu_r
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=5)

im = ax1.imshow(L6, cmap=cmap, norm=norm, interpolation='nearest')
for i in range(6):
    for j in range(6):
        ax1.text(j, i, str(L6[i][j]), ha='center', va='center',
                fontsize=14, fontweight='bold',
                color='white' if abs(L6[i][j]) > 2 else 'black')

ax1.set_xticks(range(6))
ax1.set_yticks(range(6))
ax1.set_xticklabels([f'v{i}' for i in range(6)])
ax1.set_yticklabels([f'v{i}' for i in range(6)])
ax1.set_title('Laplacian of K₆\n(D - A: degree on diagonal, -1 off-diagonal)',
              fontsize=12)
plt.colorbar(im, ax=ax1, shrink=0.8)

# Panel 2: Chip-firing evolution
ax2 = axes[1]
n = 6
C6 = _make_cycle(n)
L = _laplacian(C6)

# Initial configuration
config = np.array([5, 0, 1, 0, 2, 0])
configs = [config.copy()]

# Fire vertices that are over-full (degree = 2 for cycle)
for step in range(8):
    new_config = config.copy()
    fired = False
    for v in range(n):
        if config[v] >= C6[v].sum():  # vertex v can fire
            new_config = new_config - L[v]
            fired = True
            break
    if not fired:
        break
    config = new_config
    configs.append(config.copy())

configs = np.array(configs)
num_steps = len(configs)

# Plot as a heatmap of chip counts over time
im2 = ax2.imshow(configs.T, aspect='auto', cmap='YlOrRd',
                  interpolation='nearest', vmin=0)
for i in range(n):
    for j in range(num_steps):
        ax2.text(j, i, str(configs[j][i]), ha='center', va='center',
                fontsize=11, fontweight='bold',
                color='white' if configs[j][i] > 3 else 'black')

ax2.set_xlabel('Time step', fontsize=12)
ax2.set_ylabel('Vertex', fontsize=12)
ax2.set_yticks(range(n))
ax2.set_yticklabels([f'v{i}' for i in range(n)])
ax2.set_xticks(range(num_steps))
ax2.set_title('Chip-Firing on C₆\n(fire over-full vertices until stable)',
              fontsize=12)
plt.colorbar(im2, ax=ax2, shrink=0.8, label='# chips')

plt.tight_layout()
plt.savefig('laplacian_chipfiring.png', dpi=150, bbox_inches='tight')
print("Saved laplacian_chipfiring.png")
