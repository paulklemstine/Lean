#!/usr/bin/env python3
"""
Visualization: Expansion Landscape — Fingerprint vs Spectral Gap

Plots the relationship between mod-p fingerprint features and the true
spectral gap across a family of graphs. This tests the core conjecture:
do fingerprints predict expansion?

The visualization generates many random graphs, computes both their
fingerprints and spectral gaps, and plots the correlation.

WHY THIS MATTERS: If fingerprint features strongly predict spectral gap,
it validates the paradigm of using cheap finite-field algebra to infer
expensive real spectral data.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.cm as cm


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


def random_graph_laplacian(n, edge_prob, seed):
    rng = np.random.RandomState(seed)
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < edge_prob:
                A[i, j] = A[j, i] = 1
    D = np.diag(A.sum(axis=1))
    return D - A


def fingerprint_features(L, prime_bound=13, degree_bound=4):
    """Extract scalar features from fingerprint for plotting."""
    primes = sieve_primes(prime_bound)
    features = []
    for p in primes:
        for k in range(1, degree_bound + 1):
            features.append(mod_p_trace_pow(L, p, k) / p)
    return np.array(features)


def spectral_gap(L):
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    pos = [e for e in eigs if e > 1e-10]
    return pos[0] if pos else 0.0


# Generate random graphs
n = 12
num_graphs = 200
edge_probs = np.linspace(0.1, 0.9, num_graphs)
rng_seeds = range(1000, 1000 + num_graphs)

gaps = []
fp_norms = []
fp_means = []
fp_entropies = []
labels = []

for idx, (ep, seed) in enumerate(zip(edge_probs, rng_seeds)):
    L = random_graph_laplacian(n, ep, seed)
    g = spectral_gap(L)
    fp = fingerprint_features(L)

    gaps.append(g)
    fp_norms.append(np.linalg.norm(fp))
    fp_means.append(np.mean(fp))

    # Entropy of fingerprint (treating as probability distribution)
    fp_pos = fp + 0.01  # avoid log(0)
    fp_prob = fp_pos / fp_pos.sum()
    entropy = -np.sum(fp_prob * np.log2(fp_prob))
    fp_entropies.append(entropy)

gaps = np.array(gaps)
fp_norms = np.array(fp_norms)
fp_means = np.array(fp_means)
fp_entropies = np.array(fp_entropies)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Expansion Landscape: Fingerprint Features vs Spectral Gap",
             fontsize=15, fontweight='bold')

# Panel 1: Fingerprint L2 norm vs spectral gap
ax1 = axes[0, 0]
scatter = ax1.scatter(fp_norms, gaps, c=edge_probs, cmap='coolwarm',
                      s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax1.set_xlabel("Fingerprint L² norm", fontsize=11)
ax1.set_ylabel("Spectral gap λ₁", fontsize=11)
ax1.set_title("Fingerprint Norm vs Spectral Gap")
plt.colorbar(scatter, ax=ax1, label="Edge probability")
ax1.grid(True, alpha=0.3)

# Correlation
corr = np.corrcoef(fp_norms, gaps)[0, 1]
ax1.text(0.05, 0.95, f"r = {corr:.3f}", transform=ax1.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 2: Fingerprint mean vs spectral gap
ax2 = axes[0, 1]
scatter2 = ax2.scatter(fp_means, gaps, c=edge_probs, cmap='coolwarm',
                       s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax2.set_xlabel("Fingerprint mean value", fontsize=11)
ax2.set_ylabel("Spectral gap λ₁", fontsize=11)
ax2.set_title("Mean Fingerprint vs Spectral Gap")
plt.colorbar(scatter2, ax=ax2, label="Edge probability")
ax2.grid(True, alpha=0.3)

corr2 = np.corrcoef(fp_means, gaps)[0, 1]
ax2.text(0.05, 0.95, f"r = {corr2:.3f}", transform=ax2.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 3: Spectral gap vs edge probability (showing phase transition)
ax3 = axes[1, 0]
ax3.scatter(edge_probs, gaps, c=fp_norms, cmap='viridis',
            s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax3.set_xlabel("Edge probability", fontsize=11)
ax3.set_ylabel("Spectral gap λ₁", fontsize=11)
ax3.set_title("Spectral Gap vs Graph Density\n(color = fingerprint norm)")
ax3.axvline(x=np.log(n)/n, color='red', linestyle='--', alpha=0.5,
            label=f'Connectivity threshold ≈ {np.log(n)/n:.2f}')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Fingerprint entropy vs spectral gap
ax4 = axes[1, 1]
scatter4 = ax4.scatter(fp_entropies, gaps, c=edge_probs, cmap='coolwarm',
                       s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax4.set_xlabel("Fingerprint entropy (bits)", fontsize=11)
ax4.set_ylabel("Spectral gap λ₁", fontsize=11)
ax4.set_title("Fingerprint Entropy vs Spectral Gap")
plt.colorbar(scatter4, ax=ax4, label="Edge probability")
ax4.grid(True, alpha=0.3)

corr4 = np.corrcoef(fp_entropies, gaps)[0, 1]
ax4.text(0.05, 0.95, f"r = {corr4:.3f}", transform=ax4.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig("expansion_landscape.png", dpi=150, bbox_inches='tight')
print("Saved expansion_landscape.png")
