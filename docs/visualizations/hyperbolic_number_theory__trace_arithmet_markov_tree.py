"""
Visualization 2: The Markov Tree

This script visualizes the Markov tree — the infinite binary tree of Markov
triples connected by Vieta involutions. Each node is a Markov triple
(x, y, z) satisfying x² + y² + z² = 3xyz, and edges represent single
Vieta jumps z ↦ 3xy - z.

The tree structure reveals the deep connection between hyperbolic geometry
(the tree is a Cayley graph of a free product) and Diophantine equations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import deque


def generate_markov_tree_with_edges(max_val=200):
    """Generate Markov tree nodes and edges for visualization."""
    nodes = {}  # triple -> position
    edges = []
    queue = deque([(1, 1, 1, None)])
    visited = set()
    
    while queue:
        x, y, z, parent = queue.popleft()
        triple = tuple(sorted([x, y, z]))
        if triple in visited or max(triple) > max_val:
            continue
        visited.add(triple)
        nodes[triple] = None  # position computed later
        
        if parent is not None:
            parent_key = tuple(sorted(parent))
            if parent_key in nodes:
                edges.append((parent_key, triple))
        
        # Vieta jumps
        for a, b, c in [(x, y, z), (y, z, x), (x, z, y)]:
            nc = 3 * a * b - c
            if nc > 0 and nc != c:
                new_triple = (a, b, nc)
                queue.append((a, b, nc, (x, y, z)))
    
    return nodes, edges


def layout_tree(nodes, edges):
    """Simple hierarchical layout based on max element."""
    import math
    
    sorted_triples = sorted(nodes.keys(), key=lambda t: (max(t), sum(t)))
    
    # Group by "level" (max element)
    levels = {}
    for t in sorted_triples:
        lvl = max(t)
        if lvl not in levels:
            levels[lvl] = []
        levels[lvl].append(t)
    
    positions = {}
    sorted_levels = sorted(levels.keys())
    
    for i, lvl in enumerate(sorted_levels):
        triples_at_level = levels[lvl]
        n = len(triples_at_level)
        for j, t in enumerate(triples_at_level):
            x = (j - (n - 1) / 2) * 2.5
            y = -i * 2
            positions[t] = (x, y)
    
    return positions


nodes, edges = generate_markov_tree_with_edges(200)
positions = layout_tree(nodes, edges)

fig, ax = plt.subplots(figsize=(14, 10), dpi=150)

# Draw edges
for parent, child in edges:
    if parent in positions and child in positions:
        px, py = positions[parent]
        cx, cy = positions[child]
        ax.plot([px, cx], [py, cy], 'b-', alpha=0.3, linewidth=1)

# Draw nodes
for triple, pos in positions.items():
    x, y = pos
    color = 'gold' if max(triple) == 1 else \
            'orange' if max(triple) <= 5 else \
            'salmon' if max(triple) <= 30 else 'lightblue'
    
    ax.plot(x, y, 'o', color=color, markersize=20, markeredgecolor='black',
            markeredgewidth=1, zorder=5)
    label = f"{triple[2]}"  # Show largest element
    ax.text(x, y, label, ha='center', va='center', fontsize=7,
            fontweight='bold', zorder=6)

# Add full triple labels for small ones
for triple, pos in positions.items():
    if max(triple) <= 34:
        x, y = pos
        ax.text(x, y - 1.0, f"({triple[0]},{triple[1]},{triple[2]})",
                ha='center', va='top', fontsize=6, color='gray')

ax.set_title('The Markov Tree: Vieta Involutions on x² + y² + z² = 3xyz',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Markov triples connected by Vieta jumps z ↦ 3xy − z')
ax.axis('off')

fig.tight_layout()
plt.savefig('viz_markov_tree.png', dpi=150, bbox_inches='tight')
print(f"Saved Markov tree with {len(nodes)} triples and {len(edges)} edges")
