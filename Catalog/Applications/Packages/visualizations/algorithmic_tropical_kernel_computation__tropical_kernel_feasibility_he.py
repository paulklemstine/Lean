"""
Visualization 1: Tropical Kernel Feasibility Heatmap

Visualizes the feasibility of the tropical kernel for cycle graphs C4
as a function of two edge weight parameters. Shows how weight symmetry
(degeneracy) creates regions where balanced potentials exist.

The heatmap reveals the piecewise-linear geometry of the tropical
feasibility boundary — a direct visual manifestation of the
difference-constraint structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iproduct


def wnv(w_dict, phi, i, j):
    return w_dict.get((i, j), 0) + phi[j]


def is_balanced_at(n, adj, w_dict, phi, v):
    nbrs = adj[v]
    if len(nbrs) < 2:
        return False
    values = [wnv(w_dict, phi, v, j) for j in nbrs]
    min_val = min(values)
    return sum(1 for val in values if val == min_val) >= 2


def is_in_kernel(n, adj, w_dict, phi):
    return all(is_balanced_at(n, adj, w_dict, phi, v) for v in range(n))


def brute_search(n, adj, w_dict, bound=8):
    others = list(range(1, n))
    for combo in iproduct(range(-bound, bound + 1), repeat=len(others)):
        phi = {0: 0}
        for i, v in enumerate(others):
            phi[v] = combo[i]
        if is_in_kernel(n, adj, w_dict, phi):
            return phi
    return None


# Build C4 adjacency
n = 4
adj = {0: [1, 3], 1: [0, 2], 2: [1, 3], 3: [2, 0]}

# Scan over w01 and w12, with w23=1, w30=1 fixed
w_range = np.arange(-5, 6, 1)
feasibility = np.zeros((len(w_range), len(w_range)))

for i, w01 in enumerate(w_range):
    for j, w12 in enumerate(w_range):
        w_dict = {}
        w_dict[(0, 1)] = w_dict[(1, 0)] = int(w01)
        w_dict[(1, 2)] = w_dict[(2, 1)] = int(w12)
        w_dict[(2, 3)] = w_dict[(3, 2)] = 1
        w_dict[(3, 0)] = w_dict[(0, 3)] = 1

        result = brute_search(n, adj, w_dict, bound=8)
        feasibility[j, i] = 1 if result is not None else 0

fig, ax = plt.subplots(1, 1, figsize=(8, 7))
im = ax.imshow(feasibility, extent=[w_range[0]-0.5, w_range[-1]+0.5,
               w_range[0]-0.5, w_range[-1]+0.5],
               origin='lower', cmap='RdYlGn', aspect='equal',
               interpolation='nearest')
ax.set_xlabel('Edge weight w(0,1)', fontsize=13)
ax.set_ylabel('Edge weight w(1,2)', fontsize=13)
ax.set_title('Tropical Kernel Feasibility on C₄\n(w(2,3)=1, w(3,0)=1 fixed)',
             fontsize=14)
cbar = plt.colorbar(im, ax=ax, ticks=[0, 1])
cbar.set_ticklabels(['Infeasible', 'Feasible'])

# Mark the diagonal (symmetric weights)
ax.plot(w_range, w_range, 'b--', alpha=0.5, linewidth=1.5, label='w₀₁ = w₁₂')
ax.legend(fontsize=11)
ax.set_xticks(w_range[::2])
ax.set_yticks(w_range[::2])

plt.tight_layout()
plt.savefig('tropical_kernel_heatmap.png', dpi=150)
print("Saved: tropical_kernel_heatmap.png")
