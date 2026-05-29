#!/usr/bin/env python3
"""
Visualization: Shadow Profile Comparison

Compares the degree-k shadow sizes against the binomial bound C(ω, k)
for various M-convex families. Shows where the multiaffine bound holds
(matroid bases) and where it fails (non-multiaffine M-convex sets).

This visualization illustrates the central theorem: exchange geometry
controls shadow compression, but the multiaffine constraint is essential
for the sharp binomial bound.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb
from typing import Set, Tuple, List


Exponent = Tuple[int, ...]


def _gen_all(n, remaining, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(remaining + 1):
        current.append(v)
        _gen_all(n, remaining - v, idx + 1, current, results)
        current.pop()


def _gen_dom(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(min(m[idx], remaining) + 1):
        current.append(v)
        _gen_dom(m, remaining - v, n, idx + 1, current, results)
        current.pop()


def degree_shadow(s: Set[Exponent], k: int) -> Set[Exponent]:
    n = len(next(iter(s)))
    shadow = set()
    for m in s:
        results = []
        _gen_dom(m, k, n, 0, [], results)
        shadow.update(results)
    return shadow


def active_width(s: Set[Exponent]) -> int:
    active = set()
    for m in s:
        for i, v in enumerate(m):
            if v > 0:
                active.add(i)
    return len(active)


def uniform_matroid_bases(n: int, r: int) -> Set[Exponent]:
    bases = set()
    for subset in combinations(range(n), r):
        vec = [0] * n
        for i in subset:
            vec[i] = 1
        bases.add(tuple(vec))
    return bases


def full_simplex(n: int, d: int) -> Set[Exponent]:
    results = []
    _gen_all(n, d, 0, [], results)
    return set(results)


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


# ─── Build data ──────────────────────────────────────────────────────

families = [
    ("U₃,₅ (matroid)", uniform_matroid_bases(5, 3), True),
    ("U₄,₆ (matroid)", uniform_matroid_bases(6, 4), True),
    ("Full Δ₃,₃ (non-matroid)", full_simplex(3, 3), False),
    ("Full Δ₃,₄ (non-matroid)", full_simplex(3, 4), False),
    ("Schur s₍₂,₁₎", schur_support((2, 1), 3), False),
    ("Schur s₍₃,₁₎", schur_support((3, 1), 3), False),
]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle("Degree Shadow Profiles: M-Convex Families vs Binomial Bound",
             fontsize=14, fontweight='bold')

for idx, (name, s, is_matroid) in enumerate(families):
    ax = axes[idx // 3][idx % 3]
    d = sum(next(iter(s)))
    omega = active_width(s)

    ks = list(range(d + 1))
    shadow_sizes = [len(degree_shadow(s, k)) for k in ks]
    binomial_bound = [comb(omega, k) for k in ks]

    ax.bar(np.array(ks) - 0.15, shadow_sizes, 0.3, label='|Shadow_k|',
           color='steelblue', alpha=0.8)
    ax.bar(np.array(ks) + 0.15, binomial_bound, 0.3, label='C(ω, k)',
           color='coral', alpha=0.8)

    # Mark violations
    for ki, (ss, bb) in enumerate(zip(shadow_sizes, binomial_bound)):
        if ss > bb:
            ax.annotate('✗', (ki, ss), ha='center', va='bottom',
                       fontsize=14, color='red', fontweight='bold')

    ax.set_xlabel('Shadow degree k')
    ax.set_ylabel('Count')
    ax.set_title(f"{name}\nd={d}, ω={omega}, |S|={len(s)}",
                fontsize=10)
    ax.legend(fontsize=8)
    ax.set_xticks(ks)

plt.tight_layout()
plt.savefig("shadow_profile_comparison.png", dpi=150, bbox_inches='tight')
print("Saved shadow_profile_comparison.png")
