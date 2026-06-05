#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Hierarchy in Ultrapowers

Shows how the functions i, i², i³, i⁴ grow, demonstrating the
hierarchy of "infinities" in the ultrapower.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_power_hierarchy():
    """Plot the power hierarchy i^k for k = 1, 2, 3, 4."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: linear scale
    ax = axes[0]
    x = np.arange(2, 20)
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    labels = ['i', 'i²', 'i³', 'i⁴']

    for k, (color, label) in enumerate(zip(colors, labels), 1):
        ax.plot(x, x**k, 'o-', color=color, label=label,
                markersize=4, linewidth=2)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Power Hierarchy (Linear Scale)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('linear')
    ax.set_ylim(0, 5000)
    ax.grid(True, alpha=0.3)

    # Right: log scale
    ax = axes[1]
    x = np.arange(2, 50)
    for k, (color, label) in enumerate(zip(colors, labels), 1):
        ax.plot(x, x**k, '-', color=color, label=label, linewidth=2)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Power Hierarchy (Log Scale)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Each level strictly dominates\nthe previous for i ≥ 2',
                xy=(30, 30**3), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.suptitle('Non-Archimedean Hierarchy in Ultrapowers',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_hierarchy.png")


def plot_char_zero_emergence():
    """Visualize characteristic zero emergence."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Generate primes
    primes = []
    candidate = 2
    while len(primes) < 100:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1

    # For each N, compute fraction of primes > N
    N_values = range(1, 200)
    fractions = []
    for N in N_values:
        frac = sum(1 for p in primes if p > N) / len(primes)
        fractions.append(frac)

    ax.plot(list(N_values), fractions, 'b-', linewidth=2)
    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5,
               label='50% threshold')

    # Mark key points
    for N_mark in [10, 50, 100]:
        frac = sum(1 for p in primes if p > N_mark) / len(primes)
        ax.plot(N_mark, frac, 'ro', markersize=8)
        ax.annotate(f'N={N_mark}: {frac:.0%}', xy=(N_mark, frac),
                    xytext=(N_mark+10, frac+0.05), fontsize=9,
                    arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlabel('Threshold N', fontsize=12)
    ax.set_ylabel('Fraction of primes p > N', fontsize=12)
    ax.set_title('Characteristic Zero Emergence:\nFraction of primes exceeding each threshold',
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_char_zero.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_char_zero.png")


def plot_overspill_function():
    """Visualize the overspill function."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # S_n = {i | i >= n}, overspill function f(i) = i
    N = 30
    x = np.arange(0, N)

    # Plot membership regions
    for n in range(0, 10, 2):
        ax.fill_between(x, n, 0, where=(x >= n),
                         alpha=0.1, color=plt.cm.viridis(n/10))
        ax.axhline(y=n, color=plt.cm.viridis(n/10), alpha=0.3,
                   linestyle=':', linewidth=1)
        if n < 8:
            ax.text(N-1, n+0.3, f'S_{n}', fontsize=9,
                    color=plt.cm.viridis(n/10))

    # Plot f(i) = i (diagonal)
    ax.plot(x, x, 'r-', linewidth=3, label='f(i) = i (overspill function)')
    ax.plot(x, x, 'ro', markersize=4)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Level n / f(i)', fontsize=12)
    ax.set_title('Overspill Principle: f(i) grows while staying in S_{f(i)}',
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(-0.5, N)
    ax.set_ylim(-0.5, N)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_overspill.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_overspill.png")


if __name__ == "__main__":
    plot_power_hierarchy()
    plot_char_zero_emergence()
    plot_overspill_function()
    print("All visualizations generated.")
