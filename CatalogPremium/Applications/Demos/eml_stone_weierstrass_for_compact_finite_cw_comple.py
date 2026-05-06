"""
Applications of Retraction-Based Approximation
================================================

This demo shows practical applications of the "approximate then retract"
paradigm for non-convex targets:

1. Robotics: Path planning on configuration spaces
2. Computer Graphics: Curve approximation on surfaces
3. Physics: Order parameter field approximation
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import os

# ============================================================
# Application 1: Robotics - Path on a torus
# ============================================================

def demo_torus_path():
    """
    A robot arm with two rotational joints has configuration space T² (torus).
    Approximate a desired trajectory on the torus using Euclidean polynomials
    then retracting back to the torus.
    """
    n = 500
    t = np.linspace(0, 2 * np.pi, n, endpoint=False)

    # Torus parameters
    R, r_torus = 2.0, 0.7

    # Torus embedding in ℝ³: (θ, φ) → ((R + r·cos(φ))·cos(θ), (R + r·cos(φ))·sin(θ), r·sin(φ))
    def torus_embed(theta, phi):
        x = (R + r_torus * np.cos(phi)) * np.cos(theta)
        y = (R + r_torus * np.cos(phi)) * np.sin(theta)
        z = r_torus * np.sin(phi)
        return np.column_stack([x, y, z])

    def torus_retract(points):
        """Nearest-point retraction onto the torus (approximate)."""
        # Project to torus: first find θ from (x,y), then find φ
        x, y, z = points[:, 0], points[:, 1], points[:, 2]
        theta = np.arctan2(y, x)
        # Distance from z-axis projected point to center of tube
        dist_xy = np.sqrt(x**2 + y**2)
        dx = dist_xy - R
        phi = np.arctan2(z, dx)
        return torus_embed(theta, phi)

    # Target path on torus: a (3,2) torus knot trajectory
    theta_path = 3 * t
    phi_path = 2 * t
    target = torus_embed(theta_path, phi_path)

    # Polynomial approximation in ℝ³ (Fourier truncation)
    def fourier_approx_3d(vals, deg):
        result = np.zeros_like(vals)
        for j in range(3):
            coeffs = np.fft.fft(vals[:, j]) / n
            mask = np.zeros(n, dtype=complex)
            mask[:deg+1] = 1
            mask[-deg:] = 1
            result[:, j] = np.fft.ifft(coeffs * mask * n).real
        return result

    fig = plt.figure(figsize=(16, 6))

    for idx, deg in enumerate([5, 15, 40]):
        ax = fig.add_subplot(1, 3, idx + 1, projection='3d')

        # Draw torus surface
        u = np.linspace(0, 2 * np.pi, 50)
        v = np.linspace(0, 2 * np.pi, 50)
        U, V = np.meshgrid(u, v)
        X = (R + r_torus * np.cos(V)) * np.cos(U)
        Y = (R + r_torus * np.cos(V)) * np.sin(U)
        Z = r_torus * np.sin(V)
        ax.plot_surface(X, Y, Z, alpha=0.1, color='gray')

        # Approximate and retract
        g = fourier_approx_3d(target, deg)
        h = torus_retract(g)

        error = np.max(np.linalg.norm(h - target, axis=1))

        ax.plot(target[:, 0], target[:, 1], target[:, 2], 'b-',
                linewidth=1.5, label='Target path', alpha=0.7)
        ax.plot(h[:, 0], h[:, 1], h[:, 2], 'r-',
                linewidth=1, label='Retracted approx', alpha=0.8)

        ax.set_title(f'Degree {deg}, error: {error:.4f}', fontsize=10)
        ax.legend(fontsize=8)

    fig.suptitle('Robotics: Path Approximation on Torus (Configuration Space T²)\n'
                 '"Approximate in ℝ³, then retract to T²"',
                 fontsize=13, fontweight='bold')
    plt.savefig('demos/torus_path.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Torus path demo saved to demos/torus_path.png")


# ============================================================
# Application 2: Physics - Spin field on S²
# ============================================================

def demo_spin_field():
    """
    Approximate a spin field configuration on S² (Heisenberg magnet).
    The order parameter at each spatial point is a unit vector on S².
    """
    n_grid = 50
    x = np.linspace(-1, 1, n_grid)
    y = np.linspace(-1, 1, n_grid)
    X, Y = np.meshgrid(x, y)

    # Target spin field: a skyrmion configuration
    # n(x,y) = (sin(f(r))·cos(φ), sin(f(r))·sin(φ), cos(f(r)))
    # where r = sqrt(x² + y²), φ = atan2(y,x), f(r) = π·exp(-r²)
    R = np.sqrt(X**2 + Y**2)
    Phi = np.arctan2(Y, X)
    F = np.pi * np.exp(-2 * R**2)

    nx_target = np.sin(F) * np.cos(Phi)
    ny_target = np.sin(F) * np.sin(Phi)
    nz_target = np.cos(F)

    # Flatten for approximation
    target_flat = np.column_stack([nx_target.ravel(), ny_target.ravel(), nz_target.ravel()])

    # Low-rank polynomial approximation (keep only low spatial frequencies)
    def spatial_lowpass(field_2d, cutoff):
        ft = np.fft.fft2(field_2d)
        mask = np.zeros_like(ft)
        mask[:cutoff, :cutoff] = 1
        mask[:cutoff, -cutoff:] = 1
        mask[-cutoff:, :cutoff] = 1
        mask[-cutoff:, -cutoff:] = 1
        return np.fft.ifft2(ft * mask).real

    def sphere_retract(v):
        """Retract to S²: v ↦ v/‖v‖."""
        norms = np.linalg.norm(v, axis=-1, keepdims=True)
        norms = np.maximum(norms, 1e-10)
        return v / norms

    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    cutoffs = [3, 8, 20]
    for idx, cut in enumerate(cutoffs):
        # Polynomial approximation (spatial low-pass)
        nx_approx = spatial_lowpass(nx_target, cut)
        ny_approx = spatial_lowpass(ny_target, cut)
        nz_approx = spatial_lowpass(nz_target, cut)
        approx_flat = np.column_stack([nx_approx.ravel(), ny_approx.ravel(), nz_approx.ravel()])

        # Retract to S²
        retracted = sphere_retract(approx_flat)
        nx_ret = retracted[:, 0].reshape(n_grid, n_grid)
        ny_ret = retracted[:, 1].reshape(n_grid, n_grid)
        nz_ret = retracted[:, 2].reshape(n_grid, n_grid)

        error = np.max(np.linalg.norm(retracted - target_flat, axis=1))

        # Plot nz component (colormap)
        ax = axes[0, idx]
        im = ax.imshow(nz_ret, extent=[-1, 1, -1, 1], cmap='RdBu',
                       vmin=-1, vmax=1, origin='lower')
        ax.set_title(f'nz (cutoff={cut}), error: {error:.3f}')
        ax.set_aspect('equal')
        plt.colorbar(im, ax=ax, shrink=0.8)

        # Plot vector field
        ax = axes[1, idx]
        step = 4
        ax.quiver(X[::step, ::step], Y[::step, ::step],
                  nx_ret[::step, ::step], ny_ret[::step, ::step],
                  nz_ret[::step, ::step], cmap='RdBu', clim=(-1, 1),
                  scale=20, alpha=0.8)
        ax.set_xlim(-1, 1)
        ax.set_ylim(-1, 1)
        ax.set_aspect('equal')
        ax.set_title(f'In-plane spins (cutoff={cut})')

    fig.suptitle('Physics: Skyrmion Spin Field Approximation on S²\n'
                 'Order parameter must be a unit vector → retraction to S²',
                 fontsize=13, fontweight='bold')
    plt.savefig('demos/spin_field.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Spin field demo saved to demos/spin_field.png")


# ============================================================
# Application 3: Graph-valued maps
# ============================================================

def demo_graph_target():
    """
    Approximate maps into a finite graph (1-dimensional CW-complex).
    Graphs are the simplest non-trivial CW-complexes.
    """
    n_points = 500
    t = np.linspace(0, 1, n_points)

    # Define a Y-shaped graph in ℝ²
    # Three edges meeting at the origin
    def graph_nearest_point(points):
        """Project to the nearest point on the Y-graph."""
        edges = [
            (np.array([0, 0]), np.array([0, 1])),      # up
            (np.array([0, 0]), np.array([-0.87, -0.5])), # lower-left
            (np.array([0, 0]), np.array([0.87, -0.5])),  # lower-right
        ]
        result = np.zeros_like(points)
        for i, p in enumerate(points):
            best_dist = np.inf
            best_proj = p
            for a, b in edges:
                d = b - a
                t_param = np.clip(np.dot(p - a, d) / np.dot(d, d), 0, 1)
                proj = a + t_param * d
                dist = np.linalg.norm(p - proj)
                if dist < best_dist:
                    best_dist = dist
                    best_proj = proj
            result[i] = best_proj
        return result

    # Target: a smooth path on the Y-graph
    # Traverse: lower-right → center → up → center → lower-left
    target = np.zeros((n_points, 2))
    seg_len = n_points // 5
    for i in range(n_points):
        if i < seg_len:  # lower-right to center
            s = i / seg_len
            target[i] = (1-s) * np.array([0.87, -0.5])
        elif i < 2*seg_len:  # center to up
            s = (i - seg_len) / seg_len
            target[i] = s * np.array([0, 1])
        elif i < 3*seg_len:  # up to center
            s = (i - 2*seg_len) / seg_len
            target[i] = (1-s) * np.array([0, 1])
        elif i < 4*seg_len:  # center to lower-left
            s = (i - 3*seg_len) / seg_len
            target[i] = s * np.array([-0.87, -0.5])
        else:  # lower-left to center
            s = (i - 4*seg_len) / (n_points - 4*seg_len)
            target[i] = (1-s) * np.array([-0.87, -0.5])

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    degrees = [3, 10, 30]
    for idx, deg in enumerate(degrees):
        # Fourier approximation
        coeffs_x = np.fft.fft(target[:, 0]) / n_points
        coeffs_y = np.fft.fft(target[:, 1]) / n_points
        mask = np.zeros(n_points, dtype=complex)
        mask[:deg+1] = 1
        mask[-deg:] = 1
        g_x = np.fft.ifft(coeffs_x * mask * n_points).real
        g_y = np.fft.ifft(coeffs_y * mask * n_points).real
        g = np.column_stack([g_x, g_y])

        h = graph_nearest_point(g)
        error = np.max(np.linalg.norm(h - target, axis=1))

        ax = axes[idx]
        # Draw graph
        for a, b in [(np.array([0,0]), np.array([0,1])),
                      (np.array([0,0]), np.array([-0.87,-0.5])),
                      (np.array([0,0]), np.array([0.87,-0.5]))]:
            ax.plot([a[0], b[0]], [a[1], b[1]], 'k-', linewidth=3, alpha=0.2)

        ax.plot(target[:, 0], target[:, 1], 'b-', linewidth=2,
                label='Target path', alpha=0.6)
        ax.plot(h[:, 0], h[:, 1], 'r-', linewidth=1,
                label='Retracted approx', alpha=0.8)
        ax.scatter([0], [0], c='black', s=80, zorder=10, marker='o')
        ax.set_aspect('equal')
        ax.set_title(f'Degree {deg}, error: {error:.4f}', fontsize=10)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(-1.2, 1.2)
        ax.set_ylim(-0.8, 1.2)

    fig.suptitle('Finite Graph (Y-Graph): A 1-Dimensional CW-Complex Target\n'
                 'The singular vertex at the origin requires retraction, not projection',
                 fontsize=13, fontweight='bold')
    plt.savefig('demos/graph_target.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Graph target demo saved to demos/graph_target.png")


# ============================================================
# Run all application demos
# ============================================================

if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)
    print("="*60)
    print("Applications of Retraction-Based Approximation")
    print("="*60)
    print()

    demo_torus_path()
    demo_spin_field()
    demo_graph_target()

    print()
    print("="*60)
    print("All application demos completed!")
    print("="*60)


"""
Retraction-Based Approximation on Non-Convex Targets
=====================================================

