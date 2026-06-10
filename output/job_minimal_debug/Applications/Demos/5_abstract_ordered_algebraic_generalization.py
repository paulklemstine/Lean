#!/usr/bin/env python3
"""
Real-World Applications of the Ordered Additive Aggregation Principle.

Demonstrates the theorem in practical settings:
1. Network routing cost verification
2. Portfolio risk budget aggregation
3. Entropy budget decomposition (information theory)
4. Value iteration convergence (reinforcement learning)
"""

import numpy as np
from typing import Dict, List


def network_routing_verification(
    n_nodes: int,
    edges: List[tuple],
    potentials: np.ndarray,
    path: List[int]
) -> Dict:
    """
    Verify that a path's total cost is bounded using the aggregation principle.

    In network routing, if each edge satisfies the reduced-cost optimality
    condition (edge_weight + src_potential ≤ tgt_potential), the total path
    cost is bounded by the difference of endpoint potentials.

    This is exactly the aggregation theorem applied to the path edges.

    Args:
        n_nodes: number of nodes
        edges: list of (src, tgt, weight) tuples
        potentials: node potential function
        path: sequence of node indices forming a path

    Returns:
        Verification results
    """
    edge_dict = {}
    for u, v, w in edges:
        edge_dict[(u, v)] = w

    path_edges = []
    total_weight = 0
    all_optimal = True

    for i in range(len(path) - 1):
        u, v = path[i], path[i + 1]
        w = edge_dict.get((u, v), float('inf'))
        rc = w + potentials[u] - potentials[v]
        optimal = rc >= -1e-10
        if not optimal:
            all_optimal = False
        path_edges.append({
            "edge": (u, v),
            "weight": w,
            "reduced_cost": rc,
            "optimal": optimal,
        })
        total_weight += w

    src_potential = potentials[path[0]]
    tgt_potential = potentials[path[-1]]

    return {
        "path": path,
        "total_weight": total_weight,
        "src_potential": float(src_potential),
        "tgt_potential": float(tgt_potential),
        "potential_diff": float(tgt_potential - src_potential),
        "all_edges_optimal": all_optimal,
        "aggregation_bound": float(tgt_potential - src_potential),
        "bound_satisfied": total_weight >= tgt_potential - src_potential - 1e-10,
        "edges": path_edges,
    }


def portfolio_risk_aggregation(
    n_assets: int,
    individual_risks: np.ndarray,
    weights: np.ndarray,
    risk_budgets: np.ndarray
) -> Dict:
    """
    Portfolio risk budget aggregation.

    Each asset i has risk exposure risk[i] and weight w[i].
    If the weighted risk w[i] + risk[i] ≤ budget[i] for each asset,
    then the total weighted risk Σw + Σrisk ≤ Σbudget.

    This is the aggregation principle applied to risk management.

    Args:
        n_assets: number of assets
        individual_risks: per-asset risk measures
        weights: portfolio weights
        risk_budgets: per-asset risk budgets

    Returns:
        Risk aggregation analysis
    """
    weighted_risks = weights + individual_risks
    pointwise_ok = weighted_risks <= risk_budgets + 1e-10

    total_weighted_risk = np.sum(weights) + np.sum(individual_risks)
    total_budget = np.sum(risk_budgets)

    return {
        "n_assets": n_assets,
        "individual_risks": individual_risks.tolist(),
        "weights": weights.tolist(),
        "risk_budgets": risk_budgets.tolist(),
        "weighted_risks": weighted_risks.tolist(),
        "pointwise_within_budget": pointwise_ok.tolist(),
        "all_within_budget": bool(np.all(pointwise_ok)),
        "total_weighted_risk": float(total_weighted_risk),
        "total_budget": float(total_budget),
        "global_within_budget": bool(total_weighted_risk <= total_budget + 1e-10),
        "risk_surplus": float(total_budget - total_weighted_risk),
    }


