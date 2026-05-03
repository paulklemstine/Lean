#!/usr/bin/env python3
"""
Stone–Weierstrass for Vector Lattices: Interactive Demo
========================================================

This script demonstrates the Kakutani–Stone lattice version of the Stone–Weierstrass
theorem: any set of continuous functions on a compact space that is closed under
addition, scalar multiplication, constants, max, and min, and that separates points,
is uniformly dense in C(X, ℝ).

Key insight: you do NOT need multiplication closure (as in the classical algebraic
Stone–Weierstrass). Affine + lattice operations suffice.

We demonstrate:
1. Construction of piecewise-linear (max-plus-affine) approximations
2. The two-point interpolation lemma
3. The inf-patching and sup-patching steps of the proof
4. Convergence in sup norm
5. Comparison with polynomial (algebraic) approximation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# ============================================================================
# SECTION 1: The function class — max-plus-affine functions
# ============================================================================

def affine(a, b):
    """Return the affine function x ↦ ax + b."""
    return lambda x: a * x + b

def pointwise_max(*funcs):
    """Pointwise maximum of functions."""
    return lambda x: np.maximum.reduce([f(x) for f in funcs])

def pointwise_min(*funcs):
    """Pointwise minimum of functions."""
    return lambda x: np.minimum.reduce([f(x) for f in funcs])

def scalar_mul(c, f):
    """Scalar multiplication: c · f."""
    return lambda x: c * f(x)

def func_add(f, g):
    """Addition: f + g."""
    return lambda x: f(x) + g(x)

def const(c):
    """Constant function."""
    return lambda x: np.full_like(x, c, dtype=float)


# ============================================================================
# SECTION 2: Two-point interpolation
# ============================================================================

def two_point_interpolation(x1, y1, x2, y2):
    """
    Given two distinct points (x1, y1) and (x2, y2),
    return the unique affine function passing through them.

    This is the constructive content of eml_exists_eq_at_two_points:
    from a separating function (here, the identity x ↦ x), build
    an affine function matching prescribed values at two points.
    """
    if abs(x2 - x1) < 1e-15:
        raise ValueError("Points must be distinct")
    slope = (y2 - y1) / (x2 - x1)
    intercept = y1 - slope * x1
    return affine(slope, intercept)


# ============================================================================
# SECTION 3: The lattice patching algorithm
# ============================================================================

def lattice_approximate(target_func, domain, epsilon, n_sample=50):
    """
    Approximate target_func on domain = [a, b] to within epsilon in sup norm,
    using only affine functions, max, and min.

    This implements the Kakutani–Stone proof constructively:

    Step 1 (inf-patching): For each anchor point x_i, build F_{x_i} by:
      - For each sample point y_j, create the affine function u_{ij}
        passing through (x_i, g(x_i)) and (y_j, g(y_j)).
      - Take F_{x_i} = min over j of u_{ij}.
      - F_{x_i}(x_i) ≈ g(x_i) and F_{x_i} ≤ g + ε globally.

    Step 2 (sup-patching): Take F = max over i of F_{x_i}.
      - For each z, some x_i is close to z, so F_{x_i}(z) ≈ g(z).
      - Hence F ≈ g uniformly.

    Returns (approx_func, error, anchor_points, all_intermediates)
    """
    a, b = domain
    xs = np.linspace(a, b, n_sample)
    g_vals = target_func(xs)

    intermediates = []

    for i in range(n_sample):
        x_i = xs[i]
        g_xi = g_vals[i]

        u_list = []
        for j in range(n_sample):
            if i == j:
                continue
            x_j = xs[j]
            g_xj = g_vals[j]
            u_ij = two_point_interpolation(x_i, g_xi, x_j, g_xj)
            u_list.append(u_ij)

        if u_list:
            F_xi = pointwise_min(*u_list)
        else:
            F_xi = const(g_xi)

        intermediates.append(F_xi)

    approx = pointwise_max(*intermediates)

    fine_xs = np.linspace(a, b, 1000)
    error = np.max(np.abs(approx(fine_xs) - target_func(fine_xs)))

    return approx, error, xs, intermediates


# ============================================================================
# SECTION 4: Demonstrations
# ============================================================================

def demo_two_point_interpolation():
    """Demonstrate the two-point interpolation lemma."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    target = lambda x: np.sin(2 * np.pi * x)
    xs = np.linspace(0, 1, 500)

    point_pairs = [
        (0.2, 0.8, "Points at x=0.2, x=0.8"),
        (0.1, 0.5, "Points at x=0.1, x=0.5"),
        (0.3, 0.9, "Points at x=0.3, x=0.9"),
    ]

    for ax, (x1, x2, title) in zip(axes, point_pairs):
        y1 = target(np.array([x1]))[0]
        y2 = target(np.array([x2]))[0]

        interp = two_point_interpolation(x1, y1, x2, y2)

        ax.plot(xs, target(xs), 'b-', linewidth=2, label='Target: sin(2πx)')
        ax.plot(xs, interp(xs), 'r--', linewidth=1.5, label='Affine interpolant')
        ax.plot([x1, x2], [y1, y2], 'ko', markersize=8, zorder=5)
        ax.set_title(title, fontsize=11)
        ax.legend(fontsize=8)
        ax.set_xlim(0, 1)
        ax.grid(True, alpha=0.3)

    fig.suptitle("Two-Point Interpolation Lemma", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/fig1_two_point_interpolation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 1: Two-point interpolation saved.")


def demo_inf_patching():
    """Demonstrate the inf-patching step (Step 1 of the proof)."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))

    target = lambda x: np.sin(2 * np.pi * x) + 0.3 * np.cos(6 * np.pi * x)
    xs = np.linspace(0, 1, 500)

    anchors = [0.1, 0.3, 0.5, 0.7, 0.85, 0.95]
    sample_points = np.linspace(0, 1, 30)
    g_samples = target(sample_points)

    for ax, x_anchor in zip(axes.flat, anchors):
        g_anchor = target(np.array([x_anchor]))[0]

        u_list = []
        for j, xj in enumerate(sample_points):
            if abs(xj - x_anchor) < 1e-10:
                continue
            u_ij = two_point_interpolation(x_anchor, g_anchor, xj, g_samples[j])
            u_list.append(u_ij)

        for k, u in enumerate(u_list[::3]):
            ax.plot(xs, u(xs), 'gray', alpha=0.2, linewidth=0.5)

        F_x = pointwise_min(*u_list)

        ax.plot(xs, target(xs), 'b-', linewidth=2, label='Target g')
        ax.plot(xs, F_x(xs), 'r-', linewidth=1.5, label=f'F_{{x={x_anchor}}}')
        ax.axvline(x_anchor, color='green', linestyle=':', alpha=0.5)
        ax.plot(x_anchor, g_anchor, 'go', markersize=8, zorder=5)
        ax.set_title(f'Anchor x = {x_anchor}', fontsize=10)
        ax.set_xlim(0, 1)
        ax.set_ylim(-2, 2)
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)

    fig.suptitle("Inf-Patching Step: Each F_x matches g at anchor, stays below g + ε",
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/fig2_inf_patching.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 2: Inf-patching step saved.")


def demo_full_approximation():
    """Demonstrate the full lattice approximation algorithm."""
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig)

    test_funcs = [
        (lambda x: np.sin(2 * np.pi * x), "sin(2πx)", (0, 1)),
        (lambda x: x**3 - x, "x³ - x", (-1.2, 1.2)),
        (lambda x: np.exp(-5 * (x - 0.5)**2), "Gaussian bump", (0, 1)),
        (lambda x: np.abs(x - 0.5) - 0.25, "|x - 0.5| - 0.25", (0, 1)),
    ]

    for idx, (func, name, domain) in enumerate(test_funcs):
        ax = fig.add_subplot(gs[idx // 2, idx % 2])
        xs = np.linspace(domain[0], domain[1], 1000)

        for n in [5, 10, 20, 40]:
            approx, error, _, _ = lattice_approximate(func, domain, 0.1, n_sample=n)
            ax.plot(xs, approx(xs), '--', linewidth=1, alpha=0.7,
                    label=f'n={n}, err={error:.4f}')

        ax.plot(xs, func(xs), 'b-', linewidth=2.5, label=f'Target: {name}')
        ax.set_title(f'{name}', fontsize=12, fontweight='bold')
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)

    fig.suptitle("Lattice Approximation: Convergence for Various Target Functions",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/fig3_full_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 3: Full approximation convergence saved.")


def demo_convergence_rate():
    """Show convergence rate as number of sample points increases."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    test_funcs = [
        (lambda x: np.sin(2 * np.pi * x), "sin(2πx)", (0, 1)),
        (lambda x: np.exp(-5 * (x - 0.5)**2), "Gaussian", (0, 1)),
        (lambda x: x**3 - x, "x³ - x", (-1, 1)),
        (lambda x: np.abs(x - 0.5) - 0.25, "|x-0.5|-0.25", (0, 1)),
    ]

    ns = [5, 8, 12, 16, 20, 30, 40, 60, 80, 100]

    for func, name, domain in test_funcs:
        errors = []
        for n in ns:
            _, error, _, _ = lattice_approximate(func, domain, 0.01, n_sample=n)
            errors.append(error)

        ax1.semilogy(ns, errors, 'o-', linewidth=1.5, markersize=4, label=name)

    ax1.set_xlabel('Number of sample points', fontsize=11)
    ax1.set_ylabel('Sup-norm error', fontsize=11)
    ax1.set_title('Convergence Rate', fontsize=12, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    func = lambda x: np.abs(x)
    domain = (-1, 1)
    xs = np.linspace(-1, 1, 1000)

    lattice_errors = []
    poly_errors = []
    degs = [3, 5, 8, 12, 16, 20, 30, 40]

    for n in degs:
        _, err, _, _ = lattice_approximate(func, domain, 0.01, n_sample=n)
        lattice_errors.append(err)

        sample = np.linspace(-1, 1, 200)
        coeffs = np.polyfit(sample, func(sample), n)
        poly = np.poly1d(coeffs)
        poly_err = np.max(np.abs(poly(xs) - func(xs)))
        poly_errors.append(poly_err)

    ax2.semilogy(degs, lattice_errors, 'bo-', linewidth=1.5, markersize=5,
                 label='Lattice (max-min-affine)')
    ax2.semilogy(degs, poly_errors, 'rs-', linewidth=1.5, markersize=5,
                 label='Polynomial')
    ax2.set_xlabel('Number of basis elements / degree', fontsize=11)
    ax2.set_ylabel('Sup-norm error', fontsize=11)
    ax2.set_title('Lattice vs Polynomial: Approximating |x|', fontsize=12, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/fig4_convergence_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 4: Convergence rate comparison saved.")


def demo_proof_visualization():
    """
    Visualize the key steps of the Kakutani–Stone proof on a concrete example.
    """
    fig = plt.figure(figsize=(18, 12))

    target = lambda x: 0.5 * np.sin(4 * np.pi * x) + 0.3 * np.cos(2 * np.pi * x)
    domain = (0, 1)
    xs = np.linspace(0, 1, 500)
    epsilon = 0.15

    # Step 1: Show two-point interpolation
    ax1 = fig.add_subplot(2, 3, 1)
    ax1.plot(xs, target(xs), 'b-', linewidth=2, label='g(x)')
    ax1.fill_between(xs, target(xs) - epsilon, target(xs) + epsilon,
                     alpha=0.15, color='blue', label='g ± ε')

    anchor = 0.3
    g_anchor = target(np.array([anchor]))[0]
    sample_pts = np.linspace(0, 1, 25)
    g_samples = target(sample_pts)

    for xj in [0.1, 0.5, 0.7, 0.9]:
        g_xj = target(np.array([xj]))[0]
        f = two_point_interpolation(anchor, g_anchor, xj, g_xj)
        ax1.plot(xs, f(xs), 'gray', alpha=0.4, linewidth=0.8)
    ax1.plot(anchor, g_anchor, 'ro', markersize=8, zorder=5)
    ax1.set_title('Step 1: Affine interpolants\nthrough anchor x = 0.3', fontsize=10)
    ax1.set_xlim(0, 1); ax1.set_ylim(-1.5, 1.5)
    ax1.legend(fontsize=7); ax1.grid(True, alpha=0.3)

    # Step 2: Inf-patching for one anchor
    ax2 = fig.add_subplot(2, 3, 2)

    u_list = []
    for j, xj in enumerate(sample_pts):
        if abs(xj - anchor) < 1e-10:
            continue
        u = two_point_interpolation(anchor, g_anchor, xj, g_samples[j])
        u_list.append(u)

    F_anchor = pointwise_min(*u_list)

    ax2.plot(xs, target(xs), 'b-', linewidth=2, label='g(x)')
    ax2.fill_between(xs, target(xs) - epsilon, target(xs) + epsilon,
                     alpha=0.15, color='blue')
    ax2.plot(xs, F_anchor(xs), 'r-', linewidth=2, label='F_{0.3} = inf of interpolants')
    ax2.plot(anchor, g_anchor, 'ro', markersize=8, zorder=5)
    ax2.set_title('Step 2: Inf-patch F_x\n(below g + ε everywhere)', fontsize=10)
    ax2.set_xlim(0, 1); ax2.set_ylim(-1.5, 1.5)
    ax2.legend(fontsize=7); ax2.grid(True, alpha=0.3)

    # Step 3: Multiple inf-patched functions
    ax3 = fig.add_subplot(2, 3, 3)
    anchors = [0.1, 0.3, 0.5, 0.7, 0.9]
    F_list = []
    colors = plt.cm.Set1(np.linspace(0, 1, len(anchors)))

    for i, anch in enumerate(anchors):
        g_anch = target(np.array([anch]))[0]
        u_list = []
        for j, xj in enumerate(sample_pts):
            if abs(xj - anch) < 1e-10:
                continue
            u = two_point_interpolation(anch, g_anch, xj, g_samples[j])
            u_list.append(u)
        F_anch = pointwise_min(*u_list)
        F_list.append(F_anch)
        ax3.plot(xs, F_anch(xs), '-', color=colors[i], linewidth=1,
                 alpha=0.6, label=f'F_{{{anch}}}')

    ax3.plot(xs, target(xs), 'b-', linewidth=2.5, label='g(x)')
    ax3.fill_between(xs, target(xs) - epsilon, target(xs) + epsilon,
                     alpha=0.1, color='blue')
    ax3.set_title('Step 3: Multiple F_x functions', fontsize=10)
    ax3.set_xlim(0, 1); ax3.set_ylim(-1.5, 1.5)
    ax3.legend(fontsize=6, ncol=2); ax3.grid(True, alpha=0.3)

    # Step 4: Sup-patch = final result
    ax4 = fig.add_subplot(2, 3, 4)
    F_final = pointwise_max(*F_list)

    ax4.plot(xs, target(xs), 'b-', linewidth=2.5, label='g(x)')
    ax4.fill_between(xs, target(xs) - epsilon, target(xs) + epsilon,
                     alpha=0.15, color='blue', label='g ± ε')
    ax4.plot(xs, F_final(xs), 'r-', linewidth=2, label='F = sup of F_x')
    ax4.set_title('Step 4: Sup-patch F = sup F_x\n(the final approximation)', fontsize=10)
    ax4.set_xlim(0, 1); ax4.set_ylim(-1.5, 1.5)
    ax4.legend(fontsize=7); ax4.grid(True, alpha=0.3)

    # Step 5: Error analysis
    ax5 = fig.add_subplot(2, 3, 5)
    error = F_final(xs) - target(xs)
    ax5.plot(xs, error, 'r-', linewidth=1.5)
    ax5.axhline(y=epsilon, color='k', linestyle='--', alpha=0.5, label=f'±ε = ±{epsilon}')
    ax5.axhline(y=-epsilon, color='k', linestyle='--', alpha=0.5)
    ax5.axhline(y=0, color='gray', linewidth=0.5)
    ax5.fill_between(xs, -epsilon, epsilon, alpha=0.1, color='green')
    ax5.set_title(f'Step 5: Pointwise error F - g\n(max |error| = {np.max(np.abs(error)):.4f})',
                  fontsize=10)
    ax5.set_xlim(0, 1)
    ax5.legend(fontsize=8); ax5.grid(True, alpha=0.3)

    # Step 6: Convergence
    ax6 = fig.add_subplot(2, 3, 6)
    ns_conv = [5, 8, 12, 16, 20, 30, 40, 60, 80]
    errors_conv = []
    for n in ns_conv:
        _, err, _, _ = lattice_approximate(target, domain, 0.01, n_sample=n)
        errors_conv.append(err)
    ax6.semilogy(ns_conv, errors_conv, 'bo-', linewidth=1.5, markersize=5)
    ax6.set_xlabel('Sample points', fontsize=10)
    ax6.set_ylabel('Sup-norm error', fontsize=10)
    ax6.set_title('Convergence: error → 0\n(Stone–Weierstrass in action)', fontsize=10)
    ax6.grid(True, alpha=0.3)

    fig.suptitle("The Kakutani–Stone Proof: Step by Step",
                 fontsize=15, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('demos/fig6_proof_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 6: Proof visualization saved.")


# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)

    print("=" * 70)
    print("  Stone–Weierstrass for Vector Lattices: Demo Suite")
    print("=" * 70)
    print()

    print("Running demonstrations...")
    print()

    demo_two_point_interpolation()
    demo_inf_patching()
    demo_full_approximation()
    demo_convergence_rate()
    demo_proof_visualization()

    print()
    print("=" * 70)
    print("  All figures saved to demos/")
    print("=" * 70)
    print()
    print("Key takeaway: The lattice Stone–Weierstrass theorem shows that")
    print("max-min-affine function classes are universal approximators on")
    print("compact spaces — no multiplication needed! This is the theoretical")
    print("foundation for EML neural network architectures.")
