#!/usr/bin/env python3
"""
Casimir-Gravitational Coupling Simulator
=========================================

Investigates the connection between quantum vacuum fluctuations (Casimir effect)
and gravitational effects. The Casimir effect produces real negative energy 
density — exactly the exotic ingredient needed for warp drives and wormholes.

Key equation:
    u_Casimir = -π²ℏc / (720 a⁴)

where a is the plate separation.
"""

import numpy as np
import matplotlib.pyplot as plt
import os

output_dir = os.path.dirname(os.path.abspath(__file__))

# Physical constants
hbar = 1.055e-34     # J·s
c = 3e8              # m/s
G = 6.674e-11        # m³/(kg·s²)
pi = np.pi

# ============================================================
# Casimir Energy Density
# ============================================================
def casimir_energy_density(a):
    """Casimir energy density between parallel plates at separation a (meters)."""
    return -pi**2 * hbar * c / (720 * a**4)

def casimir_force_per_area(a):
    """Casimir force per unit area (pressure) in N/m²."""
    return -pi**2 * hbar * c / (240 * a**4)

def casimir_gravitational_effect(a, N_cavities, V_cavity):
    """
    Gravitational effect of N Casimir cavities.
    Returns equivalent mass anomaly in kg.
    """
    u = casimir_energy_density(a)
    E_total = N_cavities * u * V_cavity
    delta_m = E_total / c**2
    return delta_m

# ============================================================
# Plotting
# ============================================================

# --- Figure 1: Casimir Effect Overview ---
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Casimir-Gravitational Coupling: Quantum Vacuum Meets Gravity", 
             fontsize=16, fontweight='bold')

# Panel 1: Energy density vs plate separation
ax = axes[0, 0]
a_range = np.logspace(-9, -6, 1000)  # 1 nm to 1 μm
u = np.abs(casimir_energy_density(a_range))

ax.loglog(a_range * 1e9, u, 'b-', linewidth=2)
ax.fill_between(a_range * 1e9, u, alpha=0.2, color='blue')
ax.set_xlabel('Plate Separation (nm)', fontsize=12)
ax.set_ylabel('|Energy Density| (J/m³)', fontsize=12)
ax.set_title('Casimir Energy Density\n(All Negative — Exotic Matter!)', fontsize=13)
ax.grid(True, alpha=0.3)

# Mark key scales
for a_mark, label in [(10, '10 nm'), (50, '50 nm'), (100, '100 nm')]:
    u_mark = np.abs(casimir_energy_density(a_mark * 1e-9))
    ax.plot(a_mark, u_mark, 'ro', markersize=8)
    ax.annotate(f'{label}\n{u_mark:.1e} J/m³', xy=(a_mark, u_mark),
               xytext=(a_mark*2, u_mark*3), fontsize=9,
               arrowprops=dict(arrowstyle='->', color='red'))

# Panel 2: Casimir force (measured quantity)
ax = axes[0, 1]
F = np.abs(casimir_force_per_area(a_range))
ax.loglog(a_range * 1e9, F, 'r-', linewidth=2)
ax.fill_between(a_range * 1e9, F, alpha=0.2, color='red')
ax.set_xlabel('Plate Separation (nm)', fontsize=12)
ax.set_ylabel('|Force/Area| (N/m² = Pa)', fontsize=12)
ax.set_title('Casimir Pressure\n(Experimentally Verified to ~1%)', fontsize=13)
ax.grid(True, alpha=0.3)

# Mark atmospheric pressure for comparison
ax.axhline(101325, color='green', linestyle='--', alpha=0.5)
ax.annotate('1 atm', xy=(1, 101325), fontsize=10, color='green')

# Panel 3: Gravitational mass anomaly vs number of cavities
ax = axes[1, 0]
a_cavity = 50e-9  # 50 nm separation
V_cavity = (50e-9)**2 * 50e-9  # Tiny cavity volume
N_range = np.logspace(10, 26, 1000)

delta_m = np.abs(casimir_gravitational_effect(a_cavity, N_range, V_cavity))

ax.loglog(N_range, delta_m, 'purple', linewidth=2)
ax.fill_between(N_range, delta_m, alpha=0.1, color='purple')
ax.set_xlabel('Number of Casimir Cavities', fontsize=12)
ax.set_ylabel('|Mass Anomaly| (kg)', fontsize=12)
ax.set_title(f'Gravitational Mass Anomaly\n(a = {a_cavity*1e9:.0f} nm cavities)', fontsize=13)
ax.grid(True, alpha=0.3)

# Detection thresholds
thresholds = [
    (1e-18, 'Best torsion balance\n(~10⁻¹⁸ kg)', 'green'),
    (1e-12, 'Precision scale\n(~10⁻¹² kg)', 'orange'),
    (1e-6, 'Analytical balance\n(~10⁻⁶ kg)', 'red'),
]
for thresh, label, color in thresholds:
    ax.axhline(thresh, color=color, linestyle='--', alpha=0.5)
    ax.annotate(label, xy=(1e11, thresh), fontsize=9, color=color, va='bottom')

# Panel 4: Nanostructure design concept
ax = axes[1, 1]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_aspect('equal')

# Draw nanoscale Casimir cavities
for i in range(8):
    for j in range(8):
        x0, y0 = 1 + i * 1.0, 1 + j * 1.0
        # Plates
        ax.plot([x0, x0+0.6], [y0, y0], 'b-', linewidth=2)
        ax.plot([x0, x0+0.6], [y0+0.15, y0+0.15], 'b-', linewidth=2)
        # Vacuum between
        ax.fill_between([x0, x0+0.6], y0, y0+0.15, alpha=0.1, color='purple')

