#!/usr/bin/env python3
"""
Gravitational Metamaterial Simulator
=====================================

Simulates the concept of gravitational metamaterials — structured arrays
of rotating masses that create periodic gravitomagnetic potentials,
analogous to photonic crystals for light.

Key concepts:
- Photonic crystal analogy: periodic EM → band gaps for light
- Gravitational crystal: periodic gravitomagnetic → band gaps for gravity waves
- Effective metric modification through sub-wavelength mass structures
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from matplotlib import cm
import os

output_dir = os.path.dirname(os.path.abspath(__file__))

G = 6.674e-11
c = 3e8

# ============================================================
# 1. Gravitomagnetic Potential from Rotating Cylinder Array
# ============================================================
def gravitomagnetic_potential_cylinder(x, y, x0, y0, M, R, omega, direction=1):
    """
    Gravitomagnetic vector potential from a rotating cylinder.
    A_g ~ (G/(2c²)) * M * ω * R² / r  (far field, 2D)
    direction: +1 or -1 for rotation sense
    """
    dx, dy = x - x0, y - y0
    r2 = dx**2 + dy**2
    r = np.sqrt(r2)
    r = np.where(r < R, R, r)  # Regularize inside cylinder
    
    J = 0.5 * M * R**2 * omega * direction  # Angular momentum
    prefactor = G * J / (c**2 * r2)
    
    # Vector potential (azimuthal direction in 2D → (-y, x)/r components)
    Ax = -prefactor * dy / r
    Ay = prefactor * dx / r
    
    return Ax, Ay

def total_gravitomagnetic_field(x, y, cylinders):
    """Sum gravitomagnetic fields from array of cylinders."""
    Ax_total = np.zeros_like(x)
    Ay_total = np.zeros_like(y)
    
    for cyl in cylinders:
        Ax, Ay = gravitomagnetic_potential_cylinder(
            x, y, cyl['x'], cyl['y'], cyl['M'], cyl['R'], cyl['omega'], cyl['dir'])
        Ax_total += Ax
        Ay_total += Ay
    
    # B_g = curl(A_g) → in 2D, B_gz = dAy/dx - dAx/dy
    dx = x[0, 1] - x[0, 0] if x.ndim == 2 else 1e-3
    dy = y[1, 0] - y[0, 0] if y.ndim == 2 else 1e-3
    
    dAy_dx = np.gradient(Ay_total, dx, axis=1)
    dAx_dy = np.gradient(Ax_total, dy, axis=0)
    Bz = dAy_dx - dAx_dy
    
    return Ax_total, Ay_total, Bz

# ============================================================
# 2. Band Structure Calculation (1D model)
# ============================================================
def gravitational_band_structure(N_k=200, N_bands=6):
    """
    Compute band structure for gravitational waves in a periodic 
    gravitomagnetic potential (1D Kronig-Penney model analogy).
    
    The dispersion relation for waves in a periodic potential has gaps
    at the Brillouin zone boundaries.
    """
    # Model: free gravitational wave dispersion with periodic perturbation
    # ω² = c²k² + V₀ cos(2πx/a)
    # Band gaps open at k = nπ/a
    
    a = 0.1  # Lattice constant (m)
    V0 = 1e-20  # Gravitomagnetic potential strength (very weak)
    
    k = np.linspace(-3*np.pi/a, 3*np.pi/a, N_k)
    
    bands = []
    for n in range(-N_bands//2, N_bands//2 + 1):
        # Folded dispersion with avoided crossings
        k_shifted = k - 2*n*np.pi/a
        omega_sq = c**2 * k_shifted**2
        omega = np.sqrt(np.abs(omega_sq))
        bands.append(omega)
    
    # Create avoided crossings (band gaps)
    bands_processed = []
    omega_all = np.sort(np.array(bands), axis=0)
    
    for i in range(len(omega_all)):
        band = omega_all[i]
        if i > 0:
            # Add gap at crossing points
            gap_size = V0 * c / a  # Gap proportional to potential
            prev = bands_processed[-1]
            overlap = band < prev
            band[overlap] = prev[overlap] + gap_size
        bands_processed.append(band)
    
    return k * a / np.pi, bands_processed, a

# ============================================================
# Plotting
# ============================================================

# --- Figure 1: Gravitational Metamaterial Array ---
fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("Gravitational Metamaterials: Engineering Spacetime with Mass Arrays",
             fontsize=16, fontweight='bold')

# Panel 1: Array layout with fields
ax = axes[0, 0]
N_grid = 200
x = np.linspace(-3, 3, N_grid)
y = np.linspace(-3, 3, N_grid)
X, Y = np.meshgrid(x, y)

# Create 4x4 alternating array
cylinders = []
spacing = 1.0
M_cyl = 1e4  # 10 tons
R_cyl = 0.1
omega_cyl = 1e4  # rad/s

for i in range(-2, 2):
    for j in range(-2, 2):
        direction = (-1)**((i+j) % 2)  # Alternating rotation
        cylinders.append({
            'x': (i + 0.5) * spacing,
            'y': (j + 0.5) * spacing,
            'M': M_cyl,
            'R': R_cyl,
            'omega': omega_cyl,
            'dir': direction
        })

Ax, Ay, Bz = total_gravitomagnetic_field(X, Y, cylinders)

# Plot B_g field
vmax = np.percentile(np.abs(Bz), 95)
im = ax.pcolormesh(X, Y, Bz, cmap='RdBu_r', shading='auto', 
                    vmin=-vmax, vmax=vmax)
plt.colorbar(im, ax=ax, label='B_g (gravitomagnetic field)')

# Draw cylinders
for cyl in cylinders:
    color = 'blue' if cyl['dir'] > 0 else 'red'
    circle = Circle((cyl['x'], cyl['y']), R_cyl * 2, 
                     facecolor=color, edgecolor='black', alpha=0.7)
    ax.add_patch(circle)
    symbol = '⟳' if cyl['dir'] > 0 else '⟲'
    ax.text(cyl['x'], cyl['y'], symbol, ha='center', va='center', 
           fontsize=8, color='white')

ax.set_xlabel('x (m)', fontsize=12)
ax.set_ylabel('y (m)', fontsize=12)
ax.set_title('Gravitomagnetic Field: Alternating Rotation Array\n'
             'Blue/Red = Opposite rotations → periodic B_g', fontsize=13)
ax.set_aspect('equal')

# Panel 2: Analogy with photonic crystal
ax = axes[0, 1]
# EM photonic crystal band gap illustration
k_norm = np.linspace(-1, 1, 500)
omega_1 = np.abs(k_norm)
omega_2 = np.sqrt(k_norm**2 + 0.04)

# Lower band
ax.fill_between(k_norm, 0, omega_1 * 0.95, alpha=0.2, color='blue', label='Allowed bands')
ax.plot(k_norm, omega_1 * 0.95, 'b-', linewidth=2)

# Gap
ax.fill_between(k_norm, omega_1 * 0.95, omega_2 * 1.05, alpha=0.3, color='red', label='Band gap')

# Upper band
ax.fill_between(k_norm, omega_2 * 1.05, 2.0, alpha=0.2, color='blue')
ax.plot(k_norm, omega_2 * 1.05, 'b-', linewidth=2)

ax.set_xlabel('Wave vector k (π/a)', fontsize=12)
ax.set_ylabel('Frequency ω', fontsize=12)
ax.set_title('Band Gap Analogy\n'
             'EM metamaterials block light → Grav. metamaterials block gravity waves?',
             fontsize=12)
ax.legend(fontsize=11)
ax.set_ylim(0, 2)
ax.grid(True, alpha=0.3)

# Panel 3: Effective metric modification
ax = axes[1, 0]
r = np.linspace(0.1, 5, 1000)

# Normal metric: g_tt = -(1 - 2GM/(c²r))
M_source = 1e6  # kg
g_tt_normal = -(1 - 2*G*M_source/(c**2 * r))

# Modified metric in metamaterial region
metamaterial_region = (r > 1) & (r < 3)
g_tt_modified = g_tt_normal.copy()
modification = 0.001 * np.sin(2*np.pi * r * 5)  # Periodic modification
g_tt_modified[metamaterial_region] += modification[metamaterial_region]

ax.plot(r, -g_tt_normal - 1, 'b-', linewidth=2, label='Normal metric (g_tt + 1)')
ax.plot(r, -g_tt_modified - 1, 'r-', linewidth=1.5, label='Modified metric (in metamaterial)')
ax.axvspan(1, 3, alpha=0.1, color='green', label='Metamaterial region')
ax.set_xlabel('Distance (m)', fontsize=12)
ax.set_ylabel('Metric deviation from flat space', fontsize=12)
ax.set_title('Effective Metric Modification\n'
             'Metamaterial creates periodic spacetime "corrugation"', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: Comparison table (as text)
ax = axes[1, 1]
ax.axis('off')
table_data = [
    ['Property', 'EM Metamaterial', 'Grav. Metamaterial'],
    ['───────', '──────────────', '───────────────'],
    ['Medium', 'ε, μ (permittivity,\npermeability)', 'g_μν (metric tensor)'],
    ['Elements', 'Split-ring resonators\n(metal/dielectric)', 'Rotating dense\ncylinders (tungsten)'],
    ['Wave', 'Electromagnetic', 'Gravitational'],
    ['Band gap\nmechanism', 'Periodic ε, μ\nmodification', 'Periodic\ngravitomagnetic B_g'],
    ['Key effect', 'Negative refraction,\ninvisibility cloaking', 'GW shielding,\neffective g reduction'],
    ['Status', '✅ Demonstrated', '❌ Theoretical'],
    ['Challenge', 'Fabrication at\ntarget wavelength', '10³⁹ weakness\nof gravity'],
]

y_pos = 0.95
for row in table_data:
    for j, cell in enumerate(row):
        ax.text(0.02 + j * 0.35, y_pos, cell, fontsize=10, 
               va='top', fontfamily='monospace',
               fontweight='bold' if y_pos > 0.9 else 'normal')
    y_pos -= 0.09

ax.set_title('Analogy: EM vs Gravitational Metamaterials', fontsize=13, pad=20)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'gravitational_metamaterial.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: gravitational_metamaterial.png")

# --- Figure 2: Gravitational Cloaking Concept ---
fig, axes = plt.subplots(1, 2, figsize=(14, 7))
fig.suptitle("Gravitational Cloaking: Could We Hide Mass From Gravity?",
             fontsize=16, fontweight='bold')

# Panel 1: EM cloaking (proven)
ax = axes[0]
N_ray = 15
theta_rays = np.linspace(-0.3, 0.3, N_ray)

for theta in theta_rays:
    # Straight ray before object
    x_before = np.linspace(-4, -1.5, 100)
    y_before = np.tan(theta) * x_before
    
    # Bent ray around object
    t_around = np.linspace(-np.pi/2, np.pi/2, 100)
    r_cloak = 1.5
    x_around = r_cloak * np.cos(t_around)
    y_around = r_cloak * np.sin(t_around) + np.tan(theta) * r_cloak
    
    # Straight ray after object
    x_after = np.linspace(1.5, 4, 100)
    y_after = np.tan(theta) * x_after
    
    ax.plot(x_before, y_before, 'b-', alpha=0.5, linewidth=1)
    ax.plot(x_after, y_after, 'b-', alpha=0.5, linewidth=1)

# Cloak region
circle_outer = Circle((0, 0), 1.5, facecolor='lightyellow', edgecolor='orange',
                       linewidth=2, alpha=0.5, linestyle='--')
circle_inner = Circle((0, 0), 0.8, facecolor='gray', edgecolor='black', linewidth=2)
ax.add_patch(circle_outer)
ax.add_patch(circle_inner)

ax.text(0, 0, 'Hidden\nObject', ha='center', va='center', fontsize=10, fontweight='bold')
ax.text(0, -2.2, 'Metamaterial Cloak', ha='center', fontsize=11, color='orange')
ax.set_title('EM Invisibility Cloak\n(Demonstrated in lab)', fontsize=13)
ax.set_xlim(-4, 4)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.annotate('Light rays bend\naround object', xy=(-2, 1.5), fontsize=10, color='blue')

# Panel 2: Gravitational cloaking (theoretical)
ax = axes[1]

# Gravitational field lines around a mass
theta = np.linspace(0, 2*np.pi, 100)

# Normal field lines pointing inward
for angle in np.linspace(0, 2*np.pi, 16, endpoint=False):
    r_vals = np.linspace(1.5, 4, 100)
    x_line = r_vals * np.cos(angle)
    y_line = r_vals * np.sin(angle)
    ax.annotate('', xy=(x_line[0], y_line[0]), xytext=(x_line[-1], y_line[-1]),
               arrowprops=dict(arrowstyle='->', color='red', alpha=0.3, lw=1))

# Cloak region
circle_outer = Circle((0, 0), 1.5, facecolor='lightcyan', edgecolor='green',
                       linewidth=2, alpha=0.5, linestyle='--')
circle_inner = Circle((0, 0), 0.8, facecolor='gray', edgecolor='black', linewidth=2)
ax.add_patch(circle_outer)
ax.add_patch(circle_inner)

# Modified field lines (deflected)
for angle in np.linspace(0, 2*np.pi, 8, endpoint=False):
    r_vals = np.linspace(1.5, 4, 100)
    deflection = 0.5 * np.exp(-(r_vals - 1.5)) * np.sin(angle)
    x_line = r_vals * np.cos(angle + deflection/r_vals)
    y_line = r_vals * np.sin(angle + deflection/r_vals)
    ax.plot(x_line, y_line, 'g-', alpha=0.6, linewidth=1.5)

ax.text(0, 0, 'Shielded\nMass', ha='center', va='center', fontsize=10, fontweight='bold')
ax.text(0, -2.2, 'Gravitational Metamaterial', ha='center', fontsize=11, color='green')
ax.set_title('Gravitational Cloak (Theoretical)\n'
             'Deflect gravitational field lines around region?', fontsize=13)
ax.set_xlim(-4, 4)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('y', fontsize=12)
ax.annotate('Field lines deflected\nby metamaterial\n(hypothetical)', 
           xy=(-2, 2), fontsize=10, color='green')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'gravitational_cloaking.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: gravitational_cloaking.png")

print("\n🔮 All gravitational metamaterial visualizations complete!")
print("Key insight: If we could build gravitational metamaterials,")
print("we could engineer effective spacetime geometry — the holy grail of gravity control.")
