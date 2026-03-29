#!/usr/bin/env python3
"""
DEMO 2: Sonoluminescence-Pumped Emission Simulation
=====================================================
Models the spectral and temporal dynamics of sonoluminescent bubble collapse
and its potential to pump a gain medium.

Physics: An ultrasonic standing wave creates a cavitating bubble in liquid.
The bubble collapses violently, reaching >10,000 K for ~100 ps, emitting
broadband UV-visible light. If the liquid is doped with laser dye, this
flash can create population inversion.

Run: python demo2_sonoluminescence_spectrum.py
Outputs: sonoluminescence_pump.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ─── Physical Model ───────────────────────────────────────────────

def rayleigh_plesset_simplified(t, R0=5e-6, P_acoustic=1.3e5, f=25e3,
                                  P0=1.01e5, rho=998, sigma=0.0728, gamma=5/3):
    """
    Simplified Rayleigh-Plesset bubble dynamics.
    Returns bubble radius R(t) and velocity dR/dt.
    
    Simplified to avoid stiff ODE — uses analytic approximation
    for the collapse phase.
    """
    omega = 2 * np.pi * f
    period = 1 / f
    
    # Expansion phase (acoustic rarefaction)
    R_max = R0 * (P_acoustic / P0) ** (1/3) * 5  # max expansion ~5x
    
    # Model: smooth expansion then rapid collapse
    t_norm = (t % period) / period  # normalized to [0, 1]
    
    # Expansion: slow sinusoidal growth (0 to 0.7 of cycle)
    # Collapse: rapid implosion (0.7 to 0.75 of cycle)
    # Rebound: small bounce (0.75 to 1.0 of cycle)
    
    R = np.zeros_like(t_norm)
    
    expand = t_norm < 0.7
    collapse = (t_norm >= 0.7) & (t_norm < 0.75)
    rebound = t_norm >= 0.75
    
    R[expand] = R0 + (R_max - R0) * np.sin(np.pi * t_norm[expand] / 1.4) ** 2
    
    collapse_frac = (t_norm[collapse] - 0.7) / 0.05
    R[collapse] = R_max * (1 - collapse_frac) ** 3 + R0 * 0.1
    
    rebound_frac = (t_norm[rebound] - 0.75) / 0.25
    R[rebound] = R0 * (0.1 + 0.9 * (1 - np.exp(-5 * rebound_frac)))
    
    return R


def blackbody_spectrum(wavelengths_nm, T):
    """Planck blackbody spectral radiance B(λ, T)."""
    h = 6.626e-34
    c = 3e8
    k = 1.381e-23
    lam = wavelengths_nm * 1e-9  # convert to meters
    
    with np.errstate(over='ignore', divide='ignore'):
        B = (2 * h * c**2 / lam**5) / (np.exp(h * c / (lam * k * T)) - 1)
    
    return B


def dye_absorption(wavelengths_nm, center=530, width=30):
    """Rhodamine 6G absorption spectrum (simplified Gaussian)."""
    return np.exp(-0.5 * ((wavelengths_nm - center) / width)**2)


def dye_emission(wavelengths_nm, center=580, width=20):
    """Rhodamine 6G emission spectrum (simplified Gaussian)."""
    return np.exp(-0.5 * ((wavelengths_nm - center) / width)**2)


# ─── Simulation ────────────────────────────────────────────────────

# Time axis: two acoustic cycles
f_acoustic = 25e3  # 25 kHz ultrasonic
period = 1 / f_acoustic
t = np.linspace(0, 2 * period, 10000)

# Bubble dynamics
R = rayleigh_plesset_simplified(t, f=f_acoustic)

# Temperature during collapse (peaks when R is minimum)
R0 = 5e-6
T_ambient = 300  # K
# Adiabatic heating: T ∝ (R0/R)^(3(γ-1)) where γ = 5/3
gamma = 5.0 / 3.0
T = T_ambient * (R0 / np.maximum(R, R0 * 0.01)) ** (3 * (gamma - 1))
T = np.minimum(T, 30000)  # cap at 30,000 K

# Light emission: proportional to T^4 * surface_area
light_emission = (T / 1000)**4 * (R / R0)**2
light_emission = light_emission / np.max(light_emission)

# Spectra at different temperatures
wavelengths = np.linspace(200, 800, 1000)

# ─── Visualization ─────────────────────────────────────────────────

fig = plt.figure(figsize=(18, 14))
gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)
fig.suptitle("Sonoluminescence-Pumped Laser: From Sound to Light",
             fontsize=18, fontweight='bold', y=0.98)

# ── Panel 1: Bubble radius dynamics ──
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(t * 1e6, R * 1e6, color='dodgerblue', linewidth=2)
ax1.fill_between(t * 1e6, 0, R * 1e6, alpha=0.15, color='dodgerblue')
ax1.set_xlabel('Time (μs)', fontsize=11)
ax1.set_ylabel('Bubble Radius (μm)', fontsize=11)
ax1.set_title('Bubble Radius vs Time\n(Rayleigh-Plesset Dynamics)', fontsize=12)
ax1.set_ylim(0, None)

# ── Panel 2: Temperature during collapse ──
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(t * 1e6, T, color='orangered', linewidth=2)
ax2.fill_between(t * 1e6, T_ambient, T, alpha=0.15, color='orangered')
ax2.set_xlabel('Time (μs)', fontsize=11)
ax2.set_ylabel('Temperature (K)', fontsize=11)
ax2.set_title('Bubble Core Temperature\n(Adiabatic Compression)', fontsize=12)
ax2.set_yscale('log')
ax2.axhline(10000, color='gold', linestyle='--', alpha=0.7, label='10,000 K')
ax2.legend()

# ── Panel 3: Light emission pulse ──
ax3 = fig.add_subplot(gs[1, 0])
ax3.plot(t * 1e6, light_emission, color='gold', linewidth=2)
ax3.fill_between(t * 1e6, 0, light_emission, alpha=0.3, color='gold')
ax3.set_xlabel('Time (μs)', fontsize=11)
ax3.set_ylabel('Light Intensity (arb.)', fontsize=11)
ax3.set_title('Sonoluminescent Flash\n(~100 ps duration at peak)', fontsize=12)

# ── Panel 4: Spectral overlap ──
ax4 = fig.add_subplot(gs[1, 1])

# Sonoluminescence spectrum at peak temperature
SL_spectrum = blackbody_spectrum(wavelengths, 15000)
SL_spectrum = SL_spectrum / np.max(SL_spectrum)

# Dye absorption and emission
abs_spectrum = dye_absorption(wavelengths)
em_spectrum = dye_emission(wavelengths)

ax4.fill_between(wavelengths, SL_spectrum, alpha=0.2, color='purple',
                 label='SL emission (T≈15000K)')
ax4.plot(wavelengths, SL_spectrum, color='purple', linewidth=2)
ax4.fill_between(wavelengths, abs_spectrum * 0.8, alpha=0.3, color='green',
                 label='Dye absorption (Rh6G)')
ax4.plot(wavelengths, abs_spectrum * 0.8, color='green', linewidth=2)
ax4.fill_between(wavelengths, em_spectrum * 0.6, alpha=0.3, color='orange',
                 label='Dye emission (Rh6G)')
ax4.plot(wavelengths, em_spectrum * 0.6, color='orange', linewidth=2)

# Shade overlap region
overlap = np.minimum(SL_spectrum, abs_spectrum * 0.8)
ax4.fill_between(wavelengths, overlap, alpha=0.5, color='red',
                 label='Pump-absorption overlap')

ax4.set_xlabel('Wavelength (nm)', fontsize=11)
ax4.set_ylabel('Normalized Intensity', fontsize=11)
ax4.set_title('Spectral Overlap: SL Pump → Dye Gain', fontsize=12)
ax4.legend(fontsize=9, loc='upper right')
ax4.set_xlim(200, 800)

# ── Panel 5: Energy level diagram ──
ax5 = fig.add_subplot(gs[2, 0])
ax5.set_xlim(0, 10)
ax5.set_ylim(0, 10)

# Ground state
ax5.plot([1, 3], [1, 1], 'k-', linewidth=3)
ax5.text(2, 0.5, 'S₀ (Ground)', ha='center', fontsize=11)

# Excited singlet
ax5.plot([1, 3], [7, 7], 'b-', linewidth=3)
ax5.text(2, 7.3, 'S₁ (Excited)', ha='center', fontsize=11, color='blue')

# Pump transition (SL flash)
ax5.annotate('', xy=(2, 6.8), xytext=(2, 1.2),
            arrowprops=dict(arrowstyle='->', color='purple', lw=2.5))
ax5.text(0.3, 4, 'SL Pump\n(broadband\n UV-vis)', fontsize=10,
         color='purple', ha='center')

# Lasing level
ax5.plot([5, 7], [6, 6], 'r-', linewidth=3)
ax5.text(6, 6.3, 'Upper lasing level', ha='center', fontsize=10, color='red')

# Lower lasing level
ax5.plot([5, 7], [3, 3], 'r-', linewidth=3)
ax5.text(6, 2.5, 'Lower lasing level', ha='center', fontsize=10, color='red')

# Vibrational relaxation
ax5.annotate('', xy=(5.2, 6.1), xytext=(3, 6.9),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, ls='--'))
ax5.text(4, 7.5, 'Fast relaxation', fontsize=9, color='gray', ha='center')

# Stimulated emission
ax5.annotate('', xy=(6, 3.2), xytext=(6, 5.8),
            arrowprops=dict(arrowstyle='->', color='orange', lw=2.5))
ax5.text(7.5, 4.5, 'LASER\nemission\n580 nm', fontsize=11,
         color='orange', ha='center', fontweight='bold')

# Fast depopulation
ax5.annotate('', xy=(4, 1.1), xytext=(5.2, 2.9),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, ls='--'))
ax5.text(5.5, 1.5, 'Fast\ndepopulation', fontsize=9, color='gray')

ax5.set_title('Energy Level Diagram:\nSonoluminescence-Pumped Dye Laser', fontsize=12)
ax5.axis('off')

# ── Panel 6: System schematic ──
ax6 = fig.add_subplot(gs[2, 1])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)

# Flask/container
flask = plt.Rectangle((2, 2), 6, 6, fill=True, facecolor='lightyellow',
                       edgecolor='black', linewidth=2)
ax6.add_patch(flask)
ax6.text(5, 8.5, 'Dye-doped liquid', fontsize=11, ha='center', fontweight='bold')

# Ultrasonic transducer
trans = plt.Rectangle((3.5, 0.5), 3, 1.2, fill=True, facecolor='silver',
                       edgecolor='black', linewidth=2)
ax6.add_patch(trans)
ax6.text(5, 1.1, 'Piezo Transducer\n(25 kHz)', fontsize=9, ha='center')

# Sound waves
for y_pos in [3, 4, 5, 6, 7]:
    ax6.plot([3, 7], [y_pos, y_pos], 'b-', alpha=0.2, linewidth=1)

# Bubble
bubble = plt.Circle((5, 5), 0.4, fill=True, facecolor='white',
                     edgecolor='blue', linewidth=2)
ax6.add_patch(bubble)
ax6.text(5, 5, '💥', fontsize=14, ha='center', va='center')
ax6.text(5, 4.2, 'Cavitating\nbubble', fontsize=9, ha='center', color='blue')

# Output arrow
ax6.annotate('', xy=(9.5, 5), xytext=(8.2, 5),
            arrowprops=dict(arrowstyle='->', color='orange', lw=3))
ax6.text(9.5, 5.5, 'Coherent\noutput?', fontsize=10, ha='center',
         color='orange', fontweight='bold')

# Mirror indicators
ax6.plot([2, 2], [3, 7], 'gray', linewidth=4)
ax6.text(1.5, 5, 'M₁\n(HR)', fontsize=9, ha='center', color='gray')
ax6.plot([8, 8], [3, 7], 'gray', linewidth=3, linestyle='-')
ax6.text(8.5, 7, 'M₂\n(OC)', fontsize=9, ha='center', color='gray')

ax6.set_title('System Concept Schematic', fontsize=12)
ax6.axis('off')

plt.savefig('/workspace/request-project/laser_research/demos/sonoluminescence_pump.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: sonoluminescence_pump.png")
