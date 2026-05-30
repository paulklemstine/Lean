"""
Visualization 3: Gyrogroup Structure and Non-Commutativity
============================================================
Visualizes the gyrogroup structure of hyperbolic addition,
showing how it differs from ordinary vector addition.
"""

import numpy as np
import matplotlib.pyplot as plt


def hyp_add(z, w):
    """Hyperbolic addition."""
    return (z + w) / (1 + np.conj(z) * w)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Commutativity failure
ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Sample many pairs and show z⊕w vs w⊕z
np.random.seed(42)
n_pairs = 200
z_pts = 0.6 * np.random.randn(n_pairs) + 0.6j * np.random.randn(n_pairs)
z_pts = z_pts * 0.3  # Keep in disk
w_pts = 0.6 * np.random.randn(n_pairs) + 0.6j * np.random.randn(n_pairs)
w_pts = w_pts * 0.3

zw = np.array([hyp_add(z, w) for z, w in zip(z_pts, w_pts)])
wz = np.array([hyp_add(w, z) for z, w in zip(z_pts, w_pts)])

ax.scatter(zw.real, zw.imag, c='blue', s=8, alpha=0.5, label='z ⊕ w')
ax.scatter(wz.real, wz.imag, c='red', s=8, alpha=0.5, label='w ⊕ z')

# Connect corresponding points
for i in range(min(50, n_pairs)):
    ax.plot([zw[i].real, wz[i].real], [zw[i].imag, wz[i].imag],
            'gray', alpha=0.2, linewidth=0.5)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Non-Commutativity of ⊕\n(z⊕w ≠ w⊕z in general)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Comparison with Euclidean addition
ax = axes[1]

# Points near origin (nearly commutative) vs far from origin
radii = np.linspace(0.05, 0.95, 50)
comm_errors = []
for r in radii:
    errs = []
    for _ in range(100):
        angle1 = np.random.uniform(0, 2 * np.pi)
        angle2 = np.random.uniform(0, 2 * np.pi)
        z = r * np.exp(1j * angle1)
        w = r * np.exp(1j * angle2)
        zw = hyp_add(z, w)
        wz = hyp_add(w, z)
        errs.append(abs(zw - wz))
    comm_errors.append(np.mean(errs))

ax.plot(radii, comm_errors, 'b-', linewidth=2, label='Mean |z⊕w - w⊕z|')
ax.fill_between(radii, 0, comm_errors, alpha=0.2, color='blue')
ax.set_xlabel('Radius |z| = |w|', fontsize=11)
ax.set_ylabel('Commutativity Error', fontsize=11)
ax.set_title('Non-Commutativity vs. Radius\n(Approaches 0 near origin)', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

# Panel 3: Velocity addition in special relativity
ax = axes[2]

# Compare Galilean vs Einstein velocity addition
v1_vals = np.linspace(0, 0.99, 100)
v2 = 0.5  # Fixed second velocity

galilean = v1_vals + v2
einstein = np.array([abs(hyp_add(v1 + 0j, v2 + 0j)) for v1 in v1_vals])

ax.plot(v1_vals, galilean, 'r--', linewidth=2, label='Galilean: v₁ + v₂')
ax.plot(v1_vals, einstein, 'b-', linewidth=2, label='Einstein: v₁ ⊕ v₂')
ax.axhline(y=1.0, color='gold', linewidth=3, alpha=0.7, label='Speed of light (c=1)')
ax.fill_between(v1_vals, einstein, 1, alpha=0.1, color='blue')

ax.set_xlabel('v₁ (in units of c)', fontsize=11)
ax.set_ylabel('Combined velocity', fontsize=11)
ax.set_title('Einstein vs. Galilean Addition\n(v₂ = 0.5c fixed)', fontsize=12)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1.6)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Gyrogroup Structure: Hyperbolic Addition on the Poincaré Disk',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('gyrogroup_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: gyrogroup_structure.png")
