"""
Visualization: DLC Determinant Gap Surface

Plots the DLC gap w₁₀·w₀₁ - w₁₁·w₀₀ for each coordinate pair across
different weight systems. The gap is nonneg when DLC holds.

Visualizes how the 2×2 determinant inequality — the foundation of the
entire theory — varies across coordinate pairs and repulsion strengths.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def subsets_of(n):
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(w, n, i, j):
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        if i in S and j in S: w11 += ws
        elif i in S: w10 += ws
        elif j in S: w01 += ws
        else: w00 += ws
    return w11, w10, w01, w00


def repulsive_weights(n, beta):
    def adj(S):
        return sum(1 for x in S if x + 1 in S)
    return {S: np.exp(-beta * adj(S)) for S in subsets_of(n)}


def exclusion_weights(n, k):
    return {S: (1.0 if len(S) == k else 0.0) for S in subsets_of(n)}


# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

n = 6
pairs = list(combinations(range(n), 2))
pair_labels = [f'({i},{j})' for i, j in pairs]

# Panel 1: DLC gaps for repulsive system, varying β
ax = axes[0, 0]
betas = [0.5, 1.0, 2.0, 5.0]
x_pos = np.arange(len(pairs))
width = 0.18
for idx, beta in enumerate(betas):
    w = repulsive_weights(n, beta)
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        gaps.append(w10 * w01 - w11 * w00)
    ax.bar(x_pos + idx * width, gaps, width, label=f'β={beta}', alpha=0.8)

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xticks(x_pos + 1.5 * width)
ax.set_xticklabels(pair_labels, fontsize=7, rotation=45)
ax.set_ylabel('DLC gap (w₁₀w₀₁ - w₁₁w₀₀)')
ax.set_title('DLC Gaps: Repulsive System (varying β)', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2, axis='y')

# Panel 2: DLC gaps for exclusion process, varying k
ax = axes[0, 1]
ks = [1, 2, 3, 4, 5]
for idx, k in enumerate(ks):
    w = exclusion_weights(n, k)
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        gaps.append(w10 * w01 - w11 * w00)
    ax.bar(x_pos + idx * width, gaps, width, label=f'k={k}', alpha=0.8)

ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax.set_xticks(x_pos + 2 * width)
ax.set_xticklabels(pair_labels, fontsize=7, rotation=45)
ax.set_ylabel('DLC gap')
ax.set_title('DLC Gaps: Exclusion Process (varying k)', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2, axis='y')

# Panel 3: Negative correlations heatmap
ax = axes[1, 0]
beta = 2.0
w = repulsive_weights(n, beta)
Z = sum(w.values())
corr_mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i == j:
            pi = sum(ws for S, ws in w.items() if i in S) / Z
            corr_mat[i, j] = pi * (1 - pi)
        else:
            pi = sum(ws for S, ws in w.items() if i in S) / Z
            pj = sum(ws for S, ws in w.items() if j in S) / Z
            pij = sum(ws for S, ws in w.items() if i in S and j in S) / Z
            corr_mat[i, j] = pij - pi * pj

im = ax.imshow(corr_mat, cmap='RdBu', aspect='equal')
ax.set_title(f'Correlation Matrix (β={beta})', fontweight='bold')
ax.set_xlabel('Coordinate j')
ax.set_ylabel('Coordinate i')
plt.colorbar(im, ax=ax, fraction=0.046)
for i in range(n):
    for j in range(n):
        color = 'white' if abs(corr_mat[i, j]) > 0.02 else 'black'
        ax.text(j, i, f'{corr_mat[i,j]:.3f}', ha='center', va='center',
                fontsize=7, color=color)

# Panel 4: Summary — DLC gap vs distance between coordinates
ax = axes[1, 1]
for beta in [0.5, 1.0, 2.0, 5.0]:
    w = repulsive_weights(n, beta)
    distances = []
    gaps = []
    for i, j in pairs:
        w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
        distances.append(abs(j - i))
        gaps.append(w10 * w01 - w11 * w00)
    # Average gap by distance
    unique_d = sorted(set(distances))
    avg_gaps = [np.mean([g for d, g in zip(distances, gaps) if d == ud])
                for ud in unique_d]
    ax.plot(unique_d, avg_gaps, 'o-', label=f'β={beta}', linewidth=1.5, markersize=5)

ax.set_xlabel('Distance |j - i| between coordinates')
ax.set_ylabel('Average DLC gap')
ax.set_title('DLC Gap vs Coordinate Distance', fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)

fig.suptitle('The 2×2 Determinant Inequality: Foundation of the DLC Framework',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_dlc_determinant.png', dpi=150, bbox_inches='tight')
print("Saved viz_dlc_determinant.png")
