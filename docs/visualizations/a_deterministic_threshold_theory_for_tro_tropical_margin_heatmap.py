"""
Visualization 2: Tropical Margin Heatmap

Displays the tropical margin as a function of the two mean parameters
(μ_diag, μ_off) for a fixed matrix size, overlaid with the stability
boundary tropMargin = 0. Illustrates the deterministic theorem
tropMargin(meanModel) = 2*(μ_off - μ_diag).

The diagonal line μ_off = μ_diag is the exact phase boundary for the
mean model, with the stable region above and unstable region below.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def trop_margin(W):
    """Tropical margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j])."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
    return min_val


def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


# Compute margin grid
n = 8
res = 80
mu_diag_range = np.linspace(-3, 3, res)
mu_off_range = np.linspace(-3, 3, res)
Z = np.zeros((res, res))

for i, md in enumerate(mu_diag_range):
    for j, mo in enumerate(mu_off_range):
        Z[j, i] = 2 * (mo - md)  # exact formula from theorem

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Deterministic margin heatmap
norm = TwoSlopeNorm(vmin=-8, vcenter=0, vmax=8)
im1 = ax1.pcolormesh(mu_diag_range, mu_off_range, Z, cmap='RdBu',
                      norm=norm, shading='auto')
ax1.contour(mu_diag_range, mu_off_range, Z, levels=[0],
            colors='black', linewidths=2)
ax1.plot([-3, 3], [-3, 3], 'k--', linewidth=1, alpha=0.5, label=r'$\mu_{off} = \mu_{diag}$')
fig.colorbar(im1, ax=ax1, label='tropMargin')
ax1.set_xlabel(r'$\mu_{\mathrm{diag}}$', fontsize=13)
ax1.set_ylabel(r'$\mu_{\mathrm{off}}$', fontsize=13)
ax1.set_title('Mean Model: tropMargin = 2(μ_off − μ_diag)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_aspect('equal')

# Right: Monte Carlo with noise
sigma = 1.0
rng = np.random.default_rng(42)
num_samples = 200
res2 = 40
mu_diag_range2 = np.linspace(-3, 3, res2)
mu_off_range2 = np.linspace(-3, 3, res2)
Z2 = np.zeros((res2, res2))

for i, md in enumerate(mu_diag_range2):
    for j, mo in enumerate(mu_off_range2):
        count = 0
        for _ in range(num_samples):
            noise = rng.normal(0, sigma, (n, n))
            noise = (noise + noise.T) / np.sqrt(2)
            W = mean_model(n, md, mo) + noise
            if trop_margin(W) >= 0:
                count += 1
        Z2[j, i] = count / num_samples

im2 = ax2.pcolormesh(mu_diag_range2, mu_off_range2, Z2, cmap='RdBu',
                      vmin=0, vmax=1, shading='auto')
ax2.contour(mu_diag_range2, mu_off_range2, Z2, levels=[0.5],
            colors='black', linewidths=2)
ax2.plot([-3, 3], [-3, 3], 'k--', linewidth=1, alpha=0.5)
fig.colorbar(im2, ax=ax2, label='P(tropMargin ≥ 0)')
ax2.set_xlabel(r'$\mu_{\mathrm{diag}}$', fontsize=13)
ax2.set_ylabel(r'$\mu_{\mathrm{off}}$', fontsize=13)
ax2.set_title(f'With Gaussian Noise (σ={sigma}, n={n})', fontsize=13)
ax2.set_aspect('equal')

plt.suptitle('Tropical Stability Phase Diagram', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_margin_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_margin_heatmap.png")
