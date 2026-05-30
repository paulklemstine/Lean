#!/usr/bin/env python3
"""
Visualization: Area Generating Functions and Palindromic Symmetry
==================================================================
Shows the area distribution of lattice paths and demonstrates the
palindromic symmetry predicted by the Area Complement Theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def all_lattice_paths(m, n):
    paths = []
    for east_pos in combinations(range(m + n), m):
        p = [False] * (m + n)
        for pos in east_pos:
            p[pos] = True
        paths.append(p)
    return paths


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def area_distribution(m, n):
    gf = {}
    for p in all_lattice_paths(m, n):
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    return gf


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Area Generating Functions: Palindromic Symmetry',
             fontsize=16, fontweight='bold')

configs = [(2, 2), (2, 3), (3, 3), (3, 4), (4, 4), (4, 5)]
colors_left = '#2196F3'
colors_right = '#F44336'

for idx, (m, n) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    gf = area_distribution(m, n)
    max_area = m * n
    
    areas = list(range(max_area + 1))
    counts = [gf.get(a, 0) for a in areas]
    
    # Color bars: blue for left half, red for right half (palindromic pairs)
    bar_colors = []
    for a in areas:
        if a < max_area / 2:
            bar_colors.append('#2196F3')
        elif a > max_area / 2:
            bar_colors.append('#F44336')
        else:
            bar_colors.append('#9C27B0')
    
    ax.bar(areas, counts, color=bar_colors, alpha=0.8, edgecolor='white')
    
    # Mark the symmetry axis
    ax.axvline(x=max_area / 2, color='green', linestyle='--', linewidth=2, alpha=0.7)
    
    # Verify palindromy
    is_palindromic = all(gf.get(a, 0) == gf.get(max_area - a, 0) for a in areas)
    symbol = '✓' if is_palindromic else '✗'
    
    total = sum(counts)
    from math import comb
    ax.set_title(f'({m},{n})-paths: C({m+n},{m})={comb(m+n,m)}\n'
                 f'Palindromic: {symbol}  |  m·n = {max_area}',
                 fontsize=11)
    ax.set_xlabel('Area', fontsize=10)
    ax.set_ylabel('# Paths', fontsize=10)
    
    # Add GF text
    terms = []
    for a in sorted(gf.keys()):
        if gf[a] == 1:
            terms.append(f'q^{a}')
        else:
            terms.append(f'{gf[a]}q^{a}')
    gf_str = ' + '.join(terms[:5])
    if len(terms) > 5:
        gf_str += ' + ...'

plt.tight_layout()
plt.savefig('viz_generating_function.png', dpi=150, bbox_inches='tight')
print("Saved viz_generating_function.png")
