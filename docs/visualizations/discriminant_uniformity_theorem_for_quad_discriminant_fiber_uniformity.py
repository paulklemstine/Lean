#!/usr/bin/env python3
"""
Visualization: Fiber Uniformity of the Discriminant Map

Creates a heatmap showing the discriminant values for all (b,c) pairs
over F_p, visually demonstrating the uniform distribution.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def quad_disc(b: int, c: int, p: int) -> int:
    return (b * b - 4 * c) % p


def plot_discriminant_heatmap(p: int, ax: plt.Axes) -> None:
    """Plot the discriminant map as a heatmap over (b,c) space."""
    grid = np.zeros((p, p), dtype=int)
    for b in range(p):
        for c in range(p):
            grid[c, b] = quad_disc(b, c, p)
    im = ax.imshow(grid, cmap='viridis', origin='lower', aspect='equal')
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('c', fontsize=12)
    ax.set_title(f'Discriminant b² − 4c over F_{p}', fontsize=14)
    plt.colorbar(im, ax=ax, label='Discriminant value')


def plot_fiber_sizes(primes: list, ax: plt.Axes) -> None:
    """Bar chart showing fiber sizes for each value, confirming uniformity."""
    for p in primes:
        sizes = [0] * p
        for b in range(p):
            for c in range(p):
                d = quad_disc(b, c, p)
                sizes[d] += 1
        ax.bar([x + primes.index(p) * 0.15 for x in range(p)],
               sizes, width=0.15, alpha=0.7, label=f'p={p}')
    ax.set_xlabel('Discriminant value d', fontsize=12)
    ax.set_ylabel('Fiber size |{(b,c): b²−4c=d}|', fontsize=12)
    ax.set_title('Fiber sizes (all equal to p)', fontsize=14)
    ax.legend()


def plot_splitting_fractions(ax: plt.Axes) -> None:
    """Plot the splitting type fractions as p grows."""
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    split_frac = []
    ramified_frac = []
    inert_frac = []

    for p in primes:
        total = p * p
        split_frac.append(p * (p - 1) // 2 / total)
        ramified_frac.append(p / total)
        inert_frac.append(p * (p - 1) // 2 / total)

    ax.plot(primes, split_frac, 'go-', label='Split (two roots)', markersize=6)
    ax.plot(primes, ramified_frac, 'rs-', label='Ramified (repeated root)', markersize=6)
    ax.plot(primes, inert_frac, 'b^-', label='Inert (irreducible)', markersize=6)
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='y = 1/2')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Fraction of quadratics', fontsize=12)
    ax.set_title('Splitting Type Distribution as p → ∞', fontsize=14)
    ax.legend()
    ax.set_ylim(-0.05, 0.6)


if __name__ == "__main__":
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Heatmap for p=11
    plot_discriminant_heatmap(11, axes[0])

    # Panel 2: Fiber sizes for small primes
    plot_fiber_sizes([3, 5, 7], axes[1])

    # Panel 3: Splitting fractions converging to 1/2
    plot_splitting_fractions(axes[2])

    plt.tight_layout()
    plt.savefig('discriminant_uniformity.png', dpi=150, bbox_inches='tight')
    print("Saved discriminant_uniformity.png")
