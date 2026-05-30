"""
Visualization 1: Poincaré Disk Tessellation and Hyperbolic Lattice Points
=========================================================================
Shows the orbit of a basepoint under a group of Möbius transformations,
illustrating how hyperbolic integers tile the disk. The exponential growth
of lattice points is visible as density increases toward the boundary.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from collections import deque


def moebius_apply(a, b, c, d, z):
    return (a * z + b) / (c * z + d)


def disk_aut(center, z):
    """Disk automorphism sending center to 0."""
    return (z - center) / (1 - np.conj(center) * z)


def enumerate_orbit(generators, basepoint=0, max_depth=6, tol=1e-6):
    """BFS orbit enumeration."""
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append((g[3], -g[1], -g[2], g[0]))  # inverse

    orbit = [basepoint]
    seen = {(round(basepoint.real/tol), round(basepoint.imag/tol))}
    queue = deque([(basepoint, 0)])

    while queue:
        pt, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for g in all_gens:
            new_pt = moebius_apply(*g, pt)
            if abs(new_pt) >= 1 - 1e-10:
                continue
            key = (round(new_pt.real/tol), round(new_pt.imag/tol))
            if key not in seen:
                seen.add(key)
                orbit.append(new_pt)
                queue.append((new_pt, depth + 1))
    return orbit


def hyp_distance(z, w):
    cr = abs(z-w)**2 / ((1-abs(z)**2) * (1-abs(w)**2))
    return 2 * np.arcsinh(np.sqrt(max(cr, 0)))


# Create generators (approximate PSL(2,Z) in disk model)
g1 = (1, -0.3, -0.3, 1)    # disk automorphism-like
g2 = (1, -0.3j, 0.3j, 1)   # rotation-like

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Orbit tessellation
ax = axes[0]
orbit = enumerate_orbit([g1, g2], basepoint=0, max_depth=5)

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Color by hyperbolic distance from origin
distances = [hyp_distance(0, p) for p in orbit]
max_d = max(distances) if distances else 1

xs = [p.real for p in orbit]
ys = [p.imag for p in orbit]
scatter = ax.scatter(xs, ys, c=distances, cmap='viridis', s=15, zorder=5,
                     edgecolors='none', vmin=0, vmax=max_d)
ax.scatter([0], [0], c='red', s=80, zorder=10, marker='*', label='Origin')

plt.colorbar(scatter, ax=ax, label='Hyperbolic distance from origin')
ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Lattice Points on the Poincaré Disk', fontsize=13)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.legend(loc='upper right')
ax.grid(True, alpha=0.3)

# Right: Growth comparison
ax2 = axes[1]
Rs = np.arange(1, 15)
orbit_full = enumerate_orbit([g1, g2], basepoint=0, max_depth=8)
all_dists = sorted([hyp_distance(0, p) for p in orbit_full])

counts = []
for R in Rs:
    count = sum(1 for d in all_dists if d <= R)
    counts.append(count)

ax2.semilogy(Rs, counts, 'bo-', label='Orbit count N(R)', markersize=6)
ax2.semilogy(Rs, [np.exp(r)/r for r in Rs], 'r--', label='$e^R / R$', linewidth=2)
ax2.semilogy(Rs, [np.pi * r**2 for r in Rs], 'g:', label='$\\pi R^2$ (Euclidean)', linewidth=2)

ax2.set_xlabel('Hyperbolic radius R')
ax2.set_ylabel('Count (log scale)')
ax2.set_title('Lattice Point Growth:\nHyperbolic (exp) vs Euclidean (poly)', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('poincare_disk_tessellation.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: poincare_disk_tessellation.png")
