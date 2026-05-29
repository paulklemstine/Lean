#!/usr/bin/env python3
"""
visualize_shadows.py — Visualization of k-shadow support erosion and overlap multiplicities.

Visualizes the core concepts from the Higher-Order Anti-Cancellation theorem:
1. Support erosion under derivative shadows (2D lattice view)
2. Overlap multiplicity heatmap
3. Shadow size decay across derivative orders

All functions are self-contained — no imports from local modules.
"""

import itertools
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, List, Set, Tuple

ExponentVector = Tuple[int, ...]


# ============================================================
# Self-contained utility functions
# ============================================================

def deriv_multi_shadow(support: Set[ExponentVector],
                       m: ExponentVector) -> Set[ExponentVector]:
    shadow = set()
    for e in support:
        if all(e[i] >= m[i] for i in range(len(m))):
            shadow.add(tuple(e[i] - m[i] for i in range(len(m))))
    return shadow


def weighted_k_shadow(support: Set[ExponentVector],
                      active: Set[ExponentVector]) -> Set[ExponentVector]:
    result = set()
    for m in active:
        result |= deriv_multi_shadow(support, m)
    return result


def enumerate_multi_indices(n: int, k: int) -> List[ExponentVector]:
    if n == 0: return [()]
    if n == 1: return [(k,)]
    result = []
    for first in range(k + 1):
        for rest in enumerate_multi_indices(n - 1, k - first):
            result.append((first,) + rest)
    return result


def overlap_count(support: Set[ExponentVector],
                  active: Set[ExponentVector],
                  d: ExponentVector) -> int:
    n = len(d)
    count = 0
    for m in active:
        e = tuple(d[i] + m[i] for i in range(n))
        if e in support:
            count += 1
    return count


# ============================================================
# Figure 1: Support erosion in 2D
# ============================================================

def plot_support_erosion():
    """Show how derivative shadows erode a 2D polynomial support."""
    max_deg = 6
    support = set()
    for i in range(max_deg + 1):
        for j in range(max_deg + 1 - i):
            support.add((i, j))

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    fig.suptitle("Support Erosion Under Derivative Shadows", fontsize=14, fontweight='bold')

    for idx, k in enumerate([0, 1, 2, 3]):
        ax = axes[idx]
        if k == 0:
            shadow = support
            title = f"Original Support\n({len(shadow)} points)"
        else:
            all_indices = set(enumerate_multi_indices(2, k))
            shadow = weighted_k_shadow(support, all_indices)
            title = f"Order-{k} Shadow\n({len(shadow)} points)"

        # Plot all lattice points
        for i in range(max_deg + 1):
            for j in range(max_deg + 1):
                ax.plot(i, j, 'o', color='#e0e0e0', markersize=4)

        # Plot shadow points
        if shadow:
            xs, ys = zip(*shadow)
            ax.plot(xs, ys, 's', color='#2196F3', markersize=8, alpha=0.7)

        ax.set_title(title, fontsize=11)
        ax.set_xlabel("$x_1$ exponent")
        ax.set_ylabel("$x_2$ exponent")
        ax.set_xlim(-0.5, max_deg + 0.5)
        ax.set_ylim(-0.5, max_deg + 0.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig("shadow_erosion.png", dpi=150, bbox_inches='tight')
    print("Saved: shadow_erosion.png")


# ============================================================
# Figure 2: Overlap multiplicity heatmap
# ============================================================

def plot_overlap_heatmap():
    """Heatmap showing overlap multiplicity at each shadow point."""
    max_deg = 5
    support = set()
    for i in range(max_deg + 1):
        for j in range(max_deg + 1 - i):
            support.add((i, j))

    k = 2
    all_indices = set(enumerate_multi_indices(2, k))
    shadow = weighted_k_shadow(support, all_indices)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("Overlap Multiplicity in Order-2 Shadows", fontsize=14, fontweight='bold')

    # Heatmap
    ax = axes[0]
    grid = np.zeros((max_deg + 1, max_deg + 1))
    for d in shadow:
        count = overlap_count(support, all_indices, d)
        grid[d[1], d[0]] = count

    im = ax.imshow(grid, origin='lower', cmap='YlOrRd', aspect='equal',
                   extent=(-0.5, max_deg + 0.5, -0.5, max_deg + 0.5))
    plt.colorbar(im, ax=ax, label='Overlap multiplicity')
    ax.set_xlabel("$x_1$ exponent")
    ax.set_ylabel("$x_2$ exponent")
    ax.set_title("Overlap Multiplicity\n(how many shadows contribute)")

    # Distribution
    ax2 = axes[1]
    counts = [overlap_count(support, all_indices, d) for d in shadow]
    from collections import Counter
    count_dist = Counter(counts)
    multiplicities = sorted(count_dist.keys())
    frequencies = [count_dist[m] for m in multiplicities]
    ax2.bar(multiplicities, frequencies, color='#FF5722', alpha=0.8)
    ax2.set_xlabel("Overlap multiplicity")
    ax2.set_ylabel("Number of shadow points")
    ax2.set_title("Distribution of Overlap\nMultiplicities")

    plt.tight_layout()
    plt.savefig("overlap_heatmap.png", dpi=150, bbox_inches='tight')
    print("Saved: overlap_heatmap.png")


# ============================================================
# Figure 3: Shadow size decay
# ============================================================

def plot_shadow_decay():
    """Show how shadow size decreases with derivative order."""
    fig, ax = plt.subplots(figsize=(8, 5))

    configs = [
        ("Triangle deg=6", 6, 2),
        ("Triangle deg=8", 8, 2),
        ("Square 4×4", None, 2),
    ]

    colors = ['#2196F3', '#4CAF50', '#FF9800']

    for color, (label, deg, n) in zip(colors, configs):
        if "Square" in label:
            support = {(i, j) for i in range(4) for j in range(4)}
        else:
            support = set()
            for i in range(deg + 1):
                for j in range(deg + 1 - i):
                    support.add((i, j))

        sizes = [len(support)]
        max_k = min(8, max(sum(e) for e in support))
        for k in range(1, max_k + 1):
            all_indices = set(enumerate_multi_indices(n, k))
            shadow = weighted_k_shadow(support, all_indices)
            sizes.append(len(shadow))
            if len(shadow) == 0:
                break

        ks = list(range(len(sizes)))
        ax.plot(ks, sizes, 'o-', color=color, label=label,
                linewidth=2, markersize=6)

    ax.set_xlabel("Derivative order k", fontsize=12)
    ax.set_ylabel("Shadow size |shadow_k(S)|", fontsize=12)
    ax.set_title("Shadow Size Decay with Derivative Order",
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig("shadow_decay.png", dpi=150, bbox_inches='tight')
    print("Saved: shadow_decay.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    plot_support_erosion()
    plot_overlap_heatmap()
    plot_shadow_decay()
    print("\nAll visualizations saved.")
