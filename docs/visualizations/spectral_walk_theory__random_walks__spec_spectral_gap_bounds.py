#!/usr/bin/env python3
"""
Visualization: Cycle Graph Spectral Gap Bounds

Shows the tight bounds 8/n² ≤ 1-cos(2π/n) ≤ 2π²/n² as functions of n.
"""

import math

def spectral_gap_cycle(n):
    return 1 - math.cos(2 * math.pi / n)

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available. Printing text output instead.")
        for n in range(3, 51):
            gap = spectral_gap_cycle(n)
            lb = 8.0 / n**2
            ub = 2 * math.pi**2 / n**2
            print(f"n={n:3d}: {lb:.6f} ≤ {gap:.6f} ≤ {ub:.6f}")
        return

    ns = np.arange(3, 201)
    gaps = np.array([spectral_gap_cycle(n) for n in ns])
    lbs = 8.0 / ns**2
    ubs = 2 * np.pi**2 / ns**2

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Spectral gap and bounds
    ax1.semilogy(ns, gaps, 'b-', linewidth=2, label=r'$1 - \cos(2\pi/n)$')
    ax1.semilogy(ns, lbs, 'r--', linewidth=1.5, label=r'$8/n^2$ (lower)')
    ax1.semilogy(ns, ubs, 'g--', linewidth=1.5, label=r'$2\pi^2/n^2$ (upper)')
    ax1.fill_between(ns, lbs, ubs, alpha=0.1, color='blue')
    ax1.set_xlabel('Number of vertices n', fontsize=12)
    ax1.set_ylabel('Spectral gap γ', fontsize=12)
    ax1.set_title('Cycle Graph Spectral Gap: Tight Bounds', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio to asymptotic
    ratios = gaps / (2 * np.pi**2 / ns**2)
    ax2.plot(ns, ratios, 'b-', linewidth=2)
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.axhline(y=8/(2*np.pi**2), color='red', linestyle='--', alpha=0.5,
                label=f'Lower ratio = {8/(2*np.pi**2):.4f}')
    ax2.set_xlabel('Number of vertices n', fontsize=12)
    ax2.set_ylabel(r'$\gamma / (2\pi^2/n^2)$', fontsize=12)
    ax2.set_title('Convergence to Asymptotic', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.1)

    plt.tight_layout()
    plt.savefig('spectral_gap_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectral_gap_bounds.png")


if __name__ == "__main__":
    main()
