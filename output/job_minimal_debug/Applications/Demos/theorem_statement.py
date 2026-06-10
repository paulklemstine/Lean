"""
Applications of the Tropical Perron–Frobenius Theorem
=====================================================

Real-world applications demonstrating the practical power
of tropical spectral theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_mul(A, B):
    n, p = A.shape
    _, m = B.shape
    C = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def trop_pow(W, m):
    result = W.copy()
    for _ in range(m):
        result = trop_mul(result, W)
    return result


def max_cycle_mean(W):
    n = W.shape[0]
    best = -np.inf
    P = W.copy()
    for m in range(n):
        for i in range(n):
            best = max(best, P[i, i] / (m + 1))
        if m < n - 1:
            P = trop_mul(P, W)
    return best


# ─────────────────────────────────────────────────────
# Application 1: Production Line Scheduling
# ─────────────────────────────────────────────────────

def app_production_scheduling():
    """
    Manufacturing: Predict long-run throughput of a production system.

    Each machine i has a processing time. The weight W[i,j] represents
    the time from completing a job on machine j to completing the next
    job on machine i (including transport and setup).

    The maximum cycle mean gives the asymptotic cycle time (inverse throughput).
    """
    print("=" * 60)
    print("Application 1: Production Line Throughput Analysis")
    print("=" * 60)

    # 4-machine production line
    W = np.array([
        [10,  2,  1,  0],   # CNC Mill
        [ 3, 15,  2,  1],   # Lathe
        [ 1,  3,  8,  2],   # Drill Press
        [ 0,  1,  3, 12],   # Assembly
    ], dtype=float)

    machines = ['CNC Mill', 'Lathe', 'Drill Press', 'Assembly']

    print("\nProcessing/transport time matrix (minutes):")
    for i, name in enumerate(machines):
        print(f"  {name:12s}: {W[i]}")

    mu = max_cycle_mean(W)
    print(f"\nCycle time (max cycle mean): {mu:.1f} minutes")
    print(f"Throughput: {60/mu:.2f} jobs/hour")
    print(f"Bottleneck analysis: The slowest cycle determines system throughput.")

    # Simulate job completion times
    jobs = 20
    print(f"\nPredicted completion times for {jobs} jobs:")
    print(f"{'Job':>4} | {'Predicted':>10} | {'Actual':>10} | {'Error':>8}")
    print("-" * 40)

    for m in range(min(jobs, 10)):
        P = trop_pow(W, m)
        actual = P[0, 0]
        predicted = (m + 1) * mu
        print(f"{m+1:4d} | {predicted:10.1f} | {actual:10.1f} | {actual - predicted:8.1f}")


# ─────────────────────────────────────────────────────
# Application 2: Network Routing Optimization
# ─────────────────────────────────────────────────────

def app_network_routing():
    """
    Find the maximum-bandwidth path in a network.

    In a communication network, W[i,j] = log(bandwidth) of the link from j to i.
    The tropical power tropPow(W,m)[i,j] gives the log of the maximum
    bandwidth achievable using exactly m+1 hops.

    The maximum cycle mean reveals whether bandwidth can grow
    (positive μ → amplification cycles exist) or must decay.
    """
    print("\n" + "=" * 60)
    print("Application 2: Network Bandwidth Analysis")
    print("=" * 60)

    # Network with 5 nodes (log-bandwidth matrix)
    W = np.array([
        [-0.5, -1.0, -2.0, -3.0, -0.8],
        [-1.0, -0.3, -1.5, -2.0, -1.2],
        [-2.0, -1.5, -0.4, -1.0, -1.8],
        [-3.0, -2.0, -1.0, -0.6, -2.5],
        [-0.8, -1.2, -1.8, -2.5, -0.2],
    ])

    mu = max_cycle_mean(W)
    print(f"\nMax cycle mean: {mu:.4f}")
    print(f"Interpretation: Every multi-hop path loses at least {-mu:.4f} "
          f"log-bandwidth per hop on average.")
    print(f"Bandwidth decay factor: {np.exp(mu):.4f}x per hop")


# ─────────────────────────────────────────────────────
# Application 3: Mean-Payoff Game Value
# ─────────────────────────────────────────────────────

def app_mean_payoff_game():
    """
    Compute the value of a deterministic mean-payoff game.

    A single player moves a token on a weighted graph, collecting
    weights along edges. The goal is to maximize the long-run
    average reward. The optimal value equals the maximum cycle mean.
    """
    print("\n" + "=" * 60)
    print("Application 3: Mean-Payoff Game Optimal Strategy")
    print("=" * 60)

    # Game graph: 4 states, weights represent rewards
    W = np.array([
        [-1,  3,  0,  1],
        [ 2, -2,  4,  0],
        [ 1,  0, -1,  5],
        [ 0,  1,  2, -3],
    ], dtype=float)

    mu = max_cycle_mean(W)
    print(f"\nGame value (optimal average reward): {mu:.4f}")
    print(f"Any strategy achieves at most {mu:.4f} per step on average.")
    print(f"The optimal strategy follows the cycle achieving this mean.")

    # Find which cycle is optimal
    n = W.shape[0]
    best_mean = -np.inf
    best_cycle = None
    for i in range(n):
        if W[i, i] > best_mean:
            best_mean = W[i, i]
            best_cycle = f"self-loop at {i}"
    for i in range(n):
        for j in range(n):
            if i != j:
                mean2 = (W[i, j] + W[j, i]) / 2
                if mean2 > best_mean:
                    best_mean = mean2
                    best_cycle = f"2-cycle {i}→{j}→{i}"

    P = trop_pow(W, 2)
    for i in range(n):
        mean3 = P[i, i] / 3
        if mean3 > best_mean:
            best_mean = mean3
            best_cycle = f"3-cycle through {i}"

    print(f"Optimal cycle: {best_cycle} (mean {best_mean:.4f})")


# ─────────────────────────────────────────────────────
# Application 4: Train Timetable Synchronization
# ─────────────────────────────────────────────────────

def app_train_scheduling():
    """
    Periodic event scheduling for a train network.

    In a railway system with periodic timetables, the minimum cycle time
    is determined by the maximum cycle mean of the constraint matrix.
    """
    print("\n" + "=" * 60)
    print("Application 4: Railway Timetable Optimization")
    print("=" * 60)

    # 3 train lines with connection constraints (minutes)
    # W[i,j] = minimum time between departure of train j and departure of train i
    W = np.array([
        [60,  25,  40],   # Line A (60-min cycle, 25-min after B, 40-min after C)
        [35,  45,  20],   # Line B
        [30,  15,  50],   # Line C
    ], dtype=float)

    lines = ['Line A', 'Line B', 'Line C']

    print("\nConnection constraint matrix (minutes):")
    for i, name in enumerate(lines):
        print(f"  {name}: {W[i]}")

    mu = max_cycle_mean(W)
    print(f"\nMinimum cycle time: {mu:.1f} minutes")
    print(f"Trains per hour: {60/mu:.2f}")
    print(f"\nThis is the fundamental period of the railway timetable.")
    print(f"No timetable can achieve a shorter cycle while satisfying all constraints.")


if __name__ == "__main__":
    app_production_scheduling()
    app_network_routing()
    app_mean_payoff_game()
    app_train_scheduling()
    print("\n\nAll applications demonstrated!")


"""
Tropical Perron–Frobenius Theorem: Demonstrations
=================================================

