#!/usr/bin/env python3
"""
Visualization: Doubling Ratios Across Finite Fields

Visualizes the key prediction of the pseudofinite transfer principle:
that doubling ratios |A²|/|A| for polynomially definable families
in GL(2, F_q) stabilize as q grows, providing evidence for the
transfer conjecture.

Each curve represents a different definable family. Stable (bounded)
curves support the conjecture; diverging curves would refute it.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartprod


def mat_mul(m1, m2, q):
    (a, b), (c, d) = m1
    (e, f), (g, h) = m2
    return (((a*e + b*g) % q, (a*f + b*h) % q),
            ((c*e + d*g) % q, (c*f + d*h) % q))


def product_set(S, q):
    return {mat_mul(a, b, q) for a in S for b in S}


def poly_image_set(q, deg=2):
    return {pow(x, deg, q) for x in range(q)}


def family_upper_tri(q, trace_val=0):
    members = set()
    for a in range(1, q):
        d = (trace_val - a) % q
        if d == 0:
            continue
        for b in range(q):
            members.add(((a, b), (0, d)))
    return members


def family_unipotent(q, deg=2):
    images = poly_image_set(q, deg)
    return {((1, t), (0, 1)) for t in images}


def family_diag_unipotent(q, deg=2):
    images = poly_image_set(q, deg)
    members = set()
    for a in range(1, q):
        for t in images:
            members.add(((a, t), (0, a)))
    return members


def compute_ratio(family_fn, q, **kwargs):
    A = family_fn(q, **kwargs)
    if not A:
        return None
    AA = product_set(A, q)
    return len(AA) / len(A)


primes = [3, 5, 7, 11, 13, 17, 19, 23]

families = [
    ("Upper triangular (tr=0)", family_upper_tri, {"trace_val": 0}),
    ("Unipotent (quadratic)", family_unipotent, {"deg": 2}),
    ("Unipotent (cubic)", family_unipotent, {"deg": 3}),
    ("Diag × Unipotent (deg 2)", family_diag_unipotent, {"deg": 2}),
]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
markers = ['o', 's', '^', 'D']

for idx, (name, fn, kwargs) in enumerate(families):
    ratios = []
    sizes = []
    valid_primes = []
    for q in primes:
        r = compute_ratio(fn, q, **kwargs)
        if r is not None:
            ratios.append(r)
            A = fn(q, **kwargs)
            sizes.append(len(A))
            valid_primes.append(q)

    ax1.plot(valid_primes, ratios, color=colors[idx], marker=markers[idx],
             linewidth=2, markersize=8, label=name, alpha=0.85)
    ax2.plot(valid_primes, sizes, color=colors[idx], marker=markers[idx],
             linewidth=2, markersize=8, label=name, alpha=0.85)

ax1.set_xlabel('Field size q', fontsize=13)
ax1.set_ylabel('Doubling ratio |A²|/|A|', fontsize=13)
ax1.set_title('Doubling Ratios Stabilize\n(Transfer Conjecture Evidence)', fontsize=14)
ax1.legend(fontsize=10, loc='upper right')
ax1.axhline(y=10, color='gray', linestyle='--', alpha=0.4, label='K=10 threshold')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

ax2.set_xlabel('Field size q', fontsize=13)
ax2.set_ylabel('Family size |A_q|', fontsize=13)
ax2.set_title('Family Sizes Grow with q\n(Pseudofinite Limit is Infinite)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('doubling_ratios.png', dpi=150, bbox_inches='tight')
print("Saved doubling_ratios.png")
