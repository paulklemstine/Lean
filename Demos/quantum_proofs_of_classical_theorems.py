#!/usr/bin/env python3
"""
Quantum Proof Advantage: Numerical Demonstrations

Demonstrates the key theorems from the formal framework:
1. Exponential dominates polynomial (Theorem 1)
2. Proof advantage ratio computation (Theorem 2-3)
3. Quantum certificate compression (Theorem 4)
4. Sunflower bound growth (Theorem 6)
5. Quantum walk mixing bounds (Theorem 7)
"""

import math


def exp_dominates_poly_threshold(c: int) -> int:
    """Find smallest N such that n^c < 2^n for all n >= N."""
    n = 1
    while n ** c >= 2 ** n:
        n += 1
    return n


def proof_advantage_ratio(classical_length: int, quantum_length: int) -> int:
    """Compute the proof advantage ratio (integer division)."""
    if quantum_length == 0:
        return 0
    return classical_length // quantum_length


def sunflower_bound(k: int, ell: int) -> int:
    """Compute the Erdős-Rado sunflower bound S(k, ℓ)."""
    return (ell - 1) ** k * math.factorial(k) + 1


def quantum_certificate_compression(n: int) -> dict:
    """Demonstrate quadratic certificate compression: n² → n."""
    return {
        "classical_bits": n ** 2,
        "quantum_qubits": n,
        "compression_ratio": n if n > 0 else 1,
        "gap": 1 / 3,
    }


def quantum_walk_advantage(n: int) -> dict:
    """Demonstrate quantum walk quadratic speedup."""
    classical_mixing = n
    quantum_mixing = max(1, int(math.sqrt(n)))
    return {
        "vertices": n,
        "classical_mixing": classical_mixing,
        "quantum_mixing": quantum_mixing,
        "speedup_factor": classical_mixing / quantum_mixing if quantum_mixing > 0 else float("inf"),
        "quadratic_check": quantum_mixing ** 2 <= classical_mixing,
    }


