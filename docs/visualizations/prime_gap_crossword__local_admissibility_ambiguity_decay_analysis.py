#!/usr/bin/env python3
"""
Visualization: Ambiguity Decay in Prime Gap Crosswords

Plots how the fraction of "ambiguous" gap words (those with more than one
admissible next gap) changes as word length increases, for different sieve sets.

This tests the conjecture that ambiguity decays exponentially with word length:
longer patterns increasingly constrain the next gap, eventually forcing it.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod
from itertools import product as cartesian_product
from typing import List, Set

# ── Self-contained core algorithms ──────────────────────────────────────

def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos

def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior

def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    inter = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in inter:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True

def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))

def next_gaps(S: Set[int], word: List[int], max_gap: int = 14) -> Set[int]:
    return {g for g in range(1, max_gap + 1) if admissible_over(S, word + [g])}

# ── Compute ambiguity data ──────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

sieve_configs = [
    ({2, 3, 5}, "{2,3,5}", '#e74c3c'),
    ({2, 3, 5, 7}, "{2,3,5,7}", '#3498db'),
]

max_len = 5
max_gap_val = 12
even_gaps = list(range(2, max_gap_val + 1, 2))

for S, label, color in sieve_configs:
    lengths = []
    ambiguity_ratios = []
    total_admissible_counts = []
    forcing_counts = []

    for length in range(1, max_len + 1):
        total = 0
        ambiguous = 0
        forcing = 0

        for wt in cartesian_product(even_gaps, repeat=length):
            w = list(wt)
            if not admissible_over(S, w):
                continue
            total += 1
            ng = next_gaps(S, w, max_gap_val)
            if len(ng) > 1:
                ambiguous += 1
            elif len(ng) == 1:
                forcing += 1

        ratio = ambiguous / total if total > 0 else 0
        lengths.append(length)
        ambiguity_ratios.append(ratio)
        total_admissible_counts.append(total)
        forcing_counts.append(forcing)

    # Plot 1: Ambiguity ratio
    ax1.plot(lengths, ambiguity_ratios, 'o-', color=color, label=label,
             linewidth=2, markersize=8)

    # Plot 2: Counts
    ax2.plot(lengths, total_admissible_counts, 's--', color=color,
             label=f'{label} admissible', linewidth=1.5, markersize=6)
    ax2.plot(lengths, forcing_counts, 'o-', color=color,
             label=f'{label} forcing', linewidth=2, markersize=8)

# Customize Plot 1
ax1.set_xlabel('Gap word length', fontsize=12)
ax1.set_ylabel('Fraction with >1 admissible next gap', fontsize=12)
ax1.set_title('Ambiguity Decay with Word Length', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.set_xticks(range(1, max_len + 1))
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5)

# Add annotation
ax1.annotate('Full forcing\n(all patterns determined)',
             xy=(4, 0), xytext=(3, 0.3),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=9, ha='center', color='gray')

# Customize Plot 2
ax2.set_xlabel('Gap word length', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Admissible vs Forcing Patterns', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_xticks(range(1, max_len + 1))
ax2.grid(True, alpha=0.3)

fig.suptitle('Prime Gap Crossword: How Longer Patterns Reduce Ambiguity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ambiguity_decay.png', dpi=150, bbox_inches='tight')
print("Saved ambiguity_decay.png")
