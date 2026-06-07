#!/usr/bin/env python3
"""
Semantic Isomorphism Theory — Interactive Demonstrations

Demonstrates the core concepts:
1. Semantic equivalence detection via histogram invariants
2. Semantic distance computation between colorings
3. Chromatic stabilizer computation
"""

from itertools import permutations
from collections import Counter
from typing import Callable, List, Tuple, Dict


def coloring_histogram(coloring: List[int]) -> Dict[int, int]:
    """Compute the color histogram (multiset of color values)."""
    return dict(Counter(coloring))


def are_semantically_equivalent(c1: List[int], c2: List[int]) -> Tuple[bool, list]:
    """
    Check if two colorings are semantically equivalent.
    Returns (is_equivalent, witnessing_permutation_or_empty).
    """
    n = len(c1)
    assert len(c2) == n, "Colorings must have same length"

    # Quick check: histograms must match
    if coloring_histogram(c1) != coloring_histogram(c2):
        return False, []

    # Enumerate all permutations (brute force for small n)
    for perm in permutations(range(n)):
        if all(c1[i] == c2[perm[i]] for i in range(n)):
            return True, list(perm)

    return False, []


def semantic_distance(c1: List[int], c2: List[int]) -> int:
    """
    Compute the semantic distance: minimum disagreements over all permutations.
    """
    n = len(c1)
    assert len(c2) == n

    min_disagreements = n  # upper bound
    for perm in permutations(range(n)):
        disagreements = sum(1 for i in range(n) if c1[i] != c2[perm[i]])
        min_disagreements = min(min_disagreements, disagreements)
        if min_disagreements == 0:
            break

    return min_disagreements


def chromatic_stabilizer(coloring: List[int]) -> List[Tuple[int, ...]]:
    """
    Compute the chromatic stabilizer: all permutations preserving the coloring.
    """
    n = len(coloring)
    stabilizer = []
    for perm in permutations(range(n)):
        if all(coloring[perm[i]] == coloring[i] for i in range(n)):
            stabilizer.append(perm)
    return stabilizer


def semantic_equivalence_classes(n: int, num_colors: int) -> List[List[Tuple[int, ...]]]:
    """
    Partition all colorings of {0,...,n-1} with `num_colors` colors
    into semantic equivalence classes.
    """
    from itertools import product as cart_product

    all_colorings = list(cart_product(range(num_colors), repeat=n))
    visited = set()
    classes = []

    for coloring in all_colorings:
        if coloring in visited:
            continue
        # Find the orbit of this coloring under all permutations
        orbit = set()
        for perm in permutations(range(n)):
            permuted = tuple(coloring[perm[i]] for i in range(n))
            orbit.add(permuted)
        classes.append(sorted(orbit))
        visited.update(orbit)

    return classes


# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 1: The Semantic Gap
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("DEMONSTRATION 1: The Semantic Gap Theorem")
print("=" * 70)

c1 = [0, 0, 1]  # "mostly off" — two 0s, one 1
c2 = [0, 1, 1]  # "mostly on"  — one 0, two 1s

print(f"\nColoring 1 (gapColor₁): {c1}")
print(f"Coloring 2 (gapColor₂): {c2}")
print(f"\nHistogram of c1: {coloring_histogram(c1)}")
print(f"Histogram of c2: {coloring_histogram(c2)}")

equiv, witness = are_semantically_equivalent(c1, c2)
print(f"\nSemantically equivalent? {equiv}")
print(f"Semantic distance: {semantic_distance(c1, c2)}")
print("\n→ The histograms differ, so no permutation can transform one into the other.")
print("  This is the Semantic Gap: isomorphic structures carry irreconcilable meanings.")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 2: Semantic Distance as a Pseudometric
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMONSTRATION 2: Semantic Distance Pseudometric")
print("=" * 70)

# Colorings of Fin 4
colorings = [
    [0, 0, 1, 1],  # A
    [0, 1, 0, 1],  # B
    [0, 1, 1, 0],  # C
    [1, 1, 0, 0],  # D
    [0, 0, 0, 1],  # E
]

labels = "ABCDE"
print("\nSemantic distance matrix:")
print(f"     {'  '.join(labels)}")
for i, ci in enumerate(colorings):
    row = [semantic_distance(ci, cj) for cj in colorings]
    print(f"  {labels[i]}  {'  '.join(str(d) for d in row)}")

print("\nKey observations:")
print("  • d(X,X) = 0 for all X (reflexivity)")
print("  • d(X,Y) = d(Y,X) for all X,Y (symmetry)")
print("  • A,B,C,D all have histogram {0:2, 1:2} — some are equivalent!")

for i in range(len(colorings)):
    for j in range(i + 1, len(colorings)):
        eq, w = are_semantically_equivalent(colorings[i], colorings[j])
        if eq:
            print(f"  • {labels[i]} ≡ {labels[j]} via permutation {w}")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 3: Chromatic Stabilizer and Symmetry Breaking
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMONSTRATION 3: Chromatic Stabilizer — Symmetry Breaking")
print("=" * 70)

