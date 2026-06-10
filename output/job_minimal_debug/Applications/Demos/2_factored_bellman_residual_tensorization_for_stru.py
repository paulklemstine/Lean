#!/usr/bin/env python3
"""
Applications of Factored Bellman Residual Tensorization

Demonstrates real-world applications:
1. Multi-robot warehouse navigation (factored across robots)
2. Supply chain inventory management (factored across products)
3. Network routing with independent links
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import FactorMDP, FactoredMDP, factored_value_iteration, generate_convergence_certificate


def warehouse_navigation():
    """
    Multi-robot warehouse navigation.

    Each robot navigates a small grid independently.
    The factored approach scales linearly in the number of robots,
    while the naive approach scales exponentially.
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Robot Warehouse Navigation")
    print("=" * 60)

    grid_size = 4  # 4x4 grid per robot
    n_states = grid_size * grid_size  # 16 states per robot
    gamma = 0.95

    def create_robot_factor(seed: int) -> FactorMDP:
        """Create a single robot navigation factor."""
        rng = np.random.RandomState(seed)

        # Transition: random walk on grid with some structure
        P = np.zeros((n_states, n_states))
        for s in range(n_states):
            row, col = s // grid_size, s % grid_size
            neighbors = [(row, col)]  # stay
            if row > 0: neighbors.append((row-1, col))
            if row < grid_size-1: neighbors.append((row+1, col))
            if col > 0: neighbors.append((row, col-1))
            if col < grid_size-1: neighbors.append((row, col+1))
            for r, c in neighbors:
                P[s, r * grid_size + c] += 1.0
            P[s] /= P[s].sum()

        # Reward: goal location gives high reward
        goal = rng.randint(n_states)
        r = -0.1 * np.ones(n_states)
        r[goal] = 1.0

        return FactorMDP(n_states, r, P, gamma)

    scalability = []
    for n_robots in [1, 2, 3, 4, 5, 6, 8, 10]:
        factors = [create_robot_factor(seed=i) for i in range(n_robots)]
        mdp = FactoredMDP(factors)

        Vi, history = factored_value_iteration(mdp, tol=1e-6, max_sweeps=500)
        cert = generate_convergence_certificate(mdp, Vi, history)

        factored_memory = sum(f.n_states for f in factors)
        naive_memory = mdp.product_state_size

        scalability.append({
            'n_robots': n_robots,
            'sweeps': cert['sweeps'],
            'product_size': naive_memory,
            'factored_size': factored_memory,
            'savings': naive_memory / factored_memory if factored_memory > 0 else float('inf')
        })

        print(f"  {n_robots} robots: |S|={naive_memory:>12,d}, "
              f"factored={factored_memory:>6d}, "
              f"savings={naive_memory/factored_memory:>10,.0f}x, "
              f"sweeps={cert['sweeps']:>4d}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    n_list = [s['n_robots'] for s in scalability]
    prod_list = [s['product_size'] for s in scalability]
    fact_list = [s['factored_size'] for s in scalability]
    sweep_list = [s['sweeps'] for s in scalability]

    ax1.semilogy(n_list, prod_list, 'ro-', markersize=8, label='Naive: n^k states')
    ax1.semilogy(n_list, fact_list, 'bs-', markersize=8, label='Factored: k·n states')
    ax1.set_xlabel('Number of Robots')
    ax1.set_ylabel('Memory (# states)')
    ax1.set_title('Memory Scaling: Exponential vs Linear')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.plot(n_list, sweep_list, 'gs-', markersize=8, linewidth=2)
    ax2.set_xlabel('Number of Robots')
    ax2.set_ylabel('Sweeps to Converge')
    ax2.set_title('Convergence: Roughly Constant in k')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Multi-Robot Warehouse: Factored vs Naive Planning', fontsize=14)
    fig.tight_layout()
    fig.savefig('fig_warehouse.png', dpi=150)
    plt.close(fig)
    print("  → Saved fig_warehouse.png")


def supply_chain():
    """
    Supply chain inventory management.

    Each product has independent inventory dynamics.
    Planning over all products jointly is exponential;
    factored planning is linear in the number of products.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Supply Chain Inventory Management")
    print("=" * 60)

    n_levels = 10  # inventory levels per product
    gamma = 0.95

    def create_product_factor(demand_rate: float, seed: int) -> FactorMDP:
        """Create inventory management factor for one product."""
        rng = np.random.RandomState(seed)

        # Transition: inventory decreases by demand, replenishes stochastically
        P = np.zeros((n_levels, n_levels))
        for s in range(n_levels):
            for s_next in range(n_levels):
                # Simple model: demand reduces inventory, occasional restocking
                if s_next <= s:
                    P[s, s_next] = demand_rate ** (s - s_next) * (1 - demand_rate)
                elif s_next == n_levels - 1:
                    P[s, s_next] = 0.1  # restocking probability
                else:
                    P[s, s_next] = 0.01
            P[s] /= P[s].sum()

        # Reward: holding cost + stockout penalty
        r = np.zeros(n_levels)
        for s in range(n_levels):
            r[s] = -0.1 * s  # holding cost
            if s == 0:
                r[s] -= 5.0  # stockout penalty

        return FactorMDP(n_levels, r, P, gamma)

    n_products_list = [2, 5, 10, 15, 20]
    results = []

    for n_products in n_products_list:
        factors = [create_product_factor(
            demand_rate=0.3 + 0.05 * i,
            seed=100 + i
        ) for i in range(n_products)]
        mdp = FactoredMDP(factors)

        Vi, history = factored_value_iteration(mdp, tol=1e-6, max_sweeps=500)
        cert = generate_convergence_certificate(mdp, Vi, history)

        results.append({
            'n_products': n_products,
            'product_size': mdp.product_state_size,
            'factored_size': sum(f.n_states for f in factors),
            'sweeps': cert['sweeps'],
            'converged': cert['converged']
        })

        print(f"  {n_products:3d} products: |S|={mdp.product_state_size:>15,d}, "
              f"factored={sum(f.n_states for f in factors):>6d}, "
              f"sweeps={cert['sweeps']:>4d}")

    return results


def network_routing():
    """
    Network routing with independent link dynamics.

    Each link has independent congestion dynamics.
    Factored planning scales linearly in number of links.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Routing (Independent Links)")
    print("=" * 60)

    n_congestion_levels = 5
    gamma = 0.9

    def create_link_factor(capacity: float, seed: int) -> FactorMDP:
        """Create a link congestion dynamics factor."""
        rng = np.random.RandomState(seed)

        P = np.zeros((n_congestion_levels, n_congestion_levels))
        for s in range(n_congestion_levels):
            load = s / (n_congestion_levels - 1)
            for s_next in range(n_congestion_levels):
                # Congestion tends to mean-revert to capacity-dependent level
                target = capacity * (n_congestion_levels - 1)
                P[s, s_next] = np.exp(-0.5 * (s_next - target) ** 2)
            P[s] /= P[s].sum()

        # Reward: negative of delay (increases with congestion)
        r = np.array([-s ** 1.5 for s in range(n_congestion_levels)])

        return FactorMDP(n_congestion_levels, r, P, gamma)

    for n_links in [2, 4, 8, 12, 16, 20]:
        factors = [create_link_factor(
            capacity=0.3 + 0.4 * np.random.rand(),
            seed=200 + i
        ) for i in range(n_links)]
        mdp = FactoredMDP(factors)

        Vi, history = factored_value_iteration(mdp, tol=1e-6, max_sweeps=500)
        cert = generate_convergence_certificate(mdp, Vi, history)

        print(f"  {n_links:3d} links: |S|={mdp.product_state_size:>15,d}, "
              f"sweeps={cert['sweeps']:>4d}, converged={cert['converged']}")


if __name__ == '__main__':
    warehouse_navigation()
    supply_chain()
    network_routing()
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Factored Bellman Residual Tensorization — Demonstration

This script demonstrates the key theorems with concrete numerical examples:
1. Iterative decay of a sequence under subtractive bounds
2. Sweep composition: k factor updates compose to reduce gap by sum of betas
3. Sup-norm tensorization: gap of separable value ≤ sum of factor gaps
4. Full factored MDP convergence showing dimension-breaking behavior
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ============================================================
# Demo 1: Abstract iterative decay
# ============================================================

def demo_iterative_decay():
    """
    Demonstrate iterate_decay_le_max:
    x_{n+1} ≤ max(0, x_n - β) implies x_t ≤ max(0, x_0 - t*β).
    """
    print("=" * 60)
    print("DEMO 1: Abstract Iterative Decay")
    print("=" * 60)

    x0 = 10.0
    beta = 0.7

    # Simulate the sequence
    T = 25
    x_actual = [x0]
    x_bound = [x0]
    for t in range(1, T):
        x_next = max(0, x_actual[-1] - beta)
        x_actual.append(x_next)
        x_bound.append(max(0, x0 - t * beta))

    print(f"Initial value: x₀ = {x0}")
    print(f"Step size: β = {beta}")
    print(f"Predicted zero-crossing: t = ⌈{x0}/{beta}⌉ = {int(np.ceil(x0/beta))}")
    print(f"Actual zero at t = {next(t for t, v in enumerate(x_actual) if v == 0)}")
    print()

    for t in [0, 5, 10, 14, 15, 20]:
        if t < len(x_actual):
            print(f"  t={t:3d}: x(t)={x_actual[t]:.4f}  bound={x_bound[t]:.4f}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ts = range(T)
    ax.plot(ts, x_actual, 'b-o', markersize=4, label='x(t) actual')
    ax.plot(ts, x_bound, 'r--s', markersize=4, label='max(0, x₀ - t·β) bound')
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('Iteration t')
    ax.set_ylabel('Value')
    ax.set_title('Iterative Decay: x(t) ≤ max(0, x₀ - t·β)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig_iterative_decay.png', dpi=150)
    plt.close(fig)
    print("\n  → Saved fig_iterative_decay.png")


# ============================================================
# Demo 2: Factored MDP with separable structure
# ============================================================

def create_factored_mdp(k: int, n_per_factor: int, gamma: float):
    """
    Create a factored MDP with k factors, each with n_per_factor states.
    Rewards and transitions are factored (independent across factors).
    """
    # Factor reward functions (random)
    np.random.seed(42)
    rewards = [np.random.randn(n_per_factor) for _ in range(k)]

    # Factor transition matrices (random stochastic)
    transitions = []
    for _ in range(k):
        P = np.random.rand(n_per_factor, n_per_factor)
        P = P / P.sum(axis=1, keepdims=True)
        transitions.append(P)

    return rewards, transitions


def factor_bellman_operator(Vi: np.ndarray, ri: np.ndarray, Pi: np.ndarray, gamma: float) -> np.ndarray:
    """Apply factor Bellman operator: Ti(Vi) = ri + γ * Pi @ Vi"""
    return ri + gamma * Pi @ Vi


def factor_gap(Vi: np.ndarray, ri: np.ndarray, Pi: np.ndarray, gamma: float) -> float:
    """Compute factor Bellman residual: max|Ti(Vi) - Vi|"""
    TVi = factor_bellman_operator(Vi, ri, Pi, gamma)
    return np.max(np.abs(TVi - Vi))


def demo_factored_mdp():
    """
    Demonstrate Bellman residual tensorization on a concrete factored MDP.
    Shows that global gap ≤ sum of factor gaps, and sweep convergence.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Factored MDP Residual Tensorization")
    print("=" * 60)

    k = 4           # number of factors
    n = 5           # states per factor
    gamma = 0.9     # discount

    rewards, transitions = create_factored_mdp(k, n, gamma)

    # Initialize separable value function: V(s) = sum_i Vi(si)
    Vi = [np.zeros(n) for _ in range(k)]

    # Track gaps
    num_sweeps = 30
    global_gaps = []
    sum_factor_gaps = []
    factor_gaps_history = [[] for _ in range(k)]

    for sweep in range(num_sweeps):
        # Compute factor gaps
        f_gaps = [factor_gap(Vi[i], rewards[i], transitions[i], gamma) for i in range(k)]
        sum_fg = sum(f_gaps)

        # Compute global gap (on product state)
        # For separable V, T(V)(s) = sum_i Ti(Vi)(si), so gap = max_s |sum_i (Ti(Vi)(si) - Vi(si))|
        # By triangle inequality: gap ≤ sum_i max_{si} |Ti(Vi)(si) - Vi(si)| = sum_i gap_i
        residuals = [factor_bellman_operator(Vi[i], rewards[i], transitions[i], gamma) - Vi[i]
                     for i in range(k)]

        # Compute exact global gap over product states (sample)
        # For separable functions, gap = max over product of |sum of factor residuals|
        # We compute this exactly for small n
        global_gap = 0
        for s in np.ndindex(*([n] * k)):
            val = sum(residuals[i][s[i]] for i in range(k))
            global_gap = max(global_gap, abs(val))

        global_gaps.append(global_gap)
        sum_factor_gaps.append(sum_fg)
        for i in range(k):
            factor_gaps_history[i].append(f_gaps[i])

        # Coordinatewise Bellman update (sweep)
        for i in range(k):
            Vi[i] = factor_bellman_operator(Vi[i], rewards[i], transitions[i], gamma)

    print(f"Factors: k = {k}")
    print(f"States per factor: n = {n}")
    print(f"Product state space: |S| = {n**k}")
    print(f"Discount: γ = {gamma}")
    print()
    print("Tensorization inequality: gap(V) ≤ Σᵢ gapᵢ(Vᵢ)")
    print()
    print(f"  {'Sweep':>6s}  {'Global Gap':>12s}  {'Σ Factor Gaps':>14s}  {'Ratio':>8s}")
    print(f"  {'─'*6:>6s}  {'─'*12:>12s}  {'─'*14:>14s}  {'─'*8:>8s}")
    for t in [0, 1, 2, 5, 10, 15, 20, 25, 29]:
        if t < len(global_gaps):
            ratio = global_gaps[t] / sum_factor_gaps[t] if sum_factor_gaps[t] > 0 else 0
            print(f"  {t:6d}  {global_gaps[t]:12.6f}  {sum_factor_gaps[t]:14.6f}  {ratio:8.4f}")

    # Verify tensorization holds at every step
    violations = sum(1 for g, s in zip(global_gaps, sum_factor_gaps) if g > s + 1e-10)
    print(f"\n  Tensorization violations: {violations}/{len(global_gaps)}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    sweeps = range(num_sweeps)
    ax1.plot(sweeps, global_gaps, 'b-o', markersize=4, label='Global gap', linewidth=2)
    ax1.plot(sweeps, sum_factor_gaps, 'r--s', markersize=4, label='Σ factor gaps (upper bound)')
    ax1.set_xlabel('Sweep')
    ax1.set_ylabel('Bellman Residual')
    ax1.set_title('Residual Tensorization: gap(V) ≤ Σᵢ gapᵢ(Vᵢ)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')

    for i in range(k):
        ax2.plot(sweeps, factor_gaps_history[i], '-o', markersize=3,
                 label=f'Factor {i+1} gap', alpha=0.7)
    ax2.set_xlabel('Sweep')
    ax2.set_ylabel('Factor Bellman Residual')
    ax2.set_title('Individual Factor Gaps Decay')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')

    fig.tight_layout()
    fig.savefig('fig_tensorization.png', dpi=150)
    plt.close(fig)
    print("  → Saved fig_tensorization.png")


# ============================================================
# Demo 3: Dimension-breaking comparison
# ============================================================

def demo_dimension_breaking():
    """
    Compare convergence scaling: factor count k vs product state space size.
    Shows that sweep convergence depends on k, not n^k.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Dimension-Breaking — Convergence vs Factor Count")
    print("=" * 60)

    gamma = 0.9
    n = 3  # states per factor

    results = []
    for k in [1, 2, 3, 4, 5, 6]:
        rewards, transitions = create_factored_mdp(k, n, gamma)
        Vi = [np.zeros(n) for _ in range(k)]

        # Run sweeps until convergence
        tol = 1e-6
        for sweep in range(500):
            f_gaps = [factor_gap(Vi[i], rewards[i], transitions[i], gamma) for i in range(k)]
            total_gap = sum(f_gaps)
            if total_gap < tol:
                break
            for i in range(k):
                Vi[i] = factor_bellman_operator(Vi[i], rewards[i], transitions[i], gamma)

        product_size = n ** k
        results.append((k, product_size, sweep + 1, total_gap))
        print(f"  k={k}, |S|={product_size:>8d}, sweeps to converge: {sweep+1:>4d}")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ks = [r[0] for r in results]
    sizes = [r[1] for r in results]
    sweeps_conv = [r[2] for r in results]

    ax1.bar(ks, sweeps_conv, color='steelblue', alpha=0.8)
    ax1.set_xlabel('Number of Factors k')
    ax1.set_ylabel('Sweeps to Converge')
    ax1.set_title('Convergence: Linear in k')
    ax1.grid(True, alpha=0.3, axis='y')

    ax2.semilogy(ks, sizes, 'ro-', markersize=8, label='Product state space |S| = n^k')
    ax2.semilogy(ks, sweeps_conv, 'bs-', markersize=8, label='Sweeps to converge')
    ax2.set_xlabel('Number of Factors k')
    ax2.set_ylabel('Count (log scale)')
    ax2.set_title('Dimension Breaking: Sweeps ≪ |S|')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('fig_dimension_breaking.png', dpi=150)
    plt.close(fig)
    print("\n  → Saved fig_dimension_breaking.png")


# ============================================================
# Demo 4: Sweep decay trajectory
# ============================================================

def demo_sweep_decay_trajectory():
    """
    Show the linear decay bound max(0, gap₀ - t·β) vs actual gap trajectory.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Sweep Decay Trajectory")
    print("=" * 60)

    k = 3
    n = 4
    gamma = 0.9

    rewards, transitions = create_factored_mdp(k, n, gamma)
    Vi = [np.zeros(n) for _ in range(k)]

    num_sweeps = 40
    gaps = []

    for sweep in range(num_sweeps):
        f_gaps = [factor_gap(Vi[i], rewards[i], transitions[i], gamma) for i in range(k)]
        total = sum(f_gaps)
        gaps.append(total)
        for i in range(k):
            Vi[i] = factor_bellman_operator(Vi[i], rewards[i], transitions[i], gamma)

    # Estimate β per sweep (minimum observed decrease)
    decreases = [gaps[t] - gaps[t+1] for t in range(len(gaps)-1) if gaps[t] > 1e-8]
    if decreases:
        beta_est = min(decreases)
    else:
        beta_est = 0.1

    # Compute linear bound
    gap0 = gaps[0]
    linear_bound = [max(0, gap0 - t * beta_est) for t in range(num_sweeps)]

    print(f"Initial gap: {gap0:.6f}")
    print(f"Estimated β per sweep: {beta_est:.6f}")
    print(f"Predicted convergence: t ≈ {int(np.ceil(gap0/beta_est)) if beta_est > 0 else '∞'}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ts = range(num_sweeps)
    ax.plot(ts, gaps, 'b-o', markersize=4, label='Actual Σ factor gaps', linewidth=2)
    ax.plot(ts, linear_bound, 'r--', label=f'max(0, gap₀ - t·β), β={beta_est:.4f}', linewidth=2)
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('Sweep t')
    ax.set_ylabel('Bellman Residual')
    ax.set_title('Sweep Decay: gap(Sweep^t V₀) ≤ max(0, gap₀ - t·β)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig_sweep_decay.png', dpi=150)
    plt.close(fig)
    print("  → Saved fig_sweep_decay.png")


if __name__ == '__main__':
    demo_iterative_decay()
    demo_factored_mdp()
    demo_dimension_breaking()
    demo_sweep_decay_trajectory()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
