#!/usr/bin/env python3
"""
Visualization: Backtrack-Free Word Counting

Illustrates the combinatorial backbone of the moment method:
the number of backtrack-free words grows as 4·3^(m-1), while
total words grow as 4^m. The ratio (backtrack-free / total)
decays exponentially, representing the tree-like contribution
to spectral moments.
"""

import matplotlib.pyplot as plt
import numpy as np
import itertools

def is_backtrack_free(word):
    """Check if no adjacent pair cancels."""
    inv_map = {0: 1, 1: 0, 2: 3, 3: 2}
    for i in range(len(word) - 1):
        if word[i+1] == inv_map[word[i]]:
            return False
    return True

def count_backtrack_free_enumerate(m):
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if is_backtrack_free(list(word)):
            count += 1
    return count

# Data
ms = list(range(1, 9))
formula_counts = [4 * 3**(m-1) for m in ms]
total_counts = [4**m for m in ms]

# Verify formula for small m
verified_ms = list(range(1, 7))
verified_counts = [count_backtrack_free_enumerate(m) for m in verified_ms]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Backtrack-Free Words: The Tree-Like Contribution', fontsize=14, fontweight='bold')

# Plot 1: Counts on log scale
ax1.semilogy(ms, total_counts, 'b-o', label='Total words (4ᵐ)', linewidth=2)
ax1.semilogy(ms, formula_counts, 'r-s', label='Backtrack-free (4·3ᵐ⁻¹)', linewidth=2)
if verified_counts:
    ax1.semilogy(verified_ms, verified_counts, 'gx', markersize=12, 
                 label='Verified by enumeration', linewidth=2)
ax1.set_xlabel('Word length m')
ax1.set_ylabel('Count (log scale)')
ax1.set_title('Word Counts')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Ratio (backtrack-free / total) = (3/4)^(m-1)
ratios = [f/t for f, t in zip(formula_counts, total_counts)]
theoretical = [(3/4)**(m-1) for m in ms]

ax2.plot(ms, ratios, 'r-o', label='Ratio: BF / Total', linewidth=2, markersize=8)
ax2.plot(ms, theoretical, 'k--', label='(3/4)ᵐ⁻¹', linewidth=1.5)
ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax2.set_xlabel('Word length m')
ax2.set_ylabel('Fraction backtrack-free')
ax2.set_title('Decay of Tree-Like Contribution')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.1)

# Add annotation
ax2.annotate('As m→∞, the fraction of\nbacktrack-free words → 0.\nRelation words dominate.',
             xy=(6, 0.18), fontsize=10, ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('backtrack_free.png', dpi=150, bbox_inches='tight')
print("Saved backtrack_free.png")
