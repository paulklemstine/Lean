#!/usr/bin/env python3
"""
Demo: Computing Impossibility Spectra for Small Groups

Demonstrates the key concepts of equivariant impossibility theory:
1. Fixed-point obstruction detection
2. Full spectrum computation
3. Verification of the obstruction filter axioms
4. Upward closure visualization
"""

from algorithms import (
    cyclic_group, cyclic_regular_action, cyclic_trivial_action,
    symmetric_group_s3, enumerate_subgroups, fixed_point_set,
    impossibility_spectrum, is_obstruction_filter, GSet,
    conjugate_subgroup
)


def demo_cyclic_groups():
    """Demonstrate impossibility spectra for cyclic groups."""
    print("=" * 60)
    print("DEMO 1: Cyclic Groups Z/nZ")
    print("=" * 60)

    for n in [2, 3, 4, 6]:
        G = cyclic_group(n)
        subgroups = enumerate_subgroups(G)
        print(f"\nZ/{n}Z has {len(subgroups)} subgroups:")
        for H in subgroups:
            print(f"  {sorted(H)} (order {len(H)})")

        # Regular action vs trivial action on {0}
        X = cyclic_regular_action(n)
        Y_1 = cyclic_trivial_action(n, 1)  # single point, trivial action

        print(f"\n  Source: Z/{n}Z with regular action")
        print(f"  Target: {{0}} with trivial action")

        for H in subgroups:
            fx = fixed_point_set(X, H)
            fy = fixed_point_set(Y_1, H)
            print(f"  H = {sorted(H)}: X^H = {fx}, Y^H = {fy}", end="")
            if fx and not fy:
                print(" → FIXED-POINT OBSTRUCTION")
            elif not fx:
                print(" → No obstruction (empty source fixed points)")
            else:
                print(" → Both nonempty")

        spec = impossibility_spectrum(X, Y_1)
        print(f"\n  Impossibility spectrum: {[sorted(H) for H in spec]}")

        # Verify obstruction filter
        carrier = set(spec)
        valid, msg = is_obstruction_filter(G, carrier, subgroups)
        print(f"  Is obstruction filter? {valid} ({msg})")


def demo_fixed_point_obstruction():
    """Demonstrate the fixed-point obstruction in detail."""
    print("\n" + "=" * 60)
    print("DEMO 2: Fixed-Point Obstruction")
    print("=" * 60)

    # Z/2Z acting on {0,1} by swap vs acting trivially on {0}
    G = cyclic_group(2)
    X = GSet(G, [0, 1], lambda g, x: (g + x) % 2)  # swap action
    Y = GSet(G, [0], lambda g, x: x)  # trivial action on one point

    subgroups = enumerate_subgroups(G)
    print("\nG = Z/2Z")
    print("X = {0, 1} with swap action (g·x = (g+x) mod 2)")
    print("Y = {0} with trivial action")

    for H in subgroups:
        fx = fixed_point_set(X, H)
        fy = fixed_point_set(Y, H)
        print(f"\nH = {sorted(H)}:")
        print(f"  X^H = {fx}")
        print(f"  Y^H = {fy}")

        if fx and not fy:
            print("  → X^H is nonempty but Y^H is empty!")
            print("  → By the fixed-point obstruction theorem,")
            print("    NO H-equivariant map X → Y exists.")
        elif not fx:
            print("  → X^H is empty, so no fixed-point obstruction.")
        else:
            print(f"  → Both nonempty (|X^H| = {len(fx)}, |Y^H| = {len(fy)})")

    spec = impossibility_spectrum(X, Y)
    print(f"\nFull spectrum: {[sorted(H) for H in spec]}")


