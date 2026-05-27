#!/usr/bin/env python3
"""
Visualization: Tree-Like vs Relation-Driven Closed Walk Decomposition

This script visualizes the decomposition of closed walks on Cayley graphs
into "tree-like" (backtracking) contributions and "relation-driven"
(backtrack-free) contributions. The moment method's power comes from
isolating these two components: tree-like terms are universal (same for
all groups) while relation-driven terms encode group-specific structure.

Output: viz_decomposition.png
"""

import itertools
import math
import numpy as np
import matplotlib.pyplot as plt


# ─── Self-contained utilities ────────────────────────────────────────────

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

def eval_word(sigma, tau, word):
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

def is_backtrack_free(word):
    inv_map = {0: 1, 1: 0, 2: 3, 3: 2}
    for i in range(len(word) - 1):
        if word[i + 1] == inv_map[word[i]]:
            return False
    return True

def decompose_closed_words(sigma, tau, m):
    n = len(sigma)
    id_perm = identity(n)
    bf_closed = 0
    bt_closed = 0
    for word in itertools.product(range(4), repeat=m):
        w = list(word)
        if eval_word(sigma, tau, w) == id_perm:
            if is_backtrack_free(w):
                bf_closed += 1
            else:
                bt_closed += 1
    return bt_closed, bf_closed  # backtracking, backtrack-free


# ─── Data Collection ─────────────────────────────────────────────────────

# Use specific generators for reproducibility
test_cases = {
    '$S_3$: $\\sigma$=(01), $\\tau$=(012)': ([1, 0, 2], [1, 2, 0]),
    '$S_4$: $\\sigma$=(01), $\\tau$=(0123)': ([1, 0, 2, 3], [1, 2, 3, 0]),
    '$S_4$: $\\sigma$=(01)(23), $\\tau$=(012)': ([1, 0, 3, 2], [1, 2, 0, 3]),
}

ms = [2, 4, 6]

# Collect decomposition data
results = {}
for label, (sigma, tau) in test_cases.items():
    results[label] = {'bt': [], 'bf': []}
    for m in ms:
        bt, bf = decompose_closed_words(sigma, tau, m)
        results[label]['bt'].append(bt)
        results[label]['bf'].append(bf)


# ─── Plotting ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, len(test_cases), figsize=(15, 5.5))
fig.suptitle('Closed Walk Decomposition: Tree-Like vs Relation-Driven',
             fontsize=14, fontweight='bold')

bar_width = 0.35
x = np.arange(len(ms))

for idx, (label, data) in enumerate(results.items()):
    ax = axes[idx]
    
    bt_vals = data['bt']
    bf_vals = data['bf']
    total_vals = [b + f for b, f in zip(bt_vals, bf_vals)]
    
    # Stacked bar chart
    bars1 = ax.bar(x, bt_vals, bar_width * 2, label='Tree-like (backtracking)',
                    color='#3498db', alpha=0.7, edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x, bf_vals, bar_width * 2, bottom=bt_vals,
                    label='Relation-driven (backtrack-free)',
                    color='#e74c3c', alpha=0.7, edgecolor='black', linewidth=0.5)
    
    # Add value labels
    for i, (bt, bf, total) in enumerate(zip(bt_vals, bf_vals, total_vals)):
        if total > 0:
            ax.text(i, total + max(total_vals) * 0.02, f'{total}',
                    ha='center', va='bottom', fontsize=9, fontweight='bold')
            if bt > 0:
                ax.text(i, bt / 2, f'{bt}', ha='center', va='center', 
                        fontsize=8, color='white', fontweight='bold')
            if bf > 0:
                ax.text(i, bt + bf / 2, f'{bf}', ha='center', va='center',
                        fontsize=8, color='white', fontweight='bold')
    
    ax.set_title(label, fontsize=10)
    ax.set_xticks(x)
    ax.set_xticklabels([f'm={m}' for m in ms])
    ax.set_ylabel('Number of closed words')
    ax.set_xlabel('Word length')
    ax.legend(fontsize=7, loc='upper left')
    ax.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('viz_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_decomposition.png")
