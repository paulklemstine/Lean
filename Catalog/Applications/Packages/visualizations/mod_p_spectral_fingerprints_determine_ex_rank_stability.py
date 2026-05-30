"""
Visualization: Rank Stability and Bad Primes

Shows how the mod-p rank of integer matrices stabilizes as primes grow,
illustrating the theorem that only finitely many primes cause rank drops.

The left panel shows rank vs prime for specific matrices.
The right panel shows the cumulative count of bad primes, demonstrating
that the count plateaus (finite bad primes theorem).
"""

import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2: return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_rank(M, p):
    n = len(M)
    m = len(M[0]) if n > 0 else 0
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[rank], A[pivot_row] = A[pivot_row], A[rank]
        inv = pow(A[rank][col], p - 2, p)
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p
        rank += 1
    return rank


# Test matrices with known determinants
matrices = [
    ("det = 2·3·5·7 = 210",
     [[210, 1, 0], [0, 1, 0], [0, 0, 1]], 3),
    ("det = 2⁴·3² = 144",
     [[12, 0, 0], [0, 12, 0], [0, 0, 1]], 3),
    ("det = 2·3·5·7·11·13 = 30030",
     [[30030, 1, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]], 4),
    ("det = 7¹ = 7",
     [[7, 3], [0, 1]], 2),
]

primes = sieve_primes(200)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Rank vs prime
ax1 = axes[0]
colors = ['tab:red', 'tab:blue', 'tab:green', 'tab:orange']

for idx, (label, M, n) in enumerate(matrices):
    ranks = [mod_p_rank(M, p) for p in primes]
    ax1.scatter(primes, ranks, c=colors[idx], s=15, alpha=0.7, label=label)
    ax1.plot(primes, [n] * len(primes), color=colors[idx], linestyle='--',
             alpha=0.3, linewidth=1)

ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Rank mod p', fontsize=12)
ax1.set_title('Mod-p Rank Stabilization\n(rank drops only at prime divisors of det)', fontsize=12)
ax1.legend(fontsize=8, loc='lower right')
ax1.grid(True, alpha=0.3)

# Right: Cumulative bad primes
ax2 = axes[1]

for idx, (label, M, n) in enumerate(matrices):
    ranks = [mod_p_rank(M, p) for p in primes]
    cumulative_bad = np.cumsum([1 if r < n else 0 for r in ranks])
    ax2.plot(primes, cumulative_bad, color=colors[idx], linewidth=2,
             label=label, marker=None)

ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Cumulative # of bad primes', fontsize=12)
ax2.set_title('Cumulative Bad Primes\n(plateaus confirm finiteness theorem)', fontsize=12)
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate('Plateau = all bad\nprimes found',
             xy=(120, 4.2), fontsize=9,
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('viz_rank_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_rank_stability.png")
