#!/usr/bin/env python3
"""
Aboriginal Kinship Systems: Demonstration

Demonstrates the group-theoretic structure of Aboriginal kinship systems
by computing marriage rules, descent paths, cross-cousin relations,
and verifying key algebraic theorems.
"""

from algorithms import (
    kariera, aranda, KinshipSystem,
    verify_cross_cousin_theorem, verify_marriage_involution,
    verify_grandchild_return, classify_kinship_systems,
    two_generator_bound_test, z2_add, z2_zero
)


def demo_kariera():
    """Demonstrate the Kariera 4-section system."""
    print("=" * 60)
    print("KARIERA 4-SECTION KINSHIP SYSTEM")
    print("Group: Z₂ × Z₂ (order 4)")
    print("=" * 60)

    ks = kariera()

    # Display all sections
    print("\n--- Sections ---")
    for s in ks.all_sections():
        print(f"  {ks.section_name(s)} = {s}")

    # Marriage rules
    print("\n--- Marriage Rules ---")
    for s in ks.all_sections():
        t = ks.marry(s)
        print(f"  {ks.section_name(s)} marries {ks.section_name(t)}")

    # Descent rules
    print("\n--- Descent Rules (mother → child) ---")
    for s in ks.all_sections():
        t = ks.descend(s)
        print(f"  Mother in {ks.section_name(s)} → Child in {ks.section_name(t)}")

    # Cross-cousin verification
    print("\n--- Cross-Cousin Marriage Theorem ---")
    print("  crossCousin(s) = marry(s) for all s?")
    for s in ks.all_sections():
        cc = ks.cross_cousin(s)
        m = ks.marry(s)
        status = "✓" if cc == m else "✗"
        print(f"    {ks.section_name(s)}: crossCousin = {ks.section_name(cc)}, "
              f"marry = {ks.section_name(m)}  {status}")

    # Moiety structure
    print("\n--- Moiety Structure ---")
    moiety0 = [s for s in ks.all_sections() if ks.moiety(s) == 0]
    moiety1 = [s for s in ks.all_sections() if ks.moiety(s) == 1]
    print(f"  Moiety 0: {[ks.section_name(s) for s in moiety0]}")
    print(f"  Moiety 1: {[ks.section_name(s) for s in moiety1]}")
    print(f"  Marriage crosses moieties: "
          f"{all(ks.moiety(ks.marry(s)) != ks.moiety(s) for s in ks.all_sections())}")
    print(f"  Descent preserves moieties: "
          f"{all(ks.moiety(ks.descend(s)) == ks.moiety(s) for s in ks.all_sections())}")

    # Generation structure
    print("\n--- Generation Alternation ---")
    for s in ks.all_sections():
        child = ks.descend(s)
        grandchild = ks.descend(child)
        print(f"  {ks.section_name(s)} → {ks.section_name(child)} → "
              f"{ks.section_name(grandchild)}  "
              f"{'(returns)' if grandchild == s else '(different!)'}")

    # Subgroup generation
    print(f"\n--- Group Generation ---")
    sg = ks.generated_subgroup()
    print(f"  ⟨marriage, descent⟩ = {sorted(sg)}")
    print(f"  Generates full group: {ks.is_full_generator()}")


def demo_aranda():
    """Demonstrate the Aranda 8-subsection system."""
    print("\n" + "=" * 60)
    print("ARANDA 8-SUBSECTION KINSHIP SYSTEM")
    print("Group: Z₂ × Z₂ × Z₂ (order 8)")
    print("=" * 60)

    ks = aranda()

    # Display sections
    print("\n--- Subsections ---")
    for s in ks.all_sections():
        print(f"  {ks.section_name(s)} = {s}")

    # Marriage pairs
    print("\n--- Marriage Pairs ---")
    for s, t in ks.marriage_pairs():
        print(f"  {ks.section_name(s)} ↔ {ks.section_name(t)}")

    # Cross-cousin verification
    print("\n--- Cross-Cousin Marriage Theorem ---")
    verified = verify_cross_cousin_theorem(ks)
    print(f"  Theorem holds for all 8 subsections: {verified}")

    # Two-generator test
    print(f"\n--- Two-Generator Bound ---")
    sg = ks.generated_subgroup()
    print(f"  ⟨{ks.marriage}, {ks.descent}⟩ has order {len(sg)}")
    print(f"  Full group has order {2**ks.n}")
    print(f"  Generates full group: {ks.is_full_generator()}")
    print(f"  → A THIRD operation is needed for full 8-subsection system")


