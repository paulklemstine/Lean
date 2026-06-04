#!/usr/bin/env python3
"""
Tropical Linear Programming Demo
=================================
Demonstrates the closed-form solution of tropical LP via residuation.

In the max-plus algebra:
  - "Addition" = max
  - "Multiplication" = +
  - Tropical LP: maximize max_j(c_j + x_j) subject to max_j(a_{ij} + x_j) ≤ b_i

The residuated solution x*_j = min_i(b_i - a_{ij}) gives the optimal in O(mn) time.
"""

import numpy as np


def residuate(A: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Compute the residuated solution x*_j = min_i(b_i - a_{ij})."""
    m, n = A.shape
    return np.array([np.min(b - A[:, j]) for j in range(n)])


def maxplus_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Compute max-plus matrix-vector product: (A ⊗ x)_i = max_j(a_{ij} + x_j)."""
    m, n = A.shape
    return np.array([np.max(A[i, :] + x) for i in range(m)])


def tropical_objective(c: np.ndarray, x: np.ndarray) -> float:
    """Compute tropical objective: max_j(c_j + x_j)."""
    return np.max(c + x)


def tropical_dual_bound(A: np.ndarray, b: np.ndarray, c: np.ndarray) -> float:
    """Compute the minimax dual bound: min_i(b_i + max_j(c_j - a_{ij}))."""
    m, n = A.shape
    return np.min([b[i] + np.max(c - A[i, :]) for i in range(m)])


def solve_tropical_lp(A: np.ndarray, b: np.ndarray, c: np.ndarray) -> dict:
    """
    Solve a tropical LP in closed form.

    Primal: maximize max_j(c_j + x_j) subject to max_j(a_{ij} + x_j) ≤ b_i
    Solution: x*_j = min_i(b_i - a_{ij})
    """
    x_star = residuate(A, b)
    obj = tropical_objective(c, x_star)
    Ax = maxplus_matvec(A, x_star)
    dual_bound = tropical_dual_bound(A, b, c)

    # Find witness pair
    j_star = np.argmax(c + x_star)
    i_star = np.argmin(b - A[:, j_star])

    return {
        "solution": x_star,
        "objective": obj,
        "constraint_values": Ax,
        "rhs": b,
        "slack": b - Ax,
        "dual_bound": dual_bound,
        "duality_gap": dual_bound - obj,
        "witness_j": j_star,
        "witness_i": i_star,
        "witness_value": c[j_star] + b[i_star] - A[i_star, j_star],
    }


def main():
    print("=" * 70)
    print("TROPICAL LINEAR PROGRAMMING: CLOSED-FORM SOLUTION VIA RESIDUATION")
    print("=" * 70)

    # Example 1: Small 3×3 problem
    print("\n--- Example 1: 3 constraints, 3 variables ---")
    A = np.array([[1.0, 2.0, 3.0],
                  [4.0, 1.0, 2.0],
                  [2.0, 3.0, 1.0]])
    b = np.array([10.0, 8.0, 9.0])
    c = np.array([1.0, 2.0, 3.0])

    result = solve_tropical_lp(A, b, c)
    print(f"  A = \n{A}")
    print(f"  b = {b}")
    print(f"  c = {c}")
    print(f"  Residuated solution x* = {result['solution']}")
    print(f"  Optimal value = {result['objective']:.4f}")
    print(f"  Constraint values A⊗x* = {result['constraint_values']}")
    print(f"  Slack b - A⊗x* = {result['slack']}")
    print(f"  Dual bound = {result['dual_bound']:.4f}")
    print(f"  Duality gap = {result['duality_gap']:.4f}")
    print(f"  Witness pair (j*={result['witness_j']}, i*={result['witness_i']})")

    # Example 2: Shortest path interpretation
    print("\n--- Example 2: Shortest path (4 nodes) ---")
    # A tropical LP where A encodes edge weights and b encodes distance bounds
    A = np.array([[0, 3, 7, 5],
                  [3, 0, 2, 4],
                  [7, 2, 0, 1],
                  [5, 4, 1, 0]], dtype=float)
    b = np.array([10, 8, 6, 9], dtype=float)
    c = np.array([1, 1, 1, 1], dtype=float)

    result = solve_tropical_lp(A, b, c)
    print(f"  Residuated solution x* = {result['solution']}")
    print(f"  Optimal value = {result['objective']:.4f}")
    print(f"  Slack = {result['slack']}")

    # Example 3: Log-transform bridge
    print("\n--- Example 3: Classical-Tropical Bridge (Log Transform) ---")
    # Classical problem: maximize product, subject to product constraints
    # After log transform: becomes tropical LP
    a_classical = np.array([[2, 3], [1, 4]], dtype=float)
    b_classical = np.array([100, 50], dtype=float)
    c_classical = np.array([5, 7], dtype=float)

    # Transform to tropical
    A_trop = np.log(a_classical)
    b_trop = np.log(b_classical)
    c_trop = np.log(c_classical)

    result = solve_tropical_lp(A_trop, b_trop, c_trop)
    print(f"  Classical A = {a_classical}")
    print(f"  Classical b = {b_classical}")
    print(f"  Tropical A = log(A) = {np.round(A_trop, 4)}")
    print(f"  Tropical b = log(b) = {np.round(b_trop, 4)}")
    print(f"  Tropical solution x* = {np.round(result['solution'], 4)}")
    print(f"  Classical solution exp(x*) = {np.round(np.exp(result['solution']), 4)}")
    print(f"  Tropical optimal = {result['objective']:.4f}")
    print(f"  Classical optimal = exp(tropical) = {np.exp(result['objective']):.4f}")

    # Example 4: Sensitivity analysis - translation invariance
    print("\n--- Example 4: Translation Invariance ---")
    A = np.array([[1, 2], [3, 1]], dtype=float)
    b = np.array([5, 7], dtype=float)
    c = np.array([2, 1], dtype=float)
    s = 3.0

    result_orig = solve_tropical_lp(A, b, c)
    result_shifted = solve_tropical_lp(A, b + s, c)
    print(f"  Original optimal = {result_orig['objective']:.4f}")
    print(f"  Shifted (b+{s}) optimal = {result_shifted['objective']:.4f}")
    print(f"  Difference = {result_shifted['objective'] - result_orig['objective']:.4f}")
    print(f"  Expected shift = {s:.4f}")
    print(f"  Translation invariance verified: "
          f"{np.isclose(result_shifted['objective'] - result_orig['objective'], s)}")

    # Example 5: Random large instance
    print("\n--- Example 5: Random 100×50 instance ---")
    np.random.seed(42)
    m, n = 100, 50
    A = np.random.randn(m, n) * 3
    b = np.random.randn(m) * 2 + 10
    c = np.random.randn(n)

    result = solve_tropical_lp(A, b, c)
    print(f"  Problem size: {m} constraints × {n} variables")
    print(f"  Optimal value = {result['objective']:.4f}")
    print(f"  Dual bound = {result['dual_bound']:.4f}")
    print(f"  Duality gap = {result['duality_gap']:.4f}")
    print(f"  Min slack = {np.min(result['slack']):.6f}")
    print(f"  Max slack = {np.max(result['slack']):.4f}")
    print(f"  All constraints satisfied: {np.all(result['slack'] >= -1e-10)}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical LP Visualization
==========================
Visualizes the feasible region and optimal solution of a 2-variable tropical LP.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap


def residuate(A, b):
    m, n = A.shape
    return np.array([np.min(b - A[:, j]) for j in range(n)])


def maxplus_matvec(A, x):
    m, n = A.shape
    return np.array([np.max(A[i, :] + x) for i in range(m)])


def tropical_objective(c, x):
    return np.max(c + x)


def plot_tropical_lp_2d():
    """Plot feasible region and solution for a 2-variable tropical LP."""
    A = np.array([[1.0, 3.0],
                  [4.0, 1.0],
                  [2.0, 2.0]])
    b = np.array([8.0, 9.0, 7.0])
    c = np.array([1.0, 2.0])

    x_star = residuate(A, b)
    opt = tropical_objective(c, x_star)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Plot 1: Feasible region
    ax = axes[0]
    x1_range = np.linspace(x_star[0] - 4, x_star[0] + 2, 300)
    x2_range = np.linspace(x_star[1] - 4, x_star[1] + 2, 300)
    X1, X2 = np.meshgrid(x1_range, x2_range)

    feasible = np.ones_like(X1, dtype=bool)
    for i in range(A.shape[0]):
        for j in range(A.shape[1]):
            if j == 0:
                constraint = A[i, 0] + X1
            else:
                constraint = A[i, 1] + X2
            matvec_i = np.maximum(A[i, 0] + X1, A[i, 1] + X2)
        feasible &= (matvec_i <= b[i])

    ax.contourf(X1, X2, feasible.astype(float), levels=[0.5, 1.5],
                colors=['#2196F3'], alpha=0.3)
    ax.contour(X1, X2, feasible.astype(float), levels=[0.5],
               colors=['#1565C0'], linewidths=2)

    # Plot constraint boundaries
    colors = ['#E53935', '#43A047', '#FB8C00']
    for i in range(A.shape[0]):
        # Boundary: max(a_{i0}+x1, a_{i1}+x2) = b_i
        # This is max of two affine functions = constant
        # Region 1: a_{i0}+x1 ≥ a_{i1}+x2, so boundary is a_{i0}+x1 = b_i → x1 = b_i - a_{i0}
        # Region 2: a_{i1}+x2 ≥ a_{i0}+x1, so boundary is a_{i1}+x2 = b_i → x2 = b_i - a_{i1}
        x1_bound = b[i] - A[i, 0]
        x2_bound = b[i] - A[i, 1]
        # The corner is at x1 = x2 + a_{i1} - a_{i0}
        corner_x2 = x1_bound + A[i, 0] - A[i, 1]

        ax.axvline(x=x1_bound, color=colors[i], linestyle='--', alpha=0.5,
                  label=f'Constraint {i+1}')
        ax.axhline(y=x2_bound, color=colors[i], linestyle='--', alpha=0.5)

    ax.plot(x_star[0], x_star[1], 'r*', markersize=20, zorder=5,
            label=f'x* = ({x_star[0]:.1f}, {x_star[1]:.1f})')
    ax.set_xlabel('x₁', fontsize=14)
    ax.set_ylabel('x₂', fontsize=14)
    ax.set_title('Tropical LP Feasible Region', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Objective contours
    ax = axes[1]
    Obj = np.maximum(c[0] + X1, c[1] + X2)
    contour = ax.contourf(X1, X2, Obj, levels=20, cmap='viridis', alpha=0.7)
    ax.contour(X1, X2, feasible.astype(float), levels=[0.5],
               colors=['white'], linewidths=2)
    ax.plot(x_star[0], x_star[1], 'r*', markersize=20, zorder=5)
    plt.colorbar(contour, ax=ax, label='Objective value')
    ax.set_xlabel('x₁', fontsize=14)
    ax.set_ylabel('x₂', fontsize=14)
    ax.set_title(f'Objective Contours (opt = {opt:.1f})', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Plot 3: Residuation structure
    ax = axes[2]
    j_vals = [0, 1]
    bar_width = 0.35
    x_pos = np.arange(A.shape[0])

    for j_idx, j in enumerate(j_vals):
        vals = b - A[:, j]
        bars = ax.bar(x_pos + j_idx * bar_width, vals, bar_width,
                      label=f'b_i - a_{{i,{j+1}}}', alpha=0.7)
        # Mark the minimum
        min_idx = np.argmin(vals)
        ax.bar(x_pos[min_idx] + j_idx * bar_width, vals[min_idx], bar_width,
               color='red', alpha=0.9)

    ax.axhline(y=x_star[0], color='blue', linestyle=':', alpha=0.7,
               label=f'x*₁ = {x_star[0]:.1f}')
    ax.axhline(y=x_star[1], color='orange', linestyle=':', alpha=0.7,
               label=f'x*₂ = {x_star[1]:.1f}')
    ax.set_xlabel('Constraint index i', fontsize=14)
    ax.set_ylabel('b_i - a_{ij}', fontsize=14)
    ax.set_title('Residuation: x*_j = min_i(b_i - a_{ij})', fontsize=14)
    ax.set_xticks(x_pos + bar_width / 2)
    ax.set_xticklabels([f'i={i+1}' for i in range(A.shape[0])])
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('tropical_lp_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_lp_visualization.png")


def plot_sensitivity_analysis():
    """Plot how the optimal value changes as b is perturbed."""
    A = np.array([[1.0, 2.0], [3.0, 1.0], [2.0, 3.0]])
    b_base = np.array([8.0, 7.0, 9.0])
    c = np.array([1.0, 2.0])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Sensitivity to b[0]
    deltas = np.linspace(-5, 5, 100)
    for idx, i0 in enumerate([0, 1]):
        ax = axes[idx]
        opts = []
        for d in deltas:
            b_new = b_base.copy()
            b_new[i0] += d
            x_star = residuate(A, b_new)
            opts.append(tropical_objective(c, x_star))
        ax.plot(deltas, opts, 'b-', linewidth=2, label='Optimal value')
        ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
        opt_base = opts[len(deltas)//2]
        ax.axhline(y=opt_base, color='gray', linestyle='--', alpha=0.5)
        ax.set_xlabel(f'Perturbation δ to b_{i0+1}', fontsize=14)
        ax.set_ylabel('Optimal value', fontsize=14)
        ax.set_title(f'Sensitivity to b_{i0+1}', fontsize=14)
        ax.legend(fontsize=12)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical LP Sensitivity Analysis', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_lp_sensitivity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_lp_sensitivity.png")


def plot_duality_gap():
    """Plot the duality gap for random instances of varying size."""
    np.random.seed(42)
    sizes = range(2, 51)
    gaps = []
    gap_ratios = []

    for n in sizes:
        m = 2 * n
        A = np.random.randn(m, n) * 2
        b = np.random.randn(m) + 5
        c = np.random.randn(n)

        x_star = residuate(A, b)
        primal = tropical_objective(c, x_star)
        dual = np.min([b[i] + np.max(c - A[i, :]) for i in range(m)])
        gaps.append(dual - primal)
        gap_ratios.append((dual - primal) / abs(primal) if abs(primal) > 1e-10 else 0)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ax1.plot(list(sizes), gaps, 'bo-', markersize=3, linewidth=1)
    ax1.set_xlabel('Problem size n', fontsize=14)
    ax1.set_ylabel('Duality gap', fontsize=14)
    ax1.set_title('Absolute Duality Gap vs Problem Size', fontsize=14)
    ax1.grid(True, alpha=0.3)

    ax2.plot(list(sizes), gap_ratios, 'ro-', markersize=3, linewidth=1)
    ax2.set_xlabel('Problem size n', fontsize=14)
    ax2.set_ylabel('Relative duality gap', fontsize=14)
    ax2.set_title('Relative Duality Gap vs Problem Size', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Tropical Minimax Duality Gap', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_lp_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_lp_duality.png")


if __name__ == "__main__":
    plot_tropical_lp_2d()
    plot_sensitivity_analysis()
    plot_duality_gap()
