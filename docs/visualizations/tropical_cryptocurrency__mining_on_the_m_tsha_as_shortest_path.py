"""
Visualization: TSHA as Shortest Path in a Bipartite Graph

Illustrates the proven theorem tsha_eq_shortest_weighted_path:
TSHA(m, h) equals the minimum weight edge in the bipartite graph K_{1,k}
where edge i has weight m_i + h_i.

This connects tropical hashing to combinatorial optimization —
mining becomes a shortest-path search.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def tsha_with_witness(m, h):
    """Returns (hash_value, argmin_index)"""
    vals = [m[i] + h[i] for i in range(len(m))]
    best = min(range(len(vals)), key=lambda i: vals[i])
    return vals[best], best


fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Example data
m = [10, 4, 8, 6, 9, 3, 7]
h = [3, 7, 1, 5, 2, 8, 4]
k = len(m)
weights = [m[i] + h[i] for i in range(k)]
hash_val, argmin = tsha_with_witness(m, h)

# Panel 1: Bipartite graph visualization
ax1 = axes[0]
ax1.set_xlim(-1, 11)
ax1.set_ylim(-1, k + 0.5)

# Source node
source_x, source_y = 1, k / 2
ax1.add_patch(plt.Circle((source_x, source_y), 0.4, color='#2196F3', zorder=5))
ax1.text(source_x, source_y, 'S', ha='center', va='center', 
         fontsize=14, fontweight='bold', color='white', zorder=6)

# Destination nodes and edges
for i in range(k):
    dest_x, dest_y = 9, i + 0.25
    
    # Edge
    is_shortest = (i == argmin)
    edge_color = '#E53935' if is_shortest else '#BDBDBD'
    edge_width = 3 if is_shortest else 1
    edge_alpha = 1.0 if is_shortest else 0.5
    
    ax1.plot([source_x + 0.4, dest_x - 0.35], [source_y, dest_y],
             color=edge_color, linewidth=edge_width, alpha=edge_alpha, zorder=3)
    
    # Weight label
    mid_x = (source_x + dest_x) / 2
    mid_y = (source_y + dest_y) / 2
    weight_color = '#E53935' if is_shortest else '#616161'
    ax1.text(mid_x + 0.3, mid_y, f'w={weights[i]}',
             fontsize=9, color=weight_color,
             fontweight='bold' if is_shortest else 'normal',
             bbox=dict(boxstyle='round,pad=0.2', facecolor='white', 
                      edgecolor=weight_color, alpha=0.8))
    
    # Destination node
    node_color = '#E53935' if is_shortest else '#4CAF50'
    ax1.add_patch(plt.Circle((dest_x, dest_y), 0.35, color=node_color, zorder=5))
    ax1.text(dest_x, dest_y, f'{i}', ha='center', va='center',
             fontsize=11, fontweight='bold', color='white', zorder=6)
    
    # Component info
    ax1.text(10.2, dest_y, f'm={m[i]}, h={h[i]}',
             fontsize=8, va='center', color='#616161')

ax1.set_title(f'TSHA as Shortest Path: K_{{1,{k}}}', fontsize=13, fontweight='bold')
ax1.text(5, -0.5, f'TSHA = min weight = {hash_val} (at index {argmin})',
         fontsize=11, ha='center', color='#E53935', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE'))
ax1.axis('off')

# Panel 2: Bar chart of edge weights
ax2 = axes[1]
colors = ['#E53935' if i == argmin else '#42A5F5' for i in range(k)]
bars = ax2.bar(range(k), weights, color=colors, edgecolor='white', linewidth=1.5)

# Horizontal line at hash value
ax2.axhline(y=hash_val, color='#E53935', linestyle='--', linewidth=2,
            label=f'TSHA = {hash_val}')

# Labels
ax2.set_xlabel('Index i', fontsize=12)
ax2.set_ylabel('Weight (m_i + h_i)', fontsize=12)
ax2.set_title('Edge Weights = Message + Key', fontsize=13, fontweight='bold')
ax2.set_xticks(range(k))

# Annotate minimum
ax2.annotate(f'min = {hash_val}', xy=(argmin, hash_val),
             xytext=(argmin + 1.5, hash_val - 1.5),
             arrowprops=dict(arrowstyle='->', color='#E53935', linewidth=2),
             fontsize=12, color='#E53935', fontweight='bold')

# Add component breakdown on each bar
for i in range(k):
    ax2.text(i, weights[i] + 0.3, f'{m[i]}+{h[i]}',
             ha='center', fontsize=8, color='#424242')

ax2.legend(fontsize=11)
ax2.grid(axis='y', alpha=0.3)

plt.suptitle('Tropical Hash ↔ Shortest Path Correspondence\n(Proven: tsha_eq_shortest_weighted_path)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_shortest_path.png', dpi=150, bbox_inches='tight')
print("Saved viz_shortest_path.png")
