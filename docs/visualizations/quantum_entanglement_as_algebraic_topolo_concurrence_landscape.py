#!/usr/bin/env python3
"""
Visualization 1: Concurrence Landscape of Two-Qubit States

Visualizes the concurrence (entanglement measure) as a heatmap over the space
of two-qubit states parametrized by two angles. Shows how entanglement varies
continuously from product states (C=0) to maximally entangled Bell states (C=1).
"""

import numpy as np
import matplotlib.pyplot as plt

# Parametrize states as: |ψ(θ,φ)⟩ = cos(θ)|00⟩ + sin(θ)(cos(φ)|01⟩ + sin(φ)|10⟩)
# Actually let's use a more interesting parametrization:
# |ψ⟩ = cos(θ)|00⟩ + e^{iφ}sin(θ)|11⟩
# This sweeps from product state |00⟩ (θ=0) through Bell state (θ=π/4) to |11⟩ (θ=π/2)

theta_vals = np.linspace(0, np.pi/2, 200)
phi_vals = np.linspace(0, 2*np.pi, 200)
THETA, PHI = np.meshgrid(theta_vals, phi_vals)

# Compute concurrence for each (θ, φ)
# State: α = cos(θ), β = 0, γ = 0, δ = e^{iφ}sin(θ)
# det = αδ - βγ = cos(θ)·e^{iφ}·sin(θ)
# C = 2|det| = 2·cos(θ)·sin(θ) = sin(2θ)
C = np.sin(2 * THETA)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap
ax1 = axes[0]
im = ax1.pcolormesh(np.degrees(THETA), np.degrees(PHI), C,
                     cmap='magma', shading='auto')
ax1.set_xlabel('θ (degrees)', fontsize=12)
ax1.set_ylabel('φ (degrees)', fontsize=12)
ax1.set_title('Concurrence Landscape\n|ψ⟩ = cos(θ)|00⟩ + e^{iφ}sin(θ)|11⟩', fontsize=13)
plt.colorbar(im, ax=ax1, label='Concurrence C(ψ)')

# Mark special states
ax1.axhline(y=0, color='cyan', linestyle='--', alpha=0.5, label='φ = 0')
ax1.plot(45, 0, 'w*', markersize=15, label='Bell state |Φ+⟩')
ax1.legend(loc='upper right', fontsize=9)

# Cross-section at φ = 0
ax2 = axes[1]
c_slice = np.sin(2 * theta_vals)
ax2.plot(np.degrees(theta_vals), c_slice, 'b-', linewidth=2, label='C(θ) = sin(2θ)')
ax2.fill_between(np.degrees(theta_vals), 0, c_slice, alpha=0.2, color='blue')
ax2.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Maximum C = 1')
ax2.axvline(x=45, color='g', linestyle='--', alpha=0.5, label='θ = 45° (Bell state)')

# Mark AM-GM bound region
amgm = np.cos(theta_vals)**2 / 2 + np.sin(theta_vals)**2 / 2  # = 1/2 always for this parametrization
ax2.plot(np.degrees(theta_vals), 2 * amgm * np.ones_like(theta_vals),
         'r:', linewidth=1.5, label='AM-GM bound = 1')

ax2.set_xlabel('θ (degrees)', fontsize=12)
ax2.set_ylabel('Concurrence', fontsize=12)
ax2.set_title('Entanglement vs. Mixing Angle\n(cross-section at φ = 0)', fontsize=13)
ax2.legend(fontsize=9)
ax2.set_xlim(0, 90)
ax2.set_ylim(-0.05, 1.1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('concurrence_landscape.png', dpi=150, bbox_inches='tight')
print("Saved concurrence_landscape.png")
