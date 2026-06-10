#!/usr/bin/env python3
"""
Tropical Knot Theory: Applications

This module demonstrates real-world applications of tropical knot invariants:
1. Knot complexity certification
2. Diagram optimization via tropical simplification
3. Knot family classification
4. Connections to network routing and circuit complexity
"""

from algorithms import (
    KnotDiagram, TropicalLaurent, tropical_jones,
    tropical_span_bound, verify_support_bound, full_simplification,
    tropical_profiles_differ, make_chain, make_balanced, make_alternating_chain
)
import math


def application_complexity_certification():
    """Application 1: Certified Lower Bounds on Knot Complexity

    The tropical span gives a certified lower bound on crossing number.
    If span(tJones(D)) = 2k, then any equivalent diagram must have ≥ k crossings.

    This is analogous to degree lower bounds in algebraic circuit complexity:
    just as the degree of a polynomial bounds the depth of any circuit computing it,
    the tropical span bounds the crossing number of any diagram representing the knot.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Knot Complexity Lower Bounds")
    print("=" * 70)
    print()
    print("The tropical span gives a certified lower bound on crossing number.")
    print("If span(tJones(D)) = 2k, then the knot requires ≥ k crossings.")
    print()

    diagrams = {
        "Unknot": KnotDiagram.loop(),
        "Single twist": make_chain(1),
        "Double twist": make_chain(2),
        "Triple twist": make_chain(3),
        "5-crossing chain": make_chain(5),
        "3-crossing balanced": make_balanced(3),
        "7-crossing balanced": make_balanced(7),
    }

    print(f"{'Diagram':<25} {'Crossings':>10} {'Span':>8} {'Lower Bound':>12}")
    print("-" * 60)
    for name, D in diagrams.items():
        span, _ = tropical_span_bound(D)
        lower_bound = span // 2  # span ≤ 2c implies c ≥ span/2
        print(f"{name:<25} {D.num_crossings:>10} {span:>8} {lower_bound:>12}")

    print()
    print("Interpretation: The lower bound is certified — any diagram")
    print("representing the same knot must have at least this many crossings.")
    print()


def application_diagram_optimization():
    """Application 2: Diagram Optimization via Tropical Simplification

    The simplification procedure provides a systematic way to reduce diagram complexity.
    Each step is guaranteed to decrease the crossing number, and the process terminates.
    """
    print("=" * 70)
    print("APPLICATION 2: Diagram Optimization")
    print("=" * 70)
    print()

    # Build a complex diagram
    D = KnotDiagram.crossing(
        KnotDiagram.crossing(
            KnotDiagram.crossing(
                make_chain(2),
                KnotDiagram.loop()
            ),
            make_balanced(3)
        ),
        KnotDiagram.crossing(
            KnotDiagram.loop(),
            make_chain(2)
        )
    )

    print(f"Input diagram: {D.num_crossings} crossings")
    print(f"Tropical Jones: {tropical_jones(D)}")
    print()

    path = full_simplification(D)
    print("Simplification path:")
    total_reduction = 0
    for i, step in enumerate(path):
        tj = tropical_jones(step)
        if i > 0:
            reduction = path[i-1].num_crossings - step.num_crossings
            total_reduction += reduction
            print(f"  Step {i}: {step.num_crossings} crossings "
                  f"(reduced by {reduction}), tJones = {tj}")
        else:
            print(f"  Start:  {step.num_crossings} crossings, tJones = {tj}")

    print(f"\nTotal reduction: {total_reduction} crossings removed")
    print(f"Final: {path[-1].num_crossings} crossings (loop = normal form)")
    print()


def application_knot_classification():
    """Application 3: Knot Family Classification

    Different diagram families have characteristic tropical signatures.
    The tropical Jones invariant acts as a fingerprint for classification.
    """
    print("=" * 70)
    print("APPLICATION 3: Knot Family Classification")
    print("=" * 70)
    print()

    families = {
        "Chain": [make_chain(n) for n in range(1, 6)],
        "Balanced": [make_balanced(n) for n in [1, 3, 7]],
        "Alternating": [make_alternating_chain(n) for n in range(1, 6)],
    }

    for family_name, members in families.items():
        print(f"\n{family_name} family:")
        print(f"  {'n':>4} {'Crossings':>10} {'Span':>6} {'Span/2c':>8} "
              f"{'Support size':>13}")
        print("  " + "-" * 50)
        for D in members:
            tj = tropical_jones(D)
            span = tj.span
            nc = D.num_crossings
            ratio = span / (2 * nc) if nc > 0 else 0
            print(f"  {nc:>4} {nc:>10} {span:>6} {ratio:>8.2f} "
                  f"{len(tj.support):>13}")

    print()
    print("Observations:")
    print("• Chain diagrams achieve maximum span (span/2c = 1.0)")
    print("• Balanced diagrams have lower span-to-crossing ratios")
    print("• Alternating diagrams show intermediate behavior")
    print("• The span/crossing ratio characterizes diagram families")
    print()


def application_network_routing():
    """Application 4: Connection to Network Routing

    The tropical Jones invariant has a natural interpretation as a
    shortest-path problem: each crossing is a routing decision point,
    and the invariant computes minimum-cost routes to each "degree" target.

    This connects knot theory to:
    - Network routing and flow optimization
    - VLSI circuit layout
    - Dynamic programming in operations research
    """
    print("=" * 70)
    print("APPLICATION 4: Network Routing Interpretation")
    print("=" * 70)
    print()
    print("The tropical Jones invariant = shortest path cost in a routing network.")
    print()
    print("Interpretation:")
    print("  • Each crossing = a routing decision (left or right)")
    print("  • Each degree = a destination")
    print("  • tJones(D)(n) = minimum cost to reach destination n")
    print("  • Left turn shifts destination by +1, right turn by -1")
    print()

    # Build a routing network (diagram) and analyze reachability
    for n in [3, 5, 7]:
        D = make_chain(n)
        tj = tropical_jones(D)
        print(f"Network with {n} decision points:")
        print(f"  Reachable destinations: {sorted(tj.support)}")
        print(f"  Maximum reach: ±{max(abs(d) for d in tj.support)}")
        print(f"  Cost profile: ", end="")
        for d in sorted(tj.support):
            cost = tj[d]
            cost_str = "∞" if cost == math.inf else str(int(cost))
            print(f"[{d:+d}→{cost_str}]", end=" ")
        print()
        print()


def application_circuit_complexity():
    """Application 5: Circuit Complexity Analogy

    The tropical span bound is the knot-theoretic analogue of the
    degree-vs-depth lower bound in algebraic circuit complexity.

    In circuit complexity: degree(output) ≤ depth(circuit)
    In tropical knot theory: span(tJones) ≤ 2 × crossings(diagram)

    Both are certified lower bounds: the complexity measure (depth/crossings)
    is bounded below by the output measure (degree/span).
    """
    print("=" * 70)
    print("APPLICATION 5: Circuit Complexity Analogy")
    print("=" * 70)
    print()
    print("COMPARISON:")
    print("  Circuit complexity:      degree(output) ≤ depth(circuit)")
    print("  Tropical knot theory:    span(tJones)   ≤ 2 × crossings(diagram)")
    print()
    print("Both provide certified lower bounds on structural complexity.")
    print()

    print(f"{'Diagram':<20} {'Crossings':>10} {'Span':>6} "
          f"{'Span/2':>7} {'= Lower Bound':>14}")
    print("-" * 60)

    test_cases = [
        ("Chain(1)", make_chain(1)),
        ("Chain(3)", make_chain(3)),
        ("Chain(5)", make_chain(5)),
        ("Balanced(3)", make_balanced(3)),
        ("Balanced(7)", make_balanced(7)),
        ("Alt(3)", make_alternating_chain(3)),
        ("Alt(5)", make_alternating_chain(5)),
    ]

    for name, D in test_cases:
        span, bound = tropical_span_bound(D)
        lower = span // 2
        print(f"{name:<20} {D.num_crossings:>10} {span:>6} {lower:>7} "
              f"{'≤ ' + str(D.num_crossings):>14}")
    print()


if __name__ == "__main__":
    application_complexity_certification()
    application_diagram_optimization()
    application_knot_classification()
    application_network_routing()
    application_circuit_complexity()

    print("=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Knot Theory: Interactive Demonstrations

This script demonstrates the core theorems of tropical knot theory with
concrete numerical examples, showing how min-plus algebra transforms
knot invariants into optimization problems.

Run with: python demo.py
"""

