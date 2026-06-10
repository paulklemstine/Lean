#!/usr/bin/env python3
"""
Provability Logic GL: Demonstrations and Examples

This script demonstrates the core concepts of provability logic GL:
1. GL frame construction and validation
2. Löb's axiom verification on concrete frames
3. Gödel element detection in provability lattices
4. Well-foundedness verification
5. Theory branching visualization
"""

from itertools import product
from typing import Set, FrozenSet, Dict, List, Tuple, Optional


def demo_gl_frame():
    """Demonstrate a GL frame (finite transitive irreflexive structure)."""
    print("=" * 60)
    print("DEMO 1: GL Frame Construction")
    print("=" * 60)

    # A simple GL frame: worlds = {0, 1, 2, 3}
    # Accessibility: 0 → 1, 0 → 2, 1 → 3, 2 → 3
    # (a diamond-shaped poset)
    worlds = {0, 1, 2, 3}
    R = {(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)}  # transitive closure

    print(f"Worlds: {worlds}")
    print(f"Accessibility R: {R}")

    # Verify irreflexivity
    irrefl = all((w, w) not in R for w in worlds)
    print(f"Irreflexive: {irrefl}")

    # Verify transitivity
    trans = all(
        (w, u) in R
        for w in worlds for v in worlds for u in worlds
        if (w, v) in R and (v, u) in R
    )
    print(f"Transitive: {trans}")

    # Compute box operator for S = {3}
    S = {3}
    box_S = {w for w in worlds if all(v in S for v in worlds if (w, v) in R)}
    print(f"\nS = {S}")
    print(f"□S = {box_S}")

    # Compute box for S = {1, 3}
    S2 = {1, 3}
    box_S2 = {w for w in worlds if all(v in S2 for v in worlds if (w, v) in R)}
    print(f"\nS = {S2}")
    print(f"□S = {box_S2}")

    # Maximal worlds (dead ends)
    maximal = {w for w in worlds if not any((w, v) in R for v in worlds)}
    print(f"\nMaximal worlds: {maximal}")
    print()


def verify_loeb_axiom(worlds: set, R: set) -> bool:
    """Verify Löb's axiom on a GL frame: □((□S)ᶜ ∪ S) ⊆ □S for all S."""
    for subset_bits in range(2 ** len(worlds)):
        world_list = sorted(worlds)
        S = {world_list[i] for i in range(len(world_list)) if subset_bits & (1 << i)}

        # Compute □S
        box_S = {w for w in worlds if all(v in S for v in worlds if (w, v) in R)}

        # Compute (□S)ᶜ ∪ S
        box_S_compl_union_S = (worlds - box_S) | S

        # Compute □((□S)ᶜ ∪ S)
        box_loeb = {w for w in worlds
                    if all(v in box_S_compl_union_S for v in worlds if (w, v) in R)}

        # Check □((□S)ᶜ ∪ S) ⊆ □S
        if not box_loeb.issubset(box_S):
            return False
    return True


def demo_loeb_verification():
    """Verify Löb's axiom on several GL frames."""
    print("=" * 60)
    print("DEMO 2: Löb's Axiom Verification")
    print("=" * 60)

    # Frame 1: Linear order 0 → 1 → 2
    worlds1 = {0, 1, 2}
    R1 = {(0, 1), (0, 2), (1, 2)}
    valid1 = verify_loeb_axiom(worlds1, R1)
    print(f"Linear 3-chain: Löb valid = {valid1}")

    # Frame 2: Diamond
    worlds2 = {0, 1, 2, 3}
    R2 = {(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)}
    valid2 = verify_loeb_axiom(worlds2, R2)
    print(f"Diamond frame: Löb valid = {valid2}")

    # Frame 3: Binary tree depth 2
    worlds3 = {0, 1, 2, 3, 4, 5, 6}
    R3 = set()
    for i in range(7):
        for j in range(i + 1, 7):
            if j in {2 * i + 1, 2 * i + 2}:
                R3.add((i, j))
    # Add transitive closure
    changed = True
    while changed:
        changed = False
        for (a, b) in list(R3):
            for (c, d) in list(R3):
                if b == c and (a, d) not in R3:
                    R3.add((a, d))
                    changed = True
    valid3 = verify_loeb_axiom(worlds3, R3)
    print(f"Binary tree depth 2: Löb valid = {valid3}")

    # Counterexample: reflexive frame (NOT a GL frame)
    worlds_refl = {0, 1}
    R_refl = {(0, 0), (0, 1), (1, 1)}  # reflexive!
    valid_refl = verify_loeb_axiom(worlds_refl, R_refl)
    print(f"Reflexive frame (not GL): Löb valid = {valid_refl}")
    print()


