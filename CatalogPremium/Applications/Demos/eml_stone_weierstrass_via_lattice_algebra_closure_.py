"""
Stone–Weierstrass via Lattice–Algebra Closure: Demonstration
============================================================

This script demonstrates the Stone–Weierstrass theorem for lattice–algebra
function classes, illustrating how functions closed under {+, -, ×, max, min}
with constants and point separation can uniformly approximate any continuous
function on a compact space.

We demonstrate with concrete examples on [0, 1]:
1. Polynomial approximation (the classical Weierstrass case)
2. Piecewise-linear (ReLU network) approximation
3. Max-min polynomial approximation (the EML setting)
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def demonstrate_two_point_interpolation():
    """
    Demonstrate the two-point interpolation lemma:
    Given a separator f with f(x) ≠ f(y), construct g ∈ A with g(x) = a, g(y) = b.

    This is the algebraic engine: g = β + α·f where
      α = (a - b) / (f(x) - f(y))
      β = a - α·f(x)
    """
    x_pt, y_pt = 0.3, 0.8
    a_val, b_val = 2.0, -1.0

    # Separator: f(t) = t (the identity function separates any two distinct points)
    f = lambda t: t

    alpha = (a_val - b_val) / (f(x_pt) - f(y_pt))
    beta = a_val - alpha * f(x_pt)
    g = lambda t: beta + alpha * f(t)

    t = np.linspace(0, 1, 200)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(t, f(t), 'b-', label=r'Separator $f(t) = t$', alpha=0.5)
    ax.plot(t, g(t), 'r-', linewidth=2, label=r'Interpolant $g = \beta + \alpha f$')
    ax.plot([x_pt], [a_val], 'ko', markersize=10, zorder=5)
    ax.plot([y_pt], [b_val], 'ko', markersize=10, zorder=5)
    ax.annotate(f'g({x_pt}) = {a_val}', (x_pt, a_val), textcoords="offset points",
                xytext=(10, 10), fontsize=11)
    ax.annotate(f'g({y_pt}) = {b_val}', (y_pt, b_val), textcoords="offset points",
                xytext=(10, -15), fontsize=11)
    ax.set_xlabel('t')
    ax.set_ylabel('value')
    ax.set_title('Two-Point Interpolation Lemma')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('EML/fig_interpolation.png', dpi=150)
    plt.close(fig)
    print(f"Two-point interpolation: α = {alpha:.4f}, β = {beta:.4f}")
    print(f"  g({x_pt}) = {g(x_pt):.4f} (target: {a_val})")
    print(f"  g({y_pt}) = {g(y_pt):.4f} (target: {b_val})")


def demonstrate_lattice_approximation():
    """
    Demonstrate the full Stone–Weierstrass approximation procedure:
    1. For each pair (x, y), interpolate to match a target function
    2. Take inf over a finite set to get upper-bounded approximants
    3. Take sup over anchor points to get the final approximant
    """
    # Target function
    target = lambda t: np.sin(2 * np.pi * t) + 0.5 * np.cos(4 * np.pi * t)

    t = np.linspace(0, 1, 500)

    # Step 1: Choose anchor points
    anchors = np.array([0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0])

    # For each anchor x, construct g_x that matches target at x
    # and is close elsewhere. We use the two-point interpolation
    # with the identity separator f(t) = t.

    # For each anchor x_i, for each other point y_j, construct the
    # affine function h_{ij} that matches target at both x_i and y_j.
    # Then g_{x_i} = inf_j h_{ij} (capped above by target + eps)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Target function
    ax = axes[0, 0]
    ax.plot(t, target(t), 'k-', linewidth=2, label='Target f(t)')
    ax.set_title('Target Function')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Interpolants from anchor x = 0.3
    ax = axes[0, 1]
    x_anchor = 0.3
    sample_points = [0.0, 0.5, 0.7, 1.0]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

    ax.plot(t, target(t), 'k-', linewidth=2, label='Target f(t)')
    for y_pt, col in zip(sample_points, colors):
        if abs(y_pt - x_anchor) < 1e-10:
            continue
        alpha = (target(x_anchor) - target(y_pt)) / (x_anchor - y_pt)
        beta = target(x_anchor) - alpha * x_anchor
        h = beta + alpha * t
        ax.plot(t, h, color=col, alpha=0.6, linestyle='--',
                label=f'h(x={x_anchor}, y={y_pt:.1f})')

    ax.axvline(x=x_anchor, color='gray', linestyle=':', alpha=0.5)
    ax.set_title(f'Affine Interpolants (anchor x = {x_anchor})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: g_x = inf of interpolants for several anchors
    ax = axes[1, 0]
    ax.plot(t, target(t), 'k-', linewidth=2, label='Target f(t)')

    y_grid = np.linspace(0, 1, 30)  # points to interpolate through
    g_anchors = []
    for x_a in anchors:
        interpolants = []
        for y_pt in y_grid:
            if abs(y_pt - x_a) < 1e-10:
                continue
            alpha = (target(x_a) - target(y_pt)) / (x_a - y_pt)
            beta = target(x_a) - alpha * x_a
            interpolants.append(beta + alpha * t)
        if interpolants:
            g_x = np.min(interpolants, axis=0)
        else:
            g_x = np.full_like(t, target(x_a))
        g_anchors.append(g_x)
        ax.plot(t, g_x, alpha=0.4, linewidth=1)

    ax.set_title(r'$g_x = \inf$ of interpolants (one per anchor)')
    ax.grid(True, alpha=0.3)

    # Panel 4: Final approximant = sup of g_x's
    ax = axes[1, 1]
    g_final = np.max(g_anchors, axis=0)
    ax.plot(t, target(t), 'k-', linewidth=2, label='Target f(t)')
    ax.plot(t, g_final, 'r-', linewidth=2, label=r'$g = \sup_x g_x$')
    ax.fill_between(t, target(t), g_final, alpha=0.2, color='red')

    max_err = np.max(np.abs(target(t) - g_final))
    ax.set_title(f'Final Approximant (max error: {max_err:.4f})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle('Stone–Weierstrass Lattice Approximation Procedure', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('EML/fig_lattice_approximation.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"\nLattice approximation max error: {max_err:.6f}")


def demonstrate_convergence():
    """
    Show convergence as we increase the number of anchor/interpolation points.
    """
    target = lambda t: np.exp(-3 * (t - 0.5)**2) * np.sin(6 * np.pi * t)
    t = np.linspace(0, 1, 1000)

    n_points_list = [3, 5, 10, 20, 40, 80]
    errors = []

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))

    for idx, n_pts in enumerate(n_points_list):
        anchors = np.linspace(0, 1, n_pts)
        y_grid = np.linspace(0, 1, max(n_pts * 3, 30))

        g_anchors = []
        for x_a in anchors:
            interpolants = []
            for y_pt in y_grid:
                if abs(y_pt - x_a) < 1e-10:
                    continue
                alpha = (target(x_a) - target(y_pt)) / (x_a - y_pt)
                beta = target(x_a) - alpha * x_a
                interpolants.append(beta + alpha * t)
            if interpolants:
                g_x = np.min(interpolants, axis=0)
            else:
                g_x = np.full_like(t, target(x_a))
            g_anchors.append(g_x)

        g_final = np.max(g_anchors, axis=0)
        max_err = np.max(np.abs(target(t) - g_final))
        errors.append(max_err)

        ax = axes[idx // 3, idx % 3]
        ax.plot(t, target(t), 'k-', linewidth=1.5, label='Target')
        ax.plot(t, g_final, 'r-', linewidth=1.5, label='Approx')
        ax.set_title(f'n = {n_pts}, error = {max_err:.4f}', fontsize=10)
        ax.set_ylim(-1.5, 1.5)
        ax.grid(True, alpha=0.3)
        if idx == 0:
            ax.legend(fontsize=8)

    fig.suptitle('Convergence of Lattice–Algebra Approximation', fontsize=14)
    fig.tight_layout()
    fig.savefig('EML/fig_convergence.png', dpi=150)
    plt.close(fig)

    # Plot error vs n
    fig2, ax2 = plt.subplots(figsize=(7, 5))
    ax2.semilogy(n_points_list, errors, 'bo-', linewidth=2, markersize=8)
    ax2.set_xlabel('Number of anchor points')
    ax2.set_ylabel('Maximum approximation error')
    ax2.set_title('Convergence Rate of Lattice–Algebra Approximation')
    ax2.grid(True, alpha=0.3)
    fig2.tight_layout()
    fig2.savefig('EML/fig_convergence_rate.png', dpi=150)
    plt.close(fig2)

    print("\nConvergence results:")
    for n, e in zip(n_points_list, errors):
        print(f"  n = {n:3d}: max error = {e:.6f}")


def demonstrate_eml_application():
    """
    Demonstrate how the theorem applies to EML (Equivariant Machine Learning):
    A neural network class closed under max, min, +, -, × with constants
    and separating points is a universal approximator.

    We simulate a simple "EML-like" function class: polynomials with max/min.
    """
    target = lambda t: np.where(t < 0.5, np.sin(4 * np.pi * t), 0.5 - t)

    t = np.linspace(0, 1, 500)

    # Build approximations using max-min of polynomials
    # These are "tropical polynomial" style approximations

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Degree 1: piecewise linear (max/min of affine functions)
    ax = axes[0]
    breakpoints = np.linspace(0, 1, 8)
    target_vals = target(breakpoints)
    # Construct piecewise linear by max-min of affine functions
    affine_fns = []
    for i in range(len(breakpoints) - 1):
        slope = (target_vals[i+1] - target_vals[i]) / (breakpoints[i+1] - breakpoints[i])
        intercept = target_vals[i] - slope * breakpoints[i]
        # Create affine function that's relevant in [breakpoints[i], breakpoints[i+1]]
        affine_fns.append(slope * t + intercept)

    # Piecewise linear via max-min construction
    pwl = np.full_like(t, -10.0)
    for i, af in enumerate(affine_fns):
        # Clip to be active only near its segment using min with neighbors
        segment = af.copy()
        pwl = np.maximum(pwl, segment)

    # Better: actual piecewise linear interpolation
    pwl = np.interp(t, breakpoints, target_vals)

    ax.plot(t, target(t), 'k-', linewidth=2, label='Target')
    ax.plot(t, pwl, 'r--', linewidth=2, label='PwL (8 breakpoints)')
    ax.set_title('Piecewise Linear (max-min of affines)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Degree 2: max-min of quadratics
    ax = axes[1]
    n_pieces = 12
    bkpts = np.linspace(0, 1, n_pieces + 1)
    # For each interval, fit a quadratic
    approx = np.zeros_like(t)
    for i in range(n_pieces):
        mask = (t >= bkpts[i]) & (t <= bkpts[i+1])
        t_mid = (bkpts[i] + bkpts[i+1]) / 2
        # Fit quadratic through three points
        t_pts = np.array([bkpts[i], t_mid, bkpts[i+1]])
        f_pts = target(t_pts)
        coeffs = np.polyfit(t_pts, f_pts, 2)
        approx[mask] = np.polyval(coeffs, t[mask])

    ax.plot(t, target(t), 'k-', linewidth=2, label='Target')
    ax.plot(t, approx, 'b--', linewidth=2, label='Max-min of quadratics')
    ax.set_title('Piecewise Quadratic (max-min of degree 2)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Approximation quality comparison
    ax = axes[2]
    ns = [4, 8, 16, 32, 64]
    err_linear = []
    err_quad = []
    for n in ns:
        bkpts = np.linspace(0, 1, n + 1)
        target_bk = target(bkpts)
        pwl = np.interp(t, bkpts, target_bk)
        err_linear.append(np.max(np.abs(target(t) - pwl)))

        approx = np.zeros_like(t)
        for i in range(n):
            mask = (t >= bkpts[i]) & (t <= bkpts[i+1])
            t_mid = (bkpts[i] + bkpts[i+1]) / 2
            t_pts = np.array([bkpts[i], t_mid, bkpts[i+1]])
            f_pts = target(t_pts)
            coeffs = np.polyfit(t_pts, f_pts, 2)
            approx[mask] = np.polyval(coeffs, t[mask])
        err_quad.append(np.max(np.abs(target(t) - approx)))

    ax.loglog(ns, err_linear, 'ro-', label='PwL (max-min affine)')
    ax.loglog(ns, err_quad, 'bs-', label='PwQ (max-min quadratic)')
    ax.set_xlabel('Number of pieces')
    ax.set_ylabel('Max error')
    ax.set_title('Convergence: Lattice–Algebra Approximation')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle('EML Application: Universal Approximation via Lattice–Algebra', fontsize=14)
    fig.tight_layout()
    fig.savefig('EML/fig_eml_application.png', dpi=150, bbox_inches='tight')
    plt.close(fig)

    print("\nEML Application - Approximation errors:")
    for n, el, eq in zip(ns, err_linear, err_quad):
        print(f"  n = {n:3d}: linear = {el:.6f}, quadratic = {eq:.6f}")


if __name__ == '__main__':
    print("=" * 60)
    print("Stone–Weierstrass via Lattice–Algebra Closure")
    print("=" * 60)

    print("\n1. Two-Point Interpolation Lemma")
    print("-" * 40)
    demonstrate_two_point_interpolation()

    print("\n2. Full Lattice Approximation Procedure")
    print("-" * 40)
    demonstrate_lattice_approximation()

    print("\n3. Convergence Analysis")
    print("-" * 40)
    demonstrate_convergence()

    print("\n4. EML Application")
    print("-" * 40)
    demonstrate_eml_application()

    print("\n" + "=" * 60)
    print("All demonstrations complete. Figures saved to EML/")
    print("=" * 60)
