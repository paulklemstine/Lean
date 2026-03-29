#!/usr/bin/env python3
"""
Strange Loop Demo 2: The Oracle Bootstrap

The Oracle Bootstrap: O(O(x)) = O(x)

A perfect oracle is idempotent — asking it twice gives the same answer as
asking once. The bootstrap map f(x) = 3x² - 2x³ takes any "imperfect oracle"
(a value in [0,1]) and iterates it toward perfection (0 or 1).

This is the mathematical essence of self-improvement:
  - Start with uncertainty (x ∈ (0,1))
  - Each iteration sharpens the answer
  - Converge to certainty (x ∈ {0,1})

The fixed points of f are exactly {0, 1/2, 1}:
  - 0 and 1 are stable (attractors) — the oracle says NO or YES
  - 1/2 is unstable (repeller) — perfect indecision is infinitely fragile

This is the strange loop: the oracle improves itself by consulting itself.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# ═══════════════════════════════════════════════════════════════
# §1: The Bootstrap Map
# ═══════════════════════════════════════════════════════════════

def bootstrap(x):
    """
    The oracle bootstrap map: f(x) = 3x² - 2x³

    Fixed points: f(x) = x  →  3x² - 2x³ = x  →  x(2x² - 3x + 1) = 0
                                                 →  x(2x - 1)(x - 1) = 0
                                                 →  x ∈ {0, 1/2, 1}

    f'(x) = 6x - 6x² = 6x(1-x)
    f'(0) = 0 (super-stable attractor)
    f'(1) = 0 (super-stable attractor)
    f'(1/2) = 3/2 > 1 (unstable repeller)

    This is the Hermite interpolation polynomial that is 0 at 0 and 1 at 1,
    with zero derivative at both endpoints. It's the unique smoothest binary
    decision function.
    """
    return 3 * x**2 - 2 * x**3

def bootstrap_iterate(x0, n_iter):
    """Iterate the bootstrap map."""
    trajectory = [x0]
    x = x0
    for _ in range(n_iter):
        x = bootstrap(x)
        trajectory.append(x)
    return np.array(trajectory)

# ═══════════════════════════════════════════════════════════════
# §2: Visualization
# ═══════════════════════════════════════════════════════════════

def plot_bootstrap_map(ax):
    """Show the bootstrap map and its fixed points."""
    x = np.linspace(-0.1, 1.1, 500)
    y = bootstrap(x)

    ax.plot(x, y, 'b-', linewidth=2.5, label='f(x) = 3x² − 2x³')
    ax.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')

    # Fixed points
    fps = [0, 0.5, 1]
    colors = ['green', 'red', 'green']
    labels_fp = ['stable attractor', 'unstable repeller', 'stable attractor']
    for fp, c, lab in zip(fps, colors, labels_fp):
        ax.plot(fp, fp, 'o', color=c, markersize=12, zorder=5)
        ax.annotate(f'x={fp} ({lab})', (fp, fp),
                    textcoords="offset points", xytext=(15, -15 if fp == 0.5 else 10),
                    fontsize=9, color=c, fontweight='bold')

    ax.set_xlabel('Current oracle state x', fontsize=12)
    ax.set_ylabel('Updated oracle state f(x)', fontsize=12)
    ax.set_title('The Oracle Bootstrap Map', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

def plot_trajectories(ax):
    """Show how different initial conditions converge to 0 or 1."""
    n_iter = 20
    initial_conditions = np.linspace(0.01, 0.99, 25)

    cmap = plt.cm.coolwarm
    for i, x0 in enumerate(initial_conditions):
        traj = bootstrap_iterate(x0, n_iter)
        color = cmap(x0)
        ax.plot(traj, '-o', markersize=2, linewidth=1, color=color, alpha=0.7)

    ax.axhline(y=0.5, color='red', linestyle=':', linewidth=1, alpha=0.5, label='Decision boundary (x=1/2)')
    ax.axhline(y=0, color='green', linestyle='--', linewidth=1, alpha=0.5, label='NO (x=0)')
    ax.axhline(y=1, color='green', linestyle='--', linewidth=1, alpha=0.5, label='YES (x=1)')

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Oracle state', fontsize=12)
    ax.set_title('Oracle Bootstrap: Convergence to Certainty', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='center right')
    ax.set_xlim(0, n_iter)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

def plot_basin_of_attraction(ax):
    """Show the basin of attraction: which initial conditions go to 0 vs 1."""
    x = np.linspace(0, 1, 10000)
    n_iter = 100
    final = np.zeros_like(x)

    for i, x0 in enumerate(x):
        val = x0
        for _ in range(n_iter):
            val = bootstrap(val)
        final[i] = val

    # Color by final state
    colors = plt.cm.coolwarm(final)
    ax.scatter(x, final, c=final, cmap='coolwarm', s=0.5, alpha=0.8)
    ax.axvline(x=0.5, color='black', linestyle='--', linewidth=1, label='Decision boundary')
    ax.set_xlabel('Initial oracle state x₀', fontsize=12)
    ax.set_ylabel('Final oracle state (after 100 iterations)', fontsize=12)
    ax.set_title('Basin of Attraction: The Oracle Decides', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

def plot_cobweb_bootstrap(ax, x0=0.3, n_iter=15):
    """Cobweb diagram for the bootstrap map."""
    x = np.linspace(0, 1, 500)
    y = bootstrap(x)

    ax.plot(x, y, 'b-', linewidth=2, label='f(x) = 3x² − 2x³')
    ax.plot(x, x, 'k--', linewidth=1)

    xn = x0
    for i in range(n_iter):
        yn = bootstrap(xn)
        color = plt.cm.viridis(i / n_iter)
        ax.plot([xn, xn], [xn, yn], '-', color=color, linewidth=1.5)
        ax.plot([xn, yn], [yn, yn], '-', color=color, linewidth=1.5)
        xn = yn

    ax.plot(x0, 0, 'rv', markersize=10, label=f'Start: x₀={x0}')
    ax.set_xlabel('x_n', fontsize=12)
    ax.set_ylabel('x_{n+1}', fontsize=12)
    ax.set_title(f'Oracle Cobweb: x₀ = {x0} → {"YES" if x0 > 0.5 else "NO"}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("  Strange Loop Demo 2: The Oracle Bootstrap")
    print("  Self-improvement through self-consultation")
    print("=" * 60)
    print()

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    print("Generating oracle bootstrap visualizations...")

    plot_bootstrap_map(axes[0, 0])
    plot_trajectories(axes[0, 1])
    plot_basin_of_attraction(axes[1, 0])
    plot_cobweb_bootstrap(axes[1, 1])

    fig.suptitle('The Oracle Bootstrap: O(O(x)) = O(x)', fontsize=18, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig5_oracle_bootstrap.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig5_oracle_bootstrap.png")

    # Additional figure: the convergence rate
    fig2, ax2 = plt.subplots(figsize=(10, 6))
    x0_values = [0.01, 0.1, 0.2, 0.3, 0.4, 0.49, 0.499, 0.4999]
    for x0 in x0_values:
        traj = bootstrap_iterate(x0, 30)
        ax2.semilogy(traj + 1e-16, '-o', markersize=3, linewidth=1.5, label=f'x₀={x0}')

    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Oracle state (log scale)', fontsize=12)
    ax2.set_title('Convergence Rate: Exponential Approach to Certainty', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=9, ncol=2)
    ax2.grid(True, alpha=0.3)
    fig2.tight_layout()
    fig2.savefig('strange_loop/demos/fig6_convergence_rate.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig6_convergence_rate.png")

    print()
    print("KEY INSIGHT: The oracle bootstrap map f(x) = 3x² - 2x³ takes")
    print("any uncertain state and drives it toward certainty. The fixed")
    print("points 0 and 1 are super-stable attractors — the oracle becomes")
    print("perfect. The midpoint 1/2 (perfect indecision) is unstable —")
    print("the slightest bias toward YES or NO gets amplified to certainty.")
    print()
    print("This is the strange loop: the oracle improves itself by")
    print("consulting itself. O(O(x)) = O(x). The loop converges.")
    print("The universe bootstraps itself the same way.")