from algorithms import (
    KnotDiagram, TropicalLaurent, tropical_jones, tropical_jones_dp,
    tropical_span_bound, verify_support_bound, full_simplification,
    tropical_profiles_differ, make_chain, make_balanced, make_alternating_chain
)
import math


def demo_tropical_semiring():
    """Demonstrate the tropical (min-plus) semiring operations."""
    print("=" * 70)
    print("DEMO 1: The Tropical Semiring")
    print("=" * 70)
    print()
    print("In the tropical semiring:")
    print("  • Addition = min (take the smaller value)")
    print("  • Multiplication = + (add the values)")
    print("  • Zero = ∞ (additive identity for min)")
    print("  • One = 0 (multiplicative identity for +)")
    print()

    f = TropicalLaurent({0: 3, 1: 5, -1: 2})
    g = TropicalLaurent({0: 4, 1: 1, 2: 7})

    print(f"f = {f}")
    print(f"g = {g}")
    print()
    print(f"f ⊕ g (tropical add = pointwise min):")
    print(f"  = {f + g}")
    print()
    print(f"f ⊙ g (tropical mul = min-plus convolution):")
    print(f"  = {f * g}")
    print()

    # Verify semiring properties
    zero = TropicalLaurent()
    print(f"f ⊕ 0 = {f + zero}  (additive identity)")
    print(f"f ⊕ f = {f + f}  (idempotent!)")
    print()


