#!/usr/bin/env python3
"""
Visualization: Phase Transition in Digit-Disjointness

Shows the dramatic phase transition from base 2 (zero digit-disjoint pairs
among positive integers) to base 3+ (infinitely many such pairs).
Plots edge density of the digit-disjointness graph as a function of base.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def digits_base(n, b):
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_overlap(m, n, b):
    bm = Counter(digits_base(m, b))
    bn = Counter(digits_base(n, b))
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


N = 50
bases = list(range(2, 21))
max_edges = N * (N - 1) / 2

edge_counts = []
densities = []
max_degrees = []

for b in bases:
    edges = 0
    degrees = [0] * (N + 1)
    for m in range(1, N + 1):
        for n in range(m + 1, N + 1):
            if digit_overlap(m, n, b) == 0:
                edges += 1
                degrees[m] += 1
                degrees[n] += 1
    edge_counts.append(edges)
    densities.append(edges / max_edges)
    max_degrees.append(max(degrees[1:]))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle(f"Digit-Disjointness Graph: Phase Transition (vertices 1..{N})",
             fontsize=14, fontweight='bold')

# Plot 1: Edge count
ax1 = axes[0]
colors = ['red' if b == 2 else 'steelblue' for b in bases]
ax1.bar(bases, edge_counts, color=colors, alpha=0.8)
ax1.set_xlabel("Base b")
ax1.set_ylabel("Number of edges")
ax1.set_title("Edge Count")
ax1.annotate("Base 2: 0 edges\n(proved impossible)", xy=(2, 0),
             xytext=(5, max(edge_counts) * 0.3),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=9, color='red', fontweight='bold')

# Plot 2: Edge density
ax2 = axes[1]
ax2.plot(bases, densities, 'o-', color='darkgreen', markersize=6)
ax2.axvline(x=2.5, color='red', linestyle='--', alpha=0.5, label='Phase transition')
ax2.set_xlabel("Base b")
ax2.set_ylabel("Edge density")
ax2.set_title("Edge Density")
ax2.legend()
ax2.fill_between([1.5, 2.5], 0, 1, alpha=0.1, color='red')
ax2.fill_between([2.5, 21], 0, 1, alpha=0.05, color='green')
ax2.set_ylim(0, max(densities) * 1.1)

# Plot 3: Maximum degree
ax3 = axes[2]
ax3.plot(bases, max_degrees, 's-', color='purple', markersize=6)
ax3.set_xlabel("Base b")
ax3.set_ylabel("Maximum vertex degree")
ax3.set_title("Max Degree (hub structure)")
ax3.axvline(x=2.5, color='red', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig("viz_phase_transition.png", dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
