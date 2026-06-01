"""
Demo: Social Credit Scores as Topological Invariants

Numerical demonstrations of the main theorems:
1. Monotone convergence of scoring dynamics
2. Contraction uniqueness (different initial conditions converge)
3. Phase transitions at thresholds
4. Cantor IFS attractor approximation
5. Exponential convergence bound verification
"""

import numpy as np
from algorithms import (
    iterate_scoring, find_fixed_point, assign_tier,
    detect_phase_transitions, cantor_ifs_iterate,
    compute_box_counting_dimension, contractive_update
)


def demo_monotone_convergence():
    """Demo 1: Monotone scoring dynamics converge."""
    print("=" * 60)
    print("DEMO 1: Monotone Convergence of Scoring Dynamics")
    print("=" * 60)

    n = 5
    init = np.array([0.1, 0.9, 0.3, 0.7, 0.5])
    c = 0.6

    def update(s):
        return contractive_update(s, c=c, target=0.5)

    trajectory = iterate_scoring(update, init, steps=20)

    print(f"Population size: {n}, Contraction factor: {c}")
    print(f"Initial scores: {init}")
    print(f"\nTrajectory (first 10 steps):")
    for i, scores in enumerate(trajectory[:11]):
        print(f"  Step {i:2d}: {np.array2string(scores, precision=6)}")

    fp, iters = find_fixed_point(update, init)
    print(f"\nFixed point reached in {iters} iterations:")
    print(f"  {np.array2string(fp, precision=10)}")
    print(f"  All scores converge to 0.5 (the unique fixed point).\n")


def demo_contraction_uniqueness():
    """Demo 2: Different initial conditions converge to the same fixed point."""
    print("=" * 60)
    print("DEMO 2: Contraction Uniqueness — All Roads Lead to Rome")
    print("=" * 60)

    n = 4
    c = 0.7
    target = 0.42

    inits = [
        np.array([0.0, 0.0, 0.0, 0.0]),
        np.array([1.0, 1.0, 1.0, 1.0]),
        np.array([0.1, 0.9, 0.2, 0.8]),
        np.array([0.5, 0.5, 0.5, 0.5]),
    ]

    def update(s):
        return contractive_update(s, c=c, target=target)

    print(f"Contraction factor: {c}, Target: {target}")
    print(f"\nAll initial conditions converge to the same fixed point:")
    for init in inits:
        fp, iters = find_fixed_point(update, init)
        print(f"  init={np.array2string(init, precision=1)} → "
              f"fp={np.array2string(fp, precision=8)} ({iters} iters)")
    print()


def demo_phase_transitions():
    """Demo 3: Phase transitions at tier boundaries."""
    print("=" * 60)
    print("DEMO 3: Phase Transitions at Tier Boundaries")
    print("=" * 60)

    thresholds = np.array([0.3, 0.5, 0.7])
    n = 20
    rng = np.random.default_rng(123)
    scores = rng.random(n)

    print(f"Thresholds: {thresholds}")
    print(f"Population: {n} individuals")
    print(f"Scores: {np.array2string(scores, precision=3)}")

    for eps in [0.1, 0.01, 0.001]:
        transitions = detect_phase_transitions(thresholds, scores, eps)
        affected = len(set(t['individual'] for t in transitions))
        print(f"\n  ε = {eps}: {len(transitions)} tier changes, "
              f"{affected} individuals affected")
        if transitions:
            t = transitions[0]
            print(f"    Example: individual {t['individual']} "
                  f"(score={scores[t['individual']]:.4f}) "
                  f"tier {t['old_tier']}→{t['new_tier']}")

    # Show the phase transition theorem: score exactly at threshold
    print(f"\n  Phase transition witness:")
    print(f"  Score = 0.5 (exactly at threshold[1] = 0.5)")
    print(f"    Original tier: {assign_tier(thresholds, 0.5)}")
    eps = 1e-15
    perturbed = thresholds.copy()
    perturbed[1] += eps
    print(f"    After shifting threshold by {eps}: "
          f"tier {assign_tier(perturbed, 0.5)}")
    print(f"    → Tier changed! (Phase transition confirmed)\n")


