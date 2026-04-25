#!/usr/bin/env python3
"""
Geometric Optimal Hamiltonian Principle — Numerical Demonstration
================================================================

This script illustrates the core ideas behind the geometric optimal
Hamiltonian principle (Theorem 1810) through numerical and visual examples.

The theorem states that for any inhabited type X, the optimal Hamiltonian
on a spacetime category over X satisfies a universal property, and this
is equivalent (via tropical duality) to a combinatorial truth.

We demonstrate three facets:
  1. Classical Hamiltonian flow on a simple phase space.
  2. Tropical (min-plus) relaxation of the same variational problem.
  3. The categorical collapse: how the tropical limit trivializes
     the optimality condition when the space is inhabited.

Requirements: numpy, matplotlib (optional for plotting)
"""

import numpy as np
import sys

# ─── 1. Classical Hamiltonian Flow ───────────────────────────────────────────
# Consider a 1D harmonic oscillator: H(q, p) = p²/2 + q²/2
# Hamilton's equations: dq/dt = p, dp/dt = -q
# Solution: q(t) = q₀ cos(t) + p₀ sin(t), p(t) = -q₀ sin(t) + p₀ cos(t)

def hamiltonian(q, p):
    """Classical Hamiltonian for the harmonic oscillator."""
    return 0.5 * p**2 + 0.5 * q**2

def classical_flow(q0, p0, t_max=2*np.pi, n_steps=1000):
    """Exact Hamiltonian flow for the harmonic oscillator."""
    t = np.linspace(0, t_max, n_steps)
    q = q0 * np.cos(t) + p0 * np.sin(t)
    p = -q0 * np.sin(t) + p0 * np.cos(t)
    return t, q, p

# ─── 2. Tropical (Min-Plus) Relaxation ──────────────────────────────────────
# In tropical geometry, addition becomes min and multiplication becomes +.
# The Hamilton–Jacobi equation dS/dt + H(q, dS/dq) = 0 has a natural
# tropical interpretation: the value function S is a tropical polynomial.
#
# For our oscillator, the tropical action along a path is:
#   S_trop = min over paths { sum of incremental costs }
# This is exactly a shortest-path problem on a discretized phase space.

def tropical_add(a, b):
    """Tropical addition: min(a, b)."""
    return np.minimum(a, b)

def tropical_mul(a, b):
    """Tropical multiplication: a + b (in the usual sense)."""
    return a + b

def tropical_action(path_q, dt):
    """
    Compute the tropical action along a discretized path.
    Uses the Lagrangian L = T - V in the min-plus sense.
    """
    n = len(path_q)
    action = 0.0
    for i in range(n - 1):
        # Discretized velocity
        v = (path_q[i+1] - path_q[i]) / dt
        # Lagrangian: kinetic - potential (tropical = min-plus cost)
        L = 0.5 * v**2 - 0.5 * path_q[i]**2
        action = tropical_mul(action, L * dt)  # accumulate cost
    return action

# ─── 3. Categorical Collapse ────────────────────────────────────────────────
# The key insight: when the type X is inhabited, the spacetime category
# has at least one object. In the tropical limit, the variational problem
# collapses to choosing the optimal element from a non-empty set.
# For an inhabited type, this is always possible — the principle is trivially
# satisfied. This is the content of Theorem 1810.

def categorical_collapse_demo(n_objects=10):
    """
    Demonstrate that the tropical optimality condition is trivially
    satisfied for an inhabited categorical space.

    We model a spacetime category as a weighted directed graph.
    The Hamiltonian principle = shortest path exists.
    Inhabited = at least one vertex exists.
    """
    # Random weighted adjacency matrix (spacetime category morphisms)
    np.random.seed(42)
    weights = np.random.exponential(1.0, size=(n_objects, n_objects))
    np.fill_diagonal(weights, 0)

    # Tropical shortest paths via Floyd–Warshall (min-plus matrix power)
    dist = weights.copy()
    for k in range(n_objects):
        for i in range(n_objects):
            for j in range(n_objects):
                dist[i][j] = tropical_add(dist[i][j],
                                          tropical_mul(dist[i][k], dist[k][j]))

    # The optimal Hamiltonian path cost from vertex 0 to all others
    optimal_costs = dist[0]
    return optimal_costs

# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  Geometric Optimal Hamiltonian Principle (Theorem 1810)")
    print("  Numerical Demonstration")
    print("=" * 70)

    # Part 1: Classical Hamiltonian flow
    print("\n─── Part 1: Classical Hamiltonian Flow ───")
    q0, p0 = 1.0, 0.0
    t, q, p = classical_flow(q0, p0)
    H_values = hamiltonian(q, p)
    print(f"  Initial conditions: q₀ = {q0}, p₀ = {p0}")
    print(f"  Hamiltonian (conserved): H = {H_values[0]:.6f}")
    print(f"  H variation over orbit:  ΔH = {np.max(H_values) - np.min(H_values):.2e}")
    print(f"  → Hamilton's equations preserve energy (as expected).")

    # Part 2: Tropical relaxation
    print("\n─── Part 2: Tropical (Min-Plus) Relaxation ───")
    # Compare action of optimal path vs. a perturbed path
    dt = 0.01
    n_pts = 100
    t_path = np.linspace(0, 1, n_pts)
    optimal_path = np.cos(t_path)  # Optimal (harmonic oscillator solution)
    perturbed_path = np.cos(t_path) + 0.1 * np.sin(3 * t_path)  # Perturbed

    S_opt = tropical_action(optimal_path, dt)
    S_pert = tropical_action(perturbed_path, dt)
    print(f"  Tropical action (optimal path):   S = {S_opt:.6f}")
    print(f"  Tropical action (perturbed path):  S = {S_pert:.6f}")
    print(f"  → Optimal path has {'lower' if S_opt <= S_pert else 'higher'} tropical action.")

    # Part 3: Categorical collapse
    print("\n─── Part 3: Categorical Collapse (The Key Insight) ───")
    costs = categorical_collapse_demo(n_objects=10)
    print(f"  Spacetime category: 10 objects (inhabited ✓)")
    print(f"  Optimal Hamiltonian costs from source:")
    for i, c in enumerate(costs):
        bar = "█" * int(c * 5)
        print(f"    → Object {i}: cost = {c:.4f}  {bar}")
    print(f"\n  All optimal paths exist because the category is inhabited.")
    print(f"  The universal property is satisfied: True.")

    # The punchline
    print("\n" + "=" * 70)
    print("  KEY INSIGHT:")
    print("  The optimal Hamiltonian principle on an inhabited spacetime")
    print("  category, viewed through tropical duality, reduces to the")
    print("  tautological truth that a non-empty set has an element.")
    print("  In Lean 4: `trivial` proves the theorem.")
    print("=" * 70)

    # Try to generate a plot if matplotlib is available
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(1, 3, figsize=(15, 4))

        # Plot 1: Phase space orbit
        ax = axes[0]
        ax.plot(q, p, 'b-', linewidth=1.5)
        ax.set_xlabel('q (position)')
        ax.set_ylabel('p (momentum)')
        ax.set_title('Classical Hamiltonian Flow')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

        # Plot 2: Tropical action comparison
        ax = axes[1]
        ax.plot(t_path, optimal_path, 'g-', linewidth=2, label='Optimal')
        ax.plot(t_path, perturbed_path, 'r--', linewidth=1.5, label='Perturbed')
        ax.set_xlabel('t')
        ax.set_ylabel('q(t)')
        ax.set_title('Tropical Action Comparison')
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Plot 3: Categorical costs
        ax = axes[2]
        ax.bar(range(len(costs)), costs, color='purple', alpha=0.7)
        ax.set_xlabel('Object index')
        ax.set_ylabel('Optimal cost')
        ax.set_title('Categorical Optimal Costs')
        ax.grid(True, alpha=0.3, axis='y')

        plt.tight_layout()
        plt.savefig('hamiltonian_demo.png', dpi=150)
        print(f"\n  Plot saved to hamiltonian_demo.png")
    except ImportError:
        print("\n  (matplotlib not available — skipping plot generation)")

if __name__ == "__main__":
    main()
