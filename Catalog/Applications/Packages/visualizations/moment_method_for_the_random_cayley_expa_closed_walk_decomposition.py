#!/usr/bin/env python3
"""
Visualization 3: Closed Walk Decomposition by Word Type

Visualizes the decomposition of closed walks into:
  - Backtrack-free closed walks (tree-like / free-group contribution)
  - Walks with backtracks (relation-driven / correction terms)

This decomposition is the heart of the moment method: the tree-like
contribution is universal (independent of the group), while the
relation-driven correction captures the specific algebraic structure.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Self-contained utilities ───

def compose(p, q):
    return [p[q[i]] for i in range(len(p))]

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv

def identity(n):
    return list(range(n))

LETTER_INV = {0: 1, 1: 0, 2: 3, 3: 2}

def eval_word(sigma, tau, word):
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

def is_backtrack_free(word):
    for i in range(len(word) - 1):
        if word[i + 1] == LETTER_INV[word[i]]:
            return False
    return True

def decompose_closed_walks(sigma, tau, m):
    """Decompose closed walks into backtrack-free and backtracking."""
    n = len(sigma)
    id_perm = identity(n)
    bf_closed = 0
    bt_closed = 0
    bf_total = 0
    bt_total = 0
    
    for word in itertools.product(range(4), repeat=m):
        is_closed = (eval_word(sigma, tau, word) == id_perm)
        is_bf = is_backtrack_free(word)
        
        if is_bf:
            bf_total += 1
            if is_closed:
                bf_closed += 1
        else:
            bt_total += 1
            if is_closed:
                bt_closed += 1
    
    return {
        "total_closed": bf_closed + bt_closed,
        "bf_closed": bf_closed,
        "bt_closed": bt_closed,
        "bf_total": bf_total,
        "bt_total": bt_total,
        "total_words": 4 ** m,
    }

def free_group_return_prob(two_k):
    if two_k % 2 != 0:
        return 0.0
    k = two_k // 2
    if k == 0:
        return 1.0
    catalan = comb(2 * k, k) // (k + 1)
    return catalan * (3 ** k) / (4 ** two_k)

# ─── Data collection ───

# Use specific generators in S_4
sigma = [1, 2, 3, 0]  # (0 1 2 3) 
tau = [1, 0, 2, 3]    # (0 1)

m_values = list(range(1, 7))
decomp_data = {}

for m in m_values:
    decomp_data[m] = decompose_closed_walks(sigma, tau, m)

# ─── Plotting ───

fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Closed Walk Decomposition by Word Type\n'
             'Cayley graph of S₄ with σ=(0123), τ=(01)',
             fontsize=13, fontweight='bold')

# Panel 1: Stacked bar chart of closed walks
bf_counts = [decomp_data[m]["bf_closed"] for m in m_values]
bt_counts = [decomp_data[m]["bt_closed"] for m in m_values]

x = np.arange(len(m_values))
width = 0.6

ax1.bar(x, bf_counts, width, label='Backtrack-free closed', color='#2196F3', alpha=0.8)
ax1.bar(x, bt_counts, width, bottom=bf_counts, label='Backtracking closed', color='#FF9800', alpha=0.8)
ax1.set_xlabel('Word length m')
ax1.set_ylabel('Number of closed walks')
ax1.set_title('Closed Walk Count by Type')
ax1.set_xticks(x)
ax1.set_xticklabels(m_values)
ax1.legend()
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Moment kernel decomposition
bf_kernel = [decomp_data[m]["bf_closed"] / (4**m) for m in m_values]
bt_kernel = [decomp_data[m]["bt_closed"] / (4**m) for m in m_values]
total_kernel = [decomp_data[m]["total_closed"] / (4**m) for m in m_values]
free_group_vals = [free_group_return_prob(m) for m in m_values]

ax2.plot(m_values, total_kernel, 'ko-', linewidth=2, markersize=8, label='Total moment kernel')
ax2.plot(m_values, bf_kernel, 's--', color='#2196F3', linewidth=1.5, markersize=6, label='Backtrack-free contribution')
ax2.plot(m_values, bt_kernel, '^--', color='#FF9800', linewidth=1.5, markersize=6, label='Backtracking contribution')
ax2.plot(m_values, free_group_vals, 'r*-', linewidth=2, markersize=10, label='Free group F₂')

ax2.set_xlabel('Word length m')
ax2.set_ylabel('Normalized count (÷ 4ᵐ)')
ax2.set_title('Moment Kernel Decomposition')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=-0.02)

# Panel 3: Ratio analysis
ratios = []
for m in m_values:
    fp = free_group_return_prob(m)
    if fp > 0:
        ratios.append(total_kernel[m_values.index(m)] / fp)
    else:
        ratios.append(None)

valid_m = [m for m, r in zip(m_values, ratios) if r is not None]
valid_r = [r for r in ratios if r is not None]

ax3.bar(range(len(valid_m)), valid_r, color='#4CAF50', alpha=0.8, edgecolor='black')
ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Ratio = 1 (free group)')
ax3.set_xlabel('Word length m (even only)')
ax3.set_ylabel('μₘ(S₄) / μₘ(F₂)')
ax3.set_title('Ratio to Free-Group Benchmark')
ax3.set_xticks(range(len(valid_m)))
ax3.set_xticklabels(valid_m)
ax3.legend()
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('visualize_walks.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_walks.png")