This script demonstrates the tropical (max-plus) spectral theorem:
normalized tropical matrix powers converge entrywise to the maximum cycle mean.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_mul(A, B):
    """Tropical (max-plus) matrix multiplication: C[i,j] = max_k (A[i,k] + B[k,j])."""
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_pow(W, m):
    """Compute the (m+1)-fold tropical power of W."""
    result = W.copy()
    for _ in range(m):
        result = trop_mul(result, W)
    return result


def max_cycle_mean(W):
    """Compute the maximum cycle mean (max average weight of a simple cycle)."""
    n = W.shape[0]
    best = -np.inf
    for length in range(1, n + 1):
        # Use dynamic programming to find max weight closed walk of given length
        P = W.copy()
        if length == 1:
            for i in range(n):
                best = max(best, W[i, i])
        else:
            P_prev = W.copy()
            for _ in range(length - 1):
                P_prev = trop_mul(P_prev, W)
            for i in range(n):
                best = max(best, P_prev[i, i] / length)
    return best


def demo_convergence():
    """Demonstrate convergence of normalized tropical powers."""
    print("=" * 60)
    print("Demo 1: Convergence of Normalized Tropical Powers")
    print("=" * 60)

    # Example matrix
    W = np.array([
        [1.0, 3.0, -2.0],
        [0.0, 2.0, 4.0],
        [5.0, -1.0, 0.0]
    ])
    print(f"\nWeight matrix W:\n{W}\n")

    mcm = max_cycle_mean(W)
    print(f"Maximum cycle mean (μ): {mcm:.4f}\n")

    # Compute normalized tropical powers
    ms = list(range(20))
    results = {}
    for i in range(3):
        for j in range(3):
            results[(i, j)] = []

    for m in ms:
        P = trop_pow(W, m)
        for i in range(3):
            for j in range(3):
                results[(i, j)].append(P[i, j] / (m + 1))

    print(f"{'m':>3} | {'P[0,0]/(m+1)':>12} | {'P[0,1]/(m+1)':>12} | {'P[1,2]/(m+1)':>12} | {'μ':>8}")
    print("-" * 60)
    for idx, m in enumerate(ms):
        print(f"{m:3d} | {results[(0,0)][idx]:12.4f} | {results[(0,1)][idx]:12.4f} | "
              f"{results[(1,2)][idx]:12.4f} | {mcm:8.4f}")

    # Plot convergence
    fig, ax = plt.subplots(figsize=(10, 6))
    for (i, j), vals in results.items():
        ax.plot(ms, vals, 'o-', markersize=3, label=f'P[{i},{j}]/(m+1)')
    ax.axhline(y=mcm, color='red', linestyle='--', linewidth=2, label=f'μ = {mcm:.3f}')
    ax.set_xlabel('m (power index)', fontsize=12)
    ax.set_ylabel('Normalized tropical power', fontsize=12)
    ax.set_title('Tropical Perron–Frobenius: Convergence to Maximum Cycle Mean', fontsize=14)
    ax.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=9)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('convergence.png', dpi=150, bbox_inches='tight')
    print(f"\nConvergence plot saved to convergence.png")


