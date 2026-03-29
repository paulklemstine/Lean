"""
Demo 3: Ricci Flow & Surgery — Perelman's Paradigm
====================================================
Visualizes how Ricci flow smooths a surface toward constant curvature,
develops singularities (north poles), and how surgery removes them.

This is the paradigm case for the Oracle Council's thesis: the solved
Millennium Problem demonstrates the pattern we seek in the unsolved ones.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import Normalize
from matplotlib import cm


def generate_dumbbell(t_param, n_u=100, n_v=50):
    """
    Generate a dumbbell-shaped surface that evolves under 'Ricci-like' flow.
    t_param in [0, 1]: 0 = initial dumbbell, 1 = near-singularity.
    """
    u = np.linspace(0, 2 * np.pi, n_u)
    v = np.linspace(-2, 2, n_v)
    U, V = np.meshgrid(u, v)

    # Dumbbell profile: two bulges connected by a neck
    neck_width = max(0.15, 0.8 - 0.65 * t_param)  # Neck shrinks with time
    bulge = 0.8

    # Profile function: radius as function of v
    R = bulge * np.exp(-V**2 / 1.5) + neck_width * np.exp(-V**2 / 0.3)
    R = np.clip(R, 0.05, None)

    X = R * np.cos(U)
    Y = R * np.sin(U)
    Z = V

    # Approximate Gaussian curvature (simplified for visualization)
    # High curvature at the neck
    K = 1.0 / (R**2 + 0.01)

    return X, Y, Z, K, R


def generate_post_surgery(n_u=100, n_v=50):
    """Generate two separate spherical caps (after surgery)."""
    u = np.linspace(0, 2 * np.pi, n_u)

    # Cap 1 (right)
    v1 = np.linspace(0.3, 2, n_v)
    U1, V1 = np.meshgrid(u, v1)
    R1 = 0.8 * np.exp(-V1**2 / 1.5) + 0.3 * np.exp(-(V1 - 0.3)**2 / 0.2)
    X1 = R1 * np.cos(U1)
    Y1 = R1 * np.sin(U1)
    Z1 = V1

    # Cap 2 (left)
    v2 = np.linspace(-2, -0.3, n_v)
    U2, V2 = np.meshgrid(u, v2)
    R2 = 0.8 * np.exp(-V2**2 / 1.5) + 0.3 * np.exp(-(V2 + 0.3)**2 / 0.2)
    X2 = R2 * np.cos(U2)
    Y2 = R2 * np.sin(U2)
    Z2 = V2

    return (X1, Y1, Z1), (X2, Y2, Z2)


def generate_round_sphere(center_z=0, radius=0.7, n_u=100, n_v=50):
    """Generate a round sphere (the endpoint of Ricci flow)."""
    u = np.linspace(0, 2*np.pi, n_u)
    v = np.linspace(0, np.pi, n_v)
    U, V = np.meshgrid(u, v)

    X = radius * np.sin(V) * np.cos(U)
    Y = radius * np.sin(V) * np.sin(U)
    Z = radius * np.cos(V) + center_z

    return X, Y, Z


def main():
    fig = plt.figure(figsize=(24, 14), facecolor='#0a0a2e')

    # Create a 2x4 grid with specific spacing
    gs = gridspec.GridSpec(2, 4, figure=fig, hspace=0.3, wspace=0.15,
                           height_ratios=[1, 0.3])

    stages = [
        (0.0, 'Stage 1: Initial\nDumbbell Manifold', 'Curvature varies smoothly'),
        (0.5, 'Stage 2: Ricci Flow\nNeck Pinching', 'Curvature concentrates\nat the neck'),
        (0.9, 'Stage 3: Near Singularity\n"North Pole" Forms', 'Curvature → ∞\nat pinch point'),
        (None, 'Stage 4: Surgery\n+ Continuation', 'Cut, cap, and flow\nto round spheres'),
    ]

    curvature_cmap = cm.hot

    for i, (t, title, description) in enumerate(stages):
        ax = fig.add_subplot(gs[0, i], projection='3d', facecolor='#0a0a2e')
        ax.set_title(title, color='white', fontsize=12, fontweight='bold', pad=5)

        if t is not None:
            # Draw evolving dumbbell
            X, Y, Z, K, R = generate_dumbbell(t)

            # Color by curvature
            K_norm = Normalize(vmin=0, vmax=np.percentile(K, 95))
            colors = curvature_cmap(K_norm(K))

            ax.plot_surface(X, Y, Z, facecolors=colors, alpha=0.85,
                           shade=True, lightsource=plt.matplotlib.colors.LightSource(315, 45))

            if t > 0.7:
                # Mark the singularity
                ax.scatter([0], [0], [0], color='red', s=200, zorder=10,
                          edgecolors='white', linewidth=2)
                ax.text(0, 0, 0.5, 'N', color='red', fontsize=16,
                        fontweight='bold', ha='center')

            ax.set_xlim([-1.2, 1.2])
            ax.set_ylim([-1.2, 1.2])
            ax.set_zlim([-2.5, 2.5])
        else:
            # Post-surgery: two separate spheres
            sphere1_data = generate_round_sphere(center_z=1.2, radius=0.6)
            sphere2_data = generate_round_sphere(center_z=-1.2, radius=0.6)

            # Draw spheres with uniform color (constant curvature)
            ax.plot_surface(*sphere1_data, color='#6bcb77', alpha=0.85, shade=True)
            ax.plot_surface(*sphere2_data, color='#4d96ff', alpha=0.85, shade=True)

            # Surgery markers
            ax.text(0, 0, 0, '✂ Surgery\nhere', color='#ffd93d', fontsize=9,
                    ha='center', fontweight='bold')

            ax.set_xlim([-1.2, 1.2])
            ax.set_ylim([-1.2, 1.2])
            ax.set_zlim([-2.5, 2.5])

        ax.set_axis_off()
        ax.view_init(elev=15, azim=30)

        # Description below
        ax_desc = fig.add_subplot(gs[1, i], facecolor='#0a0a2e')
        ax_desc.set_axis_off()
        ax_desc.text(0.5, 0.7, description, color='#aaaacc', fontsize=10,
                     ha='center', va='center', style='italic',
                     transform=ax_desc.transAxes)

        # Arrow between panels (except last)
        if i < 3:
            arrow_text = '→' if i < 2 else '✂→'
            color = 'white' if i < 2 else '#ffd93d'
            ax_desc.text(1.1, 0.7, arrow_text, color=color, fontsize=24,
                        fontweight='bold', transform=ax_desc.transAxes,
                        ha='center', va='center')

    fig.suptitle("PERELMAN'S PARADIGM: Ricci Flow, Surgery & the Removable North Pole\n"
                 "The singularity forms → is classified → is removed → the manifold is a sphere",
                 color='white', fontsize=17, fontweight='bold', y=0.98)

    # Add legend/annotation at bottom
    fig.text(0.5, 0.02,
             'Colors indicate Gaussian curvature (dark = low, bright = high). '
             'The "north pole" is the singularity where curvature concentrates to infinity.\n'
             'Surgery removes the singularity and caps the resulting boundaries with standard spherical caps.',
             color='#666688', fontsize=9, ha='center', style='italic')

    plt.savefig('/workspace/request-project/oracle_council/demos/demo3_ricci_flow_surgery.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo3_ricci_flow_surgery.png")


if __name__ == '__main__':
    main()
