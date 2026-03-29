#!/usr/bin/env python3
"""
DEMO 3: Chemiluminescent Laser Simulation
==========================================
Models a laser pumped by chemical reaction light (no electricity needed).

Physics: Luminol + H₂O₂ chemiluminescence produces blue light (~425 nm).
This blue emission can pump a secondary dye (e.g., Fluorescein at ~520 nm)
placed in an optical cavity, creating a chemically-powered laser.

Run: python demo3_chemiluminescent_laser.py
Outputs: chemiluminescent_laser.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ─── Chemical Kinetics Model ──────────────────────────────────────

def chemiluminescence_kinetics(t, k1=0.5, k2=0.1, C_luminol0=1.0, C_h2o2_0=2.0):
    """
    Simplified luminol chemiluminescence kinetics.
    
    Luminol + H₂O₂ → 3-aminophthalate* → 3-aminophthalate + hν (425 nm)
    
    Two-step: k1 for oxidation, k2 for light emission from excited product.
    """
    # Reactant concentrations (simplified first-order)
    C_luminol = C_luminol0 * np.exp(-k1 * t)
    C_h2o2 = C_h2o2_0 - (C_luminol0 - C_luminol) * 0.5
    C_h2o2 = np.maximum(C_h2o2, 0)
    
    # Excited product: builds up then decays
    C_excited = C_luminol0 * k1 / (k1 - k2 + 1e-10) * (np.exp(-k2 * t) - np.exp(-k1 * t))
    C_excited = np.maximum(C_excited, 0)
    
    # Photon emission rate ∝ k2 * C_excited
    emission_rate = k2 * C_excited
    
    return C_luminol, C_h2o2, C_excited, emission_rate


def dye_rate_equations(t, pump_rate, sigma_abs=1e-16, sigma_em=2e-16,
                        N_total=1e18, tau_f=4e-9, cavity_loss=1e8):
    """
    Simplified dye laser rate equations under chemical pumping.
    
    dN₂/dt = W_pump * N₁ - N₂/τ_f - σ_em * c * ϕ * (N₂ - N₁)
    dϕ/dt = σ_em * c * L * (N₂ - N₁) * ϕ - ϕ/τ_c + β * N₂/τ_f
    """
    dt = t[1] - t[0]
    N2 = np.zeros_like(t)
    phi = np.zeros_like(t)  # photon density in cavity
    
    c = 3e8  # speed of light
    L = 0.01  # cavity length (1 cm)
    beta = 1e-4  # spontaneous emission factor
    tau_c = 1 / cavity_loss  # cavity photon lifetime
    
    for i in range(len(t) - 1):
        N1 = N_total - N2[i]
        
        # Pump rate from chemiluminescence
        W_p = pump_rate[i] * sigma_abs * c
        
        # Rate equations
        dN2 = W_p * N1 - N2[i] / tau_f - sigma_em * c * phi[i] * (N2[i] - N1)
        dphi = (sigma_em * c * L * (N2[i] - N1) * phi[i] 
                - phi[i] / tau_c 
                + beta * N2[i] / tau_f)
        
        N2[i+1] = N2[i] + dN2 * dt
        phi[i+1] = phi[i] + dphi * dt
        
        # Clamp
        N2[i+1] = np.clip(N2[i+1], 0, N_total)
        phi[i+1] = max(phi[i+1], 0)
    
    return N2, phi


# ─── Simulation ────────────────────────────────────────────────────

# Chemical reaction timescale: seconds
t_chem = np.linspace(0, 30, 5000)  # 30 seconds
C_lum, C_h2o2, C_exc, emission = chemiluminescence_kinetics(t_chem)

# Normalize pump rate for dye laser model
pump_norm = emission / np.max(emission) * 1e16  # photons/cm²/s

# Dye laser dynamics (faster timescale, but we'll use averaged pump)
t_laser = np.linspace(0, 30, 5000)
N2, phi = dye_rate_equations(t_laser, pump_norm)

# Spectra
wavelengths = np.linspace(350, 700, 1000)

# ─── Visualization ─────────────────────────────────────────────────

fig = plt.figure(figsize=(18, 16))
gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)
fig.suptitle("Chemiluminescent Laser: Chemistry Powers Light Amplification",
             fontsize=18, fontweight='bold', y=0.98)

# ── Panel 1: Chemical reaction diagram ──
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 10)

# Reactants
ax1.text(1, 8, 'Luminol', fontsize=14, fontweight='bold', color='blue',
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
ax1.text(1, 6, 'H₂O₂', fontsize=14, fontweight='bold', color='green',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
ax1.text(1, 4, 'NaOH\n(catalyst)', fontsize=11, color='gray',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Arrow
ax1.annotate('', xy=(5.5, 7), xytext=(3.5, 7),
            arrowprops=dict(arrowstyle='->', color='black', lw=2))
ax1.text(4.5, 7.5, 'oxidation', fontsize=10, ha='center')

# Products
ax1.text(6, 8, '3-amino-\nphthalate*', fontsize=12, fontweight='bold', color='purple',
         bbox=dict(boxstyle='round', facecolor='plum', alpha=0.8))

# Photon emission
ax1.annotate('', xy=(8, 5.5), xytext=(7, 7.5),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax1.text(8.5, 6.5, '💡\nhν\n425 nm', fontsize=12, ha='center', color='blue',
         fontweight='bold')

# Secondary dye excitation
ax1.annotate('', xy=(8, 3.5), xytext=(8, 5),
            arrowprops=dict(arrowstyle='->', color='orange', lw=2))
ax1.text(6, 3, 'Fluorescein\ndye (pumped)', fontsize=11, color='orange',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Laser output
ax1.annotate('', xy=(8, 1.5), xytext=(7, 2.8),
            arrowprops=dict(arrowstyle='->', color='green', lw=3))
ax1.text(8.5, 1, '🟢 LASER\n520 nm', fontsize=13, ha='center', color='green',
         fontweight='bold')

ax1.set_title('Reaction Pathway', fontsize=12)
ax1.axis('off')

# ── Panel 2: Reaction kinetics ──
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(t_chem, C_lum, 'b-', linewidth=2, label='[Luminol]')
ax2.plot(t_chem, C_h2o2, 'g-', linewidth=2, label='[H₂O₂]')
ax2.plot(t_chem, C_exc * 5, 'purple', linewidth=2, label='[Excited product] ×5')
ax2.plot(t_chem, emission * 10, 'orange', linewidth=2, label='Photon emission ×10')
ax2.set_xlabel('Time (seconds)', fontsize=11)
ax2.set_ylabel('Concentration / Intensity (arb.)', fontsize=11)
ax2.set_title('Chemiluminescence Kinetics', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 30)

# ── Panel 3: Population inversion ──
ax3 = fig.add_subplot(gs[1, 0])
inversion = 2 * N2 / 1e18 - 1  # Normalized inversion
ax3.plot(t_laser, inversion, 'r-', linewidth=2)
ax3.axhline(0, color='gray', linestyle='--', alpha=0.5)
ax3.fill_between(t_laser, inversion, 0, where=inversion > 0,
                 alpha=0.3, color='red', label='Population inversion')
ax3.fill_between(t_laser, inversion, 0, where=inversion <= 0,
                 alpha=0.3, color='blue', label='No inversion')
ax3.set_xlabel('Time (seconds)', fontsize=11)
ax3.set_ylabel('Population Inversion (N₂-N₁)/N', fontsize=11)
ax3.set_title('Dye Population Inversion\n(Driven by Chemical Pump)', fontsize=12)
ax3.legend(fontsize=10)

# ── Panel 4: Cavity photon density (lasing output) ──
ax4 = fig.add_subplot(gs[1, 1])
phi_norm = phi / (np.max(phi) + 1e-30)
ax4.plot(t_laser, phi_norm, 'green', linewidth=2, label='Intracavity photons')
ax4.set_xlabel('Time (seconds)', fontsize=11)
ax4.set_ylabel('Photon Density (normalized)', fontsize=11)
ax4.set_title('Laser Output Dynamics\n(Chemically Pumped)', fontsize=12)
ax4.legend(fontsize=10)

# ── Panel 5: Spectral comparison ──
ax5 = fig.add_subplot(gs[2, 0])

# Luminol chemiluminescence
chem_spec = np.exp(-0.5 * ((wavelengths - 425) / 20)**2)
ax5.fill_between(wavelengths, chem_spec, alpha=0.3, color='blue')
ax5.plot(wavelengths, chem_spec, 'b-', linewidth=2, label='Luminol CL (pump)')

# Fluorescein absorption
fl_abs = np.exp(-0.5 * ((wavelengths - 490) / 25)**2)
ax5.fill_between(wavelengths, fl_abs * 0.7, alpha=0.2, color='cyan')
ax5.plot(wavelengths, fl_abs * 0.7, 'c-', linewidth=2, label='Fluorescein absorption')

# Fluorescein lasing emission
fl_em = np.exp(-0.5 * ((wavelengths - 520) / 5)**2) * 0.9
ax5.fill_between(wavelengths, fl_em, alpha=0.4, color='green')
ax5.plot(wavelengths, fl_em, 'g-', linewidth=2.5, label='Laser emission (520 nm)')

ax5.set_xlabel('Wavelength (nm)', fontsize=11)
ax5.set_ylabel('Intensity (arb.)', fontsize=11)
ax5.set_title('Spectral Energy Transfer Chain', fontsize=12)
ax5.legend(fontsize=10)
ax5.set_xlim(350, 650)

# ── Panel 6: Build schematic ──
ax6 = fig.add_subplot(gs[2, 1])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)

# Test tube / cuvette
cuvette = plt.Rectangle((2.5, 1), 5, 7, fill=True, facecolor='lightyellow',
                          edgecolor='black', linewidth=2, alpha=0.7)
ax6.add_patch(cuvette)

# Liquid layers
liquid = plt.Rectangle((2.7, 1.2), 4.6, 6.6, fill=True,
                        facecolor='lightgreen', edgecolor='none', alpha=0.5)
ax6.add_patch(liquid)

# Mirrors
ax6.plot([2.3, 2.3], [2, 7], 'silver', linewidth=6, solid_capstyle='round')
ax6.text(1.5, 4.5, 'HR\nMirror', fontsize=9, ha='center', color='gray')

ax6.plot([7.7, 7.7], [2, 7], 'silver', linewidth=4, solid_capstyle='round')
ax6.text(8.5, 4.5, 'OC\nMirror\n(98%R)', fontsize=9, ha='center', color='gray')

# Labels
ax6.text(5, 8.5, 'Glass Cuvette', fontsize=12, ha='center', fontweight='bold')
ax6.text(5, 5, 'Luminol +\nH₂O₂ +\nFluorescein\n+ NaOH', fontsize=10,
         ha='center', color='darkgreen',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Mixing arrow
ax6.annotate('', xy=(5, 1.5), xytext=(5, 0.3),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax6.text(5, 0.1, 'Mix & pour', fontsize=10, ha='center', color='blue')

# Output beam
ax6.annotate('', xy=(9.8, 4.5), xytext=(7.9, 4.5),
            arrowprops=dict(arrowstyle='->', color='green', lw=3))
ax6.text(9.2, 5.2, '🟢 Laser\nbeam', fontsize=11, ha='center',
         color='green', fontweight='bold')

ax6.set_title('Hobbyist Build Concept', fontsize=12)
ax6.axis('off')

plt.savefig('/workspace/request-project/laser_research/demos/chemiluminescent_laser.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: chemiluminescent_laser.png")
