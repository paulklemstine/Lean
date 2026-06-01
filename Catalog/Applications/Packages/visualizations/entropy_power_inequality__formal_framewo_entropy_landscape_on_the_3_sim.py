#!/usr/bin/env python3
"""
Visualization: Entropy Landscape on the Probability Simplex

Shows Shannon entropy, collision entropy, and KL divergence
as functions over the probability simplex for n=3.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.tri as tri
import numpy as np
import math

def shannon_entropy(pmf):
    return -sum(p * math.log(p) if p > 0 else 0.0 for p in pmf)

def collision_entropy(pmf):
    sq_sum = sum(p ** 2 for p in pmf)
    return -math.log(sq_sum) if sq_sum > 0 else 0.0

# Generate points on the 2-simplex
N = 200
points = []
h_vals = []
h2_vals = []
ratio_vals = []

for i in range(N + 1):
    for j in range(N + 1 - i):
        k = N - i - j
        p1, p2, p3 = (i + 0.01) / (N + 0.03), (j + 0.01) / (N + 0.03), (k + 0.01) / (N + 0.03)
        total = p1 + p2 + p3
        p1, p2, p3 = p1/total, p2/total, p3/total
        pmf = [p1, p2, p3]

        h = shannon_entropy(pmf)
        h2 = collision_entropy(pmf)
        ratio = h2 / h if h > 1e-10 else 1.0

        # Barycentric to Cartesian
        x = 0.5 * (2 * p2 + p3)
        y = (math.sqrt(3) / 2) * p3

        points.append((x, y))
        h_vals.append(h)
        h2_vals.append(h2)
        ratio_vals.append(ratio)

xs = [p[0] for p in points]
ys = [p[1] for p in points]

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Shannon Entropy
triang = tri.Triangulation(xs, ys)
ax = axes[0]
tcf = ax.tricontourf(triang, h_vals, levels=20, cmap='viridis')
plt.colorbar(tcf, ax=ax, label='H(p)')
ax.set_title('Shannon Entropy H(p)', fontsize=14, fontweight='bold')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 0.95)
ax.set_aspect('equal')
ax.plot([0, 1, 0.5, 0], [0, 0, math.sqrt(3)/2, 0], 'k-', lw=1.5)
ax.annotate('max = log(3)', xy=(0.5, 0.27), fontsize=10, ha='center',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Plot 2: Collision Entropy
ax = axes[1]
tcf = ax.tricontourf(triang, h2_vals, levels=20, cmap='plasma')
plt.colorbar(tcf, ax=ax, label='H₂(p)')
ax.set_title('Collision Entropy H₂(p)', fontsize=14, fontweight='bold')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 0.95)
ax.set_aspect('equal')
ax.plot([0, 1, 0.5, 0], [0, 0, math.sqrt(3)/2, 0], 'k-', lw=1.5)
ax.annotate('H₂ ≤ H always', xy=(0.5, 0.27), fontsize=10, ha='center',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Plot 3: Ratio H₂/H
ax = axes[2]
tcf = ax.tricontourf(triang, ratio_vals, levels=20, cmap='RdYlGn')
plt.colorbar(tcf, ax=ax, label='H₂/H')
ax.set_title('Rényi-Shannon Ratio H₂/H', fontsize=14, fontweight='bold')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 0.95)
ax.set_aspect('equal')
ax.plot([0, 1, 0.5, 0], [0, 0, math.sqrt(3)/2, 0], 'k-', lw=1.5)
ax.annotate('ratio < 0.5 near\ncorners (n=3)', xy=(0.5, 0.27), fontsize=9, ha='center',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.suptitle('Information-Theoretic Landscape on the 3-Simplex', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")