def demo_upward_closure():
    """Demonstrate the upward closure property."""
    print("\n" + "=" * 60)
    print("DEMO 3: Upward Closure")
    print("=" * 60)

    # Z/6Z with various actions
    G = cyclic_group(6)
    subgroups = enumerate_subgroups(G)

    # X: regular action, Y: trivial on 2 points
    X = cyclic_regular_action(6)
    Y = cyclic_trivial_action(6, 2)

    spec = impossibility_spectrum(X, Y)
    spec_sorted = sorted(spec, key=len)

    print("\nG = Z/6Z")
    print("X = Z/6Z with regular action")
    print("Y = {0, 1} with trivial action")
    print(f"\nSubgroups ({len(subgroups)} total):")
    for H in sorted(subgroups, key=len):
        in_spec = "IN SPECTRUM" if H in set(spec) else "not in spectrum"
        print(f"  {sorted(H)} → {in_spec}")

    print("\nUpward closure check:")
    for i, H in enumerate(spec_sorted):
        for K in subgroups:
            if H.issubset(K) and H != K:
                if K in set(spec):
                    print(f"  {sorted(H)} ⊆ {sorted(K)}: ✓ (both in spectrum)")
                else:
                    print(f"  {sorted(H)} ⊆ {sorted(K)}: ✗ VIOLATION!")


def demo_s3():
    """Demonstrate impossibility spectra for the symmetric group S₃."""
    print("\n" + "=" * 60)
    print("DEMO 4: Symmetric Group S₃")
    print("=" * 60)

    G = symmetric_group_s3()
    subgroups = enumerate_subgroups(G)

    print(f"\nS₃ has {len(subgroups)} subgroups:")
    for H in sorted(subgroups, key=len):
        print(f"  {sorted(H)} (order {len(H)})")

    # S3 acting on {0,1,2} naturally vs on {0,1} by projection
    perms = [
        (0, 1, 2), (1, 0, 2), (2, 1, 0),
        (0, 2, 1), (1, 2, 0), (2, 0, 1),
    ]

    X = GSet(G, [0, 1, 2], lambda g, x: perms[g][x])  # natural action
    Y = GSet(G, [0], lambda g, x: x)  # trivial on one point

    print("\nX = {0,1,2} with natural S₃ action")
    print("Y = {0} with trivial action")

    for H in sorted(subgroups, key=len):
        fx = fixed_point_set(X, H)
        fy = fixed_point_set(Y, H)
        status = ""
        if fx and not fy:
            status = "← OBSTRUCTION"
        print(f"  H = {sorted(H)}: |X^H| = {len(fx)}, |Y^H| = {len(fy)} {status}")

    spec = impossibility_spectrum(X, Y)
    print(f"\nSpectrum: {[sorted(H) for H in sorted(spec, key=len)]}")

    # Verify obstruction filter
    carrier = set(spec)
    valid, msg = is_obstruction_filter(G, carrier, subgroups)
    print(f"Is obstruction filter? {valid} ({msg})")

    # Check conjugation invariance
    print("\nConjugation invariance check:")
    for H in spec:
        for g in G.elements:
            gHg = conjugate_subgroup(G, H, g)
            in_spec = gHg in carrier
            print(f"  conj({sorted(H)}, {g}) = {sorted(gHg)}: {'✓' if in_spec else '✗'}")


