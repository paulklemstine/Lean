"""
Visualization 1: Substitution Graph for Binary Recipes
=======================================================
Visualizes the Hamming graph H(n,2) for n=3 (a 3-dimensional hypercube).
Each vertex is a recipe (binary choice in each of 3 slots),
and edges connect recipes differing in exactly one slot.
Colored by Hamming distance from the origin recipe [0,0,0].
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import product

def hamming_distance(r1, r2):
    return int(np.sum(np.array(r1) != np.array(r2)))

# Generate all binary recipes with n=3 slots
n = 3
recipes = list(product(range(2), repeat=n))
origin = (0, 0, 0)

# 3D coordinates for the hypercube
coords = {r: np.array(r, dtype=float) for r in recipes}

# Compute edges (adjacent = Hamming distance 1)
edges = []
for i, r1 in enumerate(recipes):
    for j, r2 in enumerate(recipes):
        if i < j and hamming_distance(r1, r2) == 1:
            edges.append((r1, r2))

# Color by Hamming distance from origin
colors = [hamming_distance(r, origin) for r in recipes]
cmap = plt.cm.RdYlGn_r

fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Draw edges
for r1, r2 in edges:
    c1, c2 = coords[r1], coords[r2]
    ax.plot([c1[0], c2[0]], [c1[1], c2[1]], [c1[2], c2[2]],
            'k-', alpha=0.3, linewidth=1)

# Draw vertices
for r in recipes:
    c = coords[r]
    d = hamming_distance(r, origin)
    color = cmap(d / n)
    ax.scatter(*c, s=200, c=[color], edgecolors='black', linewidth=1.5, zorder=5)
    label = ''.join(str(x) for x in r)
    ax.text(c[0]+0.08, c[1]+0.08, c[2]+0.08, label, fontsize=9, fontweight='bold')

ax.set_xlabel('Slot 1 (flour type)')
ax.set_ylabel('Slot 2 (fat type)')
ax.set_zlabel('Slot 3 (sweetener)')
ax.set_title('Substitution Graph H(3,2): The Cookie Hypercube\n'
             'Each vertex is a recipe, edges = single-ingredient substitutions\n'
             'Color = Hamming distance from origin recipe [0,0,0]',
             fontsize=11)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=cmap(0/n), edgecolor='black', label='Distance 0'),
    Patch(facecolor=cmap(1/n), edgecolor='black', label='Distance 1'),
    Patch(facecolor=cmap(2/n), edgecolor='black', label='Distance 2'),
    Patch(facecolor=cmap(3/n), edgecolor='black', label='Distance 3'),
]
ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

plt.tight_layout()
plt.savefig('viz_substitution_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_substitution_graph.png")
