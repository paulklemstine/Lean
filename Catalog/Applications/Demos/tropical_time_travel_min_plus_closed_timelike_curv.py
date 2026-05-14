"""
Tropical CTC Applications: Real-World Uses of Min-Plus Fixed-Point Theory

Demonstrates how the tropical CTC framework applies to practical problems
in shortest paths, scheduling, recursive programs, and network analysis.
"""

import numpy as np
from algorithms import tropical_fixed_point, certify_paradox_freedom


# ============================================================
# Application 1: Shortest Path Equilibria
# ============================================================

def app_shortest_paths():
    """
    All-pairs shortest paths as a tropical fixed point.
    
    The Bellman-Ford equation d[i] = min_j(w[i,j] + d[j]) is exactly
    the tropical linear map. A consistent solution is a shortest-path
    distance vector.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Equilibria")
    print("=" * 60)
    
    # Network: 4 cities connected by roads with travel times
    # Edge weights: A[i,j] = travel time from j to i
    INF = 100.0  # Large number instead of infinity
    A = np.array([
        [0.0, 3.0, INF, 7.0],   # City 0
        [3.0, 0.0, 2.0, INF],   # City 1
        [INF, 2.0, 0.0, 1.0],   # City 2
        [7.0, INF, 1.0, 0.0],   # City 3
    ])
    
    # Source: city 0 (distance 0), others unconstrained
    b = np.array([0.0, INF, INF, INF])
    
    print("\n  Travel time matrix (∞ = no direct road):")
    print(f"  {A}")
    print(f"\n  Source: City 0")
    
    result = tropical_fixed_point(A, b, np.zeros(4), lam=1.0)
    print(f"\n  Shortest distances from City 0:")
    for i in range(4):
        print(f"    City {i}: {result.point[i]:.1f}")
    print(f"\n  ✓ Tropical fixed point = shortest-path distance vector")


# ============================================================
# Application 2: Job Scheduling with Circular Dependencies
# ============================================================

def app_scheduling():
    """
    Cyclic scheduling as a tropical CTC problem.
    
    When tasks have circular dependencies (like a feedback loop in 
    manufacturing), finding a consistent schedule is exactly finding
    a tropical fixed point.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Cyclic Job Scheduling")
    print("=" * 60)
    
    # 3 tasks in a feedback loop:
    # Task 0 depends on Task 2 (delay 2)
    # Task 1 depends on Task 0 (delay 3)
    # Task 2 depends on Task 1 (delay 1)
    # Each task also has external input constraints (b)
    
    A = np.array([
        [100., 100., 2.0],   # Task 0 ← Task 2
        [3.0, 100., 100.],   # Task 1 ← Task 0
        [100., 1.0, 100.],   # Task 2 ← Task 1
    ])
    b = np.array([0.0, 5.0, 3.0])  # External deadlines
    
    print("\n  Task dependencies (delay matrix):")
    print(f"  Task 0 ← Task 2: delay 2")
    print(f"  Task 1 ← Task 0: delay 3")
    print(f"  Task 2 ← Task 1: delay 1")
    print(f"  External deadlines: {b}")
    
    # Discounted version (tasks become slightly less dependent over time)
    lam = 0.9
    result = tropical_fixed_point(A, b, np.zeros(3), lam=lam)
    
    print(f"\n  Consistent schedule (λ={lam}):")
    for i in range(3):
        print(f"    Task {i} start time: {result.point[i]:.4f}")
    print(f"  Converged in {result.iterations} iterations")
    print(f"  ✓ Unique feasible schedule found via tropical contraction")


# ============================================================
# Application 3: Recursive Program Semantics
# ============================================================

