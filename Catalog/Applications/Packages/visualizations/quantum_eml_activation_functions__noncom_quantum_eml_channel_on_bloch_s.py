#!/usr/bin/env python3
"""
Visualization: Quantum EML Channel Action on the Bloch Sphere

Shows how the QEML channel ρ → exp(h)·ρ·exp(-h) rotates quantum states
on the Bloch sphere, with different generator matrices h.
"""

import numpy as np
from scipy.linalg import expm
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def bloch_vector(rho):
    """Extract Bloch vector (rx, ry, rz) from 2x2 density matrix."""
    sx = np.array([[0, 1], [1, 0]], dtype=complex)
    sy = np.array([[0, -1j], [1j, 0]], dtype=complex)
    sz = np.array([[1, 0], [0, -1]], dtype=complex)
    rx = np.real(np.trace(rho @ sx))
    ry = np.real(np.trace(rho @ sy))
    rz = np.real(np.trace(rho @ sz))
    return rx, ry, rz

def qeml_channel(h, rho):
    E = expm(h)
    Em = expm(-h)
    return E @ rho @ Em

sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

# Generate initial states on the Bloch sphere
n_states = 50
phi = np.linspace(0, 2*np.pi, n_states)
theta = np.linspace(0, np.pi, n_states)
initial_bloch = []
for t in theta[1:-1:3]:
    for p in phi[::3]:
        rx = np.sin(t) * np.cos(p)
        ry = np.sin(t) * np.sin(p)
        rz = np.cos(t)
        initial_bloch.append((rx, ry, rz))

# Different QEML channels
channels = {
    r'$h = 0.5i\sigma_z$ (Z-rotation)': 0.5j * sigma_z,
    r'$h = 0.3i\sigma_x$ (X-rotation)': 0.3j * sigma_x,
    r'$h = 0.4i(\sigma_x + \sigma_z)$ (Mixed)': 0.4j * (sigma_x + sigma_z),
}

fig = plt.figure(figsize=(15, 5))

for idx, (label, h) in enumerate(channels.items()):
    ax = fig.add_subplot(1, 3, idx + 1, projection='3d')

    # Draw Bloch sphere wireframe
    u = np.linspace(0, 2 * np.pi, 30)
    v = np.linspace(0, np.pi, 20)
    xs = np.outer(np.cos(u), np.sin(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    # Plot initial and transformed states
    for rx, ry, rz in initial_bloch:
        rho = 0.5 * (I2 + rx * sigma_x + ry * sigma_y + rz * sigma_z)
        rho_out = qeml_channel(h, rho)
        rx2, ry2, rz2 = bloch_vector(rho_out)

        ax.scatter(rx, ry, rz, c='blue', s=15, alpha=0.4)
        ax.scatter(rx2, ry2, rz2, c='red', s=15, alpha=0.6)
        ax.plot([rx, rx2], [ry, ry2], [rz, rz2], 'k-', alpha=0.1, linewidth=0.5)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_title(label, fontsize=10)
    ax.set_xlim([-1.1, 1.1])
    ax.set_ylim([-1.1, 1.1])
    ax.set_zlim([-1.1, 1.1])

plt.suptitle('Quantum EML Channel: Bloch Sphere Rotations', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('channel_bloch_sphere.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved channel_bloch_sphere.png")