def demo_theorems():
    """Verify key theorems computationally."""
    print("\n" + "=" * 60)
    print("THEOREM VERIFICATION")
    print("=" * 60)

    for name, ks in [("Kariera", kariera()), ("Aranda", aranda())]:
        print(f"\n--- {name} System ---")
        print(f"  Marriage involution (marry∘marry = id): "
              f"{verify_marriage_involution(ks)}")
        print(f"  Cross-cousin theorem (crossCousin = marry): "
              f"{verify_cross_cousin_theorem(ks)}")
        print(f"  Grandchild return (descend∘descend = id): "
              f"{verify_grandchild_return(ks)}")


def demo_classification():
    """Classify kinship systems on small groups."""
    print("\n" + "=" * 60)
    print("KINSHIP SYSTEM CLASSIFICATION")
    print("=" * 60)

    for n in [2, 3, 4]:
        systems = classify_kinship_systems(n)
        full_gen = sum(1 for ks in systems if ks.is_full_generator())
        print(f"\n  (Z₂)^{n} (order {2**n}):")
        print(f"    Valid kinship systems: {len(systems)}")
        print(f"    Systems generating full group: {full_gen}")
        print(f"    Systems NOT generating full group: {len(systems) - full_gen}")


def demo_two_generator_conjecture():
    """Test the two-generator bound conjecture."""
    print("\n" + "=" * 60)
    print("TWO-GENERATOR BOUND CONJECTURE")
    print("=" * 60)

    for n in [2, 3, 4, 5]:
        result = two_generator_bound_test(n)
        print(f"\n  n = {result['n']}:")
        print(f"    Group order: {result['group_order']}")
        print(f"    Pairs tested: {result['pairs_tested']}")
        print(f"    Max subgroup size from 2 generators: {result['max_subgroup_size']}")
        print(f"    Pairs generating full group: {result['full_generators']}")
        print(f"    Conjecture holds (no full generation for n≥3): "
              f"{result['conjecture_holds'] if n >= 3 else 'N/A (n=2)'}")


def demo_kinship_path():
    """Trace a kinship path through the Kariera system."""
    print("\n" + "=" * 60)
    print("KINSHIP PATH TRACING")
    print("=" * 60)

    ks = kariera()
    s = (0, 0)  # Start in section A

    print(f"\n  Person X is in section {ks.section_name(s)}")

    mother = ks.ascend(s)
    print(f"  X's mother is in section {ks.section_name(mother)}")

    uncle = mother  # Same section as mother
    print(f"  Mother's brother is in section {ks.section_name(uncle)}")

    uncle_wife = ks.marry(uncle)
    print(f"  Uncle's wife is in section {ks.section_name(uncle_wife)}")

    cousin = ks.descend(uncle_wife)
    print(f"  Uncle's daughter (cross-cousin) is in section {ks.section_name(cousin)}")

    spouse = ks.marry(s)
    print(f"  X's marriage-eligible section is {ks.section_name(spouse)}")

    print(f"\n  Cross-cousin = marriage-eligible? {cousin == spouse}  ← THE THEOREM")


if __name__ == "__main__":
    demo_kariera()
    demo_aranda()
    demo_theorems()
    demo_classification()
    demo_two_generator_conjecture()
    demo_kinship_path()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of Aboriginal Kinship Systems as Cayley Graphs

Generates matplotlib visualizations of the 4-section (Kariera) and
8-subsection (Aranda) kinship systems, showing marriage edges, descent
edges, moiety coloring, and the cross-cousin marriage path.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product


