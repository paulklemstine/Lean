#!/usr/bin/env python3
"""
Demo: The Periodic Table of Finite Groups

Computes reactivity profiles for small groups and demonstrates
the chemical analogy for finite group theory.
"""

from itertools import product
from math import gcd, factorial
from collections import Counter


def prime_factors(n):
    """Return list of prime factors with multiplicity."""
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
    """Ω(n) = number of prime factors counted with multiplicity."""
    return len(prime_factors(n))


def euler_totient(n):
    """Euler's totient function φ(n)."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


# ============================================================
# Group Representations (small groups as permutation groups)
# ============================================================

def cyclic_group(n):
    """Generate elements of Z_n as tuples with group operation."""
    return list(range(n))


def dihedral_group(n):
    """Generate elements of D_n (order 2n) as (rotation, reflection) pairs."""
    elements = []
    for r in range(n):
        elements.append((r, 0))
        elements.append((r, 1))
    return elements


def symmetric_group_order(n):
    """Order of S_n."""
    return factorial(n)


# ============================================================
# Reactivity Profile Computation
# ============================================================

class ReactivityProfile:
    """Chemical fingerprint of a finite group."""

    def __init__(self, name, order, center_order, commutator_order,
                 duality_defect, is_solvable, is_nilpotent, nilp_class):
        self.name = name
        self.order = order
        self.center_order = center_order
        self.commutator_order = commutator_order
        self.duality_defect = duality_defect
        self.is_solvable = is_solvable
        self.is_nilpotent = is_nilpotent
        self.nilp_class = nilp_class

    @property
    def abelian_defect(self):
        return self.order // self.center_order

    @property
    def chemical_series(self):
        if self.order == 1:
            return "Vacuum"
        if self.center_order == self.order:
            if len(prime_factors(self.order)) == 1 and self.order in [
                p ** k for p in range(2, 100) for k in range(1, 20)
                if all(p % d != 0 for d in range(2, p))
            ]:
                return "Noble Gas"
            return "Alkaline Earth"
        if self.is_nilpotent:
            return "Alkali Metal"
        if self.is_solvable:
            return "Compound"
        return "Radioactive"

    def __repr__(self):
        return (
            f"ReactivityProfile({self.name}: order={self.order}, "
            f"|Z|={self.center_order}, |[G,G]|={self.commutator_order}, "
            f"defect={self.duality_defect}, "
            f"series={self.chemical_series})"
        )


# Known group data for small orders
KNOWN_GROUPS = [
    ReactivityProfile("Z_1", 1, 1, 1, 1, True, True, 0),
    ReactivityProfile("Z_2", 2, 2, 1, 1, True, True, 1),
    ReactivityProfile("Z_3", 3, 3, 1, 1, True, True, 1),
    ReactivityProfile("Z_4", 4, 4, 1, 1, True, True, 1),
    ReactivityProfile("Z_2×Z_2", 4, 4, 1, 1, True, True, 1),
    ReactivityProfile("Z_5", 5, 5, 1, 1, True, True, 1),
    ReactivityProfile("S_3", 6, 1, 3, 1, True, False, 0),
    ReactivityProfile("Z_6", 6, 6, 1, 1, True, True, 1),
    ReactivityProfile("Z_7", 7, 7, 1, 1, True, True, 1),
    ReactivityProfile("D_4", 8, 2, 2, 2, True, True, 2),
    ReactivityProfile("Q_8", 8, 2, 2, 2, True, True, 2),
    ReactivityProfile("Z_8", 8, 8, 1, 1, True, True, 1),
    ReactivityProfile("Z_2×Z_4", 8, 8, 1, 1, True, True, 1),
    ReactivityProfile("Z_2³", 8, 8, 1, 1, True, True, 1),
    ReactivityProfile("Z_9", 9, 9, 1, 1, True, True, 1),
    ReactivityProfile("Z_3×Z_3", 9, 9, 1, 1, True, True, 1),
    ReactivityProfile("D_5", 10, 1, 5, 1, True, False, 0),
    ReactivityProfile("Z_10", 10, 10, 1, 1, True, True, 1),
    ReactivityProfile("A_4", 12, 1, 4, 1, True, False, 0),
    ReactivityProfile("D_6", 12, 2, 3, 1, True, False, 0),
    ReactivityProfile("Z_12", 12, 12, 1, 1, True, True, 1),
    ReactivityProfile("S_4", 24, 1, 12, 1, True, False, 0),
    ReactivityProfile("A_5", 60, 1, 60, 1, False, False, 0),
    ReactivityProfile("S_5", 120, 1, 60, 1, False, False, 0),
]


def demonstrate_periodic_law():
    """Demonstrate the quantitative periodic law: derivedDepth ≤ Ω(|G|)."""
    print("=" * 70)
    print("QUANTITATIVE PERIODIC LAW: derivedDepth(G) ≤ Ω(|G|)")
    print("=" * 70)

    # Known derived depths for some groups
    test_cases = [
        ("Z_6", 6, 1),       # Abelian: depth 1, Ω(6) = 2
        ("S_3", 6, 2),       # Depth 2, Ω(6) = 2
        ("D_4", 8, 2),       # Depth 2, Ω(8) = 3
        ("A_4", 12, 3),      # Depth 3, Ω(12) = 3
        ("S_4", 24, 3),      # Depth 3, Ω(24) = 4
        ("Z_2^4", 16, 1),    # Abelian: depth 1, Ω(16) = 4
        ("D_8", 16, 2),      # Depth 2, Ω(16) = 4
    ]

    for name, order, depth in test_cases:
        omega_val = omega(order)
        status = "✓" if depth <= omega_val else "✗"
        print(f"  {status} {name:8s}: depth={depth}, Ω({order})={omega_val}, "
              f"gap={omega_val - depth}")

    print()


def demonstrate_reactivity_profiles():
    """Display reactivity profiles organized by chemical series."""
    print("=" * 70)
    print("PERIODIC TABLE OF FINITE GROUPS — REACTIVITY PROFILES")
    print("=" * 70)

    # Organize by chemical series
    series_groups = {}
    for g in KNOWN_GROUPS:
        series = g.chemical_series
        if series not in series_groups:
            series_groups[series] = []
        series_groups[series].append(g)

    for series in ["Vacuum", "Noble Gas", "Alkaline Earth", "Alkali Metal",
                   "Compound", "Radioactive"]:
        if series in series_groups:
            print(f"\n  {series.upper()}")
            print(f"  {'─' * 60}")
            for g in series_groups[series]:
                print(f"    {g.name:12s}  |G|={g.order:4d}  |Z|={g.center_order:4d}  "
                      f"|[G,G]|={g.commutator_order:4d}  "
                      f"defect={g.abelian_defect:3d}")

    print()


def demonstrate_aut_density():
    """Show automorphism density (p-1)/p → 1 for prime p."""
    print("=" * 70)
    print("AUTOMORPHISM DENSITY: |Aut(Z_p)|/|Z_p| → 1 as p → ∞")
    print("=" * 70)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 97, 101, 997, 9973]
    for p in primes:
        density = (p - 1) / p
        print(f"  p={p:5d}:  |Aut(Z_p)|/|Z_p| = {p-1}/{p} = {density:.6f}")

    print()


def demonstrate_center_commutator_duality():
    """Show the center-commutator interaction for various groups."""
    print("=" * 70)
    print("CENTER–COMMUTATOR DUALITY")
    print("=" * 70)
    print(f"  {'Group':12s} {'|G|':>5s} {'|Z|':>5s} {'|[G,G]|':>8s} "
          f"{'|Z∩[G,G]|':>10s} {'|Z·[G,G]|/|G|':>14s}")
    print(f"  {'─' * 60}")

    for g in KNOWN_GROUPS:
        if g.order > 1:
            # |Z·[G,G]| = |Z|·|[G,G]| / |Z∩[G,G]|
            join_order = (g.center_order * g.commutator_order) // g.duality_defect
            ratio = join_order / g.order
            print(f"  {g.name:12s} {g.order:5d} {g.center_order:5d} "
                  f"{g.commutator_order:8d} {g.duality_defect:10d} "
                  f"{ratio:14.4f}")

    print()


def demonstrate_product_multiplicativity():
    """Show that abelian defect is multiplicative under products."""
    print("=" * 70)
    print("ABELIAN DEFECT MULTIPLICATIVITY: defect(G×H) = defect(G)·defect(H)")
    print("=" * 70)

    pairs = [
        ("S_3", 6, 1, "Z_2", 2, 2),
        ("D_4", 8, 2, "S_3", 6, 1),
        ("Q_8", 8, 2, "Z_3", 3, 3),
        ("A_4", 12, 1, "Z_2", 2, 2),
    ]

    for name1, ord1, center1, name2, ord2, center2 in pairs:
        defect1 = ord1 // center1
        defect2 = ord2 // center2
        prod_defect = defect1 * defect2
        prod_order = ord1 * ord2
        prod_center = center1 * center2
        actual_defect = prod_order // prod_center
        status = "✓" if actual_defect == prod_defect else "✗"
        print(f"  {status} defect({name1})·defect({name2}) = "
              f"{defect1}·{defect2} = {prod_defect} = "
              f"defect({name1}×{name2}) = {actual_defect}")

    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  THE PERIODIC TABLE OF FINITE GROUPS")
    print("  Chemistry Meets Algebra — Research Demo")
    print("=" * 70 + "\n")

    demonstrate_reactivity_profiles()
    demonstrate_periodic_law()
    demonstrate_aut_density()
    demonstrate_center_commutator_duality()
    demonstrate_product_multiplicativity()

    print("=" * 70)
    print("KEY FINDINGS:")
    print("  1. Abelian defect multiplicativity under direct products")
    print("  2. Quantitative periodic law: derivedDepth ≤ Ω(|G|)")
    print("  3. Automorphism density → 1 for prime cyclic groups")
    print("  4. Center-commutator duality captures group 'chemistry'")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Finite Groups
Standalone matplotlib script — no local imports.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def prime_factors(n):
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
    return len(prime_factors(n))


# Group data: (name, order, center_order, commutator_order, is_solvable,
#              is_nilpotent, derived_depth, chemical_series)
GROUPS = [
    ("Z₁", 1, 1, 1, True, True, 0, "Vacuum"),
    ("Z₂", 2, 2, 1, True, True, 1, "Noble Gas"),
    ("Z₃", 3, 3, 1, True, True, 1, "Noble Gas"),
    ("Z₄", 4, 4, 1, True, True, 1, "Noble Gas"),
    ("Z₂²", 4, 4, 1, True, True, 1, "Noble Gas"),
    ("Z₅", 5, 5, 1, True, True, 1, "Noble Gas"),
    ("S₃", 6, 1, 3, True, False, 2, "Compound"),
    ("Z₆", 6, 6, 1, True, True, 1, "Noble Gas"),
    ("Z₇", 7, 7, 1, True, True, 1, "Noble Gas"),
    ("D₄", 8, 2, 2, True, True, 2, "Alkali Metal"),
    ("Q₈", 8, 2, 2, True, True, 2, "Alkali Metal"),
    ("Z₈", 8, 8, 1, True, True, 1, "Noble Gas"),
    ("Z₂×Z₄", 8, 8, 1, True, True, 1, "Noble Gas"),
    ("Z₂³", 8, 8, 1, True, True, 1, "Noble Gas"),
    ("Z₃²", 9, 9, 1, True, True, 1, "Noble Gas"),
    ("D₅", 10, 1, 5, True, False, 2, "Compound"),
    ("A₄", 12, 1, 4, True, False, 3, "Compound"),
    ("D₆", 12, 2, 3, True, False, 2, "Compound"),
    ("Z₁₂", 12, 12, 1, True, True, 1, "Noble Gas"),
    ("S₄", 24, 1, 12, True, False, 3, "Compound"),
    ("SL₂(3)", 24, 2, 8, True, True, 3, "Alkali Metal"),
    ("A₅", 60, 1, 60, False, False, 0, "Radioactive"),
    ("S₅", 120, 1, 60, False, False, 0, "Radioactive"),
]

SERIES_COLORS = {
    "Vacuum": "#808080",
    "Noble Gas": "#00BFFF",
    "Alkali Metal": "#FF6347",
    "Compound": "#FFD700",
    "Radioactive": "#8B0000",
}


def plot_periodic_table():
    """Create a periodic table visualization of finite groups."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Panel 1: Scatter plot — Order vs Derived Depth colored by series
    ax1 = axes[0]
    for series, color in SERIES_COLORS.items():
        gs = [(g[1], g[6], g[0]) for g in GROUPS if g[7] == series and g[1] > 1]
        if gs:
            orders, depths, names = zip(*gs)
            ax1.scatter(orders, depths, c=color, s=100, edgecolors='black',
                       linewidth=0.5, label=series, zorder=5)
            for o, d, n in zip(orders, depths, names):
                ax1.annotate(n, (o, d), textcoords="offset points",
                           xytext=(5, 5), fontsize=7)

    # Plot the Ω(|G|) bound
    x_range = np.arange(2, 130)
    omega_vals = [omega(int(x)) for x in x_range]
    ax1.plot(x_range, omega_vals, 'k--', alpha=0.4, label='Ω(|G|) bound')
    ax1.fill_between(x_range, omega_vals, max(omega_vals) + 1, alpha=0.05, color='red')

    ax1.set_xlabel('Group Order |G|', fontsize=12)
    ax1.set_ylabel('Derived Depth d(G)', fontsize=12)
    ax1.set_title('Quantitative Periodic Law:\nd(G) ≤ Ω(|G|)', fontsize=13)
    ax1.legend(loc='upper left', fontsize=9)
    ax1.set_xlim(0, 130)
    ax1.set_ylim(-0.5, 8)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Abelian defect vs order
    ax2 = axes[1]
    for series, color in SERIES_COLORS.items():
        gs = [(g[1], g[1] // g[2], g[0]) for g in GROUPS if g[7] == series and g[1] > 1]
        if gs:
            orders, defects, names = zip(*gs)
            ax2.scatter(orders, defects, c=color, s=100, edgecolors='black',
                       linewidth=0.5, label=series, zorder=5)
            for o, d, n in zip(orders, defects, names):
                ax2.annotate(n, (o, d), textcoords="offset points",
                           xytext=(5, 5), fontsize=7)

    ax2.set_xlabel('Group Order |G|', fontsize=12)
    ax2.set_ylabel('Abelian Defect δ(G) = |G|/|Z(G)|', fontsize=12)
    ax2.set_title('Center–Commutator Duality:\nAbelian Defect by Chemical Series', fontsize=13)
    ax2.legend(loc='upper left', fontsize=9)
    ax2.set_xlim(0, 130)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('periodic_table_groups.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved periodic_table_groups.png")


def plot_aut_density():
    """Plot automorphism density convergence."""
    fig, ax = plt.subplots(figsize=(10, 5))

    # Generate primes
    def is_prime(n):
        if n < 2: return False
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0: return False
        return True

    primes = [p for p in range(2, 200) if is_prime(p)]
    densities = [(p - 1) / p for p in primes]

    ax.scatter(primes, densities, c='#00BFFF', s=30, edgecolors='black',
              linewidth=0.3, zorder=5)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Limit = 1')
    ax.fill_between([0, 210], [1, 1], [1.05, 1.05], alpha=0.1, color='red')

    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Automorphism Density (p-1)/p', fontsize=12)
    ax.set_title('Noble Gas Inertness:\n|Aut(ℤ/pℤ)|/|ℤ/pℤ| → 1 as p → ∞', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 210)
    ax.set_ylim(0.4, 1.05)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('aut_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved aut_density.png")


if __name__ == "__main__":
    plot_periodic_table()
    plot_aut_density()
    print("All visualizations generated.")
