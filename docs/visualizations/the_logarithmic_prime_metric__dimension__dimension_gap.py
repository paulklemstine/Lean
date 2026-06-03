#!/usr/bin/env python3
"""
Visualization: The Dimension Gap of the Logarithmic Prime Image

Produces a plot showing the box-counting dimension estimate converging
to ~1/2 as N grows, illustrating the gap from Hausdorff dimension 0.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

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

def box_counting_at_scale(images, epsilon):
    boxes = set()
    for x in images:
        boxes.add(int(x / epsilon))
    return len(boxes)

def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Log-log plot for box-counting dimension
    ax1 = axes[0]
    for N, color in [(10**4, '#2196F3'), (10**5, '#FF9800'), (10**6, '#4CAF50')]:
        primes = sieve_primes(N)
        images = sorted(set(1.0 / math.log(p) for p in primes))

        log_inv_eps = []
        log_counts = []
        for k in range(3, 15):
            eps = 10**(-k/3)
            count = box_counting_at_scale(images, eps)
            if count > 1:
                log_inv_eps.append(math.log(1.0/eps))
                log_counts.append(math.log(count))

        ax1.plot(log_inv_eps, log_counts, 'o-', color=color,
                 label=f'N = {N:,}', markersize=4)

    # Reference line with slope 1/2
    x_ref = [1, 10]
    y_ref = [0.5 + 0.5*x for x in x_ref]
    ax1.plot(x_ref, y_ref, '--', color='red', linewidth=2,
             label='slope = 1/2', alpha=0.7)

    ax1.set_xlabel('log(1/ε)', fontsize=12)
    ax1.set_ylabel('log(covering number)', fontsize=12)
    ax1.set_title('Box-Counting Dimension ≈ 1/2', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: The log-prime image as a point set
    ax2 = axes[1]
    primes = sieve_primes(1000)
    images = [1.0 / math.log(p) for p in primes]
    ax2.scatter(images, [0]*len(images), s=3, c='#2196F3', alpha=0.7)
    ax2.scatter(images[:10], [0]*10, s=30, c='#F44336', zorder=5,
                label='First 10 primes')
    ax2.set_xlabel('1/log(p)', fontsize=12)
    ax2.set_yticks([])
    ax2.set_title('Logarithmic Prime Image S', fontsize=13, fontweight='bold')
    ax2.set_xlim(0, 1.5)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='x')

    # Panel 3: Consecutive gaps in log-space
    ax3 = axes[2]
    primes = sieve_primes(10000)
    gaps = []
    positions = []
    for i in range(len(primes)-1):
        gap = 1.0/math.log(primes[i]) - 1.0/math.log(primes[i+1])
        gaps.append(gap)
        positions.append(primes[i])

    ax3.semilogy(positions[:500], gaps[:500], '.', color='#9C27B0',
                 markersize=2, alpha=0.6)
    # Overlay predicted decay ~ 1/(p log^2 p)
    x_pred = list(range(3, positions[499]+1, 5))
    y_pred = [2.0/(x * math.log(x)**2) for x in x_pred if x > 1]
    ax3.semilogy(x_pred[:len(y_pred)], y_pred, '-', color='red',
                 linewidth=1.5, alpha=0.7, label='~2/(p·log²p)')

    ax3.set_xlabel('Prime p', fontsize=12)
    ax3.set_ylabel('Log-metric gap Δ(p)', fontsize=12)
    ax3.set_title('Gap Decay in Log-Space', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.suptitle('The Dimension Gap: Hausdorff dim = 0, Box-Counting dim ≈ 1/2',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('dimension_gap.png', dpi=150, bbox_inches='tight')
    print("Saved dimension_gap.png")

if __name__ == "__main__":
    main()
