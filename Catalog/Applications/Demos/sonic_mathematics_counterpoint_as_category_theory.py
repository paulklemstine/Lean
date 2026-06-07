#!/usr/bin/env python3
"""
Counterpoint as Category Theory: Interactive Demo

Demonstrates the algebraic structure of consonant intervals in ℤ/12ℤ
and the voice-leading rules of first-species counterpoint.
"""

# Consonant intervals in semitones (mod 12)
CONSONANT = {0, 3, 4, 7, 8, 9}
DISSONANT = {1, 2, 5, 6, 10, 11}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

INTERVAL_NAMES = {
    0: "Unison (P1)",
    1: "Minor 2nd (m2)",
    2: "Major 2nd (M2)",
    3: "Minor 3rd (m3)",
    4: "Major 3rd (M3)",
    5: "Perfect 4th (P4)",
    6: "Tritone (A4/d5)",
    7: "Perfect 5th (P5)",
    8: "Minor 6th (m6)",
    9: "Major 6th (M6)",
    10: "Minor 7th (m7)",
    11: "Major 7th (M7)",
}


def invert(i: int) -> int:
    """Octave complement (inversion) of an interval."""
    return (12 - i) % 12


def demo_consonance_partition():
    """Demonstrate the consonance/dissonance partition of ℤ/12ℤ."""
    print("=" * 60)
    print("CONSONANCE-DISSONANCE PARTITION OF ℤ/12ℤ")
    print("=" * 60)
    print()
    for i in range(12):
        status = "CONSONANT" if i in CONSONANT else "DISSONANT"
        kind = ""
        if i in PERFECT:
            kind = " [Perfect]"
        elif i in IMPERFECT:
            kind = " [Imperfect]"
        print(f"  {i:2d} semitones = {INTERVAL_NAMES[i]:20s} → {status}{kind}")
    print(f"\n  |Consonant| = {len(CONSONANT)}, |Dissonant| = {len(DISSONANT)}")
    print(f"  Union = {sorted(CONSONANT | DISSONANT)}")
    print(f"  Intersection = {sorted(CONSONANT & DISSONANT)}")


def demo_inversion_asymmetry():
    """Demonstrate the fourth-fifth asymmetry."""
    print("\n" + "=" * 60)
    print("INVERSION SYMMETRY ANALYSIS")
    print("=" * 60)
    print()
    print("Inversion map ι(i) = 12 - i (mod 12):")
    print()

    consonant_image = {invert(i) for i in CONSONANT}
    print("  Consonant intervals and their inversions:")
    for i in sorted(CONSONANT):
        inv = invert(i)
        inv_status = "✓ consonant" if inv in CONSONANT else "✗ DISSONANT"
        print(f"    {INTERVAL_NAMES[i]:20s} → {INTERVAL_NAMES[inv]:20s} {inv_status}")

    print(f"\n  ι(C) = {sorted(consonant_image)}")
    print(f"  C    = {sorted(CONSONANT)}")
    print(f"  ι(C) = C? {'YES' if consonant_image == CONSONANT else 'NO — ASYMMETRY!'}")

    # Find the unique broken element
    print("\n  Dissonant intervals with consonant inversions:")
    broken = []
    for d in sorted(DISSONANT):
        if invert(d) in CONSONANT:
            broken.append(d)
            print(f"    {INTERVAL_NAMES[d]:20s} → {INTERVAL_NAMES[invert(d)]}")
    print(f"  Unique defect: {INTERVAL_NAMES[broken[0]]} (the only one!)")


def demo_generation():
    """Demonstrate that {3, 4} generates ℤ/12ℤ."""
    print("\n" + "=" * 60)
    print("CHROMATIC GENERATION BY THIRDS")
    print("=" * 60)
    print()
    print("Question: Can minor 3rd (3) and major 3rd (4) generate all of ℤ/12ℤ?")
    print(f"  gcd(3, 4) = 1, so YES — they generate everything!")
    print()
    print("Constructive decomposition of each pitch class:")
    for target in range(12):
        # Find a, b with 3a + 4b ≡ target (mod 12)
        found = False
        for a in range(-6, 7):
            for b in range(-6, 7):
                if (3 * a + 4 * b) % 12 == target:
                    sign_a = "+" if a >= 0 else "-"
                    sign_b = "+" if b >= 0 else "-"
                    if a >= 0:
                        expr = f"{a}×m3 + {b}×M3" if b >= 0 else f"{a}×m3 - {-b}×M3"
                    else:
                        expr = f"-{-a}×m3 + {b}×M3" if b >= 0 else f"-{-a}×m3 - {-b}×M3"
                    print(f"  {target:2d} = {expr:20s}  (= {3*a} + {4*b} mod 12)")
                    found = True
                    break
            if found:
                break


