#!/usr/bin/env python3
"""
Visualization: Spectral Phase Transition in Certification

Visualizes the sharp certification threshold p* = Δ/(2σ) showing how the
residual spectral gap transitions from positive (certifiable) to negative
(uncertifiable) at the critical perturbation strength. The plot shows
multiple noise scales to demonstrate antitonicity: larger noise → earlier transition.
"""

import numpy as np
import matplotlib.pyplot as plt

# Core functions (self-contained)
def certification_residual_gap(delta, p, sigma):
    return delta - 2 * p * sigma

def cert_threshold(delta, sigma):
    if sigma <= 0:
        return float('inf')
    return delta / (2 * sigma)

# Parameters
delta = 2.0  # spectral gap
sigma_values = [0.5, 1.0, 2.0, 4.0]
colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Residual gap vs perturbation strength
ax1 = axes[0]
for sigma, color in zip(sigma_values, colors):
    p_star = cert_threshold(delta, sigma)
    p_values = np.linspace(0, 3, 300)
    gaps = [certification_residual_gap(delta, p, sigma) for p in p_values]

    ax1.plot(p_values, gaps, color=color, linewidth=2, label=f'σ = {sigma}')
    ax1.axvline(x=p_star, color=color, linestyle='--', alpha=0.5, linewidth=1)
    ax1.plot(p_star, 0, 'o', color=color, markersize=8, zorder=5)

ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
ax1.fill_between([0, 3], [0, 0], [-8, -8], alpha=0.05, color='red')
ax1.fill_between([0, 3], [0, 0], [4, 4], alpha=0.05, color='green')
ax1.set_xlabel('Perturbation strength p', fontsize=13)
ax1.set_ylabel('Residual gap Δ − 2pσ', fontsize=13)
ax1.set_title('Phase Transition in Certification', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11, loc='upper right')
ax1.set_xlim(0, 3)
ax1.set_ylim(-6, 3)
ax1.text(0.15, 1.5, 'CERTIFIED\n(stable phase)', fontsize=11, color='green',
         fontweight='bold', ha='center')
ax1.text(2.5, -4, 'UNCERTIFIED\n(gap destroyed)', fontsize=11, color='red',
         fontweight='bold', ha='center')
ax1.grid(True, alpha=0.3)

# Right panel: Threshold vs noise scale
ax2 = axes[1]
sigma_range = np.linspace(0.1, 5, 200)
for delta_val, color, ls in zip([1.0, 2.0, 4.0], ['#e67e22', '#2980b9', '#27ae60'],
                                  ['-', '-', '-']):
    thresholds = [cert_threshold(delta_val, s) for s in sigma_range]
    ax2.plot(sigma_range, thresholds, color=color, linewidth=2,
             linestyle=ls, label=f'Δ = {delta_val}')

ax2.set_xlabel('Noise norm σ', fontsize=13)
ax2.set_ylabel('Certification threshold p*', fontsize=13)
ax2.set_title('Threshold: Monotone in Δ, Antitone in σ', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_xlim(0.1, 5)
ax2.set_ylim(0, 5)
ax2.grid(True, alpha=0.3)

# Add annotation about the formula
ax2.annotate(r'$p^* = \frac{\Delta}{2\sigma}$',
             xy=(2.5, cert_threshold(4.0, 2.5)), xytext=(3.5, 3.5),
             fontsize=14, ha='center',
             arrowprops=dict(arrowstyle='->', color='#27ae60'),
             color='#27ae60', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_phase_transition.png")
