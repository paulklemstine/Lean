#!/usr/bin/env python3
"""
Visualization: Score Functions and Curvature Decay

Panel 1: Score functions s(n) = log(a(n+1)/a(n)) for different distributions,
showing monotonicity as predicted by the log-concavity theorem.

Panel 2: Curvature magnitude decay across orders, showing how geometric
distributions have zero higher curvature while others decay.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def iter_forward_diff(f, k):
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a, k):
    log_a = [math.log(x) if x > 0 else -100 for x in a]
    return iter_forward_diff(log_a, k)


def score_function(a):
    return [math.log(a[n+1]) - math.log(a[n]) for n in range(len(a) - 1)]


# Generate distributions
N = 18

distributions = {
    'Geometric (r=0.5)': [(1-0.5)*0.5**m for m in range(N)],
    'Binomial (N=15, p=0.4)': [math.comb(15, i)*0.4**i*0.6**(15-i) for i in range(16)],
    'Poisson (λ=5)': [math.exp(-5)*5**m/math.factorial(m) for m in range(N)],
    'Binomial (N=20, p=0.5)': [math.comb(20, i)*0.5**20 for i in range(21)],
}

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Score functions
ax1.set_title('Score Functions: s(n) = log(a(n+1)/a(n))', fontsize=13, fontweight='bold')
for (name, seq), color in zip(distributions.items(), colors):
    s = score_function(seq)
    ax1.plot(range(len(s)), s, 'o-', color=color, label=name, markersize=4, linewidth=1.5)

ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.set_xlabel('Position n', fontsize=11)
ax1.set_ylabel('Score s(n)', fontsize=11)
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.annotate('Log-concavity ⟹ s(n) is non-increasing',
            xy=(0.05, 0.05), xycoords='axes fraction', fontsize=10,
            style='italic', color='#555')

# Panel 2: Curvature magnitude decay
ax2.set_title('Curvature Magnitude Decay Across Orders', fontsize=13, fontweight='bold')
max_order = 8

for (name, seq), color in zip(distributions.items(), colors):
    magnitudes = []
    for k in range(1, max_order + 1):
        curv = entropy_curvature(seq, k)
        if curv:
            magnitudes.append(max(abs(v) for v in curv))
        else:
            magnitudes.append(0)
    
    ax2.semilogy(range(1, max_order + 1), [max(m, 1e-16) for m in magnitudes],
                 's-', color=color, label=name, markersize=6, linewidth=1.5)

ax2.set_xlabel('Curvature Order k', fontsize=11)
ax2.set_ylabel('Max |Δᵏ(log a)|', fontsize=11)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, max_order + 1))
ax2.annotate('Geometric: zero from order 2\n(flat information landscape)',
            xy=(0.4, 0.15), xycoords='axes fraction', fontsize=9,
            style='italic', color='#e74c3c',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#ffeaa7', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_score_functions.png', dpi=150, bbox_inches='tight')
print("Saved: viz_score_functions.png")
