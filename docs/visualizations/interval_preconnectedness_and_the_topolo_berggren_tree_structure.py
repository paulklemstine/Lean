"""
Visualization: The Berggren Tree of Pythagorean Triples

Shows the ternary tree structure of primitive Pythagorean triples,
color-coded by the sine value a/c. The tree demonstrates how the 
three Berggren matrices generate all primitive triples from (3,4,5).
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def build_tree(max_depth=6):
    """Build tree with position information for plotting."""
    nodes = []
    edges = []
    queue = deque([(3, 4, 5, 0, 0.5, 0)])  # a, b, c, depth, x, parent_idx
    
    while queue:
        a, b, c, depth, x, parent_idx = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        if depth > max_depth or a <= 0 or b <= 0:
            continue
        
        node_idx = len(nodes)
        nodes.append({
            'triple': (a, b, c),
            'depth': depth,
            'x': x,
            'sine': a / c
        })
        
        if depth > 0:
            edges.append((parent_idx, node_idx))
        
        # Width of subtree decreases with depth
        width = 0.5 ** (depth + 1)
        
        for i, T in enumerate([berggren_A, berggren_B, berggren_C]):
            na, nb, nc = T(a, b, c)
            child_x = x + (i - 1) * width
            if nc <= 5000:
                queue.append((abs(na), abs(nb), nc, depth + 1, child_x, node_idx))
    
    return nodes, edges


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

# Left: Tree structure
nodes, edges = build_tree(max_depth=5)

for parent_idx, child_idx in edges:
    p = nodes[parent_idx]
    c = nodes[child_idx]
    ax1.plot([p['x'], c['x']], [-p['depth'], -c['depth']], 
             'k-', alpha=0.2, linewidth=0.5)

xs = [n['x'] for n in nodes]
ys = [-n['depth'] for n in nodes]
sines = [n['sine'] for n in nodes]

scatter = ax1.scatter(xs, ys, c=sines, cmap='viridis', s=30, 
                       edgecolors='black', linewidths=0.3, zorder=5)
plt.colorbar(scatter, ax=ax1, label='Sine value (a/c)')

# Label root and first level
for n in nodes[:4]:
    a, b, c = n['triple']
    ax1.annotate(f'({a},{b},{c})', (n['x'], -n['depth']),
                textcoords="offset points", xytext=(0, 8),
                fontsize=7, ha='center')

ax1.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=13)
ax1.set_ylabel('Tree Depth')
ax1.set_xlabel('Horizontal Position (schematic)')
ax1.set_yticks(range(0, -6, -1))
ax1.set_yticklabels(range(0, 6))

# Right: Sine values on the unit circle
angles = [math.asin(s) for s in sines]
for i, (angle, sine) in enumerate(zip(angles, sines)):
    depth = nodes[i]['depth']
    alpha = max(0.1, 1 - depth * 0.15)
    ax2.plot([0, math.cos(angle)], [0, math.sin(angle)], 
             'b-', alpha=alpha * 0.3, linewidth=0.5)

# Draw quarter circle
theta = np.linspace(0, np.pi/2, 100)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5)

# Plot lattice points
for n in nodes:
    a, b, c = n['triple']
    ax2.plot(b/c, a/c, 'o', markersize=4, 
             color=plt.cm.viridis(n['sine']), 
             markeredgecolor='black', markeredgewidth=0.3)

ax2.set_xlim(-0.05, 1.05)
ax2.set_ylim(-0.05, 1.05)
ax2.set_aspect('equal')
ax2.set_title('Pythagorean Triples on the Unit Circle', fontsize=13)
ax2.set_xlabel('cos(θ) = b/c')
ax2.set_ylabel('sin(θ) = a/c')
ax2.grid(True, alpha=0.3)

plt.suptitle('The Berggren Tree and Its Projection onto the Unit Circle', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_berggren_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_berggren_tree.png")
