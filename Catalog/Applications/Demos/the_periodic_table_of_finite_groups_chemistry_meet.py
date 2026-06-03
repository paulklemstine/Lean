"""
demo.py — Interactive demonstration of the Periodic Table of Finite Groups

Shows how finite groups are classified into chemical families and how
the periodic table analogy works.
"""

from algorithms import (
    cyclic_group, symmetric_group, dihedral_group,
    predict_group_properties, composition_factor_signature,
    build_periodic_table, prime_factorization
)


def demo_chemical_families():
    """Demonstrate the chemical family classification of groups."""
    print("=" * 70)
    print("CHEMICAL FAMILIES OF FINITE GROUPS")
    print("=" * 70)

    families = {
        "Noble Gases (Cyclic)": [],
        "Alkali Metals (Nilpotent non-cyclic)": [],
        "Alkaline Earth (Solvable non-nilpotent)": [],
        "Transition Metals (Simple non-abelian)": [],
    }

    # Classify cyclic groups
    for n in range(1, 16):
        zn = cyclic_group(n)
        family = zn.classify_family()
        if family == "NobleGas":
            families["Noble Gases (Cyclic)"].append(f"Z/{n}Z")

    # Classify dihedral groups
    for n in range(3, 10):
        dn = dihedral_group(n)
        family = dn.classify_family()
        if family == "AlkalineEarth":
            families["Alkaline Earth (Solvable non-nilpotent)"].append(f"D_{n}")
        elif family == "AlkaliMetal":
            families["Alkali Metals (Nilpotent non-cyclic)"].append(f"D_{n}")

    # Classify symmetric groups
    for n in range(2, 5):
        sn = symmetric_group(n)
        family = sn.classify_family()
        for fam_name in families:
            if family in fam_name.split("(")[1].split(")")[0].lower() or \
               (family == "NobleGas" and "Noble" in fam_name) or \
               (family == "AlkaliMetal" and "Alkali M" in fam_name) or \
               (family == "AlkalineEarth" and "Alkaline" in fam_name) or \
               (family == "Radioactive" and "Transition" in fam_name):
                families[fam_name].append(f"S_{n}")
                break

    for fam_name, groups in families.items():
        print(f"\n{fam_name}:")
        if groups:
            print(f"  {', '.join(groups)}")
        else:
            print(f"  (none in this range)")


def demo_derived_series():
    """Show the derived series computation for several groups."""
    print("\n" + "=" * 70)
    print("DERIVED SERIES (Solvability Depth)")
    print("=" * 70)

    groups = [
        ("Z/6Z (abelian)", cyclic_group(6)),
        ("S_3 (non-abelian, solvable)", symmetric_group(3)),
        ("S_4 (non-abelian, solvable)", symmetric_group(4)),
        ("D_4 (dihedral, nilpotent)", dihedral_group(4)),
        ("D_5 (dihedral, solvable)", dihedral_group(5)),
    ]

    for name, g in groups:
        series = g.derived_series()
        print(f"\n{name} (order {g.order}):")
        for i, term in enumerate(series):
            print(f"  G^({i}) has order {len(term)}: {sorted(term)[:10]}{'...' if len(term) > 10 else ''}")
        print(f"  Derived length: {g.derived_length()}")
        print(f"  Solvable: {g.is_solvable()}")


