#!/usr/bin/env python3
"""
Tropical Proof Complexity: Demonstration

This script demonstrates the core concepts of the tropical proof complexity
framework through numerical examples.
"""

import math
from typing import List, Tuple


def tropical_cost(epsilon: float) -> float:
    """Compute the tropical cost of an error value: τ(ε) = -log(ε)"""
    assert 0 < epsilon <= 1, f"Error must be in (0, 1], got {epsilon}"
    return -math.log(epsilon)


def amplified_error(base_error: float, k: int) -> float:
    """Compute the error after k-fold repetition: ε^k"""
    return base_error ** k


def amplified_cost(unit_cost: float, k: int) -> float:
    """Compute the cost after k-fold repetition: k · c"""
    return k * unit_cost


def demonstrate_duality():
    """Show the core amplification-cost duality."""
    print("=" * 60)
    print("AMPLIFICATION-COST DUALITY DEMONSTRATION")
    print("=" * 60)

    base_error = 0.3
    unit_cost = 1.0
    tau = tropical_cost(base_error)

    print(f"\nBase error: ε = {base_error}")
    print(f"Unit cost: c = {unit_cost}")
    print(f"Tropical cost: τ(ε) = -log({base_error}) = {tau:.4f}")
    print()
    print(f"{'k':>4} | {'Error ε^k':>14} | {'Cost k·c':>10} | {'τ(ε^k)':>12} | {'k·τ(ε)':>12} | {'Match?':>7}")
    print("-" * 70)

    for k in range(1, 11):
        err = amplified_error(base_error, k)
        cost = amplified_cost(unit_cost, k)
        tau_err = tropical_cost(err)
        k_tau = k * tau
        match = abs(tau_err - k_tau) < 1e-10
        print(f"{k:4d} | {err:14.10f} | {cost:10.1f} | {tau_err:12.6f} | {k_tau:12.6f} | {'✓' if match else '✗':>7}")

    print("\n→ The tropical cost τ(ε^k) = k·τ(ε) always holds: exponential")
    print("  decay in error space = linear growth in tropical space.")


def demonstrate_multiplicativity():
    """Show that the tropical cost transform converts multiplication to addition."""
    print("\n" + "=" * 60)
    print("TROPICAL COST MULTIPLICATIVITY")
    print("=" * 60)

    pairs = [(0.3, 0.5), (0.1, 0.2), (0.4, 0.6), (0.15, 0.25)]

    print(f"\n{'ε₁':>6} | {'ε₂':>6} | {'ε₁·ε₂':>10} | {'τ(ε₁·ε₂)':>12} | {'τ(ε₁)+τ(ε₂)':>14} | {'Match?':>7}")
    print("-" * 65)

    for e1, e2 in pairs:
        prod = e1 * e2
        tau_prod = tropical_cost(prod)
        tau_sum = tropical_cost(e1) + tropical_cost(e2)
        match = abs(tau_prod - tau_sum) < 1e-10
        print(f"{e1:6.2f} | {e2:6.2f} | {prod:10.6f} | {tau_prod:12.6f} | {tau_sum:14.6f} | {'✓' if match else '✗':>7}")

    print("\n→ τ(ε₁·ε₂) = τ(ε₁) + τ(ε₂): multiplication ↦ addition")


def demonstrate_barrier():
    """Show the tropical barrier theorem."""
    print("\n" + "=" * 60)
    print("TROPICAL BARRIER THEOREM")
    print("=" * 60)

    costs = [2.5, 3.1, 4.2, 2.8, 5.0]
    barrier = min(costs)

    print(f"\nProof strategy costs: {costs}")
    print(f"Tropical barrier B = min(costs) = {barrier}")
    print()
    print("Verification that barrier survives selection:")
    for i, c in enumerate(costs):
        print(f"  Strategy {i+1}: cost = {c:.1f} ≥ B = {barrier} ✓")

    print(f"\nBarrier scaling under k-fold repetition:")
    for k in range(1, 6):
        print(f"  k = {k}: minimum total cost ≥ k·B = {k}·{barrier} = {k*barrier:.1f}")
        print(f"           maximum achievable error ≤ exp(-k·B) = exp(-{k*barrier:.1f}) = {math.exp(-k*barrier):.6e}")


def demonstrate_pareto():
    """Show the Pareto frontier for amplification chains."""
    print("\n" + "=" * 60)
    print("PARETO FRONTIER: COST-ERROR TRADEOFF")
    print("=" * 60)

    chains = [
        ("Fast/Weak", 0.4, 0.5),
        ("Balanced", 0.3, 1.0),
        ("Slow/Strong", 0.1, 2.0),
    ]

    for name, base_err, unit_c in chains:
        print(f"\n--- Chain: {name} (ε={base_err}, c={unit_c}) ---")
        print(f"{'k':>4} | {'Cost':>8} | {'Error':>14} | {'τ(error)':>10}")
        print("-" * 45)
        for k in range(1, 8):
            err = amplified_error(base_err, k)
            cost = amplified_cost(unit_c, k)
            tau = tropical_cost(err)
            print(f"{k:4d} | {cost:8.1f} | {err:14.10f} | {tau:10.4f}")


