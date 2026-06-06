#!/usr/bin/env python3
"""
Counterpoint Category Theory — Demonstrations

Demonstrates the key mathematical results about first-species counterpoint
formalized as a categorical structure.
"""

# Consonant intervals in semitones
CONSONANT = {0, 3, 4, 7, 8, 9}
DISSONANT = {1, 2, 5, 6, 10, 11}
INTERVAL_NAMES = {
    0: "Unison", 1: "m2", 2: "M2", 3: "m3", 4: "M3", 5: "P4",
    6: "Tritone", 7: "P5", 8: "m6", 9: "M6", 10: "m7", 11: "M7"
}
CONSONANT_NAMES = {k: INTERVAL_NAMES[k] for k in sorted(CONSONANT)}

def demo_partition():
    """Demo 1: Consonance-Dissonance Partition"""
    print("=" * 60)
    print("Demo 1: Consonance-Dissonance Partition of Z/12Z")
    print("=" * 60)
    print(f"Consonant (6): {sorted(CONSONANT)} = {[INTERVAL_NAMES[i] for i in sorted(CONSONANT)]}")
    print(f"Dissonant (6): {sorted(DISSONANT)} = {[INTERVAL_NAMES[i] for i in sorted(DISSONANT)]}")
    print(f"Union = Z/12Z: {sorted(CONSONANT | DISSONANT) == list(range(12))}")
    print(f"Disjoint: {CONSONANT & DISSONANT == set()}")
    print()

def demo_inversion_asymmetry():
    """Demo 2: Inversion Asymmetry"""
    print("=" * 60)
    print("Demo 2: Inversion Asymmetry")
    print("=" * 60)
    print("Interval negation (i -> 12 - i mod 12):")
    for i in sorted(CONSONANT):
        neg = (12 - i) % 12
        status = "✓ consonant" if neg in CONSONANT else "✗ DISSONANT"
        print(f"  neg({i:2d} = {INTERVAL_NAMES[i]:>7s}) = {neg:2d} = {INTERVAL_NAMES[neg]:>7s}  {status}")
    print()
    print("KEY FINDING: The consonant set is NOT inversion-closed!")
    print("Failure point: P5 (7) -> P4 (5), which is dissonant in counterpoint.")
    print()
    
    # Imperfect consonances ARE closed
    imperfect = {3, 4, 8, 9}
    print("Imperfect consonances {3, 4, 8, 9}:")
    for i in sorted(imperfect):
        neg = (12 - i) % 12
        print(f"  neg({i}) = {neg}  {'✓' if neg in imperfect else '✗'}")
    print("Imperfect consonances ARE inversion-closed.")
    print()

def demo_non_subgroup():
    """Demo 3: Non-Subgroup Theorem"""
    print("=" * 60)
    print("Demo 3: Non-Subgroup Theorem")
    print("=" * 60)
    print("Testing closure of consonant set under addition mod 12:")
    failures = []
    for a in sorted(CONSONANT):
        for b in sorted(CONSONANT):
            s = (a + b) % 12
            if s not in CONSONANT:
                failures.append((a, b, s))
    print(f"  Found {len(failures)} closure failures:")
    for a, b, s in failures[:5]:
        print(f"    {INTERVAL_NAMES[a]} + {INTERVAL_NAMES[b]} = {s} = {INTERVAL_NAMES[s]} (DISSONANT)")
    if len(failures) > 5:
        print(f"    ... and {len(failures) - 5} more")
    print()
    print("KEY FINDING: The consonant set is NOT an additive subgroup of Z/12Z.")
    print("Most striking: m3 + m3 = 3 + 3 = 6 = Tritone (diabolus in musica)")
    print()

def demo_consonant_sum():
    """Demo 4: Consonant Sum"""
    print("=" * 60)
    print("Demo 4: Consonant Sum = Perfect Fifth")
    print("=" * 60)
    total = sum(CONSONANT)
    print(f"Sum of consonant intervals: {' + '.join(str(i) for i in sorted(CONSONANT))} = {total}")
    print(f"Mod 12: {total} mod 12 = {total % 12} = {INTERVAL_NAMES[total % 12]}")
    print("The 'center of mass' of consonance is the perfect fifth!")
    print()

