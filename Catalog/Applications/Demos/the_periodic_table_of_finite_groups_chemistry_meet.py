#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of the Group Genome framework.

Computes chemical classifications and derived depths for small groups,
illustrating the periodic table of finite groups.
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import List, Tuple, Optional
from math import gcd, log2
from itertools import product as iterproduct
from functools import reduce


class ChemicalClass(Enum):
    VACUUM = auto()
    NOBLE_GAS = auto()        # Cyclic
    ALKALI = auto()            # Abelian non-cyclic
    ALKALINE_EARTH = auto()    # Nilpotent non-abelian
    HALOGEN = auto()           # Solvable non-nilpotent
    TRANSITION_METAL = auto()  # Simple non-abelian
    COMPOUND = auto()          # Non-solvable, non-simple

    def symbol(self) -> str:
        symbols = {
            ChemicalClass.VACUUM: "∅",
            ChemicalClass.NOBLE_GAS: "Ne",
            ChemicalClass.ALKALI: "Li",
            ChemicalClass.ALKALINE_EARTH: "Mg",
            ChemicalClass.HALOGEN: "Cl",
            ChemicalClass.TRANSITION_METAL: "Fe",
            ChemicalClass.COMPOUND: "UO₂",
        }
        return symbols[self]


@dataclass
class GroupGenome:
    """Chemical fingerprint of a finite group."""
    name: str
    order: int
    chem_class: ChemicalClass
    is_solvable: bool
    is_nilpotent: bool
    is_abelian: bool
    is_cyclic: bool
    is_simple: bool
    derived_depth: Optional[int] = None

    def display(self) -> str:
        flags = []
        if self.is_cyclic: flags.append("Cyc")
        if self.is_abelian and not self.is_cyclic: flags.append("Ab")
        if self.is_nilpotent and not self.is_abelian: flags.append("Nil")
        if self.is_solvable and not self.is_nilpotent: flags.append("Sol")
        if self.is_simple: flags.append("Sim")
        depth_str = f"d={self.derived_depth}" if self.derived_depth is not None else ""
        return (f"{self.name:>12s} | ord={self.order:>4d} | "
                f"{self.chem_class.symbol():>3s} ({self.chem_class.name:>18s}) | "
                f"{','.join(flags):>8s} | {depth_str}")


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def prime_factors(n: int) -> List[int]:
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
    """Total prime multiplicity Ω(n)."""
    return len(prime_factors(n))


# ---- Known group data for small orders ----

KNOWN_GROUPS: List[GroupGenome] = [
    GroupGenome("Trivial", 1, ChemicalClass.VACUUM,
                True, True, True, True, False, 0),
    GroupGenome("Z/2Z", 2, ChemicalClass.NOBLE_GAS,
                True, True, True, True, True, 1),
    GroupGenome("Z/3Z", 3, ChemicalClass.NOBLE_GAS,
                True, True, True, True, True, 1),
    GroupGenome("Z/4Z", 4, ChemicalClass.NOBLE_GAS,
                True, True, True, True, False, 1),
    GroupGenome("V₄", 4, ChemicalClass.ALKALI,
                True, True, True, False, False, 1),
    GroupGenome("Z/5Z", 5, ChemicalClass.NOBLE_GAS,
                True, True, True, True, True, 1),
    GroupGenome("S₃", 6, ChemicalClass.HALOGEN,
                True, False, False, False, False, 2),
    GroupGenome("Z/6Z", 6, ChemicalClass.NOBLE_GAS,
                True, True, True, True, False, 1),
    GroupGenome("Z/7Z", 7, ChemicalClass.NOBLE_GAS,
                True, True, True, True, True, 1),
    GroupGenome("Z/8Z", 8, ChemicalClass.NOBLE_GAS,
                True, True, True, True, False, 1),
    GroupGenome("D₄", 8, ChemicalClass.ALKALINE_EARTH,
                True, True, False, False, False, 2),
    GroupGenome("Q₈", 8, ChemicalClass.ALKALINE_EARTH,
                True, True, False, False, False, 2),
    GroupGenome("Z/2Z³", 8, ChemicalClass.ALKALI,
                True, True, True, False, False, 1),
    GroupGenome("A₄", 12, ChemicalClass.HALOGEN,
                True, False, False, False, False, 3),
    GroupGenome("D₆", 12, ChemicalClass.HALOGEN,
                True, False, False, False, False, 2),
    GroupGenome("A₅", 60, ChemicalClass.TRANSITION_METAL,
                False, False, False, False, True, None),
    GroupGenome("S₅", 120, ChemicalClass.COMPOUND,
                False, False, False, False, False, None),
]


