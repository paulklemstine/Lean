#!/usr/bin/env python3
"""
DEMO 4: Triboluminescent Optical Cavity Simulation
====================================================
Simulates light generation from mechanical fracture of crystals and
its amplification in an optical cavity.

Physics: When certain crystals (ZnS:Mn, sugar, europium complexes) are
fractured, they emit light through charge separation across crack faces.
By repeatedly fracturing crystals inside an optical cavity with a gain
medium, we can attempt to build a mechanically-pumped laser.

Run: python demo4_triboluminescent_cavity.py
Outputs: triboluminescent_cavity.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.patches as patches

# ─── Physical Models ──────────────────────────────────────────────

def triboemission_pulse(t, t_fracture=0.0, duration=1e-6, peak_power=1.0):
    """Single triboluminescent flash from a crystal fracture event."""
    # Fast rise, exponential decay
    dt = t - t_fracture
    pulse = np.where(dt >= 0,
                     peak_power * (dt / duration) * np.exp(1 - dt / duration),
                     0.0)
    return pulse


def crystal_crusher_train(t, rate=1000, duration=1e-6, peak=1.0, jitter=0.2):
    """Train of triboluminescent pulses from a mechanical crusher."""
    np.random.seed(123)
    total = np.zeros_like(t)
    n_events = int(rate * (t[-1] - t[0]))
    
    # Regular events with jitter
    for i in range(n_events):
        t_event = t[0] + (i + np.random.normal(0, jitter)) / rate
        intensity = peak * np.random.uniform(0.3, 1.0)
        total += triboemission_pulse(t, t_event, duration, intensity)
    
    return total


def cavity_response(pump_signal, dt, cavity_lifetime=1e-8, gain_cross_section=1e-16,
                     N_total=1e17, spontaneous_lifetime=3e-9):
    """Simple cavity response to pulsed pumping."""
    n = len(pump_signal)
    N2 = np.zeros(n)      # upper state population
    phi = np.zeros(n)     # intracavity photon density
    output = np.zeros(n)  # output power
    
    c = 3e8
    beta = 1e-5  # spontaneous emission coupling
    
    for i in range(n - 1):
        N1 = N_total - N2[i]
        
        dN2 = (pump_signal[i] * N1 * gain_cross_section * c
               - N2[i] / spontaneous_lifetime
               - gain_cross_section * c * phi[i] * (N2[i] - N1))
        
        dphi = (gain_cross_section * c * 0.01 * (N2[i] - N1) * phi[i]
                - phi[i] / cavity_lifetime
                + beta * N2[i] / spontaneous_lifetime)
        
        N2[i+1] = max(0, N2[i] + dN2 * dt)
        phi[i+1] = max(0, phi[i] + dphi * dt)
        output[i+1] = phi[i+1] / cavity_lifetime * 0.02  # 2% output coupler
    
    return N2, phi, output


# ─── Crystals and their properties ────────────────────────────────

crystals = {
    'Wintergreen\n(methyl salicylate)': {
        'peak_nm': 450, 'width': 40, 'color': 'blue', 'intensity': 0.4
    },
    'ZnS:Mn\n(sphalerite)': {
        'peak_nm': 585, 'width': 25, 'color': 'orange', 'intensity': 0.9
    },
    'Europium\ntetrakis': {
        'peak_nm': 613, 'width': 8, 'color': 'red', 'intensity': 1.0
    },
    'Sugar\n(sucrose)': {
        'peak_nm': 420, 'width': 50, 'color': 'violet', 'intensity': 0.3
    },
    'UO₂(NO₃)₂\n(uranyl nitrate)': {
        'peak_nm': 520, 'width': 15, 'color': 'green', 'intensity': 0.7
    }
}

# ─── Simulation ────────────────────────────────────────────────────

# Time axis for crusher (millisecond scale)
t_ms = np.linspace(0, 5e-3, 50000)  # 5 ms window
dt = t_ms[1] - t_ms[0]

# Triboluminescent pulse train
pump_train = crystal_crusher_train(t_ms, rate=5000, duration=0.5e-6, peak=1e14)

# Cavity response
N2, phi, output = cavity_response(pump_train, dt)

# Wavelength axis
wavelengths = np.linspace(350, 750, 1000)

# ─── Visualization ─────────────────────────────────────────────────

fig = plt.figure(figsize=(18, 18))
gs = GridSpec(4, 2, figure=fig, hspace=0.4, wspace=0.3)
fig.suptitle("Triboluminescent Laser: Mechanical Energy → Coherent Light",
             fontsize=18, fontweight='bold', y=0.98)

# ── Panel 1: Crystal fracture mechanism ──
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 10)

# Crystal before fracture
crystal1 = patches.FancyBboxPatch((0.5, 3), 3, 4, boxstyle="round,pad=0.1",
                                    facecolor='lightyellow', edgecolor='orange', linewidth=2)
ax1.add_patch(crystal1)
ax1.text(2, 5, '⚡\nCrystal\n(intact)', fontsize=10, ha='center', va='center')

# Force arrows
ax1.annotate('', xy=(2, 7.5), xytext=(2, 8.5),
            arrowprops=dict(arrowstyle='->', color='red', lw=3))
ax1.annotate('', xy=(2, 2.5), xytext=(2, 1.5),
            arrowprops=dict(arrowstyle='->', color='red', lw=3))
ax1.text(2, 9, 'F↓', fontsize=12, ha='center', color='red', fontweight='bold')
ax1.text(2, 1, 'F↑', fontsize=12, ha='center', color='red', fontweight='bold')

# Crack
ax1.plot([4.5, 4.5], [3.5, 6.5], 'k-', linewidth=3)
ax1.plot([4.5, 5.0], [3.5, 3.0], 'k-', linewidth=2)
ax1.plot([4.5, 5.0], [6.5, 7.0], 'k-', linewidth=2)

# Fractured crystal
frag1 = patches.FancyBboxPatch((5.5, 4.5), 2, 3, boxstyle="round,pad=0.1",
                                 facecolor='lightyellow', edgecolor='orange', linewidth=2)
frag2 = patches.FancyBboxPatch((5.5, 2), 2, 2, boxstyle="round,pad=0.1",
                                 facecolor='lightyellow', edgecolor='orange', linewidth=2)
ax1.add_patch(frag1)
ax1.add_patch(frag2)

# Charge separation
ax1.text(6.5, 4.2, '- - -', fontsize=12, ha='center', color='blue')
ax1.text(6.5, 4.7, '+ + +', fontsize=12, ha='center', color='red')

# Photon emission
for angle in [30, 60, 120, 150, 200, 250, 310, 340]:
    dx = 1.2 * np.cos(np.radians(angle))
    dy = 1.2 * np.sin(np.radians(angle))
    ax1.annotate('', xy=(6.5 + dx, 4.5 + dy), xytext=(6.5 + dx*0.3, 4.5 + dy*0.3),
                arrowprops=dict(arrowstyle='->', color='gold', lw=1.5))

ax1.text(9, 4.5, '💡\nhν', fontsize=14, ha='center', color='goldenrod',
         fontweight='bold')

ax1.set_title('Triboluminescence Mechanism:\nCharge Separation at Fracture', fontsize=12)
ax1.axis('off')

# ── Panel 2: Emission spectra of different crystals ──
ax2 = fig.add_subplot(gs[0, 1])
for name, props in crystals.items():
    spectrum = props['intensity'] * np.exp(
        -0.5 * ((wavelengths - props['peak_nm']) / props['width'])**2
    )
    ax2.fill_between(wavelengths, spectrum, alpha=0.2, color=props['color'])
    ax2.plot(wavelengths, spectrum, color=props['color'], linewidth=2, label=name)

ax2.set_xlabel('Wavelength (nm)', fontsize=11)
ax2.set_ylabel('Relative Emission Intensity', fontsize=11)
ax2.set_title('Triboluminescent Emission Spectra\nof Various Crystals', fontsize=12)
ax2.legend(fontsize=8, loc='upper right', ncol=1)
ax2.set_xlim(350, 750)

# ── Panel 3: Mechanical crusher pulse train ──
ax3 = fig.add_subplot(gs[1, 0])
ax3.plot(t_ms * 1e3, pump_train / np.max(pump_train), color='orange', linewidth=0.8)
ax3.fill_between(t_ms * 1e3, pump_train / np.max(pump_train), alpha=0.3, color='orange')
ax3.set_xlabel('Time (ms)', fontsize=11)
ax3.set_ylabel('Flash Intensity (normalized)', fontsize=11)
ax3.set_title('Triboluminescent Pulse Train\n(Piezo crusher at ~5 kHz)', fontsize=12)
ax3.set_xlim(0, 5)

# ── Panel 4: Cavity photon buildup ──
ax4 = fig.add_subplot(gs[1, 1])
phi_norm = phi / (np.max(phi) + 1e-30)
ax4.plot(t_ms * 1e3, phi_norm, color='red', linewidth=1.5, label='Intracavity photons')
ax4.fill_between(t_ms * 1e3, phi_norm, alpha=0.2, color='red')
ax4.set_xlabel('Time (ms)', fontsize=11)
ax4.set_ylabel('Photon Density (normalized)', fontsize=11)
ax4.set_title('Cavity Photon Density Response', fontsize=12)
ax4.set_xlim(0, 5)
ax4.legend()

# ── Panel 5: Power threshold analysis ──
ax5 = fig.add_subplot(gs[2, 0])
crush_rates = np.linspace(100, 20000, 50)
max_outputs = []
for rate in crush_rates:
    pump = crystal_crusher_train(t_ms, rate=rate, duration=0.5e-6, peak=1e14)
    _, _, out = cavity_response(pump, dt)
    max_outputs.append(np.max(out))

max_outputs = np.array(max_outputs)
max_outputs_norm = max_outputs / (np.max(max_outputs) + 1e-30)

ax5.plot(crush_rates / 1000, max_outputs_norm, 'ro-', linewidth=2, markersize=4)
ax5.set_xlabel('Crush Rate (kHz)', fontsize=11)
ax5.set_ylabel('Peak Output (normalized)', fontsize=11)
ax5.set_title('Output vs Mechanical Pumping Rate\n(Lasing Threshold Analysis)', fontsize=12)

# Find threshold
threshold_idx = np.argmax(max_outputs_norm > 0.1)
if threshold_idx > 0:
    ax5.axvline(crush_rates[threshold_idx] / 1000, color='blue', linestyle='--',
                label=f'Threshold ≈ {crush_rates[threshold_idx]/1000:.1f} kHz')
    ax5.legend(fontsize=10)

# ── Panel 6: Hobbyist build concept ──
ax6 = fig.add_subplot(gs[2, 1])
ax6.set_xlim(0, 10)
ax6.set_ylim(0, 10)

# Motor
motor = patches.Circle((2, 5), 1, facecolor='silver', edgecolor='black', linewidth=2)
ax6.add_patch(motor)
ax6.text(2, 5, 'Motor\n(DC)', fontsize=9, ha='center', va='center')

# Cam
cam = patches.Ellipse((3.5, 5), 1, 0.5, angle=30, facecolor='gray',
                       edgecolor='black', linewidth=2)
ax6.add_patch(cam)
ax6.text(3.5, 4, 'Cam', fontsize=9, ha='center')

# Crusher
crusher = plt.Rectangle((4.5, 3.5), 1, 3, facecolor='steelblue',
                          edgecolor='black', linewidth=2)
ax6.add_patch(crusher)
ax6.text(5, 5, 'Anvil', fontsize=9, ha='center', va='center', color='white')

# Crystal hopper
hopper = plt.Polygon([[5.5, 8], [6.5, 8], [6.2, 6.5], [5.8, 6.5]],
                       facecolor='lightyellow', edgecolor='orange', linewidth=2)
ax6.add_patch(hopper)
ax6.text(6, 8.3, 'Crystal\nHopper', fontsize=9, ha='center', color='orange')

# Small crystals
for pos in [(5.9, 7.5), (6.1, 7.2), (6.0, 6.8)]:
    ax6.plot(*pos, 'o', color='orange', markersize=5)

# Cavity
ax6.plot([5.5, 5.5], [3, 7], 'gray', linewidth=5)  # Mirror 1
ax6.text(5.5, 2.5, 'M₁', fontsize=10, ha='center', color='gray')
ax6.plot([8.5, 8.5], [3, 7], 'gray', linewidth=3)  # Mirror 2
ax6.text(8.5, 2.5, 'M₂', fontsize=10, ha='center', color='gray')

# Cavity space (with dye)
cavity = plt.Rectangle((5.7, 3.5), 2.6, 3, facecolor='lightyellow',
                         edgecolor='none', alpha=0.5)
ax6.add_patch(cavity)
ax6.text(7, 5, 'Dye\ncell', fontsize=10, ha='center', color='darkgreen')

# Output
ax6.annotate('', xy=(9.8, 5), xytext=(8.7, 5),
            arrowprops=dict(arrowstyle='->', color='red', lw=3))
ax6.text(9.5, 5.8, 'Output', fontsize=10, ha='center', color='red', fontweight='bold')

# Battery
ax6.text(0.5, 2, '🔋 9V', fontsize=12)
ax6.annotate('', xy=(1.5, 4.2), xytext=(0.8, 2.5),
            arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

ax6.set_title('Build Concept: Motorized Crystal Crusher\nwith Optical Cavity', fontsize=12)
ax6.axis('off')

# ── Panel 7: Materials list ──
ax7 = fig.add_subplot(gs[3, :])
materials = [
    ['Component', 'Material', 'Source', 'Est. Cost'],
    ['Crystals', 'ZnS:Mn powder or Europium tetrakis', 'Chemistry supplier / eBay', '$10-25'],
    ['Crusher', 'Piezo buzzer or small DC motor + cam', 'Electronics store', '$5-15'],
    ['Cavity mirrors', 'Thorlabs or old CD/DVD (partial reflector)', 'Thorlabs / recycled', '$0-40'],
    ['Dye cell', 'Glass cuvette (10mm path)', 'Amazon / lab supplier', '$5-10'],
    ['Gain medium', 'Rhodamine 6G or Fluorescein in ethanol', 'eBay / chemistry supplier', '$10-20'],
    ['Power', '9V battery or USB power bank', 'Any store', '$3-5'],
    ['Housing', '3D printed or cardboard tube', 'Home printer / craft store', '$2-5'],
]

table = ax7.table(cellText=materials[1:], colLabels=materials[0],
                   cellLoc='center', loc='center',
                   colColours=['lightsteelblue']*4)
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1, 1.5)

# Style header
for key, cell in table.get_celld().items():
    if key[0] == 0:
        cell.set_fontsize(11)
        cell.set_text_props(fontweight='bold')

ax7.set_title('Bill of Materials: Triboluminescent Laser (~$35-120)', fontsize=13)
ax7.axis('off')

plt.savefig('/workspace/request-project/laser_research/demos/triboluminescent_cavity.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: triboluminescent_cavity.png")