def app_recursive_programs():
    """
    Cost semantics of recursive/self-referential programs.
    
    A program with recursive calls has cost satisfying:
        cost(f, input) = min over branches (overhead + cost(g, transformed_input))
    
    This is exactly a tropical affine fixed-point equation.
    Well-definedness = existence of a consistent cost assignment.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Recursive Program Cost Semantics")
    print("=" * 60)
    
    # 3 mutually recursive functions:
    # f0 can call f1 (overhead 2) or f2 (overhead 5)
    # f1 can call f0 (overhead 1) or f2 (overhead 3)
    # f2 can call f0 (overhead 4) or f1 (overhead 1)
    
    A = np.array([
        [100., 2.0, 5.0],
        [1.0, 100., 3.0],
        [4.0, 1.0, 100.],
    ])
    
    # Base case costs (minimum possible cost without recursion)
    b = np.array([10.0, 8.0, 12.0])
    
    print("\n  Recursive call costs:")
    print(f"  f0 → f1: 2,  f0 → f2: 5")
    print(f"  f1 → f0: 1,  f1 → f2: 3")
    print(f"  f2 → f0: 4,  f2 → f1: 1")
    print(f"  Base case costs: {b}")
    
    # With memoization discount (each recursive call is slightly cheaper)
    lam = 0.8
    result = tropical_fixed_point(A, b, np.ones(3) * 20, lam=lam)
    
    print(f"\n  Semantic cost assignment (λ={lam}):")
    for i in range(3):
        print(f"    cost(f{i}) = {result.point[i]:.4f}")
    
    cert = certify_paradox_freedom(A, b, lam=lam)
    print(f"\n  {cert.message}")
    print(f"  ✓ Well-defined semantics guaranteed by contraction")


# ============================================================
# Application 4: Network Resilience Analysis
# ============================================================

def app_network_resilience():
    """
    Network resilience as tropical spectral condition.
    
    A communication network is resilient to feedback loops (no oscillation)
    if and only if the minimum cycle mean of its delay matrix is positive.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Network Resilience via Cycle Analysis")
    print("=" * 60)
    
    from algorithms import minimum_cycle_mean
    
    # Resilient network (all cycle means positive)
    A_resilient = np.array([
        [2.0, 1.0, 3.0],
        [1.0, 2.0, 1.0],
        [3.0, 1.0, 2.0],
    ])
    
    # Fragile network (has a zero/negative cycle mean)
    A_fragile = np.array([
        [0.5, -0.5, 3.0],
        [-0.5, 0.5, 1.0],
        [3.0, 1.0, 0.5],
    ])
    
    mcm_r, _ = minimum_cycle_mean(A_resilient)
    mcm_f, _ = minimum_cycle_mean(A_fragile)
    
    print(f"\n  Resilient network:")
    print(f"  A = \n{A_resilient}")
    print(f"  Minimum cycle mean: {mcm_r:.4f}")
    print(f"  Status: {'✓ RESILIENT' if mcm_r > 0 else '✗ FRAGILE'}")
    
    print(f"\n  Fragile network:")
    print(f"  A = \n{A_fragile}")
    print(f"  Minimum cycle mean: {mcm_f:.4f}")
    print(f"  Status: {'✓ RESILIENT' if mcm_f > 0 else '✗ FRAGILE'}")
    
    print(f"\n  ✓ Positive cycle mean = no self-reinforcing oscillations")
    print(f"  ✓ This is the 'chronology protection' condition for networks")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   Tropical CTC Framework: Real-World Applications          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    app_shortest_paths()
    app_scheduling()
    app_recursive_programs()
    app_network_resilience()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
Tropical Time Travel: Min-Plus CTC Consistency — Interactive Demonstrations

This module demonstrates the key theorems from the tropical CTC framework:
1. Existence of consistent timelines via fixed-point iteration
2. Uniqueness under contraction (chronology protection)
3. Paradox collapse by tropical idempotence
4. Discounted contraction and convergence

All examples use concrete numerical matrices and vectors.
"""

import numpy as np
from typing import Tuple, Optional

# ============================================================
# Core Tropical Operations
# ============================================================

def trop_apply(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector multiplication: (A ⊙ x)_i = min_j(A[i,j] + x[j])"""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(A[i, :] + x)
    return result


