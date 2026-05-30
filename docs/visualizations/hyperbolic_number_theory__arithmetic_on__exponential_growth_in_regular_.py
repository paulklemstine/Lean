#!/usr/bin/env python3
"""
Visualization 3: Exponential Growth in Hyperbolic Space

Compares the polynomial growth of Euclidean balls with the exponential
growth of hyperbolic balls (modeled as regular tree balls). This is the
key geometric distinction that drives the entire theory of hyperbolic
number theory.
"""

import numpy as np
import matplotlib.pyplot as plt

def tree_sphere(q, k):
    """Vertices at distance k in (q+1)-regular tree."""
    if k == 0:
        return 1
    return (q + 1) * q ** (k - 1)

def tree_ball(q, n):
    """Total vertices within distance n."""
    return sum(tree_sphere(q, k) for k in range(n + 1))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Euclidean vs Hyperbolic growth
ax = axes[0]
n_vals = np.arange(0, 12)

# Euclidean ball volumes (d-dimensional, normalized)
for d, color, label in [(1, 'blue', 'Euclidean d=1'), 
                          (2, 'green', 'Euclidean d=2'),
                          (3, 'cyan', 'Euclidean d=3')]:
    eucl = n_vals ** d
    ax.plot(n_vals, eucl, '--', color=color, label=label, linewidth=1.5)

# Hyperbolic ball sizes
for q, color, label in [(2, 'red', 'Hyperbolic q=2'),
                          (3, 'orange', 'Hyperbolic q=3'),
                          (5, 'purple', 'Hyperbolic q=5')]:
    hyp = [tree_ball(q, n) for n in n_vals]
    ax.plot(n_vals, hyp, '-o', color=color, label=label, markersize=4, linewidth=2)

ax.set_xlabel('Radius n', fontsize=12)
ax.set_ylabel('Volume / Ball size', fontsize=12)
ax.set_title('Euclidean vs Hyperbolic Growth', fontsize=14)
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.set_ylim(0.5, 1e8)

# Panel 2: Growth bound verification
ax = axes[1]
q = 3
n_vals2 = np.arange(0, 15)
balls = [tree_ball(q, n) for n in n_vals2]
bounds = [q**n for n in n_vals2]

ax.fill_between(n_vals2, bounds, balls, alpha=0.3, color='green', label='Gap')
ax.plot(n_vals2, balls, 'ro-', label=f'treeBall({q}, n)', markersize=5, linewidth=2)
ax.plot(n_vals2, bounds, 'b^--', label=f'{q}^n (lower bound)', markersize=5, linewidth=1.5)
ax.set_xlabel('Radius n', fontsize=12)
ax.set_ylabel('Size (log scale)', fontsize=12)
ax.set_title(f'Growth Bound: {q}^n ≤ treeBall({q}, n)', fontsize=14)
ax.legend(fontsize=9)
ax.set_yscale('log')

# Panel 3: Sphere sizes (local growth rate)
ax = axes[2]
n_vals3 = np.arange(0, 12)

for q, color in [(2, 'red'), (3, 'blue'), (4, 'green'), (5, 'purple')]:
    spheres = [tree_sphere(q, k) for k in n_vals3]
    ax.plot(n_vals3, spheres, 'o-', color=color, label=f'q={q} ({q+1}-regular)', 
            markersize=4, linewidth=1.5)

ax.set_xlabel('Distance k from root', fontsize=12)
ax.set_ylabel('Sphere size S(k)', fontsize=12)
ax.set_title('Sphere Sizes in Regular Trees', fontsize=14)
ax.legend(fontsize=9)
ax.set_yscale('log')

plt.tight_layout()
plt.savefig('viz_tree_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_tree_growth.png")
