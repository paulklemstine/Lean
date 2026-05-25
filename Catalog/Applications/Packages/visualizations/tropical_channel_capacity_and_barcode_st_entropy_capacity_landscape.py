"""
Visualization: Degree Entropy vs Total Capacity

Shows the relationship between graph degree entropy H(G) and total tropical
capacity Cap(G) across random graphs of varying density. Illustrates that
capacity dominates entropy (entropy ≤ capacity) and that the gap measures
the graph's information-theoretic redundancy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def graph_degree_entropy(adj):
    """Compute H(G) = -sum p_v log p_v."""
    degrees = adj.sum(axis=1)
    total = degrees.sum()
    if total == 0:
        return 0.0
    p = degrees / total
    return -np.sum(p[p > 0] * np.log(p[p > 0]))


def total_tropical_capacity(adj):
    """Compute Cap(G) = sum log(deg(v)+1)."""
    degrees = adj.sum(axis=1).astype(int)
    return sum(np.log(d + 1) for d in degrees)


def erdos_renyi(n, p, rng):
    upper = rng.random((n, n)) < p
    adj = np.triu(upper, k=1)
    return (adj + adj.T).astype(float)


rng = np.random.RandomState(2025)
n = 50

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Entropy vs Capacity scatter
ax = axes[0]
probs = np.linspace(0.05, 0.95, 20)
for p in probs:
    entropies = []
    capacities = []
    for _ in range(30):
        G = erdos_renyi(n, p, rng)
        entropies.append(graph_degree_entropy(G))
        capacities.append(total_tropical_capacity(G))
    ax.scatter(capacities, entropies, alpha=0.3, s=10,
               color=plt.cm.viridis(p), label=f'p={p:.2f}' if p in [0.05, 0.5, 0.95] else '')

ax.plot([0, max(capacities)*1.1], [0, max(capacities)*1.1], 'r--',
        linewidth=2, label='H = Cap (equality)')
ax.set_xlabel('Total Capacity Cap(G)', fontsize=12)
ax.set_ylabel('Degree Entropy H(G)', fontsize=12)
ax.set_title('Entropy ≤ Capacity\n(colored by edge density p)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Capacity ratio for Erdos-Renyi
ax = axes[1]
c_values = np.linspace(1.5, 15, 30)
mean_ratios = []
std_ratios = []

for c in c_values:
    p_val = c / n
    ratios = []
    for _ in range(50):
        G = erdos_renyi(n, p_val, rng)
        cap = total_tropical_capacity(G)
        ratio = cap / (n * np.log(c)) if c > 1 else 0
        ratios.append(ratio)
    mean_ratios.append(np.mean(ratios))
    std_ratios.append(np.std(ratios))

ax.errorbar(c_values, mean_ratios, yerr=std_ratios, fmt='o-',
            color='steelblue', markersize=4, capsize=3)
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Predicted = 1')
ax.set_xlabel('Average degree c', fontsize=12)
ax.set_ylabel('Cap(G) / (n·log(c))', fontsize=12)
ax.set_title('Erdős-Rényi Capacity Conjecture\nG(50, c/50)', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.8, 1.3)

# Panel 3: Capacity gap heatmap
ax = axes[2]
D_vals = np.arange(1, 21)
delta_vals = np.arange(0, 20)
gap_matrix = np.zeros((20, 20))

for i, D in enumerate(D_vals):
    for j, delta in enumerate(delta_vals):
        if delta <= D:
            gap_matrix[j, i] = np.log((D + 1) / (delta + 1))
        else:
            gap_matrix[j, i] = np.nan

im = ax.imshow(gap_matrix, aspect='auto', origin='lower',
               cmap='YlOrRd', interpolation='nearest')
ax.set_xlabel('Max degree Δ', fontsize=12)
ax.set_ylabel('Min degree δ', fontsize=12)
ax.set_title('Capacity Gap\nlog((Δ+1)/(δ+1))', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='Gap (nats)')

plt.tight_layout()
plt.savefig('entropy_capacity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: entropy_capacity_landscape.png")
