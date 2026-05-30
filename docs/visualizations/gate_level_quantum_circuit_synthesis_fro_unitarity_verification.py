#!/usr/bin/env python3
"""
Visualization: Unitarity Verification — Amplitude Sum Conservation

Shows that the sum of squared amplitudes equals 1 at every level of
the certificate tree, verifying the unitarity theorem
(amplitudeSplit_normalized).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def compute_level_amplitudes(n, r, weights):
    """
    Compute amplitude vectors at each level of the certificate tree.

    Returns list of lists: level_amps[k] = list of squared amplitudes at level k.
    """
    levels = [[] for _ in range(n + 1)]

    def _traverse(elts, rank, amp_sq, level):
        levels[level].append(amp_sq)
        if rank == 0 or rank == len(elts) or len(elts) == 0:
            return
        if rank > len(elts) or rank < 0:
            return

        e = elts[0]
        rest = elts[1:]

        z_del = 0.0
        for basis in combinations(rest, rank):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_del += w

        z_con = 0.0
        for basis in combinations(rest, rank - 1):
            w = 1.0
            for i in basis:
                w *= weights[i]
            z_con += w
        z_con *= weights[e]

        z_total = z_del + z_con
        if z_total <= 0:
            return

        _traverse(rest, rank, amp_sq * z_del / z_total, level + 1)
        _traverse(rest, rank - 1, amp_sq * z_con / z_total, level + 1)

    _traverse(list(range(n)), r, 1.0, 0)
    return levels


# ============================================================
# Generate visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Unitarity Verification: Σ|amplitude|² = 1 at Every Level',
             fontsize=14, fontweight='bold')

test_cases = [
    (5, 2, [1.0, 2.0, 0.5, 1.5, 3.0]),
    (6, 3, [1.0, 1.5, 2.0, 0.8, 1.2, 2.5]),
    (7, 3, [1.0, 0.5, 2.0, 1.5, 0.8, 3.0, 1.2]),
    (8, 4, [1.0, 1.2, 0.8, 1.5, 2.0, 0.7, 1.8, 1.1]),
]

for idx, (n, r, weights) in enumerate(test_cases):
    ax = axes[idx // 2][idx % 2]

    levels = compute_level_amplitudes(n, r, weights)

    # Sum of squared amplitudes at each level
    level_sums = []
    level_counts = []
    for k, amps in enumerate(levels):
        if amps:
            level_sums.append(sum(amps))
            level_counts.append(len(amps))
        else:
            break

    n_levels = len(level_sums)
    x = np.arange(n_levels)

    # Bar chart of sums
    colors = ['green' if abs(s - 1.0) < 1e-10 else 'red' for s in level_sums]
    bars = ax.bar(x, level_sums, color=colors, alpha=0.7, edgecolor='black')

    # Add count annotations
    for i, (s, c) in enumerate(zip(level_sums, level_counts)):
        ax.text(i, s + 0.02, f'{c} nodes', ha='center', fontsize=7)

    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, linewidth=2)
    ax.set_xlabel('Tree level')
    ax.set_ylabel('Σ|amplitude|²')
    ax.set_title(f'U({r},{n}): weights={weights[:3]}...')
    ax.set_ylim(0, 1.3)

    # Show deviation
    max_dev = max(abs(s - 1.0) for s in level_sums)
    ax.text(0.95, 0.05, f'max |1-Σ|a|²| = {max_dev:.1e}',
            transform=ax.transAxes, ha='right', va='bottom', fontsize=9,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))

plt.tight_layout()
plt.savefig('unitarity_verification.png', dpi=150, bbox_inches='tight')
print("Saved unitarity_verification.png")
