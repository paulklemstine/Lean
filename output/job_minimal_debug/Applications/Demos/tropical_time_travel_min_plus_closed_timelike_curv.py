#!/usr/bin/env python3
"""
Tropical Time Travel: Real-World Applications

Demonstrates how tropical CTC fixed-point theory applies to:
  1. Network routing — shortest-path consistency
  2. Scheduling — critical path in feedback systems
  3. Program analysis — abstract interpretation fixed points
  4. Game theory — min-plus equilibria in concurrent systems
"""

import numpy as np
from algorithms import (
    tropical_fixed_point_iteration,
    check_chronology_protection,
    minimum_cycle_mean,
    find_consistent_history,
)


def app_network_routing():
    """
    Application 1: Self-Consistent Routing in Networks with Loops

    In network routing, cycles appear naturally (e.g., routing loops,
    backup paths). The tropical affine fixed point gives the shortest
    self-consistent path costs through a network with feedback.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing with Feedback Loops")
    print("=" * 60)

    # 5-node network with a cycle: 0→1→2→3→4→2
    INF = 100.0  # Large penalty (no direct edge)
    A = np.array([
        [INF,   1, INF, INF, INF],  # Node 0 → Node 1 (cost 1)
        [INF, INF,   2, INF, INF],  # Node 1 → Node 2 (cost 2)
        [INF, INF, INF,   1, INF],  # Node 2 → Node 3 (cost 1)
        [INF, INF, INF, INF,   3],  # Node 3 → Node 4 (cost 3)
        [INF, INF,   1, INF, INF],  # Node 4 → Node 2 (cost 1) — FEEDBACK
    ], dtype=float)

    # Boundary: source costs
    b = np.array([0.0, 10.0, 10.0, 10.0, 10.0])

    print("  Network: 0→1(1), 1→2(2), 2→3(1), 3→4(3), 4→2(1)")
    print("  Cycle: 2→3→4→2 with total cost 1+3+1=5")

    mcm = minimum_cycle_mean(A)
    print(f"  Minimum cycle mean: {mcm:.2f}")

    fp, iters, ok = tropical_fixed_point_iteration(A, b, lam=0.9, max_iter=100)
    print(f"  Shortest consistent path costs (λ=0.9): {np.round(fp, 4)}")
    print(f"  Converged in {iters} iterations: {ok}")

    report = check_chronology_protection(A, b, lam=0.9)
    print(f"  {report.explanation}")
    print()


def app_scheduling():
    """
    Application 2: Critical-Path Scheduling with Feedback

    In project management, some tasks depend on outputs of later tasks
    (iterative design, testing feedback). The tropical fixed point gives
    the stable schedule.
    """
    print("=" * 60)
    print("APPLICATION 2: Project Scheduling with Iterative Feedback")
    print("=" * 60)

    # 4 tasks: Design(0), Implement(1), Test(2), Review(3)
    # Dependencies with durations (min-plus: earlier = better)
    INF = 1000.0
    A = np.array([
        [INF,   2, INF,   1],  # Design depends on: Implement(+2), Review(+1)
        [  3, INF, INF, INF],  # Implement depends on: Design(+3)
        [INF,   2, INF, INF],  # Test depends on: Implement(+2)
        [INF, INF,   1, INF],  # Review depends on: Test(+1)
    ], dtype=float)

    # External deadlines
    b = np.array([0.0, 5.0, 8.0, 10.0])

    print("  Tasks: Design→Implement→Test→Review")
    print("  Feedback: Review→Design (iterative refinement)")

    mcm = minimum_cycle_mean(A)
    print(f"  Minimum cycle mean: {mcm:.2f}")
    print(f"  (Positive ⟹ schedule stabilizes)")

    fp, traj = find_consistent_history(A, b, lam=0.8)
    print(f"  Stable schedule: {np.round(fp, 4)}")
    print(f"  Converged in {len(traj)-1} iterations")
    print()


def app_program_analysis():
    """
    Application 3: Abstract Interpretation for Program Analysis

    In static analysis of programs with loops, the analysis state must
    reach a fixed point. The tropical framework models this as a min-plus
    system where "costs" represent abstract values (e.g., resource bounds).
    """
    print("=" * 60)
    print("APPLICATION 3: Program Analysis — Loop Invariant Discovery")
    print("=" * 60)

    # Simple loop: x = min(x + 1, 10) at program point 1
    # Three program points with dependencies
    A = np.array([
        [100,   0, 100],  # Point 0: entry, no deps
        [  1, 100, 100],  # Point 1: loop body, depends on Point 0 (+1)
        [100,   0, 100],  # Point 2: exit, depends on Point 1 (+0)
    ], dtype=float)

    b = np.array([0.0, 10.0, 15.0])  # Initial abstract values

    print("  Program: while (x < 10) { x = x + 1 }")
    print("  Abstract domain: min-plus costs (lower = earlier)")

    fp, iters, ok = tropical_fixed_point_iteration(A, b, lam=1.0, max_iter=50)
    print(f"  Abstract fixed point: {np.round(fp, 4)}")
    print(f"  Converged in {iters} iterations: {ok}")

    # With widening (discount)
    fp2, iters2, ok2 = tropical_fixed_point_iteration(A, b, lam=0.95, max_iter=50)
    print(f"  With widening (λ=0.95): {np.round(fp2, 4)}")
    print(f"  Converged in {iters2} iterations: {ok2}")
    print()


def app_game_theory():
    """
    Application 4: Min-Plus Equilibria in Concurrent Games

    Two players make simultaneous choices; payoffs are combined via min-plus.
    The fixed point represents a stable equilibrium where no player can
    unilaterally improve their tropical payoff.
    """
    print("=" * 60)
    print("APPLICATION 4: Tropical Game Equilibrium")
    print("=" * 60)

    # 3-player game, each player has a strategy that affects others
    # A[i,j] = impact of player j's strategy on player i's cost
    A = np.array([
        [0,  2,  3],   # Player 0's costs depend on others
        [1,  0,  4],   # Player 1
        [2,  1,  0],   # Player 2
    ], dtype=float)

    # External constraints (budget limits)
    b = np.array([5.0, 5.0, 5.0])

    print("  3-player min-plus game")
    print(f"  Impact matrix A:\n    {A.tolist()}")
    print(f"  Budget constraints: {b.tolist()}")

    report = check_chronology_protection(A, b, lam=0.7)
    print(f"\n  Analysis:")
    print(f"  {report.explanation}")

    if report.fixed_point is not None:
        print(f"\n  Equilibrium strategies: {np.round(report.fixed_point, 4)}")
    print()


if __name__ == "__main__":
    print("\n  TROPICAL TIME TRAVEL: REAL-WORLD APPLICATIONS\n")
    app_network_routing()
    app_scheduling()
    app_program_analysis()
    app_game_theory()
    print("All applications completed.\n")


#!/usr/bin/env python3
"""
Tropical Time Travel: Min-Plus Closed Timelike Curves — Demonstrations

