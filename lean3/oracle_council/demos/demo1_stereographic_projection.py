"""
Demo 1: Stereographic Projection — The Fundamental Map
=======================================================
Visualizes stereographic projection from the sphere to the plane,
showing how the north pole maps to infinity and how circles on the
sphere become circles (or lines) in the plane.

Part of the Oracle Council research project on local-global transfer
and the Millennium Problems.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d
import matplotlib.gridspec as gridspec


def stereographic_project(x, y, z):
    """Project a point on S² (minus north pole) to ℝ²."""
    denom = 1.0 - z
    denom = np.where(np.abs(denom) < 1e-12, 1e-12, denom)
    u = x / denom
    v = y / denom
    return u, v


def inverse_stereographic(u, v):
    """Map a point in ℝ² back to S²."""
    r2 = u**2 + v**2
    x = 2*u / (r2 + 1)
    y = 2*v / (r2 + 1)
    z = (r2 - 1) / (r2 + 1)
    return x, y, z


def circle_on_sphere(center_theta, center_phi, radius, n_points=200):
    """Generate a small circle on the sphere."""
    t = np.linspace(0, 2*np.pi, n_points)
    # Circle in local coordinates, then rotate
    cx = np.cos(center_theta) * np.cos(center_phi)
    cy = np.cos(center_theta) * np.sin(center_phi)
    cz = np.sin(center_theta)

    # Small circle around the z-axis, then rotate
    r = np.sin(radius)
    h = np.cos(radius)

    # Points on small circle centered at north pole
    px = r * np.cos(t)
    py = r * np.sin(t)
    pz = np.full_like(t, h)

    # Rotate to desired center using Rodrigues' formula
    # First rotate from north pole to (cx, cy, cz)
    # This requires finding the rotation that maps (0,0,1) to (cx,cy,cz)
    axis_x = -cy
    axis_y = cx
    axis_z = 0.0
    axis_norm = np.sqrt(axis_x**2 + axis_y**2 + axis_z**2)

    if axis_norm < 1e-10:
        # Already at or near pole
        return px, py, pz

    axis_x /= axis_norm
    axis_y /= axis_norm
    angle = np.arccos(np.clip(cz, -1, 1))

    c_a = np.cos(angle)
    s_a = np.sin(angle)

    # Rodrigues rotation
    dot = axis_x * px + axis_y * py + axis_z * pz
    cross_x = axis_y * pz - axis_z * py
    cross_y = axis_z * px - axis_x * pz
    cross_z = axis_x * py - axis_y * px

    rx = px * c_a + cross_x * s_a + axis_x * dot * (1 - c_a)
    ry = py * c_a + cross_y * s_a + axis_y * dot * (1 - c_a)
    rz = pz * c_a + cross_z * s_a + axis_z * dot * (1 - c_a)

    return rx, ry, rz


def main():
    fig = plt.figure(figsize=(20, 16), facecolor='#0a0a2e')

    gs = gridspec.GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.25)

    # ===== Panel 1: Sphere with circles and projection rays =====
    ax1 = fig.add_subplot(gs[0, 0], projection='3d', facecolor='#0a0a2e')
    ax1.set_title('The Sphere S²\nwith Circles & Projection Rays',
                   color='white', fontsize=14, fontweight='bold', pad=15)

    # Draw wireframe sphere
    u_s = np.linspace(0, 2*np.pi, 50)
    v_s = np.linspace(0, np.pi, 30)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax1.plot_surface(xs, ys, zs, alpha=0.08, color='cyan')

    # Draw equator
    eq_t = np.linspace(0, 2*np.pi, 200)
    ax1.plot(np.cos(eq_t), np.sin(eq_t), np.zeros_like(eq_t),
             color='cyan', alpha=0.5, linewidth=1)

    # Draw several circles on the sphere and their projections
    colors = ['#ff6b6b', '#ffd93d', '#6bcb77', '#4d96ff', '#ff6bd6']
    circle_params = [
        (0.3, 0.0, 0.3),    # low circle
        (0.6, 1.0, 0.25),   # mid circle
        (0.9, 2.0, 0.2),    # high circle (near N)
        (-0.3, 3.0, 0.35),  # southern circle
        (0.0, 0.5, 0.4),    # equatorial circle
    ]

    projected_circles = []
    for i, (theta, phi, rad) in enumerate(circle_params):
        cx, cy, cz = circle_on_sphere(theta, phi, rad)
        ax1.plot(cx, cy, cz, color=colors[i], linewidth=2.5, alpha=0.9)

        # Project to plane
        pu, pv = stereographic_project(cx, cy, cz)
        projected_circles.append((pu, pv, colors[i]))

        # Draw a few projection rays
        for j in range(0, len(cx), 40):
            if cz[j] < 0.95:  # Don't draw rays too close to N
                ax1.plot([0, cx[j]], [0, cy[j]], [1, cz[j]],
                         color=colors[i], alpha=0.15, linewidth=0.5)

    # Mark north pole
    ax1.scatter([0], [0], [1], color='red', s=100, zorder=10,
                edgecolors='white', linewidth=2)
    ax1.text(0.05, 0.05, 1.15, 'N (∞)', color='red', fontsize=12,
             fontweight='bold')

    # Mark south pole
    ax1.scatter([0], [0], [-1], color='lime', s=60, zorder=10)
    ax1.text(0.05, 0.05, -1.15, 'S', color='lime', fontsize=10)

    ax1.set_xlim([-1.3, 1.3])
    ax1.set_ylim([-1.3, 1.3])
    ax1.set_zlim([-1.3, 1.3])
    ax1.set_axis_off()

    # ===== Panel 2: Projected plane =====
    ax2 = fig.add_subplot(gs[0, 1], facecolor='#0a0a2e')
    ax2.set_title('The Plane ℝ²\nStereographic Image (Circles → Circles)',
                   color='white', fontsize=14, fontweight='bold')

    # Draw grid
    for g in np.arange(-5, 6, 1):
        ax2.axhline(y=g, color='#1a1a4e', linewidth=0.5, alpha=0.5)
        ax2.axvline(x=g, color='#1a1a4e', linewidth=0.5, alpha=0.5)

    # Draw projected circles
    labels = ['Low circle', 'Mid circle', 'Near N (→ large)', 'Southern', 'Equatorial']
    for i, (pu, pv, col) in enumerate(projected_circles):
        mask = (np.abs(pu) < 8) & (np.abs(pv) < 8)
        if np.any(mask):
            ax2.plot(pu[mask], pv[mask], color=col, linewidth=2.5,
                     label=labels[i], alpha=0.9)

    ax2.plot(0, 0, 'o', color='lime', markersize=8, label='South pole → Origin')
    ax2.set_xlim([-5, 5])
    ax2.set_ylim([-5, 5])
    ax2.set_aspect('equal')
    ax2.legend(loc='upper right', fontsize=8, facecolor='#1a1a4e',
               edgecolor='cyan', labelcolor='white')
    ax2.tick_params(colors='white')
    for spine in ax2.spines.values():
        spine.set_color('#333366')

    # ===== Panel 3: Conformal factor visualization =====
    ax3 = fig.add_subplot(gs[1, 0], facecolor='#0a0a2e')
    ax3.set_title('Conformal Factor\n4/(1 + u² + v²)² — The North Pole Singularity',
                   color='white', fontsize=14, fontweight='bold')

    u_grid = np.linspace(-4, 4, 500)
    v_grid = np.linspace(-4, 4, 500)
    U, V = np.meshgrid(u_grid, v_grid)
    R2 = U**2 + V**2
    conformal = 4.0 / (1.0 + R2)**2

    # The conformal factor is largest at origin (south pole image) = 4
    # and decays to 0 at infinity (north pole)
    im = ax3.pcolormesh(U, V, conformal, cmap='inferno', shading='auto',
                         vmin=0, vmax=4)
    plt.colorbar(im, ax=ax3, label='Conformal factor', shrink=0.8)
    ax3.set_xlabel('u', color='white', fontsize=12)
    ax3.set_ylabel('v', color='white', fontsize=12)
    ax3.set_aspect('equal')
    ax3.tick_params(colors='white')

    # Add contour lines
    contours = ax3.contour(U, V, conformal, levels=[0.1, 0.5, 1.0, 2.0, 3.0, 3.5],
                            colors='white', alpha=0.3, linewidths=0.5)

    # Annotation
    ax3.annotate('Origin\n(South Pole)\nMax distortion',
                 xy=(0, 0), xytext=(2, 2.5),
                 color='white', fontsize=9,
                 arrowprops=dict(arrowstyle='->', color='white'),
                 ha='center')
    ax3.annotate('∞ → 0\n(North Pole)\nZero distortion',
                 xy=(3.5, 3.5), xytext=(2.5, -2.5),
                 color='red', fontsize=9, fontweight='bold',
                 arrowprops=dict(arrowstyle='->', color='red'),
                 ha='center')

    # ===== Panel 4: The "north pole" for each Millennium Problem =====
    ax4 = fig.add_subplot(gs[1, 1], facecolor='#0a0a2e')
    ax4.set_title('The Seven North Poles\nMillennium Problem Obstructions',
                   color='white', fontsize=14, fontweight='bold')

    problems = [
        ('Poincaré\n(SOLVED)', 'Ricci flow\nsingularity', '#6bcb77', '✓'),
        ('Riemann\nHypothesis', 'Critical strip\narchimedean\nplace', '#ff6b6b', '?'),
        ('P vs NP', 'Search-decision\ngap', '#ffd93d', '?'),
        ('Yang-Mills', 'UV divergence\nstrong coupling', '#4d96ff', '?'),
        ('Navier-\nStokes', 'Vorticity\nblowup', '#ff6bd6', '?'),
        ('BSD', 'Ш group\nL(E,1)', '#ff8c42', '?'),
        ('Hodge', 'Topology-algebra\ngap', '#a855f7', '?'),
    ]

    # Arrange in a circle (like on a sphere!)
    n = len(problems)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    radius = 0.35

    for i, (name, pole, color, status) in enumerate(problems):
        x = 0.5 + radius * np.cos(angles[i])
        y = 0.5 + radius * np.sin(angles[i])

        # Draw circle
        circle = plt.Circle((x, y), 0.1, fill=True, facecolor=color,
                            alpha=0.3, edgecolor=color, linewidth=2,
                            transform=ax4.transAxes)
        ax4.add_patch(circle)

        # Problem name
        ax4.text(x, y + 0.02, name, transform=ax4.transAxes,
                ha='center', va='center', color='white', fontsize=7,
                fontweight='bold')

        # North pole description (outside)
        outer_x = 0.5 + (radius + 0.18) * np.cos(angles[i])
        outer_y = 0.5 + (radius + 0.18) * np.sin(angles[i])
        ax4.text(outer_x, outer_y, pole, transform=ax4.transAxes,
                ha='center', va='center', color=color, fontsize=6,
                style='italic')

        # Status
        status_x = 0.5 + (radius - 0.05) * np.cos(angles[i])
        status_y = 0.5 + (radius - 0.08) * np.sin(angles[i])

    # Center label
    ax4.text(0.5, 0.5, 'N\n(The North\nPole)', transform=ax4.transAxes,
             ha='center', va='center', color='red', fontsize=14,
             fontweight='bold', style='italic')

    # Draw a small sphere glyph in center
    theta_glyph = np.linspace(0, 2*np.pi, 100)
    glyph_r = 0.06
    glyph_x = 0.5 + glyph_r * np.cos(theta_glyph)
    glyph_y = 0.5 + glyph_r * np.sin(theta_glyph)
    ax4.plot(glyph_x, glyph_y, color='red', alpha=0.5, linewidth=1,
             transform=ax4.transAxes)

    ax4.set_xlim([0, 1])
    ax4.set_ylim([0, 1])
    ax4.set_axis_off()

    # Global title
    fig.suptitle('STEREOGRAPHIC PROJECTION & THE MILLENNIUM PROBLEMS\n'
                 'The Ancient Map That Charts Modern Mathematics',
                 color='white', fontsize=18, fontweight='bold', y=0.98)

    plt.savefig('/workspace/request-project/oracle_council/demos/demo1_stereographic_projection.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo1_stereographic_projection.png")


if __name__ == '__main__':
    main()