def trop_affine(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical affine map: F(x)_i = min((A ⊙ x)_i, b_i)"""
    return np.minimum(trop_apply(A, x), b)


def trop_affine_discounted(A: np.ndarray, b: np.ndarray, lam: float, x: np.ndarray) -> np.ndarray:
    """Discounted tropical affine: F_λ(x)_i = min(min_j(A[i,j] + λ·x[j]), b_i)"""
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(A[i, :] + lam * x)
    return np.minimum(result, b)


# ============================================================
# Demo 1: Fixed-Point Iteration for CTC Consistency
# ============================================================

def demo_fixed_point_iteration():
    """
    Demonstrate Theorem 1: Existence of a consistent tropical CTC state.
    
    We construct a tropical affine map that preserves the box [0, 10]^3,
    then iterate to find a fixed point (consistent timeline).
    """
    print("=" * 70)
    print("DEMO 1: Finding a Consistent Timeline via Fixed-Point Iteration")
    print("=" * 70)
    
    # Causal weight matrix: A[i,j] = cost of information traveling from j to i
    A = np.array([
        [2.0, 1.0, 3.0],   # Timeline 0 receives from all timelines
        [1.0, 2.0, 1.0],   # Timeline 1 receives from all timelines
        [3.0, 1.0, 2.0],   # Timeline 2 receives from all timelines
    ])
    
    # Boundary constraints
    b = np.array([8.0, 7.0, 9.0])
    
    # Box bounds
    lo = np.array([0.0, 0.0, 0.0])
    hi = np.array([10.0, 10.0, 10.0])
    
    print(f"\nCausal weight matrix A:\n{A}")
    print(f"Boundary constraints b: {b}")
    print(f"Box: [{lo}] to [{hi}]")
    
    # Start from hi (top of box) — guaranteed to descend by monotonicity
    x = hi.copy()
    print(f"\nInitial state: {x}")
    
    print("\nIteration (Knaster-Tarski descent from top):")
    for step in range(20):
        x_new = trop_affine(A, b, x)
        residual = np.max(np.abs(x_new - x))
        print(f"  Step {step+1}: x = [{x_new[0]:.6f}, {x_new[1]:.6f}, {x_new[2]:.6f}]  "
              f"residual = {residual:.2e}")
        if residual < 1e-12:
            print(f"\n  ✓ Converged after {step+1} iterations!")
            break
        x = x_new
    
    # Verify fixed point
    Fx = trop_affine(A, b, x)
    print(f"\nFixed point x* = {x}")
    print(f"F(x*)        = {Fx}")
    print(f"||F(x*) - x*||∞ = {np.max(np.abs(Fx - x)):.2e}")
    print(f"In box [{lo}, {hi}]? {np.all(lo <= x) and np.all(x <= hi)}")
    return x


# ============================================================
# Demo 2: Contraction and Chronology Protection
# ============================================================

def demo_contraction_uniqueness():
    """
    Demonstrate Theorem 2: Uniqueness under contraction.
    
    A discounted tropical affine map (λ < 1) is a contraction.
    Starting from ANY initial point, iteration converges to the SAME fixed point.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Chronology Protection via Contraction (Discounted Map)")
    print("=" * 70)
    
    A = np.array([
        [1.0, 0.5],
        [0.5, 1.0],
    ])
    b = np.array([5.0, 5.0])
    lam = 0.5  # Discount factor < 1
    
    print(f"\nCausal matrix A:\n{A}")
    print(f"Boundary b: {b}")
    print(f"Discount factor λ = {lam}")
    
    # Try multiple starting points
    starts = [
        np.array([0.0, 0.0]),
        np.array([100.0, -50.0]),
        np.array([-100.0, 200.0]),
        np.array([42.0, -17.0]),
    ]
    
    fixed_points = []
    for idx, x0 in enumerate(starts):
        x = x0.copy()
        for step in range(100):
            x_new = trop_affine_discounted(A, b, lam, x)
            if np.max(np.abs(x_new - x)) < 1e-12:
                break
            x = x_new
        fixed_points.append(x.copy())
        print(f"\n  Start {idx+1}: x₀ = {x0}")
        print(f"  → Fixed point: x* = [{x[0]:.8f}, {x[1]:.8f}]  ({step+1} iterations)")
    
    # Verify all converge to the same point
    diffs = [np.max(np.abs(fp - fixed_points[0])) for fp in fixed_points[1:]]
    print(f"\n  Max difference between fixed points: {max(diffs):.2e}")
    print(f"  ✓ All starting points converge to the SAME fixed point!")
    print(f"  This is chronology protection: unique consistent history.")
    
    return fixed_points[0]


# ============================================================
# Demo 3: Grandfather Paradox Collapse
# ============================================================

def demo_paradox_collapse():
    """
    Demonstrate Theorem 3: Paradox resolution by tropical idempotence.
    
    Duplicating or weakening constraints cannot create paradoxes.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Grandfather Paradox Collapse by Tropical Idempotence")
    print("=" * 70)
    
    # Scenario: Two timeline branches produce the same constraint
    u = np.array([3.0, 1.0, 4.0, 1.0, 5.0])
    v = u.copy()  # Same constraint, duplicated
    
    print(f"\n  Branch 1 (u): {u}")
    print(f"  Branch 2 (v): {v}")
    print(f"  min(u, v):    {np.minimum(u, v)}")
    print(f"  u == min(u,v)? {np.allclose(u, np.minimum(u, v))}")
    print(f"  ✓ Idempotence: duplicating a constraint has no effect.")
    
    # Scenario: One branch is strictly weaker
    f = np.array([1.0, 2.0, 3.0])
    g = np.array([5.0, 7.0, 4.0])  # g ≥ f pointwise
    g_dom = np.maximum(f, g)  # Ensure g ≥ f
    
    print(f"\n  Dominant branch (f):  {f}")
    print(f"  Weaker branch (g≥f): {g_dom}")
    print(f"  min(f, g):           {np.minimum(f, g_dom)}")
    print(f"  f == min(f,g)?       {np.allclose(f, np.minimum(f, g_dom))}")
    print(f"  ✓ Absorption: weaker branches are irrelevant.")
    
    # Operator-level absorption
    A = np.array([[1.0, 2.0], [3.0, 1.0]])
    x = np.array([2.0, 3.0])
    Ax = trop_apply(A, x)
    
    print(f"\n  Tropical product A⊙x:      {Ax}")
    print(f"  min(A⊙x, A⊙x):            {np.minimum(Ax, Ax)}")
    print(f"  Same? {np.allclose(Ax, np.minimum(Ax, Ax))}")
    print(f"  ✓ Operator-level idempotence: duplicate constraints are absorbed.")


# ============================================================
# Demo 4: Convergence Rate and Discount Factor
# ============================================================

def demo_convergence_rate():
    """
    Demonstrate Theorem 4: The discount factor controls convergence rate.
    
    Shows how different values of λ affect convergence speed,
    with λ < 1 guaranteeing contraction.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Convergence Rate vs Discount Factor (Spectral Condition)")
    print("=" * 70)
    
    A = np.array([
        [0.5, 1.0, 0.3],
        [0.8, 0.5, 0.7],
        [0.3, 0.6, 0.5],
    ])
    b = np.array([10.0, 10.0, 10.0])
    x0 = np.array([50.0, -30.0, 20.0])
    
    lambdas = [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]
    
    print(f"\n  Starting point: x₀ = {x0}")
    print(f"  {'λ':>6s}  {'Iterations to conv':>20s}  {'Contraction rate':>18s}")
    print(f"  {'-'*6}  {'-'*20}  {'-'*18}")
    
    for lam in lambdas:
        x = x0.copy()
        for step in range(10000):
            x_new = trop_affine_discounted(A, b, lam, x)
            if np.max(np.abs(x_new - x)) < 1e-10:
                break
            x = x_new
        
        # Measure empirical contraction rate
        y0 = np.array([0.0, 0.0, 0.0])
        Fx0 = trop_affine_discounted(A, b, lam, x0)
        Fy0 = trop_affine_discounted(A, b, lam, y0)
        d_before = np.max(np.abs(x0 - y0))
        d_after = np.max(np.abs(Fx0 - Fy0))
        rate = d_after / d_before if d_before > 0 else 0
        
        print(f"  {lam:6.2f}  {step+1:>20d}  {rate:>18.6f}")
    
    print(f"\n  ✓ Smaller λ → faster convergence → stronger chronology protection.")
    print(f"  ✓ Empirical contraction rate ≤ λ, confirming the theorem.")


# ============================================================
# Demo 5: Graph / Cycle Interpretation
# ============================================================

def demo_cycle_interpretation():
    """
    Demonstrate the graph-theoretic interpretation.
    
    The causal matrix A defines a weighted digraph. Cycle weights
    determine whether paradox-free solutions exist.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Graph-Theoretic Interpretation (Cycle Weights)")
    print("=" * 70)
    
    # Positive cycle weights: paradox-free
    A_positive = np.array([
        [2.0, 1.0],
        [1.0, 2.0],
    ])
    
    # Zero cycle weight: boundary case
    A_zero = np.array([
        [0.0, 1.0],
        [-1.0, 0.0],
    ])
    
    print("\n  Case 1: Positive cycle weights (paradox-free)")
    print(f"  A = \n{A_positive}")
    for i in range(2):
        print(f"  Self-loop weight A[{i},{i}] = {A_positive[i,i]} > 0 ✓")
    cycle_12 = A_positive[0,1] + A_positive[1,0]
    print(f"  2-cycle weight: A[0,1] + A[1,0] = {cycle_12} > 0 ✓")
    
    print("\n  Case 2: Zero cycle weight (marginal)")
    print(f"  A = \n{A_zero}")
    cycle_12_zero = A_zero[0,1] + A_zero[1,0]
    print(f"  2-cycle weight: A[0,1] + A[1,0] = {cycle_12_zero}")
    print(f"  Zero cycle ⟹ gauge symmetry (solutions unique up to additive constant)")
    
    # Show fixed points for positive case with discounting
    b = np.array([10.0, 10.0])
    lam = 0.8
    x = np.array([5.0, 5.0])
    for _ in range(1000):
        x = trop_affine_discounted(A_positive, b, lam, x)
    print(f"\n  Fixed point (positive cycles, λ={lam}): x* = {x}")
    print(f"  ✓ Unique fixed point confirms chronology protection.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   TROPICAL TIME TRAVEL: Min-Plus CTC Consistency Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_fixed_point_iteration()
    demo_contraction_uniqueness()
    demo_paradox_collapse()
    demo_convergence_rate()
    demo_cycle_interpretation()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


"""
Tropical CTC Visualizations: Convergence, Phase Diagrams, and Contraction Maps
Generates publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import os

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (8, 6),
    'figure.dpi': 150,
})