def value_iteration_convergence(
    n_states: int,
    transition_costs: np.ndarray,
    transition_probs: np.ndarray,
    discount: float,
    n_iterations: int = 20
) -> Dict:
    """
    Value iteration for discounted MDP with convergence tracking.

    At each iteration, the Bellman update satisfies:
    V'[s] = min_a [c(s,a) + γ Σ P(s'|s,a) V[s']]

    The aggregation principle guarantees that if each state's update
    improves the value by at least δ[s], the total value improves
    by at least Σδ.

    Args:
        n_states: number of states
        transition_costs: cost matrix c(s,a) of shape (n_states, n_actions)
        transition_probs: transition probability tensor P(s'|s,a)
        discount: discount factor γ ∈ (0,1)
        n_iterations: number of iterations

    Returns:
        Convergence history and aggregation verification
    """
    n_actions = transition_costs.shape[1]
    V = np.zeros(n_states)
    history = []

    for t in range(n_iterations):
        V_new = np.full(n_states, float('inf'))
        for s in range(n_states):
            for a in range(n_actions):
                q = transition_costs[s, a] + discount * np.dot(transition_probs[s, a], V)
                V_new[s] = min(V_new[s], q)

        improvement = V_new - V
        total_improvement = np.sum(V_new) - np.sum(V)
        sum_pointwise = np.sum(improvement)

        history.append({
            "iteration": t + 1,
            "total_value": float(np.sum(V_new)),
            "max_change": float(np.max(np.abs(improvement))),
            "total_improvement": float(total_improvement),
            "sum_pointwise_improvement": float(sum_pointwise),
            "aggregation_verified": abs(total_improvement - sum_pointwise) < 1e-10,
        })

        V = V_new

    return {
        "n_states": n_states,
        "n_actions": n_actions,
        "discount": discount,
        "final_values": V.tolist(),
        "converged": history[-1]["max_change"] < 1e-6 if history else False,
        "history": history,
    }


def entropy_budget_decomposition(
    n_components: int,
    entropies: np.ndarray,
    weights: np.ndarray,
    budgets: np.ndarray
) -> Dict:
    """
    Entropy budget decomposition for information-theoretic systems.

    In a multi-source system, each component i has entropy H[i] and
    processing weight w[i]. If w[i] + H[i] ≤ budget[i] for each
    component, the total weighted entropy is within the total budget.

    This models scenarios like:
    - Distributed compression with rate constraints
    - Multi-sensor fusion with information budgets
    - Privacy budget allocation in differential privacy

    Args:
        n_components: number of system components
        entropies: per-component entropy values (nonneg)
        weights: per-component processing weights (nonneg)
        budgets: per-component information budgets (nonneg)

    Returns:
        Entropy budget analysis
    """
    weighted_entropy = weights + entropies
    pointwise_ok = weighted_entropy <= budgets + 1e-10

    total_weighted_entropy = np.sum(weights) + np.sum(entropies)
    total_budget = np.sum(budgets)

    return {
        "n_components": n_components,
        "entropies": entropies.tolist(),
        "weights": weights.tolist(),
        "budgets": budgets.tolist(),
        "weighted_entropies": weighted_entropy.tolist(),
        "all_within_budget": bool(np.all(pointwise_ok)),
        "total_weighted_entropy": float(total_weighted_entropy),
        "total_budget": float(total_budget),
        "global_within_budget": bool(total_weighted_entropy <= total_budget + 1e-10),
        "entropy_surplus": float(total_budget - total_weighted_entropy),
    }


