"""
Visualization: Hankel Matrix Structure and Rank Profile

Visualizes the core mathematical object of motivic persistence theory:
the Hankel matrix H_n(a) = (a_{i+j}) built from a power-sum signal,
showing how its rank encodes the spectral complexity of the signal.

Creates a 2x2 panel:
- Top-left: Hankel matrix heatmap for a 3-eigenvalue signal
- Top-right: Vandermonde factorization verification (H = V*V^T)
- Bottom-left: Rank profiles for signals with 1, 2, 3, 4 eigenvalues
- Bottom-right: Reconstruction error as a function of truncation
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import matrix_rank


def power_sum_signal(alphas, r_max):
    return np.array([sum(a**r for a in alphas) for r in range(r_max)])


def hankel_matrix(seq, n):
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i + j < len(seq):
                H[i, j] = seq[i + j]
    return H


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Motivic Persistence: Hankel Matrix Analysis', fontsize=16, fontweight='bold')

# Panel 1: Hankel matrix heatmap
ax1 = axes[0, 0]
alphas = np.array([1.0, 2.0, 3.0])
seq = power_sum_signal(alphas, 16)
n = 6
H = hankel_matrix(seq, n)
im = ax1.imshow(np.log10(np.abs(H) + 1), cmap='YlOrRd', aspect='equal')
ax1.set_title(f'Hankel Matrix H₆ for α = {{1,2,3}}', fontsize=11)
ax1.set_xlabel('Column j')
ax1.set_ylabel('Row i')
for i in range(n):
    for j in range(n):
        ax1.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center', fontsize=8)
plt.colorbar(im, ax=ax1, label='log₁₀(|entry| + 1)')

# Panel 2: Vandermonde factorization error
ax2 = axes[0, 1]
sizes = range(2, 10)
errors = []
for n_test in sizes:
    H_test = hankel_matrix(seq, n_test)
    V = np.array([[a**i for a in alphas] for i in range(n_test)])
    VVT = V @ V.T
    errors.append(np.max(np.abs(H_test - VVT)))
ax2.semilogy(list(sizes), errors, 'bo-', markersize=8, linewidth=2)
ax2.axhline(y=1e-12, color='g', linestyle='--', alpha=0.7, label='Machine precision')
ax2.set_title('Vandermonde Factorization: H = V·Vᵀ', fontsize=11)
ax2.set_xlabel('Matrix size n')
ax2.set_ylabel('Max |H - V·Vᵀ|')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Panel 3: Rank profiles for different spectral orders
ax3 = axes[1, 0]
families = {
    'm=1: {2}': [2.0],
    'm=2: {1,3}': [1.0, 3.0],
    'm=3: {1,2,3}': [1.0, 2.0, 3.0],
    'm=4: {1,2,3,5}': [1.0, 2.0, 3.0, 5.0],
}
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
n_max = 8
for (name, alphas_i), color in zip(families.items(), colors):
    seq_i = power_sum_signal(np.array(alphas_i), 2 * n_max + 2)
    profile = [0]
    for n_i in range(1, n_max + 1):
        H_i = hankel_matrix(seq_i, n_i)
        profile.append(matrix_rank(H_i, tol=1e-10))
    ax3.plot(range(n_max + 1), profile, 'o-', color=color, label=name,
             markersize=7, linewidth=2)
ax3.set_title('Persistence Profiles (Theorem 2)', fontsize=11)
ax3.set_xlabel('Truncation level n')
ax3.set_ylabel('rank(Hₙ)')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_yticks(range(5))

# Panel 4: Prony reconstruction error
ax4 = axes[1, 1]
true_alphas = np.array([1.0, 2.0, 3.0])
m = len(true_alphas)
trunc_levels = range(2*m, 2*m + 8)
recon_errors = []
for r_max_test in trunc_levels:
    seq_test = power_sum_signal(true_alphas, r_max_test)
    H_p = np.array([[seq_test[i+j] for j in range(m)] for i in range(m)])
    h_p = np.array([seq_test[i+m] for i in range(m)])
    try:
        c = np.linalg.solve(H_p, -h_p)
        poly_c = np.zeros(m + 1)
        poly_c[m] = 1.0
        for i in range(m):
            poly_c[i] = c[i]
        roots = np.sort(np.real(np.roots(poly_c[::-1])))
        err = np.max(np.abs(roots - np.sort(true_alphas)))
    except Exception:
        err = 1.0
    recon_errors.append(err)
ax4.semilogy(list(trunc_levels), recon_errors, 'rs-', markersize=8, linewidth=2)
ax4.set_title('Spectral Reconstruction Error (Theorem 3)', fontsize=11)
ax4.set_xlabel('Number of power sums used')
ax4.set_ylabel('Max |α_recovered - α_true|')
ax4.grid(True, alpha=0.3)
ax4.axhline(y=1e-12, color='g', linestyle='--', alpha=0.7, label='Machine precision')
ax4.legend()

plt.tight_layout()
plt.savefig('vis_hankel_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved vis_hankel_heatmap.png")