def demo_reachability():
    """Demo 5: Universal Reachability (Anti-Poset)"""
    print("=" * 60)
    print("Demo 5: Universal Reachability via Oblique Motion")
    print("=" * 60)
    consonant_list = sorted(CONSONANT)
    print("Voice leading from interval a to interval b via oblique motion:")
    print("(lower voice stays at 0, upper voice moves by b - a)")
    print()
    print(f"{'From':>8s} -> {'To':>8s} : lower_step, upper_step")
    for a in consonant_list:
        for b in consonant_list:
            if a != b:
                d = b - a  # upper step (lower stays at 0)
                print(f"  {INTERVAL_NAMES[a]:>7s} -> {INTERVAL_NAMES[b]:>7s} : 0, {d:+d}")
    print()
    print("ALL transitions possible => relation is FULL => NOT a partial order")
    print("CONJECTURE DISPROVED: Counterpoint ≠ poset-generated thin category")
    print()

def demo_consonance_rank():
    """Demo 6: Consonance Hierarchy"""
    print("=" * 60)
    print("Demo 6: Consonance Hierarchy (Acoustic Simplicity)")
    print("=" * 60)
    ranking = [
        ("Unison", "1:1", 6, True),
        ("P5", "3:2", 5, True),
        ("M3", "5:4", 4, False),
        ("m3", "6:5", 3, False),
        ("M6", "5:3", 2, False),
        ("m6", "8:5", 1, False),
    ]
    print(f"{'Interval':>10s}  {'Ratio':>5s}  {'Rank':>4s}  {'Type':>10s}")
    print("-" * 35)
    for name, ratio, rank, perfect in ranking:
        t = "Perfect" if perfect else "Imperfect"
        print(f"{name:>10s}  {ratio:>5s}  {rank:>4d}  {t:>10s}")
    print()
    print("Perfect consonances (rank ≥ 5) are restricted in counterpoint.")
    print("Imperfect consonances (rank ≤ 4) move freely.")
    print()

def demo_voice_leading_count():
    """Demo 7: Voice Leading Enumeration"""
    print("=" * 60)
    print("Demo 7: Valid Voice Leadings (step bound = 7)")
    print("=" * 60)
    B = 7  # one octave
    perfect = {0, 7}
    consonant_list = sorted(CONSONANT)
    
    counts = {}
    for a in consonant_list:
        for b in consonant_list:
            count = 0
            for dl in range(-B, B + 1):
                for du in range(-B, B + 1):
                    if (du - dl) % 12 == (b - a) % 12:
                        # Check validity: no parallel to perfect
                        is_parallel = (dl == du and dl != 0)
                        if not (b in perfect and is_parallel):
                            count += 1
            counts[(a, b)] = count
    
    print(f"{'':>8s}", end="")
    for b in consonant_list:
        print(f"  {INTERVAL_NAMES[b]:>5s}", end="")
    print()
    for a in consonant_list:
        print(f"{INTERVAL_NAMES[a]:>7s}:", end="")
        for b in consonant_list:
            c = counts[(a, b)]
            print(f"  {c:>5d}", end="")
        print()
    print()
    print("Note: Diagonal entries for perfect consonances (Unison, P5)")
    print("are REDUCED compared to imperfect consonances due to the")
    print("parallel motion prohibition.")
    print()

