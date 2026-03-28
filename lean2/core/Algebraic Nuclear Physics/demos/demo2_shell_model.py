#!/usr/bin/env python3
"""
Demo 2: The Nuclear Shell Model — Magic Numbers from Algebra

Visualizes:
- Harmonic oscillator energy levels and their degeneracies
- Spin-orbit splitting and the origin of magic numbers
- Shell filling and the nuclear periodic table
- Comparison of harmonic oscillator vs spin-orbit magic numbers

Author: Oracle Council (Algebraic Nuclear Physics Project)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import warnings
warnings.filterwarnings('ignore')

C_BG = '#1a1a2e'
C_TEXT = '#e0e0e0'

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

# ─── Shell Model Data ───

# Harmonic oscillator levels: (n, ℓ, label, degeneracy 2(2ℓ+1))
ho_levels = [
    # n=0
    (0, 0, '1s₁/₂', 2),
    # n=1
    (1, 1, '1p₃/₂', 4),
    (1, 1, '1p₁/₂', 2),
    # n=2
    (2, 2, '1d₅/₂', 6),
    (2, 0, '2s₁/₂', 2),
    (2, 2, '1d₃/₂', 4),
    # n=3
    (3, 3, '1f₇/₂', 8),
    (3, 1, '2p₃/₂', 4),
    (3, 3, '1f₅/₂', 6),
    (3, 1, '2p₁/₂', 2),
    # n=4
    (4, 4, '1g₉/₂', 10),
    (4, 2, '2d₅/₂', 6),
    (4, 4, '1g₇/₂', 8),
    (4, 0, '3s₁/₂', 2),
    (4, 2, '2d₃/₂', 4),
    # n=5
    (5, 5, '1h₁₁/₂', 12),
    (5, 3, '2f₇/₂', 8),
    (5, 5, '1h₉/₂', 10),
    (5, 1, '3p₃/₂', 4),
    (5, 3, '2f₅/₂', 6),
    (5, 1, '3p₁/₂', 2),
    # n=6
    (6, 6, '1i₁₃/₂', 14),
]

# Energy levels WITH spin-orbit splitting
# (energy, label, degeneracy, cumulative_particles, is_magic_closure)
so_levels = [
    (0.0,  '1s₁/₂',  2,   2,  True),   # Magic 2
    (1.0,  '1p₃/₂',  4,   6,  False),
    (1.3,  '1p₁/₂',  2,   8,  True),   # Magic 8
    (2.0,  '1d₅/₂',  6,  14,  False),
    (2.2,  '2s₁/₂',  2,  16,  False),
    (2.5,  '1d₃/₂',  4,  20,  True),   # Magic 20
    (2.8,  '1f₇/₂',  8,  28,  True),   # Magic 28 ← spin-orbit!
    (3.5,  '2p₃/₂',  4,  32,  False),
    (3.7,  '1f₅/₂',  6,  38,  False),
    (3.9,  '2p₁/₂',  2,  40,  False),
    (4.0,  '1g₉/₂', 10,  50,  True),   # Magic 50
    (4.8,  '2d₅/₂',  6,  56,  False),
    (5.0,  '1g₇/₂',  8,  64,  False),
    (5.1,  '3s₁/₂',  2,  66,  False),
    (5.2,  '2d₃/₂',  4,  70,  False),
    (5.3,  '1h₁₁/₂',12,  82,  True),   # Magic 82
    (6.0,  '2f₇/₂',  8,  90,  False),
    (6.2,  '1h₉/₂', 10, 100,  False),
    (6.3,  '3p₃/₂',  4, 104,  False),
    (6.5,  '2f₅/₂',  6, 110,  False),
    (6.6,  '3p₁/₂',  2, 112,  False),
    (6.7,  '1i₁₃/₂',14, 126,  True),   # Magic 126
]

magic_numbers = [2, 8, 20, 28, 50, 82, 126]


# ═══════════════════════════════════════════════════
#  FIGURE 5: Shell Model Energy Levels
# ═══════════════════════════════════════════════════

fig5, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 12))

# Left: Harmonic oscillator (no spin-orbit)
ax = ax1
ax.set_title('Without Spin-Orbit\n(Harmonic Oscillator)', fontsize=14,
             fontweight='bold', color='#64B5F6')
ax.set_xlim(-1, 8)
ax.set_ylim(-0.5, 7.5)
ax.set_ylabel('Energy (ℏω)', fontsize=13)
ax.set_xticks([])

# HO cumulative: 2, 8, 20, 40, 70, 112, 168
ho_magic = [2, 8, 20, 40, 70, 112, 168]
actual_magic = [2, 8, 20, 28, 50, 82, 126]

for n_shell in range(7):
    E = n_shell
    # Subshells for this n
    subshells = []
    for ell in range(n_shell, -1, -2):
        deg = 2 * (2 * ell + 1)
        spectroscopic = 'spdfghi'[ell]
        n_radial = (n_shell - ell) // 2 + 1
        label = f'{n_radial}{spectroscopic}'
        subshells.append((label, deg))

    x_start = 1
    for i, (label, deg) in enumerate(subshells):
        x = x_start + i * 2.5
        ax.plot([x - 0.8, x + 0.8], [E, E], color='#64B5F6', linewidth=3)
        ax.text(x, E + 0.15, label, ha='center', fontsize=9, color='white')
        ax.text(x, E - 0.2, f'({deg})', ha='center', fontsize=8, color='#90CAF9')

    # Cumulative count
    cumul = ho_magic[n_shell]
    is_real_magic = cumul in actual_magic
    color = '#FFD700' if is_real_magic else '#555555'
    marker = '★' if is_real_magic else ''
    ax.text(7, E, f'Σ = {cumul} {marker}', fontsize=11,
            fontweight='bold' if is_real_magic else 'normal',
            color=color, va='center')

    # Shell gap line
    if n_shell < 6:
        ax.axhline(y=E + 0.5, color='white', alpha=0.1, linestyle='-')

ax.text(0.5, -0.08, 'Magic: 2, 8, 20 ✓ | 40, 70 ✗',
        transform=ax.transAxes, fontsize=11, color='#FF6B6B',
        ha='center', fontweight='bold')


# Right: With spin-orbit splitting
ax = ax2
ax.set_title('With Spin-Orbit Coupling\n(Mayer-Jensen)', fontsize=14,
             fontweight='bold', color='#FF7043')
ax.set_xlim(-1, 10)
ax.set_ylim(-0.5, 7.5)
ax.set_ylabel('Energy (shifted)', fontsize=13)
ax.set_xticks([])

magic_positions = {}  # Track y-positions of magic closures

for i, (E, label, deg, cumul, is_magic) in enumerate(so_levels):
    x = 3
    width = 0.6 + deg * 0.15  # Width proportional to degeneracy

    color = '#FF7043' if not is_magic else '#FFD700'
    lw = 2 if not is_magic else 3.5

    ax.plot([x - width, x + width], [E, E], color=color, linewidth=lw)
    ax.text(x + width + 0.3, E, f'{label}', fontsize=8, color='white', va='center')
    ax.text(x - width - 0.3, E, f'({deg})', fontsize=8, color='#FFAB91',
            va='center', ha='right')

    if is_magic:
        ax.text(8, E, f'Σ = {cumul} ★', fontsize=12, fontweight='bold',
                color='#FFD700', va='center')
        # Draw magic gap
        ax.axhline(y=E + 0.15, color='#FFD700', alpha=0.4, linestyle='--',
                   xmin=0.15, xmax=0.85)
        magic_positions[cumul] = E

# Highlight spin-orbit intruder levels
intruder_info = [
    (2.8, '1f₇/₂ ← intruder from n=3'),
    (4.0, '1g₉/₂ ← intruder from n=4'),
    (5.3, '1h₁₁/₂ ← intruder from n=5'),
    (6.7, '1i₁₃/₂ ← intruder from n=6'),
]
for E, note in intruder_info:
    ax.annotate(note, xy=(5.5, E), fontsize=7, color='#FF5252',
                style='italic', va='center')

ax.text(0.5, -0.08, 'Magic: 2, 8, 20, 28, 50, 82, 126 ✓',
        transform=ax.transAxes, fontsize=11, color='#4CAF50',
        ha='center', fontweight='bold')

fig5.suptitle('Nuclear Shell Model: Origin of Magic Numbers',
              fontsize=18, fontweight='bold', y=0.98, color='white')
fig5.tight_layout(rect=[0, 0.02, 1, 0.95])
fig5.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig5_shell_model.png',
             dpi=150, bbox_inches='tight')
plt.close(fig5)
print("✅ Figure 5 saved: Shell model energy levels")


# ═══════════════════════════════════════════════════
#  FIGURE 6: Magic Numbers — Algebraic Origin
# ═══════════════════════════════════════════════════

fig6, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left: Shell degeneracies
ax = axes[0]
ax.set_title('Shell Degeneracies and Cumulative Filling', fontsize=14,
             fontweight='bold', color='white')

# Each major shell and its degeneracy
shells = [
    ('1s₁/₂', 2, 2),
    ('1p', 6, 8),
    ('1d + 2s', 12, 20),
    ('1f₇/₂', 8, 28),
    ('2p + 1f₅/₂\n+ 1g₉/₂', 22, 50),
    ('2d + 3s\n+ 1g₇/₂\n+ 1h₁₁/₂', 32, 82),
    ('2f + 3p\n+ 1h₉/₂\n+ 1i₁₃/₂', 44, 126),
]

shell_names = [s[0] for s in shells]
shell_degs = [s[1] for s in shells]
cumul = [s[2] for s in shells]

x = np.arange(len(shells))
bars = ax.bar(x, shell_degs, color=['#2196F3', '#4CAF50', '#FF9800',
              '#F44336', '#9C27B0', '#00BCD4', '#FF5722'],
              alpha=0.85, edgecolor='white', linewidth=1.5)

for i, (bar, c) in enumerate(zip(bars, cumul)):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.8,
            f'Σ={c}', ha='center', fontsize=11, fontweight='bold', color='#FFD700')

ax.set_xticks(x)
ax.set_xticklabels(shell_names, fontsize=8)
ax.set_ylabel('Shell Degeneracy (2j+1)', fontsize=12)
ax.set_xlabel('Shell Orbitals', fontsize=12)

# Right: Cumulative filling curve
ax = axes[1]
ax.set_title('Cumulative Nucleon Count → Magic Numbers', fontsize=14,
             fontweight='bold', color='white')

# Plot cumulative as step function
E_levels = [s[0] for s in so_levels]
cumuls = [s[3] for s in so_levels]

ax.step(range(len(cumuls)), cumuls, where='post', color='#64B5F6',
        linewidth=2.5, alpha=0.9)
ax.scatter(range(len(cumuls)), cumuls, color='#64B5F6', s=30, zorder=5)

# Highlight magic numbers
for magic in magic_numbers:
    idx = cumuls.index(magic) if magic in cumuls else -1
    if idx >= 0:
        ax.axhline(y=magic, color='#FFD700', alpha=0.4, linestyle='--')
        ax.scatter([idx], [magic], color='#FFD700', s=150, zorder=10,
                   marker='*', edgecolors='white', linewidth=1)
        ax.text(idx + 0.5, magic, f'  {magic}', fontsize=12,
                fontweight='bold', color='#FFD700', va='center')

ax.set_xlabel('Orbital index (ordered by energy)', fontsize=12)
ax.set_ylabel('Cumulative nucleon count', fontsize=12)
ax.set_ylim(-5, 140)

# Add annotation
props = dict(boxstyle='round', facecolor='#0d1b2a', edgecolor='#FFD700', alpha=0.9)
ax.text(0.05, 0.95, 'Magic Numbers:\n2, 8, 20, 28, 50, 82, 126\n\n'
        'These are the particle counts\nwhere large energy gaps occur\n'
        'due to spin-orbit splitting.',
        transform=ax.transAxes, fontsize=10, verticalalignment='top', bbox=props)

fig6.suptitle('The Algebraic Origin of Nuclear Magic Numbers',
              fontsize=16, fontweight='bold', y=1.02, color='white')
fig6.tight_layout()
fig6.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig6_magic_numbers.png',
             dpi=150, bbox_inches='tight')
plt.close(fig6)
print("✅ Figure 6 saved: Magic numbers — algebraic origin")


# ═══════════════════════════════════════════════════
#  FIGURE 7: Binding Energy and the Mass Formula
# ═══════════════════════════════════════════════════

fig7, axes = plt.subplots(2, 2, figsize=(16, 12))

# Bethe-Weizsäcker parameters (MeV)
a_V = 15.75   # Volume
a_S = 17.80   # Surface
a_C = 0.711   # Coulomb
a_A = 23.70   # Asymmetry (isospin)
a_P = 11.18   # Pairing

def binding_energy(A, Z):
    """Semi-empirical mass formula"""
    N = A - Z
    # Pairing term
    if A % 2 == 1:
        delta = 0
    elif Z % 2 == 0:
        delta = a_P / A**0.5
    else:
        delta = -a_P / A**0.5

    B = (a_V * A - a_S * A**(2/3) - a_C * Z * (Z-1) / A**(1/3)
         - a_A * (A - 2*Z)**2 / A + delta)
    return B

def binding_per_nucleon(A, Z):
    return binding_energy(A, Z) / A

# Panel (a): B/A vs A for stability line
ax = axes[0, 0]
ax.set_title('Binding Energy per Nucleon', fontsize=13, fontweight='bold')

A_vals = np.arange(4, 250)
Z_stable = np.round(A_vals / (2 + 0.0155 * A_vals**(2/3)))  # Approximate stability line
BA = [binding_per_nucleon(A, int(Z)) for A, Z in zip(A_vals, Z_stable)]

ax.plot(A_vals, BA, color='#FF7043', linewidth=2.5, label='Algebraic formula')
ax.axhline(y=8.79, color='#FFD700', alpha=0.5, linestyle='--', label='⁵⁶Fe peak')

# Mark key nuclei
special = [(4, 2, '⁴He'), (12, 6, '¹²C'), (16, 8, '¹⁶O'),
           (56, 26, '⁵⁶Fe'), (208, 82, '²⁰⁸Pb'), (238, 92, '²³⁸U')]
for A, Z, name in special:
    BA_val = binding_per_nucleon(A, Z)
    ax.scatter([A], [BA_val], color='#FFD700', s=80, zorder=5, edgecolors='white')
    ax.annotate(name, (A, BA_val), textcoords="offset points",
                xytext=(10, 5), fontsize=9, color='white')

ax.set_xlabel('Mass Number A', fontsize=12)
ax.set_ylabel('B/A (MeV)', fontsize=12)
ax.legend(fontsize=9, loc='lower right')

# Panel (b): Decomposition of binding energy terms
ax = axes[0, 1]
ax.set_title('Algebraic Decomposition of B(A,Z)', fontsize=13, fontweight='bold')

A_vals_d = np.arange(10, 250)
Z_d = np.round(A_vals_d / (2 + 0.0155 * A_vals_d**(2/3)))

volume = a_V * A_vals_d / A_vals_d
surface = -a_S * A_vals_d**(2/3) / A_vals_d
coulomb = np.array([-a_C * Z * (Z-1) / (A**(1/3) * A) for A, Z in zip(A_vals_d, Z_d)])
asymmetry = np.array([-a_A * (A - 2*Z)**2 / (A * A) for A, Z in zip(A_vals_d, Z_d)])

ax.fill_between(A_vals_d, 0, volume, alpha=0.3, color='#4CAF50', label='Volume (C₁[U(A)])')
ax.fill_between(A_vals_d, surface, 0, alpha=0.3, color='#2196F3', label='Surface (A^{2/3})')
ax.fill_between(A_vals_d, coulomb, 0, alpha=0.3, color='#F44336', label='Coulomb (C₂[SU(2)] breaking)')
ax.fill_between(A_vals_d, asymmetry, 0, alpha=0.3, color='#FF9800', label='Isospin (C₂[SU(2)])')

total = volume + surface + coulomb + asymmetry
ax.plot(A_vals_d, total, color='white', linewidth=2, label='Total B/A')

ax.set_xlabel('Mass Number A', fontsize=12)
ax.set_ylabel('Contribution to B/A (MeV)', fontsize=12)
ax.legend(fontsize=8, loc='best')
ax.axhline(y=0, color='white', alpha=0.3)

# Panel (c): Valley of stability
ax = axes[1, 0]
ax.set_title('Valley of Stability (Algebraic Prediction)', fontsize=13, fontweight='bold')

Z_range = np.arange(1, 105)
N_range = np.arange(1, 160)
Z_grid, N_grid = np.meshgrid(Z_range, N_range)
A_grid = Z_grid + N_grid

# Compute B/A for each (Z, N)
BA_grid = np.zeros_like(A_grid, dtype=float)
for i in range(len(N_range)):
    for j in range(len(Z_range)):
        A = A_grid[i, j]
        Z = Z_grid[i, j]
        if A > 2 and Z < A:
            BA_grid[i, j] = binding_per_nucleon(A, Z)
        else:
            BA_grid[i, j] = np.nan

# Mask unstable regions
BA_grid[BA_grid < 0] = np.nan

im = ax.pcolormesh(Z_range, N_range, BA_grid, cmap='inferno', shading='auto',
                   vmin=0, vmax=9)
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('B/A (MeV)', fontsize=10, color=C_TEXT)
cbar.ax.yaxis.set_tick_params(color=C_TEXT)
plt.setp(plt.getp(cbar.ax.axes, 'yticklabels'), color=C_TEXT)

# Plot N=Z line
ax.plot(Z_range, Z_range, 'w--', alpha=0.5, label='N = Z')

# Magic number lines
for m in [2, 8, 20, 28, 50, 82]:
    ax.axvline(x=m, color='cyan', alpha=0.3, linewidth=0.8)
for m in [2, 8, 20, 28, 50, 82, 126]:
    ax.axhline(y=m, color='cyan', alpha=0.3, linewidth=0.8)

ax.set_xlabel('Proton Number Z', fontsize=12)
ax.set_ylabel('Neutron Number N', fontsize=12)
ax.set_xlim(1, 104)
ax.set_ylim(1, 155)
ax.legend(fontsize=9)

# Panel (d): Residuals
ax = axes[1, 1]
ax.set_title('Shell Effects: Residuals from Smooth Formula', fontsize=13, fontweight='bold')

# Plot B/A for real magic nuclei vs prediction
# Doubly-magic nuclei have extra binding
doubly_magic = [
    (4, 2, '⁴He', 7.07),
    (16, 8, '¹⁶O', 7.98),
    (40, 20, '⁴⁰Ca', 8.55),
    (48, 20, '⁴⁸Ca', 8.67),
    (56, 28, '⁵⁶Ni', 8.64),
    (100, 50, '¹⁰⁰Sn', 8.25),
    (132, 50, '¹³²Sn', 8.36),
    (208, 82, '²⁰⁸Pb', 7.87),
]

A_dm = [x[0] for x in doubly_magic]
Z_dm = [x[1] for x in doubly_magic]
BA_exp = [x[3] for x in doubly_magic]
BA_calc = [binding_per_nucleon(A, Z) for A, Z in zip(A_dm, Z_dm)]
residuals = [exp - calc for exp, calc in zip(BA_exp, BA_calc)]
names_dm = [x[2] for x in doubly_magic]

colors_dm = ['#FFD700' if r > 0 else '#F44336' for r in residuals]
bars = ax.bar(range(len(doubly_magic)), residuals, color=colors_dm, alpha=0.8,
              edgecolor='white', linewidth=1.5)
ax.set_xticks(range(len(doubly_magic)))
ax.set_xticklabels(names_dm, fontsize=9, rotation=45)
ax.axhline(y=0, color='white', alpha=0.5)
ax.set_ylabel('ΔB/A (MeV)', fontsize=12)
ax.set_xlabel('Doubly Magic Nucleus', fontsize=12)

props = dict(boxstyle='round', facecolor='#0d1b2a', edgecolor='#FFD700', alpha=0.9)
ax.text(0.95, 0.95, 'Positive residuals =\nextra binding from\nshell closure\n(algebraic effect)',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        horizontalalignment='right', bbox=props)

fig7.suptitle('The Bethe-Weizsäcker Mass Formula as Algebraic Casimir Sum',
              fontsize=16, fontweight='bold', y=1.01, color='white')
fig7.tight_layout()
fig7.savefig('/workspace/request-project/Algebraic Nuclear Physics/demos/fig7_binding_energy.png',
             dpi=150, bbox_inches='tight')
plt.close(fig7)
print("✅ Figure 7 saved: Binding energy and mass formula")


print("\n🎯 Demo 2 complete! Three figures generated.")
print("   fig5: Shell model energy levels")
print("   fig6: Magic numbers — algebraic origin")
print("   fig7: Binding energy and mass formula")
