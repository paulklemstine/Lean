#!/usr/bin/env python3
"""
Demo: The Periodic Table of Finite Groups

Demonstrates the chemical classification of finite groups,
the derived depth computation, and the Periodic Law Conjecture verification.
"""

from algorithms import (
    FiniteGroup, make_cyclic_group, make_dihedral_group,
    big_omega, prime_factorization, verify_periodic_law_conjecture,
    periodic_table_analysis
)


def demo_chemical_classification():
    """Demonstrate chemical series classification for various groups."""
    print("=" * 70)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("Chemical Series Classification")
    print("=" * 70)

    groups = []

    # Noble Gases: Cyclic groups
    for n in [2, 3, 5, 7, 11, 13]:
        g = make_cyclic_group(n)
        groups.append((f"Z_{n}", n, g))

    # Alkaline Earths: Products of cyclic groups (Z_2 × Z_2)
    # Z_2 × Z_2 via multiplication table
    z2z2_table = [
        [0, 1, 2, 3],
        [1, 0, 3, 2],
        [2, 3, 0, 1],
        [3, 2, 1, 0],
    ]
    groups.append(("Z_2×Z_2", 4, FiniteGroup(z2z2_table)))

    # Halogens: Dihedral groups (solvable, non-nilpotent for n ≥ 3 odd prime)
    for n in [3, 5, 7]:
        d = make_dihedral_group(n)
        groups.append((f"D_{2*n}", 2 * n, d))

    # Dihedral D_4 (nilpotent, non-abelian)
    d4 = make_dihedral_group(4)
    groups.append(("D_8", 8, d4))

    print(f"\n{'Group':12s} {'Order':>6s} {'Series':18s} {'Cyclic':>7s} "
          f"{'Abelian':>8s} {'Nilp.':>6s} {'Solv.':>6s} {'Depth':>6s}")
    print("-" * 75)

    for name, order, g in groups:
        series = g.classify_chemical_series()
        depth = g.derived_depth()
        print(f"{name:12s} {order:6d} {series:18s} "
              f"{'Yes' if g.is_cyclic() else 'No':>7s} "
              f"{'Yes' if g.is_abelian() else 'No':>8s} "
              f"{'Yes' if g.is_nilpotent() else 'No':>6s} "
              f"{'Yes' if g.is_solvable() else 'No':>6s} "
              f"{depth if depth is not None else 'N/A':>6}")


def demo_derived_series():
    """Show the derived series computation step by step."""
    print("\n" + "=" * 70)
    print("DERIVED SERIES DECOMPOSITION")
    print("=" * 70)

    # S_3 ≅ D_6
    print("\nS_3 (Symmetric group on 3 elements, order 6):")
    d3 = make_dihedral_group(3)
    series = d3.derived_series()
    for i, s in enumerate(series):
        print(f"  G^({i}) = {sorted(s)} (order {len(s)})")
    print(f"  → Derived depth = {len(series) - 1}")
    print(f"  → Chemical series: {d3.classify_chemical_series()}")

    # D_8
    print("\nD_4 (Dihedral group of order 8):")
    d4 = make_dihedral_group(4)
    series = d4.derived_series()
    for i, s in enumerate(series):
        print(f"  G^({i}) = {sorted(s)} (order {len(s)})")
    print(f"  → Derived depth = {len(series) - 1}")
    print(f"  → Chemical series: {d4.classify_chemical_series()}")

    # Z_12
    print("\nZ_12 (Cyclic group of order 12):")
    z12 = make_cyclic_group(12)
    series = z12.derived_series()
    for i, s in enumerate(series):
        print(f"  G^({i}) = {sorted(s)} (order {len(s)})")
    print(f"  → Derived depth = {len(series) - 1}")
    print(f"  → Chemical series: {z12.classify_chemical_series()}")


def demo_big_omega():
    """Demonstrate the big omega function."""
    print("\n" + "=" * 70)
    print("BIG OMEGA FUNCTION Ω(n)")
    print("(Number of prime factors with multiplicity)")
    print("=" * 70)

    print(f"\n{'n':>6s} {'Factorization':>20s} {'Ω(n)':>6s}")
    print("-" * 35)

    for n in range(2, 31):
        factors = prime_factorization(n)
        factor_str = " × ".join(
            f"{p}^{e}" if e > 1 else str(p)
            for p, e in sorted(factors.items())
        )
        print(f"{n:6d} {factor_str:>20s} {big_omega(n):6d}")


