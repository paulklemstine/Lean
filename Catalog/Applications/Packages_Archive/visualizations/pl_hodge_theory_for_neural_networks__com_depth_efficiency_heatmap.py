import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2

def zaslavsky(m, n):
    return sum(comb(m, k) for k in range(n + 1))

d = 10  # input dimension
widths = list(range(2, 11))
depths = list(range(1, 11))

gap = np.zeros((len(depths), len(widths)))
for i, L in enumerate(depths):
    for j, w in enumerate(widths):
        N = w * L
        deep = zaslavsky(w, d) ** L
        shallow_ub = (N + 1) ** d
        gap[i, j] = log2(deep) - log2(shallow_ub)

fig, ax = plt.subplots(figsize=(10, 7))
im = ax.imshow(gap, cmap='RdYlGn', aspect='auto', origin='lower')
ax.set_xticks(range(len(widths)))
ax.set_xticklabels(widths)
ax.set_yticks(range(len(depths)))
ax.set_yticklabels(depths)
ax.set_xlabel('Layer Width w')
ax.set_ylabel('Depth L')
ax.set_title(f'Depth Efficiency Gap: log₂(deep/shallow) for d={d}')

for i in range(len(depths)):
    for j in range(len(widths)):
        ax.text(j, i, f'{gap[i,j]:.0f}', ha='center', va='center', fontsize=7)

plt.colorbar(im, label='log₂(deep bound / shallow bound)')
plt.tight_layout()
plt.savefig('depth_efficiency_heatmap.png', dpi=150, bbox_inches='tight')
print('Saved depth_efficiency_heatmap.png')