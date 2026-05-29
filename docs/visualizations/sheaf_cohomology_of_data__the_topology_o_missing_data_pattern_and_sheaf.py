"""
Visualization 1: Missing Data Pattern and Sheaf Structure

Visualizes the observation mask as a heatmap, showing which entries are
observed vs missing, and the resulting coboundary norm as missing rate varies.
This illustrates the core insight that missing data creates "holes" in the
data sheaf, and the coboundary measures the size of these holes.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

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

rng = np.random.default_rng(42)

fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle('Sheaf Cohomology of Missing Data', fontsize=16, fontweight='bold')

# Top row: observation masks at different missing rates
m, n = 20, 8
rates = [0.1, 0.3, 0.6]
ground_truth = rng.standard_normal((m, n))

for idx, r in enumerate(rates):
    ax = axes[0, idx]
    mask = (rng.random((m, n)) >= r)
    
    # Color: green=observed, red=missing
    display = np.zeros((m, n, 3))
    display[mask] = [0.2, 0.7, 0.3]   # green for observed
    display[~mask] = [0.8, 0.2, 0.2]  # red for missing
    
    ax.imshow(display, aspect='auto', interpolation='nearest')
    ax.set_title(f'Missing Rate = {r:.0%}', fontsize=12)
    ax.set_xlabel('Features')
    ax.set_ylabel('Observations')
    
    n_missing = np.sum(~mask)
    ax.text(0.5, -0.15, f'{n_missing} missing entries',
            transform=ax.transAxes, ha='center', fontsize=10)

# Add legend
obs_patch = mpatches.Patch(color=[0.2, 0.7, 0.3], label='Observed')
miss_patch = mpatches.Patch(color=[0.8, 0.2, 0.2], label='Missing')
axes[0, 2].legend(handles=[obs_patch, miss_patch], loc='upper right', fontsize=9)

# Bottom left: Coboundary norm vs missing rate
ax = axes[1, 0]
rates_fine = np.arange(0.0, 0.85, 0.05)
norms = []
for r in rates_fine:
    mask = (np.random.RandomState(42).random((m, n)) >= r).astype(bool)
    imputed = mean_impute(mask, ground_truth)
    d0 = coboundary_delta0(imputed)
    norm = coboundary_norm_sq_full(mask, d0)
    norms.append(norm)

ax.plot(rates_fine, norms, 'b-o', markersize=4, linewidth=2)
ax.set_xlabel('Missing Rate r', fontsize=11)
ax.set_ylabel('Coboundary Norm² (Inconsistency)', fontsize=11)
ax.set_title('Obstruction Growth', fontsize=12)
ax.grid(True, alpha=0.3)

# Bottom middle: Theoretical prediction
ax = axes[1, 1]
r_theory = np.linspace(0.01, 0.85, 50)
theoretical = r_theory * n * r_theory * np.log(1.0 / r_theory)
ax.plot(r_theory, theoretical, 'r-', linewidth=2, label='r·n·r·log(1/r)')
ax.plot(rates_fine[1:], [norms[i] / max(norms) * max(theoretical) 
                          for i in range(1, len(norms))],
        'b--o', markersize=3, linewidth=1.5, label='Scaled empirical')
ax.set_xlabel('Missing Rate r', fontsize=11)
ax.set_ylabel('Predicted H¹ Dimension', fontsize=11)
ax.set_title('Super-linear Conjecture', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Bottom right: Shared features decay
ax = axes[1, 2]
shared_counts = []
for r in rates_fine:
    mask = (np.random.RandomState(42).random((m, n)) >= r).astype(bool)
    total_shared = 0
    pairs = 0
    for i in range(m):
        for j in range(i+1, m):
            shared = np.sum(mask[i] & mask[j])
            total_shared += shared
            pairs += 1
    avg_shared = total_shared / pairs if pairs > 0 else 0
    shared_counts.append(avg_shared)

ax.plot(rates_fine, shared_counts, 'g-s', markersize=4, linewidth=2)
ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5, label=f'n={n} (complete)')
ax.set_xlabel('Missing Rate r', fontsize=11)
ax.set_ylabel('Avg Shared Features per Pair', fontsize=11)
ax.set_title('Information Overlap Decay', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_missing_pattern.png', dpi=150, bbox_inches='tight')
print("Saved viz_missing_pattern.png")
