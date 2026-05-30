#!/usr/bin/env python3
"""
Visualization: Compression Ratio — Random vs Structured DNA

Compares the k-mer diversity (and hence compressibility) of random,
repeat-rich, and low-complexity DNA sequences. Demonstrates the
conjecture that real genomes are 2-5x more 'compressed' than random
sequences due to repeat elements.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def generate_repeat_rich(length, repeat_frac=0.5):
    seq = list(generate_random_dna(length))
    unit_len = 20
    template = generate_random_dna(unit_len)
    n_copies = int(length * repeat_frac / unit_len)
    for _ in range(n_copies):
        pos = random.randint(0, length - unit_len)
        for j in range(unit_len):
            if random.random() > 0.1:
                seq[pos + j] = template[j]
    return ''.join(seq)

def generate_low_complexity(length):
    units = ['AT', 'CG', 'ATAT', 'GCGC']
    unit = random.choice(units)
    return (unit * (length // len(unit) + 1))[:length]

def first_repeat_pos(seq, k):
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k
        seen.add(kmer)
    return len(seq)

def kmer_diversity(seq, k):
    if len(seq) < k:
        return 0.0
    kmers = set()
    for i in range(len(seq) - k + 1):
        kmers.add(seq[i:i+k])
    return len(kmers) / (4 ** k)

random.seed(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ---- Left panel: First repeat position distribution ----
k = 4
n_trials = 5000
seq_length = 300

types = {
    'Random': lambda: generate_random_dna(seq_length),
    'Repeat-rich (50%)': lambda: generate_repeat_rich(seq_length, 0.5),
    'Low-complexity': lambda: generate_low_complexity(seq_length),
}
colors = {'Random': 'steelblue', 'Repeat-rich (50%)': 'coral', 'Low-complexity': 'seagreen'}

means = {}
for name, gen_fn in types.items():
    positions = []
    for _ in range(n_trials):
        seq = gen_fn()
        pos = first_repeat_pos(seq, k)
        positions.append(pos)
    means[name] = np.mean(positions)
    ax1.hist(positions, bins=40, density=True, alpha=0.6,
             color=colors[name], label=f'{name} (μ={means[name]:.0f})')

ax1.axvline(4**k + k, color='black', linewidth=2, linestyle='--',
            label=f'Pigeonhole: {4**k + k}')
ax1.set_xlabel('Position of First Repeated 4-mer', fontsize=11)
ax1.set_ylabel('Density', fontsize=11)
ax1.set_title('First k-Mer Repeat: Random vs Structured DNA', fontsize=12)
ax1.legend(fontsize=9)

# Compression ratio annotation
if means['Low-complexity'] > 0:
    ratio = means['Random'] / means['Low-complexity']
    ax1.text(0.5, 0.95, f'Compression ratio\n(random/low): {ratio:.1f}x',
             transform=ax1.transAxes, fontsize=10, verticalalignment='top',
             horizontalalignment='center',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ---- Right panel: Diversity profile ----
lengths = list(range(20, 2001, 20))
n_avg = 30

for name, gen_fn in types.items():
    diversities = []
    for n in lengths:
        gen_specific = {
            'Random': lambda n=n: generate_random_dna(n),
            'Repeat-rich (50%)': lambda n=n: generate_repeat_rich(n, 0.5),
            'Low-complexity': lambda n=n: generate_low_complexity(n),
        }[name]
        divs = [kmer_diversity(gen_specific(), k) for _ in range(n_avg)]
        diversities.append(np.mean(divs))
    ax2.plot(lengths, diversities, color=colors[name], linewidth=2, label=name)

ax2.axhline(1.0, color='gray', linewidth=1, linestyle=':', alpha=0.5)
ax2.set_xlabel('Sequence Length (bp)', fontsize=11)
ax2.set_ylabel(f'{k}-Mer Diversity Index', fontsize=11)
ax2.set_title(f'Diversity Index vs Sequence Length (k={k})', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_ylim(-0.05, 1.1)

fig.suptitle('The Ramsey Theory of DNA: Pattern Repetition in Genetic Codes',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_compression_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_comparison.png")
