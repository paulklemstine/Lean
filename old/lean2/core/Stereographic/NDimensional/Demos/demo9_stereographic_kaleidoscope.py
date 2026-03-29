#!/usr/bin/env python3
"""
Demo 9: The Stereographic Kaleidoscope — Möbius Group Orbits
=============================================================

NEW LANDSCAPE: The transition map between north-pole and south-pole
stereographic charts is inversion y → y/|y|². Composing inversions in
different spheres generates the Möbius group. Here we visualize the
orbits of discrete Möbius subgroups (Schottky groups) — the result
is Kleinian group limit sets, among the most beautiful fractals in
mathematics.

Oracle Θ's experiment on discrete group actions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# ─── Möbius Transformations ───

def mobius_transform(z, a, b, c, d):
    """Apply Möbius transformation (az+b)/(cz+d) to complex number z."""
    denom = c * z + d
    return np.where(np.abs(denom) > 1e-12, (a * z + b) / denom, np.nan + 1j*np.nan)

def sphere_inversion_2d(x, y, cx, cy, r):
    """Inversion of (x,y) in circle centered at (cx,cy) with radius r."""
    dx, dy = x - cx, y - cy
    dist_sq = dx**2 + dy**2
    dist_sq = np.where(dist_sq < 1e-15, np.nan, dist_sq)
    factor = r**2 / dist_sq
    return cx + factor * dx, cy + factor * dy

def generate_schottky_limit_set(generators, n_points=50000, n_iters=15):
    """
    Generate the limit set of a Schottky group by iterating
    random products of generators on seed points.
    """
    # Seed: random points on the unit circle
    theta = np.random.uniform(0, 2*np.pi, n_points)
    z = np.exp(1j * theta)
    
    all_gens = generators + [np.linalg.inv(g) for g in generators]
    
    for _ in range(n_iters):
        # Random generator for each point
        idx = np.random.randint(0, len(all_gens), n_points)
        for k, gen in enumerate(all_gens):
            mask = idx == k
            a, b, c, d = gen[0,0], gen[0,1], gen[1,0], gen[1,1]
            z[mask] = mobius_transform(z[mask], a, b, c, d)
    
    return z

def generate_ifs_fractal(inversions, seed_points, n_iters=8):
    """Generate fractal via iterated function system of circle inversions."""
    points_x, points_y = seed_points
    all_x, all_y = [points_x.copy()], [points_y.copy()]
    
    for _ in range(n_iters):
        new_x, new_y = [], []
        for cx, cy, r in inversions:
            ix, iy = sphere_inversion_2d(points_x, points_y, cx, cy, r)
            valid = np.isfinite(ix) & (np.abs(ix) < 20) & (np.abs(iy) < 20)
            new_x.append(ix[valid])
            new_y.append(iy[valid])
        if new_x:
            points_x = np.concatenate(new_x)
            points_y = np.concatenate(new_y)
            # Subsample to prevent explosion
            if len(points_x) > 100000:
                idx = np.random.choice(len(points_x), 100000, replace=False)
                points_x = points_x[idx]
                points_y = points_y[idx]
            all_x.append(points_x.copy())
            all_y.append(points_y.copy())
    
    return np.concatenate(all_x), np.concatenate(all_y)

# ─── Figure ───

fig = plt.figure(figsize=(20, 16))
gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.3)

# Panel 1: Schottky group limit set (loxodromic generators)
ax1 = fig.add_subplot(gs[0, 0])

# Two loxodromic Möbius transformations
k1 = 2.0  # multiplier
gen1 = np.array([[k1, 0], [0, 1/k1]])  # z → k²z (dilation)
theta_rot = np.pi / 5
gen2 = np.array([[np.cos(theta_rot) * 1.8, np.sin(theta_rot)],
                 [-np.sin(theta_rot), np.cos(theta_rot) / 1.8]])

z = generate_schottky_limit_set([gen1, gen2], n_points=100000, n_iters=12)
valid = np.isfinite(z) & (np.abs(z) < 5)
z = z[valid]

ax1.scatter(z.real, z.imag, s=0.1, c=np.angle(z), cmap='hsv', alpha=0.3)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_aspect('equal')
ax1.set_title('Schottky Group Limit Set\n(Two loxodromic generators)',
             fontsize=13, fontweight='bold')
ax1.set_facecolor('black')

# Panel 2: Circle inversion fractal (4 inversions)
ax2 = fig.add_subplot(gs[0, 1])

# Four mutually tangent circles for Apollonian-style fractal
inversions = [
    (0, 1.0, 1.0),    # circle at (0, 1), radius 1
    (0, -1.0, 1.0),   # circle at (0, -1), radius 1
    (1.0, 0, 1.0),    # circle at (1, 0), radius 1
    (-1.0, 0, 1.0),   # circle at (-1, 0), radius 1
]

# Seed: points on a small circle
theta_seed = np.linspace(0, 2*np.pi, 500)
seed_x = 0.1 * np.cos(theta_seed)
seed_y = 0.1 * np.sin(theta_seed)

fx, fy = generate_ifs_fractal(inversions, (seed_x, seed_y), n_iters=7)
valid = np.isfinite(fx) & np.isfinite(fy)

ax2.scatter(fx[valid], fy[valid], s=0.05, c=np.sqrt(fx[valid]**2 + fy[valid]**2),
           cmap='inferno', alpha=0.3)
ax2.set_xlim(-4, 4)
ax2.set_ylim(-4, 4)
ax2.set_aspect('equal')
ax2.set_title('Circle Inversion Fractal\n(4-fold symmetric Kleinian set)',
             fontsize=13, fontweight='bold')
ax2.set_facecolor('black')

# Panel 3: Möbius flow — continuous orbit of z under exp(t·M)
ax3 = fig.add_subplot(gs[1, 0])

# Flow under a Möbius transformation: z(t) = (e^{at}z₀ + b·sinh(t)) / (c·sinh(t) + e^{-at})
z0_vals = [0.5 + 0.5j, 1.0 + 0j, 0 + 1j, -0.5 + 0.3j, 0.2 - 0.7j,
           1.5 + 0.5j, -1 + 1j, 0.3 + 1.5j, -0.5 - 0.5j, 1.0 - 1.0j,
           -1.5 + 0j, 0 - 1.5j, 2.0 + 0j, 0 + 2j, -2 + 0j]
t_flow = np.linspace(0, 8, 2000)

# Parabolic Möbius flow: z → z + t (translation on the sphere)
# Elliptic Möbius flow: z → e^{it}·z (rotation)
# Hyperbolic Möbius flow: z → e^t·z (dilation)
# Loxodromic: combination

cmap_flow = plt.cm.viridis

for idx, z0 in enumerate(z0_vals):
    # Loxodromic flow: z(t) = e^{(a+ib)t} · z₀ where a=0.1, b=1
    a_flow, b_flow = 0.08, 0.7
    z_traj = z0 * np.exp((a_flow + 1j * b_flow) * t_flow)
    
    valid_traj = np.abs(z_traj) < 10
    color = cmap_flow(idx / len(z0_vals))
    ax3.plot(z_traj[valid_traj].real, z_traj[valid_traj].imag,
            color=color, linewidth=0.8, alpha=0.7)
    ax3.plot(z0.real, z0.imag, 'o', color=color, markersize=4)

# Draw unit circle
theta_c = np.linspace(0, 2*np.pi, 200)
ax3.plot(np.cos(theta_c), np.sin(theta_c), 'w--', linewidth=0.5, alpha=0.5)

ax3.set_xlim(-5, 5)
ax3.set_ylim(-5, 5)
ax3.set_aspect('equal')
ax3.set_title('Loxodromic Möbius Flow\nSpiral orbits on the Riemann sphere',
             fontsize=13, fontweight='bold')
ax3.set_facecolor('#1a1a2e')
ax3.grid(True, alpha=0.15, color='white')

# Panel 4: The stereographic kaleidoscope — multiple inversions
ax4 = fig.add_subplot(gs[1, 1])

# Create a triangular arrangement of reflection circles
# (generates a triangle group)
R = 2.0
angles = [0, 2*np.pi/3, 4*np.pi/3]
kaleidoscope_inversions = [(R * np.cos(a), R * np.sin(a), 1.5) for a in angles]
kaleidoscope_inversions.append((0, 0, 0.8))  # Central circle

# Dense seed
n_seed = 2000
seed_theta = np.random.uniform(0, 2*np.pi, n_seed)
seed_r = np.random.uniform(0, 0.3, n_seed)
seed_kx = seed_r * np.cos(seed_theta)
seed_ky = seed_r * np.sin(seed_theta)

kx, ky = generate_ifs_fractal(kaleidoscope_inversions, (seed_kx, seed_ky), n_iters=6)
valid_k = np.isfinite(kx) & np.isfinite(ky) & (np.abs(kx) < 6) & (np.abs(ky) < 6)

ax4.scatter(kx[valid_k], ky[valid_k], s=0.05,
           c=np.arctan2(ky[valid_k], kx[valid_k]), cmap='twilight',
           alpha=0.4)

# Draw the reflection circles
for cx, cy, r in kaleidoscope_inversions:
    circle = plt.Circle((cx, cy), r, fill=False, color='white',
                        linewidth=0.5, alpha=0.3)
    ax4.add_patch(circle)

ax4.set_xlim(-5, 5)
ax4.set_ylim(-5, 5)
ax4.set_aspect('equal')
ax4.set_title('Stereographic Kaleidoscope\nTriangle group limit set',
             fontsize=13, fontweight='bold')
ax4.set_facecolor('black')

fig.suptitle('The Stereographic Kaleidoscope: Möbius Group Orbits & Fractal Limit Sets',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo9_stereographic_kaleidoscope.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 9 saved: demo9_stereographic_kaleidoscope.png")
