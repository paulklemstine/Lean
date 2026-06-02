#!/usr/bin/env python3
"""
visualize_spectrum.py — Visualize spectrum sum rigidity and chain statistics.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from itertools import permutations
from math import factorial, log2, prod


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


def sopfr(n):
    return sum(factorize(n))


def count_maximal_chains(n):
    factors = factorize(n)
    total = len(factors)
    counts = Counter(factors)
    denom = prod(factorial(e) for e in counts.values())
    return factorial(total) // denom


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Ω(n) vs log₂(n)
ax = axes[0, 0]
ns = range(2, 501)
omegas = [big_omega(n) for n in ns]
logs = [log2(n) for n in ns]
ax.scatter(ns, omegas, s=3, alpha=0.5, label='Ω(n)', color='blue')
ax.plot(ns, logs, 'r-', linewidth=1.5, alpha=0.7, label='log₂(n)')
ax.set_xlabel('n')
ax.set_ylabel('Value')
ax.set_title('Chain Rank Theorem: Ω(n) ≤ log₂(n)')
ax.legend()

# Plot 2: sopfr(n) distribution
ax = axes[0, 1]
ns = range(2, 501)
sopfrs = [sopfr(n) for n in ns]
ax.scatter(ns, sopfrs, s=3, alpha=0.5, color='green')
ax.set_xlabel('n')
ax.set_ylabel('sopfr(n)')
ax.set_title('Spectrum Sum sopfr(n) = Sum of Prime Factors')

# Plot 3: Number of maximal chains
ax = axes[1, 0]
ns_small = range(2, 201)
chain_counts = [count_maximal_chains(n) for n in ns_small]
ax.bar(ns_small, chain_counts, width=1, alpha=0.7, color='purple')
ax.set_xlabel('n')
ax.set_ylabel('Number of maximal chains')
ax.set_title('Chain Count (Multinomial Coefficient)')
ax.set_yscale('log')

# Plot 4: Ω(n) / log₂(n) ratio
ax = axes[1, 1]
ns = range(2, 1001)
ratios = [big_omega(n) / log2(n) for n in ns]
ax.scatter(ns, ratios, s=2, alpha=0.3, color='orange')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='upper bound')
ax.set_xlabel('n')
ax.set_ylabel('Ω(n) / log₂(n)')
ax.set_title('Relative Chain Depth: Ω(n) / log₂(n) ≤ 1')
ax.legend()
ax.set_ylim(0, 1.1)

plt.suptitle('Chain Invariants in Divisibility Lattices', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('chain_statistics.png', dpi=150, bbox_inches='tight')
print("Saved chain_statistics.png")
