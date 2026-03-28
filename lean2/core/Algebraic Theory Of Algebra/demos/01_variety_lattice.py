#!/usr/bin/env python3
"""
Demo 1: The Lattice of Varieties — Visualizing How Algebraic Theories Organize

This script computes and visualizes the lattice of sub-varieties of groupoids
(sets with one binary operation), showing how algebraic theories themselves
form an algebraic structure.

The Algebraic Theory of Algebra: algebra studying itself.
"""

import itertools
from dataclasses import dataclass, field
from typing import Optional

# --- Try to import visualization libraries, fall back gracefully ---
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("[INFO] matplotlib not available — will produce text output only.")


# ============================================================
# Part 1: Algebraic Theories as Data Structures
# ============================================================

@dataclass
class AlgebraicTheory:
    """An algebraic theory = signature + equational axioms."""
    name: str
    operations: list  # list of (name, arity) pairs
    axioms: list      # list of string descriptions of equations
    parent_theories: list = field(default_factory=list)

    def __repr__(self):
        return f"Theory({self.name})"


def build_variety_lattice():
    """
    Build the lattice of sub-varieties of groupoids (one binary operation).

    The lattice is ordered by inclusion: T₁ ≤ T₂ means every T₂-algebra
    is also a T₁-algebra (T₂ has MORE axioms, so FEWER models).
    """

    # Define the theories (bottom = most general, top = most restrictive trivial)
    trivial = AlgebraicTheory(
        "Trivial", [("·", 2)],
        ["x·y = x·y (no real axiom — all one-element algebras)"],
    )

    groupoid = AlgebraicTheory(
        "Groupoid", [("·", 2)], ["(none — any binary operation)"]
    )

    semigroup = AlgebraicTheory(
        "Semigroup", [("·", 2)],
        ["(x·y)·z = x·(y·z)"],
        parent_theories=["Groupoid"]
    )

    comm_groupoid = AlgebraicTheory(
        "Comm. Groupoid", [("·", 2)],
        ["x·y = y·x"],
        parent_theories=["Groupoid"]
    )

    comm_semigroup = AlgebraicTheory(
        "Comm. Semigroup", [("·", 2)],
        ["(x·y)·z = x·(y·z)", "x·y = y·x"],
        parent_theories=["Semigroup", "Comm. Groupoid"]
    )

    idemp_groupoid = AlgebraicTheory(
        "Idemp. Groupoid", [("·", 2)],
        ["x·x = x"],
        parent_theories=["Groupoid"]
    )

    band = AlgebraicTheory(
        "Band", [("·", 2)],
        ["(x·y)·z = x·(y·z)", "x·x = x"],
        parent_theories=["Semigroup", "Idemp. Groupoid"]
    )

    semilattice = AlgebraicTheory(
        "Semilattice", [("·", 2)],
        ["(x·y)·z = x·(y·z)", "x·y = y·x", "x·x = x"],
        parent_theories=["Comm. Semigroup", "Band"]
    )

    left_zero = AlgebraicTheory(
        "Left-Zero", [("·", 2)],
        ["x·y = x"],
        parent_theories=["Band"]
    )

    right_zero = AlgebraicTheory(
        "Right-Zero", [("·", 2)],
        ["x·y = y"],
        parent_theories=["Band"]
    )

    monoid = AlgebraicTheory(
        "Monoid", [("·", 2), ("e", 0)],
        ["(x·y)·z = x·(y·z)", "e·x = x", "x·e = x"],
        parent_theories=["Semigroup"]
    )

    comm_monoid = AlgebraicTheory(
        "Comm. Monoid", [("·", 2), ("e", 0)],
        ["(x·y)·z = x·(y·z)", "x·y = y·x", "e·x = x"],
        parent_theories=["Monoid", "Comm. Semigroup"]
    )

    group = AlgebraicTheory(
        "Group", [("·", 2), ("e", 0), ("⁻¹", 1)],
        ["(x·y)·z = x·(y·z)", "e·x = x", "x⁻¹·x = e"],
        parent_theories=["Monoid"]
    )

    abelian_group = AlgebraicTheory(
        "Abelian Group", [("·", 2), ("e", 0), ("⁻¹", 1)],
        ["(x·y)·z = x·(y·z)", "x·y = y·x", "e·x = x", "x⁻¹·x = e"],
        parent_theories=["Group", "Comm. Monoid"]
    )

    theories = [
        groupoid, comm_groupoid, idemp_groupoid, semigroup,
        comm_semigroup, band, semilattice, left_zero, right_zero,
        monoid, comm_monoid, group, abelian_group, trivial
    ]

    return theories


def print_lattice(theories):
    """Print the variety lattice as a text diagram."""
    print("=" * 70)
    print("THE LATTICE OF VARIETIES (Sub-varieties of Groupoids)")
    print("=" * 70)
    print()
    print("Ordered by INCLUSION of model classes (top = fewest models)")
    print()

    # Assign levels for display
    levels = {
        "Groupoid": 0,
        "Comm. Groupoid": 1, "Semigroup": 1, "Idemp. Groupoid": 1,
        "Comm. Semigroup": 2, "Band": 2, "Monoid": 2,
        "Semilattice": 3, "Left-Zero": 3, "Right-Zero": 3,
        "Comm. Monoid": 3, "Group": 3,
        "Abelian Group": 4,
        "Trivial": 5,
    }

    for level in range(6):
        theories_at_level = [t for t in theories if levels.get(t.name, -1) == level]
        if theories_at_level:
            print(f"Level {level}: ", end="")
            names = [f"[{t.name}]" for t in theories_at_level]
            print("  ".join(names))

            for t in theories_at_level:
                if t.parent_theories:
                    for p in t.parent_theories:
                        print(f"    ↑ {t.name} ⊂ {p}")
            print()

    print("-" * 70)
    print("KEY INSIGHT: This lattice is itself an algebraic structure!")
    print("The meet (∧) of two varieties = their intersection")
    print("The join (∨) of two varieties = the smallest variety containing both")
    print("This lattice is ALGEBRAIC: every element is a join of compact elements.")
    print("-" * 70)


