#!/usr/bin/env python3
"""
Visualization: Covering Number Growth vs Plünnecke-Ruzsa Bound

Plots the covering number cov(H^n, H) alongside the conjectured bound K^(n-1)
and the classical Plünnecke-Ruzsa cardinality bound K^n for various subsets
of symmetric groups. Shows that the covering bound is strictly sharper.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations


def symmetric_group(n):
    return list(permutations(range(n)))


def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))


def inverse_perm(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def set_product(A, B):
    return {compose_perm(a, b) for a in A for b in B}


def set_pow(H, n, identity):
    if n == 0:
        return {identity}
    result = {identity}
    for _ in range(n):
        result = set_product(result, H)
    return result


def covering_number(A, H, group):
    if not A:
        return 0
    uncovered = set(A)
    count = 0
    while uncovered:
        best_g = None
        best_count = 0
        for g in group:
            t = {compose_perm(g, h) for h in H}
            c = len(uncovered & t)
            if c > best_count:
                best_count = c
                best_g = g
        if best_count == 0:
            return float('inf')
        uncovered -= {compose_perm(best_g, h) for h in H}
        count += 1
    return count


# Compute data for S₃
G3 = symmetric_group(3)
e3 = (0, 1, 2)
s12 = (1, 0, 2)
s13 = (2, 1, 0)
s23 = (0, 2, 1)
H_reflections = {e3, s12, s13, s23}

# Compute data for S₄
G4 = symmetric_group(4)
e4 = (0, 1, 2, 3)
s12_4 = (1, 0, 2, 3)
s13_4 = (2, 1, 0, 3)
s23_4 = (0, 2, 1, 3)
s34_4 = (0, 1, 3, 2)
H_s4 = {e4, s12_4, s13_4, s23_4}

test_cases = [
    ("S₃: {e,(12),(13),(23)}", G3, H_reflections, e3),
    ("S₄: {e,(12),(13),(23)}", G4, H_s4, e4),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, (name, G, H, identity) in enumerate(test_cases):
    ax = axes[idx]

    HH = set_product(H, H)
    K = covering_number(HH, H, G)
    card_H = len(H)

    ns = list(range(1, 8))
    covs = []
    cards = []
    bound_cov = []
    bound_pr = []

    for n in ns:
        Hn = set_pow(H, n, identity)
        cov = covering_number(Hn, H, G)
        covs.append(cov)
        cards.append(len(Hn))
        bound_cov.append(K ** (n - 1))
        bound_pr.append(K ** n * card_H)

    ax.semilogy(ns, covs, 'bo-', linewidth=2, markersize=8, label='cov(H^n, H)', zorder=5)
    ax.semilogy(ns, bound_cov, 'r--', linewidth=2, label=f'K^(n-1), K={K}')
    ax.semilogy(ns, cards, 'g^-', linewidth=1.5, markersize=7, label='|H^n|')
    ax.semilogy(ns, bound_pr, 'k:', linewidth=1.5, label=f'K^n·|H| (Plünnecke-Ruzsa)')

    ax.set_xlabel('n (product set exponent)', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title(f'{name}\nK={K}, |H|={card_H}', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ns)

fig.suptitle('Covering Number Growth vs Classical Bounds', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('covering_growth.png', dpi=150, bbox_inches='tight')
print("Saved covering_growth.png")
