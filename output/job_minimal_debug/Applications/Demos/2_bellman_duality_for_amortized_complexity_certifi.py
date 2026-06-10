#!/usr/bin/env python3
"""
Applications of Bellman Duality for Amortized Complexity

Real-world applications demonstrating the practical utility of the duality theorem:
1. Dynamic array resize analysis
2. Binary counter increment analysis
3. Online competitive analysis
4. Resource budget certification
"""

import numpy as np
from algorithms import (
    optimal_amortized_rate,
    optimal_bellman_potential,
    amortized_analysis,
    verify_bellman_certificate,
    dynamic_array_costs,
    binary_counter_costs,
)


# ─────────────────────────────────────────────────────────────
# Application 1: Data Structure Performance Guarantees
# ─────────────────────────────────────────────────────────────

def data_structure_certification():
    """
    Certify worst-case amortized bounds for common data structures.
    The duality theorem guarantees that the potential witness proves the bound.
    """
    print("APPLICATION 1: Data Structure Performance Certification")
    print("=" * 60)

    structures = {
        "Dynamic Array (n=1000)": dynamic_array_costs(1000),
        "Binary Counter (n=1000)": binary_counter_costs(1000),
        "Fibonacci-like (n=100)": np.array([
            (i + 1) if bin(i + 1).count('1') == 1 else 1
            for i in range(100)
        ], dtype=float),
    }

    for name, costs in structures.items():
        result = amortized_analysis(costs)
        print(f"\n{name}:")
        print(f"  Total actual cost: {np.sum(costs):.0f}")
        print(f"  Optimal amortized rate: {result.optimal_rate:.4f}")
        print(f"  Amortized total bound: {result.optimal_rate * len(costs):.2f}")
        print(f"  Critical prefix at k={result.critical_prefix}")
        print(f"  Certificate valid: {result.is_dual_feasible}")
        print(f"  Max potential energy: {np.max(result.potential):.2f}")


# ─────────────────────────────────────────────────────────────
# Application 2: Competitive Analysis of Online Algorithms
# ─────────────────────────────────────────────────────────────

def competitive_analysis():
    """
    Use Bellman duality for competitive analysis of online algorithms.

    The competitive ratio c satisfies: ALG_prefix ≤ c · OPT_prefix
    This is exactly feasibleRate for the cost sequence (ALG_i - c · OPT_i).
    """
    print("\n\nAPPLICATION 2: Online Competitive Analysis")
    print("=" * 60)

    # Simulate ski rental problem
    # Rent costs 1/day, buying costs B
    # OPT knows the number of ski days in advance
    B = 10
    np.random.seed(123)
    n_trials = 5

    for trial in range(n_trials):
        # Random number of ski days
        n_days = np.random.randint(1, 30)

        # Online algorithm: rent until cost equals B, then buy
        alg_costs = np.zeros(n_days)
        bought = False
        for day in range(n_days):
            if not bought and day < B:
                alg_costs[day] = 1  # rent
            elif not bought and day == B:
                alg_costs[day] = B  # buy
                bought = True
            # else: already bought, cost = 0

        # Optimal: buy if n_days > B, rent otherwise
        opt_costs = np.zeros(n_days)
        if n_days <= B:
            opt_costs[:] = 1  # rent each day
        else:
            opt_costs[0] = B  # buy on day 1

        alg_total = np.sum(alg_costs)
        opt_total = np.sum(opt_costs)
        ratio = alg_total / opt_total if opt_total > 0 else 1.0

        print(f"\n  Trial {trial+1}: {n_days} ski days, B={B}")
        print(f"    ALG total: {alg_total:.0f}, OPT total: {opt_total:.0f}")
        print(f"    Competitive ratio: {ratio:.4f}")

        # Compute amortized analysis of the gap
        gap = alg_costs - opt_costs
        r_star, k_star = optimal_amortized_rate(gap)
        print(f"    Max prefix gap rate: {r_star:.4f} at k={k_star}")


# ─────────────────────────────────────────────────────────────
# Application 3: Resource Budget Planning
# ─────────────────────────────────────────────────────────────

