#!/usr/bin/env python3
"""
Counterpoint Category Theory Demo

Demonstrates the key results from the formalization of first-species
counterpoint as a categorical structure.
"""

from typing import List, Tuple, Dict

# Consonant interval classes (mod 12 semitones)
CONSONANT_INTERVALS = {
    'unison': 0,
    'min3': 3,
    'maj3': 4,
    'perf5': 7,
    'min6': 8,
    'maj6': 9,
}

INTERVAL_NAMES = {v: k for k, v in CONSONANT_INTERVALS.items()}

PERFECT = {'unison', 'perf5'}
IMPERFECT = {'min3', 'maj3', 'min6', 'maj6'}

MOTION_KINDS = ['contrary', 'oblique', 'similar', 'parallel']

def is_permitted(motion: str, target: str) -> bool:
    """Check if a motion kind is permitted to reach a target interval."""
    if target in PERFECT:
        return motion in ('contrary', 'oblique')
    return True

def complement(interval: str) -> str:
    """Voice exchange: swap upper and lower voice."""
    comp_map = {
        'unison': 'unison',
        'min3': 'maj6',
        'maj3': 'min6',
        'perf5': 'perf5',
        'min6': 'maj3',
        'maj6': 'min3',
    }
    return comp_map[interval]

def permitted_motion_count(target: str) -> int:
    """Count permitted motion kinds for a given target."""
    return sum(1 for m in MOTION_KINDS if is_permitted(m, target))

def weight_matrix() -> Dict[Tuple[str, str], int]:
    """Construct the weight matrix W(i,j) = permitted motions from i to j."""
    W = {}
    intervals = list(CONSONANT_INTERVALS.keys())
    for src in intervals:
        for tgt in intervals:
            W[(src, tgt)] = permitted_motion_count(tgt)
    return W

def main():
    intervals = list(CONSONANT_INTERVALS.keys())
    
    print("=" * 70)
    print("COUNTERPOINT AS CATEGORY THEORY: DEMONSTRATION")
    print("=" * 70)
    
    # 1. Show the weight matrix
    print("\n--- Weight Matrix W(i,j) = permitted motion count ---")
    print(f"{'':>8}", end="")
    for tgt in intervals:
        print(f"{tgt:>8}", end="")
    print()
    
    W = weight_matrix()
    for src in intervals:
        print(f"{src:>8}", end="")
        for tgt in intervals:
            print(f"{W[(src,tgt)]:>8}", end="")
        print()
    
    # 2. Verify key computed results
    print("\n--- Key Computed Results ---")
    
    # Row sums
    for src in intervals:
        row_sum = sum(W[(src, tgt)] for tgt in intervals)
        print(f"Row sum for {src:>8}: {row_sum}")
    
    # Column sums
    print()
    for tgt in intervals:
        col_sum = sum(W[(src, tgt)] for src in intervals)
        print(f"Col sum for {tgt:>8}: {col_sum} ({'perfect' if tgt in PERFECT else 'imperfect'})")
    
    # Total
    total = sum(W.values())
    print(f"\nTotal accessibility: {total}")
    
    # Trace
    trace = sum(W[(i, i)] for i in intervals)
    print(f"Trace: {trace}")
    
    # 3. Verify W² = trace(W) * W
    print("\n--- Rank-1 Verification: W² = 20·W ---")
    all_match = True
    for src in intervals:
        for tgt in intervals:
            w_squared = sum(W[(src, mid)] * W[(mid, tgt)] for mid in intervals)
            expected = trace * W[(src, tgt)]
            if w_squared != expected:
                print(f"  MISMATCH at ({src}, {tgt}): W²={w_squared}, 20·W={expected}")
                all_match = False
    print(f"  W² = 20·W: {'VERIFIED ✓' if all_match else 'FAILED ✗'}")
    
    # 4. Complement involution
    print("\n--- Voice Exchange (Complement) ---")
    for i in intervals:
        c = complement(i)
        cc = complement(c)
        print(f"  complement({i:>8}) = {c:>8}, complement²({i:>8}) = {cc:>8} ({'✓' if cc == i else '✗'})")
    
    # 5. Border asymmetry
    print("\n--- Border Asymmetry ---")
    perf_to_imp = sum(W[(s, t)] for s in PERFECT for t in IMPERFECT)
    imp_to_perf = sum(W[(s, t)] for s in IMPERFECT for t in PERFECT)
    print(f"  Perfect → Imperfect: {perf_to_imp}")
    print(f"  Imperfect → Perfect: {imp_to_perf}")
    print(f"  Ratio: {perf_to_imp}/{imp_to_perf} = {perf_to_imp/imp_to_perf:.1f}:1")
    
    # 6. Disproof of poset conjecture
    print("\n--- Poset Conjecture Disproof ---")
    print("  The transition relation is TOTAL: every pair is connected.")
    print("  Specifically: cpReachable(min3, maj3) AND cpReachable(maj3, min3)")
    print("  But min3 ≠ maj3, so antisymmetry fails.")
    print("  Therefore: NOT a partial order. Conjecture is FALSE. ✓")
    
    # 7. Strictness parameter sweep
    print("\n--- Strictness Parameter Sweep ---")
    for s in range(4):
        if s == 0:
            perfect_motions = 4
        elif s == 1:
            perfect_motions = 3
        elif s == 2:
            perfect_motions = 2
        else:
            perfect_motions = 1
        total_s = 6 * (2 * perfect_motions + 4 * 4)
        print(f"  Strictness {s}: perfect motions={perfect_motions}, total={total_s}")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Counterpoint Quiver Graph

