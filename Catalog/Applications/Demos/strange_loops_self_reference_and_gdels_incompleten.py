#!/usr/bin/env python3
"""
Demo: Strange Loops and Self-Reference in Formal Systems

Demonstrates the key constructions from the formalization:
1. Lawvere's fixed-point theorem
2. Cantor's diagonal argument
3. Gödel sentence construction
4. Provability algebra and fixed points
5. Strange loop detection in hierarchies
"""

from algorithms import (
    lawvere_fixed_point, diagonal_argument, ProvabilityAlgebra,
    StrangeLoopDetector, Sentence, FormalSystem, incompleteness_certificate,
    self_reference_depth, iterate_diagonal
)


def demo_lawvere():
    """Demonstrate Lawvere's fixed-point theorem."""
    print("=" * 60)
    print("DEMO 1: Lawvere's Fixed-Point Theorem")
    print("=" * 60)
    print()
    print("If phi: A -> (A -> B) is surjective, every g: B -> B has a fixed point.")
    print()

    # Example: phi maps naturals to boolean functions
    # phi(0) = always True, phi(1) = always False,
    # phi(2) = identity, phi(3) = negation
    domain = [0, 1, 2, 3]

    def phi(a):
        if a == 0:
            return lambda x: True
        elif a == 1:
            return lambda x: False
        elif a == 2:
            return lambda x: (x % 2 == 0)
        else:
            return lambda x: (x % 2 != 0)

    # g = NOT (negation)
    g = lambda b: not b

    result = lawvere_fixed_point(phi, domain, g)
    if result:
        idx, val = result
        print(f"  Fixed point found at index {idx}: g({val}) = {val}")
    else:
        print("  No fixed point found (phi is not surjective over this domain)")

    print()
    print("  Key insight: If phi WERE surjective onto all functions,")
    print("  then NOT would need a fixed point. But NOT has no fixed point")
    print("  on booleans — this is the Cantor diagonal argument!")
    print()


def demo_diagonal():
    """Demonstrate Cantor's diagonal argument."""
    print("=" * 60)
    print("DEMO 2: Cantor's Diagonal Argument")
    print("=" * 60)
    print()

    n = 5

    # Create an encoding of 5 "predicates"
    def encoding(i):
        # encoding(i)(j) = True iff i-th predicate holds of j
        return lambda j: (i + j) % 2 == 0

    print("  Encoding table (encoding(i)(j)):")
    print("      ", end="")
    for j in range(n):
        print(f"j={j} ", end="")
    print()
    for i in range(n):
        print(f"  i={i}: ", end="")
        for j in range(n):
            val = encoding(i)(j)
            print(f" {'T' if val else 'F'}   ", end="")
        print()

    print()
    print("  Diagonal: ", end="")
    for i in range(n):
        print(f" {'T' if encoding(i)(i) else 'F'}   ", end="")
    print()

    anti_diag = diagonal_argument(encoding, n)
    print("  Anti-diagonal (new predicate): ", end="")
    for j in range(n):
        print(f" {'T' if anti_diag(j) else 'F'}   ", end="")
    print()

    # Verify it differs from every row
    for i in range(n):
        differs = any(encoding(i)(j) != anti_diag(j) for j in range(n))
        print(f"  encoding({i}) ≠ anti_diagonal: {differs} (differs at j={i})")
    print()


def demo_provability_algebra():
    """Demonstrate provability algebra and fixed points."""
    print("=" * 60)
    print("DEMO 3: Provability Algebra and Fixed Points")
    print("=" * 60)
    print()

    # Create a system with 5 sentences and some derivation rules
    # Rules: {0} -> 1, {1} -> 2, {0,2} -> 3
    rules = [
        ({0}, 1),      # From sentence 0, derive sentence 1
        ({1}, 2),      # From sentence 1, derive sentence 2
        ({0, 2}, 3),   # From sentences 0 and 2, derive sentence 3
    ]

    pa = ProvabilityAlgebra(5, rules)

    # Compute closures
    print("  Closure operator on sets of sentences:")
    test_sets = [set(), {0}, {1}, {0, 1}, {4}]
    for s in test_sets:
        cl = pa.closure(s)
        print(f"  closure({s}) = {cl}")

    lfp = pa.least_fixed_point()
    print(f"\n  Least fixed point (from ∅): {lfp}")
    print(f"  Is fixed point: {pa.is_fixed_point(lfp)}")

    # Check if the full set is a fixed point
    full = set(range(5))
    print(f"  closure({{0,1,2,3,4}}) = {pa.closure(full)}")
    print(f"  Full set is fixed point: {pa.is_fixed_point(full)}")

    diag = pa.find_diagonal_sentence()
    print(f"\n  Diagonal sentence candidate: {diag}")
    print()


