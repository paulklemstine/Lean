"""
Visualization: Tropical Channel Capacity Landscape

Visualizes how the tropical channel capacity C(d) = log(d+1) varies with
vertex degree, and shows the capacity gap between different graph families.
This illustrates the key insight that the stability constant (D+1) is the
exponential of the channel capacity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Capacity function C(d) = log(d+1)
degrees = np.arange(0, 21)
capacities = np.log(degrees + 1)

ax = axes[0]
ax.bar(degrees, capacities, color='steelblue', alpha=0.8, edgecolor='white')
ax.plot(degrees, capacities, 'ro-', markersize=4, linewidth=1.5)
ax.set_xlabel('Vertex Degree d', fontsize=12)
ax.set_ylabel('Channel Capacity C(d) = log(d+1)', fontsize=12)
ax.set_title('Tropical Channel Capacity', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.annotate('Isolated\nvertex\nC=0', xy=(0, 0), xytext=(2, 0.5),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=9, color='red')

# Panel 2: Stability constant = exp(capacity)
stability = degrees + 1

ax = axes[1]
ax.plot(capacities, stability, 'go-', markersize=6, linewidth=2, label='exp(C(d)) = d+1')
ax.fill_between(capacities, stability, alpha=0.2, color='green')
ax.set_xlabel('Channel Capacity C(d)', fontsize=12)
ax.set_ylabel('Stability Constant Δ+1 = exp(C)', fontsize=12)
ax.set_title('Capacity → Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Capacity comparison across graph families
n = 20
families = {
    'Complete K₂₀': np.ones((n, n)) - np.eye(n),
    'Cycle C₂₀': np.zeros((n, n)),
    'Star S₂₀': np.zeros((n, n)),
    'Path P₂₀': np.zeros((n, n)),
}

# Build adjacency matrices
C = families['Cycle C₂₀']
for i in range(n):
    C[i, (i+1) % n] = 1
    C[(i+1) % n, i] = 1

S = families['Star S₂₀']
for i in range(1, n):
    S[0, i] = 1
    S[i, 0] = 1

P = families['Path P₂₀']
for i in range(n - 1):
    P[i, i+1] = 1
    P[i+1, i] = 1

ax = axes[2]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for idx, (name, adj) in enumerate(families.items()):
    degs = adj.sum(axis=1).astype(int)
    caps = sorted([np.log(d + 1) for d in degs], reverse=True)
    ax.plot(range(n), caps, 'o-', color=colors[idx], label=name,
            markersize=4, linewidth=2)

ax.set_xlabel('Vertex rank', fontsize=12)
ax.set_ylabel('Per-vertex capacity', fontsize=12)
ax.set_title('Capacity Profiles by Graph Family', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_capacity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_capacity_landscape.png")
