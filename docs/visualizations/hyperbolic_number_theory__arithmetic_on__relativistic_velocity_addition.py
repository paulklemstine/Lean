"""
Visualization 3: Relativistic Velocity Addition as Möbius Composition
======================================================================
Shows how special-relativistic velocity addition is a Möbius transformation
on the Poincaré disk, connecting hyperbolic number theory to physics.
The Thomas rotation effect emerges naturally from non-commutativity.
"""
import numpy as np
import matplotlib.pyplot as plt


def relativistic_add(v1, v2):
    """Relativistic velocity addition (Poincaré disk model)."""
    return (v1 + v2) / (1 + np.conj(v1) * v2)


def hyp_geodesic(z, w, n=100):
    """Compute the hyperbolic geodesic between z and w in the disk."""
    # Use the disk automorphism to map z to 0, draw a line, map back
    if abs(z - w) < 1e-10:
        return [z]
    # Parametric Möbius interpolation
    T = disk_aut_matrix(z)
    w_mapped = moebius_apply_tuple(T, w)
    # Geodesic through 0 and w_mapped is a diameter
    t = np.linspace(0, 1, n)
    line = w_mapped * t
    # Map back
    T_inv = (T[3], -T[1], -T[2], T[0])
    return [moebius_apply_tuple(T_inv, p) for p in line]


def disk_aut_matrix(a):
    return (1, -a, -np.conj(a), 1)


def moebius_apply_tuple(T, z):
    return (T[0]*z + T[1]) / (T[2]*z + T[3])


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Velocity addition grid
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Fix v1, vary v2
v1 = 0.5 + 0j
n_arrows = 12
colors = plt.cm.hsv(np.linspace(0, 1, n_arrows, endpoint=False))
for i in range(n_arrows):
    angle = 2 * np.pi * i / n_arrows
    for speed in [0.2, 0.4, 0.6]:
        v2 = speed * np.exp(1j * angle)
        v_sum = relativistic_add(v1, v2)
        ax.plot([v2.real], [v2.imag], 'o', color=colors[i], markersize=4, alpha=0.5)
        ax.plot([v_sum.real], [v_sum.imag], 's', color=colors[i], markersize=5)
        ax.annotate('', xy=(v_sum.real, v_sum.imag),
                   xytext=(v2.real, v2.imag),
                   arrowprops=dict(arrowstyle='->', color=colors[i], alpha=0.4))

ax.plot([v1.real], [v1.imag], 'r*', markersize=15, label=f'$v_1 = {v1.real}c$', zorder=10)
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Relativistic Velocity Addition\n$v_1 \\oplus v_2$ (circles → squares)', fontsize=12)
ax.set_xlabel('$v_x / c$')
ax.set_ylabel('$v_y / c$')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Non-commutativity (Thomas rotation)
ax = axes[1]
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

v1s = [0.3+0j, 0.5+0j, 0.7+0j]
v2 = 0.0 + 0.4j
markers = ['o', 's', '^']
for idx, v1 in enumerate(v1s):
    angles = np.linspace(0, 2*np.pi, 60)
    v12_pts = [relativistic_add(v1, 0.3*np.exp(1j*a)) for a in angles]
    v21_pts = [relativistic_add(0.3*np.exp(1j*a), v1) for a in angles]
    ax.plot([p.real for p in v12_pts], [p.imag for p in v12_pts],
            '-', linewidth=1.5, label=f'$v_1={abs(v1):.1f}c \\oplus$ circle')
    ax.plot([p.real for p in v21_pts], [p.imag for p in v21_pts],
            '--', linewidth=1.5, alpha=0.6)

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Thomas Rotation Effect\nSolid: $v_1 \\oplus v_2$, Dashed: $v_2 \\oplus v_1$', fontsize=12)
ax.set_xlabel('$v_x / c$')
ax.set_ylabel('$v_y / c$')
ax.legend(fontsize=9, loc='lower left')
ax.grid(True, alpha=0.3)

# Panel 3: Speed composition saturation
ax = axes[2]
speeds = np.linspace(0, 0.99, 200)
# Collinear addition: v1 ⊕ v2 = (v1 + v2)/(1 + v1*v2)
for v1_base in [0.1, 0.3, 0.5, 0.7, 0.9]:
    result = [(v1_base + s) / (1 + v1_base * s) for s in speeds]
    ax.plot(speeds, result, linewidth=2, label=f'$v_1 = {v1_base}c$')

ax.plot(speeds, speeds, 'k:', linewidth=1, alpha=0.5, label='Galilean ($v_1+v_2$)')
ax.axhline(y=1, color='red', linestyle='--', linewidth=1, alpha=0.7, label='Speed of light')

ax.set_xlabel('$v_2 / c$', fontsize=12)
ax.set_ylabel('$v_1 \\oplus v_2$ / c', fontsize=12)
ax.set_title('Velocity Addition Saturation\n(speed of light as absolute limit)', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.05)

plt.tight_layout()
plt.savefig('velocity_addition.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: velocity_addition.png")
