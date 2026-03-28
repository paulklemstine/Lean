#!/usr/bin/env python3
"""
Demo 3: Monads as Algebraic Theories — The Categorical Bridge

Every algebraic theory gives rise to a monad, and every finitary monad
on Set comes from an algebraic theory. This demo shows the correspondence
computationally and visualizes the "algebra of monads."

The Algebraic Theory of Algebra: monads ARE theories, categorically.
"""

from collections import defaultdict
from functools import reduce

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


# ============================================================
# Part 1: Monads as Data Structures
# ============================================================

class Monad:
    """
    A computational monad, viewed as an algebraic theory.

    We represent a monad T on finite sets via:
    - T(n) = the free algebra on n generators (as a finite set)
    - unit: n → T(n) = the inclusion of generators
    - mult: T(T(n)) → T(n) = substitution/flattening
    """

    def __init__(self, name, description, free_on_n, unit_example, mult_example):
        self.name = name
        self.description = description
        self.free_on_n = free_on_n  # function: n → |T(n)|
        self.unit_example = unit_example
        self.mult_example = mult_example

    def __repr__(self):
        return f"Monad({self.name})"


def define_classical_monads():
    """Define the classical monads and their algebraic theories."""

    # Identity monad = theory of sets (no operations)
    identity = Monad(
        "Identity (Sets)",
        "T(X) = X. Theory: no operations, no axioms.",
        free_on_n=lambda n: n,
        unit_example="id: x ↦ x",
        mult_example="id: x ↦ x"
    )

    # Maybe monad = theory of pointed sets (one constant)
    maybe = Monad(
        "Maybe (Pointed Sets)",
        "T(X) = X ∪ {⊥}. Theory: one constant ⊥.",
        free_on_n=lambda n: n + 1,
        unit_example="Just: x ↦ Just(x)",
        mult_example="flatten: Just(Just(x)) ↦ Just(x), Just(⊥) ↦ ⊥"
    )

    # List monad = theory of monoids
    list_monad = Monad(
        "List (Monoids)",
        "T(X) = X*. Theory: binary op (·), unit (e), assoc + unit laws.",
        free_on_n=lambda n: sum(n**k for k in range(8)),  # truncated
        unit_example="singleton: x ↦ [x]",
        mult_example="concat: [[a,b],[c]] ↦ [a,b,c]"
    )

    # Non-empty list monad = theory of semigroups
    nelist = Monad(
        "NEList (Semigroups)",
        "T(X) = X⁺. Theory: binary op (·), associativity.",
        free_on_n=lambda n: sum(n**k for k in range(1, 8)),  # truncated
        unit_example="singleton: x ↦ [x]",
        mult_example="concat: [[a,b],[c]] ↦ [a,b,c]"
    )

    # Multiset monad = theory of commutative monoids
    multiset = Monad(
        "Multiset (Comm. Monoids)",
        "T(X) = finite multisets over X. Theory: (+), 0, assoc + comm + unit.",
        free_on_n=lambda n: sum(
            # C(n+k-1, k) for k=0..7
            1 if k == 0 else
            reduce(lambda a, b: a * b, range(n, n + k)) // reduce(lambda a, b: a * b, range(1, k + 1))
            for k in range(8)
        ),
        unit_example="{x}: x ↦ {x}",
        mult_example="union: {{a,b},{c}} ↦ {a,b,c}"
    )

    # Powerset monad = theory of join-semilattices with ⊥
    powerset = Monad(
        "Powerset (Sup-Semilattices)",
        "T(X) = P(X). Theory: binary ∨, ⊥, assoc + comm + idemp + unit.",
        free_on_n=lambda n: 2**n,
        unit_example="singleton: x ↦ {x}",
        mult_example="union: {{a,b},{c}} ↦ {a,b,c}"
    )

    # Reader monad = theory of "sets with E-indexed unary operations"
    # For E = {0,1}: T(X) = X^E = X²
    reader2 = Monad(
        "Reader(2) (E=Bool)",
        "T(X) = X². Theory: two projections π₀, π₁ with π_i(f(x₀,x₁)) = xᵢ.",
        free_on_n=lambda n: n**2,
        unit_example="diag: x ↦ (x,x)",
        mult_example="apply: f ↦ (f(0)(0), f(1)(1))"
    )

    return [identity, maybe, list_monad, nelist, multiset, powerset, reader2]


# ============================================================
# Part 2: The Algebra of Monads
# ============================================================

