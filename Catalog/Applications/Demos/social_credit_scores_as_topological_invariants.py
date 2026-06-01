#!/usr/bin/env python3
"""
Social Credit Scores as Topological Invariants — Numerical Demonstrations

Demonstrates the key mathematical results:
1. Contraction convergence of iterated scoring
2. Phase transition in the logistic scoring map
3. Cantor attractor construction
"""

import math

def logistic_score(a: float, x: float) -> float:
    """The logistic scoring map f_a(x) = a*x*(1-x)."""
    return a * x * (1 - x)

def iterate_score(update, x0: float, n: int) -> list[float]:
    """Iterate a score update function n times from initial value x0."""
    trajectory = [x0]
    x = x0
    for _ in range(n):
        x = update(x)
        trajectory.append(x)
    return trajectory

def demo_contraction_convergence():
    """Demonstrate geometric convergence of iterated scoring."""
    print("=" * 60)
    print("DEMO 1: Contraction Convergence")
    print("=" * 60)

    # Contractive update: T(x) = 0.5*x + 0.25 (contraction rate κ = 0.5)
    # Fixed point: x* = 0.5*x* + 0.25 => x* = 0.5
    kappa = 0.5
    update = lambda x: kappa * x + 0.25

    for x0 in [0.0, 0.3, 0.7, 1.0]:
        traj = iterate_score(update, x0, 20)
        print(f"\n  Starting from x₀ = {x0:.1f}:")
        for i in [0, 1, 2, 5, 10, 20]:
            error = abs(traj[i] - 0.5)
            print(f"    n={i:2d}: score = {traj[i]:.10f}, |x - x*| = {error:.2e}")

    # Verify two-point contraction
    print("\n  Two-point contraction verification (x₀=0.0, y₀=1.0):")
    traj_x = iterate_score(update, 0.0, 20)
    traj_y = iterate_score(update, 1.0, 20)
    for n in [0, 1, 2, 5, 10, 15, 20]:
        gap = abs(traj_x[n] - traj_y[n])
        bound = kappa**n * abs(0.0 - 1.0)
        print(f"    n={n:2d}: |xₙ - yₙ| = {gap:.2e}, κⁿ·|x₀-y₀| = {bound:.2e}")

def demo_phase_transition():
    """Demonstrate the bifurcation in the logistic scoring map."""
    print("\n" + "=" * 60)
    print("DEMO 2: Phase Transition at a = 1")
    print("=" * 60)

    # For a < 1: unique fixed point at 0
    print("\n  Regime a < 1 (collapse to zero):")
    for a in [0.3, 0.5, 0.8, 0.95]:
        traj = iterate_score(lambda x, a=a: logistic_score(a, x), 0.5, 100)
        print(f"    a = {a:.2f}: score after 100 iterations = {traj[-1]:.10f}")

    # For a > 1: non-trivial fixed point at 1 - 1/a
    print("\n  Regime a > 1 (non-trivial fixed point emerges):")
    for a in [1.05, 1.5, 2.0, 2.5, 3.0]:
        x_star = 1 - 1/a
        traj = iterate_score(lambda x, a=a: logistic_score(a, x), 0.5, 100)
        print(f"    a = {a:.2f}: x* = {x_star:.6f}, "
              f"converged to {traj[-1]:.6f}, "
              f"error = {abs(traj[-1] - x_star):.2e}")

    # Verify the fixed point equation
    print("\n  Fixed point verification (f_a(x*) = x*):")
    for a in [1.5, 2.0, 3.0, 3.5]:
        x_star = 1 - 1/a
        fx = logistic_score(a, x_star)
        print(f"    a = {a:.1f}: x* = {x_star:.6f}, f(x*) = {fx:.6f}, "
              f"|f(x*) - x*| = {abs(fx - x_star):.2e}")

