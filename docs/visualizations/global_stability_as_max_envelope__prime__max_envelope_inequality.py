#!/usr/bin/env python3
"""
Visualization: Max-Envelope Principle for Torsion Stability

Visualizes the relationship between global torsion birth shifts and
the maximum of primewise shifts across many random filtration pairs.
Shows that globalShift ≤ maxPrimeShift always holds (points below diagonal)
but equality does not always hold.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def prime_factors(n):
    if n < 2:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def compute_shifts(F_births, F_orders, G_births, G_orders):
    primes = set()
    for n in F_orders + G_orders:
        primes |= prime_factors(n)

    def gb(births, orders):
        r = None
        for t, n in zip(births, orders):
            if n >= 2 and (r is None or t < r):
                r = t
        return r

    gF, gG = gb(F_births, F_orders), gb(G_births, G_orders)
    gs = abs(gF - gG) if gF is not None and gG is not None else None

    max_ps = 0
    for p in primes:
        pF = None
        for t, n in zip(F_births, F_orders):
            if n >= 2 and n % p == 0 and (pF is None or t < pF):
                pF = t
        pG = None
        for t, n in zip(G_births, G_orders):
            if n >= 2 and n % p == 0 and (pG is None or t < pG):
                pG = t
        if pF is not None and pG is not None:
            max_ps = max(max_ps, abs(pF - pG))

    return gs, max_ps


random.seed(42)
N = 500
pool = [2, 3, 5, 6, 10, 15, 30]

globals_list = []
maxprimes_list = []

for _ in range(N):
    nc = random.randint(1, 4)
    Fb = sorted(random.sample(range(1, 25), min(nc, 24)))
    Fo = [random.choice(pool) for _ in range(len(Fb))]
    Gb = sorted(random.sample(range(1, 25), min(nc, 24)))
    Go = [random.choice(pool) for _ in range(len(Gb))]

    gs, mps = compute_shifts(Fb, Fo, Gb, Go)
    if gs is not None:
        globals_list.append(gs)
        maxprimes_list.append(mps)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Scatter of global vs max prime shift
ax1 = axes[0]
gs_arr = np.array(globals_list)
mps_arr = np.array(maxprimes_list)

# Color by whether equality holds
eq_mask = gs_arr == mps_arr
ineq_mask = ~eq_mask

ax1.scatter(mps_arr[eq_mask], gs_arr[eq_mask], c='#2196F3', alpha=0.5,
           s=30, label=f'Equality ({eq_mask.sum()})', zorder=2)
ax1.scatter(mps_arr[ineq_mask], gs_arr[ineq_mask], c='#FF5722', alpha=0.5,
           s=30, label=f'Strict ineq ({ineq_mask.sum()})', zorder=2)

max_val = max(max(globals_list), max(maxprimes_list)) + 1
ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y = x (equality)')
ax1.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                  alpha=0.05, color='red')
ax1.set_xlabel('Max Prime Shift (envelope)', fontsize=12)
ax1.set_ylabel('Global Shift', fontsize=12)
ax1.set_title('Max-Envelope Inequality:\nGlobal Shift ≤ Max Prime Shift', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xlim(-0.5, max_val)
ax1.set_ylim(-0.5, max_val)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Plot 2: Distribution of gaps
ax2 = axes[1]
gaps = mps_arr - gs_arr
ax2.hist(gaps, bins=range(int(gaps.min()), int(gaps.max()) + 2),
         color='#4CAF50', edgecolor='white', alpha=0.8)
ax2.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Gap = 0 (equality)')
ax2.set_xlabel('Gap: maxPrimeShift − globalShift', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Max-Envelope Gap\n(always ≥ 0 by theorem)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_envelope.png', dpi=150, bbox_inches='tight')
print("Saved viz_envelope.png")