def demo_cycle_structure():
    """Show how the maximum cycle mean relates to graph cycles."""
    print("\n" + "=" * 60)
    print("Demo 2: Cycle Structure and Maximum Cycle Mean")
    print("=" * 60)

    # A graph with interesting cycle structure
    W = np.array([
        [0.0, 8.0, 0.0, 0.0],
        [0.0, 0.0, 6.0, 0.0],
        [0.0, 0.0, 0.0, 4.0],
        [2.0, 0.0, 0.0, 0.0]
    ])

    print(f"\nWeight matrix (cycle graph):\n{W}\n")
    print("Cycle structure:")
    print("  Self-loops: 0→0 (weight 0), etc.")
    print("  2-cycles: 0→1→0 (weight 8+0=8, mean 4), etc.")
    print("  4-cycle: 0→1→2→3→0 (weight 8+6+4+2=20, mean 5)")

    mcm = max_cycle_mean(W)
    print(f"\nMaximum cycle mean: {mcm:.1f}")
    print("(The 4-cycle 0→1→2→3→0 with mean 5 is optimal)")

    # Demonstrate convergence
    print(f"\n{'m':>3} | {'P[0,0]/(m+1)':>14} | {'deviation':>10}")
    print("-" * 40)
    for m in range(15):
        P = trop_pow(W, m)
        val = P[0, 0] / (m + 1)
        print(f"{m:3d} | {val:14.4f} | {val - mcm:10.4f}")