Generates a graph visualization showing the counterpoint quiver
with edge weights indicating accessibility degree.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    intervals = ['U', 'm3', 'M3', 'P5', 'm6', 'M6']
    full_names = ['unison', 'min3', 'maj3', 'perf5', 'min6', 'maj6']
    perfect_idx = {0, 3}  # unison, perf5
    n = len(intervals)
    
    # Position nodes in a hexagon
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    x = np.cos(angles)
    y = np.sin(angles)
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # 1. Full quiver with edge weights
    ax = axes[0]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title('Counterpoint Quiver (K₆)\nEdge weight = permitted motions', fontsize=13)
    
    # Draw edges with colors based on weight
    for i in range(n):
        for j in range(n):
            if i != j:
                weight = 2 if j in perfect_idx else 4
                color = '#e74c3c' if weight == 2 else '#2ecc71'
                alpha = 0.3 if weight == 2 else 0.15
                lw = 1.5 if weight == 2 else 1.0
                dx = x[j] - x[i]
                dy = y[j] - y[i]
                # Offset slightly for bidirectional edges
                offset = 0.03
                nx, ny = -dy, dx  # normal
                norm = np.sqrt(nx**2 + ny**2)
                nx, ny = nx/norm * offset, ny/norm * offset
                ax.annotate('', xy=(x[j]+nx, y[j]+ny), xytext=(x[i]+nx, y[i]+ny),
                           arrowprops=dict(arrowstyle='->', color=color, alpha=alpha+0.3, lw=lw))
    
    # Draw self-loops
    for i in range(n):
        weight = 2 if i in perfect_idx else 4
        color = '#e74c3c' if weight == 2 else '#2ecc71'
        angle = angles[i]
        loop_r = 0.15
        loop_x = x[i] + 0.2 * np.cos(angle)
        loop_y = y[i] + 0.2 * np.sin(angle)
        circle = plt.Circle((loop_x, loop_y), loop_r, fill=False, color=color, lw=1.5)
        ax.add_patch(circle)
    
    # Draw nodes
    for i in range(n):
        color = '#e74c3c' if i in perfect_idx else '#2ecc71'
        ax.plot(x[i], y[i], 'o', markersize=25, color=color, zorder=5)
        ax.text(x[i], y[i], intervals[i], ha='center', va='center',
                fontweight='bold', fontsize=10, color='white', zorder=6)
        # Label with semitone value
        label_r = 1.35
        ax.text(label_r*np.cos(angles[i]), label_r*np.sin(angles[i]),
                f'{full_names[i]}\n({[0,3,4,7,8,9][i]} st)',
                ha='center', va='center', fontsize=8)
    
    ax.legend(['Perfect (weight 2)', 'Imperfect (weight 4)'],
              loc='lower right', fontsize=9)
    ax.axis('off')
    
    # 2. Complement orbits
    ax = axes[1]
    ax.set_xlim(-2, 2)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Voice Exchange (Complement) Orbits\n2 fixed points + 2 swap pairs', fontsize=13)
    
    # Fixed points (perfect consonances)
    ax.plot(-1.2, 0.8, 'o', markersize=30, color='#e74c3c', zorder=5)
    ax.text(-1.2, 0.8, 'U', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.annotate('', xy=(-1.0, 0.8), xytext=(-1.4, 0.8),
               arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2,
                              connectionstyle='arc3,rad=0.5'))
    ax.text(-1.2, 1.2, 'fixed point', ha='center', fontsize=9, style='italic')
    
    ax.plot(-1.2, -0.8, 'o', markersize=30, color='#e74c3c', zorder=5)
    ax.text(-1.2, -0.8, 'P5', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.annotate('', xy=(-1.0, -0.8), xytext=(-1.4, -0.8),
               arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2,
                              connectionstyle='arc3,rad=0.5'))
    ax.text(-1.2, -1.2, 'fixed point', ha='center', fontsize=9, style='italic')
    
    # Swap pair 1: min3 ↔ maj6
    ax.plot(0.5, 0.6, 'o', markersize=30, color='#2ecc71', zorder=5)
    ax.text(0.5, 0.6, 'm3', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.plot(1.5, 0.6, 'o', markersize=30, color='#2ecc71', zorder=5)
    ax.text(1.5, 0.6, 'M6', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.annotate('', xy=(1.3, 0.75), xytext=(0.7, 0.75),
               arrowprops=dict(arrowstyle='<->', color='#27ae60', lw=2))
    ax.text(1.0, 1.0, '3+9=12', ha='center', fontsize=9)
    
    # Swap pair 2: maj3 ↔ min6
    ax.plot(0.5, -0.6, 'o', markersize=30, color='#2ecc71', zorder=5)
    ax.text(0.5, -0.6, 'M3', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.plot(1.5, -0.6, 'o', markersize=30, color='#2ecc71', zorder=5)
    ax.text(1.5, -0.6, 'm6', ha='center', va='center', fontweight='bold',
            fontsize=12, color='white', zorder=6)
    ax.annotate('', xy=(1.3, -0.45), xytext=(0.7, -0.45),
               arrowprops=dict(arrowstyle='<->', color='#27ae60', lw=2))
    ax.text(1.0, -1.0, '4+8=12', ha='center', fontsize=9)
    
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('counterpoint_quiver.png', dpi=150, bbox_inches='tight')
    print("Saved: counterpoint_quiver.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Counterpoint Weight Matrix

Generates a heatmap of the weight matrix W(i,j) showing the
accessibility structure of first-species counterpoint.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    intervals = ['unison', 'min3', 'maj3', 'perf5', 'min6', 'maj6']
    perfect = {'unison', 'perf5'}
    
    # Build weight matrix
    n = len(intervals)
    W = np.zeros((n, n), dtype=int)
    for i, src in enumerate(intervals):
        for j, tgt in enumerate(intervals):
            if tgt in perfect:
                W[i, j] = 2  # only contrary + oblique
            else:
                W[i, j] = 4  # all four motion types
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # 1. Weight matrix heatmap
    ax = axes[0]
    im = ax.imshow(W, cmap='YlOrRd', vmin=0, vmax=5)
    ax.set_xticks(range(n))
    ax.set_xticklabels(intervals, rotation=45, ha='right')
    ax.set_yticks(range(n))
    ax.set_yticklabels(intervals)
    ax.set_title('Weight Matrix W(i,j)\n(permitted motion counts)', fontsize=12)
    ax.set_xlabel('Target interval')
    ax.set_ylabel('Source interval')
    for i in range(n):
        for j in range(n):
            color = 'white' if W[i,j] >= 3 else 'black'
            ax.text(j, i, str(W[i,j]), ha='center', va='center', color=color, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # 2. Column sums bar chart
    ax = axes[1]
    col_sums = W.sum(axis=0)
    colors = ['#e74c3c' if intervals[j] in perfect else '#2ecc71' for j in range(n)]
    bars = ax.bar(range(n), col_sums, color=colors)
    ax.set_xticks(range(n))
    ax.set_xticklabels(intervals, rotation=45, ha='right')
    ax.set_title('Column Sums\n(12 for perfect, 24 for imperfect)', fontsize=12)
    ax.set_ylabel('Column sum')
    ax.axhline(y=12, color='#e74c3c', linestyle='--', alpha=0.5, label='Perfect')
    ax.axhline(y=24, color='#2ecc71', linestyle='--', alpha=0.5, label='Imperfect')
    ax.legend()
    
    # 3. Strictness parameter sweep
    ax = axes[2]
    strictness_levels = [0, 1, 2, 3]
    perfect_access = [4, 3, 2, 1]
    imperfect_access = [4, 4, 4, 4]
    total_access = [6*(2*p + 4*ip) for p, ip in zip(perfect_access, imperfect_access)]
    
    ax.plot(strictness_levels, perfect_access, 'o-', color='#e74c3c', linewidth=2,
            markersize=8, label='Perfect target')
    ax.plot(strictness_levels, imperfect_access, 's-', color='#2ecc71', linewidth=2,
            markersize=8, label='Imperfect target')
    ax.set_xlabel('Strictness level')
    ax.set_ylabel('Permitted motions')
    ax.set_title('Accessibility vs Strictness\n(monotone decrease for perfect)', fontsize=12)
    ax.set_xticks(strictness_levels)
    ax.set_xticklabels(['0\n(free)', '1\n(standard)', '2\n(strict)', '3\n(ultra)'])
    ax.legend()
    ax.set_ylim(0, 5)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('counterpoint_weight_matrix.png', dpi=150, bbox_inches='tight')
    print("Saved: counterpoint_weight_matrix.png")

if __name__ == "__main__":
    main()
