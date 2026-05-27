"""
Visualization: Correlation Stability Heatmap

Visualizes the stability of k-point correlation functions (principal minors)
under kernel perturbation. Shows heatmaps of original vs perturbed correlations
and the certified error bounds.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k, M):
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


np.random.seed(42)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

n = 6
# Create a nice PSD matrix
U = np.linalg.qr(np.random.randn(n, n))[0]
eigenvalues = np.array([0.9, 0.7, 0.5, 0.3, 0.2, 0.1])
K = U @ np.diag(eigenvalues) @ U.T
K = (K + K.T) / 2

eta = 0.02
E = np.random.uniform(-eta, eta, (n, n))
E = (E + E.T) / 2
K_prime = K + E

M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))

# Row 1: k=2 pairwise correlations
k = 2
subsets = list(combinations(range(n), k))
n_sub = len(subsets)

original_vals = np.array([np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets])
perturbed_vals = np.array([np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets])
errors = np.abs(original_vals - perturbed_vals)
bound = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))

labels = [f'{S}' for S in subsets]

ax = axes[0, 0]
ax.bar(range(n_sub), original_vals, alpha=0.7, color='steelblue', label='Original')
ax.bar(range(n_sub), perturbed_vals, alpha=0.5, color='coral', label='Perturbed')
ax.set_xticks(range(n_sub))
ax.set_xticklabels(labels, rotation=45, fontsize=7)
ax.set_ylabel('det(K_S)', fontsize=11)
ax.set_title(f'k=2: Pairwise Correlations', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

ax = axes[0, 1]
ax.bar(range(n_sub), errors, alpha=0.8, color='orange')
ax.axhline(y=bound, color='red', linestyle='--', linewidth=2, label=f'Certified bound = {bound:.4f}')
ax.set_xticks(range(n_sub))
ax.set_xticklabels(labels, rotation=45, fontsize=7)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=11)
ax.set_title(f'k=2: Perturbation Errors', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Heatmap: pairwise correlation matrix
ax = axes[0, 2]
corr_matrix = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i == j:
            corr_matrix[i, j] = K[i, i]
        else:
            corr_matrix[i, j] = np.linalg.det(K[np.ix_([i, j], [i, j])])
im = ax.imshow(corr_matrix, cmap='YlOrRd', aspect='auto')
ax.set_title('Pairwise Correlation Matrix', fontsize=12)
ax.set_xlabel('Site j', fontsize=11)
ax.set_ylabel('Site i', fontsize=11)
plt.colorbar(im, ax=ax, label='det(K_{i,j})')

# Row 2: k=3 triple correlations
k = 3
subsets = list(combinations(range(n), k))
n_sub = len(subsets)

original_vals = np.array([np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets])
perturbed_vals = np.array([np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets])
errors = np.abs(original_vals - perturbed_vals)
bound = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))

labels = [f'{S}' for S in subsets]

ax = axes[1, 0]
ax.bar(range(n_sub), original_vals, alpha=0.7, color='steelblue', label='Original')
ax.bar(range(n_sub), perturbed_vals, alpha=0.5, color='coral', label='Perturbed')
ax.set_xticks(range(0, n_sub, 2))
ax.set_xticklabels([labels[i] for i in range(0, n_sub, 2)], rotation=45, fontsize=6)
ax.set_ylabel('det(K_S)', fontsize=11)
ax.set_title(f'k=3: Triple Correlations', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

ax = axes[1, 1]
ax.bar(range(n_sub), errors, alpha=0.8, color='orange')
ax.axhline(y=bound, color='red', linestyle='--', linewidth=2, label=f'Certified bound = {bound:.4f}')
ax.set_xticks(range(0, n_sub, 2))
ax.set_xticklabels([labels[i] for i in range(0, n_sub, 2)], rotation=45, fontsize=6)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=11)
ax.set_title(f'k=3: Perturbation Errors', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Sorted errors vs bound
ax = axes[1, 2]
all_errors = []
all_bounds = []
for k in range(1, 5):
    subsets = list(combinations(range(n), k))
    b = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))
    for S in subsets:
        err = abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                  np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
        all_errors.append(err)
        all_bounds.append(b)

sorted_idx = np.argsort(all_errors)[::-1]
all_errors = np.array(all_errors)[sorted_idx]
all_bounds = np.array(all_bounds)[sorted_idx]

ax.semilogy(range(len(all_errors)), all_errors, 'b.', markersize=3, label='Empirical errors')
ax.semilogy(range(len(all_bounds)), all_bounds, 'r-', linewidth=1.5, label='Certified bounds')
ax.set_xlabel('Subset index (sorted by error)', fontsize=11)
ax.set_ylabel('Error magnitude', fontsize=11)
ax.set_title('All Errors vs Certified Bounds (k=1..4)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle(f'k-Point Correlation Stability Under Perturbation (n={n}, η={eta})',
             fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig('viz_correlation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_correlation_heatmap.png")
