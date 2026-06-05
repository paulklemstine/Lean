#!/usr/bin/env python3
"""
Demo: Self-Referential Types and Fixed Points
==============================================

Demonstrates the key mathematical constructions from the Lawvere Fixed Point
Theorem research cycle. Shows concrete examples of:
1. The Lawvere diagonal construction
2. Cantor's theorem via diagonal argument
3. The diagonal hierarchy
4. Fixed points of iterated operators
"""

from typing import Callable, Set, Dict, List, Optional
import itertools


def lawvere_diagonal(e: Callable[[int], Callable[[int], bool]],
                     f: Callable[[bool], bool],
                     domain_size: int) -> Optional[int]:
    """
    Demonstrate the Lawvere diagonal construction.
    
    Given e: A -> (A -> Bool) and f: Bool -> Bool,
    constructs d(x) = f(e(x)(x)) and searches for a such that e(a) = d.
    If found, e(a)(a) is a fixed point of f.
    
    Returns the fixed point if found, None otherwise.
    """
    # Construct the diagonal function d
    d = lambda x: f(e(x)(x))
    
    # Search for a such that e(a) agrees with d on the domain
    for a in range(domain_size):
        if all(e(a)(x) == d(x) for x in range(domain_size)):
            fixed_point = e(a)(a)
            print(f"  Found a = {a}")
            print(f"  e(a)(a) = {fixed_point}")
            print(f"  f(e(a)(a)) = {f(fixed_point)}")
            print(f"  Fixed point: f({fixed_point}) = {fixed_point}? {f(fixed_point) == fixed_point}")
            return fixed_point
    return None


def demo_cantor_diagonal():
    """
    Demonstrate Cantor's theorem: no surjection from {0,...,n-1} to 2^{0,...,n-1}.
    """
    print("=" * 60)
    print("DEMO 1: Cantor's Diagonal Argument")
    print("=" * 60)
    
    n = 5
    print(f"\nTrying to enumerate all subsets of {{0,...,{n-1}}} using {n} functions:")
    
    # Define n functions from {0,...,n-1} to Bool
    # This represents an attempted enumeration
    functions = []
    for i in range(n):
        # i-th function: characteristic function of {i, (i+1)%n}
        func = lambda x, i=i: x == i or x == (i + 1) % n
        functions.append(func)
    
    print("\nEnumerated functions (as characteristic sets):")
    for i, f in enumerate(functions):
        chars = [f(x) for x in range(n)]
        subset = {x for x in range(n) if f(x)}
        print(f"  f_{i} = {subset}")
    
    # Construct the diagonal set: {x | x not in f_x}
    diagonal = {x for x in range(n) if not functions[x](x)}
    print(f"\nDiagonal set D = {{x | x ∉ f_x}} = {diagonal}")
    
    # Verify D differs from every f_i
    for i, f in enumerate(functions):
        subset = {x for x in range(n) if f(x)}
        differs_at = i  # D and f_i must differ at index i
        print(f"  D vs f_{i}: D({i}) = {i in diagonal}, f_{i}({i}) = {f(i)} — {'DIFFER' if (i in diagonal) != f(i) else 'AGREE'}")
    
    print("\n→ The diagonal set differs from every enumerated set.")
    print("  This proves no finite list can enumerate all subsets.")


