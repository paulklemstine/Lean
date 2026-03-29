#!/usr/bin/env python3
"""
Demo 1: The Impedance Field — Algebra of AC Circuits
=====================================================

This demo visualizes the algebraic structure of impedances in AC circuits.
Impedances are complex numbers; series = addition, parallel = harmonic addition.
We show that these operations satisfy field axioms and visualize the geometry
of circuit combinations in the complex plane.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.gridspec import GridSpec

# ─── Configuration ───
plt.rcParams.update({
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0e0',
    'axes.labelcolor': '#e0e0e0',
    'xtick.color': '#888888',
    'ytick.color': '#888888',
    'axes.edgecolor': '#333333',
    'font.family': 'monospace',
    'font.size': 10,
})

GOLD = '#FFD700'
CYAN = '#00FFFF'
MAGENTA = '#FF00FF'
LIME = '#00FF88'
ORANGE = '#FF8800'
WHITE = '#FFFFFF'

# ─── Algebraic Operations ───

def series(z1, z2):
    """Series combination: Z = Z₁ + Z₂ (field addition)"""
    return z1 + z2

def parallel(z1, z2):
    """Parallel combination: Z = (Z₁⁻¹ + Z₂⁻¹)⁻¹ (harmonic addition)"""
    if z1 == 0 or z2 == 0:
        return 0
    return (z1 * z2) / (z1 + z2)

def impedance_R(R):
    """Resistor impedance (real)"""
    return complex(R, 0)

def impedance_C(C, omega):
    """Capacitor impedance (negative imaginary)"""
    return complex(0, -1.0 / (omega * C))

def impedance_L(L, omega):
    """Inductor impedance (positive imaginary)"""
    return complex(0, omega * L)

# ─── Demo 1a: Impedance Space Geometry ───

fig = plt.figure(figsize=(20, 16))
fig.suptitle('THE IMPEDANCE FIELD — Algebraic Theory of Electricity',
             fontsize=18, color=GOLD, fontweight='bold', y=0.98)
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: RLC components in the complex plane
ax1 = fig.add_subplot(gs[0, 0])
omega = 2 * np.pi * 60  # 60 Hz

components = [
    ('R = 100Ω', impedance_R(100), GOLD, 's'),
    ('R = 50Ω',  impedance_R(50),  GOLD, 's'),
    ('C = 10μF', impedance_C(10e-6, omega), CYAN, '^'),
    ('C = 100μF', impedance_C(100e-6, omega), CYAN, '^'),
    ('L = 0.1H', impedance_L(0.1, omega), MAGENTA, 'v'),
    ('L = 0.5H', impedance_L(0.5, omega), MAGENTA, 'v'),
]

for label, z, color, marker in components:
    ax1.plot(z.real, z.imag, marker=marker, markersize=12, color=color,
             markeredgecolor=WHITE, markeredgewidth=0.5, zorder=5)
    ax1.annotate(label, (z.real, z.imag), textcoords="offset points",
                xytext=(10, 5), fontsize=8, color=color)

# Draw axes
ax1.axhline(y=0, color='#444444', linewidth=0.5, linestyle='--')
ax1.axvline(x=0, color='#444444', linewidth=0.5, linestyle='--')
ax1.set_xlabel('Re(Z) — Resistance [Ω]')
ax1.set_ylabel('Im(Z) — Reactance [Ω]')
ax1.set_title('Impedance Space ℂ', color=CYAN, fontsize=13)
ax1.annotate('Inductive\n(Im > 0)', xy=(0.02, 0.95), xycoords='axes fraction',
            fontsize=8, color=MAGENTA, va='top')
ax1.annotate('Capacitive\n(Im < 0)', xy=(0.02, 0.05), xycoords='axes fraction',
            fontsize=8, color=CYAN, va='bottom')
ax1.set_xlim(-20, 220)

# Panel 2: Series operation (vector addition in ℂ)
ax2 = fig.add_subplot(gs[0, 1])

Z_R = impedance_R(80)
Z_L = impedance_L(0.2, omega)
Z_C = impedance_C(50e-6, omega)
Z_series = series(series(Z_R, Z_L), Z_C)

# Draw vectors
origin = [0, 0]
ax2.annotate('', xy=(Z_R.real, Z_R.imag), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color=GOLD, lw=2))
ax2.annotate('', xy=(Z_R.real + Z_L.real, Z_R.imag + Z_L.imag),
            xytext=(Z_R.real, Z_R.imag),
            arrowprops=dict(arrowstyle='->', color=MAGENTA, lw=2))
ax2.annotate('', xy=(Z_series.real, Z_series.imag),
            xytext=(Z_R.real + Z_L.real, Z_R.imag + Z_L.imag),
            arrowprops=dict(arrowstyle='->', color=CYAN, lw=2))
ax2.annotate('', xy=(Z_series.real, Z_series.imag), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color=LIME, lw=3))

ax2.plot(Z_series.real, Z_series.imag, 'o', markersize=10, color=LIME, zorder=5)
ax2.text(40, 5, 'R', color=GOLD, fontsize=12, fontweight='bold')
ax2.text(82, 40, 'L', color=MAGENTA, fontsize=12, fontweight='bold')
ax2.text(85, -10, 'C', color=CYAN, fontsize=12, fontweight='bold')
ax2.text(Z_series.real + 3, Z_series.imag + 3, f'Z = {Z_series:.1f}',
        color=LIME, fontsize=9)

ax2.axhline(y=0, color='#444444', linewidth=0.5, linestyle='--')
ax2.axvline(x=0, color='#444444', linewidth=0.5, linestyle='--')
ax2.set_xlabel('Re(Z) [Ω]')
ax2.set_ylabel('Im(Z) [Ω]')
ax2.set_title('Series = Addition in ℂ\nZ_total = Z_R + Z_L + Z_C',
             color=GOLD, fontsize=12)
ax2.set_aspect('equal')

# Panel 3: Parallel operation geometry
ax3 = fig.add_subplot(gs[0, 2])

Z1 = complex(100, 50)
Z2_range = np.linspace(10, 500, 200) + 1j * np.linspace(-100, 100, 200)

# Show how parallel combination maps impedance space
Z2_grid_r = np.linspace(10, 300, 50)
Z2_grid_i = np.linspace(-200, 200, 50)
R, X = np.meshgrid(Z2_grid_r, Z2_grid_i)
Z2_grid = R + 1j * X
Z_par = (Z1 * Z2_grid) / (Z1 + Z2_grid)

ax3.scatter(Z_par.real.flatten(), Z_par.imag.flatten(), s=1, c=np.abs(Z2_grid).flatten(),
           cmap='plasma', alpha=0.5, zorder=1)
ax3.plot(Z1.real, Z1.imag, '*', markersize=15, color=GOLD, zorder=5,
        markeredgecolor=WHITE, markeredgewidth=1)
ax3.annotate(f'Z₁ = {Z1}', (Z1.real, Z1.imag), textcoords="offset points",
            xytext=(10, 10), fontsize=9, color=GOLD)

ax3.axhline(y=0, color='#444444', linewidth=0.5, linestyle='--')
ax3.axvline(x=0, color='#444444', linewidth=0.5, linestyle='--')
ax3.set_xlabel('Re(Z) [Ω]')
ax3.set_ylabel('Im(Z) [Ω]')
ax3.set_title('Parallel: Z₁ ‖ Z₂ = (Z₁⁻¹+Z₂⁻¹)⁻¹\nMöbius transformation on ℂ',
             color=MAGENTA, fontsize=12)
ax3.set_xlim(-20, 150)
ax3.set_ylim(-100, 100)

# Panel 4: Field axiom verification
ax4 = fig.add_subplot(gs[1, 0])
ax4.axis('off')

axioms_text = """
╔══════════════════════════════════════════╗
║   FIELD AXIOMS FOR IMPEDANCE ALGEBRA    ║
╠══════════════════════════════════════════╣
║                                          ║
║  (ℂ, +, ·) is a field:                  ║
║                                          ║
║  ✓ Closure:     Z₁ + Z₂ ∈ ℂ            ║
║  ✓ Associative: (Z₁+Z₂)+Z₃ = Z₁+(Z₂+Z₃)║
║  ✓ Identity:    Z + 0 = Z   (short)     ║
║  ✓ Inverse:     Z + (-Z) = 0            ║
║  ✓ Commutative: Z₁ + Z₂ = Z₂ + Z₁      ║
║                                          ║
║  ✓ Mult closure:  Z₁·Z₂ ∈ ℂ            ║
║  ✓ Mult assoc:    (Z₁·Z₂)·Z₃ = Z₁·(Z₂·Z₃)║
║  ✓ Mult identity: Z · 1 = Z  (wire)     ║
║  ✓ Mult inverse:  Z · Z⁻¹ = 1           ║
║  ✓ Distributive:  Z₁(Z₂+Z₃) = Z₁Z₂+Z₁Z₃║
║                                          ║
║  DERIVED: Z₁ ‖ Z₂ = (Z₁⁻¹ + Z₂⁻¹)⁻¹   ║
║  (Parallel is harmonic addition)         ║
╚══════════════════════════════════════════╝
"""
ax4.text(0.05, 0.95, axioms_text, transform=ax4.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=LIME,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=LIME, alpha=0.8))

# Panel 5: Frequency response — algebra in action
ax5 = fig.add_subplot(gs[1, 1])

freqs = np.logspace(0, 6, 1000)  # 1 Hz to 1 MHz
omegas = 2 * np.pi * freqs

R_val = 1000  # 1 kΩ
L_val = 0.1   # 100 mH
C_val = 1e-6  # 1 μF

# RLC series circuit transfer function
Z_total = R_val + 1j * omegas * L_val + 1/(1j * omegas * C_val)
H = R_val / Z_total  # voltage across R

magnitude_dB = 20 * np.log10(np.abs(H))
phase_deg = np.angle(H, deg=True)

# Resonant frequency
f_res = 1 / (2 * np.pi * np.sqrt(L_val * C_val))

ax5.semilogx(freqs, magnitude_dB, color=CYAN, linewidth=2, label='|H(f)| [dB]')
ax5.axvline(x=f_res, color=GOLD, linewidth=1, linestyle='--', alpha=0.7)
ax5.annotate(f'f₀ = {f_res:.0f} Hz\n(resonance)',
            xy=(f_res, 0), xytext=(f_res * 5, -15),
            arrowprops=dict(arrowstyle='->', color=GOLD), color=GOLD, fontsize=9)

ax5.set_xlabel('Frequency [Hz]')
ax5.set_ylabel('Magnitude [dB]')
ax5.set_title('RLC Bandpass: Algebra → Physics\nH(ω) = R / (R + jωL + 1/jωC)',
             color=CYAN, fontsize=12)
ax5.set_ylim(-40, 5)
ax5.grid(True, alpha=0.2, color='#444444')
ax5.legend(loc='lower left', fontsize=9)

# Panel 6: The algebraic hierarchy
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

hierarchy = """
╔══════════════════════════════════════════╗
║     THE ALGEBRAIC HIERARCHY              ║
║     OF ELECTRICITY                       ║
╠══════════════════════════════════════════╣
║                                          ║
║  Level 5: Cl(1,3) — Spacetime Algebra    ║
║     │     Full relativistic EM           ║
║     │     ∇F = J/ε₀                      ║
║     │                                    ║
║  Level 4: Cl(3,0) — Geometric Algebra    ║
║     │     Spatial EM, rotations          ║
║     │     F = E + IB                     ║
║     │                                    ║
║  Level 3: ℍ — Quaternions                ║
║     │     3D rotations of fields         ║
║     │                                    ║
║  Level 2: ℂ — Complex Numbers            ║
║     │     AC phasors, impedance          ║
║     │     Z = R + jX                     ║
║     │                                    ║
║  Level 1: ℝ — Real Numbers               ║
║           DC circuits, Ohm's law         ║
║           V = IR                         ║
╚══════════════════════════════════════════╝
"""
ax6.text(0.05, 0.95, hierarchy, transform=ax6.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=ORANGE,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=ORANGE, alpha=0.8))

plt.savefig('/workspace/request-project/Electricity/demos/fig1_impedance_field.png',
           dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()

print("✅ Demo 1: Impedance Field visualization saved.")
print(f"   Resonant frequency: {f_res:.1f} Hz")
print(f"   Series RLC at resonance: Z = {R_val} + j({omegas[500]*L_val:.1f} - {1/(omegas[500]*C_val):.1f}) Ω")
