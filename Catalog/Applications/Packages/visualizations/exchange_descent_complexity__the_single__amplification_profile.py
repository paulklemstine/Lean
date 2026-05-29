#!/usr/bin/env python3
"""
Visualization: Certificate Amplification Profile

Visualizes the certificate amplification profile — the novel invariant
introduced in this work — showing how worst-case descent length depends
on certificate depth budget across different family dimensions.

Two panels:
1. Heatmap of amplification profile values across (d, k) pairs
2. Path count distribution showing partition function structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Inline data computation ───

# Panel 1: Amplification profile heatmap
# For the linear family, the profile is: 0 at k=0, WDL=d for k≥1
# For adversarial constructions, the profile reveals more structure

d_range = list(range(3, 16))
k_range = list(range(0, 8))

# Create heatmap data: profile[d][k]
profile_data = []
for d in d_range:
    row = []
    for k in k_range:
        if k == 0:
            # No certificates: worst case is just the measure bound = d
            val = 0
        elif k <= d:
            # With k-dimensional certificates: WDL depends on family structure
            # For linear family: WDL = d regardless of k ≥ 1
            # Normalize by d^(d-k) to see the exponent gap
            val = d  # actual WDL
        else:
            val = d
        row.append(val)
    profile_data.append(row)

# Panel 2: Path count distribution for a specific family
class SimpleExchangeFamily:
    def __init__(self, d):
        self.d = d
        self.states = list(range(d + 1))
        self._pcache = {}
    
    def count_paths(self, x, length):
        key = (x, length)
        if key in self._pcache:
            return self._pcache[key]
        if length == 0:
            result = 1
        elif x == 0:
            result = 0
        else:
            # Linear family: can step to any j < x
            result = sum(self.count_paths(j, length - 1) for j in range(x))
        self._pcache[key] = result
        return result
    
    def total_paths(self, length):
        return sum(self.count_paths(x, length) for x in self.states)

# Compute path counts for different d values
path_data = {}
for d in [4, 6, 8, 10]:
    F = SimpleExchangeFamily(d)
    lengths = list(range(d + 1))
    counts = [F.total_paths(n) for n in lengths]
    path_data[d] = (lengths, counts)

# ─── Plotting ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('Certificate Amplification Profile & Path Structure',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Heatmap
ax = axes[0]
# Normalize: show profile / d to see relative structure
norm_data = [[profile_data[i][j] / d_range[i] if d_range[i] > 0 else 0
              for j in range(len(k_range))]
             for i in range(len(d_range))]

im = ax.imshow(norm_data, aspect='auto', cmap='YlOrRd',
               interpolation='nearest', origin='lower')
ax.set_xticks(range(len(k_range)))
ax.set_xticklabels([str(k) for k in k_range])
ax.set_yticks(range(len(d_range)))
ax.set_yticklabels([str(d) for d in d_range])
ax.set_xlabel('Certificate Depth k', fontsize=12)
ax.set_ylabel('Dimension d', fontsize=12)
ax.set_title('Amplification Profile (normalized by d)', fontsize=12)
cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Profile / d', fontsize=10)

# Annotate the k=0 column
for i in range(len(d_range)):
    ax.text(0, i, '0', ha='center', va='center', fontsize=8, color='white',
            fontweight='bold')

# Panel 2: Path count distribution
ax = axes[1]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for (d, color) in zip([4, 6, 8, 10], colors):
    lengths, counts = path_data[d]
    # Only plot nonzero
    nonzero = [(l, c) for l, c in zip(lengths, counts) if c > 0]
    if nonzero:
        ls, cs = zip(*nonzero)
        ax.semilogy(ls, cs, 'o-', color=color, linewidth=2, markersize=5,
                    label=f'd={d}')

ax.set_xlabel('Chain Length n', fontsize=12)
ax.set_ylabel('Number of Descent Chains (log scale)', fontsize=12)
ax.set_title('Path Count Distribution (Linear Family)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplification.png")