def demonstrate_parallel_optimization():
    """Show optimal strategy selection from parallel alternatives."""
    print("\n" + "=" * 60)
    print("PARALLEL STRATEGY OPTIMIZATION")
    print("=" * 60)

    strategies = [
        ("SMT Solver", 0.35, 0.8),
        ("Heuristic", 0.45, 0.3),
        ("ML-Guided", 0.25, 1.5),
        ("Brute Force", 0.05, 5.0),
    ]

    target_error = 1e-6
    print(f"\nTarget error: δ = {target_error}")
    print(f"Target tropical cost: τ(δ) = {tropical_cost(target_error):.4f}")

    print(f"\n{'Strategy':>15} | {'ε':>6} | {'c':>6} | {'τ(ε)':>8} | {'k needed':>10} | {'Total cost':>12}")
    print("-" * 70)

    best_cost = float('inf')
    best_name = ""

    for name, err, cost in strategies:
        tau = tropical_cost(err)
        k_needed = math.ceil(math.log(target_error) / math.log(err))
        total_cost = k_needed * cost
        if total_cost < best_cost:
            best_cost = total_cost
            best_name = name
        print(f"{name:>15} | {err:6.2f} | {cost:6.1f} | {tau:8.4f} | {k_needed:10d} | {total_cost:12.1f}")

    print(f"\n→ Optimal: {best_name} with total cost {best_cost:.1f}")
    print(f"  (This is the tropical minimum over all strategies)")


def demonstrate_distributivity():
    """Show tropical distributivity: k · min(c₁, c₂) = min(k·c₁, k·c₂)."""
    print("\n" + "=" * 60)
    print("TROPICAL DISTRIBUTIVITY")
    print("=" * 60)

    c1, c2 = 2.3, 3.7
    print(f"\nc₁ = {c1}, c₂ = {c2}")
    print(f"\n{'k':>4} | {'k·min(c₁,c₂)':>14} | {'min(k·c₁,k·c₂)':>16} | {'Equal?':>7}")
    print("-" * 50)

    for k in range(1, 8):
        lhs = k * min(c1, c2)
        rhs = min(k * c1, k * c2)
        eq = abs(lhs - rhs) < 1e-10
        print(f"{k:4d} | {lhs:14.4f} | {rhs:16.4f} | {'✓' if eq else '✗':>7}")

    print("\n→ Amplify-then-select = select-then-amplify (tropical distributivity)")


if __name__ == "__main__":
    demonstrate_duality()
    demonstrate_multiplicativity()
    demonstrate_barrier()
    demonstrate_pareto()
    demonstrate_parallel_optimization()
    demonstrate_distributivity()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Barriers and Strategy Selection

