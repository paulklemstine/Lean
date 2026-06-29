#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Hamming Substitution Algebra results.

Demonstrates:
1. Binary triangle-free property
2. Nonbinary triangle existence
3. Singleton bound verification
4. Additive flavor map optimization
5. Fiber connectivity counterexample
"""

import itertools
from typing import List, Tuple


def hamming_dist(u: List[int], v: List[int]) -> int:
    """Compute Hamming distance between two words."""
    return sum(1 for a, b in zip(u, v) if a != b)


def all_words(n: int, m: int) -> List[List[int]]:
    """Generate all words in H(n,m)."""
    return [list(w) for w in itertools.product(range(m), repeat=n)]


def find_triangles(n: int, m: int) -> List[Tuple[List[int], List[int], List[int]]]:
    """Find all distance-1 triangles in H(n,m)."""
    words = all_words(n, m)
    triangles = []
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            if j <= i:
                continue
            if hamming_dist(u, v) != 1:
                continue
            for k, w in enumerate(words):
                if k <= j:
                    continue
                if hamming_dist(u, w) == 1 and hamming_dist(v, w) == 1:
                    triangles.append((u, v, w))
    return triangles


def singleton_bound(n: int, m: int, d: int) -> int:
    """Compute the Singleton bound m^(n-d+1)."""
    return m ** max(n - d + 1, 0)


def additive_optimize(slot_flavors: List[List[int]]) -> Tuple[List[int], int]:
    """
    Find the optimal word for an additive flavor map.
    slot_flavors[i][j] = flavor contribution of option j at slot i.
    Returns (optimal_word, optimal_value).
    """
    optimal = [max(range(len(sf)), key=lambda j: sf[j]) for sf in slot_flavors]
    value = sum(sf[optimal[i]] for i, sf in enumerate(slot_flavors))
    return optimal, value


def brute_force_optimize(slot_flavors: List[List[int]]) -> Tuple[List[int], int]:
    """Brute-force optimization over all words."""
    n = len(slot_flavors)
    m = len(slot_flavors[0])
    best_word = None
    best_value = float('-inf')
    for w in all_words(n, m):
        value = sum(slot_flavors[i][w[i]] for i in range(n))
        if value > best_value:
            best_value = value
            best_word = w
    return best_word, best_value


def fiber(slot_flavors: List[List[int]], target: int) -> List[List[int]]:
    """Find all words with a given additive flavor value."""
    n = len(slot_flavors)
    m = len(slot_flavors[0])
    result = []
    for w in all_words(n, m):
        value = sum(slot_flavors[i][w[i]] for i in range(n))
        if value == target:
            result.append(w)
    return result


def is_fiber_connected(words: List[List[int]]) -> bool:
    """Check if a set of words is connected in the Hamming graph (distance-1 edges)."""
    if len(words) <= 1:
        return True
    # BFS
    visited = {tuple(words[0])}
    queue = [words[0]]
    word_set = {tuple(w) for w in words}
    while queue:
        current = queue.pop(0)
        for w in words:
            if tuple(w) not in visited and hamming_dist(current, w) == 1:
                visited.add(tuple(w))
                queue.append(w)
    return len(visited) == len(words)


# ============================================================
# DEMO 1: Triangle Dichotomy
# ============================================================
print("=" * 60)
print("DEMO 1: Triangle Dichotomy")
print("=" * 60)

for m in [2, 3, 4]:
    n = 3
    triangles = find_triangles(n, m)
    print(f"\nH({n},{m}): {len(triangles)} distance-1 triangles found")
    if triangles:
        u, v, w = triangles[0]
        print(f"  Example: {u}, {v}, {w}")
        print(f"  Distances: d(u,v)={hamming_dist(u,v)}, "
              f"d(v,w)={hamming_dist(v,w)}, d(u,w)={hamming_dist(u,w)}")
    else:
        print("  (Triangle-free, as predicted by binary_hamming_triangle_free)")

# ============================================================
# DEMO 2: Singleton Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Singleton Bound")
print("=" * 60)

for n, m, d in [(7, 2, 3), (4, 3, 2), (6, 4, 3), (10, 5, 4)]:
    bound = singleton_bound(n, m, d)
    print(f"\nH({n},{m}), min distance d={d}:")
    print(f"  Singleton bound: |C| ≤ {bound}")
    print(f"  = {m}^({n}-{d}+1) = {m}^{n-d+1}")

# ============================================================
# DEMO 3: Additive Optimization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Additive Flavor Map Optimization")
print("=" * 60)

# 5 slots, 4 options each
slot_flavors = [
    [3, 7, 2, 5],   # slot 0: option 1 is best
    [1, 4, 8, 6],   # slot 1: option 2 is best
    [9, 1, 3, 2],   # slot 2: option 0 is best
    [2, 5, 4, 7],   # slot 3: option 3 is best
    [6, 3, 1, 8],   # slot 4: option 3 is best
]

opt_word, opt_value = additive_optimize(slot_flavors)
bf_word, bf_value = brute_force_optimize(slot_flavors)

print(f"\nSlot flavors: {slot_flavors}")
print(f"Additive optimization (O(n·m)):  word={opt_word}, value={opt_value}")
print(f"Brute-force optimization (O(m^n)): word={bf_word}, value={bf_value}")
print(f"Results match: {opt_value == bf_value}")
print(f"Search space: {4**5} = 4^5 words (brute force) vs {5*4} = 5×4 evaluations (additive)")

# ============================================================
# DEMO 4: Fiber Connectivity Counterexample
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Fiber Connectivity Counterexample")
print("=" * 60)

# H(2,2) with f(w) = w[0] + w[1]
slot_flavors_2x2 = [[0, 1], [0, 1]]
print(f"\nH(2,2) with additive map f(w) = w[0] + w[1]:")
for t in range(3):
    fib = fiber(slot_flavors_2x2, t)
    connected = is_fiber_connected(fib)
    print(f"  Fiber f⁻¹({t}) = {fib}, connected = {connected}")

# Contrast: H(3,3) typically has connected fibers
slot_flavors_3x3 = [[0, 1, 2], [0, 1, 2], [0, 1, 2]]
print(f"\nH(3,3) with additive map f(w) = w[0] + w[1] + w[2]:")
for t in range(7):
    fib = fiber(slot_flavors_3x3, t)
    connected = is_fiber_connected(fib) if fib else True
    print(f"  Fiber f⁻¹({t}): {len(fib)} words, connected = {connected}")

# ============================================================
# DEMO 5: Substitution Path Example
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Substitution Paths (Geodesics)")
print("=" * 60)

u = [0, 1, 2, 0]
v = [2, 1, 0, 1]
d = hamming_dist(u, v)
print(f"\nFrom {u} to {v}: Hamming distance = {d}")
print(f"Minimum substitution steps needed: {d}")

# Show all geodesics
differing = [i for i in range(len(u)) if u[i] != v[i]]
print(f"Differing positions: {differing}")
print(f"Number of geodesics: {d}! = {1 if d == 0 else eval('*'.join(str(i) for i in range(1, d+1)))}")

import itertools as it
print("All geodesics:")
for perm in it.permutations(differing):
    path = [u[:]]
    current = u[:]
    for pos in perm:
        current = current[:]
        current[pos] = v[pos]
        path.append(current)
    print(f"  Order {perm}: {' → '.join(str(w) for w in path)}")

print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Singleton Bound on Code Size.

Shows how the Singleton bound m^(n-d+1) constrains the maximum number of
codewords as a function of minimum distance d.
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
matplotlib.use('Agg')


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Singleton bound vs d for fixed n, varying m
ax1 = axes[0]
n = 10
for m in [2, 3, 4, 5]:
    d_values = list(range(1, n + 1))
    bounds = [m ** max(n - d + 1, 0) for d in d_values]
    ax1.semilogy(d_values, bounds, 'o-', linewidth=2, markersize=6, label=f'm={m}')

ax1.set_xlabel('Minimum distance d', fontsize=14)
ax1.set_ylabel('Singleton bound m^(n-d+1)', fontsize=14)
ax1.set_title(f'Singleton Bound for n={n}', fontsize=16)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3, which='both')
ax1.set_xticks(range(1, n + 1))

# Right: Singleton bound surface
ax2 = axes[1]
n_max = 12
m = 3
n_vals = list(range(1, n_max + 1))
d_vals = list(range(1, n_max + 1))

data = np.zeros((len(d_vals), len(n_vals)))
for i, d in enumerate(d_vals):
    for j, n in enumerate(n_vals):
        if d <= n:
            data[i, j] = np.log10(max(m ** (n - d + 1), 1))
        else:
            data[i, j] = 0

im = ax2.imshow(data, aspect='auto', origin='lower',
                extent=[0.5, n_max + 0.5, 0.5, n_max + 0.5],
                cmap='YlOrRd')
ax2.set_xlabel('Word length n', fontsize=14)
ax2.set_ylabel('Minimum distance d', fontsize=14)
ax2.set_title(f'log₁₀(Singleton Bound) for m={m}', fontsize=16)
cbar = plt.colorbar(im, ax=ax2)
cbar.set_label('log₁₀(m^(n-d+1))', fontsize=12)

# Draw the d = n+1 line (trivial bound)
ax2.plot([0.5, n_max + 0.5], [1.5, n_max + 1.5], 'k--', linewidth=2, alpha=0.5)
ax2.text(n_max * 0.3, n_max * 0.8, 'd > n\n(vacuous)', fontsize=12, color='white',
         ha='center', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_singleton_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_singleton_bound.png")


#!/usr/bin/env python3
"""
Visualization: Triangle Dichotomy in Hamming Graphs.