def demo_goedel_element():
    """Demonstrate Gödel elements in a concrete provability lattice."""
    print("=" * 60)
    print("DEMO 3: Gödel Elements in Provability Lattices")
    print("=" * 60)

    # Use the power set lattice of {a, b} with □ = interior operator
    # from the GL frame 0 → 1
    worlds = [0, 1]
    R = {(0, 1)}

    # Elements of the lattice: subsets of worlds
    elements = [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]
    names = {frozenset(): "∅", frozenset({0}): "{0}", frozenset({1}): "{1}",
             frozenset({0, 1}): "{0,1}"}

    def box(S: frozenset) -> frozenset:
        """□S = {w | ∀v, R(w,v) → v ∈ S}"""
        return frozenset(w for w in worlds
                         if all(v in S for v in worlds if (w, v) in R))

    print("Provability lattice from GL frame {0 → 1}:")
    print(f"  ⊥ = ∅, ⊤ = {{0,1}}")
    print(f"  □∅ = {names[box(frozenset())]}")
    print(f"  □{{0}} = {names[box(frozenset({0}))]}")
    print(f"  □{{1}} = {names[box(frozenset({1}))]}")
    print(f"  □{{0,1}} = {names[box(frozenset({0, 1}))]}")

    # Check for Gödel elements: g ⊓ □g = ⊥ and g ⊔ □g = ⊤
    print("\nSearching for Gödel elements...")
    bot = frozenset()
    top = frozenset({0, 1})
    for g in elements:
        bg = box(g)
        meet = g & bg  # intersection = meet
        join = g | bg  # union = join
        if meet == bot and join == top:
            print(f"  FOUND: g = {names[g]}, □g = {names[bg]}")
            print(f"    g ⊓ □g = {names[meet]} = ⊥ ✓")
            print(f"    g ⊔ □g = {names[join]} = ⊤ ✓")
            print(f"    □g ≠ ⊤: {bg != top} ✓ (g is not provable)")
            print(f"    g ≠ ⊥: {g != bot} ✓ (g is not refutable)")
            print(f"    g ≠ ⊤: {g != top} ✓ (g is not trivially true)")
    print()


def demo_well_founded():
    """Demonstrate well-foundedness of GL frames."""
    print("=" * 60)
    print("DEMO 4: Well-Foundedness of GL Frames")
    print("=" * 60)

    # Compute the rank (depth) of each world in a GL frame
    worlds = {0, 1, 2, 3, 4}
    R = {(0, 1), (0, 2), (0, 3), (0, 4), (1, 3), (1, 4), (2, 4), (3, 4)}

    def compute_rank(w, visited=None):
        if visited is None:
            visited = set()
        if w in visited:
            return -1  # cycle detected (shouldn't happen in GL)
        visited.add(w)
        successors = [v for v in worlds if (w, v) in R]
        if not successors:
            return 0
        return 1 + max(compute_rank(v, visited.copy()) for v in successors)

    print(f"GL frame with worlds {worlds}")
    print(f"R = {R}")
    print("\nWorld ranks (depth in well-founded order):")
    for w in sorted(worlds):
        rank = compute_rank(w)
        successors = sorted(v for v in worlds if (w, v) in R)
        print(f"  World {w}: rank = {rank}, successors = {successors}")

    # Verify no infinite descending chains exist
    print("\nWell-founded: every nonempty subset has a minimal element")
    for bits in range(1, 2**len(worlds)):
        wl = sorted(worlds)
        subset = {wl[i] for i in range(len(wl)) if bits & (1 << i)}
        has_min = any(
            all((v, w) not in R for v in subset)
            for w in subset
        )
        if not has_min:
            print(f"  WARNING: {subset} has no minimal element!")
            break
    else:
        print("  All nonempty subsets have minimal elements ✓")
    print()


