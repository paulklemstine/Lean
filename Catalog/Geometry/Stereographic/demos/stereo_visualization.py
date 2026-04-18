#!/usr/bin/env python3
"""
Stereographic Projection: Interactive Visualization Suite
=========================================================

Comprehensive visualizations of N-dimensional stereographic projection,
demonstrating all key theorems from the formalization.

Requirements: pip install numpy matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D, proj3d
import matplotlib.gridspec as gridspec

# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def sq_norm_fin(y):
    """sqNormFin: sum of squares of coordinates"""
    return np.sum(y**2, axis=-1)

def stereo_denom(y):
    """stereoDenom: 1 + ||y||^2, always positive"""
    return 1.0 + sq_norm_fin(y)

def inv_stereo_n(y):
    """invStereoN: inverse stereographic projection R^N -> S^N subset R^{N+1}
    
    For i < N: coordinate is 2*y_i / (1 + ||y||^2)
    For i = N: coordinate is (||y||^2 - 1) / (1 + ||y||^2)
    """
    y = np.atleast_2d(y)
    D = stereo_denom(y)
    S = sq_norm_fin(y)
    
    first_coords = 2 * y / D[..., np.newaxis]
    last_coord = (S - 1) / D
    
    return np.concatenate([first_coords, last_coord[..., np.newaxis]], axis=-1)

def stereo_n(x):
    """stereoN: forward stereographic projection from north pole"""
    x = np.atleast_2d(x)
    last = x[..., -1:]
    first = x[..., :-1]
    return first / (1 - last)

def inv_stereo_s(y):
    """invStereoS: inverse stereographic projection from south pole"""
    y = np.atleast_2d(y)
    D = stereo_denom(y)
    S = sq_norm_fin(y)
    
    first_coords = 2 * y / D[..., np.newaxis]
    last_coord = (1 - S) / D  # Note: sign flip from invStereoN
    
    return np.concatenate([first_coords, last_coord[..., np.newaxis]], axis=-1)

def conformal_factor(y):
    """The conformal factor 2/D"""
    return 2.0 / stereo_denom(y)

def moebius_1d(a, b, c, d, z):
    """1D Mobius transformation z -> (az+b)/(cz+d)"""
    return (a*z + b) / (c*z + d)


# ============================================================
# Demo 1: Lines Map to Circles (Theorem: line_image_on_sphere)
# ============================================================

def demo_line_to_circle():
    """Demonstrates that lines in R^2 map to circles on S^2."""
    fig = plt.figure(figsize=(16, 6))
    
    # Left: Lines in R^2
    ax1 = fig.add_subplot(121)
    colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
    
    directions = [
        (np.array([1, 0]), np.array([0, 0]), "Horizontal through origin"),
        (np.array([0, 1]), np.array([1, 0]), "Vertical at x=1"),
        (np.array([1, 1])/np.sqrt(2), np.array([0, 0]), "Diagonal"),
        (np.array([1, -1])/np.sqrt(2), np.array([0, 1]), "Anti-diagonal at y=1"),
        (np.array([1, 2])/np.sqrt(5), np.array([-1, 0]), "Slanted"),
    ]
    
    t = np.linspace(-3, 3, 200)
    
    for idx, (v, p, label) in enumerate(directions):
        line = p + np.outer(t, v)
        ax1.plot(line[:, 0], line[:, 1], color=colors[idx], linewidth=2, label=label)
    
    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-4, 4)
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)
    ax1.set_title("Lines in ℝ²", fontsize=14, fontweight='bold')
    ax1.set_xlabel("x")
    ax1.set_ylabel("y")
    ax1.legend(fontsize=8)
    
    # Right: Their images on S^2
    ax2 = fig.add_subplot(122, projection='3d')
    
    # Draw transparent sphere
    u_s = np.linspace(0, 2*np.pi, 50)
    v_s = np.linspace(0, np.pi, 30)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax2.plot_surface(xs, ys, zs, alpha=0.08, color='lightblue')
    
    t_dense = np.linspace(-10, 10, 1000)
    
    for idx, (v, p, label) in enumerate(directions):
        line = p + np.outer(t_dense, v)
        sphere_pts = inv_stereo_n(line)
        ax2.plot(sphere_pts[:, 0], sphere_pts[:, 1], sphere_pts[:, 2],
                color=colors[idx], linewidth=2, label=label)
    
    # Mark north pole
    ax2.scatter([0], [0], [1], color='red', s=100, marker='*', zorder=5, label='North Pole')
    
    ax2.set_title("Circles on S²\n(Images under invStereoN)", fontsize=14, fontweight='bold')
    ax2.set_xlabel("x₁")
    ax2.set_ylabel("x₂")
    ax2.set_zlabel("x₃")
    ax2.legend(fontsize=7, loc='upper left')
    
    plt.tight_layout()
    plt.savefig("demos/line_to_circle.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Lines → Circles saved to demos/line_to_circle.png")


# ============================================================
# Demo 2: Hemisphere Characterization 
# (Theorems: unit_ball_to_southern, unit_sphere_to_equator, exterior_to_northern)
# ============================================================

def demo_hemisphere_characterization():
    """Shows how ||y|| determines which hemisphere the image lands on."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Generate random points
    np.random.seed(42)
    
    # Unit ball points
    n_pts = 500
    angles = np.random.uniform(0, 2*np.pi, n_pts)
    radii = np.sqrt(np.random.uniform(0, 1, n_pts))  # sqrt for uniform in disk
    ball_pts = np.column_stack([radii * np.cos(angles), radii * np.sin(angles)])
    
    # Unit sphere points (circle)
    circle_pts = np.column_stack([np.cos(np.linspace(0, 2*np.pi, 200)),
                                   np.sin(np.linspace(0, 2*np.pi, 200))])
    
    # Exterior points
    radii_ext = np.sqrt(np.random.uniform(1, 9, n_pts))
    ext_pts = np.column_stack([radii_ext * np.cos(angles), radii_ext * np.sin(angles)])
    
    # Panel 1: R^2 coloring
    ax = axes[0]
    ax.scatter(ball_pts[:, 0], ball_pts[:, 1], c='blue', s=5, alpha=0.5, label='||y||<1 → Southern')
    ax.plot(circle_pts[:, 0], circle_pts[:, 1], 'g-', linewidth=2, label='||y||=1 → Equator')
    ax.scatter(ext_pts[:, 0], ext_pts[:, 1], c='red', s=5, alpha=0.5, label='||y||>1 → Northern')
    ax.set_aspect('equal')
    ax.set_title("ℝ² coloring by norm", fontsize=13, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Last coordinate vs norm
    ax = axes[1]
    norms = np.linspace(0, 3, 500)
    last_coords = (norms**2 - 1) / (norms**2 + 1)
    ax.plot(norms, last_coords, 'k-', linewidth=2)
    ax.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='Equator')
    ax.axvline(x=1, color='green', linestyle='--', alpha=0.5)
    ax.fill_between(norms, last_coords, -1, where=(norms < 1), alpha=0.2, color='blue', label='Southern')
    ax.fill_between(norms, last_coords, 1, where=(norms > 1), alpha=0.2, color='red', label='Northern')
    ax.set_xlabel("||y||", fontsize=12)
    ax.set_ylabel("Last coordinate", fontsize=12)
    ax.set_title("invStereoN_last_mono:\nMonotonicity of last coordinate", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-1.1, 1.1)
    
    # Panel 3: 3D sphere with coloring
    ax = fig.add_subplot(133, projection='3d')
    
    ball_sphere = inv_stereo_n(ball_pts)
    circle_sphere = inv_stereo_n(circle_pts)
    ext_sphere = inv_stereo_n(ext_pts)
    
    ax.scatter(ball_sphere[:, 0], ball_sphere[:, 1], ball_sphere[:, 2],
              c='blue', s=5, alpha=0.3, label='Southern')
    ax.plot(circle_sphere[:, 0], circle_sphere[:, 1], circle_sphere[:, 2],
           'g-', linewidth=2, label='Equator')
    ax.scatter(ext_sphere[:, 0], ext_sphere[:, 1], ext_sphere[:, 2],
              c='red', s=5, alpha=0.3, label='Northern')
    ax.scatter([0], [0], [1], color='gold', s=100, marker='*', zorder=5, label='North Pole')
    ax.scatter([0], [0], [-1], color='purple', s=100, marker='*', zorder=5, label='South Pole')
    
    ax.set_title("S² hemisphere\ncharacterization", fontsize=13, fontweight='bold')
    ax.legend(fontsize=7, loc='upper left')
    
    plt.tight_layout()
    plt.savefig("demos/hemisphere_characterization.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 2: Hemisphere characterization saved to demos/hemisphere_characterization.png")


