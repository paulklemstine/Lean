"""
Visualization 3: Entropy Rigidity — Regular Graphs as Entropy Maximizers

Demonstrates the rigidity theorem: H(G) = log|V| if and only if G is regular.
Shows how perturbing a regular graph away from regularity always decreases entropy,
and how the deficit correlates with the degree variance.
"""

import math
import random
import numpy as np
import matplotlib.pyplot as plt


def degree_entropy(degrees):
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def regularity_deficit(degrees):
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


random.seed(42)
np.random.seed(42)

n = 20

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Perturbation from regularity ---
ax1 = axes[0]

# Start from a regular graph (complete graph)
K = np.ones((n, n)) - np.eye(n)
perturbation_levels = range(0, n * (n - 1) // 4, 2)
deficits = []
variances = []

for num_removals in perturbation_levels:
    adj = K.copy()
    edges = [(i, j) for i in range(n) for j in range(i + 1, n) if adj[i][j] == 1]
    random.shuffle(edges)
    for k in range(min(num_removals, len(edges))):
        i, j = edges[k]
        adj[i][j] = adj[j][i] = 0
    degrees = [int(np.sum(adj[i])) for i in range(n)]
    if sum(degrees) == 0:
        break
    deficit = regularity_deficit(degrees)
    var = np.var(degrees)
    deficits.append(deficit)
    variances.append(var)

ax1.plot(list(perturbation_levels)[:len(deficits)], deficits, 'b-o',
         markersize=4, label='Deficit D(G)')
ax1.set_xlabel('Edges removed from K₂₀', fontsize=11)
ax1.set_ylabel('Regularity deficit D(G)', fontsize=11)
ax1.set_title('Perturbation from Regularity', fontsize=12)
ax1.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='D=0 (regular)')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Deficit vs Degree Variance ---
ax2 = axes[1]

all_deficits = []
all_variances = []
all_types = []

# Generate various graphs
for _ in range(200):
    p = random.uniform(0.05, 0.95)
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    degrees = [int(np.sum(adj[i])) for i in range(n)]
    if sum(degrees) == 0:
        continue
    d = regularity_deficit(degrees)
    v = np.var(degrees)
    all_deficits.append(d)
    all_variances.append(v)

ax2.scatter(all_variances, all_deficits, c='steelblue', s=20, alpha=0.5)
ax2.set_xlabel('Degree Variance σ²', fontsize=11)
ax2.set_ylabel('Regularity Deficit D(G)', fontsize=11)
ax2.set_title('Deficit ↔ Degree Variance', fontsize=12)
ax2.grid(True, alpha=0.3)

# Add trendline
if all_variances:
    z = np.polyfit(all_variances, all_deficits, 2)
    x_fit = np.linspace(0, max(all_variances), 100)
    y_fit = np.polyval(z, x_fit)
    ax2.plot(x_fit, y_fit, 'r-', alpha=0.7, linewidth=2, label='Quadratic fit')
    ax2.legend(fontsize=9)

# --- Panel 3: Entropy bar chart for graph families ---
ax3 = axes[2]

families = []

# Complete
degrees = [n - 1] * n
families.append(('Complete\nK₂₀', degree_entropy(degrees), True))

# Cycle
degrees = [2] * n
families.append(('Cycle\nC₂₀', degree_entropy(degrees), True))

# Petersen-like (3-regular)
degrees = [3] * n
families.append(('3-Regular', degree_entropy(degrees), True))

# Dense random
adj = np.zeros((n, n))
random.seed(100)
for i in range(n):
    for j in range(i + 1, n):
        if random.random() < 0.6:
            adj[i][j] = adj[j][i] = 1
degrees = [int(np.sum(adj[i])) for i in range(n)]
families.append(('G(n,0.6)', degree_entropy(degrees), False))

# Sparse random
adj = np.zeros((n, n))
random.seed(200)
for i in range(n):
    for j in range(i + 1, n):
        if random.random() < 0.2:
            adj[i][j] = adj[j][i] = 1
degrees = [int(np.sum(adj[i])) for i in range(n)]
families.append(('G(n,0.2)', degree_entropy(degrees), False))

# Path
degrees = [1] + [2] * (n - 2) + [1]
families.append(('Path\nP₂₀', degree_entropy(degrees), False))

# Star
degrees = [n - 1] + [1] * (n - 1)
families.append(('Star\nS₂₀', degree_entropy(degrees), False))

names = [f[0] for f in families]
entropies = [f[1] for f in families]
is_reg = [f[2] for f in families]
colors = ['#2196F3' if r else '#FF9800' for r in is_reg]

bars = ax3.bar(names, entropies, color=colors, edgecolor='white', linewidth=0.5)
ax3.axhline(y=math.log(n), color='red', linestyle='--', alpha=0.7,
            label=f'log|V| = {math.log(n):.2f}')
ax3.set_ylabel('Degree Entropy H(G)', fontsize=11)
ax3.set_title('Entropy Rigidity:\nH = log|V| ⟺ Regular', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Custom legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2196F3', label='Regular'),
                   Patch(facecolor='#FF9800', label='Irregular')]
ax3.legend(handles=legend_elements + [plt.Line2D([0], [0], color='red',
           linestyle='--', label=f'log|V| = {math.log(n):.2f}')],
           fontsize=9, loc='lower left')

plt.suptitle('Entropy Rigidity: Regular Graphs as Information-Theoretic Extrema',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_rigidity.png")
