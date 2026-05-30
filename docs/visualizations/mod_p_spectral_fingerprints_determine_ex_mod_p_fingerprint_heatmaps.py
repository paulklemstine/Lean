"""
Visualization: Mod-p Spectral Fingerprint Heatmaps

Shows how a graph Laplacian looks when reduced modulo different primes,
and how the CRT reconstruction recovers the original. Visualizes the
"fingerprint" concept: each prime reveals a different partial view of
the same integer matrix.

SELF-CONTAINED: All functions are defined inline.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial
from functools import reduce


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj


def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True


def extended_gcd(a, b):
    if a == 0: return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def crt_recover(residues, moduli):
    M = reduce(lambda a, b: a * b, moduli, 1)
    x = 0
    for r, m in zip(residues, moduli):
        Mi = M // m
        _, inv, _ = extended_gcd(Mi, m)
        x = (x + r * Mi * inv) % M
    if x > M // 2: x -= M
    return x


# Create a graph (Petersen-like)
n = 7
adj = np.zeros((n, n), dtype=int)
for i in range(n):
    adj[i, (i+1) % n] = 1
    adj[(i+1) % n, i] = 1
    adj[i, (i+3) % n] = 1
    adj[(i+3) % n, i] = 1

L = graph_laplacian(adj)

# Primes for fingerprinting
primes = [2, 3, 5, 7, 11]

fig, axes = plt.subplots(2, 4, figsize=(16, 8))
fig.suptitle('Mod-p Spectral Fingerprints of a Graph Laplacian', fontsize=16, fontweight='bold')

# Original Laplacian
ax = axes[0, 0]
im = ax.imshow(L, cmap='RdBu_r', vmin=-4, vmax=4)
ax.set_title('Original Laplacian L', fontsize=12, fontweight='bold')
ax.set_xlabel('Column')
ax.set_ylabel('Row')
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(L[i, j]), ha='center', va='center', fontsize=9)
plt.colorbar(im, ax=ax, shrink=0.8)

# Mod-p reductions
for idx, p in enumerate(primes[:3]):
    ax = axes[0, idx + 1]
    Lp = L % p
    im = ax.imshow(Lp, cmap='viridis', vmin=0, vmax=p-1)
    ax.set_title(f'L mod {p}', fontsize=12, fontweight='bold')
    ax.set_xlabel('Column')
    if idx == 0:
        ax.set_ylabel('Row')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(Lp[i, j]), ha='center', va='center',
                   fontsize=9, color='white' if Lp[i,j] > p/2 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)

# More mod-p reductions
for idx, p in enumerate(primes[3:]):
    ax = axes[1, idx]
    Lp = L % p
    im = ax.imshow(Lp, cmap='viridis', vmin=0, vmax=p-1)
    ax.set_title(f'L mod {p}', fontsize=12, fontweight='bold')
    ax.set_xlabel('Column')
    ax.set_ylabel('Row')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(Lp[i, j]), ha='center', va='center',
                   fontsize=9, color='white' if Lp[i,j] > p/2 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)

# CRT Recovered
ax = axes[1, 2]
L_rec = np.zeros_like(L)
for i in range(n):
    for j in range(n):
        residues = [int(L[i,j] % p) for p in primes]
        L_rec[i, j] = crt_recover(residues, primes)
im = ax.imshow(L_rec, cmap='RdBu_r', vmin=-4, vmax=4)
ax.set_title('CRT Recovered L', fontsize=12, fontweight='bold')
ax.set_xlabel('Column')
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(L_rec[i, j]), ha='center', va='center', fontsize=9)
plt.colorbar(im, ax=ax, shrink=0.8)

# Recovery error
ax = axes[1, 3]
error = np.abs(L - L_rec)
im = ax.imshow(error, cmap='Greens', vmin=0, vmax=1)
ax.set_title('Recovery Error |L - L_rec|', fontsize=12, fontweight='bold')
ax.set_xlabel('Column')
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(error[i, j]), ha='center', va='center', fontsize=9)
plt.colorbar(im, ax=ax, shrink=0.8)

plt.tight_layout()
plt.savefig('viz_spectral_fingerprint.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_spectral_fingerprint.png")
