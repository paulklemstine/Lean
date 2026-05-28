#!/usr/bin/env python3
"""
Visualization: Distribution of Graph Jacobian Orders

Shows the distribution of |Jac(G)| for random Erdős-Rényi graphs
and highlights the p-divisibility patterns predicted by Cohen-Lenstra.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def random_graph_jacobian_order(n, prob=0.5):
    """Compute |Jac(G)| for a random G(n, prob) graph."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < prob:
                adj[i, j] = 1
                adj[j, i] = 1
    degrees = np.sum(adj, axis=1)
    L = np.diag(degrees) - adj
    eigenvalues = np.linalg.eigvalsh(L.astype(float))
    if np.sum(np.abs(eigenvalues) < 1e-6) != 1:
        return None
    reduced = L[:n-1, :n-1].astype(float)
    det = abs(int(round(np.linalg.det(reduced))))
    return det if det > 0 else None


def cohen_lenstra_moment(p, k):
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


np.random.seed(123)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1 & 2: Distribution of log|Jac(G)| for n=10 and n=16
for idx, n in enumerate([10, 16]):
    ax = axes[0, idx]
    orders = []
    for _ in range(3000):
        order = random_graph_jacobian_order(n)
        if order is not None and order > 0:
            orders.append(order)

    log_orders = [np.log10(o) for o in orders if o > 0]

    ax.hist(log_orders, bins=40, density=True, alpha=0.7, color='steelblue',
            edgecolor='navy', linewidth=0.5)
    ax.set_xlabel('log₁₀ |Jac(G)|', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'G({n}, 1/2): Jacobian Order Distribution',
                 fontsize=13, fontweight='bold')

    mean_log = np.mean(log_orders)
    std_log = np.std(log_orders)
    ax.axvline(x=mean_log, color='red', linestyle='--', linewidth=2,
               label=f'Mean: {mean_log:.2f}')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

# Panel 3: p-divisibility bar chart
ax = axes[1, 0]
n = 16
orders = []
for _ in range(5000):
    order = random_graph_jacobian_order(n)
    if order is not None and order > 0:
        orders.append(order)

primes = [2, 3, 5, 7, 11]
bar_width = 0.35
x = np.arange(len(primes))

empirical_freqs = []
predicted_freqs = []
for p in primes:
    emp = sum(1 for o in orders if o % p == 0) / len(orders)
    pred = cohen_lenstra_moment(p, 1)
    empirical_freqs.append(emp)
    predicted_freqs.append(pred)

bars1 = ax.bar(x - bar_width/2, empirical_freqs, bar_width,
               label='Empirical', color='steelblue', alpha=0.8)
bars2 = ax.bar(x + bar_width/2, predicted_freqs, bar_width,
               label='Cohen-Lenstra', color='coral', alpha=0.8)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Pr[p | |Jac(G)|]', fontsize=12)
ax.set_title(f'p-Divisibility: Empirical vs. Predicted (n={n})',
             fontsize=13, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels([str(p) for p in primes])
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Panel 4: Valuation profile for a specific graph
ax = axes[1, 1]

# Use the Petersen graph
petersen_adj = np.zeros((10, 10), dtype=int)
outer = [(0,1),(1,2),(2,3),(3,4),(4,0)]
inner = [(5,7),(7,9),(9,6),(6,8),(8,5)]
spokes = [(0,5),(1,6),(2,7),(3,8),(4,9)]
for i, j in outer + inner + spokes:
    petersen_adj[i, j] = 1
    petersen_adj[j, i] = 1

petersen_order = random_graph_jacobian_order(10, 0)  # Not random
# Petersen graph has 2000 spanning trees
# Manually compute for illustration
L = np.diag(np.sum(petersen_adj, axis=1)) - petersen_adj
reduced = L[:9, :9].astype(float)
petersen_det = abs(int(round(np.linalg.det(reduced))))

# Show factorization structure
primes_to_check = [2, 3, 5, 7, 11, 13]
valuations = []
temp = petersen_det
for p in primes_to_check:
    v = 0
    t = temp
    while t > 0 and t % p == 0:
        t //= p
        v += 1
    valuations.append(v)

colors = plt.cm.Set2(np.linspace(0, 1, len(primes_to_check)))
bars = ax.bar(range(len(primes_to_check)), valuations, color=colors,
              edgecolor='black', linewidth=0.5)
ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('v_p(|Jac|)', fontsize=12)
ax.set_title(f'Petersen Graph: |Jac| = {petersen_det}\nPrime Factorization Profile',
             fontsize=13, fontweight='bold')
ax.set_xticks(range(len(primes_to_check)))
ax.set_xticklabels([str(p) for p in primes_to_check])
ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('Arithmetic Statistics of Graph Jacobians',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('jacobian_distribution.png', dpi=150, bbox_inches='tight')
print("Saved jacobian_distribution.png")
