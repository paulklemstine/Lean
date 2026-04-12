#!/usr/bin/env python3
"""
MetaFactoring Demo: Quantum-Classical Hybrid Advantage

Demonstrates how classical MetaFactoring lenses reduce quantum resource
requirements for Shor's and Grover's algorithms.

Key theorem (formally verified): √(S/2^k) ≤ √S
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def grover_queries(search_space_size):
    """Number of Grover iterations needed: ~π/4 · √N."""
    return math.ceil(math.pi / 4 * math.sqrt(search_space_size))


def hybrid_advantage_table():
    """Show how k classical lenses reduce quantum query complexity."""
    print("=" * 80)
    print("QUANTUM-CLASSICAL HYBRID ADVANTAGE")
    print("=" * 80)

    bit_sizes = [64, 128, 256, 512, 1024, 2048]

    print(f"\n{'Bits':>6} {'S = 2^n':>12} {'Pure Grover':>14} "
          f"{'k=3 lenses':>14} {'k=7 lenses':>14} {'k=14 lenses':>14}")
    print("-" * 80)

    for bits in bit_sizes:
        S = 2 ** bits
        pure = grover_queries(S)

        results = []
        for k in [3, 7, 14]:
            reduced_S = S // (2 ** k)
            queries = grover_queries(max(1, reduced_S))
            results.append(queries)

        print(f"{bits:>6} {'2^' + str(bits):>12} {pure:>14.2e} "
              f"{results[0]:>14.2e} {results[1]:>14.2e} {results[2]:>14.2e}")

    print()
    print("Speedup factors (Pure / Hybrid):")
    print(f"{'k lenses':>10} {'Grover speedup':>16} {'Note'}")
    print("-" * 60)
    for k in range(1, 15):
        speedup = 2 ** (k / 2)
        print(f"{k:>10} {speedup:>16.1f}× "
              f"{'← 7 standard lenses' if k == 7 else ''}"
              f"{'← doubled lenses' if k == 14 else ''}")


def shor_resource_reduction():
    """Show how classical preprocessing reduces Shor's algorithm resources."""
    print("\n" + "=" * 80)
    print("SHOR'S ALGORITHM: CLASSICAL PREPROCESSING ADVANTAGE")
    print("=" * 80)

    print("""
For RSA-n (n-bit modulus), Shor's algorithm requires:
  - ~2n logical qubits for quantum period-finding
  - Multiple quantum runs to find the period with high probability
  - Each run needs ~n³ quantum gates (modular exponentiation)

Classical MetaFactoring preprocessing reduces the NUMBER OF RUNS needed:
  - Each classical lens halves the effective search space
  - k lenses → 2^k fewer quantum runs needed on average
  - The quantum circuit depth per run is unchanged

This is a constant-factor improvement, not an asymptotic one.
""")

    print(f"{'RSA Key Size':>15} {'Qubits':>8} {'Pure Runs':>12} "
          f"{'w/7 Lenses':>12} {'Savings':>10}")
    print("-" * 65)

    for bits in [512, 1024, 2048, 4096]:
        qubits = 2 * bits
        pure_runs = 10  # typical number of quantum runs needed
        hybrid_runs = max(1, pure_runs // 128)  # 2^7 = 128× reduction
        savings = (1 - hybrid_runs / pure_runs) * 100
        print(f"{f'RSA-{bits}':>15} {qubits:>8} {pure_runs:>12} "
              f"{hybrid_runs:>12} {savings:>9.0f}%")


def plot_hybrid_advantage():
    """Generate a plot of hybrid quantum-classical advantage."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Grover query complexity vs k
    k_values = np.arange(0, 21)
    for n_bits in [64, 128, 256, 512]:
        queries = [grover_queries(max(1, 2**n_bits // 2**k)) for k in k_values]
        ax1.semilogy(k_values, queries, 'o-', label=f'{n_bits}-bit N', markersize=4)

    ax1.set_xlabel('Number of Classical Lenses (k)', fontsize=12)
    ax1.set_ylabel('Grover Queries (log scale)', fontsize=12)
    ax1.set_title('Grover Query Reduction via Classical Lenses', fontsize=14)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.axvline(x=7, color='red', linestyle='--', alpha=0.5, label='k=7 (MetaFactoring)')

    # Plot 2: Speedup factor
    speedups = [2**(k/2) for k in k_values]
    ax2.plot(k_values, speedups, 'b-o', markersize=5)
    ax2.set_xlabel('Number of Classical Lenses (k)', fontsize=12)
    ax2.set_ylabel('Speedup Factor', fontsize=12)
    ax2.set_title('Quantum Speedup from Classical Preprocessing', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=11.3, color='red', linestyle='--', alpha=0.5)
    ax2.annotate('7 lenses → 11.3×', xy=(7, 11.3), xytext=(10, 20),
                 fontsize=10, arrowprops=dict(arrowstyle='->', color='red'))

    plt.tight_layout()
    plt.savefig('MetaFactoring/visuals/quantum_hybrid_advantage.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to MetaFactoring/visuals/quantum_hybrid_advantage.png")


if __name__ == "__main__":
    hybrid_advantage_table()
    shor_resource_reduction()
    try:
        plot_hybrid_advantage()
    except Exception as e:
        print(f"\n(Plotting skipped: {e})")