def resource_budget_planning():
    """
    Use the optimal rate to plan resource budgets.

    Given historical workload data, compute the minimum per-period budget
    that guarantees no deficit at any point. The Bellman potential shows
    the buffer needed at each time step.
    """
    print("\n\nAPPLICATION 3: Resource Budget Planning")
    print("=" * 60)

    # Simulate server workload: bursty with periodic spikes
    np.random.seed(42)
    n = 365  # days
    base_load = 50 + 10 * np.sin(2 * np.pi * np.arange(n) / 7)  # weekly pattern
    spikes = np.zeros(n)
    spike_days = np.random.choice(n, size=20, replace=False)
    spikes[spike_days] = np.random.exponential(200, size=20)
    workload = base_load + spikes + np.random.normal(0, 5, n)
    workload = np.maximum(workload, 0)

    result = amortized_analysis(workload)

    print(f"  Simulation: {n} days of server workload")
    print(f"  Mean daily cost: {np.mean(workload):.2f}")
    print(f"  Max daily cost: {np.max(workload):.2f}")
    print(f"  Optimal daily budget (r*): {result.optimal_rate:.2f}")
    print(f"  Critical period: first {result.critical_prefix} days")
    print(f"  Total budget needed: {result.optimal_rate * n:.2f}")
    print(f"  Total actual cost: {np.sum(workload):.2f}")
    print(f"  Budget surplus: {result.optimal_rate * n - np.sum(workload):.2f}")
    print(f"  Max buffer (potential): {np.max(result.potential):.2f}")
    print(f"  Certificate valid: {result.is_dual_feasible}")

    # Show that a lower budget fails
    lower_budget = np.mean(workload)
    phi_lower = optimal_bellman_potential(workload, lower_budget)
    cert_lower = verify_bellman_certificate(workload, lower_budget, phi_lower)
    print(f"\n  With mean-cost budget ({lower_budget:.2f}):")
    print(f"    Certificate valid: {cert_lower['valid']}")
    print(f"    Min potential: {cert_lower['min_potential']:.2f} (negative = deficit!)")


# ─────────────────────────────────────────────────────────────
# Application 4: Cache Performance Analysis
# ─────────────────────────────────────────────────────────────

def cache_performance():
    """
    Analyze cache hit/miss patterns using amortized complexity.

    Model: cache of size k with LRU eviction. A miss costs 1, a hit costs 0.
    The amortized miss rate is bounded by the optimal amortized rate.
    """
    print("\n\nAPPLICATION 4: Cache Performance Analysis")
    print("=" * 60)

    cache_size = 4
    np.random.seed(7)

    # Generate access pattern with locality
    n_accesses = 200
    n_items = 10
    accesses = []
    current = 0
    for _ in range(n_accesses):
        if np.random.random() < 0.7:
            current = (current + np.random.choice([-1, 0, 1])) % n_items
        else:
            current = np.random.randint(0, n_items)
        accesses.append(current)

    # Simulate LRU cache
    cache = []
    costs = np.zeros(n_accesses)
    for i, item in enumerate(accesses):
        if item in cache:
            cache.remove(item)
            cache.append(item)
            costs[i] = 0  # hit
        else:
            costs[i] = 1  # miss
            cache.append(item)
            if len(cache) > cache_size:
                cache.pop(0)

    result = amortized_analysis(costs)
    hit_rate = 1 - np.mean(costs)

    print(f"  Cache size: {cache_size}, Items: {n_items}, Accesses: {n_accesses}")
    print(f"  Hit rate: {hit_rate:.4f}")
    print(f"  Total misses: {int(np.sum(costs))}")
    print(f"  Optimal amortized miss rate: {result.optimal_rate:.4f}")
    print(f"  Critical window: first {result.critical_prefix} accesses")
    print(f"  Certificate valid: {result.is_dual_feasible}")


if __name__ == "__main__":
    data_structure_certification()
    competitive_analysis()
    resource_budget_planning()
    cache_performance()
    print("\n\nAll applications completed successfully.")


