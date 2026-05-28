"""
Visualization 1: Hessian Eigenvalue Spectrum for DPP Kernels

This script visualizes the eigenvalue distribution of the resolvent Hessian
for random PSD contraction kernels of varying dimension and rank.
The key prediction: exactly one positive eigenvalue for every nonzero kernel.
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_psd_contraction(n, rank=None, seed=None):
    rng = np.random.default_rng(seed)
    if rank is None:
        rank = n
    rank = min(rank, n)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = np.zeros(n)
    eigs[:rank] = rng.uniform(0.05, 0.95, rank)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_hessian_eigenvalues(K):
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag = np.diag(L)
    H = det_A * (np.outer(diag, diag) - L ** 2)
    np.fill_diagonal(H, 0.0)
    return np.sort(np.linalg.eigvalsh(H))[::-1]


# Generate data
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Resolvent Hessian Eigenvalue Spectra for DPP Kernels', fontsize=16, fontweight='bold')

# Panel 1: Eigenvalue histograms for different dimensions
ax1 = axes[0, 0]
rng = np.random.default_rng(42)
for n, color in [(5, '#2196F3'), (10, '#4CAF50'), (20, '#FF9800'), (50, '#E91E63')]:
    all_eigs = []
    for seed in range(100):
        K = generate_psd_contraction(n, seed=seed * 1000 + n)
        eigs = compute_hessian_eigenvalues(K)
        all_eigs.extend(eigs)
    ax1.hist(all_eigs, bins=80, alpha=0.5, label=f'n={n}', color=color, density=True)

ax1.axvline(x=0, color='black', linewidth=0.5, linestyle='--')
ax1.set_xlabel('Eigenvalue', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title('Eigenvalue Distribution (100 random kernels each)', fontsize=12)
ax1.legend(fontsize=10)
ax1.set_xlim(-5, 2)

# Panel 2: Positive eigenvalue count (should always be 1)
ax2 = axes[0, 1]
dims = list(range(3, 31))
pos_counts = {d: [] for d in dims}
for d in dims:
    for trial in range(50):
        K = generate_psd_contraction(d, seed=trial * 100 + d)
        eigs = compute_hessian_eigenvalues(K)
        pos_counts[d].append(int(np.sum(eigs > 1e-10)))

means = [np.mean(pos_counts[d]) for d in dims]
ax2.bar(dims, means, color='#2196F3', alpha=0.7, edgecolor='black', linewidth=0.5)
ax2.axhline(y=1, color='red', linewidth=2, linestyle='--', label='Predicted: exactly 1')
ax2.set_xlabel('Matrix Dimension n', fontsize=12)
ax2.set_ylabel('# Positive Eigenvalues', fontsize=12)
ax2.set_title('Positive Eigenvalue Count (50 trials per dimension)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 2)

# Panel 3: Largest vs second-largest eigenvalue
ax3 = axes[1, 0]
largest = []
second = []
for trial in range(500):
    n = np.random.randint(3, 30)
    K = generate_psd_contraction(n, seed=trial)
    eigs = compute_hessian_eigenvalues(K)
    if len(eigs) >= 2:
        largest.append(eigs[0])
        second.append(eigs[1])

ax3.scatter(largest, second, s=8, alpha=0.5, c='#2196F3', edgecolors='none')
ax3.axhline(y=0, color='red', linewidth=1.5, linestyle='--', label='λ₂ = 0 boundary')
ax3.set_xlabel('Largest eigenvalue λ₁', fontsize=12)
ax3.set_ylabel('Second eigenvalue λ₂', fontsize=12)
ax3.set_title('λ₁ vs λ₂: Lorentzian Signature (1, n-1)', fontsize=12)
ax3.legend(fontsize=10)

# Panel 4: Hessian heatmap for a specific kernel
ax4 = axes[1, 1]
K_example = generate_psd_contraction(12, seed=42)
n = K_example.shape[0]
A = np.eye(n) + K_example
L = np.linalg.inv(A)
det_A = np.linalg.det(A)
diag = np.diag(L)
H = det_A * (np.outer(diag, diag) - L ** 2)
np.fill_diagonal(H, 0.0)

im = ax4.imshow(H, cmap='RdBu_r', aspect='equal',
                vmin=-np.max(np.abs(H)), vmax=np.max(np.abs(H)))
plt.colorbar(im, ax=ax4, shrink=0.8)
ax4.set_title(f'Resolvent Hessian (n=12, det={det_A:.2f})', fontsize=12)
ax4.set_xlabel('Column index j', fontsize=12)
ax4.set_ylabel('Row index i', fontsize=12)

plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")