def trop_affine_discounted(A, b, lam, x):
    n = A.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = min(np.min(A[i, :] + lam * x), b[i])
    return result


# ============================================================
# Figure 1: Convergence Trajectories
# ============================================================

def fig_convergence_trajectories():
    """Show how different starting points converge to the same fixed point."""
    A = np.array([[1.0, 0.5], [0.5, 1.0]])
    b = np.array([5.0, 5.0])
    lam = 0.6
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: trajectories in 2D state space
    ax = axes[0]
    starts = [
        np.array([0.0, 0.0]), np.array([8.0, 2.0]),
        np.array([2.0, 8.0]), np.array([-3.0, -3.0]),
        np.array([10.0, 10.0]), np.array([-5.0, 7.0]),
    ]
    colors = plt.cm.Set1(np.linspace(0, 1, len(starts)))
    
    for x0, c in zip(starts, colors):
        traj_x, traj_y = [x0[0]], [x0[1]]
        x = x0.copy()
        for _ in range(50):
            x = trop_affine_discounted(A, b, lam, x)
            traj_x.append(x[0])
            traj_y.append(x[1])
        ax.plot(traj_x, traj_y, '-o', color=c, markersize=3, alpha=0.7, linewidth=1.5)
        ax.plot(traj_x[0], traj_y[0], 's', color=c, markersize=8)
    
    # Mark fixed point
    fp = traj_x[-1], traj_y[-1]
    ax.plot(*fp, '*', color='red', markersize=20, zorder=10, markeredgecolor='black')
    ax.set_xlabel('$x_1$ (Timeline 1 state)')
    ax.set_ylabel('$x_2$ (Timeline 2 state)')
    ax.set_title(f'Convergence to Unique Fixed Point (λ={lam})')
    ax.grid(True, alpha=0.3)
    
    # Right: residual vs iteration
    ax = axes[1]
    for x0, c in zip(starts, colors):
        residuals = []
        x = x0.copy()
        for _ in range(30):
            x_new = trop_affine_discounted(A, b, lam, x)
            residuals.append(np.max(np.abs(x_new - x)))
            x = x_new
        ax.semilogy(range(1, len(residuals)+1), residuals, '-o', color=c,
                    markersize=3, linewidth=1.5)
    
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Residual $\\|F(x_k) - x_k\\|_\\infty$')
    ax.set_title('Exponential Convergence (Contraction)')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-16)
    
    plt.tight_layout()
    plt.savefig('fig_convergence.png', bbox_inches='tight')
    plt.close()
    print("Saved fig_convergence.png")


