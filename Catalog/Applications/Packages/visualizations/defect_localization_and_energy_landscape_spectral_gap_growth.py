"""
Visualization: Spectral Gap Growth vs Matrix Size

This script shows how the spectral gap of the energy landscape grows
with matrix size n, comparing supercritical (c > 1) with subcritical
(c < 1) regimes. The theoretical prediction C·σ·√(log n) is overlaid.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───────────────────────────────────────

def diag_ex_slack_matrix(W):
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

def compute_gap(W):
    n = W.shape[0]
    S = diag_ex_slack_matrix(W)
    slacks = []
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks.append(S[i, j])
    slacks.sort()
    return slacks[1] - slacks[0] if len(slacks) > 1 else 0.0

# ─── Experiment ──────────────────────────────────────────────────────────────

np.random.seed(2024)

n_values = [10, 20, 30, 50, 75, 100, 150, 200]
c_values = [0.5, 1.0, 2.0, 3.0]
n_samples = 500

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Median gap vs n for different c values
for c in c_values:
    median_gaps = []
    for n in n_values:
        gaps = []
        for _ in range(n_samples):
            mu_off = c * np.sqrt(np.log(n))
            W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
            gaps.append(compute_gap(W))
        median_gaps.append(np.median(gaps))
    
    style = '-o' if c >= 1.0 else '--s'
    ax1.plot(n_values, median_gaps, style, label=f'c={c}', linewidth=2, markersize=6)

# Theoretical curve
n_theory = np.linspace(8, 220, 100)
ax1.plot(n_theory, 0.45 * np.sqrt(np.log(n_theory)), ':', color='gray',
         linewidth=2, label=r'$0.45 \sqrt{\log n}$ (theory)')

ax1.set_xlabel('Matrix size n', fontsize=13)
ax1.set_ylabel('Median spectral gap', fontsize=13)
ax1.set_title('Spectral Gap Growth', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Right: Gap distribution for fixed n=100
n_fixed = 100
for c in [0.5, 1.5, 3.0]:
    gaps = []
    for _ in range(1000):
        mu_off = c * np.sqrt(np.log(n_fixed))
        W = mean_model(n_fixed, 0, mu_off) + np.random.randn(n_fixed, n_fixed)
        gaps.append(compute_gap(W))
    ax2.hist(gaps, bins=40, alpha=0.5, label=f'c={c}', density=True)

ax2.set_xlabel('Spectral gap', fontsize=13)
ax2.set_ylabel('Density', fontsize=13)
ax2.set_title(f'Gap Distribution (n={n_fixed})', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_gap_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_gap_growth.png")
