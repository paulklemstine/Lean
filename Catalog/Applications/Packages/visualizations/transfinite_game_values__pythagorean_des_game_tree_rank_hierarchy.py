"""
Visualization: Game Tree Rank Hierarchy

Visualizes the game-theoretic rank structure of game trees,
showing how rank increases with tree depth and branching.
Demonstrates the chain parity theorem (winning/losing alternation)
and the rank-height bound.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ---- Inline game tree implementation (self-contained) ----

class GameTree:
    def __init__(self, children=None):
        self.children = children if children else []
        self.is_leaf = len(self.children) == 0
    
    def game_rank(self):
        if self.is_leaf:
            return 0
        return max(c.game_rank() + 1 for c in self.children)
    
    def is_winning(self):
        if self.is_leaf:
            return False
        return any(not c.is_winning() for c in self.children)
    
    def height(self):
        if self.is_leaf:
            return 0
        return 1 + max(c.height() for c in self.children)
    
    @staticmethod
    def leaf():
        return GameTree()
    
    @staticmethod
    def of_rank(n):
        if n == 0:
            return GameTree.leaf()
        return GameTree([GameTree.of_rank(n - 1)])
    
    @staticmethod
    def wide_tree(n):
        return GameTree([GameTree.leaf() for _ in range(n)])

# ---- Build data ----

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Game Tree Rank Hierarchy and Pythagorean Descent', 
             fontsize=16, fontweight='bold')

# Plot 1: Chain parity theorem
ax1 = axes[0, 0]
ns = list(range(20))
ranks = [GameTree.of_rank(n).game_rank() for n in ns]
winning = [GameTree.of_rank(n).is_winning() for n in ns]
colors = ['#2ecc71' if w else '#e74c3c' for w in winning]

ax1.bar(ns, ranks, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Chain Depth n', fontsize=11)
ax1.set_ylabel('Game Rank', fontsize=11)
ax1.set_title('Chain Parity: Rank = n, Win iff n is Odd', fontsize=12)

win_patch = mpatches.Patch(color='#2ecc71', label='Winning (odd)')
lose_patch = mpatches.Patch(color='#e74c3c', label='Losing (even)')
ax1.legend(handles=[win_patch, lose_patch], loc='upper left')

# Plot 2: Rank vs Height bound
ax2 = axes[0, 1]

# Generate various trees and compare rank vs height
tree_data = []
for n in range(1, 8):
    # Chain trees
    t = GameTree.of_rank(n)
    tree_data.append((t.height(), t.game_rank(), 'Chain'))
    
    # Wide trees
    t = GameTree.wide_tree(n)
    tree_data.append((t.height(), t.game_rank(), 'Wide'))
    
    # Mixed trees
    if n >= 2:
        t = GameTree([GameTree.of_rank(n-1), GameTree.leaf()])
        tree_data.append((t.height(), t.game_rank(), 'Mixed'))

heights_chain = [d[0] for d in tree_data if d[2] == 'Chain']
ranks_chain = [d[1] for d in tree_data if d[2] == 'Chain']
heights_wide = [d[0] for d in tree_data if d[2] == 'Wide']
ranks_wide = [d[1] for d in tree_data if d[2] == 'Wide']
heights_mixed = [d[0] for d in tree_data if d[2] == 'Mixed']
ranks_mixed = [d[1] for d in tree_data if d[2] == 'Mixed']

ax2.scatter(heights_chain, ranks_chain, c='#3498db', s=80, label='Chain', zorder=3)
ax2.scatter(heights_wide, ranks_wide, c='#e67e22', s=80, label='Wide', zorder=3)
ax2.scatter(heights_mixed, ranks_mixed, c='#9b59b6', s=80, label='Mixed', zorder=3)

max_h = max(d[0] for d in tree_data)
ax2.plot([0, max_h+1], [0, max_h+1], 'k--', alpha=0.5, label='rank = height')
ax2.set_xlabel('Height', fontsize=11)
ax2.set_ylabel('Game Rank', fontsize=11)
ax2.set_title('Rank ≤ Height (Verified Bound)', fontsize=12)
ax2.legend(fontsize=9)

# Plot 3: Pythagorean descent network
ax3 = axes[1, 0]

import math

def pythagorean_moves(n):
    moves = []
    n_sq = n * n
    for m in range(1, n):
        k_sq = n_sq - m * m
        if k_sq > 0:
            k = int(math.isqrt(k_sq))
            if k * k == k_sq:
                moves.append(m)
    return moves

# Draw the network for small numbers
max_n = 50
edges = []
for n in range(2, max_n + 1):
    for m in pythagorean_moves(n):
        edges.append((n, m))

# Position nodes on a circle
hypotenuses = set()
for n in range(2, max_n + 1):
    if pythagorean_moves(n):
        hypotenuses.add(n)

all_nodes = set()
for n, m in edges:
    all_nodes.add(n)
    all_nodes.add(m)

node_list = sorted(all_nodes)
n_nodes = len(node_list)
angles = {node: 2 * np.pi * i / n_nodes for i, node in enumerate(node_list)}
positions = {node: (np.cos(angles[node]), np.sin(angles[node])) 
             for node in node_list}

# Draw edges
for n, m in edges:
    x1, y1 = positions[n]
    x2, y2 = positions[m]
    ax3.plot([x1, x2], [y1, y2], 'b-', alpha=0.15, linewidth=0.5)

# Draw nodes
for node in node_list:
    x, y = positions[node]
    color = '#e74c3c' if node in hypotenuses else '#3498db'
    ax3.scatter(x, y, c=color, s=30, zorder=3, edgecolor='black', linewidth=0.3)

ax3.set_xlim(-1.3, 1.3)
ax3.set_ylim(-1.3, 1.3)
ax3.set_aspect('equal')
ax3.set_title(f'Pythagorean Descent Network (n ≤ {max_n})', fontsize=12)
ax3.axis('off')

hyp_patch = mpatches.Patch(color='#e74c3c', label='Hypotenuse')
leg_patch = mpatches.Patch(color='#3498db', label='Leg only')
ax3.legend(handles=[hyp_patch, leg_patch], loc='lower right', fontsize=9)

# Plot 4: Hypotenuse density
ax4 = axes[1, 1]

Ns = list(range(5, 501))
counts = []
cnt = 0
hyp_set = set()
for n in range(1, 501):
    if pythagorean_moves(n):
        hyp_set.add(n)
    if n >= 5:
        counts.append(len([h for h in hyp_set if h <= n]))

predicted = [N / math.sqrt(math.log(N)) for N in Ns]

# Scale predicted to match
scale = counts[-1] / predicted[-1] if predicted[-1] > 0 else 1

ax4.plot(Ns, counts, 'b-', linewidth=2, label='Actual count')
ax4.plot(Ns, [scale * p for p in predicted], 'r--', linewidth=1.5, 
         label=f'C·N/√(log N), C≈{scale:.3f}')
ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('# Pythagorean Hypotenuses ≤ N', fontsize=11)
ax4.set_title('Hypotenuse Density (Landau–Ramanujan Conjecture)', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_game_tree.png', dpi=150, bbox_inches='tight')
print("Saved visualization to viz_game_tree.png")
