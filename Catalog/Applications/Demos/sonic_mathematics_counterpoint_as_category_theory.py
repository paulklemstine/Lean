"""
Counterpoint as Category Theory: Demonstration

Enumerates all valid voice leadings in first-species counterpoint,
computes the transition graph, and demonstrates the composition failure.
"""

from typing import List, Tuple, Set

# Consonant intervals in first-species counterpoint (semitones mod 12)
CONSONANT = {0, 3, 4, 7, 8, 9}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

INTERVAL_NAMES = {
    0: "Unison (P1)", 3: "Minor 3rd (m3)", 4: "Major 3rd (M3)",
    7: "Perfect 5th (P5)", 8: "Minor 6th (m6)", 9: "Major 6th (M6)",
    5: "Perfect 4th (P4)", 6: "Tritone (TT)"
}


def is_valid_vl(source: int, target: int, bass_step: int) -> bool:
    """Check if a voice leading is valid in first-species counterpoint."""
    s, t, b = source % 12, target % 12, bass_step % 12
    if s not in CONSONANT or t not in CONSONANT:
        return False
    treble_step = (b + (t - s)) % 12
    # Check interval change
    if (treble_step - b) % 12 != (t - s) % 12:
        return False
    # No parallel perfect consonances
    if t in PERFECT and b == treble_step and b != 0:
        return False
    return True


def count_valid_vls() -> dict:
    """Count valid voice leadings for each (source, target) pair."""
    counts = {}
    for s in sorted(CONSONANT):
        for t in sorted(CONSONANT):
            count = sum(1 for b in range(12) if is_valid_vl(s, t, b))
            counts[(s, t)] = count
    return counts


def find_composition_failure() -> None:
    """Find and display a concrete counterexample to categorical composition."""
    print("\n=== COMPOSITION FAILURE (Disproof of Category Conjecture) ===\n")
    
    # The specific counterexample from our proof
    s, m, t = 0, 3, 0
    vl1_bass, vl1_treble = 0, 3  # bass stays, treble rises m3
    vl2_bass, vl2_treble = 3, 0  # bass rises m3, treble stays
    
    print(f"VL₁: {INTERVAL_NAMES[s]} → {INTERVAL_NAMES[m]}")
    print(f"  Bass: +{vl1_bass}, Treble: +{vl1_treble}")
    print(f"  Valid: {is_valid_vl(s, m, vl1_bass)}")
    
    print(f"\nVL₂: {INTERVAL_NAMES[m]} → {INTERVAL_NAMES[t]}")
    print(f"  Bass: +{vl2_bass}, Treble: +{vl2_treble}")
    print(f"  Valid: {is_valid_vl(m, t, vl2_bass)}")
    
    comp_bass = (vl1_bass + vl2_bass) % 12
    comp_treble = (vl1_treble + vl2_treble) % 12
    
    print(f"\nComposition: {INTERVAL_NAMES[s]} → {INTERVAL_NAMES[t]}")
    print(f"  Bass: +{comp_bass}, Treble: +{comp_treble}")
    print(f"  Parallel motion: {comp_bass == comp_treble and comp_bass != 0}")
    print(f"  Target is perfect: {t in PERFECT}")
    print(f"  Valid: {is_valid_vl(s, t, comp_bass)}")
    print(f"\n  ⚡ Both VL₁ and VL₂ are valid, but their composition is INVALID!")
    print(f"  → Counterpoint does NOT form a category.")


