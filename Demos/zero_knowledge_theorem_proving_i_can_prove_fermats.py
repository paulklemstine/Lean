#!/usr/bin/env python3
"""
Zero-Knowledge Proof System Demonstrations

Demonstrates the key mathematical results from the formalization:
1. Soundness amplification via sequential repetition
2. Parallel composition with multiplicative errors
3. Query complexity for PCP-style proof oracles
4. Conjunction construction with inclusion-exclusion
"""

import math


def soundness_amplification(epsilon: float, k: int) -> float:
    """Compute soundness error after k-fold repetition."""
    return epsilon ** k


def detection_probability(n: int, q: int) -> float:
    """Probability of detecting a single corrupted step in n-step proof with q queries."""
    return 1.0 - ((n - 1) / n) ** q


def conjunction_error(eps1: float, eps2: float) -> float:
    """Conjunction soundness error via inclusion-exclusion."""
    return eps1 + eps2 - eps1 * eps2


def min_rounds_for_security(target_bits: int, base_error: float = 0.5) -> int:
    """Minimum rounds needed to achieve 2^{-target_bits} soundness error."""
    if base_error <= 0 or base_error >= 1:
        raise ValueError("Base error must be in (0, 1)")
    return math.ceil(target_bits * math.log(2) / math.log(1 / base_error))


