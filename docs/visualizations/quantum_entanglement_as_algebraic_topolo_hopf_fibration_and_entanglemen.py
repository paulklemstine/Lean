#!/usr/bin/env python3
"""
Visualization 3: The Hopf Fibration and Entanglement

Visualizes the Hopf fibration S³ → S² (the lower-dimensional analogue of the
S⁷ → S⁴ fibration relevant to two-qubit entanglement). Shows how linked
circles in S³ correspond to entangled states and unlinked circles correspond
to product states. This is the topological essence of quantum entanglement.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def hopf_inverse(eta, xi, t_values):
    """Compute a Hopf fiber on S³ projected to R³ via stereographic projection.

    The Hopf map S³ → S² sends (z₁, z₂) ∈ S³ ⊂ ℂ² to z₁/z₂ ∈ S².
    Given a point (η, ξ) on S² (in spherical coordinates), this computes
    the preimage circle.

    Args:
        eta: polar angle on S² (0 to π)
        xi: azimuthal angle on S² (0 to 2π)
        t_values: parameter for the circle (0 to 2π)

    Returns:
        (x, y, z) arrays of the stereographically projected circle
    """
    a = np.cos(eta / 2)
    b = np.sin(eta / 2)

    x = np.zeros_like(t_values)
    y = np.zeros_like(t_values)
    z = np.zeros_like(t_values)

    for i, t in enumerate(t_values):
        # Point on S³: (a·e^{it}, b·e^{i(t+ξ)})
        z1 = a * np.exp(1j * t)
        z2 = b * np.exp(1j * (t + xi))

        # Stereographic projection from S³ to R³
        # (w, x, y, z) → (x, y, z) / (1 - w)
        w = z1.real
        x_s3 = z1.imag
        y_s3 = z2.real
        z_s3 = z2.imag

        denom = 1 - w
        if abs(denom) < 1e-10:
            denom = 1e-10

        x[i] = x_s3 / denom
        y[i] = y_s3 / denom
        z[i] = z_s3 / denom

    return x, y, z

t = np.linspace(0, 2 * np.pi, 300)

fig = plt.figure(figsize=(16, 6))

# Panel 1: Linked circles (entangled state)
ax1 = fig.add_subplot(131, projection='3d')

# Two Hopf fibers over nearby points → linked circles
x1, y1, z1 = hopf_inverse(np.pi/2, 0, t)
x2, y2, z2 = hopf_inverse(np.pi/2, np.pi, t)

ax1.plot(x1, y1, z1, 'b-', linewidth=2, label='Fiber 1', alpha=0.9)
ax1.plot(x2, y2, z2, 'r-', linewidth=2, label='Fiber 2', alpha=0.9)

ax1.set_title('Linked Circles\n(Entangled State, C = 1)', fontsize=12, fontweight='bold')
ax1.set_xlabel('x'); ax1.set_ylabel('y'); ax1.set_zlabel('z')
lim = 3
ax1.set_xlim(-lim, lim); ax1.set_ylim(-lim, lim); ax1.set_zlim(-lim, lim)
ax1.legend(fontsize=9)

# Panel 2: Multiple fibers showing the structure
ax2 = fig.add_subplot(132, projection='3d')

colors = plt.cm.rainbow(np.linspace(0, 1, 8))
for i, xi_val in enumerate(np.linspace(0, 2*np.pi, 8, endpoint=False)):
    x, y, z = hopf_inverse(np.pi/3, xi_val, t)
    ax2.plot(x, y, z, color=colors[i], linewidth=1.5, alpha=0.7)

ax2.set_title('Hopf Fibration\n(Multiple Fibers)', fontsize=12, fontweight='bold')
ax2.set_xlabel('x'); ax2.set_ylabel('y'); ax2.set_zlabel('z')
ax2.set_xlim(-lim, lim); ax2.set_ylim(-lim, lim); ax2.set_zlim(-lim, lim)

# Panel 3: Concurrence as a function of state parameters
ax3 = fig.add_subplot(133)

# Plot C = sin(2θ) showing the smooth transition
theta = np.linspace(0, np.pi/2, 200)
C = np.sin(2 * theta)

ax3.fill_between(np.degrees(theta), 0, C, alpha=0.3, color='purple',
                  label='Entanglement region')
ax3.plot(np.degrees(theta), C, 'purple', linewidth=2.5)

# Mark key states
ax3.plot(0, 0, 'go', markersize=12, label='|00⟩ (product)')
ax3.plot(45, 1, 'r*', markersize=15, label='Bell state (max entangled)')
ax3.plot(90, 0, 'bs', markersize=10, label='|11⟩ (product)')

# The topology connection
ax3.annotate('Linking\nnumber = 0', xy=(5, 0.05), fontsize=10, color='green',
             fontweight='bold')
ax3.annotate('Linking\nnumber = 1', xy=(35, 0.85), fontsize=10, color='red',
             fontweight='bold')

ax3.set_xlabel('θ (degrees)', fontsize=12)
ax3.set_ylabel('Concurrence = |Linking Number|', fontsize=12)
ax3.set_title('Entanglement = Topology\nC(ψ) = |Lk|', fontsize=12, fontweight='bold')
ax3.legend(loc='center right', fontsize=9)
ax3.set_xlim(-5, 95)
ax3.set_ylim(-0.05, 1.15)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hopf_fibration_entanglement.png', dpi=150, bbox_inches='tight')
print("Saved hopf_fibration_entanglement.png")
