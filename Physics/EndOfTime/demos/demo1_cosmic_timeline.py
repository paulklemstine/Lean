#!/usr/bin/env python3
"""
Demo 1: The Cosmic Eschatological Timeline
==========================================
Visualizes the full timeline of the universe from the Big Bang to Heat Death,
spanning over 10^100 years on a logarithmic scale.

Oracle Chronos & Oracle Cosmos contributed to this visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap

# ============================================================
# Data: Cosmic Timeline Events
# ============================================================

events = [
    # (log10(years from Big Bang), label, description)
    (-43, "Planck epoch", "Quantum gravity dominates"),
    (-36, "Inflation", "Exponential expansion begins"),
    (-32, "Inflation ends", "Reheating; matter created"),
    (-6, "Quark epoch", "Quarks and gluons; QGP"),
    (0, "Nucleosynthesis", "First atomic nuclei form"),  # ~3 minutes ≈ 10^0 minutes
    (5.6, "Recombination", "First atoms; CMB released"),  # ~380,000 yr
    (8.1, "First stars", "Population III stars ignite"),  # ~100 Myr
    (8.6, "First galaxies", "Protogalaxies form"),  # ~400 Myr
    (9.1, "Reionization", "UV light reionizes hydrogen"),  # ~1 Gyr
    (10.14, "NOW", "Present day (13.8 Gyr)"),
    (10.3, "Sun dies", "Sun becomes white dwarf"),  # ~5 Gyr from now
    (11, "Galaxy mergers end", "Local Group merges into one galaxy"),
    (14, "Last stars die", "Smallest red dwarfs burn out"),
    (15, "Degenerate era", "White dwarfs, neutron stars cool"),
    (25, "Galaxies dissolve", "Gravitational evaporation of stellar remnants"),
    (37, "Dark matter decays?", "If dark matter is metastable"),
    (40, "Proton decay", "Baryonic matter dissolves (GUT prediction)"),
    (65, "BH era begins", "Black holes dominate mass-energy"),
    (67, "Stellar BHs evaporate", "~1 M☉ black holes → Hawking radiation"),
    (87, "Sgr A* evaporates", "Central supermassive BH of Milky Way"),
    (100, "Largest BHs evaporate", "10^10 M☉ monsters finally die"),
    (106, "Last BH gone", "Universe: photons, leptons, emptiness"),
    (120, "Lloyd's limit", "Max computations in observable universe"),
]

# Eras with color bands
eras = [
    (-43, -32, "Planck/Inflation", "#FF6B6B"),
    (-32, 5.6, "Radiation Era", "#FFA07A"),
    (5.6, 10.14, "Stelliferous (past)", "#FFD700"),
    (10.14, 14, "Stelliferous (future)", "#ADFF2F"),
    (14, 40, "Degenerate Era", "#87CEEB"),
    (40, 100, "Black Hole Era", "#9370DB"),
    (100, 130, "Dark/Photon Era", "#2F2F4F"),
]

# ============================================================
# Visualization
# ============================================================

fig, ax = plt.subplots(figsize=(20, 12))
fig.patch.set_facecolor('#0a0a1a')
ax.set_facecolor('#0a0a1a')

# Draw era bands
for start, end, name, color in eras:
    ax.axhspan(start, end, alpha=0.15, color=color, zorder=0)
    mid = (start + end) / 2
    ax.text(-0.3, mid, name, fontsize=9, color=color, alpha=0.8,
            ha='right', va='center', fontweight='bold',
            transform=ax.get_yaxis_transform())

# Draw timeline spine
ax.axvline(x=0.5, color='white', alpha=0.3, linewidth=2, zorder=1)

# Plot events
for i, (log_t, label, desc) in enumerate(events):
    side = 1 if i % 2 == 0 else -1
    x_text = 0.5 + side * 0.25
    
    # Color based on era
    if log_t < -32:
        color = '#FF6B6B'
    elif log_t < 5.6:
        color = '#FFA07A'
    elif log_t < 14:
        color = '#FFD700'
    elif log_t < 40:
        color = '#87CEEB'
    elif log_t < 100:
        color = '#9370DB'
    else:
        color = '#708090'
    
    # Special highlight for "NOW"
    if label == "NOW":
        color = '#00FF00'
        ax.axhline(y=log_t, color='#00FF00', alpha=0.3, linewidth=1, linestyle='--')
        marker_size = 12
    else:
        marker_size = 8
    
    # Event marker on spine
    ax.plot(0.5, log_t, 'o', color=color, markersize=marker_size, zorder=5)
    
    # Connection line
    ax.plot([0.5, x_text - side*0.02], [log_t, log_t], 
            color=color, alpha=0.5, linewidth=1, zorder=3)
    
    # Text
    ha = 'left' if side > 0 else 'right'
    ax.text(x_text, log_t, f"{label}", fontsize=10, color=color,
            ha=ha, va='center', fontweight='bold', zorder=6)
    ax.text(x_text, log_t - 1.2, f"10^{{{log_t:.0f}}} yr: {desc}", 
            fontsize=7, color=color, alpha=0.6, ha=ha, va='center', zorder=6)

# Labels and formatting
ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-50, 130)
ax.set_ylabel('log₁₀(time in years since Big Bang)', fontsize=14, color='white')
ax.set_title('The Complete Cosmic Timeline\nFrom Planck Time to Heat Death', 
             fontsize=18, color='white', fontweight='bold', pad=20)
ax.set_xticks([])
ax.tick_params(colors='white', labelsize=11)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(False)
ax.spines['left'].set_color('white')
ax.spines['left'].set_alpha(0.3)

# Add heat death annotation
ax.annotate('← Heat Death: 10^(10^76) years\n   (off the chart by a factor of 10^76)', 
            xy=(0.5, 125), fontsize=11, color='#708090',
            ha='center', style='italic')

# Subtitle
fig.text(0.5, 0.02, 
         'The universe is a brief flicker of complexity between two eternities of simplicity.',
         ha='center', fontsize=12, color='white', alpha=0.5, style='italic')

plt.tight_layout()
plt.savefig('/workspace/request-project/demos/output/cosmic_timeline.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 1: Cosmic Timeline saved to demos/output/cosmic_timeline.png")
