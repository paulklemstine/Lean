#!/usr/bin/env python3
"""
Counterpoint Category Theory — Demonstration

Enumerates the counterpoint transition graph, verifies key theorems,
and demonstrates the mathematical structure of first-species counterpoint.
"""

from typing import Dict, List, Set, Tuple

# Consonant interval classes in first-species two-voice counterpoint
CONSONANT = {0, 3, 4, 7, 8, 9}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

INTERVAL_NAMES = {
    0: "Unison (P1)", 3: "Minor 3rd (m3)", 4: "Major 3rd (M3)",
    7: "Perfect 5th (P5)", 8: "Minor 6th (m6)", 9: "Major 6th (M6)"
}


def interval_delta(a: int, b: int) -> int:
    """Interval change from voice leading (a, b)."""
    return (b - a) % 12


def is_valid_transition(i: int, j: int, a: int, b: int) -> bool:
    """Check if voice leading (a, b) from interval i to j is valid."""
    if i not in CONSONANT or j not in CONSONANT:
        return False
    if abs(a) > 2 or abs(b) > 2:
        return False
    if interval_delta(a, b) != (j - i) % 12:
        return False
    if j in PERFECT and a == b:  # No parallel motion to perfect consonances
        return False
    return True


def compute_transition_graph() -> Dict[int, Set[int]]:
    """Compute the full transition graph."""
    graph: Dict[int, Set[int]] = {i: set() for i in CONSONANT}
    for i in CONSONANT:
        for j in CONSONANT:
            for a in range(-2, 3):
                for b in range(-2, 3):
                    if is_valid_transition(i, j, a, b):
                        graph[i].add(j)
    return graph


def vl_cost(a: int, b: int) -> int:
    """Voice leading cost."""
    return abs(a) + abs(b)


def find_min_cost_transition(i: int, j: int) -> Tuple[int, int, int]:
    """Find minimum-cost valid voice leading from i to j. Returns (a, b, cost)."""
    best = None
    for a in range(-2, 3):
        for b in range(-2, 3):
            if is_valid_transition(i, j, a, b):
                c = vl_cost(a, b)
                if best is None or c < best[2]:
                    best = (a, b, c)
    return best if best else (0, 0, float('inf'))


