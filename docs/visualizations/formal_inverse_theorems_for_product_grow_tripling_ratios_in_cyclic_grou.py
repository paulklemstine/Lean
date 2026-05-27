#!/usr/bin/env python3
"""
Visualization: Tripling Ratios and Subgroup Structure

Visualizes the core phenomenon of the BGT structure theorem:
- The tripling ratio |A³|/|A| for all symmetric subsets of a finite group
- Shows the sharp gap between subgroups (ratio = 1) and non-subgroups (ratio > 1)
- Demonstrates the "growth gap" that drives the BGT classification

This script is fully self-contained — no local module imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import itertools


def product_set_add(n, A, B):
    """Product set in Z/nZ (additive)."""
    return {(a + b) % n for a in A for b in B}


def analyze_group(n):
    """Analyze all symmetric subsets containing 0 in Z/nZ."""
    elements = list(range(n))
    identity = 0
    results = []

    for size in range(1, min(n + 1, 10)):
        for subset in itertools.combinations(elements, size):
            A = set(subset)
            if identity not in A:
                continue
            # Check symmetry
            if not all((-a) % n in A for a in A):
                continue
            # Compute tripling
            AA = product_set_add(n, A, A)
            AAA = product_set_add(n, AA, A)
            ratio = len(AAA) / len(A)
            # Check subgroup
            is_sub = all((a + b) % n in A for a in A for b in A)

            results.append({
                'size': len(A),
                'ratio': ratio,
                'is_subgroup': is_sub,
            })

    return results


# Analyze several groups
groups = [6, 8, 10, 12]
fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Tripling Ratios in Cyclic Groups: The BGT Gap',
             fontsize=16, fontweight='bold')

for idx, n in enumerate(groups):
    ax = axes[idx // 2][idx % 2]
    results = analyze_group(n)

    sub_sizes = [r['size'] for r in results if r['is_subgroup']]
    sub_ratios = [r['ratio'] for r in results if r['is_subgroup']]
    nonsub_sizes = [r['size'] for r in results if not r['is_subgroup']]
    nonsub_ratios = [r['ratio'] for r in results if not r['is_subgroup']]

    ax.scatter(sub_sizes, sub_ratios, c='#2196F3', s=80, marker='s',
               label='Subgroups', zorder=5, edgecolors='navy', linewidth=0.5)
    ax.scatter(nonsub_sizes, nonsub_ratios, c='#FF5722', s=40, marker='o',
               label='Non-subgroups', alpha=0.6, zorder=4)

    # Draw the gap line at ratio = 1
    ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.7,
               label='Exact tripling (ratio=1)')

    ax.set_xlabel('|A|', fontsize=11)
    ax.set_ylabel('|A³|/|A|', fontsize=11)
    ax.set_title(f'Z/{n}Z', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(0.8, max([r['ratio'] for r in results] + [2.5]))
    ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('tripling_ratios.png', dpi=150, bbox_inches='tight')
print("Saved tripling_ratios.png")