def z2_add(a, b):
    return tuple((x + y) % 2 for x, y in zip(a, b))


def draw_kariera_cayley_graph():
    """Draw the Cayley graph of the Kariera 4-section system."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Section positions (arranged in a square)
    positions = {
        (0, 0): (0, 1),   # A - top left
        (1, 0): (1, 1),   # B - top right
        (0, 1): (0, 0),   # C - bottom left
        (1, 1): (1, 0),   # D - bottom right
    }
    names = {(0,0): 'A', (1,0): 'B', (0,1): 'C', (1,1): 'D'}
    marriage = (1, 0)
    descent = (0, 1)

    # Left panel: Marriage and Descent edges
    ax = axes[0]
    ax.set_title('Kariera Cayley Graph\n(Marriage = red, Descent = blue)', fontsize=13)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Moiety coloring
    moiety_colors = {0: '#4ECDC4', 1: '#FF6B6B'}

    for s, (x, y) in positions.items():
        color = moiety_colors[s[0]]
        circle = plt.Circle((x, y), 0.12, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, names[s], ha='center', va='center', fontsize=16,
                fontweight='bold', zorder=6)

    # Marriage edges (red, dashed)
    for s in positions:
        t = z2_add(s, marriage)
        if s < t:
            x1, y1 = positions[s]
            x2, y2 = positions[t]
            ax.annotate('', xy=(x2 - 0.13*(x2-x1)/max(abs(x2-x1),0.01), y2 - 0.13*(y2-y1)/max(abs(y2-y1),0.01)),
                       xytext=(x1 + 0.13*(x2-x1)/max(abs(x2-x1),0.01), y1 + 0.13*(y2-y1)/max(abs(y2-y1),0.01)),
                       arrowprops=dict(arrowstyle='<->', color='red', lw=2.5, linestyle='--'))

    # Descent edges (blue, solid)
    for s in positions:
        t = z2_add(s, descent)
        x1, y1 = positions[s]
        x2, y2 = positions[t]
        dx = x2 - x1
        dy = y2 - y1
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            ax.annotate('', xy=(x2 - 0.13*dx/dist, y2 - 0.13*dy/dist),
                       xytext=(x1 + 0.13*dx/dist, y1 + 0.13*dy/dist),
                       arrowprops=dict(arrowstyle='->', color='blue', lw=2.5))

    # Legend
    marriage_line = mpatches.Patch(color='red', label='Marriage (↔)')
    descent_line = mpatches.Patch(color='blue', label='Descent (→)')
    moiety0 = mpatches.Patch(color='#4ECDC4', label='Moiety 0')
    moiety1 = mpatches.Patch(color='#FF6B6B', label='Moiety 1')
    ax.legend(handles=[marriage_line, descent_line, moiety0, moiety1],
             loc='lower center', fontsize=10)

    # Right panel: Cross-cousin marriage path
    ax = axes[1]
    ax.set_title('Cross-Cousin Marriage Path\n(A → C → D → B = marry(A))', fontsize=13)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw sections
    for s, (x, y) in positions.items():
        color = moiety_colors[s[0]]
        alpha = 0.3
        if s in [(0,0), (0,1), (1,1), (1,0)]:
            alpha = 1.0
        circle = plt.Circle((x, y), 0.12, color=color, ec='black', lw=2,
                           alpha=alpha, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, names[s], ha='center', va='center', fontsize=16,
                fontweight='bold', zorder=6)

    # Cross-cousin path: A → C (ascend) → D (marry uncle) → B (descend)
    path = [(0,0), (0,1), (1,1), (1,0)]
    path_labels = ['1. Start\n(Person X)', '2. Ascend\n(Mother)', '3. Marry\n(Uncle\'s wife)', '4. Descend\n(Cross-cousin)']
    colors_path = ['#2ECC71', '#3498DB', '#E74C3C', '#F39C12']

    for i in range(len(path) - 1):
        x1, y1 = positions[path[i]]
        x2, y2 = positions[path[i+1]]
        dx = x2 - x1
        dy = y2 - y1
        dist = np.sqrt(dx**2 + dy**2)
        offset = 0.05 * (i - 1)
        ax.annotate('', xy=(x2 - 0.14*dx/dist + offset, y2 - 0.14*dy/dist),
                   xytext=(x1 + 0.14*dx/dist + offset, y1 + 0.14*dy/dist),
                   arrowprops=dict(arrowstyle='->', color=colors_path[i],
                                 lw=3, connectionstyle=f'arc3,rad={0.2*(i%2*2-1)}'))

    for i, s in enumerate(path):
        x, y = positions[s]
        offset_y = 0.25 if y > 0.5 else -0.25
        ax.text(x, y + offset_y, path_labels[i], ha='center', va='center',
               fontsize=8, color=colors_path[i], fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                        edgecolor=colors_path[i], alpha=0.9))

    plt.tight_layout()
    plt.savefig('kariera_cayley_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kariera_cayley_graph.png")


def draw_aranda_cayley_graph():
    """Draw the Cayley graph of the Aranda 8-subsection system."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_title('Aranda 8-Subsection Cayley Graph\n(Z₂ × Z₂ × Z₂)', fontsize=14)

    # Arrange in a cube-like layout
    positions = {}
    labels = {}
    section_names = ["A₁", "B₁", "C₁", "D₁", "A₂", "B₂", "C₂", "D₂"]
    for i, s in enumerate(product([0, 1], repeat=3)):
        # 3D to 2D projection
        x = s[0] * 2 + s[2] * 0.8
        y = s[1] * 2 + s[2] * 0.8
        positions[s] = (x, y)
        labels[s] = section_names[i]

    marriage = (1, 0, 0)
    descent = (0, 1, 1)

    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    moiety_colors = {0: '#4ECDC4', 1: '#FF6B6B'}

    # Draw edges
    drawn = set()
    for s in positions:
        # Marriage edge (red, dashed)
        t = z2_add(s, marriage)
        pair = tuple(sorted([s, t]))
        if pair not in drawn:
            drawn.add(pair)
            x1, y1 = positions[s]
            x2, y2 = positions[t]
            ax.plot([x1, x2], [y1, y2], 'r--', lw=1.5, alpha=0.6, zorder=1)

        # Descent edge (blue, solid)
        t = z2_add(s, descent)
        x1, y1 = positions[s]
        x2, y2 = positions[t]
        dx, dy = x2 - x1, y2 - y1
        dist = np.sqrt(dx**2 + dy**2)
        if dist > 0:
            ax.annotate('', xy=(x2 - 0.18*dx/dist, y2 - 0.18*dy/dist),
                       xytext=(x1 + 0.18*dx/dist, y1 + 0.18*dy/dist),
                       arrowprops=dict(arrowstyle='->', color='blue',
                                     lw=1.5, alpha=0.6),
                       zorder=2)

    # Draw nodes
    for s, (x, y) in positions.items():
        color = moiety_colors[s[0]]
        circle = plt.Circle((x, y), 0.15, color=color, ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, labels[s], ha='center', va='center', fontsize=11,
                fontweight='bold', zorder=6)

    # Highlight generated subgroup
    sg = {(0,0,0), marriage, descent, z2_add(marriage, descent)}
    ax.text(1.5, -0.3,
           f'⟨marriage, descent⟩ = subgroup of order {len(sg)} ⊂ group of order 8\n'
           f'→ Third generator needed!',
           ha='center', fontsize=11, style='italic',
           bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange'))

    marriage_line = mpatches.Patch(color='red', label='Marriage (order 2)')
    descent_line = mpatches.Patch(color='blue', label='Descent (order 2)')
    moiety0 = mpatches.Patch(color='#4ECDC4', label='Moiety 0')
    moiety1 = mpatches.Patch(color='#FF6B6B', label='Moiety 1')
    ax.legend(handles=[marriage_line, descent_line, moiety0, moiety1],
             loc='upper right', fontsize=10)

    plt.tight_layout()
    plt.savefig('aranda_cayley_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: aranda_cayley_graph.png")


def draw_moiety_partition():
    """Visualize the moiety partition and generation structure."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Kariera moiety + generation structure
    ax = axes[0]
    ax.set_title('Kariera: Moiety × Generation Decomposition', fontsize=13)

    sections = [(0,0), (1,0), (0,1), (1,1)]
    names = {(0,0): 'A', (1,0): 'B', (0,1): 'C', (1,1): 'D'}

    # Grid layout: x = moiety, y = generation
    grid_pos = {}
    for s in sections:
        grid_pos[s] = (s[0] * 2 + 0.5, s[1] * 2 + 0.5)

    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')

    # Draw grid
    ax.axvline(x=1.5, color='gray', lw=2, ls='--', alpha=0.5)
    ax.axhline(y=1.5, color='gray', lw=2, ls='--', alpha=0.5)

    # Labels
    ax.text(0.75, 3.2, 'Moiety 0', ha='center', fontsize=12, fontweight='bold', color='#4ECDC4')
    ax.text(2.75, 3.2, 'Moiety 1', ha='center', fontsize=12, fontweight='bold', color='#FF6B6B')
    ax.text(-0.3, 0.75, 'Gen 0', ha='center', fontsize=11, rotation=90, color='gray')
    ax.text(-0.3, 2.75, 'Gen 1', ha='center', fontsize=11, rotation=90, color='gray')

    moiety_colors = {0: '#4ECDC4', 1: '#FF6B6B'}
    for s in sections:
        x, y = grid_pos[s]
        color = moiety_colors[s[0]]
        rect = plt.Rectangle((x-0.4, y-0.4), 0.8, 0.8, color=color, alpha=0.3,
                            ec='black', lw=2, zorder=3)
        ax.add_patch(rect)
        ax.text(x, y, names[s], ha='center', va='center', fontsize=24,
               fontweight='bold', zorder=4)

    # Marriage arrows (horizontal, cross moiety)
    for s in [(0,0), (0,1)]:
        x1, y1 = grid_pos[s]
        t = z2_add(s, (1,0))
        x2, y2 = grid_pos[t]
        ax.annotate('', xy=(x2-0.45, y2), xytext=(x1+0.45, y1),
                   arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
        ax.text((x1+x2)/2, (y1+y2)/2 + 0.15, 'marry', ha='center',
               fontsize=9, color='red')

    # Descent arrows (vertical, within moiety)
    for s in [(0,0), (1,0)]:
        x1, y1 = grid_pos[s]
        t = z2_add(s, (0,1))
        x2, y2 = grid_pos[t]
        ax.annotate('', xy=(x2+0.1, y2-0.45), xytext=(x1+0.1, y1+0.45),
                   arrowprops=dict(arrowstyle='->', color='blue', lw=2.5))
        ax.text(x1+0.3, (y1+y2)/2, 'descent', ha='center',
               fontsize=9, color='blue', rotation=90)

    ax.set_xticks([])
    ax.set_yticks([])

    # Right panel: multiplication table
    ax = axes[1]
    ax.set_title('Group Operation Table (Z₂ × Z₂)', fontsize=13)
    ax.axis('off')

    table_data = [['', 'A(0,0)', 'B(1,0)', 'C(0,1)', 'D(1,1)'],
                  ['A(0,0)', 'A', 'B', 'C', 'D'],
                  ['B(1,0)', 'B', 'A', 'D', 'C'],
                  ['C(0,1)', 'C', 'D', 'A', 'B'],
                  ['D(1,1)', 'D', 'C', 'B', 'A']]

    table = ax.table(cellText=table_data, loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1, 1.5)

    # Color header
    for i in range(5):
        table[0, i].set_facecolor('#E8E8E8')
        table[i, 0].set_facecolor('#E8E8E8') if i > 0 else None

    plt.tight_layout()
    plt.savefig('moiety_partition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moiety_partition.png")


if __name__ == "__main__":
    draw_kariera_cayley_graph()
    draw_aranda_cayley_graph()
    draw_moiety_partition()
    print("\nAll visualizations generated.")