Shows the sharp transition from triangle-free (m=2) to triangle-rich (m≥3)
behavior in Hamming graphs H(n,m).
"""

import itertools
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def hamming_dist(u, v):
    return sum(1 for a, b in zip(u, v) if a != b)


def count_triangles(n, m):
    words = list(itertools.product(range(m), repeat=n))
    count = 0
    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            if hamming_dist(words[i], words[j]) != 1:
                continue
            for k in range(j + 1, len(words)):
                if hamming_dist(words[i], words[k]) == 1 and hamming_dist(words[j], words[k]) == 1:
                    count += 1
    return count


# Compute triangle counts
n_values = [2, 3, 4]
m_values = [2, 3, 4, 5]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: triangle count vs m for different n
ax1 = axes[0]
for n in n_values:
    counts = []
    for m in m_values:
        if m ** n > 1000:
            counts.append(None)
        else:
            counts.append(count_triangles(n, m))
    valid = [(m, c) for m, c in zip(m_values, counts) if c is not None]
    ms, cs = zip(*valid) if valid else ([], [])
    ax1.plot(ms, cs, 'o-', linewidth=2, markersize=8, label=f'n={n}')

ax1.set_xlabel('Alphabet size m', fontsize=14)
ax1.set_ylabel('Number of distance-1 triangles', fontsize=14)
ax1.set_title('Triangle Dichotomy in H(n,m)', fontsize=16)
ax1.legend(fontsize=12)
ax1.axvline(x=2.5, color='red', linestyle='--', alpha=0.5, label='m=2→3 transition')
ax1.set_xticks(m_values)
ax1.grid(True, alpha=0.3)

# Right: bar chart for H(3,m)
ax2 = axes[1]
n = 3
triangle_counts = [count_triangles(n, m) for m in [2, 3, 4]]
colors = ['#2196F3' if m == 2 else '#FF5722' for m in [2, 3, 4]]
bars = ax2.bar([2, 3, 4], triangle_counts, color=colors, edgecolor='black', linewidth=1.5)
ax2.set_xlabel('Alphabet size m', fontsize=14)
ax2.set_ylabel('Number of triangles', fontsize=14)
ax2.set_title(f'H(3,m): Triangle Phase Transition', fontsize=16)
ax2.set_xticks([2, 3, 4])

# Annotate
for bar, count in zip(bars, triangle_counts):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
             str(count), ha='center', fontsize=14, fontweight='bold')

ax2.annotate('Triangle-free\n(binary)', xy=(2, 0), xytext=(2, max(triangle_counts)*0.4),
            ha='center', fontsize=11, color='#2196F3',
            arrowprops=dict(arrowstyle='->', color='#2196F3'))

plt.tight_layout()
plt.savefig('viz_triangle_dichotomy.png', dpi=150, bbox_inches='tight')
print("Saved viz_triangle_dichotomy.png")