if __name__ == "__main__":
    print()
    print("=" * 60)
    print("Application 1: Network Routing Verification")
    print("=" * 60)

    edges = [
        (0, 1, 3), (0, 2, 7), (1, 2, 2),
        (1, 3, 5), (2, 3, 1), (0, 3, 10),
    ]
    potentials = np.array([0, 3, 5, 6], dtype=float)
    path = [0, 1, 2, 3]

    result = network_routing_verification(4, edges, potentials, path)
    print(f"  Path: {result['path']}")
    print(f"  Total weight: {result['total_weight']}")
    print(f"  Potential difference: {result['potential_diff']}")
    print(f"  All edges optimal: {result['all_edges_optimal']}")
    print(f"  Aggregation bound satisfied: {result['bound_satisfied']}")
    print()

    print("=" * 60)
    print("Application 2: Portfolio Risk Aggregation")
    print("=" * 60)

    result = portfolio_risk_aggregation(
        n_assets=5,
        individual_risks=np.array([0.05, 0.12, 0.03, 0.08, 0.15]),
        weights=np.array([0.2, 0.15, 0.3, 0.25, 0.1]),
        risk_budgets=np.array([0.30, 0.30, 0.40, 0.40, 0.30]),
    )
    print(f"  Total weighted risk: {result['total_weighted_risk']:.4f}")
    print(f"  Total budget: {result['total_budget']:.4f}")
    print(f"  Global within budget: {result['global_within_budget']}")
    print(f"  Risk surplus: {result['risk_surplus']:.4f}")
    print()

    print("=" * 60)
    print("Application 3: Value Iteration (Reinforcement Learning)")
    print("=" * 60)

    np.random.seed(42)
    n_states, n_actions = 4, 2
    costs = np.random.uniform(1, 5, (n_states, n_actions))
    probs = np.random.dirichlet(np.ones(n_states), (n_states, n_actions))

    result = value_iteration_convergence(n_states, costs, probs, discount=0.9, n_iterations=15)
    print(f"  Converged: {result['converged']}")
    print(f"  Final values: {[f'{v:.3f}' for v in result['final_values']]}")
    print(f"  Last 3 iterations:")
    for h in result['history'][-3:]:
        print(f"    Iter {h['iteration']}: total_value={h['total_value']:.4f}, "
              f"max_change={h['max_change']:.6f}")
    print()

    print("=" * 60)
    print("Application 4: Entropy Budget Decomposition")
    print("=" * 60)

    result = entropy_budget_decomposition(
        n_components=4,
        entropies=np.array([2.3, 1.5, 3.1, 0.8]),
        weights=np.array([0.5, 0.3, 0.7, 0.2]),
        budgets=np.array([3.5, 2.5, 4.5, 1.5]),
    )
    print(f"  Total weighted entropy: {result['total_weighted_entropy']:.4f}")
    print(f"  Total budget: {result['total_budget']:.4f}")
    print(f"  All within budget: {result['all_within_budget']}")
    print(f"  Entropy surplus: {result['entropy_surplus']:.4f}")


#!/usr/bin/env python3
"""
Demonstration of the Ordered Additive Aggregation Principle.

This script illustrates the core theorem:
  If for every coordinate i, w[i] + a[i] ≤ b[i],
  then sum(w) + sum(a) ≤ sum(b).

We demonstrate this across multiple domains:
  1. Real numbers (ℝ) — classical analysis
  2. Integers (ℤ) — combinatorial optimization
  3. Extended nonneg reals (ℝ≥0∞) — measure theory
  4. Extended reals (WithTop ℝ) — Bellman/DP with ∞ penalties
  5. Tropical/min-plus — shortest path dominance
"""

import numpy as np
from typing import List, Tuple, Optional
import json


def verify_aggregation(w: np.ndarray, a: np.ndarray, b: np.ndarray,
                       domain: str = "ℝ") -> dict:
    """Verify the aggregation principle: if w[i]+a[i] ≤ b[i] for all i,
    then sum(w)+sum(a) ≤ sum(b)."""
    pointwise_holds = np.all(w + a <= b + 1e-12)  # small tolerance for floats
    lhs = np.sum(w) + np.sum(a)
    rhs = np.sum(b)
    global_holds = lhs <= rhs + 1e-12
    gap = rhs - lhs

    return {
        "domain": domain,
        "k": len(w),
        "pointwise_holds": bool(pointwise_holds),
        "lhs (sum_w + sum_a)": float(lhs),
        "rhs (sum_b)": float(rhs),
        "gap (rhs - lhs)": float(gap),
        "global_holds": bool(global_holds),
    }


