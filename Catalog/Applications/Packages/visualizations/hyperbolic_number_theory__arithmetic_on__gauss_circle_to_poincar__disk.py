#!/usr/bin/env python3
"""
Visualization 3: Gauss Circle Problem → Poincaré Disk Embedding

Shows the bridge between classical number theory (integer lattice points
in a circle) and hyperbolic geometry (lattice points in the Poincaré disk).
The formally verified theorem gauss_to_hyp_embedding guarantees all
embedded points lie strictly inside the disk.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for idx, R in enumerate([3, 7, 15]):
    ax = axes[idx]

    # Generate Gauss circle points
    gauss_pts = []
    for a in range(-R, R + 1):
        for b in range(-R, R + 1):
            if a**2 + b**2 <= R**2:
                gauss_pts.append((a, b))

    # Embed into Poincaré disk: (a,b) ↦ (a/(R+1), b/(R+1))
    disk_pts = [(a / (R + 1) + 1j * b / (R + 1)) for a, b in gauss_pts]

    # Draw disk boundary
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

    # Color by distance from origin
    dists = [abs(z) for z in disk_pts]
    scatter = ax.scatter(
        [z.real for z in disk_pts],
        [z.imag for z in disk_pts],
        c=dists, cmap='viridis', s=max(8, 60 - R),
        edgecolors='none', alpha=0.8, vmin=0, vmax=1
    )

    # Mark the boundary where embedded points approach the circle
    max_r = max(dists) if dists else 0
    boundary = plt.Circle((0, 0), max_r, fill=False, color='red',
                           linewidth=1.5, linestyle='--', alpha=0.7)
    ax.add_patch(boundary)

    ax.set_xlim(-1.1, 1.1)
    ax.set_ylim(-1.1, 1.1)
    ax.set_aspect('equal')
    count = len(gauss_pts)
    pi_approx = count / R**2
    ax.set_title(f'R = {R}: {count} points\n'
                 f'count/R² = {pi_approx:.4f} ≈ π = {np.pi:.4f}\n'
                 f'max |z| = {max_r:.4f} < 1',
                 fontsize=11, fontweight='bold')
    ax.set_xlabel('Re(z)', fontsize=10)
    ax.set_ylabel('Im(z)', fontsize=10)
    ax.grid(True, alpha=0.2)

    if idx == 2:
        plt.colorbar(scatter, ax=ax, label='|z| (distance from origin)', shrink=0.8)

fig.suptitle('Gauss Circle Problem → Poincaré Disk Embedding\n'
             'ℤ² ∩ B(0,R) maps into the open unit disk (formally verified)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_gauss_embedding.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_gauss_embedding.png")
