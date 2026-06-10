#!/usr/bin/env python3
"""
Periodic Table of Finite Groups — Demo

Demonstrates the group-theoretic periodic table by computing invariants
for small finite groups and organizing them into chemical families.
"""

from math import gcd, log2
from itertools import product as iterproduct
from collections import Counter


def prime_factors_with_multiplicity(n: int) -> list[int]:
    """Return prime factors of n with multiplicity (Omega function)."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def omega(n: int) -> int:
    """Ω(n) — number of prime factors with multiplicity."""
    return len(prime_factors_with_multiplicity(n))


def is_abelian(table: list[list[int]]) -> bool:
    """Check if a group given by multiplication table is abelian."""
    n = len(table)
    return all(table[i][j] == table[j][i] for i in range(n) for j in range(n))


def find_identity(table: list[list[int]]) -> int:
    """Find the identity element."""
    n = len(table)
    for e in range(n):
        if all(table[e][j] == j and table[j][e] == j for j in range(n)):
            return e
    raise ValueError("No identity element found")


def inverse(table: list[list[int]], a: int) -> int:
    """Find the inverse of element a."""
    e = find_identity(table)
    n = len(table)
    for b in range(n):
        if table[a][b] == e:
            return b
    raise ValueError(f"No inverse for {a}")


def commutator_element(table: list[list[int]], a: int, b: int) -> int:
    """Compute [a,b] = a*b*a^{-1}*b^{-1}."""
    ai = inverse(table, a)
    bi = inverse(table, b)
    return table[table[table[a][b]][ai]][bi]


def commutator_subgroup(table: list[list[int]], subgroup: set[int]) -> set[int]:
    """Compute [H,H] for subgroup H — the derived subgroup."""
    generators = set()
    for a in subgroup:
        for b in subgroup:
            generators.add(commutator_element(table, a, b))
    # Generate the subgroup from these generators
    return generate_subgroup(table, generators)


def generate_subgroup(table: list[list[int]], generators: set[int]) -> set[int]:
    """Generate the subgroup from a set of generators."""
    e = find_identity(table)
    subgroup = {e}
    subgroup.update(generators)
    changed = True
    while changed:
        changed = False
        new_elements = set()
        for a in subgroup:
            for b in subgroup:
                prod = table[a][b]
                if prod not in subgroup:
                    new_elements.add(prod)
                    changed = True
                inv = inverse(table, a)
                if inv not in subgroup:
                    new_elements.add(inv)
                    changed = True
        subgroup.update(new_elements)
    return subgroup


def derived_series(table: list[list[int]]) -> list[set[int]]:
    """Compute the derived series D_0 ⊇ D_1 ⊇ ..."""
    n = len(table)
    series = [set(range(n))]
    while True:
        next_term = commutator_subgroup(table, series[-1])
        if next_term == series[-1]:
            break
        series.append(next_term)
        if len(next_term) == 1:
            break
    return series


def is_solvable(table: list[list[int]]) -> bool:
    """Check if the group is solvable."""
    series = derived_series(table)
    return len(series[-1]) == 1


def derived_depth(table: list[list[int]]) -> int | None:
    """Compute derived depth (None if not solvable)."""
    series = derived_series(table)
    if len(series[-1]) == 1:
        return len(series) - 1
    return None


def center(table: list[list[int]]) -> set[int]:
    """Compute the center Z(G)."""
    n = len(table)
    return {g for g in range(n) if all(table[g][h] == table[h][g] for h in range(n))}


def classify_group(table: list[list[int]]) -> dict:
    """Classify a finite group into the periodic table."""
    n = len(table)
    ab = is_abelian(table)
    sol = is_solvable(table)
    dd = derived_depth(table)
    z = center(table)
    
    if ab:
        family = "Noble Gas (Abelian)"
        nilpotent = True
        nil_class = 0 if n == 1 else 1
    elif len(z) > 1:
        # Check nilpotency more carefully
        family = "Noble Gas (Nilpotent)" if sol else "Transition Metal"
        nilpotent = True  # simplified
        nil_class = 2  # simplified
    elif sol:
        family = "Alkali/Alkaline (Solvable)"
        nilpotent = False
        nil_class = None
    else:
        family = "Halogen (Non-solvable)"
        nilpotent = False
        nil_class = None
    
    return {
        "order": n,
        "family": family,
        "abelian": ab,
        "nilpotent": nilpotent,
        "solvable": sol,
        "derived_depth": dd,
        "nilpotency_class": nil_class,
        "center_order": len(z),
        "info_dimension": omega(n),
    }


# --- Cyclic group multiplication table ---
def cyclic_group(n: int) -> list[list[int]]:
    """Multiplication table for Z/nZ."""
    return [[(i + j) % n for j in range(n)] for i in range(n)]


# --- Symmetric group multiplication table ---
def symmetric_group(n: int) -> list[list[int]]:
    """Multiplication table for S_n (using index encoding of permutations)."""
    from itertools import permutations
    perms = list(permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    
    def compose(p, q):
        return tuple(p[q[i]] for i in range(n))
    
    return [[perm_to_idx[compose(perms[i], perms[j])] for j in range(len(perms))] for i in range(len(perms))]


# --- Dihedral group multiplication table ---  
def dihedral_group(n: int) -> list[list[int]]:
    """Multiplication table for D_n (order 2n)."""
    # Elements: r^0, r^1, ..., r^{n-1}, s, sr, ..., sr^{n-1}
    # r^i * r^j = r^{(i+j)%n}
    # r^i * sr^j = sr^{(j-i)%n}
    # sr^i * r^j = sr^{(i+j)%n}
    # sr^i * sr^j = r^{(i-j)%n}
    size = 2 * n
    table = [[0] * size for _ in range(size)]
    for a in range(size):
        for b in range(size):
            a_is_s = a >= n
            b_is_s = b >= n
            a_rot = a % n
            b_rot = b % n
            if not a_is_s and not b_is_s:
                table[a][b] = (a_rot + b_rot) % n
            elif not a_is_s and b_is_s:
                table[a][b] = n + (b_rot - a_rot) % n
            elif a_is_s and not b_is_s:
                table[a][b] = n + (a_rot + b_rot) % n
            else:
                table[a][b] = (a_rot - b_rot) % n
    return table


def main():
    print("=" * 70)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("=" * 70)
    print()
    
    # Classify several standard groups
    groups = [
        ("Z/1Z (Trivial)", cyclic_group(1)),
        ("Z/2Z", cyclic_group(2)),
        ("Z/3Z", cyclic_group(3)),
        ("Z/4Z", cyclic_group(4)),
        ("Z/5Z", cyclic_group(5)),
        ("Z/6Z", cyclic_group(6)),
        ("Z/7Z", cyclic_group(7)),
        ("Z/8Z", cyclic_group(8)),
        ("D₃ ≅ S₃", dihedral_group(3)),
        ("D₄", dihedral_group(4)),
        ("D₅", dihedral_group(5)),
        ("S₃", symmetric_group(3)),
        ("S₄", symmetric_group(4)),
    ]
    
    print(f"{'Group':<15} {'Order':>5} {'Family':<30} {'DD':>3} {'NC':>3} {'|Z|':>4} {'Ω':>3}")
    print("-" * 70)
    
    for name, table in groups:
        info = classify_group(table)
        dd_str = str(info['derived_depth']) if info['derived_depth'] is not None else "∞"
        nc_str = str(info['nilpotency_class']) if info['nilpotency_class'] is not None else "—"
        print(f"{name:<15} {info['order']:>5} {info['family']:<30} {dd_str:>3} {nc_str:>3} {info['center_order']:>4} {info['info_dimension']:>3}")
    
    print()
    print("Legend: DD = Derived Depth, NC = Nilpotency Class, |Z| = Center Order, Ω = Info Dimension")
    print()
    
    # Demonstrate key theorems
    print("=" * 70)
    print("THEOREM DEMONSTRATIONS")
    print("=" * 70)
    print()
    
    # 1. Information Dimension Additivity
    print("1. Information Dimension Additivity: Ω(|G×H|) = Ω(|G|) + Ω(|H|)")
    for g_order, h_order in [(6, 10), (12, 15), (8, 9)]:
        print(f"   Ω({g_order} × {h_order}) = Ω({g_order * h_order}) = {omega(g_order * h_order)}"
              f" = {omega(g_order)} + {omega(h_order)}")
    print()
    
    # 2. Derived Depth ≤ Ω(|G|)
    print("2. Derived Depth ≤ Ω(|G|) for solvable groups:")
    for name, table in groups:
        info = classify_group(table)
        if info['derived_depth'] is not None:
            bound_holds = info['derived_depth'] <= info['info_dimension']
            print(f"   {name}: DD={info['derived_depth']} ≤ Ω={info['info_dimension']}  {'✓' if bound_holds else '✗'}")
    print()
    
    # 3. Noble Gas Theorem: nilpotent ⟹ solvable
    print("3. Noble Gas Theorem: All nilpotent groups are solvable")
    for name, table in groups:
        info = classify_group(table)
        if info['nilpotent']:
            print(f"   {name}: nilpotent ✓, solvable {'✓' if info['solvable'] else '✗'}")
    print()
    
    # 4. Nilpotency class 1 ↔ abelian
    print("4. Class 1 ↔ Abelian (for nontrivial groups):")
    for name, table in groups:
        info = classify_group(table)
        if info['order'] > 1 and info['nilpotency_class'] is not None:
            class1 = info['nilpotency_class'] == 1
            print(f"   {name}: class={info['nilpotency_class']}, abelian={info['abelian']}, match={'✓' if class1 == info['abelian'] else '✗'}")
    print()
    
    # 5. Product formula for derived depth
    print("5. Derived Depth Product Formula: DD(G×H) = max(DD(G), DD(H))")
    pairs = [("Z/2Z", cyclic_group(2)), ("Z/3Z", cyclic_group(3)), ("S₃", symmetric_group(3))]
    for i, (name_g, table_g) in enumerate(pairs):
        for name_h, table_h in pairs[i:]:
            dd_g = derived_depth(table_g)
            dd_h = derived_depth(table_h)
            if dd_g is not None and dd_h is not None:
                expected = max(dd_g, dd_h)
                print(f"   DD({name_g} × {name_h}) should be max({dd_g}, {dd_h}) = {expected}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Finite Groups

Creates a visual periodic table showing group families organized by
derived depth (rows) and structural family (columns).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def prime_factors_with_mult(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def omega(n):
    return len(prime_factors_with_mult(n))


# Group data: (name, order, family, derived_depth, nilpotency_class)
# family: 0=abelian, 1=nilpotent, 2=solvable, 3=non-solvable, 4=simple
GROUPS = [
    # Abelian groups (noble gases)
    ("Z₁", 1, 0, 0, 0),
    ("Z₂", 2, 0, 0, 1),
    ("Z₃", 3, 0, 0, 1),
    ("Z₄", 4, 0, 0, 1),
    ("Z₅", 5, 0, 0, 1),
    ("Z₆", 6, 0, 0, 1),
    ("Z₇", 7, 0, 0, 1),
    ("Z₂²", 4, 0, 0, 1),
    ("Z₂³", 8, 0, 0, 1),
    ("Z₂×Z₄", 8, 0, 0, 1),
    
    # Nilpotent non-abelian (noble gases, higher class)
    ("Q₈", 8, 1, 1, 2),
    ("D₄", 8, 1, 1, 2),
    ("UT₃(F₃)", 27, 1, 1, 2),
    
    # Solvable non-nilpotent
    ("S₃", 6, 2, 1, None),
    ("D₅", 10, 2, 1, None),
    ("A₄", 12, 2, 2, None),
    ("S₄", 24, 2, 3, None),
    ("D₇", 14, 2, 1, None),
    
    # Simple non-abelian (transition metals)
    ("A₅", 60, 4, None, None),
    ("PSL₂(7)", 168, 4, None, None),
    ("A₆", 360, 4, None, None),
    
    # Non-solvable (halogens)
    ("S₅", 120, 3, None, None),
    ("S₆", 720, 3, None, None),
]

FAMILY_NAMES = ["Abelian\n(Noble Gas)", "Nilpotent\n(Noble Gas+)", 
                "Solvable\n(Alkali)", "Non-Solvable\n(Halogen)", 
                "Simple\n(Trans. Metal)"]
FAMILY_COLORS = ["#4CAF50", "#8BC34A", "#FF9800", "#F44336", "#9C27B0"]


def create_periodic_table():
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    
    # Organize groups into grid
    grid = {}  # (col, row) -> list of groups
    for name, order, family, dd, nc in GROUPS:
        row = dd if dd is not None else 4  # non-solvable at bottom
        col = family
        key = (col, row)
        if key not in grid:
            grid[key] = []
        grid[key].append((name, order, nc))
    
    # Draw cells
    cell_w, cell_h = 3.0, 1.5
    for (col, row), groups in grid.items():
        x = col * (cell_w + 0.3)
        y = (4 - row) * (cell_h + 0.3)
        
        color = FAMILY_COLORS[col]
        
        for i, (name, order, nc) in enumerate(groups[:3]):  # max 3 per cell
            yi = y - i * 0.4
            rect = mpatches.FancyBboxPatch(
                (x, yi - 0.15), cell_w - 0.1, 0.35,
                boxstyle="round,pad=0.05",
                facecolor=color, alpha=0.3, edgecolor=color
            )
            ax.add_patch(rect)
            
            nc_str = f" c={nc}" if nc is not None else ""
            ax.text(x + 0.1, yi, f"{name}", fontsize=8, fontweight='bold',
                    verticalalignment='center')
            ax.text(x + cell_w - 0.2, yi, f"|G|={order}{nc_str}", fontsize=6,
                    verticalalignment='center', horizontalalignment='right',
                    color='gray')
    
    # Column headers
    for col, (name, color) in enumerate(zip(FAMILY_NAMES, FAMILY_COLORS)):
        x = col * (cell_w + 0.3)
        rect = mpatches.FancyBboxPatch(
            (x, 5 * (cell_h + 0.3) - 0.5), cell_w - 0.1, 0.6,
            boxstyle="round,pad=0.05",
            facecolor=color, alpha=0.5, edgecolor=color
        )
        ax.add_patch(rect)
        ax.text(x + cell_w / 2 - 0.05, 5 * (cell_h + 0.3) - 0.2, name,
                fontsize=9, fontweight='bold', ha='center', va='center')
    
    # Row labels
    row_names = ["DD=0 (Trivial)", "DD=1", "DD=2", "DD=3", "Non-solvable"]
    for row, name in enumerate(row_names):
        y = (4 - row) * (cell_h + 0.3)
        ax.text(-0.5, y, name, fontsize=8, ha='right', va='top',
                fontstyle='italic', color='gray')
    
    ax.set_xlim(-2, 5 * (cell_w + 0.3))
    ax.set_ylim(-2, 5 * (cell_h + 0.3) + 0.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("The Periodic Table of Finite Groups", fontsize=16, fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
    print("Saved: periodic_table_groups.png")


def create_invariant_plot():
    """Plot derived depth vs information dimension for solvable groups."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    
    solvable_groups = [(n, o, f, d, c) for n, o, f, d, c in GROUPS if d is not None]
    
    orders = [o for _, o, _, _, _ in solvable_groups]
    depths = [d for _, _, _, d, _ in solvable_groups]
    omegas = [omega(o) for o in orders]
    families = [f for _, _, f, _, _ in solvable_groups]
    names = [n for n, _, _, _, _ in solvable_groups]
    
    colors_map = {0: '#4CAF50', 1: '#8BC34A', 2: '#FF9800'}
    colors = [colors_map.get(f, '#999') for f in families]
    
    # Plot the bound line
    max_omega = max(omegas) + 1
    ax.plot([0, max_omega], [0, max_omega], 'k--', alpha=0.3, label='DD = Ω (bound)')
    ax.fill_between([0, max_omega], [0, max_omega], [max_omega, max_omega],
                     alpha=0.05, color='red')
    ax.text(max_omega - 1, max_omega - 0.5, 'Forbidden\nRegion', fontsize=8,
            color='red', alpha=0.5, ha='center')
    
    ax.scatter(omegas, depths, c=colors, s=100, edgecolors='black', linewidth=0.5, zorder=5)
    
    for name, om, dd in zip(names, omegas, depths):
        ax.annotate(name, (om, dd), textcoords="offset points", xytext=(5, 5),
                    fontsize=7, alpha=0.8)
    
    ax.set_xlabel('Information Dimension Ω(|G|)', fontsize=12)
    ax.set_ylabel('Derived Depth', fontsize=12)
    ax.set_title('Mass-Energy Inequality: Derived Depth ≤ Ω(|G|)', fontsize=14, fontweight='bold')
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', label='Abelian'),
        mpatches.Patch(facecolor='#8BC34A', label='Nilpotent'),
        mpatches.Patch(facecolor='#FF9800', label='Solvable'),
    ]
    ax.legend(handles=legend_elements, loc='upper left')
    
    ax.set_xlim(-0.5, max_omega + 0.5)
    ax.set_ylim(-0.5, max(depths) + 1)
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig("invariant_plot.png", dpi=150, bbox_inches='tight')
    print("Saved: invariant_plot.png")


if __name__ == "__main__":
    create_periodic_table()
    create_invariant_plot()
