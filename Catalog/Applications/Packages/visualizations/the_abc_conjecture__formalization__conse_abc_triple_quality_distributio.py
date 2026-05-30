#!/usr/bin/env python3
"""
Visualization 1: ABC Triple Quality Distribution

Visualizes the quality q(a,b,c) = log(c)/log(rad(abc)) for ABC triples
with c up to a given limit. The ABC conjecture predicts that triples with
quality > 1+ε are finite for any ε > 0. This plot shows the distribution
of qualities, highlighting the "quality barrier" near 1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, log, prod


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    return prod(factorize(n).keys())


def abc_quality(a, b, c):
    r = radical(a * b * c)
    if r <= 1:
        return float('inf')
    return log(c) / log(r)


# Find ABC triples
limit = 5000
qualities = []
cs = []

for c in range(3, limit + 1):
    for a in range(1, (c + 1) // 2):
        b = c - a
        if gcd(a, b) != 1:
            continue
        q = abc_quality(a, b, c)
        if q > 0.8:
            qualities.append(q)
            cs.append(c)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Scatter plot of quality vs c
ax1 = axes[0]
colors = ['#2ecc71' if q <= 1.0 else '#e74c3c' if q > 1.4 else '#f39c12'
          for q in qualities]
ax1.scatter(cs, qualities, c=colors, alpha=0.3, s=3, edgecolors='none')
ax1.axhline(y=1.0, color='#e74c3c', linestyle='--', linewidth=2,
            label='Quality = 1 (ABC threshold)')
ax1.axhline(y=1.5, color='#9b59b6', linestyle=':', linewidth=1.5,
            label='Quality = 1.5')
ax1.set_xlabel('c', fontsize=12)
ax1.set_ylabel('Quality q(a,b,c)', fontsize=12)
ax1.set_title(f'ABC Triple Quality Distribution (c ≤ {limit})', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(0.8, max(qualities) + 0.1)

# Right: Histogram of qualities
ax2 = axes[1]
high_q = [q for q in qualities if q > 1.0]
low_q = [q for q in qualities if q <= 1.0]

ax2.hist(low_q, bins=50, alpha=0.7, color='#2ecc71', label=f'q ≤ 1 ({len(low_q)} triples)')
ax2.hist(high_q, bins=30, alpha=0.7, color='#e74c3c', label=f'q > 1 ({len(high_q)} triples)')
ax2.axvline(x=1.0, color='black', linestyle='--', linewidth=2)
ax2.set_xlabel('Quality q(a,b,c)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of ABC Triple Qualities', fontsize=13)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('abc_quality_distribution.png', dpi=150, bbox_inches='tight')
print(f"Saved abc_quality_distribution.png")
print(f"Total triples found: {len(qualities)}")
print(f"Triples with quality > 1: {len(high_q)}")
if high_q:
    print(f"Maximum quality: {max(high_q):.4f}")
