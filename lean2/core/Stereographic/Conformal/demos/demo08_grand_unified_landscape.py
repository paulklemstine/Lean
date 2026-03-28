#!/usr/bin/env python3
"""
Demo 08: The Grand Unified Landscape — All Nine Worlds
========================================================
A single panoramic visualization showing all nine mathematical landscapes
connected by inverse stereographic projection, with the connections between them.

The original 6 landscapes + 3 new ones discovered in this expedition.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.patches import FancyArrowPatch, Circle
import matplotlib.patches as mpatches

fig = plt.figure(figsize=(24, 18))
fig.patch.set_facecolor('#0a0a2e')
fig.suptitle("The Grand Unified Landscape of Inverse Stereographic Projection",
             fontsize=20, fontweight='bold', color='white', y=0.97)

# === Central formula ===
ax_center = fig.add_axes([0.3, 0.42, 0.4, 0.18])
ax_center.set_facecolor('#0a0a2e')
ax_center.axis('off')
ax_center.text(0.5, 0.6,
    r'$\sigma_N^{-1}(y) = \left(\frac{2y_1}{D},\ldots,\frac{2y_N}{D},\frac{D-2}{D}\right)$'
    r'$\quad D = 1 + \|y\|^2$',
    fontsize=18, color='gold', ha='center', va='center',
    transform=ax_center.transAxes,
    bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a4e', edgecolor='gold', linewidth=2))
ax_center.text(0.5, 0.15,
    'The One Formula That Connects Nine Worlds',
    fontsize=14, color='silver', ha='center', va='center',
    transform=ax_center.transAxes, fontstyle='italic')

# === The 9 landscape panels ===
def inverse_stereo_2d(y1, y2):
    D = 1 + y1**2 + y2**2
    return 2*y1/D, 2*y2/D, (D-2)/D

# Panel positions in a circle around center
panel_specs = [
    # (position, title, color, description)
    ([0.02, 0.65, 0.28, 0.28], "1. Conformal Structure", '#e41a1c',
     "λ = 2/(1+|y|²)\nAngle-preserving\nLiouville rigidity"),
    ([0.36, 0.72, 0.28, 0.28], "2. Möbius Group", '#377eb8',
     "PSL(2,C) ≅ SO(3,1)\nFractal limit sets\nKleinian groups"),
    ([0.70, 0.65, 0.28, 0.28], "3. Number Theory", '#4daf4a',
     "Pythagorean tuples\nQuadratic forms\nRational points on Sⁿ"),
    ([0.02, 0.35, 0.28, 0.25], "4. Hopf Fibration", '#984ea3',
     "S³ → S² fiber bundle\nQuaternion structure\nLinking numbers"),
    ([0.70, 0.35, 0.28, 0.25], "5. Lorentzian Geometry", '#ff7f00',
     "Conformal compactification\nNull cone structure\nCFT radial quantization"),
    ([0.02, 0.05, 0.28, 0.28], "6. Apollonian Packings", '#a65628',
     "Descartes circle theorem\nInteger curvatures\nFractal dimension"),
    ([0.36, 0.05, 0.28, 0.25], "7. Stereographic Dynamics", '#f781bf',
     "Pulled-back flows\nConformal damping\nStereographic Lyapunov"),
    ([0.70, 0.05, 0.28, 0.28], "8. Morphogenesis", '#66c2a5',
     "Turing patterns on S²\nScale hierarchy\nLattice crystallization"),
    ([0.36, 0.32, 0.28, 0.1], "9. Information Geometry", '#fc8d62',
     "Fisher metric on S²\nConformal KL divergence\nEntropy compactification"),
]

for pos, title, color, desc in panel_specs:
    ax = fig.add_axes(pos)
    ax.set_facecolor('#0f0f3e')
    
    # Mini-visualization for each landscape
    if "Conformal" in title and "1." in title:
        r = np.linspace(0, 4, 100)
        theta = np.linspace(0, 2*np.pi, 100)
        R, T = np.meshgrid(r, theta)
        Y1 = R * np.cos(T)
        Y2 = R * np.sin(T)
        lam = 2.0 / (1 + R**2)
        ax.pcolormesh(Y1, Y2, lam, cmap='inferno', shading='auto')
        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
    elif "Möbius" in title:
        np.random.seed(7)
        # Schottky group fractal
        for _ in range(5000):
            z = np.random.randn(2) * 0.1
            for _ in range(30):
                choice = np.random.randint(4)
                r2 = z[0]**2 + z[1]**2 + 0.01
                if choice == 0:
                    z = z / r2 + np.array([1.5, 0])
                elif choice == 1:
                    z = z / r2 - np.array([1.5, 0])
                elif choice == 2:
                    z = np.array([-z[1], z[0]]) * 0.8 + np.array([0, 1])
                else:
                    z = z * 0.7 - np.array([0.5, 0.5])
            ax.plot(z[0], z[1], '.', color=color, markersize=0.3, alpha=0.3)
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
    elif "Number" in title:
        # Rational points on circle
        for m in range(1, 20):
            for n in range(1, m):
                if np.gcd(m, n) == 1:
                    a = 2*m*n
                    b = m**2 - n**2
                    c = m**2 + n**2
                    ax.plot(a/c, b/c, 'o', color=color, markersize=3, alpha=0.7)
        theta = np.linspace(0, 2*np.pi, 100)
        ax.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=0.5, alpha=0.3)
        ax.set_xlim(-1.2, 1.2)
        ax.set_ylim(-1.2, 1.2)
    elif "Hopf" in title:
        # Hopf circles
        for phi in np.linspace(0, np.pi, 8):
            for psi in np.linspace(0, 2*np.pi, 8):
                t = np.linspace(0, 2*np.pi, 100)
                x = np.cos(phi) * np.cos(t)
                y = np.cos(phi) * np.sin(t)
                z = np.sin(phi) * np.cos(t + psi)
                ax.plot(x + 0.3*z, y + 0.3*z, color=cm.hsv(phi/np.pi),
                        linewidth=0.5, alpha=0.5)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
    elif "Lorentz" in title:
        # Light cone
        t = np.linspace(-2, 2, 100)
        for sign in [-1, 1]:
            ax.plot(t, sign*t, 'y-', linewidth=1, alpha=0.7)
            ax.fill_between(t, 0, sign*t, alpha=0.1, color='yellow')
        ax.plot([-2, 2], [0, 0], 'w--', linewidth=0.5, alpha=0.3)
        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-2.5, 2.5)
    elif "Apollonian" in title:
        # Simple Apollonian-like circles
        def draw_circle(ax, cx, cy, r, depth=0, max_depth=4):
            circle = plt.Circle((cx, cy), r, fill=False, color=color, linewidth=max(0.3, 1-depth*0.2))
            ax.add_patch(circle)
            if depth < max_depth:
                r2 = r / 2.5
                for dx, dy in [(r-r2, 0), (-(r-r2), 0), (0, r-r2), (0, -(r-r2))]:
                    draw_circle(ax, cx+dx, cy+dy, r2, depth+1, max_depth)
        draw_circle(ax, 0, 0, 2)
        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-2.5, 2.5)
    elif "Dynamics" in title:
        # Spiral flow
        Y = np.linspace(-2, 2, 12)
        Y1, Y2 = np.meshgrid(Y, Y)
        V1 = -Y1/2 + Y2
        V2 = -Y1 - Y2/2
        ax.streamplot(Y, Y, V1, V2, color='white', linewidth=0.5, density=1.5,
                      arrowsize=0.8)
        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-2.5, 2.5)
    elif "Morpho" in title:
        # Turing-like pattern
        np.random.seed(123)
        N = 100
        pattern = np.random.randn(N, N) * 0.1
        from scipy.ndimage import gaussian_filter
        pattern = gaussian_filter(pattern, sigma=3) - gaussian_filter(pattern, sigma=6)
        ax.imshow(pattern, cmap='RdBu_r', extent=[-3, 3, -3, 3])
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
    elif "Information" in title:
        # KL divergence contours
        mu = np.linspace(-3, 3, 100)
        sigma = np.linspace(0.1, 3, 100)
        MU, SIG = np.meshgrid(mu, sigma)
        KL = np.log(1.0/SIG) + (SIG**2 + MU**2)/2 - 0.5
        ax.contourf(MU, SIG, KL, levels=15, cmap='cool', alpha=0.7)
        ax.set_xlim(-3, 3)
        ax.set_ylim(0, 3)
    
    ax.set_aspect('equal')
    for spine in ax.spines.values():
        spine.set_edgecolor(color)
        spine.set_linewidth(2)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_title(title, fontsize=11, fontweight='bold', color=color, pad=4)
    
    # Description text
    ax.text(0.03, 0.03, desc, transform=ax.transAxes, fontsize=7.5,
            color='white', verticalalignment='bottom',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='black', alpha=0.7))

# Connection annotations
ax_center.text(0.5, -0.5,
    "Unifying Structure: SO(N+1,1) — the Lorentz Group\n"
    "All 9 landscapes are aspects of the symmetry group of the stereographic map itself.\n"
    "The conformal factor λ = 2/(1+|y|²) is the thread connecting every world.",
    fontsize=11, color='silver', ha='center', va='center',
    transform=ax_center.transAxes, fontstyle='italic',
    bbox=dict(boxstyle='round', facecolor='#1a1a4e', edgecolor='silver', linewidth=1))

plt.savefig('/workspace/request-project/demos/demo08_grand_unified_landscape.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
plt.close()
print("✅ Demo 08 saved: demos/demo08_grand_unified_landscape.png")