def monad_algebra_demo(monads):
    """Show how monads/theories compose and interact."""

    print("=" * 70)
    print("THE ALGEBRA OF MONADS (= THE ALGEBRA OF ALGEBRAIC THEORIES)")
    print("=" * 70)
    print()

    print("Each monad T corresponds to an algebraic theory.")
    print("The free algebra T(n) on n generators tells us the theory's 'size'.")
    print()

    print(f"{'Monad/Theory':<30} | {'|T(1)|':>8} {'|T(2)|':>8} {'|T(3)|':>8} {'|T(4)|':>8}")
    print("-" * 70)

    for m in monads:
        sizes = [m.free_on_n(k) for k in [1, 2, 3, 4]]
        print(f"{m.name:<30} | {sizes[0]:>8} {sizes[1]:>8} {sizes[2]:>8} {sizes[3]:>8}")

    print()
    print("KEY OBSERVATIONS:")
    print("  • More axioms → smaller free algebras (more identifications)")
    print("  • Multiset < List (commutativity identifies more terms)")
    print("  • Powerset < Multiset (idempotency identifies even more)")
    print("  • The identity monad is the INITIAL theory (fewest axioms = none)")
    print()

    print("OPERATIONS ON MONADS/THEORIES:")
    print()

    print("1. COMPOSITION (when distributive law exists):")
    print("   List ∘ Maybe = theory of monoids with absorbing element")
    print("   (This is NOT always a monad — need a distributive law λ: ST → TS)")
    print()

    print("2. COPRODUCT (free product of theories):")
    print("   T₁ + T₂ has all operations of both, no interaction axioms")
    print("   Example: Semigroup + PointedSet = 'semigroup with a distinguished point'")
    print()

    print("3. TENSOR PRODUCT (commutative combination):")
    print("   T₁ ⊗ T₂: all operations of both, plus every T₁-op commutes with every T₂-op")
    print("   Example: Monoid ⊗ Monoid = theory underlying RINGS (via Eckmann-Hilton)")
    print("   This is the algebraic reason rings have both + and × !")
    print()

    print("4. MORPHISMS OF THEORIES:")
    print("   A morphism T₁ → T₂ means 'T₂ can interpret all of T₁'")
    print("   Example: Group → Monoid (forget inverses)")
    print("   These morphisms form a category — the CATEGORY OF ALGEBRAIC THEORIES")
    print()

    return monads


# ============================================================
# Part 3: Visualization
# ============================================================

def visualize_monad_sizes(monads):
    """Visualize how free algebra sizes compare across theories."""
    if not HAS_MPL:
        print("[SKIP] matplotlib not available.")
        return

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Plot 1: Free algebra sizes (log scale)
    ns = range(1, 7)
    for m in monads:
        sizes = [m.free_on_n(n) for n in ns]
        axes[0].plot(list(ns), sizes, 'o-', label=m.name, linewidth=2, markersize=6)

    axes[0].set_xlabel('Number of generators (n)', fontsize=12)
    axes[0].set_ylabel('|T(n)| = Size of free algebra', fontsize=12)
    axes[0].set_title('Free Algebra Growth by Theory\n(Log Scale)', fontsize=14)
    axes[0].set_yscale('log')
    axes[0].legend(fontsize=8, loc='upper left')
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Theory relationship diagram
    ax = axes[1]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-0.5, 6.5)
    ax.axis('off')
    ax.set_title('Morphisms Between Algebraic Theories\n(Arrows = "can interpret")',
                 fontsize=14)

    theory_pos = {
        "Sets": (2, 0),
        "Pointed Sets": (0.5, 1),
        "Semigroups": (3.5, 1),
        "Monoids": (2, 2),
        "Comm. Monoids": (0.5, 3),
        "Groups": (3.5, 3),
        "Abelian Groups": (2, 4),
        "Rings": (2, 5.5),
    }

    theory_colors = {
        "Sets": "#E3F2FD",
        "Pointed Sets": "#BBDEFB",
        "Semigroups": "#BBDEFB",
        "Monoids": "#90CAF9",
        "Comm. Monoids": "#64B5F6",
        "Groups": "#64B5F6",
        "Abelian Groups": "#42A5F5",
        "Rings": "#1E88E5",
    }

    # Draw nodes
    for name, (x, y) in theory_pos.items():
        color = theory_colors[name]
        bbox = dict(boxstyle='round,pad=0.4', facecolor=color,
                    edgecolor='black', linewidth=1.5)
        ax.text(x, y, name, ha='center', va='center', fontsize=9,
                fontweight='bold', bbox=bbox)

    # Draw arrows (theory morphisms)
    arrows = [
        ("Sets", "Pointed Sets"),
        ("Sets", "Semigroups"),
        ("Pointed Sets", "Monoids"),
        ("Semigroups", "Monoids"),
        ("Monoids", "Comm. Monoids"),
        ("Monoids", "Groups"),
        ("Comm. Monoids", "Abelian Groups"),
        ("Groups", "Abelian Groups"),
        ("Abelian Groups", "Rings"),
    ]

    for (a, b) in arrows:
        xa, ya = theory_pos[a]
        xb, yb = theory_pos[b]
        ax.annotate('', xy=(xb, yb - 0.3), xytext=(xa, ya + 0.3),
                    arrowprops=dict(arrowstyle='->', color='navy',
                                    lw=1.5, alpha=0.6))

    # Add caption
    ax.text(2, -0.3,
            "More axioms ↓ = stronger theory = fewer models\n"
            "Rings ≅ Monoid ⊗ Monoid (tensor product!)",
            ha='center', fontsize=9, style='italic',
            color='darkblue')

    fig.suptitle('The Algebraic Theory of Algebra: Monads and Theory Morphisms',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebra/AlgebraicTheoryOfAlgebra/demos/monad_algebra.png',
                dpi=150, bbox_inches='tight')
    print("\n[OK] Saved monad_algebra.png")
    plt.close()