def print_periodic_table():
    """Display the periodic table of known groups."""
    print("=" * 85)
    print("THE PERIODIC TABLE OF FINITE GROUPS")
    print("=" * 85)
    print(f"{'Group':>12s} | {'Ord':>4s}  | {'Sym':>3s} {'Class':>18s}  | {'Props':>8s} | Depth")
    print("-" * 85)
    for g in KNOWN_GROUPS:
        print(g.display())
    print("=" * 85)


def demonstrate_stability_chain():
    """Show the stability hierarchy in action."""
    print("\n" + "=" * 60)
    print("STABILITY HIERARCHY: Cyclic → Abelian → Nilpotent → Solvable")
    print("=" * 60)

    classes = {
        "Cyclic (Noble Gas)": [g for g in KNOWN_GROUPS if g.is_cyclic and g.order > 1],
        "Abelian non-Cyclic (Alkali)": [g for g in KNOWN_GROUPS
                                         if g.is_abelian and not g.is_cyclic],
        "Nilpotent non-Abelian (Alkaline Earth)": [g for g in KNOWN_GROUPS
                                                     if g.is_nilpotent and not g.is_abelian],
        "Solvable non-Nilpotent (Halogen)": [g for g in KNOWN_GROUPS
                                               if g.is_solvable and not g.is_nilpotent],
        "Simple non-Abelian (Trans. Metal)": [g for g in KNOWN_GROUPS
                                                if g.is_simple and not g.is_abelian],
    }

    for cls_name, groups in classes.items():
        print(f"\n  {cls_name}:")
        for g in groups:
            depth_str = f"d={g.derived_depth}" if g.derived_depth is not None else "d=N/A"
            print(f"    {g.name:>8s} (order {g.order:>3d}) — {depth_str}")


def demonstrate_derived_depth_bound():
    """Show the conjectured bound d(G) ≤ Ω(|G|)."""
    print("\n" + "=" * 60)
    print("DERIVED DEPTH BOUND CONJECTURE: d(G) ≤ Ω(|G|)")
    print("=" * 60)
    print(f"{'Group':>12s} | {'|G|':>4s} | {'d(G)':>4s} | {'Ω(|G|)':>6s} | {'Bound?':>6s}")
    print("-" * 50)
    for g in KNOWN_GROUPS:
        if g.derived_depth is not None:
            om = omega(g.order)
            ok = "✓" if g.derived_depth <= om else "✗"
            print(f"{g.name:>12s} | {g.order:>4d} | {g.derived_depth:>4d} | {om:>6d} | {ok:>6s}")


def demonstrate_product_predictions():
    """Show genome predictions for direct products."""
    print("\n" + "=" * 60)
    print("PRODUCT PREDICTIONS: genome(G × H)")
    print("=" * 60)

    pairs = [
        ("Z/2Z", "Z/3Z", "Z/6Z", 6, ChemicalClass.NOBLE_GAS),
        ("Z/2Z", "Z/2Z", "V₄", 4, ChemicalClass.ALKALI),
        ("S₃", "Z/2Z", "S₃×Z/2Z", 12, ChemicalClass.HALOGEN),
        ("Z/5Z", "Z/7Z", "Z/35Z", 35, ChemicalClass.NOBLE_GAS),
    ]

    for g1, g2, name, order, predicted_class in pairs:
        print(f"  {g1} × {g2} = {name} (order {order})")
        print(f"    Predicted class: {predicted_class.symbol()} ({predicted_class.name})")
        print()


def print_class_distribution():
    """Distribution of chemical classes for groups of order ≤ n."""
    print("\n" + "=" * 60)
    print("CHEMICAL CLASS DISTRIBUTION (selected orders)")
    print("=" * 60)

    # Known group counts by order and class
    data = {
        1: {"total": 1, ChemicalClass.VACUUM: 1},
        2: {"total": 1, ChemicalClass.NOBLE_GAS: 1},
        3: {"total": 1, ChemicalClass.NOBLE_GAS: 1},
        4: {"total": 2, ChemicalClass.NOBLE_GAS: 1, ChemicalClass.ALKALI: 1},
        5: {"total": 1, ChemicalClass.NOBLE_GAS: 1},
        6: {"total": 2, ChemicalClass.NOBLE_GAS: 1, ChemicalClass.HALOGEN: 1},
        7: {"total": 1, ChemicalClass.NOBLE_GAS: 1},
        8: {"total": 5, ChemicalClass.NOBLE_GAS: 1, ChemicalClass.ALKALI: 2,
            ChemicalClass.ALKALINE_EARTH: 2},
        12: {"total": 5, ChemicalClass.NOBLE_GAS: 1, ChemicalClass.ALKALI: 1,
             ChemicalClass.HALOGEN: 3},
        60: {"total": 13, ChemicalClass.TRANSITION_METAL: 1},
    }

    for order, info in sorted(data.items()):
        total = info["total"]
        print(f"\n  Order {order} ({total} group{'s' if total > 1 else ''}):")
        for cls in ChemicalClass:
            count = info.get(cls, 0)
            if count > 0:
                bar = "█" * count
                print(f"    {cls.symbol():>3s} {cls.name:>18s}: {count:>2d} {bar}")