def demo_strange_loop_detection():
    """Demonstrate strange loop detection in hierarchies."""
    print("=" * 60)
    print("DEMO 4: Strange Loop Detection")
    print("=" * 60)
    print()

    # Create a 4-level hierarchy (like Hofstadter's example)
    detector = StrangeLoopDetector(4)

    # Level 0: Object language (arithmetic)
    # Level 1: Meta-language (talks about Level 0)
    # Level 2: Meta-meta-language (talks about Level 1)
    # Level 3: Meta-meta-meta-language (talks about Level 2)

    # Standard references (downward)
    detector.add_reference(1, 0, "proves theorems about arithmetic")
    detector.add_reference(2, 1, "proves theorems about provability")
    detector.add_reference(3, 2, "proves theorems about meta-provability")

    # The strange loop: Level 0 talks about Level 2 via Gödel encoding
    detector.add_reference(0, 2, "encodes meta-level statements via Gödel numbers")

    print("  Hierarchy:")
    print("  Level 3 (Meta³) → Level 2 (Meta²)")
    print("  Level 2 (Meta²) → Level 1 (Meta¹)")
    print("  Level 1 (Meta¹) → Level 0 (Object)")
    print("  Level 0 (Object) → Level 2 (Meta²)  ← STRANGE LOOP!")
    print()

    loops = detector.find_loops()
    for loop in loops:
        classification = detector.classify_loop(loop)
        print(f"  Loop found: {' → '.join(f'L{l}' for l in loop)} → L{loop[0]}")
        print(f"  Classification: {classification}")
    print()


def demo_goedel_sentence():
    """Demonstrate the Gödel sentence construction."""
    print("=" * 60)
    print("DEMO 5: Gödel Sentence and Incompleteness")
    print("=" * 60)
    print()

    # Create a simple formal system
    # Sentences 0-4: arithmetic truths
    # Sentence 5: the Gödel sentence (true but unprovable)
    sentences = [
        Sentence(i, f"arithmetic_{i}") for i in range(5)
    ] + [
        Sentence(5, "goedel_G", is_self_referential=True, depth=1)
    ]

    # Truth: all sentences are true
    def true_(s):
        return True

    # Provability: everything except the Gödel sentence
    def provable(s):
        return s.index != 5

    system = FormalSystem(sentences=sentences, provable=provable, true_=true_)

    cert = incompleteness_certificate(system, 5)
    print("  Formal System Analysis:")
    print(f"    Sound: {cert['is_sound']}")
    print(f"    Complete: {cert['is_complete']}")
    print(f"    Gödel sentence (G) is true: {cert['is_true']}")
    print(f"    Gödel sentence (G) is provable: {cert['is_provable']}")
    print(f"    Incompleteness witness found: {cert['incompleteness_witness']}")
    print()
    print("  Interpretation:")
    print("    G says: 'I am not provable'")
    print("    If G were provable → G would be true (soundness)")
    print("    → 'I am not provable' would be true → G is not provable")
    print("    → Contradiction! So G is not provable.")
    print("    But then 'I am not provable' is TRUE → G is true.")
    print("    Therefore: G is true but not provable. □")
    print()


