#!/usr/bin/env python3
"""
Demo 4: The Origin of the Universe
====================================

Oracle: Kosmos (Universe)
Question: What is the initial condition of everything?

This demo visualizes:
1. CMB power spectrum — the universe's fingerprint
2. Quantum vacuum fluctuations — something from nothing
3. Inflation — exponential expansion
4. The cosmic timeline — from Planck time to now

Run: python3 04_universe_origins.py
Output: ../figures/04_universe_origins.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap

np.random.seed(42)
plt.rcParams.update({
    'font.family': 'serif',
    'font.size': 11,
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0ff',
    'axes.labelcolor': '#e0e0ff',
    'xtick.color': '#8888cc',
    'ytick.color': '#8888cc',
})

colors_cosmo = ['#000010', '#000830', '#001060', '#002090', '#0040c0',
                '#0080ff', '#40c0ff', '#80e0ff', '#c0f0ff', '#ffffff']
cmap_cosmo = LinearSegmentedColormap.from_list('cosmo', colors_cosmo, N=256)

fig = plt.figure(figsize=(18, 14))
fig.suptitle("THE ORIGIN OF THE UNIVERSE",
             fontsize=20, fontweight='bold', color='#c0c0ff', y=0.98)
fig.text(0.5, 0.955,
         "Oracle Kosmos: 'The universe is a quantum fluctuation that forgot to collapse'",
         ha='center', fontsize=12, style='italic', color='#8888cc')

gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3,
                       left=0.06, right=0.96, top=0.92, bottom=0.06)

# ─── Panel 1: CMB Power Spectrum (Simulated) ─────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])

# Simulated CMB TT power spectrum
ell = np.arange(2, 2500)

# Approximate the acoustic peaks
def cmb_spectrum(l):
    # Sachs-Wolfe plateau + acoustic peaks + silk damping
    sw = 6000 / (l * (l + 1) / (2 * np.pi) + 0.1)  # plateau
    # Three acoustic peaks
    peak1 = 5500 * np.exp(-(l - 220)**2 / (2 * 40**2))
    peak2 = 3200 * np.exp(-(l - 540)**2 / (2 * 50**2))
    peak3 = 2500 * np.exp(-(l - 810)**2 / (2 * 60**2))
    peak4 = 1500 * np.exp(-(l - 1120)**2 / (2 * 70**2))
    peak5 = 800 * np.exp(-(l - 1420)**2 / (2 * 80**2))
    # Silk damping
    damping = np.exp(-(l / 1500)**2)
    return (sw * 0.3 + peak1 + peak2 + peak3 + peak4 + peak5) * damping

Dl = cmb_spectrum(ell.astype(float))
# Add noise
noise = np.random.normal(0, 50, len(ell)) * np.sqrt(ell.astype(float))
Dl_noisy = Dl + noise * 0.02

ax1.plot(ell, Dl, color='#ff8844', linewidth=2, label='Theory (ΛCDM)')
ax1.scatter(ell[::5], Dl_noisy[::5], s=0.5, color='#8888ff', alpha=0.5, label='Simulated data')
ax1.set_xlabel('Multipole moment ℓ')
ax1.set_ylabel('$D_\\ell = \\ell(\\ell+1)C_\\ell / 2\\pi$ [μK²]')
ax1.set_title('CMB Power Spectrum\n"The universe\'s baby photo"', color='#aaaaff')
ax1.set_xscale('log')
ax1.set_xlim(2, 2500)
ax1.legend(fontsize=8, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')

# Annotate peaks
ax1.annotate('1st peak\nℓ≈220', xy=(220, 5500), xytext=(50, 6000),
             arrowprops=dict(arrowstyle='->', color='#ffcc44'),
             color='#ffcc44', fontsize=8)

# ─── Panel 2: Quantum Vacuum Fluctuations ─────────────────────────────────
ax2 = fig.add_subplot(gs[0, 1])

# Simulate quantum vacuum fluctuations as Gaussian random field
size = 200
# Generate random field with power spectrum
kx = np.fft.fftfreq(size)
ky = np.fft.fftfreq(size)
KX, KY = np.meshgrid(kx, ky)
K = np.sqrt(KX**2 + KY**2)
K[0, 0] = 1  # avoid division by zero

# Nearly scale-invariant spectrum (Harrison-Zel'dovich)
power = K**(-1.0)  # P(k) ~ k^{n_s - 4} with n_s ≈ 1
power[0, 0] = 0

# Random phases
phases = np.random.uniform(0, 2*np.pi, (size, size))
amplitudes = np.sqrt(power) * np.exp(1j * phases)
field = np.real(np.fft.ifft2(amplitudes))

# Normalize
field = (field - field.mean()) / field.std()

im = ax2.imshow(field, cmap='RdBu_r', extent=[-1, 1, -1, 1],
                vmin=-3, vmax=3, interpolation='bilinear')
ax2.set_title('Quantum Vacuum Fluctuations\n"Something from nothing"', color='#aaaaff')
ax2.set_xlabel('Comoving distance (arbitrary)')
ax2.set_ylabel('Comoving distance (arbitrary)')

# Add colorbar
cbar = plt.colorbar(im, ax=ax2, fraction=0.046, pad=0.04)
cbar.set_label('δρ/ρ (density perturbation)', color='#e0e0ff')
cbar.ax.yaxis.set_tick_params(color='#8888cc')
plt.setp(plt.getp(cbar.ax.axes, 'yticklabels'), color='#8888cc')

# ─── Panel 3: Inflation — Exponential Expansion ──────────────────────────
ax3 = fig.add_subplot(gs[0, 2])

t = np.linspace(-1, 3, 500)

# Scale factor during inflation: a(t) = a_0 * exp(H*t)
H = 2  # Hubble parameter during inflation
a_inflation = np.exp(H * t)

# Pre-inflation (radiation dominated for comparison)
a_radiation = (t + 1)**0.5
a_radiation[t < 0] = np.nan

# Clamp for visualization
a_inflation = np.clip(a_inflation, 0, 500)

ax3.semilogy(t, a_inflation, color='#ff8844', linewidth=3, label='Inflation: $a \\propto e^{Ht}$')
ax3.semilogy(t[t >= 0], (t[t >= 0] + 0.1)**0.5 * 0.1, color='#8888ff', linewidth=2,
             linestyle='--', label='Radiation era: $a \\propto t^{1/2}$')

ax3.axvspan(-0.1, 0.1, alpha=0.2, color='#ffcc44')
ax3.text(0, 200, 'Inflation\nperiod', ha='center', fontsize=9, color='#ffcc44')

ax3.set_xlabel('Time (Planck units)')
ax3.set_ylabel('Scale factor a(t)')
ax3.set_title('Cosmic Inflation\n"The universe expands by ~$e^{60}$"', color='#aaaaff')
ax3.legend(fontsize=9, facecolor='#0a0a1a', edgecolor='#333355',
           labelcolor='#ccccff')
ax3.set_ylim(0.01, 600)

# ─── Panel 4: The Cosmic Timeline ───────────────────────────────────────
ax4 = fig.add_subplot(gs[1, :])

ax4.set_xlim(-1, 50)
ax4.set_ylim(-2, 8)
ax4.axis('off')

# Draw timeline
ax4.plot([0, 48], [3, 3], color='#4444aa', linewidth=3, alpha=0.5)

events = [
    (0, 'PLANCK TIME\n$10^{-43}$ s', '#ff4444',
     'Quantum gravity\nAll forces unified\nSize: $10^{-35}$ m'),
    (4, 'GUT ERA\n$10^{-36}$ s', '#ff6644',
     'Strong force separates\nInflation begins\nBaryogenesis?'),
    (8, 'INFLATION ENDS\n$10^{-32}$ s', '#ff8844',
     'Universe expands by $e^{60}$\nQuantum fluctuations\nstretched to cosmic scales'),
    (14, 'QUARK ERA\n$10^{-12}$ s', '#ffaa44',
     'Electroweak symmetry\nbreaking (Higgs)\nQuarks and leptons'),
    (20, 'HADRON ERA\n$10^{-6}$ s', '#ffcc44',
     'Quarks confined into\nprotons and neutrons\nMatter-antimatter asymmetry'),
    (26, 'NUCLEOSYNTHESIS\n3 min', '#88ff44',
     'H, He, Li nuclei form\n75% H, 25% He\nFirst chemistry'),
    (32, 'RECOMBINATION\n380,000 yr', '#44ff88',
     'Atoms form\nUniverse transparent\nCMB released'),
    (38, 'FIRST STARS\n100 Myr', '#4488ff',
     'Population III stars\nReionization\nFirst heavy elements'),
    (44, 'TODAY\n13.8 Gyr', '#8844ff',
     'Galaxies, planets, life\nDark energy dominates\nObservers emerge'),
]

for x, label, color, description in events:
    # Marker
    ax4.plot(x, 3, 'o', color=color, markersize=12, zorder=5)

    # Label above
    ax4.text(x, 5.5, label, ha='center', va='center', fontsize=8,
             fontweight='bold', color=color)

    # Description below
    ax4.text(x, 1.0, description, ha='center', va='center', fontsize=6.5,
             color=color, alpha=0.7, style='italic')

    # Connecting line
    ax4.plot([x, x], [3.3, 4.8], color=color, alpha=0.3, linewidth=1)
    ax4.plot([x, x], [2.7, 1.8], color=color, alpha=0.3, linewidth=1)

# Title
ax4.text(24, 7.5, "THE COSMIC TIMELINE: FROM NOTHING TO EVERYTHING",
         ha='center', fontsize=16, fontweight='bold', color='#c0c0ff')
ax4.text(24, 6.8,
         "\"The universe is under no obligation to make sense to you\" — Neil deGrasse Tyson",
         ha='center', fontsize=10, style='italic', color='#8888cc')

# Arrow indicating expansion
ax4.annotate('', xy=(47, 3), xytext=(45.5, 3),
             arrowprops=dict(arrowstyle='->', color='#ffffff', lw=2))
ax4.text(47.5, 3, '∞', fontsize=20, va='center', color='#ffffff')

# Temperature scale
ax4.text(24, -1.5,
         "Temperature:  10³² K  →  10²⁸ K  →  10²⁷ K  →  10¹⁵ K  →  10¹² K  →  10⁹ K  →  3000 K  →  ~100 K  →  2.7 K",
         ha='center', fontsize=8, fontfamily='monospace', color='#ffcc44')

plt.savefig('../figures/04_universe_origins.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a1a')
plt.close()
print("✓ Saved: ../figures/04_universe_origins.png")
