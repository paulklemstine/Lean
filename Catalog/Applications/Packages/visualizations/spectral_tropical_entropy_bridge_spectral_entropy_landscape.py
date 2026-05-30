"""
Visualization 1: Spectral-Entropy Landscape

Visualizes the spectral-entropy bridge by showing how degree entropy H(G)
and the spectral ratio lambda_1/Delta relate across different graph families.
The bridge theorem guarantees all points lie above the log(ratio) curve.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def degree_entropy(adj):
    degrees = adj.sum(axis=1)
    total = degrees.sum()
    if total == 0:
        return 0.0
    probs = degrees / total
    nonzero = probs[probs > 0]
    return float(-np.sum(nonzero * np.log(nonzero)))


def spectral_ratio(adj):
    eigs = np.linalg.eigvalsh(adj)
    lambda1 = eigs.max()
    max_deg = adj.sum(axis=1).max()
    return lambda1 / max_deg if max_deg > 0 else 1.0


def random_graph(n, p):
    upper = np.random.random((n, n)) < p
    adj = np.triu(upper, k=1).astype(float)
    return adj + adj.T


def star_graph(n):
    adj = np.zeros((n, n))
    adj[0, 1:] = 1; adj[1:, 0] = 1
    return adj


def path_graph(n):
    adj = np.zeros((n, n))
    for i in range(n - 1):
        adj[i, i+1] = 1; adj[i+1, i] = 1
    return adj


np.random.seed(42)
n = 30

# Collect data
ratios_random = []
entropies_random = []
for _ in range(500):
    p = np.random.uniform(0.05, 0.95)
    adj = random_graph(n, p)
    if adj.sum() == 0:
        continue
    ratios_random.append(spectral_ratio(adj))
    entropies_random.append(degree_entropy(adj))

# Special graphs
special = {
    'Complete': (np.ones((n, n)) - np.eye(n)),
    'Star': star_graph(n),
    'Path': path_graph(n),
}
ratios_special = {}
entropies_special = {}
for name, adj in special.items():
    ratios_special[name] = spectral_ratio(adj)
    entropies_special[name] = degree_entropy(adj)

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 7))

# Bridge bound curve
x = np.linspace(0.01, 1.0, 200)
ax.fill_between(x, np.log(x), -5, alpha=0.15, color='red',
                label='Forbidden region (H < log(λ₁/Δ))')
ax.plot(x, np.log(x), 'r-', linewidth=2, label='Lower bound: log(λ₁/Δ)')

# Upper bound
ax.axhline(y=np.log(n), color='blue', linestyle='--', linewidth=1.5,
           label=f'Upper bound: log({n}) = {np.log(n):.2f}')

# Random graphs
ax.scatter(ratios_random, entropies_random, alpha=0.4, s=20, c='steelblue',
           label='Random G(30, p)')

# Special graphs
colors = {'Complete': 'green', 'Star': 'orange', 'Path': 'purple'}
for name in special:
    ax.scatter(ratios_special[name], entropies_special[name],
               s=150, c=colors[name], marker='D', edgecolors='black',
               linewidth=1.5, zorder=5, label=name)

ax.set_xlabel('Spectral Regularity Ratio λ₁/Δ', fontsize=13)
ax.set_ylabel('Degree Entropy H(G)', fontsize=13)
ax.set_title('Spectral-Entropy Bridge: All Graphs Above the Bound', fontsize=15)
ax.legend(loc='lower right', fontsize=10)
ax.set_xlim(0, 1.05)
ax.set_ylim(-3.5, np.log(n) + 0.5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150)
print("Saved viz_entropy_landscape.png")