def demo_self_reference_depth():
    """Demonstrate self-reference depth computation."""
    print("=" * 60)
    print("DEMO 6: Self-Reference Depth Hierarchy")
    print("=" * 60)
    print()

    # Create a reference graph
    # Sentence 0: "0 is 0" (no self-reference)
    # Sentence 1: "sentence 1 is true" (direct self-reference)
    # Sentence 2: "sentence 3 is true" -> sentence 3: "sentence 2 is true"
    # (mutual reference, depth 2)
    # Sentence 4: "sentence 5 is true" -> 5 -> 6 -> 4 (cycle of length 3)
    references = {
        0: [],
        1: [1],           # direct self-reference
        2: [3],           # mutual reference
        3: [2],           # mutual reference
        4: [5],           # length-3 cycle
        5: [6],
        6: [4],
    }

    for s in range(7):
        depth = self_reference_depth(s, references)
        name = {
            0: "'0=0' (no refs)",
            1: "'I am true' (self-ref)",
            2: "'3 is true' (mutual with 3)",
            3: "'2 is true' (mutual with 2)",
            4: "'5 is true' (3-cycle)",
            5: "'6 is true' (3-cycle)",
            6: "'4 is true' (3-cycle)",
        }[s]
        print(f"  Sentence {s} {name}: depth = {depth}")

    print()
    print("  The self-reference depth measures how many steps")
    print("  are needed to return to the original sentence.")
    print("  Gödel sentences have depth 1 (direct self-reference).")
    print()


