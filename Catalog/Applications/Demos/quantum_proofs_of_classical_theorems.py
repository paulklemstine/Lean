"""
Quantum Proof Complexity: Demonstrations

Numerical examples illustrating the key results from the formal framework.
"""

import math
from algorithms import (
    classical_np, quantum_qma, grover_compression,
    pigeonhole_witness_space, pigeonhole_quantum_bound,
    GapAmplification, ProofCompression,
    exp_dominates_poly, find_super_poly_threshold,
)


def demo_grover_quadratic_bound():
    """Demonstrate Grover's quadratic bound for various search spaces."""
    print("=" * 60)
    print("Demo 1: Grover's Quadratic Bound")
    print("=" * 60)
    print(f"{'Search Space N':>15} {'Classical':>10} {'Quantum':>10} {'Ratio':>10}")
    print("-" * 50)

    for N in [4, 16, 64, 256, 1024, 10000, 1000000]:
        classical = N
        quantum = int(math.isqrt(N)) + 1
        ratio = classical / quantum
        print(f"{N:>15,} {classical:>10,} {quantum:>10,} {ratio:>10.1f}")
    print()


def demo_strict_quantum_advantage():
    """Demonstrate strict quantum advantage for NP(c) vs QMA(c)."""
    print("=" * 60)
    print("Demo 2: Strict Quantum Advantage — NP(c) vs QMA(c)")
    print("=" * 60)

    for c in [2, 3, 4]:
        np_class = classical_np(c)
        qma_class = quantum_qma(c)
        print(f"\nDegree c = {c}:")
        print(f"{'n':>6} {'NP(c)':>12} {'QMA(c)':>12} {'Compression':>12}")
        print("-" * 45)
        for n in [2, 5, 10, 50, 100]:
            np_len = np_class.proof_length_bound(n)
            qma_len = qma_class.proof_length_bound(n)
            ratio = np_len / qma_len if qma_len > 0 else float('inf')
            print(f"{n:>6} {np_len:>12,} {qma_len:>12,} {ratio:>12.1f}x")
    print()


def demo_pigeonhole_gap():
    """Demonstrate the pigeonhole witness gap."""
    print("=" * 60)
    print("Demo 3: Pigeonhole Witness Gap")
    print("=" * 60)
    print(f"{'n':>6} {'Classical':>12} {'Quantum':>12} {'Gap Ratio':>12}")
    print("-" * 45)

    for n in [2, 5, 10, 20, 50, 100, 500, 1000]:
        classical = pigeonhole_witness_space(n)
        quantum = pigeonhole_quantum_bound(n)
        ratio = classical / quantum if quantum > 0 else float('inf')
        print(f"{n:>6} {classical:>12,} {quantum:>12,} {ratio:>12.1f}x")
    print()


def demo_grover_compression():
    """Demonstrate the Grover compression as a ProofCompression morphism."""
    print("=" * 60)
    print("Demo 4: Grover Compression Morphism")
    print("=" * 60)

    for c in [2, 3]:
        gc = grover_compression(c)
        print(f"\nGrover compression NP({c}) → QMA({c}):")
        print(f"{'Input n':>8} {'Source':>10} {'Target':>10} {'Overhead':>10} {'Valid?':>8}")
        print("-" * 50)
        for n in [4, 10, 50, 100, 1000]:
            source_len = gc.source.proof_length_bound(n)
            target_len = gc.target.proof_length_bound(n)
            overhead = gc.overhead(source_len)
            valid = gc.verify_valid(n)
            print(f"{n:>8} {source_len:>10,} {target_len:>10,} {overhead:>10,} {'✓' if valid else '✗':>8}")
    print()


def demo_gap_amplification():
    """Demonstrate exponential gap from iterated amplification."""
    print("=" * 60)
    print("Demo 5: Gap Amplification")
    print("=" * 60)
    print(f"{'Rounds':>8} {'Base':>6} {'Total Gap':>15} {'2^rounds':>12} {'Valid':>8}")
    print("-" * 52)

    for rounds in range(1, 11):
        for base in [2, 3]:
            ga = GapAmplification(rounds, base)
            lower = 2 ** rounds
            valid = ga.verify_exponential_gap()
            print(f"{rounds:>8} {base:>6} {ga.total_factor:>15,} {lower:>12,} {'✓' if valid else '✗':>8}")
    print()


def demo_super_polynomial():
    """Demonstrate that exponentials dominate polynomials."""
    print("=" * 60)
    print("Demo 6: Super-Polynomial Advantage (2^n vs n^c)")
    print("=" * 60)

    for c in [2, 5, 10, 20]:
        threshold = find_super_poly_threshold(c)
        print(f"\nDegree c = {c}: threshold k₀ = {threshold}")
        print(f"  Theoretical bound: 2^(c+1) = {2**(c+1)}")
        print(f"  Verification at threshold:")
        for k in [threshold, threshold + 10, threshold + 100]:
            if k > 0 and k < 1000:  # Avoid overflow
                dominates = exp_dominates_poly(c, k)
                print(f"    k={k}: 2^k = {2**k:.2e}, k^{c} = {k**c:.2e}, "
                      f"2^k > k^{c}? {'Yes' if dominates else 'No'}")
    print()


