#!/usr/bin/env python3
"""
Visualization: k-Mer Diversity Heatmap

Shows how k-mer diversity index varies with sequence length (x-axis) and
k-mer size (y-axis) for random DNA sequences. The heatmap reveals the
phase transition: for each k, there is a critical length where diversity
drops below 1 (all k-mers seen) — this is the pigeonhole boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def kmer_diversity(seq, k):
    if len(seq) < k:
        return 0.0
    kmers = set()
    for i in range(len(seq) - k + 1):
        kmers.add(seq[i:i+k])
    return len(kmers) / (4 ** k)

random.seed(42)

# Parameters
k_values = list(range(1, 9))
lengths = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000]

# Compute diversity matrix (averaged over trials)
n_trials = 20
diversity_matrix = np.zeros((len(k_values), len(lengths)))

for i, k in enumerate(k_values):
    for j, n in enumerate(lengths):
        divs = []
        for _ in range(n_trials):
            seq = generate_random_dna(n)
            divs.append(kmer_diversity(seq, k))
        diversity_matrix[i, j] = np.mean(divs)

# Plot
fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(diversity_matrix, aspect='auto', cmap='YlOrRd_r',
               vmin=0, vmax=1, origin='lower')

ax.set_xticks(range(len(lengths)))
ax.set_xticklabels(lengths)
ax.set_yticks(range(len(k_values)))
ax.set_yticklabels(k_values)

ax.set_xlabel('Sequence Length (bp)', fontsize=12)
ax.set_ylabel('k-mer Size (k)', fontsize=12)
ax.set_title('k-Mer Diversity Index: Random DNA Sequences\n'
             '(1.0 = all possible k-mers observed, 0 = none)',
             fontsize=14)

# Add text annotations
for i in range(len(k_values)):
    for j in range(len(lengths)):
        val = diversity_matrix[i, j]
        color = 'white' if val < 0.5 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                color=color, fontsize=8)

# Add pigeonhole boundary line
pigeonhole_lengths = [4**k + k - 1 for k in k_values]
for i, (k, pb) in enumerate(zip(k_values, pigeonhole_lengths)):
    # Find where pb falls in the length axis
    for j in range(len(lengths) - 1):
        if lengths[j] <= pb <= lengths[j+1]:
            frac = (np.log(pb) - np.log(lengths[j])) / (np.log(lengths[j+1]) - np.log(lengths[j]))
            ax.plot(j + frac, i, 'k*', markersize=12)
            break

cbar = plt.colorbar(im, ax=ax, label='Diversity Index')
ax.text(len(lengths) - 0.5, len(k_values) - 0.5,
        '★ = Pigeonhole\n     boundary', fontsize=9,
        ha='right', va='top', style='italic')

plt.tight_layout()
plt.savefig('viz_diversity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_diversity_heatmap.png")
