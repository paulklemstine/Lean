"""
Visualization: Spectral Gap Heatmap Across Polynomial Families

Shows how the spectral gap varies across different elementary symmetric
polynomials e_k(x1,...,xn), revealing the landscape of numerical stability
for Lorentzian recognition.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (elementary_symmetric_polynomial_hessian, compute_spectral_gap,
                        lorentzian_condition_number)

max_n = 12
max_k = 10

gap_matrix = np.full((max_k, max_n), np.nan)
cond_matrix = np.full((max_k, max_n), np.nan)
sig_matrix = np.full((max_k, max_n), np.nan)

for n in range(2, max_n + 1):
    for k in range(2, min(n, max_k) + 1):
        H = elementary_symmetric_polynomial_hessian(n, k)
        gap, has_sig, eigenvalues = compute_spectral_gap(H)
        
        gap_matrix[k-1, n-1] = gap if has_sig else 0
        sig_matrix[k-1, n-1] = 1 if has_sig else 0
        
        if has_sig and gap > 0:
            max_ev = eigenvalues[0]
            cond_matrix[k-1, n-1] = max_ev / gap
        else:
            cond_matrix[k-1, n-1] = np.inf

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap 1: Spectral Gap
ax1 = axes[0]
im1 = ax1.imshow(gap_matrix[:max_k, :max_n], cmap='YlOrRd', aspect='auto',
                 origin='lower', interpolation='nearest')
ax1.set_xlabel('Number of variables n', fontsize=13)
ax1.set_ylabel('Degree k', fontsize=13)
ax1.set_title('Spectral Gap ε for e_k(x₁,...,xₙ)', fontsize=14)
ax1.set_xticks(range(max_n))
ax1.set_xticklabels(range(1, max_n + 1))
ax1.set_yticks(range(max_k))
ax1.set_yticklabels(range(1, max_k + 1))
plt.colorbar(im1, ax=ax1, label='Gap ε')

# Add text annotations
for k in range(max_k):
    for n in range(max_n):
        val = gap_matrix[k, n]
        if not np.isnan(val):
            color = 'white' if val > np.nanmax(gap_matrix) * 0.5 else 'black'
            ax1.text(n, k, f'{val:.1f}', ha='center', va='center', 
                    fontsize=7, color=color)

# Heatmap 2: Condition Number (log scale)
ax2 = axes[1]
log_cond = np.log10(np.where(np.isinf(cond_matrix), np.nan, cond_matrix))
im2 = ax2.imshow(log_cond[:max_k, :max_n], cmap='viridis', aspect='auto',
                 origin='lower', interpolation='nearest')
ax2.set_xlabel('Number of variables n', fontsize=13)
ax2.set_ylabel('Degree k', fontsize=13)
ax2.set_title('log₁₀(Condition Number κ_L) for e_k', fontsize=14)
ax2.set_xticks(range(max_n))
ax2.set_xticklabels(range(1, max_n + 1))
ax2.set_yticks(range(max_k))
ax2.set_yticklabels(range(1, max_k + 1))
plt.colorbar(im2, ax=ax2, label='log₁₀(κ_L)')

# Add text annotations
for k in range(max_k):
    for n in range(max_n):
        val = cond_matrix[k, n]
        if not np.isnan(val) and not np.isinf(val):
            lv = np.log10(val)
            color = 'white' if not np.isnan(lv) and lv > np.nanmean(log_cond) else 'black'
            ax2.text(n, k, f'{val:.1f}', ha='center', va='center', 
                    fontsize=7, color=color)

plt.tight_layout()
plt.savefig('gap_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved gap_heatmap.png")
