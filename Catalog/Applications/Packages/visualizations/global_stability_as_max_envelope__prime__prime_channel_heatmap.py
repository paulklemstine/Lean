#!/usr/bin/env python3
"""
Visualization: Prime Channel Decomposition

Shows how the global torsion birth is the minimum of primewise births,
and how stability distances decompose across prime channels.
Creates a heatmap of primewise shifts for multiple filtration pairs.
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


random.seed(123)
primes_list = [2, 3, 5, 7]
pool = [2, 3, 5, 6, 10, 14, 15, 21, 30, 35, 42, 70, 105, 210]
N = 20

# Compute shifts for N pairs
shifts_matrix = np.zeros((N, len(primes_list)))
global_shifts = []

for trial in range(N):
    nc = random.randint(2, 5)
    Fb = sorted(random.sample(range(1, 30), min(nc, 29)))
    Fo = [random.choice(pool) for _ in range(len(Fb))]
    Gb = sorted(random.sample(range(1, 30), min(nc, 29)))
    Go = [random.choice(pool) for _ in range(len(Gb))]

    # Global birth
    gF = min((t for t, n in zip(Fb, Fo) if n >= 2), default=None)
    gG = min((t for t, n in zip(Gb, Go) if n >= 2), default=None)
    gs = abs(gF - gG) if gF is not None and gG is not None else 0
    global_shifts.append(gs)

    # Per-prime shifts
    for j, p in enumerate(primes_list):
        pF = min((t for t, n in zip(Fb, Fo) if n >= 2 and n % p == 0), default=None)
        pG = min((t for t, n in zip(Gb, Go) if n >= 2 and n % p == 0), default=None)
        if pF is not None and pG is not None:
            shifts_matrix[trial, j] = abs(pF - pG)
        else:
            shifts_matrix[trial, j] = -1  # no data

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Heatmap of primewise shifts
ax1 = axes[0]
display_matrix = shifts_matrix.copy()
mask = display_matrix < 0
display_matrix[mask] = np.nan

im = ax1.imshow(display_matrix, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xticks(range(len(primes_list)))
ax1.set_xticklabels([f'p={p}' for p in primes_list], fontsize=11)
ax1.set_ylabel('Filtration Pair Index', fontsize=12)
ax1.set_title('Primewise Shift Heatmap\n(darker = larger shift)', fontsize=13)

# Mark cells with no data
for i in range(N):
    for j in range(len(primes_list)):
        if mask[i, j]:
            ax1.text(j, i, '—', ha='center', va='center', color='gray', fontsize=8)
        else:
            val = int(display_matrix[i, j])
            ax1.text(j, i, str(val), ha='center', va='center',
                    color='white' if val > 8 else 'black', fontsize=9)

plt.colorbar(im, ax=ax1, label='Shift Distance')

# Bar chart: global vs max prime
ax2 = axes[1]
max_prime_shifts = [max(shifts_matrix[i, shifts_matrix[i] >= 0], default=0)
                     for i in range(N)]

x = np.arange(N)
width = 0.35
bars1 = ax2.bar(x - width/2, global_shifts, width, label='Global Shift',
                color='#2196F3', alpha=0.8)
bars2 = ax2.bar(x + width/2, max_prime_shifts, width, label='Max Prime Shift',
                color='#FF9800', alpha=0.8)

# Highlight pairs where gap > 0
for i in range(N):
    if max_prime_shifts[i] > global_shifts[i]:
        ax2.annotate('', xy=(i + width/2, max_prime_shifts[i]),
                     xytext=(i + width/2, max_prime_shifts[i] + 0.5),
                     arrowprops=dict(arrowstyle='v', color='red', lw=1.5))

ax2.set_xlabel('Filtration Pair Index', fontsize=12)
ax2.set_ylabel('Shift Distance', fontsize=12)
ax2.set_title('Global vs Max Prime Shift\n(red arrows: strict inequality)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_channels.png', dpi=150, bbox_inches='tight')
print("Saved viz_channels.png")