def visualize_lattice(theories):
    """Create a visual diagram of the variety lattice."""
    if not HAS_MPL:
        print("[SKIP] Cannot create visual — matplotlib not installed.")
        return

    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 6.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("The Lattice of Algebraic Varieties\n(Sub-varieties of Groupoids)",
                 fontsize=18, fontweight='bold', pad=20)

    # Node positions
    positions = {
        "Groupoid":        (5, 0),
        "Semigroup":       (3, 1),
        "Comm. Groupoid":  (5, 1),
        "Idemp. Groupoid": (7, 1),
        "Comm. Semigroup": (2, 2),
        "Band":            (5, 2),
        "Monoid":          (8, 2),
        "Semilattice":     (1, 3),
        "Left-Zero":       (4, 3),
        "Right-Zero":      (6, 3),
        "Comm. Monoid":    (8, 3),
        "Group":           (10, 3),
        "Abelian Group":   (9, 4),
        "Trivial":         (5, 5.5),
    }

    colors = {
        "Groupoid": "#E8F5E9",
        "Semigroup": "#C8E6C9", "Comm. Groupoid": "#C8E6C9",
        "Idemp. Groupoid": "#C8E6C9",
        "Comm. Semigroup": "#A5D6A7", "Band": "#A5D6A7", "Monoid": "#A5D6A7",
        "Semilattice": "#81C784", "Left-Zero": "#81C784", "Right-Zero": "#81C784",
        "Comm. Monoid": "#66BB6A", "Group": "#66BB6A",
        "Abelian Group": "#43A047",
        "Trivial": "#2E7D32",
    }

    # Draw edges (Hasse diagram)
    edges = [
        ("Groupoid", "Semigroup"),
        ("Groupoid", "Comm. Groupoid"),
        ("Groupoid", "Idemp. Groupoid"),
        ("Semigroup", "Comm. Semigroup"),
        ("Semigroup", "Band"),
        ("Semigroup", "Monoid"),
        ("Comm. Groupoid", "Comm. Semigroup"),
        ("Idemp. Groupoid", "Band"),
        ("Comm. Semigroup", "Semilattice"),
        ("Band", "Semilattice"),
        ("Band", "Left-Zero"),
        ("Band", "Right-Zero"),
        ("Monoid", "Comm. Monoid"),
        ("Monoid", "Group"),
        ("Comm. Semigroup", "Comm. Monoid"),
        ("Comm. Monoid", "Abelian Group"),
        ("Group", "Abelian Group"),
        ("Semilattice", "Trivial"),
        ("Left-Zero", "Trivial"),
        ("Right-Zero", "Trivial"),
        ("Abelian Group", "Trivial"),
    ]

    for (a, b) in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', linewidth=1.0, alpha=0.4, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        color = colors.get(name, "#FFFFFF")
        circle = plt.Circle((x, y), 0.4, color=color, ec='black',
                             linewidth=1.5, zorder=2)
        ax.add_patch(circle)
        fontsize = 7 if len(name) > 10 else 8
        ax.text(x, y, name, ha='center', va='center', fontsize=fontsize,
                fontweight='bold', zorder=3)

    # Add annotation
    ax.text(0.5, -0.02,
            "⬆ More axioms → fewer models → higher in lattice\n"
            "This lattice is itself an algebraic lattice — algebra studying algebra!",
            transform=ax.transAxes, ha='center', va='top',
            fontsize=11, style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                      edgecolor='orange', alpha=0.8))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebra/AlgebraicTheoryOfAlgebra/demos/variety_lattice.png',
                dpi=150, bbox_inches='tight')
    print("[OK] Saved variety_lattice.png")
    plt.close()


# ============================================================
# Part 2: The Algebra of the Lattice
# ============================================================

def demonstrate_lattice_operations():
    """Show that lattice operations on varieties are algebraic."""
    print()
    print("=" * 70)
    print("LATTICE OPERATIONS ON VARIETIES")
    print("=" * 70)
    print()

    print("Meet (∧): Intersection of varieties")
    print("  Semigroup ∧ Comm. Groupoid = Comm. Semigroup")
    print("  (associative + commutative)")
    print()

    print("Join (∨): Smallest variety containing both")
    print("  Left-Zero ∨ Right-Zero = Band")
    print("  (the smallest variety containing both is all bands)")
    print()

    print("The meet is always easy (intersection of equational classes)")
    print("The join can be surprising (may require NEW equations)")
    print()

    print("SELF-REFERENCE:")
    print("  These lattice operations (∧, ∨) are themselves algebraic operations")
    print("  on the set of varieties. The lattice of varieties is an ALGEBRA")
    print("  in the variety of LATTICES.")
    print()
    print("  Therefore: the study of algebraic theories IS an algebraic theory.")
    print("  The snake eats its own tail. ∎")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   THE ALGEBRAIC THEORY OF ALGEBRA — Demo 1                 ║")
    print("║   The Lattice of Varieties                                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    theories = build_variety_lattice()
    print_lattice(theories)
    visualize_lattice(theories)
    demonstrate_lattice_operations()