def main():
    print("=" * 70)
    print("ZERO-KNOWLEDGE PROOF SYSTEM DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Soundness Amplification
    print("\n--- Demo 1: Soundness Amplification ---")
    print("Base soundness error ε = 0.5 (coin-flip security)")
    print(f"{'Rounds k':>10} | {'Error ε^k':>15} | {'Security bits':>15}")
    print("-" * 45)
    for k in [1, 5, 10, 20, 40, 80, 128, 256]:
        err = soundness_amplification(0.5, k)
        bits = -math.log2(err) if err > 0 else float('inf')
        print(f"{k:>10} | {err:>15.2e} | {bits:>15.1f}")

    # Demo 2: Parallel Composition
    print("\n--- Demo 2: Parallel Composition ---")
    print("Two independent protocols with errors ε₁, ε₂")
    print(f"{'ε₁':>8} | {'ε₂':>8} | {'ε₁·ε₂':>12} | {'Security gain':>15}")
    print("-" * 50)
    for e1, e2 in [(0.5, 0.5), (0.5, 0.3), (0.3, 0.3), (0.1, 0.1), (0.01, 0.01)]:
        product = e1 * e2
        gain = -math.log2(product) + math.log2(e1)
        print(f"{e1:>8.2f} | {e2:>8.2f} | {product:>12.4f} | {gain:>12.1f} bits")

    # Demo 3: Query Complexity for PCP
    print("\n--- Demo 3: PCP Query Complexity ---")
    print("Detecting a single corrupted step in an n-step proof")
    n = 1000
    print(f"Proof length n = {n}")
    print(f"{'Queries q':>10} | {'Detection prob':>15} | {'Escape prob':>15}")
    print("-" * 45)
    for q in [1, 10, 100, 1000, 5000, 10000]:
        p = detection_probability(n, q)
        print(f"{q:>10} | {p:>15.6f} | {1-p:>15.2e}")

    # Demo 4: Conjunction Construction
    print("\n--- Demo 4: Conjunction (Inclusion-Exclusion) ---")
    print(f"{'ε₁':>8} | {'ε₂':>8} | {'ε₁+ε₂':>10} | {'Conjunction':>12} | {'Saved':>10}")
    print("-" * 55)
    for e1, e2 in [(0.5, 0.5), (0.3, 0.4), (0.1, 0.1), (0.5, 0.1), (0.01, 0.01)]:
        naive = e1 + e2
        actual = conjunction_error(e1, e2)
        saved = naive - actual
        print(f"{e1:>8.2f} | {e2:>8.2f} | {naive:>10.4f} | {actual:>12.4f} | {saved:>10.4f}")

    # Demo 5: Communication Lower Bound
    print("\n--- Demo 5: Communication Lower Bounds ---")
    print("Minimum rounds for target security (base error = 1/2)")
    print(f"{'Target bits':>12} | {'Min rounds':>12} | {'Soundness error':>18}")
    print("-" * 48)
    for bits in [1, 8, 16, 32, 64, 128, 256]:
        rounds = min_rounds_for_security(bits)
        err = soundness_amplification(0.5, rounds)
        print(f"{bits:>12} | {rounds:>12} | {err:>18.2e}")

    # Demo 6: Exponential Decay Comparison
    print("\n--- Demo 6: Exponential Decay Comparison ---")
    print("Comparing ε^k for different base errors")
    print(f"{'k':>5} | {'ε=0.5':>12} | {'ε=0.3':>12} | {'ε=0.1':>12} | {'ε=0.01':>12}")
    print("-" * 60)
    for k in [1, 2, 5, 10, 20, 50]:
        vals = [soundness_amplification(e, k) for e in [0.5, 0.3, 0.1, 0.01]]
        print(f"{k:>5} | {vals[0]:>12.2e} | {vals[1]:>12.2e} | {vals[2]:>12.2e} | {vals[3]:>12.2e}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Soundness Amplification via Sequential Repetition

Shows how soundness error decays exponentially with the number of rounds.
"""

import matplotlib.pyplot as plt
import numpy as np


def plot_soundness_amplification():
    """Plot soundness error vs. number of rounds for various base errors."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: Linear scale
    ax = axes[0]
    k_vals = np.arange(1, 21)
    for eps in [0.9, 0.7, 0.5, 0.3, 0.1]:
        errors = eps ** k_vals
        ax.plot(k_vals, errors, 'o-', label=f'ε = {eps}', markersize=4)

    ax.set_xlabel('Number of rounds k', fontsize=12)
    ax.set_ylabel('Soundness error ε^k', fontsize=12)
    ax.set_title('Soundness Amplification (Linear Scale)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

    # Right plot: Log scale
    ax = axes[1]
    k_vals = np.arange(1, 51)
    for eps in [0.9, 0.7, 0.5, 0.3, 0.1]:
        errors = eps ** k_vals
        security_bits = -np.log2(errors)
        ax.plot(k_vals, security_bits, 'o-', label=f'ε = {eps}', markersize=3)

    ax.set_xlabel('Number of rounds k', fontsize=12)
    ax.set_ylabel('Security bits (-log₂(ε^k))', fontsize=12)
    ax.set_title('Security Level vs. Rounds', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Add reference lines for common security levels
    for bits, label in [(128, '128-bit'), (256, '256-bit')]:
        ax.axhline(y=bits, color='red', linestyle='--', alpha=0.5)
        ax.text(k_vals[-1] + 0.5, bits, label, fontsize=8, color='red', va='center')

    plt.tight_layout()
    plt.savefig('soundness_amplification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: soundness_amplification.png")


def plot_pcp_detection():
    """Plot PCP corruption detection probability vs. queries."""
    fig, ax = plt.subplots(figsize=(10, 6))

    q_vals = np.arange(0, 10001, 100)
    for n in [100, 500, 1000, 5000, 10000]:
        probs = 1 - ((n - 1) / n) ** q_vals
        ax.plot(q_vals, probs, label=f'n = {n} steps')

    ax.set_xlabel('Number of queries q', fontsize=12)
    ax.set_ylabel('Detection probability', fontsize=12)
    ax.set_title('PCP Corruption Detection: P(detect) = 1 - ((n-1)/n)^q', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Reference lines
    for p, label in [(0.99, '99%'), (0.999, '99.9%')]:
        ax.axhline(y=p, color='gray', linestyle=':', alpha=0.5)
        ax.text(q_vals[-1] * 0.95, p + 0.01, label, fontsize=8, color='gray')

    plt.tight_layout()
    plt.savefig('pcp_detection.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pcp_detection.png")


def plot_conjunction_error():
    """Plot conjunction error savings from inclusion-exclusion."""
    fig, ax = plt.subplots(figsize=(10, 6))

    eps_vals = np.linspace(0.01, 0.99, 100)
    for eps2 in [0.1, 0.3, 0.5, 0.7, 0.9]:
        naive = eps_vals + eps2
        actual = eps_vals + eps2 - eps_vals * eps2
        savings = naive - actual  # = eps1 * eps2
        ax.plot(eps_vals, savings, label=f'ε₂ = {eps2}')

    ax.set_xlabel('ε₁ (first protocol error)', fontsize=12)
    ax.set_ylabel('Error savings (ε₁·ε₂)', fontsize=12)
    ax.set_title('Conjunction: Savings from Inclusion-Exclusion', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('conjunction_savings.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conjunction_savings.png")


if __name__ == "__main__":
    plot_soundness_amplification()
    plot_pcp_detection()
    plot_conjunction_error()
    print("\nAll visualizations generated.")
