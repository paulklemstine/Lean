"""
Visualization: Cauchy-Schwarz Inequality for PSD Matrices

Scatter plot of K_ij² vs K_ii·K_jj for many random PSD matrices,
showing the Cauchy-Schwarz inequality K_ij² ≤ K_ii·K_jj holds universally.
The boundary curve is the parabola of equality.
"""
import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    rank = min(rank, n)
    B = np.random.randn(rank, n)
    return B.T @ B


np.random.seed(42)

lhs_vals = []  # K_ij²
rhs_vals = []  # K_ii · K_jj
gap_vals = []  # K_ii·K_jj - K_ij²

for _ in range(200):
    n = np.random.choice([3, 4, 5, 6])
    rank = np.random.randint(1, n + 1)
    K = random_psd_matrix(n, rank)

    for i in range(n):
        for j in range(i + 1, n):
            kij_sq = K[i, j] ** 2
            kii_kjj = K[i, i] * K[j, j]
            lhs_vals.append(kij_sq)
            rhs_vals.append(kii_kjj)
            gap_vals.append(kii_kjj - kij_sq)

lhs_vals = np.array(lhs_vals)
rhs_vals = np.array(rhs_vals)
gap_vals = np.array(gap_vals)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('PSD Entry Cauchy-Schwarz: K²ᵢⱼ ≤ Kᵢᵢ · Kⱼⱼ',
             fontsize=14, fontweight='bold')

# Left: scatter
ax1.scatter(rhs_vals, lhs_vals, alpha=0.3, s=10, c='#3498db', edgecolors='none')
max_val = max(rhs_vals.max(), lhs_vals.max()) * 1.1
ax1.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (equality)')
ax1.set_xlabel('Kᵢᵢ · Kⱼⱼ', fontsize=12)
ax1.set_ylabel('K²ᵢⱼ', fontsize=12)
ax1.set_title('All points below diagonal', fontsize=11)
ax1.legend(fontsize=10)
ax1.set_xlim(0, max_val)
ax1.set_ylim(0, max_val)
ax1.set_aspect('equal')

# Right: histogram of gaps
ax2.hist(gap_vals, bins=50, color='#2ecc71', edgecolor='black', alpha=0.8)
ax2.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Gap = 0')
ax2.set_xlabel('Gap: Kᵢᵢ·Kⱼⱼ - K²ᵢⱼ', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title(f'All {len(gap_vals)} gaps ≥ 0', fontsize=11)
ax2.legend(fontsize=10)

min_gap = gap_vals.min()
ax2.annotate(f'Min gap: {min_gap:.2e}', xy=(min_gap, 0),
             xytext=(min_gap + max(gap_vals) * 0.1, max(np.histogram(gap_vals, 50)[0]) * 0.5),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=10, color='red')

plt.tight_layout()
plt.savefig('cauchy_schwarz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cauchy_schwarz.png")
