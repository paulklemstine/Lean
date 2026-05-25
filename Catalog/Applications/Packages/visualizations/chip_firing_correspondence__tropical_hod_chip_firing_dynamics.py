"""
Visualization: Chip-Firing Dynamics on a Graph.

Shows the evolution of a chip configuration on a small graph
through successive firings, illustrating degree preservation
and convergence to a stable/q-reduced configuration.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def chip_fire(divisor, adj, q):
    result = divisor.copy()
    result[q] -= adj[q].sum()
    for v in range(len(divisor)):
        if adj[q, v]:
            result[v] += 1
    return result


def draw_graph_state(ax, adj, divisor, positions, step_label, fired_vertex=None):
    """Draw graph with chip counts on vertices."""
    n = len(divisor)

    # Draw edges
    for i in range(n):
        for j in range(i+1, n):
            if adj[i, j]:
                ax.plot([positions[i][0], positions[j][0]],
                       [positions[i][1], positions[j][1]],
                       'k-', linewidth=1.5, alpha=0.4, zorder=1)

    # Draw vertices with chip counts
    max_chips = max(abs(d) for d in divisor) + 1
    for i in range(n):
        color = '#e74c3c' if divisor[i] < 0 else '#2ecc71' if divisor[i] > 0 else '#95a5a6'
        if fired_vertex is not None and i == fired_vertex:
            edgecolor = '#f39c12'
            linewidth = 3
        else:
            edgecolor = 'black'
            linewidth = 1.5

        size = 200 + 100 * abs(divisor[i])
        ax.scatter(positions[i][0], positions[i][1], s=size, c=color,
                  edgecolors=edgecolor, linewidth=linewidth, zorder=3)
        ax.text(positions[i][0], positions[i][1], str(divisor[i]),
               ha='center', va='center', fontsize=11, fontweight='bold', zorder=4)
        ax.text(positions[i][0], positions[i][1] - 0.25, f'v{i}',
               ha='center', va='top', fontsize=8, color='gray', zorder=4)

    ax.set_title(step_label, fontsize=10, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')


# Graph: K4 (complete graph on 4 vertices)
n = 4
adj = np.ones((n, n), dtype=int)
np.fill_diagonal(adj, 0)

# Vertex positions (square layout)
positions = [(0, 1), (1, 0), (0, -1), (-1, 0)]

# Initial configuration with high chips on one vertex
initial = np.array([6, -1, -1, 2])

# Compute firing sequence
configs = [initial.copy()]
fired_vertices = [None]
D = initial.copy()

firing_order = [0, 3, 0, 1]  # predetermined firing sequence
for q in firing_order:
    if D[q] >= adj[q].sum():
        D = chip_fire(D, adj, q)
        configs.append(D.copy())
        fired_vertices.append(q)

n_steps = len(configs)
fig, axes = plt.subplots(1, min(n_steps, 5), figsize=(4 * min(n_steps, 5), 4))
fig.suptitle('Chip-Firing on K₄: Degree Conservation', fontsize=14, fontweight='bold')

if n_steps == 1:
    axes = [axes]

for idx in range(min(n_steps, 5)):
    ax = axes[idx]
    if idx == 0:
        label = f'Initial (deg={configs[idx].sum()})'
    else:
        label = f'Fire v{fired_vertices[idx]} (deg={configs[idx].sum()})'
    draw_graph_state(ax, adj, configs[idx], positions, label,
                    fired_vertices[idx] if idx > 0 else None)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#2ecc71', label='Positive chips'),
    mpatches.Patch(facecolor='#e74c3c', label='Negative chips'),
    mpatches.Patch(facecolor='#95a5a6', label='Zero chips'),
    mpatches.Patch(facecolor='white', edgecolor='#f39c12', linewidth=2, label='Fired vertex'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=9)

plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_chip_firing.png', dpi=150, bbox_inches='tight')
print("Saved viz_chip_firing.png")
