"""
Visualization 1: Entropy Landscape — Degree Entropy vs. Regularity Deficit

Visualizes how different graph families occupy the entropy-deficit space.
Regular graphs sit at deficit=0 (maximum entropy), while irregular graphs
have positive deficit. The certified upper bound log(Delta/d_bar) is shown
as a boundary line.
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


def deficit_upper_bound(degrees):
    delta = max(degrees) if degrees else 0
    d_bar = sum(degrees) / len(degrees) if degrees else 0
    if d_bar <= 0 or delta == 0:
        return float('inf')
    return math.log(delta / d_bar)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


random.seed(42)
np.random.seed(42)
n = 20

# Collect data points
categories = {
    'Regular': {'H': [], 'D': [], 'color': '#2196F3', 'marker': 's'},
    'Near-regular': {'H': [], 'D': [], 'color': '#4CAF50', 'marker': 'o'},
    'Irregular': {'H': [], 'D': [], 'color': '#FF9800', 'marker': '^'},
    'Highly irregular': {'H': [], 'D': [], 'color': '#F44336', 'marker': 'D'},
}

# Complete graph (regular)
K = np.ones((n, n)) - np.eye(n)
degrees = [int(np.sum(K[i])) for i in range(n)]
categories['Regular']['H'].append(degree_entropy(degrees))
categories['Regular']['D'].append(regularity_deficit(degrees))

# Cycle (regular)
C_adj = np.zeros((n, n))
for i in range(n):
    C_adj[i][(i + 1) % n] = C_adj[(i + 1) % n][i] = 1
degrees = [int(np.sum(C_adj[i])) for i in range(n)]
categories['Regular']['H'].append(degree_entropy(degrees))
categories['Regular']['D'].append(regularity_deficit(degrees))

# Random graphs at various densities
for p in [0.6, 0.7, 0.8]:
    for _ in range(15):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Near-regular']['H'].append(degree_entropy(degrees))
        categories['Near-regular']['D'].append(regularity_deficit(degrees))

for p in [0.2, 0.3, 0.4]:
    for _ in range(15):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Irregular']['H'].append(degree_entropy(degrees))
        categories['Irregular']['D'].append(regularity_deficit(degrees))

# Star (highly irregular)
S = np.zeros((n, n))
for i in range(1, n):
    S[0][i] = S[i][0] = 1
degrees = [int(np.sum(S[i])) for i in range(n)]
categories['Highly irregular']['H'].append(degree_entropy(degrees))
categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Path
P_adj = np.zeros((n, n))
for i in range(n - 1):
    P_adj[i][i + 1] = P_adj[i + 1][i] = 1
degrees = [int(np.sum(P_adj[i])) for i in range(n)]
categories['Highly irregular']['H'].append(degree_entropy(degrees))
categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Very sparse random
for p in [0.05, 0.1]:
    for _ in range(10):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Highly irregular']['H'].append(degree_entropy(degrees))
        categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 7))

for cat, data in categories.items():
    if data['H']:
        ax.scatter(data['D'], data['H'], c=data['color'], marker=data['marker'],
                   s=80, label=cat, alpha=0.8, edgecolors='white', linewidth=0.5)

# Add log|V| line
log_n = math.log(n)
ax.axhline(y=log_n, color='gray', linestyle='--', alpha=0.5, label=f'H = log|V| = {log_n:.2f}')

# Add the bound region
D_vals = np.linspace(0, 2.5, 100)
H_bound = [log_n - D for D in D_vals]
ax.plot(D_vals, H_bound, 'k-', alpha=0.3, linewidth=2, label='H = log|V| - D(G)')

ax.set_xlabel('Regularity Deficit D(G) = log|V| - H(G)', fontsize=13)
ax.set_ylabel('Degree Entropy H(G)', fontsize=13)
ax.set_title('Entropy Landscape: Graph Families in the (Deficit, Entropy) Plane\n'
             f'n = {n} vertices', fontsize=14)
ax.legend(loc='upper right', fontsize=10)
ax.set_xlim(-0.05, 2.0)
ax.set_ylim(0, log_n + 0.3)
ax.grid(True, alpha=0.3)

# Annotate special graphs
ax.annotate('Complete K₂₀', xy=(0, log_n), fontsize=9,
            xytext=(0.3, log_n + 0.15), arrowprops=dict(arrowstyle='->', color='gray'))
ax.annotate('Star S₂₀', xy=(categories['Highly irregular']['D'][0],
            categories['Highly irregular']['H'][0]), fontsize=9,
            xytext=(1.2, 1.0), arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_entropy_landscape.png")
