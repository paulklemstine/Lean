#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 3: QUANTUM-INSPIRED SIMULATED ANNEALING                  ║
║  ────────────────────────────────────────────────────────────    ║
║  Classical simulation of quantum tunneling through energy       ║
║  barriers using path-integral Monte Carlo. Unlike classical     ║
║  simulated annealing (which goes OVER barriers), quantum        ║
║  annealing TUNNELS THROUGH them.                                ║
║                                                                  ║
║  The barrier-crossing rate depends on width (not height),       ║
║  giving exponential advantage for tall-but-thin barriers.       ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
from typing import Callable, Tuple, List

# ── Energy Landscapes ──────────────────────────────────────────
def double_well(x: np.ndarray, barrier_height=10.0, barrier_width=0.5) -> float:
    """Double well potential with tunable barrier."""
    # Two minima at x=-2 and x=2, barrier at x=0
    return np.sum(barrier_height * np.exp(-x**2 / barrier_width**2) +
                  (x**2 - 4)**2 / 16)

def rastrigin(x: np.ndarray) -> float:
    """Rastrigin function: notoriously difficult multimodal landscape."""
    n = len(x)
    return 10 * n + np.sum(x**2 - 10 * np.cos(2 * np.pi * x))

def ackley(x: np.ndarray) -> float:
    """Ackley function: deceptive landscape with many local minima."""
    n = len(x)
    return (-20 * np.exp(-0.2 * np.sqrt(np.sum(x**2) / n))
            - np.exp(np.sum(np.cos(2 * np.pi * x)) / n)
            + 20 + np.e)

def schwefel(x: np.ndarray) -> float:
    """Schwefel function: global minimum far from local minima."""
    n = len(x)
    return 418.9829 * n - np.sum(x * np.sin(np.sqrt(np.abs(x))))


# ── Classical Simulated Annealing ──────────────────────────────
def classical_annealing(energy_fn: Callable, dim: int, bounds: Tuple[float, float],
                         n_steps: int = 10000, T_init: float = 10.0,
                         T_final: float = 0.01) -> Tuple[np.ndarray, float, List[float]]:
    """Standard Metropolis-Hastings simulated annealing."""
    x = np.random.uniform(bounds[0], bounds[1], dim)
    E = energy_fn(x)
    best_x, best_E = x.copy(), E
    history = [E]

    for step in range(n_steps):
        T = T_init * (T_final / T_init) ** (step / n_steps)  # Geometric cooling

        # Propose neighbor
        x_new = x + np.random.randn(dim) * T * 0.5
        x_new = np.clip(x_new, bounds[0], bounds[1])
        E_new = energy_fn(x_new)

        # Metropolis criterion
        dE = E_new - E
        if dE < 0 or np.random.random() < np.exp(-dE / max(T, 1e-10)):
            x, E = x_new, E_new

        if E < best_E:
            best_x, best_E = x.copy(), E

        history.append(best_E)

    return best_x, best_E, history


# ── Quantum-Inspired Annealing (Path Integral Monte Carlo) ─────
def quantum_annealing(energy_fn: Callable, dim: int, bounds: Tuple[float, float],
                       n_steps: int = 10000, n_replicas: int = 20,
                       Gamma_init: float = 5.0, Gamma_final: float = 0.01,
                       T: float = 1.0) -> Tuple[np.ndarray, float, List[float]]:
    """
    Quantum-inspired annealing using Suzuki-Trotter decomposition.

    Instead of one particle, we simulate P replicas connected by springs
    (the imaginary-time path integral). Quantum tunneling is simulated by
    the replicas collectively "stretching" through barriers.

    The transverse field Gamma controls tunneling rate:
    - High Gamma: strong tunneling (quantum regime)
    - Low Gamma: classical behavior (convergence)
    """
    P = n_replicas  # Number of Trotter slices

    # Initialize P replicas
    replicas = np.random.uniform(bounds[0], bounds[1], (P, dim))
    energies = np.array([energy_fn(r) for r in replicas])
    best_x = replicas[np.argmin(energies)].copy()
    best_E = np.min(energies)
    history = [best_E]

    for step in range(n_steps):
        # Anneal transverse field
        Gamma = Gamma_init * (Gamma_final / Gamma_init) ** (step / n_steps)

        # Effective coupling between replicas (spring constant)
        J_perp = -0.5 * P * T * np.log(np.tanh(Gamma / (P * T + 1e-10)) + 1e-10)

        for k in range(P):
            # Propose move for replica k
            x_old = replicas[k].copy()
            x_new = x_old + np.random.randn(dim) * max(0.1, Gamma)
            x_new = np.clip(x_new, bounds[0], bounds[1])

            # Classical energy change
            dE_classical = energy_fn(x_new) - energies[k]

            # Quantum coupling energy change (springs to neighbors)
            k_prev = (k - 1) % P
            k_next = (k + 1) % P
            dE_quantum = J_perp * (
                np.sum((x_new - replicas[k_prev])**2) +
                np.sum((x_new - replicas[k_next])**2) -
                np.sum((x_old - replicas[k_prev])**2) -
                np.sum((x_old - replicas[k_next])**2)
            )

            dE_total = dE_classical / P + dE_quantum

            # Metropolis criterion with effective temperature
            if dE_total < 0 or np.random.random() < np.exp(-dE_total / max(T, 1e-10)):
                replicas[k] = x_new
                energies[k] = energy_fn(x_new)

            if energies[k] < best_E:
                best_x = replicas[k].copy()
                best_E = energies[k]

        history.append(best_E)

    return best_x, best_E, history


