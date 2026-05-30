"""
Visualization: Periodic Orbit Code Dimension Heatmap

Visualizes the code dimension dim(C(r,k,n)) for linear ECA rules across
different periods k and system sizes n. This reveals the algebraic structure
of periodic orbit varieties and the Dimension Inversion Principle.

The heatmap shows how code rate (dim/n) varies, with lighter colors indicating
higher-dimensional periodic orbit codes (more periodic orbits).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def local_rule(r, left, center, right):
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r, state):
    n = len(state)
    return [local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n])
            for i in range(n)]


def eca_iterate(r, state, k):
    s = list(state)
    for _ in range(k):
        s = eca_step(r, s)
    return s


def count_periodic(r, n, k):
    count = 0
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_iterate(r, state, k) == state:
            count += 1
    return count


def code_dim(count):
    if count <= 0:
        return 0
    return int(np.log2(max(count, 1)))


# Parameters
rules = [0, 60, 90, 102, 150, 170, 204, 240]
rule_labels = [f"Rule {r}" for r in rules]
ns = list(range(3, 12))
ks = [1, 2, 3, 4, 5]

fig, axes = plt.subplots(2, 4, figsize=(18, 9))
fig.suptitle("Periodic Orbit Code Rates for Linear ECA Rules\n"
             "Color = dim(C(r,k,n)) / n  (code rate)", fontsize=14, fontweight='bold')

for idx, r in enumerate(rules):
    ax = axes[idx // 4][idx % 4]
    data = np.zeros((len(ks), len(ns)))

    for ki, k in enumerate(ks):
        for ni, n in enumerate(ns):
            count = count_periodic(r, n, k)
            dim = code_dim(count)
            data[ki, ni] = dim / n

    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1,
                   interpolation='nearest')
    ax.set_title(f"Rule {r}", fontsize=12, fontweight='bold')
    ax.set_xlabel("System size n")
    ax.set_ylabel("Period k")
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels(ns)
    ax.set_yticks(range(len(ks)))
    ax.set_yticklabels(ks)

    # Annotate cells
    for ki in range(len(ks)):
        for ni in range(len(ns)):
            val = data[ki, ni]
            color = 'white' if val > 0.5 else 'black'
            ax.text(ni, ki, f"{val:.2f}", ha='center', va='center',
                    fontsize=7, color=color)

fig.colorbar(im, ax=axes, shrink=0.6, label="Code Rate (dim/n)")
plt.tight_layout()
plt.savefig("periodic_orbit_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved periodic_orbit_heatmap.png")
