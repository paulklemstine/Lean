#!/usr/bin/env python3
"""
Visualization: Cohen-Lenstra Convergence for Graph Jacobians

Plots the empirical p-divisibility frequency of random graph Jacobians
versus the Cohen-Lenstra prediction, showing convergence as n → ∞.
This visualizes the central conjecture of the research.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def cohen_lenstra_moment(p, k):
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


def random_graph_jacobian_order(n, prob=0.5):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < prob:
                adj[i, j] = 1
                adj[j, i] = 1
    degrees = np.sum(adj, axis=1)
    L = np.diag(degrees) - adj
    reduced = L[:n-1, :n-1].astype(float)
    eigenvalues = np.linalg.eigvalsh(L.astype(float))
    if np.sum(np.abs(eigenvalues) < 1e-6) != 1:
        return None  # Not connected
    det = abs(int(round(np.linalg.det(reduced))))
    return det if det > 0 else None


np.random.seed(42)

n_values = [8, 10, 14, 18, 22]
primes = [3, 5, 7]
num_samples = 1500

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, p in enumerate(primes):
    ax = axes[idx]
    empirical_k1 = []
    empirical_k2 = []

    for n in n_values:
        orders = []
        for _ in range(num_samples):
            order = random_graph_jacobian_order(n)
            if order is not None:
                orders.append(order)

        if orders:
            freq_k1 = sum(1 for o in orders if o % p == 0) / len(orders)
            freq_k2 = sum(1 for o in orders if o % (p**2) == 0) / len(orders)
        else:
            freq_k1 = 0
            freq_k2 = 0

        empirical_k1.append(freq_k1)
        empirical_k2.append(freq_k2)

    pred_k1 = cohen_lenstra_moment(p, 1)
    pred_k2 = cohen_lenstra_moment(p, 2)

    ax.plot(n_values, empirical_k1, 'bo-', linewidth=2, markersize=8,
            label=f'Empirical (k=1)')
    ax.axhline(y=pred_k1, color='b', linestyle='--', alpha=0.7,
               label=f'CL prediction (k=1): {pred_k1:.4f}')

    ax.plot(n_values, empirical_k2, 'rs-', linewidth=2, markersize=8,
            label=f'Empirical (k=2)')
    ax.axhline(y=pred_k2, color='r', linestyle='--', alpha=0.7,
               label=f'CL prediction (k=2): {pred_k2:.4f}')

    ax.set_xlabel('Number of vertices n', fontsize=12)
    ax.set_ylabel(f'Pr[{p}^k | |Jac(G)|]', fontsize=12)
    ax.set_title(f'p = {p}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, loc='best')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, max(pred_k1, max(empirical_k1)) * 1.3)

fig.suptitle('Cohen-Lenstra Convergence for Random Graph Jacobians\n'
             f'G(n, 1/2), {num_samples} samples per point',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")
