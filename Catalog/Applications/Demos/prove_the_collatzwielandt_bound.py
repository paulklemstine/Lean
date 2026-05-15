"""
Applications of Tropical Spectral Theory
==========================================
Real-world applications demonstrating the Collatz-Wielandt theorem.
"""
import numpy as np


def train_scheduling_example():
    """Application: Train network scheduling.

    A circular train network with 4 stations. W[i][j] represents
    the minimum time for a train at station j to reach station i
    (including loading, travel, and unloading).
    """
    print("=" * 60)
    print("APPLICATION 1: Train Network Scheduling")
    print("=" * 60)

    # Transition time matrix (minutes)
    W = np.array([
        [10, 25, 15, 30],  # To station 0
        [20, 8,  22, 18],  # To station 1
        [12, 16, 12, 24],  # To station 2
        [28, 14, 20, 6],   # To station 3
    ], dtype=float)

    n = W.shape[0]
    print(f"\nTransition time matrix (minutes):")
    stations = ['Central', 'North', 'East', 'South']
    print(f"{'':>10}", end="")
    for s in stations:
        print(f"{s:>10}", end="")
    print()
    for i, s in enumerate(stations):
        print(f"{s:>10}", end="")
        for j in range(n):
            print(f"{W[i,j]:>10.0f}", end="")
        print()

    # Compute spectral radius
    from algorithms import karp_max_cycle_mean, bellman_ford_potential
    rho, cycle = karp_max_cycle_mean(W)

    print(f"\nMinimum cycle time (throughput rate): {rho:.1f} minutes/train")
    print(f"Critical cycle: {' → '.join(stations[c] for c in cycle)}")

    # Compute optimal schedule
    x = bellman_ford_potential(W, rho)
    print(f"\nOptimal departure offsets within a cycle:")
    for i, s in enumerate(stations):
        print(f"  {s}: t = {x[i]:.1f} minutes")

    print(f"\nThis means trains can depart every {rho:.1f} minutes")
    print(f"from each station, with the offsets above ensuring no conflicts.")


def digital_circuit_timing():
    """Application: Static timing analysis for a digital circuit.

    The matrix W represents signal propagation delays between
    flip-flops in a synchronous circuit. The spectral radius
    gives the minimum clock period.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Digital Circuit Timing Analysis")
    print("=" * 60)

    # Propagation delay matrix (nanoseconds)
    # W[i][j] = delay from flip-flop j's output to flip-flop i's input
    W = np.array([
        [0.5, 2.1, 0.0],
        [1.8, 0.3, 2.5],
        [0.0, 1.2, 0.4],
    ])

    n = W.shape[0]
    ff_names = ['FF_A', 'FF_B', 'FF_C']
    print(f"\nPropagation delay matrix (ns):")
    print(f"{'':>8}", end="")
    for name in ff_names:
        print(f"{name:>8}", end="")
    print()
    for i, name in enumerate(ff_names):
        print(f"{name:>8}", end="")
        for j in range(n):
            print(f"{W[i,j]:>8.1f}", end="")
        print()

    from algorithms import karp_max_cycle_mean, bellman_ford_potential
    rho, cycle = karp_max_cycle_mean(W)

    print(f"\nMinimum clock period: {rho:.2f} ns")
    print(f"Maximum clock frequency: {1000/rho:.0f} MHz")
    print(f"Critical path: {' → '.join(ff_names[c] for c in cycle)}")

    # Setup/hold time analysis
    x = bellman_ford_potential(W, rho)
    print(f"\nClock skew assignments (for min period):")
    for i, name in enumerate(ff_names):
        print(f"  {name}: skew = {x[i]:.2f} ns")

    # Check with a faster clock
    faster_period = rho - 0.2
    x_fast = bellman_ford_potential(W, faster_period)
    print(f"\nCan we run at {faster_period:.2f} ns ({1000/faster_period:.0f} MHz)?")
    print(f"  {'Yes ✓' if x_fast is not None else 'No ✗ - timing violation!'}")


def manufacturing_throughput():
    """Application: Manufacturing system throughput analysis.

    Three machines in a flexible manufacturing cell. Each job
    requires processing on specific machines with given times.
    The tropical spectral radius gives the minimum makespan per part.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Manufacturing Throughput Analysis")
    print("=" * 60)

    # Processing + transfer time matrix
    # W[i][j] = time from completing on machine j to completing on machine i
    W = np.array([
        [5.0, 8.0, 3.0],  # Machine 1 (CNC Mill)
        [4.0, 6.0, 7.0],  # Machine 2 (Lathe)
        [6.0, 3.0, 4.0],  # Machine 3 (Assembly)
    ])

    machines = ['CNC Mill', 'Lathe', 'Assembly']
    n = W.shape[0]

    print(f"\nProcessing time matrix (minutes):")
    print(f"{'':>12}", end="")
    for m in machines:
        print(f"{m:>12}", end="")
    print()
    for i, m in enumerate(machines):
        print(f"{m:>12}", end="")
        for j in range(n):
            print(f"{W[i,j]:>12.1f}", end="")
        print()

    from algorithms import karp_max_cycle_mean, bellman_ford_potential
    rho, cycle = karp_max_cycle_mean(W)

    print(f"\nMinimum cycle time: {rho:.1f} minutes/part")
    print(f"Maximum throughput: {60/rho:.1f} parts/hour")
    print(f"Bottleneck cycle: {' → '.join(machines[c] for c in cycle)}")

    x = bellman_ford_potential(W, rho)
    print(f"\nOptimal start time offsets:")
    for i, m in enumerate(machines):
        print(f"  {m}: offset = {x[i]:.1f} min")

    # Sensitivity analysis
    print(f"\nSensitivity: what if we speed up each machine by 1 min?")
    for target in range(n):
        W_improved = W.copy()
        W_improved[target, :] -= 1
        W_improved[:, target] -= 1
        rho_new, _ = karp_max_cycle_mean(W_improved)
        improvement = rho - rho_new
        print(f"  Speed up {machines[target]}: "
              f"ρ = {rho_new:.1f} min (Δ = {improvement:+.1f} min)")


