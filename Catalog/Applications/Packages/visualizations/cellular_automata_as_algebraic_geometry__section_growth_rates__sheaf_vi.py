#!/usr/bin/env python3
"""
Visualization 3: Section Growth Rates (Sheaf Theory View)
==========================================================
Shows how the number of local sections (compatible partial assignments)
grows with window width for different ECA rules. This is the 
"sheaf-theoretic" view: the growth rate of local sections measures
the richness of the rule's fixed-point sheaf.

Exponential growth (like Rule 204) = high-dimensional variety.
Constant growth (like Rule 0) = low-dimensional variety.
The growth rate is the "Hausdorff dimension" of the sheaf's section space.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from math import log2


def eca_local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def count_local_sections(r, width):
    count = 0
    for bits in product([0, 1], repeat=width):
        valid = True
        for i in range(1, width - 1):
            if eca_local_rule(r, bits[i-1], bits[i], bits[i+1]) != bits[i]:
                valid = False
                break
        if valid:
            count += 1
    return count


rules_to_show = [
    (204, 'Rule 204 (Identity)', '#2196F3'),
    (150, 'Rule 150 (l⊕c⊕r)', '#4CAF50'),
    (90, 'Rule 90 (l⊕r)', '#FF9800'),
    (110, 'Rule 110 (Turing-complete)', '#F44336'),
    (30, 'Rule 30 (Chaotic)', '#9C27B0'),
    (0, 'Rule 0 (Constant zero)', '#795548'),
]

max_width = 16

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: raw section counts
ax1 = axes[0]
for r, label, color in rules_to_show:
    widths = list(range(1, max_width + 1))
    sections = [count_local_sections(r, w) for w in widths]
    ax1.semilogy(widths, sections, 'o-', label=label, color=color, 
                 markersize=4, linewidth=1.5)

ax1.set_xlabel('Window Width', fontsize=12)
ax1.set_ylabel('Number of Local Sections (log scale)', fontsize=12)
ax1.set_title('Section Growth Rates', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper left')
ax1.grid(True, alpha=0.3)

# Right: growth rate (log-log to extract exponent)
ax2 = axes[1]
for r, label, color in rules_to_show:
    widths = list(range(3, max_width + 1))
    sections = [count_local_sections(r, w) for w in widths]
    # Compute local growth rate
    rates = []
    for i in range(1, len(sections)):
        if sections[i-1] > 0 and sections[i] > 0:
            rates.append(log2(sections[i]) - log2(sections[i-1]))
        else:
            rates.append(0)
    ax2.plot(widths[1:], rates, 'o-', label=label, color=color,
             markersize=4, linewidth=1.5)

ax2.set_xlabel('Window Width', fontsize=12)
ax2.set_ylabel('Growth Rate (bits per cell)', fontsize=12)
ax2.set_title('Section Growth Rate (Sheaf Dimension)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Rate = 1 (exponential)')
ax2.axhline(y=0.0, color='gray', linestyle=':', alpha=0.5, label='Rate = 0 (constant)')

plt.tight_layout()
plt.savefig('viz_section_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_section_growth.png")