def demo_isotope_conjecture():
    """Demonstrate the falsity of the isotope conjecture."""
    print("\n" + "=" * 70)
    print("THE ISOTOPE CONJECTURE (DISPROVED)")
    print("=" * 70)

    print("\nConjecture: Groups of the same order have the same derived length.")
    print("\nCounterexample: Z/6Z vs S_3")

    z6 = cyclic_group(6)
    s3 = symmetric_group(3)

    print(f"\n  Z/6Z: order = {z6.order}")
    print(f"    Abelian: {z6.is_abelian()}")
    print(f"    Derived series: {[len(s) for s in z6.derived_series()]}")
    print(f"    Derived length: {z6.derived_length()}")
    print(f"    Family: {z6.classify_family()}")

    print(f"\n  S_3:  order = {s3.order}")
    print(f"    Abelian: {s3.is_abelian()}")
    print(f"    Derived series: {[len(s) for s in s3.derived_series()]}")
    print(f"    Derived length: {s3.derived_length()}")
    print(f"    Family: {s3.classify_family()}")

    print(f"\n  Both have order 6 but derived lengths {z6.derived_length()} ≠ {s3.derived_length()}")
    print("  => The Isotope Conjecture is FALSE!")

    print("\n  However, the WEAK Periodic Law holds:")
    print("  Groups with the same composition factors share SOLVABILITY.")
    print(f"  Z/6Z composition factors: {composition_factor_signature(6)}")
    print(f"  Both Z/6Z and S_3 are solvable (all factors are primes).")


def demo_predictions():
    """Demonstrate predictive power of the periodic table."""
    print("\n" + "=" * 70)
    print("PREDICTIONS FROM THE PERIODIC TABLE")
    print("=" * 70)

    test_orders = [12, 24, 30, 60, 120, 168, 360]

    for n in test_orders:
        pred = predict_group_properties(n)
        print(f"\nOrder {n} = ", end="")
        factors = pred['prime_factorization']
        print(" × ".join(f"{p}^{e}" if e > 1 else str(p)
                        for p, e in sorted(factors.items())))
        print(f"  Composition factors: {pred['composition_factors']}")
        print(f"  Guaranteed solvable: {pred['guaranteed_solvable']}")
        print(f"  Guaranteed nilpotent: {pred['guaranteed_nilpotent']}")
        print(f"  Predicted family: {pred['predicted_family']}")
        if pred['sylow_info']:
            for p, info in pred['sylow_info'].items():
                print(f"  Sylow {p}-subgroup: order {info['order']}, "
                      f"possible counts: {info['possible_counts']}, "
                      f"unique: {info['unique']}")


def demo_valence():
    """Show the valence (minimal normal subgroup count) for various groups."""
    print("\n" + "=" * 70)
    print("GROUP VALENCE (Minimal Normal Subgroups)")
    print("=" * 70)

    groups = [
        ("Z/2Z", cyclic_group(2)),
        ("Z/4Z", cyclic_group(4)),
        ("Z/6Z", cyclic_group(6)),
        ("S_3", symmetric_group(3)),
        ("D_4", dihedral_group(4)),
        ("S_4", symmetric_group(4)),
    ]

    for name, g in groups:
        mns = g.minimal_normal_subgroups()
        print(f"\n{name} (order {g.order}):")
        print(f"  Valence: {g.valence()}")
        for i, ns in enumerate(mns):
            print(f"  Minimal normal subgroup {i+1}: order {len(ns)}, elements {sorted(ns)}")


if __name__ == "__main__":
    demo_chemical_families()
    demo_derived_series()
    demo_isotope_conjecture()
    demo_predictions()
    demo_valence()


