"""
Visualization: Displacement Heatmap of Prime Permutations
============================================================
Shows the displacement |σ(n) - n| as a heatmap for various bounded
displacement permutations. The tropical norm (max displacement) is
highlighted.
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


N = 200
num_perms = 50
Ks = [1, 3, 5, 10, 20]

fig, axes = plt.subplots(1, len(Ks), figsize=(18, 5))
fig.suptitle("Displacement Heatmaps |σ(n) - n| for Bounded Displacement Permutations",
             fontsize=14, fontweight='bold')

for idx, K in enumerate(Ks):
    ax = axes[idx]
    
    # Generate multiple permutations and stack displacements
    disp_matrix = np.zeros((num_perms, N))
    for trial in range(num_perms):
        perm = bounded_displacement_perm(N, K, seed=trial)
        for i in range(N):
            disp_matrix[trial, i] = abs(perm[i] - i)
    
    im = ax.imshow(disp_matrix, aspect='auto', cmap='YlOrRd',
                   vmin=0, vmax=max(K, 1), interpolation='nearest')
    ax.set_title(f"K = {K}", fontsize=12)
    ax.set_xlabel("Position n")
    if idx == 0:
        ax.set_ylabel("Trial")
    
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

plt.tight_layout()
plt.savefig("viz_displacement_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_displacement_heatmap.png")
