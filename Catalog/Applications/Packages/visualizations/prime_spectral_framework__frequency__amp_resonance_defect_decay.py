#!/usr/bin/env python3
"""
Visualization: Spectral Resonance Defect
==========================================
Shows how the resonance defect D_N(p,q) decays with resolution N,
demonstrating the irrationality of log(p)/log(q) for distinct primes.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def spectral_resonance_defect(p: int, q: int, N: int) -> float:
    r = math.log(p) / math.log(q)
    min_defect = float('inf')
    for b in range(1, N + 1):
        a = round(r * b)
        defect = abs(r - a / b)
        min_defect = min(min_defect, defect)
    return min_defect


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: D_N(2,3) vs N
    ax1 = axes[0]
    pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7)]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    Ns = list(range(1, 501))

    for (p, q), color in zip(pairs, colors):
        defects = [spectral_resonance_defect(p, q, N) for N in Ns]
        ax1.semilogy(Ns, defects, color=color, linewidth=1.2, alpha=0.8,
                     label=f'D_N({p},{q})')

    # Reference line: 1/N^2
    ref = [1.0 / (N * N) for N in Ns]
    ax1.semilogy(Ns, ref, 'k--', alpha=0.4, linewidth=1, label=r'$1/N^2$ reference')

    ax1.set_xlabel('Resolution N', fontsize=13)
    ax1.set_ylabel('Resonance Defect D_N(p,q)', fontsize=13)
    ax1.set_title('Spectral Resonance Defect Decay', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, which='both')

    # Right: Heatmap of D_100(p,q) for first 10 primes
    ax2 = axes[1]
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    n = len(small_primes)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                matrix[i][j] = spectral_resonance_defect(small_primes[i], small_primes[j], 100)
            else:
                matrix[i][j] = 0

    im = ax2.imshow(matrix, cmap='hot_r', interpolation='nearest')
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(small_primes, fontsize=10)
    ax2.set_yticklabels(small_primes, fontsize=10)
    ax2.set_xlabel('Prime q', fontsize=13)
    ax2.set_ylabel('Prime p', fontsize=13)
    ax2.set_title('D₁₀₀(p,q) Heatmap', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax2, label='Resonance Defect')

    plt.tight_layout()
    plt.savefig('resonance_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: resonance_defect.png")


if __name__ == "__main__":
    main()
