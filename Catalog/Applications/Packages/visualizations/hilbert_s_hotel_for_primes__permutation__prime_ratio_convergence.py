"""
Visualization: Prime Ratio Convergence Under Permutations
===========================================================
Shows how the ratio p_{σ(n)}/p_n behaves for different types of permutations.
For bounded displacement permutations, the ratio converges to 1.
For unbounded permutations, it may diverge.
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


N = 5000
primes = first_n_primes(N)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Prime Ratio Convergence: p_{σ(n)} / p_n", fontsize=16, fontweight='bold')

# Panel 1: Identity
ax = axes[0, 0]
ratios = [1.0] * N
ax.plot(range(N), ratios, color='#2ecc71', linewidth=0.5, alpha=0.7)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Identity Permutation (K=0)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 2: Bounded displacement K=5
ax = axes[0, 1]
perm = bounded_displacement_perm(N, 5, seed=42)
ratios = [primes[perm[i]] / primes[i] for i in range(N)]
ax.scatter(range(N), ratios, s=0.3, alpha=0.5, color='#3498db')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Bounded Displacement (K=5)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 3: Bounded displacement K=50
ax = axes[1, 0]
perm = bounded_displacement_perm(N, 50, seed=42)
ratios = [primes[perm[i]] / primes[i] for i in range(N)]
ax.scatter(range(N), ratios, s=0.3, alpha=0.5, color='#e74c3c')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Bounded Displacement (K=50)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 4: Convergence rate comparison
ax = axes[1, 1]
for K, color, label in [(1, '#2ecc71', 'K=1'), (5, '#3498db', 'K=5'), 
                         (20, '#f39c12', 'K=20'), (50, '#e74c3c', 'K=50')]:
    perm = bounded_displacement_perm(N, K, seed=42)
    ratios = [primes[perm[i]] / primes[i] for i in range(N)]
    # Rolling max deviation
    window = 100
    max_devs = []
    for i in range(window, N):
        dev = max(abs(ratios[j] - 1) for j in range(i - window, i))
        max_devs.append(dev)
    ax.plot(range(window, N), max_devs, color=color, label=label, linewidth=1, alpha=0.8)

ax.set_title("Max Deviation in Sliding Window (w=100)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("max |ratio - 1|")
ax.legend()
ax.set_yscale('log')

plt.tight_layout()
plt.savefig("viz_ratio_convergence.png", dpi=150, bbox_inches='tight')
print("Saved viz_ratio_convergence.png")
