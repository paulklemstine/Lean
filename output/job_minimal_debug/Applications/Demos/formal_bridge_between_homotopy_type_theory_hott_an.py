"""
Demo: Homotopy Type Theory Bridges

Demonstrates the key results from the formalization:
1. Eckmann-Hilton argument on concrete examples
2. Fiber structure analysis
3. H-level classification
4. Winding number computation
5. Structure Identity Principle (magma transport)
"""

import math
from algorithms import (
    EckmannHiltonData, eckmann_hilton_proof_trace,
    compute_fibers, classify_hlevel,
    MagmaStructure, MagmaIsomorphism,
    winding_number
)


def demo_eckmann_hilton():
    """
    Demonstrate the Eckmann-Hilton argument.

    We construct a type with two operations satisfying interchange:
    - M = Z/nZ (integers mod n)
    - op1 = addition mod n
    - op2 = addition mod n (same operation — this trivially satisfies interchange)

    The Eckmann-Hilton theorem says they must be equal and commutative.
    """
    print("=" * 60)
    print("DEMO 1: Eckmann-Hilton Argument")
    print("=" * 60)

    n = 5
    elements = list(range(n))

    data = EckmannHiltonData(
        op1=lambda a, b: (a + b) % n,
        op2=lambda a, b: (a + b) % n,
        e=0,
        elements=elements
    )

    print(f"\nType: Z/{n}Z = {elements}")
    print(f"Unit element: {data.e}")
    print(f"Unit laws verified: {data.verify_unit_laws()}")
    print(f"Interchange law verified: {data.verify_interchange()}")

    ops_eq, is_comm = data.verify_eckmann_hilton()
    print(f"\nEckmann-Hilton conclusions:")
    print(f"  op1 = op2: {ops_eq}")
    print(f"  Commutative: {is_comm}")

    # Show proof trace for specific elements
    print(f"\nProof trace for a=2, b=3:")
    for step in eckmann_hilton_proof_trace(data, 2, 3):
        print(f"  {step}")

    # Non-trivial example: matrix multiplication (non-commutative, single operation)
    print(f"\n--- Contrast: Non-commutative operation ---")
    # 2x2 matrices over F_2 (field with 2 elements)
    # Only identity satisfies interchange with itself when unit = identity
    print("  2x2 matrices over F_2 do NOT satisfy Eckmann-Hilton")
    print("  (matrix multiplication is not commutative)")
    print()


def demo_fiber_analysis():
    """
    Demonstrate fiber analysis for various functions.
    """
    print("=" * 60)
    print("DEMO 2: Fiber Characterization of Bijections")
    print("=" * 60)

    # Example 1: Bijection
    print("\n--- Example 1: Bijection f(x) = 2x + 1 mod 7 ---")
    n = 7
    f1 = lambda x: (2 * x + 1) % n
    analysis1 = compute_fibers(f1, list(range(n)), list(range(n)))
    print(f"  Domain: {{0,...,{n-1}}}, Codomain: {{0,...,{n-1}}}")
    print(f"  Fiber sizes: {analysis1.fiber_sizes}")
    print(f"  Is bijective: {analysis1.is_bijective}")
    print(f"  (All fibers are singletons ✓)")

    # Example 2: Non-injective
    print("\n--- Example 2: Non-injective f(x) = x mod 3 ---")
    f2 = lambda x: x % 3
    analysis2 = compute_fibers(f2, list(range(9)), list(range(3)))
    print(f"  Domain: {{0,...,8}}, Codomain: {{0,1,2}}")
    print(f"  Fiber sizes: {analysis2.fiber_sizes}")
    print(f"  Is bijective: {analysis2.is_bijective}")
    print(f"  Multi-element fibers: {analysis2.multi_fibers}")

    # Example 3: Non-surjective
    print("\n--- Example 3: Non-surjective f(x) = 2x ---")
    f3 = lambda x: 2 * x
    analysis3 = compute_fibers(f3, list(range(5)), list(range(10)))
    print(f"  Domain: {{0,...,4}}, Codomain: {{0,...,9}}")
    print(f"  Fiber sizes: {analysis3.fiber_sizes}")
    print(f"  Is bijective: {analysis3.is_bijective}")
    print(f"  Empty fibers (not in image): {analysis3.empty_fibers}")
    print()


