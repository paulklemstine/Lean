#!/usr/bin/env python3
"""
Visualization: Arithmetic Discrepancy Scaling

Shows how the discrepancy between actual prime gap complex statistics
and the Bernoulli random model grows with window position, revealing
systematic arithmetic structure beyond what density alone captures.

This is the visualization of the cross-domain theorem connecting
number theory (prime correlations) with random topology (Bernoulli flag complexes).
"""

import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained utilities ──

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

def compute_stats(n, L, S):
    primes = primes_in_window(n, L)
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
    density = V / L if L > 0 else 0
    E_bern = density**2 * sum(max(L - h, 0) for h in S)
    return {
        'V': V, 'E': E, 'T': T, 'chi': V - E + T,
        'density': density, 'E_bernoulli': E_bern,
        'edge_disc': E - E_bern,
        'chi_norm': (V - E + T) / max(V, 1),
    }

# ── Compute for many windows ──

S = {2, 4, 6, 8, 10}
window_starts = list(range(100, 20001, 200))
L = 150

ns = []
edge_discs = []
chi_norms = []
densities = []
edge_counts = []
vertex_counts = []

for n in window_starts:
    stats = compute_stats(n, L, S)
    ns.append(n)
    edge_discs.append(stats['edge_disc'])
    chi_norms.append(stats['chi_norm'])
    densities.append(stats['density'])
    edge_counts.append(stats['E'])
    vertex_counts.append(stats['V'])

ns = np.array(ns)
edge_discs = np.array(edge_discs)
chi_norms = np.array(chi_norms)

# ── Plot ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Edge discrepancy
ax = axes[0, 0]
ax.plot(ns, edge_discs, 'o-', color='crimson', markersize=2, linewidth=0.8)
ax.axhline(y=0, color='gray', linewidth=1, linestyle='--')
# Running average
window_size = 10
if len(edge_discs) >= window_size:
    running_avg = np.convolve(edge_discs, np.ones(window_size)/window_size, mode='valid')
    ax.plot(ns[window_size//2:window_size//2+len(running_avg)], running_avg,
            color='navy', linewidth=2, label=f'Running avg (w={window_size})')
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('Edge discrepancy (actual - Bernoulli)', fontsize=10)
ax.set_title('Edge Count Excess over Bernoulli Model', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Normalized Euler characteristic
ax = axes[0, 1]
ax.plot(ns, chi_norms, 'o-', color='forestgreen', markersize=2, linewidth=0.8)
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('χ / V (normalized Euler char)', fontsize=10)
ax.set_title('Normalized Euler Characteristic', fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Prime density vs 1/ln(n)
ax = axes[1, 0]
expected = [1/math.log(max(n, 3)) for n in ns]
ax.plot(ns, densities, 'o', color='crimson', markersize=2, label='Actual ρ(n,L)')
ax.plot(ns, expected, '-', color='steelblue', linewidth=1.5, label='1/ln(n)')
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('Prime density', fontsize=10)
ax.set_title('Prime Density in Windows', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Edge count vs Bernoulli prediction
ax = axes[1, 1]
bernoulli_edges = [d**2 * sum(max(L - h, 0) for h in S) for d in densities]
ax.scatter(bernoulli_edges, edge_counts, c=ns, cmap='viridis', s=15, alpha=0.7)
max_val = max(max(edge_counts), max(bernoulli_edges)) + 5
ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, label='y = x')
ax.set_xlabel('Bernoulli predicted edges', fontsize=10)
ax.set_ylabel('Actual edge count', fontsize=10)
ax.set_title('Actual vs Bernoulli Edge Counts\n(color = window position)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
cbar = plt.colorbar(ax.collections[0], ax=ax, label='Window start n')

fig.suptitle('Arithmetic Discrepancy: Primes vs Random Topology\n'
             f'S = {sorted(S)}, L = {L}',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('discrepancy_scaling.png', dpi=150, bbox_inches='tight')
print("Saved discrepancy_scaling.png")
