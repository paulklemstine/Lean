#!/usr/bin/env python3
"""
Visualization: Tropical Exchange Gap Landscape

This script visualizes the relationship between tropical exchange slack
and the Lorentzian determinant condition for 2×2 exp-weight matrices.

It produces a heatmap showing how the determinant gap (det₂) varies as a
function of the diagonal weight w₀₀ and the off-diagonal weight w₀₁,
with the exchange slack δ = 2w₀₁ - w₀₀ - w₁₁ overlaid as contour lines.
The zero contour (δ = 0) marks the Lorentzian boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Parameters
w11 = 1.0  # Fix w₁₁ = 1

w00_range = np.linspace(-2, 4, 300)
w01_range = np.linspace(-1, 5, 300)
W00, W01 = np.meshgrid(w00_range, w01_range)

# Exchange slack: δ = 2·w₀₁ - w₀₀ - w₁₁
Delta = 2 * W01 - W00 - w11

# det₂ = exp(w₀₁)² - exp(w₀₀)·exp(w₁₁) = exp(w₀₀+w₁₁)·(exp(δ)-1)
Det2 = np.exp(W00 + w11) * (np.exp(Delta) - 1)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Exchange slack δ
ax1 = axes[0]
im1 = ax1.contourf(W00, W01, Delta, levels=30, cmap='RdYlGn')
ax1.contour(W00, W01, Delta, levels=[0], colors='black', linewidths=2)
ax1.set_xlabel('w₀₀ (diagonal weight)', fontsize=12)
ax1.set_ylabel('w₀₁ (off-diagonal weight)', fontsize=12)
ax1.set_title('Exchange Slack δ = 2w₀₁ - w₀₀ - w₁₁', fontsize=13)
plt.colorbar(im1, ax=ax1, label='δ')
ax1.annotate('Lorentzian\n(δ ≥ 0)', xy=(0, 2.5), fontsize=11,
             ha='center', color='darkgreen', fontweight='bold')
ax1.annotate('Non-Lorentzian\n(δ < 0)', xy=(3, 1), fontsize=11,
             ha='center', color='darkred', fontweight='bold')

# Plot 2: det₂ (Lorentzian determinant)
ax2 = axes[1]
# Use symmetric log scale for det₂
vmax = np.percentile(np.abs(Det2), 95)
norm = mcolors.SymLogNorm(linthresh=1, vmin=-vmax, vmax=vmax)
im2 = ax2.contourf(W00, W01, Det2, levels=30, cmap='coolwarm', norm=norm)
ax2.contour(W00, W01, Det2, levels=[0], colors='black', linewidths=2)
ax2.set_xlabel('w₀₀ (diagonal weight)', fontsize=12)
ax2.set_ylabel('w₀₁ (off-diagonal weight)', fontsize=12)
ax2.set_title('det₂ = exp(w₀₁)² - exp(w₀₀)exp(w₁₁)', fontsize=13)
plt.colorbar(im2, ax=ax2, label='det₂')

# Plot 3: Stability margin as function of δ
ax3 = axes[2]
delta_vals = np.linspace(-3, 5, 500)
det2_from_delta = np.exp(2 + w11) * (np.exp(delta_vals) - 1)  # w₀₀ = 2 fixed
log_stability = np.log(np.maximum(det2_from_delta, 1e-10))

ax3.plot(delta_vals, det2_from_delta, 'b-', linewidth=2, label='det₂(δ)')
ax3.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
ax3.axvline(x=0, color='r', linewidth=1.5, linestyle='--', label='δ = 0 (boundary)')
ax3.fill_between(delta_vals, det2_from_delta, 0,
                 where=(delta_vals >= 0), alpha=0.15, color='green',
                 label='Lorentzian region')
ax3.fill_between(delta_vals, det2_from_delta, 0,
                 where=(delta_vals < 0), alpha=0.15, color='red',
                 label='Non-Lorentzian')
ax3.set_xlabel('Exchange Slack δ', fontsize=12)
ax3.set_ylabel('det₂', fontsize=12)
ax3.set_title('det₂ vs Exchange Slack (w₀₀=2)', fontsize=13)
ax3.set_ylim(-50, 150)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Tropical Shadows: Exchange Slack Controls Lorentzian Stability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_gap_landscape.png")
