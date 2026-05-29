"""
Visualization 2: Imputation Method Comparison

Compares sheaf-theoretic imputation with mean imputation across different
missing rates, showing RMSE, coboundary norm, and reconstruction quality.
This visualizes the main practical result: sheaf imputation produces more
consistent reconstructions, especially when data has structure.
"""

import numpy as np
import matplotlib.pyplot as plt

# Self-contained implementations
def coboundary_delta0(data):
    return data[None, :, :] - data[:, None, :]

def coboundary_norm_sq_full(mask, g):
    m, n = mask.shape
    total = 0.0
    for i in range(m):
        for j in range(m):
            shared = np.where(mask[i] & mask[j])[0]
            if len(shared) > 0:
                total += np.sum(g[i, j, shared] ** 2)
    return total

def mean_impute(mask, data):
    imputed = data.copy()
    m, n = mask.shape
    for j in range(n):
        obs = data[mask[:, j], j]
        imputed[~mask[:, j], j] = np.mean(obs) if len(obs) > 0 else 0.0
    return imputed

def sheaf_impute(mask, data, max_iter=50, tol=1e-6):
    m, n = mask.shape
    imputed = mean_impute(mask, data)
    for _ in range(max_iter):
        old = imputed.copy()
        for i in range(m):
            for k in range(n):
                if mask[i, k]: continue
                tw, ws = 0.0, 0.0
                for j in range(m):
                    if j != i and mask[j, k]:
                        shared = np.sum(mask[i] & mask[j])
                        w = shared + 1
                        ws += w * imputed[j, k]; tw += w
                if tw > 0: imputed[i, k] = ws / tw
        if np.max(np.abs(imputed - old)) < tol: break
    return imputed


rng = np.random.default_rng(42)

# Generate structured low-rank data
m, n = 25, 6
U = rng.standard_normal((m, 2))
V = rng.standard_normal((2, n))
ground_truth = U @ V + 0.2 * rng.standard_normal((m, n))

rates = np.arange(0.05, 0.75, 0.05)
mean_rmses, sheaf_rmses = [], []
mean_cbs, sheaf_cbs = [], []

for r in rates:
    mask = (rng.random((m, n)) >= r).astype(bool)
    
    mi = mean_impute(mask, ground_truth)
    si = sheaf_impute(mask, ground_truth)
    
    missing = ~mask
    if np.any(missing):
        mean_rmses.append(np.sqrt(np.mean((mi[missing] - ground_truth[missing]) ** 2)))
        sheaf_rmses.append(np.sqrt(np.mean((si[missing] - ground_truth[missing]) ** 2)))
        
        mean_cbs.append(coboundary_norm_sq_full(mask, coboundary_delta0(mi)))
        sheaf_cbs.append(coboundary_norm_sq_full(mask, coboundary_delta0(si)))
    else:
        mean_rmses.append(0); sheaf_rmses.append(0)
        mean_cbs.append(0); sheaf_cbs.append(0)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Sheaf Imputation vs Mean Imputation', fontsize=16, fontweight='bold')

# RMSE comparison
ax = axes[0, 0]
ax.plot(rates, mean_rmses, 'r-o', markersize=4, linewidth=2, label='Mean Imputation')
ax.plot(rates, sheaf_rmses, 'b-s', markersize=4, linewidth=2, label='Sheaf Imputation')
ax.set_xlabel('Missing Rate', fontsize=11)
ax.set_ylabel('RMSE', fontsize=11)
ax.set_title('Reconstruction Error', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Coboundary norm comparison
ax = axes[0, 1]
ax.plot(rates, mean_cbs, 'r-o', markersize=4, linewidth=2, label='Mean Imputation')
ax.plot(rates, sheaf_cbs, 'b-s', markersize=4, linewidth=2, label='Sheaf Imputation')
ax.set_xlabel('Missing Rate', fontsize=11)
ax.set_ylabel('Coboundary Norm²', fontsize=11)
ax.set_title('Data Inconsistency', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Improvement percentage
ax = axes[1, 0]
improvements = [(mr - sr) / mr * 100 if mr > 0 else 0 
                for mr, sr in zip(mean_rmses, sheaf_rmses)]
colors = ['green' if imp > 0 else 'red' for imp in improvements]
ax.bar(range(len(rates)), improvements, color=colors, alpha=0.7)
ax.set_xticks(range(0, len(rates), 3))
ax.set_xticklabels([f'{r:.0%}' for r in rates[::3]])
ax.set_xlabel('Missing Rate', fontsize=11)
ax.set_ylabel('RMSE Improvement (%)', fontsize=11)
ax.set_title('Sheaf Advantage Over Mean', fontsize=12)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.grid(True, alpha=0.3, axis='y')

# Scatter: RMSE vs Coboundary Norm
ax = axes[1, 1]
ax.scatter(mean_cbs, mean_rmses, c='red', s=50, alpha=0.7, 
           label='Mean', marker='o', edgecolors='darkred')
ax.scatter(sheaf_cbs, sheaf_rmses, c='blue', s=50, alpha=0.7, 
           label='Sheaf', marker='s', edgecolors='darkblue')

# Connect corresponding points
for i in range(len(rates)):
    ax.annotate('', xy=(sheaf_cbs[i], sheaf_rmses[i]),
                xytext=(mean_cbs[i], mean_rmses[i]),
                arrowprops=dict(arrowstyle='->', color='gray', alpha=0.3))

ax.set_xlabel('Coboundary Norm² (Inconsistency)', fontsize=11)
ax.set_ylabel('RMSE (Error)', fontsize=11)
ax.set_title('Error vs Inconsistency Trade-off', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_imputation_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_imputation_comparison.png")
