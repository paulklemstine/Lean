#!/usr/bin/env python3
"""
Visualization: Backtrack-Free vs Total Word Counting

Visualizes the fundamental decomposition of spectral moments:
- Total words: 4^m (all possible walks)
- Backtrack-free words: 4 · 3^(m-1) (tree-like walks)
- Closed words: depends on group relations

The gap between backtrack-free closed words and total closed words
measures the contribution of group relations to spectral moments.
This decomposition is the seed of the moment method.
"""

import itertools
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ──── Self-contained functions ────

def compose(p, q):
    return [p[q[i]] for i in range(len(p))]

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return inv

def identity(n):
    return list(range(n))

def is_identity(p):
    return all(p[i] == i for i in range(len(p)))

ALPHABET = [0, 1, 2, 3]
FORMAL_INV = {0: 1, 1: 0, 2: 3, 3: 2}

def eval_word(word, sigma, tau, n):
    sigma_inv = inverse(sigma)
    tau_inv = inverse(tau)
    gen_map = {0: sigma, 1: sigma_inv, 2: tau, 3: tau_inv}
    result = identity(n)
    for letter in word:
        result = compose(gen_map[letter], result)
    return result

def is_backtrack_free(word):
    for i in range(len(word) - 1):
        if word[i + 1] == FORMAL_INV[word[i]]:
            return False
    return True

# ──── Main visualization ────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: word counting comparison
m_values = list(range(1, 9))
total_words = [4**m for m in m_values]
bf_words = [4 * 3**(m-1) for m in m_values]
bf_ratio = [b/t for b, t in zip(bf_words, total_words)]

ax1.semilogy(m_values, total_words, 'o-', color='steelblue',
             linewidth=2, markersize=8, label='Total words: $4^m$')
ax1.semilogy(m_values, bf_words, 's-', color='coral',
             linewidth=2, markersize=8, label='Backtrack-free: $4 \\cdot 3^{m-1}$')
ax1.set_xlabel('Word length m', fontsize=12)
ax1.set_ylabel('Count (log scale)', fontsize=12)
ax1.set_title('Total vs Backtrack-Free Words', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Right plot: decomposition for S_4
n = 4
sigma = [1, 2, 3, 0]  # 4-cycle
tau = [1, 0, 2, 3]    # transposition

m_vals_small = [2, 4, 6]
closed_total = []
closed_bf = []
closed_non_bf = []

for m in m_vals_small:
    ct, cbf, cnbf = 0, 0, 0
    for word in itertools.product(ALPHABET, repeat=m):
        if is_identity(eval_word(word, sigma, tau, n)):
            ct += 1
            if is_backtrack_free(word):
                cbf += 1
            else:
                cnbf += 1
    closed_total.append(ct)
    closed_bf.append(cbf)
    closed_non_bf.append(cnbf)

x = np.arange(len(m_vals_small))
width = 0.35

bars1 = ax2.bar(x - width/2, closed_non_bf, width, label='Cancellation-driven',
                color='lightcoral', edgecolor='darkred')
bars2 = ax2.bar(x + width/2, closed_bf, width, label='Relation-driven (backtrack-free)',
                color='lightgreen', edgecolor='darkgreen')

# Add text annotations
for i, (nbf, bf, total) in enumerate(zip(closed_non_bf, closed_bf, closed_total)):
    ax2.text(i, max(nbf, bf) + total*0.05,
             f'Total: {total}', ha='center', fontsize=10, fontweight='bold')

ax2.set_xlabel('Word length m', fontsize=12)
ax2.set_ylabel('Closed word count', fontsize=12)
ax2.set_title(f'Closed Word Decomposition in S₄\nσ=(0123), τ=(01)',
              fontsize=14, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels([f'm={m}' for m in m_vals_small])
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

fig.suptitle('The Moment Method: Decomposing Spectral Moments',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('backtrack_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: backtrack_decomposition.png")
