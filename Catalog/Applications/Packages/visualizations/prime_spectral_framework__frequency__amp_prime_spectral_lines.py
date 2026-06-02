#!/usr/bin/env python3
"""
Visualization: Prime Spectral Lines
====================================
Displays the prime spectral lines as a frequency-amplitude plot,
showing how each prime contributes to the zeta function on the critical line.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def sieve_primes(n: int) -> list:
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
    primes = sieve_primes(200)
    freqs = [math.log(p) / (2 * math.pi) for p in primes]
    amps = [1.0 / math.sqrt(p) for p in primes]

    fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [3, 1]})

    # Top: spectral lines as vertical bars
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(primes)))
    for i, (f, a) in enumerate(zip(freqs, amps)):
        ax1.vlines(f, 0, a, colors=[colors[i]], linewidth=2, alpha=0.8)
        if primes[i] <= 19:
            ax1.annotate(f'p={primes[i]}', (f, a), textcoords="offset points",
                        xytext=(5, 5), fontsize=9, fontweight='bold')

    # Envelope curve: 1/sqrt(e^{2πf}) = e^{-πf}
    f_cont = np.linspace(0.05, max(freqs) + 0.1, 500)
    envelope = np.exp(-np.pi * f_cont)
    ax1.plot(f_cont, envelope, 'r--', alpha=0.5, linewidth=1.5,
             label=r'Envelope: $e^{-\pi f}$')

    ax1.set_xlabel('Spectral Frequency  ν = log(p)/(2π)', fontsize=13)
    ax1.set_ylabel('Amplitude  A = 1/√p', fontsize=13)
    ax1.set_title('Prime Spectral Lines: The Music of the Primes', fontsize=15, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 0.8)
    ax1.grid(True, alpha=0.3)

    # Bottom: spectral energy (1/p)
    ax2 = axes[1]
    energies = [1.0 / p for p in primes]
    ax2.bar(freqs, energies, width=0.003, color=colors, alpha=0.7)
    ax2.set_xlabel('Spectral Frequency  ν = log(p)/(2π)', fontsize=13)
    ax2.set_ylabel('Energy  E = 1/p', fontsize=13)
    ax2.set_title('Spectral Energy Distribution', fontsize=13)
    ax2.set_ylim(0, 0.55)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('prime_spectral_lines.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: prime_spectral_lines.png")


if __name__ == "__main__":
    main()
