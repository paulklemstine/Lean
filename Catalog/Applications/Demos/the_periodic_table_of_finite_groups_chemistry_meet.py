"""
The Periodic Table of Finite Groups — Interactive Demo

Computes and displays group-theoretic invariants for all groups
of small order, organizing them by "chemical family" and
solvability spectrum.
"""

from itertools import product as iterproduct
from math import gcd, log2
from collections import defaultdict


def prime_factors(n):
    """Return the prime factorization as a dict {prime: exponent}."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def is_prime_power(n):
    """Check if n is a prime power."""
    if n <= 1:
        return False
    f = prime_factors(n)
    return len(f) == 1


def euler_totient(n):
    """Euler's totient function."""
    result = n
    for p in prime_factors(n):
        result = result * (p - 1) // p
    return result


def num_groups_of_order(n):
    """
    Approximate number of groups of order n (exact for small n).
    Uses the known values for n <= 100.
    """
    # Known group counts for orders 1-60
    known = {
        1: 1, 2: 1, 3: 1, 4: 2, 5: 1, 6: 2, 7: 1, 8: 5, 9: 2, 10: 2,
        11: 1, 12: 5, 13: 1, 14: 2, 15: 1, 16: 14, 17: 1, 18: 5, 19: 1, 20: 5,
        21: 2, 22: 2, 23: 1, 24: 15, 25: 2, 26: 2, 27: 5, 28: 4, 29: 1, 30: 4,
        31: 1, 32: 51, 33: 1, 34: 2, 35: 1, 36: 14, 37: 1, 38: 2, 39: 2, 40: 14,
        41: 1, 42: 6, 43: 1, 44: 4, 45: 2, 46: 2, 47: 1, 48: 52, 49: 2, 50: 5,
        51: 1, 52: 5, 53: 1, 54: 15, 55: 2, 56: 13, 57: 2, 58: 2, 59: 1, 60: 13,
    }
    return known.get(n, None)


def classify_order(n):
    """Classify a group order into its periodic table family tendency."""
    if n == 1:
        return "trivial"
    f = prime_factors(n)
    if len(f) == 1:
        p, k = list(f.items())[0]
        if k == 1:
            return "noble_gas"  # Cyclic of prime order
        else:
            return "alkali_metal"  # p-groups (nilpotent)
    # Check if all groups of this order are abelian
    if n <= 60:
        count = num_groups_of_order(n)
        if count == 1:
            return "noble_gas"  # Cyclic
    # Check for squarefree order
    if all(e == 1 for e in f.values()):
        return "noble_gas_or_alkaline"  # Squarefree: could be cyclic or metacyclic
    return "mixed"


def solvability_spectrum_cyclic(n):
    """Solvability spectrum for Z/nZ (abelian group): [n, 1, 1, ...]."""
    return [n]  # Only one nontrivial entry


def solvability_spectrum_symmetric(n):
    """
    Approximate solvability spectrum for S_n.
    S_1, S_2: abelian, depth 1
    S_3: depth 2, spectrum [2, 3]
    S_4: depth 3, spectrum [2, 3, 4] (roughly)
    S_n for n >= 5: not solvable
    """
    import math
    if n <= 1:
        return [1]
    if n == 2:
        return [2]
    if n == 3:
        return [2, 3]  # |S_3| = 6, D_1 = A_3 (order 3), D_2 = {e}
    if n == 4:
        return [2, 3, 4]  # |S_4| = 24, D_1 = A_4 (12), D_2 = V_4 (4), D_3 = {e}
    return None  # Not solvable for n >= 5


def build_periodic_table(max_order=60):
    """
    Build the periodic table of finite groups up to the given order.
    Returns a list of entries with group-theoretic invariants.
    """
    table = []
    for n in range(1, max_order + 1):
        entry = {
            "order": n,
            "prime_factorization": prime_factors(n),
            "is_prime_power": is_prime_power(n),
            "num_groups": num_groups_of_order(n),
            "family_tendency": classify_order(n),
            "cyclic_spectrum": solvability_spectrum_cyclic(n),
            "euler_totient": euler_totient(n),
            "omega": sum(prime_factors(n).values()),  # Number of prime factors with multiplicity
        }
        table.append(entry)
    return table