ax.set_title('Nanostructured Casimir Material\n(Concept: Dense array of nm-scale cavities)', fontsize=13)
ax.annotate('Each cavity: ~50 nm gap\nPurple = negative energy vacuum\n\n'
           '1 cm³ material contains\n~10¹⁸ cavities',
           xy=(5, 9.5), fontsize=11, ha='center', va='top',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# Scale bar
ax.plot([1, 2], [0.3, 0.3], 'k-', linewidth=3)
ax.text(1.5, 0.5, '~100 nm', ha='center', fontsize=10)

ax.axis('off')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'casimir_gravity.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: casimir_gravity.png")

# --- Figure 2: Exotic Matter Budget for Warp Drive ---
fig, ax = plt.subplots(figsize=(12, 7))

# Different technologies and their negative energy requirements
technologies = [
    'Casimir Cavity\n(50 nm, 1 cm³)',
    'Casimir Array\n(10¹⁸ cavities)',
    'Casimir Mega-Array\n(10²⁴ cavities)',
    'Traversable\nWormhole\n(1m throat)',
    'Van Den Broeck\nWarp Drive',
    'Alcubierre\nWarp Drive\n(Original)',
]

# Negative energy in Joules (absolute value)
energies = [
    abs(casimir_energy_density(50e-9)) * (1e-2)**3,      # Single cm³
    abs(casimir_energy_density(50e-9)) * (50e-9)**3 * 1e18,  # Array
    abs(casimir_energy_density(50e-9)) * (50e-9)**3 * 1e24,  # Mega
    1e40,   # Wormhole estimate
    2e46,   # Van Den Broeck
    2e62,   # Original Alcubierre
]

colors = ['#2ecc71', '#27ae60', '#1abc9c', '#3498db', '#e67e22', '#e74c3c']
bars = ax.barh(range(len(technologies)), [np.log10(e) for e in energies], 
               color=colors, edgecolor='black', height=0.7)

ax.set_yticks(range(len(technologies)))
ax.set_yticklabels(technologies, fontsize=11)
ax.set_xlabel('log₁₀(Negative Energy Required) [Joules]', fontsize=13)
ax.set_title('Exotic Matter Budget: From Lab to Warp Drive\n'
             'How much negative energy does each technology need?', fontsize=14)

# Add labels
for i, (bar, e) in enumerate(zip(bars, energies)):
    ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2,
            f'10^{np.log10(e):.0f} J', va='center', fontsize=11, fontweight='bold')

# Comparison lines
comparisons = [
    (np.log10(4.2e9), 'TNT (1 ton)'),
    (np.log10(4e15), 'Tsar Bomba'),
    (np.log10(3.8e26), 'Sun (1 second)'),
    (np.log10(1.8e47), 'Sun (total mass-energy)'),
]
for val, label in comparisons:
    ax.axvline(val, color='gray', linestyle=':', alpha=0.5)
    ax.text(val, len(technologies) - 0.2, label, fontsize=8, rotation=90,
           ha='right', va='top', color='gray')

ax.set_xlim(-5, 70)
ax.grid(True, alpha=0.2, axis='x')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'exotic_matter_budget.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: exotic_matter_budget.png")

# --- Figure 3: Experimental Sensitivity Roadmap ---
fig, ax = plt.subplots(figsize=(12, 8))

# Timeline vs sensitivity
years = [2025, 2030, 2035, 2040, 2050, 2075, 2100]
experiments = {
    'Torsion Balance': {
        'sensitivity': [1e-18, 5e-19, 1e-19, 5e-20, 1e-20, 1e-22, 1e-24],
        'color': 'blue', 'marker': 'o'
    },
    'Atom Interferometry': {
        'sensitivity': [1e-15, 1e-16, 1e-17, 1e-18, 1e-19, 1e-21, 1e-23],
        'color': 'green', 'marker': 's'
    },
    'LIGO/Space GW': {
        'sensitivity': [1e-23, 5e-24, 1e-24, 5e-25, 1e-25, 1e-27, 1e-29],
        'color': 'red', 'marker': '^'
    },
}

# Required sensitivities for detection
detection_thresholds = {
    'Casimir-gravity coupling\n(nanostructure)': 1e-18,
    'GEMR in superconductor\n(if Q~10⁶)': 1e-13,
    'Frame-dragging\n(lab scale)': 1e-20,
    'Gravitational wave\nfrom lab source': 1e-30,
}

for name, data in experiments.items():
    ax.semilogy(years, data['sensitivity'], f"{data['marker']}-", 
               color=data['color'], linewidth=2, markersize=8, label=name)

for name, thresh in detection_thresholds.items():
    ax.axhline(thresh, linestyle='--', alpha=0.4, color='purple')
    ax.text(2102, thresh, name, fontsize=9, va='center', color='purple')

ax.set_xlabel('Year', fontsize=13)
ax.set_ylabel('Measurement Sensitivity (dimensionless strain or kg)', fontsize=12)
ax.set_title('Experimental Sensitivity Roadmap\n'
             'When could we detect gravitational engineering effects?', fontsize=14)
ax.legend(loc='lower left', fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(2023, 2120)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'sensitivity_roadmap.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: sensitivity_roadmap.png")

print("\n⚛️  All Casimir-gravity coupling visualizations complete!")
print("Key insight: Casimir effect = real negative energy = exotic matter lite.")
print("Nanostructured materials could test the gravity-quantum vacuum connection.")
