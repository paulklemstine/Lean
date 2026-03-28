#!/usr/bin/env python3
"""
Demo 13: Higher-Dimensional Polytope Shadows via Stereographic Projection
===========================================================================

NEW LANDSCAPE: Regular polytopes in ℝ^N, inscribed in S^{N-1}, can be
stereographically projected to ℝ^{N-1}. The result transforms regular
structures into conformally-distorted but angle-preserving images.

Key Discovery: The 24-cell (unique to 4D), 120-cell, and 600-cell create
extraordinary patterns when stereographically projected to ℝ³ and then
rendered. The conformal preservation means angles between edges are
preserved, but lengths are wildly distorted.

Oracle Λ's computational experiment.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from mpl_toolkits.mplot3d import Axes3D
from itertools import combinations

def stereo_project_nd(points, pole_idx=-1):
    """
    Stereographic projection from S^{N-1} ⊂ ℝ^N to ℝ^{N-1}.
    Projects from the point where coordinate `pole_idx` = 1.
    
    points: array of shape (M, N) — M points in ℝ^N on the unit sphere
    Returns: array of shape (M, N-1)
    """
    N = points.shape[1]
    denom = 1 - points[:, pole_idx]
    denom = np.where(np.abs(denom) < 1e-10, np.nan, denom)
    
    indices = [i for i in range(N) if i != (pole_idx % N)]
    result = points[:, indices] / denom[:, np.newaxis]
    return result

def make_tesseract():
    """Vertices of the 4D hypercube (tesseract) inscribed in S³."""
    verts = []
    for i in range(16):
        v = [(i >> j & 1) * 2 - 1 for j in range(4)]
        verts.append(v)
    verts = np.array(verts, dtype=float)
    # Normalize to unit sphere
    verts = verts / np.linalg.norm(verts[0])
    return verts

def make_16cell():
    """Vertices of the 16-cell (4D cross-polytope) on S³."""
    verts = []
    for i in range(4):
        for s in [1, -1]:
            v = [0, 0, 0, 0]
            v[i] = s
            verts.append(v)
    return np.array(verts, dtype=float)

def make_24cell():
    """
    Vertices of the 24-cell — unique to 4D, no analog in other dimensions.
    24 vertices: the 16-cell vertices ± all permutations of (±1,±1,0,0)/√2.
    """
    verts = []
    # 8 vertices from 16-cell
    for i in range(4):
        for s in [1, -1]:
            v = [0, 0, 0, 0]
            v[i] = s
            verts.append(v)
    # 16 vertices from tesseract-type (all sign combinations of (±1,±1,0,0) etc.)
    for i in range(4):
        for j in range(i+1, 4):
            for si in [1, -1]:
                for sj in [1, -1]:
                    v = [0, 0, 0, 0]
                    v[i] = si / np.sqrt(2)
                    v[j] = sj / np.sqrt(2)
                    verts.append(v)
    return np.array(verts, dtype=float)

def get_edges_by_distance(verts, tol_factor=1.1):
    """Find edges connecting nearest-neighbor pairs."""
    n = len(verts)
    dists = np.zeros((n, n))
    for i in range(n):
        for j in range(i+1, n):
            dists[i, j] = dists[j, i] = np.linalg.norm(verts[i] - verts[j])
    
    # Minimum nonzero distance
    nonzero = dists[dists > 1e-10]
    if len(nonzero) == 0:
        return []
    min_dist = np.min(nonzero)
    
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if dists[i, j] < min_dist * tol_factor:
                edges.append((i, j))
    return edges

def make_120cell_sample():
    """
    Generate vertices of the 600-cell (easier to construct).
    The 600-cell has 120 vertices on S³.
    We use the quaternion group structure.
    """
    phi = (1 + np.sqrt(5)) / 2  # golden ratio
    
    verts = []
    
    # 16 vertices: ±1, ±1, ±1, ±1 (normalized)
    for s1 in [1, -1]:
        for s2 in [1, -1]:
            for s3 in [1, -1]:
                for s4 in [1, -1]:
                    verts.append([s1/2, s2/2, s3/2, s4/2])
    
    # 8 vertices: axis-aligned
    for i in range(4):
        for s in [1, -1]:
            v = [0, 0, 0, 0]
            v[i] = s
            verts.append(v)
    
    # 96 vertices: even permutations of (±φ, ±1, ±1/φ, 0)/2
    coords = [phi/2, 0.5, 1/(2*phi), 0]
    from itertools import permutations
    seen = set()
    for perm in permutations(range(4)):
        for s1 in [1, -1]:
            for s2 in [1, -1]:
                for s3 in [1, -1]:
                    v = [0, 0, 0, 0]
                    c = [coords[0]*s1, coords[1]*s2, coords[2]*s3, 0]
                    for k in range(4):
                        v[perm[k]] = c[k]
                    key = tuple(round(x, 6) for x in v)
                    if key not in seen:
                        seen.add(key)
                        norm = np.sqrt(sum(x**2 for x in v))
                        if norm > 0.1:
                            verts.append([x/norm for x in v])
    
    verts = np.array(verts)
    # Deduplicate
    unique = []
    for v in verts:
        is_dup = False
        for u in unique:
            if np.linalg.norm(v - np.array(u)) < 0.01:
                is_dup = True
                break
        if not is_dup:
            unique.append(list(v))
    
    return np.array(unique)

# ─── Figure ───

fig = plt.figure(figsize=(20, 16))

# Panel 1: Tesseract stereographic projection
ax1 = fig.add_subplot(221, projection='3d')

tesseract = make_tesseract()
proj_tess = stereo_project_nd(tesseract, pole_idx=3)
edges_tess = get_edges_by_distance(tesseract)

valid = np.all(np.isfinite(proj_tess), axis=1) & (np.max(np.abs(proj_tess), axis=1) < 10)
for i, j in edges_tess:
    if valid[i] and valid[j]:
        ax1.plot([proj_tess[i,0], proj_tess[j,0]],
                [proj_tess[i,1], proj_tess[j,1]],
                [proj_tess[i,2], proj_tess[j,2]],
                'b-', linewidth=1.5, alpha=0.6)

if np.any(valid):
    ax1.scatter(proj_tess[valid, 0], proj_tess[valid, 1], proj_tess[valid, 2],
               c='red', s=50, zorder=5, edgecolors='k')

ax1.set_title('Tesseract (4D Hypercube)\nStereographically projected S³→ℝ³',
             fontsize=12, fontweight='bold')
ax1.view_init(elev=20, azim=45)

# Panel 2: 16-cell projection
ax2 = fig.add_subplot(222, projection='3d')

cell16 = make_16cell()
proj_16 = stereo_project_nd(cell16, pole_idx=3)
edges_16 = get_edges_by_distance(cell16)

valid_16 = np.all(np.isfinite(proj_16), axis=1) & (np.max(np.abs(proj_16), axis=1) < 10)
for i, j in edges_16:
    if valid_16[i] and valid_16[j]:
        ax2.plot([proj_16[i,0], proj_16[j,0]],
                [proj_16[i,1], proj_16[j,1]],
                [proj_16[i,2], proj_16[j,2]],
                'g-', linewidth=2, alpha=0.7)

if np.any(valid_16):
    ax2.scatter(proj_16[valid_16, 0], proj_16[valid_16, 1], proj_16[valid_16, 2],
               c='orange', s=80, zorder=5, edgecolors='k')

ax2.set_title('16-Cell (4D Cross-Polytope)\nDual of the tesseract',
             fontsize=12, fontweight='bold')
ax2.view_init(elev=25, azim=60)

# Panel 3: 24-cell projection — unique to 4D
ax3 = fig.add_subplot(223, projection='3d')

cell24 = make_24cell()
proj_24 = stereo_project_nd(cell24, pole_idx=3)
edges_24 = get_edges_by_distance(cell24)

valid_24 = np.all(np.isfinite(proj_24), axis=1) & (np.max(np.abs(proj_24), axis=1) < 15)
for i, j in edges_24:
    if valid_24[i] and valid_24[j]:
        dist_from_origin = (np.linalg.norm(proj_24[i]) + np.linalg.norm(proj_24[j])) / 2
        color = plt.cm.plasma(min(dist_from_origin / 5, 1))
        ax3.plot([proj_24[i,0], proj_24[j,0]],
                [proj_24[i,1], proj_24[j,1]],
                [proj_24[i,2], proj_24[j,2]],
                color=color, linewidth=1.5, alpha=0.7)

if np.any(valid_24):
    dists = np.linalg.norm(proj_24[valid_24], axis=1)
    ax3.scatter(proj_24[valid_24, 0], proj_24[valid_24, 1], proj_24[valid_24, 2],
               c=dists, cmap='plasma', s=40, zorder=5, edgecolors='k', linewidth=0.5)

ax3.set_title('24-Cell (Unique to 4D!)\nSelf-dual, 24 octahedral cells',
             fontsize=12, fontweight='bold')
ax3.view_init(elev=15, azim=30)

# Panel 4: 600-cell vertices
ax4 = fig.add_subplot(224, projection='3d')

cell600 = make_120cell_sample()
proj_600 = stereo_project_nd(cell600, pole_idx=3)

valid_600 = np.all(np.isfinite(proj_600), axis=1) & (np.max(np.abs(proj_600), axis=1) < 8)

if np.any(valid_600):
    dists_600 = np.linalg.norm(proj_600[valid_600], axis=1)
    ax4.scatter(proj_600[valid_600, 0], proj_600[valid_600, 1], proj_600[valid_600, 2],
               c=dists_600, cmap='turbo', s=15, alpha=0.7, edgecolors='none')

ax4.set_title(f'600-Cell Vertices ({np.sum(valid_600)} visible)\nGolden ratio geometry',
             fontsize=12, fontweight='bold')
ax4.view_init(elev=20, azim=50)

fig.suptitle('4D Polytopes Through the Stereographic Lens\n'
            'Regular 4D solids projected S³ → ℝ³',
            fontsize=18, fontweight='bold', y=0.98)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo13_polytope_projection.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 13 saved: demo13_polytope_projection.png")
