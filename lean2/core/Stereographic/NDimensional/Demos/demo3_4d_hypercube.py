#!/usr/bin/env python3
"""
Demo 3: 4D → 3D Stereographic Projection — Polytopes from Higher Dimensions
============================================================================

Projects vertices of 4D polytopes (hypercube, 24-cell, 600-cell) from S³ to ℝ³
using stereographic projection. Reveals hidden symmetries of higher-dimensional objects.

Oracle Λ's third experiment — seeing the fourth dimension.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import combinations
import matplotlib.gridspec as gridspec

def stereo_project_4d_to_3d(x, y, z, w):
    """Stereographic projection from S³ ⊂ ℝ⁴ to ℝ³.
    Projects from the 'north pole' (0,0,0,1)."""
    denom = 1 - w
    mask = np.abs(denom) > 1e-10
    u = np.where(mask, x / denom, np.nan)
    v = np.where(mask, y / denom, np.nan)
    t = np.where(mask, z / denom, np.nan)
    return u, v, t

def normalize_to_sphere(points):
    """Project points onto S³."""
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms

# ─── Generate 4D polytope vertices ───

def hypercube_vertices():
    """Vertices of the 4D hypercube (tesseract)."""
    verts = []
    for i in [-1, 1]:
        for j in [-1, 1]:
            for k in [-1, 1]:
                for l in [-1, 1]:
                    verts.append([i, j, k, l])
    return normalize_to_sphere(np.array(verts, dtype=float))

def cell24_vertices():
    """Vertices of the 24-cell: permutations of (±1, ±1, 0, 0)."""
    verts = []
    for signs in [(-1,1), (1,1), (-1,-1), (1,-1)]:
        for perm in combinations(range(4), 2):
            v = [0.0, 0.0, 0.0, 0.0]
            v[perm[0]] = signs[0]
            v[perm[1]] = signs[1]
            verts.append(v)
    return normalize_to_sphere(np.array(verts, dtype=float))

def cell16_vertices():
    """Vertices of the 16-cell (hyperoctahedron): ±eᵢ."""
    verts = []
    for i in range(4):
        for s in [-1, 1]:
            v = [0.0, 0.0, 0.0, 0.0]
            v[i] = s
            verts.append(v)
    return np.array(verts, dtype=float)

def get_edges(vertices, threshold):
    """Find edges: pairs of vertices within a distance threshold."""
    edges = []
    n = len(vertices)
    for i in range(n):
        for j in range(i+1, n):
            d = np.linalg.norm(vertices[i] - vertices[j])
            if d < threshold:
                edges.append((i, j))
    return edges

# ─── Create visualization ───

fig = plt.figure(figsize=(20, 14))
gs = gridspec.GridSpec(2, 3, hspace=0.3, wspace=0.25)

polytopes = [
    ("16-cell\n(Hyperoctahedron)", cell16_vertices(), 1.5),
    ("24-cell", cell24_vertices(), 1.05),
    ("Tesseract\n(Hypercube)", hypercube_vertices(), 1.2),
]

# Apply a small rotation in 4D before projecting to avoid degeneracies
def rotate_4d(points, angle):
    """Small rotation in the xw-plane."""
    c, s = np.cos(angle), np.sin(angle)
    R = np.array([
        [c, 0, 0, s],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [-s, 0, 0, c]
    ])
    return points @ R.T

for idx, (name, verts4d, edge_thresh) in enumerate(polytopes):
    # Rotate slightly
    verts_rot = rotate_4d(verts4d, 0.3)

    # Project to 3D
    u, v, t = stereo_project_4d_to_3d(
        verts_rot[:, 0], verts_rot[:, 1], verts_rot[:, 2], verts_rot[:, 3]
    )

    # Get edges in 4D
    edges = get_edges(verts4d, edge_thresh)

    # 3D plot
    ax = fig.add_subplot(gs[0, idx], projection='3d')

    # Draw edges
    for i, j in edges:
        p1 = [u[i], v[i], t[i]]
        p2 = [u[j], v[j], t[j]]
        if all(np.isfinite(p1)) and all(np.isfinite(p2)):
            ax.plot([p1[0], p2[0]], [p1[1], p2[1]], [p1[2], p2[2]],
                   'b-', alpha=0.4, linewidth=0.8)

    # Draw vertices
    mask = np.isfinite(u)
    # Color by distance from origin (shows depth in 4D)
    dist = np.sqrt(u[mask]**2 + v[mask]**2 + t[mask]**2)
    scatter = ax.scatter(u[mask], v[mask], t[mask], c=dist,
                        cmap='plasma', s=60, edgecolors='black',
                        linewidth=0.5, zorder=5)

    ax.set_title(f'{name}\n({len(verts4d)} vertices, {len(edges)} edges)',
                fontsize=13, fontweight='bold')
    ax.view_init(elev=20, azim=45)

    # 2D projection (shadow) below
    ax2 = fig.add_subplot(gs[1, idx])
    for i, j in edges:
        if np.isfinite(u[i]) and np.isfinite(u[j]):
            ax2.plot([u[i], u[j]], [v[i], v[j]], 'b-', alpha=0.3, linewidth=0.5)

    ax2.scatter(u[mask], v[mask], c=dist, cmap='plasma', s=40,
               edgecolors='black', linewidth=0.5, zorder=5)
    ax2.set_aspect('equal')
    ax2.set_title(f'{name} — 2D shadow', fontsize=12)
    ax2.grid(True, alpha=0.2)

    # Set reasonable limits
    max_coord = np.nanpercentile(np.abs(np.concatenate([u[mask], v[mask]])), 95)
    lim = max(max_coord * 1.3, 2)
    ax2.set_xlim(-lim, lim)
    ax2.set_ylim(-lim, lim)

fig.suptitle('4D Polytopes via Stereographic Projection to ℝ³\n'
            'Hidden symmetries revealed by projecting from the fourth dimension',
            fontsize=18, fontweight='bold', y=1.02)

plt.savefig('/workspace/request-project/Stereographic/Demos/demo3_4d_hypercube.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 3 saved: demo3_4d_hypercube.png")
