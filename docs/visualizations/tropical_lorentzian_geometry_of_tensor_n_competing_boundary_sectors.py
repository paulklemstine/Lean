#!/usr/bin/env python3
"""
Visualization 3: Competing Boundary Sectors in 1D

Visualizes the tropical polynomial evaluation for a 1D boundary measurement
datum. Each affine function c(m) + m·x corresponds to a monomial/sector.
The tropical polynomial is the pointwise minimum (lower envelope). 
Tropical hypersurface points are where two lines cross at the minimum —
exactly the "competing sectors" of Theorems 2-3.
"""

import numpy as np
import matplotlib.pyplot as plt


# Define 1D boundary measurement data
support = [(0,), (1,), (2,), (3,)]
coeff = {
    (0,): 3.0,   # constant sector
    (1,): 1.5,   # linear sector  
    (2,): 0.5,   # quadratic sector
    (3,): 0.0,   # cubic sector
}

colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12']
labels = ['Sector m=0', 'Sector m=1', 'Sector m=2', 'Sector m=3']

# Compute weight evaluations
x_range = np.linspace(-3, 3, 1000)

fig, axes = plt.subplots(2, 1, figsize=(12, 9), height_ratios=[3, 1])

# Top panel: affine functions and lower envelope
ax1 = axes[0]

all_weights = []
for idx, m in enumerate(support):
    weights = [coeff[m] + m[0] * x for x in x_range]
    all_weights.append(weights)
    ax1.plot(x_range, weights, color=colors[idx], linewidth=1.5, 
             alpha=0.5, linestyle='--', label=labels[idx])

# Lower envelope (tropical polynomial)
all_weights = np.array(all_weights)
tropical_min = np.min(all_weights, axis=0)
dominant_sector = np.argmin(all_weights, axis=0)

# Draw lower envelope with color indicating dominant sector
for idx in range(len(support)):
    mask = dominant_sector == idx
    # Find contiguous regions
    segments = np.where(mask)[0]
    if len(segments) == 0:
        continue
    # Split into contiguous groups
    breaks = np.where(np.diff(segments) > 1)[0] + 1
    groups = np.split(segments, breaks)
    for g in groups:
        if len(g) > 1:
            ax1.plot(x_range[g], tropical_min[g], color=colors[idx], 
                     linewidth=3.5, solid_capstyle='round')

# Mark hypersurface points (crossings at the minimum)
hypersurface_x = []
for i in range(len(x_range) - 1):
    if dominant_sector[i] != dominant_sector[i + 1]:
        # Interpolate the crossing point
        x_cross = (x_range[i] + x_range[i + 1]) / 2
        y_cross = tropical_min[i]
        hypersurface_x.append((x_cross, y_cross, 
                              dominant_sector[i], dominant_sector[i+1]))

for x_c, y_c, s1, s2 in hypersurface_x:
    ax1.plot(x_c, y_c, 'ko', markersize=12, zorder=5)
    ax1.plot(x_c, y_c, 'w*', markersize=8, zorder=6)
    ax1.annotate(f'{labels[s1].split("=")[1]}/{labels[s2].split("=")[1]} tie',
                 xy=(x_c, y_c), xytext=(x_c + 0.3, y_c + 1.0),
                 fontsize=9, fontweight='bold',
                 arrowprops=dict(arrowstyle='->', color='black', lw=1.5),
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))

ax1.set_ylabel('Tropical weight', fontsize=13)
ax1.set_title('Competing Boundary Sectors: Tropical Polynomial as Lower Envelope',
              fontsize=14, fontweight='bold')
ax1.legend(loc='upper left', fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 3)

# Bottom panel: tropical gap
ax2 = axes[1]
gaps = []
for i in range(len(x_range)):
    weights_at_x = all_weights[:, i]
    sorted_w = np.sort(weights_at_x)
    gap = sorted_w[1] - sorted_w[0]
    gaps.append(gap)

ax2.fill_between(x_range, 0, gaps, alpha=0.3, color='purple')
ax2.plot(x_range, gaps, color='purple', linewidth=2, label='Tropical gap')

# Mark hypersurface points
for x_c, y_c, s1, s2 in hypersurface_x:
    ax2.axvline(x=x_c, color='red', linestyle=':', alpha=0.7, linewidth=1.5)
    ax2.plot(x_c, 0, 'rv', markersize=10, zorder=5)

ax2.set_xlabel('Tropical parameter x', fontsize=13)
ax2.set_ylabel('Gap', fontsize=13)
ax2.set_title('Tropical Gap (Zero = Hypersurface Point = Entanglement Ambiguity)',
              fontsize=12, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-3, 3)
ax2.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('competing_sectors.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved competing_sectors.png")
print(f"\nHypersurface points found: {len(hypersurface_x)}")
for x_c, y_c, s1, s2 in hypersurface_x:
    print(f"  x ≈ {x_c:.3f}: sectors m={support[s1][0]} and m={support[s2][0]} compete "
          f"(weight ≈ {y_c:.3f})")
