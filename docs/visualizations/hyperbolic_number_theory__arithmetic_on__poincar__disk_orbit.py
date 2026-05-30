"""
Visualization 1: Poincaré Disk Tessellation
============================================
Visualizes the orbit of the origin under PSL(2,ℤ) in the Poincaré disk,
showing the hyperbolic lattice points that form the "hyperbolic integers."
The concentric circles show geodesic (hyperbolic) distance levels.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math

# === Inline all needed functions ===

def sl2_mul(g, h):
    a1,b1,c1,d1 = g
    a2,b2,c2,d2 = h
    return (a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2)

def sl2_inv(g):
    a,b,c,d = g
    return (d,-b,-c,a)

def generate_orbit(max_depth=7):
    S = (0,-1,1,0)
    T = (1,1,0,1)
    Ti = (1,-1,0,1)
    gens = [S, T, Ti]
    
    orbit = {}
    identity = (1,0,0,1)
    key = lambda g: tuple(round(x, 6) for x in g)
    orbit[key(identity)] = identity
    frontier = [identity]
    
    for _ in range(max_depth):
        nf = []
        for g in frontier:
            for gen in gens:
                h = sl2_mul(g, gen)
                k = key(h)
                if k not in orbit:
                    orbit[k] = h
                    nf.append(h)
        frontier = nf
    return list(orbit.values())

def to_disk(g):
    a,b,c,d = g
    denom = c**2 + d**2
    if denom < 1e-15:
        return None
    re_z = (a*c + b*d) / denom
    im_z = (a*d - b*c) / denom
    num_re, num_im = re_z, im_z - 1
    den_re, den_im = re_z, im_z + 1
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-15:
        return None
    w_re = (num_re*den_re + num_im*den_im) / den_sq
    w_im = (num_im*den_re - num_re*den_im) / den_sq
    r_sq = w_re**2 + w_im**2
    if r_sq >= 1 - 1e-10:
        return None
    return (w_re, w_im)

# === Generate data ===
matrices = generate_orbit(7)
points = []
for g in matrices:
    pt = to_disk(g)
    if pt:
        points.append(pt)

xs = [p[0] for p in points]
ys = [p[1] for p in points]
rs = [math.sqrt(p[0]**2 + p[1]**2) for p in points]

# === Plot ===
fig, ax = plt.subplots(1, 1, figsize=(10, 10), facecolor='#0a0a2e')
ax.set_facecolor('#0a0a2e')

# Draw the unit disk boundary
circle = plt.Circle((0, 0), 1, fill=False, color='white', linewidth=2)
ax.add_patch(circle)

# Draw hyperbolic distance circles (in Euclidean coords)
for hyp_r in [0.5, 1.0, 1.5, 2.0, 2.5]:
    # Euclidean radius for hyperbolic radius R: r = tanh(R/2)
    euc_r = math.tanh(hyp_r / 2)
    c = plt.Circle((0, 0), euc_r, fill=False, color='#334477', 
                    linewidth=0.5, linestyle='--', alpha=0.5)
    ax.add_patch(c)
    ax.text(euc_r + 0.02, 0.02, f'R={hyp_r}', color='#5577aa', fontsize=7, alpha=0.7)

# Color points by distance from origin
colors = plt.cm.plasma(np.array(rs) / max(rs) if rs else [0])
sizes = 20 / (1 + 5 * np.array(rs))

ax.scatter(xs, ys, c=rs, cmap='plasma', s=sizes * 10, alpha=0.8, 
           edgecolors='none', zorder=5)

# Mark origin
ax.plot(0, 0, 'o', color='#00ffaa', markersize=8, zorder=10)
ax.text(0.03, 0.03, 'O', color='#00ffaa', fontsize=12, fontweight='bold')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title(f'Hyperbolic Integers: PSL(2,ℤ) Orbit in the Poincaré Disk\n'
             f'({len(points)} lattice points, depth 7)',
             color='white', fontsize=14, pad=20)
ax.tick_params(colors='#666666')
for spine in ax.spines.values():
    spine.set_color('#333333')

plt.tight_layout()
plt.savefig('poincare_disk_orbit.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a2e')
plt.close()
print(f"Saved poincare_disk_orbit.png with {len(points)} points")
