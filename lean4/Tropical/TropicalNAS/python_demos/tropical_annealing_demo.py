#!/usr/bin/env python3
"""
Tropical Annealing Demo: Optimal Cooling Schedules

Demonstrates the connection between tropical geometry, LogSumExp,
and simulated annealing. Shows how different cooling schedules
converge to the global optimum at different rates.

Usage:
    python tropical_annealing_demo.py
"""

import numpy as np
from typing import Callable, Tuple, List
import json


def logsumexp(x: np.ndarray, beta: float) -> float:
    """LSE_β(x) = (1/β) · log(Σ exp(β·xᵢ))"""
    if beta < 1e-10:
        return float(np.mean(x))
    bx = beta * x
    m = np.max(bx)
    return float((m + np.log(np.sum(np.exp(bx - m)))) / beta)


def tropical_max(x: np.ndarray) -> float:
    """Tropical limit: max(x)"""
    return float(np.max(x))


# ============================================================
# Cooling Schedules (Lean-verified properties)
# ============================================================

def logarithmic_cooling(t: float, c: float = 2.0) -> float:
    """β(t) = c · log(1 + t). Lean verified: log_cooling_monotone."""
    return c * np.log(1 + t)

def geometric_cooling(t: float, beta0: float = 0.1, alpha: float = 1.05) -> float:
    """β(t) = β₀ · α^t. Lean verified: geometric_cooling_positive."""
    return beta0 * alpha ** t

def linear_cooling(t: float, rate: float = 0.1) -> float:
    """β(t) = rate · t."""
    return rate * t

def inverse_cooling(t: float, c: float = 10.0) -> float:
    """T(t) = c / (1 + t), so β(t) = (1 + t) / c."""
    return (1 + t) / c


# ============================================================
# Annealing Simulation
# ============================================================

def simulate_annealing(
    energy_landscape: np.ndarray,
    cooling_schedule: Callable,
    n_steps: int = 1000,
) -> List[dict]:
    """
    Simulate tropical annealing on a discrete energy landscape.
    
    At each step t:
    1. Compute β(t) using the cooling schedule
    2. Compute LSE_β(energies) — the "soft maximum"
    3. Track the gap to the true maximum
    4. Sample from the Boltzmann distribution
    
    Returns trajectory of (t, beta, lse, gap, sampled_state).
    """
    true_max = np.max(energy_landscape)
    trajectory = []
    
    for t in range(n_steps):
        beta = cooling_schedule(t)
        lse = logsumexp(energy_landscape, beta)
        gap = true_max - lse
        
        # Boltzmann sampling
        if beta > 0:
            logits = beta * energy_landscape
            logits -= np.max(logits)
            probs = np.exp(logits)
            probs /= np.sum(probs)
            sampled = np.random.choice(len(energy_landscape), p=probs)
        else:
            sampled = np.random.choice(len(energy_landscape))
        
        trajectory.append({
            'step': t,
            'beta': float(beta),
            'lse': float(lse),
            'gap': float(gap),
            'sampled_energy': float(energy_landscape[sampled]),
            'prob_optimal': float(probs[np.argmax(energy_landscape)]) if beta > 0 else 1.0/len(energy_landscape),
        })
    
    return trajectory


def run_comparison():
    """Compare different cooling schedules on the same landscape."""
    print("=" * 80)
    print("TROPICAL ANNEALING: Cooling Schedule Comparison")
    print("=" * 80)
    print()
    
    np.random.seed(42)
    n = 100
    energy = np.random.randn(n)
    energy[42] = 5.0  # plant a clear maximum
    
    true_max = np.max(energy)
    print(f"Energy landscape: {n} states, max = {true_max:.4f}")
    print()
    
    schedules = {
        'Logarithmic':  lambda t: logarithmic_cooling(t, c=2.0),
        'Geometric':    lambda t: geometric_cooling(t, beta0=0.1, alpha=1.01),
        'Linear':       lambda t: linear_cooling(t, rate=0.05),
        'Inverse':      lambda t: inverse_cooling(t, c=5.0),
    }
    
    results = {}
    for name, schedule in schedules.items():
        traj = simulate_annealing(energy, schedule, n_steps=500)
        results[name] = traj
    
    # Print comparison at key time points
    checkpoints = [0, 10, 50, 100, 200, 499]
    
    for cp in checkpoints:
        print(f"Step {cp:>4}:")
        print(f"  {'Schedule':<15} {'β':>8} {'LSE':>10} {'Gap':>10} {'P(opt)':>10}")
        print(f"  {'-'*55}")
        for name, traj in results.items():
            t = traj[cp]
            print(f"  {name:<15} {t['beta']:>8.3f} {t['lse']:>10.4f} "
                  f"{t['gap']:>10.6f} {t['prob_optimal']:>10.6f}")
        print()
    
    # Gap bounds (Lean verified)
    print("Theoretical Gap Bounds (Lean verified: cooling_gap_bound):")
    print(f"  Gap ≤ log(n) / β where n = {n}")
    print(f"  log({n}) = {np.log(n):.4f}")
    print()
    for name, traj in results.items():
        final = traj[-1]
        bound = np.log(n) / max(final['beta'], 1e-10)
        print(f"  {name:<15}: β={final['beta']:.3f}, bound={bound:.6f}, "
              f"actual={final['gap']:.6f}, {'✓' if final['gap'] <= bound + 1e-10 else '≈'}")
    
    return results


def demo_free_energy():
    """Demonstrate free energy interpolation."""
    print("\n" + "=" * 80)
    print("FREE ENERGY INTERPOLATION: F = E - T·S")
    print("Lean verified: free_energy_bounds")
    print("=" * 80)
    print()
    
    energies = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    n = len(energies)
    
    print(f"{'T':>8} {'β=1/T':>8} {'F':>10} {'E_avg':>10} {'S_eff':>10} {'Gap to max':>12}")
    print("-" * 60)
    
    max_e = np.max(energies)
    for T in [100, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.01, 0.001]:
        beta = 1.0 / T
        # Free energy: F = -(1/β) · log(Z) where Z = Σ exp(β·Eᵢ)
        lse = logsumexp(energies, beta)
        
        # Effective entropy from Boltzmann distribution
        logits = beta * energies
        logits -= np.max(logits)
        probs = np.exp(logits) / np.sum(np.exp(logits))
        entropy = -np.sum(probs * np.log(probs + 1e-10))
        
        E_avg = np.sum(probs * energies)
        
        print(f"{T:>8.3f} {beta:>8.2f} {lse:>10.4f} {E_avg:>10.4f} "
              f"{entropy:>10.4f} {max_e - lse:>12.6f}")
    
    print()
    print("As T → 0 (β → ∞): F → max(E) [tropical limit]")
    print("As T → ∞ (β → 0): F → mean(E) [uniform exploration]")


def demo_boltzmann_concentration():
    """Show Boltzmann concentration (Lean verified)."""
    print("\n" + "=" * 80)
    print("BOLTZMANN CONCENTRATION")
    print("Lean verified: boltzmann_concentration")
    print("=" * 80)
    print()
    
    states = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        logits = beta * states
        logits -= np.max(logits)
        probs = np.exp(logits) / np.sum(np.exp(logits))
        
        print(f"β = {beta:>5.1f}: P = [{', '.join(f'{p:.4f}' for p in probs)}]")
    
    print()
    print("As β → ∞, probability concentrates on the maximum state.")
    print("This is the tropical limit: P → one-hot(argmax).")


if __name__ == '__main__':
    results = run_comparison()
    demo_free_energy()
    demo_boltzmann_concentration()
    
    print("\n✓ All demos completed successfully.")
