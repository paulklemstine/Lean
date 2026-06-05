#!/usr/bin/env python3
"""
Counterpoint Category Theory — Numerical Demonstrations

Demonstrates the key results from the Lean formalization:
1. The Fourth Anomaly (consonance inversion asymmetry)
2. The 2/4 Law (morphism counting)
3. Contrary Motion Completeness
4. Consonance Distance Preorder
"""

# --- Consonant Intervals ---
CONSONANT = {0, 3, 4, 7, 8, 9}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}
INTERVAL_NAMES = {
    0: "Unison", 1: "m2", 2: "M2", 3: "m3", 4: "M3",
    5: "P4", 6: "Tritone", 7: "P5", 8: "m6", 9: "M6",
    10: "m7", 11: "M7"
}


def neg_mod12(i: int) -> int:
    return (-i) % 12


def circle_distance(i: int) -> int:
    v = i % 12
    return min(v, 12 - v)


def demo_fourth_anomaly():
    """Demonstrate the Fourth Anomaly: consonance is NOT closed under negation."""
    print("=" * 60)
    print("DEMO 1: The Fourth Anomaly")
    print("=" * 60)
    print(f"\nConsonant intervals: {sorted(CONSONANT)}")
    print(f"  Names: {[INTERVAL_NAMES[i] for i in sorted(CONSONANT)]}")
    print(f"\nNegations (inversions mod 12):")
    for i in sorted(CONSONANT):
        ni = neg_mod12(i)
        status = "✓ consonant" if ni in CONSONANT else "✗ NOT consonant"
        print(f"  -{i} = {ni} ({INTERVAL_NAMES[ni]}): {status}")
    print(f"\nThe perfect fifth (7) inverts to the perfect fourth (5),")
    print(f"which is NOT consonant in first-species counterpoint.")
    print(f"Neg-stable count: {sum(1 for i in CONSONANT if neg_mod12(i) in CONSONANT)}/6")


def demo_two_four_law():
    """Demonstrate the 2/4 Law and morphism counting."""
    print("\n" + "=" * 60)
    print("DEMO 2: The 2/4 Law")
    print("=" * 60)
    motion_types = ["contrary", "oblique", "similar", "parallel"]
    print(f"\nMotion types available by target type:")
    print(f"  Perfect targets ({sorted(PERFECT)}): contrary, oblique (2 types)")
    print(f"  Imperfect targets ({sorted(IMPERFECT)}): all 4 types")
    
    total = 0
    print(f"\nMorphism count breakdown:")
    for target in sorted(CONSONANT):
        is_perfect = target in PERFECT
        n_motions = 2 if is_perfect else 4
        count = 6 * n_motions
        total += count
        ttype = "perfect" if is_perfect else "imperfect"
        print(f"  Target {target} ({INTERVAL_NAMES[target]}, {ttype}): "
              f"6 sources × {n_motions} motions = {count}")
    print(f"\nTotal morphisms: {total}")
    print(f"Note: {total} = 5! = {__import__('math').factorial(5)}")


def demo_contrary_completeness():
    """Demonstrate Contrary Motion Completeness."""
    print("\n" + "=" * 60)
    print("DEMO 3: Contrary Motion Completeness")
    print("=" * 60)
    print(f"\nFor every pair (a, b) of consonant intervals,")
    print(f"there exists a contrary-motion voice leading a → b.")
    print(f"\nExplicit witnesses (bass_step, soprano_step):")
    for a in sorted(CONSONANT):
        for b in sorted(CONSONANT):
            # Construct contrary motion: bass down, soprano up
            diff = (b - a) % 12
            bass = -1
            soprano = diff + bass  # soprano - bass = diff, so soprano = diff + bass
            # Ensure contrary: need bass < 0 and soprano > 0
            if soprano <= 0:
                soprano += 12
            change = (soprano - bass) % 12
            assert change == diff, f"Coherence failed for {a}→{b}: {change} != {diff}"
            assert bass < 0 and soprano > 0, f"Not contrary for {a}→{b}"
            print(f"  {INTERVAL_NAMES[a]:6s} → {INTERVAL_NAMES[b]:6s}: "
                  f"bass={bass:+d}, soprano={soprano:+d}")


