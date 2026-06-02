#!/usr/bin/env python3
"""
visualize_chains.py — Visualize divisibility chain structure.

Produces a matplotlib figure showing:
1. All maximal chains from 1 to n as paths in the divisibility lattice
2. The Hasse diagram of divisors of n
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from itertools import permutations
from math import factorial, prod


def factorize(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n):
    return len(factorize(n))


def divisors(n):
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def enumerate_maximal_chains(n):
    factors = factorize(n)
    if not factors:
        return [[1]] if n == 1 else []
    chains = set()
    for perm in set(permutations(factors)):
        chain = [1]
        for p in perm:
            chain.append(chain[-1] * p)
        chains.add(tuple(chain))
    return [list(c) for c in sorted(chains)]


def plot_divisibility_lattice(n, ax):
    """Plot the Hasse diagram of divisors of n with maximal chains highlighted."""
    divs = divisors(n)
    
    # Assign y-coordinate based on Omega
    y_pos = {d: big_omega(d) for d in divs}
    
    # Assign x-coordinate: spread elements at same level
    levels = {}
    for d in divs:
        lev = y_pos[d]
        if lev not in levels:
            levels[lev] = []
        levels[lev].append(d)
    
    x_pos = {}
    for lev, elements in levels.items():
        for i, d in enumerate(sorted(elements)):
            x_pos[d] = (i - (len(elements) - 1) / 2) * 1.5
    
    # Draw edges (Hasse diagram: d1 -> d2 if d1 | d2 and d2/d1 is prime)
    for d1 in divs:
        for d2 in divs:
            if d1 != d2 and d2 % d1 == 0:
                q = d2 // d1
                if len(factorize(q)) == 1:  # q is prime
                    ax.plot([x_pos[d1], x_pos[d2]], [y_pos[d1], y_pos[d2]], 
                           'k-', alpha=0.2, linewidth=1)
    
    # Highlight maximal chains
    chains = enumerate_maximal_chains(n)
    colors = plt.cm.Set1(np.linspace(0, 1, min(len(chains), 9)))
    
    for idx, chain in enumerate(chains[:9]):
        color = colors[idx % len(colors)]
        for i in range(len(chain) - 1):
            d1, d2 = chain[i], chain[i + 1]
            ax.plot([x_pos[d1], x_pos[d2]], [y_pos[d1], y_pos[d2]], 
                   '-', color=color, linewidth=2.5, alpha=0.7)
    
    # Draw nodes
    for d in divs:
        ax.plot(x_pos[d], y_pos[d], 'o', color='white', markersize=20, 
               markeredgecolor='black', markeredgewidth=1.5, zorder=5)
        ax.text(x_pos[d], y_pos[d], str(d), ha='center', va='center', 
               fontsize=8, fontweight='bold', zorder=6)
    
    ax.set_ylabel('Ω (chain depth)', fontsize=11)
    ax.set_title(f'Divisibility lattice of {n}\n'
                f'Ω({n}) = {big_omega(n)}, '
                f'{len(chains)} maximal chain{"s" if len(chains) > 1 else ""}',
                fontsize=12)
    ax.set_xlim(-4, 4)


fig, axes = plt.subplots(1, 3, figsize=(18, 7))

for ax, n in zip(axes, [12, 30, 60]):
    plot_divisibility_lattice(n, ax)

plt.tight_layout()
plt.savefig('divisibility_lattice.png', dpi=150, bbox_inches='tight')
print("Saved divisibility_lattice.png")