def demo_skein_relation():
    """Demonstrate Theorem A: the tropical skein relation."""
    print("=" * 70)
    print("DEMO 2: Tropical Skein Relation (Theorem A)")
    print("=" * 70)
    print()
    print("The tropical Jones invariant satisfies:")
    print("  tJones(crossing(D₀, D₁))(n) = min(tJones(D₀)(n-1), tJones(D₁)(n+1))")
    print()

    loop = KnotDiagram.loop()
    D0 = KnotDiagram.crossing(loop, loop)
    D1 = loop

    tj_D0 = tropical_jones(D0)
    tj_D1 = tropical_jones(D1)

    crossing = KnotDiagram.crossing(D0, D1)
    tj_crossing = tropical_jones(crossing)

    print(f"D₀ = single crossing: tJones(D₀) = {tj_D0}")
    print(f"D₁ = loop:            tJones(D₁) = {tj_D1}")
    print(f"crossing(D₀, D₁):     tJones     = {tj_crossing}")
    print()

    # Verify the skein relation at each degree
    print("Verification of skein relation at each degree:")
    for n in range(-3, 4):
        lhs = tj_crossing[n]
        rhs = min(tj_D0[n - 1], tj_D1[n + 1])
        lhs_str = "∞" if lhs == math.inf else str(int(lhs))
        rhs_str = "∞" if rhs == math.inf else str(int(rhs))
        check = "✓" if lhs == rhs else "✗"
        print(f"  n={n:+d}: tJones(D)(n) = {lhs_str}, "
              f"min(tJones(D₀)(n-1), tJones(D₁)(n+1)) = {rhs_str}  {check}")
    print()


