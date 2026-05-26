#!/usr/bin/env python3
"""
Visualization 1: Product Growth Exponents in SL(2, F_p)

Visualizes the empirical growth exponent δ = log|A³|/log|A| - 1
across different primes and subset sizes, colored by obstruction class.
This shows the dichotomy between Borel-trapped sets (low growth)
and escaped/noncommuting sets (high growth).
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import math


def mod(x, p):
    return x % p

def mat_mul(A, B, p):
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return ((mod(a1*a2+b1*c2,p), mod(a1*b2+b1*d2,p)),
            (mod(c1*a2+d1*c2,p), mod(c1*b2+d1*d2,p)))

def mat_inv(M, p):
    (a, b), (c, d) = M
    return ((mod(d,p), mod(-b,p)), (mod(-c,p), mod(a,p)))

def mat_trace(M, p):
    return mod(M[0][0] + M[1][1], p)

def identity():
    return ((1, 0), (0, 1))

def build_sl2(p):
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if mod(a*d - b*c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result

def is_irreducible_charpoly(M, p):
    t = mat_trace(M, p)
    disc = mod(t*t - 4, p)
    if disc == 0:
        return False
    return pow(disc, (p-1)//2, p) != 1

def is_upper_triangular(M):
    return M[1][0] == 0

def triple_product(A, p):
    result = set()
    A_list = list(A)
    A2 = set()
    for a in A_list:
        for b in A_list:
            A2.add(mat_mul(a, b, p))
    for ab in A2:
        for c in A_list:
            result.add(mat_mul(ab, c, p))
    return result

def commuting_pairs(A, p):
    A_list = list(A)
    n = len(A_list)
    total = 0
    commuting = 0
    for i in range(n):
        for j in range(i+1, n):
            total += 1
            if mat_mul(A_list[i], A_list[j], p) == mat_mul(A_list[j], A_list[i], p):
                commuting += 1
    return commuting / total if total > 0 else 1.0

def classify(A, p):
    if all(is_upper_triangular(m) for m in A):
        return "Borel-like"
    has_irr = any(is_irreducible_charpoly(m, p) for m in A)
    cr = commuting_pairs(A, p)
    if has_irr and cr < 1.0:
        return "escaped/noncommuting"
    elif has_irr:
        return "escaped/commuting"
    elif cr > 0.8:
        return "commuting-heavy"
    else:
        return "mixed"

def sample_symmetric_subset(sl2, p, size):
    I = identity()
    result = {I}
    candidates = [m for m in sl2 if m != I]
    sample_size = min(size // 2, len(candidates))
    if sample_size > 0:
        chosen = random.sample(candidates, sample_size)
        for m in chosen:
            result.add(m)
            result.add(mat_inv(m, p))
    return result


random.seed(42)

primes = [5, 7, 11, 13]
colors = {
    "Borel-like": "#e74c3c",
    "escaped/noncommuting": "#2ecc71",
    "escaped/commuting": "#3498db",
    "commuting-heavy": "#f39c12",
    "mixed": "#9b59b6",
}
markers = {
    "Borel-like": "s",
    "escaped/noncommuting": "o",
    "escaped/commuting": "^",
    "commuting-heavy": "D",
    "mixed": "v",
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Product Growth Exponents in SL(2, 𝔽ₚ)", fontsize=16, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 2][idx % 2]
    sl2 = build_sl2(p)

    data_by_class = {}
    for target_size in [3, 5, 7, 9, 11]:
        for _ in range(25):
            A = sample_symmetric_subset(sl2, p, target_size)
            if len(A) < 2:
                continue
            A3 = triple_product(A, p)
            delta = math.log(len(A3)) / math.log(len(A)) - 1
            cls = classify(A, p)
            if cls not in data_by_class:
                data_by_class[cls] = ([], [])
            data_by_class[cls][0].append(len(A))
            data_by_class[cls][1].append(delta)

    for cls, (sizes, deltas) in data_by_class.items():
        ax.scatter(sizes, deltas, c=colors.get(cls, 'gray'),
                   marker=markers.get(cls, 'o'), label=cls, alpha=0.7, s=50)

    ax.set_xlabel("|A|", fontsize=12)
    ax.set_ylabel("δ = log|A³|/log|A| - 1", fontsize=12)
    ax.set_title(f"p = {p}, |SL(2, 𝔽ₚ)| = {len(sl2)}", fontsize=13)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("growth_exponents.png", dpi=150, bbox_inches='tight')
print("Saved growth_exponents.png")
