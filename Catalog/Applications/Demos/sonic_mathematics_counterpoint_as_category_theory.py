#!/usr/bin/env python3
"""
Demo: Voice Leading Algebra — Counterpoint as Categorical Structure

Demonstrates the key results:
1. The Counterpoint Obstruction (non-compositionality)
2. Strong Connectivity of the counterpoint quiver
3. Inversion Asymmetry (the perfect fifth anomaly)
4. The Perfect Bottleneck (1 vs 12 parallel self-transitions)
5. Tension Rank analysis
"""

# Consonant intervals in semitones mod 12
CONSONANT_SET = {0, 3, 4, 7, 8, 9}
PERFECT_SET = {0, 7}
IMPERFECT_SET = {3, 4, 8, 9}

INTERVAL_NAMES = {
    0: "P1 (unison)", 3: "m3 (minor third)", 4: "M3 (major third)",
    7: "P5 (perfect fifth)", 8: "m6 (minor sixth)", 9: "M6 (major sixth)"
}

TENSION_RANK = {0: 0, 7: 1, 4: 2, 3: 3, 9: 4, 8: 5}


def apply_vl(delta_u: int, delta_l: int, interval: int) -> int:
    """Apply voice leading to interval."""
    return (interval + delta_u - delta_l) % 12


def is_parallel(delta_u: int, delta_l: int) -> bool:
    """Check if voice leading has parallel motion."""
    return delta_u % 12 == delta_l % 12 and delta_u % 12 != 0


def is_valid_vl(interval: int, delta_u: int, delta_l: int) -> bool:
    """Check if voice leading is valid from given interval."""
    target = apply_vl(delta_u, delta_l, interval)
    if interval not in CONSONANT_SET:
        return False
    if target not in CONSONANT_SET:
        return False
    if interval in PERFECT_SET and target == interval and is_parallel(delta_u, delta_l):
        return False
    return True


def demo_obstruction():
    """Demonstrate the Counterpoint Obstruction Theorem."""
    print("=" * 60)
    print("THEOREM 1: The Counterpoint Obstruction")
    print("=" * 60)
    print()
    
    i, j = 7, 9  # P5 -> M6
    v1 = (2, 0)  # oblique: upper moves +2
    v2 = (0, 2)  # oblique: lower moves +2
    
    target1 = apply_vl(*v1, i)
    target2 = apply_vl(*v2, j)
    
    print(f"Start: {INTERVAL_NAMES[i]}")
    print(f"v₁ = ({v1[0]}, {v1[1]}): upper +{v1[0]}, lower stays")
    print(f"  {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[target1]}")
    print(f"  Valid? {is_valid_vl(i, *v1)}")
    print()
    print(f"v₂ = ({v2[0]}, {v2[1]}): upper stays, lower +{v2[1]}")
    print(f"  {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[target2]}")
    print(f"  Valid? {is_valid_vl(j, *v2)}")
    print()
    
    comp = ((v1[0] + v2[0]) % 12, (v1[1] + v2[1]) % 12)
    comp_target = apply_vl(*comp, i)
    print(f"Composite v₁∘v₂ = ({comp[0]}, {comp[1]}): both voices +2")
    print(f"  {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[comp_target]}")
    print(f"  Parallel motion? {is_parallel(*comp)}")
    print(f"  Valid? {is_valid_vl(i, *comp)}")
    print()
    print("⚡ Two valid oblique motions compose to INVALID parallel fifths!")
    print("   Counterpoint rules are NOT closed under composition.")
    print()


def demo_connectivity():
    """Demonstrate strong connectivity."""
    print("=" * 60)
    print("THEOREM 2: Strong Connectivity")
    print("=" * 60)
    print()
    print("For every pair (i, j) of consonant intervals,")
    print("the oblique voice leading (j-i, 0) is valid:")
    print()
    
    for i in sorted(CONSONANT_SET):
        for j in sorted(CONSONANT_SET):
            delta = (j - i) % 12
            valid = is_valid_vl(i, delta, 0)
            mark = "✓" if valid else "✗"
            print(f"  {INTERVAL_NAMES[i]:25s} → {INTERVAL_NAMES[j]:25s}  "
                  f"vl=({delta:2d}, 0)  {mark}")
    print()


