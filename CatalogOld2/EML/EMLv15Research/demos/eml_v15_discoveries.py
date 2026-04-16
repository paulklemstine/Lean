#!/usr/bin/env python3
"""
EML V15 Discovery Demos — New results and computational explorations.

Focused on V15-specific discoveries:
1. Joint convexity visualization
2. Fixed point uniqueness (cobweb + error analysis)
3. Bregman divergence decomposition
4. σ-EML zero crossing analysis
5. Lambert W connection
6. Symmetrized EML landscape
7. Power scaling identity verification
8. EML gradient flow simulation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.optimize import brentq
from scipy.special import lambertw
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

def eml(x, y):
    return np.exp(x) - np.log(y)

def gmap(z):
    return np.e - np.log(z)

def sigma_eml(x):
    return np.exp(x) - np.log(1 + np.exp(-x))

# ============================================================
# Demo 1: Joint Convexity of EML
# ============================================================

def demo_joint_convexity():
    """Show that EML sublevel sets are convex."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    x = np.linspace(-2, 3, 300)
    y = np.linspace(0.01, 8, 300)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)

    for i, c in enumerate([1, 3, 5]):
        ax = axes[i]
        # Sublevel set
        ax.contourf(X, Y, Z, levels=[-10, c], colors=['lightblue'], alpha=0.5)
        ax.contour(X, Y, Z, levels=[c], colors=['blue'], linewidths=2)

        # Test convexity: sample random pairs in sublevel set and show midpoints are inside
        np.random.seed(42 + i)
        for _ in range(50):
            x1, y1 = np.random.uniform(-1, 2), np.random.uniform(0.1, 6)
            x2, y2 = np.random.uniform(-1, 2), np.random.uniform(0.1, 6)
            if eml(x1, y1) <= c and eml(x2, y2) <= c:
                xm, ym = (x1 + x2) / 2, (y1 + y2) / 2
                color = 'green' if eml(xm, ym) <= c else 'red'
                ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.2, linewidth=0.5)
                ax.plot(xm, ym, '.', color=color, markersize=4)

        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('y', fontsize=11)
        ax.set_title(f'Sublevel set {{eml ≤ {c}}}', fontsize=13)
        ax.set_xlim(-2, 3)
        ax.set_ylim(0, 8)

    plt.suptitle('Joint Convexity: All midpoints (green) lie inside sublevel sets', fontsize=14)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_joint_convexity.png'), dpi=150)
    plt.close()
    print("✓ Joint convexity demo saved")

# ============================================================
# Demo 2: Fixed Point Uniqueness — Error Analysis
# ============================================================

