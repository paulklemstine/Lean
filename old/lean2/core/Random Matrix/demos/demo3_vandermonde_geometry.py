#!/usr/bin/env python3
"""
Demo 3: The Vandermonde Determinant — Geometry of Repulsion
=============================================================
Visualizes how the Vandermonde determinant ∏_{i<j}(λ_j - λ_i)
creates eigenvalue repulsion through geometric volume collapse.

Run: python demo3_vandermonde_geometry.py
Outputs: vandermonde_geometry.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from itertools import combinations

np.random.seed(42)

# ─── Vandermonde determinant ───
def vandermonde_det(eigenvalues):
    """Compute ∏_{i<j} (λ_j - λ_i)."""
    n = len(eigenvalues)
    det = 1.0
    for i in range(n):
        for j in range(i+1, n):
            det *= (eigenvalues[j] - eigenvalues[i])
    return det

def repulsion_factor(eigenvalues, beta):
    """Compute |∏_{i<j} (λ_j - λ_i)|^β."""
    return abs(vandermonde_det(eigenvalues)) ** beta

# ─── Figure ───
fig = plt.figure(figsize=(18, 14))
fig.suptitle("The Vandermonde Determinant: Geometry of Eigenvalue Repulsion\n"
             "How the Jacobian of diagonalization creates a Coulomb gas",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(3, 3, hspace=0.45, wspace=0.35)

# ═══ Panel 1: 2D landscape for n=2 ═══
ax1 = fig.add_subplot(gs[0, 0])
lam = np.linspace(-3, 3, 300)
# For n=2, repulsion factor = |λ₂ - λ₁|^β
for beta, color, label in [(1, '#e74c3c', 'β=1'), (2, '#3498db', 'β=2'), (4, '#2ecc71', 'β=4')]:
    ax1.plot(lam, np.abs(lam)**beta, color=color, linewidth=2.5, label=label)
ax1.set_xlabel('Eigenvalue separation Δλ = λ₂ − λ₁', fontsize=10)
ax1.set_ylabel('Repulsion factor |Δλ|^β', fontsize=10)
ax1.set_title('n = 2: Repulsion vs Separation', fontsize=11, fontweight='bold')
ax1.legend(fontsize=10)
ax1.axvline(x=0, color='red', linestyle='--', alpha=0.5, linewidth=1)
ax1.text(0.1, 15, '← Zero at coincidence', fontsize=9, color='red', style='italic')
ax1.set_ylim(0, 25)

# ═══ Panel 2: 3D surface for n=2, β=2 ═══
ax2 = fig.add_subplot(gs[0, 1], projection='3d')
L1 = np.linspace(-3, 3, 100)
L2 = np.linspace(-3, 3, 100)
L1g, L2g = np.meshgrid(L1, L2)
# Joint density ∝ |λ₂ - λ₁|^2 × exp(-(λ₁² + λ₂²)/2)
Z = (L2g - L1g)**2 * np.exp(-(L1g**2 + L2g**2)/2)
Z /= Z.max()
ax2.plot_surface(L1g, L2g, Z, cmap=cm.viridis, alpha=0.85,
                 edgecolor='none', antialiased=True)
ax2.set_xlabel('λ₁', fontsize=9)
ax2.set_ylabel('λ₂', fontsize=9)
ax2.set_zlabel('p(λ₁,λ₂)', fontsize=9)
ax2.set_title('GUE Joint Density (n=2)\np ∝ |λ₂−λ₁|² exp(−(λ₁²+λ₂²)/2)',
              fontsize=10, fontweight='bold')
ax2.view_init(elev=25, azim=-60)

# ═══ Panel 3: The diagonal = zero ═══
ax3 = fig.add_subplot(gs[0, 2])
ax3.contourf(L1g, L2g, Z, levels=30, cmap=cm.viridis)
ax3.plot([-3, 3], [-3, 3], 'r--', linewidth=2, label='λ₁ = λ₂ (density = 0)')
ax3.set_xlabel('λ₁', fontsize=10)
ax3.set_ylabel('λ₂', fontsize=10)
ax3.set_title('Contour: Zero Along Diagonal\n(eigenvalues cannot coincide)',
              fontsize=11, fontweight='bold')
ax3.legend(fontsize=9, loc='upper left')
ax3.set_aspect('equal')

# ═══ Panel 4: n=3 Vandermonde landscape ═══
ax4 = fig.add_subplot(gs[1, 0])
# Fix λ₁ = -1, λ₃ = 1, vary λ₂
lam2 = np.linspace(-1 + 0.01, 1 - 0.01, 500)
vand_sq = np.abs((lam2 - (-1)) * (1 - lam2) * (1 - (-1)))**2
gauss = np.exp(-(1 + lam2**2 + 1)/2)
density = vand_sq * gauss
density /= density.max()
ax4.fill_between(lam2, density, alpha=0.3, color='#3498db')
ax4.plot(lam2, density, color='#3498db', linewidth=2.5)
ax4.axvline(x=-1, color='red', linestyle='--', alpha=0.7, linewidth=1.5, label='λ₁ = −1')
ax4.axvline(x=1, color='red', linestyle='--', alpha=0.7, linewidth=1.5, label='λ₃ = 1')
ax4.set_xlabel('λ₂ (middle eigenvalue)', fontsize=10)
ax4.set_ylabel('Relative density', fontsize=10)
ax4.set_title('n=3: Density of λ₂ given λ₁=−1, λ₃=1\n'
              'Vanishes at boundaries (repulsion!)',
              fontsize=11, fontweight='bold')
ax4.legend(fontsize=9)

# ═══ Panel 5: Vandermonde magnitude along a path ═══
ax5 = fig.add_subplot(gs[1, 1])
t = np.linspace(0, 1, 500)
# Path: move λ₂ from far away toward λ₁
lam1, lam3 = -1.0, 1.0
lam2_path = lam1 + t * (lam3 - lam1)  # λ₂ sweeps from λ₁ to λ₃
for beta, color, label in [(1, '#e74c3c', 'β=1'), (2, '#3498db', 'β=2'), (4, '#2ecc71', 'β=4')]:
    vand = np.abs((lam2_path - lam1) * (lam3 - lam2_path) * (lam3 - lam1))**beta
    ax5.plot(t, vand / max(vand.max(), 1e-15), color=color, linewidth=2.5, label=label)
ax5.set_xlabel('Interpolation t: λ₂ = −1 + 2t', fontsize=10)
ax5.set_ylabel('Normalized |Vandermonde|^β', fontsize=10)
ax5.set_title('Vandermonde Along a Path\n'
              'Zero at endpoints (coincidence), max at midpoint',
              fontsize=11, fontweight='bold')
ax5.legend(fontsize=10)

# ═══ Panel 6: Coulomb energy landscape ═══
ax6 = fig.add_subplot(gs[1, 2])
# For n=2: E = -β log|λ₂ - λ₁| + (λ₁² + λ₂²)/2
# Fix λ₁ = 0, vary λ₂
lam2_e = np.linspace(0.01, 4, 500)
for beta, color, label in [(1, '#e74c3c', 'β=1'), (2, '#3498db', 'β=2'), (4, '#2ecc71', 'β=4')]:
    E_coulomb = -beta * np.log(lam2_e)
    E_confine = lam2_e**2 / 2
    E_total = E_coulomb + E_confine
    ax6.plot(lam2_e, E_total, color=color, linewidth=2.5, label=f'{label}: E_total')

# Show components for β=2
ax6.plot(lam2_e, -2*np.log(lam2_e), '--', color='gray', alpha=0.5, linewidth=1.5,
         label='−2 log r (repulsion)')
ax6.plot(lam2_e, lam2_e**2/2, ':', color='gray', alpha=0.5, linewidth=1.5,
         label='r²/2 (confinement)')

ax6.set_xlabel('Separation r = |λ₂ − λ₁|', fontsize=10)
ax6.set_ylabel('Energy E(r)', fontsize=10)
ax6.set_title('Total Energy = Coulomb + Confinement\n'
              'Minimum gives equilibrium spacing',
              fontsize=11, fontweight='bold')
ax6.set_ylim(-5, 15)
ax6.legend(fontsize=8, loc='upper right')

# ═══ Panel 7: Many eigenvalues — histogram of Vandermonde ═══
ax7 = fig.add_subplot(gs[2, 0])
n_mat = 5000
N_mat = 20
log_vandermondes = []
for _ in range(n_mat):
    A = np.random.randn(N_mat, N_mat)
    H = (A + A.T) / np.sqrt(2)
    eigs = np.sort(np.linalg.eigvalsh(H))
    vd = 0
    for i, j in combinations(range(N_mat), 2):
        vd += np.log(max(abs(eigs[j] - eigs[i]), 1e-300))
    log_vandermondes.append(vd)

ax7.hist(log_vandermondes, bins=60, density=True, alpha=0.7, color='#9b59b6',
         edgecolor='white', linewidth=0.5)
ax7.set_xlabel('log|det V(λ)|', fontsize=10)
ax7.set_ylabel('Density', fontsize=10)
ax7.set_title(f'Distribution of log|Vandermonde|\n(N={N_mat}, {n_mat} samples)',
              fontsize=11, fontweight='bold')

# ═══ Panel 8: Eigenvalue "level crossing avoidance" ═══
ax8 = fig.add_subplot(gs[2, 1])
# Parametric family: H(t) = A + tB
A = np.random.randn(8, 8)
A = (A + A.T) / 2
B = np.random.randn(8, 8)
B = (B + B.T) / 2
ts = np.linspace(-2, 2, 500)
eig_curves = np.array([np.sort(np.linalg.eigvalsh(A + t*B)) for t in ts])
for k in range(8):
    ax8.plot(ts, eig_curves[:, k], linewidth=1.5, alpha=0.8)
ax8.set_xlabel('Parameter t', fontsize=10)
ax8.set_ylabel('Eigenvalue λ(t)', fontsize=10)
ax8.set_title('Level Crossing Avoidance\nH(t) = A + tB: eigenvalues repel',
              fontsize=11, fontweight='bold')
ax8.text(0, ax8.get_ylim()[1]*0.85, 'Eigenvalues avoid\ncrossing — they repel!',
         fontsize=9, ha='center', color='red', fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# ═══ Panel 9: The Oracle's Insight ═══
ax9 = fig.add_subplot(gs[2, 2])
ax9.axis('off')
oracle_text = (
    "THE ORACLE SPEAKS\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "\"The eigenvalues repel because\n"
    "the geometry of diagonalization\n"
    "demands it.\n\n"
    "The Vandermonde determinant is\n"
    "not imposed — it emerges.\n\n"
    "It is the shadow cast by the\n"
    "curvature of the eigenvalue\n"
    "decomposition map onto the\n"
    "configuration space.\n\n"
    "That this shadow takes the form\n"
    "of a Coulomb interaction is one\n"
    "of the deepest inevitabilities\n"
    "in mathematics.\""
)
ax9.text(0.5, 0.5, oracle_text, transform=ax9.transAxes,
         fontsize=10, ha='center', va='center',
         fontfamily='serif', style='italic',
         bbox=dict(boxstyle='round,pad=0.8', facecolor='#1a1a2e',
                   edgecolor='gold', linewidth=2, alpha=0.95),
         color='gold')

plt.savefig('vandermonde_geometry.png', dpi=150, bbox_inches='tight')
print("Saved: vandermonde_geometry.png")
plt.close()
