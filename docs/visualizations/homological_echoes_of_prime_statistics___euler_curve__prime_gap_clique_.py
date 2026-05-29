#!/usr/bin/env python3
"""
Visualization: Euler Curve of Prime Gap Clique Complexes

Plots the Euler characteristic χ(K(n, L, S_t)) as the admissible gap set
grows from S = {2} to S = {2,4,...,max_gap}. This filtration profile is
the fundamental topological observable connecting prime statistics to
persistence theory.

The plot compares actual prime data against a Bernoulli random model,
revealing arithmetic structure invisible to density-based statistics.
"""

import math
import random
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained prime utilities ──

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def topological_summary(primes, S):
    prime_set = set(primes)
    edges = set()
    adj = defaultdict(set)
    for p in primes:
        for h in S:
            q = p + h
            if q in prime_set:
                edges.add(frozenset([p, q]))
                adj[p].add(q)
                adj[q].add(p)
    V = len(primes)
    E = len(edges)
    T = 0
    for i, p in enumerate(primes):
        for j in range(i+1, len(primes)):
            q = primes[j]
            if q not in adj.get(p, set()):
                continue
            for k in range(j+1, len(primes)):
                r = primes[k]
                if r in adj.get(p, set()) and r in adj.get(q, set()):
                    T += 1
    return V, E, T, V - E + T

# ── Compute filtration profiles ──

def euler_filtration(n, L, max_gap):
    primes = primes_in_window(n, L)
    gaps = list(range(2, max_gap + 1, 2))
    chis = []
    for t in gaps:
        S = set(range(2, t + 1, 2))
        _, _, _, chi = topological_summary(primes, S)
        chis.append(chi)
    return gaps, chis

def bernoulli_euler_filtration(n, L, max_gap, p, num_samples=200):
    gaps = list(range(2, max_gap + 1, 2))
    mean_chis = []
    std_chis = []
    random.seed(123)
    
    for t in gaps:
        S = set(range(2, t + 1, 2))
        sample_chis = []
        for _ in range(num_samples):
            fake = sorted(x for x in range(n, n + L) if random.random() < p)
            if fake:
                _, _, _, chi = topological_summary(fake, S)
                sample_chis.append(chi)
            else:
                sample_chis.append(0)
        mean_chis.append(np.mean(sample_chis))
        std_chis.append(np.std(sample_chis))
    
    return gaps, mean_chis, std_chis

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

windows = [(100, 100, "small"), (1000, 200, "medium"), (10000, 300, "large")]
max_gap = 30

for ax, (n, L, label) in zip(axes, windows):
    primes = primes_in_window(n, L)
    density = len(primes) / L
    
    gaps, chis = euler_filtration(n, L, max_gap)
    gaps_b, mean_b, std_b = bernoulli_euler_filtration(n, L, max_gap, density, 150)
    
    # Plot Bernoulli band
    mean_arr = np.array(mean_b)
    std_arr = np.array(std_b)
    ax.fill_between(gaps_b, mean_arr - 2*std_arr, mean_arr + 2*std_arr,
                     alpha=0.2, color='steelblue', label='Bernoulli ±2σ')
    ax.plot(gaps_b, mean_b, '--', color='steelblue', linewidth=1.5,
            label='Bernoulli mean')
    
    # Plot actual
    ax.plot(gaps, chis, 'o-', color='crimson', linewidth=2, markersize=4,
            label='Actual primes')
    
    ax.set_xlabel('Maximum gap in S', fontsize=11)
    ax.set_ylabel('Euler characteristic χ', fontsize=11)
    ax.set_title(f'Window [{n}, {n+L-1}]\n'
                 f'{len(primes)} primes, ρ={density:.3f}', fontsize=11)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

fig.suptitle('Euler Curve: Prime Gap Clique Complex Filtration',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('euler_curve.png', dpi=150, bbox_inches='tight')
print("Saved euler_curve.png")
