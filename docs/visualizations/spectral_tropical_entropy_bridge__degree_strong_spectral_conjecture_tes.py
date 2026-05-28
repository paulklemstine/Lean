#!/usr/bin/env python3
"""
Visualization 2: Testing the Strong Spectral Conjecture

Tests the conjecture H(G) ≥ log(|V|·λ₁/Δ) across random graphs.
The certified bound uses d̄ instead of λ₁; the conjecture replaces d̄
with the spectral radius λ₁ ≥ d̄ (a STRONGER claim).

Displays empirical evidence for/against the conjecture across
different graph families and densities.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

random.seed(42)
np.random.seed(42)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


def degree_sequence(adj):
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees):
    return float(degrees.sum())


def degree_distribution(degrees):
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees):
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def spectral_radius(adj):
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


n = 50
p_values = [0.1, 0.3, 0.5, 0.7]
n_samples = 250

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

for idx, p_val in enumerate(p_values):
    ax = axes[idx // 2][idx % 2]

    entropies = []
    certified_bounds = []
    spectral_bounds = []
    counterexamples_x = []
    counterexamples_y = []

    for _ in range(n_samples):
        adj = generate_erdos_renyi(n, p_val)
        degrees = degree_sequence(adj)
        if graph_volume(degrees) == 0:
            continue

        H = shannon_entropy(degrees)
        d_bar = float(degrees.mean())
        delta = int(degrees.max())
        lam1 = spectral_radius(adj)

        if delta == 0:
            continue

        lb_cert = np.log(n * d_bar / delta)
        lb_spec = np.log(n * lam1 / delta)

        entropies.append(H)
        certified_bounds.append(lb_cert)
        spectral_bounds.append(lb_spec)

        if H < lb_spec - 1e-10:
            counterexamples_x.append(lb_spec)
            counterexamples_y.append(H)

    entropies = np.array(entropies)
    certified_bounds = np.array(certified_bounds)
    spectral_bounds = np.array(spectral_bounds)

    # Plot certified bound
    ax.scatter(certified_bounds, entropies, c='steelblue', alpha=0.3, s=12, label='Certified bound (d̄)')
    # Plot spectral bound
    ax.scatter(spectral_bounds, entropies, c='orange', alpha=0.3, s=12, label='Spectral bound (λ₁)')

    if len(counterexamples_x) > 0:
        ax.scatter(counterexamples_x, counterexamples_y, c='red', s=50, marker='x',
                   label=f'Counterexamples: {len(counterexamples_x)}', zorder=5)

    # Equality line
    lims = [min(certified_bounds.min(), spectral_bounds.min()) - 0.1,
            max(entropies.max(), spectral_bounds.max()) + 0.1]
    ax.plot(lims, lims, 'k--', linewidth=1, alpha=0.5)

    margin_cert = (entropies - certified_bounds).min()
    margin_spec = (entropies - spectral_bounds).min()

    ax.set_xlabel('Lower Bound', fontsize=11)
    ax.set_ylabel('Entropy H(G)', fontsize=11)
    ax.set_title(f'G({n}, {p_val}): min margin (cert)={margin_cert:.4f}, (spec)={margin_spec:.4f}', fontsize=12)
    ax.legend(fontsize=9, loc='upper left')

plt.suptitle('Strong Spectral Conjecture: H(G) ≥ log(|V|·λ₁/Δ)', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('spectral_conjecture.png', dpi=150, bbox_inches='tight')
print("Saved spectral_conjecture.png")
