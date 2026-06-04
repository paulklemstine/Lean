#!/usr/bin/env python3
"""
Visualization: The Hausdorff-Minkowski Dimension Gap for Prime Distributions

Produces three plots:
1. The log-inverse prime image with accumulation at 0
2. Box-counting dimension convergence to 1
3. Gap energy spectrum showing the critical exponent at s=1
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n+1, i):
                is_prime[j] = False
    return [p for p in range(2, n+1) if is_prime[p]]


def log_inv(p):
    return 1.0 / math.log(p)


def box_count(points, eps):
    return len(set(int(x / eps) for x in points))


def gap_energy(points, s):
    pts = sorted(points, reverse=True)
    return sum(abs(pts[i] - pts[i+1])**s for i in range(len(pts)-1))


def main():
    print("Generating primes...")
    primes = sieve_primes(2_000_000)
    image = [log_inv(p) for p in primes]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Hausdorff–Minkowski Dimension Gap for Prime Distributions',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: Log-inverse prime image
    ax1 = axes[0, 0]
    small_image = [log_inv(p) for p in primes[:500]]
    ax1.scatter(range(len(small_image)), small_image, s=2, c='navy', alpha=0.6)
    ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='Limit point at 0')
    ax1.axhline(y=1/math.log(2), color='green', linestyle='--', alpha=0.5, 
                label=f'Sup = 1/log(2) ≈ {1/math.log(2):.3f}')
    ax1.set_xlabel('Prime index k')
    ax1.set_ylabel('φ(pₖ) = 1/log(pₖ)')
    ax1.set_title('Log-Inverse Prime Image')
    ax1.legend(fontsize=8)
    
    # Plot 2: Box-counting dimension
    ax2 = axes[0, 1]
    eps_values = np.logspace(-5, -1, 30)
    dims = []
    for eps in eps_values:
        N = box_count(image, eps)
        if N > 1:
            dims.append((eps, math.log(N) / math.log(1/eps)))
    
    if dims:
        eps_plot, dim_plot = zip(*dims)
        ax2.semilogx(eps_plot, dim_plot, 'o-', color='darkred', markersize=3)
        ax2.axhline(y=1.0, color='blue', linestyle='--', alpha=0.5, label='dim_M = 1')
        ax2.axhline(y=0.0, color='green', linestyle='--', alpha=0.5, label='dim_H = 0')
        ax2.fill_between([min(eps_plot), max(eps_plot)], 0, 1, alpha=0.1, color='orange',
                        label='DIMENSION GAP')
    ax2.set_xlabel('Scale ε')
    ax2.set_ylabel('log N(ε) / log(1/ε)')
    ax2.set_title('Box-Counting Dimension Convergence')
    ax2.legend(fontsize=8)
    ax2.set_ylim(-0.1, 1.5)
    
    # Plot 3: Gap energy spectrum
    ax3 = axes[1, 0]
    s_values = np.linspace(0.3, 2.5, 40)
    small_img = [log_inv(p) for p in primes[:20000]]
    energies = []
    for s in s_values:
        E = gap_energy(small_img, s)
        energies.append(min(E, 1000))  # cap for display
    
    ax3.semilogy(s_values, energies, 'o-', color='purple', markersize=3)
    ax3.axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='Critical s* = 1 = dim_M')
    ax3.set_xlabel('Exponent s')
    ax3.set_ylabel('Gap Energy E_s (capped at 1000)')
    ax3.set_title('Gap Energy Spectrum')
    ax3.legend(fontsize=8)
    
    # Plot 4: Twin prime compression
    ax4 = axes[1, 1]
    twin_primes = [(p, p+2) for p in primes if p+2 in set(primes) and p >= 3][:200]
    if twin_primes:
        ps = [t[0] for t in twin_primes]
        d_log = [abs(log_inv(p) - log_inv(p+2)) for p, _ in twin_primes]
        d_approx = [2.0 / (p * math.log(p)**2) for p in ps]
        
        ax4.loglog(ps, d_log, 'o', color='blue', markersize=3, alpha=0.6, label='Exact d_log(p, p+2)')
        ax4.loglog(ps, d_approx, '-', color='red', alpha=0.5, label='≈ 2/(p·log²p)')
        ax4.set_xlabel('Prime p')
        ax4.set_ylabel('Log-metric distance d(p, p+2)')
        ax4.set_title('Twin Prime Compression')
        ax4.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('dimension_gap_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: dimension_gap_visualization.png")


if __name__ == "__main__":
    main()