def main():
    print("=" * 60)
    print("COUNTERPOINT AS CATEGORY THEORY")
    print("First-Species Transition Graph Analysis")
    print("=" * 60)

    graph = compute_transition_graph()

    # Display transition graph
    print("\n--- Transition Graph (Adjacency List) ---")
    total_edges = 0
    for i in sorted(CONSONANT):
        targets = sorted(graph[i])
        names = [INTERVAL_NAMES[t] for t in targets]
        print(f"  {INTERVAL_NAMES[i]:20s} → {names}  (out-degree {len(targets)})")
        total_edges += len(targets)
    print(f"\n  Total edges: {total_edges}")

    # Theorem A: Inversion Asymmetry
    print("\n--- Theorem A: Inversion Asymmetry ---")
    for i in sorted(CONSONANT):
        neg_i = (-i) % 12
        status = "✓ consonant" if neg_i in CONSONANT else "✗ DISSONANT"
        print(f"  -{INTERVAL_NAMES[i]:20s} = {neg_i:2d} semitones  {status}")

    # Theorem B: Stepwise Separation
    print("\n--- Theorem B: Stepwise Separation ---")
    reachable_deltas = set()
    for a in range(-2, 3):
        for b in range(-2, 3):
            reachable_deltas.add(interval_delta(a, b))
    print(f"  Reachable interval changes: {sorted(reachable_deltas)}")
    print(f"  Contains 5 (P4)? {5 in reachable_deltas}")
    print(f"  Contains 7 (P5)? {7 in reachable_deltas}")
    print(f"  → Perfect consonances SEPARATED")

    # Theorem C: Balanced Graph
    print("\n--- Theorem C: Balanced Graph ---")
    for v in sorted(CONSONANT):
        out_deg = len(graph[v])
        in_deg = sum(1 for u in CONSONANT if v in graph[u])
        balanced = "✓" if out_deg == in_deg else "✗"
        print(f"  {INTERVAL_NAMES[v]:20s}: out={out_deg}, in={in_deg}  {balanced}")

    # Theorem D: Strong Connectivity
    print("\n--- Theorem D: Diameter Analysis ---")
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            if i == j:
                continue
            direct = j in graph[i]
            two_step = any(j in graph[k] for k in graph[i])
            if not direct and two_step:
                # Find intermediate
                intermediates = [k for k in graph[i] if j in graph[k]]
                int_names = [INTERVAL_NAMES[k] for k in intermediates]
                print(f"  {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]}: "
                      f"2 steps via {int_names}")

    # Minimum cost transitions
    print("\n--- Minimum Cost Voice Leadings ---")
    for i in sorted(CONSONANT):
        for j in sorted(graph[i]):
            a, b, c = find_min_cost_transition(i, j)
            print(f"  {INTERVAL_NAMES[i]:12s} → {INTERVAL_NAMES[j]:12s}: "
                  f"({a:+d},{b:+d}) cost={c}")

    # Diatonic restriction
    print("\n--- Diatonic Restriction ---")
    diatonic = {0, 2, 4, 5, 7, 9, 11}
    diatonic_consonant = CONSONANT & diatonic
    print(f"  Diatonic consonances: {sorted(diatonic_consonant)}")
    print(f"  Lost intervals: {sorted(CONSONANT - diatonic_consonant)}")

    diatonic_edges = 0
    for i in sorted(diatonic_consonant):
        targets = [j for j in sorted(diatonic_consonant) if j in graph[i]]
        diatonic_edges += len(targets)
        print(f"  {INTERVAL_NAMES[i]:20s} → "
              f"{[INTERVAL_NAMES[t] for t in targets]}")
    print(f"  Diatonic edges: {diatonic_edges} (vs {total_edges} chromatic)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Inversion Asymmetry in Counterpoint Consonances

Shows which consonant intervals map to consonant intervals under
negation (mod 12), highlighting the unique asymmetry at the perfect fifth.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    consonant = {0, 3, 4, 7, 8, 9}
    all_intervals = list(range(12))
    names = {
        0: "P1", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
        6: "TT", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7"
    }

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Circle of interval classes with inversion arrows
    ax1.set_aspect('equal')
    ax1.set_xlim(-2.5, 2.5)
    ax1.set_ylim(-2.5, 2.5)
    ax1.axis('off')
    ax1.set_title("Interval Classes and Inversion\n(negation mod 12)",
                  fontsize=12, fontweight='bold')

    radius = 1.8
    for i in all_intervals:
        angle = 2 * np.pi * i / 12 - np.pi / 2
        x, y = radius * np.cos(angle), radius * np.sin(angle)

        if i in consonant:
            color = '#e74c3c' if i in {0, 7} else '#3498db'
        else:
            color = '#cccccc'

        circle = plt.Circle((x, y), 0.22, color=color, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, names[i], ha='center', va='center',
                fontsize=8, fontweight='bold', color='white', zorder=6)

    # Draw inversion arrows for consonant intervals
    for i in [3, 4, 7]:  # Only draw one direction of each pair
        neg_i = (-i) % 12
        a1 = 2 * np.pi * i / 12 - np.pi / 2
        a2 = 2 * np.pi * neg_i / 12 - np.pi / 2
        r_inner = 1.5
        x1, y1 = r_inner * np.cos(a1), r_inner * np.sin(a1)
        x2, y2 = r_inner * np.cos(a2), r_inner * np.sin(a2)

        color = '#e74c3c' if neg_i not in consonant else '#27ae60'
        style = '--' if neg_i not in consonant else '-'
        ax1.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=color,
                                  lw=2, linestyle=style))

    # Right: Bar chart of consonance preservation
    ax2.set_title("Inversion Preserves Consonance?\nFor Each Consonant Interval",
                  fontsize=12, fontweight='bold')

    consonant_list = sorted(consonant)
    preserved = []
    colors = []
    for i in consonant_list:
        neg_i = (-i) % 12
        if neg_i in consonant:
            preserved.append(1)
            colors.append('#27ae60')
        else:
            preserved.append(0)
            colors.append('#e74c3c')

    bars = ax2.bar([names[i] for i in consonant_list], preserved, color=colors)
    ax2.set_ylabel("Inversion Preserves Consonance", fontsize=11)
    ax2.set_ylim(-0.1, 1.3)
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(['No', 'Yes'])

    for i, (bar, ic) in enumerate(zip(bars, consonant_list)):
        neg_ic = (-ic) % 12
        label = f"→ {names[neg_ic]}"
        ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.05,
                label, ha='center', va='bottom', fontsize=9)

    plt.tight_layout()
    plt.savefig('inversion_asymmetry.png', dpi=150, bbox_inches='tight')
    print("Saved: inversion_asymmetry.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph

Renders the 26-edge directed graph of first-species counterpoint transitions
using matplotlib, with perfect consonances in one color and imperfect in another.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def build_graph():
    """Build the transition graph."""
    consonant = [0, 3, 4, 7, 8, 9]
    perfect = {0, 7}
    edges = []
    for i in consonant:
        for j in consonant:
            for a in range(-2, 3):
                for b in range(-2, 3):
                    delta = (b - a) % 12
                    target_delta = (j - i) % 12
                    if delta == target_delta:
                        if j in perfect and a == b:
                            continue
                        edges.append((i, j))
                        break
                else:
                    continue
                break
    return consonant, edges


def main():
    consonant, edges = build_graph()
    names = {0: "P1\n(0)", 3: "m3\n(3)", 4: "M3\n(4)",
             7: "P5\n(7)", 8: "m6\n(8)", 9: "M6\n(9)"}
    perfect = {0, 7}

    # Arrange vertices in a circle
    n = len(consonant)
    angles = {v: 2 * np.pi * i / n - np.pi / 2 for i, v in enumerate(consonant)}
    radius = 2.5
    pos = {v: (radius * np.cos(angles[v]), radius * np.sin(angles[v]))
           for v in consonant}

    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_aspect('equal')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.axis('off')
    ax.set_title("First-Species Counterpoint Transition Graph\n"
                 "6 vertices, 26 edges, diameter 2",
                 fontsize=14, fontweight='bold')

    # Draw edges
    for (u, v) in edges:
        x1, y1 = pos[u]
        x2, y2 = pos[v]

        if u == v:
            # Self-loop
            angle = angles[u]
            loop_center = (x1 + 0.6 * np.cos(angle), y1 + 0.6 * np.sin(angle))
            circle = plt.Circle(loop_center, 0.3, fill=False,
                              color='#666666', linewidth=1.5)
            ax.add_patch(circle)
        else:
            # Curved arrow
            dx, dy = x2 - x1, y2 - y1
            dist = np.sqrt(dx**2 + dy**2)
            # Shorten for node radius
            shrink = 0.45
            sx1 = x1 + shrink * dx / dist
            sy1 = y1 + shrink * dy / dist
            sx2 = x2 - shrink * dx / dist
            sy2 = y2 - shrink * dy / dist

            # Check if reverse edge exists for curving
            has_reverse = (v, u) in edges
            curve = 0.15 if has_reverse else 0.0

            style = mpatches.FancyArrowPatch(
                (sx1, sy1), (sx2, sy2),
                arrowstyle='->', mutation_scale=15,
                connectionstyle=f"arc3,rad={curve}",
                color='#444444', linewidth=1.2
            )
            ax.add_patch(style)

    # Draw vertices
    for v in consonant:
        x, y = pos[v]
        color = '#e74c3c' if v in perfect else '#3498db'
        circle = plt.Circle((x, y), 0.4, color=color, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, names[v], ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=6)

    # Legend
    perfect_patch = mpatches.Patch(color='#e74c3c', label='Perfect consonance')
    imperfect_patch = mpatches.Patch(color='#3498db', label='Imperfect consonance')
    ax.legend(handles=[perfect_patch, imperfect_patch], loc='lower right',
              fontsize=11)

    # Degree annotations
    for v in consonant:
        x, y = pos[v]
        out_deg = sum(1 for (u, w) in edges if u == v)
        ax.text(x, y - 0.65, f"deg={out_deg}", ha='center', va='center',
                fontsize=8, color='#666666')

    plt.tight_layout()
    plt.savefig('transition_graph.png', dpi=150, bbox_inches='tight')
    print("Saved: transition_graph.png")


if __name__ == "__main__":
    main()