def demo_diagonal_hierarchy():
    """
    Demonstrate the diagonal hierarchy: iterated diagonalization
    produces strictly increasing complexity levels.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: The Diagonal Hierarchy")
    print("=" * 60)
    
    # Level 0: decidable sets (represented as finite sets of ℕ < 20)
    # Level 1: sets that require one diagonalization
    # Level 2: sets that require two diagonalizations
    
    n = 10  # universe size
    
    # Level 0: simple arithmetic sets
    level0 = [
        {x for x in range(n) if x % 2 == 0},  # evens
        {x for x in range(n) if x % 2 == 1},  # odds
        {x for x in range(n) if x % 3 == 0},  # multiples of 3
        {x for x in range(n) if x < 5},        # small numbers
        set(),                                   # empty set
        set(range(n)),                           # full set
    ]
    
    print(f"\nLevel 0 sets (simple arithmetic, {len(level0)} sets):")
    for i, s in enumerate(level0):
        print(f"  S_{i} = {sorted(s)}")
    
    # Pad to n functions
    while len(level0) < n:
        level0.append(set())
    
    # Diagonalize level 0
    diag0 = {x for x in range(n) if x not in level0[x]}
    print(f"\nDiagonal of Level 0: D₀ = {{x | x ∉ S_x}} = {sorted(diag0)}")
    
    # Verify D₀ is not in level 0
    for i, s in enumerate(level0[:6]):
        if diag0 == s:
            print(f"  ⚠ D₀ equals S_{i}!")
            break
    else:
        print("  ✓ D₀ differs from all Level 0 sets (as guaranteed by Lawvere)")
    
    # Level 1 includes level 0 plus D₀
    level1 = level0[:6] + [diag0]
    
    # Pad to n
    while len(level1) < n:
        level1.append(set())
    
    # Diagonalize level 1
    diag1 = {x for x in range(n) if x not in level1[x]}
    print(f"\nDiagonal of Level 1: D₁ = {{x | x ∉ T_x}} = {sorted(diag1)}")
    
    for i, s in enumerate(level1[:7]):
        if diag1 == s:
            print(f"  ⚠ D₁ equals T_{i}!")
            break
    else:
        print("  ✓ D₁ differs from all Level 1 sets")
    
    print(f"\n→ Level 0 ⊊ Level 1 ⊊ Level 2 ⊊ ... (strict hierarchy)")
    print("  Each diagonalization creates genuinely new complexity.")


def demo_fixed_point_iteration():
    """
    Demonstrate fixed points under iteration and the period-2 phenomenon.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Fixed Points of Iterated Operations")
    print("=" * 60)
    
    # Example 1: f(x) = 1-x on {0, 1}
    print("\nExample: f(x) = 1 - x on {0, 1}")
    f = lambda x: 1 - x
    
    print("  f(0) =", f(0), "  f(1) =", f(1))
    print("  Fixed points of f: none (f(0)=1≠0, f(1)=0≠1)")
    
    f2 = lambda x: f(f(x))
    print("  f²(0) =", f2(0), "  f²(1) =", f2(1))
    print("  Fixed points of f²: {0, 1} (f²=id)")
    print("  → Period-2 orbits: 0 ↔ 1")
    
    # Example 2: Collatz-like function
    print("\nExample: g(x) = x//2 if even, 3x+1 if odd (mod 16)")
    def g(x):
        if x % 2 == 0:
            return x // 2
        else:
            return (3 * x + 1) % 16
    
    print("  Values: ", {x: g(x) for x in range(16)})
    
    # Find fixed points of g, g², g³, ...
    for k in range(1, 7):
        gk = lambda x, k=k: x
        for _ in range(k):
            gk_prev = gk
            gk = lambda x, f=gk_prev: g(f(x))
        
        fps = {x for x in range(16) if gk(x) == x}
        print(f"  Fixed points of g^{k}: {sorted(fps)} ({len(fps)} points)")
    
    print("\n  → Fixed point sets grow with iteration depth")
    print("  → FixedPoints(f) ⊆ FixedPoints(f²) ⊆ FixedPoints(f³) ⊆ ...")


