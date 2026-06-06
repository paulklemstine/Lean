#!/usr/bin/env python3
"""
Visualization: Prime Density and the Ultrafilter Dichotomy

Shows how the prime density decays (PNT), illustrating why BOTH
prime-selecting and composite-selecting ultrafilters exist.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def sieve_of_eratosthenes(limit: int) -> list:
    """Return list of primes up to limit."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def main():
    N = 100000
    primes = set(sieve_of_eratosthenes(N))

    # Compute running prime density
    xs = list(range(2, N + 1))
    prime_count = [0] * len(xs)
    running = 0
    for idx, x in enumerate(xs):
        if x in primes:
            running += 1
        prime_count[idx] = running

    densities = [prime_count[i] / xs[i] for i in range(len(xs))]
    pnt_approx = [1 / math.log(x) if x > 1 else 0 for x in xs]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Non-Standard Arithmetic: Prime/Composite Dichotomy\nfor the Diagonal Element ω = [id]',
                 fontsize=14, fontweight='bold')

    # Plot 1: Prime counting function
    ax1 = axes[0, 0]
    ax1.plot(xs, prime_count, 'b-', linewidth=0.5, label='π(n)')
    ax1.plot(xs, [x / math.log(x) if x > 1 else 0 for x in xs],
             'r--', linewidth=1, label='n/ln(n)')
    ax1.set_xlabel('n')
    ax1.set_ylabel('π(n)')
    ax1.set_title('Prime Counting Function π(n)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Prime density
    ax2 = axes[0, 1]
    ax2.plot(xs[10:], densities[10:], 'b-', linewidth=0.5, label='π(n)/n')
    ax2.plot(xs[10:], pnt_approx[10:], 'r--', linewidth=1, label='1/ln(n)')
    ax2.set_xlabel('n')
    ax2.set_ylabel('Density')
    ax2.set_title('Prime Density → 0 (but primes are infinite)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 0.3)

    # Plot 3: Local prime indicator (window of size 100)
    ax3 = axes[1, 0]
    window = 100
    local_density = []
    local_xs = []
    for start in range(2, N - window, window):
        count = sum(1 for i in range(start, start + window) if i in primes)
        local_density.append(count / window)
        local_xs.append(start + window // 2)

    ax3.bar(local_xs[:200], local_density[:200], width=window * 0.9,
            color=['blue' if d > 0.15 else 'red' for d in local_density[:200]],
            alpha=0.6)
    ax3.axhline(y=0.15, color='green', linestyle='--', label='Threshold')
    ax3.set_xlabel('n (center of window)')
    ax3.set_ylabel('Local prime density')
    ax3.set_title('Local Prime Density (window=100)\nBlue=high, Red=low')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Saturation degree illustration
    ax4 = axes[1, 1]
    predicates = {
        'P(i) = "i is even"': lambda i: i % 2 == 0,
        'P(i) = "i > 100"': lambda i: i > 100,
        'P(i) = "i is prime"': lambda i: i in primes,
        'P(i) = "i < 500"': lambda i: i < 500,
    }

    colors = ['blue', 'green', 'red', 'orange']
    for (name, P), color in zip(predicates.items(), colors):
        sat_profile = []
        check_range = range(0, 2000, 10)
        for n in check_range:
            count = sum(1 for i in range(n, n + 200) if P(i))
            sat_profile.append(count / 200)
        ax4.plot(list(check_range), sat_profile, color=color, label=name, linewidth=1.5)

    ax4.axhline(y=0.5, color='black', linestyle=':', label='U-large threshold')
    ax4.set_xlabel('Starting index n')
    ax4.set_ylabel('Density of P on [n, n+200]')
    ax4.set_title('Saturation Degree: How Far P Extends')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_prime_density.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_prime_density.png")


if __name__ == "__main__":
    main()
