#!/usr/bin/env python3
"""
Visualization: Birthday Paradox for k-Mers

Shows the distribution of first k-mer repeat positions for random DNA
sequences, compared to the birthday paradox prediction and the pigeonhole
upper bound. Demonstrates that repeats occur much earlier than the
worst-case pigeonhole bound predicts.
"""

import numpy as np
import matplotlib.pyplot as plt
import random
import math

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def first_repeat_position(seq, k):
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k
        seen.add(kmer)
    return None

random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.flatten()

for idx, k in enumerate([3, 4, 5, 6]):
    ax = axes[idx]
    space = 4 ** k
    pigeonhole = space + k
    birthday = math.sqrt(math.pi / 2 * space) + k
    
    # Generate empirical distribution
    n_trials = 10000
    max_len = min(pigeonhole + 10, 10000)
    positions = []
    for _ in range(n_trials):
        seq = generate_random_dna(max_len)
        pos = first_repeat_position(seq, k)
        if pos is not None:
            positions.append(pos)
    
    # Histogram
    bins = min(50, max(10, len(set(positions)) // 5))
    ax.hist(positions, bins=bins, density=True, alpha=0.7,
            color='steelblue', edgecolor='white', label='Empirical')
    
    # Mark birthday prediction
    ax.axvline(birthday, color='red', linewidth=2, linestyle='--',
               label=f'Birthday: {birthday:.0f}')
    
    # Mark pigeonhole bound
    if pigeonhole <= max_len * 1.5:
        ax.axvline(pigeonhole, color='darkgreen', linewidth=2, linestyle=':',
                   label=f'Pigeonhole: {pigeonhole}')
    
    # Mark empirical mean
    emp_mean = np.mean(positions)
    ax.axvline(emp_mean, color='orange', linewidth=2,
               label=f'Mean: {emp_mean:.0f}')
    
    ax.set_xlabel('Position of First Repeated k-mer', fontsize=10)
    ax.set_ylabel('Density', fontsize=10)
    ax.set_title(f'k = {k}  (space = 4^{k} = {space})', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    
    # Add statistics text
    stats_text = (f'Median: {np.median(positions):.0f}\n'
                  f'Std: {np.std(positions):.0f}\n'
                  f'Min: {min(positions)}\n'
                  f'Max: {max(positions)}')
    ax.text(0.98, 0.55, stats_text, transform=ax.transAxes,
            fontsize=8, verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Birthday Paradox for DNA k-Mers\n'
             'First repeat occurs much earlier than the pigeonhole bound',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_birthday_paradox.png', dpi=150, bbox_inches='tight')
print("Saved viz_birthday_paradox.png")