def demo_fixed_point_uniqueness():
    """Show convergence rate and uniqueness."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    z_star = brentq(lambda z: gmap(z) - z, 1.5, 3)

    # Left: h(z) = z + ln(z) is strictly increasing (uniqueness proof)
    ax = axes[0]
    z = np.linspace(0.01, 5, 500)
    h = z + np.log(z)
    ax.plot(z, h, 'b-', linewidth=2, label='h(z) = z + ln(z)')
    ax.axhline(y=np.e, color='r', linestyle='--', label=f'y = e ≈ {np.e:.4f}')
    ax.plot(z_star, np.e, 'r*', markersize=15, zorder=5)

    # Show derivative h'(z) = 1 + 1/z > 0
    h_prime = 1 + 1/z
    ax2 = ax.twinx()
    ax2.plot(z, h_prime, 'g--', linewidth=1, alpha=0.5, label="h'(z) = 1 + 1/z > 0")
    ax2.set_ylabel("h'(z)", color='green', fontsize=10)
    ax2.axhline(y=0, color='gray', linewidth=0.5)

    ax.set_xlabel('z', fontsize=11)
    ax.set_ylabel('h(z)', fontsize=11)
    ax.set_title('h(z) strictly increasing → unique solution', fontsize=13)
    ax.legend(loc='upper left', fontsize=9)

    # Middle: convergence errors
    ax = axes[1]
    starts = [0.1, 0.5, 1.0, 2.0, 3.5, 5.0, 10.0]
    for z0 in starts:
        errors = []
        zn = z0
        for _ in range(25):
            errors.append(abs(zn - z_star))
            zn = gmap(zn)
        ax.semilogy(errors, '-o', markersize=2, label=f'z₀={z0}')

    ax.set_xlabel('Iteration', fontsize=11)
    ax.set_ylabel('|g^n(z₀) - z*|', fontsize=11)
    ax.set_title('Convergence Error (log scale)', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)

    # Right: Lambert W verification
    ax = axes[2]
    z = np.linspace(0.5, 4, 200)
    lhs = z * np.exp(z)
    rhs = np.exp(np.e)

    ax.plot(z, lhs, 'b-', linewidth=2, label='z·exp(z)')
    ax.axhline(y=rhs, color='r', linestyle='--', linewidth=1.5, label=f'exp(e) ≈ {rhs:.2f}')
    ax.plot(z_star, z_star * np.exp(z_star), 'r*', markersize=15)

    # Lambert W verification
    w_val = float(lambertw(np.exp(np.e)).real)
    ax.annotate(f'z* = W(exp(e)) ≈ {w_val:.6f}', xy=(z_star, rhs),
                xytext=(3, rhs-3), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlabel('z', fontsize=11)
    ax.set_ylabel('z·exp(z)', fontsize=11)
    ax.set_title(f'Lambert W: z* = W(exp(e)) ≈ {w_val:.6f}', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_fixed_point_uniqueness.png'), dpi=150)
    plt.close()
    print(f"✓ Fixed point uniqueness demo saved (z* = {z_star:.10f}, W(exp(e)) = {w_val:.10f})")

# ============================================================
# Demo 3: Bregman Divergence Decomposition
# ============================================================

def demo_bregman_decomposition():
    """Visualize the Bregman divergence structure."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    p = np.linspace(0.1, 5, 300)

    # Left: decomposition p - ln(p) = 1 + D_{-ln}(p||1)
    ax = axes[0]
    eml_diag = p - np.log(p)
    bregman = p - 1 - np.log(p)
    constant_1 = np.ones_like(p)

    ax.fill_between(p, 0, constant_1, alpha=0.2, color='blue', label='Constant = 1')
    ax.fill_between(p, constant_1, constant_1 + bregman, alpha=0.2, color='red',
                    label='Bregman D_{-ln}(p||1)')
    ax.plot(p, eml_diag, 'k-', linewidth=2, label='EML diagonal: p - ln(p)')
    ax.plot(1, 1, 'ko', markersize=8)
    ax.annotate('Min at (1, 1)', xy=(1, 1), xytext=(2, 0.5), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='black'))

    ax.set_xlabel('p', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('EML Diagonal = 1 + Bregman Divergence', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: Bregman divergence from various reference points
    ax = axes[1]
    refs = [0.5, 1.0, 2.0, 3.0]
    for q in refs:
        # D_{-ln}(p||q) = p/q - 1 - ln(p/q) = p/q - 1 - ln(p) + ln(q)
        bregman_q = p/q - 1 - np.log(p/q)
        ax.plot(p, bregman_q, linewidth=2, label=f'D(p||{q})')

    ax.set_xlabel('p', fontsize=12)
    ax.set_ylabel('Bregman divergence D_{-ln}(p||q)', fontsize=12)
    ax.set_title('Bregman Divergences of -ln(x)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_bregman.png'), dpi=150)
    plt.close()
    print("✓ Bregman decomposition demo saved")

# ============================================================
# Demo 4: σ-EML Zero Crossing Analysis
# ============================================================

def demo_sigma_zero_crossing():
    """Detailed analysis of the σ-EML zero crossing."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x_zero = brentq(sigma_eml, -3, 0)

    # Left: σ-EML near zero crossing
    ax = axes[0]
    x = np.linspace(-2, 1, 500)
    y = sigma_eml(x)

    ax.plot(x, y, 'b-', linewidth=2.5, label='σ_EML(x)')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.plot(x_zero, 0, 'ro', markersize=10, zorder=5)

    # Tangent line at zero crossing
    dx = 1e-6
    deriv_at_zero = (sigma_eml(x_zero + dx) - sigma_eml(x_zero - dx)) / (2 * dx)
    tangent = deriv_at_zero * (x - x_zero)
    ax.plot(x, tangent, 'r--', linewidth=1, alpha=0.5, label=f"Tangent (slope = {deriv_at_zero:.4f})")

    ax.annotate(f'x₀ ≈ {x_zero:.6f}', xy=(x_zero, 0),
                xytext=(x_zero + 0.5, -0.5), fontsize=12,
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('σ_EML(x)', fontsize=12)
    ax.set_title('σ-EML Zero Crossing', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-1, 3)

    # Right: derivative = exp(x) + 1/(1+exp(x)) > 0 always
    ax = axes[1]
    x = np.linspace(-5, 3, 500)
    deriv = np.exp(x) + 1 / (1 + np.exp(x))

    ax.plot(x, deriv, 'b-', linewidth=2.5, label="σ'_EML(x) = exp(x) + 1/(1+exp(x))")
    ax.plot(x, np.exp(x), 'r--', linewidth=1, alpha=0.5, label='exp(x) component')
    ax.plot(x, 1 / (1 + np.exp(x)), 'g--', linewidth=1, alpha=0.5, label='1/(1+exp(x)) component')
    ax.axhline(y=0, color='k', linewidth=0.5)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel("Derivative", fontsize=12)
    ax.set_title("σ'_EML > 0 everywhere (strict monotonicity)", fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 8)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_sigma_zero.png'), dpi=150)
    plt.close()
    print(f"✓ σ-EML zero crossing demo saved (x₀ = {x_zero:.10f})")
    print(f"  σ'_EML(x₀) = {deriv_at_zero:.6f} (positive → clean crossing)")

# ============================================================
# Demo 5: Symmetrized EML Landscape
# ============================================================

def demo_symmetrized_eml():
    """Visualize (a - ln b) + (b - ln a) ≥ 2."""
    fig, ax = plt.subplots(figsize=(10, 8))

    a = np.linspace(0.01, 5, 300)
    b = np.linspace(0.01, 5, 300)
    A, B = np.meshgrid(a, b)
    S = (A - np.log(B)) + (B - np.log(A))

    levels = [2, 2.5, 3, 4, 5, 7, 10, 15]
    cs = ax.contourf(A, B, S, levels=[0] + levels + [20], cmap='YlOrRd', alpha=0.7)
    ax.contour(A, B, S, levels=levels, colors='black', linewidths=0.5)
    ax.contour(A, B, S, levels=[2], colors='blue', linewidths=3)

    plt.colorbar(cs, ax=ax, label='S(a,b) = (a - ln b) + (b - ln a)')

    ax.plot(1, 1, 'w*', markersize=20, markeredgecolor='black', zorder=5)
    ax.annotate('Min = 2 at (1,1)', xy=(1, 1), xytext=(2, 0.5), fontsize=12,
                arrowprops=dict(arrowstyle='->', color='white', lw=2))

    # Show symmetry line
    t = np.linspace(0.01, 5, 100)
    ax.plot(t, t, 'w--', linewidth=1, alpha=0.5, label='a = b (symmetry)')

    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('b', fontsize=12)
    ax.set_title('Symmetrized EML: S(a,b) ≥ 2, with equality at (1,1)', fontsize=14)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_symmetrized_eml.png'), dpi=150)
    plt.close()
    print("✓ Symmetrized EML demo saved")

# ============================================================
# Demo 6: EML Gradient Flow
# ============================================================

def demo_gradient_flow():
    """Simulate the EML gradient flow: dx/dt = -exp(x), dy/dt = 1/y."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: gradient flow trajectories
    ax = axes[0]

    # Explicit solutions: x(t) = -ln(exp(-x0) + t), y(t) = sqrt(y0^2 + 2t)
    starts = [(1, 0.5), (0, 1), (-1, 2), (2, 0.3), (0, 3)]
    t = np.linspace(0, 5, 1000)

    x_grid = np.linspace(-3, 3, 20)
    y_grid = np.linspace(0.1, 5, 20)
    XG, YG = np.meshgrid(x_grid, y_grid)
    U = -np.exp(XG)  # dx/dt = -exp(x)
    V = 1 / YG       # dy/dt = 1/y
    speed = np.sqrt(U**2 + V**2)
    ax.streamplot(XG, YG, U, V, color=speed, cmap='coolwarm', density=1.5,
                  linewidth=0.8, arrowsize=0.8)

    for x0, y0 in starts:
        xt = -np.log(np.exp(-x0) + t)
        yt = np.sqrt(y0**2 + 2*t)
        valid = np.isfinite(xt) & np.isfinite(yt)
        ax.plot(xt[valid], yt[valid], 'k-', linewidth=2, alpha=0.7)
        ax.plot(x0, y0, 'ko', markersize=6)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('EML Gradient Flow: (ẋ, ẏ) = (-eˣ, 1/y)', fontsize=14)
    ax.set_xlim(-3, 3)
    ax.set_ylim(0, 5)

    # Right: EML value along flow
    ax = axes[1]
    for x0, y0 in starts:
        xt = -np.log(np.exp(-x0) + t)
        yt = np.sqrt(y0**2 + 2*t)
        valid = np.isfinite(xt) & np.isfinite(yt) & (yt > 0)
        eml_t = np.exp(xt[valid]) - np.log(yt[valid])
        ax.plot(t[valid], eml_t, linewidth=2, label=f'({x0}, {y0})')

    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('eml(x(t), y(t))', fontsize=12)
    ax.set_title('EML Value Along Gradient Flow (Decreasing)', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_gradient_flow.png'), dpi=150)
    plt.close()
    print("✓ Gradient flow demo saved")

# ============================================================
# Demo 7: EML Power Scaling Verification
# ============================================================

def demo_power_scaling():
    """Verify eml(nx, y^n) = exp(nx) - n*ln(y)."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x_vals = np.linspace(-1, 2, 50)
    y_fixed = 2.0

    for n in [1, 2, 3, 5]:
        lhs = np.exp(n * x_vals) - np.log(y_fixed**n)
        rhs = np.exp(n * x_vals) - n * np.log(y_fixed)
        ax.plot(x_vals, lhs, '-', linewidth=2, label=f'eml({n}x, {y_fixed}^{n})')
        ax.plot(x_vals, rhs, '--', linewidth=1, alpha=0.5)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(f'Power Scaling: eml(nx, y^n) = exp(nx) − n·ln(y) [y={y_fixed}]', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_power_scaling.png'), dpi=150)
    plt.close()
    print("✓ Power scaling demo saved")

# ============================================================
# Demo 8: Lipschitz Estimates
# ============================================================

def demo_lipschitz():
    """Visualize Lipschitz constants in x and y."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Lipschitz in x
    ax = axes[0]
    x = np.linspace(-2, 2, 200)
    y_fixed = 1.0
    f = np.exp(x) - np.log(y_fixed)
    lip_const = np.exp(x)  # Local Lipschitz constant

    ax.plot(x, f, 'b-', linewidth=2, label='eml(x, 1)')
    ax2 = ax.twinx()
    ax2.plot(x, lip_const, 'r--', linewidth=1.5, label='Lipschitz const = exp(x)')
    ax2.set_ylabel('Lipschitz constant', color='red', fontsize=11)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('eml(x, 1)', fontsize=12)
    ax.set_title('Local Lipschitz Constant in x: exp(x)', fontsize=14)
    ax.legend(loc='upper left', fontsize=10)
    ax2.legend(loc='upper right', fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: Lipschitz in y
    ax = axes[1]
    y = np.linspace(0.1, 5, 200)
    x_fixed = 0.0
    f = np.exp(x_fixed) - np.log(y)

    ax.plot(y, f, 'b-', linewidth=2, label='eml(0, y)')
    # Lipschitz constant 1/y for local, 1/a for global on [a,∞)
    ax2 = ax.twinx()
    ax2.plot(y, 1/y, 'r--', linewidth=1.5, label='|d/dy eml| = 1/y')
    ax2.set_ylabel('|derivative|', color='red', fontsize=11)

    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('eml(0, y)', fontsize=12)
    ax.set_title('Local Lipschitz Constant in y: 1/y', fontsize=14)
    ax.legend(loc='upper right', fontsize=10)
    ax2.legend(loc='center right', fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'v15_lipschitz.png'), dpi=150)
    plt.close()
    print("✓ Lipschitz estimates demo saved")

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("EML V15 Discovery Demos")
    print("=" * 60)

    demo_joint_convexity()
    demo_fixed_point_uniqueness()
    demo_bregman_decomposition()
    demo_sigma_zero_crossing()
    demo_symmetrized_eml()
    demo_gradient_flow()
    demo_power_scaling()
    demo_lipschitz()

    print("\n" + "=" * 60)
    print("All V15 discovery demos generated!")
    print("=" * 60)