def demo_consistency_hierarchy():
    """Demonstrate the consistency strength hierarchy."""
    print("=" * 60)
    print("DEMO 5: Consistency Strength Hierarchy")
    print("=" * 60)

    # Model: 5-world linear frame  0 → 1 → 2 → 3 → 4
    worlds = list(range(5))
    R = {(i, j) for i in range(5) for j in range(i + 1, 5)}

    def box(S):
        return frozenset(w for w in worlds if all(v in S for v in worlds if (w, v) in R))

    def complement(S):
        return frozenset(w for w in worlds if w not in S)

    # Consistency hierarchy: Con₀ = ⊤, Conₙ₊₁ = ¬□¬Conₙ
    bot = frozenset()
    top = frozenset(worlds)

    con = [top]
    print("Consistency hierarchy Con₀(T), Con₁(T), Con₂(T), ...")
    print(f"  Con₀ = {set(con[0])} (= ⊤)")

    for n in range(1, 5):
        prev = con[-1]
        neg_prev = complement(prev)
        box_neg = box(neg_prev)
        con_n = complement(box_neg)  # ¬□¬Conₙ₋₁
        con.append(con_n)
        print(f"  Con{n} = ¬□¬Con{n-1} = {set(con_n)}")

    print("\nHierarchy is strictly decreasing in the lattice:")
    for n in range(len(con) - 1):
        is_strict = con[n + 1].issubset(con[n]) and con[n + 1] != con[n]
        print(f"  Con{n+1} ⊂ Con{n}: {is_strict}")
    print()


def demo_theory_branching():
    """Demonstrate theory branching from independent sentences."""
    print("=" * 60)
    print("DEMO 6: Theory Branching")
    print("=" * 60)

    # Simple model: 3 atomic sentences, initial theory = {⊤}
    # G is independent, so we get two extensions
    print("Initial theory T with 3 atomic sentences: p, q, r")
    print("T = {⊤} (only tautologies)")
    print()

    # Simulate: G = p ∧ ¬q is independent
    print("Suppose G = 'p ∧ ¬q' is independent of T:")
    print("  G ∉ T  and  ¬G ∉ T")
    print()
    print("Branching:")
    print("  Extension 1: T + G  = T ∪ {p ∧ ¬q, p, ¬q, ...}")
    print("  Extension 2: T + ¬G = T ∪ {¬p ∨ q, ...}")
    print()
    print("Both extensions are consistent (by independence)")
    print("They are distinct (G ∈ T+G but G ∉ T+¬G)")
    print()

    # Count: with n independent sentences, 2^n branches
    for n in range(1, 7):
        print(f"  {n} independent sentences → {2**n} maximal extensions")
    print()


if __name__ == "__main__":
    demo_gl_frame()
    demo_loeb_verification()
    demo_goedel_element()
    demo_well_founded()
    demo_consistency_hierarchy()
    demo_theory_branching()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: GL Frame Structure and Theory Branching