Concrete numerical examples illustrating the formally verified theorems:
  1. Novikov consistency (fixed-point existence via idempotence)
  2. Unique consistency for contractive tropical maps
  3. Grandfather paradox collapse via min-idempotence
  4. Chronology protection from acyclicity / discounting
"""

import numpy as np
from typing import Callable, Tuple, Optional

# ─────────────────────────────────────────────────
# Core: min-plus matrix-vector product and affine map
# ─────────────────────────────────────────────────

def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """(A ⊗ x)_i = min_j (A[i,j] + x[j])"""
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def tropical_affine(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """F(x)_i = min( (A ⊗ x)_i, b_i )"""
    return np.minimum(tropical_matvec(A, x), b)


def discounted_tropical_affine(A: np.ndarray, b: np.ndarray,
                                lam: float, x: np.ndarray) -> np.ndarray:
    """F_λ(x)_i = min( min_j(A[i,j] + λ·x[j]), b_i )"""
    n = A.shape[0]
    Tx = np.array([np.min(A[i, :] + lam * x) for i in range(n)])
    return np.minimum(Tx, b)


# ─────────────────────────────────────────────────
# Demo 1: Novikov Consistency — Idempotent Fixed Point
# ─────────────────────────────────────────────────

def demo_novikov():
    """Demonstrate that an idempotent operator always has a fixed point."""
    print("=" * 60)
    print("DEMO 1: Novikov Consistency (Idempotent Fixed Point)")
    print("=" * 60)

    # Define a simple idempotent operator: projection onto min
    # F(x)_i = min(x_0, x_1, ..., x_{n-1})  (constant output)
    def F_idem(x: np.ndarray) -> np.ndarray:
        return np.full_like(x, np.min(x))

    # Verify idempotence: F(F(x)) = F(x)
    x0 = np.array([3.0, 1.0, 4.0, 1.0, 5.0])
    Fx = F_idem(x0)
    FFx = F_idem(Fx)
    print(f"  x₀     = {x0}")
    print(f"  F(x₀)  = {Fx}")
    print(f"  F²(x₀) = {FFx}")
    print(f"  Idempotent: F²(x₀) == F(x₀)? {np.allclose(FFx, Fx)}")

    # F(x₀) is already a fixed point
    print(f"  Fixed point: F(x₀) is fixed? F(F(x₀)) == F(x₀)? {np.allclose(F_idem(Fx), Fx)}")

    # A more interesting idempotent: tropical affine with A such that b dominates
    n = 3
    A = np.array([[0, 10, 10],
                   [10, 0, 10],
                   [10, 10, 0]], dtype=float)
    b = np.array([-1.0, -2.0, -3.0])

    # When all A[i,j] + b[j] >= b[i], the tropical affine map has b as fixed point
    print(f"\n  Tropical affine system (n={n}):")
    print(f"    A = {A.tolist()}")
    print(f"    b = {b.tolist()}")
    fp = tropical_affine(A, b, b)
    print(f"    F(b) = {fp}")
    print(f"    b is fixed point: {np.allclose(fp, b)}")
    print()


# ─────────────────────────────────────────────────
# Demo 2: Unique Consistency via Contraction
# ─────────────────────────────────────────────────

def demo_contraction_uniqueness():
    """Demonstrate convergence to a unique fixed point for contractive maps."""
    print("=" * 60)
    print("DEMO 2: Unique Consistency (Contraction Fixed Point)")
    print("=" * 60)

    n = 3
    A = np.array([[0, 2, 5],
                   [3, 0, 2],
                   [4, 3, 0]], dtype=float)
    b = np.array([1.0, 0.5, 2.0])
    lam = 0.5  # discount factor

    print(f"  Discount factor λ = {lam}")
    print(f"  A = {A.tolist()}")
    print(f"  b = {b.tolist()}")

    # Iterate from two different starting points
    x1 = np.array([100.0, -50.0, 0.0])
    x2 = np.array([-100.0, 200.0, -300.0])

    print(f"\n  Starting from x₁ = {x1.tolist()}")
    for step in range(15):
        x1 = discounted_tropical_affine(A, b, lam, x1)
        if step < 5 or step >= 12:
            print(f"    Iteration {step+1:2d}: {np.round(x1, 6).tolist()}")

    print(f"\n  Starting from x₂ = {x2.tolist()}")
    for step in range(15):
        x2 = discounted_tropical_affine(A, b, lam, x2)
        if step < 5 or step >= 12:
            print(f"    Iteration {step+1:2d}: {np.round(x2, 6).tolist()}")

    print(f"\n  Both converge to same point? {np.allclose(x1, x2, atol=1e-8)}")
    print(f"  Fixed point: {np.round(x1, 8).tolist()}")

    # Verify it's a fixed point
    fp_check = discounted_tropical_affine(A, b, lam, x1)
    print(f"  F(x*) = x*? {np.allclose(fp_check, x1, atol=1e-10)}")
    print()


# ─────────────────────────────────────────────────
# Demo 3: Grandfather Paradox Collapse
# ─────────────────────────────────────────────────

def demo_paradox_collapse():
    """Demonstrate that min(a,a) = a resolves branch duplication."""
    print("=" * 60)
    print("DEMO 3: Grandfather Paradox Collapse (Idempotence of min)")
    print("=" * 60)

    # Scalar case
    a = 42.0
    print(f"  Scalar: min({a}, {a}) = {min(a, a)}  (== {a}? {min(a, a) == a})")

    # Vector case: two identical timeline branches
    branch1 = np.array([1.0, -2.5, 3.14, 0.0, -1.0])
    branch2 = branch1.copy()
    merged = np.minimum(branch1, branch2)
    print(f"\n  Branch 1: {branch1.tolist()}")
    print(f"  Branch 2: {branch2.tolist()}")
    print(f"  Merged:   {merged.tolist()}")
    print(f"  Collapse: merged == branch1? {np.array_equal(merged, branch1)}")

    # Operator level: F and min(F, F)
    A = np.array([[1, 3], [2, 1]], dtype=float)
    b = np.array([0.0, 0.5])
    x = np.array([5.0, -3.0])

    Fx = tropical_affine(A, b, x)
    merged_Fx = np.minimum(Fx, Fx)
    print(f"\n  Operator: F(x) = {Fx.tolist()}")
    print(f"  min(F(x), F(x)) = {merged_Fx.tolist()}")
    print(f"  Collapse holds: {np.array_equal(merged_Fx, Fx)}")
    print()


# ─────────────────────────────────────────────────
# Demo 4: Chronology Protection
# ─────────────────────────────────────────────────

def demo_chronology_protection():
    """Demonstrate fixed-point existence from domination / acyclicity."""
    print("=" * 60)
    print("DEMO 4: Chronology Protection (Acyclicity / Domination)")
    print("=" * 60)

    # Case 1: b dominates (A[i,j] + b[j] >= b[i] for all i,j)
    n = 4
    b = np.array([0.0, 1.0, 2.0, 3.0])
    # Make A such that A[i,j] + b[j] >= b[i] always
    A = np.array([[5, 4, 3, 2],
                   [6, 5, 4, 3],
                   [7, 6, 5, 4],
                   [8, 7, 6, 5]], dtype=float)

    print("  Case 1: Domination condition A[i,j] + b[j] >= b[i]")
    dominated = all(A[i, j] + b[j] >= b[i] for i in range(n) for j in range(n))
    print(f"    Domination holds: {dominated}")
    fp = tropical_affine(A, b, b)
    print(f"    b = {b.tolist()}")
    print(f"    F(b) = {fp.tolist()}")
    print(f"    b is fixed point: {np.allclose(fp, b)}")

    # Case 2: Discounted map converges
    print("\n  Case 2: Discounted tropical map (λ=0.3)")
    A2 = np.array([[0, 1, 2],
                    [2, 0, 1],
                    [1, 2, 0]], dtype=float)
    b2 = np.array([1.0, 1.0, 1.0])
    lam = 0.3

    x = np.zeros(3)
    print(f"    Starting from x = {x.tolist()}")
    for step in range(20):
        x = discounted_tropical_affine(A2, b2, lam, x)
    print(f"    After 20 iterations: {np.round(x, 8).tolist()}")
    fp_check = discounted_tropical_affine(A2, b2, lam, x)
    print(f"    Is fixed point: {np.allclose(fp_check, x, atol=1e-12)}")
    print()


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n  TROPICAL TIME TRAVEL: MIN-PLUS CTC DEMONSTRATIONS\n")
    demo_novikov()
    demo_contraction_uniqueness()
    demo_paradox_collapse()
    demo_chronology_protection()
    print("All demonstrations completed successfully.\n")


#!/usr/bin/env python3
"""
Tropical Time Travel: Visualizations

