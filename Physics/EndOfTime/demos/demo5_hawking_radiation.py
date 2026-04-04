#!/usr/bin/env python3
"""
Demo 5: Hawking Radiation and Black Hole Evaporation
=====================================================
Models the evaporation of black holes via Hawking radiation, showing
how even the most massive objects in the universe eventually vanish.

Oracle Cosmos & Oracle Entropeia contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# Physics: Hawking Radiation
# ============================================================

# Constants (SI)
G = 6.674e-11       # gravitational constant
c = 3e8              # speed of light
hbar = 1.055e-34     # reduced Planck constant
kB = 1.381e-23       # Boltzmann constant
sigma_SB = 5.67e-8   # Stefan-Boltzmann constant
M_sun = 1.989e30     # solar mass
yr = 3.156e7         # seconds per year

def hawking_temperature(M):
    """Hawking temperature of a Schwarzschild black hole."""
    return hbar * c**3 / (8 * np.pi * G * M * kB)

def evaporation_time(M):
    """Evaporation time of a Schwarzschild black hole (in years)."""
    t_sec = 5120 * np.pi * G**2 * M**3 / (hbar * c**4)
    return t_sec / yr

def mass_evolution(M0, t_array_years):
    """
    Mass of an evaporating black hole as a function of time.
    M(t)³ = M0³ - (M0³/t_evap) * t
    """
    t_evap = evaporation_time(M0)
    # Fraction of lifetime
    frac = t_array_years / t_evap
    # M(t)/M0 = (1 - t/t_evap)^{1/3}
    mass_ratio = np.where(frac < 1, (1 - frac)**(1./3.), 0)
    return M0 * mass_ratio

# ============================================================
# Black hole catalog
# ============================================================

black_holes = [
    ("Primordial\n(10¹² kg)", 1e12, '#FF4444'),
    ("Lunar mass\n(7×10²² kg)", 7e22, '#FF8844'),
    ("Earth mass\n(6×10²⁴ kg)", 6e24, '#FFCC44'),
    ("1 M☉", 1 * M_sun, '#44FF44'),
    ("10 M☉\n(stellar)", 10 * M_sun, '#44AAFF'),
    ("4×10⁶ M☉\n(Sgr A*)", 4e6 * M_sun, '#8844FF'),
    ("10¹⁰ M☉\n(TON 618)", 1e10 * M_sun, '#FF44FF'),
]

# ============================================================
# Visualization
# ============================================================

fig = plt.figure(figsize=(20, 14))
fig.patch.set_facecolor('#0a0a1a')
gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# --- Panel 1: Evaporation times ---
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_facecolor('#0a0a1a')

masses = np.logspace(8, 42, 500)  # kg
t_evap = np.array([evaporation_time(m) for m in masses])

ax1.loglog(masses / M_sun, t_evap, color='#FF6600', linewidth=2.5)
ax1.fill_between(masses / M_sun, t_evap, alpha=0.1, color='#FF6600')

# Mark specific black holes
for name, mass, color in black_holes:
    t = evaporation_time(mass)
    ax1.plot(mass / M_sun, t, 'o', color=color, markersize=10, zorder=5)
    ax1.annotate(name.replace('\n', ' '), xy=(mass/M_sun, t), 
                xytext=(10, 10), textcoords='offset points',
                fontsize=7, color=color, alpha=0.8)

# Reference lines
ax1.axhline(y=13.8e9, color='white', alpha=0.3, linestyle='--')
ax1.text(1e-20, 13.8e9 * 1.5, 'Age of Universe', color='white', alpha=0.5, fontsize=9)
ax1.axhline(y=1e14, color='white', alpha=0.2, linestyle=':')
ax1.text(1e-20, 1e14 * 1.5, 'Last stars die', color='white', alpha=0.3, fontsize=8)

ax1.set_xlabel('Black Hole Mass (M☉)', fontsize=12, color='white')
ax1.set_ylabel('Evaporation Time (years)', fontsize=12, color='white')
ax1.set_title('Black Hole Evaporation Times\nt_evap ∝ M³', 
              fontsize=14, color='white', fontweight='bold')
ax1.tick_params(colors='white')
ax1.grid(True, alpha=0.1, color='white')
for spine in ax1.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

# --- Panel 2: Hawking Temperature ---
ax2 = fig.add_subplot(gs[0, 1])
ax2.set_facecolor('#0a0a1a')

temps = np.array([hawking_temperature(m) for m in masses])
ax2.loglog(masses / M_sun, temps, color='#00CCFF', linewidth=2.5)
ax2.fill_between(masses / M_sun, temps, alpha=0.1, color='#00CCFF')

for name, mass, color in black_holes:
    T = hawking_temperature(mass)
    ax2.plot(mass / M_sun, T, 'o', color=color, markersize=10, zorder=5)

# Reference temperatures
ax2.axhline(y=2.725, color='#FFAA00', alpha=0.3, linestyle='--')
ax2.text(1e-20, 3.5, 'CMB temperature (2.725 K)', color='#FFAA00', alpha=0.5, fontsize=9)

ax2.set_xlabel('Black Hole Mass (M☉)', fontsize=12, color='white')
ax2.set_ylabel('Hawking Temperature (K)', fontsize=12, color='white')
ax2.set_title('Hawking Temperature\nT_H = ℏc³/(8πGMk_B)', 
              fontsize=14, color='white', fontweight='bold')
ax2.tick_params(colors='white')
ax2.grid(True, alpha=0.1, color='white')
for spine in ax2.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax2.annotate('Smaller BHs are HOTTER\n→ evaporate faster\n→ runaway process!', 
            xy=(1e-18, 1e12), fontsize=10, color='#00CCFF',
            ha='center', style='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#1a1a3e', 
                     edgecolor='#00CCFF', alpha=0.8))

# --- Panel 3: Mass evolution during evaporation ---
ax3 = fig.add_subplot(gs[1, 0])
ax3.set_facecolor('#0a0a1a')

for name, mass, color in black_holes[3:]:  # Solar mass and above
    t_evap_yr = evaporation_time(mass)
    t = np.linspace(0, t_evap_yr * 0.9999, 1000)
    M = mass_evolution(mass, t)
    ax3.plot(t / t_evap_yr, M / mass, color=color, linewidth=2.5, 
            label=name.replace('\n', ' '))

ax3.set_xlabel('t / t_evaporation', fontsize=12, color='white')
ax3.set_ylabel('M(t) / M₀', fontsize=12, color='white')
ax3.set_title('Black Hole Mass Evolution\nM(t) = M₀(1 - t/t_evap)^{1/3}', 
              fontsize=14, color='white', fontweight='bold')
ax3.tick_params(colors='white')
ax3.grid(True, alpha=0.1, color='white')
ax3.legend(fontsize=8, facecolor='#1a1a2e', edgecolor='white', labelcolor='white')
for spine in ax3.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax3.annotate('Final explosion!\nAll mass → radiation\nin last instant', 
            xy=(0.98, 0.05), fontsize=10, color='#FF4444',
            ha='center', style='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#1a1a3e', 
                     edgecolor='#FF4444', alpha=0.8))

# --- Panel 4: The Final Flash ---
ax4 = fig.add_subplot(gs[1, 1])
ax4.set_facecolor('#0a0a1a')

# Power output in the last moments
# P = (ħc⁶)/(15360π G² M²)
# As M→0, P→∞: the final explosion

# Normalized: last 1% of evaporation time
t_frac = np.linspace(0.90, 0.9999, 1000)
M_frac = (1 - t_frac)**(1/3)
# P ∝ M^{-2} ∝ (1-t/t_evap)^{-2/3}
P_relative = M_frac**(-2)

ax4.semilogy(t_frac, P_relative, color='#FFD700', linewidth=2.5)
ax4.fill_between(t_frac, 1, P_relative, alpha=0.15, color='#FFD700')

ax4.set_xlabel('t / t_evaporation', fontsize=12, color='white')
ax4.set_ylabel('Luminosity / L₀ (relative)', fontsize=12, color='white')
ax4.set_title('The Final Flash\nBlack Hole Death Luminosity', 
              fontsize=14, color='white', fontweight='bold')
ax4.tick_params(colors='white')
ax4.grid(True, alpha=0.1, color='white')
for spine in ax4.spines.values():
    spine.set_color('white')
    spine.set_alpha(0.3)

ax4.annotate('The last black hole dies\nin a burst of gamma rays,\n'
            'releasing its remaining mass\nas pure radiation.\n\n'
            'After this: eternal darkness.', 
            xy=(0.93, 100), fontsize=10, color='#FFD700',
            ha='center', style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#1a1a3e', 
                     edgecolor='#FFD700', alpha=0.8))

fig.text(0.5, 0.01, 
         '"Black holes ain\'t so black." — Stephen Hawking, 1974',
         ha='center', fontsize=12, color='white', alpha=0.4, style='italic')

plt.savefig('/workspace/request-project/demos/output/hawking_radiation.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 5: Hawking Radiation saved to demos/output/hawking_radiation.png")