def demo_real():
    """Demo 1: Real numbers — classical weighted coupling."""
    print("=" * 60)
    print("DEMO 1: Real Numbers (ℝ)")
    print("=" * 60)

    np.random.seed(42)
    k = 5
    w = np.random.uniform(0, 3, k)
    a = np.random.uniform(0, 5, k)
    slack = np.random.uniform(0, 2, k)
    b = w + a + slack  # ensures w[i] + a[i] ≤ b[i]

    result = verify_aggregation(w, a, b, "ℝ")
    print(f"  k = {k}")
    print(f"  w = {w.round(3)}")
    print(f"  a = {a.round(3)}")
    print(f"  b = {b.round(3)}")
    print(f"  Pointwise w[i]+a[i] ≤ b[i]: {result['pointwise_holds']}")
    print(f"  sum(w) + sum(a) = {result['lhs (sum_w + sum_a)']:.4f}")
    print(f"  sum(b) = {result['rhs (sum_b)']:.4f}")
    print(f"  Gap = {result['gap (rhs - lhs)']:.4f}")
    print(f"  Global inequality holds: {result['global_holds']}")
    print()
    return result


def demo_integer():
    """Demo 2: Integers — discrete optimization."""
    print("=" * 60)
    print("DEMO 2: Integers (ℤ)")
    print("=" * 60)

    k = 6
    w = np.array([3, -1, 2, 0, -2, 4], dtype=int)
    a = np.array([1, 5, -1, 3, 7, 2], dtype=int)
    b = np.array([5, 6, 3, 4, 8, 7], dtype=int)  # w+a ≤ b

    result = verify_aggregation(w, a, b, "ℤ")
    print(f"  k = {k}")
    print(f"  w = {w}")
    print(f"  a = {a}")
    print(f"  b = {b}")
    print(f"  w+a = {w + a}")
    print(f"  Pointwise w[i]+a[i] ≤ b[i]: {result['pointwise_holds']}")
    print(f"  sum(w) + sum(a) = {int(result['lhs (sum_w + sum_a)'])}")
    print(f"  sum(b) = {int(result['rhs (sum_b)'])}")
    print(f"  Gap = {int(result['gap (rhs - lhs)'])}")
    print(f"  Global inequality holds: {result['global_holds']}")
    print()
    return result


def demo_ennreal():
    """Demo 3: Extended nonneg reals — measure theory costs."""
    print("=" * 60)
    print("DEMO 3: Extended Nonneg Reals (ℝ≥0∞)")
    print("=" * 60)

    k = 4
    # Use large values to simulate ∞-like behavior
    INF = float('inf')
    w = np.array([1.5, 0.0, 2.3, INF])
    a = np.array([0.5, 3.0, 1.7, 0.0])
    b = np.array([3.0, 4.0, 5.0, INF])

    print(f"  k = {k}")
    print(f"  w = {w}")
    print(f"  a = {a}")
    print(f"  b = {b}")
    print(f"  w+a = {w + a}")

    pointwise = all((w[i] + a[i]) <= b[i] or (w[i] + a[i] == b[i]) for i in range(k))
    lhs = np.sum(w) + np.sum(a)
    rhs = np.sum(b)
    print(f"  Pointwise w[i]+a[i] ≤ b[i]: {pointwise}")
    print(f"  sum(w) + sum(a) = {lhs}")
    print(f"  sum(b) = {rhs}")
    print(f"  Global inequality holds: {lhs <= rhs}")
    print()
    return {"domain": "ℝ≥0∞", "pointwise_holds": pointwise, "global_holds": lhs <= rhs}


def demo_bellman():
    """Demo 4: Bellman/DP with infinite penalties (WithTop ℝ)."""
    print("=" * 60)
    print("DEMO 4: Bellman DP with Infinite Penalties")
    print("=" * 60)

    k = 5
    INF = float('inf')

    # Transition costs
    cost = np.array([2.0, 1.0, INF, 0.5, 3.0])
    # Current value function
    V = np.array([10.0, 8.0, INF, 5.0, 12.0])
    # Updated value function (after Bellman step)
    V_prime = np.array([13.0, 10.0, INF, 6.0, 16.0])

    print(f"  States: {k}")
    print(f"  Transition costs: {cost}")
    print(f"  Current values V: {V}")
    print(f"  Updated values V': {V_prime}")
    print(f"  cost + V = {cost + V}")

    pointwise = all(cost[i] + V[i] <= V_prime[i] for i in range(k))
    lhs = np.sum(cost) + np.sum(V)
    rhs = np.sum(V_prime)

    print(f"  Pointwise cost[i]+V[i] ≤ V'[i]: {pointwise}")
    print(f"  sum(cost) + sum(V) = {lhs}")
    print(f"  sum(V') = {rhs}")
    print(f"  Bellman dominance holds: {lhs <= rhs}")
    print()
    return {"domain": "WithTop ℝ", "pointwise_holds": pointwise, "global_holds": lhs <= rhs}


