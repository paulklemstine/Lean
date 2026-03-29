#!/usr/bin/env python3
"""
DEMO 5: Bioluminescent / Biological Laser Simulation
======================================================
Simulates a laser using Green Fluorescent Protein (GFP) or
bioluminescent organisms as the gain medium.

Physics: GFP has been demonstrated to lase when concentrated and
placed in an optical cavity (Gather & Yun, Nature Photonics 2011).
This simulation models the gain dynamics of a GFP-based microlaser
and explores bioluminescence as a potential pump source.

Run: python demo5_biolaser_simulation.py
Outputs: biolaser_simulation.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.patches as patches

# ─── GFP Optical Properties ───────────────────────────────────────

def gfp_absorption(wavelengths):
    """GFP absorption spectrum (two peaks: 395 nm and 475 nm)."""
    peak1 = 0.6 * np.exp(-0.5 * ((wavelengths - 395) / 15)**2)
    peak2 = 1.0 * np.exp(-0.5 * ((wavelengths - 475) / 12)**2)
    return peak1 + peak2


def gfp_emission(wavelengths):
    """GFP fluorescence emission spectrum (peak ~509 nm)."""
    return np.exp(-0.5 * ((wavelengths - 509) / 18)**2)


def gfp_lasing_emission(wavelengths):
    """GFP lasing emission (narrowed, ~509 nm)."""
    return np.exp(-0.5 * ((wavelengths - 509) / 2)**2)


def bioluminescence_spectrum(wavelengths, organism='firefly'):
    """Bioluminescence emission spectra for various organisms."""
    spectra = {
        'firefly': (560, 30, 'yellow'),        # Photinus pyralis
        'jellyfish': (508, 20, 'green'),        # Aequorea victoria (with GFP)
        'dinoflagellate': (475, 25, 'cyan'),    # Noctiluca scintillans
        'fungi': (530, 20, 'lime'),             # Panellus stipticus
        'bacteria': (490, 30, 'teal'),          # Vibrio fischeri
    }
    center, width, _ = spectra[organism]
    return np.exp(-0.5 * ((wavelengths - center) / width)**2)


# ─── Laser Threshold Model ────────────────────────────────────────

def whispering_gallery_modes(radius_um, n_eff=1.45, wavelength_range=(500, 520)):
    """Calculate whispering gallery mode positions for a microsphere."""
    c = 3e8
    circumference = 2 * np.pi * radius_um * 1e-6  # meters
    
    # Mode condition: m * λ = n * circumference
    modes = []
    for m in range(1, 10000):
        lam = n_eff * circumference / m * 1e9  # nm
        if wavelength_range[0] <= lam <= wavelength_range[1]:
            modes.append(lam)
    
    return np.array(modes)


def threshold_vs_concentration(concentrations_mM, cavity_Q=1e4, volume_pL=10):
    """
    Estimate lasing threshold pump energy vs GFP concentration.
    
    Threshold ∝ 1 / (σ_em * N * Q * V)
    """
    N_avogadro = 6.022e23
    sigma_em = 2e-16  # cm² — GFP emission cross section
    
    N = concentrations_mM * 1e-3 * N_avogadro * volume_pL * 1e-12  # molecules
    
    # Threshold pump energy (simplified)
    E_threshold = 1 / (sigma_em * N * cavity_Q + 1e-30)
    E_threshold = E_threshold / np.min(E_threshold)  # normalize
    
    return E_threshold


# ─── Simulation ────────────────────────────────────────────────────

wavelengths = np.linspace(350, 700, 1000)
concentrations = np.logspace(-2, 2, 100)  # 0.01 to 100 mM
E_thresh = threshold_vs_concentration(concentrations)

# Whispering gallery modes for a 5 μm radius GFP droplet
wgm_modes = whispering_gallery_modes(5.0, n_eff=1.36)

# ─── Visualization ─────────────────────────────────────────────────

fig = plt.figure(figsize=(18, 20))
gs = GridSpec(4, 2, figure=fig, hspace=0.4, wspace=0.3)
fig.suptitle("Biolaser: Living Light Amplification",
             fontsize=18, fontweight='bold', y=0.98)

# ── Panel 1: GFP absorption & emission ──
ax1 = fig.add_subplot(gs[0, 0])
abs_spec = gfp_absorption(wavelengths)
em_spec = gfp_emission(wavelengths)
lase_spec = gfp_lasing_emission(wavelengths)

ax1.fill_between(wavelengths, abs_spec, alpha=0.3, color='blue')
ax1.plot(wavelengths, abs_spec, 'b-', linewidth=2, label='GFP Absorption')
ax1.fill_between(wavelengths, em_spec * 0.7, alpha=0.3, color='green')
ax1.plot(wavelengths, em_spec * 0.7, 'g-', linewidth=2, label='GFP Fluorescence')
ax1.fill_between(wavelengths, lase_spec * 0.9, alpha=0.5, color='lime')
ax1.plot(wavelengths, lase_spec * 0.9, 'lime', linewidth=3, label='GFP Lasing (509 nm)')

ax1.set_xlabel('Wavelength (nm)', fontsize=11)
ax1.set_ylabel('Intensity (arb.)', fontsize=11)
ax1.set_title('GFP Spectral Properties', fontsize=12)
ax1.legend(fontsize=10)
ax1.set_xlim(350, 650)

# ── Panel 2: Bioluminescence spectra zoo ──
ax2 = fig.add_subplot(gs[0, 1])
organisms = ['firefly', 'jellyfish', 'dinoflagellate', 'fungi', 'bacteria']
colors = ['gold', 'green', 'cyan', 'lime', 'teal']
for org, col in zip(organisms, colors):
    spec = bioluminescence_spectrum(wavelengths, org)
    ax2.fill_between(wavelengths, spec, alpha=0.2, color=col)
    ax2.plot(wavelengths, spec, color=col, linewidth=2, label=org.capitalize())

ax2.set_xlabel('Wavelength (nm)', fontsize=11)
ax2.set_ylabel('Emission Intensity (arb.)', fontsize=11)
ax2.set_title('Bioluminescence Emission Spectra\nNature\'s Light Sources', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_xlim(400, 650)

# ── Panel 3: Threshold vs concentration ──
ax3 = fig.add_subplot(gs[1, 0])
ax3.loglog(concentrations, E_thresh, 'go-', linewidth=2, markersize=3)
ax3.axhline(1, color='red', linestyle='--', label='Minimum threshold')
ax3.axvline(1, color='blue', linestyle='--', alpha=0.5,
            label='~1 mM (achievable)')
ax3.set_xlabel('GFP Concentration (mM)', fontsize=11)
ax3.set_ylabel('Relative Threshold Pump Energy', fontsize=11)
ax3.set_title('Lasing Threshold vs GFP Concentration\n(Lower = easier to lase)', fontsize=12)
ax3.legend(fontsize=10)
ax3.set_ylim(0.1, 1e6)

# ── Panel 4: Whispering Gallery Mode structure ──
ax4 = fig.add_subplot(gs[1, 1])

# Show emission with WGM comb
em_broad = gfp_emission(wavelengths) * 0.3
ax4.fill_between(wavelengths, em_broad, alpha=0.2, color='green',
                 label='Fluorescence (below threshold)')
ax4.plot(wavelengths, em_broad, 'g-', linewidth=1)

# WGM peaks
for mode_wl in wgm_modes[:20]:
    peak = 0.8 * np.exp(-0.5 * ((wavelengths - mode_wl) / 0.3)**2)
    ax4.plot(wavelengths, peak, 'darkgreen', linewidth=1.5)

ax4.plot([], [], 'darkgreen', linewidth=2, label='WGM lasing modes')

ax4.set_xlabel('Wavelength (nm)', fontsize=11)
ax4.set_ylabel('Emission Intensity (arb.)', fontsize=11)
ax4.set_title('Whispering Gallery Mode Spectrum\n(5 μm GFP microsphere)', fontsize=12)
ax4.legend(fontsize=10)
ax4.set_xlim(500, 520)

# ── Panel 5: Microdroplet schematic ──
ax5 = fig.add_subplot(gs[2, 0])
ax5.set_xlim(0, 10)
ax5.set_ylim(0, 10)

# Large GFP droplet
droplet = patches.Circle((5, 5), 3, facecolor='lightgreen', edgecolor='green',
                           linewidth=3, alpha=0.5)
ax5.add_patch(droplet)

# Whispering gallery mode path
theta = np.linspace(0, 2 * np.pi, 100)
r_wgm = 2.8
ax5.plot(5 + r_wgm * np.cos(theta), 5 + r_wgm * np.sin(theta),
         'g--', linewidth=2, alpha=0.5, label='WGM path')

# Internal reflections (simplified polygon)
n_reflections = 8
angles = np.linspace(0, 2 * np.pi, n_reflections + 1)
for i in range(n_reflections):
    x1, y1 = 5 + 2.7 * np.cos(angles[i]), 5 + 2.7 * np.sin(angles[i])
    x2, y2 = 5 + 2.7 * np.cos(angles[i+1]), 5 + 2.7 * np.sin(angles[i+1])
    ax5.plot([x1, x2], [y1, y2], 'lime', linewidth=2, alpha=0.8)
    # Reflection point
    ax5.plot(x1, y1, 'o', color='lime', markersize=5)

# Pump beam
ax5.annotate('', xy=(3.5, 7.5), xytext=(1, 9.5),
            arrowprops=dict(arrowstyle='->', color='blue', lw=3))
ax5.text(0.5, 9.7, 'UV pump\n(405 nm LED)', fontsize=10, color='blue',
         fontweight='bold')

# Output
ax5.annotate('', xy=(9.5, 5), xytext=(8, 5),
            arrowprops=dict(arrowstyle='->', color='lime', lw=3))
ax5.text(9, 5.8, 'Lasing\n509 nm', fontsize=11, color='green', fontweight='bold')

ax5.text(5, 5, 'GFP\nsolution\ndroplet', fontsize=11, ha='center',
         va='center', fontweight='bold', color='darkgreen')

ax5.set_title('Whispering Gallery Mode Microlaser\n(GFP Droplet)', fontsize=12)
ax5.legend(loc='lower left', fontsize=10)
ax5.axis('off')

# ── Panel 6: Bioluminescent pumping concept ──
ax6 = fig.add_subplot(gs[2, 1])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)

# Petri dish with bioluminescent bacteria
dish = patches.Ellipse((5, 3), 8, 2, facecolor='lightyellow',
                         edgecolor='brown', linewidth=2)
ax6.add_patch(dish)

# Bacteria (dots)
np.random.seed(42)
bact_x = 5 + np.random.normal(0, 1.5, 50)
bact_y = 3 + np.random.normal(0, 0.3, 50)
ax6.scatter(bact_x, bact_y, c='teal', s=15, alpha=0.6, label='V. fischeri bacteria')

# Upward light arrows
for _ in range(8):
    x = np.random.uniform(2, 8)
    ax6.annotate('', xy=(x, 5.5), xytext=(x, 3.5),
                arrowprops=dict(arrowstyle='->', color='cyan', lw=1.5, alpha=0.5))

# GFP droplet above
gfp_drop = patches.Circle((5, 7), 1.2, facecolor='lightgreen',
                            edgecolor='green', linewidth=2, alpha=0.6)
ax6.add_patch(gfp_drop)
ax6.text(5, 7, 'GFP\ndroplet', fontsize=10, ha='center', color='darkgreen')

# Lasing output
ax6.annotate('', xy=(8, 8.5), xytext=(6, 7.5),
            arrowprops=dict(arrowstyle='->', color='lime', lw=3))
ax6.text(8.5, 8.5, '🟢 Lasing!', fontsize=12, color='green', fontweight='bold')

ax6.text(5, 1, 'Bioluminescent bacteria pump GFP microlaser',
         fontsize=11, ha='center', color='teal', fontstyle='italic')
ax6.text(5, 0.3, '(A fully biological laser — no electricity!)',
         fontsize=10, ha='center', color='gray')

ax6.set_title('Dream Concept: Fully Biological Laser\nBacteria → GFP → Coherent Light', fontsize=12)
ax6.legend(fontsize=10, loc='upper left')
ax6.axis('off')

# ── Panel 7: Comparison table ──
ax7 = fig.add_subplot(gs[3, :])
data = [
    ['Gain Medium', 'Pump Source', 'Cavity', 'λ_out (nm)', 'Feasibility', 'Novelty'],
    ['GFP solution', 'Blue LED (405nm)', 'Cuvette + mirrors', '509', '★★★★', '★★★'],
    ['GFP droplet', 'Blue LED', 'Whispering gallery', '509', '★★★', '★★★★'],
    ['GFP in cell', 'Microscope laser', 'Cell membrane', '~510', '★★', '★★★★★'],
    ['Firefly luciferin', 'Self (bioluminescence)', 'External mirrors', '560', '★★', '★★★★★'],
    ['Bacterial culture', 'Self (bioluminescence)', 'Fiber loop', '490', '★', '★★★★★'],
]

table = ax7.table(cellText=data[1:], colLabels=data[0],
                   cellLoc='center', loc='center',
                   colColours=['lightgreen']*6)
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1, 1.5)

for key, cell in table.get_celld().items():
    if key[0] == 0:
        cell.set_fontsize(11)
        cell.set_text_props(fontweight='bold')

ax7.set_title('Biolaser Configurations Comparison', fontsize=13)
ax7.axis('off')

plt.savefig('/workspace/request-project/laser_research/demos/biolaser_simulation.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: biolaser_simulation.png")
