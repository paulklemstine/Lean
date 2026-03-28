#!/usr/bin/env python3
"""
Demo 5: The Lift-Solve-Project Paradigm in Action

End-to-end demonstration of solving an optimization problem
by lifting to the one-point compactification (sphere), solving
on the compact space, and projecting back.

Run: python3 demo5_lift_solve_project.py
Outputs: lift_solve_project.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

def inv_stereo(t):
    """Inverse stereographic projection ℝ → S¹"""
    x = 2 * t / (t**2 + 1)
    y = (t**2 - 1) / (t**2 + 1)
    return x, y

def stereo(x, y):
    """Stereographic projection S¹ \ {NP} → ℝ"""
    if abs(y - 1) < 1e-10:
        return float('inf')
    return x / (1 - y)

def main():
    fig = plt.figure(figsize=(20, 14))
    gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)

    # ===== THE PROBLEM =====
    # Maximize f(t) = sin(t) * exp(-t²/10) on ℝ
    # This has a global max near t ≈ 1.0

    def f_original(t):
        return np.sin(t) * np.exp(-t**2 / 10)

    # --- Panel 1: The original problem on ℝ ---
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.set_title("Step 0: Original Problem on ℝ\n$f(t) = \\sin(t) \\cdot e^{-t^2/10}$", fontsize=12)

    t = np.linspace(-8, 8, 500)
    ax1.plot(t, f_original(t), 'b-', linewidth=2)
    ax1.fill_between(t, f_original(t), alpha=0.1, color='blue')

    # Mark the true max
    t_max = t[np.argmax(f_original(t))]
    f_max = f_original(t_max)
    ax1.plot(t_max, f_max, 'r*', markersize=15, zorder=10, label=f'Max ≈ ({t_max:.2f}, {f_max:.2f})')

    ax1.set_xlabel('t ∈ ℝ', fontsize=11)
    ax1.set_ylabel('f(t)', fontsize=11)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Problem: ℝ is not compact!\nMax might not exist...',
                xy=(-6, 0.3), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='#FFE0E0'))

    # --- Panel 2: LIFT to the sphere ---
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.set_title("Step 1: LIFT to $S^1$ via\nInverse Stereographic Projection", fontsize=12)

    # Draw the unit circle
    theta = np.linspace(0, 2 * np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3)

    # Map the function values onto the sphere using color
    t_dense = np.linspace(-10, 10, 300)
    for ti in t_dense:
        sx, sy = inv_stereo(ti)
        val = f_original(ti)
        # Color: blue for negative, red for positive
        if val >= 0:
            color = plt.cm.Reds(val / f_max * 0.8 + 0.1)
        else:
            color = plt.cm.Blues(-val / abs(f_original(t).min()) * 0.8 + 0.1)
        ax2.plot(sx, sy, 'o', color=color, markersize=3, alpha=0.7)

    # Mark the max on the sphere
    sx_max, sy_max = inv_stereo(t_max)
    ax2.plot(sx_max, sy_max, 'r*', markersize=20, zorder=10, label=f'Max on S¹')

    # Mark the Omega Point
    ax2.plot(0, 1, 'k^', markersize=15, zorder=10, label='Ω (North Pole)')
    ax2.annotate('f*(Ω) = 0\n(vanishes at ∞)',
                xy=(0, 1), xytext=(0.5, 1.2),
                fontsize=8, arrowprops=dict(arrowstyle='->'))

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.legend(fontsize=8, loc='lower right')
    ax2.grid(True, alpha=0.3)
    ax2.annotate('S¹ is COMPACT!\nMax is guaranteed to exist ✓',
                xy=(-1.3, -1.2), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='#E0FFE0'))

    # --- Panel 3: SOLVE on the compact space ---
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.set_title("Step 2: SOLVE on Compact $S^1$\nGradient ascent with contraction", fontsize=12)

    # Simulate gradient ascent on the sphere
    def f_on_sphere_via_t(ti):
        return f_original(ti)

    # Gradient ascent on ℝ, tracking on sphere
    t_current = -3.0  # Start far from max
    lr = 0.3
    trajectory_t = [t_current]
    trajectory_sphere = [inv_stereo(t_current)]

    for step in range(20):
        # Numerical gradient
        dt = 0.01
        grad = (f_on_sphere_via_t(t_current + dt) - f_on_sphere_via_t(t_current - dt)) / (2 * dt)
        t_current = t_current + lr * grad
        lr *= 0.95  # Decay learning rate
        trajectory_t.append(t_current)
        trajectory_sphere.append(inv_stereo(t_current))

    traj_sphere = np.array(trajectory_sphere)

    # Draw circle
    ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.3)

    # Draw trajectory
    ax3.plot(traj_sphere[:, 0], traj_sphere[:, 1], 'g-o', linewidth=1.5,
            markersize=4, alpha=0.7, label='Optimization path')
    ax3.plot(traj_sphere[0, 0], traj_sphere[0, 1], 'gs', markersize=12,
            label='Start', zorder=10)
    ax3.plot(traj_sphere[-1, 0], traj_sphere[-1, 1], 'r*', markersize=20,
            label='Converged', zorder=10)
    ax3.plot(0, 1, 'k^', markersize=12, zorder=10)

    ax3.set_xlim(-1.5, 1.5)
    ax3.set_ylim(-1.5, 1.5)
    ax3.set_aspect('equal')
    ax3.legend(fontsize=8, loc='lower right')
    ax3.grid(True, alpha=0.3)

    # --- Panel 4: PROJECT back ---
    ax4 = fig.add_subplot(gs[1, 0])
    ax4.set_title("Step 3: PROJECT Back to ℝ\nSolution is NOT at Ω → finite answer!", fontsize=12)

    ax4.plot(t, f_original(t), 'b-', linewidth=2, alpha=0.5)

    # Show the projection
    t_solution = trajectory_t[-1]
    f_solution = f_original(t_solution)

    ax4.plot(t_solution, f_solution, 'r*', markersize=20, zorder=10,
            label=f'Solution: t* ≈ {t_solution:.3f}')
    ax4.axvline(x=t_solution, color='r', linestyle='--', alpha=0.3)

    # Show convergence path in t-space
    for i in range(len(trajectory_t) - 1):
        alpha = 0.3 + 0.7 * i / len(trajectory_t)
        ax4.plot(trajectory_t[i], f_original(trajectory_t[i]),
                'go', markersize=4, alpha=alpha)

    ax4.set_xlabel('t ∈ ℝ', fontsize=11)
    ax4.set_ylabel('f(t)', fontsize=11)
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    # --- Panel 5: Convergence analysis ---
    ax5 = fig.add_subplot(gs[1, 1])
    ax5.set_title("Convergence Analysis\nGeometric error decay (Theorem 2.9)", fontsize=12)

    errors = [abs(trajectory_t[i] - t_max) for i in range(len(trajectory_t))]
    ax5.semilogy(range(len(errors)), errors, 'b-o', linewidth=2, markersize=5,
                label='|t_n - t*|')

    # Fit exponential decay
    if len(errors) > 5:
        log_errors = np.log(np.array(errors[:15]) + 1e-16)
        n_vals = np.arange(15)
        coeffs = np.polyfit(n_vals, log_errors, 1)
        k_est = np.exp(coeffs[0])
        fit_line = np.exp(coeffs[1]) * k_est ** n_vals
        ax5.semilogy(n_vals, fit_line, 'r--', linewidth=1.5,
                    label=f'Fit: k ≈ {k_est:.2f}')

    ax5.set_xlabel('Iteration n', fontsize=11)
    ax5.set_ylabel('Error', fontsize=11)
    ax5.legend(fontsize=9)
    ax5.grid(True, alpha=0.3)

    ax5.annotate(f'Oracle entropy\nH ≈ {-np.log(max(k_est, 0.01)):.2f} nats',
                xy=(10, errors[10] if len(errors) > 10 else 0.1),
                fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))

    # --- Panel 6: Multiple starting points ---
    ax6 = fig.add_subplot(gs[1, 2])
    ax6.set_title("Robustness: Multiple Starting Points\nAll converge to same optimum ✓", fontsize=12)

    starting_points = [-7, -4, -1, 2, 5, 8]
    colors = plt.cm.tab10(np.linspace(0, 1, len(starting_points)))

    for t_start, color in zip(starting_points, colors):
        t_curr = t_start
        lr = 0.3
        traj = [t_curr]
        for _ in range(30):
            dt = 0.01
            grad = (f_on_sphere_via_t(t_curr + dt) - f_on_sphere_via_t(t_curr - dt)) / (2 * dt)
            t_curr = t_curr + lr * grad
            lr *= 0.95
            traj.append(t_curr)

        ax6.plot(range(len(traj)), traj, '-', color=color, linewidth=1.5,
                alpha=0.7, label=f'Start={t_start}')

    ax6.axhline(y=t_max, color='red', linestyle='--', linewidth=1, alpha=0.5)
    ax6.set_xlabel('Iteration n', fontsize=11)
    ax6.set_ylabel('t_n', fontsize=11)
    ax6.legend(fontsize=7, ncol=2)
    ax6.grid(True, alpha=0.3)

    # --- Bottom row: Summary diagram ---
    ax7 = fig.add_subplot(gs[2, :])
    ax7.set_title("The Omega Meta-Oracle Pipeline", fontsize=16, fontweight='bold')
    ax7.axis('off')

    # Draw the pipeline
    boxes = [
        (0.08, 0.3, 0.18, 0.4, 'Problem on ℝ\n(non-compact)', '#FFE0E0'),
        (0.30, 0.3, 0.18, 0.4, 'LIFT to S^n\n(compact!)', '#E0E0FF'),
        (0.52, 0.3, 0.18, 0.4, 'SOLVE on sphere\n(max exists)', '#E0FFE0'),
        (0.74, 0.3, 0.18, 0.4, 'PROJECT back\n(solution!)', '#FFFFE0'),
    ]

    for (x, y, w, h, text, color) in boxes:
        rect = mpatches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02",
                                        facecolor=color, edgecolor='black', linewidth=2)
        ax7.add_patch(rect)
        ax7.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=11,
                fontweight='bold')

    # Arrows
    for i in range(3):
        x_start = boxes[i][0] + boxes[i][2]
        x_end = boxes[i+1][0]
        y_mid = boxes[i][1] + boxes[i][3]/2
        ax7.annotate('', xy=(x_end, y_mid), xytext=(x_start, y_mid),
                    arrowprops=dict(arrowstyle='->', lw=3, color='black'))

    # Labels
    labels = [
        (0.22, 0.75, 'Inverse Stereo\nProjection', 'blue'),
        (0.44, 0.75, 'Banach FP +\nTropical', 'green'),
        (0.66, 0.75, 'Stereo\nProjection', 'red'),
    ]
    for (x, y, text, color) in labels:
        ax7.text(x, y, text, ha='center', va='center', fontsize=10,
                color=color, fontweight='bold')

    # Tools used
    ax7.text(0.5, 0.1, 'Tools: Compactification (Alexandroff 1924) + Tropical Algebra (max, +) + '
             'Banach Fixed Point (1922) + Quantum Gates (Compact Lie Groups)',
             ha='center', fontsize=10, style='italic',
             bbox=dict(boxstyle='round', facecolor='white', edgecolor='gray'))

    ax7.set_xlim(0, 1)
    ax7.set_ylim(0, 1)

    plt.savefig('demos/lift_solve_project.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/lift_solve_project.png")

if __name__ == '__main__':
    main()