test_colorings = [
    ("Constant",        [0, 0, 0]),
    ("Two colors",      [0, 0, 1]),
    ("Injective",       [0, 1, 2]),
    ("Alternating-4",   [0, 1, 0, 1]),
    ("Block-4",         [0, 0, 1, 1]),
]

import math

for name, coloring in test_colorings:
    stab = chromatic_stabilizer(coloring)
    n = len(coloring)
    full_aut_size = math.factorial(n)
    print(f"\n  {name}: {coloring}")
    print(f"    |Stab| = {len(stab)}, |Aut| = {full_aut_size}, "
          f"index = {full_aut_size // len(stab)}")
    print(f"    Symmetry broken: {100 * (1 - len(stab) / full_aut_size):.0f}%")

print("\n→ Injective colorings break ALL symmetry (|Stab| = 1).")
print("  Constant colorings preserve ALL symmetry (|Stab| = |Aut|).")
print("  This is the Chromatic Rigidity Theorem in action.")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 4: Counting Semantic Equivalence Classes
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMONSTRATION 4: Semantic Equivalence Classes (Burnside Counting)")
print("=" * 70)

for n in range(1, 5):
    for k in range(1, min(n + 2, 4)):
        classes = semantic_equivalence_classes(n, k)
        total = k ** n
        print(f"  |Fin {n}| with {k} colors: "
              f"{total} colorings → {len(classes)} semantic classes")

print("\n→ The number of classes grows much slower than the number of colorings.")
print("  This is because structural symmetries identify many colorings.")

# ═══════════════════════════════════════════════════════════════
# DEMONSTRATION 5: Transfer Obstruction
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("DEMONSTRATION 5: Transfer Obstruction")
print("=" * 70)

# Property: "element 0 has color true"
c_true_at_0 = [1, 0]   # true at position 0
c_false_at_0 = [0, 1]  # false at position 0

print(f"\n  c₁ = {c_true_at_0} — element 0 is colored 1 (true)")
print(f"  c₂ = {c_false_at_0} — element 0 is colored 0 (false)")

equiv, witness = are_semantically_equivalent(c_true_at_0, c_false_at_0)
print(f"\n  Semantically equivalent? {equiv} (via swap {witness})")
print(f"  But P(c₁) = True, P(c₂) = False for P = 'color of element 0 is 1'")
print("\n→ Point-evaluation is NOT transferable across semantic equivalence.")
print("  Structural isomorphisms destroy point-specific meaning.")

# Property: "all elements same color" — this IS transferable
c_const = [1, 1]
c_mixed = [0, 1]
print(f"\n  Constant coloring {c_const}: all same color? True")
print(f"  Mixed coloring {c_mixed}: all same color? False")
print(f"  These are NOT semantically equivalent (distance = {semantic_distance(c_const, c_mixed)})")
print("→ 'All same color' IS transferable: it's preserved by all permutations.")


#!/usr/bin/env python3
"""
Visualization: Burnside Class Counting

Shows how the number of semantic equivalence classes grows
compared to the total number of colorings, demonstrating
the dramatic compression effect of structural symmetry.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
import math


def count_semantic_classes_burnside(n, k):
    """Count classes using Burnside's lemma."""
    total_fixed = 0
    for perm in permutations(range(n)):
        visited = [False] * n
        num_cycles = 0
        for i in range(n):
            if not visited[i]:
                num_cycles += 1
                j = i
                while not visited[j]:
                    visited[j] = True
                    j = perm[j]
        total_fixed += k ** num_cycles
    return total_fixed // math.factorial(n)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Classes vs total colorings
ax = axes[0]
for k in [2, 3, 4]:
    ns = range(1, 8)
    totals = [k**n for n in ns]
    classes = [count_semantic_classes_burnside(n, k) for n in ns]

    ax.semilogy(list(ns), totals, '--', alpha=0.4, color=f'C{k-2}')
    ax.semilogy(list(ns), classes, 'o-', linewidth=2, color=f'C{k-2}',
                label=f'k={k}')