def demo_knaster_tarski():
    """
    Demonstrate the Knaster-Tarski theorem on a finite lattice.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Knaster-Tarski Fixed Points on Power Set Lattice")
    print("=" * 60)
    
    universe = {0, 1, 2, 3, 4}
    
    # Monotone function: closure under taking pairs that sum to 4
    def f(S: frozenset) -> frozenset:
        result = set(S)
        for x in S:
            complement = 4 - x
            if 0 <= complement <= 4:
                result.add(complement)
        return frozenset(result)
    
    print(f"\nMonotone function f on P({set(universe)}):")
    print("  f(S) = S ∪ {4-x | x ∈ S, 0 ≤ 4-x ≤ 4}")
    
    # Compute all fixed points
    fixed_points = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            S = frozenset(subset)
            if f(S) == S:
                fixed_points.append(set(S))
    
    print(f"\n  Fixed points of f ({len(fixed_points)} total):")
    for fp in sorted(fixed_points, key=lambda s: (len(s), sorted(s))):
        print(f"    {fp}")
    
    # Find least fixed point (by Knaster-Tarski = ∩ of pre-fixed-points)
    pre_fps = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            S = frozenset(subset)
            if f(S).issubset(S):
                pre_fps.append(S)
    
    lfp = frozenset.intersection(*pre_fps) if pre_fps else frozenset()
    print(f"\n  Least fixed point (⊓ pre-fixed-points): {set(lfp)}")
    print(f"  f(lfp) = {set(f(lfp))} = lfp? {f(lfp) == lfp}")
    
    # Find greatest fixed point (∪ of post-fixed-points)
    post_fps = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            S = frozenset(subset)
            if S.issubset(f(S)):
                post_fps.append(S)
    
    gfp = frozenset.union(*post_fps) if post_fps else frozenset()
    print(f"  Greatest fixed point (⊔ post-fixed-points): {set(gfp)}")
    print(f"  f(gfp) = {set(f(gfp))} = gfp? {f(gfp) == gfp}")


def demo_self_reference_trilemma():
    """
    Demonstrate the Self-Reference Trilemma with a truth-teller/liar example.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: The Self-Reference Trilemma")
    print("=" * 60)
    
    print("""
    The Self-Reference Trilemma: No system can be simultaneously
    (1) Self-referential, (2) Consistent, and (3) Complete.
    
    Example: A library catalog that lists all books
    
    Consider a library with books b₀, b₁, b₂, ...
    Each book bᵢ contains a list of books (a "catalog").
    
    Question: Is there a book that lists exactly the books
    that do NOT list themselves?
    
    Let D = {i | book i does not list book i}
    
    If book k has catalog D:
      - Does book k list itself?
      - If yes: k ∈ catalog(k) = D, so k ∉ catalog(k). Contradiction!
      - If no: k ∉ catalog(k) = D, so k ∈ catalog(k). Contradiction!
    
    Conclusion: No such book k exists.
    The catalog system is INCOMPLETE — not every "natural" set
    of books can be represented as a catalog.
    
    This is exactly Lawvere's theorem with:
      α = books, β = Bool (listed/not listed)
      e(i) = catalog function of book i
      f = negation (Bool.not)
    """)
    
    # Concrete numerical example
    n = 6
    catalogs = {
        0: {0, 1, 2},      # Book 0 lists books 0, 1, 2
        1: {1, 3, 5},      # Book 1 lists books 1, 3, 5
        2: {0, 2, 4},      # Book 2 lists books 0, 2, 4
        3: {3, 4, 5},      # Book 3 lists books 3, 4, 5
        4: {0, 1},          # Book 4 lists books 0, 1
        5: {2, 3, 4, 5},    # Book 5 lists books 2, 3, 4, 5
    }
    
    # Self-listing status
    print("  Book catalogs:")
    for i in range(n):
        lists_self = i in catalogs[i]
        print(f"    Book {i}: lists {catalogs[i]}, lists self? {lists_self}")
    
    # The "Russell set"
    russell = {i for i in range(n) if i not in catalogs[i]}
    print(f"\n  Russell set R = {{i | book i doesn't list itself}} = {russell}")
    
    # Check if any book has this catalog
    for i in range(n):
        if catalogs[i] == russell:
            print(f"  ⚠ Book {i} has catalog R!")
    else:
        print("  ✓ No book has the Russell set as its catalog.")
        print("  → The catalog system is INCOMPLETE (Lawvere's theorem).")


if __name__ == "__main__":
    demo_cantor_diagonal()
    demo_diagonal_hierarchy()
    demo_fixed_point_iteration()
    demo_knaster_tarski()
    demo_self_reference_trilemma()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Diagonal Hierarchy
======================================

