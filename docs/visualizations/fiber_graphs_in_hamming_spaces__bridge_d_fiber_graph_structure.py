#!/usr/bin/env python3
"""
Visualization: Fiber Graph Structure

Plots the fiber graph for a small Hamming space, showing
configurations as nodes colored by fiber, with edges for
Hamming-adjacent same-score pairs.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product


def weight_system_score(weights, config):
    return sum(weights[i][config[i]] for i in range(len(config)))


def hamming_dist(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def main():
    n, q = 3, 3
    weights = [
        [0, 1, 2],
        [0, 3, 1],
        [0, 2, 4],
    ]

    configs = list(product(range(q), repeat=n))
    scores = {c: weight_system_score(weights, c) for c in configs}

    # Group by score
    fibers = {}
    for c, s in scores.items():
        fibers.setdefault(s, []).append(c)

    # Build fiber graphs
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Fiber Graphs in Hamming Space (n=3, q=3)', fontsize=16, fontweight='bold')

    sorted_scores = sorted(fibers.keys())
    colors = plt.cm.Set2(np.linspace(0, 1, len(sorted_scores)))

    for idx, (score, ax) in enumerate(zip(sorted_scores[:6], axes.flat)):
        fiber = fibers[score]
        m = len(fiber)

        # Position nodes in a circle
        if m == 1:
            positions = {fiber[0]: (0.5, 0.5)}
        else:
            angles = np.linspace(0, 2 * np.pi, m, endpoint=False)
            positions = {fiber[k]: (0.5 + 0.35 * np.cos(angles[k]),
                                     0.5 + 0.35 * np.sin(angles[k]))
                        for k in range(m)}

        # Draw edges
        for i, c1 in enumerate(fiber):
            for c2 in fiber[i+1:]:
                if hamming_dist(c1, c2) == 1:
                    x1, y1 = positions[c1]
                    x2, y2 = positions[c2]
                    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

        # Draw nodes
        for c in fiber:
            x, y = positions[c]
            ax.plot(x, y, 'o', color=colors[idx], markersize=12, markeredgecolor='black')
            label = ''.join(str(v) for v in c)
            ax.text(x, y, label, ha='center', va='center', fontsize=6, fontweight='bold')

        ax.set_title(f'Score = {score} ({m} configs)', fontsize=12)
        ax.set_xlim(-0.05, 1.05)
        ax.set_ylim(-0.05, 1.05)
        ax.set_aspect('equal')
        ax.axis('off')

    for idx in range(len(sorted_scores), 6):
        axes.flat[idx].axis('off')

    plt.tight_layout()
    plt.savefig('fiber_graph_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved fiber_graph_visualization.png")


if __name__ == "__main__":
    main()