def inversion_analysis() -> None:
    """Analyze interval inversion and the consonance asymmetry."""
    print("\n=== CONSONANCE ASYMMETRY UNDER INVERSION ===\n")
    print(f"{'Interval':<20} {'Semitones':>10} {'Inversion':>10} {'Inv. Name':<20} {'Both consonant?'}")
    print("-" * 80)
    for i in sorted(CONSONANT):
        inv = (12 - i) % 12
        inv_consonant = inv in CONSONANT
        name = INTERVAL_NAMES.get(i, f"({i})")
        inv_name = INTERVAL_NAMES.get(inv, f"({inv})")
        both = "✓" if inv_consonant else "✗ ASYMMETRIC"
        print(f"{name:<20} {i:>10} {inv:>10} {inv_name:<20} {both}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  First-Species Counterpoint as Category Theory          ║")
    print("║  Sonic Mathematics: Voice Leading Structure Analysis    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # 1. Count valid voice leadings
    counts = count_valid_vls()
    total = sum(counts.values())
    
    print(f"\n=== VOICE LEADING COUNTS (mod 12) ===\n")
    print(f"{'Source → Target':<25} {'Valid VLs':>10} {'Max (12)':>10} {'Deficit':>10}")
    print("-" * 55)
    for (s, t), c in sorted(counts.items()):
        sn = INTERVAL_NAMES.get(s, str(s))[:6]
        tn = INTERVAL_NAMES.get(t, str(t))[:6]
        deficit = 12 - c
        marker = " ← PARALLEL RESTRICTION" if deficit > 0 else ""
        print(f"{sn:>6} → {tn:<12} {c:>10} {12:>10} {deficit:>10}{marker}")
    
    print(f"\n  Total valid voice leadings: {total}")
    print(f"  Unrestricted would be:      {6*6*12}")
    print(f"  Deficit from parallel rule:  {6*6*12 - total}")
    
    # 2. Inversion analysis
    inversion_analysis()
    
    # 3. Composition failure
    find_composition_failure()
    
    # 4. Imperfect subcategory
    print("\n=== IMPERFECT CONSONANCE SUBCATEGORY ===\n")
    print("Transitions between imperfect consonances {m3, M3, m6, M6}")
    print("form a genuine subcategory (composition is always valid).")
    print(f"  Objects: 4 imperfect consonances")
    print(f"  Morphisms per pair: 12 (all unrestricted)")
    print(f"  Total morphisms: {4*4*12}")
    print(f"  This subcategory IS a category — composition preserves validity.")
    
    # 5. Summary
    print("\n=== KEY RESULTS ===\n")
    print("1. Consonant intervals: {0, 3, 4, 7, 8, 9} — 6 elements of Z/12Z")
    print("2. Consonance is NOT closed under inversion (P5↔P4 asymmetry)")
    print("3. Imperfect consonances ARE closed under inversion (m3↔M6, M3↔m6)")
    print("4. Transition graph is complete K₆ (all transitions possible)")
    print("5. Exactly 410 valid voice leadings (deficit of 22 from parallel rule)")
    print("6. DISPROOF: Counterpoint does NOT form a category!")
    print("7. Imperfect-only transitions DO form a subcategory")


if __name__ == "__main__":
    main()


"""
Visualization: Counterpoint Transition Graph

Displays the complete transition graph K₆ on consonant intervals,
with edge weights showing the number of valid voice leadings.
Self-loops on perfect consonances are highlighted to show the
deficit from the parallel-perfects rule.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Consonant intervals
CONSONANT = [0, 3, 4, 7, 8, 9]
PERFECT = {0, 7}
NAMES = {0: "P1\n(0)", 3: "m3\n(3)", 4: "M3\n(4)",
         7: "P5\n(7)", 8: "m6\n(8)", 9: "M6\n(9)"}

def compute_counts():
    """Compute valid voice leading counts for each pair."""
    counts = {}
    for s in CONSONANT:
        for t in CONSONANT:
            count = 0
            for b in range(12):
                treble = (b + (t - s)) % 12
                is_parallel = (b == treble) and (b != 0)
                if t in PERFECT and is_parallel:
                    continue
                count += 1
            counts[(s, t)] = count
    return counts

def main():
    counts = compute_counts()

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # --- Left: Transition graph ---
    ax = axes[0]
    n = len(CONSONANT)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    radius = 2.0
    positions = {c: (radius * np.cos(a), radius * np.sin(a))
                 for c, a in zip(CONSONANT, angles)}

    # Draw edges (only between different nodes)
    for i, s in enumerate(CONSONANT):
        for j, t in enumerate(CONSONANT):
            if s >= t:
                continue
            x1, y1 = positions[s]
            x2, y2 = positions[t]
            c = counts[(s, t)]
            ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            ax.text(mx, my, str(c), fontsize=7, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.15', facecolor='lightyellow',
                              edgecolor='gray', alpha=0.8))

    # Draw nodes
    for c in CONSONANT:
        x, y = positions[c]
        color = '#ff6b6b' if c in PERFECT else '#4ecdc4'
        circle = plt.Circle((x, y), 0.4, color=color, ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, NAMES[c], fontsize=9, ha='center', va='center',
                fontweight='bold', zorder=6)
        # Self-loop annotation
        sl_count = counts[(c, c)]
        offset = 0.55
        dx, dy = x / radius * offset, y / radius * offset
        color_sl = '#ff0000' if sl_count < 12 else '#008800'
        ax.text(x + dx, y + dy, f"↻{sl_count}",
                fontsize=8, ha='center', va='center', color=color_sl,
                fontweight='bold')

    ax.set_xlim(-3.2, 3.2)
    ax.set_ylim(-3.2, 3.2)
    ax.set_aspect('equal')
    ax.set_title('Counterpoint Transition Graph K₆\n'
                 '(edge labels = valid voice leading count)',
                 fontsize=12, fontweight='bold')
    ax.axis('off')

    # Legend
    perfect_patch = mpatches.Patch(color='#ff6b6b', label='Perfect consonance')
    imperfect_patch = mpatches.Patch(color='#4ecdc4', label='Imperfect consonance')
    ax.legend(handles=[perfect_patch, imperfect_patch], loc='lower left', fontsize=9)

    # --- Right: Deficit heatmap ---
    ax2 = axes[1]
    matrix = np.zeros((n, n))
    for i, s in enumerate(CONSONANT):
        for j, t in enumerate(CONSONANT):
            matrix[i, j] = 12 - counts[(s, t)]

    im = ax2.imshow(matrix, cmap='YlOrRd', vmin=0, vmax=11)
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    labels = [NAMES[c].replace('\n', ' ') for c in CONSONANT]
    ax2.set_xticklabels(labels, fontsize=9)
    ax2.set_yticklabels(labels, fontsize=9)
    ax2.set_xlabel('Target interval', fontsize=10)
    ax2.set_ylabel('Source interval', fontsize=10)
    ax2.set_title('Parallel-Perfects Deficit\n'
                  '(# voice leadings removed by rule)',
                  fontsize=12, fontweight='bold')

    for i in range(n):
        for j in range(n):
            val = int(matrix[i, j])
            color = 'white' if val > 5 else 'black'
            ax2.text(j, i, str(val), ha='center', va='center',
                     color=color, fontsize=11, fontweight='bold')

    plt.colorbar(im, ax=ax2, shrink=0.8, label='Deficit')

    plt.tight_layout()
    plt.savefig('counterpoint_transition_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: counterpoint_transition_graph.png")

if __name__ == "__main__":
    main()