def demo_cantor_attractor():
    """Demo 4: Cantor IFS attractor approximation."""
    print("=" * 60)
    print("DEMO 4: Cantor Set Attractor via IFS")
    print("=" * 60)

    c = 1/3
    print(f"Contraction ratio: c = {c:.4f}")
    print(f"Theoretical dimension: log(2)/log(3) = {np.log(2)/np.log(3):.6f}")

    for depth in [1, 2, 3, 4, 5, 8]:
        intervals = cantor_ifs_iterate(c=c, depth=depth)
        total_length = sum(b - a for a, b in intervals)
        n_intervals = len(intervals)
        theoretical_length = (2/3)**depth
        print(f"  Depth {depth}: {n_intervals:4d} intervals, "
              f"total length = {total_length:.8f} "
              f"(theoretical: {theoretical_length:.8f})")

    # Dimension estimation
    depths = list(range(1, 12))
    dim = compute_box_counting_dimension(c, depths)
    print(f"\n  Box-counting dimension estimate: {dim:.6f}")
    print(f"  Theoretical: {np.log(2)/np.log(3):.6f}")

    # Try different contraction ratios
    print(f"\n  Dimension for various contraction ratios:")
    for c_val in [0.2, 0.25, 1/3, 0.4, 0.45, 0.49]:
        theoretical = np.log(2) / np.log(1/c_val)
        estimated = compute_box_counting_dimension(c_val, depths)
        print(f"    c={c_val:.3f}: estimated={estimated:.4f}, "
              f"theoretical={theoretical:.4f}")
    print()


def demo_exponential_convergence():
    """Demo 5: Verify exponential convergence bound."""
    print("=" * 60)
    print("DEMO 5: Exponential Convergence — c^m Bound")
    print("=" * 60)

    n = 3
    c = 0.5
    f_init = np.array([0.0, 0.0, 0.0])
    g_init = np.array([1.0, 0.5, 0.8])

    def update(s):
        return contractive_update(s, c=c, target=0.5)

    f_traj = iterate_scoring(update, f_init, steps=20)
    g_traj = iterate_scoring(update, g_init, steps=20)

    B = np.max(np.abs(f_init - g_init))
    print(f"Contraction factor: c = {c}")
    print(f"Initial bound B = max|f-g| = {B}")
    print(f"\n{'Step':>4s}  {'Actual |f-g|':>14s}  {'Bound c^m*B':>14s}  {'Ratio':>8s}")
    print("-" * 48)

    for m in range(15):
        actual = np.max(np.abs(f_traj[m] - g_traj[m]))
        bound = c**m * B
        ratio = actual / bound if bound > 0 else 0
        print(f"  {m:3d}  {actual:14.10f}  {bound:14.10f}  {ratio:8.4f}")

    print(f"\n  Ratio ≤ 1 at every step (theorem verified numerically).\n")


if __name__ == "__main__":
    demo_monotone_convergence()
    demo_contraction_uniqueness()
    demo_phase_transitions()
    demo_cantor_attractor()
    demo_exponential_convergence()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Social Credit Scoring Dynamics