#!/usr/bin/env python3
"""
Bellman Duality for Amortized Complexity: Demonstrations

Concrete numerical examples demonstrating the main theorems:
1. feasibleRate ↔ bellmanFeasible (duality equivalence)
2. optimal rate = max prefix average
3. Constructive potential witness
"""

import numpy as np
from typing import List, Tuple


def prefix_sums(costs: np.ndarray) -> np.ndarray:
    """Compute prefix sums S_0, S_1, ..., S_n where S_k = sum of first k costs."""
    return np.concatenate([[0], np.cumsum(costs)])


def max_prefix_avg(costs: np.ndarray) -> float:
    """Compute the optimal amortized rate r* = max_{1<=k<=n} S_k/k."""
    S = prefix_sums(costs)
    n = len(costs)
    if n == 0:
        return 0.0
    avgs = S[1:] / np.arange(1, n + 1)
    return float(np.max(avgs))


def canonical_potential(costs: np.ndarray, r: float) -> np.ndarray:
    """Construct the canonical Bellman potential: phi_k = r*k - S_k."""
    S = prefix_sums(costs)
    return r * np.arange(len(S)) - S


def verify_bellman_feasibility(costs: np.ndarray, r: float, phi: np.ndarray,
                                tol: float = 1e-10) -> dict:
    """Verify that (r, phi) is a valid Bellman certificate."""
    n = len(costs)
    checks = {
        'phi_0_eq_0': abs(phi[0]) < tol,
        'phi_nonneg': all(phi[k] >= -tol for k in range(n + 1)),
        'bellman_ineq': all(
            costs[i] + phi[i + 1] - phi[i] <= r + tol
            for i in range(n)
        ),
    }
    checks['all_pass'] = all(checks.values())
    return checks


def verify_prefix_feasibility(costs: np.ndarray, r: float, tol: float = 1e-10) -> bool:
    """Verify that r is prefix-feasible: S_k <= r*k for all k."""
    S = prefix_sums(costs)
    return all(S[k] <= r * k + tol for k in range(len(costs) + 1))


# ─────────────────────────────────────────────────────────────
# Example 1: Dynamic Array (doubling strategy)
# ─────────────────────────────────────────────────────────────

def dynamic_array_costs(n: int) -> np.ndarray:
    """Cost sequence for n insertions into a doubling dynamic array."""
    costs = np.ones(n)
    capacity = 1
    for i in range(n):
        if i + 1 > capacity:
            costs[i] = i + 1  # copy all elements
            capacity *= 2
    return costs


print("=" * 60)
print("EXAMPLE 1: Dynamic Array (Doubling Strategy)")
print("=" * 60)

n = 20
costs = dynamic_array_costs(n)
r_star = max_prefix_avg(costs)
phi = canonical_potential(costs, r_star)

print(f"Number of operations: {n}")
print(f"Cost sequence: {costs}")
print(f"Optimal amortized rate r* = {r_star:.4f}")
print(f"Canonical potential: {phi}")
print(f"Bellman verification: {verify_bellman_feasibility(costs, r_star, phi)}")
print(f"Prefix feasibility: {verify_prefix_feasibility(costs, r_star)}")
print()

# Show the duality: bellman inequality values
bellman_values = [costs[i] + phi[i + 1] - phi[i] for i in range(n)]
print(f"Bellman inequality values (cost_i + Δφ_i):")
for i, v in enumerate(bellman_values):
    print(f"  Step {i}: {v:.4f} {'= r*' if abs(v - r_star) < 1e-10 else '<= r*'}")

# ─────────────────────────────────────────────────────────────
# Example 2: Binary Counter
# ─────────────────────────────────────────────────────────────

def binary_counter_costs(n: int) -> np.ndarray:
    """Cost of n binary counter increments. Cost = 1 + trailing ones flipped."""
    costs = np.zeros(n)
    for i in range(n):
        val = i + 1
        trailing = 0
        while val % 2 == 0:
            trailing += 1
            val //= 2
        # Actually: cost = 1 + number of trailing 1s in binary repr of i
        # At step i, incrementing from i to i+1 flips the trailing 1s
        v = i
        t = 0
        while v > 0 and v % 2 == 1:
            t += 1
            v //= 2
        costs[i] = t + 1
    return costs