This demo illustrates the core theorem: continuous maps into a compact
neighborhood retract can be uniformly approximated by retracting
Euclidean-space approximants.

We demonstrate this on the unit circle S¹ ⊂ ℝ², which is the simplest
non-convex compact neighborhood retract. The idea generalizes to any
compact polyhedron or finite CW-complex.

The algorithm:
1. Start with f: X → S¹ (a continuous map into the circle)
2. View f as a map X → ℝ² (via embedding)
3. Approximate f by a polynomial/neural-net map g: X → ℝ² (EML density)
4. Retract g back to S¹ via r(z) = z/‖z‖ (nearest-point retraction)
5. The retracted map h = r∘g approximates f uniformly
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.gridspec import GridSpec
import os

# ============================================================
# Core mathematical objects
# ============================================================

def circle_retraction(z):
    """Retraction r: ℝ² \ {0} → S¹, r(z) = z / ‖z‖."""
    norms = np.linalg.norm(z, axis=-1, keepdims=True)
    norms = np.maximum(norms, 1e-10)  # avoid division by zero
    return z / norms

def polynomial_approx(f_vals, degree=5):
    """
    Approximate a function on [0, 2π] by truncated Fourier/polynomial series.
    Returns the approximation evaluated at the same points.
    """
    n = len(f_vals)
    t = np.linspace(0, 2 * np.pi, n, endpoint=False)
    # Fourier approximation (which is a polynomial in cos/sin)
    coeffs = np.fft.fft(f_vals, axis=0) / n
    # Truncate to `degree` terms
    mask = np.zeros(n, dtype=complex)
    mask[:degree + 1] = 1
    mask[-(degree):] = 1
    approx_coeffs = coeffs * mask[:, None]
    return np.fft.ifft(approx_coeffs * n, axis=0).real

