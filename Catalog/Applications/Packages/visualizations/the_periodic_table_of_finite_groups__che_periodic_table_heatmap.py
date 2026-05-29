#!/usr/bin/env python3
"""
Visualization 1: The Periodic Table of Finite Groups

Displays a heatmap-style periodic table where each cell represents a group order,
colored by chemical series (Noble Gas, Alkaline Earth, Compound, Radioactive).
The intensity encodes the number of groups of that order.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import gcd, log2


def prime_factorization(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def classify(n):
    """0=Noble Gas, 1=Alkaline Earth, 2=Compound, 3=Radioactive"""
    if n <= 1 or is_prime(n):
        return 0
    factors = prime_factorization(n)
    if len(factors) == 1:
        _, a = list(factors.items())[0]
        return 1 if a == 2 else 2
    if n % 60 == 0 and n >= 60:
        return 3
    if len(factors) == 2:
        return 2
    return 2


def euler_totient(n):
    if n <= 0: return 0
    result = n
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0: temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


# Known group counts
group_counts = {
    1:1, 2:1, 3:1, 4:2, 5:1, 6:2, 7:1, 8:5, 9:2, 10:2,
    11:1, 12:5, 13:1, 14:2, 15:1, 16:14, 17:1, 18:5, 19:1, 20:5,
    21:2, 22:2, 23:1, 24:15, 25:2, 26:2, 27:5, 28:4, 29:1, 30:4,
    31:1, 32:51, 33:1, 34:2, 35:1, 36:14, 37:1, 38:2, 39:2, 40:14,
    41:1, 42:6, 43:1, 44:4, 45:2, 46:2, 47:1, 48:52, 49:2, 50:5,
    51:1, 52:5, 53:1, 54:15, 55:2, 56:13, 57:2, 58:2, 59:1, 60:13,
}

# Build grid: 6 rows x 10 columns for orders 1-60
rows, cols = 6, 10
fig, ax = plt.subplots(figsize=(14, 9))

colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']  # Blue, Green, Orange, Red
labels = ['Noble Gas', 'Alkaline Earth', 'Compound', 'Radioactive']

for n in range(1, 61):
    r = (n - 1) // cols
    c = (n - 1) % cols
    series = classify(n)
    count = group_counts.get(n, 1)

    # Intensity based on log of group count
    intensity = min(1.0, 0.3 + 0.7 * log2(count + 1) / log2(52))

    from matplotlib.colors import to_rgba
    base_color = to_rgba(colors[series])
    cell_color = (*base_color[:3], intensity)

    rect = mpatches.FancyBboxPatch((c, rows - 1 - r), 0.92, 0.92,
                                     boxstyle="round,pad=0.02",
                                     facecolor=cell_color,
                                     edgecolor='white', linewidth=1.5)
    ax.add_patch(rect)

    # Order number
    ax.text(c + 0.46, rows - 1 - r + 0.65, str(n),
            ha='center', va='center', fontsize=11, fontweight='bold',
            color='white' if intensity > 0.5 else 'black')

    # Group count
    ax.text(c + 0.46, rows - 1 - r + 0.35, f'{count}g',
            ha='center', va='center', fontsize=7,
            color='white' if intensity > 0.5 else 'gray')

    # φ(n)
    ax.text(c + 0.46, rows - 1 - r + 0.15, f'φ={euler_totient(n)}',
            ha='center', va='center', fontsize=6,
            color='white' if intensity > 0.5 else 'gray')

ax.set_xlim(-0.1, cols + 0.1)
ax.set_ylim(-0.1, rows + 0.1)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The Periodic Table of Finite Groups (Orders 1–60)',
             fontsize=16, fontweight='bold', pad=20)

# Legend
legend_patches = [mpatches.Patch(color=colors[i], label=labels[i]) for i in range(4)]
ax.legend(handles=legend_patches, loc='lower center', ncol=4,
          fontsize=10, frameon=False, bbox_to_anchor=(0.5, -0.05))

plt.tight_layout()
plt.savefig('periodic_table.png', dpi=150, bbox_inches='tight')
print("Saved periodic_table.png")
