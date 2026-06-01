#!/usr/bin/env python3
"""Visualization: Neural Information Defect heatmap."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def neural_info_defect(n, k, k_prime):
    if k <= 0 or k_prime <= 0:
        return 0
    return n * n * (math.log2(k) - math.log2(k_prime))

k_values = [2, 4, 8, 16, 32, 64, 128, 256]
n_neurons = [10, 50, 100, 500, 1000, 5000, 10000]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Heatmap: NID per synapse for different k → k' transitions
k_from = 256
nid_matrix = np.zeros((len(k_values), len(k_values)))
for i, k1 in enumerate(k_values):
    for j, k2 in enumerate(k_values):
        if k2 <= k1:
            nid_matrix[i, j] = math.log2(k1) - math.log2(k2)
        else:
            nid_matrix[i, j] = np.nan

im = ax1.imshow(nid_matrix, cmap='YlOrRd', aspect='auto', origin='lower')
ax1.set_xticks(range(len(k_values)))
ax1.set_xticklabels(k_values)
ax1.set_yticks(range(len(k_values)))
ax1.set_yticklabels(k_values)
ax1.set_xlabel("Target precision k'", fontsize=12)
ax1.set_ylabel("Source precision k", fontsize=12)
ax1.set_title("NID per Synapse (bits)\nk → k' coarsening", fontsize=14)
plt.colorbar(im, ax=ax1, label='Bits lost per synapse')

for i in range(len(k_values)):
    for j in range(len(k_values)):
        if not np.isnan(nid_matrix[i, j]):
            ax1.text(j, i, f'{nid_matrix[i,j]:.0f}',
                    ha='center', va='center', fontsize=8,
                    color='white' if nid_matrix[i,j] > 4 else 'black')

# Bar chart: Total NID for different brain sizes
k_original = 256
k_target = 16
nids = [neural_info_defect(n, k_original, k_target) for n in n_neurons]

bars = ax2.bar(range(len(n_neurons)), nids, color='#F44336', alpha=0.8)
ax2.set_xticks(range(len(n_neurons)))
ax2.set_xticklabels([str(n) for n in n_neurons], rotation=45)
ax2.set_xlabel('Number of Neurons', fontsize=12)
ax2.set_ylabel('Total NID (bits)', fontsize=12)
ax2.set_title(f'Total Information Lost\nCoarsening {k_original}→{k_target} levels', fontsize=14)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('nid_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved nid_heatmap.png")