def demo_conjecture_test():
    """Test the falsifiable conjecture: 2^k > k^10 for all k ≥ 2^11."""
    print("=" * 60)
    print("Demo 7: Conjecture Test — 2^k > k^10 for k ≥ 2048")
    print("=" * 60)

    c = 10
    k0 = 2 ** (c + 1)  # = 2048
    print(f"Testing: 2^k > k^{c} for k ≥ {k0}")

    # Test at several points
    test_points = [k0, k0 + 100, k0 + 1000, 5000, 10000]
    all_pass = True
    for k in test_points:
        result = exp_dominates_poly(c, k)
        status = "PASS" if result else "FAIL"
        all_pass = all_pass and result
        print(f"  k = {k:>6}: {status}")

    # Test near the boundary
    print(f"\nBoundary analysis (near k = {k0}):")
    for k in range(k0 - 5, k0 + 5):
        result = exp_dominates_poly(c, k)
        marker = " ← threshold" if k == k0 else ""
        print(f"  k = {k}: {'PASS' if result else 'FAIL'}{marker}")

    print(f"\nConjecture status: {'CONFIRMED' if all_pass else 'REFUTED'} "
          f"(all tested points {'pass' if all_pass else 'do not pass'})")
    print()


def demo_composition():
    """Demonstrate proof compression composition."""
    print("=" * 60)
    print("Demo 8: Proof Compression Composition")
    print("=" * 60)

    # Compose two Grover compressions
    gc2 = grover_compression(2)
    gc3 = grover_compression(3)

    # Identity composition
    id_comp = ProofCompression.identity(classical_np(2))
    composed = ProofCompression.compose(id_comp, gc2)

    print("Identity ∘ Grover(2) = Grover(2):")
    for n in [10, 100, 1000]:
        direct = gc2.overhead(gc2.source.proof_length_bound(n))
        via_comp = composed.overhead(composed.source.proof_length_bound(n))
        print(f"  n = {n}: direct overhead = {direct}, composed = {via_comp}")
    print()


if __name__ == "__main__":
    demo_grover_quadratic_bound()
    demo_strict_quantum_advantage()
    demo_pigeonhole_gap()
    demo_grover_compression()
    demo_gap_amplification()
    demo_super_polynomial()
    demo_conjecture_test()
    demo_composition()

    print("All demonstrations completed successfully.")


"""Visualization: Quantum vs Classical Proof Complexity"""
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_quantum_advantage():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Quantum Proof Complexity: Key Results', fontsize=16, fontweight='bold')

    # Plot 1: Grover Quadratic Bound
    ax = axes[0, 0]
    N_vals = np.arange(4, 1001)
    classical = N_vals.copy()
    quantum = np.array([int(math.isqrt(n)) + 1 for n in N_vals])
    ax.plot(N_vals, classical, 'r-', linewidth=2, label='Classical: N')
    ax.plot(N_vals, quantum, 'b-', linewidth=2, label='Quantum: √N + 1')
    ax.fill_between(N_vals, quantum, classical, alpha=0.2, color='green', label='Quantum Advantage')
    ax.set_xlabel('Search Space Size N')
    ax.set_ylabel('Query Complexity')
    ax.set_title("Grover's Quadratic Bound")
    ax.legend()
    ax.set_yscale('log')
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: NP(c) vs QMA(c)
    ax = axes[0, 1]
    n_vals = np.arange(2, 101)
    for c in [2, 3, 4]:
        np_len = n_vals ** c
        qma_len = np.array([int(math.isqrt(n ** c)) + 1 for n in n_vals])
        ax.plot(n_vals, np_len, '--', linewidth=1.5, label=f'NP({c})')
        ax.plot(n_vals, qma_len, '-', linewidth=2, label=f'QMA({c})')
    ax.set_xlabel('Input Size n')
    ax.set_ylabel('Proof Length')
    ax.set_title('Proof Complexity: NP(c) vs QMA(c)')
    ax.legend(fontsize=8)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 3: Pigeonhole Witness Gap
    ax = axes[1, 0]
    n_vals = np.arange(2, 201)
    classical_ph = np.array([n * (n + 1) // 2 for n in n_vals])
    quantum_ph = np.array([int(math.isqrt(n * (n + 1) // 2)) for n in n_vals])
    ratio_ph = classical_ph / np.maximum(quantum_ph, 1)
    ax.plot(n_vals, classical_ph, 'r-', linewidth=2, label='Classical: n(n+1)/2')
    ax.plot(n_vals, quantum_ph, 'b-', linewidth=2, label='Quantum: √(n(n+1)/2)')
    ax.plot(n_vals, n_vals, 'g--', linewidth=1, label='Linear: n')
    ax.set_xlabel('Number of Pigeons n')
    ax.set_ylabel('Witness Complexity')
    ax.set_title('Pigeonhole Witness Gap')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Super-polynomial advantage
    ax = axes[1, 1]
    k_vals = np.arange(1, 25)
    two_k = 2.0 ** k_vals
    for c in [1, 2, 3, 5]:
        k_c = k_vals.astype(float) ** c
        ax.plot(k_vals, k_c, '--', linewidth=1.5, label=f'k^{c}')
    ax.plot(k_vals, two_k, 'k-', linewidth=2.5, label='2^k')
    ax.set_xlabel('k')
    ax.set_ylabel('Value')
    ax.set_title('Exponentials Dominate Polynomials')
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_advantage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved quantum_advantage.png")

if __name__ == '__main__':
    plot_quantum_advantage()
