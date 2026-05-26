#!/usr/bin/env python3
"""
Visualization 2: Trace Amplification in SL(2, F_p)

Visualizes how the trace set grows through iterated products:
|tr(A)| → |tr(A²)| → |tr(A³)|
Shows the amplification effect that connects group multiplication
to additive structure in the base field F_p.
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


random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Trace Amplification Through Products in SL(2, 𝔽ₚ)",
             fontsize=15, fontweight='bold')

primes = [7, 11, 13]

for idx, p in enumerate(primes):
    ax = axes[idx]
    sl2 = build_sl2(p)

    # Run multiple trials
    results = []
    for _ in range(40):
        # Sample symmetric subset
        I = identity()
        size = random.randint(3, min(15, len(sl2) // 4))
        A_set = {I}
        candidates = [m for m in sl2 if m != I]
        chosen = random.sample(candidates, min(size, len(candidates)))
        for m in chosen:
            A_set.add(m)
            A_set.add(mat_inv(m, p))
        A_list = list(A_set)

        # Compute trace sets at each level
        tr_A = {mat_trace(g, p) for g in A_set}

        A2 = set()
        for a in A_list:
            for b in A_list:
                A2.add(mat_mul(a, b, p))
        tr_A2 = {mat_trace(g, p) for g in A2}

        A3 = set()
        for ab in A2:
            for c in A_list:
                A3.add(mat_mul(ab, c, p))
        tr_A3 = {mat_trace(g, p) for g in A3}

        has_irr = any(is_irreducible_charpoly(m, p) for m in A_set)

        results.append({
            'A_size': len(A_set),
            'tr_sizes': [len(tr_A), len(tr_A2), len(tr_A3)],
            'has_irr': has_irr,
        })

    # Plot trace amplification
    for r in results:
        color = '#2ecc71' if r['has_irr'] else '#e74c3c'
        alpha = 0.6 if r['has_irr'] else 0.4
        label = None
        ax.plot([1, 2, 3], r['tr_sizes'], '-o', color=color,
                alpha=alpha, markersize=4, linewidth=1)

    # Add reference line for p (max possible)
    ax.axhline(y=p, color='navy', linestyle='--', alpha=0.7,
               label=f'p = {p} (max)')

    # Custom legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#2ecc71', marker='o', label='Has irr. charpoly'),
        Line2D([0], [0], color='#e74c3c', marker='o', label='No irr. charpoly'),
        Line2D([0], [0], color='navy', linestyle='--', label=f'p = {p}'),
    ]
    ax.legend(handles=legend_elements, fontsize=9, loc='lower right')

    ax.set_xlabel("Product level k (A, A², A³)", fontsize=11)
    ax.set_ylabel("|tr(Aᵏ)|", fontsize=11)
    ax.set_title(f"p = {p}", fontsize=13)
    ax.set_xticks([1, 2, 3])
    ax.set_xticklabels(["A", "A²", "A³"])
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("trace_amplification.png", dpi=150, bbox_inches='tight')
print("Saved trace_amplification.png")