def demo_inversion():
    """Demonstrate the inversion asymmetry."""
    print("=" * 60)
    print("THEOREM 3: Inversion Asymmetry")
    print("=" * 60)
    print()
    print("Inversion (octave complement) of each consonant interval:")
    print()
    
    for i in sorted(CONSONANT_SET):
        inv = (12 - i) % 12
        in_cons = "✓ consonant" if inv in CONSONANT_SET else "✗ DISSONANT"
        inv_name = INTERVAL_NAMES.get(inv, f"P4 ({inv} semitones)")
        print(f"  {INTERVAL_NAMES[i]:25s} → {inv_name:25s}  {in_cons}")
    
    print()
    print("⚡ The perfect fifth is the UNIQUE consonance whose inversion")
    print("   is not consonant. This explains its special status!")
    print()


def demo_bottleneck():
    """Demonstrate the perfect bottleneck."""
    print("=" * 60)
    print("THEOREM 4: Perfect Consonance Bottleneck")
    print("=" * 60)
    print()
    print("Parallel self-transitions (both voices move by same amount,")
    print("interval returns to itself):")
    print()
    
    for i in sorted(CONSONANT_SET):
        count = 0
        valid_steps = []
        for a in range(12):
            target = apply_vl(a, a, i)
            if target == i and is_valid_vl(i, a, a):
                count += 1
                valid_steps.append(a)
        
        kind = "PERFECT" if i in PERFECT_SET else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:25s} ({kind:9s}): {count:2d} transitions  "
              f"steps={valid_steps}")
    
    print()
    print("⚡ Perfect consonances: 1 transition (identity only)")
    print("   Imperfect consonances: 12 transitions (all parallel motions)")
    print("   Ratio 12:1 — the parallel-fifths rule removes 91% of transitions!")
    print()


def demo_tension():
    """Demonstrate the tension hierarchy."""
    print("=" * 60)
    print("THEOREM 5: Tension Hierarchy")
    print("=" * 60)
    print()
    
    sorted_intervals = sorted(CONSONANT_SET, key=lambda x: TENSION_RANK[x])
    print("Consonant intervals ordered by tension (low = stable):")
    print()
    
    for i in sorted_intervals:
        rank = TENSION_RANK[i]
        kind = "PERFECT" if i in PERFECT_SET else "imperfect"
        bar = "█" * (rank + 1) + "░" * (5 - rank)
        print(f"  τ={rank}  {bar}  {INTERVAL_NAMES[i]:25s}  ({kind})")
    
    print()
    print("⚡ All perfect consonances have lower tension than all imperfect ones.")
    print("   Tension rank is injective: each interval has a unique rank.")
    print()


def demo_adjacency_matrix():
    """Compute the full adjacency matrix of the counterpoint quiver."""
    print("=" * 60)
    print("ADJACENCY MATRIX of the Counterpoint Quiver")
    print("=" * 60)
    print()
    print("A[i,j] = number of valid voice leadings from interval i to j")
    print("(over all 144 possible voice leadings)")
    print()
    
    intervals = sorted(CONSONANT_SET)
    short_names = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
    
    # Header
    print(f"{'':>6s}", end="")
    for j in intervals:
        print(f"  {short_names[j]:>4s}", end="")
    print()
    print(f"{'':>6s}" + "-" * 30)
    
    total_valid = 0
    for i in intervals:
        print(f"  {short_names[i]:>4s}|", end="")
        for j in intervals:
            count = 0
            for du in range(12):
                for dl in range(12):
                    if apply_vl(du, dl, i) == j and is_valid_vl(i, du, dl):
                        count += 1
            total_valid += count
            print(f"  {count:4d}", end="")
        print()
    
    print()
    print(f"Total valid voice leadings: {total_valid}")
    total_possible = 6 * 144  # 6 source intervals × 144 voice leadings
    print(f"Total possible: {total_possible}")
    print(f"Validity rate: {total_valid/total_possible:.1%}")
    print()


if __name__ == "__main__":
    demo_obstruction()
    demo_connectivity()
    demo_inversion()
    demo_bottleneck()
    demo_tension()
    demo_adjacency_matrix()


