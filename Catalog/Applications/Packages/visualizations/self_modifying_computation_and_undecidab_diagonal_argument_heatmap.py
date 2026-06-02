#!/usr/bin/env python3
"""
Visualization: The Diagonal Argument

Shows how the diagonal function escapes any enumeration of Boolean predicates.
Produces a heatmap of enum(i,j) values with the diagonal highlighted.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def create_diagonal_visualization(n: int = 12):
    """Create a heatmap showing the diagonal argument."""
    # Define an enumeration
    enum = np.array([[int((i * j + i) % 5 < 2) for j in range(n)] for i in range(n)])

    # Compute diagonal
    diag = np.array([1 - enum[i, i] for i in range(n)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap of enumeration
    im = ax1.imshow(enum, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)
    ax1.set_xlabel('Input j', fontsize=12)
    ax1.set_ylabel('Program i', fontsize=12)
    ax1.set_title('Enumeration: enum(i, j)', fontsize=14)

    # Highlight diagonal cells
    for i in range(n):
        rect = patches.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                  linewidth=3, edgecolor='blue',
                                  facecolor='none', linestyle='--')
        ax1.add_patch(rect)
        ax1.text(i, i, str(enum[i, i]), ha='center', va='center',
                fontsize=10, fontweight='bold', color='blue')

    # Add cell values
    for i in range(n):
        for j in range(n):
            if i != j:
                ax1.text(j, i, str(enum[i, j]), ha='center', va='center',
                        fontsize=8, color='gray')

    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))

    # Diagonal vs each program
    colors = ['#e74c3c' if diag[i] != enum[i, i] else '#2ecc71' for i in range(n)]
    bars = ax2.bar(range(n), [1] * n, color=colors, edgecolor='black', alpha=0.7)

    for i in range(n):
        ax2.text(i, 0.7, f'enum={enum[i,i]}', ha='center', va='center',
                fontsize=9, color='black')
        ax2.text(i, 0.3, f'diag={diag[i]}', ha='center', va='center',
                fontsize=9, color='white', fontweight='bold')

    ax2.set_xlabel('Program index i', fontsize=12)
    ax2.set_title('Diagonal ≠ enum(i, i) at every index', fontsize=14)
    ax2.set_xticks(range(n))
    ax2.set_ylim(0, 1.2)
    ax2.set_yticks([])

    # Legend
    legend_elements = [
        patches.Patch(facecolor='#e74c3c', label='Diagonal differs (always!)'),
        patches.Patch(facecolor='#2ecc71', label='Would match (impossible)')
    ]
    ax2.legend(handles=legend_elements, loc='upper right')

    plt.suptitle('The Diagonal Argument: Why No Enumeration Is Surjective',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_diagonal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_diagonal.png")


def create_code_evolution_visualization():
    """Visualize code evolution in self-modifying systems."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # System 1: Stabilizing
    codes1 = [10, 8, 6, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    axes[0].plot(codes1, 'b-o', markersize=6, linewidth=2)
    axes[0].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Stable code')
    axes[0].fill_between(range(7, 15), 0, max(codes1), alpha=0.1, color='green')
    axes[0].set_title('Stabilizing System', fontsize=13, fontweight='bold')
    axes[0].set_xlabel('Step')
    axes[0].set_ylabel('Code State')
    axes[0].legend(['Code value', 'Fixed point', 'Stabilized region'])

    # System 2: Halting
    codes2 = [42, 40, 34, 32, 2, 0]
    axes[1].plot(codes2, 'r-s', markersize=8, linewidth=2)
    axes[1].plot(len(codes2) - 1, codes2[-1], 'k*', markersize=20)
    axes[1].set_title('Halting System', fontsize=13, fontweight='bold')
    axes[1].set_xlabel('Step')
    axes[1].set_ylabel('Code State')
    axes[1].legend(['Code value', 'HALT'])

    # System 3: Oscillating
    codes3 = [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2]
    axes[2].plot(codes3, 'g-^', markersize=6, linewidth=2)
    axes[2].set_title('Oscillating System (Never Stabilizes)', fontsize=13, fontweight='bold')
    axes[2].set_xlabel('Step')
    axes[2].set_ylabel('Code State')
    axes[2].legend(['Code value (period 3)'])

    plt.suptitle('Self-Modifying System Behaviors: Three Fates',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_code_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_code_evolution.png")


if __name__ == "__main__":
    create_diagonal_visualization()
    create_code_evolution_visualization()
