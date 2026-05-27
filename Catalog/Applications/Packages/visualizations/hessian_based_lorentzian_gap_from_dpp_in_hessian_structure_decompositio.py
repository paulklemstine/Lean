"""
Visualization: Principal Minor Matrix Structure

This script visualizes the decomposition H = d·dᵀ - K⊙K for a DPP kernel,
showing how the rank-1 outer product and Hadamard square combine to produce
the Lorentzian Hessian structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor_matrix(K):
    d = np.diag(K)
    return np.outer(d, d) - K * K


def tfim_correlation_matrix(n, J, h):
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


# Create figure with 3 panels
fig, axes = plt.subplots(2, 3, figsize=(15, 10))

n = 6
K = tfim_correlation_matrix(n, J=1.0, h=0.5)
d = np.diag(K)
ddT = np.outer(d, d)
KoK = K * K
H = ddT - KoK

# Top row: Matrix decomposition
vmax = max(np.max(np.abs(ddT)), np.max(np.abs(KoK)), np.max(np.abs(H)))

im0 = axes[0, 0].imshow(ddT, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 0].set_title('d·dᵀ (Rank-1 Outer Product)', fontsize=12)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('i')
plt.colorbar(im0, ax=axes[0, 0], shrink=0.8)

im1 = axes[0, 1].imshow(KoK, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 1].set_title('K ⊙ K (Hadamard Square)', fontsize=12)
axes[0, 1].set_xlabel('j')
plt.colorbar(im1, ax=axes[0, 1], shrink=0.8)

im2 = axes[0, 2].imshow(H, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 2].set_title('H = d·dᵀ - K⊙K\n(Principal Minor Matrix)', fontsize=12)
axes[0, 2].set_xlabel('j')
plt.colorbar(im2, ax=axes[0, 2], shrink=0.8)

# Bottom left: Eigenvalue spectrum of H
eigs_H = np.sort(np.linalg.eigvalsh(H))[::-1]
colors = ['#e74c3c' if e > 1e-10 else '#3498db' if e < -1e-10 else '#95a5a6' for e in eigs_H]
axes[1, 0].bar(range(n), eigs_H, color=colors, edgecolor='black', linewidth=0.5)
axes[1, 0].axhline(y=0, color='black', linewidth=0.5)
axes[1, 0].set_xlabel('Eigenvalue index')
axes[1, 0].set_ylabel('Eigenvalue')
axes[1, 0].set_title('Eigenvalue Spectrum of H\n(Red=positive, Blue=negative)', fontsize=12)
axes[1, 0].grid(True, alpha=0.3)

# Bottom middle: Comparison across field values
h_vals = np.linspace(0.1, 3.0, 40)
gaps = []
deltas = []
for h in h_vals:
    K_h = tfim_correlation_matrix(n, J=1.0, h=h)
    H_h = principal_minor_matrix(K_h)
    eigs = np.sort(np.linalg.eigvalsh(H_h))[::-1]
    gaps.append(eigs[0] - eigs[1])
    eigs_K = np.linalg.eigvalsh(K_h)
    deltas.append(np.min(np.minimum(eigs_K, 1 - eigs_K)))

axes[1, 1].plot(h_vals, gaps, 'b-', linewidth=2, label='Lorentzian gap')
axes[1, 1].axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='h = J (critical)')
axes[1, 1].set_xlabel('Transverse field h')
axes[1, 1].set_ylabel('Eigenvalue gap λ₁ - λ₂')
axes[1, 1].set_title('Lorentzian Gap vs Field Strength\n(TFIM, n=6, J=1)', fontsize=12)
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

# Bottom right: Gap vs Δ² scatter
axes[1, 2].scatter(np.array(deltas)**2, gaps, c=h_vals, cmap='viridis', s=40, edgecolors='black', linewidth=0.5)
if len(deltas) > 0:
    d2 = np.array(deltas)**2
    g = np.array(gaps)
    mask = d2 > 1e-6
    if np.any(mask):
        slope = np.min(g[mask] / d2[mask])
        x_fit = np.linspace(0, np.max(d2), 100)
        axes[1, 2].plot(x_fit, slope * x_fit, 'r--', linewidth=2, label=f'Bound: {slope:.2f}·Δ²')
cbar = plt.colorbar(axes[1, 2].collections[0], ax=axes[1, 2], shrink=0.8)
cbar.set_label('h value')
axes[1, 2].set_xlabel('Δ²')
axes[1, 2].set_ylabel('Eigenvalue gap')
axes[1, 2].set_title('Gap ∝ Δ² (Quadratic Bound)', fontsize=12)
axes[1, 2].legend()
axes[1, 2].grid(True, alpha=0.3)

plt.suptitle('Hessian Decomposition of DPP Generating Polynomial\n'
             'H = d·dᵀ - K⊙K  reveals Lorentzian signature',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('hessian_structure.png', dpi=150, bbox_inches='tight')
print("Saved: hessian_structure.png")
