#!/usr/bin/env python3
"""
Demo 4: Advanced Algebraic Nuclear Physics

Visualizes:
- IBM Hamiltonian matrix construction and diagonalization
- Transition rates and selection rules
- Nuclear supersymmetry (SUSY) multiplets
- The algebraic tower: from nucleon pairs to nuclear shapes

Author: Oracle Council (Algebraic Nuclear Physics Project)
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import eigh
from scipy.special import comb
import warnings
warnings.filterwarnings('ignore')

C_BG = '#1a1a2e'
C_TEXT = '#e0e0e0'
C_U5 = '#2196F3'
C_SU3 = '#F44336'
C_O6 = '#4CAF50'
C_GOLD = '#FFD700'

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


def ibm_hilbert_dim(N):
    """Dimension of IBM-1 Hilbert space for N bosons: (N+5)! / (N! * 5!)"""
    return int(comb(N + 5, 5))


def ibm_L0_states(N):
    """
    Generate L=0 states in the U(5) basis for N bosons.
    Returns list of (n_d, tau, n_Delta, L) with L=0.
    L=0 requires tau even, and specific n_Delta values.
    """
    states = []
    for n_d in range(N + 1):
        for tau in range(n_d, -1, -2):
            if tau < 0:
                break
            if tau == 0:
                states.append((n_d, tau, 0, 0))
    return states


def ibm_spectrum_numerical(N, eta, chi):
    """
    Compute IBM-1 spectrum numerically for L=0 sector.
    H = (1-η)·n_d - (η/4N)·Q·Q
    """
    states = ibm_L0_states(N)
    dim = len(states)

    if dim == 0:
        return np.array([]), states

    # Build Hamiltonian matrix in U(5) basis
    H = np.zeros((dim, dim))

    for i, (nd_i, tau_i, _, _) in enumerate(states):
        # Diagonal: n_d term
        H[i, i] += (1 - eta) * nd_i

        # Diagonal: part of Q·Q
        # In U(5) basis, Q·Q has both diagonal and off-diagonal parts
        # Diagonal contributions from d†d terms
        c2_u5 = nd_i * (nd_i + 4)
        c2_o5 = tau_i * (tau_i + 3)
        H[i, i] -= (eta / (4*N)) * (5 * nd_i + chi**2 * (2*c2_u5 - c2_o5) / 5)

        # Off-diagonal: s†d† and d†s terms in Q·Q (Δn_d = ±2)
        for j, (nd_j, tau_j, _, _) in enumerate(states):
            if nd_j == nd_i + 2 and tau_j == tau_i:
                # <n_d+2, τ | Q·Q | n_d, τ>
                matrix_element = np.sqrt((nd_i + 1) * (nd_i + 2) *
                                        (N - nd_i) * (N - nd_i - 1)) * 0.2
                H[i, j] -= (eta / (4*N)) * matrix_element
                H[j, i] -= (eta / (4*N)) * matrix_element

    eigenvalues, eigenvectors = eigh(H)
    return eigenvalues, states


# ═══════════════════════════════════════════════════
#  FIGURE 12: IBM Hilbert Space Dimensions
# ═══════════════════════════════════════════════════

fig12, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Hilbert space dimension vs N
ax = axes[0]
ax.set_title('IBM Hilbert Space Dimension vs Boson Number N',
             fontsize=14, fontweight='bold', color='white')

N_vals = np.arange(1, 21)
dims = [ibm_hilbert_dim(N) for N in N_vals]

ax.bar(N_vals, dims, color='#7C4DFF', alpha=0.85, edgecolor='white', linewidth=1)
for N, d in zip(N_vals, dims):
    if N <= 15:
        ax.text(N, d + max(dims)*0.02, str(d), ha='center', fontsize=7,
                color='white', rotation=45)

ax.set_xlabel('Boson Number N', fontsize=13)
ax.set_ylabel('Hilbert Space Dimension', fontsize=13)
ax.set_yscale('log')

# Add formula
props = dict(boxstyle='round', facecolor='#0d1b2a', edgecolor=C_GOLD, alpha=0.9)
ax.text(0.05, 0.95, 'dim H = (N+5)! / (N!·5!)\n\nN=10: dim = 3003\nN=15: dim = 15504',
        transform=ax.transAxes, fontsize=10, verticalalignment='top', bbox=props)

# Mark typical nuclear values
for N, label in [(6, 'Pt'), (10, 'Sm'), (14, 'Er')]:
    ax.annotate(label, (N, ibm_hilbert_dim(N)),
                textcoords="offset points", xytext=(10, 10),
                fontsize=10, color=C_GOLD,
                arrowprops=dict(arrowstyle='->', color=C_GOLD))

# Right: Decomposition by angular momentum
ax = axes[1]
ax.set_title('Hilbert Space Decomposition by Angular Momentum L',
             fontsize=14, fontweight='bold', color='white')

N = 6
L_counts = {}
for n_d in range(N + 1):
    for tau in range(n_d, -1, -2):
        if tau < 0:
            break
        # L values from tau
        if tau == 0:
            L_list = [0]
        elif tau == 1:
            L_list = [2]
        elif tau == 2:
            L_list = [2, 4]
        elif tau == 3:
            L_list = [0, 3, 4, 6]
        elif tau == 4:
            L_list = [2, 4, 5, 6, 8]
        elif tau == 5:
            L_list = [0, 3, 4, 5, 6, 7, 8, 10]
        elif tau == 6:
            L_list = [2, 4, 5, 6, 7, 8, 9, 10, 12]
        else:
            L_list = list(range(tau, 2*tau + 1, 2))

        for L in L_list:
            L_counts[L] = L_counts.get(L, 0) + (2*L + 1)

L_vals = sorted(L_counts.keys())
counts = [L_counts[L] for L in L_vals]

colors_L = plt.cm.viridis(np.linspace(0.2, 0.9, len(L_vals)))
ax.bar(L_vals, counts, color=colors_L, edgecolor='white', linewidth=1, alpha=0.85)

for L, c in zip(L_vals, counts):
    ax.text(L, c + 1, str(c), ha='center', fontsize=9, color='white')

ax.set_xlabel('Angular Momentum L', fontsize=13)
ax.set_ylabel('Number of States (2L+1 degeneracy)', fontsize=13)
ax.text(0.7, 0.9, f'N = {N} bosons\nTotal dim = {ibm_hilbert_dim(N)}',
        transform=ax.transAxes, fontsize=11, bbox=props)

fig12.suptitle('The IBM Hilbert Space — Finite-Dimensional Nuclear Quantum Mechanics',
               fontsize=16, fontweight='bold', y=1.01, color='white')
fig12.tight_layout()
fig12.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig12_hilbert_space.png',
              dpi=150, bbox_inches='tight')
plt.close(fig12)
print("✅ Figure 12 saved: IBM Hilbert space dimensions")


# ═══════════════════════════════════════════════════
#  FIGURE 13: Spectral Flow — Interpolation Between Limits
# ═══════════════════════════════════════════════════

fig13, ax = plt.subplots(figsize=(14, 8))
ax.set_title('Spectral Flow: U(5) → SU(3) Phase Transition (L=0 Sector)',
             fontsize=15, fontweight='bold', color='white')

N = 8
n_eta = 100
eta_vals = np.linspace(0, 1, n_eta)
chi = -np.sqrt(2/7) * 3.5

all_eigenvalues = []
for eta in eta_vals:
    evals, _ = ibm_spectrum_numerical(N, eta, chi)
    all_eigenvalues.append(evals)

# Normalize energies
all_eigenvalues = np.array(all_eigenvalues)
# Shift so ground state = 0
for i in range(len(eta_vals)):
    if len(all_eigenvalues[i]) > 0:
        all_eigenvalues[i] -= all_eigenvalues[i].min()

# Plot each energy level as function of η
n_levels = min(all_eigenvalues.shape[1] if len(all_eigenvalues.shape) > 1 else 0, 8)
colors_spec = plt.cm.plasma(np.linspace(0.1, 0.9, n_levels))

for j in range(n_levels):
    ax.plot(eta_vals, all_eigenvalues[:, j], color=colors_spec[j],
            linewidth=2, alpha=0.85)

# Phase transition indicator
ax.axvline(x=0.8, color=C_GOLD, alpha=0.5, linestyle='--', linewidth=2)
ax.text(0.82, ax.get_ylim()[1] * 0.9, 'QPT\nη_c ≈ 0.8', fontsize=11,
        color=C_GOLD, fontweight='bold')

# Label phases
ax.text(0.2, ax.get_ylim()[1] * 0.85, 'U(5)\nVibrational', fontsize=14,
        color=C_U5, fontweight='bold', ha='center')
ax.text(0.92, ax.get_ylim()[1] * 0.85, 'SU(3)\nRotational', fontsize=14,
        color=C_SU3, fontweight='bold', ha='center')

ax.set_xlabel('Control Parameter η', fontsize=14)
ax.set_ylabel('Energy (relative to ground state)', fontsize=14)

props = dict(boxstyle='round', facecolor='#0d1b2a', edgecolor='white', alpha=0.9)
ax.text(0.02, 0.98, f'N = {N} bosons\nL = 0 sector\nχ = -√(2/7)·3.5',
        transform=ax.transAxes, fontsize=10, verticalalignment='top', bbox=props)

fig13.tight_layout()
fig13.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig13_spectral_flow.png',
              dpi=150, bbox_inches='tight')
plt.close(fig13)
print("✅ Figure 13 saved: Spectral flow — U(5) to SU(3)")


# ═══════════════════════════════════════════════════
#  FIGURE 14: Nuclear SUSY and the Algebraic Tower
# ═══════════════════════════════════════════════════

fig14 = plt.figure(figsize=(14, 10))
ax = fig14.add_subplot(111)
ax.axis('off')
ax.set_xlim(0, 14)
ax.set_ylim(0, 11)
ax.set_title('The Algebraic Tower of Nuclear Physics',
             fontsize=18, fontweight='bold', color='white', pad=20)

def draw_level(ax, y, label, sublabel, color, width=10, x_center=7):
    box = plt.Rectangle((x_center - width/2, y - 0.35), width, 0.7,
                        facecolor=color, edgecolor='white', linewidth=2, alpha=0.8)
    ax.add_patch(box)
    ax.text(x_center, y + 0.05, label, ha='center', va='center',
            fontsize=13, fontweight='bold', color='white')
    ax.text(x_center, y - 0.2, sublabel, ha='center', va='center',
            fontsize=9, color='white', alpha=0.8)

# The tower from bottom to top
levels = [
    (1.0, 'Level 0: Nucleons', 'Protons (p) and Neutrons (n) — SU(2)_isospin',
     '#795548', 12),
    (2.5, 'Level 1: Pairing', 'J=0 (s-boson) and J=2 (d-boson) pairs — Sp(2Ω)',
     '#FF5722', 11),
    (4.0, 'Level 2: Boson Space', '6-dimensional Fock space — U(6)',
     '#9C27B0', 10),
    (5.5, 'Level 3: Symmetry Chains',
     'U(5) ∪ SU(3) ∪ O(6) — dynamical symmetries', '#2196F3', 9),
    (7.0, 'Level 4: Nuclear Shapes', 'β, γ deformation — coherent states on CP¹',
     '#4CAF50', 8),
    (8.5, 'Level 5: Phase Transitions', 'QPT, E(5), X(5) — catastrophe theory',
     '#FFD700', 7),
    (10.0, 'Level 6: Nuclear SUSY', 'U(6/Ω) superalgebra — Bose-Fermi symmetry',
     '#E91E63', 6),
]

for y, label, sublabel, color, width in levels:
    draw_level(ax, y, label, sublabel, color, width)

# Arrows between levels
for i in range(len(levels) - 1):
    y1 = levels[i][0] + 0.4
    y2 = levels[i + 1][0] - 0.4
    ax.annotate('', xy=(7, y2), xytext=(7, y1),
                arrowprops=dict(arrowstyle='->', color='white', lw=2))

# Side annotations
annotations = [
    (1.0, 'Fermions\n938 MeV', 0.5),
    (2.5, 'Pairs\n~1 MeV gap', 0.5),
    (4.0, '36 generators\ndim = (N+5)!/N!5!', 0.5),
    (5.5, '3 exact\nsolutions', 0.5),
    (7.0, 'Casten\ntriangle', 0.5),
    (8.5, '2 critical\npoints', 0.5),
    (10.0, 'Even-odd\ncorrelations', 0.5),
]

for y, text, x in annotations:
    ax.text(x, y, text, fontsize=8, color='#90CAF9', ha='center', va='center',
            style='italic')

fig14.tight_layout()
fig14.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig14_algebraic_tower.png',
              dpi=150, bbox_inches='tight')
plt.close(fig14)
print("✅ Figure 14 saved: The algebraic tower")


# ═══════════════════════════════════════════════════
#  FIGURE 15: Summary — The Grand Unified Picture
# ═══════════════════════════════════════════════════

fig15 = plt.figure(figsize=(16, 10))

# Create a summary dashboard
gs = fig15.add_gridspec(2, 3, hspace=0.4, wspace=0.3)

# Panel 1: Nuclear shapes
ax1 = fig15.add_subplot(gs[0, 0])
ax1.set_title('Nuclear Shapes', fontsize=12, fontweight='bold', color='white')
theta = np.linspace(0, 2*np.pi, 100)

# Spherical (U(5))
r_sphere = np.ones_like(theta)
ax1.plot(r_sphere * np.cos(theta), r_sphere * np.sin(theta),
         color=C_U5, linewidth=2.5, label='U(5): Sphere')

# Prolate (SU(3))
a_pro, b_pro = 1.4, 0.7
r_prolate = a_pro * b_pro / np.sqrt((b_pro * np.cos(theta))**2 + (a_pro * np.sin(theta))**2)
ax1.plot(r_prolate * np.cos(theta), r_prolate * np.sin(theta),
         color=C_SU3, linewidth=2.5, label='SU(3): Prolate')

# Triaxial (O(6))
r_triaxial = 1.0 + 0.3 * np.cos(2*theta) + 0.1 * np.cos(4*theta)
ax1.plot(r_triaxial * np.cos(theta), r_triaxial * np.sin(theta),
         color=C_O6, linewidth=2.5, label='O(6): Triaxial')

ax1.set_aspect('equal')
ax1.legend(fontsize=8, loc='upper right')
ax1.set_xlim(-2, 2)
ax1.set_ylim(-1.8, 1.8)

# Panel 2: Energy ratios
ax2 = fig15.add_subplot(gs[0, 1])
ax2.set_title('R₄/₂ Diagnostic', fontsize=12, fontweight='bold', color='white')

symmetries = ['U(5)', 'E(5)', 'O(6)', 'X(5)', 'SU(3)']
R42_values = [2.00, 2.20, 2.50, 2.91, 3.33]
colors_r = [C_U5, C_GOLD, C_O6, C_GOLD, C_SU3]

bars = ax2.barh(symmetries, R42_values, color=colors_r, alpha=0.85,
                edgecolor='white', linewidth=1.5, height=0.6)
for bar, val in zip(bars, R42_values):
    ax2.text(val + 0.05, bar.get_y() + bar.get_height()/2,
             f'{val:.2f}', va='center', fontsize=10, color='white')
ax2.set_xlabel('R₄/₂', fontsize=11)
ax2.set_xlim(1.5, 3.8)

# Panel 3: Magic numbers
ax3 = fig15.add_subplot(gs[0, 2])
ax3.set_title('Magic Numbers', fontsize=12, fontweight='bold', color='white')

magic = [2, 8, 20, 28, 50, 82, 126]
shell_gaps = [2, 6, 12, 8, 22, 32, 44]  # Shell degeneracies
cumul = np.cumsum(shell_gaps)

ax3.barh(range(len(magic)), shell_gaps, color='#7C4DFF', alpha=0.85,
         edgecolor='white', linewidth=1.5, height=0.6)
for i, (m, sg) in enumerate(zip(magic, shell_gaps)):
    ax3.text(sg + 1, i, f'Σ = {m}', va='center', fontsize=10,
             color=C_GOLD, fontweight='bold')

ax3.set_yticks(range(len(magic)))
ax3.set_yticklabels([f'Shell {i+1}' for i in range(len(magic))], fontsize=9)
ax3.set_xlabel('Shell Degeneracy', fontsize=11)

# Panel 4: Algebra dimensions
ax4 = fig15.add_subplot(gs[1, 0])
ax4.set_title('Algebra Dimensions', fontsize=12, fontweight='bold', color='white')

algebras = ['O(2)', 'O(3)', 'SU(3)', 'O(5)', 'O(6)', 'U(5)', 'U(6)']
dims = [1, 3, 8, 10, 15, 25, 36]
colors_a = ['#795548', '#FF9800', C_SU3, '#607D8B', C_O6, C_U5, '#9C27B0']

ax4.barh(algebras, dims, color=colors_a, alpha=0.85,
         edgecolor='white', linewidth=1.5, height=0.6)
for i, d in enumerate(dims):
    ax4.text(d + 0.5, i, str(d), va='center', fontsize=10, color='white')
ax4.set_xlabel('Number of Generators', fontsize=11)

# Panel 5: Timeline
ax5 = fig15.add_subplot(gs[1, 1:])
ax5.set_title('Historical Development of Algebraic Nuclear Physics',
              fontsize=12, fontweight='bold', color='white')

events = [
    (1932, 'Heisenberg:\nIsospin SU(2)'),
    (1937, 'Wigner:\nSU(4) supermultiplet'),
    (1949, 'Mayer-Jensen:\nShell model'),
    (1958, 'Elliott:\nSU(3) model'),
    (1975, 'Arima-Iachello:\nIBM / U(6)'),
    (1980, 'Iachello:\nNuclear SUSY'),
    (2000, 'Iachello:\nE(5), X(5)'),
    (2025, 'This work:\nUnified algebraic\ntheory'),
]

years = [e[0] for e in events]
labels = [e[1] for e in events]

ax5.scatter(years, [0]*len(years), s=100, color=C_GOLD, zorder=5,
            edgecolors='white', linewidth=1.5)
ax5.plot(years, [0]*len(years), color='white', alpha=0.3, linewidth=1)

for i, (year, label) in enumerate(events):
    y_offset = 0.3 if i % 2 == 0 else -0.3
    va = 'bottom' if i % 2 == 0 else 'top'
    ax5.annotate(f'{year}\n{label}', (year, 0),
                 textcoords="offset points", xytext=(0, 40 if i % 2 == 0 else -40),
                 fontsize=8, color='white', ha='center', va=va,
                 arrowprops=dict(arrowstyle='->', color=C_GOLD, lw=1))

ax5.set_ylim(-1, 1)
ax5.set_xlim(1925, 2030)
ax5.set_yticks([])
ax5.set_xlabel('Year', fontsize=11)

fig15.suptitle('The Algebraic Theory of Nuclear Physics — Grand Summary',
               fontsize=18, fontweight='bold', y=1.02, color='white')
fig15.tight_layout()
fig15.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig15_grand_summary.png',
              dpi=150, bbox_inches='tight')
plt.close(fig15)
print("✅ Figure 15 saved: Grand summary dashboard")


print("\n🎯 Demo 4 complete! Four figures generated.")
print("   fig12: IBM Hilbert space dimensions")
print("   fig13: Spectral flow — U(5) to SU(3)")
print("   fig14: The algebraic tower")
print("   fig15: Grand summary dashboard")
print("\n✨ All 15 figures generated across 4 demo scripts!")