print("=" * 60)
print("EXAMPLE 2: Binary Counter")
print("=" * 60)

n = 16
costs = binary_counter_costs(n)
r_star = max_prefix_avg(costs)
phi = canonical_potential(costs, r_star)

print(f"Number of increments: {n}")
print(f"Cost sequence: {costs}")
print(f"Optimal amortized rate r* = {r_star:.4f}")
print(f"Canonical potential: {np.round(phi, 4)}")
print(f"Bellman verification: {verify_bellman_feasibility(costs, r_star, phi)}")
print()

# ─────────────────────────────────────────────────────────────
# Example 3: Worst-case spike
# ─────────────────────────────────────────────────────────────

print("=" * 60)
print("EXAMPLE 3: Single Spike (worst case for amortization)")
print("=" * 60)

n = 10
costs = np.ones(n)
costs[0] = 100  # spike at the beginning
r_star = max_prefix_avg(costs)
phi = canonical_potential(costs, r_star)

print(f"Cost sequence: {costs}")
print(f"Optimal amortized rate r* = {r_star:.4f}")
print(f"Critical prefix: k=1, average = {costs[0]:.1f}")
print(f"Full average: {np.mean(costs):.4f}")
print(f"Canonical potential: {np.round(phi, 4)}")
print(f"Bellman verification: {verify_bellman_feasibility(costs, r_star, phi)}")
print()

# ─────────────────────────────────────────────────────────────
# Example 4: Duality demonstration
# ─────────────────────────────────────────────────────────────

print("=" * 60)
print("EXAMPLE 4: Duality Theorem Demonstration")
print("=" * 60)

np.random.seed(42)
n = 50
costs = np.random.exponential(5, n)
r_star = max_prefix_avg(costs)

# Primal: check all prefix bounds
S = prefix_sums(costs)
print(f"Random cost sequence (n={n}), r* = {r_star:.4f}")
print(f"Primal check (all S_k ≤ r*·k): {verify_prefix_feasibility(costs, r_star)}")

# Dual: construct and verify potential
phi = canonical_potential(costs, r_star)
checks = verify_bellman_feasibility(costs, r_star, phi)
print(f"Dual check (Bellman certificate): {checks['all_pass']}")

# Show that r* - epsilon is NOT feasible
eps = 0.01
print(f"\nr* - {eps} = {r_star - eps:.4f} is NOT feasible:")
print(f"  Primal feasible: {verify_prefix_feasibility(costs, r_star - eps)}")
phi_sub = canonical_potential(costs, r_star - eps)
print(f"  Bellman feasible: {verify_bellman_feasibility(costs, r_star - eps, phi_sub)['all_pass']}")

# Identify the critical prefix
avgs = S[1:] / np.arange(1, n + 1)
k_star = np.argmax(avgs) + 1
print(f"\nCritical prefix: k* = {k_star}")
print(f"  S_{k_star} / {k_star} = {S[k_star] / k_star:.4f} = r*")
print(f"  φ_{k_star} = {phi[k_star]:.6f} (should be ≈ 0 at critical prefix)")

# ─────────────────────────────────────────────────────────────
# Example 5: Total charge optimality
# ─────────────────────────────────────────────────────────────

print()
print("=" * 60)
print("EXAMPLE 5: Optimal Total Charge = Total Cost")
print("=" * 60)

n = 10
costs = np.array([3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0, 5.0, 3.0])
total = np.sum(costs)
print(f"Cost sequence: {costs}")
print(f"Total cost: {total}")
print(f"Any charge schedule a with prefix domination must have ∑a ≥ {total}")
print(f"The schedule a = cost achieves ∑a = {total} (tight)")
print(f"This confirms: inf{{∑a : prefix domination}} = ∑cost = {total}")