def demo_consonance_preorder():
    """Demonstrate the consonance distance preorder."""
    print("\n" + "=" * 60)
    print("DEMO 4: Consonance Distance Preorder")
    print("=" * 60)
    print(f"\nCircle distances of consonant intervals:")
    distances = [(circle_distance(i), i) for i in sorted(CONSONANT)]
    distances.sort()
    for d, i in distances:
        bar = "█" * (d * 4)
        print(f"  {INTERVAL_NAMES[i]:6s} (i={i}): distance={d}  {bar}")
    print(f"\nOrdering: Unison ≤ {{m3, M6}} ≤ {{M3, m6}} ≤ P5")
    print(f"Inversion pairs occupy the same level (same distance).")


def demo_hexachordal_balance():
    """Demonstrate hexachordal balance."""
    print("\n" + "=" * 60)
    print("DEMO 5: Hexachordal Balance")
    print("=" * 60)
    dissonant = set(range(12)) - CONSONANT
    print(f"\nConsonant: {sorted(CONSONANT)} ({len(CONSONANT)} intervals)")
    print(f"  Names: {[INTERVAL_NAMES[i] for i in sorted(CONSONANT)]}")
    print(f"Dissonant: {sorted(dissonant)} ({len(dissonant)} intervals)")
    print(f"  Names: {[INTERVAL_NAMES[i] for i in sorted(dissonant)]}")
    print(f"\nBalance: |C| = |D| = 6 — a perfect hexachordal partition.")


def demo_non_subgroup():
    """Demonstrate that consonances don't form a subgroup."""
    print("\n" + "=" * 60)
    print("DEMO 6: Non-Subgroup Structure")
    print("=" * 60)
    print(f"\nConsonant set: {sorted(CONSONANT)}")
    print(f"Addition table (mod 12) — entries marked ✗ if not consonant:")
    header = "     " + "  ".join(f"{i:2d}" for i in sorted(CONSONANT))
    print(header)
    for a in sorted(CONSONANT):
        row = f"  {a:2d} "
        for b in sorted(CONSONANT):
            s = (a + b) % 12
            mark = "✓" if s in CONSONANT else "✗"
            row += f" {s:2d}{mark}"
        print(row)
    failures = [(a, b) for a in CONSONANT for b in CONSONANT 
                if (a + b) % 12 not in CONSONANT]
    print(f"\nNon-consonant sums: {len(failures)}/36")
    print(f"Example: 3 + 3 = 6 (tritone, not consonant)")
    print(f"But: 3 + 4 = 7 (perfect fifth IS consonant)")


if __name__ == "__main__":
    demo_fourth_anomaly()
    demo_two_four_law()
    demo_contrary_completeness()
    demo_consonance_preorder()
    demo_hexachordal_balance()
    demo_non_subgroup()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Counterpoint Category on the Chromatic Circle

Produces a circular diagram showing:
- Consonant intervals (highlighted) on the chromatic circle
- Inversion (negation) connections
- The Fourth Anomaly (P5 → P4 breaks consonance)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

INTERVAL_NAMES = {
    0: "P1", 1: "m2", 2: "M2", 3: "m3", 4: "M3",
    5: "P4", 6: "TT", 7: "P5", 8: "m6", 9: "M6",
    10: "m7", 11: "M7"
}
CONSONANT = {0, 3, 4, 7, 8, 9}
PERFECT = {0, 7}
IMPERFECT = {3, 4, 8, 9}

