#!/usr/bin/env python3
"""
Visualization 3: NormSq Identity and Disk Preservation

Illustrates the key algebraic identity that makes everything work:
1 - |φ_a(z)|² = (1-|a|²)(1-|z|²) / |1-āz|²

Shows how the "remaining room" in the disk after applying a Möbius map
factors into contributions from the generator and the input point.
"""

import numpy as np
import matplotlib.pyplot as plt


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: |φ_a(z)|² as a function of |z| for different |a|
ax1 = axes[0, 0]
zs = np.linspace(0, 0.99, 200)
for a_val, color in [(0.1, '#4CAF50'), (0.3, '#2196F3'), (0.5, '#FF9800'),
                      (0.7, '#E91E63'), (0.9, '#9C27B0')]:
    phi_normsq = [abs(moebius_map(a_val, z))**2 for z in zs]
    ax1.plot(zs, phi_normsq, color=color, linewidth=2, label=f'|a| = {a_val}')

ax1.plot(zs, zs**2, '--', color='gray', alpha=0.5, label='|z|² (identity)')
ax1.set_xlabel('|z|', fontsize=11)
ax1.set_ylabel('|φ_a(z)|²', fontsize=11)
ax1.set_title('Image NormSq vs Input (real axis)', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Complement identity verification
ax2 = axes[0, 1]
for a_val, color in [(0.2, '#4CAF50'), (0.5, '#2196F3'), (0.8, '#E91E63')]:
    complement_lhs = [1 - abs(moebius_map(a_val, z))**2 for z in zs]
    factor1 = 1 - a_val**2
    complement_rhs = [factor1 * (1 - z**2) / abs(1 - a_val * z)**2 for z in zs]
    
    ax2.plot(zs, complement_lhs, color=color, linewidth=2,
             label=f'1−|φ(z)|² (|a|={a_val})')
    ax2.plot(zs, complement_rhs, ':', color=color, linewidth=3, alpha=0.5)

ax2.set_xlabel('|z|', fontsize=11)
ax2.set_ylabel('1 − |φ_a(z)|²', fontsize=11)
ax2.set_title('NormSq Complement Identity Verification', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.text(0.5, 0.5, 'Solid = LHS\nDotted = RHS\n(identical!)',
         transform=ax2.transAxes, fontsize=10, ha='center',
         style='italic', alpha=0.7)

# Panel 3: Orbit |z_n|² convergence to 1
ax3 = axes[1, 0]
golden = (3 - np.sqrt(5)) / 2
N = 50
orbit = [0.0 + 0j]
for _ in range(N):
    orbit.append(moebius_map(golden, orbit[-1]))
normsqs = [abs(z)**2 for z in orbit]

ax3.plot(range(N+1), normsqs, 'o-', color='#2196F3', markersize=4, linewidth=1)
ax3.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary (|z|² = 1)')
ax3.fill_between(range(N+1), normsqs, 1, alpha=0.1, color='blue')

# Mark primes
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
for p in primes:
    if p <= N:
        ax3.scatter(p, normsqs[p], c='red', s=40, zorder=5, marker='*')

ax3.set_xlabel('Orbit index n', fontsize=11)
ax3.set_ylabel('|z_n|²', fontsize=11)
ax3.set_title('Orbit NormSq (Golden Generator)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Cross-ratio symmetry heatmap
ax4 = axes[1, 1]
n_pts = 15
pts = [0.7 * np.exp(2j * np.pi * k / n_pts) * (0.3 + 0.4 * k / n_pts)
       for k in range(n_pts)]

asymmetry = np.zeros((n_pts, n_pts))
for i in range(n_pts):
    for j in range(n_pts):
        rho_ij = abs(pts[i] - pts[j])**2 / max(abs(1 - np.conj(pts[i]) * pts[j])**2, 1e-30)
        rho_ji = abs(pts[j] - pts[i])**2 / max(abs(1 - np.conj(pts[j]) * pts[i])**2, 1e-30)
        asymmetry[i, j] = abs(rho_ij - rho_ji)

im = ax4.imshow(asymmetry, cmap='RdBu_r', vmin=-1e-15, vmax=1e-15)
ax4.set_xlabel('Point index j', fontsize=11)
ax4.set_ylabel('Point index i', fontsize=11)
ax4.set_title('Cross-Ratio Asymmetry |ρ(i,j)−ρ(j,i)|', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax4, label='Asymmetry (≈ 0)')

fig.suptitle('The NormSq Identity: Foundation of Disk Preservation',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_normsq.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_normsq.png")