def demo_voice_leading():
    """Demonstrate valid voice leadings between consonant intervals."""
    print("\n" + "=" * 60)
    print("VOICE LEADING TRANSITION TABLE")
    print("=" * 60)
    print()
    print("For each pair (i → j) of consonant intervals,")
    print("show a valid voice leading (stepUpper, stepLower):")
    print()

    cons = sorted(CONSONANT)
    header = "From\\To  " + "  ".join(f"{INTERVAL_NAMES[j][:4]:>4s}" for j in cons)
    print(f"  {header}")
    print("  " + "-" * len(header))

    for i in cons:
        row = f"  {INTERVAL_NAMES[i][:4]:>4s}    "
        for j in cons:
            # Use oblique motion: (j-i, 0)
            step = (j - i) % 12
            row += f"({step:2d},0) "
        print(row)

    print("\n  All entries are valid (oblique motion with stationary bass).")
    print("  This proves the transition graph is COMPLETE.")


def demo_parallel_restriction():
    """Demonstrate the parallel motion restriction."""
    print("\n" + "=" * 60)
    print("PARALLEL MOTION ANALYSIS")
    print("=" * 60)
    print()
    print("Parallel motion (stepUpper = stepLower) at each consonant interval:")
    print()
    for i in sorted(CONSONANT):
        if i in PERFECT:
            status = "❌ FORBIDDEN (except stationary)"
            reason = "parallel perfect consonance"
        else:
            status = "✅ ALLOWED"
            reason = "imperfect consonance"
        print(f"  {INTERVAL_NAMES[i]:20s}: {status} — {reason}")


def demo_tension_poset():
    """Demonstrate the tension partial order."""
    print("\n" + "=" * 60)
    print("TENSION PARTIAL ORDER")
    print("=" * 60)
    print()
    tension = {0: 0, 7: 1, 3: 2, 4: 2, 8: 2, 9: 2}
    level_names = {0: "Stable (ground)", 1: "Stable (dominant)", 2: "Mobile (driving)"}

    for level in range(3):
        members = [i for i in sorted(CONSONANT) if tension[i] == level]
        names = ", ".join(INTERVAL_NAMES[i] for i in members)
        print(f"  Level {level} — {level_names[level]}:")
        print(f"    {names}")
        print(f"    Count: {len(members)}")
        print()

    print("  Hasse diagram: Unison → Fifth → {m3, M3, m6, M6}")
    print("  Poset type: ordinal sum 1 + 1 + 4")


def demo_consonant_sum():
    """Demonstrate the consonant sum property."""
    print("\n" + "=" * 60)
    print("ARITHMETIC CENTER OF CONSONANCE")
    print("=" * 60)
    print()
    total = sum(CONSONANT)
    print(f"  Sum of consonant intervals: {' + '.join(str(i) for i in sorted(CONSONANT))} = {total}")
    print(f"  Modulo 12: {total} mod 12 = {total % 12}")
    print(f"  The center of consonance is the {INTERVAL_NAMES[total % 12]}!")
    print(f"  (The interval that structures the circle of fifths)")


if __name__ == "__main__":
    demo_consonance_partition()
    demo_inversion_asymmetry()
    demo_generation()
    demo_voice_leading()
    demo_parallel_restriction()
    demo_tension_poset()
    demo_consonant_sum()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Consonant Intervals on the Chromatic Circle

