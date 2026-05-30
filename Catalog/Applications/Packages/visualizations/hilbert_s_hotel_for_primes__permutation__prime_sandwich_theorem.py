"""
Visualization: Prime Sandwich Theorem
========================================
Illustrates the sandwich theorem: for bounded displacement K,
p_{n-K} ≤ p_{σ(n)} ≤ p_{n+K}. Shows how the permuted prime
is "sandwiched" between the (n-K)th and (n+K)th primes.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def first_n_primes(count):
    if count <= 0:
        return []
    limit = max(15, int(count * (math.log(count) + math.log(max(1, math.log(count)))) + 100))
    primes = sieve_primes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:count]


def bounded_displacement_perm(n, K, seed=42):
    rng = random.Random(seed)
    used = [False] * n
    result = [0] * n
    for i in range(n):
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        candidates = [j for j in range(lo, hi + 1) if not used[j]]
        if not candidates:
            candidates = [j for j in range(n) if not used[j]]
        choice = rng.choice(candidates)
        result[i] = choice
        used[choice] = True
    return result


N = 500
K = 10
primes = first_n_primes(N + K + 1)
perm = bounded_displacement_perm(N, K, seed=42)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
fig.suptitle(f"Prime Sandwich Theorem (Displacement Bound K={K})", 
             fontsize=16, fontweight='bold')

# Top panel: prime values with sandwich bounds
ns = list(range(K, N))
p_lower = [primes[n - K] for n in ns]
p_upper = [primes[n + K] for n in ns]
p_sigma = [primes[perm[n]] for n in ns]
p_canon = [primes[n] for n in ns]

ax1.fill_between(ns, p_lower, p_upper, alpha=0.2, color='#3498db', label='Sandwich region')
ax1.plot(ns, p_canon, color='#2c3e50', linewidth=1, label='p_n (canonical)', alpha=0.8)
ax1.plot(ns, p_sigma, '.', color='#e74c3c', markersize=1, label='p_{σ(n)} (permuted)', alpha=0.6)
ax1.set_xlabel("n", fontsize=12)
ax1.set_ylabel("Prime value", fontsize=12)
ax1.legend(fontsize=10)
ax1.set_title("Permuted primes stay within the sandwich", fontsize=12)

# Bottom panel: zoom into a region
zoom_start, zoom_end = 100, 200
ns_zoom = list(range(zoom_start, zoom_end))
p_lower_z = [primes[n - K] for n in ns_zoom]
p_upper_z = [primes[n + K] for n in ns_zoom]
p_sigma_z = [primes[perm[n]] for n in ns_zoom]
p_canon_z = [primes[n] for n in ns_zoom]

ax2.fill_between(ns_zoom, p_lower_z, p_upper_z, alpha=0.2, color='#3498db', label='Sandwich region')
ax2.plot(ns_zoom, p_canon_z, 'o-', color='#2c3e50', linewidth=1, markersize=3, label='p_n', alpha=0.8)
ax2.plot(ns_zoom, p_sigma_z, 's', color='#e74c3c', markersize=4, label='p_{σ(n)}', alpha=0.7)
ax2.plot(ns_zoom, p_lower_z, '--', color='#3498db', linewidth=0.5, alpha=0.5)
ax2.plot(ns_zoom, p_upper_z, '--', color='#3498db', linewidth=0.5, alpha=0.5)
ax2.set_xlabel("n", fontsize=12)
ax2.set_ylabel("Prime value", fontsize=12)
ax2.legend(fontsize=10)
ax2.set_title(f"Zoom: n ∈ [{zoom_start}, {zoom_end})", fontsize=12)

plt.tight_layout()
plt.savefig("viz_prime_sandwich.png", dpi=150, bbox_inches='tight')
print("Saved viz_prime_sandwich.png")
