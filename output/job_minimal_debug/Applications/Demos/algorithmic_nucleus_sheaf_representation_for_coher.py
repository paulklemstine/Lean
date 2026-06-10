#!/usr/bin/env python3
"""
Nucleus-Sheaf Reconstruction: Interactive Demonstration
=======================================================

This script demonstrates the key theorems from the Lean formalization of
nucleus-sheaf reconstruction for coherent idempotent semirings:

1. Local quotients and evaluation at nucleus points
2. Prime separation and the local-to-global principle
3. Binary gluing of compatible local sections
4. The global sections reconstruction isomorphism

We use the Boolean semiring {0, 1} with OR as addition and AND as multiplication
as a concrete, computable example of an idempotent commutative semiring.
"""

import itertools
from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Set, FrozenSet
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# =============================================================================
# 1. THE BOOLEAN SEMIRING: Simplest idempotent commutative semiring
# =============================================================================

class BoolSemiring:
    """
    The Boolean semiring ({0, 1}, OR, AND).
    - Addition = OR (idempotent: a OR a = a)
    - Multiplication = AND
    - Zero = 0, One = 1
    """
    def __init__(self, val: int):
        self.val = 1 if val else 0

    def __add__(self, other):
        return BoolSemiring(self.val | other.val)

    def __mul__(self, other):
        return BoolSemiring(self.val & other.val)

    def __eq__(self, other):
        return self.val == other.val

    def __hash__(self):
        return hash(self.val)

    def __repr__(self):
        return str(self.val)

    @staticmethod
    def zero():
        return BoolSemiring(0)

    @staticmethod
    def one():
        return BoolSemiring(1)


# =============================================================================
# 2. FINITE IDEMPOTENT SEMIRING: Product of Boolean semirings
# =============================================================================

class FiniteIdemSemiring:
    """
    The product semiring B^n = {0,1}^n with componentwise OR and AND.
    This is a coherent idempotent commutative semiring.
    Elements are n-tuples of 0s and 1s.
    """
    def __init__(self, coords: Tuple[int, ...]):
        self.coords = tuple(1 if c else 0 for c in coords)
        self.n = len(coords)

    def __add__(self, other):
        assert self.n == other.n
        return FiniteIdemSemiring(tuple(a | b for a, b in zip(self.coords, other.coords)))

    def __mul__(self, other):
        assert self.n == other.n
        return FiniteIdemSemiring(tuple(a & b for a, b in zip(self.coords, other.coords)))

    def __eq__(self, other):
        return self.coords == other.coords

    def __hash__(self):
        return hash(self.coords)

    def __repr__(self):
        return str(self.coords)


# =============================================================================
# 3. NUCLEUS POINTS (PRIME CONGRUENCES) ON B^n
# =============================================================================

@dataclass
class ProjectionCongruence:
    """
    A projection congruence on B^n: identifies elements that agree on coordinate i.
    This is π_i : B^n → B, and two elements are congruent iff π_i(a) = π_i(b).

    These are exactly the prime congruences of B^n.
    """
    index: int
    n: int

    def congruent(self, a: FiniteIdemSemiring, b: FiniteIdemSemiring) -> bool:
        """Check if a ≡ b under this congruence (same i-th coordinate)."""
        return a.coords[self.index] == b.coords[self.index]

    def evaluate(self, a: FiniteIdemSemiring) -> int:
        """Evaluate at this point: project to coordinate i."""
        return a.coords[self.index]

    def __repr__(self):
        return f"π_{self.index}"

    def __hash__(self):
        return hash((self.index, self.n))

    def __eq__(self, other):
        return isinstance(other, ProjectionCongruence) and self.index == other.index


# =============================================================================
# 4. SECTION CONGRUENCES AND LOCAL QUOTIENTS
# =============================================================================

def section_congruence(points: List[ProjectionCongruence],
                       a: FiniteIdemSemiring,
                       b: FiniteIdemSemiring) -> bool:
    """
    The section congruence θ_U(a, b) = ∀ x ∈ U, x.con(a, b).
    Two elements are identified iff they agree at ALL points in U.
    """
    return all(p.congruent(a, b) for p in points)