Creates a visualization of GL frames showing the well-founded accessibility
structure, world ranks, and box operator behavior.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_gl_frame():
    """Draw a GL frame with world ranks and accessibility arrows."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Frame 1: Linear chain
    ax = axes[0]
    ax.set_title("Linear GL Frame\n(0 → 1 → 2 → 3)", fontsize=12, fontweight='bold')
    worlds = [0, 1, 2, 3]
    positions = {0: (0.5, 0.1), 1: (0.5, 0.35), 2: (0.5, 0.6), 3: (0.5, 0.85)}
    R = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]

    for (u, v) in R:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        ax.annotate("", xy=(x2, y2 - 0.03), xytext=(x1, y1 + 0.03),
                     arrowprops=dict(arrowstyle="->", color="steelblue", lw=1.5, alpha=0.5))

    for w in worlds:
        x, y = positions[w]
        circle = plt.Circle((x, y), 0.04, color='coral', ec='black', lw=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(w), ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)
        ax.text(x + 0.12, y, f"rank={3-w}", ha='left', va='center', fontsize=9, color='gray')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')

    # Frame 2: Diamond
    ax = axes[1]
    ax.set_title("Diamond GL Frame\n(binary branching)", fontsize=12, fontweight='bold')
    positions2 = {0: (0.5, 0.1), 1: (0.25, 0.5), 2: (0.75, 0.5), 3: (0.5, 0.85)}
    R2 = [(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)]

    for (u, v) in R2:
        x1, y1 = positions2[u]
        x2, y2 = positions2[v]
        ax.annotate("", xy=(x2, y2 - 0.03), xytext=(x1, y1 + 0.03),
                     arrowprops=dict(arrowstyle="->", color="steelblue", lw=1.5, alpha=0.5))

    ranks2 = {0: 2, 1: 1, 2: 1, 3: 0}
    for w in [0, 1, 2, 3]:
        x, y = positions2[w]
        circle = plt.Circle((x, y), 0.04, color='coral', ec='black', lw=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(w), ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)
        ax.text(x + 0.1, y, f"r={ranks2[w]}", ha='left', va='center', fontsize=9, color='gray')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')

    # Frame 3: Theory branching tree
    ax = axes[2]
    ax.set_title("Theory Branching\n(independent sentences → forks)", fontsize=12, fontweight='bold')

    # Draw a binary tree representing theory extensions
    def draw_tree(ax, x, y, dx, depth, label="T"):
        if depth == 0:
            ax.plot(x, y, 'o', color='gold', markersize=8, markeredgecolor='black', zorder=5)
            ax.text(x, y - 0.06, label, ha='center', fontsize=7)
            return

        ax.plot(x, y, 'o', color='lightgreen', markersize=8, markeredgecolor='black', zorder=5)
        ax.text(x, y - 0.06, label, ha='center', fontsize=7)

        # Left branch: T + G
        x_left, y_left = x - dx, y + 0.2
        ax.plot([x, x_left], [y + 0.02, y_left - 0.02], '-', color='steelblue', lw=1.5)
        ax.text((x + x_left) / 2 - 0.03, (y + y_left) / 2, "+G", fontsize=7, color='blue')
        draw_tree(ax, x_left, y_left, dx * 0.5, depth - 1, f"{label}+G")

        # Right branch: T + ¬G
        x_right, y_right = x + dx, y + 0.2
        ax.plot([x, x_right], [y + 0.02, y_right - 0.02], '-', color='firebrick', lw=1.5)
        ax.text((x + x_right) / 2 + 0.01, (y + y_right) / 2, "+¬G", fontsize=7, color='red')
        draw_tree(ax, x_right, y_right, dx * 0.5, depth - 1, f"{label}+¬G")

    draw_tree(ax, 0.5, 0.05, 0.2, 3, "T₀")
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("gl_frames.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved gl_frames.png")


def draw_consistency_hierarchy():
    """Visualize the consistency strength hierarchy."""
    fig, ax = plt.subplots(figsize=(10, 6))

    levels = ["T", "T + Con(T)", "T + Con(T + Con(T))",
              "T + Con²(T)", "T + Con³(T)"]
    widths = [1.0, 0.85, 0.72, 0.61, 0.52]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(levels)))

    for i, (level, width) in enumerate(zip(levels, widths)):
        y = i * 1.2
        rect = patches.FancyBboxPatch(
            (0.5 - width / 2, y), width, 0.8,
            boxstyle="round,pad=0.05",
            facecolor=colors[i], edgecolor='black', alpha=0.7
        )
        ax.add_patch(rect)
        ax.text(0.5, y + 0.4, level, ha='center', va='center',
                fontsize=11, fontweight='bold', color='white')

        if i > 0:
            ax.annotate("", xy=(0.5, y), xytext=(0.5, y - 0.4),
                         arrowprops=dict(arrowstyle="->", color='black', lw=2))

    ax.text(1.1, 2.5, "Each level is\nstrictly stronger\nthan the one below",
            fontsize=10, ha='left', style='italic', color='gray')

    ax.set_xlim(-0.2, 1.6)
    ax.set_ylim(-0.5, 6.5)
    ax.set_title("Consistency Strength Hierarchy", fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("consistency_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved consistency_hierarchy.png")


def draw_provability_lattice():
    """Draw the provability lattice from a GL frame."""
    fig, ax = plt.subplots(figsize=(8, 8))

    # Lattice of upward-closed subsets of {0 → 1}
    # Elements: ∅, {1}, {0,1}
    # Plus box values
    elements = {
        "∅": (0.5, 0.1),
        "{1}": (0.5, 0.45),
        "{0,1}": (0.5, 0.8),
    }

    box_values = {"∅": "∅", "{1}": "{0,1}", "{0,1}": "{0,1}"}

    # Draw edges (Hasse diagram)
    edges = [("∅", "{1}"), ("{1}", "{0,1}")]
    for (a, b) in edges:
        x1, y1 = elements[a]
        x2, y2 = elements[b]
        ax.plot([x1, x2], [y1, y2], '-', color='steelblue', lw=2)

    for name, (x, y) in elements.items():
        circle = plt.Circle((x, y), 0.06, color='lightyellow', ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)
        ax.text(x + 0.15, y, f"□={box_values[name]}", ha='left', va='center',
                fontsize=9, color='darkred')

    # Mark Gödel element
    # In this simple lattice, {1} is NOT a Gödel element ({1} ⊓ □{1} = {1} ⊓ {0,1} = {1} ≠ ∅)
    # We need the 4-element lattice from the diamond frame

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_title("Provability Lattice\n(from GL frame 0 → 1)", fontsize=14, fontweight='bold')
    ax.text(0.5, -0.05, "⊥ = ∅ (contradiction), ⊤ = {0,1} (tautology)",
            ha='center', fontsize=10, color='gray')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("provability_lattice.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved provability_lattice.png")


if __name__ == "__main__":
    draw_gl_frame()
    draw_consistency_hierarchy()
    draw_provability_lattice()
    print("All visualizations saved.")
