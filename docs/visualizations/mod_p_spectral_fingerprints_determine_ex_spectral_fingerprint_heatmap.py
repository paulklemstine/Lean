"""
Visualization: Spectral Fingerprint Heatmap

Visualizes the mod-p rank (spectral fingerprint) of various graph Laplacians
across different primes. Each row is a different graph, each column is a prime p.
The color intensity shows the rank drop: dark = full rank, light = rank deficient.

This reveals the arithmetic structure of graph Laplacians:
- Complete graphs K_n have rank drops at primes dividing n
- Path graphs stabilize quickly
- Cycle graphs show periodic patterns
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
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


def complete_laplacian(n):
    return [[(n if i == j else 0) - 1 for j in range(n)] for i in range(n)]


def path_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 1 if (i == 0 or i == n-1) else 2
        if i > 0: L[i][i-1] = -1
        if i < n-1: L[i][i+1] = -1
    return L


def cycle_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 2
        L[i][(i+1)%n] = -1
        L[(i+1)%n][i] = -1
    return L


# Build data
primes = sieve_primes(47)
graphs = [
    ("K₃", complete_laplacian(3), 3),
    ("K₄", complete_laplacian(4), 4),
    ("K₅", complete_laplacian(5), 5),
    ("K₆", complete_laplacian(6), 6),
    ("P₄", path_laplacian(4), 4),
    ("P₅", path_laplacian(5), 5),
    ("P₆", path_laplacian(6), 6),
    ("C₄", cycle_laplacian(4), 4),
    ("C₅", cycle_laplacian(5), 5),
    ("C₆", cycle_laplacian(6), 6),
]

data = np.zeros((len(graphs), len(primes)))
for i, (name, L, n) in enumerate(graphs):
    for j, p in enumerate(primes):
        rank = mod_p_rank(L, p)
        # Normalize: show fraction of full rank achieved
        data[i, j] = rank / n

fig, ax = plt.subplots(figsize=(14, 6))

cmap = plt.cm.RdYlGn
im = ax.imshow(data, aspect='auto', cmap=cmap, vmin=0, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=8, rotation=45)
ax.set_yticks(range(len(graphs)))
ax.set_yticklabels([g[0] for g in graphs], fontsize=10)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Graph', fontsize=12)
ax.set_title('Spectral Fingerprint Heatmap: Rank(L mod p) / dim(L)\n'
             'Green = full rank, Red = rank deficient (bad prime)', fontsize=13)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Fraction of full rank', fontsize=10)

# Annotate cells with rank values
for i, (name, L, n) in enumerate(graphs):
    for j, p in enumerate(primes):
        rank = mod_p_rank(L, p)
        color = 'white' if data[i, j] < 0.5 else 'black'
        ax.text(j, i, str(rank), ha='center', va='center',
                fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_fingerprint_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_fingerprint_heatmap.png")
