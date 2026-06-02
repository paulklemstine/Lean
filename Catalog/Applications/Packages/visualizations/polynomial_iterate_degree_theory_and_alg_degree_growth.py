#!/usr/bin/env python3
"""
Visualization: Degree growth under polynomial iteration.
Compares different base degrees and shows the exponential explosion.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Degree growth comparison
    ax = axes[0]
    ns = np.arange(0, 16)
    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0']
    for i, d in enumerate([2, 3, 4, 5, 7]):
        degrees = d ** ns
        ax.semilogy(ns, degrees, 'o-', color=colors[i], markersize=5,
                   linewidth=2, label=f'd = {d}')
    
    ax.set_xlabel('Iteration depth n', fontsize=13)
    ax.set_ylabel('Degree of iterate d^n', fontsize=13)
    ax.set_title('Iterate Degree Theorem\ndeg(p^{∘n}) = (deg p)^n', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 15)
    
    # Panel 2: Preimage tree
    ax = axes[1]
    # Draw a tree showing how preimages branch
    d = 2
    max_depth = 5
    
    def draw_tree(ax, x, y, depth, x_spread):
        if depth >= max_depth:
            return
        for i in range(d):
            # Child position
            cx = x + (i - (d-1)/2) * x_spread
            cy = y - 1
            # Draw line
            ax.plot([x, cx], [y, cy], 'b-', alpha=0.5, linewidth=max(0.5, 2-depth*0.3))
            # Draw node
            size = max(10, 50 - depth * 10)
            ax.plot(cx, cy, 'o', color='#2196F3', markersize=size/10, alpha=0.7)
            # Recurse
            draw_tree(ax, cx, cy, depth + 1, x_spread / (d + 0.5))
    
    # Root
    ax.plot(0, 0, 'o', color='red', markersize=8, zorder=5)
    ax.annotate('target c', xy=(0, 0), xytext=(0.3, 0.3),
               fontsize=10, ha='left',
               arrowprops=dict(arrowstyle='->', color='red'))
    draw_tree(ax, 0, 0, 0, 4)
    
    ax.set_xlim(-6, 6)
    ax.set_ylim(-max_depth - 0.5, 1)
    ax.set_title(f'Preimage Tree (d=2, depth={max_depth})\n'
                 f'At most d^n = {d**max_depth} preimages', fontsize=14)
    ax.set_ylabel('Iteration depth (backward)', fontsize=13)
    ax.set_xlabel('Preimage spread', fontsize=13)
    
    # Add depth labels
    for depth in range(max_depth + 1):
        count = d ** depth
        ax.text(5.5, -depth, f'n={depth}: ≤{count}', fontsize=9,
               va='center', ha='left', color='gray')
    
    plt.tight_layout()
    plt.savefig('degree_growth.png', dpi=150)
    print("Saved: degree_growth.png")
    plt.close()


if __name__ == "__main__":
    main()
