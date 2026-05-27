#!/usr/bin/env python3
"""
Visualization: Decision-Tree Complexity Bridge

Visualizes the connection between layer profiles and decision-tree
complexity, showing how forced layer drops imply decision-tree depth
lower bounds.

This is a self-contained script — no local imports.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def decision_tree_depth_bound(d, k):
    """Compute decision-tree depth lower bound: ceil(log2(d^(d-k-1)))."""
    exp = max(d - k - 1, 0)
    if exp == 0:
        return 0
    num_layers = d ** exp
    return int(np.ceil(np.log2(max(num_layers, 1))))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Decision-tree depth bound vs dimension for different k
    ax = axes[0]
    for k in [0, 1, 2, 3]:
        ds = list(range(k + 2, 16))
        depths = [decision_tree_depth_bound(d, k) for d in ds]
        ax.plot(ds, depths, 'o-', label=f'k={k}', markersize=4)

    # Also plot d itself for comparison
    ds_all = list(range(2, 16))
    ax.plot(ds_all, ds_all, 'k--', alpha=0.3, label='y = d')

    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Decision-tree depth lower bound')
    ax.set_title('Decision-Tree Depth from Layer Profile')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Number of layers (leaves needed) vs dimension
    ax = axes[1]
    for k in [0, 1, 2]:
        ds = list(range(k + 2, 12))
        layers = [d ** max(d - k - 1, 1) for d in ds]
        ax.semilogy(ds, layers, 's-', label=f'k={k}: $d^{{d-k-1}}$ layers', markersize=5)

    # Compare with 2^depth
    for k in [0, 1, 2]:
        ds = list(range(k + 2, 12))
        tree_caps = [2 ** decision_tree_depth_bound(d, k) for d in ds]
        ax.semilogy(ds, tree_caps, '--', alpha=0.4,
                    label=f'k={k}: $2^{{depth}}$ capacity')

    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Count (log scale)')
    ax.set_title('Forced Layers vs Tree Capacity')
    ax.legend(fontsize=7)
    ax.grid(True, alpha=0.3)

    # Plot 3: Ratio of depth bound to (d-k-1) * log2(d)
    ax = axes[2]
    for k in [0, 1, 2]:
        ds = list(range(k + 2, 20))
        ratios = []
        for d in ds:
            depth = decision_tree_depth_bound(d, k)
            theory = (d - k - 1) * np.log2(d) if d > 1 else 1
            ratios.append(depth / theory if theory > 0 else 0)
        ax.plot(ds, ratios, 'o-', label=f'k={k}', markersize=4)

    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Exact match')
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Depth / (d-k-1)·log₂(d)')
    ax.set_title('Depth Bound Approaches (d-k-1)·log₂(d)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.8, 1.5)

    plt.suptitle('Cross-Domain Bridge: Layer Profiles → Decision-Tree Complexity',
                 fontsize=13, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_decision_tree.png', dpi=150, bbox_inches='tight')
    print("Saved viz_decision_tree.png")


if __name__ == '__main__':
    main()
