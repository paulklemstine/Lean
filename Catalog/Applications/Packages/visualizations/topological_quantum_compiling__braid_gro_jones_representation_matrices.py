"""
Visualization 2: Jones Representation Matrices
===============================================

Visualizes the 3x3 unitary matrices representing braid generators
σ₁, σ₂, σ₃ in the Fibonacci anyon model (k=5, B_4). Shows both
the magnitude and phase structure, revealing the topological quantum
gate structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize

# Compute braid generator matrices
phi = (1 + np.sqrt(5)) / 2
tau = 1 / phi

r_1 = np.exp(-4j * np.pi / 5)
r_tau = np.exp(3j * np.pi / 5)

F = np.array([
    [tau, np.sqrt(tau)],
    [np.sqrt(tau), -tau]
], dtype=complex)

R_diag = np.diag([r_tau, r_1])

sigma1 = np.zeros((3, 3), dtype=complex)
sigma1[0, 0] = r_tau
sigma1[1:, 1:] = F @ R_diag @ np.linalg.inv(F)

sigma2 = np.zeros((3, 3), dtype=complex)
sigma2[:2, :2] = F @ R_diag @ np.linalg.inv(F)
sigma2[2, 2] = r_tau

sigma3 = np.zeros((3, 3), dtype=complex)
sigma3[0, 0] = r_tau
sigma3[1, 1] = r_tau
sigma3[2, 2] = r_1

matrices = [sigma1, sigma2, sigma3]
names = ['σ₁', 'σ₂', 'σ₃']

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for col, (mat, name) in enumerate(zip(matrices, names)):
    # Top row: magnitude
    ax_mag = axes[0, col]
    mag = np.abs(mat)
    im = ax_mag.imshow(mag, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
    ax_mag.set_title(f'|{name}| (magnitude)', fontsize=13, fontweight='bold')
    for i in range(3):
        for j in range(3):
            ax_mag.text(j, i, f'{mag[i,j]:.3f}', ha='center', va='center',
                       fontsize=11, color='black' if mag[i,j] < 0.5 else 'white')
    ax_mag.set_xticks(range(3))
    ax_mag.set_yticks(range(3))
    plt.colorbar(im, ax=ax_mag, shrink=0.8)

    # Bottom row: phase (in units of π)
    ax_phase = axes[1, col]
    phase = np.angle(mat) / np.pi
    # Mask near-zero entries
    mask = np.abs(mat) > 0.01
    phase_display = np.where(mask, phase, np.nan)
    im2 = ax_phase.imshow(phase_display, cmap='hsv', vmin=-1, vmax=1, aspect='equal')
    ax_phase.set_title(f'arg({name})/π (phase)', fontsize=13, fontweight='bold')
    for i in range(3):
        for j in range(3):
            if mask[i, j]:
                ax_phase.text(j, i, f'{phase[i,j]:.3f}π', ha='center', va='center',
                             fontsize=10, color='black',
                             bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.7))
    ax_phase.set_xticks(range(3))
    ax_phase.set_yticks(range(3))
    plt.colorbar(im2, ax=ax_phase, shrink=0.8)

fig.suptitle('Jones Representation: Fibonacci Anyon Braid Matrices (k=5, B₄)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_braid_matrices.png', dpi=150, bbox_inches='tight')
print("Saved viz_braid_matrices.png")
