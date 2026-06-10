#!/usr/bin/env python3
"""
Applications of Width-Bounded Tropical Φ Computation.

Demonstrates real-world applications:
1. Shortest path in layered graphs (transportation networks)
2. Viterbi decoding analogue (hidden Markov models)
3. Transfer matrix method in statistical mechanics
4. Neural network robustness certification (tropical geometry)
"""

import numpy as np
from algorithms import (LayeredTropicalCircuit, bellman_dp,
                         recover_optimal_trajectory, dp_work_bound)


# ──────────────────────────────────────────────────────────────────
# Application 1: Shortest Path in Layered Transportation Networks
# ──────────────────────────────────────────────────────────────────

def shortest_path_demo():
    """Compute shortest path through a layered city network.

    Model: A delivery driver must cross L zones of a city.
    Each zone has w possible routes/intersections.
    Cost = travel time between consecutive intersections.

    This is exactly tropicalPhi of the layered circuit.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest Path in Layered Networks")
    print("=" * 60)

    # 5 zones, 4 intersections per zone
    zone_names = ["Downtown", "Midtown", "Uptown", "Suburbs", "Airport"]
    intersection_names = ["North", "South", "East", "West"]

    np.random.seed(42)
    L, w = 5, 4

    # Travel times (minutes) between intersections in consecutive zones
    step_costs = []
    for ell in range(L):
        # Asymmetric costs: some routes are faster than others
        M = np.random.randint(5, 30, size=(w, w)).astype(float)
        # Make diagonal (staying in same direction) slightly cheaper
        for i in range(w):
            M[i, i] = max(3, M[i, i] - 10)
        step_costs.append(M)

    circuit = LayeredTropicalCircuit(step_costs)
    phi, V, ops = bellman_dp(circuit)
    traj, cost = recover_optimal_trajectory(circuit, V)

    print(f"\n  Zones: {zone_names}")
    print(f"  Intersections: {intersection_names}")
    print(f"\n  Optimal route (fastest delivery):")
    for ell in range(L + 1):
        zone = zone_names[ell] if ell < L else "Destination"
        intersection = intersection_names[traj[ell]]
        print(f"    Zone {ell} ({zone}): via {intersection}")
    print(f"\n  Minimum travel time: {cost:.0f} minutes")
    print(f"  DP operations: {ops} (vs {w**(L+1)} brute-force paths)")
    print()


# ──────────────────────────────────────────────────────────────────
# Application 2: Viterbi Decoding Analogue
# ──────────────────────────────────────────────────────────────────

def viterbi_analogue_demo():
    """Tropical Φ as a Viterbi-like decoder.

    In an HMM, the Viterbi algorithm finds the most likely state sequence
    by maximizing log-probabilities (equivalently, minimizing negative
    log-probabilities). This is exactly min-plus DP = tropical Φ.

    Model: A communication channel with w possible symbol states
    over L time steps. The "cost" is the negative log-likelihood of
    a transition (lower = more likely).
    """
    print("=" * 60)
    print("APPLICATION 2: Viterbi Decoding (Tropical HMM)")
    print("=" * 60)

    np.random.seed(123)
    L, w = 10, 3  # 10 time steps, 3 symbol states
    state_names = ["A", "B", "C"]

    # Generate transition costs = -log(transition probabilities)
    step_costs = []
    for _ in range(L):
        # Random transition probabilities
        P = np.random.dirichlet([2, 2, 2], size=w)
        # Convert to costs: -log(probability)
        M = -np.log(P + 1e-10)
        step_costs.append(M)

    circuit = LayeredTropicalCircuit(step_costs)
    phi, V, ops = bellman_dp(circuit)
    traj, cost = recover_optimal_trajectory(circuit, V)

    print(f"\n  States: {state_names}")
    print(f"  Time steps: {L}")
    print(f"\n  Most likely state sequence (Viterbi path):")
    path_str = " → ".join(state_names[s] for s in traj)
    print(f"    {path_str}")
    print(f"\n  Negative log-likelihood: {cost:.4f}")
    print(f"  Likelihood: {np.exp(-cost):.6e}")
    print(f"  DP operations: {ops}")
    print()


# ──────────────────────────────────────────────────────────────────
# Application 3: Transfer Matrix in Statistical Mechanics
# ──────────────────────────────────────────────────────────────────

def transfer_matrix_demo():
    """Zero-temperature transfer matrix computation.

    Model: A 1D spin chain with L sites, w possible spin states per site.
    The energy of a configuration is the sum of nearest-neighbor interactions.
    At zero temperature, the partition function is dominated by the ground state:
        ground state energy = min over all configurations of total energy
                            = tropicalPhi of the interaction circuit.

    This connects to the min-plus (tropical) semiring interpretation
    of statistical mechanics transfer matrices.
    """
    print("=" * 60)
    print("APPLICATION 3: Zero-Temperature Transfer Matrix")
    print("=" * 60)

    np.random.seed(456)
    L, w = 20, 4  # 20-site chain, 4 spin states (e.g., clock model)
    spin_names = ["↑", "→", "↓", "←"]

    # Nearest-neighbor interaction energy
    # Ferromagnetic: aligned spins have lower energy
    step_costs = []
    for _ in range(L):
        M = np.zeros((w, w))
        for i in range(w):
            for j in range(w):
                # Energy depends on relative angle
                angle_diff = abs(i - j) % w
                M[i, j] = 2.0 * min(angle_diff, w - angle_diff)
                # Add small random disorder
                M[i, j] += np.random.uniform(-0.1, 0.1)
        step_costs.append(M)

    circuit = LayeredTropicalCircuit(step_costs)
    phi, V, ops = bellman_dp(circuit)
    traj, cost = recover_optimal_trajectory(circuit, V)

    print(f"\n  Spin chain: {L} sites, {w} states per site")
    print(f"  Ground state configuration:")
    config_str = " ".join(spin_names[s] for s in traj)
    print(f"    {config_str}")
    print(f"\n  Ground state energy: {cost:.4f}")
    print(f"  DP operations: {ops}")
    print(f"  Brute force would need: {w**(L+1):,} configuration evaluations")
    print(f"  Speedup factor: {w**(L+1) / ops:,.0f}x")
    print()


# ──────────────────────────────────────────────────────────────────
# Application 4: Neural Network Robustness via Tropical Geometry
# ──────────────────────────────────────────────────────────────────

def neural_network_robustness_demo():
    """Tropical robustness certification for a ReLU network.

    A ReLU neural network with bounded width w per layer defines
    a piecewise-linear function whose behavior can be analyzed via
    tropical geometry. The "tropical Φ" of the network's activation
    patterns captures the worst-case perturbation cost.

    Model: Each layer's "step cost" represents the minimum perturbation
    energy needed to change the activation pattern from one configuration
    to another. TropicalPhi gives the minimum total perturbation cost
    to traverse the network — a lower bound on adversarial robustness.
    """
    print("=" * 60)
    print("APPLICATION 4: Neural Network Robustness Certificate")
    print("=" * 60)

    np.random.seed(789)
    L, w = 6, 8  # 6 layers, 8 activation patterns per layer

    # Perturbation costs between activation patterns
    step_costs = []
    for ell in range(L):
        M = np.zeros((w, w))
        for i in range(w):
            for j in range(w):
                # Hamming-like distance between activation patterns
                diff = bin(i ^ j).count('1')
                M[i, j] = diff * np.random.uniform(0.5, 2.0)
        step_costs.append(M)

    circuit = LayeredTropicalCircuit(step_costs)
    phi, V, ops = bellman_dp(circuit)
    traj, cost = recover_optimal_trajectory(circuit, V)

    print(f"\n  Network: {L} layers, {w} activation patterns per layer")
    print(f"\n  Minimum perturbation path:")
    for ell, s in enumerate(traj):
        pattern = format(s, f'0{int(np.log2(w))}b')
        print(f"    Layer {ell}: pattern {pattern} (state {s})")
    print(f"\n  Minimum perturbation cost (robustness lower bound): {cost:.4f}")
    print(f"  DP operations: {ops}")
    print(f"  Work bound: {dp_work_bound(L, w)}")
    print()


# ──────────────────────────────────────────────────────────────────
# Application 5: Resource-Constrained Scheduling
# ──────────────────────────────────────────────────────────────────

def scheduling_demo():
    """Optimal scheduling through resource-constrained stages.

    Model: A project with L sequential stages. At each stage,
    the project can be in one of w resource configurations.
    Switching configurations between stages incurs a cost.
    Find the minimum-cost resource allocation plan.
    """
    print("=" * 60)
    print("APPLICATION 5: Resource-Constrained Scheduling")
    print("=" * 60)

    np.random.seed(321)
    L, w = 8, 5
    config_names = ["Minimal", "Standard", "Enhanced", "Premium", "Maximum"]

    # Transition costs include both switching cost and operation cost
    step_costs = []
    for ell in range(L):
        M = np.zeros((w, w))
        for i in range(w):
            for j in range(w):
                switching_cost = abs(i - j) * 3.0  # Cost to switch configurations
                operation_cost = 10.0 - j * 1.5     # Higher configs = lower operation cost
                M[i, j] = switching_cost + max(operation_cost, 1.0)
        step_costs.append(M)

    circuit = LayeredTropicalCircuit(step_costs)
    phi, V, ops = bellman_dp(circuit)
    traj, cost = recover_optimal_trajectory(circuit, V)

    print(f"\n  Project: {L} stages, {w} resource configurations")
    print(f"\n  Optimal resource allocation:")
    for ell in range(L + 1):
        stage = f"Stage {ell}" if ell < L else "End"
        config = config_names[traj[ell]]
        print(f"    {stage:8s}: {config}")
    print(f"\n  Minimum total cost: {cost:.2f}")
    print(f"  DP operations: {ops}")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  Applications of Width-Bounded Tropical Φ")
    print("█" * 60 + "\n")

    shortest_path_demo()
    viterbi_analogue_demo()
    transfer_matrix_demo()
    neural_network_robustness_demo()
    scheduling_demo()

    print("All application demos completed successfully.")


#!/usr/bin/env python3
"""
Demonstration of Width-Bounded Dynamic Programming for Tropical Φ.