def demo_hlevel():
    """
    Demonstrate h-level classification.
    """
    print("=" * 60)
    print("DEMO 3: H-Level Hierarchy")
    print("=" * 60)

    # Level 0: Contractible (singleton)
    print("\n--- Contractible type (singleton) ---")
    level = classify_hlevel([42], lambda a, b: a == b)
    print(f"  {{42}}: h-level = {level} (contractible)")

    # Level 1: Mere proposition (but not contractible if empty)
    print("\n--- Empty type ---")
    level = classify_hlevel([], lambda a, b: a == b)
    print(f"  {{}}: h-level = {level} (empty)")

    # Level 2: Set with distinct elements
    print("\n--- Set with distinct elements ---")
    level = classify_hlevel([1, 2, 3], lambda a, b: a == b)
    print(f"  {{1,2,3}}: h-level = {level} (h-set)")

    # Illustrate the hierarchy
    print("\n--- H-Level Hierarchy ---")
    print("  Contractible (0) ⊂ Mere Proposition (1) ⊂ H-Set (2)")
    print("  Every contractible type is a proposition (all elements equal)")
    print("  Every proposition is a set (equality is propositional)")
    print("  Example: {true} is contractible")
    print("  Example: Bool is a set but not a proposition")
    print()


def demo_winding_number():
    """
    Demonstrate winding number computation (modeling π₁(S¹) ≅ ℤ).
    """
    print("=" * 60)
    print("DEMO 4: Winding Numbers and π₁(S¹) ≅ ℤ")
    print("=" * 60)

    N = 1000  # number of sample points

    # Winding number +1: one counterclockwise loop
    path_ccw = [2 * math.pi * i / N for i in range(N + 1)]
    w1 = winding_number(path_ccw)
    print(f"\n  Counterclockwise loop: winding number = {w1}")

    # Winding number -1: one clockwise loop
    path_cw = [-2 * math.pi * i / N for i in range(N + 1)]
    w_neg1 = winding_number(path_cw)
    print(f"  Clockwise loop: winding number = {w_neg1}")

    # Winding number +3: three counterclockwise loops
    path_3 = [6 * math.pi * i / N for i in range(N + 1)]
    w3 = winding_number(path_3)
    print(f"  Triple counterclockwise: winding number = {w3}")

    # Winding number 0: contractible loop
    path_0 = [math.sin(2 * math.pi * i / N) for i in range(N + 1)]
    w0 = winding_number(path_0)
    print(f"  Contractible loop: winding number = {w0}")

    # Additivity: winding(p·q) = winding(p) + winding(q)
    print(f"\n  Additivity check:")
    print(f"    w(+1) + w(+3) = {w1} + {w3} = {w1 + w3}")
    combined = path_ccw + path_3[1:]
    w_combined = winding_number(combined)
    print(f"    w(combined) = {w_combined}")
    print(f"    Match: {w1 + w3 == w_combined}")
    print()