#!/usr/bin/env python3
"""
Visualization: The Perfect Consonance Bottleneck

Bar chart comparing parallel self-transition counts between
perfect and imperfect consonances.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_parallel_counts():
    """Compute parallel self-transition counts for each consonant interval."""
    consonant = [0, 3, 4, 7, 8, 9]
    perfect = {0, 7}
    n = 12
    
    counts = {}
    for i in consonant:
        count = 0
        for a in range(n):
            target = (i + a - a) % n  # always i
            if target != i:
                continue
            # Check validity
            is_par = (a != 0)  # parallel if a = a and a != 0
            if i in perfect and target == i and is_par:
                continue
            count += 1
        counts[i] = count
    return counts


def main():
    counts = compute_parallel_counts()
    
    names = {0: "P1\n(unison)", 3: "m3\n(min 3rd)", 4: "M3\n(maj 3rd)",
             7: "P5\n(fifth)", 8: "m6\n(min 6th)", 9: "M6\n(maj 6th)"}
    perfect = {0, 7}
    
    intervals = [0, 7, 3, 4, 8, 9]  # perfects first, then imperfects
    labels = [names[i] for i in intervals]
    values = [counts[i] for i in intervals]
    colors = ['#e74c3c' if i in perfect else '#3498db' for i in intervals]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Bar chart
    bars = ax1.bar(range(len(intervals)), values, color=colors, edgecolor='white', linewidth=1.5)
    ax1.set_xticks(range(len(intervals)))
    ax1.set_xticklabels(labels, fontsize=10)
    ax1.set_ylabel('Number of parallel self-transitions', fontsize=12)
    ax1.set_title('The Perfect Consonance Bottleneck\n'
                   'Parallel self-transitions: Perfect vs Imperfect', 
                   fontsize=13, fontweight='bold')
    
    for bar, val in zip(bars, values):
        ax1.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                str(val), ha='center', va='bottom', fontsize=14, fontweight='bold')
    
    ax1.axhline(y=1, color='#e74c3c', linestyle='--', alpha=0.3, label='Perfect limit (1)')
    ax1.axhline(y=12, color='#3498db', linestyle='--', alpha=0.3, label='Imperfect count (12)')
    ax1.set_ylim(0, 15)
    ax1.legend(fontsize=10)
    
    # Annotation
    ax1.annotate('12:1\nBottleneck\nRatio', xy=(1, 1), xytext=(1, 7),
                fontsize=14, fontweight='bold', color='#c0392b',
                ha='center', va='center',
                arrowprops=dict(arrowstyle='->', color='#c0392b', lw=2),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#fce4e4'))
    
    # Tension rank chart
    tension = {0: 0, 7: 1, 4: 2, 3: 3, 9: 4, 8: 5}
    tension_order = sorted(tension.keys(), key=lambda x: tension[x])
    t_labels = [names[i].replace('\n', ' ') for i in tension_order]
    t_values = [tension[i] for i in tension_order]
    t_colors = ['#e74c3c' if i in perfect else '#3498db' for i in tension_order]
    
    ax2.barh(range(len(tension_order)), t_values, color=t_colors, 
             edgecolor='white', linewidth=1.5)
    ax2.set_yticks(range(len(tension_order)))
    ax2.set_yticklabels(t_labels, fontsize=10)
    ax2.set_xlabel('Tension rank (τ)', fontsize=12)
    ax2.set_title('Tension Hierarchy\n'
                   'Lower rank = more stable', fontsize=13, fontweight='bold')
    ax2.invert_yaxis()
    
    # Add separation line
    ax2.axhline(y=1.5, color='gray', linestyle=':', alpha=0.5)
    ax2.text(4.5, 0.5, 'PERFECT', fontsize=9, color='#e74c3c', 
             ha='center', va='center', style='italic')
    ax2.text(4.5, 3.5, 'IMPERFECT', fontsize=9, color='#2980b9',
             ha='center', va='center', style='italic')
    
    plt.tight_layout()
    plt.savefig('bottleneck_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: bottleneck_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Counterpoint Quiver

Plots the directed graph of valid voice leading transitions between
consonant intervals, with edge thickness proportional to the number
of valid voice leadings.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_adjacency():
    """Compute adjacency matrix of counterpoint quiver."""
    consonant = [0, 3, 4, 7, 8, 9]
    perfect = {0, 7}
    n = 12
    
    matrix = {}
    for i in consonant:
        for j in consonant:
            count = 0
            for du in range(n):
                for dl in range(n):
                    target = (i + du - dl) % n
                    if target != j:
                        continue
                    if j not in set(consonant):
                        continue
                    # Check parallel perfect
                    is_par = (du == dl and du != 0)
                    if i in perfect and target == i and is_par:
                        continue
                    count += 1
            matrix[(i, j)] = count
    return matrix


def main():
    consonant = [0, 3, 4, 7, 8, 9]
    perfect = {0, 7}
    names = {0: "P1\n(unison)", 3: "m3", 4: "M3", 
             7: "P5\n(fifth)", 8: "m6", 9: "M6"}
    
    matrix = compute_adjacency()
    
    # Layout: arrange intervals in a hexagon
    n_nodes = len(consonant)
    angles = np.linspace(0, 2 * np.pi, n_nodes, endpoint=False) + np.pi / 2
    radius = 2.5
    positions = {interval: (radius * np.cos(a), radius * np.sin(a)) 
                 for interval, a in zip(consonant, angles)}
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_aspect('equal')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.axis('off')
    ax.set_title("The Counterpoint Quiver\nEdge width ∝ number of valid voice leadings", 
                 fontsize=14, fontweight='bold', pad=20)
    
    # Draw edges
    max_count = max(matrix.values())
    for (i, j), count in matrix.items():
        if count == 0 or i == j:
            continue
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        
        # Offset for bidirectional edges
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        nx, ny = -dy / length, dx / length
        offset = 0.08
        
        width = 0.5 + 3.0 * count / max_count
        alpha = 0.3 + 0.5 * count / max_count
        
        # Color by whether target is perfect
        color = '#c0392b' if j in perfect else '#2980b9'
        
        ax.annotate("", 
                     xy=(x2 + nx * offset, y2 + ny * offset),
                     xytext=(x1 + nx * offset, y1 + ny * offset),
                     arrowprops=dict(arrowstyle='->', lw=width, color=color,
                                     alpha=alpha, connectionstyle='arc3,rad=0.1'))
    
    # Draw self-loops (count them)
    for i in consonant:
        count = matrix[(i, i)]
        x, y = positions[i]
        angle = np.arctan2(y, x)
        loop_r = 0.4
        lx = x + loop_r * np.cos(angle) * 1.5
        ly = y + loop_r * np.sin(angle) * 1.5
        
        color = '#c0392b' if i in perfect else '#2980b9'
        circle = plt.Circle((lx, ly), loop_r, fill=False, 
                            color=color, linewidth=1 + count / 5, alpha=0.5)
        ax.add_patch(circle)
        ax.text(lx + loop_r * np.cos(angle) * 1.2, 
                ly + loop_r * np.sin(angle) * 1.2,
                str(count), fontsize=8, ha='center', va='center', color=color)
    
    # Draw nodes
    for interval in consonant:
        x, y = positions[interval]
        is_perf = interval in perfect
        color = '#e74c3c' if is_perf else '#3498db'
        edge_color = '#c0392b' if is_perf else '#2980b9'
        
        circle = plt.Circle((x, y), 0.45, color=color, ec=edge_color, 
                            linewidth=2, zorder=10)
        ax.add_patch(circle)
        ax.text(x, y, names[interval], fontsize=9, ha='center', va='center',
                fontweight='bold', color='white', zorder=11)
    
    # Legend
    perf_patch = mpatches.Patch(color='#e74c3c', label='Perfect consonance')
    imperf_patch = mpatches.Patch(color='#3498db', label='Imperfect consonance')
    ax.legend(handles=[perf_patch, imperf_patch], loc='lower right', fontsize=11)
    
    plt.tight_layout()
    plt.savefig('counterpoint_quiver.png', dpi=150, bbox_inches='tight')
    print("Saved: counterpoint_quiver.png")


if __name__ == "__main__":
    main()