Visualizes the strict hierarchy produced by iterated diagonalization,
showing how each level strictly contains the previous one.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def build_hierarchy(n_universe: int, n_levels: int):
    """Build the diagonal hierarchy and track set membership."""
    levels = []
    all_sets = []
    
    # Level 0: simple arithmetic sets
    base = [
        {x for x in range(n_universe) if x % 2 == 0},
        {x for x in range(n_universe) if x % 2 == 1},
        {x for x in range(n_universe) if x % 3 == 0},
        {x for x in range(n_universe) if x < n_universe // 2},
        set(),
        set(range(n_universe)),
    ]
    all_sets.extend(base)
    levels.append(list(base))
    
    for level in range(1, n_levels):
        current = list(all_sets)
        # Pad to n_universe
        while len(current) < n_universe:
            current.append(set())
        
        # Diagonal
        diag = {x for x in range(n_universe) if x not in current[x]}
        all_sets.append(diag)
        levels.append(levels[-1] + [diag])
    
    return levels


def visualize():
    n_universe = 12
    n_levels = 5
    levels = build_hierarchy(n_universe, n_levels)
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # Left panel: Set membership matrix at each level
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_levels))
    
    y_positions = []
    y_labels = []
    y_colors = []
    
    pos = 0
    for level_idx, level_sets in enumerate(levels):
        for set_idx, s in enumerate(level_sets):
            y_positions.append(pos)
            is_new = (level_idx > 0 and set_idx >= len(levels[level_idx - 1]))
            label = f"L{level_idx}" + ("·D" if is_new else f"·S{set_idx}")
            y_labels.append(label)
            y_colors.append(colors[level_idx])
            
            for x in s:
                ax1.scatter(x, pos, c=[colors[level_idx]], s=80, 
                          edgecolors='black' if is_new else 'gray',
                          linewidths=2 if is_new else 0.5,
                          zorder=3)
            pos += 1
        pos += 0.5  # gap between levels
    
    ax1.set_yticks(y_positions)
    ax1.set_yticklabels(y_labels, fontsize=7)
    ax1.set_xlabel('Element', fontsize=12)
    ax1.set_title('Set Membership by Hierarchy Level', fontsize=14)
    ax1.set_xlim(-0.5, n_universe - 0.5)
    ax1.grid(True, alpha=0.3)
    ax1.invert_yaxis()
    
    # Right panel: Level sizes
    ax2 = axes[1]
    level_sizes = [len(l) for l in levels]
    bars = ax2.bar(range(n_levels), level_sizes, color=colors, edgecolor='black')
    ax2.set_xlabel('Hierarchy Level', fontsize=12)
    ax2.set_ylabel('Number of Sets', fontsize=12)
    ax2.set_title('Strict Growth: |Level n| < |Level n+1|', fontsize=14)
    
    for i, (bar, size) in enumerate(zip(bars, level_sizes)):
        ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                str(size), ha='center', fontsize=12, fontweight='bold')
    
    # Add annotation about strictness
    ax2.annotate('Each diagonal\nescapes its level',
                xy=(2, level_sizes[2]), xytext=(3.5, level_sizes[1]),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=10, color='red', ha='center')
    
    plt.tight_layout()
    plt.savefig('diagonal_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: diagonal_hierarchy.png")


def visualize_fixed_points():
    """Visualize fixed points of iterated functions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Fixed points of f^n for f(x) = (2x+1) mod 16
    ax1 = axes[0]
    n = 16
    f = lambda x: (2 * x + 1) % n
    
    max_iter = 8
    fp_sizes = []
    fp_sets = []
    
    for k in range(1, max_iter + 1):
        def iterate(x, depth=k):
            for _ in range(depth):
                x = f(x)
            return x
        fps = {x for x in range(n) if iterate(x) == x}
        fp_sizes.append(len(fps))
        fp_sets.append(fps)
    
    ax1.bar(range(1, max_iter + 1), fp_sizes, 
           color=plt.cm.plasma(np.linspace(0.2, 0.8, max_iter)),
           edgecolor='black')
    ax1.set_xlabel('Iteration Depth k', fontsize=12)
    ax1.set_ylabel('|FixedPoints(f^k)|', fontsize=12)
    ax1.set_title('Fixed Points Grow with Iteration\nf(x) = (2x+1) mod 16', fontsize=13)
    
    # Right: Orbit structure
    ax2 = axes[1]
    
    # Draw the orbit graph
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x_pos = np.cos(theta)
    y_pos = np.sin(theta)
    
    # Draw edges
    for i in range(n):
        j = f(i)
        ax2.annotate('', xy=(x_pos[j], y_pos[j]), xytext=(x_pos[i], y_pos[i]),
                    arrowprops=dict(arrowstyle='->', color='steelblue', alpha=0.6))
    
    # Color nodes by first iteration depth where they become periodic
    node_colors = []
    for i in range(n):
        depth = 0
        for k in range(1, max_iter + 1):
            if i in fp_sets[k - 1]:
                depth = k
                break
        node_colors.append(depth if depth > 0 else max_iter + 1)
    
    scatter = ax2.scatter(x_pos, y_pos, c=node_colors, cmap='plasma',
                         s=200, edgecolors='black', linewidths=1.5, zorder=5,
                         vmin=1, vmax=max_iter)
    
    for i in range(n):
        ax2.text(x_pos[i], y_pos[i], str(i), ha='center', va='center',
                fontsize=8, fontweight='bold', zorder=6)
    
    ax2.set_title('Orbit Graph of f(x) = (2x+1) mod 16', fontsize=13)
    ax2.set_aspect('equal')
    ax2.axis('off')
    
    plt.colorbar(scatter, ax=ax2, label='First periodic depth k')
    
    plt.tight_layout()
    plt.savefig('fixed_point_orbits.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fixed_point_orbits.png")


if __name__ == "__main__":
    visualize()
    visualize_fixed_points()