def demo_structure_identity():
    """
    Demonstrate the Structure Identity Principle for magmas.
    """
    print("=" * 60)
    print("DEMO 5: Structure Identity Principle")
    print("=" * 60)

    # Source magma: (Z/4Z, +)
    n = 4
    source = MagmaStructure(
        elements=list(range(n)),
        op=lambda a, b: (a + b) % n
    )
    print(f"\n  Source magma: (Z/{n}Z, +)")
    print(f"  Commutative: {source.is_commutative()}")
    print(f"  Associative: {source.is_associative()}")

    # Target magma: ({0,2,4,6}, + mod 8) ≅ source via x ↦ 2x
    target = MagmaStructure(
        elements=[0, 2, 4, 6],
        op=lambda a, b: (a + b) % 8
    )
    print(f"\n  Target magma: ({{0,2,4,6}}, + mod 8)")

    # Isomorphism: x ↦ 2x
    iso = MagmaIsomorphism(
        source=source,
        target=target,
        forward=lambda x: (2 * x) % 8,
        backward=lambda x: (x // 2) % n
    )
    print(f"  Isomorphism: x ↦ 2x mod 8")
    print(f"  Is homomorphism: {iso.verify_homomorphism()}")
    print(f"  Is bijection: {iso.verify_bijection()}")

    # Transport properties
    print(f"\n  --- Property Transport ---")
    print(f"  Source is commutative: {source.is_commutative()}")
    print(f"  Transport commutativity: {iso.transport_property('commutativity')}")
    print(f"  Target is commutative: {target.is_commutative()} ✓")

    print(f"\n  Source is associative: {source.is_associative()}")
    print(f"  Transport associativity: {iso.transport_property('associativity')}")
    print(f"  Target is associative: {target.is_associative()} ✓")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Homotopy Type Theory: Formal Bridges Demo           ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_eckmann_hilton()
    demo_fiber_analysis()
    demo_hlevel()
    demo_winding_number()
    demo_structure_identity()

    print("All demos completed successfully!")


"""
Visualization: Eckmann-Hilton Argument

Visualizes the interchange law and its consequences for
modular arithmetic groups.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_interchange_grid(n: int = 5) -> None:
    """
    Visualize the interchange law for Z/nZ.

    Shows a 2D grid where:
    - x-axis: op1(a, b) values
    - y-axis: op2(a, b) values
    - Color: whether op1 = op2 at each point
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    elements = list(range(n))

    # Panel 1: op1 multiplication table
    table1 = np.array([[((a + b) % n) for b in elements] for a in elements])
    im1 = axes[0].imshow(table1, cmap='viridis', interpolation='nearest')
    axes[0].set_title(f'op₁(a, b) = (a + b) mod {n}', fontsize=12)
    axes[0].set_xlabel('b')
    axes[0].set_ylabel('a')
    for i in range(n):
        for j in range(n):
            axes[0].text(j, i, str(table1[i, j]),
                        ha='center', va='center', color='white', fontsize=10)
    plt.colorbar(im1, ax=axes[0], shrink=0.8)

    # Panel 2: op2 multiplication table (same operation)
    table2 = np.array([[((a + b) % n) for b in elements] for a in elements])
    im2 = axes[1].imshow(table2, cmap='viridis', interpolation='nearest')
    axes[1].set_title(f'op₂(a, b) = (a + b) mod {n}', fontsize=12)
    axes[1].set_xlabel('b')
    axes[1].set_ylabel('a')
    for i in range(n):
        for j in range(n):
            axes[1].text(j, i, str(table2[i, j]),
                        ha='center', va='center', color='white', fontsize=10)
    plt.colorbar(im2, ax=axes[1], shrink=0.8)

    # Panel 3: Commutativity check
    comm_check = np.array([[(1 if (a + b) % n == (b + a) % n else 0)
                           for b in elements] for a in elements])
    im3 = axes[2].imshow(comm_check, cmap='RdYlGn', interpolation='nearest',
                         vmin=0, vmax=1)
    axes[2].set_title('Eckmann-Hilton: op₁(a,b) = op₁(b,a)', fontsize=12)
    axes[2].set_xlabel('b')
    axes[2].set_ylabel('a')
    for i in range(n):
        for j in range(n):
            axes[2].text(j, i, '✓' if comm_check[i, j] else '✗',
                        ha='center', va='center', fontsize=14)
    plt.colorbar(im3, ax=axes[2], shrink=0.8)

    plt.suptitle('Eckmann-Hilton Argument: Interchange ⟹ Commutativity',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('eckmann_hilton_viz.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eckmann_hilton_viz.png")


def plot_hlevel_hierarchy() -> None:
    """
    Visualize the h-level hierarchy as a nested diagram.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Draw nested regions
    from matplotlib.patches import FancyBboxPatch, Circle

    levels = [
        (0.5, 0.5, 9.0, 6.0, '#E8F5E9', 'H-Set (level 2)\nEquality is decidable'),
        (1.5, 1.0, 7.0, 5.0, '#C8E6C9', 'Mere Proposition (level 1)\n∀ a b : A, a = b'),
        (3.0, 2.0, 4.0, 3.0, '#A5D6A7', 'Contractible (level 0)\n∃ c, ∀ a, a = c'),
    ]

    for x, y, w, h, color, label in levels:
        rect = FancyBboxPatch((x, y), w, h,
                             boxstyle="round,pad=0.3",
                             facecolor=color, edgecolor='#2E7D32',
                             linewidth=2, alpha=0.8)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h - 0.5, label,
               ha='center', va='top', fontsize=11, fontweight='bold')

    # Add examples
    examples = [
        (5.0, 3.5, '• {*}', '#1B5E20'),
        (5.0, 3.0, '• Unit', '#1B5E20'),
        (5.0, 2.0, '• Bool (as Prop)', '#388E3C'),
        (3.0, 1.5, '• ℕ', '#4CAF50'),
        (6.0, 1.5, '• ℤ', '#4CAF50'),
        (8.5, 1.5, '• ℝ', '#4CAF50'),
    ]
    for x, y, text, color in examples:
        ax.text(x, y, text, fontsize=10, color=color)

    # Arrows showing hierarchy
    ax.annotate('', xy=(5, 4.5), xytext=(5, 5.5),
               arrowprops=dict(arrowstyle='->', color='#1B5E20', lw=2))
    ax.text(5.3, 5.0, 'IsContr → IsMereProp', fontsize=9, color='#1B5E20')

    ax.annotate('', xy=(5, 5.7), xytext=(5, 6.2),
               arrowprops=dict(arrowstyle='->', color='#1B5E20', lw=2))
    ax.text(5.3, 5.9, 'IsMereProp → IsHSet', fontsize=9, color='#1B5E20')

    ax.set_xlim(0, 10)
    ax.set_ylim(0, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('H-Level Hierarchy in Homotopy Type Theory',
                fontsize=14, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('hlevel_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hlevel_hierarchy.png")


def plot_fiber_structure() -> None:
    """
    Visualize fiber structures for different functions.
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Function 1: Bijection
    ax = axes[0]
    domain = list(range(5))
    codomain = list(range(5))
    f = lambda x: (2 * x + 1) % 5
    for a in domain:
        ax.annotate('', xy=(1, codomain.index(f(a))),
                   xytext=(0, a),
                   arrowprops=dict(arrowstyle='->', color='#1976D2', lw=1.5))
    for a in domain:
        ax.plot(0, a, 'o', color='#1976D2', markersize=10)
        ax.text(-0.15, a, str(a), ha='right', va='center', fontsize=10)
    for b in codomain:
        ax.plot(1, b, 'o', color='#D32F2F', markersize=10)
        ax.text(1.15, b, str(b), ha='left', va='center', fontsize=10)
    ax.set_title('Bijection: f(x) = 2x+1 mod 5\nAll fibers are singletons ✓',
                fontsize=10)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 4.5)
    ax.axis('off')

    # Function 2: Non-injective
    ax = axes[1]
    domain2 = list(range(6))
    codomain2 = list(range(3))
    f2 = lambda x: x % 3
    for a in domain2:
        ax.annotate('', xy=(1, f2(a)),
                   xytext=(0, a),
                   arrowprops=dict(arrowstyle='->', color='#F57C00', lw=1.5))
    for a in domain2:
        ax.plot(0, a, 'o', color='#1976D2', markersize=10)
        ax.text(-0.15, a, str(a), ha='right', va='center', fontsize=10)
    for b in codomain2:
        ax.plot(1, b, 'o', color='#D32F2F', markersize=10)
        ax.text(1.15, b, str(b), ha='left', va='center', fontsize=10)
    ax.set_title('Non-injective: f(x) = x mod 3\nFibers have 2 elements ✗',
                fontsize=10)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 5.5)
    ax.axis('off')

    # Function 3: Non-surjective
    ax = axes[2]
    domain3 = list(range(3))
    codomain3 = list(range(5))
    f3 = lambda x: 2 * x
    for a in domain3:
        ax.annotate('', xy=(1, f3(a)),
                   xytext=(0, a),
                   arrowprops=dict(arrowstyle='->', color='#7B1FA2', lw=1.5))
    for a in domain3:
        ax.plot(0, a, 'o', color='#1976D2', markersize=10)
        ax.text(-0.15, a, str(a), ha='right', va='center', fontsize=10)
    for b in codomain3:
        color = '#D32F2F' if b in [0, 2, 4] else '#BDBDBD'
        ax.plot(1, b, 'o', color=color, markersize=10)
        ax.text(1.15, b, str(b), ha='left', va='center', fontsize=10)
    ax.set_title('Non-surjective: f(x) = 2x\nSome fibers are empty ✗',
                fontsize=10)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 4.5)
    ax.axis('off')

    plt.suptitle('Fiber Characterization: Bijective ↔ All Fibers Singletons',
                fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fiber_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fiber_structure.png")


if __name__ == "__main__":
    plot_interchange_grid()
    plot_hlevel_hierarchy()
    plot_fiber_structure()
    print("\nAll visualizations generated!")