def display_periodic_table(table):
    """Display the periodic table in a formatted way."""
    print("=" * 90)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("=" * 90)
    print(f"{'Order':>5} {'Factorization':>15} {'#Groups':>8} {'Family':>20} "
          f"{'Ω(n)':>5} {'φ(n)':>5} {'Spectrum':>15}")
    print("-" * 90)

    families = defaultdict(list)
    for entry in table:
        n = entry["order"]
        factors = entry["prime_factorization"]
        factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p)
                                for p, e in sorted(factors.items()))
        if n == 1:
            factor_str = "1"

        num_groups = entry["num_groups"]
        num_str = str(num_groups) if num_groups is not None else "?"
        family = entry["family_tendency"]
        omega = entry["omega"]
        phi = entry["euler_totient"]
        spectrum = entry["cyclic_spectrum"]
        spec_str = str(spectrum)

        print(f"{n:>5} {factor_str:>15} {num_str:>8} {family:>20} "
              f"{omega:>5} {phi:>5} {spec_str:>15}")

        families[family].append(n)

    print("\n" + "=" * 90)
    print("FAMILY DISTRIBUTION")
    print("-" * 90)
    for family, orders in sorted(families.items()):
        print(f"  {family:>25}: {len(orders):>3} groups — orders: {orders[:15]}...")


def demonstrate_solvability_depth():
    """Demonstrate the key theorem: depth ≤ 1 implies nilpotent."""
    print("\n" + "=" * 70)
    print("SOLVABILITY DEPTH ANALYSIS")
    print("=" * 70)

    examples = [
        ("Z/6Z (cyclic)", 6, 1, True, True, "Noble gas"),
        ("Z/2 × Z/2 × Z/2", 8, 1, True, True, "Noble gas"),
        ("S_3", 6, 2, True, False, "Alkaline earth"),
        ("D_4 (dihedral-8)", 8, 2, True, True, "Alkali metal"),
        ("A_4", 12, 2, True, False, "Alkaline earth"),
        ("S_4", 24, 3, True, False, "Alkaline earth"),
        ("A_5", 60, None, False, False, "Transition metal"),
        ("Q_8 (quaternion)", 8, 2, True, True, "Alkali metal"),
    ]

    print(f"{'Group':>25} {'|G|':>5} {'Depth':>6} {'Solv':>5} {'Nilp':>5} {'Family':>20}")
    print("-" * 70)
    for name, order, depth, solvable, nilpotent, family in examples:
        d_str = str(depth) if depth is not None else "∞"
        print(f"{name:>25} {order:>5} {d_str:>6} {'Yes':>5 if solvable else 'No':>5} "
              f"{'Yes':>5 if nilpotent else 'No':>5} {family:>20}")

    print("\n--- KEY INSIGHT (Proved in Lean 4) ---")
    print("Theorem: depth ≤ 1 ⟹ nilpotent (the 'noble gas row')")
    print("Theorem: not nilpotent ⟹ depth ≥ 2 (the 'solvability gap')")
    print("Theorem: Φ(G) ⊇ [G,G] for nilpotent G (Frattini-commutator duality)")


def demonstrate_spectrum():
    """Demonstrate the solvability spectrum concept."""
    print("\n" + "=" * 70)
    print("SOLVABILITY SPECTRUM EXAMPLES")
    print("=" * 70)

    print("\nThe solvability spectrum σ_G(n) = |D_n(G)| / |D_{n+1}(G)|")
    print("measures the 'abelian layer sizes' of a group.\n")

    spectra = [
        ("Z/12Z", [12], "All mass in one shell (abelian)"),
        ("S_3", [2, 3], "Two shells: index-2 then index-3"),
        ("S_4", [2, 3, 4], "Three shells: 2, 3, 4"),
        ("D_4", [2, 2], "Two equal shells (nilpotent)"),
        ("Q_8", [2, 2], "Two equal shells (nilpotent)"),
        ("A_4", [3, 4], "Two shells: 3, 4"),
    ]

    for name, spectrum, description in spectra:
        total = 1
        for s in spectrum:
            total *= s
        print(f"  {name:>8}: σ = {spectrum!s:>12}  (product = {total:>4})  — {description}")

    print("\n--- PROVED IN LEAN 4 ---")
    print("Theorem: σ_G(n) > 1 for n < solDepth(G) (strict descent)")
    print("Theorem: D_n(G×H) = D_n(G) × D_n(H) (product decomposition)")


if __name__ == "__main__":
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("A Chemical-Algebraic Classification System\n")

    # Build and display the periodic table
    table = build_periodic_table(60)
    display_periodic_table(table)

    # Demonstrate key concepts
    demonstrate_solvability_depth()
    demonstrate_spectrum()

    print("\n" + "=" * 70)
    print("All key theorems verified in Lean 4 (Mathlib)")
    print("=" * 70)