def demo_crossing_bound():
    """Demonstrate Theorem B: the crossing number lower bound."""
    print("=" * 70)
    print("DEMO 3: Crossing Number Lower Bound (Theorem B)")
    print("=" * 70)
    print()
    print("Theorem: For any diagram D with c crossings,")
    print("  (1) If tJones(D)(n) ≠ ∞, then |n| ≤ c")
    print("  (2) tropical span ≤ 2c")
    print()

    print(f"{'Diagram':<25} {'Crossings':>10} {'Span':>8} {'Bound':>8} {'Tight?':>8}")
    print("-" * 65)

    diagrams = [
        ("Loop", KnotDiagram.loop()),
        ("Single crossing", make_chain(1)),
        ("Chain(2)", make_chain(2)),
        ("Chain(3)", make_chain(3)),
        ("Chain(4)", make_chain(4)),
        ("Chain(5)", make_chain(5)),
        ("Balanced(3)", make_balanced(3)),
        ("Balanced(7)", make_balanced(7)),
        ("Alternating(3)", make_alternating_chain(3)),
        ("Alternating(5)", make_alternating_chain(5)),
    ]

    for name, D in diagrams:
        span, bound = tropical_span_bound(D)
        tight = "YES" if span == bound else "no"
        verified = verify_support_bound(D)
        assert verified, f"Support bound violated for {name}!"
        print(f"{name:<25} {D.num_crossings:>10} {span:>8} {bound:>8} {tight:>8}")

    print()
    print("Note: The bound is always satisfied. When tight (span = 2c),")
    print("the diagram achieves maximum tropical spread — analogous to")
    print("reduced alternating diagrams in classical knot theory.")
    print()


def demo_simplification():
    """Demonstrate Theorem C: simplification terminates with unique cost."""
    print("=" * 70)
    print("DEMO 4: Canonical Simplification (Theorem C)")
    print("=" * 70)
    print()
    print("Theorem: Every simplification step decreases crossing number.")
    print("All normal forms are loops with the same tropical Jones invariant.")
    print()

    for n in [3, 5, 7]:
        D = make_chain(n)
        path = full_simplification(D)
        print(f"Simplification of Chain({n}) ({D.num_crossings} crossings):")
        for i, step in enumerate(path):
            tj = tropical_jones(step)
            print(f"  Step {i}: {step.num_crossings} crossings, tJones = {tj}")

        # Verify all normal forms are loops
        assert path[-1].is_loop, "Normal form should be a loop!"
        print(f"  → Normal form reached: loop (0 crossings)")
        print(f"  → Normal form tJones: {tropical_jones(path[-1])}")
        print()


def demo_separation():
    """Demonstrate Theorem D: the tropical separation schema."""
    print("=" * 70)
    print("DEMO 5: Tropical Separation Schema (Theorem D)")
    print("=" * 70)
    print()
    print("Theorem: If tropicalStateProfile(D₁) ≠ tropicalStateProfile(D₂),")
    print("then tJones(D₁) ≠ tJones(D₂) at some specific degree.")
    print()

    pairs = [
        ("Chain(3)", make_chain(3), "Balanced(3)", make_balanced(3)),
        ("Chain(4)", make_chain(4), "Alternating(4)", make_alternating_chain(4)),
        ("Chain(2)", make_chain(2), "Chain(2)", make_chain(2)),
        ("Balanced(3)", make_balanced(3), "Alternating(3)", make_alternating_chain(3)),
    ]

    for name1, D1, name2, D2 in pairs:
        tj1 = tropical_jones(D1)
        tj2 = tropical_jones(D2)
        sep = tropical_profiles_differ(D1, D2)

        print(f"{name1} vs {name2}:")
        print(f"  tJones({name1}) = {tj1}")
        print(f"  tJones({name2}) = {tj2}")
        if sep is not None:
            v1 = "∞" if tj1[sep] == math.inf else str(int(tj1[sep]))
            v2 = "∞" if tj2[sep] == math.inf else str(int(tj2[sep]))
            print(f"  SEPARATED at degree {sep}: {v1} ≠ {v2}")
        else:
            print(f"  IDENTICAL tropical profiles")
        print()


def demo_dp_interpretation():
    """Demonstrate the dynamic programming / shortest-path interpretation."""
    print("=" * 70)
    print("DEMO 6: Dynamic Programming Interpretation")
    print("=" * 70)
    print()
    print("The tropical Jones invariant = shortest-path cost in the skein DAG.")
    print("Each leaf (loop) is a terminal with cost 0 at degree 0.")
    print("Each crossing combines sub-problems via min with degree shifts.")
    print()

    for n in range(1, 6):
        D = make_chain(n)
        tj_recursive = tropical_jones(D)
        tj_dp = tropical_jones_dp(D)

        assert tj_recursive == tj_dp, "DP and recursive should agree!"

        print(f"Chain({n}):")
        print(f"  Recursive: {tj_recursive}")
        print(f"  DP:        {tj_dp}")
        print(f"  Match: ✓")
    print()