if __name__ == "__main__":
    demo_partition()
    demo_inversion_asymmetry()
    demo_non_subgroup()
    demo_consonant_sum()
    demo_reachability()
    demo_consonance_rank()
    demo_voice_leading_count()
    print("=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Consonance on the Chromatic Circle

Shows the 12 pitch-class intervals on a circle, highlighting consonant vs dissonant,
and the inversion symmetry (broken at the fifth-fourth boundary).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    n = 12
    names = ["Unison", "m2", "M2", "m3", "M3", "P4",
             "Tritone", "P5", "m6", "M6", "m7", "M7"]
    consonant = {0, 3, 4, 7, 8, 9}
    perfect = {0, 7}
    
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) - np.pi / 2
    x = np.cos(angles)
    y = np.sin(angles)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left: consonance/dissonance partition
    ax1.set_xlim(-1.8, 1.8)
    ax1.set_ylim(-1.8, 1.8)
    ax1.set_aspect('equal')
    ax1.set_title('Consonance-Dissonance Partition\nof the Chromatic Circle', fontsize=14)
    
    # Draw circle outline
    theta = np.linspace(0, 2 * np.pi, 100)
    ax1.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, lw=0.5)
    
    for i in range(n):
        if i in perfect:
            color, ec, sz = 'gold', 'darkgoldenrod', 0.15
        elif i in consonant:
            color, ec, sz = 'lightblue', 'steelblue', 0.13
        else:
            color, ec, sz = 'lightcoral', 'darkred', 0.11
        circle = plt.Circle((x[i], y[i]), sz, color=color, ec=ec, lw=2, zorder=5)
        ax1.add_patch(circle)
        # Label outside
        lx, ly = x[i] * 1.4, y[i] * 1.4
        ax1.text(lx, ly, f"{i}\n{names[i]}", ha='center', va='center', fontsize=8)
    
    import matplotlib.patches as mpatches
    p1 = mpatches.Patch(color='gold', label='Perfect consonance')
    p2 = mpatches.Patch(color='lightblue', label='Imperfect consonance')
    p3 = mpatches.Patch(color='lightcoral', label='Dissonance')
    ax1.legend(handles=[p1, p2, p3], loc='lower right', fontsize=9)
    ax1.axis('off')
    
    # Right: inversion arrows
    ax2.set_xlim(-1.8, 1.8)
    ax2.set_ylim(-1.8, 1.8)
    ax2.set_aspect('equal')
    ax2.set_title('Interval Inversion (i → 12-i mod 12)\nBroken Symmetry at P5 ↔ P4', fontsize=14)
    
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, lw=0.5)
    
    # Draw nodes
    for i in range(n):
        if i in consonant:
            color, ec = ('gold' if i in perfect else 'lightblue'), ('darkgoldenrod' if i in perfect else 'steelblue')
        else:
            color, ec = 'lightcoral', 'darkred'
        circle = plt.Circle((x[i], y[i]), 0.12, color=color, ec=ec, lw=2, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x[i] * 1.35, y[i] * 1.35, f"{i}", ha='center', va='center', fontsize=9)
    
    # Draw inversion arrows for consonant intervals
    drawn = set()
    for i in sorted(consonant):
        j = (12 - i) % 12
        if (min(i, j), max(i, j)) in drawn:
            continue
        drawn.add((min(i, j), max(i, j)))
        if i == j:
            continue
        
        # Arrow from i to j
        both_consonant = (j in consonant)
        color = 'green' if both_consonant else 'red'
        style = '->' if both_consonant else '->'
        lw = 2 if both_consonant else 3
        
        mid_x = (x[i] + x[j]) / 2
        mid_y = (y[i] + y[j]) / 2
        
        ax2.annotate("", xy=(x[j] * 0.85, y[j] * 0.85),
                     xytext=(x[i] * 0.85, y[i] * 0.85),
                     arrowprops=dict(arrowstyle='<->', color=color, lw=lw,
                                    connectionstyle='arc3,rad=0'))
        
        label = "✓" if both_consonant else "✗"
        ax2.text(mid_x * 0.6, mid_y * 0.6, label, ha='center', va='center',
                fontsize=14, color=color, fontweight='bold')
    
    ax2.text(0, -1.65, "Green: both endpoints consonant (inversion preserves consonance)\n"
             "Red: one endpoint dissonant (inversion breaks consonance)",
             ha='center', va='center', fontsize=8, style='italic')
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('viz_consonance_circle.png', dpi=150, bbox_inches='tight')
    print("Saved viz_consonance_circle.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph

Shows the directed graph of valid voice leadings between consonant intervals,
with edge weights indicating the number of valid voice leadings (step bound = 7).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def compute_transition_matrix(step_bound=7):
    """Compute the 6x6 transition count matrix."""
    consonant = [0, 3, 4, 7, 8, 9]
    perfect = {0, 7}
    n = len(consonant)
    matrix = np.zeros((n, n), dtype=int)
    
    for i, a in enumerate(consonant):
        for j, b in enumerate(consonant):
            count = 0
            for dl in range(-step_bound, step_bound + 1):
                for du in range(-step_bound, step_bound + 1):
                    if (du - dl) % 12 == (b - a) % 12:
                        is_parallel = (dl == du and dl != 0)
                        if not (b in perfect and is_parallel):
                            count += 1
            matrix[i, j] = count
    return matrix

def main():
    names = ["Unison", "m3", "M3", "P5", "m6", "M6"]
    consonant = [0, 3, 4, 7, 8, 9]
    is_perfect = [True, False, False, True, False, False]
    
    matrix = compute_transition_matrix(7)
    
    # Position nodes in a circle
    n = len(names)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) - np.pi / 2
    x = np.cos(angles) * 2
    y = np.sin(angles) * 2
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left panel: transition graph
    ax1.set_xlim(-3.5, 3.5)
    ax1.set_ylim(-3.5, 3.5)
    ax1.set_aspect('equal')
    ax1.set_title('Counterpoint Transition Graph\n(Valid Voice Leadings, |step| ≤ 7)', fontsize=14)
    
    # Draw edges with width proportional to count
    max_count = matrix.max()
    for i in range(n):
        for j in range(n):
            if i != j and matrix[i, j] > 0:
                w = matrix[i, j] / max_count * 3
                alpha = 0.3 + 0.5 * (matrix[i, j] / max_count)
                color = 'red' if (is_perfect[i] and is_perfect[j]) else 'steelblue'
                ax1.annotate("", xy=(x[j], y[j]), xytext=(x[i], y[i]),
                    arrowprops=dict(arrowstyle='->', color=color, lw=w, alpha=alpha,
                                   connectionstyle='arc3,rad=0.15'))
    
    # Draw nodes
    for i in range(n):
        color = 'gold' if is_perfect[i] else 'lightblue'
        edge_color = 'darkgoldenrod' if is_perfect[i] else 'steelblue'
        circle = plt.Circle((x[i], y[i]), 0.35, color=color, ec=edge_color, lw=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x[i], y[i], names[i], ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)
    
    perfect_patch = mpatches.Patch(color='gold', label='Perfect consonance')
    imperfect_patch = mpatches.Patch(color='lightblue', label='Imperfect consonance')
    ax1.legend(handles=[perfect_patch, imperfect_patch], loc='lower right', fontsize=9)
    ax1.axis('off')
    
    # Right panel: transition matrix heatmap
    im = ax2.imshow(matrix, cmap='YlOrRd', interpolation='nearest')
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(names, rotation=45, ha='right')
    ax2.set_yticklabels(names)
    ax2.set_xlabel('Target Interval')
    ax2.set_ylabel('Source Interval')
    ax2.set_title('Voice Leading Count Matrix\n(|step| ≤ 7)', fontsize=14)
    
    for i in range(n):
        for j in range(n):
            color = 'white' if matrix[i, j] > max_count * 0.6 else 'black'
            ax2.text(j, i, str(matrix[i, j]), ha='center', va='center', color=color, fontsize=11)
    
    plt.colorbar(im, ax=ax2, shrink=0.8, label='Number of valid voice leadings')
    
    plt.tight_layout()
    plt.savefig('viz_transition_graph.png', dpi=150, bbox_inches='tight')
    print("Saved viz_transition_graph.png")

if __name__ == "__main__":
    main()
