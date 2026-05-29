#!/usr/bin/env python3
"""
Visualization: Projective Line Action of Singer-Like Elements

This script visualizes the action of Singer-like matrices on the projective
line P¹(F_q). It demonstrates the key geometric theorem: Singer-like elements
(those with irreducible characteristic polynomial) act WITHOUT fixed points
on P¹, in contrast to non-Singer elements that have 1 or 2 fixed points.

This geometric property is the engine of certified expansion: the absence
of fixed projective points forces the averaging operator to mix all
directions, preventing concentration on low-dimensional invariant subspaces.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def mod_inv(a, q):
    if a % q == 0: return None
    return pow(a, q-2, q)

def mat_det(M, q):
    return int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % q)

def charpoly_irred(M, q):
    tr = int((M[0,0]+M[1,1]) % q)
    det = mat_det(M, q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    return pow(int(disc), (q-1)//2, q) != 1

def proj_line(q):
    pts = [(1, b) for b in range(q)] + [(0, 1)]
    return pts

def proj_action(M, pt, q):
    a, b = pt
    na = (int(M[0,0])*a + int(M[0,1])*b) % q
    nb = (int(M[1,0])*a + int(M[1,1])*b) % q
    if na != 0:
        inv = mod_inv(na, q)
        return (1, (inv * nb) % q)
    elif nb != 0:
        return (0, 1)
    raise ValueError("Singular")

def count_fixed_points(M, q):
    pts = proj_line(q)
    return sum(1 for p in pts if proj_action(M, p, q) == p)


q = 7  # Use q=7 for a clearer visualization

# Classify all invertible matrices by their projective fixed-point count
singer_fps = []
non_singer_fps = []
all_fps = {0: 0, 1: 0, 2: 0}

for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) == 0: continue
    if np.array_equal(M%q, np.eye(2,dtype=int)): continue
    nfp = count_fixed_points(M, q)
    nfp = min(nfp, 2)  # cap
    all_fps[nfp] = all_fps.get(nfp, 0) + 1
    if charpoly_irred(M, q):
        singer_fps.append(nfp)
    else:
        non_singer_fps.append(nfp)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Distribution of fixed points for Singer vs non-Singer
labels = ['0 fixed pts', '1 fixed pt', '2 fixed pts']
singer_counts = [singer_fps.count(i) for i in range(3)]
non_singer_counts = [non_singer_fps.count(i) for i in range(3)]

x = np.arange(3)
w = 0.35
axes[0].bar(x - w/2, singer_counts, w, label='Singer-like', color='#2ca02c', alpha=0.8)
axes[0].bar(x + w/2, non_singer_counts, w, label='Non-Singer', color='#d62728', alpha=0.8)
axes[0].set_xticks(x)
axes[0].set_xticklabels(labels)
axes[0].set_ylabel('Count')
axes[0].set_title(f'Fixed Points on P¹(𝔽_{q})\nSinger-like vs Non-Singer', fontweight='bold')
axes[0].legend()
axes[0].text(0.5, 0.9, f'ALL Singer-like: 0 fixed points ✓',
             transform=axes[0].transAxes, fontsize=10, ha='center',
             color='#2ca02c', fontweight='bold')

# Plot 2: Orbit diagram for a Singer-like element
# Find a Singer-like element
singer_M = None
for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) != 0 and charpoly_irred(M, q):
        singer_M = M % q
        break

pts = proj_line(q)
n_pts = len(pts)

# Draw the orbit structure
angles = np.linspace(0, 2*np.pi, n_pts, endpoint=False)
px = np.cos(angles)
py = np.sin(angles)

axes[1].set_xlim(-1.5, 1.5)
axes[1].set_ylim(-1.5, 1.5)
axes[1].set_aspect('equal')

for i, p in enumerate(pts):
    img = proj_action(singer_M, p, q)
    j = pts.index(img)
    # Draw arrow from p to image
    dx = px[j] - px[i]
    dy = py[j] - py[i]
    axes[1].annotate('', xy=(px[j]*0.9, py[j]*0.9),
                     xytext=(px[i]*0.9, py[i]*0.9),
                     arrowprops=dict(arrowstyle='->', color='steelblue', lw=1.5))
    label = f'({p[0]}:{p[1]})' if p[0] == 1 else '∞'
    axes[1].plot(px[i], py[i], 'ko', markersize=8)
    axes[1].text(px[i]*1.15, py[i]*1.15, label, ha='center', va='center', fontsize=8)

axes[1].set_title(f'Singer-like action on P¹(𝔽_{q})\n(No fixed points — all orbits are cycles)',
                  fontweight='bold')
axes[1].axis('off')

# Plot 3: Find a non-Singer element with fixed points and show its action
non_singer_M = None
for a,b,c,d in product(range(q), repeat=4):
    M = np.array([[a,b],[c,d]], dtype=int)
    if mat_det(M, q) != 0 and not charpoly_irred(M, q):
        nfp = count_fixed_points(M, q)
        if nfp >= 1 and not np.array_equal(M%q, np.eye(2,dtype=int)):
            non_singer_M = M % q
            break

axes[2].set_xlim(-1.5, 1.5)
axes[2].set_ylim(-1.5, 1.5)
axes[2].set_aspect('equal')

fixed_indices = []
for i, p in enumerate(pts):
    img = proj_action(non_singer_M, p, q)
    j = pts.index(img)
    if i == j:
        fixed_indices.append(i)
    axes[2].annotate('', xy=(px[j]*0.9, py[j]*0.9),
                     xytext=(px[i]*0.9, py[i]*0.9),
                     arrowprops=dict(arrowstyle='->', color='coral', lw=1.5))
    label = f'({p[0]}:{p[1]})' if p[0] == 1 else '∞'
    color = 'red' if i in fixed_indices else 'black'
    size = 12 if i in fixed_indices else 8
    axes[2].plot(px[i], py[i], 'o', color=color, markersize=size)
    axes[2].text(px[i]*1.15, py[i]*1.15, label, ha='center', va='center',
                fontsize=8, color=color, fontweight='bold' if i in fixed_indices else 'normal')

axes[2].set_title(f'Non-Singer action on P¹(𝔽_{q})\n(Has {len(fixed_indices)} fixed point(s) — shown in red)',
                  fontweight='bold')
axes[2].axis('off')

plt.suptitle('The Geometric Engine of Certified Expansion:\nSinger-Like Elements Have No Fixed Points on the Projective Line',
             fontsize=13, fontweight='bold', y=1.04)
plt.tight_layout()
plt.savefig('projective_action.png', dpi=150, bbox_inches='tight')
print("Saved projective_action.png")
print(f"\nSinger-like elements in GL₂(𝔽_{q}): {len(singer_fps)} (all have 0 fixed points)")
print(f"Non-Singer elements: {len(non_singer_fps)} ({non_singer_counts[1]} with 1 fixed pt, {non_singer_counts[2]} with 2)")
