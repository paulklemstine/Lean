#!/usr/bin/env python3
"""
Visualization: Tropical Fractional Helly Conjecture

Tests the conjecture computationally by generating random tropical
halfspaces and plotting the relationship between:
- α: fraction of (n+1)-subfamilies with nonempty intersection
- β: maximum fraction of sets containing any single point

The conjecture predicts β ≥ c·α for some constant c > 0.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def farkas_point(A, b):
    """Farkas construction: x_i = max_j(b_j - A_ji)."""
    m, n = A.shape
    x = np.array([np.max(b - A[:, i]) for i in range(n)])
    for j in range(m):
        if np.max(A[j] + x) < b[j] - 1e-10:
            return None
    return x


def compute_alpha_beta(A, b, dim):
    """Compute α (intersection fraction) and β (coverage fraction)."""
    m = A.shape[0]
    k = min(dim + 1, m)
    
    total = 0
    intersecting = 0
    for combo in combinations(range(m), k):
        idx = list(combo)
        total += 1
        if farkas_point(A[idx], b[idx]) is not None:
            intersecting += 1
    
    alpha = intersecting / total if total > 0 else 0
    
    # Find best coverage point via Farkas + grid
    best_count = 0
    
    # Farkas point for full system
    fp = farkas_point(A, b)
    if fp is not None:
        count = sum(1 for j in range(m) if np.max(A[j] + fp) >= b[j] - 1e-10)
        best_count = max(best_count, count)
    
    # Random sampling
    for _ in range(200):
        x = np.random.randn(dim) * 3
        count = sum(1 for j in range(m) if np.max(A[j] + x) >= b[j] - 1e-10)
        best_count = max(best_count, count)
    
    beta = best_count / m if m > 0 else 0
    return alpha, beta


# Run experiments
np.random.seed(42)
n_trials = 300
dim = 3
m = 12

alphas, betas = [], []
for trial in range(n_trials):
    A = np.random.randn(m, dim) * 2
    b = np.random.randn(m) * 1.5
    alpha, beta = compute_alpha_beta(A, b, dim)
    alphas.append(alpha)
    betas.append(beta)

alphas = np.array(alphas)
betas = np.array(betas)

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Scatter plot α vs β ---
ax = axes[0]
sc = ax.scatter(alphas, betas, c=alphas, cmap='RdYlGn', s=20, alpha=0.7, 
                edgecolors='gray', linewidths=0.3)

# Reference lines
ax.plot([0, 1], [0, 1], 'k--', alpha=0.3, label='β = α')
ax.plot([0, 1], [0, 0.5], 'b--', alpha=0.3, label='β = α/2')

# Trend line
from numpy.polynomial import polynomial as P
mask = alphas > 0.05
if mask.sum() > 10:
    coeffs = np.polyfit(alphas[mask], betas[mask], 1)
    x_fit = np.linspace(0, 1, 100)
    y_fit = np.polyval(coeffs, x_fit)
    ax.plot(x_fit, np.clip(y_fit, 0, 1), 'r-', linewidth=2, alpha=0.8, 
            label=f'Trend: β ≈ {coeffs[0]:.2f}α + {coeffs[1]:.2f}')

ax.set_xlabel('α (fraction of 4-tuples intersecting)', fontsize=12)
ax.set_ylabel('β (best coverage fraction)', fontsize=12)
ax.set_title('Tropical Fractional Helly Conjecture Test\n'
             f'(n={dim}, m={m}, {n_trials} trials)', fontsize=13, fontweight='bold')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 1.05)
ax.legend(fontsize=9, loc='lower right')
ax.grid(True, alpha=0.3)
plt.colorbar(sc, ax=ax, label='α value')

# Highlight region where conjecture might fail
fail_mask = betas < 0.1 * alphas
if fail_mask.any():
    ax.scatter(alphas[fail_mask], betas[fail_mask], facecolors='none', 
               edgecolors='red', s=100, linewidths=2, label='Potential failures')

# --- Panel 2: Binned statistics ---
ax = axes[1]
bins = np.linspace(0, 1, 11)
bin_centers = (bins[:-1] + bins[1:]) / 2
mean_betas = []
min_betas = []
max_betas = []

for i in range(len(bins) - 1):
    mask = (alphas >= bins[i]) & (alphas < bins[i+1])
    if mask.sum() > 0:
        mean_betas.append(np.mean(betas[mask]))
        min_betas.append(np.min(betas[mask]))
        max_betas.append(np.max(betas[mask]))
    else:
        mean_betas.append(np.nan)
        min_betas.append(np.nan)
        max_betas.append(np.nan)

mean_betas = np.array(mean_betas)
min_betas = np.array(min_betas)
max_betas = np.array(max_betas)

valid = ~np.isnan(mean_betas)
ax.fill_between(bin_centers[valid], min_betas[valid], max_betas[valid], 
                alpha=0.3, color='#377eb8', label='Min–Max range')
ax.plot(bin_centers[valid], mean_betas[valid], 'o-', color='#377eb8', 
        linewidth=2, markersize=8, label='Mean β')
ax.plot([0, 1], [0, 1], 'k--', alpha=0.3, label='β = α')

ax.set_xlabel('α (fraction of 4-tuples intersecting)', fontsize=12)
ax.set_ylabel('β (best coverage fraction)', fontsize=12)
ax.set_title('Binned Statistics\n(Mean ± Range)', fontsize=13, fontweight='bold')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 1.05)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Verdict
verdict = "SUPPORTED" if np.all(min_betas[valid] >= 0.05 * bin_centers[valid] - 0.01) else "UNCLEAR"
fig.text(0.5, 0.01, f'Conjecture status: {verdict} (β ≥ c·α for some c > 0)', 
         ha='center', fontsize=12, fontweight='bold',
         color='green' if verdict == "SUPPORTED" else 'orange')

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.savefig('fractional_helly.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fractional_helly.png")
