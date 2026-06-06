#!/usr/bin/env python3
"""
Demo: Counterpoint Category Theory
Numerical examples demonstrating the main theorems.
"""

# Consonant intervals in first-species counterpoint (semitones mod 12)
CONSONANCES = [0, 3, 4, 7, 8, 9]
NAMES = {0: "Unison", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
CLASSES = {0: "perfect", 3: "imperfect", 4: "imperfect",
           7: "perfect", 8: "imperfect", 9: "imperfect"}

MOTION_TYPES = ["parallel", "similar", "contrary", "oblique"]


def is_valid_transition(src: int, tgt: int, motion: str) -> bool:
    """Check if a voice leading transition is valid in first-species counterpoint."""
    if CLASSES[tgt] == "perfect" and motion in ("parallel", "similar"):
        return False
    return True


def demo_target_only_dependence():
    """Demonstrate that valid motions depend only on the target."""
    print("=" * 60)
    print("THEOREM: Target-Only Dependence")
    print("The set of valid motions depends ONLY on the target interval.")
    print("=" * 60)
    for tgt in CONSONANCES:
        valid = [m for m in MOTION_TYPES if is_valid_transition(0, tgt, m)]
        print(f"  To {NAMES[tgt]:6s} ({CLASSES[tgt]:9s}): {valid}")
    print()


def demo_complement_involution():
    """Demonstrate the complement involution on consonant intervals."""
    print("=" * 60)
    print("THEOREM: Complement Involution")
    print("Swaps m3↔M6, M3↔m6; fixes Unison and P5.")
    print("=" * 60)
    complement = {0: 0, 3: 9, 4: 8, 7: 7, 8: 4, 9: 3}
    for i in CONSONANCES:
        c = complement[i]
        fixed = "  (fixed point)" if i == c else ""
        print(f"  {NAMES[i]:6s} ({i}) → {NAMES[c]:6s} ({c}){fixed}")
        assert complement[c] == i, "Not an involution!"
    print("  ✓ Verified: complement ∘ complement = identity")
    print()


def demo_exact_counting():
    """Count valid and invalid transitions."""
    print("=" * 60)
    print("THEOREM: Exact Transition Count")
    print("120 valid out of 144 total transitions (restriction factor 5/6)")
    print("=" * 60)
    valid_count = 0
    forbidden = []
    for src in CONSONANCES:
        for tgt in CONSONANCES:
            for m in MOTION_TYPES:
                if is_valid_transition(src, tgt, m):
                    valid_count += 1
                else:
                    forbidden.append((NAMES[src], NAMES[tgt], m))

    print(f"  Total transitions: {len(CONSONANCES)**2 * len(MOTION_TYPES)}")
    print(f"  Valid transitions: {valid_count}")
    print(f"  Forbidden transitions: {len(forbidden)}")
    print(f"  Restriction factor: {valid_count}/{len(CONSONANCES)**2 * len(MOTION_TYPES)}"
          f" = {valid_count / (len(CONSONANCES)**2 * len(MOTION_TYPES)):.4f}")
    print(f"\n  Forbidden transitions (all approach perfect consonances):")
    for src, tgt, m in forbidden[:8]:
        print(f"    {src} → {tgt} by {m}")
    if len(forbidden) > 8:
        print(f"    ... and {len(forbidden) - 8} more")
    print()


def demo_non_closure():
    """Show that consonances are not closed under addition mod 12."""
    print("=" * 60)
    print("THEOREM: Non-Closure Under Addition")
    print("Consonant intervals don't form a subgroup of Z/12Z.")
    print("=" * 60)
    consonant_set = set(CONSONANCES)
    consonant_pairs = 0
    dissonant_pairs = []
    for i in CONSONANCES:
        for j in CONSONANCES:
            s = (i + j) % 12
            if s in consonant_set:
                consonant_pairs += 1
            else:
                dissonant_pairs.append((i, j, s))

    print(f"  Consonant sums: {consonant_pairs}/36 ({consonant_pairs/36:.1%})")
    print(f"  Dissonant sums: {len(dissonant_pairs)}/36")
    print(f"\n  Example dissonant sums:")
    dissonant_names = {1: "m2", 2: "M2", 5: "P4", 6: "tritone",
                       10: "m7", 11: "M7"}
    for i, j, s in dissonant_pairs[:6]:
        sname = dissonant_names.get(s, f"{s}st")
        print(f"    {NAMES[i]} + {NAMES[j]} = {s} ({sname})")
    print()


def demo_ramsey_property():
    """Verify the Ramsey property: no dissonance triangle exists."""
    print("=" * 60)
    print("THEOREM: Ramsey Property")
    print("Every triple of distinct consonances has a consonant-summing pair.")
    print("=" * 60)
    consonant_set = set(CONSONANCES)

    def is_adjacent(i, j):
        return (i + j) % 12 in consonant_set

    # Check all triples
    from itertools import combinations
    triples = list(combinations(CONSONANCES, 3))
    all_have_pair = True
    for a, b, c in triples:
        if not (is_adjacent(a, b) or is_adjacent(b, c) or is_adjacent(a, c)):
            all_have_pair = False
            print(f"  COUNTEREXAMPLE: {NAMES[a]}, {NAMES[b]}, {NAMES[c]}")

    if all_have_pair:
        print(f"  ✓ Verified for all {len(triples)} triples: no dissonance triangle exists")

    # Show the dissonance pairs
    dissonant_edges = [(i, j) for i, j in combinations(CONSONANCES, 2)
                       if not is_adjacent(i, j)]
    print(f"\n  Non-adjacent pairs (summing to dissonance):")
    for i, j in dissonant_edges:
        print(f"    {NAMES[i]} + {NAMES[j]} = {(i+j)%12}")
    print(f"  Total: {len(dissonant_edges)} edges in complement graph")
    print(f"  Independence number of complement graph: 2 (no triangle)")
    print()


def demo_rigidity():
    """Verify trivial stabilizer of consonance set."""
    print("=" * 60)
    print("THEOREM: Rigidity (Trivial Stabilizer)")
    print("No nonzero transposition preserves the consonance set.")
    print("=" * 60)
    consonant_set = set(CONSONANCES)
    for t in range(12):
        translated = {(s + t) % 12 for s in CONSONANCES}
        if translated == consonant_set:
            print(f"  t = {t:2d}: {sorted(translated)} = consonances ✓")
        else:
            diff = translated - consonant_set
            print(f"  t = {t:2d}: introduces {sorted(diff)}")
    print()


def demo_interval_distance():
    """Compute the interval distance matrix."""
    print("=" * 60)
    print("THEOREM: Interval Distance and Diameter")
    print("=" * 60)
    print(f"  {'':6s}", end="")
    for j in CONSONANCES:
        print(f"{NAMES[j]:>6s}", end="")
    print()

    max_dist = 0
    max_pair = (0, 0)
    for i in CONSONANCES:
        print(f"  {NAMES[i]:6s}", end="")
        for j in CONSONANCES:
            d = min((j - i) % 12, (i - j) % 12)
            if d > max_dist:
                max_dist = d
                max_pair = (i, j)
            print(f"{d:6d}", end="")
        print()
    print(f"\n  Diameter: {max_dist} (between {NAMES[max_pair[0]]} and {NAMES[max_pair[1]]})")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  COUNTERPOINT CATEGORY THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_target_only_dependence()
    demo_complement_involution()
    demo_exact_counting()
    demo_non_closure()
    demo_ramsey_property()
    demo_rigidity()
    demo_interval_distance()


#!/usr/bin/env python3
"""
Visualization: Consonance Ramsey Property
Shows the consonance adjacency graph and its complement.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def main():
    names = ["U", "m3", "M3", "P5", "m6", "M6"]
    semitones = [0, 3, 4, 7, 8, 9]
    consonant_set = set(semitones)
    n = len(names)

    # Compute adjacency
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                adj[i][j] = (semitones[i] + semitones[j]) % 12 in consonant_set

    angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]
    x = [1.5 * np.cos(a) for a in angles]
    y = [1.5 * np.sin(a) for a in angles]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: consonance adjacency graph
    ax = axes[0]
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title("Consonance Adjacency Graph\n(edge = sum is consonant)", fontsize=12, fontweight='bold')

    for i in range(n):
        for j in range(i + 1, n):
            if adj[i][j]:
                s = (semitones[i] + semitones[j]) % 12
                ax.plot([x[i], x[j]], [y[i], y[j]], '-', color='#3498db', lw=1.5, alpha=0.6)
                mx, my = (x[i] + x[j]) / 2, (y[i] + y[j]) / 2
                ax.text(mx, my, str(s), fontsize=7, ha='center', va='center',
                       bbox=dict(boxstyle='round,pad=0.15', facecolor='white', edgecolor='#3498db', alpha=0.8))

    for i in range(n):
        ax.scatter(x[i], y[i], s=600, c='#3498db', zorder=5, edgecolors='black', linewidth=1.5)
        ax.text(x[i], y[i], names[i], ha='center', va='center',
                fontsize=9, fontweight='bold', color='white')

    edge_count = sum(1 for i in range(n) for j in range(i+1, n) if adj[i][j])
    ax.text(0, -2.2, f"{edge_count} edges", ha='center', fontsize=11, fontweight='bold')
    ax.axis('off')

    # Right: complement graph (dissonance)
    ax = axes[1]
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title("Dissonance Graph (complement)\n(edge = sum is dissonant)", fontsize=12, fontweight='bold')

    for i in range(n):
        for j in range(i + 1, n):
            if not adj[i][j]:
                s = (semitones[i] + semitones[j]) % 12
                ax.plot([x[i], x[j]], [y[i], y[j]], '-', color='#e74c3c', lw=2, alpha=0.8)
                mx, my = (x[i] + x[j]) / 2, (y[i] + y[j]) / 2
                ax.text(mx, my, str(s), fontsize=7, ha='center', va='center',
                       bbox=dict(boxstyle='round,pad=0.15', facecolor='white', edgecolor='#e74c3c', alpha=0.8))

    for i in range(n):
        ax.scatter(x[i], y[i], s=600, c='#e74c3c', zorder=5, edgecolors='black', linewidth=1.5)
        ax.text(x[i], y[i], names[i], ha='center', va='center',
                fontsize=9, fontweight='bold', color='white')

    comp_edges = sum(1 for i in range(n) for j in range(i+1, n) if not adj[i][j])
    ax.text(0, -2.2, f"{comp_edges} edges — no triangle!\n(Ramsey property)", ha='center', fontsize=11, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("ramsey_property.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved ramsey_property.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Counterpoint Transition Graph
Shows the directed graph of valid voice leadings with motion-type edge colors.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def main():
    # Consonant intervals
    names = ["U", "m3", "M3", "P5", "m6", "M6"]
    semitones = [0, 3, 4, 7, 8, 9]
    is_perfect = [True, False, False, True, False, False]

    # Position nodes in a circle
    n = len(names)
    angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]
    x = [1.5 * np.cos(a) for a in angles]
    y = [1.5 * np.sin(a) for a in angles]

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # --- Left panel: Receptivity ---
    ax = axes[0]
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title("Consonant Interval Receptivity", fontsize=14, fontweight='bold')

    for i in range(n):
        for j in range(n):
            if i != j:
                dx = x[j] - x[i]
                dy = y[j] - y[i]
                dist = np.sqrt(dx**2 + dy**2)
                # Shorten arrow
                shrink = 0.25
                ax.annotate("", xy=(x[j] - shrink * dx / dist, y[j] - shrink * dy / dist),
                           xytext=(x[i] + shrink * dx / dist, y[i] + shrink * dy / dist),
                           arrowprops=dict(arrowstyle="->", color="gray", alpha=0.3, lw=0.5))

    for i in range(n):
        color = "#e74c3c" if is_perfect[i] else "#3498db"
        recept = 2 if is_perfect[i] else 4
        size = 800 if is_perfect[i] else 1200
        ax.scatter(x[i], y[i], s=size, c=color, zorder=5, edgecolors='black', linewidth=2)
        ax.text(x[i], y[i], f"{names[i]}\n({recept})", ha='center', va='center',
                fontsize=10, fontweight='bold', color='white')

    # Legend
    perfect_patch = mpatches.Patch(color='#e74c3c', label='Perfect (receptivity 2)')
    imperfect_patch = mpatches.Patch(color='#3498db', label='Imperfect (receptivity 4)')
    ax.legend(handles=[perfect_patch, imperfect_patch], loc='lower right', fontsize=10)
    ax.axis('off')

    # --- Right panel: Complement pairs ---
    ax = axes[1]
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title("Complement Involution", fontsize=14, fontweight='bold')

    complement = {0: 0, 1: 5, 2: 4, 3: 3, 4: 2, 5: 1}

    for i in range(n):
        color = "#e74c3c" if is_perfect[i] else "#3498db"
        ax.scatter(x[i], y[i], s=1000, c=color, zorder=5, edgecolors='black', linewidth=2)
        ax.text(x[i], y[i], f"{names[i]}\n({semitones[i]})", ha='center', va='center',
                fontsize=10, fontweight='bold', color='white')

    # Draw complement arcs
    complement_pairs = [(1, 5), (2, 4)]  # m3↔M6, M3↔m6
    for i, j in complement_pairs:
        mid_x = (x[i] + x[j]) / 2
        mid_y = (y[i] + y[j]) / 2
        # Draw curved arrow
        ax.annotate("", xy=(x[j], y[j]), xytext=(x[i], y[i]),
                    arrowprops=dict(arrowstyle="<->", color="#2ecc71", lw=2.5,
                                   connectionstyle="arc3,rad=0.3"))
        label_x = mid_x + 0.3 * np.sign(mid_x) if abs(mid_x) > 0.1 else mid_x + 0.3
        label_y = mid_y + 0.3
        ax.text(label_x, label_y, f"{semitones[i]}+{semitones[j]}=12",
                fontsize=9, color='#2ecc71', fontweight='bold')

    # Fixed points
    for i in [0, 3]:  # unison, fifth
        ax.annotate("", xy=(x[i] + 0.2, y[i] + 0.35),
                    xytext=(x[i] - 0.2, y[i] + 0.35),
                    arrowprops=dict(arrowstyle="->", color="#f39c12", lw=2,
                                   connectionstyle="arc3,rad=-0.8"))
        ax.text(x[i], y[i] + 0.55, "fixed", fontsize=8, ha='center',
                color='#f39c12', fontweight='bold')

    complement_patch = mpatches.Patch(color='#2ecc71', label='Complement pair (sum=12)')
    fixed_patch = mpatches.Patch(color='#f39c12', label='Fixed point (perfect)')
    ax.legend(handles=[complement_patch, fixed_patch], loc='lower right', fontsize=10)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("counterpoint_graph.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved counterpoint_graph.png")


if __name__ == "__main__":
    main()
