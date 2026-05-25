#!/usr/bin/env python3
"""
Visualization: Exchange Width Monotonicity Under Differentiation

Shows how the exchange width (minimum coordinate range) decreases
as we apply successive partial derivatives. This is a cross-domain
invariant connecting algebraic differentiation to discrete optimization:
each derivative narrows the feasible region.
"""

import matplotlib.pyplot as plt
import numpy as np


def unit_vec(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def vec_sub(a, b):
    return tuple(max(x - y, 0) for x, y in zip(a, b))

def support_contraction(S, n, i):
    ei = unit_vec(n, i)
    return {vec_sub(m, ei) for m in S if m[i] > 0}

def homogeneous_support(n, d):
    result = set()
    def gen(rem, deg, cur):
        if rem == 1:
            result.add(tuple(cur + [deg]))
            return
        for k in range(deg + 1):
            gen(rem - 1, deg - k, cur + [k])
    gen(n, d, [])
    return result

def exchange_width(S, n):
    if not S or n == 0:
        return 0
    return min(max(m[i] for m in S) - min(m[i] for m in S) for i in range(n))

def coord_ranges(S, n):
    if not S:
        return [(0, 0)] * n
    return [(min(m[i] for m in S), max(m[i] for m in S)) for i in range(n)]


# Generate data for multiple starting degrees
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Width vs. contraction step for different degrees
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']
n = 3

for d_idx, d in enumerate([3, 4, 5, 6, 7]):
    S = homogeneous_support(n, d)
    widths = [exchange_width(S, n)]
    sizes = [len(S)]
    current = S
    step = 0
    while current and len(current) > 1:
        i = step % n
        current = support_contraction(current, n, i)
        if current:
            widths.append(exchange_width(current, n))
            sizes.append(len(current))
        step += 1
        if step > 20:
            break
    
    ax1.plot(range(len(widths)), widths, 'o-', color=colors[d_idx % len(colors)],
            linewidth=2, markersize=6, label=f'd={d}')

ax1.set_xlabel('Number of Contractions', fontsize=12)
ax1.set_ylabel('Exchange Width', fontsize=12)
ax1.set_title('Exchange Width Decreases Under\nRepeated Contraction (n=3)', 
             fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=-0.5)

# Panel 2: Coordinate ranges for a specific case
d = 5
S = homogeneous_support(n, d)
current = S
all_ranges = [coord_ranges(current, n)]
steps_labels = ['Original']

deriv_seq = [0, 1, 2, 0, 1]
for var in deriv_seq:
    current = support_contraction(current, n, var)
    if not current:
        break
    all_ranges.append(coord_ranges(current, n))
    steps_labels.append(f'∂/∂x_{var}')

x_pos = np.arange(len(all_ranges))
bar_width = 0.25
coord_colors = ['#EF5350', '#66BB6A', '#42A5F5']
coord_labels = ['x₀ range', 'x₁ range', 'x₂ range']

for i in range(n):
    ranges = [r[i][1] - r[i][0] for r in all_ranges]
    offset = (i - 1) * bar_width
    bars = ax2.bar(x_pos + offset, ranges, bar_width, color=coord_colors[i],
                  label=coord_labels[i], alpha=0.8, edgecolor='black', linewidth=0.5)

# Add exchange width line
ew = [min(r[i][1]-r[i][0] for i in range(n)) for r in all_ranges]
ax2.plot(x_pos, ew, 'k--', linewidth=2, marker='D', markersize=7,
        label='Exchange width (min)', zorder=5)

ax2.set_xlabel('Differentiation Step', fontsize=12)
ax2.set_ylabel('Coordinate Range', fontsize=12)
ax2.set_title(f'Per-Coordinate Ranges Under\nContraction (n={n}, d={d})',
             fontsize=13, fontweight='bold')
ax2.set_xticks(x_pos)
ax2.set_xticklabels(steps_labels, rotation=30, ha='right', fontsize=9)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('width_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved: width_monotonicity.png")
