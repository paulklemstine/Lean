"""
Visualization: Certificate Complexity Phase Transition

Visualizes the sharp phase transition in certificate complexity (lower bound via
log₂(spanning tree count)) as a function of the threshold ratio k = p / (ln(n)/n)
for random graphs G(n, p). The predicted phase transition at k = 1 coincides with
the Erdős–Rényi connectivity threshold.

This demonstrates the central conjecture: certificate complexity transitions from
polynomial to exponential at exactly the connectivity threshold.
"""

import numpy as np
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def laplacian_matrix(n, edges):
    A = np.zeros((n, n), dtype=float)
    for u, v in edges:
        A[u][v] = 1.0
        A[v][u] = 1.0
    D = np.diag(A.sum(axis=1))
    return D - A


def spanning_tree_count(n, edges):
    if n <= 1:
        return 1.0
    L = laplacian_matrix(n, edges)
    L_reduced = L[1:, 1:]
    det = np.linalg.det(L_reduced)
    return max(0.0, det)


def generate_gnp(n, p, rng):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def is_connected(n, edges):
    if n <= 1:
        return True
    adj = {i: [] for i in range(n)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)
    visited = {0}
    queue = [0]
    while queue:
        node = queue.pop(0)
        for nb in adj[node]:
            if nb not in visited:
                visited.add(nb)
                queue.append(nb)
    return len(visited) == n


# Run experiments
rng = np.random.default_rng(42)
n_values = [10, 20, 30, 50]
k_values = np.concatenate([
    np.linspace(0.2, 0.85, 6),
    np.linspace(0.9, 1.15, 10),
    np.linspace(1.2, 3.0, 8)
])
num_trials = 40

results = {}
for n in n_values:
    p_star = math.log(n) / n
    data = []
    for k in k_values:
        p = min(k * p_star, 1.0)
        log_taus = []
        conn_rates = []
        for _ in range(num_trials):
            edges = generate_gnp(n, p, rng)
            tau = spanning_tree_count(n, edges)
            log_taus.append(math.log2(tau) if tau > 1e-10 else 0.0)
            conn_rates.append(1.0 if is_connected(n, edges) else 0.0)
        data.append((k, np.mean(log_taus), np.mean(conn_rates)))
    results[n] = data

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(15, 6))
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

# Left: Certificate complexity
ax = axes[0]
for idx, n in enumerate(n_values):
    ks = [d[0] for d in results[n]]
    means = [d[1] for d in results[n]]
    # Normalize by n for comparison
    normalized = [m / n for m in means]
    ax.plot(ks, normalized, 'o-', color=colors[idx], label=f'n = {n}',
            markersize=4, linewidth=2, alpha=0.8)

ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2.5, alpha=0.6,
           label='k = 1 (predicted threshold)')
ax.fill_betweenx([0, 10], 0, 1.0, alpha=0.05, color='blue')
ax.fill_betweenx([0, 10], 1.0, 4, alpha=0.05, color='red')
ax.set_xlabel('Threshold ratio k  (p = k · ln(n)/n)', fontsize=13)
ax.set_ylabel('E[log₂(τ(G))] / n  (normalized cert complexity bound)', fontsize=12)
ax.set_title('Certificate Complexity Phase Transition', fontsize=15, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 3.1)
ax.set_ylim(bottom=-0.1)
ax.text(0.4, ax.get_ylim()[1] * 0.85, 'POLYNOMIAL\nREGIME', fontsize=11,
        ha='center', color='#1565C0', alpha=0.5, fontweight='bold')
ax.text(2.0, ax.get_ylim()[1] * 0.85, 'EXPONENTIAL\nREGIME', fontsize=11,
        ha='center', color='#C62828', alpha=0.5, fontweight='bold')

# Right: Connectivity
ax = axes[1]
for idx, n in enumerate(n_values):
    ks = [d[0] for d in results[n]]
    conns = [d[2] for d in results[n]]
    ax.plot(ks, conns, 's-', color=colors[idx], label=f'n = {n}',
            markersize=4, linewidth=2, alpha=0.8)

ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2.5, alpha=0.6,
           label='k = 1 (Erdős–Rényi threshold)')
ax.set_xlabel('Threshold ratio k  (p = k · ln(n)/n)', fontsize=13)
ax.set_ylabel('P(G(n,p) is connected)', fontsize=12)
ax.set_title('Connectivity Phase Transition', fontsize=15, fontweight='bold')
ax.legend(fontsize=11, loc='center right')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 3.1)
ax.set_ylim(-0.05, 1.05)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Phase transition plot saved to phase_transition.png")
