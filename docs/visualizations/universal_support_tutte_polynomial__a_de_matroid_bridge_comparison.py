#!/usr/bin/env python3
"""
Visualization: Matroid Bridge — Binary vs Non-Binary Supports

Compares the support-Tutte polynomial for binary (matroidal) supports
with their non-binary generalizations, showing that the support invariant
strictly extends classical matroid Tutte theory by detecting degree
information that matroids erase.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, Dict, List

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
        if all(v[i] > 0 for v in S):
            r = a_val * _rec(tutte_contract(S, i), remaining)
        elif any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S):
            r = _rec(support_delete(S, i), rest) + _rec(tutte_contract(S, i), rest)
        else:
            r = _rec(S, rest)
        cache[key] = r
        return r
    return _rec(S, tuple(range(n)))


# ---------------------------------------------------------------------------
# Define support families
# ---------------------------------------------------------------------------

# Binary supports (matroid-like)
binary_supports = {
    "U(1,3)": frozenset({(1,0,0), (0,1,0), (0,0,1)}),
    "U(2,3)": frozenset({(1,1,0), (1,0,1), (0,1,1)}),
    "U(2,4)": frozenset({(1,1,0,0), (1,0,1,0), (1,0,0,1),
                          (0,1,1,0), (0,1,0,1), (0,0,1,1)}),
}

# Non-binary supports (with values > 1)
nonbinary_supports = {
    "Vertices(3,2)": frozenset({(2,0,0), (0,2,0), (0,0,2)}),
    "Δ(3,2)": frozenset({(2,0,0), (0,2,0), (0,0,2),
                          (1,1,0), (1,0,1), (0,1,1)}),
    "Vertices(4,2)": frozenset({(2,0,0,0), (0,2,0,0), (0,0,2,0), (0,0,0,2)}),
}

a_values = np.linspace(-1.5, 3.0, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Binary supports
ax1 = axes[0]
colors_bin = ['#2ecc71', '#3498db', '#9b59b6']
for idx, (name, S) in enumerate(binary_supports.items()):
    values = [compute_tutte_value(S, a) for a in a_values]
    ax1.plot(a_values, values, color=colors_bin[idx], linewidth=2, label=name)

ax1.set_xlabel('Loop weight a', fontsize=11)
ax1.set_ylabel('T(a)', fontsize=11)
ax1.set_title('Binary (Matroidal) Supports', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(-20, 50)
ax1.axhline(y=0, color='k', linewidth=0.3)
ax1.axvline(x=0, color='k', linewidth=0.3)
ax1.grid(True, alpha=0.2)

# Panel 2: Non-binary supports
ax2 = axes[1]
colors_nb = ['#e74c3c', '#f39c12', '#1abc9c']
for idx, (name, S) in enumerate(nonbinary_supports.items()):
    values = [compute_tutte_value(S, a) for a in a_values]
    ax2.plot(a_values, values, color=colors_nb[idx], linewidth=2, label=name)

ax2.set_xlabel('Loop weight a', fontsize=11)
ax2.set_ylabel('T(a)', fontsize=11)
ax2.set_title('Non-Binary (Non-Matroidal) Supports', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(-20, 50)
ax2.axhline(y=0, color='k', linewidth=0.3)
ax2.axvline(x=0, color='k', linewidth=0.3)
ax2.grid(True, alpha=0.2)

# Panel 3: Comparison — same cardinality, different structure
ax3 = axes[2]

# U(1,3) vs Vertices(3,2): both have 3 elements
S_bin = binary_supports["U(1,3)"]
S_nb = nonbinary_supports["Vertices(3,2)"]

vals_bin = [compute_tutte_value(S_bin, a) for a in a_values]
vals_nb = [compute_tutte_value(S_nb, a) for a in a_values]
vals_diff = [nb - b for b, nb in zip(vals_bin, vals_nb)]

ax3.plot(a_values, vals_bin, color='#3498db', linewidth=2, label='U(1,3) — binary')
ax3.plot(a_values, vals_nb, color='#e74c3c', linewidth=2, label='Vertices(3,2) — non-binary')
ax3.fill_between(a_values, vals_bin, vals_nb, alpha=0.15, color='purple')
ax3.plot(a_values, vals_diff, color='#8e44ad', linewidth=1.5, linestyle='--',
         label='Difference')

ax3.set_xlabel('Loop weight a', fontsize=11)
ax3.set_ylabel('T(a)', fontsize=11)
ax3.set_title('Same Cardinality, Different Structure\n(3 elements each)', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_ylim(-10, 30)
ax3.axhline(y=0, color='k', linewidth=0.3)
ax3.axvline(x=0, color='k', linewidth=0.3)
ax3.grid(True, alpha=0.2)

# Add annotation
ax3.annotate('Support-Tutte\nsees the\ndifference!',
             xy=(1.5, 8), fontsize=10, ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Support-Tutte Polynomial: Binary vs. Non-Binary Supports',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('matroid_bridge.png', dpi=150, bbox_inches='tight')
print("Saved matroid_bridge.png")