def local_quotient_class(points: List[ProjectionCongruence],
                         a: FiniteIdemSemiring,
                         all_elements: List[FiniteIdemSemiring]) -> FrozenSet:
    """
    Compute the equivalence class [a] in LocalQuotient S U.
    Returns the set of elements equivalent to a under the section congruence.
    """
    return frozenset(b for b in all_elements if section_congruence(points, a, b))


def local_quotient_classes(points: List[ProjectionCongruence],
                           all_elements: List[FiniteIdemSemiring]) -> List[FrozenSet]:
    """Compute all equivalence classes in LocalQuotient S U."""
    seen = set()
    classes = []
    for a in all_elements:
        cls = local_quotient_class(points, a, all_elements)
        if cls not in seen:
            seen.add(cls)
            classes.append(cls)
    return classes


# =============================================================================
# DEMO 1: Idempotent Semiring Basics
# =============================================================================

def demo_idempotent_basics():
    print("=" * 70)
    print("DEMO 1: Idempotent Semiring Basics")
    print("=" * 70)
    print()
    print("The Boolean semiring B = ({0,1}, OR, AND) is idempotent:")
    for v in [BoolSemiring(0), BoolSemiring(1)]:
        print(f"  {v} + {v} = {v + v}  (a + a = a ✓)")
    print()

    n = 3
    print(f"The product B^{n} has {2**n} elements:")
    elements = [FiniteIdemSemiring(t) for t in itertools.product([0, 1], repeat=n)]
    for e in elements:
        ee = e + e
        assert ee == e, f"Idempotence failed for {e}"
    print(f"  All {2**n} elements satisfy a + a = a ✓")
    print()

    # Show some operations
    a = FiniteIdemSemiring((1, 0, 1))
    b = FiniteIdemSemiring((0, 1, 1))
    print(f"  {a} + {b} = {a + b}  (componentwise OR)")
    print(f"  {a} * {b} = {a * b}  (componentwise AND)")
    print()
    return elements


# =============================================================================
# DEMO 2: Prime Separation (congruence_eq_iff_locally)
# =============================================================================

def demo_prime_separation(elements):
    n = elements[0].n
    print("=" * 70)
    print("DEMO 2: Prime Separation — congruence_eq_iff_locally")
    print("=" * 70)
    print()
    print("Theorem: a = b ↔ ∀ nucleus point x, evalAt x a = evalAt x b")
    print()

    # Define all nucleus points (projection congruences)
    points = [ProjectionCongruence(i, n) for i in range(n)]
    print(f"B^{n} has {n} nucleus points: {points}")
    print()

    # Verify prime separation for all pairs
    separations_found = 0
    total_distinct = 0
    for a in elements:
        for b in elements:
            if a != b:
                total_distinct += 1
                # Find a separating point
                sep = [p for p in points if not p.congruent(a, b)]
                assert len(sep) > 0, f"No separation for {a} ≠ {b}!"
                separations_found += 1

    print(f"  Checked {total_distinct} distinct pairs: all separated ✓")
    print()

    # Show specific examples
    a = FiniteIdemSemiring((1, 0, 1))
    b = FiniteIdemSemiring((1, 1, 1))
    print(f"  Example: a = {a}, b = {b}")
    for p in points:
        eq = "=" if p.congruent(a, b) else "≠"
        print(f"    {p}(a) = {p.evaluate(a)}, {p}(b) = {p.evaluate(b)} → {eq}")
    sep = [p for p in points if not p.congruent(a, b)]
    print(f"    Separating point: {sep[0]} ✓")
    print()

    return points


# =============================================================================
# DEMO 3: Local Quotients and Restriction Maps
# =============================================================================

def demo_local_quotients(elements, points):
    n = elements[0].n
    print("=" * 70)
    print("DEMO 3: Local Quotients and Restriction Maps")
    print("=" * 70)
    print()

    # Show local quotient for different opens
    print("Local quotients S/θ_U for different sets U of nucleus points:")
    print()

    for k in range(n + 1):
        for subset in itertools.combinations(range(n), k):
            U = [points[i] for i in subset]
            classes = local_quotient_classes(U, elements)
            U_name = "{" + ", ".join(str(p) for p in U) + "}" if U else "∅"
            print(f"  U = {U_name}: |LocalQuotient| = {len(classes)}")

    print()
    print("  U = ∅ gives 1 class (everything identified)")
    print(f"  U = all {n} points gives {2**n} classes (full separation = S itself)")
    print()

    # Demonstrate restriction: V ⊆ U means LocalQuotient U → LocalQuotient V
    U = [points[0], points[1]]
    V = [points[0]]
    print(f"  Restriction: U = {{π₀, π₁}} → V = {{π₀}}")
    U_classes = local_quotient_classes(U, elements)
    V_classes = local_quotient_classes(V, elements)
    print(f"    |LocalQuotient U| = {len(U_classes)} → |LocalQuotient V| = {len(V_classes)}")
    print(f"    (each U-class maps to a V-class by forgetting π₁-information)")
    print()


