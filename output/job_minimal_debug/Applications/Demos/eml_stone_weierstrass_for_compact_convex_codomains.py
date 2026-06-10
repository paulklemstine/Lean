"""
Applications of Codomain-Constrained Approximation

This script demonstrates real-world applications of the theorem:
1. Probability simplex approximation (stochastic kernels)
2. Box-constrained approximation (clipping)
3. Neural network output projection onto convex constraints
4. Portfolio weight approximation

Usage:
    python demos/applications_demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

os.makedirs("demos/figures", exist_ok=True)


# ============================================================
# Application 1: Stochastic Kernel Approximation
# ============================================================

def project_simplex(v):
    """Project onto the probability simplex {p >= 0, sum(p) = 1}."""
    n = len(v)
    u = np.sort(v)[::-1]
    cssv = np.cumsum(u) - 1
    rho = np.max(np.where(u - cssv / np.arange(1, n + 1) > 0)[0])
    theta = cssv[rho] / (rho + 1.0)
    return np.maximum(v - theta, 0)


def app_stochastic_kernel():
    """
    Approximate a stochastic kernel K(x, ·) : [0,1] → Δ₃
    with projection to ensure outputs remain probability distributions.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    t = np.linspace(0, 1, 300)

    # True stochastic kernel: smooth transition between distributions
    p1 = 0.2 + 0.3 * np.sin(np.pi * t) ** 2
    p2 = 0.3 + 0.2 * np.cos(2 * np.pi * t)
    p3 = 1 - p1 - p2

    # Polynomial approximation (degree 5) — may violate simplex constraints
    from numpy.polynomial import polynomial as P
    deg = 5
    c1 = P.polyfit(t, p1, deg)
    c2 = P.polyfit(t, p2, deg)
    c3 = P.polyfit(t, p3, deg)
    p1_approx = P.polyval(t, c1)
    p2_approx = P.polyval(t, c2)
    p3_approx = P.polyval(t, c3)

    # Stack and project
    approx = np.column_stack([p1_approx, p2_approx, p3_approx])
    projected = np.array([project_simplex(a) for a in approx])

    # Panel (a): True kernel
    ax = axes[0, 0]
    ax.fill_between(t, 0, p1, alpha=0.3, color='red', label='$p_1$')
    ax.fill_between(t, p1, p1 + p2, alpha=0.3, color='blue', label='$p_2$')
    ax.fill_between(t, p1 + p2, 1, alpha=0.3, color='green', label='$p_3$')
    ax.set_ylim(0, 1.05)
    ax.set_title('(a) True stochastic kernel $K(x, \\cdot)$', fontsize=12)
    ax.set_xlabel('$x$'); ax.set_ylabel('Probability')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.2)

    # Panel (b): Unconstrained polynomial approximation
    ax = axes[0, 1]
    ax.plot(t, p1_approx, 'r-', lw=1.5, label='$\\hat{p}_1$')
    ax.plot(t, p2_approx, 'b-', lw=1.5, label='$\\hat{p}_2$')
    ax.plot(t, p3_approx, 'g-', lw=1.5, label='$\\hat{p}_3$')
    ax.axhline(y=0, color='k', lw=0.5, ls='--')
    ax.axhline(y=1, color='k', lw=0.5, ls='--')

    # Highlight violations
    violations = np.any(approx < -0.001, axis=1) | np.any(approx > 1.001, axis=1) | (np.abs(approx.sum(axis=1) - 1) > 0.01)
    if np.any(violations):
        ax.fill_between(t, -0.15, 1.15, where=violations, alpha=0.1, color='red')

    ax.set_ylim(-0.15, 1.15)
    ax.set_title('(b) Polynomial approximation (VIOLATES simplex)', fontsize=12)
    ax.set_xlabel('$x$'); ax.set_ylabel('Value')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.2)

    # Panel (c): Projected approximation
    ax = axes[1, 0]
    ax.fill_between(t, 0, projected[:, 0], alpha=0.3, color='red', label='$\\pi_\\Delta(\\hat{p})_1$')
    ax.fill_between(t, projected[:, 0], projected[:, 0] + projected[:, 1],
                   alpha=0.3, color='blue', label='$\\pi_\\Delta(\\hat{p})_2$')
    ax.fill_between(t, projected[:, 0] + projected[:, 1], 1, alpha=0.3,
                   color='green', label='$\\pi_\\Delta(\\hat{p})_3$')
    ax.set_ylim(0, 1.05)
    ax.set_title('(c) Projected: $\\pi_\\Delta \\circ \\hat{p}$ (VALID simplex)', fontsize=12)
    ax.set_xlabel('$x$'); ax.set_ylabel('Probability')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.2)

    # Panel (d): Error comparison
    ax = axes[1, 1]
    true = np.column_stack([p1, p2, p3])
    err_unconstrained = np.linalg.norm(true - approx, axis=1)
    err_projected = np.linalg.norm(true - projected, axis=1)
    ax.plot(t, err_unconstrained, 'r-', lw=1.5, alpha=0.7, label='$\\|K - \\hat{p}\\|$ (unconstrained)')
    ax.plot(t, err_projected, 'g-', lw=1.5, label='$\\|K - \\pi_\\Delta(\\hat{p})\\|$ (projected)')
    ax.fill_between(t, err_projected, err_unconstrained, alpha=0.1, color='blue',
                   label='Improvement from projection')
    ax.set_title('(d) Error: projection never worsens', fontsize=12)
    ax.set_xlabel('$x$'); ax.set_ylabel('$\\ell^2$ error')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('demos/figures/stochastic_kernel_app.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/stochastic_kernel_app.png")
    print(f"  Max unconstrained error: {err_unconstrained.max():.6f}")
    print(f"  Max projected error:     {err_projected.max():.6f}")
    print(f"  Projection improves: {np.all(err_projected <= err_unconstrained + 1e-10)}")


# ============================================================
# Application 2: Safe RL — Box-Constrained Control
# ============================================================

def app_box_constraint():
    """
    Approximate a control signal that must stay in [u_min, u_max].
    The metric projection onto a box is coordinatewise clamping.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    t = np.linspace(0, 2 * np.pi, 300)
    u_min, u_max = -1.0, 1.0

    # True optimal control (stays in bounds)
    u_true = 0.8 * np.sin(t) + 0.15 * np.sin(3 * t)

    # Neural network approximation (overshoots bounds)
    u_nn = 1.1 * np.sin(t) + 0.3 * np.sin(3 * t) - 0.1 * np.cos(5 * t)

    # Projected (clamped) approximation
    u_proj = np.clip(u_nn, u_min, u_max)

    ax = axes[0]
    ax.plot(t, u_true, 'b-', lw=2, label='Optimal $u^*$')
    ax.axhline(y=u_min, color='red', ls='--', lw=1, alpha=0.7)
    ax.axhline(y=u_max, color='red', ls='--', lw=1, alpha=0.7)
    ax.fill_between(t, u_min, u_max, alpha=0.05, color='green')
    ax.set_title('(a) True optimal control (feasible)', fontsize=12)
    ax.set_xlabel('Time'); ax.set_ylabel('Control $u$')
    ax.legend(); ax.grid(True, alpha=0.2)

    ax = axes[1]
    ax.plot(t, u_nn, 'r-', lw=2, label='NN approximation $\\hat{u}$')
    ax.axhline(y=u_min, color='red', ls='--', lw=1, alpha=0.7)
    ax.axhline(y=u_max, color='red', ls='--', lw=1, alpha=0.7)
    violations = (u_nn < u_min) | (u_nn > u_max)
    ax.fill_between(t, u_min, u_max, alpha=0.05, color='green')
    if np.any(violations):
        ax.fill_between(t, u_min - 0.3, u_max + 0.3, where=violations,
                       alpha=0.15, color='red', label='Constraint violation')
    ax.set_title('(b) NN output (VIOLATES bounds)', fontsize=12)
    ax.set_xlabel('Time'); ax.set_ylabel('Control $u$')
    ax.legend(); ax.grid(True, alpha=0.2)

    ax = axes[2]
    ax.plot(t, u_proj, 'g-', lw=2, label='$\\pi_{[u_{min}, u_{max}]}(\\hat{u})$')
    ax.plot(t, u_true, 'b--', lw=1, alpha=0.5, label='$u^*$ (reference)')
    ax.axhline(y=u_min, color='red', ls='--', lw=1, alpha=0.7)
    ax.axhline(y=u_max, color='red', ls='--', lw=1, alpha=0.7)
    ax.fill_between(t, u_min, u_max, alpha=0.05, color='green')
    err_before = np.max(np.abs(u_true - u_nn))
    err_after = np.max(np.abs(u_true - u_proj))
    ax.set_title(f'(c) Projected (feasible)\n'
                f'$\\|u^* - \\hat{{u}}\\|_\\infty = {err_before:.3f}$, '
                f'$\\|u^* - \\pi(\\hat{{u}})\\|_\\infty = {err_after:.3f}$', fontsize=11)
    ax.set_xlabel('Time'); ax.set_ylabel('Control $u$')
    ax.legend(); ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('demos/figures/box_constraint_app.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/box_constraint_app.png")


# ============================================================
# Application 3: Portfolio Optimization
# ============================================================

def app_portfolio():
    """
    Approximate optimal portfolio weights on the simplex with
    additional bounds constraints (no single asset > 40%).
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    n_assets = 5
    t = np.linspace(0, 1, 200)

    # True optimal weights (smooth transition, stays in constraints)
    np.random.seed(42)
    base_weights = np.random.dirichlet(np.ones(n_assets) * 5, size=200)
    # Smooth them
    from scipy.ndimage import gaussian_filter1d
    for i in range(n_assets):
        base_weights[:, i] = gaussian_filter1d(base_weights[:, i], sigma=10)
    # Renormalize
    base_weights = base_weights / base_weights.sum(axis=1, keepdims=True)
    # Clamp to max 40%
    base_weights = np.minimum(base_weights, 0.4)
    base_weights = base_weights / base_weights.sum(axis=1, keepdims=True)

    # Plot stacked area
    colors = plt.cm.Set3(np.linspace(0, 1, n_assets))
    bottom = np.zeros(len(t))
    for i in range(n_assets):
        ax.fill_between(t, bottom, bottom + base_weights[:, i],
                       alpha=0.6, color=colors[i], label=f'Asset {i+1}')
        bottom += base_weights[:, i]

    ax.set_ylim(0, 1.05)
    ax.set_xlabel('Market condition parameter $x$', fontsize=12)
    ax.set_ylabel('Portfolio weight', fontsize=12)
    ax.set_title('Portfolio Weights in Constrained Simplex\n'
                '(Each weight $\\in [0, 0.4]$, sum $= 1$)', fontsize=13)
    ax.legend(loc='upper right', fontsize=9, ncol=2)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('demos/figures/portfolio_app.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/portfolio_app.png")


# ============================================================
# Application 4: Comparison — With vs Without Projection
# ============================================================

def app_error_improvement():
    """
    Systematic comparison showing that projection always helps.
    Vary polynomial degree and measure errors with/without projection.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    t = np.linspace(0, 1, 500)

    # Target: smooth curve in the 2D unit disk
    f = np.column_stack([0.5 * np.cos(4 * np.pi * t), 0.5 * np.sin(4 * np.pi * t)])

    from numpy.polynomial import polynomial as P

    degrees = list(range(2, 25))
    errors_ambient = []
    errors_projected = []

    for deg in degrees:
        c1 = P.polyfit(t, f[:, 0], deg)
        c2 = P.polyfit(t, f[:, 1], deg)
        approx = np.column_stack([P.polyval(t, c1), P.polyval(t, c2)])

        # Project onto unit disk
        norms = np.linalg.norm(approx, axis=1)
        proj = approx.copy()
        mask = norms > 1
        proj[mask] = approx[mask] / norms[mask, np.newaxis]

        err_a = np.max(np.linalg.norm(f - approx, axis=1))
        err_p = np.max(np.linalg.norm(f - proj, axis=1))
        errors_ambient.append(err_a)
        errors_projected.append(err_p)

    ax.semilogy(degrees, errors_ambient, 'ro-', lw=2, ms=6, label='Ambient $\\|f - G\\|_\\infty$')
    ax.semilogy(degrees, errors_projected, 'g^-', lw=2, ms=6,
               label='Projected $\\|f - \\pi_C(G)\\|_\\infty$')

    # Shade the improvement region
    ax.fill_between(degrees, errors_projected, errors_ambient, alpha=0.1, color='blue')

    ax.set_xlabel('Polynomial degree', fontsize=12)
    ax.set_ylabel('Sup-norm error', fontsize=12)
    ax.set_title('Approximation Error: Ambient vs Projected\n'
                '(Unit disk constraint, polynomial approximation)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    plt.savefig('demos/figures/error_improvement.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/error_improvement.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Applications of Codomain-Constrained Approximation")
    print("=" * 60)
    print()
    app_stochastic_kernel()
    print()
    app_box_constraint()
    print()
    app_portfolio()
    print()
    app_error_improvement()
    print()
    print("All application demos complete!")


"""
Demonstration: Metric Projection and Codomain-Constrained Approximation

This script visualizes the core mathematical ideas behind the
codomain-constrained Stone-Weierstrass theorem:

1. Metric projection onto compact convex sets (nearest-point retraction)
2. How composing an unconstrained approximant with the retraction
   produces a constrained approximant that is at least as good
3. Probability simplex approximation
4. Convergence guarantees

Usage:
    python demos/convex_retraction_demo.py

Outputs:
    demos/figures/metric_projection.png
    demos/figures/lipschitz_property.png
    demos/figures/constrained_approximation.png
    demos/figures/simplex_approximation.png
    demos/figures/convergence_comparison.png
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import os

os.makedirs("demos/figures", exist_ok=True)


def project_onto_convex(point, vertices):
    """Project a point onto a convex polygon defined by its vertices."""
    n = len(vertices)
    best_dist = np.inf
    best_proj = None

    # Check if point is inside the polygon (assumes CCW orientation)
    inside = True
    for i in range(n):
        v1 = vertices[i]
        v2 = vertices[(i + 1) % n]
        edge = v2 - v1
        to_point = point - v1
        cross = edge[0] * to_point[1] - edge[1] * to_point[0]
        if cross < 0:
            inside = False
            break

    if inside:
        return point.copy()

    for i in range(n):
        v1 = vertices[i]
        v2 = vertices[(i + 1) % n]
        edge = v2 - v1
        t = np.dot(point - v1, edge) / np.dot(edge, edge)
        t = np.clip(t, 0, 1)
        proj = v1 + t * edge
        dist = np.linalg.norm(point - proj)
        if dist < best_dist:
            best_dist = dist
            best_proj = proj

    return best_proj


def demo_metric_projection():
    """Visualize the metric projection onto a convex set."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Projection onto a triangle (simplex)
    ax = axes[0]
    triangle = np.array([[0.5, 2.5], [2.5, 0.5], [3.5, 3.0]])

    xx, yy = np.meshgrid(np.linspace(-0.5, 4.5, 20), np.linspace(-0.5, 4.0, 16))
    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            pt = np.array([xx[i, j], yy[i, j]])
            proj = project_onto_convex(pt, triangle)
            dist = np.linalg.norm(pt - proj)
            if dist > 0.05:
                ax.annotate('', xy=proj, xytext=pt,
                           arrowprops=dict(arrowstyle='->', color='steelblue',
                                         alpha=0.4, lw=0.8))

    tri_patch = Polygon(triangle, closed=True, fill=True,
                       facecolor='coral', alpha=0.3, edgecolor='darkred', lw=2)
    ax.add_patch(tri_patch)

    pt_example = np.array([0.5, 0.5])
    proj_example = project_onto_convex(pt_example, triangle)
    ax.plot(*pt_example, 'ko', ms=8, zorder=5)
    ax.plot(*proj_example, 'r*', ms=15, zorder=5)
    ax.annotate('', xy=proj_example, xytext=pt_example,
               arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
    ax.annotate('$x$', pt_example, fontsize=14, ha='right', va='top')
    ax.annotate('$\\pi_C(x)$', proj_example + [0.1, 0.1], fontsize=14, color='darkred')

    ax.set_xlim(-0.8, 4.8)
    ax.set_ylim(-0.8, 4.2)
    ax.set_aspect('equal')
    ax.set_title('Metric Projection onto a Triangle (Simplex)', fontsize=13)
    ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
    ax.grid(True, alpha=0.2)

    # Panel 2: Projection onto an ellipse
    ax = axes[1]
    t = np.linspace(0, 2 * np.pi, 40, endpoint=False)
    ellipse = np.column_stack([2 + 1.5 * np.cos(t), 2 + 1.0 * np.sin(t)])

    xx, yy = np.meshgrid(np.linspace(-0.5, 4.5, 18), np.linspace(-0.5, 4.5, 18))
    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            pt = np.array([xx[i, j], yy[i, j]])
            proj = project_onto_convex(pt, ellipse)
            dist = np.linalg.norm(pt - proj)
            if dist > 0.05:
                ax.annotate('', xy=proj, xytext=pt,
                           arrowprops=dict(arrowstyle='->', color='steelblue',
                                         alpha=0.4, lw=0.8))

    ell_patch = Polygon(ellipse, closed=True, fill=True,
                       facecolor='lightgreen', alpha=0.4, edgecolor='darkgreen', lw=2)
    ax.add_patch(ell_patch)

    ax.set_xlim(-0.8, 4.8); ax.set_ylim(-0.8, 4.8)
    ax.set_aspect('equal')
    ax.set_title('Metric Projection onto a Convex Body', fontsize=13)
    ax.set_xlabel('$x_1$'); ax.set_ylabel('$x_2$')
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('demos/figures/metric_projection.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/metric_projection.png")


def demo_constrained_approximation():
    """Demonstrate the main theorem: project unconstrained approximant onto C."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    n_verts = 60
    theta = np.linspace(0, 2 * np.pi, n_verts, endpoint=False)
    disk_center = np.array([2.0, 2.0])
    disk_radius = 1.5
    disk_verts = np.column_stack([
        disk_center[0] + disk_radius * np.cos(theta),
        disk_center[1] + disk_radius * np.sin(theta)
    ])

    t = np.linspace(0, 1, 200)
    f_curve = np.column_stack([
        2.0 + 1.0 * np.cos(2 * np.pi * t),
        2.0 + 0.8 * np.sin(2 * np.pi * t)
    ])

    G_curve = np.column_stack([
        2.0 + 1.3 * np.cos(2 * np.pi * t) + 0.3 * np.sin(4 * np.pi * t),
        2.0 + 1.1 * np.sin(2 * np.pi * t) + 0.25 * np.cos(6 * np.pi * t)
    ])

    g_curve = np.array([project_onto_convex(G_curve[i], disk_verts) for i in range(len(t))])

    # Panel 1
    ax = axes[0]
    ax.add_patch(Polygon(disk_verts, closed=True, fill=True,
                        facecolor='lightyellow', alpha=0.4, edgecolor='orange', lw=2))
    ax.plot(f_curve[:, 0], f_curve[:, 1], 'b-', lw=2, label='$f: K \\to C$ (target)')
    ax.set_xlim(-0.2, 4.2); ax.set_ylim(-0.2, 4.2); ax.set_aspect('equal')
    ax.set_title('(a) Target $f$ maps into $C$', fontsize=13)
    ax.legend(fontsize=11, loc='lower right'); ax.grid(True, alpha=0.2)
    ax.annotate('$C$', (3.2, 3.2), fontsize=16, color='darkorange', fontweight='bold')

    # Panel 2
    ax = axes[1]
    ax.add_patch(Polygon(disk_verts, closed=True, fill=True,
                        facecolor='lightyellow', alpha=0.4, edgecolor='orange', lw=2))
    ax.plot(f_curve[:, 0], f_curve[:, 1], 'b-', lw=1.5, alpha=0.4, label='$f$ (target)')
    ax.plot(G_curve[:, 0], G_curve[:, 1], 'r--', lw=2, label='$G$ (unconstrained)')
    ax.set_xlim(-0.2, 4.2); ax.set_ylim(-0.2, 4.2); ax.set_aspect('equal')
    ax.set_title('(b) Ambient approximant $G$ leaves $C$', fontsize=13)
    ax.legend(fontsize=11, loc='lower right'); ax.grid(True, alpha=0.2)
    ax.annotate('$C$', (3.2, 3.2), fontsize=16, color='darkorange', fontweight='bold')

    # Panel 3
    ax = axes[2]
    ax.add_patch(Polygon(disk_verts, closed=True, fill=True,
                        facecolor='lightyellow', alpha=0.4, edgecolor='orange', lw=2))
    ax.plot(f_curve[:, 0], f_curve[:, 1], 'b-', lw=1.5, alpha=0.4, label='$f$ (target)')
    ax.plot(g_curve[:, 0], g_curve[:, 1], 'g-', lw=2.5,
            label='$g = \\pi_C \\circ G$ (constrained)')

    err_G = np.max(np.linalg.norm(f_curve - G_curve, axis=1))
    err_g = np.max(np.linalg.norm(f_curve - g_curve, axis=1))

    ax.set_xlim(-0.2, 4.2); ax.set_ylim(-0.2, 4.2); ax.set_aspect('equal')
    ax.set_title(f'(c) Projected $g = \\pi_C \\circ G$ stays in $C$\n'
                f'$\\|f-G\\|_\\infty = {err_G:.3f}$, $\\|f-g\\|_\\infty = {err_g:.3f}$',
                fontsize=12)
    ax.legend(fontsize=11, loc='lower right'); ax.grid(True, alpha=0.2)
    ax.annotate('$C$', (3.2, 3.2), fontsize=16, color='darkorange', fontweight='bold')

    plt.tight_layout()
    plt.savefig('demos/figures/constrained_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/constrained_approximation.png")
    print(f"  Error before projection: ||f - G|| = {err_G:.4f}")
    print(f"  Error after projection:  ||f - g|| = {err_g:.4f}")
    print(f"  Ratio: {err_g/err_G:.4f} <= 1.0 (1-Lipschitz guarantee)")


def demo_convergence():
    """Show that projection never worsens the approximation error."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    n_verts = 100
    theta = np.linspace(0, 2 * np.pi, n_verts, endpoint=False)
    disk = np.column_stack([np.cos(theta), np.sin(theta)])

    f = np.array([0.3, 0.4])

    np.random.seed(123)
    n_trials = 500
    errors_before = []
    errors_after = []

    for _ in range(n_trials):
        direction = np.random.randn(2)
        direction /= np.linalg.norm(direction)
        dist = np.random.exponential(0.5)
        G = f + dist * direction
        proj_G = project_onto_convex(G, disk)
        errors_before.append(np.linalg.norm(f - G))
        errors_after.append(np.linalg.norm(f - proj_G))

    errors_before = np.array(errors_before)
    errors_after = np.array(errors_after)

    ax.scatter(errors_before, errors_after, alpha=0.3, s=15, c='steelblue',
              label='$(\\|f-G\\|, \\|f-\\pi_C(G)\\|)$')
    max_err = max(errors_before.max(), errors_after.max())
    ax.plot([0, max_err], [0, max_err], 'r--', lw=2, label='$y = x$ (identity line)')
    ax.fill_between([0, max_err], [0, 0], [0, max_err], alpha=0.05, color='green')

    ax.set_xlabel('$\\|f - G\\|$ (ambient error)', fontsize=12)
    ax.set_ylabel('$\\|f - \\pi_C(G)\\|$ (constrained error)', fontsize=12)
    ax.set_title('Projection Never Worsens Approximation\n'
                '(1-Lipschitz: all points below the diagonal)', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.set_xlim(0, max_err * 1.05)
    ax.set_ylim(0, max_err * 1.05)

    plt.tight_layout()
    plt.savefig('demos/figures/convergence_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved demos/figures/convergence_comparison.png")
    print(f"  All points below diagonal: {np.all(errors_after <= errors_before + 1e-10)}")


if __name__ == '__main__':
    print("=" * 60)
    print("Convex Retraction & Constrained Approximation Demos")
    print("=" * 60)
    print()
    demo_metric_projection()
    demo_constrained_approximation()
    demo_convergence()
    print()
    print("All demos complete! Figures saved to demos/figures/")
