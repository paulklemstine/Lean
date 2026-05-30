#!/usr/bin/env python3
"""
Visualization: Prime Fractal Embedding and Metric Space

Visualizes the prime fractal embedding p ↦ 1/log(p) and its properties:
- The embedding of primes on the real line
- Distance decay between consecutive primes
- Box-counting dimension estimation
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def prime_fractal_embed(n):
    if n >= 2:
        return 1.0 / math.log(n)
    return 0.0


def box_count(N, epsilon):
    boxes = set()
    for n in range(2, N + 1):
        val = prime_fractal_embed(n)
        box_idx = int(math.floor(val / epsilon))
        boxes.add(box_idx)
    return len(boxes)


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# ─── Panel 1: Prime Fractal Embedding ───
ax1 = axes[0]
primes = sieve_of_eratosthenes(200)
embeddings = [prime_fractal_embed(p) for p in primes]

ax1.scatter(primes, embeddings, s=15, c='#2563eb', alpha=0.8, zorder=3)
ax1.plot(primes, embeddings, 'b-', alpha=0.3, linewidth=0.5)

# Annotate a few primes
for p in [2, 3, 5, 11, 29, 97, 197]:
    if p in primes:
        e = prime_fractal_embed(p)
        ax1.annotate(f'{p}', (p, e), textcoords="offset points",
                    xytext=(5, 5), fontsize=7, color='#1e40af')

ax1.set_xlabel('Prime p', fontsize=11)
ax1.set_ylabel('φ(p) = 1/log(p)', fontsize=11)
ax1.set_title('Prime Fractal Embedding', fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 210)

# ─── Panel 2: Gap Measure Decay ───
ax2 = axes[1]
ns = list(range(2, 500))
gaps = [1.0/math.log(n) - 1.0/math.log(n+1) for n in ns]
approx = [1.0/(n * math.log(n)**2) for n in ns]

ax2.semilogy(ns, gaps, 'b-', linewidth=1.5, label='Δ(n) = 1/log(n) − 1/log(n+1)', alpha=0.8)
ax2.semilogy(ns, approx, 'r--', linewidth=1, label='≈ 1/(n·log²(n))', alpha=0.6)

# Mark prime positions
prime_gaps = [(p, 1.0/math.log(p) - 1.0/math.log(p+1)) for p in primes if p < 500]
px, py = zip(*prime_gaps)
ax2.scatter(px, py, s=8, c='#dc2626', alpha=0.5, zorder=3, label='At primes')

ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel('Gap measure Δ(n)', fontsize=11)
ax2.set_title('Logarithmic Gap Decay', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

# ─── Panel 3: Box-Counting Dimension ───
ax3 = axes[2]

Ns = [1000, 5000, 10000, 50000]
colors = ['#2563eb', '#7c3aed', '#dc2626', '#059669']

for N, color in zip(Ns, colors):
    scales = [10**(-k/2) for k in range(2, 11)]
    log_inv = []
    log_bc = []
    for eps in scales:
        bc = box_count(N, eps)
        if bc > 1:
            log_inv.append(math.log(1.0/eps))
            log_bc.append(math.log(bc))
    ax3.plot(log_inv, log_bc, 'o-', color=color, markersize=4,
             linewidth=1.5, label=f'N={N}', alpha=0.8)

# Reference line: slope = 1
x_ref = np.linspace(1, 12, 100)
ax3.plot(x_ref, x_ref, 'k--', alpha=0.3, linewidth=1, label='slope = 1 (dim = 1)')

ax3.set_xlabel('log(1/ε)', fontsize=11)
ax3.set_ylabel('log(boxCount)', fontsize=11)
ax3.set_title('Box-Counting Dimension', fontsize=13, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('prime_fractal_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: prime_fractal_visualization.png")
