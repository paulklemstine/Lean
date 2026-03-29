#!/usr/bin/env python3
"""
🪞 The Broken Mirror — Visualizing Involutions and Fixed Points

Demonstrates the Broken Mirror Theorem: every involution on a finite set
of odd cardinality must have at least one fixed point.

We visualize random involutions as graphs, highlighting fixed points (red)
and paired "shattered" points (blue). The theorem guarantees: when |S| is odd,
at least one point is colored red.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import random

def random_involution(n):
    """Generate a random involution on {0, 1, ..., n-1}."""
    perm = list(range(n))
    available = list(range(n))
    random.shuffle(available)
    used = set()
    for x in available:
        if x in used:
            continue
        remaining = [y for y in available if y not in used and y != x]
        if remaining and random.random() < 0.7:  # 70% chance to pair
            y = random.choice(remaining)
            perm[x] = y
            perm[y] = x
            used.add(x)
            used.add(y)
        else:
            perm[x] = x  # fixed point
            used.add(x)
    return perm

def visualize_involution(perm, ax, title):
    """Visualize an involution as a circular diagram."""
    n = len(perm)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)

    # Draw connections (pairs)
    for i in range(n):
        j = perm[i]
        if i < j:  # draw each pair once
            ax.plot([x_pos[i], x_pos[j]], [y_pos[i], y_pos[j]],
                   'b-', alpha=0.5, linewidth=2)

    # Draw points
    fixed = [i for i in range(n) if perm[i] == i]
    shattered = [i for i in range(n) if perm[i] != i]

    if fixed:
        ax.scatter(x_pos[fixed], y_pos[fixed], c='red', s=200, zorder=5,
                  label=f'Fixed ({len(fixed)})', edgecolors='darkred', linewidth=2)
    if shattered:
        ax.scatter(x_pos[shattered], y_pos[shattered], c='royalblue', s=150,
                  zorder=5, label=f'Shattered ({len(shattered)})',
                  edgecolors='navy', linewidth=2)

    for i in range(n):
        ax.annotate(str(i), (x_pos[i], y_pos[i]), fontsize=8,
                   ha='center', va='center', fontweight='bold',
                   color='white')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.legend(loc='upper right', fontsize=8)
    ax.axis('off')

def main():
    random.seed(42)
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('🪞 The Broken Mirror Theorem\n'
                 'Every involution on an odd-sized set has a fixed point (red)',
                 fontsize=16, fontweight='bold', y=0.98)

    sizes = [5, 7, 9, 6, 8, 10]
    for idx, (n, ax) in enumerate(zip(sizes, axes.flat)):
        perm = random_involution(n)
        parity = "ODD" if n % 2 == 1 else "EVEN"
        fixed_count = sum(1 for i in range(n) if perm[i] == i)
        title = f'n={n} ({parity}) — {fixed_count} fixed point{"s" if fixed_count != 1 else ""}'
        if n % 2 == 1:
            title += '\n✓ Theorem guarantees ≥ 1 fixed point'
        visualize_involution(perm, ax, title)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/broken_mirror.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved broken_mirror.png")

    # Statistical validation
    print("\n📊 Statistical Validation of the Broken Mirror Theorem:")
    print("-" * 60)
    for n in [3, 5, 7, 9, 11, 13, 15]:
        trials = 10000
        all_have_fixed = True
        min_fixed = n
        for _ in range(trials):
            perm = random_involution(n)
            fixed = sum(1 for i in range(n) if perm[i] == i)
            min_fixed = min(min_fixed, fixed)
            if fixed == 0:
                all_have_fixed = False
        status = "✓" if all_have_fixed else "✗"
        print(f"  n={n:2d} (odd):  {status} All {trials} involutions had ≥{min_fixed} fixed points")

    print()
    for n in [2, 4, 6, 8, 10]:
        trials = 10000
        zero_count = 0
        for _ in range(trials):
            perm = random_involution(n)
            fixed = sum(1 for i in range(n) if perm[i] == i)
            if fixed == 0:
                zero_count += 1
        print(f"  n={n:2d} (even): {zero_count}/{trials} involutions had 0 fixed points")

if __name__ == "__main__":
    main()
