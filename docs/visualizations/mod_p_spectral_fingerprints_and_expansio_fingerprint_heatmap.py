#!/usr/bin/env python3
"""
Visualization: Mod-p Spectral Fingerprint Heatmaps

Visualizes the prime spectral fingerprint of several graphs as heatmaps.
Each heatmap shows tr(A^k) mod p for primes p (rows) and powers k (columns).
This makes the arithmetic structure of the fingerprint visually apparent:
- Expanders show uniform, rapidly mixing patterns
- Non-expanders show structured, slowly varying patterns

WHAT IT VISUALIZES: The core data structure of the theory — how mod-p
trace data varies across primes and powers for different graph families.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def sieve_primes(bound):
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def mod_p_trace_pow(A, p, k):
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def cycle_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i+1) % n] = -1
        L[(i+1) % n, i] = -1
    return L


def complete_laplacian(n):
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


def path_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n-1):
        L[i, i] += 1; L[i+1, i+1] += 1
        L[i, i+1] = -1; L[i+1, i] = -1
    return L


def petersen_laplacian():
    edges = [(0,1),(1,2),(2,3),(3,4),(4,0),(5,7),(7,9),(9,6),(6,8),(8,5),
             (0,5),(1,6),(2,7),(3,8),(4,9)]
    A = np.zeros((10,10), dtype=int)
    for i,j in edges:
        A[i,j] = A[j,i] = 1
    return np.diag(A.sum(axis=1)) - A


def compute_fingerprint_matrix(L, prime_bound, degree_bound):
    primes = sieve_primes(prime_bound)
    data = np.zeros((len(primes), degree_bound), dtype=int)
    for i, p in enumerate(primes):
        for k in range(1, degree_bound + 1):
            data[i, k-1] = mod_p_trace_pow(L, p, k)
    return data, primes


# Build graphs
n = 10
graphs = {
    f"Cycle C_{n}": cycle_laplacian(n),
    f"Complete K_{n}": complete_laplacian(n),
    f"Path P_{n}": path_laplacian(n),
    "Petersen": petersen_laplacian(),
}

prime_bound = 19
degree_bound = 8
primes = sieve_primes(prime_bound)

fig = plt.figure(figsize=(16, 10))
fig.suptitle("Mod-p Spectral Fingerprints of Graph Laplacians",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

for idx, (name, L) in enumerate(graphs.items()):
    ax = fig.add_subplot(gs[idx])
    data, used_primes = compute_fingerprint_matrix(L, prime_bound, degree_bound)

    # Normalize each row by the prime for better visualization
    norm_data = np.zeros_like(data, dtype=float)
    for i, p in enumerate(used_primes):
        norm_data[i] = data[i] / p

    im = ax.imshow(norm_data, aspect='auto', cmap='viridis',
                   interpolation='nearest', vmin=0, vmax=1)

    ax.set_xlabel("Power k", fontsize=11)
    ax.set_ylabel("Prime p", fontsize=11)
    ax.set_xticks(range(degree_bound))
    ax.set_xticklabels(range(1, degree_bound + 1))
    ax.set_yticks(range(len(used_primes)))
    ax.set_yticklabels(used_primes)

    # Compute spectral gap
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    gap = next((e for e in eigs if e > 1e-10), 0)
    ax.set_title(f"{name}\nSpectral gap = {gap:.4f}", fontsize=12)

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label="tr(L^k)/p mod 1")

fig.text(0.5, 0.01,
         "Each cell shows tr(L^k) mod p, normalized by p. "
         "Expanders (K₁₀) show uniform patterns; non-expanders (paths, cycles) show structure.",
         ha='center', fontsize=10, style='italic')

plt.savefig("fingerprint_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved fingerprint_heatmap.png")
