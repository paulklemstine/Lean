#!/usr/bin/env python3
"""
Visualization 2: Composition Monotonicity (Data Processing Inequality)

Shows that entropy monotonically increases through a pipeline of functions.
Each additional composition can only increase (or maintain) the entropy,
illustrating the irreversibility of information loss.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def functorial_entropy_from_map(f_values: list, n: int) -> float:
    if n == 0:
        return 0.0
    counts = Counter(f_values)
    total = 0.0
    for x in range(n):
        fiber_size = counts[f_values[x]]
        total += math.log(fiber_size)
    return total / n


# Build several pipelines with different structures
n = 120

pipelines = {
    'Uniform reduction\n(mod k)': [
        ('mod 60', lambda x: x % 60),
        ('mod 30', lambda x: x % 30),
        ('mod 15', lambda x: x % 15),
        ('mod 5', lambda x: x % 5),
        ('mod 1', lambda x: 0),
    ],
    'Aggressive early\nloss': [
        ('mod 6', lambda x: x % 6),
        ('mod 5', lambda x: x % 5),
        ('mod 4', lambda x: x % 4),
        ('mod 3', lambda x: x % 3),
        ('mod 2', lambda x: x % 2),
    ],
    'Gradual loss\n(bitwise)': [
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
    ],
    'Mixed injective\n& lossy': [
        ('+1 (inv)', lambda x: x + 1),
        ('mod 40', lambda x: x % 40),
        ('×3 (inv)', lambda x: x * 3),
        ('mod 10', lambda x: x % 10),
        ('mod 2', lambda x: x % 2),
    ],
}

fig, ax = plt.subplots(figsize=(10, 6))
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
markers = ['o', 's', 'D', '^']

for idx, (pipe_name, stages) in enumerate(pipelines.items()):
    entropies = [0.0]  # Start with identity (H=0)
    current_values = list(range(n))

    for name, f in stages:
        current_values = [f(v) for v in current_values]
        # Compute entropy of the composed function from original domain
        composed_values = current_values  # Already the composed output
        H = functorial_entropy_from_map(composed_values, n)
        entropies.append(H)

    stages_x = list(range(len(entropies)))
    ax.plot(stages_x, entropies, color=colors[idx], marker=markers[idx],
            linewidth=2, markersize=8, label=pipe_name, alpha=0.85)

ax.axhline(y=math.log(n), color='red', linestyle=':', alpha=0.5,
           label=f'Maximum H = log({n}) = {math.log(n):.2f}')
ax.axhline(y=0, color='green', linestyle=':', alpha=0.5, label='Minimum H = 0')

ax.set_xlabel('Pipeline Stage', fontsize=13)
ax.set_ylabel('Functorial Entropy H', fontsize=13)
ax.set_title(f'Composition Monotonicity: Entropy Through Pipelines (n={n})', fontsize=14)
ax.set_xticks(range(6))
ax.set_xticklabels(['id'] + [f'Stage {i+1}' for i in range(5)])
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('composition_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved composition_monotonicity.png")