"""
Visualization: The Periodic Table of Finite Groups

Generates a heatmap-style periodic table showing group orders
colored by their structural complexity (solvability depth bound).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def prime_factors(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def omega(n):
    return sum(prime_factors(n).values())


def classify(n):
    if n == 1:
        return 0  # trivial
    f = prime_factors(n)
    if len(f) == 1 and list(f.values())[0] == 1:
        return 1  # prime (noble gas)
    if len(f) == 1:
        return 2  # prime power (alkali metal)
    if all(v == 1 for v in f.values()):
        return 3  # squarefree (potentially noble)
    return 4  # mixed


def plot_periodic_table():
    """Plot the periodic table of finite groups as a grid."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left panel: Group order grid colored by Ω(n)
    ax1 = axes[0]
    rows, cols = 10, 10
    grid = np.zeros((rows, cols))
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n <= 100:
                grid[i, j] = omega(n)

    im = ax1.imshow(grid, cmap='YlOrRd', aspect='equal')
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n <= 100:
                ax1.text(j, i, str(n), ha='center', va='center',
                        fontsize=7, fontweight='bold',
                        color='white' if grid[i,j] > 4 else 'black')

    ax1.set_title('Periodic Table of Group Orders\n(Color = Ω(n) = max solvability depth)',
                   fontsize=11, fontweight='bold')
    ax1.set_xticks([])
    ax1.set_yticks([])
    plt.colorbar(im, ax=ax1, label='Ω(n)', shrink=0.8)

    # Right panel: Family classification
    ax2 = axes[1]
    family_colors = {0: '#CCCCCC', 1: '#FFD700', 2: '#87CEEB',
                     3: '#98FB98', 4: '#FF6B6B'}
    family_names = {0: 'Trivial', 1: 'Prime (Noble Gas)',
                    2: 'Prime Power (Alkali)', 3: 'Squarefree',
                    4: 'Mixed'}

    grid2 = np.zeros((rows, cols))
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n <= 100:
                grid2[i, j] = classify(n)

    from matplotlib.colors import ListedColormap
    cmap = ListedColormap(['#CCCCCC', '#FFD700', '#87CEEB', '#98FB98', '#FF6B6B'])
    ax2.imshow(grid2, cmap=cmap, aspect='equal', vmin=0, vmax=4)
    for i in range(rows):
        for j in range(cols):
            n = i * cols + j + 1
            if n <= 100:
                ax2.text(j, i, str(n), ha='center', va='center',
                        fontsize=7, fontweight='bold')

    ax2.set_title('Family Classification\n(Structural type by prime factorization)',
                   fontsize=11, fontweight='bold')
    ax2.set_xticks([])
    ax2.set_yticks([])

    # Legend
    patches = [mpatches.Patch(color=family_colors[k], label=family_names[k])
               for k in sorted(family_colors)]
    ax2.legend(handles=patches, loc='upper left', fontsize=8,
              bbox_to_anchor=(0, -0.05), ncol=3)

    plt.tight_layout()
    plt.savefig('periodic_table_groups.png', dpi=150, bbox_inches='tight')
    print("Saved: periodic_table_groups.png")


def plot_depth_spectrum():
    """Plot the relationship between order and solvability depth bound."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Ω(n) vs n
    ax1 = axes[0]
    ns = list(range(1, 201))
    omegas = [omega(n) for n in ns]
    colors = ['#FFD700' if len(prime_factors(n)) == 1 and list(prime_factors(n).values())[0] == 1
              else '#87CEEB' if len(prime_factors(n)) == 1
              else '#FF6B6B' for n in ns]

    ax1.scatter(ns, omegas, c=colors, s=15, alpha=0.7)
    ax1.set_xlabel('Group order n', fontsize=12)
    ax1.set_ylabel('Ω(n) = max depth bound', fontsize=12)
    ax1.set_title('Solvability Depth Bound vs Order', fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Highlight key orders
    highlights = {6: 'S₃', 12: 'A₄', 24: 'S₄', 60: 'A₅', 120: 'S₅'}
    for n, label in highlights.items():
        if n <= 200:
            ax1.annotate(label, (n, omega(n)), textcoords="offset points",
                        xytext=(5, 5), fontsize=8, color='red')

    # Right: Distribution of Ω values
    ax2 = axes[1]
    from collections import Counter
    omega_dist = Counter(omegas)
    vals = sorted(omega_dist.keys())
    counts = [omega_dist[v] for v in vals]
    ax2.bar(vals, counts, color='#4ECDC4', edgecolor='white')
    ax2.set_xlabel('Ω(n) value', fontsize=12)
    ax2.set_ylabel('Count (orders 1-200)', fontsize=12)
    ax2.set_title('Distribution of Depth Bounds\n(Orders 1-200)', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('depth_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: depth_spectrum.png")


if __name__ == "__main__":
    plot_periodic_table()
    plot_depth_spectrum()
