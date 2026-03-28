#!/usr/bin/env python3
"""
Demo 1: The Nuclear Algebra U(6) — Structure and Symmetry Chains

Visualizes:
- The U(6) algebra structure and its three subalgebra chains
- Casimir operator eigenvalue spectra for each symmetry limit
- The "periodic table" of nuclear symmetries

Author: Oracle Council (Algebraic Nuclear Physics Project)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.gridspec import GridSpec
import warnings
warnings.filterwarnings('ignore')

# ─── Color Palette ───
C_U5 = '#2196F3'    # Blue — vibrational
C_SU3 = '#F44336'   # Red — rotational
C_O6 = '#4CAF50'    # Green — γ-unstable
C_U6 = '#9C27B0'    # Purple — parent algebra
C_O3 = '#FF9800'    # Orange — rotation group
C_BG = '#1a1a2e'    # Dark background
C_TEXT = '#e0e0e0'   # Light text

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


def u5_spectrum(N, epsilon=1.0, alpha=0.02, beta_param=0.01, gamma_param=0.005):
    """U(5) vibrational spectrum: E = ε·n_d + α·n_d(n_d+4) + β·τ(τ+3) + γ·L(L+1)"""
    levels = []
    for n_d in range(N + 1):
        for tau in range(n_d, -1, -2):  # τ = n_d, n_d-2, ..., 0 or 1
            if tau < 0:
                break
            # L values from τ: L = τ, τ+1, ..., 2τ-2, 2τ (Δ=2 missing some)
            # Simplified: L = 2τ, 2τ-2, ..., τ (for τ > 0) and L=0 for τ=0
            L_values = []
            if tau == 0:
                L_values = [0]
            elif tau == 1:
                L_values = [2]
            elif tau == 2:
                L_values = [2, 4]
            elif tau == 3:
                L_values = [0, 3, 4, 6]
            else:
                L_values = list(range(tau, 2*tau + 1, 2))
                if 0 not in L_values and tau % 2 == 0:
                    L_values = [0] + L_values

            for L in L_values:
                E = (epsilon * n_d + alpha * n_d * (n_d + 4)
                     + beta_param * tau * (tau + 3) + gamma_param * L * (L + 1))
                levels.append((n_d, tau, L, E))
    return levels


def su3_spectrum(N, kappa=-0.02, kappa_prime=0.005):
    """SU(3) rotational spectrum: Ground band (2N,0), β band (2N-4,2), γ band (2N-2,1)"""
    levels = []

    # Ground band (λ,μ) = (2N, 0)
    lam, mu = 2*N, 0
    C2_su3 = lam**2 + mu**2 + lam*mu + 3*(lam + mu)
    for L in range(0, 2*N + 1, 2):
        if L > 10:
            break
        E = kappa * C2_su3 + kappa_prime * L * (L + 1)
        levels.append(('g', lam, mu, L, E))

    # β band (λ,μ) = (2N-4, 2)
    lam, mu = max(2*N - 4, 0), 2
    if lam >= 0:
        C2_su3 = lam**2 + mu**2 + lam*mu + 3*(lam + mu)
        for L in [0, 2, 4, 6, 8]:
            if L > 2*lam + mu:
                break
            E = kappa * C2_su3 + kappa_prime * L * (L + 1)
            levels.append(('β', lam, mu, L, E))

    # γ band (λ,μ) = (2N-2, 1)  — odd L allowed
    lam, mu = max(2*N - 2, 0), 1
    if lam >= 0:
        C2_su3 = lam**2 + mu**2 + lam*mu + 3*(lam + mu)
        for L in [2, 3, 4, 5, 6, 7, 8]:
            E = kappa * C2_su3 + kappa_prime * L * (L + 1)
            levels.append(('γ', lam, mu, L, E))

    return levels


def o6_spectrum(N, A_param=0.05, B_param=0.02, C_param=0.005):
    """O(6) γ-unstable spectrum: E = A·σ(σ+4) + B·τ(τ+3) + C·L(L+1)"""
    levels = []
    for sigma in range(N, -1, -2):
        if sigma < 0:
            break
        for tau in range(0, sigma + 1):
            L_values = []
            if tau == 0:
                L_values = [0]
            elif tau == 1:
                L_values = [2]
            elif tau == 2:
                L_values = [2, 4]
            elif tau == 3:
                L_values = [0, 3, 4, 6]
            else:
                L_values = list(range(tau, 2*tau + 1, 2))

            for L in L_values:
                if L > 10:
                    continue
                E = (A_param * sigma * (sigma + 4) +
                     B_param * tau * (tau + 3) + C_param * L * (L + 1))
                levels.append((sigma, tau, L, E))
    return levels


# ═══════════════════════════════════════════════════
#  FIGURE 1: The Algebra Structure Diagram
# ═══════════════════════════════════════════════════

fig1 = plt.figure(figsize=(14, 10))
ax = fig1.add_subplot(111)
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')
ax.set_title('The Nuclear Algebra U(6) — Three Dynamical Symmetry Chains',
             fontsize=18, fontweight='bold', pad=20, color='white')

def draw_box(ax, x, y, w, h, text, color, fontsize=12):
    box = FancyBboxPatch((x - w/2, y - h/2), w, h,
                         boxstyle="round,pad=0.15",
                         facecolor=color, edgecolor='white',
                         linewidth=2, alpha=0.85)
    ax.add_patch(box)
    ax.text(x, y, text, ha='center', va='center', fontsize=fontsize,
            fontweight='bold', color='white')

def draw_arrow(ax, x1, y1, x2, y2, color='white'):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

# Parent: U(6) at top
draw_box(ax, 7, 9, 3, 0.8, 'U(6)\n36 generators', C_U6, 13)

# Three chains
# Chain I: U(5)
draw_box(ax, 2.5, 7, 2.2, 0.7, 'U(5)\n25 gen.', C_U5)
draw_arrow(ax, 5.8, 8.6, 3.5, 7.4, C_U5)

# Chain II: SU(3)
draw_box(ax, 7, 7, 2.2, 0.7, 'SU(3)\n8 gen.', C_SU3)
draw_arrow(ax, 7, 8.6, 7, 7.4, C_SU3)

# Chain III: O(6)
draw_box(ax, 11.5, 7, 2.2, 0.7, 'O(6)\n15 gen.', C_O6)
draw_arrow(ax, 8.2, 8.6, 10.5, 7.4, C_O6)

# O(5) appears in chains I and III
draw_box(ax, 2.5, 5, 2.2, 0.7, 'O(5)\n10 gen.', '#607D8B')
draw_arrow(ax, 2.5, 6.6, 2.5, 5.4)

draw_box(ax, 11.5, 5, 2.2, 0.7, 'O(5)\n10 gen.', '#607D8B')
draw_arrow(ax, 11.5, 6.6, 11.5, 5.4)

# O(3) at bottom — all chains converge
draw_box(ax, 7, 3, 2.2, 0.7, 'O(3)\n3 gen.', C_O3)
draw_arrow(ax, 2.5, 4.6, 5.9, 3.4, C_U5)
draw_arrow(ax, 7, 6.6, 7, 3.7, C_SU3)
draw_arrow(ax, 11.5, 4.6, 8.1, 3.4, C_O6)

# O(2) at very bottom
draw_box(ax, 7, 1.2, 2.2, 0.7, 'O(2)\n1 gen.', '#795548')
draw_arrow(ax, 7, 2.6, 7, 1.6)

# Labels for physical content
ax.text(1.0, 7, 'Vibrational\n(spherical)', fontsize=10, color=C_U5,
        ha='center', va='center', style='italic')
ax.text(5.0, 7, 'Rotational\n(deformed)', fontsize=10, color=C_SU3,
        ha='center', va='center', style='italic')
ax.text(13.2, 7, 'γ-unstable\n(triaxial)', fontsize=10, color=C_O6,
        ha='center', va='center', style='italic')

# Quantum numbers
ax.text(0.3, 9, 'Quantum\nNumbers:', fontsize=10, fontweight='bold', color='white')
ax.text(0.3, 7.8, 'N', fontsize=10, color=C_U6)
ax.text(0.3, 6.3, 'nₐ, τ, L', fontsize=9, color=C_U5)
ax.text(4.8, 6.3, '(λ,μ), L', fontsize=9, color=C_SU3)
ax.text(13.2, 6.3, 'σ, τ, L', fontsize=9, color=C_O6)

# Physical interpretation box
props = dict(boxstyle='round', facecolor='#0d1b2a', edgecolor='white', alpha=0.9)
textstr = ('Physical Interpretation:\n'
           '• U(6) = parent algebra of s and d bosons (nucleon pairs)\n'
           '• Each chain = a complete set of commuting observables\n'
           '• Casimir operators → energy eigenvalues (no diagonalization!)\n'
           '• Real nuclei: superposition of all three limits')
ax.text(7, 0.15, textstr, transform=ax.transData, fontsize=9,
        verticalalignment='bottom', horizontalalignment='center', bbox=props)

fig1.tight_layout()
fig1.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig1_algebra_structure.png',
             dpi=150, bbox_inches='tight')
plt.close(fig1)
print("✅ Figure 1 saved: Algebra structure diagram")


# ═══════════════════════════════════════════════════
#  FIGURE 2: Energy Spectra for Three Symmetry Limits
# ═══════════════════════════════════════════════════

fig2, axes = plt.subplots(1, 3, figsize=(18, 10))

N = 6  # Boson number

# --- U(5) spectrum ---
ax = axes[0]
ax.set_title('Chain I: U(5) — Vibrational', fontsize=14, fontweight='bold', color=C_U5)

levels_u5 = u5_spectrum(N, epsilon=1.0, alpha=0.0, beta_param=0.0, gamma_param=0.02)
levels_u5.sort(key=lambda x: x[3])  # sort by energy

# Group by n_d
for n_d_val in range(min(5, N+1)):
    group = [(nd, tau, L, E) for nd, tau, L, E in levels_u5 if nd == n_d_val and L <= 8]
    if not group:
        continue
    for i, (nd, tau, L, E) in enumerate(group):
        x_pos = n_d_val * 1.5 + 0.5
        width = 0.6
        ax.plot([x_pos - width/2, x_pos + width/2], [E, E],
                color=C_U5, linewidth=2.5, alpha=0.9)
        ax.text(x_pos + width/2 + 0.1, E, f'{L}⁺',
                fontsize=8, color='white', va='center')

ax.set_xlabel('nₐ (d-boson number)', fontsize=12)
ax.set_ylabel('Energy (arb. units)', fontsize=12)
ax.set_xticks([0.5, 2.0, 3.5, 5.0, 6.5])
ax.set_xticklabels(['0', '1', '2', '3', '4'])
ax.text(0.5, -0.15, 'R₄/₂ = 2.00', transform=ax.transAxes,
        fontsize=13, fontweight='bold', color=C_U5, ha='center')

# --- SU(3) spectrum ---
ax = axes[1]
ax.set_title('Chain II: SU(3) — Rotational', fontsize=14, fontweight='bold', color=C_SU3)

levels_su3 = su3_spectrum(N, kappa=-0.02, kappa_prime=0.008)
# Normalize so E(2+) = 1
E_2plus = None
for band, lam, mu, L, E in levels_su3:
    if band == 'g' and L == 2:
        E_2plus = E
        break

band_colors = {'g': C_SU3, 'β': '#FF7043', 'γ': '#AB47BC'}
band_x = {'g': 1.5, 'β': 3.5, 'γ': 5.5}

for band, lam, mu, L, E in levels_su3:
    if L > 10:
        continue
    if E_2plus and E_2plus != 0:
        E_norm = (E - levels_su3[0][4]) / abs(E_2plus - levels_su3[0][4])
    else:
        E_norm = E
    x_pos = band_x[band]
    width = 0.8
    ax.plot([x_pos - width/2, x_pos + width/2], [E_norm, E_norm],
            color=band_colors[band], linewidth=2.5, alpha=0.9)
    ax.text(x_pos + width/2 + 0.1, E_norm, f'{L}⁺',
            fontsize=8, color='white', va='center')

ax.set_xlabel('Band', fontsize=12)
ax.set_ylabel('E / E(2₁⁺)', fontsize=12)
ax.set_xticks([1.5, 3.5, 5.5])
ax.set_xticklabels(['ground', 'β', 'γ'], fontsize=10)
ax.text(0.5, -0.15, 'R₄/₂ = 3.33', transform=ax.transAxes,
        fontsize=13, fontweight='bold', color=C_SU3, ha='center')

# --- O(6) spectrum ---
ax = axes[2]
ax.set_title('Chain III: O(6) — γ-unstable', fontsize=14, fontweight='bold', color=C_O6)

levels_o6 = o6_spectrum(N, A_param=0.0, B_param=0.5, C_param=0.02)
levels_o6.sort(key=lambda x: x[3])

# Group by τ
for tau_val in range(5):
    group = [(s, tau, L, E) for s, tau, L, E in levels_o6 if tau == tau_val and L <= 8]
    if not group:
        continue
    for s, tau, L, E in group:
        x_pos = tau_val * 1.5 + 0.5
        width = 0.6
        ax.plot([x_pos - width/2, x_pos + width/2], [E, E],
                color=C_O6, linewidth=2.5, alpha=0.9)
        ax.text(x_pos + width/2 + 0.1, E, f'{L}⁺',
                fontsize=8, color='white', va='center')

ax.set_xlabel('τ (seniority)', fontsize=12)
ax.set_ylabel('Energy (arb. units)', fontsize=12)
ax.set_xticks([0.5, 2.0, 3.5, 5.0, 6.5])
ax.set_xticklabels(['0', '1', '2', '3', '4'])
ax.text(0.5, -0.15, 'R₄/₂ = 2.50', transform=ax.transAxes,
        fontsize=13, fontweight='bold', color=C_O6, ha='center')

fig2.suptitle('Energy Spectra of the Three Dynamical Symmetry Limits (N = 6 bosons)',
              fontsize=16, fontweight='bold', y=0.98, color='white')
fig2.tight_layout(rect=[0, 0.02, 1, 0.95])
fig2.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig2_energy_spectra.png',
             dpi=150, bbox_inches='tight')
plt.close(fig2)
print("✅ Figure 2 saved: Energy spectra for three symmetry limits")


# ═══════════════════════════════════════════════════
#  FIGURE 3: Nuclear Periodic Table (Algebraic)
# ═══════════════════════════════════════════════════

fig3, ax = plt.subplots(figsize=(12, 10))
ax.set_title('The Algebraic Periodic Table of Nuclear Structure',
             fontsize=16, fontweight='bold', color='white', pad=20)

# Nuclear data: (Z, N, R42, name)
nuclei = [
    # Near U(5) — vibrational
    (48, 62, 2.24, '¹¹⁰Cd'), (48, 64, 2.29, '¹¹²Cd'), (48, 66, 2.38, '¹¹⁴Cd'),
    (52, 70, 2.03, '¹²²Te'), (52, 72, 2.09, '¹²⁴Te'), (52, 74, 2.14, '¹²⁶Te'),
    (50, 66, 2.09, '¹¹⁶Sn'), (50, 68, 2.11, '¹¹⁸Sn'), (50, 70, 2.14, '¹²⁰Sn'),
    # Near O(6) — γ-unstable
    (78, 116, 2.48, '¹⁹⁴Pt'), (78, 118, 2.46, '¹⁹⁶Pt'), (78, 120, 2.41, '¹⁹⁸Pt'),
    (76, 114, 2.49, '¹⁹⁰Os'), (76, 116, 2.50, '¹⁹²Os'),
    (54, 78, 2.40, '¹³²Xe'), (54, 80, 2.43, '¹³⁴Xe'),
    # Near SU(3) — rotational
    (64, 92, 3.24, '¹⁵⁶Gd'), (64, 94, 3.27, '¹⁵⁸Gd'), (64, 96, 3.29, '¹⁶⁰Gd'),
    (66, 96, 3.28, '¹⁶²Dy'), (66, 98, 3.30, '¹⁶⁴Dy'), (66, 100, 3.31, '¹⁶⁶Dy'),
    (68, 98, 3.29, '¹⁶⁶Er'), (68, 100, 3.31, '¹⁶⁸Er'), (68, 102, 3.31, '¹⁷⁰Er'),
    (70, 104, 3.30, '¹⁷⁴Yb'), (72, 106, 3.31, '¹⁷⁸Hf'),
    # Transitional — near X(5) critical point
    (60, 90, 2.93, '¹⁵⁰Nd'), (62, 90, 3.01, '¹⁵²Sm'), (62, 88, 2.30, '¹⁵⁰Sm'),
    (56, 78, 2.32, '¹³⁴Ba'), (58, 82, 2.31, '¹⁴⁰Ce'),
]

# Create scatter plot colored by R42
Z_vals = [n[0] for n in nuclei]
N_vals = [n[1] for n in nuclei]
R42_vals = [n[2] for n in nuclei]
names = [n[3] for n in nuclei]

sc = ax.scatter(N_vals, Z_vals, c=R42_vals, cmap='RdYlBu_r', s=200,
                edgecolors='white', linewidth=1.5, vmin=1.8, vmax=3.5, zorder=5)

for i, name in enumerate(names):
    ax.annotate(name, (N_vals[i], Z_vals[i]), textcoords="offset points",
                xytext=(8, 5), fontsize=6, color='white', alpha=0.8)

# Magic number lines
for magic in [50, 82, 126]:
    ax.axvline(x=magic, color='yellow', linewidth=1, alpha=0.3, linestyle='--')
    ax.text(magic, ax.get_ylim()[0] + 0.5, f'N={magic}', fontsize=8,
            color='yellow', alpha=0.5, ha='center')
for magic in [50, 82]:
    ax.axhline(y=magic, color='yellow', linewidth=1, alpha=0.3, linestyle='--')
    ax.text(ax.get_xlim()[0] + 0.5, magic, f'Z={magic}', fontsize=8,
            color='yellow', alpha=0.5, va='center')

cbar = plt.colorbar(sc, ax=ax, shrink=0.8, pad=0.02)
cbar.set_label('R₄/₂ = E(4⁺)/E(2⁺)', fontsize=12, color=C_TEXT)
cbar.ax.yaxis.set_tick_params(color=C_TEXT)
plt.setp(plt.getp(cbar.ax.axes, 'yticklabels'), color=C_TEXT)

# Add symmetry labels on colorbar
cbar.ax.text(1.5, 2.0, 'U(5)', fontsize=10, color=C_U5, fontweight='bold',
             transform=cbar.ax.transData)
cbar.ax.text(1.5, 2.5, 'O(6)', fontsize=10, color=C_O6, fontweight='bold',
             transform=cbar.ax.transData)
cbar.ax.text(1.5, 3.33, 'SU(3)', fontsize=10, color=C_SU3, fontweight='bold',
             transform=cbar.ax.transData)

ax.set_xlabel('Neutron Number N', fontsize=13)
ax.set_ylabel('Proton Number Z', fontsize=13)

fig3.tight_layout()
fig3.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig3_nuclear_periodic_table.png',
             dpi=150, bbox_inches='tight')
plt.close(fig3)
print("✅ Figure 3 saved: Nuclear periodic table")


# ═══════════════════════════════════════════════════
#  FIGURE 4: Casimir Operator Eigenvalue Diagrams
# ═══════════════════════════════════════════════════

fig4, axes = plt.subplots(2, 2, figsize=(14, 12))

# --- Panel (a): C₂[U(5)] eigenvalues ---
ax = axes[0, 0]
ax.set_title('C₂[U(5)] = nₐ(nₐ + 4)', fontsize=13, fontweight='bold', color=C_U5)
n_d_vals = np.arange(0, 11)
C2_u5 = n_d_vals * (n_d_vals + 4)
ax.bar(n_d_vals, C2_u5, color=C_U5, alpha=0.8, edgecolor='white', linewidth=1)
for i, v in enumerate(C2_u5):
    ax.text(i, v + 1, str(int(v)), ha='center', fontsize=9, color='white')
ax.set_xlabel('nₐ', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)

# --- Panel (b): C₂[SU(3)] eigenvalues ---
ax = axes[0, 1]
ax.set_title('C₂[SU(3)] = λ² + μ² + λμ + 3(λ+μ)', fontsize=13, fontweight='bold', color=C_SU3)
# Plot for different (λ, μ) representations
reps = [(2*n, 0) for n in range(1, 8)]
labels = [f'({l},{m})' for l, m in reps]
C2_su3 = [l**2 + m**2 + l*m + 3*(l + m) for l, m in reps]
x_pos = np.arange(len(reps))
ax.bar(x_pos, C2_su3, color=C_SU3, alpha=0.8, edgecolor='white', linewidth=1)
for i, v in enumerate(C2_su3):
    ax.text(i, v + 2, str(int(v)), ha='center', fontsize=9, color='white')
ax.set_xticks(x_pos)
ax.set_xticklabels(labels, fontsize=9, rotation=30)
ax.set_xlabel('(λ, μ) representation', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)

# --- Panel (c): C₂[O(6)] eigenvalues ---
ax = axes[1, 0]
ax.set_title('C₂[O(6)] = σ(σ + 4)', fontsize=13, fontweight='bold', color=C_O6)
sigma_vals = np.arange(0, 11)
C2_o6 = sigma_vals * (sigma_vals + 4)
ax.bar(sigma_vals, C2_o6, color=C_O6, alpha=0.8, edgecolor='white', linewidth=1)
for i, v in enumerate(C2_o6):
    ax.text(i, v + 1, str(int(v)), ha='center', fontsize=9, color='white')
ax.set_xlabel('σ', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)

# --- Panel (d): C₂[O(3)] = L(L+1) ---
ax = axes[1, 1]
ax.set_title('C₂[O(3)] = L(L + 1)', fontsize=13, fontweight='bold', color=C_O3)
L_vals = np.arange(0, 11)
C2_o3 = L_vals * (L_vals + 1)
ax.bar(L_vals, C2_o3, color=C_O3, alpha=0.8, edgecolor='white', linewidth=1)
for i, v in enumerate(C2_o3):
    ax.text(i, v + 1, str(int(v)), ha='center', fontsize=9, color='white')
ax.set_xlabel('L (angular momentum)', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)

fig4.suptitle('Casimir Operator Eigenvalues — The Building Blocks of Nuclear Spectra',
              fontsize=16, fontweight='bold', y=1.02, color='white')
fig4.tight_layout()
fig4.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig4_casimir_eigenvalues.png',
             dpi=150, bbox_inches='tight')
plt.close(fig4)
print("✅ Figure 4 saved: Casimir operator eigenvalues")

print("\n🎯 Demo 1 complete! All four figures generated.")
print("   fig1: Algebra structure diagram")
print("   fig2: Energy spectra for three symmetry limits")
print("   fig3: Nuclear periodic table")
print("   fig4: Casimir operator eigenvalues")
