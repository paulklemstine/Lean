#!/usr/bin/env python3
"""
Visualization: Meme Propagation Dynamics
=========================================
Animates (as a static multi-frame plot) how meme values propagate
through a network via the discrete heat equation, converging to
consistent sections (fixed points).
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict

def propagation_step(adj, f, n):
    result = np.zeros(n)
    for i in range(n):
        neighbors = adj.get(i, set())
        if not neighbors:
            result[i] = f[i]
        else:
            result[i] = sum(f[j] for j in neighbors) / len(neighbors)
    return result

# Create a network with two communities
n = 20
edges = []
# Community 1: nodes 0-9 (ring + some random)
for i in range(10):
    edges.append((i, (i+1) % 10))
edges += [(0, 5), (2, 7), (3, 8)]
# Community 2: nodes 10-19 (ring + some random)
for i in range(10, 20):
    edges.append((i, 10 + (i-10+1) % 10))
edges += [(10, 15), (12, 17)]
# Bridge between communities
edges.append((9, 10))

adj = defaultdict(set)
for u, v in edges:
    adj[u].add(v)
    adj[v].add(u)

# Initial meme values: high at node 0, zero elsewhere
f = np.zeros(n)
f[0] = 10.0

# Run propagation
steps_to_show = [0, 1, 3, 5, 10, 20, 50, 100]
history = {0: f.copy()}
for step in range(1, max(steps_to_show) + 1):
    f = propagation_step(adj, f, n)
    if step in steps_to_show:
        history[step] = f.copy()

# Plot
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
axes = axes.flatten()

# Node positions (two circles)
theta1 = np.linspace(0, 2*np.pi, 10, endpoint=False)
theta2 = np.linspace(0, 2*np.pi, 10, endpoint=False)
pos = {}
for i in range(10):
    pos[i] = (np.cos(theta1[i]) - 1.5, np.sin(theta1[i]))
for i in range(10, 20):
    pos[i] = (np.cos(theta2[i-10]) + 1.5, np.sin(theta2[i-10]))

for ax_idx, step in enumerate(steps_to_show):
    ax = axes[ax_idx]
    values = history[step]
    
    # Draw edges
    for u, v in edges:
        ax.plot([pos[u][0], pos[v][0]], [pos[u][1], pos[v][1]], 
                'k-', alpha=0.2, linewidth=0.5)
    
    # Draw nodes with colors based on meme value
    vmax = max(np.max(np.abs(history[0])), 0.1)
    x = [pos[i][0] for i in range(n)]
    y = [pos[i][1] for i in range(n)]
    scatter = ax.scatter(x, y, c=values, cmap='RdYlBu_r', 
                         s=100, vmin=0, vmax=vmax,
                         edgecolors='black', linewidth=0.5, zorder=5)
    
    ax.set_title(f'Step {step}', fontsize=11, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Add community labels
    ax.text(-1.5, -1.4, 'Community A', ha='center', fontsize=8, color='gray')
    ax.text(1.5, -1.4, 'Community B', ha='center', fontsize=8, color='gray')

fig.suptitle('Meme Propagation: Discrete Heat Equation on a Social Network\n'
             '(Converges to consistent section — the H⁰ equilibrium)',
             fontsize=14, fontweight='bold')
fig.colorbar(scatter, ax=axes, label='Meme Value', shrink=0.6)
plt.tight_layout(rect=[0, 0, 0.9, 0.93])
plt.savefig('propagation_dynamics.png', dpi=150, bbox_inches='tight')
print("Saved propagation_dynamics.png")
