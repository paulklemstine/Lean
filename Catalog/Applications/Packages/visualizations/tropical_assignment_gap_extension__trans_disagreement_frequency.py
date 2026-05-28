"""
Visualization 2: Disagreement Frequency vs Matrix Size

Tests the falsifiable conjecture: for random symmetric Gaussian matrices
with varying diagonal boost, the probability that a long cycle beats all
transpositions decreases. Under strict diagonal dominance (large boost),
it drops to zero — as proved by the theorem.

Self-contained — all functions inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def perm_weight(W, sigma):
    return sum(W[i, sigma[i]] for i in range(len(sigma)))


def is_identity(sigma):
    return all(sigma[i] == i for i in range(len(sigma)))


def is_transposition(sigma):
    moved = [i for i in range(len(sigma)) if sigma[i] != i]
    if len(moved) != 2:
        return False
    a, b = moved
    return sigma[a] == b and sigma[b] == a


def find_best_competitor(W):
    n = W.shape[0]
    best_perm = None
    best_weight = -np.inf
    for perm in permutations(range(n)):
        perm = list(perm)
        if is_identity(perm):
            continue
        w = perm_weight(W, perm)
        if w > best_weight:
            best_weight = w
            best_perm = perm
    return best_perm, best_weight


# Parameters
sizes = [3, 4, 5, 6]
boosts = [0.0, 0.5, 1.0, 2.0, 4.0, 8.0]
N_trials = 300
np.random.seed(2024)

# Collect data
results = {}
for boost in boosts:
    results[boost] = {}
    for n in sizes:
        disagreements = 0
        for _ in range(N_trials):
            G = np.random.randn(n, n)
            W = (G + G.T) / 2 + boost * np.eye(n)
            best_perm, _ = find_best_competitor(W)
            if not is_transposition(best_perm):
                disagreements += 1
        results[boost][n] = disagreements / N_trials

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Left panel: disagreement vs n for each boost
colors = plt.cm.viridis(np.linspace(0, 0.9, len(boosts)))
for idx, boost in enumerate(boosts):
    rates = [results[boost][n] for n in sizes]
    ax1.plot(sizes, rates, 'o-', color=colors[idx], linewidth=2,
             markersize=8, label=f'boost={boost:.1f}')

ax1.set_xlabel('Matrix size n', fontsize=12)
ax1.set_ylabel('P(best competitor is NOT a transposition)', fontsize=11)
ax1.set_title('Disagreement Frequency vs Matrix Size', fontsize=13,
              fontweight='bold')
ax1.legend(fontsize=9)
ax1.set_ylim(-0.02, 0.55)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5, linewidth=1)

# Right panel: disagreement vs boost for each n
colors2 = plt.cm.Set1(np.linspace(0, 0.6, len(sizes)))
for idx, n in enumerate(sizes):
    rates = [results[boost][n] for boost in boosts]
    ax2.plot(boosts, rates, 's-', color=colors2[idx], linewidth=2,
             markersize=8, label=f'n={n}')

ax2.set_xlabel('Diagonal boost', fontsize=12)
ax2.set_ylabel('P(best competitor is NOT a transposition)', fontsize=11)
ax2.set_title('Transposition Dominance vs Diagonal Boost', fontsize=13,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(-0.02, 0.55)
ax2.grid(True, alpha=0.3)

# Add annotation for the theorem
ax2.annotate('Theorem guarantees\n0% here',
            xy=(4, 0.01), xytext=(5, 0.15),
            fontsize=10, color='red', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

plt.suptitle('Falsifiable Conjecture: Long Cycles vs Transpositions\nin Random Assignment Problems',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_disagreement.png', dpi=150, bbox_inches='tight')
plt.close()
