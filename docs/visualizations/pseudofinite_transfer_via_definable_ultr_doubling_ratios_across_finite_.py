#!/usr/bin/env python3
"""
Visualization: Doubling Ratios Across Finite Fields

Visualizes how the doubling ratio |A²|/|A| behaves as the field size
increases for three definable families of subsets of GL(2, F_p).
The transfer principle predicts that bounded ratios transfer to the
pseudofinite limit, so visual stability = evidence for transfer.

Produces a bar chart comparing doubling ratios across field sizes
for the three families studied in the paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cart_product


def mat_mul_p(A, B, p):
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
         (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
         (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p],
    ]


def mat_tuple(A):
    return (A[0][0], A[0][1], A[1][0], A[1][1])


def product_set_p(A_list, p):
    result = set()
    for a1 in A_list:
        for a2 in A_list:
            result.add(mat_tuple(mat_mul_p(a1, a2, p)))
    return result


def family_upper_tri_trace(p):
    members = []
    for a, b, d in cart_product(range(p), repeat=3):
        if (a * d) % p != 0:
            tr = (a + d) % p
            det_ = (a * d) % p
            if (tr * tr) % p == det_:
                members.append([[a, b], [0, d]])
    return members


def family_unipotent_square(p):
    squares = set((t * t) % p for t in range(p))
    return [[[1, s], [0, 1]] for s in squares]


def family_circle(p):
    members = []
    for a in range(1, p):
        for t in range(p):
            if (a * a + t * t) % p == 1:
                members.append([[a, (a * t) % p], [0, a]])
    return members


def compute_ratios(family_func, primes):
    ratios = []
    valid_primes = []
    for p in primes:
        A = family_func(p)
        if len(A) == 0:
            continue
        A_sq = product_set_p(A, p)
        ratios.append(len(A_sq) / len(A))
        valid_primes.append(p)
    return valid_primes, ratios


primes = [3, 5, 7, 11, 13]

families = [
    ("Upper triangular\n(tr² = det)", family_upper_tri_trace),
    ("Unipotent\n(square entry)", family_unipotent_square),
    ("Scalar × unipotent\n(circle)", family_circle),
]

fig, axes = plt.subplots(1, 3, figsize=(14, 5), sharey=True)
fig.suptitle("Doubling Ratios |A²|/|A| Across Finite Fields\n"
             "Bounded ratios ⟹ transfer conjecture consistent",
             fontsize=14, fontweight='bold')

colors = ['#2196F3', '#4CAF50', '#FF9800']

for idx, (name, func) in enumerate(families):
    ax = axes[idx]
    valid_p, ratios = compute_ratios(func, primes)

    bars = ax.bar([str(p) for p in valid_p], ratios,
                  color=colors[idx], alpha=0.8, edgecolor='white')

    # Add value labels on bars
    for bar, r in zip(bars, ratios):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.05,
                f'{r:.2f}', ha='center', va='bottom', fontsize=9)

    ax.set_xlabel('Field size p', fontsize=11)
    ax.set_title(name, fontsize=11)
    ax.set_ylim(0, max(max(r for _, r in [compute_ratios(f, primes)
                for _, f in families] if r), default=[4]) + 0.5)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Ratio = 1')
    ax.grid(axis='y', alpha=0.3)

axes[0].set_ylabel('Doubling Ratio |A²|/|A|', fontsize=11)

plt.tight_layout()
plt.savefig('doubling_ratios.png', dpi=150, bbox_inches='tight')
print("Saved doubling_ratios.png")
