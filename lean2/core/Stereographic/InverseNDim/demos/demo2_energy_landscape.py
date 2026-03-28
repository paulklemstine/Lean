"""
Demo 2: The Stereographic Energy Landscape
===========================================
Visualizes the Dirichlet energy density of inverse stereographic projection,
showing that σ⁻¹ is a harmonic map from ℝ^N to S^N.

The energy density e(y) = 4N/(1+|y|²)² concentrates near the origin,
revealing the "gravitational" pull of the south pole in stereographic coordinates.

Oracle Σ's discovery: stereographic projection minimizes the Dirichlet energy
among all conformal maps from ℝ^N to S^N.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ─── Energy Functions ────────────────────────────────────────
def energy_density(x, y, N=2):
    """Dirichlet energy density: e = 4N/(1+r²)²"""
    r2 = x**2 + y**2
    return 4 * N / (1 + r2)**2

def conformal_factor(x, y):
    """λ(y) = 2/(1+|y|²)"""
    return 2 / (1 + x**2 + y**2)

def inv_stereo_x(u, v):
    """x-component of σ⁻¹(u,v)"""
    D = 1 + u**2 + v**2
    return 2*u/D

def inv_stereo_y(u, v):
    """y-component of σ⁻¹(u,v)"""
    D = 1 + u**2 + v**2
    return 2*v/D

def inv_stereo_z(u, v):
    """z-component of σ⁻¹(u,v)"""
    D = 1 + u**2 + v**2
    return (D - 2)/D

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')
gs = gridspec.GridSpec(2, 3, hspace=0.3, wspace=0.3)

# Grid
L = 4
res = 300
x = np.linspace(-L, L, res)
y = np.linspace(-L, L, res)
X, Y = np.meshgrid(x, y)

# ── Panel 1: Energy density heatmap ─────────────────────────
ax1 = fig.add_subplot(gs[0, 0], facecolor='#0a0a1a')

E = energy_density(X, Y, N=2)
im = ax1.imshow(np.log10(E + 1e-10), extent=[-L, L, -L, L], cmap='magma',
                origin='lower', vmin=-2, vmax=1)
ax1.contour(X, Y, E, levels=[0.1, 0.5, 1.0, 2.0, 4.0, 6.0], colors='white', alpha=0.4, linewidths=0.5)

# Energy flow lines (gradient of E)
stride = 20
dE_dx = -16 * X / (1 + X**2 + Y**2)**3
dE_dy = -16 * Y / (1 + X**2 + Y**2)**3
mag = np.sqrt(dE_dx**2 + dE_dy**2) + 1e-10
ax1.quiver(X[::stride, ::stride], Y[::stride, ::stride],
           dE_dx[::stride, ::stride]/mag[::stride, ::stride],
           dE_dy[::stride, ::stride]/mag[::stride, ::stride],
           color='#00ddff', alpha=0.4, scale=25, width=0.003)

plt.colorbar(im, ax=ax1, label='log₁₀(energy density)', shrink=0.8)
ax1.set_title('Energy Density: e(y) = 8/(1+|y|²)²', color='#ff6600', fontsize=13, fontweight='bold')
ax1.set_xlabel('y₁', color='white')
ax1.set_ylabel('y₂', color='white')
ax1.tick_params(colors='white')

# ── Panel 2: 3D energy surface ──────────────────────────────
ax2 = fig.add_subplot(gs[0, 1], projection='3d', facecolor='#0a0a1a')

x3 = np.linspace(-3, 3, 150)
y3 = np.linspace(-3, 3, 150)
X3, Y3 = np.meshgrid(x3, y3)
E3 = energy_density(X3, Y3, N=2)

ax2.plot_surface(X3, Y3, E3, cmap='inferno', alpha=0.8, antialiased=True,
                 rstride=3, cstride=3, edgecolor='none')
ax2.set_xlabel('y₁', color='white', fontsize=10)
ax2.set_ylabel('y₂', color='white', fontsize=10)
ax2.set_zlabel('e(y)', color='white', fontsize=10)
ax2.set_title('Energy Landscape (3D)', color='#ff6600', fontsize=13, fontweight='bold')
ax2.tick_params(colors='white')
ax2.set_facecolor('#0a0a1a')
ax2.xaxis.pane.fill = False
ax2.yaxis.pane.fill = False
ax2.zaxis.pane.fill = False

# ── Panel 3: Energy by dimension ─────────────────────────────
ax3 = fig.add_subplot(gs[0, 2], facecolor='#0a0a1a')

r = np.linspace(0, 5, 500)
for N in [1, 2, 3, 4, 6, 8]:
    eN = 4 * N / (1 + r**2)**2
    ax3.plot(r, eN, linewidth=2, label=f'N={N}')

ax3.set_xlabel('r = |y|', color='white', fontsize=12)
ax3.set_ylabel('e(r)', color='white', fontsize=12)
ax3.set_title('Energy Density vs Dimension', color='#ff6600', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('#333355')

# ── Panel 4: The sphere coloring by energy ───────────────────
ax4 = fig.add_subplot(gs[1, 0], projection='3d', facecolor='#0a0a1a')

u_sphere = np.linspace(0, 2*np.pi, 200)
v_sphere = np.linspace(0, np.pi, 100)
U, V = np.meshgrid(u_sphere, v_sphere)

Xs = np.sin(V) * np.cos(U)
Ys = np.sin(V) * np.sin(U)
Zs = np.cos(V)

# Color by stereographic energy (distance from north pole)
# North pole = (0,0,1), south pole = (0,0,-1)
# Energy ∝ 1/(1-z)² approximately
energy_on_sphere = 1 / (2 - Zs + 0.01)

ax4.plot_surface(Xs, Ys, Zs, facecolors=plt.cm.inferno(energy_on_sphere / energy_on_sphere.max()),
                 alpha=0.9, antialiased=True, rstride=2, cstride=2, edgecolor='none')
ax4.set_title('Energy on S² (hot = high)', color='#ff6600', fontsize=13, fontweight='bold')
ax4.set_facecolor('#0a0a1a')
ax4.xaxis.pane.fill = False
ax4.yaxis.pane.fill = False
ax4.zaxis.pane.fill = False
ax4.tick_params(colors='white')

# ── Panel 5: Harmonic map visualization ──────────────────────
ax5 = fig.add_subplot(gs[1, 1], facecolor='#0a0a1a')

# Show how a grid in ℝ² maps to S² via σ⁻¹
# Draw grid lines in stereographic coords, colored by energy
for val in np.linspace(-3, 3, 25):
    t = np.linspace(-3, 3, 200)
    # Horizontal lines
    sx = inv_stereo_x(t, val * np.ones_like(t))
    sy = inv_stereo_y(t, val * np.ones_like(t))
    energy = energy_density(t, val * np.ones_like(t))
    ax5.scatter(sx, sy, c=energy, cmap='inferno', s=0.3, alpha=0.5, vmin=0, vmax=8)
    
    # Vertical lines
    sx = inv_stereo_x(val * np.ones_like(t), t)
    sy = inv_stereo_y(val * np.ones_like(t), t)
    energy = energy_density(val * np.ones_like(t), t)
    ax5.scatter(sx, sy, c=energy, cmap='inferno', s=0.3, alpha=0.5, vmin=0, vmax=8)

circle = plt.Circle((0, 0), 1, fill=False, color='#00ddff', linewidth=1, linestyle='--')
ax5.add_patch(circle)
ax5.set_xlim(-1.2, 1.2)
ax5.set_ylim(-1.2, 1.2)
ax5.set_aspect('equal')
ax5.set_title('Grid → S² (x,y components)', color='#ff6600', fontsize=13, fontweight='bold')
ax5.set_xlabel('x₁ on S²', color='white')
ax5.set_ylabel('x₂ on S²', color='white')
ax5.tick_params(colors='white')
for spine in ax5.spines.values():
    spine.set_color('#333355')

# ── Panel 6: Total energy vs dimension ───────────────────────
ax6 = fig.add_subplot(gs[1, 2], facecolor='#0a0a1a')

# Total energy E(N) = N · Vol(S^N)
# Vol(S^N) = 2π^((N+1)/2) / Γ((N+1)/2)
from math import gamma, pi
dims = np.arange(1, 25)
vol_sn = [2 * pi**((n+1)/2) / gamma((n+1)/2) for n in dims]
total_energy = [n * v for n, v in zip(dims, vol_sn)]

ax6.bar(dims, total_energy, color=plt.cm.plasma(dims / 25), edgecolor='none', alpha=0.8)
ax6.set_xlabel('Dimension N', color='white', fontsize=12)
ax6.set_ylabel('Total Energy E = N·Vol(S^N)', color='white', fontsize=12)
ax6.set_title('Dirichlet Energy by Dimension', color='#ff6600', fontsize=13, fontweight='bold')
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#333355')

# Mark special dimensions
for d in [1, 2, 4, 8]:
    idx = d - 1
    ax6.annotate(f'N={d}', (dims[idx], total_energy[idx]),
                textcoords="offset points", xytext=(0, 10),
                ha='center', color='#00ddff', fontsize=9, fontweight='bold')

fig.suptitle('THE STEREOGRAPHIC ENERGY LANDSCAPE\n'
             'Inverse stereographic projection as a harmonic map minimizing Dirichlet energy',
             color='white', fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo2_energy_landscape.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 2: Energy Landscape — saved!")
