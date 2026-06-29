"""
Polyhedral Retraction Approximation Demo
=========================================

This script demonstrates the key geometric ideas from the formally verified
Stone-Weierstrass theorem for compact polyhedral codomains:

1. A compact polyhedron K in R^n has an open neighborhood U with a continuous retraction r: U -> K.
2. Any continuous map f: X -> K can be uniformly approximated by r ∘ g, where g is a
   smooth/polynomial ambient approximant.

We illustrate this with:
- A triangle in R^2 as the polyhedron K
- A continuous curve mapping [0, 2π] -> K (a path along the triangle boundary)
- Polynomial approximation in the ambient R^2
- Retraction back to K via nearest-point projection

This is the numerical companion to the Lean 4 formalization in
EML/StoneWeierstrass/PolyhedronCodomain.lean
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import matplotlib.colors as mcolors
from scipy.spatial import ConvexHull

# ============================================================================
# Part 1: Define the polyhedron K and retraction r
# ============================================================================

# Triangle vertices in R^2
VERTICES = np.array([
    [0.0, 0.0],
    [1.0, 0.0],
    [0.5, np.sqrt(3)/2]
])

def point_in_triangle(p, v0, v1, v2):
    """Check if point p is inside triangle (v0, v1, v2) using barycentric coordinates."""
    d00 = np.dot(v1 - v0, v1 - v0)
    d01 = np.dot(v1 - v0, v2 - v0)
    d11 = np.dot(v2 - v0, v2 - v0)
    d20 = np.dot(p - v0, v1 - v0)
    d21 = np.dot(p - v0, v2 - v0)
    denom = d00 * d11 - d01 * d01
    if abs(denom) < 1e-12:
        return False
    v = (d11 * d20 - d01 * d21) / denom
    w = (d00 * d21 - d01 * d20) / denom
    u = 1 - v - w
    return (u >= -1e-10) and (v >= -1e-10) and (w >= -1e-10)

def project_to_segment(p, a, b):
    """Project point p onto line segment [a, b]."""
    ab = b - a
    t = np.dot(p - a, ab) / (np.dot(ab, ab) + 1e-15)
    t = np.clip(t, 0, 1)
    return a + t * ab

def nearest_point_on_triangle(p, vertices):
    """Find the nearest point on the triangle to p (nearest-point retraction)."""
    if point_in_triangle(p, *vertices):
        return p.copy()
    
    # Project onto each edge and find closest
    best_dist = np.inf
    best_point = None
    n = len(vertices)
    for i in range(n):
        proj = project_to_segment(p, vertices[i], vertices[(i+1) % n])
        d = np.linalg.norm(p - proj)
        if d < best_dist:
            best_dist = d
            best_point = proj
    return best_point

def retraction(p, vertices=VERTICES):
    """Continuous retraction r: R^2 -> K (nearest-point projection onto triangle)."""
    return nearest_point_on_triangle(p, vertices)

# ============================================================================
# Part 2: Define a continuous curve f: [0, 2π] -> K
# ============================================================================

def target_curve(t):
    """A continuous map f: [0, 2π] -> K tracing the triangle boundary."""
    # Parameterize the boundary of the triangle
    t_mod = t % (2 * np.pi)
    frac = t_mod / (2 * np.pi) * 3  # 0 to 3
    
    if frac < 1:
        # Edge 0->1
        return VERTICES[0] + frac * (VERTICES[1] - VERTICES[0])
    elif frac < 2:
        # Edge 1->2
        return VERTICES[1] + (frac - 1) * (VERTICES[2] - VERTICES[1])
    else:
        # Edge 2->0
        return VERTICES[2] + (frac - 2) * (VERTICES[0] - VERTICES[2])

# ============================================================================
# Part 3: Polynomial approximation in ambient R^2
# ============================================================================

def polynomial_approx(t_vals, f_vals, degree=5):
    """Fit a polynomial of given degree to approximate f in R^2."""
    coeffs_x = np.polyfit(t_vals, f_vals[:, 0], degree)
    coeffs_y = np.polyfit(t_vals, f_vals[:, 1], degree)
    
    def g(t):
        return np.array([np.polyval(coeffs_x, t), np.polyval(coeffs_y, t)])
    
    return g

# ============================================================================
# Part 4: Visualization
# ============================================================================

def demo_approximation():
    """Main demo: show ambient approximation + retraction."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Sample the target curve
    t_dense = np.linspace(0, 2 * np.pi, 500)
    f_vals = np.array([target_curve(t) for t in t_dense])
    
    # Fit polynomial approximants of different degrees
    t_fit = np.linspace(0, 2 * np.pi, 50)
    f_fit = np.array([target_curve(t) for t in t_fit])
    
    degrees = [3, 7, 15]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    for ax_idx, (degree, color) in enumerate(zip(degrees, colors)):
        ax = axes[ax_idx]
        
        # Draw the triangle K
        triangle = Polygon(VERTICES, fill=True, facecolor='#ecf0f1', 
                          edgecolor='black', linewidth=2, label='K (triangle)')
        ax.add_patch(triangle)
        
        # Draw the target curve f
        ax.plot(f_vals[:, 0], f_vals[:, 1], 'k-', linewidth=2, label='f (target)', zorder=3)
        
        # Compute polynomial approximation g
        g = polynomial_approx(t_fit, f_fit, degree=degree)
        g_vals = np.array([g(t) for t in t_dense])
        
        # Draw the ambient approximant g (may leave K)
        ax.plot(g_vals[:, 0], g_vals[:, 1], '--', color=color, linewidth=1.5, 
                alpha=0.7, label=f'g (degree {degree})', zorder=4)
        
        # Retract: h = r ∘ g
        h_vals = np.array([retraction(g(t)) for t in t_dense])
        ax.plot(h_vals[:, 0], h_vals[:, 1], '-', color=color, linewidth=2.5, 
                label=f'r∘g (retracted)', zorder=5)
        
        # Draw retraction arrows for a few sample points
        t_arrows = np.linspace(0.3, 5.8, 8)
        for t in t_arrows:
            gp = g(t)
            hp = retraction(gp)
            if np.linalg.norm(gp - hp) > 0.01:
                ax.annotate('', xy=hp, xytext=gp,
                           arrowprops=dict(arrowstyle='->', color='gray', 
                                          alpha=0.5, lw=1))
        
        # Compute approximation error
        errors = np.array([np.linalg.norm(h_vals[i] - f_vals[i]) for i in range(len(t_dense))])
        max_error = np.max(errors)
        
        ax.set_xlim(-0.3, 1.3)
        ax.set_ylim(-0.3, 1.2)
        ax.set_aspect('equal')
        ax.legend(loc='upper right', fontsize=8)
        ax.set_title(f'Degree {degree} | max error: {max_error:.4f}', fontsize=12)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Stone-Weierstrass for Polyhedral Codomains:\n'
                 'Ambient Polynomial Approximation + Retraction to Triangle',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/polyhedral_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/polyhedral_approximation.png")

