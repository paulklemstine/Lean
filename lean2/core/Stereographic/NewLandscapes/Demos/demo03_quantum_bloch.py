#!/usr/bin/env python3
"""
Demo 03: Quantum State Geometry — The Bloch Sphere and Beyond

Visualizes quantum states as stereographic coordinates on S².
Shows quantum gates as Möbius transformations and explores 
two-qubit entanglement geometry.

Oracle Ϙ's Theorem: "Quantum gates are Möbius transformations in disguise."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm

def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

def stereo_from_bloch(theta, phi):
    """Bloch sphere angles to stereographic coordinate z = tan(θ/2)e^{iφ}."""
    z = np.tan(theta/2) * np.exp(1j * phi)
    return z.real, z.imag

def mobius(z, a, b, c, d):
    """Möbius transformation (az+b)/(cz+d)."""
    return (a*z + b) / (c*z + d)

def draw_sphere(ax, alpha=0.04):
    u = np.linspace(0, 2*np.pi, 30)
    v = np.linspace(0, np.pi, 15)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(x, y, z, color='gray', alpha=alpha, linewidth=0.3)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Quantum State Geometry: Bloch Sphere & Stereographic Coordinates\n"
             "Oracle Ϙ — \"Quantum gates are Möbius transformations in disguise\"",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Bloch sphere with quantum states ---
ax1 = fig.add_subplot(2, 2, 1, projection='3d')
draw_sphere(ax1, alpha=0.05)

# Plot special quantum states
states = {
    '|0⟩': (0, 0, -1, 'blue', 150),         # South pole in our convention
    '|1⟩': (0, 0, 1, 'red', 150),            # North pole
    '|+⟩': (1, 0, 0, 'green', 100),          # +x
    '|-⟩': (-1, 0, 0, 'orange', 100),        # -x
    '|+i⟩': (0, 1, 0, 'purple', 100),        # +y
    '|-i⟩': (0, -1, 0, 'cyan', 100),         # -y
}

for name, (x, y, z, color, size) in states.items():
    ax1.scatter([x], [y], [z], color=color, s=size, zorder=10, edgecolor='black')
    ax1.text(x*1.2, y*1.2, z*1.2, name, fontsize=10, fontweight='bold', color=color)

# Draw axes
for axis, color in [([1.3, 0, 0], 'gray'), ([0, 1.3, 0], 'gray'), ([0, 0, 1.3], 'gray')]:
    ax1.plot([0, axis[0]], [0, axis[1]], [0, axis[2]], color=color, alpha=0.3, linewidth=1)
    ax1.plot([0, -axis[0]], [0, -axis[1]], [0, -axis[2]], color=color, alpha=0.3, linewidth=1)

# Draw a few state trajectories (rotation about z-axis = phase gate)
theta_traj = np.pi/3
phi_traj = np.linspace(0, 2*np.pi, 100)
x_traj = np.sin(theta_traj) * np.cos(phi_traj)
y_traj = np.sin(theta_traj) * np.sin(phi_traj)
z_traj = np.cos(theta_traj) * np.ones_like(phi_traj)
ax1.plot(x_traj, y_traj, z_traj, 'k-', linewidth=1.5, alpha=0.5, label='Phase rotation')

ax1.set_title("The Bloch Sphere\n(Quantum States on S²)", fontsize=12)
ax1.view_init(elev=20, azim=45)
ax1.set_xlim([-1.3, 1.3]); ax1.set_ylim([-1.3, 1.3]); ax1.set_zlim([-1.3, 1.3])
ax1.legend(fontsize=9)

# --- Panel 2: Quantum gates as Möbius transformations ---
ax2 = fig.add_subplot(2, 2, 2, projection='3d')
draw_sphere(ax2, alpha=0.05)

# Start with a grid of states on the sphere
theta_grid = np.linspace(0.1, np.pi-0.1, 8)
phi_grid = np.linspace(0, 2*np.pi, 16, endpoint=False)
THETA, PHI = np.meshgrid(theta_grid, phi_grid)
theta_flat = THETA.flatten()
phi_flat = PHI.flatten()

# Original states
x0 = np.sin(theta_flat) * np.cos(phi_flat)
y0 = np.sin(theta_flat) * np.sin(phi_flat)
z0 = np.cos(theta_flat)

# Hadamard gate as Möbius: z → (z+1)/(1-z) (corrected sign)
z_stereo = np.tan(theta_flat/2) * np.exp(1j * phi_flat)
z_hadamard = np.where(np.abs(1 - z_stereo) > 1e-10,
                       (z_stereo + 1) / (1 - z_stereo),
                       1e10 + 0j)

# Convert back to Bloch sphere
r_had = np.abs(z_hadamard)
theta_had = 2 * np.arctan(r_had)
phi_had = np.angle(z_hadamard)
x_had = np.sin(theta_had) * np.cos(phi_had)
y_had = np.sin(theta_had) * np.sin(phi_had)
z_had = np.cos(theta_had)

# Clip outliers
mask = r_had < 100
ax2.scatter(x0[mask], y0[mask], z0[mask], c='blue', s=20, alpha=0.5, label='Before H')
ax2.scatter(x_had[mask], y_had[mask], z_had[mask], c='red', s=20, alpha=0.5, label='After H')

# Draw arrows for a few
for i in range(0, len(x0[mask]), 3):
    ax2.plot([x0[mask][i], x_had[mask][i]],
             [y0[mask][i], y_had[mask][i]],
             [z0[mask][i], z_had[mask][i]], 'g-', alpha=0.3, linewidth=0.5)

ax2.set_title("Hadamard Gate as Möbius\nTransformation on S²", fontsize=12)
ax2.view_init(elev=25, azim=60)
ax2.set_xlim([-1.3, 1.3]); ax2.set_ylim([-1.3, 1.3]); ax2.set_zlim([-1.3, 1.3])
ax2.legend(fontsize=9)

# --- Panel 3: Stereographic coordinates of gate orbits ---
ax3 = fig.add_subplot(2, 2, 3)

# Apply repeated gates and track in stereographic coordinates
z0_single = 0.5 + 0.5j  # Starting state

gates = {
    'T-gate orbit': lambda z: np.exp(1j*np.pi/4) * z,
    'S-gate orbit': lambda z: 1j * z,
    'Hadamard orbit': lambda z: (z + 1) / (1 - z) if abs(1-z) > 1e-10 else 1e10,
}

for name, gate in gates.items():
    trajectory = [z0_single]
    z = z0_single
    for _ in range(50):
        try:
            z = gate(z)
            if abs(z) > 1e6:
                break
            trajectory.append(z)
        except:
            break
    traj = np.array(trajectory)
    ax3.plot(traj.real, traj.imag, '.-', markersize=4, linewidth=1, label=name, alpha=0.8)

ax3.set_xlabel('Re(z) = stereographic x', fontsize=11)
ax3.set_ylabel('Im(z) = stereographic y', fontsize=11)
ax3.set_title("Gate Orbits in\nStereographic Coordinates", fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_aspect('equal')
ax3.set_xlim([-3, 3]); ax3.set_ylim([-3, 3])

# --- Panel 4: Entanglement visualization (2-qubit reduced density matrix) ---
ax4 = fig.add_subplot(2, 2, 4, projection='3d')
draw_sphere(ax4, alpha=0.05)

# For a 2-qubit state |ψ⟩ = cos(α)|00⟩ + sin(α)|11⟩
# The reduced density matrix ρ_A has Bloch vector (0, 0, cos(2α))
# At α=0: product state |00⟩, Bloch vector (0,0,1)
# At α=π/4: Bell state, Bloch vector (0,0,0) = maximally mixed
# At α=π/2: product state |11⟩, Bloch vector (0,0,-1)

alphas = np.linspace(0, np.pi/2, 100)
bloch_z = np.cos(2 * alphas)
bloch_x = np.zeros_like(alphas)
bloch_y = np.zeros_like(alphas)

# The Bloch vector traces a path from north pole to south pole through center
ax4.plot(bloch_x, bloch_y, bloch_z, 'r-', linewidth=3, label='Entanglement path')

# Mark special states
markers = [
    (0, '|00⟩\n(separable)', 'blue'),
    (np.pi/8, 'partially\nentangled', 'green'),
    (np.pi/4, 'Bell state\n(max entangled)', 'red'),
    (3*np.pi/8, 'partially\nentangled', 'green'),
    (np.pi/2, '|11⟩\n(separable)', 'blue'),
]

for alpha, label, color in markers:
    bz = np.cos(2*alpha)
    ax4.scatter([0], [0], [bz], color=color, s=100, zorder=10, edgecolor='black')
    ax4.text(0.15, 0.15, bz, label, fontsize=8, color=color)

# Draw purity radius (Bloch ball interior = mixed states)
theta_ball = np.linspace(0, 2*np.pi, 50)
for r in [0.3, 0.6, 0.9]:
    ax4.plot(r*np.cos(theta_ball), r*np.sin(theta_ball),
             np.zeros_like(theta_ball), 'k-', alpha=0.1, linewidth=0.5)

ax4.set_title("2-Qubit Entanglement Path\n(Reduced State on Bloch Sphere)", fontsize=12)
ax4.view_init(elev=15, azim=45)
ax4.set_xlim([-1.3, 1.3]); ax4.set_ylim([-1.3, 1.3]); ax4.set_zlim([-1.3, 1.3])
ax4.legend(fontsize=9, loc='lower left')

plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo03_quantum_bloch.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 03: Quantum State Geometry — Bloch Sphere saved.")