print()
print("=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Bellman Duality in Amortized Complexity

Generates publication-quality figures illustrating the main theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def dynamic_array_costs(n):
    costs = np.ones(n)
    capacity = 1
    for i in range(n):
        if i + 1 > capacity:
            costs[i] = i + 1
            capacity *= 2
    return costs


def binary_counter_costs(n):
    costs = np.zeros(n)
    for i in range(n):
        v = i; t = 0
        while v > 0 and v % 2 == 1:
            t += 1; v //= 2
        costs[i] = t + 1
    return costs


def viz_duality_diagram():
    """
    Visualization 1: Primal vs Dual feasibility regions.
    Shows prefix sums, rate lines, and the Bellman potential.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    costs = np.array([3, 1, 7, 2, 1, 4, 2, 3, 1, 5], dtype=float)
    n = len(costs)
    S = np.concatenate([[0], np.cumsum(costs)])
    ks = np.arange(n + 1)

    # Optimal rate
    avgs = S[1:] / np.arange(1, n + 1)
    r_star = np.max(avgs)
    k_star = np.argmax(avgs) + 1

    # Panel 1: Prefix sums and rate line
    ax = axes[0]
    ax.step(ks, S, where='post', color='#2196F3', linewidth=2, label='Prefix sum $S_k$')
    ax.plot(ks, r_star * ks, 'r--', linewidth=2, label=f'$r^* \\cdot k$ ($r^*={r_star:.2f}$)')
    ax.fill_between(ks, S, r_star * ks, alpha=0.15, color='green')
    ax.scatter([k_star], [S[k_star]], color='red', s=100, zorder=5,
               label=f'Critical prefix $k^*={k_star}$')
    ax.set_xlabel('Steps $k$', fontsize=12)
    ax.set_ylabel('Cumulative cost', fontsize=12)
    ax.set_title('Primal: Prefix Bounds', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Bellman potential
    ax = axes[1]
    phi = r_star * ks - S
    ax.bar(ks, phi, color='#4CAF50', alpha=0.7, edgecolor='#2E7D32')
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.scatter([k_star], [phi[k_star]], color='red', s=100, zorder=5,
               label=f'$\\varphi_{{{k_star}}} = {phi[k_star]:.2f}$')
    ax.set_xlabel('Steps $k$', fontsize=12)
    ax.set_ylabel('Potential $\\varphi_k$', fontsize=12)
    ax.set_title('Dual: Bellman Potential', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Bellman inequality values
    ax = axes[2]
    bellman = np.array([costs[i] + phi[i + 1] - phi[i] for i in range(n)])
    ax.bar(range(n), bellman, color='#FF9800', alpha=0.7, edgecolor='#E65100')
    ax.axhline(y=r_star, color='red', linewidth=2, linestyle='--',
               label=f'$r^* = {r_star:.2f}$')
    ax.set_xlabel('Step $i$', fontsize=12)
    ax.set_ylabel('$c_i + \\varphi_{i+1} - \\varphi_i$', fontsize=12)
    ax.set_title('Bellman Values (all $= r^*$)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Bellman Duality: Primal-Dual Correspondence', fontsize=16,
                 fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_prefix_averages():
    """
    Visualization 2: Prefix averages showing the optimal rate.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for ax, (name, costs) in zip(axes, [
        ("Dynamic Array", dynamic_array_costs(50)),
        ("Binary Counter", binary_counter_costs(64))
    ]):
        n = len(costs)
        S = np.concatenate([[0], np.cumsum(costs)])
        avgs = S[1:] / np.arange(1, n + 1)
        r_star = np.max(avgs)
        k_star = np.argmax(avgs) + 1

        ax.plot(range(1, n + 1), avgs, 'b-', linewidth=2, label='Prefix average $S_k/k$')
        ax.axhline(y=r_star, color='red', linewidth=2, linestyle='--',
                   label=f'$r^* = {r_star:.4f}$')
        ax.scatter([k_star], [r_star], color='red', s=100, zorder=5)
        ax.fill_between(range(1, n + 1), avgs, r_star, alpha=0.1, color='blue')
        ax.set_xlabel('Prefix length $k$', fontsize=12)
        ax.set_ylabel('Average cost $S_k/k$', fontsize=12)
        ax.set_title(f'{name}: $r^* = \\max_k S_k/k$', fontsize=14, fontweight='bold')
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def viz_potential_landscape():
    """
    Visualization 3: Potential landscape for different rates.
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    costs = dynamic_array_costs(30)
    n = len(costs)
    S = np.concatenate([[0], np.cumsum(costs)])
    avgs = S[1:] / np.arange(1, n + 1)
    r_star = np.max(avgs)
    ks = np.arange(n + 1)

    rates = [r_star * 0.8, r_star * 0.9, r_star, r_star * 1.1, r_star * 1.3]
    colors = ['#D32F2F', '#FF5722', '#4CAF50', '#2196F3', '#9C27B0']
    labels = ['$0.8 r^*$ (infeasible)', '$0.9 r^*$ (infeasible)',
              '$r^*$ (optimal)', '$1.1 r^*$ (feasible)', '$1.3 r^*$ (feasible)']

    for r, color, label in zip(rates, colors, labels):
        phi = r * ks - S
        style = '--' if r < r_star - 0.001 else '-'
        ax.plot(ks, phi, color=color, linewidth=2, linestyle=style, label=label)

    ax.axhline(y=0, color='black', linewidth=1, linestyle='-')
    ax.fill_between(ks, -50, 0, alpha=0.05, color='red')
    ax.set_xlabel('Steps $k$', fontsize=12)
    ax.set_ylabel('Potential $\\varphi_k = r \\cdot k - S_k$', fontsize=12)
    ax.set_title('Potential Landscape: Feasibility Boundary at $r^*$',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=-20)

    plt.tight_layout()
    return fig


def viz_duality_convergence():
    """
    Visualization 4: How the optimal rate converges as trace length grows.
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    np.random.seed(42)
    max_n = 500
    costs = np.random.exponential(5, max_n)

    ns = range(10, max_n + 1, 5)
    rates = []
    for n in ns:
        S = np.cumsum(costs[:n])
        avgs = S / np.arange(1, n + 1)
        rates.append(np.max(avgs))

    ax.plot(list(ns), rates, 'b-', linewidth=2, label='$r^*(n)$')
    ax.axhline(y=np.mean(costs), color='gray', linewidth=1, linestyle=':',
               label=f'Mean cost = {np.mean(costs):.2f}')

    # The long-run rate should converge to the mean for i.i.d. costs
    ax.set_xlabel('Trace length $n$', fontsize=12)
    ax.set_ylabel('Optimal rate $r^*(n)$', fontsize=12)
    ax.set_title('Optimal Rate vs. Trace Length (i.i.d. Exponential Costs)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


if __name__ == "__main__":
    figures = {}

    print("Generating Figure 1: Duality Diagram...")
    fig1 = viz_duality_diagram()
    fig1.savefig('viz_duality_diagram.png', dpi=150, bbox_inches='tight')
    figures['duality_diagram'] = fig_to_base64(fig1)
    plt.close(fig1)

    print("Generating Figure 2: Prefix Averages...")
    fig2 = viz_prefix_averages()
    fig2.savefig('viz_prefix_averages.png', dpi=150, bbox_inches='tight')
    figures['prefix_averages'] = fig_to_base64(fig2)
    plt.close(fig2)

    print("Generating Figure 3: Potential Landscape...")
    fig3 = viz_potential_landscape()
    fig3.savefig('viz_potential_landscape.png', dpi=150, bbox_inches='tight')
    figures['potential_landscape'] = fig_to_base64(fig3)
    plt.close(fig3)

    print("Generating Figure 4: Convergence...")
    fig4 = viz_duality_convergence()
    fig4.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    figures['convergence'] = fig_to_base64(fig4)
    plt.close(fig4)

    # Save base64 data for PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump(figures, f)

    print("All visualizations generated successfully.")