def plot_chromatic_circle():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # --- Panel 1: Consonance on the Chromatic Circle ---
    ax = axes[0]
    ax.set_aspect('equal')
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_title("Consonant Intervals on the Chromatic Circle", fontsize=14, fontweight='bold')
    
    theta = np.linspace(np.pi/2, np.pi/2 - 2*np.pi, 13)[:-1]
    r = 1.2
    
    for i in range(12):
        x, y = r * np.cos(theta[i]), r * np.sin(theta[i])
        if i in PERFECT:
            color = '#2196F3'
            size = 700
        elif i in IMPERFECT:
            color = '#4CAF50'
            size = 600
        else:
            color = '#E0E0E0'
            size = 400
        ax.scatter(x, y, s=size, c=color, zorder=5, edgecolors='black', linewidths=1.5)
        offset = 1.4
        ax.text(offset * np.cos(theta[i]), offset * np.sin(theta[i]),
                INTERVAL_NAMES[i], ha='center', va='center', fontsize=11, fontweight='bold')
    
    # Draw inversion arrows for imperfect consonances
    inv_pairs = [(3, 9), (4, 8)]
    for a, b in inv_pairs:
        xa, ya = 0.95 * np.cos(theta[a]), 0.95 * np.sin(theta[a])
        xb, yb = 0.95 * np.cos(theta[b]), 0.95 * np.sin(theta[b])
        ax.annotate('', xy=(xb, yb), xytext=(xa, ya),
                   arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2))
    
    # Draw the broken P5→P4 arrow (dashed, red)
    xa, ya = 0.95 * np.cos(theta[7]), 0.95 * np.sin(theta[7])
    xb, yb = 0.95 * np.cos(theta[5]), 0.95 * np.sin(theta[5])
    ax.annotate('', xy=(xb, yb), xytext=(xa, ya),
               arrowprops=dict(arrowstyle='->', color='#F44336', lw=2.5, linestyle='dashed'))
    ax.text(-0.15, -0.55, "Fourth\nAnomaly!", color='#F44336', fontsize=10,
            ha='center', fontweight='bold', style='italic')
    
    # Legend
    perfect_patch = mpatches.Patch(color='#2196F3', label='Perfect consonance')
    imperfect_patch = mpatches.Patch(color='#4CAF50', label='Imperfect consonance')
    dissonant_patch = mpatches.Patch(color='#E0E0E0', label='Dissonant')
    ax.legend(handles=[perfect_patch, imperfect_patch, dissonant_patch],
             loc='lower left', fontsize=9)
    ax.axis('off')
    
    # --- Panel 2: The 2/4 Law ---
    ax = axes[1]
    ax.set_title("The 2/4 Law: Motion Types by Target", fontsize=14, fontweight='bold')
    
    targets = ['P1\n(perfect)', 'P5\n(perfect)', 'm3\n(imperfect)',
               'M3\n(imperfect)', 'm6\n(imperfect)', 'M6\n(imperfect)']
    motions = [2, 2, 4, 4, 4, 4]
    colors = ['#2196F3', '#2196F3', '#4CAF50', '#4CAF50', '#4CAF50', '#4CAF50']
    
    bars = ax.bar(range(6), motions, color=colors, edgecolor='black', linewidth=1.2)
    ax.set_xticks(range(6))
    ax.set_xticklabels(targets, fontsize=10)
    ax.set_ylabel('Valid Motion Types', fontsize=12)
    ax.set_ylim(0, 5)
    ax.axhline(y=2, color='#2196F3', linestyle='--', alpha=0.5, label='Perfect limit')
    ax.axhline(y=4, color='#4CAF50', linestyle='--', alpha=0.5, label='Imperfect limit')
    
    for i, v in enumerate(motions):
        ax.text(i, v + 0.15, str(v), ha='center', fontweight='bold', fontsize=12)
    
    ax.text(2.5, 4.5, f"Total morphisms: 6×2×2 + 6×4×4 = 120 = 5!",
            ha='center', fontsize=11, style='italic',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    ax.legend(loc='center right', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('counterpoint_category.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: counterpoint_category.png")

if __name__ == "__main__":
    plot_chromatic_circle()
