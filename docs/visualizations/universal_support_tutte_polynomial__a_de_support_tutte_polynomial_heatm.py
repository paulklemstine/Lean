#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Heatmap

Visualizes the support-Tutte polynomial T(a) evaluated across a range of
loop weights for different support families (simplex lattice points of
increasing degree). The heatmap reveals how the invariant's value landscape
changes as the support structure becomes richer.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, List, Dict

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]


def support_delete(S: Support, i: int) -> Support:
    return frozenset(v for v in S if v[i] == 0)

def tutte_contract(S: Support, i: int) -> Support:
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return frozenset(result)

def compute_tutte_value(S: Support, a_val: float) -> float:
    """Compute T_S(a) at a specific numeric value of a."""
    if not S:
        return 1.0
    n = len(next(iter(S)))
    zero = tuple(0 for _ in range(n))
    if all(v == zero for v in S):
        return 1.0

    cache: Dict = {}
    def _rec(S: Support, remaining: Tuple[int, ...]) -> float:
        key = (S, remaining)
        if key in cache:
            return cache[key]
        if not S or all(v == zero for v in S) or not remaining:
            cache[key] = 1.0
            return 1.0
        i, rest = remaining[0], remaining[1:]
        if all(v[i] > 0 for v in S):  # loop
            r = a_val * _rec(tutte_contract(S, i), remaining)
        elif any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S):  # ordinary
            r = _rec(support_delete(S, i), rest) + _rec(tutte_contract(S, i), rest)
        else:  # trivial
            r = _rec(S, rest)
        cache[key] = r
        return r
    return _rec(S, tuple(range(n)))

def simplex_points(n: int, d: int) -> Support:
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


# Generate data
n_vars = 3
max_degree = 7
a_values = np.linspace(-2, 3, 100)

data = np.zeros((max_degree, len(a_values)))
labels = []

for d in range(1, max_degree + 1):
    S = simplex_points(n_vars, d)
    labels.append(f"d={d}, |S|={len(S)}")
    for j, a_val in enumerate(a_values):
        data[d - 1, j] = compute_tutte_value(S, a_val)

# Normalize for visualization (log scale for large values)
data_viz = np.sign(data) * np.log1p(np.abs(data))

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(data_viz, aspect='auto', cmap='RdBu_r',
                extent=[a_values[0], a_values[-1], max_degree + 0.5, 0.5],
                interpolation='bilinear')
ax1.set_xlabel('Loop weight a', fontsize=12)
ax1.set_ylabel('Simplex degree d', fontsize=12)
ax1.set_title('Support-Tutte Polynomial T(a)\n(sign · log(1+|T|) scale)', fontsize=13)
ax1.set_yticks(range(1, max_degree + 1))
ax1.set_yticklabels([f'd={d}' for d in range(1, max_degree + 1)])
plt.colorbar(im, ax=ax1, label='sign(T) · log(1+|T|)')

# Line plots
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 1, max_degree))
for d in range(1, max_degree + 1):
    ax2.plot(a_values, data[d - 1], color=colors[d - 1],
             linewidth=1.5, label=labels[d - 1])
ax2.set_xlabel('Loop weight a', fontsize=12)
ax2.set_ylabel('T(a)', fontsize=12)
ax2.set_title('Support-Tutte Polynomials\nfor Simplex Families Δ(3,d)', fontsize=13)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_ylim(-50, 200)
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.axvline(x=0, color='k', linewidth=0.5)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tutte_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved tutte_heatmap.png")