# =============================================================================
# DEMO 4: Binary Gluing / Patching
# =============================================================================

def demo_binary_gluing(elements, points):
    n = elements[0].n
    print("=" * 70)
    print("DEMO 4: Binary Gluing of Compatible Sections")
    print("=" * 70)
    print()

    # Take U = {π₀, π₁} and V = {π₁, π₂}
    U_indices = [0, 1]
    V_indices = [1, 2]
    UV_indices = [0, 1, 2]  # union
    inter_indices = [1]     # intersection

    U = [points[i] for i in U_indices]
    V = [points[i] for i in V_indices]
    UV = [points[i] for i in UV_indices]
    inter = [points[i] for i in inter_indices]

    print(f"  U = {{π₀, π₁}}, V = {{π₁, π₂}}, U∩V = {{π₁}}, U∪V = {{π₀, π₁, π₂}}")
    print()

    # Pick compatible sections
    a = FiniteIdemSemiring((1, 0, 1))  # represents [a]_U
    b = FiniteIdemSemiring((0, 0, 0))  # represents [b]_V

    # Check compatibility: [a]_{U∩V} = [b]_{U∩V}?
    compat = section_congruence(inter, a, b)
    print(f"  sU represented by a = {a}")
    print(f"  sV represented by b = {b}")
    print(f"  Compatible on U∩V? {compat}")

    if compat:
        print(f"    (both have π₁-value = {inter[0].evaluate(a)})")
        # Find patching element c with θ_U(c,a) and θ_V(c,b)
        found = False
        for c in elements:
            if section_congruence(U, c, a) and section_congruence(V, c, b):
                print(f"  Patching element: c = {c}")
                print(f"    c agrees with a on U: {section_congruence(U, c, a)} ✓")
                print(f"    c agrees with b on V: {section_congruence(V, c, b)} ✓")
                found = True
                break
        if not found:
            print("  No patching element found (CRT condition may not hold)")
    else:
        # Find compatible pair
        print("  Not compatible. Finding a compatible pair...")
        for a2 in elements:
            for b2 in elements:
                if section_congruence(inter, a2, b2) and a2 != b2:
                    # Check if CRT gives a patching element
                    for c in elements:
                        if section_congruence(U, c, a2) and section_congruence(V, c, b2):
                            print(f"  Found compatible pair: a={a2}, b={b2}")
                            print(f"  Patching element: c = {c}")
                            break
                    break
            else:
                continue
            break

    print()

    # Systematic check: for all compatible pairs, does patching exist?
    print("  Systematic verification of gluing for all compatible pairs:")
    total_compat = 0
    total_glued = 0
    for a in elements:
        for b in elements:
            if section_congruence(inter, a, b):
                total_compat += 1
                for c in elements:
                    if section_congruence(U, c, a) and section_congruence(V, c, b):
                        total_glued += 1
                        break
    print(f"    Compatible pairs: {total_compat}")
    print(f"    Successfully glued: {total_glued}")
    print(f"    CRT property holds: {total_compat == total_glued} ✓")
    print()


# =============================================================================
# DEMO 5: Global Sections Isomorphism
# =============================================================================