This script illustrates the core theorems with concrete numerical examples:
1. Computes tropicalPhi via brute-force enumeration of all trajectories
2. Computes the same value via Bellman DP
3. Verifies they agree (computePhiDP_correct)
4. Compares operation counts (dp_beats_enumeration)
"""

import numpy as np
from itertools import product
import time


def path_cost(step_costs, trajectory):
    """Compute the total cost of a trajectory through a layered system.

    Args:
        step_costs: List of L matrices, each w×w, giving transition costs.
        trajectory: List of L+1 states (integers in [0, w)).

    Returns:
        Total cost (sum of transition costs along the trajectory).
    """
    total = 0.0
    for ell, M in enumerate(step_costs):
        total += M[trajectory[ell], trajectory[ell + 1]]
    return total


def tropical_phi_bruteforce(step_costs):
    """Compute tropicalPhi by brute-force enumeration of all trajectories.

    This has complexity O(w^(L+1)) — exponential in L.
    """
    L = len(step_costs)
    w = step_costs[0].shape[0]
    best = float('inf')
    count = 0
    for traj in product(range(w), repeat=L + 1):
        cost = path_cost(step_costs, traj)
        best = min(best, cost)
        count += 1
    return best, count


def dp_table(step_costs):
    """Compute the DP table by backward Bellman recursion.

    Returns:
        V: Array of shape (L+1, w) where V[ell, s] = min cost-to-go from
           state s at layer ell.
        ops: Number of arithmetic operations performed.
    """
    L = len(step_costs)
    w = step_costs[0].shape[0]
    V = np.zeros((L + 1, w))
    ops = 0

    # Backward pass: V[L, :] = 0 (base case)
    for ell in range(L - 1, -1, -1):
        for s in range(w):
            best = float('inf')
            for t in range(w):
                cost = step_costs[ell][s, t] + V[ell + 1, t]
                best = min(best, cost)
                ops += 1  # One add + one min = one "arithmetic operation"
            V[ell, s] = best

    return V, ops


def compute_phi_dp(step_costs):
    """Compute tropicalPhi via dynamic programming.

    Returns the minimum cost and operation count.
    """
    V, ops = dp_table(step_costs)
    w = step_costs[0].shape[0]
    phi = min(V[0, s] for s in range(w))
    ops += w  # Final minimization over initial states
    return phi, ops


def demo_correctness():
    """Demonstrate that DP and brute-force give the same result."""
    print("=" * 60)
    print("DEMO 1: Correctness (computePhiDP_correct)")
    print("=" * 60)

    np.random.seed(42)

    for L, w in [(3, 2), (4, 3), (5, 2), (3, 4), (6, 2)]:
        step_costs = [np.random.rand(w, w) * 10 for _ in range(L)]

        phi_bf, bf_ops = tropical_phi_bruteforce(step_costs)
        phi_dp, dp_ops = compute_phi_dp(step_costs)

        match = np.isclose(phi_bf, phi_dp)
        print(f"  L={L}, w={w}: φ_bf={phi_bf:.6f}, φ_dp={phi_dp:.6f}, "
              f"match={match}, bf_ops={bf_ops}, dp_ops={dp_ops}")
        assert match, f"Mismatch for L={L}, w={w}!"

    print("\n  ✓ All tests passed: DP = brute-force in every case.\n")


def demo_work_bound():
    """Demonstrate the work bound dpWork = L * w * w + w."""
    print("=" * 60)
    print("DEMO 2: Work Bound (dp_work_le)")
    print("=" * 60)

    np.random.seed(123)

    for L, w in [(5, 3), (10, 2), (8, 4), (20, 2), (15, 3)]:
        step_costs = [np.random.rand(w, w) for _ in range(L)]
        _, ops = compute_phi_dp(step_costs)
        bound = L * w * w + w
        print(f"  L={L:2d}, w={w}: ops={ops:5d}, bound={bound:5d}, "
              f"ops ≤ bound: {ops <= bound}")
        assert ops <= bound

    print("\n  ✓ All operation counts within the L·w²+w bound.\n")


def demo_asymptotic_separation():
    """Demonstrate that DP work is eventually less than 2^L."""
    print("=" * 60)
    print("DEMO 3: Asymptotic Separation (dp_beats_enumeration)")
    print("=" * 60)

    for w in [1, 2, 3, 5, 10]:
        print(f"\n  Width w = {w}:")
        print(f"  {'L':>4s} | {'dpWork':>12s} | {'2^L':>15s} | {'dp < 2^L':>8s}")
        print(f"  {'-'*4}-+-{'-'*12}-+-{'-'*15}-+-{'-'*8}")

        crossover = None
        for L in range(1, 51):
            dp_work = L * w * w + w
            exp_val = 2 ** L
            is_less = dp_work < exp_val

            if L <= 15 or (crossover and L <= crossover + 3) or L % 10 == 0:
                print(f"  {L:4d} | {dp_work:12d} | {exp_val:15d} | {'✓' if is_less else '✗':>8s}")

            if is_less and crossover is None:
                crossover = L

        if crossover:
            print(f"  → Crossover at L = {crossover}: DP becomes faster")
        else:
            print(f"  → No crossover in range (need larger L)")

    print()


def demo_timing():
    """Time comparison between brute-force and DP for increasing L."""
    print("=" * 60)
    print("DEMO 4: Timing Comparison")
    print("=" * 60)

    w = 3
    np.random.seed(999)
    print(f"\n  Fixed width w = {w}")
    print(f"  {'L':>4s} | {'BF time (s)':>12s} | {'DP time (s)':>12s} | {'Speedup':>10s}")
    print(f"  {'-'*4}-+-{'-'*12}-+-{'-'*12}-+-{'-'*10}")

    for L in [3, 5, 7, 9, 11, 13]:
        step_costs = [np.random.rand(w, w) for _ in range(L)]

        t0 = time.perf_counter()
        phi_bf, _ = tropical_phi_bruteforce(step_costs)
        t_bf = time.perf_counter() - t0

        t0 = time.perf_counter()
        for _ in range(1000):  # Run DP 1000x for measurable time
            phi_dp, _ = compute_phi_dp(step_costs)
        t_dp = (time.perf_counter() - t0) / 1000

        speedup = t_bf / max(t_dp, 1e-10)
        print(f"  {L:4d} | {t_bf:12.6f} | {t_dp:12.6f} | {speedup:10.1f}x")

    print()


def demo_optimal_trajectory():
    """Demonstrate recovery of the optimal trajectory from the DP table."""
    print("=" * 60)
    print("DEMO 5: Optimal Trajectory Recovery")
    print("=" * 60)

    np.random.seed(7)
    L, w = 5, 4
    step_costs = [np.random.rand(w, w) * 10 for _ in range(L)]

    V, _ = dp_table(step_costs)

    # Find optimal initial state
    s_star = int(np.argmin(V[0, :]))
    trajectory = [s_star]

    # Forward trace
    for ell in range(L):
        s = trajectory[-1]
        costs = [step_costs[ell][s, t] + V[ell + 1, t] for t in range(w)]
        t_star = int(np.argmin(costs))
        trajectory.append(t_star)

    cost = path_cost(step_costs, trajectory)
    phi_dp, _ = compute_phi_dp(step_costs)

    print(f"\n  L={L}, w={w}")
    print(f"  Optimal trajectory: {trajectory}")
    print(f"  Path cost:    {cost:.6f}")
    print(f"  tropicalPhi:  {phi_dp:.6f}")
    print(f"  Match: {np.isclose(cost, phi_dp)}")

    # Show step costs
    print("\n  Step costs along optimal path:")
    for ell in range(L):
        c = step_costs[ell][trajectory[ell], trajectory[ell + 1]]
        print(f"    Layer {ell}: state {trajectory[ell]} → {trajectory[ell+1]}, cost = {c:.4f}")
    print(f"    Total = {cost:.6f}\n")


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  Width-Bounded Tropical Φ: Dynamic Programming Demo")
    print("█" * 60 + "\n")

    demo_correctness()
    demo_work_bound()
    demo_asymptotic_separation()
    demo_timing()
    demo_optimal_trajectory()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Width-Bounded Tropical Φ.

Generates publication-quality figures illustrating:
1. DP vs brute-force operation count scaling
2. Crossover points for different widths
3. DP table heatmap for a sample circuit
4. Speedup factor vs depth
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_scaling_comparison():
    """Plot DP work vs 2^L for various widths."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    L_vals = np.arange(1, 31)
    exp_vals = 2.0 ** L_vals

    ax.semilogy(L_vals, exp_vals, 'k--', linewidth=2, label='$2^L$ (enumeration)', alpha=0.8)

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    for i, w in enumerate([1, 2, 3, 5, 10]):
        dp_vals = L_vals * w * w + w
        ax.semilogy(L_vals, dp_vals, '-o', color=colors[i], markersize=4,
                    linewidth=1.5, label=f'DP work (w={w})')

    ax.set_xlabel('Depth L (number of layers)', fontsize=13)
    ax.set_ylabel('Operations (log scale)', fontsize=13)
    ax.set_title('Dynamic Programming vs Exponential Enumeration', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 30)

    fig.savefig('fig_scaling_comparison.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_crossover_analysis():
    """Plot crossover points where DP becomes faster than 2^L."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: crossover point vs width
    widths = list(range(1, 51))
    crossovers = []
    for w in widths:
        for L in range(1, 500):
            if L * w * w + w < 2 ** L:
                crossovers.append(L)
                break
        else:
            crossovers.append(None)

    valid_w = [w for w, c in zip(widths, crossovers) if c is not None]
    valid_c = [c for c in crossovers if c is not None]

    ax1.plot(valid_w, valid_c, 'o-', color='#e74c3c', markersize=5)
    ax1.set_xlabel('Width w', fontsize=13)
    ax1.set_ylabel('Crossover depth $L_0$', fontsize=13)
    ax1.set_title('Crossover: DP Beats $2^L$', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Right: ratio dp_work / 2^L for w=3
    w = 3
    L_vals = np.arange(1, 25)
    ratios = (L_vals * w * w + w) / (2.0 ** L_vals)

    ax2.semilogy(L_vals, ratios, 'o-', color='#3498db', markersize=5)
    ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Breakeven')
    ax2.set_xlabel('Depth L', fontsize=13)
    ax2.set_ylabel('DP Work / $2^L$', fontsize=13)
    ax2.set_title(f'Work Ratio (w={w})', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('fig_crossover_analysis.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_dp_table_heatmap():
    """Visualize the DP table V[ℓ, s] for a sample circuit."""
    np.random.seed(42)
    L, w = 10, 6
    step_costs = [np.random.rand(w, w) * 5 for _ in range(L)]

    # Compute DP table
    V = np.zeros((L + 1, w))
    for ell in range(L - 1, -1, -1):
        for s in range(w):
            V[ell, s] = min(step_costs[ell][s, t] + V[ell + 1, t] for t in range(w))

    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    im = ax.imshow(V.T, aspect='auto', cmap='viridis_r', interpolation='nearest')
    ax.set_xlabel('Layer ℓ', fontsize=13)
    ax.set_ylabel('State s', fontsize=13)
    ax.set_title('DP Table: Cost-to-Go V[ℓ, s]', fontsize=15, fontweight='bold')
    ax.set_xticks(range(L + 1))
    ax.set_yticks(range(w))
    plt.colorbar(im, ax=ax, label='Cost-to-go')

    # Highlight optimal path
    traj = [int(np.argmin(V[0, :]))]
    for ell in range(L):
        s = traj[-1]
        costs = [step_costs[ell][s, t] + V[ell + 1, t] for t in range(w)]
        traj.append(int(np.argmin(costs)))

    ax.plot(range(L + 1), traj, 'r*-', markersize=12, linewidth=2,
            label='Optimal path', zorder=5)
    ax.legend(fontsize=11, loc='upper right')

    fig.savefig('fig_dp_table.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_speedup_factors():
    """Plot the speedup of DP over brute force for various configurations."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    for w in [2, 3, 4, 5]:
        L_vals = np.arange(2, 20)
        speedups = []
        for L in L_vals:
            bf_ops = L * (w ** (L + 1))
            dp_ops = L * w * w + w
            speedups.append(bf_ops / dp_ops)

        ax.semilogy(L_vals, speedups, 'o-', markersize=4, linewidth=1.5,
                    label=f'w = {w}')

    ax.set_xlabel('Depth L', fontsize=13)
    ax.set_ylabel('Speedup (brute force / DP)', fontsize=13)
    ax.set_title('Exponential Speedup of Dynamic Programming', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.savefig('fig_speedup.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_scaling_comparison()
    print(f"  ✓ Scaling comparison ({len(b64_1)} chars)")

    b64_2 = plot_crossover_analysis()
    print(f"  ✓ Crossover analysis ({len(b64_2)} chars)")

    b64_3 = plot_dp_table_heatmap()
    print(f"  ✓ DP table heatmap ({len(b64_3)} chars)")

    b64_4 = plot_speedup_factors()
    print(f"  ✓ Speedup factors ({len(b64_4)} chars)")

    print("\nAll visualizations generated and saved as PNG files.")
