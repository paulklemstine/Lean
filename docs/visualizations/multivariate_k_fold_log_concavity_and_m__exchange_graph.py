#!/usr/bin/env python3
"""
Visualization: Support Exchange Graph

Visualizes the exchange graph of a matroid basis polynomial,
showing how support points are connected by single-coordinate exchanges.
Rectangle closure means every "coordinate rectangle" has all four corners filled.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import factorial

def multinomial(m):
    total = sum(m)
    result = factorial(total)
    for mi in m:
        result //= factorial(mi)
    return result

# Generate support of h_3(x1, x2, x3) — all exponent vectors of degree 3
d = 3
n = 3
support = []
for a in range(d+1):
    for b in range(d+1-a):
        c = d - a - b
        support.append((a, b, c))

# Project to 2D: use (m1, m2) since m3 = d - m1 - m2
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Support with exchange edges
ax = axes[0]
support_set = set(support)

# Draw exchange edges: connect m and m' if they differ by e_i - e_j
for m in support:
    for i in range(n):
        for j in range(n):
            if i != j and m[i] > 0:
                m_prime = list(m)
                m_prime[i] -= 1
                m_prime[j] += 1
                m_prime = tuple(m_prime)
                if m_prime in support_set:
                    ax.plot([m[0], m_prime[0]], [m[1], m_prime[1]],
                            'b-', alpha=0.3, linewidth=1)

# Draw support points with size proportional to coefficient
for m in support:
    coeff = multinomial(m)
    ax.scatter(m[0], m[1], s=100 + 50*coeff, c='red', alpha=0.8,
               edgecolors='darkred', linewidths=1.5, zorder=5)
    ax.annotate(f'{m}', (m[0]+0.08, m[1]+0.08), fontsize=7)

ax.set_xlabel('$m_1$', fontsize=12)
ax.set_ylabel('$m_2$', fontsize=12)
ax.set_title(f'Exchange Graph of $h_{d}(x_1, x_2, x_3)$\n'
             f'(point size ∝ multinomial coefficient)', fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.3, d+0.3)
ax.set_ylim(-0.3, d+0.3)

# Plot 2: Rectangle closure visualization
ax = axes[1]

# Highlight coordinate rectangles
for m in support:
    for i in range(n):
        for j in range(i+1, n):
            if m[i] < d and m[j] < d:
                # Check all four corners of rectangle
                m_arr = list(m)
                corners = [m]
                m_i = list(m); m_i[i] += 1; m_i[j] -= 1 if m_i[j] > 0 else 0
                # Actually draw rectangles in (m1, m2) space
                pass

# Simpler: show the support with coefficient values
for m in support:
    coeff = multinomial(m)
    color = plt.cm.YlOrRd(coeff / max(multinomial(s) for s in support))
    ax.scatter(m[0], m[1], s=200, c=[color], alpha=0.9,
               edgecolors='black', linewidths=1.5, zorder=5)
    ax.annotate(f'{coeff}', (m[0], m[1]), ha='center', va='center',
                fontsize=9, fontweight='bold', zorder=6)

# Draw rectangle closure: for each pair (m, m+ei+ej), show rectangle
for m in support:
    for i in range(n):
        for j in range(i+1, n):
            ei = [0]*n; ei[i] = 1
            ej = [0]*n; ej[j] = 1
            m_ij = tuple(m[k] + ei[k] + ej[k] for k in range(n))
            m_i = tuple(m[k] + ei[k] for k in range(n))
            m_j = tuple(m[k] + ej[k] for k in range(n))
            
            if m_ij in support_set and m_i in support_set and m_j in support_set:
                # Draw rectangle
                rect_x = [m[0], m_i[0], m_ij[0], m_j[0], m[0]]
                rect_y = [m[1], m_i[1], m_ij[1], m_j[1], m[1]]
                ax.plot(rect_x, rect_y, 'g-', alpha=0.2, linewidth=2)

ax.set_xlabel('$m_1$', fontsize=12)
ax.set_ylabel('$m_2$', fontsize=12)
ax.set_title(f'Coefficient Values and Coordinate Rectangles\n'
             f'(rectangle closure: all corners present)', fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.3, d+0.3)
ax.set_ylim(-0.3, d+0.3)

fig.suptitle('Support Structure and Exchange Properties', fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('exchange_graph.png', dpi=150, bbox_inches='tight')
print("Saved exchange_graph.png")
