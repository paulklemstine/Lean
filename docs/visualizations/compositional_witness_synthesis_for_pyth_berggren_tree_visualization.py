#!/usr/bin/env python3
"""
Visualization: The Berggren Tree of Primitive Pythagorean Triples

Visualizes the first 4 levels of the Berggren ternary tree, showing how
each primitive Pythagorean triple generates three children via the
Berggren matrices A, B, C. Node size reflects hypotenuse magnitude.

This demonstrates the compositional witness synthesis: every primitive
triple is uniquely reached by a path from the root (3, 4, 5).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Berggren matrices
BERGGREN = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
]
NAMES = ['A', 'B', 'C']
COLORS = ['#e74c3c', '#3498db', '#2ecc71']

def build_tree(depth):
    """Build tree structure for visualization."""
    nodes = []
    edges = []
    
    def add_node(triple, path, d, parent_idx=None):
        idx = len(nodes)
        nodes.append({
            'triple': tuple(int(x) for x in triple),
            'path': path,
            'depth': d,
            'idx': idx
        })
        if parent_idx is not None:
            edges.append((parent_idx, idx, path[-1] if path else -1))
        
        if d < depth:
            for i in range(3):
                child = BERGGREN[i] @ triple
                add_node(child, path + [i], d + 1, idx)
    
    add_node(np.array([3, 4, 5]), [], 0)
    return nodes, edges

def layout_tree(nodes, edges):
    """Compute x, y positions for tree nodes."""
    max_depth = max(n['depth'] for n in nodes)
    
    # Count nodes at each depth for spacing
    depth_counts = {}
    depth_indices = {}
    for n in nodes:
        d = n['depth']
        if d not in depth_counts:
            depth_counts[d] = 0
            depth_indices[d] = 0
        depth_counts[d] += 1
    
    # Assign positions
    positions = {}
    counters = {d: 0 for d in depth_counts}
    
    for n in nodes:
        d = n['depth']
        count = depth_counts[d]
        idx = counters[d]
        counters[d] += 1
        
        x = (idx - (count - 1) / 2) * (12 / max(count, 1))
        y = -d * 2.5
        positions[n['idx']] = (x, y)
    
    return positions

# Build and layout
nodes, edges = build_tree(3)
positions = layout_tree(nodes, edges)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(18, 12))
fig.patch.set_facecolor('white')
ax.set_facecolor('#fafafa')

# Draw edges
for parent_idx, child_idx, matrix_idx in edges:
    px, py = positions[parent_idx]
    cx, cy = positions[child_idx]
    color = COLORS[matrix_idx] if matrix_idx >= 0 else 'gray'
    ax.plot([px, cx], [py, cy], '-', color=color, linewidth=1.5, alpha=0.5, zorder=1)

# Draw nodes
max_hyp = max(n['triple'][2] for n in nodes)
for n in nodes:
    x, y = positions[n['idx']]
    a, b, c = n['triple']
    
    # Size proportional to log(hypotenuse)
    size = 800 + 400 * np.log(c)
    
    # Color by depth
    depth_colors = ['#f39c12', '#e74c3c', '#9b59b6', '#3498db']
    color = depth_colors[min(n['depth'], len(depth_colors) - 1)]
    
    ax.scatter([x], [y], s=size, c=color, alpha=0.8, edgecolors='white', 
               linewidths=2, zorder=2)
    
    label = f"({a},{b},{c})"
    fontsize = 7 if n['depth'] >= 2 else (9 if n['depth'] == 1 else 11)
    ax.annotate(label, (x, y), ha='center', va='center', fontsize=fontsize,
                fontweight='bold', color='white', zorder=3)

# Legend
for i, (name, color) in enumerate(zip(NAMES, COLORS)):
    ax.plot([], [], '-', color=color, linewidth=3, label=f'Matrix {name}')
ax.legend(loc='upper right', fontsize=12, framealpha=0.9)

# Annotations
ax.set_title('The Berggren Tree: Compositional Synthesis of Primitive Pythagorean Triples',
             fontsize=16, fontweight='bold', pad=20)
ax.set_xlabel('Branching Position', fontsize=12)
ax.text(0.02, 0.02, 
        'Root (3,4,5) → 3 children per node via Berggren matrices A, B, C\n'
        'Every primitive Pythagorean triple appears exactly once\n'
        'Node size ∝ log(hypotenuse) | Lorentz form Q = a² + b² - c² = 0 at every node',
        transform=ax.transAxes, fontsize=10, verticalalignment='bottom',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

ax.set_xlim(-8, 8)
ax.set_ylim(-9, 1.5)
ax.set_yticks([])
ax.grid(False)

plt.tight_layout()
plt.savefig('viz_berggren_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_berggren_tree.png")