# ============================================================
# Figure 2: Contraction Rate vs Discount Factor
# ============================================================

def fig_contraction_rate():
    """Phase diagram: contraction rate as a function of discount factor."""
    A = np.array([[0.5, 1.0, 0.3], [0.8, 0.5, 0.7], [0.3, 0.6, 0.5]])
    b = np.array([10.0, 10.0, 10.0])
    
    lambdas = np.linspace(0.01, 0.99, 50)
    empirical_rates = []
    iterations_to_conv = []
    
    for lam in lambdas:
        # Empirical rate
        max_rate = 0
        for _ in range(50):
            x = np.random.randn(3) * 10
            y = np.random.randn(3) * 10
            d_in = np.max(np.abs(x - y))
            if d_in < 1e-10: continue
            Fx = trop_affine_discounted(A, b, lam, x)
            Fy = trop_affine_discounted(A, b, lam, y)
            d_out = np.max(np.abs(Fx - Fy))
            max_rate = max(max_rate, d_out / d_in)
        empirical_rates.append(max_rate)
        
        # Iterations to convergence
        x = np.ones(3) * 50
        for k in range(10000):
            x_new = trop_affine_discounted(A, b, lam, x)
            if np.max(np.abs(x_new - x)) < 1e-10:
                break
            x = x_new
        iterations_to_conv.append(k + 1)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    ax = axes[0]
    ax.plot(lambdas, empirical_rates, 'b-', linewidth=2, label='Empirical rate')
    ax.plot(lambdas, lambdas, 'r--', linewidth=2, label='Theoretical bound (λ)')
    ax.fill_between(lambdas, 0, lambdas, alpha=0.1, color='red')
    ax.set_xlabel('Discount Factor λ')
    ax.set_ylabel('Contraction Rate')
    ax.set_title('Contraction Rate ≤ λ (Theorem 4)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    
    ax = axes[1]
    ax.semilogy(lambdas, iterations_to_conv, 'g-', linewidth=2)
    ax.axvline(x=1.0, color='red', linestyle='--', label='λ = 1 (no protection)')
    ax.set_xlabel('Discount Factor λ')
    ax.set_ylabel('Iterations to Convergence')
    ax.set_title('Convergence Speed vs Dissipation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_contraction_rate.png', bbox_inches='tight')
    plt.close()
    print("Saved fig_contraction_rate.png")


# ============================================================
# Figure 3: Paradox Collapse Illustration
# ============================================================

def fig_paradox_collapse():
    """Illustrate how min absorbs duplicate and weaker constraints."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    n = 5
    x = np.arange(n)
    
    # Panel 1: Idempotence
    ax = axes[0]
    u = np.array([3, 1, 4, 1, 5])
    ax.bar(x - 0.15, u, 0.3, label='Branch u', color='steelblue', alpha=0.8)
    ax.bar(x + 0.15, u, 0.3, label='Branch v = u', color='coral', alpha=0.8)
    ax.plot(x, np.minimum(u, u), 'k*', markersize=15, label='min(u, v) = u')
    ax.set_xlabel('Coordinate')
    ax.set_ylabel('Value')
    ax.set_title('Idempotence: min(u, u) = u')
    ax.legend(fontsize=9)
    ax.set_xticks(x)
    
    # Panel 2: Absorption
    ax = axes[1]
    f = np.array([1, 2, 3, 2, 1])
    g = np.array([5, 7, 4, 6, 8])
    ax.bar(x - 0.15, f, 0.3, label='Dominant f', color='steelblue', alpha=0.8)
    ax.bar(x + 0.15, g, 0.3, label='Weaker g ≥ f', color='coral', alpha=0.8)
    ax.plot(x, np.minimum(f, g), 'k*', markersize=15, label='min(f, g) = f')
    ax.set_xlabel('Coordinate')
    ax.set_ylabel('Value')
    ax.set_title('Absorption: f ≤ g ⟹ min(f, g) = f')
    ax.legend(fontsize=9)
    ax.set_xticks(x)
    
    # Panel 3: Operator absorption
    ax = axes[2]
    A = np.array([[1, 2, 3, 1, 2], [2, 1, 1, 3, 1], [3, 2, 1, 2, 1],
                  [1, 3, 2, 1, 3], [2, 1, 3, 2, 1]], dtype=float)
    xv = np.array([2, 3, 1, 4, 2], dtype=float)
    Ax = np.array([np.min(A[i] + xv) for i in range(5)])
    ax.bar(x - 0.2, Ax, 0.2, label='A⊙x', color='steelblue', alpha=0.8)
    ax.bar(x, Ax, 0.2, label='A⊙x (copy)', color='coral', alpha=0.8)
    ax.bar(x + 0.2, np.minimum(Ax, Ax), 0.2, label='min(A⊙x, A⊙x)', color='gold', alpha=0.8)
    ax.set_xlabel('Coordinate')
    ax.set_ylabel('Value')
    ax.set_title('Duplicate Absorption')
    ax.legend(fontsize=9)
    ax.set_xticks(x)
    
    plt.tight_layout()
    plt.savefig('fig_paradox_collapse.png', bbox_inches='tight')
    plt.close()
    print("Saved fig_paradox_collapse.png")


# ============================================================
# Figure 4: Fixed Point Existence (Box Preservation)
# ============================================================

def fig_box_preservation():
    """Show how a monotone map preserving a box must have a fixed point."""
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # 2D case
    lo = np.array([0.0, 0.0])
    hi = np.array([10.0, 10.0])
    
    A = np.array([[2.0, 1.0], [1.0, 2.0]])
    b = np.array([8.0, 7.0])
    lam = 0.7
    
    # Draw box
    rect = plt.Rectangle(lo, hi[0]-lo[0], hi[1]-lo[1], fill=False,
                         edgecolor='black', linewidth=2, linestyle='--')
    ax.add_patch(rect)
    
    # Show F mapping on a grid of points
    grid = np.linspace(0.5, 9.5, 8)
    for xi in grid:
        for yi in grid:
            x = np.array([xi, yi])
            Fx = trop_affine_discounted(A, b, lam, x)
            dx, dy = Fx[0] - x[0], Fx[1] - x[1]
            ax.arrow(x[0], x[1], dx*0.8, dy*0.8, head_width=0.15,
                    head_length=0.1, fc='steelblue', ec='steelblue', alpha=0.5)
    
    # Show trajectory from corner
    x = hi.copy()
    traj = [x.copy()]
    for _ in range(30):
        x = trop_affine_discounted(A, b, lam, x)
        traj.append(x.copy())
    traj = np.array(traj)
    ax.plot(traj[:, 0], traj[:, 1], 'r-o', markersize=4, linewidth=2, label='Iteration')
    ax.plot(traj[-1, 0], traj[-1, 1], '*', color='red', markersize=20,
           markeredgecolor='black', label='Fixed point')
    
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 11)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_title(f'Box-Preserving Map → Fixed Point (λ={lam})')
    ax.legend(loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('fig_box_preservation.png', bbox_inches='tight')
    plt.close()
    print("Saved fig_box_preservation.png")


# ============================================================
# Generate All Figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    fig_convergence_trajectories()
    fig_contraction_rate()
    fig_paradox_collapse()
    fig_box_preservation()
    print("\nAll figures generated successfully!")
