"""
Visualization: Topology Lattice and Phantom Decomposition
==========================================================
Visualizes the lattice of all topologies on a 2-element set {0,1},
showing refinement relationships and phantom decompositions.
The indiscrete topology (top) decomposes as the consensus of the
two Sierpiński topologies (middle layer).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ---- Left panel: Topology lattice on {0,1} ----
ax = axes[0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Topology Lattice on {0, 1}', fontsize=14, fontweight='bold')

# Positions: bottom=discrete, top=indiscrete
positions = {
    'discrete': (0, 0),
    'sierp_0': (-0.8, 1.5),
    'sierp_1': (0.8, 1.5),
    'indiscrete': (0, 3),
}

labels = {
    'discrete': '{∅, {0}, {1}, {0,1}}',
    'sierp_0': '{∅, {0}, {0,1}}',
    'sierp_1': '{∅, {1}, {0,1}}',
    'indiscrete': '{∅, {0,1}}',
}

colors = {
    'discrete': '#2196F3',
    'sierp_0': '#FF9800',
    'sierp_1': '#FF9800',
    'indiscrete': '#F44336',
}

# Draw edges (refinement: finer → coarser = bottom → top)
edges = [
    ('discrete', 'sierp_0'),
    ('discrete', 'sierp_1'),
    ('sierp_0', 'indiscrete'),
    ('sierp_1', 'indiscrete'),
]

for a, b in edges:
    ax.annotate('', xy=positions[b], xytext=positions[a],
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

# Draw nodes
for key, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.15, color=colors[key], zorder=5)
    ax.add_patch(circle)
    ax.text(x, y - 0.35, labels[key], ha='center', va='top', fontsize=8)

# Annotations
ax.text(0, 3.4, '⊤ (coarsest)', ha='center', fontsize=9, color='#F44336')
ax.text(0, -0.4, '⊥ (finest)', ha='center', fontsize=9, color='#2196F3')
ax.text(-1.3, 1.5, 'Sierpiński\ntopologies', ha='center', fontsize=8,
        style='italic', color='#FF9800')

# ---- Right panel: Phantom decomposition ----
ax2 = axes[1]
ax2.set_xlim(-2, 2)
ax2.set_ylim(-0.5, 3.5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Phantom Decomposition', fontsize=14, fontweight='bold')

# Show indiscrete = consensus of two Sierpinski
obs_positions = {
    'obs1': (-1, 2),
    'obs2': (1, 2),
    'consensus': (0, 0.5),
}

# Observer 1 (Sierpinski {0})
circle1 = plt.Circle(obs_positions['obs1'], 0.3, color='#FF9800',
                      alpha=0.8, zorder=5)
ax2.add_patch(circle1)
ax2.text(-1, 2, 'Observer 1', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(-1, 1.55, '{∅, {0}, {0,1}}', ha='center', fontsize=8)

# Observer 2 (Sierpinski {1})
circle2 = plt.Circle(obs_positions['obs2'], 0.3, color='#FF9800',
                      alpha=0.8, zorder=5)
ax2.add_patch(circle2)
ax2.text(1, 2, 'Observer 2', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(1, 1.55, '{∅, {1}, {0,1}}', ha='center', fontsize=8)

# Consensus
circle_c = plt.Circle(obs_positions['consensus'], 0.3, color='#F44336',
                       alpha=0.8, zorder=5)
ax2.add_patch(circle_c)
ax2.text(0, 0.5, 'Consensus', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(0, 0.05, '{∅, {0,1}} = Indiscrete', ha='center', fontsize=8,
         color='#F44336')

# Arrows
for obs in ['obs1', 'obs2']:
    ax2.annotate('', xy=obs_positions['consensus'],
                 xytext=obs_positions[obs],
                 arrowprops=dict(arrowstyle='->', color='#666', lw=2))

# Labels
ax2.text(0, 3.2, 'Phantom Number = 2', ha='center', fontsize=12,
         fontweight='bold', color='#333',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF9C4', alpha=0.8))
ax2.text(0, 2.7, 'The indiscrete topology is the consensus\n'
         'of two Sierpiński observers', ha='center', fontsize=9, color='#666')

plt.tight_layout()
plt.savefig('viz_topology_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_topology_lattice.png")