ax.set_xlabel('n (number of elements)', fontsize=12)
ax.set_ylabel('Count (log scale)', fontsize=12)
ax.set_title('Semantic Classes vs Total Colorings\n(dashed = total, solid = classes)',
             fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Compression ratio
ax = axes[1]
for k in [2, 3, 4]:
    ns = range(1, 8)
    ratios = []
    for n in ns:
        total = k ** n
        classes = count_semantic_classes_burnside(n, k)
        ratios.append(classes / total)

    ax.plot(list(ns), ratios, 'o-', linewidth=2, label=f'k={k}')

ax.set_xlabel('n (number of elements)', fontsize=12)
ax.set_ylabel('Classes / Total colorings', fontsize=12)
ax.set_title('Semantic Compression Ratio\n(lower = more symmetry reduction)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.05)

plt.tight_layout()
plt.savefig('burnside_classes.png', dpi=150)
print("Saved: burnside_classes.png")


#!/usr/bin/env python3
"""
Visualization: Semantic Distance Heatmap

Shows the semantic distance matrix between all 2-colorings of Fin 4,
grouped by semantic equivalence class.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, product as cart_product


def semantic_distance(c1, c2):
    n = len(c1)
    best = n
    for perm in permutations(range(n)):
        d = sum(1 for i in range(n) if c1[i] != c2[perm[i]])
        best = min(best, d)
        if best == 0:
            return 0
    return best


def histogram_sig(c):
    from collections import Counter
    return tuple(sorted(Counter(c).values()))


# Generate all 2-colorings of Fin 4
n, k = 4, 2
all_colorings = list(cart_product(range(k), repeat=n))

# Sort by histogram signature for visual grouping
all_colorings.sort(key=lambda c: (histogram_sig(c), c))

# Compute distance matrix
N = len(all_colorings)
dist_matrix = np.zeros((N, N), dtype=int)
for i in range(N):
    for j in range(i, N):
        d = semantic_distance(list(all_colorings[i]), list(all_colorings[j]))
        dist_matrix[i, j] = d
        dist_matrix[j, i] = d

# Plot
fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(dist_matrix, cmap='YlOrRd', interpolation='nearest')
ax.set_title('Semantic Distance Between 2-Colorings of Fin 4\n'
             '(Sorted by histogram signature)', fontsize=14)
ax.set_xlabel('Coloring index')
ax.set_ylabel('Coloring index')

# Add colorbar
cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Semantic Distance', fontsize=12)

# Add coloring labels on axes
labels = [''.join(str(x) for x in c) for c in all_colorings]
ax.set_xticks(range(N))
ax.set_xticklabels(labels, rotation=90, fontsize=7)
ax.set_yticks(range(N))
ax.set_yticklabels(labels, fontsize=7)

# Draw block boundaries for histogram classes
sigs = [histogram_sig(c) for c in all_colorings]
boundaries = []
for i in range(1, N):
    if sigs[i] != sigs[i-1]:
        boundaries.append(i - 0.5)
for b in boundaries:
    ax.axhline(y=b, color='blue', linewidth=1.5, linestyle='--', alpha=0.7)
    ax.axvline(x=b, color='blue', linewidth=1.5, linestyle='--', alpha=0.7)

plt.tight_layout()
plt.savefig('semantic_distance_heatmap.png', dpi=150)
print("Saved: semantic_distance_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Chromatic Stabilizer Spectrum

Shows how the stabilizer size varies across different colorings,
illustrating the symmetry-breaking effect of semantic content.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, product as cart_product
from collections import Counter
import math


def stabilizer_size(coloring):
    """Compute |Stab(c)| = product of (multiplicity)! for each color."""
    hist = Counter(coloring)
    result = 1
    for count in hist.values():
        result *= math.factorial(count)
    return result


def stabilizer_index(coloring):
    """Compute [Sym(n) : Stab(c)] = n! / |Stab(c)|."""
    n = len(coloring)
    return math.factorial(n) // stabilizer_size(coloring)


# Parameters
max_n = 6

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: Distribution of stabilizer sizes for n=5, k=3
n, k = 5, 3
all_colorings = list(cart_product(range(k), repeat=n))
stab_sizes = [stabilizer_size(list(c)) for c in all_colorings]
unique_sizes = sorted(set(stab_sizes))
size_counts = Counter(stab_sizes)

ax = axes[0]
bars = ax.bar(range(len(unique_sizes)),
              [size_counts[s] for s in unique_sizes],
              color='steelblue', alpha=0.8)
ax.set_xticks(range(len(unique_sizes)))
ax.set_xticklabels([str(s) for s in unique_sizes])
ax.set_xlabel('|Stab(c)|', fontsize=12)
ax.set_ylabel('Number of colorings', fontsize=12)
ax.set_title(f'Stabilizer Size Distribution\n(n={n}, k={k})', fontsize=14)
ax.set_yscale('log')

# Add percentage labels
total = len(all_colorings)
for bar, s in zip(bars, unique_sizes):
    count = size_counts[s]
    pct = 100 * count / total
    if pct > 0.5:
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height(),
                f'{pct:.0f}%', ha='center', va='bottom', fontsize=8)

# Right plot: Symmetry breaking ratio vs number of colors
ax = axes[1]
for n in range(3, max_n + 1):
    k_range = range(1, n + 2)
    avg_indices = []
    for k in k_range:
        all_c = list(cart_product(range(k), repeat=n))
        indices = [stabilizer_index(list(c)) for c in all_c]
        avg_indices.append(np.mean(indices))

    ax.plot(list(k_range), avg_indices, 'o-', label=f'n={n}', linewidth=2)

ax.set_xlabel('Number of colors (k)', fontsize=12)
ax.set_ylabel('Average orbit size [Sym(n):Stab(c)]', fontsize=12)
ax.set_title('Average Symmetry Breaking\nvs Number of Colors', fontsize=14)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('stabilizer_spectrum.png', dpi=150)
print("Saved: stabilizer_spectrum.png")