def demo_periodic_law():
    """Test the Periodic Law Conjecture."""
    print("\n" + "=" * 70)
    print("PERIODIC LAW CONJECTURE VERIFICATION")
    print("derivedDepth(G) ≤ Ω(|G|)")
    print("=" * 70)

    results = verify_periodic_law_conjecture(20)

    solvable_results = [r for r in results if r["derived_depth"] is not None]
    non_solvable = [r for r in results if r["derived_depth"] is None]

    print(f"\n{'Group':10s} {'Order':>6s} {'Depth':>6s} {'Ω':>4s} "
          f"{'Gap':>4s} {'Series':18s} {'Status':>8s}")
    print("-" * 65)

    all_hold = True
    for r in solvable_results:
        gap = r["big_omega"] - r["derived_depth"]
        status = "✓" if r["conjecture_holds"] else "✗"
        if not r["conjecture_holds"]:
            all_hold = False
        print(f"{r['group']:10s} {r['order']:6d} {r['derived_depth']:6d} "
              f"{r['big_omega']:4d} {gap:4d} {r['chemical_series']:18s} {status:>8s}")

    if non_solvable:
        print(f"\nNon-solvable groups (excluded from conjecture):")
        for r in non_solvable:
            print(f"  {r['group']:10s} order={r['order']:4d} "
                  f"series={r['chemical_series']}")

    print(f"\n{'CONJECTURE HOLDS' if all_hold else 'COUNTEREXAMPLE FOUND'} "
          f"for all {len(solvable_results)} solvable groups tested.")


def demo_valence():
    """Demonstrate group valence computation."""
    print("\n" + "=" * 70)
    print("GROUP VALENCE (Minimal Normal Subgroups)")
    print("=" * 70)

    groups = [
        ("Z_2", make_cyclic_group(2)),
        ("Z_3", make_cyclic_group(3)),
        ("Z_6", make_cyclic_group(6)),
        ("Z_2×Z_2", FiniteGroup([
            [0, 1, 2, 3], [1, 0, 3, 2],
            [2, 3, 0, 1], [3, 2, 1, 0]
        ])),
        ("D_6", make_dihedral_group(3)),
        ("D_8", make_dihedral_group(4)),
    ]

    print(f"\n{'Group':12s} {'Order':>6s} {'Valence':>8s} "
          f"{'Normal Subs':>12s} {'Series':18s}")
    print("-" * 65)

    for name, g in groups:
        v = g.valence()
        normals = len(g.normal_subgroups())
        series = g.classify_chemical_series()
        print(f"{name:12s} {g.n:6d} {v:8d} {normals:12d} {series:18s}")


if __name__ == "__main__":
    demo_chemical_classification()
    demo_derived_series()
    demo_big_omega()
    demo_periodic_law()
    demo_valence()


#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Finite Groups

Creates a visual periodic table showing groups classified by chemical series,
with derived depth and Ω values displayed.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def big_omega(n: int) -> int:
    """Count prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


def prime_factorization_str(n: int) -> str:
    """Return a readable prime factorization string."""
    if n <= 1:
        return str(n)
    factors = {}
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = factors.get(temp, 0) + 1
    parts = []
    for p in sorted(factors):
        e = factors[p]
        parts.append(f"{p}^{e}" if e > 1 else str(p))
    return "·".join(parts)


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def classify_order(n: int) -> str:
    """Heuristic classification of groups of order n."""
    if n == 1:
        return "Trivial"
    if is_prime(n):
        return "Noble Gas"  # Only cyclic group exists
    # Check if n is a prime power
    for p in range(2, n + 1):
        if not is_prime(p):
            continue
        k = 0
        temp = n
        while temp % p == 0:
            k += 1
            temp //= p
        if temp == 1:
            if k == 1:
                return "Noble Gas"
            return "Alkali Metal"  # p-groups are nilpotent
    # Multiple prime factors
    factors = {}
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = factors.get(temp, 0) + 1

    if len(factors) == 2:
        return "Halogen"  # Burnside: p^a q^b → solvable
    return "Transition Metal"  # May or may not be solvable


# Color scheme
COLORS = {
    "Noble Gas": "#4FC3F7",      # Light blue
    "Alkaline Earth": "#81C784",  # Green
    "Alkali Metal": "#FFB74D",    # Orange
    "Halogen": "#E57373",         # Red
    "Transition Metal": "#9575CD", # Purple
    "Trivial": "#BDBDBD",         # Grey
}


def create_periodic_table():
    """Create the periodic table visualization."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 12.5)
    ax.set_aspect('equal')
    ax.invert_yaxis()
    ax.axis('off')
    ax.set_title("The Periodic Table of Finite Groups\n"
                 "Groups of Order 1-100, Classified by Chemical Series",
                 fontsize=16, fontweight='bold', pad=20)

    # Place groups in a grid: rows by order magnitude, columns by type
    data = []
    for n in range(1, 101):
        series = classify_order(n)
        omega = big_omega(n)
        data.append({
            "order": n,
            "series": series,
            "omega": omega,
            "factorization": prime_factorization_str(n),
        })

    # Organize by series for the table
    series_groups = {}
    for d in data:
        s = d["series"]
        if s not in series_groups:
            series_groups[s] = []
        series_groups[s].append(d)

    # Column positions for each series
    col_map = {
        "Noble Gas": 0,
        "Alkali Metal": 2,
        "Halogen": 5,
        "Transition Metal": 8,
        "Trivial": 0,
    }

    # Draw entries
    row_counters = {k: 0 for k in col_map}
    cell_size = 0.9

    for series_name in ["Noble Gas", "Alkali Metal", "Halogen", "Transition Metal"]:
        if series_name not in series_groups:
            continue
        col = col_map[series_name]
        groups = series_groups[series_name][:12]  # Limit to 12 per column

        for i, d in enumerate(groups):
            x = col
            y = i + 1
            color = COLORS.get(series_name, "#BDBDBD")

            rect = mpatches.FancyBboxPatch(
                (x - cell_size/2, y - cell_size/2),
                cell_size * 2, cell_size,
                boxstyle="round,pad=0.05",
                facecolor=color, edgecolor='black', linewidth=0.5, alpha=0.8
            )
            ax.add_patch(rect)

            # Order number (like atomic number)
            ax.text(x - cell_size/2 + 0.1, y - cell_size/2 + 0.15,
                    str(d["order"]), fontsize=7, fontweight='bold', va='top')

            # Omega value
            ax.text(x + cell_size * 1.5 - 0.1, y - cell_size/2 + 0.15,
                    f"Ω={d['omega']}", fontsize=6, va='top', ha='right')

            # Factorization
            ax.text(x + cell_size/2, y + 0.05,
                    d["factorization"], fontsize=8, ha='center', va='center',
                    fontweight='bold')

    # Column headers
    headers = {
        0: "Noble Gas\n(Cyclic/Prime)",
        2: "Alkali Metal\n(p-groups)",
        5: "Halogen\n(2-prime)",
        8: "Transition Metal\n(≥3 primes)",
    }
    for col, label in headers.items():
        ax.text(col + cell_size/2, 0.3, label,
                fontsize=9, fontweight='bold', ha='center', va='bottom',
                color=COLORS.get(label.split('\n')[0], 'black'))

    # Legend
    legend_items = [
        mpatches.Patch(color=COLORS["Noble Gas"], label="Noble Gas (cyclic)"),
        mpatches.Patch(color=COLORS["Alkali Metal"], label="Alkali Metal (nilpotent)"),
        mpatches.Patch(color=COLORS["Halogen"], label="Halogen (solvable)"),
        mpatches.Patch(color=COLORS["Transition Metal"], label="Transition Metal (complex)"),
    ]
    ax.legend(handles=legend_items, loc='lower right', fontsize=8)

    plt.tight_layout()
    plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
    print("Saved: periodic_table_groups.png")


