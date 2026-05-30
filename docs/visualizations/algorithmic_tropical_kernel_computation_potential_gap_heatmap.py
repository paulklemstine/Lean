"""
Visualization: Tropical Potential Gap Heatmap
=============================================

Visualizes how the tropical potential gap varies across vertices of a graph
as the vertex potentials change. The potential gap measures distance from
tropical equilibrium — darker colors indicate vertices closer to balance.

This illustrates the key theorem: gap ≥ 0 for kernel elements, with
gap = 0 corresponding to exact tropical flow conservation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def potential_gap(adj, weights, x, v):
    """Compute tropical potential gap at vertex v."""
    nbrs = adj[v]
    if not nbrs:
        return 0.0
    vals = [weights[(v, u)] + x[u] for u in nbrs]
    return x[v] - min(vals)


def build_graph(n, edges_with_weights):
    """Build adjacency list and weight dict."""
    adj = {i: [] for i in range(n)}
    weights = {}
    for u, v, w in edges_with_weights:
        adj[u].append(v)
        adj[v].append(u)
        weights[(u, v)] = w
        weights[(v, u)] = w
    return adj, weights


# Create a 6-vertex graph (hexagonal-ish network)
n = 6
edges = [
    (0, 1, -1.0), (1, 2, -1.5), (2, 3, -0.8),
    (3, 4, -1.2), (4, 5, -1.0), (5, 0, -0.9),
    (0, 3, -2.0), (1, 4, -1.8),
]
adj, weights = build_graph(n, edges)

# Generate potential profiles and compute gaps
num_profiles = 50
profiles = np.linspace(-3, 3, num_profiles)
gap_matrix = np.zeros((num_profiles, n))

for i, shift in enumerate(profiles):
    # Profile: linearly increasing potential with shift
    x = [shift + 0.5 * v for v in range(n)]
    for v in range(n):
        gap_matrix[i, v] = potential_gap(adj, weights, x, v)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(gap_matrix, aspect='auto', cmap='YlOrRd',
                extent=[0, n-1, profiles[-1], profiles[0]])
ax1.set_xlabel('Vertex', fontsize=12)
ax1.set_ylabel('Potential Shift', fontsize=12)
ax1.set_title('Tropical Potential Gap by Vertex and Shift', fontsize=14)
ax1.set_xticks(range(n))
plt.colorbar(im, ax=ax1, label='Gap (≥ 0 for kernel elements)')

# Gap profiles for specific shifts
ax2 = axes[1]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']
shifts = [profiles[0], profiles[num_profiles//3],
          profiles[2*num_profiles//3], profiles[-1]]

for shift, color in zip(shifts, colors):
    x = [shift + 0.5 * v for v in range(n)]
    gaps = [potential_gap(adj, weights, x, v) for v in range(n)]
    ax2.plot(range(n), gaps, 'o-', color=color, label=f'shift={shift:.1f}',
             markersize=8, linewidth=2)

ax2.axhline(y=0, color='black', linestyle='--', alpha=0.3, label='Equilibrium')
ax2.set_xlabel('Vertex', fontsize=12)
ax2.set_ylabel('Potential Gap', fontsize=12)
ax2.set_title('Gap Profiles (gap ≥ 0 Always)', fontsize=14)
ax2.legend()
ax2.set_xticks(range(n))

plt.tight_layout()
plt.savefig('viz_potential_gap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_potential_gap.png")
