#!/usr/bin/env python3
"""
Visualization: Depth-Width Tradeoff for Tropical Neural Varieties

Generates plots showing how tropical degree, folding number, and spectral gap
depend on network depth for a fixed total width budget.
"""

import numpy as np
import math

def tropical_degree(widths):
    r = 1
    for w in widths:
        r *= w
    return r

def spectral_gap(w, L):
    if w <= 1 or L <= 0:
        return 0.0
    return L * math.log2(w) - math.log2(L * w)

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Neural Varieties: Depth-Width Tradeoff', fontsize=16, fontweight='bold')

    # Plot 1: Tropical Degree vs Depth for fixed total width
    ax1 = axes[0, 0]
    for W in [8, 12, 16, 20]:
        depths = []
        degrees = []
        for L in range(1, W + 1):
            w = W // L
            if w < 1:
                break
            depths.append(L)
            degrees.append(w ** L)
        ax1.semilogy(depths, degrees, 'o-', label=f'W={W}', markersize=4)
    ax1.set_xlabel('Depth L')
    ax1.set_ylabel('Tropical Degree (log scale)')
    ax1.set_title('Tropical Degree vs Depth')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Spectral Gap
    ax2 = axes[0, 1]
    for W in [8, 12, 16, 20]:
        depths = []
        gaps = []
        for L in range(1, W + 1):
            w = W // L
            if w < 2:
                break
            depths.append(L)
            gaps.append(spectral_gap(w, L))
        ax2.plot(depths, gaps, 'o-', label=f'W={W}', markersize=4)
    ax2.set_xlabel('Depth L')
    ax2.set_ylabel('Tropical Spectral Gap')
    ax2.set_title('Spectral Gap: Depth Advantage Measure')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0, color='black', linewidth=0.5)

    # Plot 3: Deep vs Shallow comparison
    ax3 = axes[1, 0]
    widths_range = range(2, 12)
    for L in [2, 3, 4, 5]:
        deep = [w**L for w in widths_range]
        shallow = [L*w for w in widths_range]
        ax3.semilogy(list(widths_range), deep, 'o-', label=f'Deep (L={L}): w^L', markersize=3)
    ax3.semilogy(list(widths_range), [L*w for L, w in zip([2]*10, widths_range)],
                  'k--', label='Shallow: L*w', linewidth=2)
    ax3.set_xlabel('Width per layer w')
    ax3.set_ylabel('Tropical Degree (log scale)')
    ax3.set_title('Deep vs Shallow: w^L vs L·w')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Boundary complexity landscape
    ax4 = axes[1, 1]
    W_values = range(4, 25)
    for W in W_values:
        best_L = 1
        best_deg = W
        for L in range(1, W + 1):
            w = W // L
            if w < 2:
                break
            deg = w ** L
            if deg > best_deg:
                best_deg = deg
                best_L = L
        ax4.scatter(W, best_L, c='steelblue', s=30)
    ax4.set_xlabel('Total Width Budget W')
    ax4.set_ylabel('Optimal Depth')
    ax4.set_title('Optimal Depth for Maximum Tropical Degree')
    ax4.grid(True, alpha=0.3)

    # Add text annotation
    ax4.annotate('Optimal depth ≈ W/e', xy=(15, 5), fontsize=10,
                  bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.tight_layout()
    plt.savefig('tradeoff_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved tradeoff_visualization.png")

if __name__ == "__main__":
    main()