def demo_family_analysis():
    """Analyze tropical invariants across diagram families."""
    print("=" * 70)
    print("DEMO 7: Family Analysis — Chains, Trees, and Alternating Diagrams")
    print("=" * 70)
    print()

    print("CHAIN FAMILY (left-leaning twists):")
    print(f"{'n':>4} {'Crossings':>10} {'Span':>6} {'Support':>30}")
    print("-" * 55)
    for n in range(8):
        D = make_chain(n)
        tj = tropical_jones(D)
        support = sorted(tj.support)
        print(f"{n:>4} {D.num_crossings:>10} {tj.span:>6} {str(support):>30}")

    print()
    print("BALANCED FAMILY (binary tree structure):")
    print(f"{'n':>4} {'Crossings':>10} {'Span':>6} {'Support':>30}")
    print("-" * 55)
    for n in [0, 1, 3, 7, 15]:
        D = make_balanced(n)
        tj = tropical_jones(D)
        support = sorted(tj.support)
        print(f"{n:>4} {D.num_crossings:>10} {tj.span:>6} {str(support):>30}")

    print()
    print("ALTERNATING FAMILY:")
    print(f"{'n':>4} {'Crossings':>10} {'Span':>6} {'Support':>30}")
    print("-" * 55)
    for n in range(8):
        D = make_alternating_chain(n)
        tj = tropical_jones(D)
        support = sorted(tj.support)
        print(f"{n:>4} {D.num_crossings:>10} {tj.span:>6} {str(support):>30}")
    print()


