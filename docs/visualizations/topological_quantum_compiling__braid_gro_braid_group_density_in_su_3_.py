"""
Visualization 3: Density of Braid Group Image in SU(3)
======================================================

Visualizes the density of the braid group image in SU(3) by projecting
random braid word products onto a 2D subspace. If the image is dense,
the projected points should fill a region uniformly. This provides
visual evidence for the universality conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt

# Braid generator matrices
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

generators = [sigma1, sigma2, sigma3]
inv_generators = [np.linalg.inv(g) for g in generators]
all_mats = generators + inv_generators

# Generate random braid words and collect the (0,0) matrix entries
np.random.seed(42)
n_samples = 20000

# Collect points for different word lengths
fig, axes = plt.subplots(1, 3, figsize=(18, 6))
lengths = [5, 15, 40]
colors = ['#e74c3c', '#3498db', '#2ecc71']

for ax_idx, (max_len, color) in enumerate(zip(lengths, colors)):
    points_real = []
    points_imag = []

    for _ in range(n_samples):
        length = max_len
        indices = np.random.randint(0, 6, size=length)
        mat = np.eye(3, dtype=complex)
        for idx in indices:
            mat = mat @ all_mats[idx]

        # Project to (0,0) entry (a complex number on the unit disk)
        z = mat[0, 0]
        points_real.append(z.real)
        points_imag.append(z.imag)

    ax = axes[ax_idx]
    ax.scatter(points_real, points_imag, s=0.5, alpha=0.3, color=color)

    # Draw unit circle
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1, alpha=0.3)

    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    ax.set_aspect('equal')
    ax.set_xlabel('Re(U₀₀)', fontsize=12)
    ax.set_ylabel('Im(U₀₀)', fontsize=12)
    ax.set_title(f'Word length = {max_len}\n({n_samples} samples)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.2)

fig.suptitle('Density of Braid Group Image in SU(3)\n'
             'Projection of ρ₅(w) onto the (0,0) matrix entry',
             fontsize=15, fontweight='bold', y=1.05)
plt.tight_layout()
plt.savefig('viz_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_density.png")
