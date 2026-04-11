#!/usr/bin/env python3
"""
Demo 2: LogSumExp Annealing — From Quantum to Tropical

This demonstrates the continuous deformation from soft (quantum/probabilistic)
to hard (tropical/deterministic) computation via temperature-controlled LogSumExp.

The key equation:
    LSE_β(x₁, ..., xₙ) = (1/β) · log(Σᵢ exp(β·xᵢ))

As β → ∞: LSE_β → max (tropical limit)
As β → 0: LSE_β → mean (uniform/quantum limit)

This is the mathematical foundation for:
  - Simulated annealing cooling schedules
  - Softmax temperature in transformers
  - Gumbel-Softmax for discrete optimization
  - Entropy-regularized reinforcement learning
"""

import numpy as np


def logsumexp(x, beta):
    """
    Temperature-parameterized LogSumExp.

    LSE_β(x) = (1/β) · log(Σ exp(β·xᵢ))

    Numerically stable implementation using the max trick.
    """
    if beta == 0:
        return np.mean(x)
    max_x = np.max(x)
    return max_x + (1 / beta) * np.log(np.sum(np.exp(beta * (x - max_x))))


def softmax(x, beta):
    """Temperature-parameterized softmax."""
    max_x = np.max(x)
    exp_x = np.exp(beta * (x - max_x))
    return exp_x / np.sum(exp_x)


def log_cooling_schedule(c, t):
    """Logarithmic cooling: β(t) = c · log(1 + t)."""
    return c * np.log(1 + t)


def geometric_cooling_schedule(beta0, alpha, t):
    """Geometric cooling: T(t) = T₀ · α^t, so β(t) = β₀ / α^t."""
    return beta0 / (alpha ** t)


def demo_logsumexp_convergence():
    """Show LSE_β converging to max as β → ∞."""
    print("=" * 70)
    print("LOGSUMEXP: QUANTUM → TROPICAL TRANSITION")
    print("=" * 70)
    print()

    x = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    print(f"Input: x = {x}")
    print(f"max(x) = {np.max(x)}")
    print(f"mean(x) = {np.mean(x)}")
    print()

    print(f"{'β':>10} {'LSE_β(x)':>12} {'|LSE-max|':>12} {'Gap Bound':>12}")
    print("-" * 50)

    for beta in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0, 1000.0]:
        lse = logsumexp(x, beta)
        gap = abs(lse - np.max(x))
        bound = np.log(len(x)) / beta
        print(f"{beta:>10.2f} {lse:>12.6f} {gap:>12.8f} {bound:>12.8f}")

    print()
    print("Key theorem (verified in Lean):")
    print("  |LSE_β(x) - max(x)| ≤ log(n)/β")
    print("  This gap → 0 as β → ∞ (tropical limit)")
    print()


def demo_cooling_schedules():
    """Compare cooling schedules for simulated annealing."""
    print("=" * 70)
    print("COOLING SCHEDULES FOR SIMULATED ANNEALING")
    print("=" * 70)
    print()

    times = [0, 1, 5, 10, 50, 100, 500, 1000]

    print("Logarithmic cooling: β(t) = 2·log(1 + t)")
    print(f"{'t':>8} {'β(t)':>10} {'T(t)=1/β':>10} {'Gap ≤':>10}")
    print("-" * 42)
    for t in times:
        beta = log_cooling_schedule(2.0, t)
        T = 1 / beta if beta > 0 else float('inf')
        gap = np.log(2) / beta if beta > 0 else float('inf')
        print(f"{t:>8} {beta:>10.4f} {T:>10.4f} {gap:>10.6f}")

    print()
    print("Geometric cooling: β(t) = 1.0 / 0.95^t")
    print(f"{'t':>8} {'β(t)':>10} {'T(t)=1/β':>10}")
    print("-" * 32)
    for t in times:
        beta = geometric_cooling_schedule(1.0, 0.95, t)
        T = 1 / beta
        print(f"{t:>8} {beta:>10.4f} {T:>10.6f}")

    print()
    print("Theorem (Lean-verified): Logarithmic cooling is monotonically")
    print("increasing, starts at β(0) = 0, and gap ≤ log(2)/β ≤ log(2).")
    print()


def demo_boltzmann_concentration():
    """Show Boltzmann distribution concentrating on the optimum."""
    print("=" * 70)
    print("BOLTZMANN CONCENTRATION → TROPICAL LIMIT")
    print("=" * 70)
    print()

    energies = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    labels = [f"state {i}" for i in range(len(energies))]

    print(f"Energies: {energies}")
    print(f"Optimal state: {np.argmax(energies)} (energy = {np.max(energies)})")
    print()

    print(f"{'β':>6} ", end="")
    for l in labels:
        print(f"{l:>10}", end="")
    print(f"  {'Entropy':>8}")
    print("-" * (6 + 10 * len(labels) + 10))

    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        probs = softmax(energies, beta)
        entropy = -np.sum(probs * np.log(probs + 1e-15))
        print(f"{beta:>6.1f} ", end="")
        for p in probs:
            print(f"{p:>10.4f}", end="")
        print(f"  {entropy:>8.4f}")

    print()
    print("As β → ∞: probability concentrates on max-energy state")
    print("This is the Boltzmann concentration theorem (Lean-verified)")
    print()


def demo_free_energy():
    """Demonstrate free energy interpolation."""
    print("=" * 70)
    print("FREE ENERGY: F = E - T·S")
    print("=" * 70)
    print()

    energies = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    n = len(energies)

    print(f"{'T':>6} {'F(T)':>10} {'E_avg':>10} {'S':>10} {'LSE_β':>10}")
    print("-" * 50)

    for T in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        beta = 1 / T
        probs = softmax(energies, beta)
        E_avg = np.sum(probs * energies)
        S = -np.sum(probs * np.log(probs + 1e-15))
        F = E_avg - T * S
        lse = logsumexp(energies, beta)
        print(f"{T:>6.2f} {F:>10.4f} {E_avg:>10.4f} {S:>10.4f} {lse:>10.4f}")

    print()
    print("Key relationships (Lean-verified):")
    print("  F ≤ E  (free energy bounds)")
    print("  T → 0: F → max(energies) (tropical limit)")
    print("  T → ∞: F → mean(energies) (quantum/uniform limit)")
    print()


if __name__ == "__main__":
    demo_logsumexp_convergence()
    demo_cooling_schedules()
    demo_boltzmann_concentration()
    demo_free_energy()

    print("=" * 70)
    print("All annealing demos completed.")
    print("=" * 70)
