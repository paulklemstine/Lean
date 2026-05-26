#!/usr/bin/env python3
"""
Visualization 3: Cayley Graph Ball Growth and Mixing

Visualizes the ball growth B(k) = |{g : d(1,g) ≤ k}| in the Cayley graph
of SL(2, F_p) with different generating sets. Shows how product growth
translates to rapid expansion in the graph metric, and compares
different generator choices.
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


def ball_growth(generators, p):
    """Compute ball sizes in Cayley graph."""
    sl2 = build_sl2(p)
    N = len(sl2)

    S = set(generators)
    for g in list(S):
        S.add(mat_inv(g, p))
    S.add(identity())

    visited = {identity()}
    frontier = {identity()}
    sizes = [1]

    while frontier and len(visited) < N:
        new_frontier = set()
        for g in frontier:
            for s in S:
                gs = mat_mul(g, s, p)
                if gs not in visited:
                    visited.add(gs)
                    new_frontier.add(gs)
        frontier = new_frontier
        sizes.append(len(visited))

    return sizes


random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Ball growth for different generator types in SL(2, F_7)
p = 7
sl2 = build_sl2(p)
N = len(sl2)

ax = axes[0]

# Generator set 1: Two elements with irreducible charpoly
irr_elements = [g for g in sl2 if is_irreducible_charpoly(g, p)]
gen1 = [irr_elements[0], irr_elements[len(irr_elements)//3]]
sizes1 = ball_growth(gen1, p)

# Generator set 2: Upper triangular elements only
ut_elements = [g for g in sl2 if g[1][0] == 0 and g != identity()]
gen2 = [ut_elements[0], ut_elements[len(ut_elements)//3]]
sizes2 = ball_growth(gen2, p)

# Generator set 3: Mixed (one irr, one ut)
gen3 = [irr_elements[0], ut_elements[0]]
sizes3 = ball_growth(gen3, p)

ax.plot(range(len(sizes1)), sizes1, 'o-', color='#2ecc71',
        label=f'Irr. charpoly gens (d={len(sizes1)-1})', linewidth=2, markersize=5)
ax.plot(range(len(sizes2)), sizes2, 's-', color='#e74c3c',
        label=f'Upper triang. gens (d={len(sizes2)-1})', linewidth=2, markersize=5)
ax.plot(range(len(sizes3)), sizes3, '^-', color='#3498db',
        label=f'Mixed gens (d={len(sizes3)-1})', linewidth=2, markersize=5)
ax.axhline(y=N, color='gray', linestyle='--', alpha=0.5, label=f'|SL(2,𝔽₇)| = {N}')

ax.set_xlabel("Distance from identity (k)", fontsize=12)
ax.set_ylabel("Ball size |B(k)|", fontsize=12)
ax.set_title(f"Cayley Graph Ball Growth in SL(2, 𝔽₇)", fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Plot 2: Diameter comparison across primes
ax = axes[1]

primes_for_diam = [5, 7, 11, 13]
diameters_irr = []
diameters_ut = []
group_sizes = []

for pp in primes_for_diam:
    sl2_pp = build_sl2(pp)
    N_pp = len(sl2_pp)
    group_sizes.append(N_pp)

    irr_pp = [g for g in sl2_pp if is_irreducible_charpoly(g, pp)]
    if len(irr_pp) >= 2:
        gen_irr = [irr_pp[0], irr_pp[len(irr_pp)//3]]
        s_irr = ball_growth(gen_irr, pp)
        diameters_irr.append(len(s_irr) - 1)
    else:
        diameters_irr.append(0)

    ut_pp = [g for g in sl2_pp if g[1][0] == 0 and g != identity()]
    if len(ut_pp) >= 2:
        gen_ut = [ut_pp[0], ut_pp[min(1, len(ut_pp)-1)]]
        s_ut = ball_growth(gen_ut, pp)
        diameters_ut.append(len(s_ut) - 1)
    else:
        diameters_ut.append(0)

log_sizes = [math.log(n) for n in group_sizes]

ax.bar(np.arange(len(primes_for_diam)) - 0.15, diameters_irr, 0.3,
       color='#2ecc71', label='Irr. charpoly gens', alpha=0.8)
ax.bar(np.arange(len(primes_for_diam)) + 0.15, diameters_ut, 0.3,
       color='#e74c3c', label='Upper triang. gens', alpha=0.8)

# Add log(N) reference
ax2 = ax.twinx()
ax2.plot(range(len(primes_for_diam)), log_sizes, 'k--', marker='D',
         label='log|G|', alpha=0.6, markersize=6)
ax2.set_ylabel("log|SL(2, 𝔽ₚ)|", fontsize=11)
ax2.legend(loc='upper left', fontsize=10)

ax.set_xticks(range(len(primes_for_diam)))
ax.set_xticklabels([f"p={pp}" for pp in primes_for_diam])
ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("Cayley Graph Diameter", fontsize=12)
ax.set_title("Diameter vs Generator Type", fontsize=13, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("cayley_graph_growth.png", dpi=150, bbox_inches='tight')
print("Saved cayley_graph_growth.png")
