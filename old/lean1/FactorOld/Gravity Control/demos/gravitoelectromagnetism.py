#!/usr/bin/env python3
"""
Gravitoelectromagnetism (GEM) Simulator
=======================================

Simulates the gravitoelectric and gravitomagnetic fields produced by 
rotating mass distributions, demonstrating the formal analogy between
linearized gravity and Maxwell's electromagnetism.

GEM Maxwell Equations:
    ∇·E_g = -4πGρ          (gravitational Gauss's law)
    ∇×E_g = -∂B_g/∂t       (gravitational Faraday's law)
    ∇·B_g = 0               (no gravitomagnetic monopoles)
    ∇×B_g = -(4πG/c²)J_g   (gravitational Ampère's law, static case)

where J_g = ρv is the mass current density.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import os

output_dir = os.path.dirname(os.path.abspath(__file__))

# Physical constants
G = 6.674e-11       # m³/(kg·s²)
c = 3e8             # m/s

# ============================================================
# 1. Gravitoelectric Field of a Point Mass
# ============================================================
def gravitoelectric_field(x, y, M, x0=0, y0=0):
    """Gravitoelectric field E_g = -GM/r² r_hat (Newtonian gravity)."""
    dx, dy = x - x0, y - y0
    r2 = dx**2 + dy**2
    r = np.sqrt(r2)
    r3 = r2 * r
    r3 = np.where(r3 < 1e-10, 1e-10, r3)
    Ex = -G * M * dx / r3
    Ey = -G * M * dy / r3
    return Ex, Ey

# ============================================================
# 2. Gravitomagnetic Field of a Spinning Mass
# ============================================================
def gravitomagnetic_field_dipole(x, y, z, M, R, omega):
    """
    Gravitomagnetic field of a uniformly rotating sphere.
    Analogous to the magnetic field of a magnetic dipole.
    
    B_g = (2G/c²) * (J × r_hat) / r²  (far field)
    
    where J = (2/5)MR²ω is the angular momentum.
    """
    J = 0.4 * M * R**2 * omega  # Angular momentum (solid sphere)
    r2 = x**2 + y**2 + z**2
    r = np.sqrt(r2)
    r5 = r2**2 * r
    r5 = np.where(r5 < 1e-30, 1e-30, r5)
    r3 = r2 * r
    r3 = np.where(r3 < 1e-20, 1e-20, r3)
    
    # Dipole field (J along z-axis)
    # B_g = (G/(c²r³)) * [3(J·r_hat)r_hat - J]  (factor of 2 for GR)
    factor = 2 * G / (c**2)
    
    Jr = J * z  # J·r (J is along z)
    
    Bx = factor * (3 * Jr * x / r5)
    By = factor * (3 * Jr * y / r5)
    Bz = factor * (3 * Jr * z / r5 - J / r3)
    
    return Bx, By, Bz

# ============================================================
# Plotting
# ============================================================

# --- Figure 1: GEM Field Comparison ---
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle("Gravitoelectromagnetism: Gravity's Hidden Electromagnetic Twin", 
             fontsize=16, fontweight='bold')

# Panel 1: Gravitoelectric field (Newtonian gravity)
ax = axes[0]
N = 20
x = np.linspace(-5, 5, N)
y = np.linspace(-5, 5, N)
X, Y = np.meshgrid(x, y)

M_earth = 5.97e24  # kg
Ex, Ey = gravitoelectric_field(X, Y, 1.0)  # Normalized
E_mag = np.sqrt(Ex**2 + Ey**2)
E_mag = np.where(E_mag < 1e-10, 1e-10, E_mag)

ax.streamplot(x, y, Ex/E_mag, Ey/E_mag, color=np.log10(E_mag+1e-10), 
              cmap='Oranges_r', density=1.5, linewidth=1.5)
ax.plot(0, 0, 'ko', markersize=15)
ax.annotate('M', xy=(0, 0), fontsize=14, ha='center', va='center', color='white', fontweight='bold')
ax.set_title('Gravitoelectric Field E_g\n(= Newtonian Gravity)', fontsize=13)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_aspect('equal')

# Panel 2: Electric field analogy
ax = axes[1]
# Electric field of point charge (identical structure!)
ax.streamplot(x, y, -Ex/E_mag, -Ey/E_mag, color=np.log10(E_mag+1e-10),
              cmap='Blues_r', density=1.5, linewidth=1.5)
ax.plot(0, 0, 'ro', markersize=15)
ax.annotate('+q', xy=(0, 0), fontsize=12, ha='center', va='center', color='white', fontweight='bold')
ax.set_title('Electric Field E\n(Coulomb — identical structure!)', fontsize=13)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_aspect('equal')

# Panel 3: Gravitomagnetic field (frame dragging)
ax = axes[2]
N2 = 20
x2 = np.linspace(-5, 5, N2)
y2 = np.linspace(-5, 5, N2)
X2, Y2 = np.meshgrid(x2, y2)
Z2 = np.zeros_like(X2)

Bx, By, Bz = gravitomagnetic_field_dipole(X2, Y2, Z2 + 0.01, 1.0, 1.0, 1.0)
B_mag = np.sqrt(Bx**2 + By**2)
B_mag = np.where(B_mag < 1e-30, 1e-30, B_mag)

ax.streamplot(x2, y2, Bx/B_mag, By/B_mag, color=np.log10(B_mag + 1e-30),
              cmap='Greens_r', density=1.5, linewidth=1.5)
ax.plot(0, 0, 'ko', markersize=15)
ax.annotate('⟳M', xy=(0, 0), fontsize=11, ha='center', va='center', color='white', fontweight='bold')
ax.set_title('Gravitomagnetic Field B_g\n(Frame Dragging — from rotation)', fontsize=13)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'gem_fields.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: gem_fields.png")

# --- Figure 2: Gravitomagnetic Resonance Concept ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("Gravitoelectromagnetic Resonance (GEMR)\nProposed Amplification Mechanism", 
             fontsize=16, fontweight='bold')

# Panel 1: Resonance curve
ax = axes[0]
Q_values = [1, 10, 100, 1000]
f = np.linspace(0.01, 2, 1000)
f0 = 1.0  # Resonant frequency (normalized)

for Q in Q_values:
    response = 1.0 / np.sqrt((1 - f**2)**2 + (f/(Q))**2)
    ax.semilogy(f, response, linewidth=2, label=f'Q = {Q}')

ax.set_xlabel('Frequency / Resonant Frequency', fontsize=12)
ax.set_ylabel('Gravitomagnetic Amplification Factor', fontsize=12)
ax.set_title('GEMR Amplification vs Frequency\n'
             'Higher Q → stronger amplification at resonance', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 2)
ax.set_ylim(0.1, 1e4)

# Panel 2: Physical setup schematic
ax = axes[1]
ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')

# Rotating disc
theta = np.linspace(0, 2*np.pi, 100)
for r in [0.5, 1.0, 1.5, 2.0]:
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'b-', alpha=0.3)

# Rotation arrows
for angle in [0, np.pi/2, np.pi, 3*np.pi/2]:
    r = 1.5
    x_a = r * np.cos(angle)
    y_a = r * np.sin(angle)
    dx = -0.3 * np.sin(angle)
    dy = 0.3 * np.cos(angle)
    ax.annotate('', xy=(x_a + dx, y_a + dy), xytext=(x_a, y_a),
               arrowprops=dict(arrowstyle='->', color='blue', lw=2))

# Detector
ax.plot(0, 2.8, 'rs', markersize=15)
ax.annotate('Accelerometer\n(detector)', xy=(0, 2.8), xytext=(1.5, 2.8),
           fontsize=10, ha='left', va='center',
           arrowprops=dict(arrowstyle='->', color='red'))

# Labels
ax.annotate('Superconducting\nDisc (rotating)', xy=(0, 0), fontsize=11,
           ha='center', va='center', fontweight='bold',
           bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
ax.annotate('ω', xy=(0.8, 0.8), fontsize=16, color='blue', fontweight='bold')
ax.set_title('Proposed GEMR Experiment\nRotating superconductor + precision accelerometer', fontsize=13)
ax.axis('off')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'gemr_resonance.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: gemr_resonance.png")

# --- Figure 3: The Hierarchy Problem ---
fig, ax = plt.subplots(figsize=(12, 7))

forces = ['Strong Nuclear', 'Electromagnetic', 'Weak Nuclear', 'Gravity']
strengths = [1, 1/137, 1e-6, 6e-39]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

bars = ax.barh(forces, [np.log10(s) for s in strengths], color=colors, edgecolor='black', height=0.6)

ax.set_xlabel('log₁₀(Relative Strength)', fontsize=13)
ax.set_title('The Fundamental Forces: Why Gravity is So Hard to Engineer\n'
             'Gravity is 10³⁹ times weaker than electromagnetism', fontsize=14)

# Add value labels
for bar, strength in zip(bars, strengths):
    width = bar.get_width()
    ax.text(width - 1, bar.get_y() + bar.get_height()/2,
            f'  ~10^{int(np.log10(strength))}' if strength < 1e-2 else f'  ~{strength:.3f}',
            ha='left', va='center', fontsize=12, fontweight='bold')

ax.axvline(0, color='black', linewidth=0.5)
ax.set_xlim(-42, 2)
ax.grid(True, alpha=0.2, axis='x')

# Annotation
ax.annotate('← This gap is the\nfundamental challenge\nof gravity control',
           xy=(-20, 2.5), fontsize=12, color='purple',
           ha='center', fontweight='bold',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'hierarchy_problem.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: hierarchy_problem.png")

# --- Figure 4: Gravitomagnetic Field of Earth ---
fig, ax = plt.subplots(figsize=(10, 10))
ax.set_title("Earth's Gravitomagnetic Field (Frame Dragging)\n"
             "Confirmed by Gravity Probe B (2011)", fontsize=14, fontweight='bold')

N3 = 25
x3 = np.linspace(-4, 4, N3)
y3 = np.linspace(-4, 4, N3)
X3, Y3 = np.meshgrid(x3, y3)

# Earth parameters (normalized for visualization)
M_e = 1.0
R_e = 1.0
omega_e = 1.0

# Field in the equatorial plane (z = small offset)
Bx, By, Bz = gravitomagnetic_field_dipole(X3, Y3, np.ones_like(X3)*0.1, M_e, R_e, omega_e)
B_mag = np.sqrt(Bx**2 + By**2)
B_mag = np.where(B_mag < 1e-30, 1e-30, B_mag)

# Mask interior
mask = X3**2 + Y3**2 < R_e**2
Bx[mask] = np.nan
By[mask] = np.nan

ax.streamplot(x3, y3, Bx, By, color='green', density=2, linewidth=1.5, arrowsize=1.5)

# Draw Earth
theta = np.linspace(0, 2*np.pi, 100)
ax.fill(R_e*np.cos(theta), R_e*np.sin(theta), color='royalblue', alpha=0.6)
ax.plot(R_e*np.cos(theta), R_e*np.sin(theta), 'k-', linewidth=2)

# Rotation arrow
ax.annotate('', xy=(0, 1.8), xytext=(0.5, 1.5),
           arrowprops=dict(arrowstyle='->', color='red', lw=2,
                          connectionstyle='arc3,rad=0.3'))
ax.text(0.7, 1.7, 'ω', fontsize=16, color='red', fontweight='bold')

ax.set_xlabel('x (Earth radii)', fontsize=12)
ax.set_ylabel('y (Earth radii)', fontsize=12)
ax.set_aspect('equal')
ax.set_xlim(-4, 4)
ax.set_ylim(-4, 4)

# Info box
info = ("Earth's gravitomagnetic field:\n"
        "B_g ≈ 10⁻¹⁴ s⁻¹\n\n"
        "Measured by GP-B to 19% precision\n"
        "Causes gyroscope precession of\n"
        "39.2 milliarcseconds/year")
ax.text(0.02, 0.98, info, transform=ax.transAxes, fontsize=11,
       verticalalignment='top', bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'earth_gravitomagnetic.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: earth_gravitomagnetic.png")

print("\n🌌 All GEM visualizations complete!")
print("Key insight: Gravity has an electromagnetic twin — gravitomagnetism.")
print("Engineering this twin could be the key to gravitational technology.")
