#!/usr/bin/env python3
"""
Visualization 3: Exchange Slack Heatmap and Additivity

Shows the exchange slack matrix as a heatmap, demonstrating:
1. All upper-triangular entries are nonneg (exchange property)
2. Slack is additive under pointwise products (tensor theorem)
3. Slack is preserved/amplified through the cascade
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def weighted_derivative(a):
    return [(k + 1) * a[k + 1] for k in range(len(a) - 1)]

def exchange_slack_matrix(a):
    n = len(a) - 1
    log_a = np.log(np.array(a, dtype=float))
    slack = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            slack[i, j] = (log_a[i + 1] + log_a[j]) - (log_a[i] + log_a[j + 1])
    return slack

# Base sequence
n = 10
a = [float(comb(n, k)) for k in range(n + 1)]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Exchange Slack Analysis: Tropical Geometry of the Cascade',
             fontsize=14, fontweight='bold')

# Panel 1: Exchange slack of base sequence
ax1 = axes[0, 0]
slack0 = exchange_slack_matrix(a)
im1 = ax1.imshow(slack0, cmap='RdYlGn', aspect='equal',
                  vmin=-max(abs(slack0.min()), slack0.max()),
                  vmax=max(abs(slack0.min()), slack0.max()))
ax1.set_title(f'Exchange Slack: C({n},k)', fontsize=11)
ax1.set_xlabel('j')
ax1.set_ylabel('i')
plt.colorbar(im1, ax=ax1, shrink=0.8)

# Panel 2: Exchange slack of derivative
da = weighted_derivative(a)
ax2 = axes[0, 1]
slack1 = exchange_slack_matrix(da)
im2 = ax2.imshow(slack1, cmap='RdYlGn', aspect='equal',
                  vmin=-max(abs(slack1.min()), slack1.max()),
                  vmax=max(abs(slack1.min()), slack1.max()))
ax2.set_title('Exchange Slack: D(C(10,k))', fontsize=11)
ax2.set_xlabel('j')
ax2.set_ylabel('i')
plt.colorbar(im2, ax=ax2, shrink=0.8)

# Panel 3: Additivity demonstration
a1 = [float(comb(6, k)) for k in range(7)]
a2 = [float(comb(8, k)) for k in range(7)]
a_prod = [a1[k] * a2[k] for k in range(7)]

ax3 = axes[1, 0]
s1 = exchange_slack_matrix(a1)
s2 = exchange_slack_matrix(a2)
s_prod = exchange_slack_matrix(a_prod)
s_sum = s1[:min(s1.shape[0], s2.shape[0]), :min(s1.shape[1], s2.shape[1])] + \
        s2[:min(s1.shape[0], s2.shape[0]), :min(s1.shape[1], s2.shape[1])]

# Plot the difference (should be ~0)
diff = s_prod - s_sum
im3 = ax3.imshow(np.abs(diff), cmap='hot_r', aspect='equal')
ax3.set_title('|Slack(a·b) - Slack(a) - Slack(b)|', fontsize=11)
ax3.set_xlabel('j')
ax3.set_ylabel('i')
plt.colorbar(im3, ax=ax3, shrink=0.8)
ax3.text(0.5, -0.15, f'Max error: {np.max(np.abs(diff)):.2e}',
         transform=ax3.transAxes, ha='center', fontsize=10)

# Panel 4: Diagonal slack across cascade levels
ax4 = axes[1, 1]
cascade = [a]
for _ in range(5):
    if len(cascade[-1]) >= 3:
        cascade.append(weighted_derivative(cascade[-1]))

for level, seq in enumerate(cascade):
    if len(seq) < 3:
        break
    slk = exchange_slack_matrix(seq)
    # Extract diagonal exchange slacks (i, i+1)
    diag_slacks = [slk[i, i+1] for i in range(min(slk.shape[0]-1, slk.shape[1]-1))]
    ax4.plot(range(len(diag_slacks)), diag_slacks, 'o-',
             label=f'Level {level}', markersize=4, linewidth=1.5)

ax4.set_title('Nearest-Neighbor Exchange Slack by Level', fontsize=11)
ax4.set_xlabel('Index i')
ax4.set_ylabel('Slack(i, i+1)')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)
ax4.axhline(y=0, color='red', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('viz_exchange_slack.png', dpi=150, bbox_inches='tight')
print("Saved: viz_exchange_slack.png")
