#!/usr/bin/env python3
"""
Visualization 3: Dimension-Entropy Correspondence

Visualizes the fundamental identity: pseudofinite dimension equals
normalized Shannon entropy for uniform distributions. This bridges
model theory (dimension) to information theory (entropy), opening
paths to entropy-theoretic proofs in additive combinatorics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import math

matplotlib.rcParams['font.family'] = 'serif'
matplotlib.rcParams['font.size'] = 11


def pseudofinite_dim(card_A, card_G):
    if card_G <= 1 or card_A <= 0:
        return 0.0
    return math.log(card_A) / math.log(card_G)


def shannon_entropy_uniform(card_A):
    if card_A <= 0:
        return 0.0
    return math.log(card_A)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: dim(A) vs H(U_A)/log|G| — perfect correspondence
ax1 = axes[0]

primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
dims_list = []
entropies_list = []

for p in primes:
    for card_A in range(1, p + 1):
        d = pseudofinite_dim(card_A, p)
        e = shannon_entropy_uniform(card_A) / math.log(p)
        dims_list.append(d)
        entropies_list.append(e)

ax1.scatter(dims_list, entropies_list, s=8, alpha=0.6, c='#2196F3', edgecolors='none')
ax1.plot([0, 1], [0, 1], 'r--', linewidth=2, label='y = x (exact match)')
ax1.set_xlabel('Pseudofinite dimension dim(A)', fontsize=12)
ax1.set_ylabel('Normalized entropy H(U_A)/log|G|', fontsize=12)
ax1.set_title('Dimension = Normalized Entropy\n(all subsets, all primes p ≤ 47)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xlim(-0.02, 1.02)
ax1.set_ylim(-0.02, 1.02)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Panel 2: Entropy vs dimension during stabilizer descent
ax2 = axes[1]

p = 23
G = list(range(p))

# Simulate descent with actual computations
initial_sets = [
    set(range(12)),     # about half
    set(range(8)),      # about third
    set(range(5)),      # small set
]
colors_descent = ['#E91E63', '#9C27B0', '#4CAF50']
markers = ['o', 's', '^']

for A_init, color, marker in zip(initial_sets, colors_descent, markers):
    dim_trace = []
    entropy_trace = []
    current = A_init
    
    for step in range(10):
        card_A = len(current)
        if card_A <= 0:
            break
            
        d = pseudofinite_dim(card_A, p)
        h = shannon_entropy_uniform(card_A)
        dim_trace.append(d)
        entropy_trace.append(h)
        
        if card_A <= 1:
            break
        
        # Compute stabilizer
        AA = {(a1 + a2) % p for a1 in current for a2 in current}
        stab = {g for g in G if all((g + a) % p in AA for a in current)}
        
        if len(stab) >= len(current) or len(stab) <= 1:
            if len(stab) >= 1:
                d2 = pseudofinite_dim(len(stab), p)
                h2 = shannon_entropy_uniform(len(stab))
                dim_trace.append(d2)
                entropy_trace.append(h2)
            break
        current = stab
    
    ax2.plot(range(len(dim_trace)), dim_trace, f'{marker}-', color=color,
             linewidth=2, markersize=7, label=f'|A₀| = {len(A_init)}, dim trace')
    ax2.plot(range(len(entropy_trace)),
             [e / math.log(p) for e in entropy_trace],
             f'{marker}--', color=color, linewidth=1, markersize=5, alpha=0.5)

ax2.set_xlabel('Descent step', fontsize=12)
ax2.set_ylabel('Value', fontsize=12)
ax2.set_title(f'Parallel Descent of Dimension & Entropy\n(Z/{p}Z, solid=dim, dashed=H/log|G|)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)

# Panel 3: Information content interpretation
ax3 = axes[2]

# Show how dimension encodes "information content" 
# dim(A) = fraction of information needed to specify an element of A
# compared to specifying an element of G

p = 101
card_As = np.arange(1, p + 1)
dims = np.array([pseudofinite_dim(c, p) for c in card_As])
bits_to_specify = np.array([math.log2(c) if c > 0 else 0 for c in card_As])
total_bits = math.log2(p)

ax3.fill_between(card_As / p, 0, dims, alpha=0.3, color='#2196F3',
                 label='dim(A) = information fraction')
ax3.plot(card_As / p, dims, color='#2196F3', linewidth=2)

# Mark special points
special = [
    (1, "singleton\n(0 bits)"),
    (int(math.sqrt(p)), f"√|G| ≈ {int(math.sqrt(p))}\n(dim = 0.5)"),
    (p, "full group\n(dim = 1)"),
]
for card, label in special:
    d = pseudofinite_dim(card, p)
    ax3.plot(card / p, d, 'ro', markersize=10, zorder=5)
    offset_y = 0.08 if d < 0.5 else -0.12
    ax3.annotate(label, xy=(card/p, d), xytext=(card/p, d + offset_y),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

ax3.set_xlabel('|A| / |G|', fontsize=12)
ax3.set_ylabel('dim(A) = H(U_A) / log|G|', fontsize=12)
ax3.set_title(f'Information Content of Definable Sets\n(G = Z/{p}Z)',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=10, loc='lower right')
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0, 1.02)
ax3.set_ylim(-0.05, 1.1)

plt.tight_layout()
plt.savefig('viz_entropy_correspondence.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_correspondence.png")