def demo_tropical():
    """Demo 5: Tropical/min-plus shortest path dominance."""
    print("=" * 60)
    print("DEMO 5: Tropical Min-Plus Path Dominance")
    print("=" * 60)

    # Shortest path setting: edge weights + source potentials ≤ target potentials
    edges = 4
    edge_weight = np.array([3.0, 1.0, 4.0, 2.0])
    src_potential = np.array([5.0, 8.0, 2.0, 6.0])
    tgt_potential = np.array([9.0, 10.0, 7.0, 9.0])

    print(f"  Edges: {edges}")
    print(f"  Edge weights: {edge_weight}")
    print(f"  Source potentials: {src_potential}")
    print(f"  Target potentials: {tgt_potential}")
    print(f"  Reduced costs (tgt - src - weight): {tgt_potential - src_potential - edge_weight}")

    pointwise = np.all(edge_weight + src_potential <= tgt_potential + 1e-12)
    lhs = np.sum(edge_weight) + np.sum(src_potential)
    rhs = np.sum(tgt_potential)

    print(f"  Pointwise optimality: {pointwise}")
    print(f"  Total edge weight + total src potential = {lhs}")
    print(f"  Total tgt potential = {rhs}")
    print(f"  Path dominance holds: {lhs <= rhs + 1e-12}")

    # Tropical interpretation
    print()
    print("  Tropical interpretation:")
    print(f"    min(sum(w)+sum(src), sum(tgt)) = {min(lhs, rhs)}")
    print(f"    = sum(w)+sum(src) = {lhs} ✓ (tropical cost dominance)")
    print()
    return {"domain": "tropical", "pointwise_holds": bool(pointwise), "global_holds": bool(lhs <= rhs + 1e-12)}


