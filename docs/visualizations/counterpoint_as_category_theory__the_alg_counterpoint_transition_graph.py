#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph

Shows the directed graph of permitted voice-leading transitions between
consonant intervals, with edge weights indicating the number of valid
voice leadings for each transition.
"""

import matplotlib.pyplot as plt
import numpy as np


def compute_morphism_counts():
    """Compute the number of valid voice leadings between each pair."""
    CONSONANT = [0, 3, 4, 7, 8, 9]
    PERFECT = {0, 7}
    n = 12

    counts = {}
    for i in CONSONANT:
        for j in CONSONANT:
            count = 0
            target_change = (j - i) % n
            for su in range(n):
                sl = (su - target_change) % n
                is_parallel = (su == sl)
                is_stationary = (su == 0 and sl == 0)
                if j in PERFECT and is_parallel and not is_stationary:
                    continue
                count += 1
            counts[(i, j)] = count
    return counts


def draw_transition_graph():
    """Draw the counterpoint transition graph."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    CONSONANT = [0, 3, 4, 7, 8, 9]
    NAMES = {0: 'P1', 3: 'm3', 4: 'M3', 7: 'P5', 8: 'm6', 9: 'M6'}
    PERFECT = {0, 7}
    counts = compute_morphism_counts()

    # Plot 1: Transition graph
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_title('Counterpoint Transition Graph\n(edge labels = morphism count)',
                  fontsize=12, fontweight='bold')
    ax.axis('off')

    # Position nodes in a hexagon
    positions = {}
    for idx, interval in enumerate(CONSONANT):
        angle = np.pi / 2 - 2 * np.pi * idx / 6
        positions[interval] = (1.2 * np.cos(angle), 1.2 * np.sin(angle))

    # Draw edges (skip self-loops for clarity)
    for i in CONSONANT:
        for j in CONSONANT:
            if i == j:
                continue
            xi, yi = positions[i]
            xj, yj = positions[j]
            # Offset slightly to show bidirectional
            dx, dy = xj - xi, yj - yi
            length = np.sqrt(dx**2 + dy**2)
            nx, ny = -dy / length * 0.05, dx / length * 0.05

            count = counts[(i, j)]
            color = '#2196F3' if j in PERFECT else '#4CAF50'
            alpha = 0.3

            ax.annotate('', xy=(xj - dx * 0.15 + nx, yj - dy * 0.15 + ny),
                         xytext=(xi + dx * 0.15 + nx, yi + dy * 0.15 + ny),
                         arrowprops=dict(arrowstyle='->', color=color, alpha=alpha, lw=1))

    # Draw nodes
    for interval in CONSONANT:
        x, y = positions[interval]
        color = '#2196F3' if interval in PERFECT else '#4CAF50'
        ax.scatter(x, y, s=600, c=color, zorder=10, edgecolors='black', linewidth=2)
        ax.text(x, y, NAMES[interval], ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=11)

        # Self-loop count
        self_count = counts[(interval, interval)]
        ax.text(x, y - 0.3, f'({self_count})', ha='center', fontsize=7, color='gray')

    # Plot 2: Morphism count heatmap
    ax2 = axes[1]
    matrix = np.array([[counts[(i, j)] for j in CONSONANT] for i in CONSONANT])
    im = ax2.imshow(matrix, cmap='YlGnBu', aspect='equal')
    ax2.set_xticks(range(6))
    ax2.set_yticks(range(6))
    ax2.set_xticklabels([NAMES[c] for c in CONSONANT])
    ax2.set_yticklabels([NAMES[c] for c in CONSONANT])
    ax2.set_xlabel('Target interval', fontsize=11)
    ax2.set_ylabel('Source interval', fontsize=11)
    ax2.set_title('Morphism Count Matrix\n|Hom(i, j)|', fontsize=12, fontweight='bold')

    for i in range(6):
        for j in range(6):
            color = 'white' if matrix[i, j] > 10 else 'black'
            ax2.text(j, i, str(matrix[i, j]), ha='center', va='center',
                     fontsize=10, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax2, shrink=0.8)

    plt.tight_layout()
    plt.savefig('transition_graph.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: transition_graph.png")


if __name__ == "__main__":
    draw_transition_graph()