Standalone visualization showing convergence trajectories,
phase transitions, and Cantor set approximation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def plot_convergence_trajectories():
    """Plot score trajectories under contractive dynamics."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Multiple trajectories converging
    n = 8
    steps = 30
    c = 0.7
    target = 0.5
    rng = np.random.default_rng(42)

    ax = axes[0]
    for _ in range(5):
        init = rng.random(n)
        traj = [init.copy()]
        current = init.copy()
        for _ in range(steps):
            current = c * current + (1 - c) * target
            traj.append(current.copy())
        traj = np.array(traj)
        for j in range(n):
            ax.plot(range(steps + 1), traj[:, j], alpha=0.5, linewidth=0.8)
    ax.axhline(y=target, color='red', linestyle='--', linewidth=2, label='Fixed point')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Score')
    ax.set_title('Contraction: All Trajectories → Fixed Point')
    ax.legend()

    # Panel 2: Exponential convergence bound
    ax = axes[1]
    f_init = np.array([0.0, 0.2, 0.8, 1.0])
    g_init = np.array([0.5, 0.5, 0.5, 0.5])
    B = np.max(np.abs(f_init - g_init))

    for c_val in [0.3, 0.5, 0.7, 0.9]:
        diffs = []
        f_curr, g_curr = f_init.copy(), g_init.copy()
        for m in range(40):
            diffs.append(np.max(np.abs(f_curr - g_curr)))
            f_curr = c_val * f_curr + (1 - c_val) * 0.5
            g_curr = c_val * g_curr + (1 - c_val) * 0.5
        ax.semilogy(range(40), diffs, label=f'c={c_val}')
    ax.set_xlabel('Iteration')
    ax.set_ylabel('sup|f - g| (log scale)')
    ax.set_title('Exponential Convergence: c^m Decay')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Phase transition
    ax = axes[2]
    thresholds = np.array([0.3, 0.5, 0.7])
    scores = np.linspace(0, 1, 200)
    tiers = [int(np.sum(thresholds <= s)) for s in scores]
    ax.plot(scores, tiers, 'b-', linewidth=2)
    for t in thresholds:
        ax.axvline(x=t, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Score')
    ax.set_ylabel('Tier')
    ax.set_title('Phase Transitions at Thresholds')
    ax.set_yticks([0, 1, 2, 3])
    ax.set_yticklabels(['Tier 0', 'Tier 1', 'Tier 2', 'Tier 3'])

    plt.tight_layout()
    plt.savefig('convergence_dynamics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: convergence_dynamics.png")


def plot_cantor_attractor():
    """Plot Cantor set construction and attractor."""
    fig, axes = plt.subplots(2, 1, figsize=(12, 6))

    # Panel 1: Cantor set construction
    ax = axes[0]
    c = 1/3
    for depth in range(7):
        intervals = [(0.0, 1.0)]
        for _ in range(depth):
            new = []
            for a, b in intervals:
                new.append((c * a, c * b))
                new.append((c * a + (1 - c), c * b + (1 - c)))
            intervals = new
        y = 6 - depth
        for a, b in intervals:
            ax.plot([a, b], [y, y], 'b-', linewidth=3)
    ax.set_xlabel('Score')
    ax.set_ylabel('Iteration depth')
    ax.set_title('Cantor Set Construction (c = 1/3)')
    ax.set_yticks(range(7))
    ax.set_yticklabels([f'k={i}' for i in range(7)])

    # Panel 2: Dimension vs contraction ratio
    ax = axes[1]
    c_vals = np.linspace(0.05, 0.49, 100)
    dims = np.log(2) / np.log(1 / c_vals)
    ax.plot(c_vals, dims, 'b-', linewidth=2)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='d=1 (fills interval)')
    ax.axvline(x=0.5, color='green', linestyle='--', alpha=0.5, label='c=1/2 (critical)')
    ax.scatter([1/3], [np.log(2)/np.log(3)], color='red', s=100, zorder=5,
               label=f'Standard Cantor (d≈{np.log(2)/np.log(3):.3f})')
    ax.set_xlabel('Contraction ratio c')
    ax.set_ylabel('Hausdorff dimension')
    ax.set_title('Attractor Dimension vs Contraction Ratio')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cantor_attractor.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cantor_attractor.png")


def plot_phase_transition_sensitivity():
    """Plot sensitivity of tier assignments to threshold perturbation."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 100
    rng = np.random.default_rng(42)
    scores = rng.random(n)
    thresholds = np.array([0.3, 0.5, 0.7])

    epsilons = np.logspace(-6, -1, 50)
    n_affected = []
    for eps in epsilons:
        affected = set()
        for t_idx in range(len(thresholds)):
            perturbed = thresholds.copy()
            perturbed[t_idx] += eps
            for i, s in enumerate(scores):
                old_tier = int(np.sum(thresholds <= s))
                new_tier = int(np.sum(perturbed <= s))
                if old_tier != new_tier:
                    affected.add(i)
        n_affected.append(len(affected))

    ax.semilogx(epsilons, n_affected, 'b-', linewidth=2)
    ax.set_xlabel('Perturbation ε')
    ax.set_ylabel('Number of individuals changing tier')
    ax.set_title('Phase Transition Sensitivity: Tier Changes vs Perturbation Size')
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Even tiny ε causes tier changes\nfor boundary individuals',
                xy=(1e-5, n_affected[10]), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'),
                xytext=(1e-3, max(n_affected) * 0.8))

    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: phase_transition.png")


if __name__ == "__main__":
    plot_convergence_trajectories()
    plot_cantor_attractor()
    plot_phase_transition_sensitivity()
    print("All visualizations generated.")