def visualize_self_reference():
    """The culminating visualization: the self-referential structure."""
    if not HAS_MPL:
        return

    fig, ax = plt.subplots(figsize=(12, 12))
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Algebraic Theory of Algebra\nSelf-Referential Structure',
                 fontsize=18, fontweight='bold')

    # Draw concentric circles for levels
    import numpy as np

    for r, label, color in [
        (4.2, "Level 3: Category of Algebraic Theories", "#FFCDD2"),
        (3.0, "Level 2: Algebraic Theories\n(Lawvere theories, Monads)", "#EF9A9A"),
        (1.8, "Level 1: Algebras\n(Groups, Rings, Modules...)", "#E57373"),
        (0.8, "Level 0: Sets\n(The base)", "#EF5350"),
    ]:
        circle = plt.Circle((0, 0), r, fill=True, facecolor=color,
                             edgecolor='black', linewidth=2, alpha=0.5)
        ax.add_patch(circle)
        if r > 2:
            ax.text(0, r - 0.4, label, ha='center', va='center',
                    fontsize=9, fontweight='bold')
        else:
            ax.text(0, r - 0.3, label, ha='center', va='center',
                    fontsize=8, fontweight='bold')

    # Draw the self-referential arrow (ouroboros)
    theta = np.linspace(0.3, 5.9, 100)
    spiral_r = 4.5 + 0.15 * np.sin(4 * theta)
    ax.plot(spiral_r * np.cos(theta), spiral_r * np.sin(theta),
            'b-', linewidth=3, alpha=0.6)
    ax.annotate('', xy=(spiral_r[-1] * np.cos(theta[-1]),
                         spiral_r[-1] * np.sin(theta[-1])),
                xytext=(spiral_r[-2] * np.cos(theta[-2]),
                        spiral_r[-2] * np.sin(theta[-2])),
                arrowprops=dict(arrowstyle='->', color='blue', lw=3))

    ax.text(4.8, 2.5, "Self-reference:\nLevel 3 is\nan algebra at\nLevel 1",
            fontsize=10, color='blue', fontweight='bold',
            ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='lightyellow',
                      edgecolor='blue', alpha=0.9))

    # Key insight box
    ax.text(0, -4.7,
            "The collection of all algebraic theories forms a lattice.\n"
            "Lattice theory IS an algebraic theory.\n"
            "Therefore: the algebraic theory of algebra IS an algebra.\n"
            "🐍 The Ouroboros of Mathematics 🐍",
            ha='center', va='center', fontsize=11,
            bbox=dict(boxstyle='round,pad=0.6', facecolor='gold',
                      edgecolor='darkred', linewidth=2, alpha=0.9),
            fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebra/AlgebraicTheoryOfAlgebra/demos/self_reference.png',
                dpi=150, bbox_inches='tight')
    print("[OK] Saved self_reference.png")
    plt.close()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   THE ALGEBRAIC THEORY OF ALGEBRA — Demo 3                 ║")
    print("║   Monads as Algebraic Theories                             ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    monads = define_classical_monads()
    monad_algebra_demo(monads)
    visualize_monad_sizes(monads)
    visualize_self_reference()

    print()
    print("═" * 70)
    print("CONCLUSION: The Algebraic Theory of Algebra")
    print("═" * 70)
    print("""
    We have demonstrated three levels of self-reference:

    1. ALGEBRAS are defined by theories (operations + equations)

    2. THEORIES are themselves algebraic objects:
       - They form a category with products, coproducts, tensor products
       - They correspond to monads (via Lawvere-Linton)
       - They form a lattice (the variety lattice)

    3. THE STUDY OF THEORIES uses algebraic tools (lattice theory,
       category theory) that are themselves algebraic theories

    The circle closes. Algebra contains its own meta-theory.
    This is not a paradox — it is a FIXED POINT of mathematical thought.
    """)
