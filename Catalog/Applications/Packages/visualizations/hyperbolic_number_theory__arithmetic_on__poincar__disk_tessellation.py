"""
Visualization: Poincaré Disk Tessellation and Orbit Points
============================================================
Visualizes the orbit of the origin under a discrete group of
Möbius transformations, showing the hyperbolic lattice structure.
The exponential growth of orbit points — a hallmark of negative
curvature — is visible as the points crowd toward the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def mobius_transform(a, theta, z):
    """Möbius transformation on the Poincaré disk."""
    eitheta = np.exp(1j * theta)
    denom = 1 - np.conj(a) * z
    mask = np.abs(denom) > 1e-10
    result = np.where(mask, eitheta * (z - a) / np.where(mask, denom, 1), 0)
    return result


def generate_orbit(generators, max_depth=5):
    """Generate orbit points by applying all words up to given depth."""
    points = {0 + 0j}
    current = {0 + 0j}
    all_transforms = []
    for a, theta in generators:
        all_transforms.append((a, theta))
        # Approximate inverse
        inv_a = mobius_transform(a, theta, 0 + 0j)
        all_transforms.append((inv_a, -theta))

    for depth in range(max_depth):
        next_level = set()
        for pt in current:
            for a, theta in all_transforms:
                try:
                    w = mobius_transform(a, theta, np.array([pt]))[0]
                    if np.abs(w) < 0.999 and not any(abs(w - p) < 0.001 for p in points):
                        next_level.add(w)
                        points.add(w)
                except:
                    continue
        current = next_level
        if not current:
            break

    return list(points)


# Generate orbit points
generators = [
    (0.35 + 0.15j, np.pi / 4),
    (0.15 - 0.35j, np.pi / 3),
]
orbit = generate_orbit(generators, max_depth=6)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: Orbit points on the Poincaré disk
ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Color by distance from origin (depth proxy)
xs = [z.real for z in orbit]
ys = [z.imag for z in orbit]
rs = [abs(z) for z in orbit]

scatter = ax.scatter(xs, ys, c=rs, cmap='plasma', s=15, alpha=0.8,
                     edgecolors='none', vmin=0, vmax=1)
ax.scatter([0], [0], c='red', s=100, zorder=5, marker='*', label='Origin')

# Draw some geodesics (circular arcs)
for z in orbit[:20]:
    if abs(z) > 0.01:
        ax.plot([0, z.real], [0, z.imag], 'gray', alpha=0.1, linewidth=0.5)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Lattice on the Poincaré Disk\n(Orbit Γ·0)', fontsize=12)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
plt.colorbar(scatter, ax=ax, label='Euclidean distance from origin')
ax.legend(loc='upper right', fontsize=9)

# Right plot: Growth rate comparison
ax2 = axes[1]
n_gen = 2
d = 2 * n_gen
max_R = 8

# Hyperbolic growth (exponential)
R_vals = list(range(max_R + 1))
hyp_growth = [sum(d**k for k in range(R + 1)) for R in R_vals]

# Euclidean growth (polynomial, dimension 2)
euc_growth = [(2 * R + 1)**2 for R in R_vals]

ax2.semilogy(R_vals, hyp_growth, 'b-o', label=f'Hyperbolic (d={d})', linewidth=2)
ax2.semilogy(R_vals, euc_growth, 'r--s', label='Euclidean (dim 2)', linewidth=2)
ax2.fill_between(R_vals, euc_growth, hyp_growth, alpha=0.15, color='blue')

ax2.set_xlabel('Radius R (word length)', fontsize=11)
ax2.set_ylabel('Number of lattice points', fontsize=11)
ax2.set_title('Exponential vs Polynomial Growth\nof Lattice Points', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the gap
mid_R = max_R // 2
ax2.annotate('Curvature\ngap', xy=(mid_R, (hyp_growth[mid_R] + euc_growth[mid_R]) / 2),
             fontsize=9, ha='center', color='blue', alpha=0.7)

plt.tight_layout()
plt.savefig('poincare_disk_tessellation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: poincare_disk_tessellation.png")
