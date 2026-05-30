"""
Visualization: Dimension Inversion Principle

Shows that dynamically complex ECA rules (Class 3-4) have FEWER periodic orbits
than simpler rules (Class 1-2). This is the "Dimension Inversion Principle":
algebraic complexity is inversely correlated with dynamical complexity.

The plot shows log2(|Fix_k|) / n for different Wolfram classes across system sizes.
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


rules_by_class = {
    "Class 1\n(Uniform)": ([0, 128, 32, 160], 'blue'),
    "Class 2\n(Periodic)": ([4, 36, 50, 76], 'green'),
    "Class 3\n(Chaotic)": ([30, 45, 60, 90], 'orange'),
    "Class 4\n(Complex)": ([110, 54, 106], 'red'),
}

ns = list(range(3, 11))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Dimension Inversion Principle: Complex Rules ↔ Fewer Periodic Orbits",
             fontsize=13, fontweight='bold')

for ki, k in enumerate([1, 2, 3]):
    ax = axes[ki]
    ax.set_title(f"Period k = {k}", fontsize=12)

    for cls_name, (rules, color) in rules_by_class.items():
        rates = []
        for n in ns:
            class_rates = []
            for r in rules:
                count = count_periodic(r, n, k)
                rate = np.log2(max(count, 1)) / n
                class_rates.append(rate)
            rates.append(np.mean(class_rates))

        ax.plot(ns, rates, 'o-', color=color, label=cls_name, linewidth=2,
                markersize=6)

    ax.set_xlabel("System size n", fontsize=11)
    ax.set_ylabel("Code rate  log₂|Fix_k| / n", fontsize=11)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig("dimension_inversion.png", dpi=150, bbox_inches='tight')
print("Saved dimension_inversion.png")
