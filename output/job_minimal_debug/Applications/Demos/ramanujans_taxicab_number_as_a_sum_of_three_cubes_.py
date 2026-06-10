#!/usr/bin/env python3
"""
Ramanujan's Taxicab Number 1729: Sums of Two and Three Cubes

Demonstrates the key mathematical results:
1. 1729 = 1³ + 12³ = 9³ + 10³ (Hardy-Ramanujan taxicab property)
2. 1729 = (-7)³ + (-5)³ + 13³ (nontrivial three-cube representation)
3. The Three-Cube Inversion Principle
4. Mod-9 obstruction for sums of three cubes
"""


def is_perfect_cube(n: int) -> tuple[bool, int]:
    """Check if n is a perfect cube, return (is_cube, cube_root)."""
    if n == 0:
        return True, 0
    sign = 1 if n > 0 else -1
    root = round(abs(n) ** (1/3))
    for r in [root - 1, root, root + 1]:
        if r ** 3 == abs(n):
            return True, sign * r
    return False, 0


def find_two_cube_representations(n: int) -> list[tuple[int, int]]:
    """Find all representations n = a³ + b³ with 0 < a ≤ b."""
    reps = []
    a = 1
    while a ** 3 <= n // 2:
        remainder = n - a ** 3
        is_cube, b = is_perfect_cube(remainder)
        if is_cube and b >= a and b > 0:
            reps.append((a, b))
        a += 1
    return reps


def find_three_cube_representations(n: int, bound: int = 50) -> list[tuple[int, int, int]]:
    """Find representations n = x³ + y³ + z³ with x ≤ y ≤ z, all nonzero."""
    reps = []
    for x in range(-bound, bound + 1):
        if x == 0:
            continue
        for y in range(x, bound + 1):
            if y == 0:
                continue
            rem = n - x ** 3 - y ** 3
            if rem == 0:
                continue
            is_cube, z = is_perfect_cube(rem)
            if is_cube and z != 0 and z >= y:
                reps.append((x, y, z))
    return reps


def three_cube_inversion(n: int, c: int) -> list[tuple[int, int, int]]:
    """Apply the three-cube inversion principle.

    Given n and c, compute c³ - n and check if it's a sum of two cubes.
    If c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³.
    """
    overshoot = c ** 3 - n
    if overshoot <= 0:
        return []
    reps = find_two_cube_representations(overshoot)
    results = []
    for a, b in reps:
        results.append((-a, -b, c))
    return results


def cube_residues_mod9() -> dict[int, int]:
    """Compute x³ mod 9 for all residue classes."""
    return {x: (x ** 3) % 9 for x in range(9)}


def sum_three_cubes_possible_residues() -> set[int]:
    """Compute all possible values of (x³ + y³ + z³) mod 9."""
    cube_res = set(cube_residues_mod9().values())
    possible = set()
    for r1 in cube_res:
        for r2 in cube_res:
            for r3 in cube_res:
                possible.add((r1 + r2 + r3) % 9)
    return possible