Shows how tropical barriers persist under strategy selection and scale
under repetition.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Barrier persistence under selection
    ax1 = axes[0]
    strategies = ['Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E']
    costs = [3.2, 4.1, 2.8, 5.5, 3.7]
    barrier = min(costs)

    colors = ['#4CAF50' if c == barrier else '#2196F3' for c in costs]
    bars = ax1.bar(strategies, costs, color=colors, edgecolor='black', linewidth=0.5)
    ax1.axhline(y=barrier, color='red', linestyle='--', linewidth=2,
                label=f'Barrier B = {barrier}')
    ax1.set_ylabel('Tropical Cost', fontsize=12)
    ax1.set_title('Tropical Barrier:\nNo Strategy Breaks Below B', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, max(costs) * 1.2)
    for bar, cost in zip(bars, costs):
        ax1.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.1,
                f'{cost}', ha='center', va='bottom', fontsize=10)

    # Panel 2: Barrier scaling under repetition
    ax2 = axes[1]
    ks = np.arange(1, 11)

    for name, cost in [('Best (B=2.8)', 2.8), ('Average (3.7)', 3.7), ('Worst (5.5)', 5.5)]:
        total_costs = ks * cost
        errors = np.exp(-total_costs)
        ax2.semilogy(ks, errors, 'o-', label=name, markersize=5)

    # Barrier line
    barrier_errors = np.exp(-ks * barrier)
    ax2.fill_between(ks, barrier_errors, 1, alpha=0.1, color='red')
    ax2.semilogy(ks, barrier_errors, 'r--', linewidth=2,
                 label=f'Barrier bound exp(-k·{barrier})')

    ax2.set_xlabel('Rounds (k)', fontsize=12)
    ax2.set_ylabel('Achievable Error (log scale)', fontsize=12)
    ax2.set_title('Barrier Scaling:\nLinear in Tropical ↔ Exponential in Error', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_barriers.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_barriers.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Amplification-Cost Duality

Shows the core duality: exponential error decay in probability space
becomes linear cost growth in tropical space.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    base_errors = [0.1, 0.2, 0.3, 0.4, 0.5]
    max_k = 15

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Exponential error decay
    ax1 = axes[0]
    for eps in base_errors:
        ks = np.arange(1, max_k + 1)
        errors = eps ** ks
        ax1.semilogy(ks, errors, 'o-', label=f'ε = {eps}', markersize=4)

    ax1.set_xlabel('Rounds (k)', fontsize=12)
    ax1.set_ylabel('Error ε^k (log scale)', fontsize=12)
    ax1.set_title('Probability Space:\nExponential Decay', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Linear tropical cost growth
    ax2 = axes[1]
    for eps in base_errors:
        tau = -math.log(eps)
        ks = np.arange(1, max_k + 1)
        trop_costs = ks * tau
        ax2.plot(ks, trop_costs, 'o-', label=f'τ(ε) = {tau:.2f}', markersize=4)

    ax2.set_xlabel('Rounds (k)', fontsize=12)
    ax2.set_ylabel('Tropical Cost k·τ(ε)', fontsize=12)
    ax2.set_title('Tropical Space:\nLinear Growth', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Panel 3: The transform
    ax3 = axes[2]
    eps_range = np.linspace(0.01, 0.99, 200)
    tau_range = -np.log(eps_range)
    ax3.plot(eps_range, tau_range, 'k-', linewidth=2)
    ax3.fill_between(eps_range, tau_range, alpha=0.1, color='blue')

    for eps in base_errors:
        tau = -math.log(eps)
        ax3.plot(eps, tau, 'ro', markersize=8)
        ax3.annotate(f'({eps}, {tau:.2f})', (eps, tau),
                     textcoords="offset points", xytext=(10, 5), fontsize=8)

    ax3.set_xlabel('Error ε', fontsize=12)
    ax3.set_ylabel('Tropical Cost τ(ε) = -log(ε)', fontsize=12)
    ax3.set_title('The Transform:\nτ(ε) = -log(ε)', fontsize=13)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('duality_transform.png', dpi=150, bbox_inches='tight')
    print("Saved: duality_transform.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Pareto Frontier of Cost-Error Tradeoffs

Generates a plot showing how different proof amplification chains
create different cost-error tradeoff curves, and the combined
Pareto frontier.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def amplified_error(base_error: float, k: int) -> float:
    return base_error ** k

def amplified_cost(unit_cost: float, k: int) -> float:
    return k * unit_cost

def tropical_cost_of_error(eps: float) -> float:
    return -math.log(eps) if eps > 0 else float('inf')


def main():
    chains = [
        ("Fast/Weak (ε=0.4, c=0.5)", 0.4, 0.5, 'tab:blue'),
        ("Balanced (ε=0.3, c=1.0)", 0.3, 1.0, 'tab:orange'),
        ("Slow/Strong (ε=0.1, c=2.0)", 0.1, 2.0, 'tab:green'),
    ]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left plot: Error vs Cost (log scale for error)
    ax1 = axes[0]
    max_k = 25

    for name, base_err, unit_c, color in chains:
        costs = [amplified_cost(unit_c, k) for k in range(1, max_k + 1)]
        errors = [amplified_error(base_err, k) for k in range(1, max_k + 1)]
        ax1.semilogy(costs, errors, 'o-', color=color, label=name, markersize=4)

    # Compute and plot Pareto frontier
    all_points = []
    for _, base_err, unit_c, _ in chains:
        for k in range(1, max_k + 1):
            all_points.append((amplified_cost(unit_c, k), amplified_error(base_err, k)))

    all_points.sort(key=lambda p: p[0])
    frontier = []
    min_err = float('inf')
    for c, e in all_points:
        if e < min_err:
            frontier.append((c, e))
            min_err = e

    fc, fe = zip(*frontier)
    ax1.semilogy(fc, fe, 'k--', linewidth=2, label='Pareto Frontier', alpha=0.7)

    ax1.set_xlabel('Total Cost', fontsize=12)
    ax1.set_ylabel('Soundness Error (log scale)', fontsize=12)
    ax1.set_title('Cost-Error Tradeoff Curves', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right plot: Tropical cost vs Economic cost
    ax2 = axes[1]

    for name, base_err, unit_c, color in chains:
        costs = [amplified_cost(unit_c, k) for k in range(1, max_k + 1)]
        trop_costs = [k * tropical_cost_of_error(base_err) for k in range(1, max_k + 1)]
        ax2.plot(costs, trop_costs, 'o-', color=color, label=name, markersize=4)

    ax2.set_xlabel('Economic Cost (k · c)', fontsize=12)
    ax2.set_ylabel('Tropical Cost (k · τ(ε))', fontsize=12)
    ax2.set_title('Tropical vs Economic Cost (Both Linear!)', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('pareto_frontier.png', dpi=150, bbox_inches='tight')
    print("Saved: pareto_frontier.png")


if __name__ == "__main__":
    main()
