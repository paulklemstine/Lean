#!/usr/bin/env python3
"""
Demo 3: IBM Phase Transitions and the Casten Triangle

Visualizes:
- The Casten triangle — parameter space of nuclear shapes
- Quantum phase transition from U(5) to SU(3)
- Energy surfaces E(β, γ) for each symmetry limit
- R₄/₂ systematics across the nuclear chart

Author: Oracle Council (Algebraic Nuclear Physics Project)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import Normalize
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.tri as mtri
import warnings
warnings.filterwarnings('ignore')

C_BG = '#1a1a2e'
C_TEXT = '#e0e0e0'
C_U5 = '#2196F3'
C_SU3 = '#F44336'
C_O6 = '#4CAF50'

plt.rcParams.update({
    'figure.facecolor': C_BG,
    'axes.facecolor': '#16213e',
    'text.color': C_TEXT,
    'axes.labelcolor': C_TEXT,
    'xtick.color': C_TEXT,
    'ytick.color': C_TEXT,
    'font.family': 'sans-serif',
    'font.size': 11,
})


def energy_surface(beta, gamma, eta, chi, N=10):
    """
    IBM coherent state energy surface E(β, γ; η, χ).
    
    H = (1-η)·n_d - (η/4N)·Q(χ)·Q(χ)
    
    E(β,γ) / N = [(1-η)·β² / (1+β²)] 
                 - [η/(4N)] · [4β² - 4√(2/7)·χ·β³·cos(3γ) + (2/7)χ²β⁴] / (1+β²)²
                 + const
    """
    b2 = beta**2
    denom = (1 + b2)
    denom2 = denom**2

    # n_d expectation value
    nd = N * b2 / denom

    # Q·Q expectation value (approximate)
    QQ = N * (N - 1) * (4*b2 - 4*np.sqrt(2/7)*chi*beta**3*np.cos(3*gamma)
                        + (2/7)*chi**2*beta**4) / denom2

    E = (1 - eta) * nd - (eta / (4*N)) * QQ
    return E


# ═══════════════════════════════════════════════════
#  FIGURE 8: The Casten Triangle
# ═══════════════════════════════════════════════════

fig8 = plt.figure(figsize=(12, 10))
ax = fig8.add_subplot(111)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The Casten Triangle — Parameter Space of Nuclear Shapes',
             fontsize=16, fontweight='bold', color='white', pad=20)

# Triangle vertices (in 2D coordinates)
# U(5) at top, SU(3) at bottom-left, O(6) at bottom-right
tri_U5 = np.array([0.5, np.sqrt(3)/2])
tri_SU3 = np.array([0.0, 0.0])
tri_O6 = np.array([1.0, 0.0])

# Draw triangle
triangle = plt.Polygon([tri_U5, tri_SU3, tri_O6], fill=False,
                        edgecolor='white', linewidth=3)
ax.add_patch(triangle)

# Fill with gradient
n_pts = 50
points_x = []
points_y = []
colors = []

for i in range(n_pts):
    for j in range(n_pts - i):
        k = n_pts - 1 - i - j
        # Barycentric coordinates
        a, b, c = i/(n_pts-1), j/(n_pts-1), k/(n_pts-1)
        x = a * tri_U5[0] + b * tri_SU3[0] + c * tri_O6[0]
        y = a * tri_U5[1] + b * tri_SU3[1] + c * tri_O6[1]

        # R₄/₂ interpolation
        R42 = a * 2.0 + b * 3.33 + c * 2.5
        points_x.append(x)
        points_y.append(y)
        colors.append(R42)

sc = ax.scatter(points_x, points_y, c=colors, cmap='RdYlBu_r',
                vmin=1.8, vmax=3.5, s=30, alpha=0.6, edgecolors='none')

# Vertex labels
offset = 0.08
ax.plot(*tri_U5, 'o', color=C_U5, markersize=20, zorder=10)
ax.text(tri_U5[0], tri_U5[1] + offset, 'U(5)\nVibrational\nR₄/₂ = 2.00',
        ha='center', va='bottom', fontsize=12, fontweight='bold', color=C_U5)

ax.plot(*tri_SU3, 'o', color=C_SU3, markersize=20, zorder=10)
ax.text(tri_SU3[0] - offset, tri_SU3[1] - offset, 'SU(3)\nRotational\nR₄/₂ = 3.33',
        ha='center', va='top', fontsize=12, fontweight='bold', color=C_SU3)

ax.plot(*tri_O6, 'o', color=C_O6, markersize=20, zorder=10)
ax.text(tri_O6[0] + offset, tri_O6[1] - offset, 'O(6)\nγ-unstable\nR₄/₂ = 2.50',
        ha='center', va='top', fontsize=12, fontweight='bold', color=C_O6)

# Phase transition lines
# U(5) → SU(3): first-order (thick red dashed)
mid1 = 0.5 * (tri_U5 + tri_SU3)
ax.plot([tri_U5[0], tri_SU3[0]], [tri_U5[1], tri_SU3[1]],
        '--', color='#FF5252', linewidth=2, alpha=0.7)
ax.text(mid1[0] - 0.12, mid1[1], '1st order\nQPT', fontsize=9,
        color='#FF5252', ha='center', rotation=60)

# U(5) → O(6): second-order (thick green dashed)
mid2 = 0.5 * (tri_U5 + tri_O6)
ax.plot([tri_U5[0], tri_O6[0]], [tri_U5[1], tri_O6[1]],
        '--', color='#66BB6A', linewidth=2, alpha=0.7)
ax.text(mid2[0] + 0.12, mid2[1], '2nd order\nQPT', fontsize=9,
        color='#66BB6A', ha='center', rotation=-60)

# SU(3) → O(6): crossover
mid3 = 0.5 * (tri_SU3 + tri_O6)
ax.plot([tri_SU3[0], tri_O6[0]], [tri_SU3[1], tri_O6[1]],
        ':', color='#BDBDBD', linewidth=2, alpha=0.7)
ax.text(mid3[0], mid3[1] - 0.08, 'Crossover', fontsize=9,
        color='#BDBDBD', ha='center')

# Critical point symmetries
# X(5) on U(5)-SU(3) edge
x5_pos = 0.6 * tri_U5 + 0.4 * tri_SU3
ax.plot(*x5_pos, '*', color='#FFD700', markersize=18, zorder=10)
ax.text(x5_pos[0] - 0.1, x5_pos[1] - 0.03, 'X(5)', fontsize=11,
        fontweight='bold', color='#FFD700')

# E(5) on U(5)-O(6) edge
e5_pos = 0.6 * tri_U5 + 0.4 * tri_O6
ax.plot(*e5_pos, '*', color='#FFD700', markersize=18, zorder=10)
ax.text(e5_pos[0] + 0.07, e5_pos[1] - 0.03, 'E(5)', fontsize=11,
        fontweight='bold', color='#FFD700')

# Place some nuclei
nuclei_in_triangle = [
    (0.75, 0.15, '¹⁵⁶Gd', C_SU3),
    (0.38, 0.6, '¹¹⁰Cd', C_U5),
    (0.78, 0.08, '¹⁹⁶Pt', C_O6),
    (0.35, 0.35, '¹⁵²Sm', '#FFD700'),
    (0.42, 0.52, '¹³⁴Ba', '#FFD700'),
]
for x, y, name, color in nuclei_in_triangle:
    # Convert from barycentric-ish to actual position
    ax.plot(x, y, 'D', color=color, markersize=8, zorder=8)
    ax.text(x + 0.03, y + 0.02, name, fontsize=9, color=color)

cbar = plt.colorbar(sc, ax=ax, shrink=0.6, pad=0.02)
cbar.set_label('R₄/₂', fontsize=12, color=C_TEXT)
cbar.ax.yaxis.set_tick_params(color=C_TEXT)
plt.setp(plt.getp(cbar.ax.axes, 'yticklabels'), color=C_TEXT)

ax.set_xlim(-0.3, 1.3)
ax.set_ylim(-0.25, 1.15)

fig8.tight_layout()
fig8.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig8_casten_triangle.png',
             dpi=150, bbox_inches='tight')
plt.close(fig8)
print("✅ Figure 8 saved: Casten triangle")


# ═══════════════════════════════════════════════════
#  FIGURE 9: Energy Surfaces E(β, γ) for Each Limit
# ═══════════════════════════════════════════════════

fig9, axes = plt.subplots(1, 3, figsize=(18, 6), subplot_kw={'projection': '3d'})

beta_range = np.linspace(0, 2.0, 80)
gamma_range = np.linspace(0, np.pi/3, 60)
B, G = np.meshgrid(beta_range, gamma_range)

configs = [
    ('U(5) — Spherical Minimum', 0.0, -np.sqrt(2/7) * 3.5, C_U5),
    ('SU(3) — Deformed Minimum', 1.0, -np.sqrt(2/7) * 3.5, C_SU3),
    ('O(6) — γ-flat Valley', 1.0, 0.0, C_O6),
]

for ax, (title, eta, chi, color) in zip(axes, configs):
    E = energy_surface(B, G, eta, chi, N=10)
    E = E - E.min()  # normalize

    surf = ax.plot_surface(B * np.cos(G), B * np.sin(G), E,
                          cmap='magma', alpha=0.85, edgecolor='none')
    ax.set_title(title, fontsize=12, fontweight='bold', color=color, pad=10)
    ax.set_xlabel('β cos γ', fontsize=9, labelpad=-5)
    ax.set_ylabel('β sin γ', fontsize=9, labelpad=-5)
    ax.set_zlabel('E', fontsize=9, labelpad=-5)
    ax.tick_params(labelsize=7)
    ax.set_facecolor('#0a0a1a')
    ax.xaxis.pane.fill = False
    ax.yaxis.pane.fill = False
    ax.zaxis.pane.fill = False
    ax.view_init(elev=35, azim=-60)

fig9.suptitle('Coherent State Energy Surfaces — The Three Nuclear Phases',
              fontsize=16, fontweight='bold', y=1.02, color='white')
fig9.tight_layout()
fig9.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig9_energy_surfaces.png',
             dpi=150, bbox_inches='tight')
plt.close(fig9)
print("✅ Figure 9 saved: Energy surfaces E(β, γ)")


# ═══════════════════════════════════════════════════
#  FIGURE 10: Quantum Phase Transition — Sm isotopes
# ═══════════════════════════════════════════════════

fig10, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: R₄/₂ vs neutron number for Sm isotopes
ax = axes[0]
ax.set_title('Quantum Phase Transition in Samarium Isotopes',
             fontsize=14, fontweight='bold', color='white')

# Sm data
Sm_N = [82, 84, 86, 88, 90, 92, 94]
Sm_R42 = [1.54, 2.04, 2.30, 2.93, 3.01, 3.25, 3.29]
Sm_labels = ['¹⁴⁴Sm', '¹⁴⁶Sm', '¹⁴⁸Sm', '¹⁵⁰Sm', '¹⁵²Sm', '¹⁵⁴Sm', '¹⁵⁶Sm']

ax.plot(Sm_N, Sm_R42, 'o-', color='#FF7043', markersize=12, linewidth=2.5,
        markeredgecolor='white', markeredgewidth=1.5, label='Sm (Z=62)')

for N, R, name in zip(Sm_N, Sm_R42, Sm_labels):
    ax.annotate(name, (N, R), textcoords="offset points",
                xytext=(10, 8), fontsize=9, color='white')

# Reference lines
ax.axhline(y=2.0, color=C_U5, alpha=0.5, linestyle='--', label='U(5) = 2.00')
ax.axhline(y=2.5, color=C_O6, alpha=0.5, linestyle='--', label='O(6) = 2.50')
ax.axhline(y=10/3, color=C_SU3, alpha=0.5, linestyle='--', label='SU(3) = 3.33')
ax.axhline(y=2.91, color='#FFD700', alpha=0.5, linestyle=':', label='X(5) = 2.91')

# Critical region
ax.axvspan(88.5, 90.5, alpha=0.15, color='#FFD700')
ax.text(89.5, 1.6, 'Critical\nRegion', ha='center', fontsize=10,
        color='#FFD700', fontweight='bold')

ax.set_xlabel('Neutron Number N', fontsize=13)
ax.set_ylabel('R₄/₂ = E(4⁺)/E(2⁺)', fontsize=13)
ax.legend(fontsize=9, loc='lower right')
ax.set_ylim(1.3, 3.6)

# Right: Order parameter β₀ vs η
ax = axes[1]
ax.set_title('Order Parameter — Ground State Deformation',
             fontsize=14, fontweight='bold', color='white')

eta_vals = np.linspace(0, 1, 200)
N = 10
chi = -np.sqrt(2/7) * 3.5  # SU(3)-like

beta_0 = np.zeros_like(eta_vals)
for i, eta in enumerate(eta_vals):
    # Find minimum of E(β) at γ=0
    betas = np.linspace(0, 3, 500)
    E_vals = energy_surface(betas, 0.0, eta, chi, N)
    beta_0[i] = betas[np.argmin(E_vals)]

ax.plot(eta_vals, beta_0, color='#FF7043', linewidth=3)
ax.axvline(x=0.8, color='#FFD700', alpha=0.5, linestyle='--', linewidth=2)
ax.text(0.82, 0.5, 'η_c ≈ 0.8\n(Critical point)', fontsize=10,
        color='#FFD700', va='center')

# Label phases
ax.text(0.3, 0.1, 'Spherical\nPhase\n(U(5))', fontsize=12, color=C_U5,
        ha='center', fontweight='bold')
ax.text(0.9, 1.0, 'Deformed\nPhase\n(SU(3))', fontsize=12, color=C_SU3,
        ha='center', fontweight='bold')

ax.set_xlabel('Control Parameter η', fontsize=13)
ax.set_ylabel('β₀ (ground state deformation)', fontsize=13)
ax.set_xlim(0, 1)

fig10.suptitle('Nuclear Quantum Phase Transitions — From Spheres to Ellipsoids',
               fontsize=16, fontweight='bold', y=1.02, color='white')
fig10.tight_layout()
fig10.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig10_phase_transition.png',
              dpi=150, bbox_inches='tight')
plt.close(fig10)
print("✅ Figure 10 saved: Quantum phase transition")


# ═══════════════════════════════════════════════════
#  FIGURE 11: R₄/₂ Systematics Across Nuclear Chart
# ═══════════════════════════════════════════════════

fig11, ax = plt.subplots(figsize=(14, 6))
ax.set_title('R₄/₂ Systematics — Even-Even Nuclei',
             fontsize=15, fontweight='bold', color='white')

# Simulated R₄/₂ data for even-even nuclei
# This is a simplified model based on known systematics
np.random.seed(42)

Z_vals_all = []
R42_all = []

for Z in range(20, 100, 2):
    for N in range(Z, int(Z * 1.6), 2):
        A = Z + N
        if A < 40 or A > 260:
            continue

        # Model R₄/₂ based on proximity to shell closures
        magic_Z = [20, 28, 50, 82]
        magic_N = [20, 28, 50, 82, 126]

        # Distance to nearest magic number
        dZ = min(abs(Z - m) for m in magic_Z)
        dN = min(abs(N - m) for m in magic_N)
        d_magic = min(dZ, dN)

        # Near shell closure: vibrational (R ≈ 2)
        # Far from closure: rotational (R ≈ 3.3)
        if d_magic <= 2:
            R42 = 1.5 + np.random.normal(0, 0.15)
        elif d_magic <= 6:
            R42 = 2.0 + 0.1 * d_magic + np.random.normal(0, 0.1)
        else:
            R42 = min(3.33, 2.5 + 0.08 * d_magic + np.random.normal(0, 0.08))

        R42 = max(1.0, min(3.5, R42))
        Z_vals_all.append(Z)
        R42_all.append(R42)

sc = ax.scatter(Z_vals_all, R42_all, c=R42_all, cmap='RdYlBu_r',
                s=15, alpha=0.7, vmin=1.5, vmax=3.5, edgecolors='none')

# Reference lines
ax.axhline(y=2.0, color=C_U5, alpha=0.6, linestyle='--', linewidth=1.5,
           label='U(5) = 2.00')
ax.axhline(y=2.5, color=C_O6, alpha=0.6, linestyle='--', linewidth=1.5,
           label='O(6) = 2.50')
ax.axhline(y=10/3, color=C_SU3, alpha=0.6, linestyle='--', linewidth=1.5,
           label='SU(3) = 3.33')

# Magic number regions
for m in [20, 28, 50, 82]:
    ax.axvline(x=m, color='yellow', alpha=0.2, linewidth=1)
    ax.text(m, 3.6, f'Z={m}', fontsize=8, color='yellow', alpha=0.6,
            ha='center')

ax.set_xlabel('Proton Number Z', fontsize=13)
ax.set_ylabel('R₄/₂', fontsize=13)
ax.legend(fontsize=10, loc='upper left')
ax.set_ylim(1.0, 3.8)

cbar = plt.colorbar(sc, ax=ax, shrink=0.8, pad=0.02)
cbar.set_label('R₄/₂', fontsize=11, color=C_TEXT)
cbar.ax.yaxis.set_tick_params(color=C_TEXT)
plt.setp(plt.getp(cbar.ax.axes, 'yticklabels'), color=C_TEXT)

fig11.tight_layout()
fig11.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig11_R42_systematics.png',
              dpi=150, bbox_inches='tight')
plt.close(fig11)
print("✅ Figure 11 saved: R₄/₂ systematics")


print("\n🎯 Demo 3 complete! Four figures generated.")
print("   fig8:  Casten triangle")
print("   fig9:  Energy surfaces E(β, γ)")
print("   fig10: Quantum phase transition")
print("   fig11: R₄/₂ systematics")
