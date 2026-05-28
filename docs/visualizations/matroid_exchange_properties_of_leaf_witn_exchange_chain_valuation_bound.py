"""
Visualization 3: Exchange Chain Valuation Bounds

Visualizes the key theorem: along an exchange chain from base B₁ to base B₂,
the leaf witness values stay above min(v(B₁), v(B₂)). This is the "valley
floor" property — every ridge path between two peaks stays above the lower
peak.

Shows multiple exchange chains between two fixed bases, with the valuation
floor highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import FrozenSet, Dict, Set, Tuple, List
import random

# Self-contained infrastructure
Basis = FrozenSet[int]
Polynomial = Dict[Tuple[int, ...], float]

def uniform_bases(n: int, r: int) -> Set[Basis]:
    return {frozenset(c) for c in combinations(range(n), r)}

def basis_gen_poly(bases: Set[Basis], n: int) -> Polynomial:
    poly: Polynomial = {}
    for basis in bases:
        exp = tuple(1 if i in basis else 0 for i in range(n))
        poly[exp] = poly.get(exp, 0.0) + 1.0
    return poly

def pderiv(p: Polynomial, var: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in p.items():
        if var < len(exp) and exp[var] > 0:
            ne = list(exp)
            ne[var] -= 1
            k = tuple(ne)
            result[k] = result.get(k, 0.0) + coeff * exp[var]
    return result

def lw(p: Polynomial, S: FrozenSet[int]) -> float:
    c = p
    for i in sorted(S):
        c = pderiv(c, i)
    return sum(c.values())


def find_exchange_chains(bases: Set[Basis], start: Basis, end: Basis,
                         max_chains: int = 10, max_depth: int = 10) -> List[List[Basis]]:
    """Find exchange chains from start to end using BFS."""
    from collections import deque
    chains: List[List[Basis]] = []
    queue = deque([(start, [start])])
    visited_paths: Set[Tuple[Basis, ...]] = set()

    while queue and len(chains) < max_chains:
        current, path = queue.popleft()
        if len(path) > max_depth:
            continue
        if current == end:
            chains.append(path)
            continue

        # Try all single exchanges
        for a in current - end:
            for b in end - current:
                b_new = (current - {a}) | {b}
                if b_new in bases and b_new not in path:
                    new_path = path + [b_new]
                    path_key = tuple(new_path)
                    if path_key not in visited_paths:
                        visited_paths.add(path_key)
                        queue.append((b_new, new_path))

    return chains


# Build U(3, 6) — interesting enough to have multiple chains
n, r = 6, 3
bases = uniform_bases(n, r)
p = basis_gen_poly(bases, n)
v = {b: lw(p, b) for b in bases}

# Pick two specific bases
bases_list = sorted(bases)
B_start = frozenset({0, 1, 2})
B_end = frozenset({3, 4, 5})

chains = find_exchange_chains(bases, B_start, B_end, max_chains=8, max_depth=6)

# Create figure
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))

# --- Top panel: Exchange chains with valuation floor ---
v_start = v[B_start]
v_end = v[B_end]
floor = min(v_start, v_end)

colors = plt.cm.Set2(np.linspace(0, 1, max(len(chains), 1)))

for idx, chain in enumerate(chains[:6]):
    values = [v[b] for b in chain]
    x_pos = np.arange(len(chain))
    label = f'Chain {idx+1}: ' + ' → '.join(
        '{' + ','.join(str(e) for e in sorted(b)) + '}' for b in chain
    )
    ax1.plot(x_pos, values, 'o-', color=colors[idx], linewidth=2,
             markersize=8, label=f'Chain {idx+1}', zorder=3)

# Draw floor line
if chains:
    max_len = max(len(c) for c in chains[:6])
    ax1.axhline(y=floor, color='red', linestyle='--', linewidth=2,
                label=f'Floor = min(v(B₁), v(B₂)) = {floor:.1f}', zorder=2)
    ax1.fill_between([0, max_len-1], floor, floor - 0.5,
                     color='red', alpha=0.1, zorder=1)

ax1.set_xlabel('Exchange Step', fontsize=12)
ax1.set_ylabel('Leaf Witness Value', fontsize=12)
ax1.set_title(
    f'Exchange Chains: {{0,1,2}} → {{3,4,5}} in U(3,6)\n'
    f'Valley Floor Property: All values ≥ min(v(B₁), v(B₂))',
    fontsize=13
)
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)

# --- Bottom panel: Distribution of leaf witness values ---
all_values = sorted(v.values())
unique_values = sorted(set(all_values))
counts = [all_values.count(uv) for uv in unique_values]

bars = ax2.bar(range(len(unique_values)), counts, color='steelblue',
               edgecolor='black', linewidth=0.5)
ax2.set_xticks(range(len(unique_values)))
ax2.set_xticklabels([f'{uv:.1f}' for uv in unique_values], rotation=45)
ax2.set_xlabel('Leaf Witness Value', fontsize=12)
ax2.set_ylabel('Number of Bases', fontsize=12)
ax2.set_title(f'Distribution of Leaf Witness Values\nU(3, 6): {len(bases)} bases', fontsize=13)

# Highlight the start and end values
for i, uv in enumerate(unique_values):
    if abs(uv - v_start) < 1e-10:
        bars[i].set_color('green')
        bars[i].set_edgecolor('darkgreen')
    if abs(uv - v_end) < 1e-10:
        bars[i].set_color('orange')
        bars[i].set_edgecolor('darkorange')

from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='green', edgecolor='darkgreen', label=f'B₁ = {{0,1,2}}, v = {v_start:.1f}'),
    Patch(facecolor='orange', edgecolor='darkorange', label=f'B₂ = {{3,4,5}}, v = {v_end:.1f}'),
    Patch(facecolor='steelblue', edgecolor='black', label='Other bases'),
]
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('exchange_chain.png', dpi=150, bbox_inches='tight')
print("Saved exchange_chain.png")
