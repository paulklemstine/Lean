"""
Visualization: Birkhoff Representation — Lattice as Lower Sets of 𝔽₁-Points

This visualizes the Birkhoff representation theorem: a finite distributive lattice
is isomorphic to the lattice of lower sets (downward-closed subsets) of its poset
of sup-irreducible elements.

We show two examples side by side:
1. The divisor lattice of 12 (sup-irreducibles: 2, 3, 4)
2. Its Birkhoff image: lower sets of the poset {2, 3, 4}

This illustrates Theorem 5 (base change): the lattice is fully determined by its
𝔽₁-skeleton.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import gcd


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # ── Left panel: Divisor lattice of 12 ────────────────────────────────

    ax = axes[0]
    divs = [1, 2, 3, 4, 6, 12]
    lcm_fn = lambda a, b: a * b // gcd(a, b)

    # Check sup-irreducibility
    irreds = []
    for d in divs:
        if d == 1:
            continue
        is_irred = True
        for a in divs:
            for b in divs:
                if lcm_fn(a, b) == d and a != d and b != d:
                    is_irred = False
                    break
            if not is_irred:
                break
        if is_irred:
            irreds.append(d)

    # Positions for Hasse diagram
    positions = {
        1: (0, 0),
        2: (-1.5, 1.5),
        3: (1.5, 1.5),
        4: (-1.5, 3.0),
        6: (1.5, 3.0),
        12: (0, 4.5),
    }

    # Hasse edges (covers in divisibility order)
    hasse = [(1, 2), (1, 3), (2, 4), (2, 6), (3, 6), (4, 12), (6, 12)]

    # Draw edges
    for a, b in hasse:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', linewidth=1.2, alpha=0.4)

    # Draw nodes
    for d in divs:
        x, y = positions[d]
        if d in irreds:
            color = '#e74c3c'
            size = 900
        elif d == 1:
            color = '#95a5a6'
            size = 700
        else:
            color = '#3498db'
            size = 700

        ax.scatter(x, y, s=size, c=color, edgecolors='white',
                   linewidths=2, zorder=10)
        ax.annotate(str(d), (x, y), fontsize=14, ha='center', va='center',
                    fontweight='bold', color='white', zorder=11)

    ax.set_title("Divisor Lattice D₁₂\nSup-irreducibles = {2, 3, 4}",
                 fontsize=14, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.8, 5.5)
    ax.axis('off')

    # Annotations showing the Birkhoff map
    birkhoff = {
        1:  "∅",
        2:  "{2}",
        3:  "{3}",
        4:  "{2,4}",
        6:  "{2,3}",
        12: "{2,3,4}",
    }

    for d in divs:
        x, y = positions[d]
        ax.annotate(f"→ {birkhoff[d]}", (x + 0.15, y - 0.5),
                    fontsize=9, ha='center', color='#8e44ad',
                    fontstyle='italic')

    # ── Right panel: Lower sets of {2, 3, 4} ────────────────────────────

    ax = axes[1]

    # Poset of sup-irreducibles: 2 | 4, 3 is incomparable to both
    # Lower sets: ∅, {2}, {3}, {2,3}, {2,4}, {2,3,4}
    lower_sets = [
        frozenset(),
        frozenset({2}),
        frozenset({3}),
        frozenset({2, 3}),
        frozenset({2, 4}),
        frozenset({2, 3, 4}),
    ]

    ls_positions = {
        frozenset(): (0, 0),
        frozenset({2}): (-1.5, 1.5),
        frozenset({3}): (1.5, 1.5),
        frozenset({2, 4}): (-1.5, 3.0),
        frozenset({2, 3}): (1.5, 3.0),
        frozenset({2, 3, 4}): (0, 4.5),
    }

    # Hasse edges
    ls_hasse = [
        (frozenset(), frozenset({2})),
        (frozenset(), frozenset({3})),
        (frozenset({2}), frozenset({2, 4})),
        (frozenset({2}), frozenset({2, 3})),
        (frozenset({3}), frozenset({2, 3})),
        (frozenset({2, 4}), frozenset({2, 3, 4})),
        (frozenset({2, 3}), frozenset({2, 3, 4})),
    ]

    for a, b in ls_hasse:
        xa, ya = ls_positions[a]
        xb, yb = ls_positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', linewidth=1.2, alpha=0.4)

    for ls in lower_sets:
        x, y = ls_positions[ls]
        if len(ls) == 0:
            color = '#95a5a6'
        elif len(ls) == 1:
            color = '#e74c3c'
        else:
            color = '#8e44ad'
        size = 900

        ax.scatter(x, y, s=size, c=color, edgecolors='white',
                   linewidths=2, zorder=10)

        lbl = "∅" if not ls else "{" + ",".join(str(x) for x in sorted(ls)) + "}"
        ax.annotate(lbl, (x, y), fontsize=11, ha='center', va='center',
                    fontweight='bold', color='white', zorder=11)

    ax.set_title("Lower Sets of Poset J(D₁₂)\n= Birkhoff Representation",
                 fontsize=14, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.8, 5.5)
    ax.axis('off')

    # Big arrow between panels
    fig.text(0.5, 0.5, "≅", fontsize=40, ha='center', va='center',
             fontweight='bold', color='#e67e22',
             transform=fig.transFigure)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', label='𝔽₁-point (sup-irreducible)'),
        mpatches.Patch(facecolor='#3498db', label='Composite (generated)'),
        mpatches.Patch(facecolor='#8e44ad', label='Lower set (Birkhoff image)'),
        mpatches.Patch(facecolor='#95a5a6', label='Bottom ⊥'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=4,
               fontsize=10, framealpha=0.9)

    plt.suptitle("Birkhoff Representation: Every Lattice Element\n"
                 "= A Lower Set of 𝔽₁-Points",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.subplots_adjust(bottom=0.12)
    plt.savefig('viz_birkhoff_representation.png', dpi=150, bbox_inches='tight')
    print("Saved viz_birkhoff_representation.png")


if __name__ == "__main__":
    main()