"""
visualize_periodic_table.py — Visualize the Periodic Table of Finite Groups

Creates a color-coded periodic table showing group families,
derived lengths, and structural properties.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import factorial, gcd


def prime_factorization(n):
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


def is_prime(n):
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def classify_order(n):
    """Classify groups of order n by their guaranteed family."""
    if n == 1:
        return "NobleGas", 1
    if is_prime(n):
        return "NobleGas", 1
    factors = prime_factorization(n)
    primes = list(factors.keys())
    if len(primes) == 1:
        p, k = list(factors.items())[0]
        if k == 1:
            return "NobleGas", 1
        return "AlkaliMetal", 2  # p-groups are nilpotent
    if len(primes) == 2:
        return "AlkalineEarth", max(2, sum(factors.values()))  # Burnside: solvable
    # For 3+ prime factors, might not be solvable
    # Check if any composition includes A5 (order 60)
    if n % 60 == 0 and n >= 60:
        return "Radioactive", -1
    return "AlkalineEarth", sum(factors.values())


def get_family_color(family):
    colors = {
        "NobleGas": "#E8F5E9",       # Light green
        "AlkaliMetal": "#FFEBEE",     # Light red
        "AlkalineEarth": "#FFF3E0",   # Light orange
        "TransitionMetal": "#E3F2FD", # Light blue
        "Halogen": "#F3E5F5",         # Light purple
        "Radioactive": "#ECEFF1",     # Light gray
    }
    return colors.get(family, "#FFFFFF")


def get_family_border(family):
    colors = {
        "NobleGas": "#4CAF50",
        "AlkaliMetal": "#F44336",
        "AlkalineEarth": "#FF9800",
        "TransitionMetal": "#2196F3",
        "Halogen": "#9C27B0",
        "Radioactive": "#607D8B",
    }
    return colors.get(family, "#000000")


def create_periodic_table():
    """Create a visual periodic table of finite groups."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 10.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("The Periodic Table of Finite Groups (Orders 1-100)",
                 fontsize=16, fontweight='bold', pad=20)

    # Layout: rows = decades of order, columns = family type
    # We'll show selected representative groups

    groups_data = [
        # (row, col, order, name, family, derived_length)
        (0, 0, 1, "{e}", "NobleGas", 0),
        (0, 1, 2, "Z/2", "NobleGas", 1),
        (0, 2, 3, "Z/3", "NobleGas", 1),
        (0, 3, 4, "Z/4", "NobleGas", 1),
        (0, 4, 4, "V₄", "AlkaliMetal", 1),
        (0, 5, 5, "Z/5", "NobleGas", 1),
        (0, 6, 6, "Z/6", "NobleGas", 1),
        (0, 7, 6, "S₃", "AlkalineEarth", 2),

        (1, 0, 7, "Z/7", "NobleGas", 1),
        (1, 1, 8, "Z/8", "NobleGas", 1),
        (1, 2, 8, "D₄", "AlkaliMetal", 2),
        (1, 3, 8, "Q₈", "AlkaliMetal", 2),
        (1, 4, 9, "Z/9", "NobleGas", 1),
        (1, 5, 9, "Z/3²", "AlkaliMetal", 1),
        (1, 6, 10, "Z/10", "NobleGas", 1),
        (1, 7, 10, "D₅", "AlkalineEarth", 2),

        (2, 0, 11, "Z/11", "NobleGas", 1),
        (2, 1, 12, "Z/12", "NobleGas", 1),
        (2, 2, 12, "A₄", "AlkalineEarth", 3),
        (2, 3, 12, "D₆", "AlkalineEarth", 2),
        (2, 4, 13, "Z/13", "NobleGas", 1),
        (2, 5, 14, "D₇", "AlkalineEarth", 2),
        (2, 6, 15, "Z/15", "NobleGas", 1),
        (2, 7, 16, "Z/16", "NobleGas", 1),

        (3, 0, 16, "D₈", "AlkaliMetal", 2),
        (3, 1, 17, "Z/17", "NobleGas", 1),
        (3, 2, 18, "D₉", "AlkalineEarth", 2),
        (3, 3, 20, "D₁₀", "AlkalineEarth", 2),
        (3, 4, 21, "Z/21", "NobleGas", 1),
        (3, 5, 24, "S₄", "AlkalineEarth", 3),
        (3, 6, 24, "SL₂₃", "AlkalineEarth", 3),

        (4, 0, 27, "Z/27", "NobleGas", 1),
        (4, 1, 30, "Z/30", "NobleGas", 1),
        (4, 2, 32, "Z/32", "NobleGas", 1),
        (4, 3, 36, "Z/36", "NobleGas", 1),
        (4, 4, 48, "GL₂₃", "AlkalineEarth", 3),

        (5, 0, 60, "A₅", "TransitionMetal", -1),
        (5, 1, 60, "Z/60", "NobleGas", 1),
        (5, 2, 120, "S₅", "Radioactive", -1),
        (5, 3, 168, "GL₃₂", "TransitionMetal", -1),
    ]

    for row, col, order, name, family, dl in groups_data:
        x = col * 1.3
        y = 9.5 - row * 1.8

        # Draw cell
        rect = mpatches.FancyBboxPatch(
            (x - 0.55, y - 0.75), 1.1, 1.4,
            boxstyle="round,pad=0.05",
            facecolor=get_family_color(family),
            edgecolor=get_family_border(family),
            linewidth=2
        )
        ax.add_patch(rect)

        # Order (atomic number)
        ax.text(x - 0.4, y + 0.45, str(order),
                fontsize=7, fontweight='bold', color='#333')

        # Name (element symbol)
        ax.text(x, y + 0.05, name,
                fontsize=10, fontweight='bold', ha='center', va='center')

        # Derived length
        dl_str = f"d={dl}" if dl >= 0 else "∞"
        ax.text(x, y - 0.45, dl_str,
                fontsize=7, ha='center', color='#666')

    # Legend
    legend_items = [
        ("Noble Gas (Cyclic)", "NobleGas"),
        ("Alkali Metal (Nilpotent)", "AlkaliMetal"),
        ("Alkaline Earth (Solvable)", "AlkalineEarth"),
        ("Transition Metal (Simple)", "TransitionMetal"),
        ("Radioactive (Non-solvable)", "Radioactive"),
    ]

    for i, (label, family) in enumerate(legend_items):
        y_leg = 1.5 - i * 0.5
        rect = mpatches.FancyBboxPatch(
            (10.5, y_leg - 0.15), 0.3, 0.3,
            boxstyle="round,pad=0.02",
            facecolor=get_family_color(family),
            edgecolor=get_family_border(family),
            linewidth=1.5
        )
        ax.add_patch(rect)
        ax.text(10.95, y_leg, label, fontsize=8, va='center')

    ax.set_xlim(-1, 15)
    plt.tight_layout()
    plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: periodic_table_groups.png")


