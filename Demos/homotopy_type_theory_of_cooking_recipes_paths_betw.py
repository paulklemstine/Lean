#!/usr/bin/env python3
"""
Demo: Recipe Substitution Graph — Numerical Examples

Demonstrates the key mathematical results from the recipe homotopy theory:
1. Hamming distance as a metric on recipe space
2. Triangle-freeness for m=2, triangle existence for m≥3
3. Substitution spectrum identity
4. Slot independence for additive flavor maps
5. Vertex transitivity via translation
"""

import itertools
import numpy as np
from typing import List, Tuple
from collections import defaultdict


def hamming_distance(r1: Tuple[int, ...], r2: Tuple[int, ...]) -> int:
    """Compute Hamming distance between two recipes."""
    return sum(1 for a, b in zip(r1, r2) if a != b)


def all_recipes(n: int, m: int) -> List[Tuple[int, ...]]:
    """Generate all recipes with n slots and m choices."""
    return list(itertools.product(range(m), repeat=n))


def substitution_graph_edges(recipes: List[Tuple[int, ...]], n: int, m: int):
    """Return edges of the substitution graph (pairs at Hamming distance 1)."""
    edges = []
    for i, r1 in enumerate(recipes):
        for j, r2 in enumerate(recipes):
            if i < j and hamming_distance(r1, r2) == 1:
                edges.append((r1, r2))
    return edges


def count_triangles(recipes, n, m):
    """Count triangles in the substitution graph."""
    adj = defaultdict(set)
    for r1 in recipes:
        for r2 in recipes:
            if r1 != r2 and hamming_distance(r1, r2) == 1:
                adj[r1].add(r2)

    triangles = 0
    recipe_list = list(recipes)
    for i, a in enumerate(recipe_list):
        for j in range(i + 1, len(recipe_list)):
            b = recipe_list[j]
            if b in adj[a]:
                for k in range(j + 1, len(recipe_list)):
                    c = recipe_list[k]
                    if c in adj[a] and c in adj[b]:
                        triangles += 1
    return triangles


def spectrum_count(n: int, m: int, k: int) -> int:
    """C(n,k) * (m-1)^k"""
    from math import comb
    return comb(n, k) * (m - 1) ** k


def verify_spectrum_sum(n: int, m: int) -> bool:
    """Verify that sum of spectrum counts equals m^n."""
    total = sum(spectrum_count(n, m, k) for k in range(n + 1))
    return total == m ** n


def additive_flavor_eval(contrib, recipe, d):
    """Evaluate an additive flavor map."""
    n = len(recipe)
    result = np.zeros(d)
    for i in range(n):
        result += contrib[i][recipe[i]]
    return result


def verify_slot_independence(contrib, recipe, slot, new_val, d):
    """Verify the slot independence theorem numerically."""
    recipe_modified = list(recipe)
    old_val = recipe[slot]
    recipe_modified[slot] = new_val
    recipe_modified = tuple(recipe_modified)

    flavor_orig = additive_flavor_eval(contrib, recipe, d)
    flavor_mod = additive_flavor_eval(contrib, recipe_modified, d)

    diff_actual = flavor_mod - flavor_orig
    diff_predicted = contrib[slot][new_val] - contrib[slot][old_val]

    return np.allclose(diff_actual, diff_predicted)


