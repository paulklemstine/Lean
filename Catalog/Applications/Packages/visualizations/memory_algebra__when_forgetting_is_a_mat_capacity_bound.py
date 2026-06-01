"""Visualization: Memory capacity bound.

Plots the relationship between memory size, alphabet size, and maximum
distinguishing length, illustrating the capacity bound theorem.
"""
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Memory Capacity Bounds: n^k ≤ |M|',
                 fontsize=14, fontweight='bold')

    # Plot 1: Max distinguishing length vs memory size for different alphabets
    memory_sizes = np.arange(1, 1001)
    for n in [2, 3, 5, 10, 26]:
        max_k = [math.floor(math.log(m) / math.log(n)) if m > 0 else 0
                 for m in memory_sizes]
        ax1.plot(memory_sizes, max_k, label=f'|Σ| = {n}', linewidth=2)

    ax1.set_xlabel('Memory size |M|', fontsize=12)
    ax1.set_ylabel('Max distinguishing length k', fontsize=12)
    ax1.set_title('How Much Can You Remember?')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Confusion growth — fraction of streams that are confused
    alphabet_size = 2
    memory_sizes_2 = [4, 8, 16, 32, 64]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(memory_sizes_2)))

    for m, color in zip(memory_sizes_2, colors):
        k_values = range(1, 12)
        confusion_fracs = []
        for k in k_values:
            n_streams = alphabet_size ** k
            # At most m distinct encodings, so at least max(0, n-m)/n streams share
            n_classes = min(n_streams, m)
            # Fraction that must share (lower bound)
            confused_frac = max(0, n_streams - n_classes) / n_streams
            confusion_fracs.append(confused_frac)
        ax2.plot(list(k_values), confusion_fracs,
                 label=f'|M| = {m}', linewidth=2, color=color, marker='o', markersize=4)

    ax2.set_xlabel('Stream length k', fontsize=12)
    ax2.set_ylabel('Minimum confusion fraction', fontsize=12)
    ax2.set_title('Confusion Grows with Stream Length (binary alphabet)')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('viz_capacity_bound.png', dpi=150)
    plt.close()
    print("Saved viz_capacity_bound.png")


if __name__ == '__main__':
    main()
