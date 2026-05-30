#!/usr/bin/env python3
"""
Visualization: Cayley Graph Structure and Walk Probability

Shows the Cayley graph for small groups (Z_8, S_3) with the probability
distribution of a random walk overlaid as vertex colors. Illustrates
how the walk spreads from the identity to the uniform distribution.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def cayley_adj_cyclic(n, gens):
    A = np.zeros((n, n))
    for g in range(n):
        for s in gens:
            A[g][(g + s) % n] = 1
    return A


fig, axes = plt.subplots(2, 4, figsize=(16, 8))

# Row 1: Walk on Z_12
n = 12
gens = [1, n-1]
A = cayley_adj_cyclic(n, gens)
P = A / A.sum(axis=1, keepdims=True)
p = np.zeros(n)
p[0] = 1.0

angles = np.linspace(0, 2*np.pi, n, endpoint=False)
x = np.cos(angles)
y = np.sin(angles)

for step_idx, t in enumerate([0, 3, 10, 50]):
    ax = axes[0, step_idx]
    p_t = np.linalg.matrix_power(P, t) @ np.eye(n)[0]

    # Draw edges
    for i in range(n):
        for s in gens:
            j = (i + s) % n
            ax.plot([x[i], x[j]], [y[i], y[j]], 'gray', linewidth=0.5, alpha=0.3)

    # Draw vertices colored by probability
    colors = plt.cm.hot(p_t / max(p_t.max(), 1e-10))
    sizes = 100 + 500 * p_t / max(p_t.max(), 1e-10)
    ax.scatter(x, y, c=colors, s=sizes, zorder=5, edgecolors='black', linewidths=0.5)

    ax.set_title(f't = {t}', fontsize=12)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Add probability values for t=0
    if t == 0:
        for i in range(n):
            ax.annotate(f'{i}', (x[i]*1.2, y[i]*1.2), ha='center', va='center', fontsize=7)

axes[0, 0].set_ylabel('Z₁₂', fontsize=14, rotation=0, labelpad=40)

# Row 2: Walk on S_3
perms = list(permutations(range(3)))
perm_labels = ['e', '(12)', '(13)', '(23)', '(123)', '(132)']
idx = {p: i for i, p in enumerate(perms)}
N = len(perms)
A_s3 = np.zeros((N, N))
for i, p in enumerate(perms):
    for a in range(3):
        for b in range(a+1, 3):
            q = list(p)
            q[a], q[b] = q[b], q[a]
            A_s3[i][idx[tuple(q)]] = 1

P_s3 = A_s3 / A_s3.sum(axis=1, keepdims=True)

# Layout for S_3 (hexagonal)
angles_s3 = np.linspace(0, 2*np.pi, N, endpoint=False)
x_s3 = np.cos(angles_s3)
y_s3 = np.sin(angles_s3)

for step_idx, t in enumerate([0, 1, 3, 10]):
    ax = axes[1, step_idx]
    p_t = np.linalg.matrix_power(P_s3, t) @ np.eye(N)[0]

    # Draw edges
    for i in range(N):
        for j in range(i+1, N):
            if A_s3[i][j] > 0:
                ax.plot([x_s3[i], x_s3[j]], [y_s3[i], y_s3[j]],
                       'gray', linewidth=0.8, alpha=0.4)

    # Draw vertices
    colors = plt.cm.hot(p_t / max(p_t.max(), 1e-10))
    sizes = 150 + 600 * p_t / max(p_t.max(), 1e-10)
    ax.scatter(x_s3, y_s3, c=colors, s=sizes, zorder=5,
              edgecolors='black', linewidths=0.5)

    # Labels
    for i in range(N):
        ax.annotate(perm_labels[i], (x_s3[i]*1.3, y_s3[i]*1.3),
                   ha='center', va='center', fontsize=7)

    ax.set_title(f't = {t}', fontsize=12)
    ax.set_xlim(-1.7, 1.7)
    ax.set_ylim(-1.7, 1.7)
    ax.set_aspect('equal')
    ax.axis('off')

axes[1, 0].set_ylabel('S₃', fontsize=14, rotation=0, labelpad=40)

plt.suptitle('Random Walk Diffusion on Cayley Graphs\n(Hot colors = high probability)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('cayley_graph_walk.png', dpi=150, bbox_inches='tight')
print("Saved cayley_graph_walk.png")