# ============================================================
# Demo 1: Approximating a winding map on S¹
# ============================================================

def demo_circle_approximation():
    """Demonstrate retraction-based approximation for maps X → S¹."""
    n_points = 500
    t = np.linspace(0, 2 * np.pi, n_points, endpoint=False)

    # Target map f: [0, 2π] → S¹, a smooth curve on the circle
    # f(t) = (cos(2t + sin(t)), sin(2t + sin(t)))
    phase = 2 * t + 0.5 * np.sin(3 * t)
    f_vals = np.column_stack([np.cos(phase), np.sin(phase)])

    fig = plt.figure(figsize=(18, 12))
    gs = GridSpec(2, 3, figure=fig, hspace=0.3, wspace=0.3)

    degrees = [2, 5, 15]

    for idx, deg in enumerate(degrees):
        # Step 1: Polynomial approximation in ℝ²
        g_vals = polynomial_approx(f_vals, degree=deg)

        # Step 2: Retract back to S¹
        h_vals = circle_retraction(g_vals)

        # Compute errors
        euclidean_error = np.max(np.linalg.norm(g_vals - f_vals, axis=1))
        retracted_error = np.max(np.linalg.norm(h_vals - f_vals, axis=1))

        # Plot Euclidean approximation
        ax1 = fig.add_subplot(gs[0, idx])
        circle = Circle((0, 0), 1, fill=False, color='gray', linewidth=1, linestyle='--')
        ax1.add_patch(circle)
        ax1.plot(f_vals[:, 0], f_vals[:, 1], 'b-', linewidth=1.5,
                 label='Target f', alpha=0.7)
        ax1.plot(g_vals[:, 0], g_vals[:, 1], 'r-', linewidth=1,
                 label=f'Poly approx g (deg {deg})', alpha=0.7)
        ax1.set_xlim(-1.8, 1.8)
        ax1.set_ylim(-1.8, 1.8)
        ax1.set_aspect('equal')
        ax1.legend(fontsize=8)
        ax1.set_title(f'Euclidean Approx (deg {deg})\nmax error: {euclidean_error:.4f}')
        ax1.grid(True, alpha=0.3)

        # Plot retracted approximation
        ax2 = fig.add_subplot(gs[1, idx])
        circle = Circle((0, 0), 1, fill=False, color='gray', linewidth=1, linestyle='--')
        ax2.add_patch(circle)
        ax2.plot(f_vals[:, 0], f_vals[:, 1], 'b-', linewidth=1.5,
                 label='Target f', alpha=0.7)
        ax2.plot(h_vals[:, 0], h_vals[:, 1], 'g-', linewidth=1,
                 label=f'Retracted h = r∘g', alpha=0.7)
        ax2.set_xlim(-1.5, 1.5)
        ax2.set_ylim(-1.5, 1.5)
        ax2.set_aspect('equal')
        ax2.legend(fontsize=8)
        ax2.set_title(f'After Retraction to S¹\nmax error: {retracted_error:.4f}')
        ax2.grid(True, alpha=0.3)

    fig.suptitle('Retraction-Based Approximation: Maps into S¹ ⊂ ℝ²\n'
                 '(Top: Euclidean polynomial approximation; '
                 'Bottom: after retracting to S¹)',
                 fontsize=14, fontweight='bold')
    plt.savefig('demos/circle_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Circle approximation demo saved to demos/circle_approximation.png")


# ============================================================
# Demo 2: Approximation on a figure-eight (wedge of circles)
# ============================================================

def demo_figure_eight():
    """
    Demonstrate approximation on a figure-eight, which is a finite
    CW-complex that is NOT a manifold (it has a singular point).
    """
    n_points = 1000
    t = np.linspace(0, 2 * np.pi, n_points, endpoint=False)

    # Figure-eight as image in ℝ²: (sin(2t), sin(t))
    figure_eight = np.column_stack([np.sin(2 * t), np.sin(t)])

    # Target map: a curve traversing the figure-eight with varying speed
    phase = t + 0.3 * np.sin(5 * t)
    target = np.column_stack([np.sin(2 * phase), np.sin(phase)])

    # Retraction: project to nearest point on the figure-eight
    # (for demo purposes, we use parameter-based nearest-point projection)
    def figure_eight_retraction(points, n_search=2000):
        """Nearest-point projection onto the figure-eight."""
        s = np.linspace(0, 2 * np.pi, n_search)
        curve = np.column_stack([np.sin(2 * s), np.sin(s)])
        result = np.zeros_like(points)
        for i, p in enumerate(points):
            dists = np.linalg.norm(curve - p, axis=1)
            result[i] = curve[np.argmin(dists)]
        return result

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    degrees = [3, 10, 30]
    for idx, deg in enumerate(degrees):
        g_vals = polynomial_approx(target, degree=deg)
        h_vals = figure_eight_retraction(g_vals)

        error_before = np.max(np.linalg.norm(g_vals - target, axis=1))
        error_after = np.max(np.linalg.norm(h_vals - target, axis=1))

        ax = axes[idx]
        ax.plot(figure_eight[:, 0], figure_eight[:, 1], 'k-',
                linewidth=0.5, alpha=0.3, label='Figure-eight')
        ax.plot(target[:, 0], target[:, 1], 'b-', linewidth=1.5,
                label='Target', alpha=0.6)
        ax.plot(h_vals[:, 0], h_vals[:, 1], 'r-', linewidth=1,
                label='Retracted approx', alpha=0.8)
        ax.set_aspect('equal')
        ax.legend(fontsize=8)
        ax.set_title(f'Degree {deg}\n'
                     f'ℝ² error: {error_before:.4f}, '
                     f'Retracted error: {error_after:.4f}')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Approximation on Figure-Eight (Non-Manifold CW-Complex)\n'
                 'The singular point at the origin is handled by retraction',
                 fontsize=13, fontweight='bold')
    plt.savefig('demos/figure_eight_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure-eight demo saved to demos/figure_eight_approximation.png")


# ============================================================
# Demo 3: Convergence rate analysis
# ============================================================

def demo_convergence():
    """Plot the convergence of retracted approximation error vs degree."""
    n_points = 500
    t = np.linspace(0, 2 * np.pi, n_points, endpoint=False)

    # Target map f: [0, 2π] → S¹
    phase = 2 * t + 0.5 * np.sin(3 * t)
    f_vals = np.column_stack([np.cos(phase), np.sin(phase)])

    degrees = range(1, 50)
    euclidean_errors = []
    retracted_errors = []

    for deg in degrees:
        g_vals = polynomial_approx(f_vals, degree=deg)
        h_vals = circle_retraction(g_vals)
        euclidean_errors.append(np.max(np.linalg.norm(g_vals - f_vals, axis=1)))
        retracted_errors.append(np.max(np.linalg.norm(h_vals - f_vals, axis=1)))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(list(degrees), euclidean_errors, 'b-o', markersize=3,
                label='Euclidean approx error ‖g - f‖')
    ax.semilogy(list(degrees), retracted_errors, 'r-s', markersize=3,
                label='Retracted approx error ‖r∘g - f‖')
    ax.set_xlabel('Approximation degree', fontsize=12)
    ax.set_ylabel('Maximum error (sup norm)', fontsize=12)
    ax.set_title('Convergence of Retraction-Based Approximation\n'
                 'Retraction preserves convergence rate',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 50)

    plt.savefig('demos/convergence_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Convergence analysis saved to demos/convergence_analysis.png")


# ============================================================
# Demo 4: Thickening / tubular neighborhood visualization
# ============================================================

def demo_thickening():
    """
    Visualize the key geometric lemma: a compact set inside an open set
    has a uniform tubular neighborhood still inside the open set.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Circle with tubular neighborhood
    theta = np.linspace(0, 2 * np.pi, 200)
    circle_x = np.cos(theta)
    circle_y = np.sin(theta)

    ax = axes[0]
    # Open set U (annulus)
    for r in [0.6, 1.5]:
        ax.plot(r * np.cos(theta), r * np.sin(theta), 'g--',
                linewidth=1, alpha=0.5)
    ax.fill_between(1.5 * np.cos(theta), 1.5 * np.sin(theta),
                     alpha=0.1, color='green', label='Open set U')

    # Uniform δ-thickening
    delta = 0.25
    for sign in [-1, 1]:
        r = 1 + sign * delta
        ax.plot(r * np.cos(theta), r * np.sin(theta), 'r-',
                linewidth=1.5, alpha=0.7)
    ax.fill_between((1 + delta) * np.cos(theta), (1 + delta) * np.sin(theta),
                     (1 - delta) * np.cos(theta), (1 - delta) * np.sin(theta),
                     alpha=0.2, color='red', label=f'δ-thickening (δ={delta})')

    # The compact set P (circle)
    ax.plot(circle_x, circle_y, 'b-', linewidth=2.5, label='Compact P = S¹')
    ax.set_aspect('equal')
    ax.set_title('Uniform Tubular Neighborhood\n(exists_thickening_subset_open)',
                 fontsize=11)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)

    # Right: The approximation scheme
    ax = axes[1]
    ax.plot(circle_x, circle_y, 'b-', linewidth=2, label='Target P = S¹')

    # Show a few approximation points and their retractions
    np.random.seed(42)
    n_demo = 12
    angles = np.linspace(0, 2 * np.pi, n_demo, endpoint=False)
    target_pts = np.column_stack([np.cos(angles), np.sin(angles)])
    perturbations = 0.15 * np.random.randn(n_demo, 2)
    approx_pts = target_pts + perturbations
    retracted_pts = circle_retraction(approx_pts)

    for i in range(n_demo):
        ax.plot([target_pts[i, 0], approx_pts[i, 0]],
                [target_pts[i, 1], approx_pts[i, 1]], 'r-', alpha=0.4)
        ax.plot([approx_pts[i, 0], retracted_pts[i, 0]],
                [approx_pts[i, 1], retracted_pts[i, 1]], 'g-', alpha=0.6)

    ax.scatter(target_pts[:, 0], target_pts[:, 1], c='blue', s=40,
               zorder=5, label='f(x) ∈ P')
    ax.scatter(approx_pts[:, 0], approx_pts[:, 1], c='red', s=30,
               zorder=5, marker='^', label='g(x) ∈ ℝ² (approx)')
    ax.scatter(retracted_pts[:, 0], retracted_pts[:, 1], c='green', s=30,
               zorder=5, marker='s', label='h(x) = r(g(x)) ∈ P')

    ax.set_aspect('equal')
    ax.set_title('Approximate then Retract\n(eml_approx_via_retraction)',
                 fontsize=11)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)

    fig.suptitle('Geometric Ingredients of the Retraction Approximation Theorem',
                 fontsize=13, fontweight='bold')
    plt.savefig('demos/thickening_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Thickening visualization saved to demos/thickening_visualization.png")


# ============================================================
# Run all demos
# ============================================================

if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)
    print("="*60)
    print("EML Retraction-Based Approximation Demos")
    print("="*60)
    print()

    demo_circle_approximation()
    demo_figure_eight()
    demo_convergence()
    demo_thickening()

    print()
    print("="*60)
    print("All demos completed successfully!")
    print("="*60)