def demo_tubular_margin():
    """Visualize the uniform tubular margin δ around K."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Draw thickenings of the triangle
    deltas = [0.3, 0.2, 0.1, 0.05]
    cmap = plt.cm.Blues
    
    for i, delta in enumerate(deltas):
        # Sample points and check if they're within delta of K
        x_range = np.linspace(-0.5, 1.5, 300)
        y_range = np.linspace(-0.5, 1.3, 300)
        X, Y = np.meshgrid(x_range, y_range)
        
        # Compute distance to triangle for each point
        Z = np.zeros_like(X)
        for ix in range(X.shape[0]):
            for iy in range(X.shape[1]):
                p = np.array([X[ix, iy], Y[ix, iy]])
                np_point = nearest_point_on_triangle(p, VERTICES)
                Z[ix, iy] = np.linalg.norm(p - np_point)
        
        ax.contour(X, Y, Z, levels=[delta], colors=[cmap(0.3 + 0.15*i)], linewidths=2)
        ax.contourf(X, Y, Z, levels=[0, delta], colors=[cmap(0.1 + 0.1*i)], alpha=0.15)
    
    # Draw the triangle
    triangle = Polygon(VERTICES, fill=True, facecolor='#e74c3c', 
                      edgecolor='black', linewidth=2.5, alpha=0.8)
    ax.add_patch(triangle)
    
    # Labels
    for i, delta in enumerate(deltas):
        ax.text(1.1, 0.9 - i*0.08, f'δ = {delta}', fontsize=11, 
                color=cmap(0.3 + 0.15*i), fontweight='bold')
    
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 1.3)
    ax.set_aspect('equal')
    ax.set_title('Uniform Tubular Margin: thickening(δ, K) ⊆ U\n'
                 '(Key geometric lemma: exists_thickening_subset_open)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/tubular_margin.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/tubular_margin.png")

def demo_convergence():
    """Show convergence of approximation error as polynomial degree increases."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    t_dense = np.linspace(0, 2 * np.pi, 500)
    f_vals = np.array([target_curve(t) for t in t_dense])
    
    t_fit = np.linspace(0, 2 * np.pi, 80)
    f_fit = np.array([target_curve(t) for t in t_fit])
    
    degrees = list(range(3, 26))
    max_errors_ambient = []
    max_errors_retracted = []
    
    for degree in degrees:
        g = polynomial_approx(t_fit, f_fit, degree=degree)
        g_vals = np.array([g(t) for t in t_dense])
        h_vals = np.array([retraction(g(t)) for t in t_dense])
        
        err_ambient = np.max(np.linalg.norm(g_vals - f_vals, axis=1))
        err_retracted = np.max(np.linalg.norm(h_vals - f_vals, axis=1))
        
        max_errors_ambient.append(err_ambient)
        max_errors_retracted.append(err_retracted)
    
    # Plot convergence
    ax1.semilogy(degrees, max_errors_ambient, 'o--', color='#e74c3c', 
                label='Ambient error ‖g - f‖', markersize=5)
    ax1.semilogy(degrees, max_errors_retracted, 's-', color='#2ecc71', 
                label='Retracted error ‖r∘g - f‖', markersize=5, linewidth=2)
    ax1.set_xlabel('Polynomial degree', fontsize=12)
    ax1.set_ylabel('Max uniform error', fontsize=12)
    ax1.set_title('Convergence: Ambient vs. Retracted Approximation', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Show the error ratio
    ratios = [r/a if a > 1e-15 else 1.0 for a, r in zip(max_errors_ambient, max_errors_retracted)]
    ax2.plot(degrees, ratios, 'D-', color='#9b59b6', markersize=5, linewidth=2)
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Polynomial degree', fontsize=12)
    ax2.set_ylabel('Error ratio (retracted / ambient)', fontsize=12)
    ax2.set_title('Retraction is a 1-Lipschitz projection:\nerror never increases', fontsize=13)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.5)
    
    plt.tight_layout()
    plt.savefig('demos/convergence_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/convergence_analysis.png")

def demo_3d_polyhedron():
    """Demo with a 3D polyhedron: tetrahedron in R^3."""
    from mpl_toolkits.mplot3d import Axes3D
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection
    
    # Tetrahedron vertices
    tet_vertices = np.array([
        [0, 0, 0],
        [1, 0, 0],
        [0.5, np.sqrt(3)/2, 0],
        [0.5, np.sqrt(3)/6, np.sqrt(6)/3]
    ], dtype=float)
    
    def nearest_point_tetrahedron(p, verts):
        """Simple nearest-point retraction onto a tetrahedron (brute force via faces)."""
        from itertools import combinations
        best = None
        best_dist = np.inf
        
        # Check if inside (simplified: project to centroid if close)
        centroid = verts.mean(axis=0)
        
        # Project onto each face (triangle)
        for face_idx in combinations(range(4), 3):
            face_verts = verts[list(face_idx)]
            proj = nearest_point_on_triangle(p[:2] if len(p) == 2 else p, face_verts)
            d = np.linalg.norm(p - proj)
            if d < best_dist:
                best_dist = d
                best = proj
        
        # Also check vertices
        for v in verts:
            d = np.linalg.norm(p - v)
            if d < best_dist:
                best_dist = d
                best = v.copy()
        
        return best
    
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    
    # Draw tetrahedron faces
    faces = [[0,1,2], [0,1,3], [0,2,3], [1,2,3]]
    face_collection = Poly3DCollection(
        [tet_vertices[face] for face in faces],
        alpha=0.15, facecolor='cyan', edgecolor='black', linewidth=1.5
    )
    ax.add_collection3d(face_collection)
    
    # Create a curve on the tetrahedron surface (path along edges)
    t = np.linspace(0, 2*np.pi, 200)
    f_curve = np.zeros((len(t), 3))
    for i, ti in enumerate(t):
        frac = (ti / (2*np.pi)) * 4
        edge = int(frac) % 4
        s = frac - int(frac)
        edges = [(0,1), (1,2), (2,3), (3,0)]
        a, b = edges[edge]
        f_curve[i] = tet_vertices[a] + s * (tet_vertices[b] - tet_vertices[a])
    
    ax.plot(f_curve[:, 0], f_curve[:, 1], f_curve[:, 2], 'k-', linewidth=2, label='f (target)')
    
    # Polynomial approximation in R^3
    coeffs = [np.polyfit(t, f_curve[:, j], 8) for j in range(3)]
    g_curve = np.array([[np.polyval(c, ti) for c in coeffs] for ti in t])
    ax.plot(g_curve[:, 0], g_curve[:, 1], g_curve[:, 2], 'r--', linewidth=1.5, 
            alpha=0.6, label='g (ambient approx)')
    
    # Retract
    h_curve = np.array([nearest_point_tetrahedron(g, tet_vertices) for g in g_curve])
    ax.plot(h_curve[:, 0], h_curve[:, 1], h_curve[:, 2], 'g-', linewidth=2.5, 
            label='r∘g (retracted)')
    
    ax.set_title('3D Polyhedral Approximation:\nTetrahedron in ℝ³', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('demos/3d_polyhedron_demo.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/3d_polyhedron_demo.png")

# ============================================================================
# Part 5: Application — Robot arm configuration space
# ============================================================================

def demo_robot_arm():
    """
    Application: Approximating trajectories on a configuration-space polyhedron.
    
    A simplified 2-link robot arm has joint angles (θ₁, θ₂) constrained
    to a convex polygon (the "safe zone") in configuration space.
    We approximate a desired trajectory using the retraction method.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Configuration space: a hexagonal safe zone
    n_sides = 6
    angles = np.linspace(0, 2*np.pi, n_sides, endpoint=False)
    hex_vertices = np.array([[0.5*np.cos(a) + 0.5, 0.5*np.sin(a) + 0.5] for a in angles])
    
    # Target trajectory in config space (stays on boundary)
    t = np.linspace(0, 2*np.pi, 300)
    config_target = np.array([
        [0.5 + 0.45*np.cos(ti), 0.5 + 0.45*np.sin(ti)] for ti in t
    ])
    
    # Retract onto hexagon
    def retract_hexagon(p):
        # Nearest point on convex hull
        from scipy.spatial import ConvexHull
        hull = ConvexHull(hex_vertices)
        
        # Check if inside
        from matplotlib.path import Path
        path = Path(hex_vertices)
        if path.contains_point(p):
            return p.copy()
        
        # Project to nearest edge
        best_dist = np.inf
        best_point = p.copy()
        n = len(hex_vertices)
        for i in range(n):
            proj = project_to_segment(p, hex_vertices[i], hex_vertices[(i+1) % n])
            d = np.linalg.norm(p - proj)
            if d < best_dist:
                best_dist = d
                best_point = proj
        return best_point
    
    # Fourier/polynomial approximation
    coeffs_x = np.polyfit(t, config_target[:, 0], 12)
    coeffs_y = np.polyfit(t, config_target[:, 1], 12)
    g_vals = np.array([[np.polyval(coeffs_x, ti), np.polyval(coeffs_y, ti)] for ti in t])
    h_vals = np.array([retract_hexagon(g) for g in g_vals])
    
    # Config space plot
    hex_patch = Polygon(hex_vertices, fill=True, facecolor='#d5f5e3', 
                       edgecolor='#27ae60', linewidth=2)
    ax1.add_patch(hex_patch)
    ax1.plot(config_target[:, 0], config_target[:, 1], 'k-', linewidth=2, label='Desired trajectory')
    ax1.plot(g_vals[:, 0], g_vals[:, 1], 'r--', linewidth=1.5, alpha=0.5, label='Polynomial approx')
    ax1.plot(h_vals[:, 0], h_vals[:, 1], 'b-', linewidth=2.5, label='Retracted (safe)')
    ax1.set_xlim(-0.2, 1.2)
    ax1.set_ylim(-0.2, 1.2)
    ax1.set_aspect('equal')
    ax1.legend(fontsize=10)
    ax1.set_title('Configuration Space\n(Joint Angle Constraints)', fontsize=13)
    ax1.set_xlabel('θ₁')
    ax1.set_ylabel('θ₂')
    ax1.grid(True, alpha=0.3)
    
    # Error plot
    errors = np.linalg.norm(h_vals - config_target, axis=1)
    ax2.plot(t, errors, 'b-', linewidth=2)
    ax2.fill_between(t, 0, errors, alpha=0.2, color='blue')
    ax2.set_xlabel('Parameter t', fontsize=12)
    ax2.set_ylabel('Approximation error', fontsize=12)
    ax2.set_title('Uniform Error ‖r∘g - f‖\n(Bounded by retraction theorem)', fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/robot_arm_application.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/robot_arm_application.png")

# ============================================================================
# Run all demos
# ============================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("Polyhedral Retraction Approximation — Demo Suite")
    print("=" * 60)
    print()
    
    print("Demo 1: Ambient approximation + retraction to triangle")
    demo_approximation()
    
    print("\nDemo 2: Uniform tubular margin visualization")
    demo_tubular_margin()
    
    print("\nDemo 3: Convergence analysis")
    demo_convergence()
    
    print("\nDemo 4: 3D polyhedron (tetrahedron)")
    demo_3d_polyhedron()
    
    print("\nDemo 5: Robot arm application")
    demo_robot_arm()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