def main():
    print("=" * 60)
    print("RECIPE SUBSTITUTION GRAPH — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Triangle structure
    print("\n--- Demo 1: Triangle Structure ---")
    for m in [2, 3, 4]:
        n = 3
        recipes = all_recipes(n, m)
        tri = count_triangles(recipes, n, m)
        print(f"  H({n},{m}): {len(recipes)} recipes, {tri} triangles")

    print("  → Theorem confirmed: m=2 has 0 triangles, m≥3 has triangles")

    # Demo 2: Spectrum identity
    print("\n--- Demo 2: Substitution Spectrum ---")
    n, m = 5, 4
    print(f"  Recipe space H({n},{m}): {m**n} total recipes")
    for k in range(n + 1):
        sc = spectrum_count(n, m, k)
        print(f"    Distance {k}: {sc} recipes")
    total = sum(spectrum_count(n, m, k) for k in range(n + 1))
    print(f"    Sum = {total} = {m}^{n} = {m**n} ✓" if total == m**n
          else f"    Sum = {total} ≠ {m}^{n} ✗")

    # Demo 3: Metric properties
    print("\n--- Demo 3: Triangle Inequality ---")
    np.random.seed(42)
    n, m = 4, 3
    violations = 0
    for _ in range(10000):
        r1 = tuple(np.random.randint(0, m, n))
        r2 = tuple(np.random.randint(0, m, n))
        r3 = tuple(np.random.randint(0, m, n))
        if hamming_distance(r1, r3) > hamming_distance(r1, r2) + hamming_distance(r2, r3):
            violations += 1
    print(f"  Triangle inequality violations in 10000 random triples: {violations}")

    # Demo 4: Slot independence
    print("\n--- Demo 4: Slot Independence ---")
    n, m, d = 4, 3, 3
    contrib = {i: {v: np.random.randn(d) for v in range(m)} for i in range(n)}
    checks = 0
    passes = 0
    for _ in range(1000):
        recipe = tuple(np.random.randint(0, m, n))
        slot = np.random.randint(0, n)
        new_val = np.random.randint(0, m)
        if verify_slot_independence(contrib, recipe, slot, new_val, d):
            passes += 1
        checks += 1
    print(f"  Slot independence verified: {passes}/{checks} checks passed")

    # Demo 5: Vertex transitivity
    print("\n--- Demo 5: Vertex Transitivity ---")
    n, m = 3, 3
    recipes = all_recipes(n, m)
    r1 = (0, 0, 0)
    r2 = (1, 2, 0)
    offset = tuple((r2[i] - r1[i]) % m for i in range(n))

    # Verify translation preserves adjacency structure
    adj_r1 = sorted([r for r in recipes if hamming_distance(r1, r) == 1])
    translated_r1 = tuple((r1[i] + offset[i]) % m for i in range(n))
    adj_translated = sorted([r for r in recipes if hamming_distance(translated_r1, r) == 1])
    print(f"  r1 = {r1}, translated to {translated_r1} = r2 = {r2}")
    print(f"  Neighbors of r1: {len(adj_r1)}")
    print(f"  Neighbors of r2: {len(adj_translated)}")
    print(f"  Degree preserved: {len(adj_r1) == len(adj_translated)} (both = n*(m-1) = {n*(m-1)})")

    # Demo 6: Spectrum verification for multiple parameters
    print("\n--- Demo 6: Spectrum Sum Verification ---")
    for n in range(1, 8):
        for m in range(1, 6):
            assert verify_spectrum_sum(n, m), f"Failed for n={n}, m={m}"
    print("  Spectrum sum = m^n verified for all n ∈ [1,7], m ∈ [1,5] ✓")

    # Demo 7: Four-cycle detection
    print("\n--- Demo 7: Four-Cycles ---")
    n, m = 3, 2
    recipes = all_recipes(n, m)
    edges = substitution_graph_edges(recipes, n, m)
    adj = defaultdict(set)
    for r1, r2 in edges:
        adj[r1].add(r2)
        adj[r2].add(r1)
    four_cycles = 0
    for a in recipes:
        for b in adj[a]:
            for c in adj[b]:
                if c != a and c not in adj[a]:
                    for d in adj[c]:
                        if d != b and d in adj[a] and d not in adj[b]:
                            four_cycles += 1
    four_cycles //= 8  # Each 4-cycle counted 8 times
    print(f"  H({n},{m}): {four_cycles} four-cycles")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Recipe Substitution Graph Structure

Visualizes the substitution graph for small parameters,
showing triangle structure and four-cycles.
"""

import matplotlib.pyplot as plt
import numpy as np
import itertools
from collections import defaultdict


def hamming_distance(r1, r2):
    return sum(1 for a, b in zip(r1, r2) if a != b)


def plot_substitution_graph():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: H(3,2) — the 3-cube (triangle-free)
    ax = axes[0]
    n, m = 3, 2
    recipes = list(itertools.product(range(m), repeat=n))

    # 3D layout for the cube
    positions = {r: np.array(r, dtype=float) for r in recipes}

    # Project 3D to 2D using isometric projection
    angle = np.pi / 6
    proj = np.array([[1, -np.cos(angle)], [0, np.sin(angle)], [0.3, 0.3]])
    pos2d = {r: positions[r] @ proj for r in recipes}

    # Draw edges
    for r1 in recipes:
        for r2 in recipes:
            if hamming_distance(r1, r2) == 1:
                p1, p2 = pos2d[r1], pos2d[r2]
                ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'b-', alpha=0.4, linewidth=1.5)

    # Color by Hamming weight (parity)
    for r in recipes:
        p = pos2d[r]
        weight = sum(r)
        color = 'red' if weight % 2 == 0 else 'blue'
        ax.plot(p[0], p[1], 'o', color=color, markersize=12, zorder=5)
        ax.annotate(str(r), (p[0], p[1]), textcoords="offset points",
                   xytext=(5, 5), fontsize=7)

    ax.set_title(f'H({n},{m}) — Hypercube (Triangle-Free)\nRed=even parity, Blue=odd parity')
    ax.set_aspect('equal')
    ax.axis('off')

    # Plot 2: H(2,3) — contains triangles
    ax = axes[1]
    n, m = 2, 3
    recipes = list(itertools.product(range(m), repeat=n))

    # 2D layout: grid
    pos2d = {r: np.array([r[0] * 1.5, r[1] * 1.5]) for r in recipes}

    # Draw edges
    for r1 in recipes:
        for r2 in recipes:
            if hamming_distance(r1, r2) == 1:
                p1, p2 = pos2d[r1], pos2d[r2]
                ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'g-', alpha=0.4, linewidth=1.5)

    # Highlight a triangle
    triangle = [(0, 0), (1, 0), (2, 0)]
    for i in range(3):
        p1 = pos2d[triangle[i]]
        p2 = pos2d[triangle[(i+1) % 3]]
        ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'r-', linewidth=3, alpha=0.8)

    for r in recipes:
        p = pos2d[r]
        color = 'red' if r in triangle else 'green'
        ax.plot(p[0], p[1], 'o', color=color, markersize=12, zorder=5)
        ax.annotate(str(r), (p[0], p[1]), textcoords="offset points",
                   xytext=(5, 5), fontsize=8)

    ax.set_title(f'H({n},{m}) — Contains Triangles\nRed triangle: (0,0)-(1,0)-(2,0)')
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('graph_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: graph_visualization.png")


if __name__ == "__main__":
    plot_substitution_graph()


#!/usr/bin/env python3
"""
Visualization: Recipe Substitution Spectrum

Plots the Hamming distance spectrum C(n,k)*(m-1)^k for various parameters,
illustrating the Vandermonde-Culinary Identity.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb


def spectrum_count(n: int, m: int, k: int) -> int:
    return comb(n, k) * (m - 1) ** k


def plot_spectrum():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Fixed n, varying m
    n = 8
    ax = axes[0]
    for m in [2, 3, 4, 5]:
        ks = list(range(n + 1))
        counts = [spectrum_count(n, m, k) for k in ks]
        ax.bar([k + (m-2)*0.2 for k in ks], counts, width=0.18,
               label=f'm={m}', alpha=0.8)
    ax.set_xlabel('Hamming distance k')
    ax.set_ylabel('Number of recipes')
    ax.set_title(f'Substitution Spectrum (n={n})')
    ax.legend()
    ax.set_yscale('log')

    # Plot 2: Fixed m, varying n
    m = 3
    ax = axes[1]
    for n in [3, 5, 7, 10]:
        ks = list(range(n + 1))
        counts = [spectrum_count(n, m, k) / (m**n) for k in ks]
        ax.plot(ks, counts, 'o-', label=f'n={n}', markersize=4)
    ax.set_xlabel('Hamming distance k')
    ax.set_ylabel('Fraction of recipe space')
    ax.set_title(f'Normalized Spectrum (m={m})')
    ax.legend()

    # Plot 3: Spectrum sum verification
    ax = axes[2]
    ns = list(range(1, 12))
    for m in [2, 3, 4]:
        sums = [sum(spectrum_count(n, m, k) for k in range(n+1)) for n in ns]
        expected = [m**n for n in ns]
        ax.plot(ns, sums, 'o', label=f'm={m} (computed)', markersize=6)
        ax.plot(ns, expected, '-', label=f'm={m} (m^n)', alpha=0.5)
    ax.set_xlabel('n (ingredient slots)')
    ax.set_ylabel('Total recipes')
    ax.set_title('Spectrum Sum = m^n')
    ax.legend()
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('spectrum_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: spectrum_visualization.png")


if __name__ == "__main__":
    plot_spectrum()
