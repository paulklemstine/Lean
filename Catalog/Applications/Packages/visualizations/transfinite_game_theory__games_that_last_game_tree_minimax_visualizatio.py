#!/usr/bin/env python3
"""
Visualization 1: Game Tree with Minimax Values
Shows a game tree colored by winning status.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Optional, Tuple, Dict


class VizNode:
    def __init__(self, children=None, terminal_value=None, label=""):
        self.children = children or []
        self.terminal_value = terminal_value
        self.label = label
        self.x = 0.0
        self.y = 0.0
        self.value = None  # minimax value

    @property
    def is_terminal(self):
        return len(self.children) == 0


def minimax(node: VizNode, depth: int = 0) -> bool:
    if node.is_terminal:
        node.value = node.terminal_value if node.terminal_value is not None else False
        return node.value
    if depth % 2 == 0:
        node.value = any(minimax(c, depth + 1) for c in node.children)
    else:
        node.value = all(minimax(c, depth + 1) for c in node.children)
    return node.value


def layout_tree(node: VizNode, x: float = 0, y: float = 0,
                x_span: float = 8, y_step: float = 1.5) -> None:
    node.x = x
    node.y = y
    if node.children:
        n = len(node.children)
        child_span = x_span / max(n, 1)
        start_x = x - x_span / 2 + child_span / 2
        for i, child in enumerate(node.children):
            layout_tree(child, start_x + i * child_span, y - y_step,
                       child_span * 0.8, y_step)


def draw_tree(ax, node: VizNode, depth: int = 0):
    # Draw edges first
    for child in node.children:
        ax.plot([node.x, child.x], [node.y, child.y],
                'k-', linewidth=1.5, alpha=0.5, zorder=1)
        draw_tree(ax, child, depth + 1)

    # Node color based on minimax value
    color = '#4CAF50' if node.value else '#F44336'  # green=PI wins, red=PII wins
    edge_color = '#2E7D32' if node.value else '#C62828'

    # Shape based on player
    if node.is_terminal:
        marker = 's'  # square for terminal
        size = 400
    elif depth % 2 == 0:
        marker = 'o'  # circle for Player I
        size = 600
    else:
        marker = 'D'  # diamond for Player II
        size = 500

    ax.scatter(node.x, node.y, s=size, c=color, marker=marker,
              edgecolors=edge_color, linewidths=2, zorder=3)

    # Label
    if node.label:
        ax.annotate(node.label, (node.x, node.y), fontsize=7,
                   ha='center', va='center', fontweight='bold',
                   color='white', zorder=4)


def main():
    # Build an interesting game tree
    # Level 3 leaves
    l1 = VizNode(terminal_value=True, label="W")
    l2 = VizNode(terminal_value=False, label="L")
    l3 = VizNode(terminal_value=True, label="W")
    l4 = VizNode(terminal_value=False, label="L")
    l5 = VizNode(terminal_value=True, label="W")
    l6 = VizNode(terminal_value=False, label="L")
    l7 = VizNode(terminal_value=True, label="W")
    l8 = VizNode(terminal_value=False, label="L")

    # Level 2 (Player II nodes)
    n1 = VizNode([l1, l2], label="II")
    n2 = VizNode([l3, l4], label="II")
    n3 = VizNode([l5, l6], label="II")
    n4 = VizNode([l7, l8], label="II")

    # Level 1 (Player I nodes)
    m1 = VizNode([n1, n2], label="I")
    m2 = VizNode([n3, n4], label="I")

    # Root (Player I)
    root = VizNode([m1, m2], label="I")

    # Compute minimax
    minimax(root)

    # Layout
    layout_tree(root)

    # Draw
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    draw_tree(ax, root)

    ax.set_xlim(-6, 6)
    ax.set_ylim(-6, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', edgecolor='#2E7D32',
                      label='Player I wins'),
        mpatches.Patch(facecolor='#F44336', edgecolor='#C62828',
                      label='Player II wins'),
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='gray',
                   markersize=12, label='Player I node'),
        plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='gray',
                   markersize=10, label='Player II node'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='gray',
                   markersize=10, label='Terminal'),
    ]
    ax.legend(handles=legend_elements, loc='lower right', fontsize=10,
             framealpha=0.9)

    ax.set_title('Game Tree with Minimax Values\n'
                 '(Green = Player I wins, Red = Player II wins)',
                 fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('game_tree_minimax.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: game_tree_minimax.png")


if __name__ == "__main__":
    main()
