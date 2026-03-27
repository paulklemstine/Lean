#!/usr/bin/env python3
"""
PISPD Interactive Visualizer
==============================

Visual demonstrations of the Photonic Inverse Stereographic Projection Device.
Creates matplotlib figures showing the key mathematical properties.

Usage:
    python pispd_visualizer.py              # Generate all figures (saved as PNG)
    python pispd_visualizer.py --show       # Show interactive plots
"""

import math
import sys
import os
import numpy as np

# Try to import matplotlib; provide graceful fallback
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend by default
    import matplotlib.pyplot as plt
    from matplotlib import cm
    from mpl_toolkits.mplot3d import Axes3D
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available — generating numerical output only")


def inverse_stereo_np(u, v):
    """Vectorized inverse stereographic projection."""
    r2 = u**2 + v**2
    denom = r2 + 1.0
    x = 2 * u / denom
    y = 2 * v / denom
    z = (r2 - 1.0) / denom
    return x, y, z


def forward_stereo_np(x, y, z):
    """Vectorized forward stereographic projection."""
    denom = 1.0 - z
    mask = np.abs(denom) > 1e-10
    u = np.where(mask, x / denom, np.nan)
    v = np.where(mask, y / denom, np.nan)
    return u, v


def conformal_factor_np(u, v):
    """Vectorized conformal factor."""
    r2 = u**2 + v**2
    return 4.0 / (1.0 + r2)**2


# ═══════════════════════════════════════════════════════════════
# Figure 1: The Inverse Stereographic Map
# ═══════════════════════════════════════════════════════════════

