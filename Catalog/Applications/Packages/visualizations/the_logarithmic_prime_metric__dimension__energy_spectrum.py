#!/usr/bin/env python3
"""
Visualization: Log-Gap Energy Spectrum

Shows the s-energy E_s = Σ_{p<q≤N} (1/d(p,q))^s as a function of s,
revealing the critical exponent at s ≈ 1/2 where the energy transitions
from convergent to divergent behavior as N → ∞.
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

def compute_energy(primes, s):
    total = 0.0
    for i in range(len(primes)):
        for j in range(i+1, len(primes)):
            d = abs(1.0/math.log(primes[i]) - 1.0/math.log(primes[j]))
            if d > 0:
                total += (1.0/d)**s
    return total

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Energy vs exponent for different N
    ax1 = axes[0]
    s_values = [0.1 * k for k in range(1, 25)]

    for N, color, marker in [(30, '#2196F3', 'o'), (50, '#FF9800', 's'),
                              (100, '#4CAF50', '^'), (200, '#F44336', 'D')]:
        primes = sieve_primes(N)
        energies = [compute_energy(primes, s) for s in s_values]
        ax1.semilogy(s_values, energies, f'{marker}-', color=color,
                     label=f'N = {N}', markersize=4, linewidth=1.5)

    ax1.axvline(x=0.5, color='black', linestyle='--', linewidth=2,
                alpha=0.5, label='s = 1/2 (critical)')
    ax1.set_xlabel('Exponent s', fontsize=12)
    ax1.set_ylabel('Energy E_s (log scale)', fontsize=12)
    ax1.set_title('Log-Gap Energy Spectrum', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Energy growth rate at fixed s as N increases
    ax2 = axes[1]
    N_values = [20, 30, 50, 75, 100, 150, 200]

    for s, color in [(0.3, '#2196F3'), (0.5, '#FF9800'), (0.7, '#4CAF50'),
                     (1.0, '#F44336'), (1.5, '#9C27B0')]:
        energies = []
        for N in N_values:
            primes = sieve_primes(N)
            energies.append(compute_energy(primes, s))
        ax2.loglog(N_values, energies, 'o-', color=color,
                   label=f's = {s}', markersize=5, linewidth=1.5)

    ax2.set_xlabel('N (primes up to N)', fontsize=12)
    ax2.set_ylabel('Energy E_s (log scale)', fontsize=12)
    ax2.set_title('Energy Growth with N', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Prime Log-Gap Energy: Critical Exponent at s = 1/2',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('energy_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved energy_spectrum.png")

if __name__ == "__main__":
    main()