# ============================================================
# Demo 3: Conformal Factor Visualization
# (Theorems: conformal_factor_pos, conformal_factor_le_two, conformal_factor_at_zero)
# ============================================================

def demo_conformal_factor():
    """Visualize the conformal factor 2/D and its properties."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Conformal factor as a function of radius
    ax = axes[0]
    r = np.linspace(0, 5, 500)
    cf = 2 / (1 + r**2)
    ax.plot(r, cf, 'b-', linewidth=2.5)
    ax.axhline(y=2, color='red', linestyle='--', alpha=0.5, label='Max = 2 (at origin)')
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.scatter([0], [2], color='red', s=100, zorder=5)
    ax.annotate('conformal_factor_at_zero: 2/D(0)=2', xy=(0, 2), xytext=(1.5, 1.8),
               fontsize=9, arrowprops=dict(arrowstyle='->', color='red'))
    ax.set_xlabel("||y||", fontsize=12)
    ax.set_ylabel("2/D(y)", fontsize=12)
    ax.set_title("Conformal Factor 2/D\n(always in (0,2])", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: 2D heatmap of conformal factor
    ax = axes[1]
    x = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x, x)
    pts = np.stack([X, Y], axis=-1)
    CF = conformal_factor(pts)
    
    im = ax.imshow(CF, extent=[-3, 3, -3, 3], cmap='hot', origin='lower', vmin=0, vmax=2)
    ax.contour(X, Y, CF, levels=[0.5, 1.0, 1.5, 1.9], colors='white', linewidths=0.8)
    circle = plt.Circle((0, 0), 1, fill=False, color='cyan', linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.set_title("2D Conformal Factor\n(unit circle = equator boundary)", fontsize=13, fontweight='bold')
    ax.set_xlabel("y₁")
    ax.set_ylabel("y₂")
    plt.colorbar(im, ax=ax, label="2/D")
    
    # Panel 3: Grid distortion
    ax = axes[2]
    t = np.linspace(-2.5, 2.5, 20)
    
    # Draw distorted grid on sphere (projected back)
    for ti in t:
        # Horizontal lines
        line_h = np.column_stack([np.linspace(-2.5, 2.5, 100), np.full(100, ti)])
        sphere_h = inv_stereo_n(line_h)
        projected_h = stereo_n(sphere_h)  # Round trip
        cf_h = conformal_factor(line_h)
        ax.plot(line_h[:, 0], line_h[:, 1], 'b-', alpha=0.3, linewidth=0.5)
        
        # Vertical lines
        line_v = np.column_stack([np.full(100, ti), np.linspace(-2.5, 2.5, 100)])
        ax.plot(line_v[:, 0], line_v[:, 1], 'r-', alpha=0.3, linewidth=0.5)
    
    # Show conformal factor as scatter
    pts_grid = np.column_stack([X.ravel(), Y.ravel()])
    cf_grid = conformal_factor(pts_grid)
    sc = ax.scatter(pts_grid[:, 0], pts_grid[:, 1], c=cf_grid, cmap='hot', s=1, alpha=0.5)
    ax.set_aspect('equal')
    ax.set_title("Grid with conformal factor\n(brighter = more stretching)", fontsize=13, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    
    plt.tight_layout()
    plt.savefig("demos/conformal_factor.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3: Conformal factor saved to demos/conformal_factor.png")


# ============================================================
# Demo 4: Transition Map = Geometric Inversion
# (Theorems: transition_map_is_inversion, transition_map_involution)
# ============================================================

def demo_transition_map():
    """Visualize the transition map between north and south charts."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Original grid in north chart
    ax = axes[0]
    t = np.linspace(-2, 2, 15)
    for ti in t:
        ax.plot([ti]*100, np.linspace(-2, 2, 100), 'b-', alpha=0.4, linewidth=0.8)
        ax.plot(np.linspace(-2, 2, 100), [ti]*100, 'r-', alpha=0.4, linewidth=0.8)
    circle = plt.Circle((0, 0), 1, fill=False, color='green', linewidth=2)
    ax.add_patch(circle)
    ax.set_aspect('equal')
    ax.set_title("North chart (ℝ²)", fontsize=13, fontweight='bold')
    ax.set_xlabel("y₁")
    ax.set_ylabel("y₂")
    ax.grid(True, alpha=0.2)
    
    # Panel 2: Inverted grid (transition map = inversion y/||y||^2)
    ax = axes[1]
    for ti in t:
        if abs(ti) < 0.01:
            continue
        # Horizontal line y2 = ti
        pts = np.column_stack([np.linspace(-2, 2, 200), np.full(200, ti)])
        norms_sq = sq_norm_fin(pts)
        norms_sq = np.maximum(norms_sq, 1e-10)
        inv_pts = pts / norms_sq[:, np.newaxis]
        mask = norms_sq > 0.05
        ax.plot(inv_pts[mask, 0], inv_pts[mask, 1], 'b-', alpha=0.4, linewidth=0.8)
        
        # Vertical line y1 = ti
        pts = np.column_stack([np.full(200, ti), np.linspace(-2, 2, 200)])
        norms_sq = sq_norm_fin(pts)
        norms_sq = np.maximum(norms_sq, 1e-10)
        inv_pts = pts / norms_sq[:, np.newaxis]
        mask = norms_sq > 0.05
        ax.plot(inv_pts[mask, 0], inv_pts[mask, 1], 'r-', alpha=0.4, linewidth=0.8)
    
    circle = plt.Circle((0, 0), 1, fill=False, color='green', linewidth=2)
    ax.add_patch(circle)
    ax.set_aspect('equal')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_title("South chart (inversion y/||y||²)\nLines → Circles through origin", fontsize=13, fontweight='bold')
    ax.set_xlabel("z₁")
    ax.set_ylabel("z₂")
    
    # Panel 3: Verify involution property
    ax = axes[2]
    np.random.seed(123)
    pts = np.random.randn(200, 2) * 2
    pts = pts[sq_norm_fin(pts) > 0.1]
    
    # Apply transition map once
    norms_sq = sq_norm_fin(pts)
    inv1 = pts / norms_sq[:, np.newaxis]
    
    # Apply twice (should be identity)
    norms_sq2 = sq_norm_fin(inv1)
    inv2 = inv1 / norms_sq2[:, np.newaxis]
    
    errors = np.sqrt(np.sum((inv2 - pts)**2, axis=1))
    
    ax.hist(errors, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
    ax.axvline(x=np.max(errors), color='red', linestyle='--', label=f'Max error: {np.max(errors):.2e}')
    ax.set_xlabel("||f(f(y)) - y||", fontsize=12)
    ax.set_ylabel("Count", fontsize=12)
    ax.set_title("transition_map_involution:\nf∘f = id (numerical verification)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig("demos/transition_map.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4: Transition map saved to demos/transition_map.png")


# ============================================================
# Demo 5: Chordal Distance Formula
# (Theorem: invStereoN_chordal_sq)
# ============================================================

def demo_chordal_distance():
    """Verify and visualize the chordal distance formula."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    np.random.seed(42)
    n_pairs = 2000
    y = np.random.randn(n_pairs, 2) * 2
    z = np.random.randn(n_pairs, 2) * 2
    
    # Compute chordal distance directly
    sy = inv_stereo_n(y)
    sz = inv_stereo_n(z)
    chordal_sq = np.sum((sy - sz)**2, axis=1)
    
    # Compute via formula: 4*||y-z||^2 / (D_y * D_z)
    flat_dist_sq = np.sum((y - z)**2, axis=1)
    Dy = stereo_denom(y)
    Dz = stereo_denom(z)
    formula_sq = 4 * flat_dist_sq / (Dy * Dz)
    
    # Panel 1: Scatter plot comparing the two
    ax = axes[0]
    ax.scatter(chordal_sq, formula_sq, s=3, alpha=0.3, c='steelblue')
    ax.plot([0, 4], [0, 4], 'r--', linewidth=2, label='y=x (exact match)')
    ax.set_xlabel("Direct computation ||σ(y)-σ(z)||²", fontsize=10)
    ax.set_ylabel("Formula: 4||y-z||²/(D_y·D_z)", fontsize=10)
    ax.set_title("invStereoN_chordal_sq:\nExact formula verification", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Chordal vs flat distance
    ax = axes[1]
    flat_dist = np.sqrt(flat_dist_sq)
    chordal = np.sqrt(chordal_sq)
    ax.scatter(flat_dist, chordal, s=3, alpha=0.3, c='purple')
    ax.plot([0, 6], [0, 6], 'gray', linestyle='--', alpha=0.5, label='d_chord = d_flat')
    ax.plot([0, 6], [0, 2], 'red', linestyle='--', alpha=0.5, label='d_chord ≤ 2')
    ax.set_xlabel("Flat distance ||y-z||", fontsize=11)
    ax.set_ylabel("Chordal distance ||σ(y)-σ(z)||", fontsize=11)
    ax.set_title("chordal_le_euclidean:\nChordal ≤ Flat distance", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Angular distance identity
    ax = axes[2]
    dot_products = np.sum(sy * sz, axis=1)
    angular_lhs = 2 - 2 * dot_products
    angular_rhs = chordal_sq
    
    errors = np.abs(angular_lhs - angular_rhs)
    ax.hist(np.log10(errors + 1e-20), bins=50, color='orange', edgecolor='black', alpha=0.7)
    ax.set_xlabel("log₁₀(error)", fontsize=11)
    ax.set_ylabel("Count", fontsize=11)
    ax.set_title("angular_distance_identity:\n2-2⟨σ(y),σ(z)⟩ = ||σ(y)-σ(z)||²", fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig("demos/chordal_distance.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5: Chordal distance saved to demos/chordal_distance.png")


# ============================================================
# Demo 6: Antipodal Symmetry & Inversion Duality
# (Theorems: invStereoN_neg_first_coords, invStereoN_neg_last_coord, 
#  invStereoN_inversion_last)
# ============================================================

def demo_antipodal_inversion():
    """Visualize antipodal symmetry and inversion duality."""
    fig = plt.figure(figsize=(16, 6))
    
    # Panel 1: Antipodal symmetry on S^2
    ax1 = fig.add_subplot(121, projection='3d')
    
    # Draw sphere
    u_s = np.linspace(0, 2*np.pi, 40)
    v_s = np.linspace(0, np.pi, 25)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax1.plot_surface(xs, ys, zs, alpha=0.06, color='lightblue')
    
    # Draw equator
    theta = np.linspace(0, 2*np.pi, 200)
    ax1.plot(np.cos(theta), np.sin(theta), np.zeros_like(theta), 'g-', linewidth=1.5, alpha=0.5)
    
    # Points and their negations
    np.random.seed(77)
    pts = np.random.randn(8, 2) * 1.5
    img_pts = inv_stereo_n(pts)
    img_neg = inv_stereo_n(-pts)
    
    for i in range(len(pts)):
        ax1.scatter(*img_pts[i], color='blue', s=40, zorder=5)
        ax1.scatter(*img_neg[i], color='red', s=40, zorder=5)
        ax1.plot([img_pts[i, 0], img_neg[i, 0]], 
                [img_pts[i, 1], img_neg[i, 1]],
                [img_pts[i, 2], img_neg[i, 2]], 'k--', alpha=0.3, linewidth=0.8)
    
    ax1.set_title("Antipodal Symmetry:\ny ↦ -y reflects through equator\n(same last coord, negated first coords)", 
                  fontsize=11, fontweight='bold')
    
    # Panel 2: Inversion duality
    ax2 = fig.add_subplot(122, projection='3d')
    ax2.plot_surface(xs, ys, zs, alpha=0.06, color='lightblue')
    ax2.plot(np.cos(theta), np.sin(theta), np.zeros_like(theta), 'g-', linewidth=1.5, alpha=0.5)
    
    # Points and their inversions y/||y||^2
    pts2 = np.random.randn(8, 2) * 1.5
    pts2 = pts2[sq_norm_fin(pts2) > 0.3]
    
    norms_sq = sq_norm_fin(pts2)
    inv_pts = pts2 / norms_sq[:, np.newaxis]
    
    img_pts2 = inv_stereo_n(pts2)
    img_inv = inv_stereo_n(inv_pts)
    
    for i in range(len(pts2)):
        ax2.scatter(*img_pts2[i], color='blue', s=40, zorder=5)
        ax2.scatter(*img_inv[i], color='orange', s=40, zorder=5)
        # Verify: last coord is negated
        ax2.plot([img_pts2[i, 0], img_inv[i, 0]],
                [img_pts2[i, 1], img_inv[i, 1]],
                [img_pts2[i, 2], img_inv[i, 2]], 'k:', alpha=0.3, linewidth=0.8)
    
    ax2.set_title("Inversion Duality:\ny ↦ y/||y||² negates last coord\n(equatorial reflection on S²)", 
                  fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig("demos/antipodal_inversion.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 6: Antipodal & inversion saved to demos/antipodal_inversion.png")


# ============================================================
# Demo 7: Pythagorean Triples from Stereographic Projection
# (Theorem: pythagorean_from_rational_stereo)
# ============================================================

def demo_pythagorean_triples():
    """Generate Pythagorean triples using stereographic projection of rational points."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Rational points on the unit circle via stereo projection
    ax = axes[0]
    
    triples = []
    for p in range(-10, 11):
        for q in range(1, 11):
            if np.gcd(abs(p), q) == 1 and p > 0:  # primitive
                a = 2*p*q
                b = p**2 - q**2
                c = p**2 + q**2
                if b > 0:
                    triples.append((a, b, c))
                    # Rational point on circle
                    t = p/q
                    x_c = 2*t/(1+t**2)
                    y_c = (t**2-1)/(1+t**2)
                    ax.scatter(x_c, y_c, s=20, c='blue', zorder=5)
    
    theta = np.linspace(0, 2*np.pi, 500)
    ax.plot(np.cos(theta), np.sin(theta), 'gray', alpha=0.5)
    ax.set_aspect('equal')
    ax.set_title("Rational points on S¹\nfrom stereographic projection", fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.set_xlabel("2t/(1+t²)")
    ax.set_ylabel("(t²-1)/(1+t²)")
    
    # Panel 2: Pythagorean triples as lattice points
    ax = axes[1]
    for a, b, c in triples[:30]:
        ax.scatter(a, b, s=30, c='blue', zorder=5)
        ax.annotate(f'({a},{b},{c})', (a, b), fontsize=6, textcoords="offset points", xytext=(3, 3))
    
    ax.set_xlabel("a = 2pq", fontsize=11)
    ax.set_ylabel("b = p²-q²", fontsize=11)
    ax.set_title("Pythagorean Triples (a²+b²=c²)\nfrom rational t = p/q", fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Verify Brahmagupta-Fibonacci identity
    ax = axes[2]
    np.random.seed(42)
    N = 100
    a_vals = np.random.randint(-20, 21, N)
    b_vals = np.random.randint(-20, 21, N)
    c_vals = np.random.randint(-20, 21, N)
    d_vals = np.random.randint(-20, 21, N)
    
    lhs = (a_vals**2 + b_vals**2) * (c_vals**2 + d_vals**2)
    rhs = (a_vals*c_vals - b_vals*d_vals)**2 + (a_vals*d_vals + b_vals*c_vals)**2
    
    ax.scatter(lhs, rhs, s=10, alpha=0.5, c='purple')
    ax.plot([0, max(lhs)], [0, max(lhs)], 'r--', linewidth=1.5, label='y=x')
    ax.set_xlabel("(a²+b²)(c²+d²)", fontsize=10)
    ax.set_ylabel("(ac-bd)²+(ad+bc)²", fontsize=10)
    ax.set_title("Brahmagupta-Fibonacci Identity\n(sums of squares are multiplicative)", fontsize=13, fontweight='bold')
    ax.legend()
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig("demos/pythagorean_triples.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 7: Pythagorean triples saved to demos/pythagorean_triples.png")


# ============================================================
# Demo 8: Möbius Transformations
# (Theorems: moebius_1d_composition, cross_ratio_translation_invariant)
# ============================================================

def demo_moebius_transforms():
    """Visualize 1D Möbius transformations and their composition."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Gallery of Möbius transformations
    ax = axes[0]
    t = np.linspace(-3, 3, 1000)
    
    transforms = [
        (1, 0, 0, 1, "Identity"),
        (1, 1, 0, 1, "Translation z+1"),
        (2, 0, 0, 1, "Scaling 2z"),
        (0, 1, 1, 0, "Inversion 1/z"),
        (1, 0, 1, 1, "z/(z+1)"),
    ]
    
    colors = plt.cm.tab10(np.linspace(0, 0.5, len(transforms)))
    for idx, (a, b, c, d, label) in enumerate(transforms):
        denom = c*t + d
        valid = np.abs(denom) > 0.1
        result = np.where(valid, (a*t + b) / denom, np.nan)
        ax.plot(t[valid], result[valid], color=colors[idx], linewidth=2, label=label)
    
    ax.set_ylim(-5, 5)
    ax.set_xlabel("z", fontsize=11)
    ax.set_ylabel("T(z)", fontsize=11)
    ax.set_title("Möbius Transformations\nz ↦ (az+b)/(cz+d)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Composition = matrix product
    ax = axes[1]
    # Compose translation z+1 with scaling 2z: should be 2(z+1) = 2z+2
    z_vals = np.linspace(-2, 2, 200)
    
    # Direct composition
    composed_direct = moebius_1d(2, 0, 0, 1, moebius_1d(1, 1, 0, 1, z_vals))
    
    # Matrix product: [2,0;0,1] * [1,1;0,1] = [2,2;0,1]
    composed_matrix = moebius_1d(2, 2, 0, 1, z_vals)
    
    ax.plot(z_vals, composed_direct, 'b-', linewidth=3, label='Direct: S(T(z))')
    ax.plot(z_vals, composed_matrix, 'r--', linewidth=2, label='Matrix: (ST)(z)')
    ax.set_xlabel("z", fontsize=11)
    ax.set_ylabel("Result", fontsize=11)
    ax.set_title("moebius_1d_composition:\nComposition = Matrix Product", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Cross-ratio invariance under translation
    ax = axes[2]
    
    def cross_ratio(z1, z2, z3, z4):
        return (z1 - z3) * (z2 - z4) / ((z1 - z4) * (z2 - z3))
    
    z1, z2, z3, z4 = 1.0, 2.0, 3.0, 5.0
    base_cr = cross_ratio(z1, z2, z3, z4)
    
    translations = np.linspace(-5, 5, 200)
    cr_vals = [cross_ratio(z1+a, z2+a, z3+a, z4+a) for a in translations]
    
    ax.plot(translations, cr_vals, 'b-', linewidth=2)
    ax.axhline(y=base_cr, color='red', linestyle='--', label=f'CR = {base_cr:.4f}')
    ax.set_xlabel("Translation a", fontsize=11)
    ax.set_ylabel("Cross-ratio", fontsize=11)
    ax.set_title("cross_ratio_translation_invariant:\nCR preserved under translation", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("demos/moebius_transforms.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 8: Möbius transforms saved to demos/moebius_transforms.png")


# ============================================================
# Demo 9: Hopf Fibration Visualization
# ============================================================

def demo_hopf_fibration():
    """Visualize the Hopf fibration S^3 -> S^2 via stereographic projection."""
    fig = plt.figure(figsize=(16, 6))
    
    # The Hopf map in coordinates: (z1, z2) in C^2 with |z1|^2+|z2|^2=1
    # maps to (2*Re(z1*conj(z2)), 2*Im(z1*conj(z2)), |z1|^2-|z2|^2) in S^2
    
    # Panel 1: Fibers over points on S^2
    ax1 = fig.add_subplot(121, projection='3d')
    
    # Choose points on S^2 (base space)
    base_points = [
        (0, 0, 1, "North pole"),     # z2 = 0
        (0, 0, -1, "South pole"),    # z1 = 0
        (1, 0, 0, "Equator (1,0,0)"),
        (0, 1, 0, "Equator (0,1,0)"),
    ]
    
    colors = ['red', 'blue', 'green', 'orange']
    
    for idx, (bx, by, bz, label) in enumerate(base_points):
        # For each base point, compute the fiber (a great circle in S^3)
        # parametrize by angle phi
        phi = np.linspace(0, 2*np.pi, 200)
        
        if bz == 1:  # North pole
            z1 = np.exp(1j * phi)
            z2 = np.zeros_like(phi)
        elif bz == -1:  # South pole
            z1 = np.zeros_like(phi)
            z2 = np.exp(1j * phi)
        else:
            # General case
            theta_half = np.arccos(np.sqrt((1+bz)/2))
            alpha = np.arctan2(by, bx)
            z1 = np.cos(theta_half) * np.exp(1j * phi)
            z2 = np.sin(theta_half) * np.exp(1j * (phi + alpha))
        
        # S^3 coordinates
        s3 = np.column_stack([z1.real, z1.imag, z2.real, z2.imag])
        
        # Stereographic projection S^3 -> R^3
        s3_stereo = s3[:, :3] / (1 - s3[:, 3:4] + 1e-10)
        
        # Only plot bounded part
        mask = np.all(np.abs(s3_stereo) < 5, axis=1)
        ax1.plot(s3_stereo[mask, 0], s3_stereo[mask, 1], s3_stereo[mask, 2],
                color=colors[idx], linewidth=2, label=label)
    
    ax1.set_title("Hopf Fibers in ℝ³\n(via stereo projection of S³)", fontsize=12, fontweight='bold')
    ax1.legend(fontsize=8, loc='upper left')
    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_zlim(-3, 3)
    
    # Panel 2: Base space S^2 with fiber points colored
    ax2 = fig.add_subplot(122, projection='3d')
    
    u_s = np.linspace(0, 2*np.pi, 40)
    v_s = np.linspace(0, np.pi, 25)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax2.plot_surface(xs, ys, zs, alpha=0.1, color='lightblue')
    
    for idx, (bx, by, bz, label) in enumerate(base_points):
        ax2.scatter([bx], [by], [bz], color=colors[idx], s=100, zorder=5, label=label)
    
    # Add many random fibers
    np.random.seed(42)
    for _ in range(50):
        phi0 = np.random.uniform(0, 2*np.pi)
        theta0 = np.random.uniform(0, np.pi)
        bx = np.sin(theta0)*np.cos(phi0)
        by = np.sin(theta0)*np.sin(phi0)
        bz = np.cos(theta0)
        ax2.scatter([bx], [by], [bz], color=plt.cm.hsv(phi0 / (2*np.pi)), s=10, alpha=0.5)
    
    ax2.set_title("Base Space S²\n(each point = one S¹ fiber)", fontsize=12, fontweight='bold')
    ax2.legend(fontsize=8, loc='upper left')
    
    plt.tight_layout()
    plt.savefig("demos/hopf_fibration.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 9: Hopf fibration saved to demos/hopf_fibration.png")


# ============================================================
# Demo 10: Energy Partition on the Sphere
# (Theorem: energy_partition)
# ============================================================

def demo_energy_partition():
    """Visualize the energy partition: horizontal + vertical = 1."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Many random points in R^2
    np.random.seed(42)
    pts = np.random.randn(5000, 2) * 3
    
    sphere_pts = inv_stereo_n(pts)
    
    # Horizontal energy: sum of first N coords squared
    h_energy = np.sum(sphere_pts[:, :2]**2, axis=1)
    # Vertical energy: last coord squared
    v_energy = sphere_pts[:, 2]**2
    # Total should be 1
    total = h_energy + v_energy
    
    # Panel 1: h_energy vs v_energy
    ax = axes[0]
    sc = ax.scatter(h_energy, v_energy, c=np.sqrt(sq_norm_fin(pts)), 
                    cmap='viridis', s=5, alpha=0.5)
    ax.plot([0, 1], [1, 0], 'r-', linewidth=2, label='h + v = 1')
    ax.set_xlabel("Horizontal energy Σᵢ₌₀ᴺ⁻¹ xᵢ²", fontsize=11)
    ax.set_ylabel("Vertical energy x_N²", fontsize=11)
    ax.set_title("energy_partition:\nhorizontal + vertical = 1", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_aspect('equal')
    plt.colorbar(sc, ax=ax, label="||y|| in ℝ²")
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Total energy histogram
    ax = axes[1]
    ax.hist(total, bins=50, color='steelblue', edgecolor='black', alpha=0.7, range=(0.9999, 1.0001))
    ax.axvline(x=1, color='red', linewidth=2, linestyle='--', label='Expected: 1.0')
    ax.set_xlabel("Total energy (h + v)", fontsize=11)
    ax.set_ylabel("Count", fontsize=11)
    ax.set_title(f"Verification: total energy = 1\nmax deviation: {np.max(np.abs(total-1)):.2e}", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig("demos/energy_partition.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 10: Energy partition saved to demos/energy_partition.png")


# ============================================================
# Demo 11: Neural Network Stereographic Layer
# ============================================================

def demo_stereo_neural_network():
    """Demonstrate stereographic projection as a neural network layer."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    
    np.random.seed(42)
    
    # Generate 2D classification data (two spirals)
    n = 500
    t1 = np.linspace(0, 3*np.pi, n)
    t2 = np.linspace(0, 3*np.pi, n)
    
    class1 = np.column_stack([t1 * np.cos(t1), t1 * np.sin(t1)]) / 5
    class2 = np.column_stack([t2 * np.cos(t2 + np.pi), t2 * np.sin(t2 + np.pi)]) / 5
    
    data = np.vstack([class1, class2])
    labels = np.array([0]*n + [1]*n)
    
    # Panel (0,0): Original 2D data
    ax = axes[0, 0]
    ax.scatter(class1[:, 0], class1[:, 1], c='blue', s=5, alpha=0.5, label='Class 0')
    ax.scatter(class2[:, 0], class2[:, 1], c='red', s=5, alpha=0.5, label='Class 1')
    ax.set_aspect('equal')
    ax.set_title("Input: ℝ² spirals", fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel (0,1): Lifted to S^2
    ax = axes[0, 1]
    ax = fig.add_subplot(2, 3, 2, projection='3d')
    sphere1 = inv_stereo_n(class1)
    sphere2 = inv_stereo_n(class2)
    
    u_s = np.linspace(0, 2*np.pi, 30)
    v_s = np.linspace(0, np.pi, 20)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax.plot_surface(xs, ys, zs, alpha=0.05, color='lightblue')
    
    ax.scatter(sphere1[:, 0], sphere1[:, 1], sphere1[:, 2], c='blue', s=3, alpha=0.3)
    ax.scatter(sphere2[:, 0], sphere2[:, 1], sphere2[:, 2], c='red', s=3, alpha=0.3)
    ax.set_title("Lifted to S²\n(invStereoN layer)", fontsize=12, fontweight='bold')
    
    # Panel (0,2): Conformal factor as feature
    ax = axes[0, 2]
    cf = conformal_factor(data)
    norms = np.sqrt(sq_norm_fin(data))
    ax.scatter(norms[labels==0], cf[labels==0], c='blue', s=5, alpha=0.3, label='Class 0')
    ax.scatter(norms[labels==1], cf[labels==1], c='red', s=5, alpha=0.3, label='Class 1')
    ax.set_xlabel("||y||", fontsize=10)
    ax.set_ylabel("2/D (conformal factor)", fontsize=10)
    ax.set_title("Conformal factor\nas extra feature", fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Panel (1,0): Chordal distances within and between classes
    ax = axes[1, 0]
    idx1 = np.random.choice(n, 200, replace=False)
    idx2 = np.random.choice(n, 200, replace=False) + n
    
    within_dists = []
    between_dists = []
    for i in range(100):
        for j in range(i+1, min(i+5, 100)):
            d_w = np.sqrt(np.sum((sphere1[idx1[i]-0] - sphere1[idx1[j]-0])**2))
            within_dists.append(d_w)
            d_b = np.sqrt(np.sum((sphere1[idx1[i]-0] - sphere2[idx2[j]-n])**2))
            between_dists.append(d_b)
    
    ax.hist(within_dists, bins=30, alpha=0.5, color='green', label='Within-class', density=True)
    ax.hist(between_dists, bins=30, alpha=0.5, color='orange', label='Between-class', density=True)
    ax.set_xlabel("Chordal distance", fontsize=10)
    ax.set_title("Chordal distances\n(class separation on S²)", fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    
    # Panel (1,1): Stereographic positional encoding
    ax = axes[1, 1]
    # 1D sequence positions mapped to S^1
    seq_len = 50
    positions = np.arange(seq_len).reshape(-1, 1).astype(float) / 10
    pos_sphere = inv_stereo_n(positions)
    
    ax.scatter(pos_sphere[:, 0], pos_sphere[:, 1], c=np.arange(seq_len), 
              cmap='rainbow', s=50, zorder=5)
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'gray', alpha=0.3)
    ax.set_aspect('equal')
    ax.set_title("Positional encoding\n(seq positions on S¹)", fontsize=12, fontweight='bold')
    plt.colorbar(ax.scatter([], [], c=[], cmap='rainbow'), ax=ax, label='Position')
    
    # Panel (1,2): Bounded outputs
    ax = axes[1, 2]
    extreme_pts = np.random.randn(1000, 2) * 10  # Very large inputs
    sphere_extreme = inv_stereo_n(extreme_pts)
    
    ax.hist(sphere_extreme[:, 0], bins=50, alpha=0.5, label='x₁', color='blue')
    ax.hist(sphere_extreme[:, 1], bins=50, alpha=0.5, label='x₂', color='red')
    ax.hist(sphere_extreme[:, 2], bins=50, alpha=0.5, label='x₃', color='green')
    ax.axvline(x=-1, color='gray', linestyle='--', alpha=0.5)
    ax.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel("Coordinate value", fontsize=10)
    ax.set_title("invStereoN_coord_bounded:\n|xᵢ| ≤ 1 always", fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig("demos/stereo_neural_network.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 11: Neural network layer saved to demos/stereo_neural_network.png")


# ============================================================
# Demo 12: Cayley Transform & Hyperbolic Geometry
# ============================================================

def demo_cayley_transform():
    """Visualize the Cayley transform: real line to unit circle."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Panel 1: Cayley transform maps R to S^1
    ax = axes[0]
    t = np.linspace(-10, 10, 1000)
    x = (t**2 - 1) / (t**2 + 1)
    y = 2*t / (t**2 + 1)
    
    # Verify: x^2 + y^2 = 1 (cayley_transform_real_to_circle)
    check = x**2 + y**2
    
    sc = ax.scatter(x, y, c=t, cmap='coolwarm', s=10, zorder=5)
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'gray', alpha=0.3, linewidth=1)
    ax.scatter([-1], [0], color='red', s=100, marker='*', zorder=10, label='t=0 → (-1,0)')
    ax.scatter([1], [0], color='gold', s=100, marker='*', zorder=10, label='t→∞ → (1,0)')
    ax.set_aspect('equal')
    ax.set_title("Cayley Transform: ℝ → S¹\ncayley_transform_real_to_circle", fontsize=12, fontweight='bold')
    ax.legend(fontsize=8)
    plt.colorbar(sc, ax=ax, label='t ∈ ℝ')
    
    # Panel 2: Grid under Cayley transform (Poincaré disk model)
    ax = axes[1]
    
    # Upper half-plane grid
    for y_val in [0.2, 0.5, 1, 2, 4]:
        x_vals = np.linspace(-5, 5, 500)
        # Cayley transform: w = (z-i)/(z+i) where z = x+iy
        z = x_vals + 1j*y_val
        w = (z - 1j) / (z + 1j)
        ax.plot(w.real, w.imag, 'b-', alpha=0.4, linewidth=0.8)
    
    for x_val in np.linspace(-3, 3, 15):
        y_vals = np.linspace(0.01, 5, 200)
        z = x_val + 1j*y_vals
        w = (z - 1j) / (z + 1j)
        ax.plot(w.real, w.imag, 'r-', alpha=0.3, linewidth=0.8)
    
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5)
    ax.set_aspect('equal')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_title("Upper half-plane → Poincaré disk\n(Cayley transform of grid)", fontsize=12, fontweight='bold')
    
    # Panel 3: Geodesics in the Poincaré disk
    ax = axes[2]
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
    
    # Geodesics in the Poincaré disk are arcs of circles orthogonal to the boundary
    for angle in np.linspace(0, np.pi, 8)[1:-1]:
        # Geodesic from -1 to exp(i*angle) on the boundary
        p1 = np.array([-1, 0])
        p2 = np.array([np.cos(angle), np.sin(angle)])
        
        # Find circle through these two points orthogonal to unit circle
        # For diameter geodesics
        t_vals = np.linspace(0, 1, 200)
        # Parametric geodesic (simplified)
        geodesic = p1[np.newaxis, :] * (1-t_vals[:, np.newaxis]) + p2[np.newaxis, :] * t_vals[:, np.newaxis]
        ax.plot(geodesic[:, 0], geodesic[:, 1], 'b-', alpha=0.5, linewidth=1.5)
    
    # Circular geodesics
    for d in [0.3, 0.6]:
        center_x = 0
        center_y = d
        # Circle orthogonal to unit circle passing through (center_x, center_y)
        r = np.sqrt(1 + d**2)
        arc = np.linspace(-np.pi/3, np.pi/3, 200)
        cx = center_x + r * np.cos(arc)
        cy = -1/d + r * np.sin(arc)
        inside = cx**2 + cy**2 < 1
        ax.plot(cx[inside], cy[inside], 'r-', alpha=0.5, linewidth=1.5)
    
    ax.set_aspect('equal')
    ax.set_xlim(-1.3, 1.3)
    ax.set_ylim(-1.3, 1.3)
    ax.set_title("Geodesics in\nPoincaré Disk Model", fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig("demos/cayley_transform.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 12: Cayley transform saved to demos/cayley_transform.png")


# ============================================================
# Main: Run all demos
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Stereographic Projection Visualization Suite")
    print("=" * 60)
    print()
    
    demo_line_to_circle()
    demo_hemisphere_characterization()
    demo_conformal_factor()
    demo_transition_map()
    demo_chordal_distance()
    demo_antipodal_inversion()
    demo_pythagorean_triples()
    demo_moebius_transforms()
    demo_hopf_fibration()
    demo_energy_partition()
    demo_stereo_neural_network()
    demo_cayley_transform()
    
    print()
    print("=" * 60)
    print("All 12 demos generated successfully!")
    print("See demos/ directory for PNG outputs.")
    print("=" * 60)
