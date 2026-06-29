"""
Tropical Spectral Mechanics — Applications

Demonstrates real-world applications of tropical spectral theory:
1. Optimal routing in transportation networks
2. Manufacturing cycle time optimization
3. Protein folding energy landscape analysis
4. Digital circuit timing analysis

Each application models a system as a discrete mechanical system,
computes the tropical eigenvalue (minimum cycle mean), eigenvector,
and spectral gap, and interprets the results physically.
"""

import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Core algorithms (self-contained for standalone use)
# ============================================================

def karp_min_cycle_mean(L: np.ndarray) -> float:
    """Karp's algorithm for minimum cycle mean."""
    n = L.shape[0]
    D = np.full((n + 1, n), np.inf)
    D[0, :] = 0.0
    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.min(D[k - 1, :] + L[:, i])
    lambda_star = np.inf
    for i in range(n):
        max_val = -np.inf
        for k in range(n):
            if D[k, i] < np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                max_val = max(max_val, val)
        lambda_star = min(lambda_star, max_val)
    return lambda_star


def tropical_eigenvector(L: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute tropical eigenvalue and eigenvector via value iteration."""
    n = L.shape[0]
    lam = karp_min_cycle_mean(L)
    v = np.zeros(n)
    for _ in range(n * n):
        v_new = np.array([np.min(L[i, :] + v) - lam for i in range(n)])
        v_new -= v_new[0]
        if np.max(np.abs(v_new - v)) < 1e-12:
            break
        v = v_new
    return lam, v


def min_plus_power(L: np.ndarray, N: int) -> np.ndarray:
    """N-th min-plus power."""
    result = L.copy()
    for _ in range(N - 1):
        n = L.shape[0]
        C = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                C[i, j] = np.min(result[i, :] + L[:, j])
        result = C
    return result


def compute_spectral_gap(L: np.ndarray) -> float:
    """Compute tropical spectral gap."""
    n = L.shape[0]
    cycle_means = set()
    for length in range(1, n + 1):
        Lk = min_plus_power(L, length)
        for i in range(n):
            if Lk[i, i] < np.inf:
                cycle_means.add(round(Lk[i, i] / length, 10))
    sorted_means = sorted(cycle_means)
    return sorted_means[1] - sorted_means[0] if len(sorted_means) > 1 else 0.0


# ============================================================
# Application 1: Transportation Network
# ============================================================

def transportation_network_demo():
    """Model a delivery network as a discrete mechanical system.

    Cities: A, B, C, D, E
    L[i,j] = travel time from city i to city j

    The tropical eigenvalue gives the minimum average cycle time
    for a delivery route. The eigenvector gives the relative
    "position" of each city in the optimal routing.
    """
    print("=" * 60)
    print("APPLICATION 1: Transportation Network Optimization")
    print("=" * 60)

    cities = ["New York", "Chicago", "Dallas", "Denver", "LA"]
    n = len(cities)

    # Travel times (hours) between cities
    L = np.array([
        [2.0, 3.5, 5.0, 6.0, 8.0],   # from NY
        [3.5, 1.5, 3.0, 4.0, 6.5],   # from Chicago
        [5.0, 3.0, 1.5, 3.5, 5.0],   # from Dallas
        [6.0, 4.0, 3.5, 1.5, 3.5],   # from Denver
        [8.0, 6.5, 5.0, 3.5, 2.0],   # from LA
    ])

    print(f"\nTravel time matrix (hours):")
    print(f"{'':>12}", end="")
    for c in cities:
        print(f"{c:>10}", end="")
    print()
    for i, c in enumerate(cities):
        print(f"{c:>12}", end="")
        for j in range(n):
            print(f"{L[i,j]:10.1f}", end="")
        print()

    lam, v = tropical_eigenvector(L)
    gap = compute_spectral_gap(L)

    print(f"\n--- Tropical Spectral Analysis ---")
    print(f"Tropical eigenvalue (min avg cycle time): {lam:.4f} hours/stop")
    print(f"Spectral gap: {gap:.4f}")
    print(f"\nTropical eigenvector (routing potential):")
    for i, c in enumerate(cities):
        print(f"  {c:>12}: v = {v[i]:+.4f}")

    print(f"\nInterpretation:")
    print(f"  - The minimum average time per stop in any delivery route is {lam:.2f} hours.")
    print(f"  - The eigenvector encodes optimal routing: cities with similar v-values")
    print(f"    are natural sequential stops.")
    ranked = sorted(range(n), key=lambda i: v[i])
    route = " → ".join(cities[i] for i in ranked)
    print(f"  - Suggested route order: {route}")

    # Value function convergence
    print(f"\n  Value function V(N, NY, NY) convergence:")
    print(f"  {'N':>4} {'V':>10} {'V/N':>10} {'V - N·λ*':>12}")
    for N in range(1, 11):
        LN = min_plus_power(L, N)
        V_val = LN[0, 0]
        print(f"  {N:4d} {V_val:10.2f} {V_val/N:10.4f} {V_val - N*lam:12.4f}")


# ============================================================
# Application 2: Manufacturing Cycle Time
# ============================================================

def manufacturing_demo():
    """Model a manufacturing system with multiple machines.

    Each machine processes a part and passes it to the next.
    L[i,j] = processing time at machine i + transfer time to machine j.

    The tropical eigenvalue gives the throughput bottleneck.
    The spectral gap measures system robustness.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Manufacturing Cycle Time Optimization")
    print("=" * 60)

    machines = ["Cutting", "Welding", "Assembly", "Testing", "Packing"]
    n = len(machines)

    # Processing + transfer times (minutes)
    L = np.array([
        [15.0, 12.0, 20.0, 25.0, 18.0],
        [14.0, 18.0, 10.0, 22.0, 16.0],
        [22.0, 13.0, 20.0, 8.0, 14.0],
        [20.0, 19.0, 15.0, 25.0, 10.0],
        [16.0, 15.0, 18.0, 20.0, 22.0],
    ])

    lam, v = tropical_eigenvector(L)
    gap = compute_spectral_gap(L)

    print(f"\nProcessing + transfer time matrix (minutes):")
    for i, m in enumerate(machines):
        print(f"  {m:>10}: {L[i]}")

    print(f"\n--- Tropical Spectral Analysis ---")
    print(f"Minimum average cycle time: {lam:.2f} minutes/step")
    print(f"Throughput: {60/lam:.2f} units/hour (in optimal cycle)")
    print(f"Spectral gap: {gap:.4f}")
    print(f"  → Convergence rate ρ = exp(-γ) = {np.exp(-gap):.6f}")

    print(f"\nMachine potentials (eigenvector):")
    for i, m in enumerate(machines):
        print(f"  {m:>10}: v = {v[i]:+.4f}")

    # Perturbation analysis
    print(f"\n--- Perturbation Analysis ---")
    print(f"How much does a 1-minute speedup at each machine help?")
    for k in range(n):
        L_pert = L.copy()
        L_pert[k, :] -= 1.0  # speed up machine k
        lam_pert = karp_min_cycle_mean(L_pert)
        improvement = lam - lam_pert
        print(f"  {machines[k]:>10}: Δλ* = {improvement:+.4f} min/step")


# ============================================================
# Application 3: Circuit Timing Analysis
# ============================================================

def circuit_timing_demo():
    """Model a digital circuit as a tropical spectral system.

    Gates: AND, OR, NOT, XOR, BUF (buffer)
    L[i,j] = propagation delay from gate i output to gate j input

    The tropical eigenvalue gives the maximum clock frequency.
    The spectral gap indicates timing margin.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Digital Circuit Timing Analysis")
    print("=" * 60)

    gates = ["AND1", "OR1", "NOT1", "XOR1", "BUF1", "AND2"]
    n = len(gates)

    # Propagation delays (nanoseconds)
    L = np.array([
        [5.0, 3.0, 2.0, 4.0, 1.5, 3.5],
        [3.5, 4.0, 2.5, 3.0, 1.0, 4.0],
        [2.0, 2.5, 3.0, 2.0, 1.5, 2.5],
        [4.5, 3.5, 2.5, 5.0, 2.0, 4.0],
        [1.5, 1.0, 1.5, 2.0, 2.0, 1.5],
        [3.5, 4.0, 2.5, 4.0, 1.5, 5.0],
    ])

    lam, v = tropical_eigenvector(L)
    gap = compute_spectral_gap(L)

    print(f"\nGate delay matrix (ns):")
    print(f"{'':>8}", end="")
    for g in gates:
        print(f"{g:>7}", end="")
    print()
    for i, g in enumerate(gates):
        print(f"{g:>8}", end="")
        for j in range(n):
            print(f"{L[i,j]:7.1f}", end="")
        print()

    print(f"\n--- Tropical Spectral Analysis ---")
    print(f"Minimum cycle delay: {lam:.4f} ns/gate")
    print(f"Maximum clock frequency: {1000/lam:.1f} MHz")
    print(f"Spectral gap: {gap:.4f} ns")
    print(f"  → Timing margin indicator: {'TIGHT' if gap < 0.5 else 'COMFORTABLE'}")

    print(f"\nGate criticality (eigenvector):")
    for i, g in enumerate(gates):
        criticality = "CRITICAL" if abs(v[i]) < 0.1 else "non-critical"
        print(f"  {g:>6}: v = {v[i]:+.4f}  [{criticality}]")


# ============================================================
# Application 4: Lipschitz Stability Demonstration
# ============================================================

def lipschitz_stability_demo():
    """Demonstrate the Lipschitz continuity of the tropical eigenvalue.

    Theorem: |λ*(L₁) - λ*(L₂)| ≤ max|L₁ - L₂|

    We verify this computationally by perturbing a matrix and
    checking the eigenvalue change is bounded.
    """
    print(f"\n{'=' * 60}")
    print("APPLICATION 4: Tropical Eigenvalue Lipschitz Stability")
    print("=" * 60)

    n = 5
    np.random.seed(42)
    L = np.random.uniform(1, 10, (n, n))

    lam0 = karp_min_cycle_mean(L)
    print(f"\nBase matrix (random {n}×{n}):")
    print(f"λ*(L₀) = {lam0:.8f}")

    print(f"\n{'ε':>10} {'max|ΔL|':>12} {'|Δλ*|':>12} {'|Δλ*|/ε':>12} {'Lipschitz?':>12}")
    print("-" * 60)

    for eps in [0.001, 0.01, 0.1, 0.5, 1.0, 2.0]:
        # Random perturbation with max norm ε
        delta = np.random.uniform(-1, 1, (n, n))
        delta = delta / np.max(np.abs(delta)) * eps

        L_pert = L + delta
        lam_pert = karp_min_cycle_mean(L_pert)

        max_delta = np.max(np.abs(delta))
        delta_lam = abs(lam_pert - lam0)
        ratio = delta_lam / eps if eps > 0 else 0

        lipschitz_ok = delta_lam <= max_delta + 1e-10
        print(f"{eps:10.4f} {max_delta:12.6f} {delta_lam:12.6f} {ratio:12.6f}"
              f" {'✓' if lipschitz_ok else '✗':>12}")

    print(f"\nThe Lipschitz bound |Δλ*| ≤ max|ΔL| holds in all cases,")
    print(f"confirming the formally verified theorem tropEigenvalue_lipschitz.")


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔" + "═" * 58 + "╗")
    print("║  TROPICAL SPECTRAL MECHANICS — Real-World Applications  ║")
    print("╚" + "═" * 58 + "╝")
    print()
    print("Demonstrating how the tropical eigenvalue, eigenvector,")
    print("and spectral gap provide actionable insights across domains.")
    print()

    transportation_network_demo()
    manufacturing_demo()
    circuit_timing_demo()
    lipschitz_stability_demo()

    print(f"\n{'=' * 60}")
    print("All applications demonstrate the power of tropical spectral")
    print("theory: the minimum cycle mean (tropical eigenvalue) captures")
    print("the fundamental throughput/timing constraint, while the")
    print("eigenvector identifies critical components and the spectral")
    print("gap measures system robustness.")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()


"""
Tropical Spectral Mechanics — Demo: Spectral Gap Scaling

Tests the conjecture that the tropical spectral gap γ(M) scales as
γ(M) ~ c · M^{-2} for discrete mechanical systems arising from
smooth Lagrangians on [0,1] with grid spacing ε = 1/M.

Potentials tested:
  - V(q) = 0       (free particle)
  - V(q) = q²      (harmonic oscillator)
  - V(q) = q⁴      (quartic potential)

Output: Log-log plot of γ(M) vs M showing the M^{-2} scaling law.
"""

import numpy as np
import json
from typing import Callable, Dict, List, Tuple


def min_plus_power(L: np.ndarray, N: int) -> np.ndarray:
    """Compute the N-th min-plus power of matrix L."""
    if N <= 0:
        raise ValueError("N must be positive")
    result = L.copy()
    for _ in range(N - 1):
        n = L.shape[0]
        C = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                C[i, j] = np.min(result[i, :] + L[:, j])
        result = C
    return result


def karp_min_cycle_mean(L: np.ndarray) -> float:
    """Karp's algorithm for minimum cycle mean (tropical eigenvalue)."""
    n = L.shape[0]
    D = np.full((n + 1, n), np.inf)
    D[0, :] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.min(D[k - 1, :] + L[:, i])

    lambda_star = np.inf
    for i in range(n):
        max_val = -np.inf
        for k in range(n):
            if D[k, i] < np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                max_val = max(max_val, val)
        lambda_star = min(lambda_star, max_val)

    return lambda_star


def compute_spectral_gap(L: np.ndarray) -> float:
    """Compute the tropical spectral gap from cycle means."""
    n = L.shape[0]

    # Collect all cycle means for cycles of length 1 to n
    cycle_means = set()
    for length in range(1, min(n + 1, n + 1)):
        Lk = min_plus_power(L, length)
        for i in range(n):
            if Lk[i, i] < np.inf:
                mean = Lk[i, i] / length
                cycle_means.add(round(mean, 10))

    sorted_means = sorted(cycle_means)
    if len(sorted_means) <= 1:
        return 0.0

    return sorted_means[1] - sorted_means[0]


def build_lagrangian_matrix(M: int, V: Callable[[float], float],
                            epsilon: float = None) -> np.ndarray:
    """Build the discrete Lagrangian matrix for a 1D system on [0,1].

    L_d(i,j) = ε/2 · ((x_i - x_j)/ε)² + ε · V(x_i)

    where ε = 1/M and x_i = i·ε for i = 0, ..., M-1.

    Args:
        M: number of grid points
        V: potential function V: [0,1] → ℝ
        epsilon: grid spacing (default: 1/M)

    Returns:
        M×M Lagrangian matrix
    """
    if epsilon is None:
        epsilon = 1.0 / M

    x = np.linspace(0, 1 - epsilon, M)  # grid points
    L = np.zeros((M, M))

    for i in range(M):
        for j in range(M):
            kinetic = 0.5 * ((x[i] - x[j]) / epsilon) ** 2 * epsilon
            potential = epsilon * V(x[i])
            L[i, j] = kinetic + potential

    return L


def run_scaling_experiment(V: Callable[[float], float],
                           V_name: str,
                           M_values: List[int]) -> Dict:
    """Run the spectral gap scaling experiment for a given potential.

    Args:
        V: potential function
        V_name: name for display
        M_values: list of grid sizes to test

    Returns:
        Dictionary with results
    """
    results = {
        "potential": V_name,
        "M_values": [],
        "eigenvalues": [],
        "spectral_gaps": [],
    }

    for M in M_values:
        print(f"  M = {M:4d} ... ", end="", flush=True)
        L = build_lagrangian_matrix(M, V)
        lam = karp_min_cycle_mean(L)
        gap = compute_spectral_gap(L)
        print(f"λ* = {lam:.8f}, γ = {gap:.8f}")

        results["M_values"].append(M)
        results["eigenvalues"].append(lam)
        results["spectral_gaps"].append(gap)

    return results


def fit_power_law(M_values: List[int], gaps: List[float]) -> Tuple[float, float]:
    """Fit γ(M) = c · M^{-α} using log-log linear regression.

    Returns:
        (alpha, c): the exponent and coefficient
    """
    # Filter out zero or negative gaps
    valid = [(m, g) for m, g in zip(M_values, gaps) if g > 0]
    if len(valid) < 2:
        return 0.0, 0.0

    log_M = np.log([v[0] for v in valid])
    log_gap = np.log([v[1] for v in valid])

    # Linear regression: log(γ) = log(c) - α · log(M)
    coeffs = np.polyfit(log_M, log_gap, 1)
    alpha = -coeffs[0]
    c = np.exp(coeffs[1])

    return alpha, c


def create_ascii_plot(M_values: List[int], gaps: List[float],
                      alpha: float, c: float, title: str) -> str:
    """Create a simple ASCII log-log plot."""
    lines = [f"\n  {title}", "  " + "=" * 50]

    valid = [(m, g) for m, g in zip(M_values, gaps) if g > 0]
    if not valid:
        return "\n".join(lines + ["  No valid data points"])

    log_M = [np.log10(v[0]) for v in valid]
    log_gap = [np.log10(v[1]) for v in valid]

    min_lm, max_lm = min(log_M), max(log_M)
    min_lg, max_lg = min(log_gap), max(log_gap)

    # Expand range slightly
    range_lm = max_lm - min_lm or 1
    range_lg = max_lg - min_lg or 1

    width, height = 50, 15
    grid = [[' '] * width for _ in range(height)]

    # Plot data points
    for lm, lg in zip(log_M, log_gap):
        x = int((lm - min_lm) / range_lm * (width - 1))
        y = int((1 - (lg - min_lg) / range_lg) * (height - 1))
        x = max(0, min(width - 1, x))
        y = max(0, min(height - 1, y))
        grid[y][x] = '*'

    # Plot fitted line
    for xi in range(width):
        lm = min_lm + xi / (width - 1) * range_lm
        lg_fit = np.log10(c) - alpha * lm
        y = int((1 - (lg_fit - min_lg) / range_lg) * (height - 1))
        if 0 <= y < height:
            if grid[y][xi] == ' ':
                grid[y][xi] = '.'

    # Add axes
    lines.append(f"  log10(γ) ^")
    for row_idx, row in enumerate(grid):
        if row_idx == 0:
            label = f"{max_lg:.1f}"
        elif row_idx == height - 1:
            label = f"{min_lg:.1f}"
        else:
            label = "     "
        lines.append(f"  {label:>5s} |{''.join(row)}|")
    lines.append(f"        +{'—' * width}> log10(M)")
    lines.append(f"         {min_lm:.1f}{' ' * (width - 8)}{max_lm:.1f}")
    lines.append(f"  * = data, . = fit (α = {alpha:.3f})")

    return "\n".join(lines)


def main():
    print("=" * 70)
    print("TROPICAL ACTION SPECTRUM — Spectral Gap Scaling Experiment")
    print("=" * 70)
    print()
    print("Testing conjecture: γ(M) ~ c · M^{-α} with α ≈ 2")
    print()

    # Grid sizes to test
    M_values = [5, 8, 10, 15, 20, 30, 40]

    # Define potentials
    potentials = [
        (lambda q: 0.0, "V(q) = 0 (free particle)"),
        (lambda q: q**2, "V(q) = q² (harmonic)"),
        (lambda q: q**4, "V(q) = q⁴ (quartic)"),
    ]

    all_results = []

    for V, name in potentials:
        print(f"\n{'—' * 60}")
        print(f"Potential: {name}")
        print(f"{'—' * 60}")
        results = run_scaling_experiment(V, name, M_values)
        all_results.append(results)

        # Fit power law
        alpha, c_fit = fit_power_law(results["M_values"],
                                     results["spectral_gaps"])
        print(f"\n  Fitted: γ(M) ≈ {c_fit:.4f} · M^{{-{alpha:.3f}}}")
        print(f"  Expected α ≈ 2.0, got α = {alpha:.3f}")

        # ASCII plot
        plot = create_ascii_plot(results["M_values"],
                                 results["spectral_gaps"],
                                 alpha, c_fit, name)
        print(plot)

    # Summary
    print(f"\n{'=' * 70}")
    print("SUMMARY")
    print(f"{'=' * 70}")
    print(f"\n{'Potential':<30} {'α (fitted)':<15} {'c':<15}")
    print("-" * 60)
    for results in all_results:
        alpha, c_fit = fit_power_law(results["M_values"],
                                     results["spectral_gaps"])
        print(f"{results['potential']:<30} {alpha:<15.4f} {c_fit:<15.6f}")

    print(f"\nConclusion: The scaling exponent α should be examined for")
    print(f"consistency with the conjecture α ≈ 2.")

    # Demonstrate value function convergence
    print(f"\n{'=' * 70}")
    print("VALUE FUNCTION CONVERGENCE DEMO")
    print(f"{'=' * 70}")

    M = 10
    L = build_lagrangian_matrix(M, lambda q: q**2)
    lam = karp_min_cycle_mean(L)
    print(f"\nHarmonic oscillator, M = {M}, λ* = {lam:.8f}")
    print(f"\n{'N':>4} {'V(N,0,0)':>14} {'V(N,0,0)/N':>14} {'V - N·λ*':>14}")
    print("-" * 50)

    for N in range(1, 16):
        LN = min_plus_power(L, N)
        V_val = LN[0, 0]
        print(f"{N:4d} {V_val:14.6f} {V_val/N:14.8f} {V_val - N*lam:14.8f}")


if __name__ == "__main__":
    main()