def create_omega_vs_depth_plot():
    """Create a scatter plot of Ω(n) vs known derived depths."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Known groups with their derived depths
    groups = [
        ("Z_1", 1, 0), ("Z_2", 2, 1), ("Z_3", 3, 1), ("Z_4", 4, 1),
        ("Z_5", 5, 1), ("Z_6", 6, 1), ("Z_7", 7, 1), ("Z_8", 8, 1),
        ("Z_12", 12, 1), ("Z_24", 24, 1), ("Z_30", 30, 1),
        ("S_3", 6, 2), ("D_8", 8, 2), ("D_10", 10, 2),
        ("A_4", 12, 2), ("D_12", 12, 2),
        ("S_4", 24, 3), ("D_16", 16, 2),
        ("Q_8", 8, 2), ("D_24", 24, 2),
    ]

    omegas = [big_omega(g[1]) for g in groups]
    depths = [g[2] for g in groups]
    orders = [g[1] for g in groups]
    names = [g[0] for g in groups]

    # Color by chemical series
    colors = []
    for name in names:
        if name.startswith("Z_"):
            colors.append(COLORS["Noble Gas"])
        elif name.startswith("D_") or name.startswith("Q_"):
            colors.append(COLORS["Alkali Metal"])
        elif name.startswith("S_"):
            colors.append(COLORS["Halogen"])
        elif name.startswith("A_"):
            colors.append(COLORS["Halogen"])
        else:
            colors.append(COLORS["Transition Metal"])

    scatter = ax.scatter(omegas, depths, c=colors, s=100, edgecolors='black',
                         linewidths=0.5, zorder=3)

    # Add labels
    for i, name in enumerate(names):
        ax.annotate(name, (omegas[i], depths[i]),
                    textcoords="offset points", xytext=(5, 5),
                    fontsize=7, alpha=0.8)

    # Conjecture line: depth ≤ Ω
    max_omega = max(omegas) + 1
    ax.plot([0, max_omega], [0, max_omega], 'r--', alpha=0.5,
            label='Conjecture bound: depth = Ω')

    ax.set_xlabel("Ω(|G|) — Prime factors with multiplicity", fontsize=12)
    ax.set_ylabel("Derived Depth", fontsize=12)
    ax.set_title("Periodic Law Conjecture: derivedDepth(G) ≤ Ω(|G|)",
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, max_omega)
    ax.set_ylim(-0.5, max(depths) + 1)

    plt.tight_layout()
    plt.savefig("omega_vs_depth.png", dpi=150, bbox_inches='tight')
    print("Saved: omega_vs_depth.png")


if __name__ == "__main__":
    create_periodic_table()
    create_omega_vs_depth_plot()