def create_derived_length_distribution():
    """Create a bar chart of derived length distribution by order."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: derived length by order
    orders = list(range(1, 51))
    dl_min = []
    dl_max = []

    for n in orders:
        family, dl = classify_order(n)
        if family == "NobleGas":
            dl_min.append(1 if n > 1 else 0)
            dl_max.append(1 if n > 1 else 0)
        elif family == "AlkaliMetal":
            dl_min.append(1)
            dl_max.append(dl)
        elif family == "AlkalineEarth":
            dl_min.append(1)
            dl_max.append(dl)
        else:
            dl_min.append(1)
            dl_max.append(dl if dl > 0 else 5)

    colors = []
    for n in orders:
        family, _ = classify_order(n)
        colors.append(get_family_border(family))

    axes[0].bar(orders, dl_max, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    axes[0].set_xlabel("Group Order", fontsize=12)
    axes[0].set_ylabel("Max Derived Length", fontsize=12)
    axes[0].set_title("Derived Length vs Order", fontsize=14, fontweight='bold')

    # Right: family distribution
    family_counts = {"NobleGas": 0, "AlkaliMetal": 0, "AlkalineEarth": 0,
                     "TransitionMetal": 0, "Radioactive": 0}
    for n in range(1, 101):
        family, _ = classify_order(n)
        family_counts[family] = family_counts.get(family, 0) + 1

    labels = list(family_counts.keys())
    values = list(family_counts.values())
    fcolors = [get_family_border(f) for f in labels]

    axes[1].pie(values, labels=[l.replace("NobleGas", "Noble Gas")
                                 .replace("AlkaliMetal", "Alkali Metal")
                                 .replace("AlkalineEarth", "Alkaline Earth")
                                 .replace("TransitionMetal", "Trans. Metal")
                                 for l in labels],
                colors=fcolors, autopct='%1.0f%%', startangle=90,
                textprops={'fontsize': 9})
    axes[1].set_title("Family Distribution (Orders 1-100)",
                      fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig("derived_length_distribution.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: derived_length_distribution.png")


if __name__ == "__main__":
    create_periodic_table()
    create_derived_length_distribution()
