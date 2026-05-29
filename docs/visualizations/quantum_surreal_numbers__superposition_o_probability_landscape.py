"""
Visualization: Quantum State Probability Landscape
===================================================

Visualizes the probability distribution of a parameterized quantum state
|ψ(θ,φ)⟩ = cos(θ)|0⟩ + sin(θ)e^{iφ}|1⟩ on the Bloch sphere,
showing how the Born rule maps amplitudes to probabilities.

The heatmap shows P(0) = cos²(θ) as a function of θ and φ,
demonstrating that probability depends only on |amplitude|, not phase.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
theta = np.linspace(0, np.pi, 200)
phi = np.linspace(0, 2*np.pi, 200)
THETA, PHI = np.meshgrid(theta, phi)

# Probability of outcome 0: P(0) = |cos(θ)|² = cos²(θ)
P0 = np.cos(THETA)**2

# Probability of outcome 1: P(1) = |sin(θ)|² = sin²(θ)
P1 = np.sin(THETA)**2

# Shannon entropy: H = -P0*log(P0) - P1*log(P1)
H = np.zeros_like(P0)
mask0 = P0 > 1e-15
mask1 = P1 > 1e-15
H[mask0] -= P0[mask0] * np.log(P0[mask0])
H[mask1] -= P1[mask1] * np.log(P1[mask1])

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: P(0) heatmap
im0 = axes[0].pcolormesh(theta, phi, P0, cmap='viridis', shading='auto')
axes[0].set_xlabel('θ (polar angle)', fontsize=12)
axes[0].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[0].set_title('P(|0⟩) = cos²(θ)\nBorn Rule Probability', fontsize=13)
plt.colorbar(im0, ax=axes[0], label='Probability')
axes[0].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[0].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[0].set_yticks([0, np.pi, 2*np.pi])
axes[0].set_yticklabels(['0', 'π', '2π'])

# Plot 2: Entropy heatmap
im1 = axes[1].pcolormesh(theta, phi, H, cmap='inferno', shading='auto')
axes[1].set_xlabel('θ (polar angle)', fontsize=12)
axes[1].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[1].set_title('Shannon Entropy H(ψ)\nMaximum at Equal Superposition', fontsize=13)
plt.colorbar(im1, ax=axes[1], label='Entropy (nats)')
axes[1].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[1].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[1].set_yticks([0, np.pi, 2*np.pi])
axes[1].set_yticklabels(['0', 'π', '2π'])

# Plot 3: Tropical cost of P(0)
TC = np.full_like(P0, np.nan)
TC[mask0] = -np.log(P0[mask0])
im2 = axes[2].pcolormesh(theta, phi, TC, cmap='plasma', shading='auto',
                          vmin=0, vmax=5)
axes[2].set_xlabel('θ (polar angle)', fontsize=12)
axes[2].set_ylabel('φ (azimuthal angle)', fontsize=12)
axes[2].set_title('Tropical Cost = −log P(|0⟩)\nQuantum-Tropical Bridge', fontsize=13)
plt.colorbar(im2, ax=axes[2], label='Tropical cost')
axes[2].set_xticks([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
axes[2].set_xticklabels(['0', 'π/4', 'π/2', '3π/4', 'π'])
axes[2].set_yticks([0, np.pi, 2*np.pi])
axes[2].set_yticklabels(['0', 'π', '2π'])

fig.suptitle('Quantum Surreal Numbers: Probability, Entropy, and Tropical Cost',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_probability_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_probability_landscape.png")
