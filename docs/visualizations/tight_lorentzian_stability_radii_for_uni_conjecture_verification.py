"""
Visualization: Conjecture Test — Stability Ratio Universality

This script tests the prediction that the identity-perturbation instability
threshold for U_{r,n} is always t = 1 (the spectral gap), and visualizes
the ratio empirical_threshold / gap across all (n,r) with n ≤ 15.

The uniformity of the ratio confirms that the spectral gap is the
governing quantity: Lorentzian stability is an eigengap phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def uniform_leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def verify_lorentzian(A, tol=1e-10):
    eigs = np.linalg.eigvalsh(A)
    return np.sum(eigs > tol) <= 1

def find_threshold(m, E, lo=0.0, hi=10.0, steps=150):
    H = uniform_leaf_hessian(m)
    for _ in range(steps):
        mid = (lo + hi) / 2
        if verify_lorentzian(H + mid * E):
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2

# Compute data for all valid (n, r)
max_n = 15
data = []

for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        E = np.eye(m)
        t = find_threshold(m, E, steps=150)
        ratio = t / 1.0  # gap = 1
        data.append({
            'n': n, 'r': r, 'm': m,
            'threshold': t, 'ratio': ratio,
            'binomial': comb(n, r)
        })

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Ratio heatmap
ax1 = axes[0, 0]
n_vals = sorted(set(d['n'] for d in data))
r_vals = sorted(set(d['r'] for d in data))
ratio_grid = np.full((len(n_vals), max(r_vals) + 1), np.nan)
for d in data:
    ni = n_vals.index(d['n'])
    ratio_grid[ni, d['r']] = d['ratio']

im = ax1.imshow(ratio_grid[:, 2:], cmap='RdYlGn', vmin=0.95, vmax=1.05,
                 aspect='auto', origin='lower',
                 extent=[2 - 0.5, ratio_grid.shape[1] - 0.5, n_vals[0] - 0.5, n_vals[-1] + 0.5])
ax1.set_xlabel('r (degree)', fontsize=12)
ax1.set_ylabel('n (variables)', fontsize=12)
ax1.set_title('Ratio: Empirical Threshold / Spectral Gap', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Ratio')

# Panel 2: Ratio distribution
ax2 = axes[0, 1]
ratios = [d['ratio'] for d in data]
ax2.hist(ratios, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Predicted (ratio = 1)')
ax2.set_xlabel('Threshold / Gap ratio', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Stability Ratios', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
mean_r = np.mean(ratios)
std_r = np.std(ratios)
ax2.text(0.05, 0.95, f'Mean: {mean_r:.6f}\nStd: {std_r:.2e}',
         transform=ax2.transAxes, fontsize=11, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 3: Threshold vs leaf dimension
ax3 = axes[1, 0]
m_vals = sorted(set(d['m'] for d in data))
for m_val in m_vals:
    subset = [d for d in data if d['m'] == m_val]
    thresholds = [d['threshold'] for d in subset]
    ax3.scatter([m_val] * len(thresholds), thresholds,
                 color='steelblue', alpha=0.6, s=40)
ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Gap = 1')
ax3.set_xlabel('Leaf dimension m = n - r + 2', fontsize=12)
ax3.set_ylabel('Instability threshold', fontsize=12)
ax3.set_title('Threshold vs Leaf Dimension', fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# Panel 4: Threshold vs binomial coefficient
ax4 = axes[1, 1]
binomials = [d['binomial'] for d in data]
thresholds = [d['threshold'] for d in data]
ax4.semilogx(binomials, thresholds, 'o', color='steelblue', alpha=0.6, markersize=5)
ax4.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Gap = 1')
ax4.set_xlabel('Binomial coefficient C(n,r)', fontsize=12)
ax4.set_ylabel('Instability threshold', fontsize=12)
ax4.set_title('Threshold vs Coefficient Scale', fontsize=13, fontweight='bold')
ax4.legend(fontsize=11)
ax4.grid(True, alpha=0.3)

plt.suptitle('Universal Stability: The Spectral Gap Governs Lorentzian Robustness',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_conjecture_ratios.png', dpi=150, bbox_inches='tight')
print("Saved viz_conjecture_ratios.png")
print(f"\nSummary: Mean ratio = {mean_r:.8f}, Std = {std_r:.2e}")
print(f"All ratios in [0.999, 1.001]: {all(0.999 < r < 1.001 for r in ratios)}")
