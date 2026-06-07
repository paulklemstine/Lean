"""
Demo: The Fux Category — Counterpoint as Category Theory

Numerical demonstrations of the main theorems.
"""

from algorithms import *


def demo_partition():
    """Demo 1: Consonant/Dissonant Partition"""
    print("=" * 60)
    print("DEMO 1: Consonant/Dissonant Partition of Z/12Z")
    print("=" * 60)
    cs = consonant_set()
    ds = set(range(12)) - cs
    print(f"Consonant intervals: {sorted(cs)}")
    print(f"  = {{unison(0), m3(3), M3(4), P5(7), m6(8), M6(9)}}")
    print(f"Dissonant intervals: {sorted(ds)}")
    print(f"  = {{m2(1), M2(2), P4(5), tritone(6), m7(10), M7(11)}}")
    print(f"|Consonant| = {len(cs)}, |Dissonant| = {len(ds)}")
    print(f"Partition check: {cs | ds == set(range(12)) and not (cs & ds)}")
    print()


def demo_inversion():
    """Demo 2: Inversion Asymmetry"""
    print("=" * 60)
    print("DEMO 2: The Perfect Fourth Anomaly")
    print("=" * 60)
    cs = consonant_set()
    imperfect = {3, 4, 8, 9}
    print("Interval inversions (n → 12-n mod 12):")
    for n in sorted(cs):
        inv = interval_inversion(n)
        status = "✓ consonant" if inv in cs else "✗ DISSONANT"
        name = {0: "unison", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}[n]
        inv_name = {0: "unison", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
                    6: "tritone", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7"}[inv]
        print(f"  {name}({n}) → {inv_name}({inv}) {status}")
    print(f"\nImperfect consonances {sorted(imperfect)} are closed under inversion: ",
          all(interval_inversion(n) in imperfect for n in imperfect))
    print(f"Full consonant set is NOT closed: P5(7) → P4(5) which is dissonant!")
    print()


def demo_transitions():
    """Demo 3: Transition Counting"""
    print("=" * 60)
    print("DEMO 3: Fux Quiver Transition Counts")
    print("=" * 60)
    valid = enumerate_valid_transitions()
    forbidden = enumerate_forbidden_transitions()
    print(f"Total: {len(valid) + len(forbidden)} = 6×6×4")
    print(f"Valid: {len(valid)}")
    print(f"Forbidden: {len(forbidden)}")
    print(f"\nForbidden transitions (all parallel to perfect consonances):")
    for t in forbidden:
        print(f"  {t.source.name} → {t.target.name} by {t.motion.name}")
    print()


def demo_adjacency():
    """Demo 4: Adjacency Matrix"""
    print("=" * 60)
    print("DEMO 4: Adjacency Matrix (Transition Counts)")
    print("=" * 60)
    matrix = build_adjacency_matrix()
    intervals = list(ConsonantInterval)
    names = ["U", "m3", "M3", "P5", "m6", "M6"]
    print(f"{'':>4}", end="")
    for name in names:
        print(f"{name:>4}", end="")
    print()
    for i, s in enumerate(intervals):
        print(f"{names[i]:>4}", end="")
        for t in intervals:
            print(f"{matrix[(s, t)]:>4}", end="")
        print(f"  | out={outgoing_count(s)}")
    print(f"{'in':>4}", end="")
    for t in intervals:
        print(f"{incoming_count(t):>4}", end="")
    print()
    print(f"\nAll entries are from {{3, 4}}: {set(matrix.values()) == {3, 4}}")
    print(f"3 = transition to perfect consonance (1 motion forbidden)")
    print(f"4 = transition to imperfect consonance (all motions valid)")
    print()


def demo_spectrum():
    """Demo 5: Spectral Completeness"""
    print("=" * 60)
    print("DEMO 5: Consonance Spectrum")
    print("=" * 60)
    cs = consonant_set()
    diffs = difference_set(cs)
    print(f"Consonant set: {sorted(cs)}")
    print(f"Pairwise differences mod 12: {sorted(diffs)}")
    print(f"Covers all of Z/12Z: {diffs == set(range(12))}")
    print(f"\nThis means every interval class appears as a difference")
    print(f"of two consonant intervals — spectral completeness!")
    print()


def demo_composition():
    """Demo 6: Composition Preservation"""
    print("=" * 60)
    print("DEMO 6: Composition Preservation")
    print("=" * 60)
    print("Testing: for all t1, t2 with fuxValid(t2), fuxValid(t1∘t2)")
    result = verify_composition_preservation()
    print(f"Result: {result}")
    print(f"\nKey insight: the ONLY way to produce parallel motion is")
    print(f"parallel ∘ parallel. If t2 is valid and targets a perfect")
    print(f"consonance, then t2's motion ≠ parallel, so the composed")
    print(f"motion can never be parallel. QED.")
    print()


def demo_generation():
    """Demo 7: Generation"""
    print("=" * 60)
    print("DEMO 7: Consonant Set Generates Z/12Z")
    print("=" * 60)
    cs = consonant_set()
    generated = set()
    generated.add(0)
    # Add all sums and differences iteratively
    for _ in range(12):
        new = set()
        for g in generated:
            for c in cs:
                new.add((g + c) % 12)
                new.add((g - c) % 12)
        generated |= new
    print(f"Generated from {sorted(cs)}: {sorted(generated)}")
    print(f"Generates all of Z/12Z: {generated == set(range(12))}")
    print(f"Key: 4 - 3 = 1, and 1 generates Z/12Z")
    print()


def demo_tritone():
    """Demo 8: Tritone Uniqueness"""
    print("=" * 60)
    print("DEMO 8: The Tritone — Unique Self-Inverse Dissonance")
    print("=" * 60)
    cs = consonant_set()
    self_inverse = [n for n in range(12) if interval_inversion(n) == n]
    print(f"Self-inverse intervals (n = -n mod 12): {self_inverse}")
    print(f"Of these, non-zero: {[n for n in self_inverse if n != 0]}")
    print(f"Of these, dissonant: {[n for n in self_inverse if n != 0 and n not in cs]}")
    print(f"→ Only the tritone (6) is non-zero, self-inverse, AND dissonant")
    print()


if __name__ == "__main__":
    demo_partition()
    demo_inversion()
    demo_transitions()
    demo_adjacency()
    demo_spectrum()
    demo_composition()
    demo_generation()
    demo_tritone()


"""
Visualization: The Fux Quiver — Adjacency Structure of Counterpoint

Standalone matplotlib visualization of the Fux quiver's adjacency matrix
and transition structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import cos, sin, pi


def build_adjacency_matrix():
    """Build the 6x6 adjacency matrix."""
    # Consonant intervals: U(0), m3(3), M3(4), P5(7), m6(8), M6(9)
    # Perfect: U, P5 (indices 0, 3)
    # Imperfect: m3, M3, m6, M6 (indices 1, 2, 4, 5)
    matrix = np.zeros((6, 6), dtype=int)
    for i in range(6):
        for j in range(6):
            # Perfect targets (j=0 or j=3): 3 valid motions
            # Imperfect targets: 4 valid motions
            if j in (0, 3):
                matrix[i][j] = 3
            else:
                matrix[i][j] = 4
    return matrix


def plot_adjacency_heatmap():
    """Plot the adjacency matrix as a heatmap."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    matrix = build_adjacency_matrix()
    labels = ['U (0)', 'm3 (3)', 'M3 (4)', 'P5 (7)', 'm6 (8)', 'M6 (9)']
    is_perfect = [True, False, False, True, False, False]

    # Heatmap
    ax = axes[0]
    cmap = plt.cm.RdYlGn
    im = ax.imshow(matrix, cmap=cmap, vmin=2.5, vmax=4.5, aspect='equal')
    ax.set_xticks(range(6))
    ax.set_yticks(range(6))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_yticklabels(labels, fontsize=9)
    ax.set_xlabel('Target Interval', fontsize=11)
    ax.set_ylabel('Source Interval', fontsize=11)
    ax.set_title('Fux Quiver Adjacency Matrix\n(Valid Motion Types per Transition)', fontsize=12)

    for i in range(6):
        for j in range(6):
            color = 'white' if matrix[i][j] == 3 else 'black'
            ax.text(j, i, str(matrix[i][j]), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    # Add perfect/imperfect markers
    for i, (label, perf) in enumerate(zip(labels, is_perfect)):
        if perf:
            ax.add_patch(mpatches.Rectangle((i-0.5, -0.5), 1, 6, linewidth=2,
                                              edgecolor='red', facecolor='none', linestyle='--'))

    plt.colorbar(im, ax=ax, label='Valid motion types', ticks=[3, 4])

    # Quiver graph
    ax = axes[1]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title('Fux Quiver Graph\n(6 consonant intervals, 132 edges)', fontsize=12)
    ax.axis('off')

    # Place nodes on a circle
    n = 6
    angles = [pi/2 - 2*pi*i/n for i in range(n)]
    xs = [1.3 * cos(a) for a in angles]
    ys = [1.3 * sin(a) for a in angles]
    colors = ['#e74c3c' if p else '#3498db' for p in is_perfect]
    short_labels = ['U', 'm3', 'M3', 'P5', 'm6', 'M6']

    # Draw edges (curved)
    for i in range(n):
        for j in range(n):
            count = matrix[i][j]
            if i == j:
                # Self-loop
                loop_r = 0.2
                theta = angles[i]
                cx = xs[i] + loop_r * cos(theta) * 1.5
                cy = ys[i] + loop_r * sin(theta) * 1.5
                circle = mpatches.Circle((cx, cy), loop_r, fill=False,
                                          edgecolor='gray', alpha=0.4, linewidth=0.5)
                ax.add_patch(circle)
            else:
                alpha = 0.15 if count == 3 else 0.25
                width = 0.8 if count == 3 else 1.2
                ax.annotate('', xy=(xs[j], ys[j]), xytext=(xs[i], ys[i]),
                           arrowprops=dict(arrowstyle='->', color='gray',
                                          alpha=alpha, lw=width,
                                          connectionstyle=f'arc3,rad=0.15'))

    # Draw nodes
    for i in range(n):
        circle = mpatches.Circle((xs[i], ys[i]), 0.2, facecolor=colors[i],
                                  edgecolor='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(xs[i], ys[i], short_labels[i], ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)

    # Legend
    ax.add_patch(mpatches.Circle((0.8, -1.5), 0.1, facecolor='#e74c3c', edgecolor='black'))
    ax.text(1.0, -1.5, 'Perfect', va='center', fontsize=9)
    ax.add_patch(mpatches.Circle((0.8, -1.7), 0.1, facecolor='#3498db', edgecolor='black'))
    ax.text(1.0, -1.7, 'Imperfect', va='center', fontsize=9)

    plt.tight_layout()
    plt.savefig('fux_quiver.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fux_quiver.png")


def plot_inversion_diagram():
    """Plot the interval inversion showing the asymmetry."""
    fig, ax = plt.subplots(figsize=(10, 6))

    intervals = list(range(12))
    names = ['U', 'm2', 'M2', 'm3', 'M3', 'P4', 'TT', 'P5', 'm6', 'M6', 'm7', 'M7']
    consonant = {0, 3, 4, 7, 8, 9}

    # Draw circle of intervals
    for i in intervals:
        angle = pi/2 - 2*pi*i/12
        x = 2 * cos(angle)
        y = 2 * sin(angle)

        color = '#27ae60' if i in consonant else '#e74c3c'
        circle = mpatches.Circle((x, y), 0.25, facecolor=color, edgecolor='black',
                                  linewidth=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f'{names[i]}\n({i})', ha='center', va='center',
                fontsize=7, fontweight='bold', color='white', zorder=6)

    # Draw inversion arrows for consonant intervals
    for n in sorted(consonant):
        inv = (12 - n) % 12
        if n <= inv and n != inv:  # Avoid drawing both directions
            a1 = pi/2 - 2*pi*n/12
            a2 = pi/2 - 2*pi*inv/12
            x1, y1 = 1.7*cos(a1), 1.7*sin(a1)
            x2, y2 = 1.7*cos(a2), 1.7*sin(a2)

            style = 'solid' if inv in consonant else 'dashed'
            color = '#2980b9' if inv in consonant else '#c0392b'
            ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle='<->', color=color,
                                      lw=2, linestyle=style,
                                      connectionstyle='arc3,rad=0.3'))

    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Interval Inversion in ℤ/12ℤ\nGreen = consonant, Red = dissonant\n'
                 'Solid arrows = both consonant, Dashed = asymmetry (P5↔P4)',
                 fontsize=12)

    plt.tight_layout()
    plt.savefig('inversion_asymmetry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved inversion_asymmetry.png")


if __name__ == "__main__":
    plot_adjacency_heatmap()
    plot_inversion_diagram()
