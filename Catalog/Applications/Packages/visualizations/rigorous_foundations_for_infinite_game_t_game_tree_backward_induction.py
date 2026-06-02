"""
Visualization: Finite Game Tree with Backward Induction
========================================================

Draws a game tree and color-codes nodes by which player wins
from that position. Demonstrates Zermelo's determinacy theorem
for finite games.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random

random.seed(42)


def generate_random_tree(depth, branching=2):
    """Generate a random game tree as nested dicts."""
    if depth == 0:
        return {"leaf": True, "value": random.choice([True, False])}
    children = [generate_random_tree(depth - 1, branching) for _ in range(branching)]
    return {"leaf": False, "player": depth % 2, "children": children}


def solve_tree(node):
    """Backward induction: returns True if Player I wins."""
    if node["leaf"]:
        return node["value"]
    results = [solve_tree(c) for c in node["children"]]
    if node["player"] == 0:  # Player I: exists winning child
        return any(results)
    else:  # Player II: all children winning for I
        return all(results)


def layout_tree(node, x=0, y=0, dx=1.0, positions=None, edges=None, node_id=0):
    """Compute positions for all nodes."""
    if positions is None:
        positions = {}
        edges = []

    positions[node_id] = (x, y, node)
    current_id = node_id

    if not node["leaf"]:
        n = len(node["children"])
        start_x = x - dx * (n - 1) / 2
        next_id = node_id + 1
        for i, child in enumerate(node["children"]):
            child_x = start_x + i * dx
            edges.append((node_id, next_id))
            next_id = layout_tree(child, child_x, y - 1, dx / 2.5,
                                  positions, edges, next_id)
        return next_id
    return node_id + 1


def draw_game_tree():
    """Draw the game tree visualization."""
    tree = generate_random_tree(depth=4, branching=2)

    positions = {}
    edges = []
    layout_tree(tree, x=0, y=0, dx=8.0, positions=positions, edges=edges)

    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    fig.suptitle("Finite Game Tree: Backward Induction (Zermelo's Theorem)",
                 fontsize=16, fontweight='bold')

    # Draw edges
    for (p, c) in edges:
        px, py, _ = positions[p]
        cx, cy, _ = positions[c]
        ax.plot([px, cx], [py, cy], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for nid, (x, y, node) in positions.items():
        winner = solve_tree(node)
        color = '#2ecc71' if winner else '#e74c3c'  # Green=I wins, Red=II wins

        if node["leaf"]:
            marker = 's'
            size = 80
        else:
            marker = 'o' if node["player"] == 0 else 'D'
            size = 120

        ax.scatter(x, y, c=color, s=size, marker=marker, zorder=5,
                   edgecolors='black', linewidth=0.5)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Player I wins'),
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Player II wins'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='gray',
                   markersize=10, label='Player I node (circle)'),
        plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='gray',
                   markersize=10, label='Player II node (diamond)'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='gray',
                   markersize=8, label='Terminal node (square)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    overall = solve_tree(tree)
    ax.set_title(f"Result: Player {'I' if overall else 'II'} has a winning strategy\n"
                 f"(Depth 4, 31 nodes — every finite game is determined)",
                 fontsize=12)

    ax.set_xlim(-10, 10)
    ax.set_ylim(-5, 1)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_game_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_game_tree.png")


if __name__ == "__main__":
    draw_game_tree()