def demo_bounded_deviation():
    """Demonstrate the bounded deviation property."""
    print("\n" + "=" * 60)
    print("Demo 3: Bounded Deviation from Linear Growth")
    print("=" * 60)

    W = np.array([
        [1.0, 5.0],
        [3.0, 2.0]
    ])

    print(f"\nWeight matrix:\n{W}\n")
    mcm = max_cycle_mean(W)
    print(f"Maximum cycle mean: {mcm:.4f}")

    ms = list(range(30))
    deviations = []

    print(f"\n{'m':>3} | {'P[0,1]':>10} | {'(m+1)*μ':>10} | {'deviation':>10}")
    print("-" * 50)
    for m in ms:
        P = trop_pow(W, m)
        expected = (m + 1) * mcm
        dev = P[0, 1] - expected
        deviations.append(abs(dev))
        if m < 15:
            print(f"{m:3d} | {P[0,1]:10.2f} | {expected:10.2f} | {dev:10.2f}")

    print(f"\nMax |deviation| over m=0..29: {max(deviations):.4f}")
    print("(Bounded! This is the bounded deviation property.)")

    # Plot deviations
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: linear growth
    powers = [trop_pow(W, m)[0, 1] for m in ms]
    linear = [(m + 1) * mcm for m in ms]
    ax1.plot(ms, powers, 'b.-', label='tropPow W m [0,1]')
    ax1.plot(ms, linear, 'r--', label=f'(m+1)·μ, μ={mcm:.2f}')
    ax1.set_xlabel('m')
    ax1.set_ylabel('Value')
    ax1.set_title('Linear Growth of Tropical Powers')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: bounded deviation
    devs_all = []
    for m in ms:
        P = trop_pow(W, m)
        for i in range(2):
            for j in range(2):
                devs_all.append((m, abs(P[i, j] - (m + 1) * mcm)))

    for i in range(2):
        for j in range(2):
            d = [abs(trop_pow(W, m)[i, j] - (m + 1) * mcm) for m in ms]
            ax2.plot(ms, d, '.-', label=f'|P[{i},{j}] - (m+1)μ|', markersize=3)

    ax2.set_xlabel('m')
    ax2.set_ylabel('|deviation|')
    ax2.set_title('Bounded Deviation Property')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('bounded_deviation.png', dpi=150, bbox_inches='tight')
    print(f"\nBounded deviation plot saved to bounded_deviation.png")


def demo_scheduling():
    """Real-world application: production scheduling / discrete event systems."""
    print("\n" + "=" * 60)
    print("Demo 4: Application — Production Line Throughput")
    print("=" * 60)

    # 3-machine production line: W[i,j] = processing time + transport time
    # from completing job at machine j to completing next job at machine i
    W = np.array([
        [3.0, 1.0, 0.5],  # Machine A
        [2.0, 4.0, 1.5],  # Machine B
        [1.0, 2.0, 5.0],  # Machine C
    ])

    print(f"\nProcessing time matrix (machine i after machine j):\n{W}\n")

    mcm = max_cycle_mean(W)
    print(f"Maximum cycle mean (= cycle time): {mcm:.2f} time units")
    print(f"Throughput: {1/mcm:.4f} jobs per time unit")

    print(f"\nCompletion times for successive jobs:")
    print(f"{'Job':>4} | {'Machine A':>10} | {'Machine B':>10} | {'Machine C':>10}")
    print("-" * 45)
    for m in range(8):
        P = trop_pow(W, m)
        print(f"{m+1:4d} | {P[0,0]:10.1f} | {P[1,1]:10.1f} | {P[2,2]:10.1f}")

    print(f"\nAs jobs → ∞, average time per job → {mcm:.2f}")
    print("This is the tropical Perron–Frobenius theorem in action!")


if __name__ == "__main__":
    demo_convergence()
    demo_cycle_structure()
    demo_bounded_deviation()
    demo_scheduling()
    print("\n\nAll demos complete!")