def fig1_inverse_stereo_grid():
    """Show how a regular grid on the plane maps to the sphere."""
    if not HAS_MPL:
        print("Figure 1: Grid mapping (requires matplotlib)")
        return

    fig = plt.figure(figsize=(16, 7))

    # Left: plane grid
    ax1 = fig.add_subplot(121)
    for u in np.linspace(-3, 3, 13):
        ax1.axvline(u, color='steelblue', alpha=0.5, linewidth=0.8)
    for v in np.linspace(-3, 3, 13):
        ax1.axhline(v, color='coral', alpha=0.5, linewidth=0.8)

    # Add unit circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax1.plot(np.cos(theta), np.sin(theta), 'g-', linewidth=2,
             label='Unit circle (isometric)')
    ax1.set_xlim(-3.5, 3.5)
    ax1.set_ylim(-3.5, 3.5)
    ax1.set_aspect('equal')
    ax1.set_title('Detector Plane ℝ²', fontsize=14)
    ax1.set_xlabel('u')
    ax1.set_ylabel('v')
    ax1.legend()
    ax1.grid(False)

    # Right: sphere with mapped grid
    ax2 = fig.add_subplot(122, projection='3d')

    # Draw wireframe sphere
    phi_s = np.linspace(0, np.pi, 30)
    theta_s = np.linspace(0, 2*np.pi, 30)
    xs = np.outer(np.sin(phi_s), np.cos(theta_s))
    ys = np.outer(np.sin(phi_s), np.sin(theta_s))
    zs = np.outer(np.cos(phi_s), np.ones_like(theta_s))
    ax2.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    # Map grid lines to sphere
    t = np.linspace(-3, 3, 200)
    for u_fixed in np.linspace(-3, 3, 13):
        x, y, z = inverse_stereo_np(u_fixed * np.ones_like(t), t)
        ax2.plot(x, y, z, color='steelblue', alpha=0.6, linewidth=0.8)

    for v_fixed in np.linspace(-3, 3, 13):
        x, y, z = inverse_stereo_np(t, v_fixed * np.ones_like(t))
        ax2.plot(x, y, z, color='coral', alpha=0.6, linewidth=0.8)

    # Map unit circle
    x, y, z = inverse_stereo_np(np.cos(theta), np.sin(theta))
    ax2.plot(x, y, z, 'g-', linewidth=2, label='Equator')

    ax2.set_title('Sphere S²', fontsize=14)
    ax2.legend()

    plt.suptitle('Figure 1: Inverse Stereographic Projection Maps Grid → Sphere',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig1_inverse_stereo_grid.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig1_inverse_stereo_grid.png")


# ═══════════════════════════════════════════════════════════════
# Figure 2: Conformal Factor Heat Map
# ═══════════════════════════════════════════════════════════════

def fig2_conformal_factor():
    """Visualize the conformal factor across the plane."""
    if not HAS_MPL:
        print("Figure 2: Conformal factor (requires matplotlib)")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Heat map
    u = np.linspace(-4, 4, 400)
    v = np.linspace(-4, 4, 400)
    U, V = np.meshgrid(u, v)
    CF = conformal_factor_np(U, V)

    im = axes[0].pcolormesh(U, V, CF, cmap='inferno', shading='auto')
    axes[0].contour(U, V, CF, levels=[0.1, 0.25, 0.5, 1.0, 2.0, 3.0, 3.9],
                    colors='white', linewidths=0.5)
    plt.colorbar(im, ax=axes[0], label='Conformal factor λ²')
    axes[0].set_title('Conformal Factor: λ² = 4/(1+|p|²)²')
    axes[0].set_xlabel('u')
    axes[0].set_ylabel('v')
    axes[0].set_aspect('equal')

    # Cross-section
    r = np.linspace(0, 5, 500)
    cf_r = 4.0 / (1.0 + r**2)**2
    axes[1].plot(r, cf_r, 'b-', linewidth=2)
    axes[1].axhline(1.0, color='green', linestyle='--', alpha=0.5,
                    label='λ² = 1 (isometric)')
    axes[1].axvline(1.0, color='green', linestyle='--', alpha=0.5)
    axes[1].fill_between(r, 0, cf_r, alpha=0.1)
    axes[1].set_xlabel('|p| (distance from origin)')
    axes[1].set_ylabel('Conformal factor λ²')
    axes[1].set_title('Cross-Section: Factor vs Distance')
    axes[1].legend()
    axes[1].set_xlim(0, 5)
    axes[1].grid(True, alpha=0.3)

    plt.suptitle('Figure 2: The Conformal Metric of Inverse Stereographic Projection',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig2_conformal_factor.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig2_conformal_factor.png")


# ═══════════════════════════════════════════════════════════════
# Figure 3: Circle-Preserving Property
# ═══════════════════════════════════════════════════════════════

def fig3_circle_preservation():
    """Show that circles on the plane map to circles on the sphere."""
    if not HAS_MPL:
        print("Figure 3: Circle preservation (requires matplotlib)")
        return

    fig = plt.figure(figsize=(16, 7))

    ax1 = fig.add_subplot(121)
    ax2 = fig.add_subplot(122, projection='3d')

    # Wireframe sphere
    phi_s = np.linspace(0, np.pi, 30)
    theta_s = np.linspace(0, 2*np.pi, 30)
    xs = np.outer(np.sin(phi_s), np.cos(theta_s))
    ys = np.outer(np.sin(phi_s), np.sin(theta_s))
    zs = np.outer(np.cos(phi_s), np.ones_like(theta_s))
    ax2.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    configs = [
        ("Circle r=0.5", 0, 0, 0.5),
        ("Circle r=1.0", 0, 0, 1.0),
        ("Circle r=2.0", 0, 0, 2.0),
        ("Off-center", 1.5, 0.5, 0.8),
        ("Off-center 2", -1, 1, 0.6),
    ]

    theta = np.linspace(0, 2*np.pi, 200)

    for i, (name, cx, cy, r) in enumerate(configs):
        u = cx + r * np.cos(theta)
        v = cy + r * np.sin(theta)

        # Plane
        ax1.plot(u, v, color=colors[i], linewidth=2, label=name)

        # Sphere
        x, y, z = inverse_stereo_np(u, v)
        ax2.plot(x, y, z, color=colors[i], linewidth=2, label=name)

    # Add a line (through origin) — should map to great circle
    t = np.linspace(-5, 5, 200)
    ax1.plot(t, 0.5 * t, color='black', linewidth=2, linestyle='--',
             label='Line (→ great circle)')
    x, y, z = inverse_stereo_np(t, 0.5 * t)
    ax2.plot(x, y, z, color='black', linewidth=2, linestyle='--',
             label='Great circle')

    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-4, 4)
    ax1.set_aspect('equal')
    ax1.legend(fontsize=8)
    ax1.set_title('Plane: Circles and Lines', fontsize=13)
    ax1.grid(True, alpha=0.3)

    ax2.legend(fontsize=8)
    ax2.set_title('Sphere: All Become Circles', fontsize=13)

    plt.suptitle('Figure 3: The Circle-Preserving Property',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig3_circle_preservation.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig3_circle_preservation.png")


# ═══════════════════════════════════════════════════════════════
# Figure 4: PISPD Pipeline Visualization
# ═══════════════════════════════════════════════════════════════

def fig4_pispd_pipeline():
    """Visualize the full PISPD capture → lift → rotate → project pipeline."""
    if not HAS_MPL:
        print("Figure 4: Pipeline (requires matplotlib)")
        return

    fig = plt.figure(figsize=(20, 5))

    # Stage 1: Planar pattern
    ax1 = fig.add_subplot(141)
    theta = np.linspace(0, 2*np.pi, 200)
    for k in range(1, 6):
        r = k * 0.4
        u = r * np.cos(theta + k * 0.3)
        v = r * np.sin(theta + k * 0.3)
        wl = 450 + 50 * k
        color = wavelength_to_rgb(wl)
        ax1.scatter(u, v, c=[color]*len(u), s=1, alpha=0.8)
    ax1.set_xlim(-2.5, 2.5)
    ax1.set_ylim(-2.5, 2.5)
    ax1.set_aspect('equal')
    ax1.set_title('①  Capture\n(Detector Plane)', fontsize=11)
    ax1.set_xlabel('u')

    # Stage 2: Lifted to sphere
    ax2 = fig.add_subplot(142, projection='3d')
    phi_s = np.linspace(0, np.pi, 20)
    theta_s = np.linspace(0, 2*np.pi, 20)
    xs = np.outer(np.sin(phi_s), np.cos(theta_s))
    ys = np.outer(np.sin(phi_s), np.sin(theta_s))
    zs = np.outer(np.cos(phi_s), np.ones_like(theta_s))
    ax2.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    for k in range(1, 6):
        r = k * 0.4
        u = r * np.cos(theta + k * 0.3)
        v = r * np.sin(theta + k * 0.3)
        x, y, z = inverse_stereo_np(u, v)
        wl = 450 + 50 * k
        color = wavelength_to_rgb(wl)
        ax2.scatter(x, y, z, c=[color]*len(x), s=1, alpha=0.8)
    ax2.set_title('②  Lift\n(Inverse Stereo → S²)', fontsize=11)

    # Stage 3: Rotated on sphere
    ax3 = fig.add_subplot(143, projection='3d')
    ax3.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    angle = np.pi / 4
    cos_a, sin_a = np.cos(angle), np.sin(angle)
    for k in range(1, 6):
        r = k * 0.4
        u = r * np.cos(theta + k * 0.3)
        v = r * np.sin(theta + k * 0.3)
        x, y, z = inverse_stereo_np(u, v)
        # Rotate around x-axis
        y_rot = cos_a * y - sin_a * z
        z_rot = sin_a * y + cos_a * z
        wl = 450 + 50 * k
        color = wavelength_to_rgb(wl)
        ax3.scatter(x, y_rot, z_rot, c=[color]*len(x), s=1, alpha=0.8)
    ax3.set_title('③  Process\n(Rotate 45° on S²)', fontsize=11)

    # Stage 4: Projected back
    ax4 = fig.add_subplot(144)
    for k in range(1, 6):
        r = k * 0.4
        u = r * np.cos(theta + k * 0.3)
        v = r * np.sin(theta + k * 0.3)
        x, y, z = inverse_stereo_np(u, v)
        y_rot = cos_a * y - sin_a * z
        z_rot = sin_a * y + cos_a * z
        mask = np.abs(z_rot - 1.0) > 0.05
        u_out, v_out = forward_stereo_np(x[mask], y_rot[mask], z_rot[mask])
        wl = 450 + 50 * k
        color = wavelength_to_rgb(wl)
        valid = ~np.isnan(u_out)
        ax4.scatter(u_out[valid], v_out[valid], c=[color]*np.sum(valid), s=1, alpha=0.8)
    ax4.set_xlim(-4, 4)
    ax4.set_ylim(-4, 4)
    ax4.set_aspect('equal')
    ax4.set_title('④  Project\n(Forward Stereo → ℝ²)', fontsize=11)
    ax4.set_xlabel('u')

    plt.suptitle('Figure 4: The PISPD Pipeline — Capture → Lift → Process → Project',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig4_pispd_pipeline.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig4_pispd_pipeline.png")


def wavelength_to_rgb(wavelength):
    """Approximate visible wavelength to RGB color."""
    if wavelength < 380:
        return (0.5, 0.0, 0.5)
    elif wavelength < 440:
        t = (wavelength - 380) / 60
        return (0.5 * (1 - t), 0.0, 0.5 + 0.5 * t)
    elif wavelength < 490:
        t = (wavelength - 440) / 50
        return (0.0, t, 1.0)
    elif wavelength < 510:
        t = (wavelength - 490) / 20
        return (0.0, 1.0, 1.0 - t)
    elif wavelength < 580:
        t = (wavelength - 510) / 70
        return (t, 1.0, 0.0)
    elif wavelength < 645:
        t = (wavelength - 580) / 65
        return (1.0, 1.0 - t, 0.0)
    elif wavelength < 700:
        return (1.0, 0.0, 0.0)
    else:
        return (0.5, 0.0, 0.0)


# ═══════════════════════════════════════════════════════════════
# Figure 5: Information Density Map
# ═══════════════════════════════════════════════════════════════

def fig5_information_density():
    """Show how uniform plane density becomes concentrated on the sphere."""
    if not HAS_MPL:
        print("Figure 5: Information density (requires matplotlib)")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Uniform distribution on plane
    n = 2000
    np.random.seed(42)
    u = np.random.uniform(-3, 3, n)
    v = np.random.uniform(-3, 3, n)

    axes[0].scatter(u, v, s=1, alpha=0.3, c='blue')
    axes[0].set_xlim(-3.5, 3.5)
    axes[0].set_ylim(-3.5, 3.5)
    axes[0].set_aspect('equal')
    axes[0].set_title('Uniform on Plane', fontsize=13)
    axes[0].set_xlabel('u')
    axes[0].set_ylabel('v')

    # Map to sphere
    x, y, z = inverse_stereo_np(u, v)

    # Sphere colored by density
    ax2 = fig.add_subplot(132, projection='3d')
    phi_s = np.linspace(0, np.pi, 20)
    theta_s = np.linspace(0, 2*np.pi, 20)
    xs = np.outer(np.sin(phi_s), np.cos(theta_s))
    ys = np.outer(np.sin(phi_s), np.sin(theta_s))
    zs = np.outer(np.cos(phi_s), np.ones_like(theta_s))
    ax2.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')
    ax2.scatter(x, y, z, s=1, alpha=0.3, c=z, cmap='coolwarm')
    ax2.set_title('Mapped to Sphere\n(Non-uniform!)', fontsize=13)

    # Histogram of z-values (latitude distribution)
    axes[2].hist(z, bins=50, color='steelblue', edgecolor='white', density=True)
    axes[2].axvline(0, color='red', linestyle='--', label='Equator')
    axes[2].set_xlabel('z-coordinate (latitude)')
    axes[2].set_ylabel('Density')
    axes[2].set_title('Latitude Distribution\n(Concentrated near z=1)', fontsize=13)
    axes[2].legend()

    plt.suptitle('Figure 5: Information Density Concentration Under Inverse Stereographic Projection',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig5_information_density.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig5_information_density.png")


# ═══════════════════════════════════════════════════════════════
# Figure 6: Möbius–Rotation Equivalence
# ═══════════════════════════════════════════════════════════════

def fig6_mobius_rotation():
    """Show that rotations on S² become Möbius transforms on ℝ²."""
    if not HAS_MPL:
        print("Figure 6: Möbius-rotation equivalence (requires matplotlib)")
        return

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    theta = np.linspace(0, 2*np.pi, 200)

    # Original patterns
    patterns = {
        'circles': lambda: (np.cos(theta), np.sin(theta)),
        'grid_h': lambda: (np.linspace(-2, 2, 200), np.zeros(200)),
        'grid_v': lambda: (np.zeros(200), np.linspace(-2, 2, 200)),
    }

    rotations = [0, np.pi/6, np.pi/3]
    rot_labels = ['0°', '30°', '60°']

    for j, (angle, label) in enumerate(zip(rotations, rot_labels)):
        ax = axes[0, j]
        cos_a, sin_a = np.cos(angle), np.sin(angle)

        # Draw circles at various radii
        for r in [0.3, 0.6, 1.0, 1.5, 2.0]:
            u = r * np.cos(theta)
            v = r * np.sin(theta)
            # Lift, rotate (y-axis), project
            x, y, z = inverse_stereo_np(u, v)
            y_rot = cos_a * y - sin_a * z
            z_rot = sin_a * y + cos_a * z
            u_out, v_out = forward_stereo_np(x, y_rot, z_rot)
            valid = ~np.isnan(u_out)
            ax.plot(u_out[valid], v_out[valid], linewidth=1)

        # Draw radial lines
        for ang in np.linspace(0, np.pi, 7):
            t = np.linspace(-3, 3, 200)
            u = t * np.cos(ang)
            v = t * np.sin(ang)
            x, y, z = inverse_stereo_np(u, v)
            y_rot = cos_a * y - sin_a * z
            z_rot = sin_a * y + cos_a * z
            u_out, v_out = forward_stereo_np(x, y_rot, z_rot)
            valid = ~np.isnan(u_out) & (np.abs(u_out) < 5) & (np.abs(v_out) < 5)
            ax.plot(u_out[valid], v_out[valid], 'gray', linewidth=0.5)

        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
        ax.set_aspect('equal')
        ax.set_title(f'Y-axis rotation: {label}', fontsize=11)
        ax.grid(True, alpha=0.2)

    # Bottom row: show the sphere rotation directly
    for j, (angle, label) in enumerate(zip(rotations, rot_labels)):
        ax = fig.add_subplot(2, 3, j + 4, projection='3d')
        cos_a, sin_a = np.cos(angle), np.sin(angle)

        # Wireframe
        phi_s = np.linspace(0, np.pi, 20)
        theta_s = np.linspace(0, 2*np.pi, 20)
        xs = np.outer(np.sin(phi_s), np.cos(theta_s))
        ys = np.outer(np.sin(phi_s), np.sin(theta_s))
        zs = np.outer(np.cos(phi_s), np.ones_like(theta_s))
        ax.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

        # Latitude circles
        for lat in np.linspace(-0.8, 0.8, 5):
            r_circle = np.sqrt(1 - lat**2)
            x_c = r_circle * np.cos(theta)
            y_c = r_circle * np.sin(theta)
            z_c = lat * np.ones_like(theta)
            # Rotate
            y_r = cos_a * y_c - sin_a * z_c
            z_r = sin_a * y_c + cos_a * z_c
            ax.plot(x_c, y_r, z_r, linewidth=1)

        ax.set_title(f'On S²: {label}', fontsize=11)

    plt.suptitle('Figure 6: Sphere Rotations ↔ Möbius Transformations on the Plane',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig6_mobius_rotation.png', dpi=150, bbox_inches='tight')
    print("  ✓ Saved fig6_mobius_rotation.png")


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

def main():
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║     PISPD Visualizer — Generating Figures                ║")
    print("╚═══════════════════════════════════════════════════════════╝\n")

    os.makedirs('/workspace/request-project/demos/figures', exist_ok=True)
    os.chdir('/workspace/request-project/demos/figures')

    fig1_inverse_stereo_grid()
    fig2_conformal_factor()
    fig3_circle_preservation()
    fig4_pispd_pipeline()
    fig5_information_density()
    fig6_mobius_rotation()

    if HAS_MPL:
        print("\n  All figures saved to demos/figures/")
    else:
        print("\n  Install matplotlib for figure generation:")
        print("    pip install matplotlib numpy")

    if "--show" in sys.argv and HAS_MPL:
        matplotlib.use('TkAgg')
        plt.show()


if __name__ == "__main__":
    main()