Generates publication-quality figures illustrating:
  1. Contraction convergence to unique fixed point
  2. Iteration trajectory in state space
  3. Chronology protection phase diagram
  4. Paradox collapse illustration
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def tropical_matvec(A, x):
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def discounted_tropical_affine(A, b, lam, x):
    n = A.shape[0]
    Tx = np.array([np.min(A[i, :] + lam * x) for i in range(n)])
    return np.minimum(Tx, b)


# ─────────────────────────────────────────────────
# Figure 1: Contraction Convergence
# ─────────────────────────────────────────────────

def plot_contraction_convergence():
    """Show convergence from different starting points to unique fixed point."""
    A = np.array([[0, 2, 5], [3, 0, 2], [4, 3, 0]], dtype=float)
    b = np.array([1.0, 0.5, 2.0])
    lam = 0.5

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: trajectories of each coordinate
    ax = axes[0]
    colors_starts = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    starts = [
        np.array([10.0, -5.0, 8.0]),
        np.array([-8.0, 12.0, -3.0]),
        np.array([0.0, 0.0, 0.0]),
        np.array([5.0, 5.0, 5.0]),
    ]

    for si, x0 in enumerate(starts):
        x = x0.copy()
        traj = [x.copy()]
        for _ in range(25):
            x = discounted_tropical_affine(A, b, lam, x)
            traj.append(x.copy())
        traj = np.array(traj)

        for ci in range(3):
            label = f"Start {si+1}, x[{ci}]" if ci == 0 else None
            ax.plot(traj[:, ci], color=colors_starts[si], alpha=0.6,
                    linestyle=['-', '--', ':'][ci], linewidth=1.5)

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('State value', fontsize=12)
    ax.set_title('Convergence to Unique Fixed Point (λ=0.5)', fontsize=13)
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.grid(True, alpha=0.3)

    # Right: sup-norm error vs iteration
    ax = axes[1]
    # Find the fixed point
    x_star = starts[0].copy()
    for _ in range(200):
        x_star = discounted_tropical_affine(A, b, lam, x_star)

    for si, x0 in enumerate(starts):
        x = x0.copy()
        errors = [np.max(np.abs(x - x_star))]
        for _ in range(25):
            x = discounted_tropical_affine(A, b, lam, x)
            errors.append(np.max(np.abs(x - x_star)))
        ax.semilogy(errors, color=colors_starts[si], linewidth=2,
                    label=f'Start {si+1}')

    # Theoretical bound: q^k * d0
    k_vals = np.arange(26)
    ax.semilogy(k_vals, lam**k_vals * 20, 'k--', alpha=0.5,
                label=f'Bound: λᵏ·d₀ (λ={lam})')

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('‖x - x*‖∞', fontsize=12)
    ax.set_title('Exponential Convergence Rate', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical CTC: Contraction Maps Have Unique Consistent Solutions',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_contraction.png',
                dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────
# Figure 2: Phase diagram — discount factor vs convergence
# ─────────────────────────────────────────────────

def plot_phase_diagram():
    """Chronology protection: how discount factor affects convergence."""
    A = np.array([[0, 1, 3], [2, 0, 1], [1, 3, 0]], dtype=float)
    b = np.array([2.0, 1.0, 3.0])

    lam_values = np.linspace(0.01, 0.99, 50)
    convergence_iters = []
    fp_norms = []

    for lam in lam_values:
        x = np.zeros(3)
        for it in range(500):
            x_new = discounted_tropical_affine(A, b, lam, x)
            if np.max(np.abs(x_new - x)) < 1e-12:
                convergence_iters.append(it + 1)
                fp_norms.append(np.linalg.norm(x_new))
                break
            x = x_new
        else:
            convergence_iters.append(500)
            fp_norms.append(np.linalg.norm(x))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.plot(lam_values, convergence_iters, 'b-', linewidth=2)
    ax.fill_between(lam_values, convergence_iters, alpha=0.15, color='blue')
    ax.set_xlabel('Discount Factor λ', fontsize=12)
    ax.set_ylabel('Iterations to Convergence', fontsize=12)
    ax.set_title('Convergence Speed vs. Damping', fontsize=13)
    ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='λ=1 (undamped)')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(lam_values, fp_norms, 'r-', linewidth=2)
    ax.set_xlabel('Discount Factor λ', fontsize=12)
    ax.set_ylabel('‖x*‖₂ (Fixed Point Norm)', fontsize=12)
    ax.set_title('Fixed Point Location vs. Damping', fontsize=13)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Chronology Protection Phase Diagram',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_phase_diagram.png',
                dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────
