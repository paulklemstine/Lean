#!/usr/bin/env python3
"""
Visualization: Prime Constellations in Log-Space

Shows clusters of primes that are close together in the logarithmic
metric, revealing the local structure of the prime distribution.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    primes = sieve_primes(5000)
    images = [(p, 1.0/math.log(p)) for p in primes]

    # Panel 1: Full log-prime image with density coloring
    ax1 = axes[0][0]
    xs = [t for _, t in images]
    # Color by local density
    colors = []
    for i, (p, t) in enumerate(images):
        neighbors = sum(1 for _, t2 in images if abs(t - t2) < 0.005)
        colors.append(neighbors)

    sc = ax1.scatter(xs, [p for p, _ in images], c=colors, s=3,
                     cmap='plasma', alpha=0.7)
    plt.colorbar(sc, ax=ax1, label='Local density (r=0.005)')
    ax1.set_xlabel('1/log(p)', fontsize=11)
    ax1.set_ylabel('Prime p', fontsize=11)
    ax1.set_title('Log-Prime Image with Local Density', fontsize=12, fontweight='bold')

    # Panel 2: Zoom into a dense region
    ax2 = axes[0][1]
    zoom_primes = [(p, t) for p, t in images if 0.1 < t < 0.2]
    for p, t in zoom_primes:
        ax2.plot([t, t], [0, 1], '-', color='#2196F3', linewidth=0.8, alpha=0.5)
        ax2.plot(t, 0.5, 'o', color='#F44336', markersize=3)
    ax2.set_xlabel('1/log(p)', fontsize=11)
    ax2.set_xlim(0.1, 0.2)
    ax2.set_yticks([])
    ax2.set_title('Zoom: Dense Region (0.1 < 1/log p < 0.2)', fontsize=12, fontweight='bold')

    # Panel 3: Gap distribution in log-space
    ax3 = axes[1][0]
    gaps = []
    for i in range(len(images) - 1):
        gap = images[i][1] - images[i+1][1]  # positive since anti-tonic
        gaps.append(gap)

    ax3.hist(gaps, bins=50, color='#4CAF50', alpha=0.7, edgecolor='white')
    ax3.axvline(x=sum(gaps)/len(gaps), color='red', linestyle='--',
                linewidth=2, label=f'Mean = {sum(gaps)/len(gaps):.6f}')
    ax3.set_xlabel('Log-metric gap', fontsize=11)
    ax3.set_ylabel('Count', fontsize=11)
    ax3.set_title('Distribution of Consecutive Log-Gaps', fontsize=12, fontweight='bold')
    ax3.legend(fontsize=10)

    # Panel 4: Constellation sizes for various radii
    ax4 = axes[1][1]
    radii = [0.001, 0.002, 0.005, 0.01, 0.02, 0.05]
    max_sizes = []
    avg_sizes = []

    for r in radii:
        sizes = []
        for i, (p, t) in enumerate(images):
            count = sum(1 for _, t2 in images if abs(t - t2) <= r)
            sizes.append(count)
        max_sizes.append(max(sizes))
        avg_sizes.append(sum(sizes) / len(sizes))

    ax4.loglog(radii, max_sizes, 'o-', color='#F44336', linewidth=2,
               label='Max constellation size', markersize=6)
    ax4.loglog(radii, avg_sizes, 's-', color='#2196F3', linewidth=2,
               label='Avg constellation size', markersize=6)

    # Reference: size ~ r^(1/2) scaling
    r_ref = [radii[0], radii[-1]]
    s_ref = [max_sizes[0] * (r/radii[0])**0.5 for r in r_ref]
    ax4.loglog(r_ref, s_ref, '--', color='gray', linewidth=1.5,
               label='~r^{1/2} scaling', alpha=0.7)

    ax4.set_xlabel('Constellation radius r', fontsize=11)
    ax4.set_ylabel('Constellation size', fontsize=11)
    ax4.set_title('Constellation Size vs Radius', fontsize=12, fontweight='bold')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Prime Constellations in the Logarithmic Metric',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('constellations.png', dpi=150, bbox_inches='tight')
    print("Saved constellations.png")

if __name__ == "__main__":
    main()