Shows the 12 pitch classes arranged in a circle, with consonant intervals
highlighted and inversion pairs connected by arcs.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_chromatic_circle():
    """Draw the chromatic circle with consonance analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    CONSONANT = {0, 3, 4, 7, 8, 9}
    PERFECT = {0, 7}
    IMPERFECT = {3, 4, 8, 9}

    NAMES = ['C/P1', 'm2', 'M2', 'm3', 'M3', 'P4',
             'TT', 'P5', 'm6', 'M6', 'm7', 'M7']

    # Plot 1: Consonance on the chromatic circle
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_title('Consonant Intervals in ℤ/12ℤ', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Draw circle
    theta = np.linspace(0, 2 * np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=1)

    # Place intervals
    for i in range(12):
        angle = np.pi / 2 - 2 * np.pi * i / 12
        x, y = 1.0 * np.cos(angle), 1.0 * np.sin(angle)
        lx, ly = 1.35 * np.cos(angle), 1.35 * np.sin(angle)

        if i in PERFECT:
            color = '#2196F3'
            size = 300
        elif i in IMPERFECT:
            color = '#4CAF50'
            size = 250
        else:
            color = '#E0E0E0'
            size = 150

        ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        ax.text(lx, ly, NAMES[i], ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw inversion pairs
    inv_pairs = [(3, 9), (4, 8)]
    for a, b in inv_pairs:
        angle_a = np.pi / 2 - 2 * np.pi * a / 12
        angle_b = np.pi / 2 - 2 * np.pi * b / 12
        xa, ya = 0.85 * np.cos(angle_a), 0.85 * np.sin(angle_a)
        xb, yb = 0.85 * np.cos(angle_b), 0.85 * np.sin(angle_b)
        ax.annotate('', xy=(xb, yb), xytext=(xa, ya),
                     arrowprops=dict(arrowstyle='<->', color='#FF9800', lw=2))

    # Draw the broken pair (5, 7)
    for val, c in [(5, '#F44336'), (7, '#2196F3')]:
        angle = np.pi / 2 - 2 * np.pi * val / 12
        xa, ya = 0.85 * np.cos(angle), 0.85 * np.sin(angle)
    angle_5 = np.pi / 2 - 2 * np.pi * 5 / 12
    angle_7 = np.pi / 2 - 2 * np.pi * 7 / 12
    x5, y5 = 0.85 * np.cos(angle_5), 0.85 * np.sin(angle_5)
    x7, y7 = 0.85 * np.cos(angle_7), 0.85 * np.sin(angle_7)
    ax.annotate('', xy=(x5, y5), xytext=(x7, y7),
                 arrowprops=dict(arrowstyle='<->', color='#F44336', lw=2, linestyle='dashed'))

    # Legend
    ax.scatter([], [], c='#2196F3', s=100, label='Perfect consonance', edgecolors='black')
    ax.scatter([], [], c='#4CAF50', s=100, label='Imperfect consonance', edgecolors='black')
    ax.scatter([], [], c='#E0E0E0', s=100, label='Dissonant', edgecolors='black')
    ax.plot([], [], '-', color='#FF9800', lw=2, label='Inversion pair (both consonant)')
    ax.plot([], [], '--', color='#F44336', lw=2, label='Broken pair (P5↔P4)')
    ax.legend(loc='lower center', fontsize=8, ncol=2)

    # Plot 2: Tension Poset
    ax2 = axes[1]
    ax2.set_xlim(-2, 6)
    ax2.set_ylim(-0.5, 3.5)
    ax2.set_title('Tension Poset: 1 + 1 + 4', fontsize=14, fontweight='bold')
    ax2.axis('off')

    # Level 0: Unison
    ax2.scatter([2], [0], s=400, c='#2196F3', zorder=5, edgecolors='black', linewidth=2)
    ax2.text(2, -0.35, 'Unison (0)\nτ = 0', ha='center', fontsize=9)

    # Level 1: Fifth
    ax2.scatter([2], [1.2], s=400, c='#2196F3', zorder=5, edgecolors='black', linewidth=2)
    ax2.text(2, 0.85, 'Fifth (7)\nτ = 1', ha='center', fontsize=9)

    # Level 2: Imperfect consonances
    imp_x = [0.5, 1.5, 2.5, 3.5]
    imp_labels = ['m3 (3)', 'M3 (4)', 'm6 (8)', 'M6 (9)']
    for x, label in zip(imp_x, imp_labels):
        ax2.scatter([x], [2.5], s=350, c='#4CAF50', zorder=5, edgecolors='black', linewidth=2)
        ax2.text(x, 2.9, label, ha='center', fontsize=8)
    ax2.text(2, 2.15, 'τ = 2 (mobile)', ha='center', fontsize=9, fontstyle='italic')

    # Hasse edges
    ax2.plot([2, 2], [0.15, 1.05], 'k-', linewidth=2)
    for x in imp_x:
        ax2.plot([2, x], [1.35, 2.35], 'k-', linewidth=1.5, alpha=0.6)

    # Annotations
    ax2.text(2.2, 0.6, '≤', fontsize=14, fontweight='bold')
    ax2.text(0.3, 1.8, '≤', fontsize=12, rotation=55)

    plt.tight_layout()
    plt.savefig('counterpoint_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: counterpoint_analysis.png")


if __name__ == "__main__":
    draw_chromatic_circle()


#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph

Shows the directed graph of permitted voice-leading transitions between
consonant intervals, with edge weights indicating the number of valid
voice leadings for each transition.
"""