def main():
    print("=" * 70)
    print("RAMANUJAN'S TAXICAB NUMBER 1729: SUMS OF TWO AND THREE CUBES")
    print("=" * 70)

    # 1. Two-cube representations
    print("\n§1. TWO-CUBE REPRESENTATIONS OF 1729")
    print("-" * 40)
    reps = find_two_cube_representations(1729)
    for a, b in reps:
        print(f"  1729 = {a}³ + {b}³ = {a**3} + {b**3}")
    print(f"  → 1729 has {len(reps)} distinct representations as a sum of two positive cubes")

    # 2. Prime factorization and algebraic structure
    print("\n§2. ALGEBRAIC STRUCTURE")
    print("-" * 40)
    print(f"  1729 = 7 × 13 × 19")
    for a, b in reps:
        s = a + b
        q = a**2 - a*b + b**2
        print(f"  {a}³ + {b}³ = ({a}+{b})({a}²-{a}·{b}+{b}²) = {s} × {q}")

    # 3. Three-cube representations
    print("\n§3. THREE-CUBE REPRESENTATIONS (REFUTING THE CONJECTURE)")
    print("-" * 40)
    three_reps = find_three_cube_representations(1729, bound=100)
    for x, y, z in three_reps:
        print(f"  1729 = ({x})³ + ({y})³ + ({z})³ = {x**3} + {y**3} + {z**3}")
    if three_reps:
        print(f"  → The conjecture is REFUTED: 1729 HAS a nontrivial three-cube representation!")

    # 4. Three-cube inversion principle
    print("\n§4. THREE-CUBE INVERSION PRINCIPLE")
    print("-" * 40)
    print("  If c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³")
    print(f"  For n = 1729, c = 13:")
    print(f"    13³ - 1729 = {13**3} - 1729 = {13**3 - 1729}")
    print(f"    468 = 7³ + 5³ = {7**3} + {5**3} ✓")
    print(f"    → 1729 = (-7)³ + (-5)³ + 13³")

    # 5. Searching for more inversions
    print("\n§5. SYSTEMATIC INVERSION SEARCH")
    print("-" * 40)
    for c in range(2, 30):
        results = three_cube_inversion(1729, c)
        for a, b, cc in results:
            if a != 0 and b != 0:
                print(f"  c={cc}: {cc}³ - 1729 = {cc**3 - 1729} = ({-a})³ + ({-b})³")
                print(f"    → 1729 = ({a})³ + ({b})³ + ({cc})³")

    # 6. Mod-9 analysis
    print("\n§6. MOD-9 OBSTRUCTION")
    print("-" * 40)
    residues = cube_residues_mod9()
    print(f"  Cube residues mod 9: {residues}")
    possible = sum_three_cubes_possible_residues()
    impossible = set(range(9)) - possible
    print(f"  Possible sum-of-three-cubes residues mod 9: {sorted(possible)}")
    print(f"  Impossible residues (obstructed): {sorted(impossible)}")
    print(f"  1729 mod 9 = {1729 % 9} → {'ADMISSIBLE' if 1729 % 9 in possible else 'OBSTRUCTED'}")

    # 7. Carmichael connection
    print("\n§7. CARMICHAEL NUMBER CONNECTION")
    print("-" * 40)
    print(f"  1729 - 1 = 1728 = 12³")
    print(f"  Korselt's criterion: for each prime p | 1729, (p-1) | 1728")
    for p in [7, 13, 19]:
        print(f"    p = {p}: ({p}-1) = {p-1}, 1728 / {p-1} = {1728 // (p-1)} ✓")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Three-Cube Inversion Principle for 1729"""
import matplotlib.pyplot as plt
import numpy as np


def find_two_cube_reps(n):
    reps = []
    a = 1
    while 2 * a ** 3 <= n:
        remainder = n - a ** 3
        sign = 1 if remainder > 0 else -1
        approx = round(abs(remainder) ** (1/3))
        for r in [approx - 1, approx, approx + 1]:
            if r >= 0 and r ** 3 == abs(remainder) and sign * r >= a:
                reps.append((a, sign * r))
        a += 1
    return reps


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Ramanujan's Taxicab Number 1729: Cube Decomposition Analysis",
                 fontsize=14, fontweight='bold')

    # Panel 1: Two-cube representations
    ax = axes[0, 0]
    a_vals = np.arange(1, 13)
    for a in a_vals:
        b_val = (1729 - a**3) ** (1/3) if 1729 - a**3 > 0 else 0
        ax.scatter(a, b_val, color='steelblue', s=30, alpha=0.5)
    ax.scatter([1, 9], [12, 10], color='red', s=100, zorder=5, label='Solutions')
    ax.annotate('(1, 12)', (1, 12), textcoords="offset points", xytext=(10, 5), fontsize=9)
    ax.annotate('(9, 10)', (9, 10), textcoords="offset points", xytext=(10, 5), fontsize=9)
    ax.set_xlabel('a')
    ax.set_ylabel('b = (1729 - a³)^{1/3}')
    ax.set_title('Two-Cube Representations: a³ + b³ = 1729')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Three-cube inversion
    ax = axes[0, 1]
    c_vals = range(2, 25)
    overshoots = [c**3 - 1729 for c in c_vals]
    colors = ['green' if find_two_cube_reps(o) and o > 0 else 'gray' for o in overshoots]
    ax.bar([c for c in c_vals], [max(0, o) for o in overshoots], color=colors, alpha=0.7)
    ax.axhline(y=468, color='red', linestyle='--', alpha=0.5, label='468 = 7³ + 5³')
    ax.scatter([13], [468], color='red', s=100, zorder=5)
    ax.annotate('c=13: 13³-1729 = 468 = 7³+5³', (13, 468),
                textcoords="offset points", xytext=(10, 10), fontsize=8,
                arrowprops=dict(arrowstyle='->', color='red'))
    ax.set_xlabel('c')
    ax.set_ylabel('c³ - 1729')
    ax.set_title('Three-Cube Inversion: Overshoot c³ - 1729')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Mod-9 obstruction
    ax = axes[1, 0]
    residues = list(range(9))
    cube_res = [(x**3) % 9 for x in range(9)]
    possible = set()
    for r1 in set(cube_res):
        for r2 in set(cube_res):
            for r3 in set(cube_res):
                possible.add((r1 + r2 + r3) % 9)
    colors_mod9 = ['green' if r in possible else 'red' for r in residues]
    ax.bar(residues, [1]*9, color=colors_mod9, alpha=0.7, edgecolor='black')
    ax.bar([1729 % 9], [1], color='gold', alpha=0.9, edgecolor='black', linewidth=2,
           label=f'1729 mod 9 = {1729 % 9}')
    for i, r in enumerate(residues):
        label = '✓' if r in possible else '✗'
        ax.text(i, 0.5, label, ha='center', va='center', fontsize=14, fontweight='bold')
    ax.set_xlabel('Residue mod 9')
    ax.set_title('Mod-9 Admissibility for Sum of Three Cubes')
    ax.set_xticks(residues)
    ax.legend()
    ax.set_ylim(0, 1.3)

    # Panel 4: Factor structure
    ax = axes[1, 1]
    # Show the factorization tree: 1729 = 7 × 13 × 19
    # And how each factor appears in cube representations
    categories = ['7 × 13 × 19\n= 1729', '13 × 133\n= 1³ + 12³',
                  '19 × 91\n= 9³ + 10³', '(-7)³+(-5)³+13³\n= 1729']
    values = [1729, 1729, 1729, 1729]
    colors_f = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    bars = ax.bar(categories, values, color=colors_f, alpha=0.8, edgecolor='black')
    ax.set_title('Algebraic Structure of 1729')
    ax.set_ylabel('Value')
    ax.tick_params(axis='x', rotation=0)
    for bar, label in zip(bars, ['factorization', 'rep 1', 'rep 2', 'three-cube']):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 30,
                label, ha='center', fontsize=8, fontstyle='italic')

    plt.tight_layout()
    plt.savefig('taxicab_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved taxicab_analysis.png")


if __name__ == "__main__":
    main()