def demo_cantor_attractor():
    """Demonstrate the Cantor set construction via middle-third removal."""
    print("\n" + "=" * 60)
    print("DEMO 3: Cantor Attractor Construction")
    print("=" * 60)

    def middle_third_removal(n: int) -> list[tuple[float, float]]:
        """Return intervals at stage n of the Cantor construction."""
        intervals = [(0.0, 1.0)]
        for _ in range(n):
            new_intervals = []
            for a, b in intervals:
                w = (b - a) / 3
                new_intervals.append((a, a + w))
                new_intervals.append((b - w, b))
            intervals = new_intervals
        return intervals

    for n in range(7):
        intervals = middle_third_removal(n)
        total_length = sum(b - a for a, b in intervals)
        print(f"\n  Stage {n}: {len(intervals)} intervals, "
              f"total length = {total_length:.6f} = (2/3)^{n} = {(2/3)**n:.6f}")
        if n <= 3:
            for a, b in intervals:
                print(f"    [{a:.4f}, {b:.4f}]")

    # Verify 0 and 1 survive all stages
    print("\n  Endpoints in attractor:")
    for n in range(10):
        intervals = middle_third_removal(n)
        zero_in = any(a <= 0 <= b for a, b in intervals)
        one_in = any(a <= 1 <= b for a, b in intervals)
        print(f"    Stage {n}: 0 ∈ C_{n}? {zero_in}, 1 ∈ C_{n}? {one_in}")

def demo_scoring_stratification():
    """Demonstrate level set partition and threshold boundary."""
    print("\n" + "=" * 60)
    print("DEMO 4: Scoring Stratification")
    print("=" * 60)

    # Simulate a 1D population with Gaussian score distribution
    import random
    random.seed(42)
    n_pop = 1000
    population = sorted([random.gauss(0.5, 0.15) for _ in range(n_pop)])
    population = [max(0, min(1, x)) for x in population]

    theta = 0.6
    approved = [x for x in population if x >= theta]
    rejected = [x for x in population if x < theta]

    print(f"\n  Population: {n_pop} individuals")
    print(f"  Threshold θ = {theta}")
    print(f"  Approved: {len(approved)} ({100*len(approved)/n_pop:.1f}%)")
    print(f"  Rejected: {len(rejected)} ({100*len(rejected)/n_pop:.1f}%)")

    # Show boundary behavior
    near_boundary = [x for x in population if abs(x - theta) < 0.01]
    approved_boundary = [x for x in near_boundary if x >= theta]
    rejected_boundary = [x for x in near_boundary if x < theta]
    print(f"\n  Near boundary (|score - θ| < 0.01):")
    print(f"    Total: {len(near_boundary)}")
    print(f"    Approved (score ≥ θ): {len(approved_boundary)}")
    print(f"    Rejected (score < θ): {len(rejected_boundary)}")
    print(f"    Note: θ itself belongs to the APPROVED (closed) set")

    # Threshold sensitivity
    print(f"\n  Threshold sensitivity (% approved vs θ):")
    for t in [0.3, 0.4, 0.5, 0.6, 0.7, 0.8]:
        pct = 100 * sum(1 for x in population if x >= t) / n_pop
        print(f"    θ = {t:.1f}: {pct:.1f}% approved")

if __name__ == "__main__":
    demo_contraction_convergence()
    demo_phase_transition()
    demo_cantor_attractor()
    demo_scoring_stratification()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Bifurcation Diagram of the Logistic Scoring Map

