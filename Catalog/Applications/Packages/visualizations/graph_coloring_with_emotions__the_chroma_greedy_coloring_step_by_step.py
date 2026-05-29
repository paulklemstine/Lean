"""
Visualization: Greedy Coloring in Action

Illustrates the greedy coloring algorithm on a small social network,
showing step-by-step how emotions are assigned and how the degree
bound guarantees success with Δ+1 emotions.
"""

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

# Define a small social network
n = 8
edges = [(0,1), (0,2), (1,2), (1,3), (2,4), (3,4), (3,5), (4,5), (5,6), (6,7), (5,7)]
adj = {i: set() for i in range(n)}
for u, v in edges:
    adj[u].add(v)
    adj[v].add(u)

# Positions for visualization (circular layout)
angles = np.linspace(0, 2*np.pi, n, endpoint=False)
positions = {i: (1.5*np.cos(a), 1.5*np.sin(a)) for i, a in enumerate(angles)}

# Greedy coloring
def greedy_step_by_step(n, adj):
    coloring = [-1] * n
    steps = []
    for v in range(n):
        used = {coloring[u] for u in adj[v] if coloring[u] >= 0}
        color = 0
        while color in used:
            color += 1
        coloring[v] = color
        steps.append((v, color, set(used), coloring[:]))
    return steps

steps = greedy_step_by_step(n, adj)

# Color palette (emotions)
emotion_colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD']
emotion_names = ['Happiness', 'Sadness', 'Anger', 'Fear', 'Disgust', 'Surprise']

fig, axes = plt.subplots(2, 4, figsize=(20, 10))
axes = axes.flatten()

for step_idx, (v, color, used, current_coloring) in enumerate(steps):
    ax = axes[step_idx]

    # Draw edges
    for u1, v1 in edges:
        x = [positions[u1][0], positions[v1][0]]
        y = [positions[u1][1], positions[v1][1]]
        ax.plot(x, y, 'gray', linewidth=1, alpha=0.4, zorder=1)

    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        c = current_coloring[i]
        if c >= 0:
            fc = emotion_colors[c]
            alpha = 1.0
        else:
            fc = 'lightgray'
            alpha = 0.5

        if i == v:
            # Highlight current vertex
            circle = plt.Circle((x, y), 0.22, facecolor=fc, edgecolor='black',
                                linewidth=3, zorder=3, alpha=alpha)
        else:
            circle = plt.Circle((x, y), 0.18, facecolor=fc, edgecolor='gray',
                                linewidth=1.5, zorder=2, alpha=alpha)
        ax.add_patch(circle)
        ax.text(x, y, str(i), ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=4)

    # Title
    forbidden = ', '.join(emotion_names[c] for c in sorted(used) if c < len(emotion_names))
    assigned = emotion_names[color] if color < len(emotion_names) else f'Color {color}'
    ax.set_title(f'Step {step_idx+1}: Vertex {v}\n'
                 f'Forbidden: {{{forbidden}}}\n'
                 f'Assigned: {assigned}',
                 fontsize=9, fontweight='bold')

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.axis('off')

# Add legend
legend_patches = [mpatches.Patch(facecolor=emotion_colors[i], edgecolor='gray',
                                  label=emotion_names[i])
                  for i in range(min(max(s[1] for s in steps) + 1, len(emotion_names)))]
legend_patches.append(mpatches.Patch(facecolor='lightgray', edgecolor='gray',
                                      label='Uncolored'))

fig.legend(handles=legend_patches, loc='lower center', ncol=len(legend_patches),
           fontsize=11, frameon=True, fancybox=True, shadow=True)

max_deg = max(len(adj[v]) for v in range(n))
num_colors = max(s[1] for s in steps) + 1

plt.suptitle(f'Greedy Coloring Algorithm on Social Network\n'
             f'Δ = {max_deg}, Colors used = {num_colors} ≤ Δ+1 = {max_deg+1} '
             f'(Formally proved: colorable_of_degree_le)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('greedy_coloring.png', dpi=150, bbox_inches='tight')
print("Saved greedy_coloring.png")
