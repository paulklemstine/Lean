"""
Visualization: Affected Node Heatmap
=====================================

Visualizes the affected derivative node counts across different update
exponents and derivative depths. Shows how sparsity of the update monomial
controls the number of certificate nodes that need recomputation.

This is the core visual insight of the locality theorem: sparse updates
create sparse certificate perturbations.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


def affected_count(alpha, k):
    """Count multiindices beta with sum(beta)=k and beta_i <= alpha_i."""
    n = len(alpha)
    result = [0]
    def _bt(idx, rem, cur):
        if idx == n:
            if rem == 0:
                result[0] += 1
            return
        for v in range(min(alpha[idx], rem) + 1):
            _bt(idx + 1, rem - v, cur + [v])
    _bt(0, k, [])
    return result[0]


def dynamic_cert_cost(alpha, d):
    return sum(affected_count(alpha, k) for k in range(d - 1))


# Parameters
n = 6  # number of variables
d = 5  # degree

# Generate different update patterns
patterns = {
    'Concentrated\n(5,0,0,0,0,0)': (5, 0, 0, 0, 0, 0),
    'Semi-sparse\n(3,2,0,0,0,0)': (3, 2, 0, 0, 0, 0),
    'Moderate\n(2,1,1,1,0,0)': (2, 1, 1, 1, 0, 0),
    'Spread\n(2,1,1,1,0,0)': (1, 1, 1, 1, 1, 0),
    'Balanced\n(1,1,1,1,1,0)': (1, 1, 1, 1, 1, 0),
}

# Create heatmap data
depth_range = range(d - 1)
data = np.zeros((len(patterns), len(depth_range)))
labels = list(patterns.keys())

for i, (name, alpha) in enumerate(patterns.items()):
    for j, k in enumerate(depth_range):
        data[i, j] = affected_count(alpha, k)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap
ax = axes[0]
im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax.set_xticks(range(len(depth_range)))
ax.set_xticklabels([f'k={k}' for k in depth_range])
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Derivative Depth k', fontsize=12)
ax.set_ylabel('Update Pattern α', fontsize=12)
ax.set_title(f'Affected Node Counts (n={n}, d={d})', fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(labels)):
    for j in range(len(depth_range)):
        ax.text(j, i, f'{int(data[i, j])}', ha='center', va='center',
                fontsize=10, color='black' if data[i, j] < data.max() * 0.6 else 'white')

plt.colorbar(im, ax=ax, label='|Affected(α, k)|')

# Bar chart: total dynamic cost vs rebuild cost
ax2 = axes[1]
dyn_costs = [dynamic_cert_cost(alpha, d) for alpha in patterns.values()]
rebuild = n ** d

x = np.arange(len(patterns))
bars = ax2.barh(x, dyn_costs, color='steelblue', alpha=0.8, label='Dynamic Cost')
ax2.axvline(x=rebuild, color='red', linestyle='--', linewidth=2, label=f'Rebuild Cost ({rebuild})')
ax2.set_yticks(x)
ax2.set_yticklabels([k.split('\n')[0] for k in labels], fontsize=9)
ax2.set_xlabel('Certificate Nodes', fontsize=12)
ax2.set_title('Dynamic vs Rebuild Cost', fontsize=13, fontweight='bold')
ax2.legend(loc='lower right')

# Add speedup annotations
for i, (dc, bar) in enumerate(zip(dyn_costs, bars)):
    speedup = rebuild / dc if dc > 0 else float('inf')
    ax2.text(dc + rebuild * 0.02, i, f'{speedup:.1f}× speedup',
             va='center', fontsize=9, color='darkblue')

plt.tight_layout()
plt.savefig('viz_affected_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_affected_heatmap.png")
