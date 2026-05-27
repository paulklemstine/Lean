#!/usr/bin/env python3
"""
Visualization 2: Fourier Symbol Heatmap for d=2.

Shows the hybrid eigenvalue λ_hyb(k₁, k₂) as a heatmap over the
frequency space (ℤ/nℤ)², with the spectral gap minimizers highlighted.
Also shows the local eigenvalue for comparison.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


n = 15  # modulus
d = 2   # dimension

# Compute eigenvalue grids
local_grid = np.zeros((n, n))
hybrid_grid = np.zeros((n, n))

for k1 in range(n):
    for k2 in range(n):
        lam_loc = (2 - 2*math.cos(2*math.pi*k1/n)) + (2 - 2*math.cos(2*math.pi*k2/n))
        lam_diag = 2 - 2*math.cos(2*math.pi*(k1+k2)/n)
        local_grid[k2, k1] = lam_loc
        hybrid_grid[k2, k1] = lam_loc + lam_diag

# Set k=(0,0) to NaN so it doesn't show as minimum
local_grid[0, 0] = np.nan
hybrid_grid[0, 0] = np.nan

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Local eigenvalue
ax1 = axes[0]
im1 = ax1.imshow(local_grid, cmap='viridis', origin='lower',
                  extent=[-0.5, n-0.5, -0.5, n-0.5])
plt.colorbar(im1, ax=ax1, label='λ_loc(k)')
ax1.set_title(f'Local Eigenvalue λ_loc(k₁,k₂)\nn={n}', fontsize=13)
ax1.set_xlabel('k₁')
ax1.set_ylabel('k₂')
# Mark minimizers (coordinate frequencies)
for k in [(1,0), (0,1), (n-1,0), (0,n-1)]:
    ax1.plot(k[0], k[1], 'r*', markersize=15, markeredgecolor='white', markeredgewidth=0.5)

# Panel 2: Hybrid eigenvalue
ax2 = axes[1]
im2 = ax2.imshow(hybrid_grid, cmap='inferno', origin='lower',
                  extent=[-0.5, n-0.5, -0.5, n-0.5])
plt.colorbar(im2, ax=ax2, label='λ_hyb(k)')
ax2.set_title(f'Hybrid Eigenvalue λ_hyb(k₁,k₂)\nn={n}', fontsize=13)
ax2.set_xlabel('k₁')
ax2.set_ylabel('k₂')
# Mark minimizers
for k in [(1,0), (0,1), (n-1,0), (0,n-1)]:
    ax2.plot(k[0], k[1], 'c*', markersize=15, markeredgecolor='white', markeredgewidth=0.5)

# Panel 3: Diagonal contribution
diag_grid = np.zeros((n, n))
for k1 in range(n):
    for k2 in range(n):
        diag_grid[k2, k1] = 2 - 2*math.cos(2*math.pi*(k1+k2)/n)
diag_grid[0, 0] = np.nan

ax3 = axes[2]
im3 = ax3.imshow(diag_grid, cmap='magma', origin='lower',
                  extent=[-0.5, n-0.5, -0.5, n-0.5])
plt.colorbar(im3, ax=ax3, label='λ_diag(k)')
ax3.set_title(f'Diagonal Contribution λ_diag(k₁,k₂)\nn={n}', fontsize=13)
ax3.set_xlabel('k₁')
ax3.set_ylabel('k₂')
# Mark the anti-diagonal k1+k2 ≡ 0 (where diagonal contribution vanishes)
for k1 in range(n):
    k2 = (n - k1) % n
    if (k1, k2) != (0, 0):
        ax3.plot(k1, k2, 'w.', markersize=4)

fig.suptitle('Fourier Symbols on (ℤ/15ℤ)²: Spectral Additivity in Action',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('fourier_symbol.png', dpi=150, bbox_inches='tight')
print("Saved fourier_symbol.png")
