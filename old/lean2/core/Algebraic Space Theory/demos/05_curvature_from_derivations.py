"""
Demo 5: Curvature from Non-commutativity of Derivations
========================================================
The Algebraic Theory of Space — Pillar V

In differential geometry, curvature measures how covariant derivatives
fail to commute. Algebraically, derivations δ: A → A satisfying the
Leibniz rule δ(ab) = aδ(b) + δ(a)b form a Lie algebra.

Curvature = [∇_X, ∇_Y] - ∇_{[X,Y]}

We visualize this for surfaces of varying curvature and show how
the commutator of derivations captures geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm

def plot_curvature_surfaces():
    """Show surfaces with different curvatures and their algebraic signatures."""
    fig = plt.figure(figsize=(18, 12))

    surfaces = [
        {
            'title': 'Flat (ℝ²)\nCurvature = 0',
            'subtitle': '[∂/∂x, ∂/∂y] = 0\nDerivations commute!',
            'color': '#377eb8',
            'func': lambda u, v: (u, v, np.zeros_like(u)),
            'u_range': (-2, 2), 'v_range': (-2, 2),
        },
        {
            'title': 'Sphere (S²)\nCurvature = +1/R²',
            'subtitle': '[∇_θ, ∇_φ] ≠ ∇_{[∂_θ, ∂_φ]}\nNon-commuting!',
            'color': '#e41a1c',
            'func': lambda u, v: (np.cos(u)*np.cos(v), np.sin(u)*np.cos(v), np.sin(v)),
            'u_range': (0, 2*np.pi), 'v_range': (-np.pi/2, np.pi/2),
        },
        {
            'title': 'Saddle (K < 0)\nCurvature = −1',
            'subtitle': 'Negative curvature =\nopposite non-commutativity',
            'color': '#4daf4a',
            'func': lambda u, v: (u, v, u**2 - v**2),
            'u_range': (-1.5, 1.5), 'v_range': (-1.5, 1.5),
        },
    ]

    for idx, surf in enumerate(surfaces):
        ax = fig.add_subplot(2, 3, idx + 1, projection='3d')

        u = np.linspace(*surf['u_range'], 40)
        v = np.linspace(*surf['v_range'], 40)
        U, V = np.meshgrid(u, v)
        X, Y, Z = surf['func'](U, V)

        ax.plot_surface(X, Y, Z, alpha=0.6, cmap=cm.coolwarm,
                       edgecolor='gray', linewidth=0.2)
        ax.set_title(surf['title'], fontsize=11, fontweight='bold', pad=10)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_zlabel('z')

    # Bottom row: algebraic interpretation
    for idx, surf in enumerate(surfaces):
        ax = fig.add_subplot(2, 3, idx + 4)
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)

        ax.text(5, 7, surf['subtitle'], ha='center', va='center',
                fontsize=13, fontweight='bold', color=surf['color'],
                bbox=dict(boxstyle='round', facecolor=surf['color'], alpha=0.1))

        if idx == 0:
            ax.text(5, 3,
                    'On flat space:\n'
                    '∂²f/∂x∂y = ∂²f/∂y∂x\n'
                    'Mixed partials commute\n'
                    '⟹ Curvature = 0',
                    ha='center', va='center', fontsize=11,
                    fontfamily='serif')
        elif idx == 1:
            ax.text(5, 3,
                    'On the sphere:\n'
                    'Parallel transport around\n'
                    'a closed loop ROTATES vectors\n'
                    '⟹ [∇,∇] ≠ 0 ⟹ K > 0',
                    ha='center', va='center', fontsize=11,
                    fontfamily='serif')
        else:
            ax.text(5, 3,
                    'On a saddle:\n'
                    'Parallel transport rotates\n'
                    'in the OPPOSITE direction\n'
                    '⟹ [∇,∇] ≠ 0 ⟹ K < 0',
                    ha='center', va='center', fontsize=11,
                    fontfamily='serif')

        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_visible(False)

    fig.suptitle("Pillar V: Curvature = Failure of Derivations to Commute",
                 fontsize=16, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/05_curvature_surfaces.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 05_curvature_surfaces.png")


def plot_parallel_transport():
    """Animate parallel transport showing curvature as holonomy."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Flat: parallel transport around a square — no rotation
    ax = axes[0]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_title("Flat Space: No Holonomy", fontsize=13, fontweight='bold')

    # Square path
    path_x = [0, 1, 1, 0, 0]
    path_y = [0, 0, 1, 1, 0]
    ax.plot(path_x, path_y, 'k-', lw=2)

    # Vector at each corner (stays the same!)
    for i in range(4):
        ax.annotate('', xy=(path_x[i]+0.3, path_y[i]+0.3),
                    xytext=(path_x[i], path_y[i]),
                    arrowprops=dict(arrowstyle='->', color='crimson', lw=2))

    ax.text(0.5, -1, 'Vector returns UNCHANGED\n[∂_x, ∂_y] = 0',
            ha='center', fontsize=10, color='crimson', fontweight='bold')
    ax.grid(True, alpha=0.2)

    # Sphere: parallel transport around a triangle — 90° rotation
    ax = axes[1]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_title("Sphere: 90° Holonomy", fontsize=13, fontweight='bold')

    # Triangular path on sphere (projected)
    t = np.linspace(0, 2*np.pi, 100)
    ax.plot(1.5*np.cos(t), 1.5*np.sin(t), 'k--', alpha=0.2)

    path_x = [0, 1.5, 0, 0]
    path_y = [1.5, 0, 0, 1.5]
    ax.plot(path_x, path_y, 'b-', lw=2)

    # Vectors showing rotation
    ax.annotate('', xy=(0.3, 1.8), xytext=(0, 1.5),
                arrowprops=dict(arrowstyle='->', color='crimson', lw=2))
    ax.annotate('', xy=(1.5, 0.3), xytext=(1.5, 0),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.annotate('', xy=(-0.3, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2))
    ax.annotate('', xy=(0, 1.8), xytext=(0, 1.5),
                arrowprops=dict(arrowstyle='->', color='purple', lw=2, linestyle='--'))

    ax.text(0.5, -1.5, 'Vector ROTATED 90°!\nHolonomy = Area × Curvature',
            ha='center', fontsize=10, color='crimson', fontweight='bold')
    ax.grid(True, alpha=0.2)

    # Algebraic interpretation
    ax = axes[2]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_title("The Algebraic Formula", fontsize=13, fontweight='bold')

    ax.text(5, 8, 'Curvature 2-form:', ha='center', fontsize=14, fontweight='bold')
    ax.text(5, 6.5, 'R(X,Y) = [∇_X, ∇_Y] − ∇_{[X,Y]}',
            ha='center', fontsize=16, fontfamily='serif',
            bbox=dict(boxstyle='round', facecolor='lightyellow'))

    ax.text(5, 4.5, 'In words:', ha='center', fontsize=12, fontweight='bold')
    ax.text(5, 3,
            '"Curvature measures how much\n'
            'covariant differentiation fails\n'
            'to be a Lie algebra homomorphism\n'
            'from vector fields to operators."',
            ha='center', fontsize=11, style='italic', color='navy')

    ax.text(5, 1,
            'Flat ⟺ ∇ is a Lie algebra homomorphism\n'
            'Curved ⟺ ∇ "breaks" the Lie bracket',
            ha='center', fontsize=10, color='crimson',
            bbox=dict(boxstyle='round', facecolor='#ffe0e0'))

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    fig.suptitle("Curvature as Holonomy: The Algebraic Viewpoint",
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Space Theory/demos/05_parallel_transport.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved 05_parallel_transport.png")


if __name__ == "__main__":
    plot_curvature_surfaces()
    plot_parallel_transport()
    print("\n🎯 Pillar V demos complete: Curvature from derivations!")