# Figure 3: Paradox collapse illustration
# ─────────────────────────────────────────────────

def plot_paradox_collapse():
    """Illustrate how min(F(x), F(x)) = F(x) absorbs contradictions."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Panel 1: Scalar min(a, a) = a
    ax = axes[0]
    a_vals = np.linspace(-3, 3, 100)
    ax.plot(a_vals, a_vals, 'b-', linewidth=2, label='a')
    ax.plot(a_vals, np.minimum(a_vals, a_vals), 'r--', linewidth=3,
            alpha=0.7, label='min(a, a)')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Scalar Idempotence: min(a,a) = a', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 2: Two branches merging
    ax = axes[1]
    t = np.linspace(0, 2*np.pi, 100)
    branch1 = np.sin(t) + 0.5
    branch2 = np.sin(t) + 0.5  # Same branch
    merged = np.minimum(branch1, branch2)

    ax.plot(t, branch1, 'b-', linewidth=2, label='Branch 1 (F)')
    ax.plot(t, branch2, 'r--', linewidth=3, alpha=0.5, label='Branch 2 (F)')
    ax.plot(t, merged, 'g:', linewidth=2, label='min(F, F) = F')
    ax.set_xlabel('State parameter', fontsize=12)
    ax.set_ylabel('Timeline value', fontsize=12)
    ax.set_title('Paradox Collapse: Identical Branches', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Different branches (min selects lower)
    ax = axes[2]
    branch_a = np.sin(t) + 1
    branch_b = np.cos(t) + 0.5
    merged_ab = np.minimum(branch_a, branch_b)

    ax.plot(t, branch_a, 'b-', linewidth=2, label='Branch A')
    ax.plot(t, branch_b, 'r-', linewidth=2, label='Branch B')
    ax.fill_between(t, merged_ab, alpha=0.2, color='green')
    ax.plot(t, merged_ab, 'g-', linewidth=2.5, label='min(A, B) — optimal')
    ax.set_xlabel('State parameter', fontsize=12)
    ax.set_ylabel('Timeline value', fontsize=12)
    ax.set_title('Branch Selection: min Picks Cheapest', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Grandfather Paradox Resolution via Tropical Idempotence',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_paradox_collapse.png',
                dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────
# Figure 4: Iteration trajectory in 2D state space
# ─────────────────────────────────────────────────

def plot_trajectory_2d():
    """Show iteration paths in 2D state space converging to fixed point."""
    A = np.array([[0, 3], [2, 0]], dtype=float)
    b = np.array([1.0, 1.5])
    lam = 0.6

    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Find fixed point
    x_star = np.zeros(2)
    for _ in range(200):
        x_star = discounted_tropical_affine(A, b, lam, x_star)

    # Plot trajectories from different starts
    starts = [
        np.array([8.0, -4.0]),
        np.array([-5.0, 10.0]),
        np.array([6.0, 7.0]),
        np.array([-3.0, -6.0]),
        np.array([0.0, 12.0]),
    ]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']

    for si, x0 in enumerate(starts):
        x = x0.copy()
        xs, ys = [x[0]], [x[1]]
        for _ in range(30):
            x = discounted_tropical_affine(A, b, lam, x)
            xs.append(x[0])
            ys.append(x[1])

        ax.plot(xs, ys, '-o', color=colors[si], markersize=3,
                linewidth=1.5, alpha=0.7, label=f'Start {si+1}')
        ax.plot(xs[0], ys[0], 's', color=colors[si], markersize=10)

    ax.plot(x_star[0], x_star[1], '*', color='black', markersize=20,
            zorder=10, label='Fixed Point x*')

    ax.set_xlabel('x[0]', fontsize=12)
    ax.set_ylabel('x[1]', fontsize=12)
    ax.set_title('Tropical CTC Iteration: All Paths Converge\nto the Unique Consistent History',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal', adjustable='datalim')

    fig.savefig('/workspace/request-project/fig_trajectory.png',
                dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_contraction_convergence()
    print(f"  fig_contraction.png — {len(b64_1)} chars base64")
    b64_2 = plot_phase_diagram()
    print(f"  fig_phase_diagram.png — {len(b64_2)} chars base64")
    b64_3 = plot_paradox_collapse()
    print(f"  fig_paradox_collapse.png — {len(b64_3)} chars base64")
    b64_4 = plot_trajectory_2d()
    print(f"  fig_trajectory.png — {len(b64_4)} chars base64")
    print("Done.")
