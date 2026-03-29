#!/usr/bin/env python3
"""
Demo 08: Grand Unification — All Six Landscapes Connected

The final synthesis showing how all six new landscapes connect through
the single formula σ⁻¹(y) = (2y/(1+|y|²), (|y|²-1)/(|y|²+1)).

The Counselor's Synthesis: "Six landscapes, one formula, one conformal group."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm
import matplotlib.patches as mpatches
from matplotlib.colors import Normalize

def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

def draw_sphere(ax, alpha=0.04):
    u = np.linspace(0, 2*np.pi, 30)
    v = np.linspace(0, np.pi, 15)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(x, y, z, color='gray', alpha=alpha, linewidth=0.3)

fig = plt.figure(figsize=(24, 20))
fig.suptitle("Grand Unification: Six New Landscapes Connected by σ⁻¹\n"
             "The Counselor — \"The conformal group is the stage. σ⁻¹ is the curtain.\"",
             fontsize=18, fontweight='bold', y=0.98)

# --- Panel 1: The Central Formula ---
ax1 = fig.add_subplot(3, 3, 1)
ax1.text(0.5, 0.8, r'$\sigma_N^{-1}: \mathbb{R}^N \to S^N$',
         fontsize=20, ha='center', va='center', transform=ax1.transAxes,
         fontweight='bold', color='navy')
ax1.text(0.5, 0.55, r'$\sigma^{-1}(y) = \left(\frac{2y}{1+\|y\|^2}, \frac{\|y\|^2-1}{\|y\|^2+1}\right)$',
         fontsize=14, ha='center', va='center', transform=ax1.transAxes)
ax1.text(0.5, 0.3, "The One Formula\nThat Connects\nSix Worlds",
         fontsize=14, ha='center', va='center', transform=ax1.transAxes,
         style='italic', color='darkred')

landscape_info = [
    ("⟐ Dynamics", "Julia sets on S²\nChaos revealed", "#FF4444"),
    ("⟁ Information", "Fisher sphere\nBayesian geometry", "#44AA44"),
    ("⊛ Quantum", "Bloch cosmos\nGates as Möbius", "#4444FF"),
    ("⊘ Knots", "S³ → ℝ³ shadows\nCrossing numbers", "#FF8800"),
    ("⟠ Spectral", "Eigenvalue bridge\nHeat kernels", "#8844FF"),
    ("✦ Fractals", "Mandelbrot sphere\nCompact chaos", "#FF44AA"),
]

y_pos = 0.15
for name, desc, color in landscape_info:
    ax1.text(0.5, y_pos, f"{name}", fontsize=9, ha='center', va='center',
             transform=ax1.transAxes, color=color, fontweight='bold')
    y_pos -= 0.03

ax1.set_xlim([0, 1]); ax1.set_ylim([0, 1])
ax1.axis('off')

# --- Panel 2: Landscape 1 — Dynamics (Julia on S²) ---
ax2 = fig.add_subplot(3, 3, 2, projection='3d')
draw_sphere(ax2, alpha=0.03)

n_pts = 100
phi = np.linspace(0, 2*np.pi, n_pts*2)
theta = np.linspace(0.1, np.pi-0.1, n_pts)
PHI, THETA = np.meshgrid(phi, theta)
r_s = np.tan(THETA / 2)
U_s = r_s * np.cos(PHI)
V_s = r_s * np.sin(PHI)
C_s = U_s + 1j * V_s

escape = np.zeros_like(U_s)
c_val = -0.12 + 0.74j
for i in range(escape.shape[0]):
    for j in range(escape.shape[1]):
        z = C_s[i, j]
        for k in range(40):
            if abs(z) > 2:
                escape[i, j] = k; break
            z = z*z + c_val
        else:
            escape[i, j] = 40

X_s = np.sin(THETA) * np.cos(PHI)
Y_s = np.sin(THETA) * np.sin(PHI)
Z_s = np.cos(THETA)
colors = cm.inferno(Normalize(0, 40)(escape))
ax2.plot_surface(X_s, Y_s, Z_s, facecolors=colors, shade=False, alpha=0.9)
ax2.set_title("⟐ Dynamics\nJulia on S²", fontsize=11, color='#FF4444')
ax2.set_xlim([-1.1, 1.1]); ax2.set_ylim([-1.1, 1.1]); ax2.set_zlim([-1.1, 1.1])
ax2.view_init(elev=20, azim=45)

# --- Panel 3: Landscape 2 — Information (Fisher sphere) ---
ax3 = fig.add_subplot(3, 3, 3, projection='3d')
draw_sphere(ax3, alpha=0.03)

mus = np.linspace(-3, 3, 25)
sigmas = np.logspace(-0.3, 1.2, 20)
for mu in mus:
    for sigma in sigmas:
        z = mu + 1j * sigma
        w = (z - 1j) / (z + 1j)
        sx, sy, sz = inv_stereo(w.real * 2, w.imag * 2)
        color = cm.coolwarm(Normalize(-0.5, 1.5)(np.log10(sigma)))
        ax3.scatter([sx], [sy], [sz], color=color, s=3, alpha=0.5)

ax3.set_title("⟁ Information\nFisher Sphere", fontsize=11, color='#44AA44')
ax3.set_xlim([-1.1, 1.1]); ax3.set_ylim([-1.1, 1.1]); ax3.set_zlim([-1.1, 1.1])
ax3.view_init(elev=25, azim=60)

# --- Panel 4: Landscape 3 — Quantum (Bloch sphere) ---
ax4 = fig.add_subplot(3, 3, 4, projection='3d')
draw_sphere(ax4, alpha=0.05)

# Random quantum states
np.random.seed(42)
for _ in range(200):
    theta_q = np.random.uniform(0, np.pi)
    phi_q = np.random.uniform(0, 2*np.pi)
    x, y, z = np.sin(theta_q)*np.cos(phi_q), np.sin(theta_q)*np.sin(phi_q), np.cos(theta_q)

    # Color by purity (pure states on surface)
    purity = np.random.uniform(0.5, 1.0)
    ax4.scatter([x*purity], [y*purity], [z*purity],
                color=cm.plasma(purity), s=10, alpha=0.6)

# Special states
for name, pos, color in [('|0⟩', (0,0,-1), 'blue'), ('|1⟩', (0,0,1), 'red'),
                          ('|+⟩', (1,0,0), 'green')]:
    ax4.scatter([pos[0]], [pos[1]], [pos[2]], color=color, s=80, zorder=10,
                edgecolor='black', linewidth=1)
    ax4.text(pos[0]*1.3, pos[1]*1.3, pos[2]*1.3, name, fontsize=9, fontweight='bold')

ax4.set_title("⊛ Quantum\nBloch Cosmos", fontsize=11, color='#4444FF')
ax4.set_xlim([-1.3, 1.3]); ax4.set_ylim([-1.3, 1.3]); ax4.set_zlim([-1.3, 1.3])
ax4.view_init(elev=20, azim=30)

# --- Panel 5: Landscape 4 — Knots (trefoil from S³) ---
ax5 = fig.add_subplot(3, 3, 5, projection='3d')

# Trefoil knot parametrization in ℝ³
t = np.linspace(0, 2*np.pi, 1000)
x_k = np.sin(t) + 2*np.sin(2*t)
y_k = np.cos(t) - 2*np.cos(2*t)
z_k = -np.sin(3*t)

# Normalize and project to sphere neighborhood
scale = 3
x_k /= scale; y_k /= scale; z_k /= scale

for i in range(len(t)-1):
    ax5.plot(x_k[i:i+2], y_k[i:i+2], z_k[i:i+2],
             color=cm.hsv(t[i]/(2*np.pi)), linewidth=2.5, alpha=0.8)

ax5.set_title("⊘ Knots\nTrefoil from S³", fontsize=11, color='#FF8800')
ax5.view_init(elev=20, azim=60)

# --- Panel 6: Landscape 5 — Spectral (harmonics) ---
ax6 = fig.add_subplot(3, 3, 6)

res2 = 300
u2 = np.linspace(-3, 3, res2)
v2 = np.linspace(-3, 3, res2)
U2, V2 = np.meshgrid(u2, v2)
R2 = U2**2 + V2**2
D2 = 1 + R2
THETA2 = np.arctan2(V2, U2)

# Y_3^2 in stereographic coords
theta_s = 2 * np.arctan(np.sqrt(R2))
phi_s = np.arctan2(V2, U2)
from scipy.special import sph_harm_y
Y32 = sph_harm_y(3, 2, theta_s, phi_s).real

im6 = ax6.pcolormesh(U2, V2, Y32, cmap='RdBu_r', shading='auto')
ax6.set_title("⟠ Spectral\nY₃² in Stereo Coords", fontsize=11, color='#8844FF')
ax6.set_aspect('equal')
ax6.set_xlim([-3, 3]); ax6.set_ylim([-3, 3])
theta_c = np.linspace(0, 2*np.pi, 100)
ax6.plot(np.cos(theta_c), np.sin(theta_c), 'k-', linewidth=1, alpha=0.5)

# --- Panel 7: Landscape 6 — Fractals (Mandelbrot on S²) ---
ax7 = fig.add_subplot(3, 3, 7, projection='3d')

escape2 = np.zeros_like(U_s)
for i in range(escape2.shape[0]):
    for j in range(escape2.shape[1]):
        z = 0
        c = C_s[i, j]
        for k in range(40):
            if abs(z) > 2:
                escape2[i, j] = k; break
            z = z*z + c
        else:
            escape2[i, j] = 40

colors2 = cm.magma(Normalize(0, 40)(escape2))
ax7.plot_surface(X_s, Y_s, Z_s, facecolors=colors2, shade=False, alpha=0.9)
ax7.set_title("✦ Fractals\nMandelbrot Sphere", fontsize=11, color='#FF44AA')
ax7.set_xlim([-1.1, 1.1]); ax7.set_ylim([-1.1, 1.1]); ax7.set_zlim([-1.1, 1.1])
ax7.view_init(elev=30, azim=-45)

# --- Panel 8: Connection Diagram ---
ax8 = fig.add_subplot(3, 3, 8)
ax8.set_xlim([-1.5, 1.5]); ax8.set_ylim([-1.5, 1.5])
ax8.set_aspect('equal')
ax8.axis('off')

# Draw hexagonal connection diagram
labels = ['Dynamics', 'Information', 'Quantum', 'Knots', 'Spectral', 'Fractals']
colors_hex = ['#FF4444', '#44AA44', '#4444FF', '#FF8800', '#8844FF', '#FF44AA']
angles_hex = np.linspace(0, 2*np.pi, 7)[:-1] + np.pi/2

for i in range(6):
    x = np.cos(angles_hex[i])
    y = np.sin(angles_hex[i])
    circle = plt.Circle((x, y), 0.25, color=colors_hex[i], alpha=0.3)
    ax8.add_patch(circle)
    ax8.text(x, y, labels[i], ha='center', va='center', fontsize=9,
             fontweight='bold', color=colors_hex[i])

    # Connect to all others
    for j in range(i+1, 6):
        x2 = np.cos(angles_hex[j])
        y2 = np.sin(angles_hex[j])
        ax8.plot([x, x2], [y, y2], 'k-', alpha=0.15, linewidth=1)

# Center: σ⁻¹
center = plt.Circle((0, 0), 0.3, color='gold', alpha=0.4)
ax8.add_patch(center)
ax8.text(0, 0, 'σ⁻¹\nConformal\nGroup', ha='center', va='center',
         fontsize=10, fontweight='bold', color='darkgoldenrod')

for i in range(6):
    x = np.cos(angles_hex[i]) * 0.7
    y = np.sin(angles_hex[i]) * 0.7
    ax8.plot([0, x], [0, y], 'gold', alpha=0.5, linewidth=2)

ax8.set_title("Connection Map\nAll roads lead to σ⁻¹", fontsize=11)

# --- Panel 9: Key theorems summary ---
ax9 = fig.add_subplot(3, 3, 9)
ax9.axis('off')

theorems = [
    ("Theorem 1", "σ⁻¹ conjugates z→z²+c to a\nsmooth map on S²", "#FF4444"),
    ("Theorem 2", "Fisher metric under σ⁻¹ becomes\nthe round metric for exponentials", "#44AA44"),
    ("Theorem 3", "Quantum gates = Möbius maps\nin stereographic coords", "#4444FF"),
    ("Theorem 4", "Knot crossing # depends on\nprojection point in S³", "#FF8800"),
    ("Theorem 5", "Spherical eigenvalues become\nweighted flat eigenvalues", "#8844FF"),
    ("Theorem 6", "Mandelbrot set is compact\non S² (no escape radius)", "#FF44AA"),
]

for i, (name, desc, color) in enumerate(theorems):
    y = 0.88 - i * 0.15
    ax9.text(0.05, y, name, fontsize=11, fontweight='bold', color=color,
             transform=ax9.transAxes)
    ax9.text(0.05, y - 0.06, desc, fontsize=9, color='black',
             transform=ax9.transAxes)
    # separator line
    ax9.plot([0.02, 0.98], [y - 0.1, y - 0.1], color='gray',
             alpha=0.2, linewidth=0.5, transform=ax9.transAxes)

ax9.set_title("Key Theorems", fontsize=11)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo08_grand_unification.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 08: Grand Unification saved.")