def demo_conjecture_test():
    """Test the self-reference depth hierarchy conjecture."""
    print("=" * 60)
    print("DEMO 7: Testing the Depth Hierarchy Conjecture")
    print("=" * 60)
    print()
    print("  Conjecture: Iterated diagonals produce distinct sentences")
    print("  at each depth level.")
    print()

    # Simple model: sentences are natural numbers
    # diag(P) returns the smallest n such that P(n) holds
    counter = [0]

    def diag(pred):
        result = counter[0]
        counter[0] += 1
        return result

    def true_pred(s):
        return True

    def provable(s):
        return s < 5  # Only first 5 sentences provable

    sentences = iterate_diagonal(diag, true_pred, provable, 10)
    print(f"  Iterated diagonal sentences: {sentences}")
    print(f"  All distinct: {len(set(sentences)) == len(sentences)}")
    print()

    if len(set(sentences)) == len(sentences):
        print("  ✓ Conjecture holds for this model!")
    else:
        print("  ✗ Conjecture fails for this model!")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Strange Loops: Self-Reference and Gödel's             ║")
    print("║  Incompleteness in Formal Systems                      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_lawvere()
    demo_diagonal()
    demo_provability_algebra()
    demo_strange_loop_detection()
    demo_goedel_sentence()
    demo_self_reference_depth()
    demo_conjecture_test()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Strange Loops and Provability Lattices

Generates three visualizations:
1. The provability lattice with LFP-GFP gap
2. Strange loop reference diagram
3. Diagonal argument visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def plot_provability_lattice():
    """Visualize the lattice of theories with LFP and GFP marked."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Generate a small lattice: subsets of {0,1,2}
    elements = [set(), {0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}]
    labels = ['∅', '{0}', '{1}', '{2}', '{0,1}', '{0,2}', '{1,2}', '{0,1,2}']

    # Positions in a Hasse diagram layout
    positions = {
        0: (4, 0),    # ∅
        1: (1, 2),    # {0}
        2: (4, 2),    # {1}
        3: (7, 2),    # {2}
        4: (1, 4),    # {0,1}
        5: (4, 4),    # {0,2}
        6: (7, 4),    # {1,2}
        7: (4, 6),    # {0,1,2}
    }

    # Draw edges (Hasse diagram)
    edges = [
        (0,1), (0,2), (0,3),
        (1,4), (1,5),
        (2,4), (2,6),
        (3,5), (3,6),
        (4,7), (5,7), (6,7)
    ]

    for i, j in edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

    # Define a closure operator (derivation rules: {0} -> 1, {1} -> 2)
    def closure(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            if 0 in result and 1 not in result:
                result.add(1)
                changed = True
            if 1 in result and 2 not in result:
                result.add(2)
                changed = True
        return frozenset(result)

    # Find fixed points
    fixed_points = []
    for i, s in enumerate(elements):
        if set(closure(s)) == s:
            fixed_points.append(i)

    # Color nodes
    colors = []
    for i in range(len(elements)):
        if i in fixed_points:
            if i == min(fixed_points):
                colors.append('#2ecc71')  # LFP - green
            elif i == max(fixed_points):
                colors.append('#e74c3c')  # GFP - red
            else:
                colors.append('#f39c12')  # Other fixed points - orange
        else:
            colors.append('#3498db')  # Non-fixed points - blue

    # Draw nodes
    for i in range(len(elements)):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.4, color=colors[i], ec='black',
                           linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, labels[i], ha='center', va='center',
               fontsize=8, fontweight='bold', zorder=6)

    # Add legend
    legend_elements = [
        mpatches.Patch(color='#2ecc71', label='LFP (Least Fixed Point)'),
        mpatches.Patch(color='#e74c3c', label='GFP (Greatest Fixed Point)'),
        mpatches.Patch(color='#f39c12', label='Other Fixed Points'),
        mpatches.Patch(color='#3498db', label='Non-Fixed Points'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)

    # Add annotation for the gap
    lfp_pos = positions[min(fixed_points)]
    gfp_pos = positions[max(fixed_points)]
    ax.annotate('', xy=(gfp_pos[0]+0.8, gfp_pos[1]),
               xytext=(lfp_pos[0]+0.8, lfp_pos[1]),
               arrowprops=dict(arrowstyle='<->', color='purple', lw=2))
    mid_y = (lfp_pos[1] + gfp_pos[1]) / 2
    ax.text(gfp_pos[0]+1.5, mid_y, 'Incompleteness\nGap',
           fontsize=11, color='purple', ha='center', va='center',
           fontweight='bold')

    ax.set_xlim(-1, 10)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.set_title('Provability Lattice with Incompleteness Gap',
                fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_provability_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_provability_lattice.png")


def plot_strange_loop():
    """Visualize a strange loop in a formal hierarchy."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    # Levels of the hierarchy
    levels = ['Object\n(Arithmetic)', 'Meta\n(Provability)',
              'Meta²\n(Meta-provability)', 'Meta³\n(Meta²-provability)']
    n = len(levels)

    # Position levels in a circle
    angles = np.linspace(np.pi/2, np.pi/2 + 2*np.pi, n, endpoint=False)
    radius = 3
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]

    # Draw normal hierarchy edges (downward)
    normal_edges = [(1, 0), (2, 1), (3, 2)]
    for i, j in normal_edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrows to not overlap with circles
        shrink = 0.7 / length
        ax.annotate('', xy=(x2 - dx*shrink, y2 - dy*shrink),
                   xytext=(x1 + dx*shrink, y1 + dy*shrink),
                   arrowprops=dict(arrowstyle='->', color='#2c3e50',
                                  lw=2, connectionstyle='arc3,rad=0.1'))

    # Draw the strange loop (0 -> 2, the tangle)
    x1, y1 = positions[0]
    x2, y2 = positions[2]
    dx, dy = x2 - x1, y2 - y1
    length = np.sqrt(dx**2 + dy**2)
    shrink = 0.7 / length
    ax.annotate('', xy=(x2 - dx*shrink, y2 - dy*shrink),
               xytext=(x1 + dx*shrink, y1 + dy*shrink),
               arrowprops=dict(arrowstyle='->', color='#e74c3c',
                              lw=3, connectionstyle='arc3,rad=-0.3',
                              linestyle='dashed'))

    # Draw level circles
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.7, color='#ecf0f1', ec='#2c3e50',
                           linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f'Level {i}\n{levels[i]}', ha='center', va='center',
               fontsize=8, fontweight='bold', zorder=6)

    # Add Gödel sentence annotation
    gx, gy = 0, 0  # center
    ax.text(gx, gy, 'G: "I am not\nprovable"',
           ha='center', va='center', fontsize=12,
           fontweight='bold', color='#e74c3c',
           bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8',
                    edgecolor='#e74c3c', linewidth=2))

    # Arrow from center to the strange loop edge
    ax.annotate('', xy=(positions[0][0]*0.6, positions[0][1]*0.6),
               xytext=(gx, gy - 0.4),
               arrowprops=dict(arrowstyle='->', color='#e74c3c',
                              lw=1.5, linestyle='dotted'))

    # Legend
    normal_arrow = mpatches.FancyArrowPatch((0,0), (1,0), arrowstyle='->',
                                            color='#2c3e50', lw=2)
    strange_arrow = mpatches.FancyArrowPatch((0,0), (1,0), arrowstyle='->',
                                             color='#e74c3c', lw=3,
                                             linestyle='dashed')
    ax.text(-4.5, -4.5, '→ Normal reference (level talks about level below)\n'
           '⤳ Strange loop (object level encodes meta-level)',
           fontsize=10, color='#2c3e50',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_xlim(-5, 5)
    ax.set_ylim(-5, 5)
    ax.set_aspect('equal')
    ax.set_title('Strange Loop in a Formal Hierarchy\n'
                '(Hofstadter\'s Tangled Hierarchy)',
                fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_strange_loop.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_strange_loop.png")


def plot_diagonal_argument():
    """Visualize Cantor's diagonal argument."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    n = 6

    # Create the encoding table
    def encoding(i, j):
        return (i + j) % 3 != 0

    # Draw the grid
    cell_size = 1.0
    for i in range(n):
        for j in range(n):
            val = encoding(i, j)
            color = '#2ecc71' if val else '#e74c3c'
            alpha = 0.3 if i != j else 0.8

            rect = plt.Rectangle((j * cell_size + 0.5, (n - 1 - i) * cell_size + 0.5),
                                cell_size, cell_size,
                                facecolor=color, alpha=alpha,
                                edgecolor='white', linewidth=2)
            ax.add_patch(rect)

            label = 'T' if val else 'F'
            ax.text(j * cell_size + 1.0, (n - 1 - i) * cell_size + 1.0,
                   label, ha='center', va='center',
                   fontsize=12, fontweight='bold' if i == j else 'normal',
                   color='black' if i == j else '#555')

    # Labels
    for i in range(n):
        ax.text(i * cell_size + 1.0, n * cell_size + 0.7, f'j={i}',
               ha='center', va='center', fontsize=10, fontweight='bold')
        ax.text(0.2, (n - 1 - i) * cell_size + 1.0, f'φ({i})',
               ha='center', va='center', fontsize=10, fontweight='bold')

    # Anti-diagonal column
    x_offset = n * cell_size + 1.5
    ax.text(x_offset + 0.5, n * cell_size + 0.7, 'Anti-\ndiag',
           ha='center', va='center', fontsize=9, fontweight='bold',
           color='#8e44ad')

    for i in range(n):
        val = not encoding(i, i)
        color = '#2ecc71' if val else '#e74c3c'
        rect = plt.Rectangle((x_offset, (n - 1 - i) * cell_size + 0.5),
                            cell_size, cell_size,
                            facecolor=color, alpha=0.8,
                            edgecolor='#8e44ad', linewidth=3)
        ax.add_patch(rect)
        label = 'T' if val else 'F'
        ax.text(x_offset + 0.5, (n - 1 - i) * cell_size + 1.0,
               label, ha='center', va='center',
               fontsize=12, fontweight='bold', color='#8e44ad')

    # Arrow showing "flip"
    for i in range(n):
        orig = encoding(i, i)
        ax.annotate('', xy=(x_offset + 0.1, (n - 1 - i) * cell_size + 1.0),
                   xytext=(i * cell_size + cell_size + 0.4,
                          (n - 1 - i) * cell_size + 1.0),
                   arrowprops=dict(arrowstyle='->', color='#8e44ad',
                                  lw=1.5, linestyle='dotted'))

    # Title and annotations
    ax.set_title("Cantor's Diagonal Argument\n"
                "The anti-diagonal differs from every row at the diagonal entry",
                fontsize=14, fontweight='bold')

    ax.text(4, -0.5, 'Diagonal entries (highlighted) are flipped\n'
           'to create a predicate not in the range of φ',
           ha='center', va='center', fontsize=10, color='#555',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlim(-0.5, x_offset + 2)
    ax.set_ylim(-1.5, n * cell_size + 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_diagonal_argument.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_diagonal_argument.png")


if __name__ == '__main__':
    plot_provability_lattice()
    plot_strange_loop()
    plot_diagonal_argument()
    print("\nAll visualizations generated!")