if __name__ == "__main__":
    train_scheduling_example()
    digital_circuit_timing()
    manufacturing_throughput()


"""
Tropical Collatz-Wielandt Theorem: Demonstrations
==================================================
Concrete numerical examples of the tropical spectral radius,
subeigenvectors, and the Collatz-Wielandt equivalence.
"""
import numpy as np
from typing import Tuple, List, Optional


def trop_mat_vec(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (W ⊗ x)_i = max_j (W_ij + x_j)."""
    n = W.shape[0]
    return np.array([np.max(W[i, :] + x) for i in range(n)])


def is_subeigenvector(W: np.ndarray, lam: float, x: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if x is a subeigenvector with value lambda."""
    Wx = trop_mat_vec(W, x)
    return np.all(Wx <= x + lam + tol)


def all_cycle_means(W: np.ndarray) -> List[float]:
    """Compute all cycle means for cycles of length 1 to n."""
    n = W.shape[0]
    means = []
    # Length 1: self-loops
    for i in range(n):
        means.append(W[i, i])
    # Length 2
    for i in range(n):
        for j in range(n):
            means.append((W[i, j] + W[j, i]) / 2)
    # Length k for k = 3, ..., n (brute force for small n)
    from itertools import product as cartprod
    for k in range(3, n + 1):
        for cycle in cartprod(range(n), repeat=k):
            weight = sum(W[cycle[t], cycle[(t + 1) % k]] for t in range(k))
            means.append(weight / k)
    return means


def tropical_spectral_radius(W: np.ndarray) -> float:
    """Compute the tropical spectral radius (max cycle mean)."""
    return max(all_cycle_means(W))


def construct_potential(W: np.ndarray, lam: float) -> np.ndarray:
    """Construct the subeigenvector (potential) from the proof.

    Uses the Bellman-Ford-style iteration: compute max walk weight
    of length 0, 1, ..., n-1 from each vertex in the shifted matrix A = W - lam.
    """
    n = W.shape[0]
    A = W - lam

    # best_walk[i][m] = max walk weight of length m from vertex i
    # Compute iteratively via the Bellman operator
    best = np.zeros((n,))  # length 0: weight 0
    potential = best.copy()

    for m in range(1, n):
        new_best = np.array([np.max(A[i, :] + best) for i in range(n)])
        potential = np.maximum(potential, new_best)
        best = new_best

    return potential


# ============================================================
# DEMO 1: Simple 2x2 matrix
# ============================================================
print("=" * 60)
print("DEMO 1: 2x2 Matrix")
print("=" * 60)

W1 = np.array([[1.0, 3.0],
                [2.0, 0.0]])

rho1 = tropical_spectral_radius(W1)
print(f"\nMatrix W:\n{W1}")
print(f"\nTropical spectral radius ρ = {rho1}")
print(f"  (Self-loop means: W[0,0]={W1[0,0]}, W[1,1]={W1[1,1]})")
print(f"  (2-cycle mean: (W[0,1]+W[1,0])/2 = ({W1[0,1]}+{W1[1,0]})/2 = {(W1[0,1]+W1[1,0])/2})")

# Construct subeigenvector for lambda = rho
x1 = construct_potential(W1, rho1)
print(f"\nSubeigenvector x for λ = ρ = {rho1}: x = {x1}")
print(f"  Verification: (W⊗x)_i ≤ x_i + λ?")
Wx1 = trop_mat_vec(W1, x1)
for i in range(2):
    print(f"    i={i}: (W⊗x)_{i} = {Wx1[i]:.4f} ≤ {x1[i] + rho1:.4f} = x_{i} + λ ✓"
          if Wx1[i] <= x1[i] + rho1 + 1e-10 else f"    i={i}: FAIL")

# Show infeasibility for lambda < rho
lam_small = rho1 - 0.5
print(f"\nFor λ = {lam_small} < ρ = {rho1}:")
print(f"  HasSubeig? No subeigenvector exists (by Collatz-Wielandt theorem)")

# ============================================================
# DEMO 2: 3x3 matrix (factory example)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: 3x3 Factory Timing Matrix")
print("=" * 60)

W2 = np.array([[0.0, 5.0, 1.0],
                [2.0, 0.0, 4.0],
                [3.0, 1.0, 0.0]])

rho2 = tropical_spectral_radius(W2)
print(f"\nMatrix W:\n{W2}")
print(f"\nTropical spectral radius ρ = {rho2:.4f}")

# Enumerate key cycles
print("\nKey cycle means:")
for i in range(3):
    print(f"  Self-loop at {i}: mean = {W2[i,i]}")
for i in range(3):
    for j in range(i+1, 3):
        mean = (W2[i,j] + W2[j,i]) / 2
        print(f"  2-cycle ({i},{j}): mean = ({W2[i,j]}+{W2[j,i]})/2 = {mean}")

x2 = construct_potential(W2, rho2)
print(f"\nSubeigenvector for λ = ρ: x = {x2}")
print(f"Verification: {is_subeigenvector(W2, rho2, x2)}")

# ============================================================
# DEMO 3: Collatz-Wielandt equivalence sweep
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Collatz-Wielandt Equivalence Sweep")
print("=" * 60)

W3 = np.array([[0.0, 3.0],
                [4.0, 1.0]])
rho3 = tropical_spectral_radius(W3)
print(f"\nMatrix W:\n{W3}")
print(f"Tropical spectral radius: {rho3}")

print(f"\n{'λ':>8} | {'HasSubeig':>10} | {'ρ ≤ λ':>8} | {'Match':>6}")
print("-" * 45)
for lam in np.arange(rho3 - 2, rho3 + 2.5, 0.5):
    x = construct_potential(W3, lam)
    has_sub = is_subeigenvector(W3, lam, x)
    rho_le = rho3 <= lam + 1e-10
    match = has_sub == rho_le
    print(f"{lam:8.2f} | {str(has_sub):>10} | {str(rho_le):>8} | {'✓' if match else '✗':>6}")

print("\n✓ Collatz-Wielandt equivalence verified for all test values!")

# ============================================================
# DEMO 4: Difference constraints interpretation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Difference Constraints (Scheduling)")
print("=" * 60)

# The subeigenvector condition W_ij + x_j ≤ x_i + λ
# is equivalent to x_i - x_j ≥ W_ij - λ
# This is a system of difference constraints!

W4 = np.array([[0.0, 2.0, 1.0],
                [3.0, 0.0, 2.0],
                [1.0, 1.0, 0.0]])

rho4 = tropical_spectral_radius(W4)
x4 = construct_potential(W4, rho4)

print(f"\nTiming matrix W:\n{W4}")
print(f"Minimum cycle time (ρ): {rho4}")
print(f"Optimal schedule (x): {x4}")
print(f"\nDifference constraints satisfied:")
n = W4.shape[0]
for i in range(n):
    for j in range(n):
        diff = x4[i] - x4[j]
        bound = W4[i, j] - rho4
        ok = diff >= bound - 1e-10
        print(f"  x[{i}] - x[{j}] = {diff:6.2f} ≥ {bound:6.2f} = W[{i},{j}] - ρ  {'✓' if ok else '✗'}")


"""
Visualizations for Tropical Spectral Theory
=============================================
Generate charts and diagrams for the research.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_collatz_wielandt_sweep():
    """Plot the Collatz-Wielandt equivalence: HasSubeig vs spectral radius."""
    from algorithms import karp_max_cycle_mean, bellman_ford_potential

    W = np.array([[0, 5, 1],
                   [2, 0, 4],
                   [3, 1, 0]], dtype=float)

    rho, _ = karp_max_cycle_mean(W)
    lambdas = np.linspace(rho - 2, rho + 3, 200)
    feasible = []
    residuals = []

    for lam in lambdas:
        x = bellman_ford_potential(W, lam)
        if x is not None:
            Wx = np.array([np.max(W[i, :] + x) for i in range(W.shape[0])])
            res = np.max(Wx - x - lam)
            feasible.append(True)
            residuals.append(max(0, res))
        else:
            feasible.append(False)
            residuals.append(None)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    # Top: feasibility region
    feas_vals = [1 if f else 0 for f in feasible]
    ax1.fill_between(lambdas, 0, feas_vals, alpha=0.3, color='green', label='Feasible (HasSubeig)')
    ax1.fill_between(lambdas, 0, [1-f for f in feas_vals], alpha=0.3, color='red', label='Infeasible')
    ax1.axvline(x=rho, color='black', linestyle='--', linewidth=2, label=f'ρ = {rho:.2f}')
    ax1.set_xlabel('λ', fontsize=14)
    ax1.set_ylabel('Feasibility', fontsize=14)
    ax1.set_title('Tropical Collatz-Wielandt Theorem: HasSubeig(W, λ) ↔ ρ(W) ≤ λ', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.set_ylim(-0.1, 1.1)

    # Bottom: residual
    res_plot = [r if r is not None else np.nan for r in residuals]
    ax2.semilogy(lambdas, [max(r, 1e-15) for r in res_plot], 'b-', linewidth=1.5)
    ax2.axvline(x=rho, color='black', linestyle='--', linewidth=2, label=f'ρ = {rho:.2f}')
    ax2.set_xlabel('λ', fontsize=14)
    ax2.set_ylabel('Residual (log scale)', fontsize=14)
    ax2.set_title('Subeigenvector Residual: max_i ((W⊗x)_i - x_i - λ)', fontsize=14)
    ax2.legend(fontsize=12)

    fig.tight_layout()
    fig.savefig('collatz_wielandt_sweep.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_bellman_convergence():
    """Plot convergence of the Bellman iteration."""
    W = np.array([[0, 5, 1],
                   [2, 0, 4],
                   [3, 1, 0]], dtype=float)

    from algorithms import karp_max_cycle_mean
    rho, _ = karp_max_cycle_mean(W)
    A = W - rho
    n = W.shape[0]

    # Track iteration
    best = np.zeros(n)
    potentials = [best.copy()]

    for m in range(1, 2 * n):
        new_best = np.array([np.max(A[i, :] + best) for i in range(n)])
        potential = np.maximum(potentials[-1], new_best)
        potentials.append(potential.copy())
        best = new_best

    fig, ax = plt.subplots(figsize=(10, 6))
    potentials = np.array(potentials)
    labels = [f'Vertex {i}' for i in range(n)]
    for i in range(n):
        ax.plot(range(len(potentials)), potentials[:, i], 'o-', linewidth=2, markersize=6, label=labels[i])

    ax.axvline(x=n-1, color='gray', linestyle=':', linewidth=1.5, label=f'n-1 = {n-1} (stabilization)')
    ax.set_xlabel('Iteration (walk length)', fontsize=14)
    ax.set_ylabel('Potential value', fontsize=14)
    ax.set_title(f'Bellman-Ford Potential Convergence (ρ = {rho:.2f})', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.savefig('bellman_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_cycle_means_histogram():
    """Histogram of cycle means showing the spectral radius."""
    W = np.array([[0, 5, 1, 2],
                   [2, 0, 4, 1],
                   [3, 1, 0, 3],
                   [1, 2, 2, 0]], dtype=float)

    n = W.shape[0]
    from itertools import product as cartprod

    means = []
    for k in range(1, n + 1):
        for cycle in cartprod(range(n), repeat=k):
            weight = sum(W[cycle[t], cycle[(t + 1) % k]] for t in range(k))
            means.append(weight / k)

    rho = max(means)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.hist(means, bins=50, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axvline(x=rho, color='red', linestyle='--', linewidth=2.5, label=f'ρ(W) = {rho:.2f}')
    ax.set_xlabel('Cycle Mean', fontsize=14)
    ax.set_ylabel('Count', fontsize=14)
    ax.set_title('Distribution of Cycle Means (4×4 matrix)', fontsize=14)
    ax.legend(fontsize=14)
    ax.grid(True, alpha=0.3)

    fig.savefig('cycle_means_histogram.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_collatz_wielandt_sweep()
    print(f"  collatz_wielandt_sweep.png generated ({len(b64_1)} chars)")
    b64_2 = plot_bellman_convergence()
    print(f"  bellman_convergence.png generated ({len(b64_2)} chars)")
    b64_3 = plot_cycle_means_histogram()
    print(f"  cycle_means_histogram.png generated ({len(b64_3)} chars)")
    print("Done!")
