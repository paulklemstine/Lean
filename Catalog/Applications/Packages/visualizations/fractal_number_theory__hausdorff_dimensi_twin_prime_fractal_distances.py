"""
Visualization 3: Twin Prime Fractal Distances
================================================
Shows how twin prime pairs cluster in the fractal metric, with
fractal distance d(p, p+2) decaying as ~1/log²(p). Compares
actual distances to the theoretical bound.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


def prime_fractal_dist(p, q):
    return abs(log_embed(p) - log_embed(q))


N = 100000
primes = sieve_primes(N)
prime_set = set(primes)
twins = [(p, p+2) for p in primes if p+2 in prime_set]

twin_ps = [p for p, _ in twins]
twin_dists = [prime_fractal_dist(p, p+2) for p, _ in twins]
bounds = [1.0 / math.log(p)**2 for p in twin_ps]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Panel 1: Twin prime distances vs p
ax = axes[0, 0]
ax.scatter(twin_ps, twin_dists, s=8, alpha=0.5, c='#3498db', label='d(p, p+2)')
x = np.linspace(3, N, 1000)
ax.plot(x, 1.0 / np.log(x)**2, 'r-', linewidth=2, alpha=0.8, label='1/log²(p) bound')
ax.set_xlabel('Twin prime p', fontsize=12)
ax.set_ylabel('Fractal distance', fontsize=12)
ax.set_title('Twin Prime Fractal Distance', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Ratio d(p,p+2) / (1/log²(p))
ax = axes[0, 1]
ratios = [d / b for d, b in zip(twin_dists, bounds)]
ax.scatter(twin_ps, ratios, s=8, alpha=0.5, c='#2ecc71')
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, alpha=0.6, label='ratio = 1')
ax.set_xlabel('Twin prime p', fontsize=12)
ax.set_ylabel('d(p,p+2) / (1/log²(p))', fontsize=12)
ax.set_title('Distance / Bound Ratio (should be < 1)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.2)

# Panel 3: Distribution of fractal distances
ax = axes[1, 0]
ax.hist(twin_dists, bins=50, color='#9b59b6', alpha=0.7, edgecolor='white')
ax.set_xlabel('Fractal distance d(p, p+2)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Distribution of Twin Prime Fractal Distances', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 4: Consecutive prime distances (all) vs twin prime distances
ax = axes[1, 1]
consec_dists = [prime_fractal_dist(primes[i], primes[i+1])
                for i in range(len(primes) - 1)]
ax.hist(consec_dists, bins=80, color='#3498db', alpha=0.5,
        edgecolor='white', label='All consecutive', density=True)
ax.hist(twin_dists, bins=40, color='#e74c3c', alpha=0.5,
        edgecolor='white', label='Twin primes', density=True)
ax.set_xlabel('Fractal distance', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Consecutive vs Twin Prime Distances', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle(f'Twin Prime Fractal Analysis (primes up to {N:,})',
             fontsize=16, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_twin_prime_fractal.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_twin_prime_fractal.png")