Visualizes the phase transition: for a < 1, scores collapse to 0.
At a = 1, a non-trivial fixed point emerges. For a > 3, period-doubling
cascades lead to chaos.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_bifurcation_diagram(
    a_min: float = 0.0,
    a_max: float = 4.0,
    n_params: int = 2000,
    n_warmup: int = 500,
    n_plot: int = 200,
) -> tuple:
    a_values = np.linspace(a_min, a_max, n_params)
    all_a = []
    all_x = []

    for a in a_values:
        x = 0.5
        for _ in range(n_warmup):
            x = a * x * (1 - x)
        for _ in range(n_plot):
            x = a * x * (1 - x)
            all_a.append(a)
            all_x.append(x)

    return np.array(all_a), np.array(all_x)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Full bifurcation diagram
    a_vals, x_vals = compute_bifurcation_diagram()
    axes[0].scatter(a_vals, x_vals, s=0.01, c='navy', alpha=0.3)
    axes[0].axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='a = 1 (bifurcation)')
    axes[0].axvline(x=3.0, color='orange', linestyle='--', alpha=0.7, label='a = 3 (period-2)')

    # Plot the analytical fixed point x* = 1 - 1/a
    a_range = np.linspace(1.01, 4.0, 500)
    x_star = 1 - 1/a_range
    axes[0].plot(a_range, x_star, 'r-', linewidth=1.5, alpha=0.5, label='x* = 1-1/a')
    axes[0].plot([0, 4], [0, 0], 'g-', linewidth=1.5, alpha=0.5, label='x* = 0')

    axes[0].set_xlabel('Parameter a', fontsize=12)
    axes[0].set_ylabel('Score (attractor)', fontsize=12)
    axes[0].set_title('Logistic Scoring Map: Bifurcation Diagram', fontsize=13)
    axes[0].legend(fontsize=9)
    axes[0].set_xlim(0, 4)
    axes[0].set_ylim(-0.05, 1.05)

    # Zoom into the phase transition at a = 1
    a_vals_zoom, x_vals_zoom = compute_bifurcation_diagram(0.5, 1.5, 1000, 200, 50)
    axes[1].scatter(a_vals_zoom, x_vals_zoom, s=0.5, c='navy', alpha=0.5)
    axes[1].axvline(x=1.0, color='red', linestyle='--', alpha=0.7, label='Phase transition')

    a_zoom = np.linspace(1.01, 1.5, 200)
    axes[1].plot(a_zoom, 1 - 1/a_zoom, 'r-', linewidth=2, label='x* = 1-1/a')
    axes[1].plot([0.5, 1.5], [0, 0], 'g-', linewidth=2, label='x* = 0')

    axes[1].set_xlabel('Parameter a', fontsize=12)
    axes[1].set_ylabel('Score (attractor)', fontsize=12)
    axes[1].set_title('Phase Transition Detail (a ≈ 1)', fontsize=13)
    axes[1].legend(fontsize=10)
    axes[1].set_xlim(0.5, 1.5)
    axes[1].set_ylim(-0.1, 0.5)

    plt.tight_layout()
    plt.savefig('viz_bifurcation.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_bifurcation.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Cantor Set Attractor Visualization

Shows the iterative construction of the Cantor set through middle-third
removal, demonstrating the attractor dimension collapse.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def cantor_intervals(n_stages: int) -> list:
    intervals = [(0.0, 1.0)]
    for _ in range(n_stages):
        new = []
        for a, b in intervals:
            w = (b - a) / 3
            new.append((a, a + w))
            new.append((b - w, b))
        intervals = new
    return intervals


def main():
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [3, 1]})

    n_stages = 7
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_stages + 1))

    for stage in range(n_stages + 1):
        intervals = cantor_intervals(stage)
        y = n_stages - stage
        for a, b in intervals:
            axes[0].fill_between([a, b], y - 0.35, y + 0.35,
                               color=colors[stage], alpha=0.8)

    axes[0].set_yticks(range(n_stages + 1))
    axes[0].set_yticklabels([f'Stage {n_stages - i}' for i in range(n_stages + 1)])
    axes[0].set_xlabel('Score', fontsize=12)
    axes[0].set_title('Cantor Set Construction: Middle-Third Removal', fontsize=14)
    axes[0].set_xlim(-0.02, 1.02)

    # Plot measure decay
    stages = list(range(n_stages + 1))
    measures = [(2/3)**n for n in stages]
    n_intervals = [2**n for n in stages]

    ax2 = axes[1]
    ax2.semilogy(stages, measures, 'bo-', linewidth=2, markersize=8, label='Total measure (2/3)ⁿ')
    ax2.set_xlabel('Stage', fontsize=12)
    ax2.set_ylabel('Measure', fontsize=12)
    ax2.set_title('Measure Decay → 0 (Dimension Collapse)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    ax3 = ax2.twinx()
    ax3.semilogy(stages, n_intervals, 'rs--', linewidth=2, markersize=8, label='Number of intervals 2ⁿ')
    ax3.set_ylabel('Count', fontsize=12, color='red')
    ax3.legend(fontsize=10, loc='center right')

    plt.tight_layout()
    plt.savefig('viz_cantor.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_cantor.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Score Convergence Visualization

Shows geometric convergence of iterated scoring under contraction,
and the two-point contraction theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Convergence from different starting points
    kappa = 0.6
    x_star = 0.5 / (1 - kappa)  # fixed point of T(x) = κx + 0.5*(1-κ)
    update = lambda x: kappa * x + 0.5 * (1 - kappa)
    n_iter = 30

    starts = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
    colors = plt.cm.cool(np.linspace(0, 1, len(starts)))

    for x0, c in zip(starts, colors):
        traj = [x0]
        x = x0
        for _ in range(n_iter):
            x = update(x)
            traj.append(x)
        axes[0].plot(range(n_iter + 1), traj, '-o', color=c, markersize=3,
                    label=f'x₀ = {x0:.1f}')

    axes[0].axhline(y=x_star, color='red', linestyle='--', alpha=0.7,
                   label=f'x* = {x_star:.2f}')
    axes[0].set_xlabel('Iteration n', fontsize=11)
    axes[0].set_ylabel('Score', fontsize=11)
    axes[0].set_title(f'Contraction Convergence (κ = {kappa})', fontsize=12)
    axes[0].legend(fontsize=8, ncol=2)
    axes[0].set_ylim(-0.05, 1.05)

    # Panel 2: Error decay (log scale)
    for x0, c in zip(starts, colors):
        traj = [x0]
        x = x0
        for _ in range(n_iter):
            x = update(x)
            traj.append(x)
        errors = [abs(t - x_star) + 1e-16 for t in traj]
        axes[1].semilogy(range(n_iter + 1), errors, '-o', color=c,
                        markersize=3, label=f'x₀ = {x0:.1f}')

    # Theoretical bound
    bound = [kappa**n for n in range(n_iter + 1)]
    axes[1].semilogy(range(n_iter + 1), bound, 'k--', linewidth=2,
                    alpha=0.5, label=f'κⁿ = {kappa}ⁿ')
    axes[1].set_xlabel('Iteration n', fontsize=11)
    axes[1].set_ylabel('|xₙ - x*|', fontsize=11)
    axes[1].set_title('Geometric Error Decay', fontsize=12)
    axes[1].legend(fontsize=8, ncol=2)

    # Panel 3: Two-point gap contraction
    kappas = [0.3, 0.5, 0.7, 0.9]
    colors_k = plt.cm.autumn(np.linspace(0, 0.9, len(kappas)))

    for k, c in zip(kappas, colors_k):
        update_k = lambda x, k=k: k * x + 0.5 * (1 - k)
        x, y = 0.1, 0.9
        gaps = [abs(x - y)]
        for _ in range(n_iter):
            x = update_k(x)
            y = update_k(y)
            gaps.append(abs(x - y))
        axes[2].semilogy(range(n_iter + 1), gaps, '-o', color=c,
                        markersize=3, label=f'κ = {k}')

    axes[2].set_xlabel('Iteration n', fontsize=11)
    axes[2].set_ylabel('|xₙ - yₙ|', fontsize=11)
    axes[2].set_title('Two-Point Gap Contraction', fontsize=12)
    axes[2].legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_convergence.png")


if __name__ == "__main__":
    main()