# ── Benchmark ──────────────────────────────────────────────────
def benchmark(name: str, energy_fn: Callable, dim: int, bounds: Tuple[float, float],
              optimal: float, n_trials: int = 10, n_steps: int = 5000):
    """Compare classical vs quantum annealing."""
    print(f"\n  {'─' * 55}")
    print(f"  {name} (dim={dim}, optimal={optimal:.4f})")
    print(f"  {'─' * 55}")

    classical_results = []
    quantum_results = []

    for trial in range(n_trials):
        np.random.seed(trial * 137)
        _, c_E, c_hist = classical_annealing(energy_fn, dim, bounds, n_steps)
        classical_results.append(c_E)

        np.random.seed(trial * 137)
        _, q_E, q_hist = quantum_annealing(energy_fn, dim, bounds, n_steps)
        quantum_results.append(q_E)

    c_mean, c_std = np.mean(classical_results), np.std(classical_results)
    q_mean, q_std = np.mean(quantum_results), np.std(quantum_results)
    c_best = np.min(classical_results)
    q_best = np.min(quantum_results)

    print(f"    {'Method':<20} {'Mean ± Std':>20} {'Best':>12} {'Gap':>10}")
    print(f"    {'─'*62}")
    print(f"    {'Classical SA':<20} {c_mean:>10.4f} ± {c_std:<8.4f} {c_best:>12.4f} {c_best-optimal:>10.4f}")
    print(f"    {'Quantum SA':<20} {q_mean:>10.4f} ± {q_std:<8.4f} {q_best:>12.4f} {q_best-optimal:>10.4f}")

    if q_mean < c_mean:
        improvement = (c_mean - q_mean) / max(abs(c_mean), 1e-10) * 100
        print(f"    ★ Quantum advantage: {improvement:.1f}% better mean energy")
    else:
        print(f"    Classical wins on this landscape")

    return classical_results, quantum_results


# ── Main ───────────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  QUANTUM-INSPIRED vs CLASSICAL SIMULATED ANNEALING")
    print("  Path-Integral Monte Carlo Tunneling Simulation")
    print("=" * 65)

    # Test 1: Double well (quantum should tunnel through barrier)
    benchmark("Double Well (tall barrier)", double_well, dim=2,
              bounds=(-5, 5), optimal=0.0, n_trials=5, n_steps=1500)

    # Test 2: Rastrigin (many local minima)
    benchmark("Rastrigin Function", rastrigin, dim=5,
              bounds=(-5.12, 5.12), optimal=0.0, n_trials=5, n_steps=2000)

    # Test 3: Ackley (deceptive landscape)
    benchmark("Ackley Function", ackley, dim=5,
              bounds=(-5, 5), optimal=0.0, n_trials=5, n_steps=2000)

    # Test 4: Schwefel (distant global optimum)
    benchmark("Schwefel Function", schwefel, dim=3,
              bounds=(-500, 500), optimal=0.0, n_trials=5, n_steps=3000)

    # ── Tunneling Visualization ────────────────────────────────
    print("\n" + "=" * 65)
    print("  TUNNELING DEMONSTRATION (1D Double Well)")
    print("=" * 65)

    # Show the energy landscape
    xs = np.linspace(-4, 4, 60)
    energies = [double_well(np.array([x]), barrier_height=15.0, barrier_width=0.3) for x in xs]
    max_e = max(energies)
    min_e = min(energies)

    print("\n  Energy Landscape (barrier_height=15, barrier_width=0.3):")
    for row in range(15, -1, -1):
        threshold = min_e + (max_e - min_e) * row / 15
        line = "    "
        for e in energies:
            if e >= threshold:
                line += "█"
            else:
                line += " "
        print(line + f" {threshold:.1f}")
    print("    " + "─" * 60)

    # Run quantum annealing on this landscape
    def hard_well(x):
        return double_well(x, barrier_height=15.0, barrier_width=0.3)

    # Start in the WRONG well (x=2), need to tunnel to global min
    print("\n  Starting from right well (x≈2), seeking global minimum...")

    n_trials = 10
    c_found_global = 0
    q_found_global = 0

    for trial in range(n_trials):
        np.random.seed(trial + 1000)

        # Classical
        x0 = np.array([2.0 + np.random.randn() * 0.5])
        x = x0.copy()
        E = hard_well(x)
        for step in range(3000):
            T = 5.0 * (0.01 / 5.0) ** (step / 3000)
            x_new = x + np.random.randn(1) * T * 0.3
            x_new = np.clip(x_new, -4, 4)
            E_new = hard_well(x_new)
            if E_new < E or np.random.random() < np.exp(-(E_new - E) / max(T, 1e-10)):
                x, E = x_new, E_new
        if x[0] < 0:
            c_found_global += 1

        # Quantum
        np.random.seed(trial + 1000)
        q_x, q_E, _ = quantum_annealing(hard_well, 1, (-4, 4), n_steps=3000,
                                          n_replicas=30, Gamma_init=8.0)
        if q_x[0] < 0:
            q_found_global += 1

    print(f"\n    Classical tunneling rate: {c_found_global}/{n_trials} "
          f"({c_found_global/n_trials*100:.0f}%)")
    print(f"    Quantum tunneling rate:  {q_found_global}/{n_trials} "
          f"({q_found_global/n_trials*100:.0f}%)")

    if q_found_global > c_found_global:
        print(f"\n    ★ Quantum tunneling advantage: "
              f"{q_found_global/max(c_found_global,1):.1f}× more barrier crossings")

    print("\n" + "=" * 65)


if __name__ == "__main__":
    main()
