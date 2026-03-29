#!/usr/bin/env python3
"""
DEMO 1: Random Laser Simulation
================================
Simulates photon random walks through a scattering gain medium.
Demonstrates how coherent amplification emerges from disorder.

Physics: Photons scatter off TiO2 nanoparticles in a dye solution.
If the scattering mean free path is short enough relative to the
gain length, photons make enough passes through the gain medium
to achieve amplification — a "random laser."

Run: python demo1_random_laser_simulation.py
Outputs: random_laser_simulation.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import LineCollection

# ─── Physical Parameters ───────────────────────────────────────────
np.random.seed(42)

MEDIUM_RADIUS = 50.0        # μm — radius of gain medium droplet
SCATTERING_MFP = 5.0        # μm — transport mean free path
GAIN_PER_STEP = 0.08        # fractional intensity gain per scattering event
LOSS_PER_STEP = 0.02        # fractional loss per step (absorption, escape)
NUM_PHOTONS = 200           # number of seed photons to simulate
MAX_STEPS = 300             # max scattering events per photon
LASING_THRESHOLD = 5.0      # intensity amplification factor for "lasing"

# ─── Simulation ────────────────────────────────────────────────────
def simulate_photon(mfp, gain, loss, max_steps, boundary):
    """Simulate a single photon random-walking through a scattering gain medium."""
    x, y = 0.0, 0.0
    intensity = 1.0
    path_x, path_y, path_i = [x], [y], [intensity]

    for _ in range(max_steps):
        # Random direction, exponentially distributed step length
        theta = np.random.uniform(0, 2 * np.pi)
        step = np.random.exponential(mfp)
        x += step * np.cos(theta)
        y += step * np.sin(theta)

        # Gain and loss
        intensity *= (1 + gain - loss)

        path_x.append(x)
        path_y.append(y)
        path_i.append(intensity)

        # Photon escapes the medium
        if np.sqrt(x**2 + y**2) > boundary:
            break

    return np.array(path_x), np.array(path_y), np.array(path_i)


def run_simulation(mfp):
    """Run full simulation for a given mean free path."""
    results = []
    for _ in range(NUM_PHOTONS):
        px, py, pi = simulate_photon(mfp, GAIN_PER_STEP, LOSS_PER_STEP,
                                      MAX_STEPS, MEDIUM_RADIUS)
        results.append((px, py, pi))
    return results


# ─── Run for two regimes ───────────────────────────────────────────
print("Simulating diffusive regime (long mean free path)...")
results_diffuse = run_simulation(mfp=20.0)   # few scattering events

print("Simulating random lasing regime (short mean free path)...")
results_lasing = run_simulation(mfp=3.0)     # many scattering events → lasing

# ─── Visualization ─────────────────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("Random Laser Simulation: From Diffusion to Lasing",
             fontsize=18, fontweight='bold', y=0.98)

# ── Panel 1: Diffuse photon paths ──
ax = axes[0, 0]
circle = plt.Circle((0, 0), MEDIUM_RADIUS, fill=False, color='steelblue',
                     linewidth=2, linestyle='--', label='Medium boundary')
ax.add_patch(circle)
for px, py, pi in results_diffuse[:30]:
    color = 'gray' if pi[-1] < LASING_THRESHOLD else 'red'
    ax.plot(px, py, alpha=0.3, linewidth=0.5, color=color)
ax.set_xlim(-80, 80)
ax.set_ylim(-80, 80)
ax.set_aspect('equal')
ax.set_title('Diffusive Regime (MFP = 20 μm)\nPhotons escape quickly', fontsize=12)
ax.set_xlabel('x (μm)')
ax.set_ylabel('y (μm)')

# ── Panel 2: Lasing photon paths ──
ax = axes[0, 1]
circle = plt.Circle((0, 0), MEDIUM_RADIUS, fill=False, color='steelblue',
                     linewidth=2, linestyle='--')
ax.add_patch(circle)
lasing_count = 0
for px, py, pi in results_lasing[:30]:
    if pi[-1] >= LASING_THRESHOLD:
        ax.plot(px, py, alpha=0.5, linewidth=0.8, color='red')
        lasing_count += 1
    else:
        ax.plot(px, py, alpha=0.2, linewidth=0.3, color='gray')
ax.set_xlim(-80, 80)
ax.set_ylim(-80, 80)
ax.set_aspect('equal')
ax.set_title(f'Random Lasing Regime (MFP = 3 μm)\nPhotons trapped → amplified',
             fontsize=12)
ax.set_xlabel('x (μm)')
ax.set_ylabel('y (μm)')

# ── Panel 3: Intensity distributions ──
ax = axes[1, 0]
final_I_diffuse = [r[2][-1] for r in results_diffuse]
final_I_lasing = [r[2][-1] for r in results_lasing]

bins = np.logspace(-1, 3, 50)
ax.hist(final_I_diffuse, bins=bins, alpha=0.6, color='steelblue',
        label=f'Diffusive (MFP=20μm)\nMean I = {np.mean(final_I_diffuse):.2f}')
ax.hist(final_I_lasing, bins=bins, alpha=0.6, color='crimson',
        label=f'Random Lasing (MFP=3μm)\nMean I = {np.mean(final_I_lasing):.2f}')
ax.axvline(LASING_THRESHOLD, color='gold', linewidth=2, linestyle='--',
           label=f'Lasing threshold (I={LASING_THRESHOLD})')
ax.set_xscale('log')
ax.set_xlabel('Final Photon Intensity (arb. units)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Output Intensity Distribution', fontsize=12)
ax.legend(fontsize=9)

# ── Panel 4: Emission spectrum simulation ──
ax = axes[1, 1]
wavelengths = np.linspace(550, 650, 500)  # nm, typical rhodamine range
center = 590  # nm

# Broad spontaneous emission
spont = np.exp(-0.5 * ((wavelengths - center) / 15)**2)

# Narrowed lasing emission (random laser still has some linewidth)
lasing_emission = np.exp(-0.5 * ((wavelengths - center) / 2.5)**2)

# Below threshold: broad emission
ax.fill_between(wavelengths, spont * 0.3, alpha=0.3, color='steelblue',
                label='Below threshold (spontaneous)')
ax.plot(wavelengths, spont * 0.3, color='steelblue', linewidth=1.5)

# Above threshold: narrowed peaks
# Random lasers show multiple narrow peaks
for offset in [-3, 0, 1.5, 4]:
    peak = 0.8 * np.exp(-0.5 * ((wavelengths - center - offset) / 0.8)**2)
    ax.plot(wavelengths, peak, color='crimson', linewidth=1.5)
ax.fill_between(wavelengths, lasing_emission * 0.9, alpha=0.15, color='crimson',
                label='Above threshold (random lasing)')

ax.set_xlabel('Wavelength (nm)', fontsize=11)
ax.set_ylabel('Emission Intensity (arb.)', fontsize=11)
ax.set_title('Emission Spectrum: Threshold Behavior', fontsize=12)
ax.legend(fontsize=10)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/workspace/request-project/laser_research/demos/random_laser_simulation.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Saved: random_laser_simulation.png")

# ─── Summary Statistics ───────────────────────────────────────────
print("\n" + "="*60)
print("RANDOM LASER SIMULATION RESULTS")
print("="*60)
frac_d = sum(1 for i in final_I_diffuse if i >= LASING_THRESHOLD) / NUM_PHOTONS
frac_l = sum(1 for i in final_I_lasing if i >= LASING_THRESHOLD) / NUM_PHOTONS
print(f"Diffusive regime:  {frac_d*100:.1f}% of photons reach lasing threshold")
print(f"Random lasing:     {frac_l*100:.1f}% of photons reach lasing threshold")
print(f"Mean amplification (diffuse):  {np.mean(final_I_diffuse):.2f}x")
print(f"Mean amplification (lasing):   {np.mean(final_I_lasing):.2f}x")
print(f"Max amplification (lasing):    {np.max(final_I_lasing):.2f}x")
