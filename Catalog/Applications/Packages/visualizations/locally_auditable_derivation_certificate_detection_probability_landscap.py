#!/usr/bin/env python3
"""
Visualization: Defect Detection Heatmap

Visualizes the detection probability as a function of both defect density and
number of audit rounds. This creates a heatmap showing the "detection landscape"
— the probability of catching at least one defective step across different
parameter regimes.

Demonstrates Theorem 2 (detection count bound) combined with Theorem 3
(exponential amplification): the probability of detecting a defect of density δ
after k rounds is at least 1 - (1-δ)^k.
"""

import numpy as np
import matplotlib.pyplot as plt

# ── Compute detection probability surface ──

densities = np.linspace(0.01, 0.50, 50)
rounds = np.arange(1, 41)

# Detection probability: P(detect) = 1 - (1-δ)^k
D, K = np.meshgrid(densities, rounds)
detection_prob = 1 - (1 - D) ** K

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ── Panel 1: Heatmap ──
ax1 = axes[0]
im = ax1.pcolormesh(densities * 100, rounds, detection_prob,
                     cmap='YlOrRd', shading='auto', vmin=0, vmax=1)
plt.colorbar(im, ax=ax1, label='Detection Probability')

# Add contour lines
contours = ax1.contour(densities * 100, rounds, detection_prob,
                        levels=[0.5, 0.9, 0.95, 0.99],
                        colors='black', linewidths=1)
ax1.clabel(contours, inline=True, fontsize=9, fmt='%.2f')

ax1.set_xlabel('Defect Density (%)', fontsize=12)
ax1.set_ylabel('Number of Audit Rounds', fontsize=12)
ax1.set_title('Detection Probability Landscape', fontsize=14, fontweight='bold')

# ── Panel 2: Detection curves for fixed densities ──
ax2 = axes[1]
highlight_densities = [0.02, 0.05, 0.10, 0.20, 0.35]
colors = plt.cm.plasma(np.linspace(0.15, 0.85, len(highlight_densities)))

for i, d in enumerate(highlight_densities):
    probs = [1 - (1-d)**k for k in rounds]
    ax2.plot(rounds, probs, '-', color=colors[i], linewidth=2,
             label=f'δ = {d:.0%}')
    # Mark 95% threshold
    k95 = next((k for k in rounds if 1-(1-d)**k >= 0.95), None)
    if k95 and k95 <= 40:
        ax2.plot(k95, 0.95, 'o', color=colors[i], markersize=8, zorder=5)

ax2.axhline(y=0.95, color='gray', linestyle='--', alpha=0.5, label='95% threshold')
ax2.set_xlabel('Number of Audit Rounds', fontsize=12)
ax2.set_ylabel('Detection Probability', fontsize=12)
ax2.set_title('Detection Curves by Defect Density', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 41)
ax2.set_ylim(0, 1.05)

# ── Panel 3: Rounds needed for various confidence levels ──
ax3 = axes[2]
conf_levels = [0.50, 0.90, 0.95, 0.99, 0.999]
density_range = np.linspace(0.01, 0.5, 200)
colors3 = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(conf_levels)))

for i, conf in enumerate(conf_levels):
    k_needed = np.log(1 - conf) / np.log(1 - density_range)
    ax3.plot(density_range * 100, k_needed, '-', color=colors3[i], linewidth=2,
             label=f'{conf:.1%} confidence')

ax3.set_xlabel('Defect Density (%)', fontsize=12)
ax3.set_ylabel('Rounds Required', fontsize=12)
ax3.set_title('Cost of Confidence', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0, 50)
ax3.set_ylim(0, 80)

plt.tight_layout()
plt.savefig('viz_detection.png', dpi=150, bbox_inches='tight')
print("Saved viz_detection.png")
