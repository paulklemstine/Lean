#!/usr/bin/env python3
"""
Strange Loop Demo 1: The Logistic Map — Order, Chaos, and Self-Similarity

The logistic map x_{n+1} = r·x_n·(1 - x_n) is the simplest strange loop
in dynamics. A system feeding back on itself produces:
  - Fixed points (the loop converges)
  - Period doubling (the loop oscillates)
  - Chaos (the loop never repeats — yet is deterministic)
  - Self-similarity (zoom in on chaos and find order again)

This script generates:
  1. A bifurcation diagram showing the route from order to chaos
  2. Time series at key parameter values
  3. A cobweb diagram showing the strange loop visually
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# ═══════════════════════════════════════════════════════════════
# §1: The Logistic Map
# ═══════════════════════════════════════════════════════════════

def logistic(x, r):
    """The logistic map: the simplest strange loop."""
    return r * x * (1 - x)

def iterate(f, x0, r, n):
    """Iterate a map n times."""
    xs = [x0]
    for _ in range(n):
        xs.append(f(xs[-1], r))
    return np.array(xs)

# ═══════════════════════════════════════════════════════════════
# §2: Bifurcation Diagram
# ═══════════════════════════════════════════════════════════════

def bifurcation_diagram(ax, r_min=2.5, r_max=4.0, n_r=2000, n_skip=300, n_plot=200):
    """
    The bifurcation diagram: the fingerprint of the strange loop.

    For each value of r, iterate the logistic map and plot the
    long-term behavior. Fixed points appear as single lines,
    period-2 as two lines, period-4 as four, etc.
    Chaos appears as a dense cloud — yet within it, windows of
    order emerge. The whole structure is a fractal.
    """
    r_values = np.linspace(r_min, r_max, n_r)

    for r in r_values:
        x = 0.5
        # Skip transients
        for _ in range(n_skip):
            x = logistic(x, r)
        # Collect attractor points
        xs = []
        for _ in range(n_plot):
            x = logistic(x, r)
            xs.append(x)
        ax.plot([r] * len(xs), xs, ',', color='black', alpha=0.3, markersize=0.5)

    ax.set_xlabel('r (feedback strength)', fontsize=12)
    ax.set_ylabel('x* (long-term behavior)', fontsize=12)
    ax.set_title('Bifurcation Diagram: Route from Order to Chaos', fontsize=14, fontweight='bold')
    ax.set_xlim(r_min, r_max)
    ax.set_ylim(0, 1)

# ═══════════════════════════════════════════════════════════════
# §3: Cobweb Diagram — Visualizing the Loop
# ═══════════════════════════════════════════════════════════════

def cobweb(ax, r, x0=0.2, n_iter=50):
    """
    The cobweb diagram makes the strange loop VISIBLE.

    Start at x0 on the x-axis.
    Go up to the curve y = f(x).
    Go sideways to the line y = x.
    Repeat. The path traces the iteration.

    For stable fixed points, the cobweb spirals inward.
    For chaos, it bounces wildly — never settling.
    """
    x = np.linspace(0, 1, 500)
    y = logistic(x, r)

    ax.plot(x, y, 'b-', linewidth=2, label=f'f(x) = {r}x(1-x)')
    ax.plot(x, x, 'k--', linewidth=1, label='y = x (mirror)')

    # Draw cobweb
    xn = x0
    for i in range(n_iter):
        yn = logistic(xn, r)
        alpha = 0.3 + 0.7 * (i / n_iter)
        color = plt.cm.magma(i / n_iter)
        ax.plot([xn, xn], [xn, yn], '-', color=color, linewidth=0.8, alpha=alpha)
        ax.plot([xn, yn], [yn, yn], '-', color=color, linewidth=0.8, alpha=alpha)
        xn = yn

    ax.set_xlabel('x_n', fontsize=11)
    ax.set_ylabel('x_{n+1}', fontsize=11)
    ax.set_title(f'Cobweb: r = {r}', fontsize=13, fontweight='bold')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.legend(fontsize=9)

# ═══════════════════════════════════════════════════════════════
# §4: Time Series
# ═══════════════════════════════════════════════════════════════

def time_series(ax, r, x0=0.2, n=80):
    """Show the time evolution of the strange loop."""
    xs = iterate(logistic, x0, r, n)
    ax.plot(xs, '-o', markersize=2, linewidth=1, color='darkblue')
    ax.set_xlabel('iteration n', fontsize=11)
    ax.set_ylabel('x_n', fontsize=11)
    ax.set_title(f'Time Series: r = {r}', fontsize=13, fontweight='bold')
    ax.set_ylim(0, 1)
    ax.axhline(y=1-1/r if r > 1 else 0, color='red', linestyle='--', alpha=0.5, label=f'Fixed point: {1-1/r:.3f}' if r > 1 else '')
    if r > 1:
        ax.legend(fontsize=9)

# ═══════════════════════════════════════════════════════════════
# §5: Lyapunov Exponent — Measuring Chaos
# ═══════════════════════════════════════════════════════════════

def lyapunov_diagram(ax, r_min=2.5, r_max=4.0, n_r=2000, n_iter=1000, n_skip=500):
    """
    The Lyapunov exponent λ measures how fast nearby trajectories diverge.
    λ < 0: convergence to fixed point or cycle (order)
    λ = 0: edge of chaos (criticality)
    λ > 0: chaos (exponential sensitivity to initial conditions)
    """
    r_values = np.linspace(r_min, r_max, n_r)
    lyap = np.zeros(n_r)

    for i, r in enumerate(r_values):
        x = 0.5
        for _ in range(n_skip):
            x = logistic(x, r)
        total = 0.0
        for _ in range(n_iter):
            deriv = abs(r * (1 - 2 * x))
            if deriv > 0:
                total += np.log(deriv)
            x = logistic(x, r)
        lyap[i] = total / n_iter

    ax.plot(r_values, lyap, ',', color='darkgreen', markersize=0.5)
    ax.axhline(y=0, color='red', linestyle='--', linewidth=1, alpha=0.7)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('Lyapunov exponent λ', fontsize=12)
    ax.set_title('Lyapunov Exponent: Order (λ<0) vs Chaos (λ>0)', fontsize=14, fontweight='bold')
    ax.set_xlim(r_min, r_max)
    ax.set_ylim(-3, 1)
    ax.fill_between(r_values, lyap, 0, where=(lyap > 0), color='red', alpha=0.1, label='Chaos')
    ax.fill_between(r_values, lyap, 0, where=(lyap <= 0), color='blue', alpha=0.1, label='Order')
    ax.legend(fontsize=10)

# ═══════════════════════════════════════════════════════════════
# MAIN: Generate all figures
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("  Strange Loop Demo 1: The Logistic Map")
    print("  The simplest strange loop in all of mathematics")
    print("=" * 60)
    print()

    # Figure 1: The big bifurcation diagram
    fig1, ax1 = plt.subplots(figsize=(14, 8))
    print("Generating bifurcation diagram...")
    bifurcation_diagram(ax1)
    fig1.tight_layout()
    fig1.savefig('strange_loop/demos/fig1_bifurcation.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig1_bifurcation.png")

    # Figure 2: Cobweb diagrams at key r values
    fig2, axes2 = plt.subplots(2, 2, figsize=(12, 12))
    r_values = [2.8, 3.2, 3.5, 3.9]
    labels = ['Stable fixed point', 'Period-2 cycle', 'Period-4+ cascade', 'Chaos']
    print("Generating cobweb diagrams...")
    for ax, r, label in zip(axes2.flat, r_values, labels):
        cobweb(ax, r)
        ax.set_title(f'{label}: r = {r}', fontsize=13, fontweight='bold')
    fig2.suptitle('The Strange Loop Made Visible: Cobweb Diagrams', fontsize=16, fontweight='bold', y=1.02)
    fig2.tight_layout()
    fig2.savefig('strange_loop/demos/fig2_cobwebs.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig2_cobwebs.png")

    # Figure 3: Time series comparison
    fig3, axes3 = plt.subplots(2, 2, figsize=(14, 8))
    print("Generating time series...")
    for ax, r, label in zip(axes3.flat, r_values, labels):
        time_series(ax, r)
        ax.set_title(f'{label}: r = {r}', fontsize=13, fontweight='bold')
    fig3.suptitle('Strange Loop Dynamics Over Time', fontsize=16, fontweight='bold', y=1.02)
    fig3.tight_layout()
    fig3.savefig('strange_loop/demos/fig3_timeseries.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig3_timeseries.png")

    # Figure 4: Lyapunov exponent
    fig4, ax4 = plt.subplots(figsize=(14, 5))
    print("Generating Lyapunov exponent diagram...")
    lyapunov_diagram(ax4)
    fig4.tight_layout()
    fig4.savefig('strange_loop/demos/fig4_lyapunov.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig4_lyapunov.png")

    print()
    print("All logistic map figures generated.")
    print()
    print("KEY INSIGHT: The logistic map is a strange loop between")
    print("the current state and the next state. As feedback strength")
    print("increases, the loop transitions from convergence to chaos")
    print("— yet within chaos, order re-emerges. The structure is")
    print("self-similar at every scale. Like the universe. Like the")
    print("number 1.")