def demo_global_sections(elements, points):
    n = elements[0].n
    print("=" * 70)
    print("DEMO 5: Global Sections Reconstruction Isomorphism")
    print("=" * 70)
    print()

    # The global section map: S → LocalQuotient S (all points)
    all_classes = local_quotient_classes(points, elements)
    print(f"  S = B^{n} has {len(elements)} elements")
    print(f"  LocalQuotient S (all points) has {len(all_classes)} classes")
    print()

    if len(elements) == len(all_classes):
        print("  The global section map is BIJECTIVE ✓")
        print("  This confirms: S ≅ GlobalSections(S)")
        print()
        print("  Concretely, each element is uniquely determined by its")
        print(f"  evaluations at the {n} nucleus points (projection congruences):")
        print()
        for e in elements:
            evals = tuple(p.evaluate(e) for p in points)
            print(f"    {e} ↦ evaluations {evals}")
    else:
        print(f"  Global section map is NOT injective (missing separation)")
    print()


# =============================================================================
# VISUALIZATION: The Nucleus Spectrum
# =============================================================================

def visualize_spectrum():
    """Visualize the nucleus spectrum of B^3 and its local quotients."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # 1. The spectrum: 3 points
    ax = axes[0]
    ax.set_title("Nucleus Spectrum of B³", fontsize=14, fontweight='bold')
    angles = [90, 210, 330]
    radius = 0.35
    point_positions = {}
    for i, angle in enumerate(angles):
        x = 0.5 + radius * np.cos(np.radians(angle))
        y = 0.5 + radius * np.sin(np.radians(angle))
        ax.plot(x, y, 'ko', markersize=15)
        ax.annotate(f'π₋{i}', (x, y), textcoords="offset points",
                    xytext=(15, 5), fontsize=14, fontweight='bold')
        point_positions[i] = (x, y)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.text(0.5, 0.05, "3 nucleus points\n(prime congruences)",
            ha='center', fontsize=10, style='italic')

    # 2. Local quotients by size
    ax = axes[1]
    ax.set_title("Local Quotient Sizes |S/θ_U|", fontsize=14, fontweight='bold')
    opens = [
        ("∅", 0, 1),
        ("{π₀}", 1, 2),
        ("{π₁}", 1, 2),
        ("{π₂}", 1, 2),
        ("{π₀,π₁}", 2, 4),
        ("{π₁,π₂}", 2, 4),
        ("{π₀,π₂}", 2, 4),
        ("{π₀,π₁,π₂}", 3, 8),
    ]
    sizes = [s for _, _, s in opens]
    labels = [name for name, _, _ in opens]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(opens)))
    bars = ax.barh(range(len(opens)), sizes, color=colors)
    ax.set_yticks(range(len(opens)))
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel("|LocalQuotient S U|", fontsize=11)
    for bar, size in zip(bars, sizes):
        ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
                str(size), va='center', fontsize=10)

    # 3. Restriction maps diagram
    ax = axes[2]
    ax.set_title("Restriction Maps (Presheaf)", fontsize=14, fontweight='bold')

    # Draw a lattice of opens
    positions = {
        "∅": (0.5, 0.1),
        "{0}": (0.15, 0.3), "{1}": (0.5, 0.3), "{2}": (0.85, 0.3),
        "{0,1}": (0.15, 0.6), "{1,2}": (0.5, 0.6), "{0,2}": (0.85, 0.6),
        "{0,1,2}": (0.5, 0.85),
    }

    # Draw edges (restriction maps go from larger to smaller open)
    edges = [
        ("{0,1,2}", "{0,1}"), ("{0,1,2}", "{1,2}"), ("{0,1,2}", "{0,2}"),
        ("{0,1}", "{0}"), ("{0,1}", "{1}"),
        ("{1,2}", "{1}"), ("{1,2}", "{2}"),
        ("{0,2}", "{0}"), ("{0,2}", "{2}"),
        ("{0}", "∅"), ("{1}", "∅"), ("{2}", "∅"),
    ]

    for start, end in edges:
        x1, y1 = positions[start]
        x2, y2 = positions[end]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="->", color="gray", lw=1.5))

    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=20, color='steelblue', zorder=5)
        ax.text(x, y, name.replace("{", "").replace("}", ""),
                ha='center', va='center', fontsize=7, color='white',
                fontweight='bold', zorder=6)

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0, 1)
    ax.axis('off')
    ax.text(0.5, -0.02, "Arrows = restriction maps\n(presheaf structure)",
            ha='center', fontsize=9, style='italic')

    plt.tight_layout()
    plt.savefig("/workspace/request-project/nucleus_spectrum_visualization.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: nucleus_spectrum_visualization.png")


# =============================================================================
# DEMO 6: Application — Tropical Semiring Sketch
# =============================================================================

def demo_tropical_application():
    print("=" * 70)
    print("DEMO 6: Application — Tropical Semiring & Optimization")
    print("=" * 70)
    print()
    print("The tropical semiring T = (ℝ ∪ {∞}, min, +) is idempotent:")
    print("  min(a, a) = a for all a")
    print()
    print("Nucleus-sheaf reconstruction applies to tropical geometry:")
    print()
    print("  • Nucleus points correspond to 'tropical valuations'")
    print("  • Local quotients give 'piecewise-linear localizations'")
    print("  • The reconstruction theorem says:")
    print("    A tropical polynomial is determined by its values at")
    print("    all tropical prime points (vertices of Newton polytopes)")
    print()
    print("Application to optimization:")
    print("  A shortest-path computation in a network can be decomposed:")
    print("  1. Compute local shortest paths in subnetworks (local quotients)")
    print("  2. Glue compatible local solutions (binary gluing theorem)")
    print("  3. Recover the global shortest path (reconstruction isomorphism)")
    print()
    print("  This is the 'sheaf-theoretic' view of Dijkstra's algorithm:")
    print("  global optimality = gluing of local optimalities.")
    print()

    # Simple tropical shortest path example
    # min-plus semiring on small values
    INF = float('inf')

    def trop_add(a, b):
        return min(a, b)

    def trop_mul(a, b):
        return a + b if a < INF and b < INF else INF

    # Adjacency matrix (weights) for a 4-node graph
    #   0 --3-- 1
    #   |       |
    #   2       1
    #   |       |
    #   3 --4-- 2
    W = [
        [0,   3,   2,   INF],
        [3,   0,   INF, 1  ],
        [INF, INF, 0,   4  ],
        [INF, 1,   4,   0  ],
    ]

    print("  Example: 4-node graph")
    print("    0 --3-- 1")
    print("    |       |")
    print("    2       1")
    print("    |       |")
    print("    3 --4-- 2")
    print()

    # Compute all-pairs shortest paths (tropical matrix power)
    n = 4
    D = [row[:] for row in W]
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i][j] = trop_add(D[i][j], trop_mul(D[i][k], D[k][j]))

    print("  All-pairs shortest distances (tropical matrix closure):")
    for i in range(n):
        row = " ".join(f"{D[i][j]:3g}" for j in range(n))
        print(f"    {row}")
    print()
    print("  Key insight: these distances are 'global sections' of the")
    print("  tropical structure sheaf on the graph's metric spectrum.")
    print()


# =============================================================================
# MAIN
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  NUCLEUS-SHEAF RECONSTRUCTION FOR IDEMPOTENT SEMIRINGS         ║")
    print("║  Interactive Demonstration of Formally Verified Theorems       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    elements = demo_idempotent_basics()
    points = demo_prime_separation(elements)
    demo_local_quotients(elements, points)
    demo_binary_gluing(elements, points)
    demo_global_sections(elements, points)

    print("=" * 70)
    print("VISUALIZATION")
    print("=" * 70)
    print()
    visualize_spectrum()
    print()

    demo_tropical_application()

    print("=" * 70)
    print("SUMMARY OF FORMALLY VERIFIED THEOREMS")
    print("=" * 70)
    print()
    print("All of the following are proved in Lean 4 without sorry:")
    print()
    print("  1. congruence_eq_iff_locally")
    print("     a = b ↔ ∀ nucleus point x, evalAt x a = evalAt x b")
    print("     (Under prime separation hypothesis)")
    print()
    print("  2. toGlobalSections_injective_of_prime_separation")
    print("     The global section map S →+* LocalQuotient S univ is injective")
    print()
    print("  3. globalSectionsIso")
    print("     S ≃+* LocalQuotient S univ (ring isomorphism)")
    print()
    print("  4. sections_glue_binary")
    print("     Compatible sections over U and V glue over U ∪ V")
    print("     (Under congruence CRT hypothesis)")
    print()
    print("  5. restrict_id, restrict_comp")
    print("     Presheaf laws: identity and composition of restrictions")
    print()
    print("  6. toStalkProduct_injective")
    print("     Faithful embedding into the product of all stalks")
    print()


if __name__ == "__main__":
    main()
