#!/usr/bin/env python3
"""
Visualization: Cayley Graph Diameter and Isogeny Graph Structure

Standalone visualization script using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple, Dict


def cayley_diameter_bfs(n: int) -> int:
    """Compute Cayley graph diameter for ℤ/nℤ with generators {1, -1}."""
    if n <= 1:
        return 0
    visited = {0: 0}
    queue = [0]
    max_dist = 0
    while queue:
        current = queue.pop(0)
        for delta in [1, n - 1]:
            neighbor = (current + delta) % n
            if neighbor not in visited:
                visited[neighbor] = visited[current] + 1
                max_dist = max(max_dist, visited[neighbor])
                queue.append(neighbor)
    return max_dist


def bfs_distance_distribution(n: int) -> Dict[int, int]:
    """Compute the distribution of distances from 0 in ℤ/nℤ."""
    visited = {0: 0}
    queue = [0]
    dist_count: Dict[int, int] = {0: 1}
    while queue:
        current = queue.pop(0)
        for delta in [1, n - 1]:
            neighbor = (current + delta) % n
            if neighbor not in visited:
                d = visited[current] + 1
                visited[neighbor] = d
                dist_count[d] = dist_count.get(d, 0) + 1
                queue.append(neighbor)
    return dist_count


def csidh_keyspace_size(n: int, B: int) -> int:
    return (2 * B + 1) ** n


def plot_cayley_diameter():
    """Plot Cayley diameter vs n, comparing with ⌊n/2⌋."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Diameter vs n
    n_values = list(range(3, 102, 2))
    diameters = [cayley_diameter_bfs(n) for n in n_values]
    expected = [n // 2 for n in n_values]

    ax = axes[0]
    ax.plot(n_values, diameters, 'b-', linewidth=2, label='Computed diameter')
    ax.plot(n_values, expected, 'r--', linewidth=1.5, label='⌊n/2⌋')
    ax.set_xlabel('Group order n', fontsize=12)
    ax.set_ylabel('Cayley diameter', fontsize=12)
    ax.set_title('Cayley Graph Diameter of ℤ/nℤ', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Distance distribution for a specific n
    n = 31
    dist = bfs_distance_distribution(n)
    distances = sorted(dist.keys())
    counts = [dist[d] for d in distances]

    ax = axes[1]
    ax.bar(distances, counts, color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel('Distance from origin', fontsize=12)
    ax.set_ylabel('Number of vertices', fontsize=12)
    ax.set_title(f'Distance Distribution in Cayley(ℤ/{n}ℤ)', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Key space size (log scale)
    B_values = list(range(1, 21))
    for n_primes in [37, 50, 74]:
        sizes_bits = [float(n_primes) * np.log2(float(2*B+1)) for B in B_values]
        ax = axes[2]
        ax.plot(B_values, sizes_bits, 'o-', linewidth=2,
                label=f'n = {n_primes} primes', markersize=4)

    ax = axes[2]
    ax.axhline(y=128, color='gray', linestyle=':', label='128-bit security')
    ax.axhline(y=256, color='gray', linestyle='--', label='256-bit security')
    ax.set_xlabel('Exponent bound B', fontsize=12)
    ax.set_ylabel('Key space (bits)', fontsize=12)
    ax.set_title('CSIDH Key Space Size', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cayley_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved cayley_analysis.png")


def plot_security_landscape():
    """Plot the security landscape of isogeny-based schemes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Soundness error vs rounds
    rounds = np.arange(1, 513)
    soundness_error = 2.0 ** (-rounds)

    ax = axes[0]
    ax.semilogy(rounds, soundness_error, 'b-', linewidth=2)
    ax.axhline(y=2**(-128), color='red', linestyle='--', alpha=0.7,
               label='2⁻¹²⁸ target')
    ax.axvline(x=128, color='red', linestyle=':', alpha=0.5)
    ax.set_xlabel('Number of parallel rounds n', fontsize=12)
    ax.set_ylabel('Soundness error 2⁻ⁿ', fontsize=12)
    ax.set_title('CSI-FiSh Soundness Amplification', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 512)

    # Panel 2: Connector triangle identity verification
    test_ns = list(range(3, 200))
    triangle_values = []
    for n in test_ns:
        x, y, z = 1, n // 3, 2 * n // 3
        cxy = (y - x) % n
        cyz = (z - y) % n
        czx = (x - z) % n
        triangle_values.append((cxy + cyz + czx) % n)

    ax = axes[1]
    ax.scatter(test_ns, triangle_values, s=10, alpha=0.7, color='green')
    ax.set_xlabel('Group order n', fontsize=12)
    ax.set_ylabel('Triangle sum (mod n)', fontsize=12)
    ax.set_title('Connector Triangle Identity: ∑conn = 0', fontsize=13)
    ax.set_ylim(-0.5, 1.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved security_landscape.png")


if __name__ == "__main__":
    plot_cayley_diameter()
    plot_security_landscape()
    print("All visualizations generated.")