if __name__ == "__main__":
    print_periodic_table()
    demonstrate_stability_chain()
    demonstrate_derived_depth_bound()
    demonstrate_product_predictions()
    print_class_distribution()
    print("\n✓ All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Finite Groups

A scatter/grid plot showing groups organized by order (x-axis)
and chemical class (y-axis), with size proportional to derived depth.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Group data: (name, order, class_index, derived_depth, is_simple)
# Class indices: 0=Vacuum, 1=NobleGas, 2=Alkali, 3=AlkalineEarth, 4=Halogen, 5=TransMetal, 6=Compound
GROUPS = [
    ("e", 1, 0, 0, False),
    ("Z/2Z", 2, 1, 1, True),
    ("Z/3Z", 3, 1, 1, True),
    ("Z/4Z", 4, 1, 1, False),
    ("V₄", 4, 2, 1, False),
    ("Z/5Z", 5, 1, 1, True),
    ("Z/6Z", 6, 1, 1, False),
    ("S₃", 6, 4, 2, False),
    ("Z/7Z", 7, 1, 1, True),
    ("Z/8Z", 8, 1, 1, False),
    ("Z/2Z×Z/4Z", 8, 2, 1, False),
    ("D₄", 8, 3, 2, False),
    ("Q₈", 8, 3, 2, False),
    ("Z/2Z³", 8, 2, 1, False),
    ("Z/9Z", 9, 1, 1, False),
    ("Z/3Z²", 9, 2, 1, False),
    ("Z/10Z", 10, 1, 1, False),
    ("D₅", 10, 4, 2, False),
    ("Z/11Z", 11, 1, 1, True),
    ("A₄", 12, 4, 3, False),
    ("D₆", 12, 4, 2, False),
    ("Z/12Z", 12, 1, 1, False),
    ("Z/13Z", 13, 1, 1, True),
    ("D₇", 14, 4, 2, False),
    ("Z/15Z", 15, 1, 1, False),
    ("Z/16Z", 16, 1, 1, False),
    ("Z/17Z", 17, 1, 1, True),
    ("Z/19Z", 19, 1, 1, True),
    ("Z/23Z", 23, 1, 1, True),
    ("S₄", 24, 4, 3, False),
    ("Z/29Z", 29, 1, 1, True),
    ("Z/31Z", 31, 1, 1, True),
    ("A₅", 60, 5, None, True),
    ("S₅", 120, 6, None, False),
]

CLASS_NAMES = ["Vacuum", "Noble Gas", "Alkali", "Alkaline\nEarth",
               "Halogen", "Transition\nMetal", "Compound"]
CLASS_COLORS = ["#888888", "#FFD700", "#FF6B6B", "#4ECDC4",
                "#45B7D1", "#96CEB4", "#FFEAA7"]

fig, ax = plt.subplots(figsize=(16, 8))

for name, order, cls, depth, is_simple in GROUPS:
    size = 80 if depth is None else 40 + depth * 40
    color = CLASS_COLORS[cls]
    edge = 'black' if is_simple else 'gray'
    linewidth = 2 if is_simple else 0.5

    # Add jitter for overlapping orders
    jitter = np.random.uniform(-0.15, 0.15)
    ax.scatter(order, cls + jitter, s=size, c=color, edgecolors=edge,
              linewidth=linewidth, alpha=0.85, zorder=5)

    if order <= 20 or name in ["A₄", "S₄", "A₅", "S₅"]:
        ax.annotate(name, (order, cls + jitter),
                   fontsize=6, ha='center', va='bottom',
                   xytext=(0, 8), textcoords='offset points')

ax.set_yticks(range(7))
ax.set_yticklabels(CLASS_NAMES, fontsize=10)
ax.set_xlabel("Group Order (Atomic Number)", fontsize=12)
ax.set_title("The Periodic Table of Finite Groups", fontsize=16, fontweight='bold')
ax.set_xlim(-2, 130)
ax.set_ylim(-0.5, 6.5)
ax.grid(True, alpha=0.3, axis='x')

# Add horizontal bands
for i in range(7):
    ax.axhspan(i - 0.4, i + 0.4, alpha=0.08, color=CLASS_COLORS[i])

# Legend
handles = [mpatches.Patch(color=CLASS_COLORS[i], label=CLASS_NAMES[i].replace('\n', ' '))
           for i in range(7)]
handles.append(plt.scatter([], [], s=80, c='white', edgecolors='black',
                           linewidth=2, label='Simple'))
ax.legend(handles=handles, loc='upper right', fontsize=8)

plt.tight_layout()
plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
print("Saved: periodic_table_groups.png")


#!/usr/bin/env python3
"""
Visualization: Stability Hierarchy and Derived Depth

Shows the inclusion chain Cyclic ⊂ Abelian ⊂ Nilpotent ⊂ Solvable
with example groups at each level and their derived depth.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

# ---- Left panel: Venn-like inclusion diagram ----
colors = ['#FFD700', '#FF6B6B', '#4ECDC4', '#45B7D1', '#888888']

# Draw concentric rounded rectangles
levels = [
    (0.5, 0.5, 0.95, 0.9, '#45B7D1', 'Solvable', 0.15),
    (0.5, 0.48, 0.75, 0.7, '#4ECDC4', 'Nilpotent', 0.2),
    (0.5, 0.46, 0.55, 0.5, '#FF6B6B', 'Abelian', 0.25),
    (0.5, 0.44, 0.35, 0.3, '#FFD700', 'Cyclic', 0.3),
]

for cx, cy, w, h, color, label, alpha in levels:
    rect = mpatches.FancyBboxPatch(
        (cx - w/2, cy - h/2), w, h,
        boxstyle="round,pad=0.02",
        facecolor=color, alpha=alpha, edgecolor='black', linewidth=1.5
    )
    ax1.add_patch(rect)
    ax1.text(cx, cy + h/2 - 0.04, label,
            ha='center', va='top', fontsize=11, fontweight='bold')

# Add example groups
examples = [
    (0.5, 0.35, "Z/5Z, Z/7Z", 8),
    (0.3, 0.55, "V₄, Z/2Z³", 8),
    (0.7, 0.58, "D₄, Q₈", 8),
    (0.2, 0.78, "S₃, A₄", 8),
]
for x, y, text, size in examples:
    ax1.text(x, y, text, ha='center', va='center', fontsize=size,
            style='italic', color='#333333')

# Outside: non-solvable
ax1.text(0.5, 0.98, "Non-solvable: A₅, S₅, ...",
        ha='center', va='top', fontsize=9, color='#666666')

ax1.set_xlim(0, 1)
ax1.set_ylim(0, 1)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title("Stability Hierarchy\n(Inclusion Chain)", fontsize=13, fontweight='bold')

# ---- Right panel: Derived depth distribution ----
groups_by_depth = {
    0: [("e", 1)],
    1: [("Z/2Z", 2), ("Z/3Z", 3), ("Z/5Z", 5), ("Z/7Z", 7),
        ("V₄", 4), ("Z/2Z³", 8)],
    2: [("S₃", 6), ("D₄", 8), ("Q₈", 8), ("D₅", 10), ("D₆", 12)],
    3: [("A₄", 12), ("S₄", 24)],
}

colors_depth = ['#888888', '#FFD700', '#FF6B6B', '#45B7D1']
y_offset = 0

for depth in sorted(groups_by_depth.keys()):
    groups = groups_by_depth[depth]
    for i, (name, order) in enumerate(groups):
        ax2.barh(y_offset, order, height=0.7,
                color=colors_depth[depth], edgecolor='black', linewidth=0.5,
                alpha=0.8)
        ax2.text(order + 1, y_offset, f"{name} (|G|={order})",
                ha='left', va='center', fontsize=8)
        y_offset += 1
    # Add depth label
    mid = y_offset - len(groups) / 2
    ax2.text(-3, mid, f"d={depth}", ha='right', va='center',
            fontsize=11, fontweight='bold', color=colors_depth[depth])
    y_offset += 0.5

ax2.set_xlabel("Group Order", fontsize=11)
ax2.set_title("Derived Depth Distribution\n(Abelian Onion Layers)", fontsize=13, fontweight='bold')
ax2.set_yticks([])
ax2.set_xlim(-5, 35)
ax2.invert_yaxis()
ax2.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig("stability_hierarchy.png", dpi=150, bbox_inches='tight')
print("Saved: stability_hierarchy.png")