import matplotlib.pyplot as plt
import numpy as np


def compute_morphism_counts():
    """Compute the number of valid voice leadings between each pair."""
    CONSONANT = [0, 3, 4, 7, 8, 9]
    PERFECT = {0, 7}
    n = 12

    counts = {}
    for i in CONSONANT:
        for j in CONSONANT:
            count = 0
            target_change = (j - i) % n
            for su in range(n):
                sl = (su - target_change) % n
                is_parallel = (su == sl)
                is_stationary = (su == 0 and sl == 0)
                if j in PERFECT and is_parallel and not is_stationary:
                    continue
                count += 1
            counts[(i, j)] = count
    return counts


def draw_transition_graph():
    """Draw the counterpoint transition graph."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    CONSONANT = [0, 3, 4, 7, 8, 9]
    NAMES = {0: 'P1', 3: 'm3', 4: 'M3', 7: 'P5', 8: 'm6', 9: 'M6'}
    PERFECT = {0, 7}
    counts = compute_morphism_counts()

    # Plot 1: Transition graph
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_title('Counterpoint Transition Graph\n(edge labels = morphism count)',
                  fontsize=12, fontweight='bold')
    ax.axis('off')

    # Position nodes in a hexagon
    positions = {}
    for idx, interval in enumerate(CONSONANT):
        angle = np.pi / 2 - 2 * np.pi * idx / 6
        positions[interval] = (1.2 * np.cos(angle), 1.2 * np.sin(angle))

    # Draw edges (skip self-loops for clarity)
    for i in CONSONANT:
        for j in CONSONANT:
            if i == j:
                continue
            xi, yi = positions[i]
            xj, yj = positions[j]
            # Offset slightly to show bidirectional
            dx, dy = xj - xi, yj - yi
            length = np.sqrt(dx**2 + dy**2)
            nx, ny = -dy / length * 0.05, dx / length * 0.05

            count = counts[(i, j)]
            color = '#2196F3' if j in PERFECT else '#4CAF50'
            alpha = 0.3

            ax.annotate('', xy=(xj - dx * 0.15 + nx, yj - dy * 0.15 + ny),
                         xytext=(xi + dx * 0.15 + nx, yi + dy * 0.15 + ny),
                         arrowprops=dict(arrowstyle='->', color=color, alpha=alpha, lw=1))

    # Draw nodes
    for interval in CONSONANT:
        x, y = positions[interval]
        color = '#2196F3' if interval in PERFECT else '#4CAF50'
        ax.scatter(x, y, s=600, c=color, zorder=10, edgecolors='black', linewidth=2)
        ax.text(x, y, NAMES[interval], ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=11)

        # Self-loop count
        self_count = counts[(interval, interval)]
        ax.text(x, y - 0.3, f'({self_count})', ha='center', fontsize=7, color='gray')

    # Plot 2: Morphism count heatmap
    ax2 = axes[1]
    matrix = np.array([[counts[(i, j)] for j in CONSONANT] for i in CONSONANT])
    im = ax2.imshow(matrix, cmap='YlGnBu', aspect='equal')
    ax2.set_xticks(range(6))
    ax2.set_yticks(range(6))
    ax2.set_xticklabels([NAMES[c] for c in CONSONANT])
    ax2.set_yticklabels([NAMES[c] for c in CONSONANT])
    ax2.set_xlabel('Target interval', fontsize=11)
    ax2.set_ylabel('Source interval', fontsize=11)
    ax2.set_title('Morphism Count Matrix\n|Hom(i, j)|', fontsize=12, fontweight='bold')

    for i in range(6):
        for j in range(6):
            color = 'white' if matrix[i, j] > 10 else 'black'
            ax2.text(j, i, str(matrix[i, j]), ha='center', va='center',
                     fontsize=10, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax2, shrink=0.8)

    plt.tight_layout()
    plt.savefig('transition_graph.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: transition_graph.png")


if __name__ == "__main__":
    draw_transition_graph()
