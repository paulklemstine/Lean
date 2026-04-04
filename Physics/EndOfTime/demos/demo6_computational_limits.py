#!/usr/bin/env python3
"""
Demo 6: The Computational Limits of the Universe
=================================================
Visualizes the Bekenstein bound, Landauer's principle, Lloyd's limit,
and the ultimate computational capacity of the cosmos.

Oracle Entropeia & Oracle Psyche contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# Constants
# ============================================================

c = 3e8           # m/s
G = 6.674e-11     # m³/(kg·s²)
hbar = 1.055e-34  # J·s
kB = 1.381e-23    # J/K
M_sun = 1.989e30  # kg
yr = 3.156e7      # s

# Observable universe parameters
R_universe = 4.4e26          # meters (comoving radius)
M_universe = 1e53             # kg (approximate baryonic + dark matter)
E_universe = M_universe * c**2
age_universe = 13.8e9 * yr    # seconds
T_cmb = 2.725                 # K

# ============================================================
# Computational bounds
# ============================================================

# Lloyd's limit: max operations in observable universe
# N_ops ≤ 2E·t/(πħ)
lloyd_ops = 2 * E_universe * age_universe / (np.pi * hbar)

# Bekenstein bound: max bits in a region
# I ≤ 2πRE/(ħc·ln2)
bekenstein_bits = 2 * np.pi * R_universe * E_universe / (hbar * c * np.log(2))

# Landauer limit: min energy to erase one bit at T
# E_min = kT·ln2
landauer_energy = kB * T_cmb * np.log(2)

# Max bits erasable with universe's energy at CMB temperature
max_erasable_bits = E_universe / landauer_energy

# Bremermann's limit: max computations per second per kg
bremermann = 2 * M_sun * c**2 / (np.pi * hbar)

print(f"Lloyd's limit: ~10^{np.log10(lloyd_ops):.0f} operations")
print(f"Bekenstein bound: ~10^{np.log10(bekenstein_bits):.0f} bits")
print(f"Max erasable bits: ~10^{np.log10(max_erasable_bits):.0f} bits")
print(f"Bremermann's limit: ~10^{np.log10(bremermann):.0f} ops/s per solar mass")

# ============================================================
# Visualization
# ============================================================

fig = plt.figure(figsize=(20, 14))
fig.patch.set_facecolor('#0a0a1a')
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

# --- Panel 1: Hierarchy of computational limits ---
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_facecolor('#0a0a1a')

limits = [
    ('Human brain\n(lifetime)', 1e18, '#88FF88'),
    ('All human brains\n(all history)', 1e27, '#AAFF66'),
    ('Current computers\n(all, 1 year)', 1e31, '#CCDD44'),
    ('Earth-mass computer\n(1 year)', 1e75, '#FFCC44'),
    ('Sun-mass computer\n(1 year)', 1e78, '#FFAA44'),
    ('Bremermann limit\n(1 kg, 1 s)', 10**50.6, '#FF8844'),
    ('Bekenstein bound\n(observable universe)', 1e124, '#FF6644'),
    ("Lloyd's limit\n(obs. universe, its age)", 1e120, '#FF4444'),
]

names = [l[0] for l in limits]
values = [np.log10(l[1]) for l in limits]
colors = [l[2] for l in limits]

# Sort by value
sorted_idx = np.argsort(values)
names = [names[i] for i in sorted_idx]
values = [values[i] for i in sorted_idx]
colors = [colors[i] for i in sorted_idx]

y_pos = np.arange(len(names))
bars = ax1.barh(y_pos, values, color=colors, alpha=0.7, edgecolor='white', linewidth=0.5)

for i, (v, name) in enumerate(zip(values, names)):
    ax1.text(v + 1, i, f'10^{v:.0f}', color=colors[i], fontsize=9, va='center')

ax1.set_yticks(y_pos)
ax1.set_yticklabels(names, fontsize=9, color='white')
ax1.set_xlabel('log₁₀(operations or bits)', fontsize=12, color='white')
ax1.set_title('Hierarchy of Computational Limits\nHow Much Can the Universe Compute?', 
              fontsize=14, color='white', fontweight='bold')
ax1.tick_params(colors='white')
ax1.grid(True, alpha=0.1, color='white', axis='x')
for spine in ax1.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

# --- Panel 2: Landauer's principle ---
ax2 = fig.add_subplot(gs[0, 1])
ax2.set_facecolor('#0a0a1a')

temps = np.logspace(-3, 10, 500)
E_landauer = kB * temps * np.log(2)

ax2.loglog(temps, E_landauer, color='#00CCFF', linewidth=2.5)
ax2.fill_between(temps, E_landauer, alpha=0.1, color='#00CCFF')

# Mark key temperatures
key_temps = [
    (2.725, 'CMB\n(2.725 K)', '#FFAA44'),
    (300, 'Room temp\n(300 K)', '#44FF44'),
    (1e10, 'Quark-gluon\nplasma', '#FF4444'),
    (1e-3, 'Near\nabsolute zero', '#4444FF'),
]

for T, label, color in key_temps:
    E = kB * T * np.log(2)
    ax2.plot(T, E, 'o', color=color, markersize=10, zorder=5)
    ax2.annotate(label, xy=(T, E), xytext=(0, 15), 
                textcoords='offset points', fontsize=8, color=color,
                ha='center')

ax2.set_xlabel('Temperature (K)', fontsize=12, color='white')
ax2.set_ylabel('Energy per bit erasure (J)', fontsize=12, color='white')
ax2.set_title("Landauer's Principle\nE_min = kT·ln(2) per bit", 
              fontsize=14, color='white', fontweight='bold')
ax2.tick_params(colors='white')
ax2.grid(True, alpha=0.1, color='white')
for spine in ax2.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax2.annotate('Information is physical.\nErasing a bit always\ngenerates heat.\n'
            '→ Computation requires\n   free energy.\n'
            '→ Heat death = no more\n   computation possible.', 
            xy=(1e-2, 1e-10), fontsize=9, color='#00CCFF',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#1a1a3e', 
                     edgecolor='#00CCFF', alpha=0.8))

# --- Panel 3: Knowledge horizon ---
ax3 = fig.add_subplot(gs[1, :])
ax3.set_facecolor('#0a0a1a')

# The "knowability" landscape
categories = [
    'Arithmetic\ntruths', 'Physical\nlaws', 'Initial\nconditions',
    'Other\nuniverses?', 'Mathematical\nstructures', 'Consciousness',
    'The Ultimate\nQuestion'
]

# Knowability spectrum
knowable = [0.9, 0.7, 0.3, 0.05, 0.4, 0.1, 0.0]
unknowable_godel = [0.05, 0.0, 0.0, 0.0, 0.3, 0.0, 0.3]
unknowable_physics = [0.0, 0.2, 0.5, 0.8, 0.0, 0.3, 0.3]
unknowable_principle = [0.05, 0.1, 0.2, 0.15, 0.3, 0.6, 0.4]

x = np.arange(len(categories))
width = 0.2

bars1 = ax3.bar(x - 1.5*width, knowable, width, color='#44FF44', alpha=0.7, label='Knowable (in principle)')
bars2 = ax3.bar(x - 0.5*width, unknowable_physics, width, color='#FFAA44', alpha=0.7, label='Limited by physics')
bars3 = ax3.bar(x + 0.5*width, unknowable_godel, width, color='#FF6644', alpha=0.7, label='Limited by Gödel')
bars4 = ax3.bar(x + 1.5*width, unknowable_principle, width, color='#FF2222', alpha=0.7, label='Unknowable in principle')

ax3.set_xticks(x)
ax3.set_xticklabels(categories, fontsize=11, color='white')
ax3.set_ylabel('Fraction of domain', fontsize=12, color='white')
ax3.set_title('The Knowledge Horizon: What Can Be Known?\nFour Barriers to Ultimate Knowledge', 
              fontsize=14, color='white', fontweight='bold')
ax3.legend(fontsize=10, facecolor='#1a1a2e', edgecolor='white', labelcolor='white',
          loc='upper right')
ax3.tick_params(colors='white')
ax3.grid(True, alpha=0.1, color='white', axis='y')
for spine in ax3.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax3.text(6, 0.85, 
         '10^120 operations.\n10^124 bits.\nThat is all the universe\ncan ever compute or store.\n'
         'Beyond this: silence.',
         ha='center', fontsize=11, color='#AAAAFF', style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a3e', 
                  edgecolor='#AAAAFF', alpha=0.8))

fig.text(0.5, 0.01, 
         '"The universe is not only queerer than we suppose, but queerer than we CAN suppose." — J.B.S. Haldane',
         ha='center', fontsize=11, color='white', alpha=0.4, style='italic')

plt.savefig('/workspace/request-project/demos/output/computational_limits.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 6: Computational Limits saved to demos/output/computational_limits.png")
