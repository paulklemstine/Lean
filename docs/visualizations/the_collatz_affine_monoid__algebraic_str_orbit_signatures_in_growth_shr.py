#!/usr/bin/env python3
"""
Visualization: Collatz Orbit Signatures in the Growth-Shrink Plane

Plots each starting value n as a point (odd_steps, even_steps) in the
signature plane. The critical line 3^s = 2^e (i.e., s*log(3) = e*log(2))
separates contracting orbits from expanding ones.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def compute_signature(n):
    odd_count = 0
    even_count = 0
    current = n
    while current != 1:
        if current % 2 == 0:
            even_count += 1
            current = current // 2
        else:
            odd_count += 1
            current = 3 * current + 1
    return odd_count, even_count


def main():
    N = 500
    signatures = []
    for n in range(2, N + 1):
        s, e = compute_signature(n)
        signatures.append((n, s, e))

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Plot 1: Signature plane
    ax = axes[0]
    ss = [sig[1] for sig in signatures]
    es = [sig[2] for sig in signatures]
    ns = [sig[0] for sig in signatures]
    scatter = ax.scatter(ss, es, c=np.log2(ns), cmap='viridis', s=8, alpha=0.7)
    plt.colorbar(scatter, ax=ax, label='log₂(n)')

    # Critical line: s*log(3) = e*log(2), i.e., e = s*log(3)/log(2)
    s_line = np.linspace(0, max(ss) + 5, 100)
    e_line = s_line * math.log(3) / math.log(2)
    ax.plot(s_line, e_line, 'r--', linewidth=2, label='Critical: 3ˢ = 2ᵉ')

    # Density contraction bound: e = 2s
    e_bound = 2 * s_line
    ax.plot(s_line, e_bound, 'g-.', linewidth=1.5,
            label='Density bound: e = 2s')

    ax.set_xlabel('Odd steps (s)', fontsize=12)
    ax.set_ylabel('Even steps (e)', fontsize=12)
    ax.set_title('Collatz Orbit Signatures (n = 2..500)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, max(ss) + 2)
    ax.set_ylim(0, max(es) + 2)

    # Plot 2: Odd-step density distribution
    ax2 = axes[1]
    densities = [s / (s + e) if s + e > 0 else 0 for _, s, e in signatures]
    ax2.hist(densities, bins=40, color='steelblue', edgecolor='white', alpha=0.8)
    critical = math.log(2) / math.log(6)
    ax2.axvline(critical, color='red', linewidth=2, linestyle='--',
                label=f'Critical density ≈ {critical:.4f}')
    ax2.set_xlabel('Odd-step density s/(s+e)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Parity Densities', fontsize=14)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('collatz_signatures.png', dpi=150, bbox_inches='tight')
    print("Saved: collatz_signatures.png")


if __name__ == "__main__":
    main()
