#!/usr/bin/env python3
"""
Floating Car & Levitation Technology Simulator
===============================================

Compares different approaches to macroscopic levitation:
1. Electromagnetic (maglev) - current technology
2. Diamagnetic levitation - demonstrated in labs
3. Gravitomagnetic levitation - theoretical
4. Casimir-based gravity reduction - speculative
5. Warp-based inertial cancellation - far future

Simulates the dynamics and energy requirements of each approach.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.patches import FancyBboxPatch, Circle
import os

output_dir = os.path.dirname(os.path.abspath(__file__))

# Physical constants
G = 6.674e-11
c = 3e8
g = 9.81  # m/s²
mu0 = 4 * np.pi * 1e-7  # T·m/A

# Car parameters
M_car = 1500  # kg
W_car = M_car * g  # Weight in Newtons

# ============================================================
# Levitation Technologies Analysis
# ============================================================

class LevitationTech:
    """Analyze different levitation technologies."""
    
    @staticmethod
    def maglev_requirements():
        """Electromagnetic levitation (current technology)."""
        # F = B²A/(2μ₀) for magnetic pressure
        B_needed = np.sqrt(2 * mu0 * W_car / 2.0)  # 2 m² area
        I_coil = B_needed / (mu0 * 1000)  # 1000 turns/m solenoid
        P_resistive = I_coil**2 * 0.01  # 10 mΩ resistance
        P_superconducting = 500  # W (just for cooling)
        
        return {
            'name': 'Electromagnetic (Maglev)',
            'B_field': B_needed,
            'power_normal': P_resistive,
            'power_sc': P_superconducting,
            'feasibility': 'Current Technology',
            'status': '✅ Operational (Shanghai, Japan)',
            'gap': 0.01,  # 1 cm levitation gap
        }
    
    @staticmethod
    def diamagnetic_requirements():
        """Diamagnetic levitation (demonstrated for small objects)."""
        # χ_dia ~ -10⁻⁵ for most materials
        chi = -1e-5
        # F = χ V B (dB/dz) / μ₀
        # To levitate: ρg = χ B(dB/dz) / μ₀
        # Need B ~ 16 T for water (demonstrated by Geim)
        B_needed = np.sqrt(g * 1000 * mu0 / abs(chi))  # For water density
        
        return {
            'name': 'Diamagnetic Levitation',
            'B_field': B_needed,
            'power': 1e6,  # ~1 MW for 16T magnet
            'feasibility': 'Lab Demonstration',
            'status': '🔬 Frogs levitated (Geim, 2000)',
            'max_mass': 0.01,  # ~10g practical limit
        }
    
    @staticmethod
    def gravitomagnetic_requirements():
        """Gravitomagnetic (frame-dragging) levitation."""
        # F_gm = m(v × B_g)
        # Need B_g = g/v for levitation
        v = 100  # m/s (car velocity)
        Bg_needed = g / v  # s⁻¹
        Bg_earth = 1e-14  # s⁻¹
        amplification = Bg_needed / Bg_earth
        
        # Mass required for artificial B_g field
        # B_g ~ GM/(c²R²)
        R = 1  # m
        M_needed = Bg_needed * c**2 * R**2 / G
        
        return {
            'name': 'Gravitomagnetic Levitation',
            'Bg_needed': Bg_needed,
            'amplification_over_earth': amplification,
            'M_source': M_needed,
            'feasibility': 'Theoretical Only',
            'status': '❌ Requires ~10²⁸ kg source mass',
        }
    
    @staticmethod
    def casimir_requirements():
        """Casimir-based gravity reduction."""
        hbar = 1.055e-34
        a = 50e-9  # 50 nm cavity spacing
        
        u_casimir = -np.pi**2 * hbar * c / (720 * a**4)
        # Mass equivalent per cavity
        V_cavity = a * (100e-9)**2  # tiny cavity
        dm_per_cavity = u_casimir * V_cavity / c**2
        
        # Number of cavities to cancel car's weight
        # Need dm_total * g = M_car * g → dm_total = M_car
        N_needed = M_car / abs(dm_per_cavity)
        
        return {
            'name': 'Casimir Gravity Reduction',
            'energy_density': u_casimir,
            'N_cavities_for_levitation': N_needed,
            'feasibility': 'Speculative',
            'status': f'❌ Needs ~10^{int(np.log10(N_needed))} cavities',
        }

# ============================================================
# Plotting
# ============================================================

# --- Figure 1: Technology Comparison Dashboard ---
fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("Floating Car Technology Assessment\n"
             f"Target: Levitate {M_car} kg car against Earth's gravity",
             fontsize=16, fontweight='bold')

tech = LevitationTech()
maglev = tech.maglev_requirements()
diamag = tech.diamagnetic_requirements()
gravmag = tech.gravitomagnetic_requirements()
casimir = tech.casimir_requirements()

# Panel 1: Force requirements comparison
ax = axes[0, 0]
methods = ['Maglev\n(Current)', 'Diamagnetic\n(Lab Demo)', 'Gravitomagnetic\n(Theoretical)', 
           'Casimir\n(Speculative)', 'Warp Bubble\n(Far Future)']
forces_available = [W_car, 0.1, 1e-10, 1e-20, W_car]  # N achievable
forces_needed = [W_car] * 5

x_pos = np.arange(len(methods))
width = 0.35

bars1 = ax.bar(x_pos - width/2, [np.log10(max(f, 1e-30)) for f in forces_needed], 
               width, label='Force Needed (N)', color='red', alpha=0.7)
bars2 = ax.bar(x_pos + width/2, [np.log10(max(f, 1e-30)) for f in forces_available],
               width, label='Force Available (N)', color='green', alpha=0.7)

ax.set_ylabel('log₁₀(Force) [Newtons]', fontsize=12)
ax.set_title('Force: Required vs Available', fontsize=13)
ax.set_xticks(x_pos)
ax.set_xticklabels(methods, fontsize=9)
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Energy/Power requirements
ax = axes[0, 1]
powers = [500, 1e6, 1e30, 1e50, 1e62]  # Watts
labels = methods
colors = ['green', 'yellow', 'orange', 'red', 'darkred']

bars = ax.barh(range(len(powers)), [np.log10(p) for p in powers], 
               color=colors, edgecolor='black', height=0.6)
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=10)
ax.set_xlabel('log₁₀(Power Required) [Watts]', fontsize=12)
ax.set_title('Power Requirements', fontsize=13)

# Reference lines
refs = [(np.log10(1e9), 'Nuclear plant'), (np.log10(3.8e26), 'Sun\'s luminosity')]
for val, label in refs:
    ax.axvline(val, color='blue', linestyle=':', alpha=0.5)
    ax.text(val+0.5, 4, label, fontsize=8, color='blue', rotation=90, va='top')

ax.grid(True, alpha=0.3, axis='x')

# Panel 3: Timeline / Feasibility
ax = axes[1, 0]
techs = ['Maglev Train', 'Diamagnetic\n(small objects)', 'Superconducting\nLevitation',
         'Casimir Force\nMeasurement', 'Frame Dragging\nDetection (GP-B)',
         'GEMR Test\n(proposed)', 'Casimir-Gravity\nCoupling Test',
         'Gravitational\nMetamaterial',
         'Gravity Reduction\nDevice', 'Floating Car']
years = [1984, 2000, 1990, 1997, 2011, 2030, 2040, 2060, 2100, 2200]
achieved = [True, True, True, True, True, False, False, False, False, False]

colors_tl = ['green' if a else 'red' for a in achieved]
ax.barh(range(len(techs)), years, color=colors_tl, alpha=0.7, edgecolor='black', height=0.7)
ax.set_yticks(range(len(techs)))
ax.set_yticklabels(techs, fontsize=9)
ax.set_xlabel('Year', fontsize=12)
ax.set_title('Technology Timeline\n(Green = Achieved, Red = Projected)', fontsize=13)
ax.axvline(2024, color='blue', linewidth=2, linestyle='--', label='Now (2024)')
ax.legend(fontsize=11)
ax.set_xlim(1980, 2250)
ax.grid(True, alpha=0.3, axis='x')

# Panel 4: Conceptual floating car schematic
ax = axes[1, 1]
ax.set_xlim(-5, 5)
ax.set_ylim(-2, 6)
ax.set_aspect('equal')

# Ground
ax.fill_between([-5, 5], -2, 0, color='#8B7355', alpha=0.3)
ax.plot([-5, 5], [0, 0], 'k-', linewidth=2)
ax.text(0, -1, 'GROUND', ha='center', fontsize=12, color='brown')

# Car body
car = FancyBboxPatch((-2, 2.5), 4, 1.5, boxstyle="round,pad=0.2",
                      facecolor='#3498db', edgecolor='black', linewidth=2)
ax.add_patch(car)
ax.text(0, 3.25, '1500 kg', ha='center', va='center', fontsize=14, 
       fontweight='bold', color='white')

# Levitation field lines
for i in range(5):
    x_line = -1.5 + i * 0.75
    y_vals = np.linspace(0.2, 2.3, 50)
    wave = 0.15 * np.sin(8 * y_vals + i)
    ax.plot(x_line + wave, y_vals, 'c-', alpha=0.5, linewidth=1.5)

# Force arrows
ax.annotate('', xy=(0, 4.5), xytext=(0, 3.9),
           arrowprops=dict(arrowstyle='->', color='green', lw=3))
ax.text(0.3, 4.2, 'F_levitation', fontsize=11, color='green', fontweight='bold')

ax.annotate('', xy=(0, 2.0), xytext=(0, 2.6),
           arrowprops=dict(arrowstyle='->', color='red', lw=3))
ax.text(0.3, 2.0, 'mg = 14,700 N', fontsize=11, color='red', fontweight='bold')

# Gap label
ax.annotate('', xy=(-2.5, 0), xytext=(-2.5, 2.5),
           arrowprops=dict(arrowstyle='<->', color='purple', lw=2))
ax.text(-3.5, 1.25, 'Levitation\nGap', fontsize=10, color='purple', 
       ha='center', fontweight='bold')

ax.set_title('The Dream: A Floating Car', fontsize=14)
ax.axis('off')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'floating_car_analysis.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: floating_car_analysis.png")

# --- Figure 2: Maglev Physics (the one that works!) ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("Electromagnetic Levitation: The Technology That Works Today", 
             fontsize=16, fontweight='bold')

# Panel 1: Maglev force vs gap distance
ax = axes[0]
gaps = np.linspace(0.001, 0.1, 1000)
# Magnetic pressure: P = B²/(2μ₀)
# For a superconducting magnet, B ~ B₀(d₀/d) approximately
B0 = 2.0  # Tesla at reference distance
d0 = 0.01  # 1 cm reference
B = B0 * (d0 / gaps)
F_mag = B**2 / (2 * mu0) * 2.0  # 2 m² area, total force

ax.semilogy(gaps * 100, F_mag, 'b-', linewidth=2, label='Magnetic levitation force')
ax.axhline(W_car, color='red', linestyle='--', linewidth=2, label=f'Car weight ({W_car:.0f} N)')
ax.set_xlabel('Gap Distance (cm)', fontsize=12)
ax.set_ylabel('Levitation Force (N)', fontsize=12)
ax.set_title('Maglev Force vs Gap\n(Superconducting, 2T field)', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 10)

# Find equilibrium gap
eq_idx = np.argmin(np.abs(F_mag - W_car))
eq_gap = gaps[eq_idx]
ax.axvline(eq_gap * 100, color='green', linestyle=':', alpha=0.5)
ax.annotate(f'Equilibrium: {eq_gap*100:.1f} cm', 
           xy=(eq_gap*100, W_car), fontsize=11, color='green',
           xytext=(eq_gap*100 + 2, W_car * 10),
           arrowprops=dict(arrowstyle='->', color='green'))

# Panel 2: Levitation dynamics simulation
ax = axes[1]
dt = 0.001
t_max = 5.0
t = np.arange(0, t_max, dt)
z = np.zeros_like(t)
v = np.zeros_like(t)
z[0] = 0.03  # Start at 3 cm
v[0] = 0

# Simple dynamics: F = -kz_eff + noise (linearized near equilibrium)
z_eq = eq_gap
k_eff = 2 * W_car / z_eq  # Effective spring constant
damping = 50  # Damping coefficient

for i in range(len(t) - 1):
    dz = z[i] - z_eq
    F_net = -k_eff * dz - damping * v[i] + 0.5 * np.sin(2 * np.pi * 3 * t[i])  # + perturbation
    a = F_net / M_car
    v[i+1] = v[i] + a * dt
    z[i+1] = z[i] + v[i+1] * dt
    z[i+1] = max(z[i+1], 0.001)  # Can't go through ground

ax.plot(t, z * 100, 'b-', linewidth=1.5)
ax.axhline(z_eq * 100, color='red', linestyle='--', alpha=0.5, label=f'Equilibrium ({z_eq*100:.1f} cm)')
ax.set_xlabel('Time (s)', fontsize=12)
ax.set_ylabel('Height (cm)', fontsize=12)
ax.set_title('Maglev Dynamics Simulation\n(Perturbed levitation + damping)', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'maglev_physics.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: maglev_physics.png")

# --- Figure 3: Technology Readiness Assessment ---
fig, ax = plt.subplots(figsize=(14, 8))

categories = [
    'Electromagnetic\nLevitation (Maglev)',
    'Superconducting\nLevitation (Flux Pinning)',
    'Diamagnetic\nLevitation',
    'Acoustic\nLevitation',
    'Electrostatic\nLevitation',
    'Optical Trapping\n(Laser Tweezers)',
    'Gravitomagnetic\n(Frame Dragging)',
    'Casimir-Based\nGravity Modification',
    'Warp Field\nLevitation',
    'Antigravity\n(Unknown Physics)'
]

TRL = [9, 7, 4, 5, 3, 6, 1, 1, 1, 0]  # Technology Readiness Level
max_mass = [500000, 1000, 0.01, 0.001, 0.0001, 1e-12, 0, 0, 0, 0]  # kg
colors_trl = plt.cm.RdYlGn(np.array(TRL) / 9.0)

bars = ax.barh(range(len(categories)), TRL, color=colors_trl, edgecolor='black', height=0.7)

ax.set_yticks(range(len(categories)))
ax.set_yticklabels(categories, fontsize=10)
ax.set_xlabel('Technology Readiness Level (TRL)', fontsize=13)
ax.set_title('Levitation Technology Readiness Assessment\n'
             'TRL 1 = Basic Research → TRL 9 = Operational System', fontsize=14)

# TRL labels
for i, (bar, trl, mass) in enumerate(zip(bars, TRL, max_mass)):
    mass_str = f'{mass:.0f} kg' if mass >= 1 else (f'{mass*1000:.0f} g' if mass >= 0.001 else 
               (f'{mass*1e6:.0f} μg' if mass > 0 else 'N/A'))
    ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
            f'TRL {trl} | Max mass: {mass_str}', va='center', fontsize=10)

ax.set_xlim(0, 12)
ax.grid(True, alpha=0.3, axis='x')

# TRL legend
trl_desc = {
    0: 'Unproven concept',
    1: 'Basic research',
    3: 'Proof of concept',
    5: 'Component validation',
    7: 'Prototype demo',
    9: 'Operational system'
}
legend_text = '\n'.join([f'TRL {k}: {v}' for k, v in trl_desc.items()])
ax.text(0.98, 0.02, legend_text, transform=ax.transAxes, fontsize=9,
       verticalalignment='bottom', horizontalalignment='right',
       bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'tech_readiness.png'), dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: tech_readiness.png")

print("\n🚗 All floating car simulations complete!")
print("Key insight: Electromagnetic levitation works today for heavy objects.")
print("Gravitational levitation requires breakthroughs we cannot yet predict.")