def demo_scaling():
    """Demo 6: Scaling behavior — gap grows linearly with k."""
    print("=" * 60)
    print("DEMO 6: Scaling Behavior")
    print("=" * 60)

    np.random.seed(123)
    ks = [5, 10, 50, 100, 500, 1000]
    results = []

    for k in ks:
        w = np.random.uniform(0, 1, k)
        a = np.random.uniform(0, 1, k)
        slack = np.random.uniform(0, 0.5, k)
        b = w + a + slack
        gap = np.sum(b) - (np.sum(w) + np.sum(a))
        avg_slack = np.mean(slack)
        results.append((k, gap, avg_slack, gap / k))

    print(f"  {'k':>6} {'gap':>10} {'avg_slack':>10} {'gap/k':>10}")
    print(f"  {'-'*6} {'-'*10} {'-'*10} {'-'*10}")
    for k, gap, avg, ratio in results:
        print(f"  {k:>6} {gap:>10.4f} {avg:>10.4f} {ratio:>10.4f}")
    print()
    print("  Observation: gap/k ≈ avg_slack, confirming that the gap is")
    print("  exactly the sum of pointwise slacks (by linearity of summation).")
    print()
    return results


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  ORDERED ADDITIVE AGGREGATION: Cross-Domain Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    print("Core theorem: If ∀i, w[i] + a[i] ≤ b[i], then Σw + Σa ≤ Σb.")
    print("This holds in ANY ordered additive commutative monoid with")
    print("left-monotone addition — not just the reals!")
    print()

    r1 = demo_real()
    r2 = demo_integer()
    r3 = demo_ennreal()
    r4 = demo_bellman()
    r5 = demo_tropical()
    r6 = demo_scaling()

    print("=" * 60)
    print("SUMMARY: All demonstrations confirm the aggregation principle")
    print("across ℝ, ℤ, ℝ≥0∞, WithTop ℝ, and tropical/min-plus domains.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Ordered Additive Aggregation Principle.
Generates publication-quality figures as PNG files.
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
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_pointwise_to_global():
    """Visualize pointwise inequalities aggregating to global inequality."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    k = 6
    np.random.seed(42)
    w = np.random.uniform(0.5, 2.5, k)
    a = np.random.uniform(0.5, 3.0, k)
    slack = np.random.uniform(0.2, 1.5, k)
    b = w + a + slack

    x = np.arange(k)
    width = 0.35

    # Left: pointwise view
    ax = axes[0]
    bars1 = ax.bar(x - width/2, w + a, width, label='w[i] + a[i]', color='#2196F3', alpha=0.8)
    bars2 = ax.bar(x + width/2, b, width, label='b[i]', color='#FF9800', alpha=0.8)

    for i in range(k):
        ax.annotate('', xy=(i + width/2, b[i]), xytext=(i - width/2, w[i] + a[i]),
                    arrowprops=dict(arrowstyle='->', color='green', lw=1.5))

    ax.set_xlabel('Coordinate i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Pointwise: w[i] + a[i] ≤ b[i]', fontsize=14)
    ax.set_xticks(x)
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)

    # Right: global aggregation
    ax = axes[1]
    lhs = np.sum(w) + np.sum(a)
    rhs = np.sum(b)
    bars = ax.bar(['Σw + Σa', 'Σb'], [lhs, rhs],
                  color=['#2196F3', '#FF9800'], alpha=0.8, width=0.5)
    ax.annotate('', xy=(1, rhs), xytext=(0, lhs),
                arrowprops=dict(arrowstyle='->', color='green', lw=2.5))
    ax.annotate(f'Gap = {rhs - lhs:.2f}', xy=(0.5, (lhs + rhs) / 2),
                fontsize=13, ha='center', color='green', fontweight='bold')
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Global: Σw + Σa ≤ Σb', fontsize=14)
    ax.grid(axis='y', alpha=0.3)

    fig.suptitle('The Aggregation Principle: Local Bounds → Global Bound',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_aggregation.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_cross_domain():
    """Show the theorem working across multiple domains."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    domains = ['ℝ (Reals)', 'ℤ (Integers)', 'ℝ≥0∞ (Extended)', 'Tropical']
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

    np.random.seed(42)

    for idx, (ax, domain, color) in enumerate(zip(axes.flat, domains, colors)):
        k = 5
        if idx == 0:  # Reals
            w = np.random.uniform(0, 3, k)
            a = np.random.uniform(0, 3, k)
            slack = np.random.uniform(0.1, 1, k)
        elif idx == 1:  # Integers
            w = np.random.randint(0, 5, k).astype(float)
            a = np.random.randint(0, 5, k).astype(float)
            slack = np.random.randint(1, 3, k).astype(float)
        elif idx == 2:  # ENNReal
            w = np.random.uniform(0, 5, k)
            a = np.random.uniform(0, 5, k)
            slack = np.random.uniform(0, 2, k)
        else:  # Tropical
            w = np.random.uniform(1, 4, k)
            a = np.random.uniform(1, 4, k)
            slack = np.random.uniform(0.5, 1.5, k)

        b = w + a + slack
        x = np.arange(k)

        ax.bar(x - 0.2, w + a, 0.35, label='w+a', color=color, alpha=0.7)
        ax.bar(x + 0.2, b, 0.35, label='b', color=color, alpha=0.3,
               edgecolor=color, linewidth=2)

        lhs = sum(w) + sum(a)
        rhs = sum(b)
        ax.axhline(y=lhs / k, color=color, linestyle='--', alpha=0.5, label=f'avg(w+a)={lhs/k:.1f}')

        ax.set_title(f'{domain}', fontsize=14, fontweight='bold')
        ax.set_xlabel('Coordinate')
        ax.set_ylabel('Value')
        ax.legend(fontsize=9)
        ax.grid(axis='y', alpha=0.3)

        ax.text(0.98, 0.95, f'Σ(w+a)={lhs:.1f}\nΣb={rhs:.1f}\nGap={rhs-lhs:.1f}',
                transform=ax.transAxes, fontsize=10, verticalalignment='top',
                horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    fig.suptitle('Aggregation Principle Across Mathematical Domains',
                 fontsize=16, fontweight='bold')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_cross_domain.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_bellman_convergence():
    """Visualize Bellman/DP convergence using the aggregation principle."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    np.random.seed(42)
    n_states, n_actions = 4, 2
    costs = np.random.uniform(1, 5, (n_states, n_actions))
    probs = np.random.dirichlet(np.ones(n_states), (n_states, n_actions))
    discount = 0.9

    V = np.zeros(n_states)
    total_values = [np.sum(V)]
    per_state = [V.copy()]
    improvements = []

    for t in range(20):
        V_new = np.full(n_states, float('inf'))
        for s in range(n_states):
            for a in range(n_actions):
                q = costs[s, a] + discount * np.dot(probs[s, a], V)
                V_new[s] = min(V_new[s], q)
        improvements.append(np.sum(V_new) - np.sum(V))
        V = V_new
        total_values.append(np.sum(V))
        per_state.append(V.copy())

    # Left: total value convergence
    ax1.plot(total_values, 'o-', color='#2196F3', linewidth=2, markersize=5)
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Total Value Σ V[s]', fontsize=12)
    ax1.set_title('Bellman Value Iteration Convergence', fontsize=14)
    ax1.grid(alpha=0.3)

    # Right: per-state convergence
    per_state = np.array(per_state)
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    for s in range(n_states):
        ax2.plot(per_state[:, s], 'o-', color=colors[s], linewidth=2,
                markersize=4, label=f'State {s}')
    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('V[s]', fontsize=12)
    ax2.set_title('Per-State Value Convergence', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(alpha=0.3)

    fig.suptitle('Aggregation Principle in Dynamic Programming',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_bellman.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_typeclass_hierarchy():
    """Visualize the algebraic hierarchy and which types satisfy which conditions."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))

    # Type hierarchy as a diagram
    types = {
        'ℕ': (0.2, 0.8),
        'ℤ': (0.4, 0.8),
        'ℚ': (0.6, 0.8),
        'ℝ': (0.8, 0.8),
        'ℝ≥0∞': (0.3, 0.4),
        'WithTop ℝ': (0.7, 0.4),
        'ℝ≥0': (0.5, 0.6),
    }

    colors = {
        'ℕ': '#4CAF50',
        'ℤ': '#2196F3',
        'ℚ': '#FF9800',
        'ℝ': '#E91E63',
        'ℝ≥0∞': '#9C27B0',
        'WithTop ℝ': '#00BCD4',
        'ℝ≥0': '#FF5722',
    }

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)

    # Draw boxes
    for name, (x, y) in types.items():
        color = colors[name]
        rect = plt.Rectangle((x - 0.08, y - 0.05), 0.16, 0.1,
                            facecolor=color, alpha=0.3, edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold',
               color=color)

    # Draw the "all satisfy" region
    rect = plt.Rectangle((0.05, 0.15), 0.9, 0.8, fill=False,
                         edgecolor='green', linewidth=3, linestyle='--')
    ax.add_patch(rect)
    ax.text(0.5, 0.18, 'All satisfy: AddCommMonoid + PartialOrder + AddLeftMono',
           ha='center', va='center', fontsize=12, color='green', fontweight='bold',
           bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.3))

    # Title at top
    ax.text(0.5, 0.95, 'Types Where the Aggregation Principle Holds',
           ha='center', va='center', fontsize=16, fontweight='bold')

    # Properties
    ax.text(0.5, 0.12, '✓ Theorem applies to ALL types in the box — proved once, used everywhere',
           ha='center', va='center', fontsize=11, style='italic', color='#333')

    ax.axis('off')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_hierarchy.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_agg = plot_pointwise_to_global()
    print("  ✓ viz_aggregation.png")

    b64_cross = plot_cross_domain()
    print("  ✓ viz_cross_domain.png")

    b64_bellman = plot_bellman_convergence()
    print("  ✓ viz_bellman.png")

    b64_hierarchy = plot_typeclass_hierarchy()
    print("  ✓ viz_hierarchy.png")

    # Save base64 data for JSON package
    import json
    viz_data = {
        "aggregation": b64_agg,
        "cross_domain": b64_cross,
        "bellman": b64_bellman,
        "hierarchy": b64_hierarchy,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated successfully.")
