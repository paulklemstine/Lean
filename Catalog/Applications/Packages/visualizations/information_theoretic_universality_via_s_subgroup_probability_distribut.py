"""
Visualization: Subgroup Probability Distributions

Shows how the index⁻² weighting creates a probability distribution
over subgroup families, and how this distribution concentrates on
low-index (large) subgroups. Compares distributions across different
groups to illustrate universality classes.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def divisors(n):
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def compute_probs(indices):
    weights = [1.0 / (i ** 2) for i in indices]
    Z = sum(weights)
    return [w / Z for w in weights]


def compute_entropy(indices):
    probs = compute_probs(indices)
    return -sum(p * math.log(p) for p in probs if p > 0)


fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Subgroup Weight Distributions and Universality Classes",
             fontsize=14, fontweight='bold')

# Row 1: Probability distributions for specific groups
groups = [
    (6, "Z/6Z"), (12, "Z/12Z"), (30, "Z/30Z"),
    (24, "Z/24Z"), (60, "Z/60Z"), (48, "Z/48Z"),
]

for ax, (n, name) in zip(axes.flat, groups):
    indices = divisors(n)
    probs = compute_probs(indices)
    H = compute_entropy(indices)
    Hmax = math.log(len(indices))

    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(indices)))
    bars = ax.bar(range(len(indices)), probs, color=colors, alpha=0.8)

    # Add uniform line
    uniform = 1.0 / len(indices)
    ax.axhline(y=uniform, color='red', linestyle='--', alpha=0.5,
               label=f'uniform = {uniform:.3f}')

    ax.set_xticks(range(len(indices)))
    ax.set_xticklabels([str(i) for i in indices], fontsize=7, rotation=45)
    ax.set_xlabel('Subgroup index [G:H]')
    ax.set_ylabel('Probability p(H)')
    ax.set_title(f'{name}: H={H:.3f}, log|S|={Hmax:.3f}')
    ax.legend(fontsize=7)

plt.tight_layout()
plt.savefig('distributions.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved distributions.png")