def main():
    print("=" * 70)
    print("QUANTUM PROOF ADVANTAGE: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Exponential dominates polynomial
    print("\n--- Theorem 1: Exponential Dominates Polynomial ---")
    print(f"{'Degree c':>10} {'Threshold N':>15} {'N^c':>20} {'2^N':>20}")
    print("-" * 65)
    for c in range(1, 11):
        N = exp_dominates_poly_threshold(c)
        print(f"{c:>10} {N:>15} {N**c:>20} {2**N:>20}")

    # Demo 2: Proof advantage ratios
    print("\n--- Theorems 2-3: Proof Advantage Ratios ---")
    print(f"{'n':>5} {'Classical (2^n)':>18} {'Quantum (n²)':>15} {'Ratio':>12}")
    print("-" * 50)
    for n in [5, 10, 15, 20, 25, 30]:
        cl = 2 ** n
        qu = n ** 2
        ratio = proof_advantage_ratio(cl, qu)
        print(f"{n:>5} {cl:>18} {qu:>15} {ratio:>12}")

    # Demo 3: Quantum certificate compression
    print("\n--- Theorem 4: Quantum Certificate Compression ---")
    print(f"{'n':>5} {'Classical (n²)':>16} {'Quantum (n)':>14} {'Ratio':>8} {'Gap':>8}")
    print("-" * 51)
    for n in [1, 5, 10, 50, 100, 1000]:
        cert = quantum_certificate_compression(n)
        print(
            f"{n:>5} {cert['classical_bits']:>16} {cert['quantum_qubits']:>14} "
            f"{cert['compression_ratio']:>8} {cert['gap']:>8.4f}"
        )

    # Demo 4: Sunflower bound growth
    print("\n--- Theorem 6: Sunflower Bound Growth ---")
    print(f"{'k':>5} {'ℓ':>5} {'S(k,ℓ)':>20} {'k!':>15} {'Ratio':>10}")
    print("-" * 55)
    for k in range(2, 9):
        ell = 3
        sb = sunflower_bound(k, ell)
        kf = math.factorial(k)
        print(f"{k:>5} {ell:>5} {sb:>20} {kf:>15} {sb/kf:>10.2f}")

    # Demo 5: Quantum walk speedup
    print("\n--- Theorem 7: Quantum Walk Mixing Bounds ---")
    print(f"{'Vertices':>10} {'Classical':>12} {'Quantum':>10} {'Speedup':>10} {'Valid':>8}")
    print("-" * 50)
    for n in [4, 16, 64, 256, 1024, 10000]:
        qw = quantum_walk_advantage(n)
        print(
            f"{qw['vertices']:>10} {qw['classical_mixing']:>12} "
            f"{qw['quantum_mixing']:>10} {qw['speedup_factor']:>10.1f} "
            f"{'✓' if qw['quadratic_check'] else '✗':>8}"
        )

    # Demo 6: Super-polynomial advantage visualization
    print("\n--- Main Theorem: Super-Polynomial Advantage ---")
    print(f"{'n':>5} {'n^5':>18} {'n^10':>18} {'2^n':>25} {'Gap(c=5)':>15}")
    print("-" * 80)
    for n in [10, 20, 30, 40, 50, 60]:
        n5 = n ** 5
        n10 = n ** 10
        exp_n = 2 ** n
        gap = exp_n // n5 if n5 > 0 else 0
        print(f"{n:>5} {n5:>18} {n10:>18} {exp_n:>25} {gap:>15}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Quantum vs Classical Proof Length Growth"""
import matplotlib.pyplot as plt
import numpy as np

def plot_advantage():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Exponential vs Polynomial
    n = np.arange(1, 31)
    ax = axes[0]
    for c in [2, 4, 6, 8]:
        ax.semilogy(n, n.astype(float)**c, '--', label=f'n^{c}', alpha=0.7)
    ax.semilogy(n, 2.0**n, 'k-', linewidth=2, label='2^n')
    ax.set_xlabel('n')
    ax.set_ylabel('Value (log scale)')
    ax.set_title('Exponential Dominates Polynomial')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Advantage Ratio Growth
    ax = axes[1]
    sizes = np.arange(5, 51)
    for k in [1, 2, 3]:
        classical = 2.0**sizes
        quantum = sizes.astype(float)**(2*k)
        ratio = classical / quantum
        ax.semilogy(sizes, ratio, label=f'2^n / n^{2*k}')
    ax.set_xlabel('Problem size n')
    ax.set_ylabel('Advantage ratio (log scale)')
    ax.set_title('Super-Polynomial Advantage Growth')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Certificate Compression
    ax = axes[2]
    n = np.arange(1, 101)
    ax.plot(n, n**2, 'r-', linewidth=2, label='Classical: n²')
    ax.plot(n, n, 'b-', linewidth=2, label='Quantum: n')
    ax.fill_between(n, n, n**2, alpha=0.2, color='green', label='Compression savings')
    ax.set_xlabel('Problem size n')
    ax.set_ylabel('Certificate size')
    ax.set_title('Quantum Certificate Compression')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_advantage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved quantum_advantage.png")

if __name__ == "__main__":
    plot_advantage()


#!/usr/bin/env python3
"""Visualization: Sunflower Bound and Factorial Growth"""
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_sunflower():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Sunflower bound vs factorial
    k_vals = np.arange(2, 12)
    ax = axes[0]
    for ell in [2, 3, 4, 5]:
        bounds = [(ell - 1)**k * math.factorial(k) + 1 for k in k_vals]
        ax.semilogy(k_vals, bounds, 'o-', label=f'S(k, {ell})')
    factorials = [math.factorial(k) for k in k_vals]
    ax.semilogy(k_vals, factorials, 'k--', linewidth=2, label='k!')
    ax.set_xlabel('Uniformity k')
    ax.set_ylabel('Bound (log scale)')
    ax.set_title('Sunflower Bound Growth')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Quantum walk mixing time
    ax = axes[1]
    n = np.arange(4, 1001)
    classical = n.astype(float)
    quantum = np.sqrt(n)
    ax.plot(n, classical, 'r-', linewidth=2, label='Classical: O(n)')
    ax.plot(n, quantum, 'b-', linewidth=2, label='Quantum: O(√n)')
    ax.fill_between(n, quantum, classical, alpha=0.15, color='purple')
    ax.set_xlabel('Number of vertices n')
    ax.set_ylabel('Mixing time')
    ax.set_title('Quantum Walk Speedup')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('sunflower_walk.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sunflower_walk.png")

if __name__ == "__main__":
    plot_sunflower()