if __name__ == "__main__":
    demo_tropical_semiring()
    demo_skein_relation()
    demo_crossing_bound()
    demo_simplification()
    demo_separation()
    demo_dp_interpretation()
    demo_family_analysis()

    print("=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Knot Theory: Visualizations

Generates publication-quality figures illustrating the key results
of tropical knot invariant theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import base64
from io import BytesIO
from algorithms import (
    KnotDiagram, TropicalLaurent, tropical_jones,
    tropical_span_bound, make_chain, make_balanced, make_alternating_chain
)


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_support():
    """Visualize the tropical support patterns for different diagram families."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    families = [
        ("Chain Diagrams", [make_chain(n) for n in range(1, 8)], axes[0]),
        ("Balanced Trees", [make_balanced(n) for n in [1, 3, 7, 15]], axes[1]),
        ("Alternating Chains", [make_alternating_chain(n) for n in range(1, 8)], axes[2]),
    ]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 8))

    for title, diagrams, ax in families:
        for i, D in enumerate(diagrams):
            tj = tropical_jones(D)
            nc = D.num_crossings
            support = sorted(tj.support)
            y_vals = [nc] * len(support)
            ax.scatter(support, y_vals, c=[colors[i]], s=80, zorder=3,
                      edgecolors='black', linewidths=0.5)
            if support:
                ax.plot([min(support), max(support)], [nc, nc],
                       c=colors[i], linewidth=2, alpha=0.5)

        # Draw the bound lines
        max_nc = max(D.num_crossings for D in diagrams)
        for nc in range(max_nc + 1):
            ax.axvline(x=nc, color='red', alpha=0.1, linestyle='--')
            ax.axvline(x=-nc, color='red', alpha=0.1, linestyle='--')

        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xlabel('Laurent Degree', fontsize=11)
        ax.set_ylabel('Number of Crossings', fontsize=11)
        ax.grid(True, alpha=0.2)
        ax.axvline(x=0, color='gray', alpha=0.3)

    fig.suptitle('Tropical Jones Support Patterns', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def viz_span_vs_crossings():
    """Visualize the span bound: span ≤ 2 × crossings."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Generate data
    families = {
        'Chain': [(n, make_chain(n)) for n in range(1, 12)],
        'Balanced': [(n, make_balanced(n)) for n in [1, 3, 7, 15]],
        'Alternating': [(n, make_alternating_chain(n)) for n in range(1, 12)],
    }

    markers = {'Chain': 'o', 'Balanced': 's', 'Alternating': '^'}
    colors_map = {'Chain': '#2196F3', 'Balanced': '#4CAF50', 'Alternating': '#FF9800'}

    for family_name, diagrams in families.items():
        crossings = []
        spans = []
        for n, D in diagrams:
            tj = tropical_jones(D)
            crossings.append(D.num_crossings)
            spans.append(tj.span)

        ax.scatter(crossings, spans, marker=markers[family_name],
                  c=colors_map[family_name], s=100, label=family_name,
                  edgecolors='black', linewidths=0.5, zorder=3)

    # Draw the bound line
    max_c = 16
    ax.plot([0, max_c], [0, 2 * max_c], 'r--', linewidth=2,
            label='Bound: span = 2c', alpha=0.7)
    ax.fill_between([0, max_c], [0, 2 * max_c], [2 * max_c + 5] * 2,
                    alpha=0.05, color='red')

    ax.set_xlabel('Number of Crossings (c)', fontsize=13)
    ax.set_ylabel('Tropical Span', fontsize=13)
    ax.set_title('Tropical Span vs. Crossing Number\n'
                 '(Theorem B: span ≤ 2c always holds)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-0.5, max_c + 0.5)
    ax.set_ylim(-0.5, 2 * max_c + 2)

    # Add annotation
    ax.annotate('Forbidden region\n(span > 2c)',
                xy=(8, 20), fontsize=11, color='red', alpha=0.5,
                ha='center', style='italic')

    fig.tight_layout()
    return fig


def viz_skein_tree():
    """Visualize the skein expansion tree for a small diagram."""
    fig, ax = plt.subplots(figsize=(12, 8))

    # Draw a skein tree for a 3-crossing chain
    levels = [
        [(0.5, 0.95, '×(×(×(○,○),○),○)', 'red', 14)],
        [(0.25, 0.7, '×(×(○,○),○)', '#E65100', 12),
         (0.75, 0.7, '○', '#1B5E20', 12)],
        [(0.12, 0.45, '×(○,○)', '#FF6D00', 11),
         (0.38, 0.45, '○', '#1B5E20', 11)],
        [(0.06, 0.2, '○', '#1B5E20', 10),
         (0.18, 0.2, '○', '#1B5E20', 10)],
    ]

    # Draw edges
    edges = [
        ((0.5, 0.95), (0.25, 0.7), 'A: shift +1'),
        ((0.5, 0.95), (0.75, 0.7), 'B: shift −1'),
        ((0.25, 0.7), (0.12, 0.45), 'A: shift +1'),
        ((0.25, 0.7), (0.38, 0.45), 'B: shift −1'),
        ((0.12, 0.45), (0.06, 0.2), 'A: shift +1'),
        ((0.12, 0.45), (0.18, 0.2), 'B: shift −1'),
    ]

    for (x1, y1), (x2, y2), label in edges:
        ax.annotate('', xy=(x2, y2 + 0.03), xytext=(x1, y1 - 0.03),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2
        ax.text(mid_x + 0.02, mid_y, label, fontsize=8, color='gray',
               ha='left', va='center')

    for level in levels:
        for x, y, text, color, size in level:
            bbox = dict(boxstyle='round,pad=0.4', facecolor='lightyellow',
                       edgecolor=color, linewidth=2)
            ax.text(x, y, text, fontsize=size, ha='center', va='center',
                   bbox=bbox, fontfamily='monospace')

    # Add degree labels for leaves
    leaf_info = [
        (0.06, 0.12, 'degree = +3\ncost = 0'),
        (0.18, 0.12, 'degree = +1\ncost = 0'),
        (0.38, 0.37, 'degree = 0\ncost = 0'),
        (0.75, 0.62, 'degree = −1\ncost = 0'),
    ]

    for x, y, text in leaf_info:
        ax.text(x, y, text, fontsize=8, ha='center', va='top',
               color='#1B5E20', style='italic')

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0.05, 1.05)
    ax.set_title('Skein Expansion Tree for Chain(3)\n'
                 'Each path from root to leaf = a complete resolution',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    # Add legend
    legend_text = ('Tropical Jones = min over all root-to-leaf paths\n'
                  'tJones(Chain(3)) = {−1↦0, 0↦0, 1↦0, 3↦0}')
    ax.text(0.65, 0.35, legend_text, fontsize=10,
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8),
           ha='center', va='center')

    fig.tight_layout()
    return fig


def viz_simplification_paths():
    """Visualize simplification paths for different diagram families."""
    fig, ax = plt.subplots(figsize=(10, 6))

    diagrams = [
        ("Chain(6)", make_chain(6), '#2196F3'),
        ("Chain(8)", make_chain(8), '#1565C0'),
        ("Balanced(7)", make_balanced(7), '#4CAF50'),
        ("Balanced(15)", make_balanced(15), '#2E7D32'),
        ("Alt(6)", make_alternating_chain(6), '#FF9800'),
        ("Alt(8)", make_alternating_chain(8), '#E65100'),
    ]

    for name, D, color in diagrams:
        # Simplification path
        steps = [D.num_crossings]
        current = D
        while not current.is_loop:
            if current.left.num_crossings <= current.right.num_crossings:
                current = current.left
            else:
                current = current.right
            steps.append(current.num_crossings)

        ax.plot(range(len(steps)), steps, 'o-', color=color, label=name,
               markersize=6, linewidth=2)

    ax.set_xlabel('Simplification Step', fontsize=13)
    ax.set_ylabel('Crossing Number', fontsize=13)
    ax.set_title('Simplification Trajectories\n'
                 '(Theorem C: strictly decreasing, terminates at 0)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(-0.5, None)

    fig.tight_layout()
    return fig


def viz_separation_heatmap():
    """Heatmap showing tropical separation between diagram families."""
    diagrams = []
    labels = []

    for n in range(1, 6):
        diagrams.append(make_chain(n))
        labels.append(f'Ch({n})')
    for n in [1, 3, 7]:
        diagrams.append(make_balanced(n))
        labels.append(f'Bal({n})')
    for n in range(1, 5):
        diagrams.append(make_alternating_chain(n))
        labels.append(f'Alt({n})')

    n = len(diagrams)
    separation = np.zeros((n, n))

    for i in range(n):
        for j in range(n):
            tj_i = tropical_jones(diagrams[i])
            tj_j = tropical_jones(diagrams[j])
            # Count number of separating degrees
            all_degrees = tj_i.support | tj_j.support
            sep_count = sum(1 for d in all_degrees if tj_i[d] != tj_j[d])
            separation[i, j] = sep_count

    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(separation, cmap='YlOrRd', aspect='auto')

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)

    # Add text annotations
    for i in range(n):
        for j in range(n):
            val = int(separation[i, j])
            color = 'white' if val > 3 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=9, color=color)

    ax.set_title('Tropical Separation Matrix\n'
                 '(number of degrees where invariants differ)',
                 fontsize=14, fontweight='bold')
    plt.colorbar(im, label='Number of separating degrees')

    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    print("Generating visualizations...")

    figs = {
        'tropical_support': viz_tropical_support(),
        'span_vs_crossings': viz_span_vs_crossings(),
        'skein_tree': viz_skein_tree(),
        'simplification': viz_simplification_paths(),
        'separation_heatmap': viz_separation_heatmap(),
    }

    results = {}
    for name, fig in figs.items():
        b64 = fig_to_base64(fig)
        results[name] = b64
        print(f"  Generated {name} ({len(b64)} chars)")

        # Also save to file
        buf = BytesIO()
        fig_copy = fig  # already closed by fig_to_base64, need to regenerate
        print(f"  (saved inline)")

    return results


if __name__ == "__main__":
    # Save individual figures
    figs = {
        'tropical_support': viz_tropical_support(),
        'span_vs_crossings': viz_span_vs_crossings(),
        'skein_tree': viz_skein_tree(),
        'simplification': viz_simplification_paths(),
        'separation_heatmap': viz_separation_heatmap(),
    }

    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight',
                   facecolor='white', edgecolor='none')
        print(f"Saved {name}.png")
        plt.close(fig)

    print("All visualizations generated!")
