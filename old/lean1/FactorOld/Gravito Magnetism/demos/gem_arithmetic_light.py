#!/usr/bin/env python3
"""
Arithmetic Light and Gravitomagnetism
======================================

This demo explores the deep connection between Pythagorean triples
("arithmetic light") and discrete gravitomagnetic field configurations.

Key ideas:
- Each Pythagorean triple (a,b,c) defines a point on S¹ via stereographic projection
- These points are "integer gravitons" — discrete GEM field configurations
- The Berggren tree generates ALL primitive triples, acting as discrete Lorentz boosts
- The conformal factor links stereographic geometry to gravitational physics
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

# ============================================================
# Generate the Berggren Tree of Pythagorean Triples
# ============================================================

def berggren_matrices():
    """The three Berggren matrices that generate all primitive triples."""
    A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    return A, B, C

def generate_berggren_tree(depth=4):
    """Generate all primitive Pythagorean triples up to given depth."""
    A, B, C = berggren_matrices()
    root = np.array([3, 4, 5])
    
    tree = {0: [root]}
    all_triples = [root]
    
    for d in range(1, depth + 1):
        tree[d] = []
        for parent in tree[d-1]:
            for M in [A, B, C]:
                child = M @ parent
                if all(child > 0):
                    tree[d].append(child)
                    all_triples.append(child)
    
    return tree, all_triples

def triple_to_gem(a, b, c):
    """Map Pythagorean triple to GEM field on unit circle."""
    E_g = 2*a*b / c**2
    B_g = (b**2 - a**2) / c**2
    return E_g, B_g

# ============================================================
# Visualization
# ============================================================

tree, all_triples = generate_berggren_tree(depth=4)

fig = plt.figure(figsize=(18, 14))

# --- Panel 1: The Berggren Tree of Integer Gravitons ---
ax1 = fig.add_subplot(221)
theta = np.linspace(0, 2*np.pi, 300)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1.5)

depth_colors = {0: 'red', 1: 'blue', 2: 'green', 3: 'orange', 4: 'purple'}
depth_labels = {}

for depth_level, triples in tree.items():
    for t in triples:
        E, B = triple_to_gem(*t)
        color = depth_colors.get(depth_level, 'gray')
        size = max(4, 12 - 2*depth_level)
        ax1.plot(E, B, 'o', color=color, markersize=size, alpha=0.7)
        if depth_level not in depth_labels:
            depth_labels[depth_level] = ax1.plot([], [], 'o', color=color, 
                                                  markersize=size, label=f'Depth {depth_level}')[0]

# Label the root
E0, B0 = triple_to_gem(3, 4, 5)
ax1.annotate('(3,4,5)', (E0, B0), fontsize=9, fontweight='bold',
            xytext=(10, -15), textcoords='offset points',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax1.set_xlabel('E_g (gravitoelectric)', fontsize=11)
ax1.set_ylabel('B_g (gravitomagnetic)', fontsize=11)
ax1.set_title('Berggren Tree of Integer Gravitons\n(Each ● is a Pythagorean triple on S¹)', fontsize=12)
ax1.legend(fontsize=8, loc='lower left')
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# --- Panel 2: GEM Field Spectrum (angle distribution) ---
ax2 = fig.add_subplot(222)
angles = []
for t in all_triples:
    E, B = triple_to_gem(*t)
    angle = np.arctan2(B, E)
    angles.append(angle)

ax2.hist(angles, bins=40, color='steelblue', edgecolor='navy', alpha=0.7)
ax2.set_xlabel('GEM field angle θ = arctan(B_g/E_g)', fontsize=11)
ax2.set_ylabel('Count', fontsize=11)
ax2.set_title('Angular Distribution of Integer Gravitons\n(Spectrum of arithmetic light)', fontsize=12)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Conformal Energy Landscape ---
ax3 = fig.add_subplot(223)
u = np.linspace(-4, 4, 300)
v = np.linspace(-4, 4, 300)
U, V = np.meshgrid(u, v)
R2 = U**2 + V**2

# Conformal factor
CF = 4 / (1 + R2)**2

# GEM energy density weighted by conformal factor
# Place a graviton at the origin
E_field = 2 * U * V / (R2 + 1e-10)  # stereographic E_g
B_field = (V**2 - U**2) / (R2 + 1e-10)  # stereographic B_g
GEM_energy = (E_field**2 + B_field**2) * CF

# Clip for visualization
GEM_energy_clipped = np.clip(GEM_energy, 0, 10)

im = ax3.contourf(U, V, np.log10(CF + 1e-10), levels=30, cmap='magma')
plt.colorbar(im, ax=ax3, label='log₁₀(conformal factor)')

# Overlay integer gravitons
for t in all_triples[:30]:
    E, B = triple_to_gem(*t)
    ax3.plot(E, B, 'c.', markersize=5, alpha=0.8)

ax3.set_xlabel('u (plane coordinate)', fontsize=11)
ax3.set_ylabel('v (plane coordinate)', fontsize=11)
ax3.set_title('Conformal Energy Landscape\nwith Graviton Positions', fontsize=12)
ax3.set_aspect('equal')

# --- Panel 4: The Mass-Energy Duality Map ---
ax4 = fig.add_subplot(224)

# Show the Kelvin inversion as mass-energy duality
t_vals = np.linspace(0.1, 5, 100)
mass_vals = t_vals
energy_vals = 1 / t_vals

ax4.plot(mass_vals, energy_vals, 'b-', linewidth=2.5, label='E = 1/m (Kelvin inversion)')
ax4.plot([0, 5], [0, 5], 'k--', alpha=0.3, label='E = m (self-dual)')

# Mark self-dual point
ax4.plot(1, 1, 'ro', markersize=12, zorder=5, label='Self-dual: m = E = 1')

# Mark some Pythagorean graviton masses
for t in all_triples[:10]:
    a, b, c_val = t
    mass = c_val / (a**2 + b**2)  # arbitrary mass assignment
    energy = 1 / mass
    ax4.plot(mass, energy, 'g^', markersize=6, alpha=0.7)

ax4.fill_between(mass_vals, energy_vals, alpha=0.05, color='blue')
ax4.set_xlabel('Mass coordinate m', fontsize=11)
ax4.set_ylabel('Energy coordinate E = 1/m', fontsize=11)
ax4.set_title('Mass-Energy Duality\n(Kelvin Inversion = Chart Transition)', fontsize=12)
ax4.legend(fontsize=9)
ax4.set_xlim(0, 5)
ax4.set_ylim(0, 5)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Gravitomagnetism/demos/gem_arithmetic_light.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved gem_arithmetic_light.png")

# ============================================================
# Gravitomagnetic Levitation Analysis
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Required B_g for levitation vs mass
ax = axes[0]
g = 9.81  # m/s²
v_vals = [10, 100, 1000, 7800]  # velocities in m/s
masses = np.logspace(-1, 4, 100)  # kg

for v in v_vals:
    B_g_required = g / v  # from m*g = 2*m*v*B_g → B_g = g/(2v)
    ax.axhline(y=B_g_required, linewidth=1.5, label=f'v = {v} m/s')

ax.set_xlabel('Mass (kg)', fontsize=11)
ax.set_ylabel('Required B_g (rad/s)', fontsize=11)
ax.set_title('Gravitomagnetic Field\nfor Levitation', fontsize=12)
ax.set_yscale('log')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Lense-Thirring for Earth, Jupiter, Neutron Star
ax = axes[1]
G_SI = 6.674e-11
c_SI = 3e8
r_range = np.logspace(6, 10, 200)  # meters

bodies = {
    'Earth': {'M': 5.97e24, 'R': 6.37e6, 'J': 7.1e33, 'color': 'blue'},
    'Jupiter': {'M': 1.9e27, 'R': 7.15e7, 'J': 6.9e38, 'color': 'orange'},
    'Neutron Star': {'M': 2.8e30, 'R': 1e4, 'J': 1e40, 'color': 'red'},
}

for name, params in bodies.items():
    omega_LT = 2 * G_SI * params['J'] / (c_SI**2 * r_range**3)
    valid = r_range > params['R']
    ax.loglog(r_range[valid], omega_LT[valid], '-', color=params['color'],
              linewidth=2, label=name)
    ax.axvline(x=params['R'], color=params['color'], linestyle=':', alpha=0.3)

ax.set_xlabel('Distance from center (m)', fontsize=11)
ax.set_ylabel('Ω_LT (rad/s)', fontsize=11)
ax.set_title('Lense-Thirring Precession\nfor Astrophysical Objects', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: GEM Resonance Enhancement
ax = axes[2]
omega_range = np.linspace(0.01, 5, 500)
omega_0 = 1.0  # natural frequency
Q_values = [1, 5, 20, 100]

for Q in Q_values:
    # Lorentzian response
    response = Q / np.sqrt(1 + Q**2 * (omega_range/omega_0 - omega_0/omega_range)**2)
    ax.plot(omega_range, response, linewidth=1.5, label=f'Q = {Q}')

ax.axvline(x=omega_0, color='red', linestyle='--', alpha=0.5)
ax.set_xlabel('Driving frequency ω/ω₀', fontsize=11)
ax.set_ylabel('Enhancement factor', fontsize=11)
ax.set_title('GEMR: Gravitomagnetic\nResonance Enhancement', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Gravitomagnetism/demos/gem_applications.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved gem_applications.png")

# ============================================================
# Summary Statistics
# ============================================================
print(f"\n{'='*50}")
print(f"ARITHMETIC LIGHT GRAVITON STATISTICS")
print(f"{'='*50}")
print(f"Total primitive triples generated: {len(all_triples)}")
print(f"Berggren tree depth: 4")
print(f"All gravitons verified on S¹: {all(abs(triple_to_gem(*t)[0]**2 + triple_to_gem(*t)[1]**2 - 1) < 1e-10 for t in all_triples)}")
print(f"Smallest triple: {all_triples[0]}")
print(f"Largest hypotenuse: {max(t[2] for t in all_triples)}")
print(f"Angular range: [{min(angles):.4f}, {max(angles):.4f}] radians")
print(f"Mean angle: {np.mean(angles):.4f} radians")