def demo_quantitative():
    """Demonstrate the quantitative fixed-point obstruction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Quantitative Fixed-Point Obstruction")
    print("=" * 60)

    G = cyclic_group(4)
    subgroups = enumerate_subgroups(G)

    # X has 4 points with regular action, Y has 3 points with shift mod 4 restricted
    X = cyclic_regular_action(4)
    Y = GSet(G, [0, 1, 2], lambda g, x: x)  # trivial on 3 points

    print("\nG = Z/4Z")
    print("X = Z/4Z with regular action (4 points)")
    print("Y = {0,1,2} with trivial action (3 points)")

    for H in sorted(subgroups, key=len):
        fx = fixed_point_set(X, H)
        fy = fixed_point_set(Y, H)
        print(f"\n  H = {sorted(H)}:")
        print(f"    |X^H| = {len(fx)}, |Y^H| = {len(fy)}")
        if len(fx) > len(fy):
            print(f"    → |X^H| > |Y^H|: No INJECTIVE equivariant map exists!")
        if fx and not fy:
            print(f"    → X^H nonempty, Y^H empty: No equivariant map at all!")


if __name__ == "__main__":
    demo_cyclic_groups()
    demo_fixed_point_obstruction()
    demo_upward_closure()
    demo_s3()
    demo_quantitative()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Impossibility Spectrum as a Hasse Diagram

Plots the subgroup lattice of a finite group with the impossibility spectrum
highlighted. Subgroups in the spectrum are colored red; those outside are green.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    cyclic_group, symmetric_group_s3, enumerate_subgroups,
    impossibility_spectrum, fixed_point_set, GSet
)


def hasse_diagram_positions(subgroups):
    """Compute positions for a Hasse diagram of the subgroup lattice."""
    # Group by order
    by_order = {}
    for H in subgroups:
        order = len(H)
        by_order.setdefault(order, []).append(H)

    orders = sorted(by_order.keys())
    positions = {}
    for i, order in enumerate(orders):
        subs = by_order[order]
        n = len(subs)
        for j, H in enumerate(subs):
            x = (j - (n - 1) / 2) * 1.5
            y = i * 1.5
            positions[H] = (x, y)

    return positions


def draw_spectrum(subgroups, spectrum_set, positions, title, ax):
    """Draw the subgroup lattice with spectrum highlighted."""
    # Draw edges (Hasse diagram: connect H to K if H ⊂ K and no intermediate)
    for H in subgroups:
        for K in subgroups:
            if H != K and H.issubset(K):
                # Check no intermediate
                intermediate = False
                for M in subgroups:
                    if M != H and M != K and H.issubset(M) and M.issubset(K):
                        intermediate = True
                        break
                if not intermediate:
                    x1, y1 = positions[H]
                    x2, y2 = positions[K]
                    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for H in subgroups:
        x, y = positions[H]
        color = '#ff4444' if H in spectrum_set else '#44cc44'
        ax.plot(x, y, 'o', markersize=20, color=color, markeredgecolor='black',
                markeredgewidth=1.5, zorder=5)
        label = f"|H|={len(H)}"
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
                fontweight='bold', zorder=6)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


def main():
    # Example 1: S3 with natural action on {0,1,2} vs trivial on empty
    G = symmetric_group_s3()
    subgroups = enumerate_subgroups(G)

    perms = [
        (0, 1, 2), (1, 0, 2), (2, 1, 0),
        (0, 2, 1), (1, 2, 0), (2, 0, 1),
    ]

    # Create a more interesting example: S3 acting on {0,1,2} naturally
    # vs S3 acting on {0,1,2} by sign (trivial on A3, swap 0,1 on transpositions)
    X = GSet(G, [0, 1, 2], lambda g, x: perms[g][x])

    # Target: two points with sign action
    # (01) swaps 0,1; (02) swaps 0,1; etc. — use trivial on one point
    Y_trivial_1 = GSet(G, [0], lambda g, x: x)

    # Another target: just {0, 1} with action where transpositions swap
    Y_swap = GSet(G, [0, 1], lambda g, x: (1 - x) if g in [1, 2, 3] else x)

    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # Spectrum 1
    spec1 = impossibility_spectrum(X, Y_trivial_1)
    spec1_set = set(spec1)
    pos = hasse_diagram_positions(subgroups)
    draw_spectrum(subgroups, spec1_set, pos,
                  "S₃: {0,1,2} natural → {0} trivial", axes[0])

    # Spectrum 2
    spec2 = impossibility_spectrum(X, Y_swap)
    spec2_set = set(spec2)
    draw_spectrum(subgroups, spec2_set, pos,
                  "S₃: {0,1,2} natural → {0,1} swap", axes[1])

    # Legend
    red_patch = mpatches.Patch(color='#ff4444', label='In spectrum (impossible)')
    green_patch = mpatches.Patch(color='#44cc44', label='Not in spectrum (possible)')
    fig.legend(handles=[red_patch, green_patch], loc='lower center',
               ncol=2, fontsize=11, frameon=True)

    fig.suptitle("Impossibility Spectra on Subgroup Lattices",
                 fontsize=14, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('spectrum_hasse.png', dpi=150, bbox_inches='tight')
    print("Saved spectrum_hasse.png")


if __name__ == "__main__":
    main()
