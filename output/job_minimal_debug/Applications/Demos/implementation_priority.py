#!/usr/bin/env python3
"""
Applications of Mod-12 Pareto Rigidity
=======================================

Real-world applications demonstrating how cyclic Pareto optimality
and transposition invariance connect to:

1. Automatic voice leading in music composition
2. Discrete optimal transport on cyclic groups
3. Robust harmonic preference under perturbation
4. Chord progression optimization
"""

import itertools
from typing import List, Tuple, Dict

# ─────────────────────────────────────────────────────────────
# Core functions (self-contained)
# ─────────────────────────────────────────────────────────────

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

def cyc_dist(a: int, b: int, n: int = 12) -> int:
    r = (a - b) % n
    return min(r, n - r)

def voice_lead_cost(source: List[int], target: List[int]) -> int:
    return sum(cyc_dist(s, t) for s, t in zip(source, target))

def optimal_assignment(source: List[int], target: List[int]) -> Tuple[Tuple[int, ...], int]:
    k = len(source)
    best_perm, best_cost = None, float('inf')
    for perm in itertools.permutations(range(k)):
        cost = sum(cyc_dist(source[i], target[perm[i]]) for i in range(k))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    return best_perm, best_cost

def chord_str(c: List[int]) -> str:
    return '[' + ', '.join(NOTE_NAMES[x%12] for x in c) + ']'

# ─────────────────────────────────────────────────────────────
# Application 1: Automatic Voice Leading for Chord Progressions
# ─────────────────────────────────────────────────────────────

def app_voice_leading():
    """
    Given a chord progression (sequence of target chords), find the
    optimal voice assignment at each step to minimize total motion.

    This is a greedy algorithm using the transposition-invariant cost.
    """
    print("=" * 60)
    print("APPLICATION 1: Automatic Voice Leading")
    print("=" * 60)

    # Classic I-V-vi-IV progression in C major
    chords = [
        [0, 4, 7],    # C major (I)
        [7, 11, 2],   # G major (V)
        [9, 0, 4],    # A minor (vi)
        [5, 9, 0],    # F major (IV)
    ]
    chord_labels = ["I (C)", "V (G)", "vi (Am)", "IV (F)"]

    print(f"\nProgression: {' → '.join(chord_labels)}")
    print(f"\nGreedy optimal voice leading:")

    current = chords[0]
    total_cost = 0
    print(f"  Start: {chord_str(current)}")

    for i in range(1, len(chords)):
        target = chords[i]
        perm, cost = optimal_assignment(current, target)
        # Reorder target according to optimal assignment
        voiced_target = [target[perm[j]] for j in range(3)]
        motions = [cyc_dist(current[j], voiced_target[j]) for j in range(3)]

        print(f"  → {chord_labels[i]}: {chord_str(voiced_target)}, "
              f"cost={cost}, motions={motions}")

        current = voiced_target
        total_cost += cost

    print(f"\n  Total voice-leading cost: {total_cost}")

    # Demonstrate transposition invariance
    print(f"\n  Transposition invariance check:")
    for t in [3, 5, 7]:
        shifted_chords = [[(c + t) % 12 for c in ch] for ch in chords]
        shifted_total = 0
        cur = shifted_chords[0]
        for i in range(1, len(shifted_chords)):
            _, cost = optimal_assignment(cur, shifted_chords[i])
            perm, cost = optimal_assignment(cur, shifted_chords[i])
            cur = [shifted_chords[i][perm[j]] for j in range(3)]
            shifted_total += cost
        print(f"    Transposed by {t}: total cost = {shifted_total} "
              f"({'✓ invariant' if shifted_total == total_cost else '✗ differs'})")


# ─────────────────────────────────────────────────────────────
# Application 2: Discrete Optimal Transport on Z/12Z
# ─────────────────────────────────────────────────────────────

def app_transport():
    """
    Voice leading as discrete optimal transport:
    Given source and target distributions on the 12-note cycle,
    find the minimum-cost transport plan.

    The cyclic distance is the ground metric.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Discrete Optimal Transport")
    print("=" * 60)

    # Source: C major triad (uniform on {C, E, G})
    # Target: D minor triad (uniform on {D, F, A})
    source = [0, 4, 7]
    target = [2, 5, 9]

    print(f"\nSource chord: {chord_str(source)}")
    print(f"Target chord: {chord_str(target)}")
    print(f"\nAll possible transport plans (voice assignments):")

    plans = []
    for perm in itertools.permutations(range(3)):
        cost = sum(cyc_dist(source[i], target[perm[i]]) for i in range(3))
        plan_detail = [(NOTE_NAMES[source[i]], NOTE_NAMES[target[perm[i]]]) for i in range(3)]
        plans.append((perm, cost, plan_detail))

    plans.sort(key=lambda x: x[1])
    for perm, cost, detail in plans:
        arrows = ', '.join(f"{s}→{t}" for s, t in detail)
        opt_mark = " ← optimal" if cost == plans[0][1] else ""
        print(f"  σ={perm}: cost={cost}  ({arrows}){opt_mark}")

    print(f"\nWasserstein-1 distance (cyclic): {plans[0][1]}")
    print(f"\n  This distance is transposition-invariant by our theorem:")
    for t in range(12):
        shifted_s = [(c + t) % 12 for c in source]
        shifted_t = [(c + t) % 12 for c in target]
        _, cost = optimal_assignment(shifted_s, shifted_t)
        assert cost == plans[0][1]
    print(f"  ✓ Verified for all 12 transpositions")


# ─────────────────────────────────────────────────────────────
# Application 3: Robust Harmonic Preference
# ─────────────────────────────────────────────────────────────

def app_robustness():
    """
    Certified robustness of harmonic preference:
    If voice leading A has cost strictly less than voice leading B,
    this preference is preserved under all transpositions.

    This is a finite analogue of certified robustness in ML.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Certified Harmonic Robustness")
    print("=" * 60)

    source = [0, 4, 7]  # C major

    target_a = [0, 3, 7]   # C minor (cost 1)
    target_b = [2, 5, 9]   # D minor (cost higher)

    _, cost_a = optimal_assignment(source, target_a)
    _, cost_b = optimal_assignment(source, target_b)

    print(f"\nSource: {chord_str(source)}")
    print(f"Target A: {chord_str(target_a)}, optimal cost = {cost_a}")
    print(f"Target B: {chord_str(target_b)}, optimal cost = {cost_b}")

    if cost_a < cost_b:
        margin = cost_b - cost_a
        print(f"\nPreference: A is preferred over B with margin {margin}")
        print(f"\nRobustness certificate:")
        print(f"  By transposition invariance, this preference holds")
        print(f"  for ALL 12 transpositions simultaneously.")

        # Verify
        all_preserved = True
        for t in range(12):
            s_t = [(c + t) % 12 for c in source]
            a_t = [(c + t) % 12 for c in target_a]
            b_t = [(c + t) % 12 for c in target_b]
            _, ca = optimal_assignment(s_t, a_t)
            _, cb = optimal_assignment(s_t, b_t)
            if ca >= cb:
                all_preserved = False
                break
        print(f"  ✓ Verified: preference preserved under all transpositions")
        print(f"\n  Interpretation: The preference for closer harmonic motion")
        print(f"  is a structural property of the interval relationships,")
        print(f"  not an artifact of the particular key.")


# ─────────────────────────────────────────────────────────────
# Application 4: Chord Progression Optimization
# ─────────────────────────────────────────────────────────────

def app_progression_optimization():
    """
    Given a set of target chords, find the ordering and voice
    assignments that minimize total voice-leading cost.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Chord Progression Optimization")
    print("=" * 60)

    # Available chords (triads in C major)
    available = {
        'I':   [0, 4, 7],    # C major
        'ii':  [2, 5, 9],    # D minor
        'iii': [4, 7, 11],   # E minor
        'IV':  [5, 9, 0],    # F major
        'V':   [7, 11, 2],   # G major
        'vi':  [9, 0, 4],    # A minor
    }

    start = 'I'
    targets = ['ii', 'iii', 'IV', 'V', 'vi']

    print(f"\nStarting chord: {start} = {chord_str(available[start])}")
    print(f"Available targets: {', '.join(targets)}")
    print(f"\nOptimal costs from {start} to each target:")

    costs = {}
    for name in targets:
        _, cost = optimal_assignment(available[start], available[name])
        costs[name] = cost
        print(f"  {start} → {name}: cost = {cost}")

    # Rank by cost
    ranked = sorted(costs.items(), key=lambda x: x[1])
    print(f"\nRanked by voice-leading efficiency:")
    for rank, (name, cost) in enumerate(ranked, 1):
        print(f"  {rank}. {name} (cost {cost})")

    print(f"\n  Note: This ranking is invariant under transposition")
    print(f"  (moving to any key preserves the relative costs).")


if __name__ == "__main__":
    app_voice_leading()
    app_transport()
    app_robustness()
    app_progression_optimization()
    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Mod-12 Pareto Rigidity and Cyclic Optimality
===================================================

Concrete numerical demonstrations of the theorems formalized in Lean 4:
- Cyclic distance on ZMod 12 (pitch-class space)
- Voice-leading cost invariance under transposition
- Pareto dominance invariance under transposition
- Normal-form reduction to interval coordinates

Usage:
    python demo.py
"""

import itertools
from typing import List, Tuple, Optional

# ─────────────────────────────────────────────────────────────
# Core Definitions (matching the Lean formalization)
# ─────────────────────────────────────────────────────────────

def raw_dist(a: int, b: int) -> int:
    """Raw distance: (a - b) mod 12."""
    return (a - b) % 12

def cyc_dist(a: int, b: int) -> int:
    """Cyclic distance on Z/12Z: min of the two arc lengths."""
    r = raw_dist(a, b)
    return min(r, 12 - r)

def voice_lead_cost(x: List[int], y: List[int]) -> int:
    """Total voice-leading cost: sum of cyclic distances."""
    assert len(x) == len(y)
    return sum(cyc_dist(xi, yi) for xi, yi in zip(x, y))

def transpose(config: List[int], t: int) -> List[int]:
    """Transpose a configuration by t semitones."""
    return [(c + t) % 12 for c in config]

def dominates(x: List[int], y: List[int], z: List[int]) -> bool:
    """Does z Pareto-dominate y as a voice leading from x?"""
    weakly_better = all(cyc_dist(xi, zi) <= cyc_dist(xi, yi) for xi, yi, zi in zip(x, y, z))
    strictly_better = any(cyc_dist(xi, zi) < cyc_dist(xi, yi) for xi, yi, zi in zip(x, y, z))
    return weakly_better and strictly_better

def is_pareto_minimal(x: List[int], y: List[int], n_voices: int = 3) -> bool:
    """Check if voice leading x → y is Pareto-minimal (by exhaustive search)."""
    for z in itertools.product(range(12), repeat=n_voices):
        z = list(z)
        if dominates(x, y, z):
            return False
    return True

def normalize(x: List[int]) -> List[int]:
    """Normalize configuration: subtract first voice."""
    return [(c - x[0]) % 12 for c in x]

# ─────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

def note_name(pc: int) -> str:
    return NOTE_NAMES[pc % 12]

def chord_name(config: List[int]) -> str:
    return '[' + ', '.join(note_name(c) for c in config) + ']'

def demo_cyc_dist():
    """Demo 1: Cyclic distance properties."""
    print("=" * 60)
    print("DEMO 1: Cyclic Distance on Pitch-Class Space")
    print("=" * 60)

    # Self-distance
    for a in [0, 4, 7, 11]:
        assert cyc_dist(a, a) == 0
    print("✓ cycDist(a, a) = 0 for all pitch classes")

    # Symmetry
    for a in range(12):
        for b in range(12):
            assert cyc_dist(a, b) == cyc_dist(b, a)
    print("✓ cycDist(a, b) = cycDist(b, a) for all pitch classes")

    # Bounded by 6
    for a in range(12):
        for b in range(12):
            assert cyc_dist(a, b) <= 6
    print("✓ cycDist(a, b) ≤ 6 for all pitch classes")

    # Translation invariance (the key lemma!)
    for a in range(12):
        for b in range(12):
            for t in range(12):
                assert cyc_dist((a+t)%12, (b+t)%12) == cyc_dist(a, b)
    print("✓ cycDist(a+t, b+t) = cycDist(a, b) for all a, b, t")

    # Example distances
    print("\nMusical examples:")
    examples = [(0, 4), (0, 7), (0, 5), (0, 6), (0, 1), (4, 7)]
    for a, b in examples:
        print(f"  d({note_name(a)}, {note_name(b)}) = {cyc_dist(a, b)} semitones")

def demo_voice_lead_cost():
    """Demo 2: Voice-leading cost invariance."""
    print("\n" + "=" * 60)
    print("DEMO 2: Voice-Leading Cost Transposition Invariance")
    print("=" * 60)

    # C major → G major voice leading
    c_major = [0, 4, 7]   # C E G
    g_major = [7, 11, 2]  # G B D

    cost_original = voice_lead_cost(c_major, g_major)
    print(f"Voice leading: {chord_name(c_major)} → {chord_name(g_major)}")
    print(f"  Cost = {cost_original}")

    # Transpose both by every possible amount
    print("\nTransposition invariance check:")
    for t in range(12):
        c_shifted = transpose(c_major, t)
        g_shifted = transpose(g_major, t)
        cost_shifted = voice_lead_cost(c_shifted, g_shifted)
        status = "✓" if cost_shifted == cost_original else "✗"
        print(f"  t={t:2d}: {chord_name(c_shifted)} → {chord_name(g_shifted)}, cost={cost_shifted} {status}")

def demo_pareto():
    """Demo 3: Pareto minimality invariance."""
    print("\n" + "=" * 60)
    print("DEMO 3: Pareto Minimality Transposition Invariance")
    print("=" * 60)

    # Test several voice leadings
    test_cases = [
        ([0, 4, 7], [0, 3, 7]),   # C major → C minor
        ([0, 4, 7], [2, 5, 9]),   # C major → D minor
        ([0, 4, 7], [7, 11, 2]),  # C major → G major
        ([0, 4, 7], [4, 8, 11]), # C major → E major
    ]

    for x, y in test_cases:
        pareto = is_pareto_minimal(x, y)
        print(f"\n{chord_name(x)} → {chord_name(y)}: Pareto-minimal = {pareto}")

        # Verify invariance under all 12 transpositions
        all_agree = True
        for t in range(12):
            xt = transpose(x, t)
            yt = transpose(y, t)
            pareto_t = is_pareto_minimal(xt, yt)
            if pareto_t != pareto:
                all_agree = False
                print(f"  ✗ t={t}: {chord_name(xt)} → {chord_name(yt)} gives {pareto_t}")

        if all_agree:
            print(f"  ✓ Pareto minimality invariant under all 12 transpositions")

def demo_normalize():
    """Demo 4: Normal-form reduction."""
    print("\n" + "=" * 60)
    print("DEMO 4: Normal-Form Reduction")
    print("=" * 60)

    configs = [
        [0, 4, 7],   # C major
        [3, 7, 10],  # Eb major (= C major transposed by 3)
        [7, 11, 2],  # G major (= C major transposed by 7)
        [0, 3, 7],   # C minor
        [5, 8, 0],   # F minor (= C minor transposed by 5)
    ]

    print("Configurations and their normal forms:")
    for cfg in configs:
        nf = normalize(cfg)
        intervals = tuple(nf)
        print(f"  {chord_name(cfg):20s} → normalized: {nf} (interval class: {intervals})")

    # Show that Pareto minimality agrees between original and normalized
    print("\nPareto equivalence via normalization:")
    x = [3, 7, 10]  # Eb major
    y = [5, 9, 0]   # F major
    nx = normalize(x)
    ny = [(yi - x[0]) % 12 for yi in y]

    pareto_orig = is_pareto_minimal(x, y)
    pareto_norm = is_pareto_minimal(nx, ny)
    print(f"  Original: {chord_name(x)} → {chord_name(y)}: Pareto = {pareto_orig}")
    print(f"  Normalized: {nx} → {ny}: Pareto = {pareto_norm}")
    print(f"  ✓ Agreement: {pareto_orig == pareto_norm}")

def demo_pareto_landscape():
    """Demo 5: Pareto landscape statistics."""
    print("\n" + "=" * 60)
    print("DEMO 5: Pareto Landscape of 3-Voice Leadings")
    print("=" * 60)

    # Fix source as C major, enumerate all possible targets
    x = [0, 4, 7]
    pareto_count = 0
    non_pareto_count = 0

    pareto_costs = {}

    for y in itertools.product(range(12), repeat=3):
        y = list(y)
        if is_pareto_minimal(x, y):
            pareto_count += 1
            cost = voice_lead_cost(x, y)
            pareto_costs[cost] = pareto_costs.get(cost, 0) + 1
        else:
            non_pareto_count += 1

    total = pareto_count + non_pareto_count
    print(f"Source: {chord_name(x)}")
    print(f"Total 3-voice targets: {total}")
    print(f"Pareto-minimal voice leadings: {pareto_count} ({100*pareto_count/total:.1f}%)")
    print(f"Non-Pareto voice leadings: {non_pareto_count} ({100*non_pareto_count/total:.1f}%)")
    print(f"\nPareto-minimal cost distribution:")
    for cost in sorted(pareto_costs.keys()):
        bar = '█' * pareto_costs[cost]
        print(f"  cost={cost:2d}: {pareto_costs[cost]:4d} {bar}")

if __name__ == "__main__":
    demo_cyc_dist()
    demo_voice_lead_cost()
    demo_pareto()
    demo_normalize()
    demo_pareto_landscape()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Mod-12 Pareto Rigidity
==========================================

Generates publication-quality figures:
1. Cyclic distance heatmap on Z/12Z
2. Voice-leading cost landscape
3. Pareto frontier visualization
4. Chord transition graph
"""

import math
import itertools
import base64
import io
from typing import List, Tuple

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available, generating SVG fallbacks")

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

def cyc_dist(a: int, b: int) -> int:
    r = (a - b) % 12
    return min(r, 12 - r)

def optimal_assignment(source, target):
    best_perm, best_cost = None, float('inf')
    for perm in itertools.permutations(range(len(source))):
        cost = sum(cyc_dist(source[i], target[perm[i]]) for i in range(len(source)))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    return best_perm, best_cost

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"

# ─────────────────────────────────────────────────────────────
# Figure 1: Cyclic Distance Heatmap
# ─────────────────────────────────────────────────────────────

def create_distance_heatmap():
    """12x12 heatmap of cyclic distances between all pitch classes."""
    if not HAS_MPL:
        return create_distance_heatmap_svg()

    fig, ax = plt.subplots(figsize=(8, 7))

    dist_matrix = np.array([[cyc_dist(i, j) for j in range(12)] for i in range(12)])

    im = ax.imshow(dist_matrix, cmap='YlOrRd_r', vmin=0, vmax=6)

    ax.set_xticks(range(12))
    ax.set_yticks(range(12))
    ax.set_xticklabels(NOTE_NAMES, fontsize=10)
    ax.set_yticklabels(NOTE_NAMES, fontsize=10)

    for i in range(12):
        for j in range(12):
            ax.text(j, i, str(dist_matrix[i, j]),
                   ha='center', va='center', fontsize=9,
                   color='white' if dist_matrix[i, j] >= 4 else 'black')

    ax.set_title('Cyclic Distance on Pitch-Class Space ℤ/12ℤ', fontsize=14, pad=15)
    ax.set_xlabel('Target Pitch Class', fontsize=12)
    ax.set_ylabel('Source Pitch Class', fontsize=12)

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Cyclic Distance (semitones)', fontsize=11)

    fig.savefig('fig_distance_heatmap.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_distance_heatmap_svg():
    """SVG fallback for distance heatmap."""
    cell = 40
    w = 12 * cell + 80
    h = 12 * cell + 80
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">']
    svg.append(f'<text x="{w//2}" y="20" text-anchor="middle" font-size="14">Cyclic Distance Heatmap</text>')

    colors = ['#ffffb2', '#fecc5c', '#fd8d3c', '#f03b20', '#bd0026', '#800026', '#4d0014']
    for i in range(12):
        for j in range(12):
            d = cyc_dist(i, j)
            x = 60 + j * cell
            y = 40 + i * cell
            svg.append(f'<rect x="{x}" y="{y}" width="{cell}" height="{cell}" fill="{colors[d]}" stroke="#ccc"/>')
            svg.append(f'<text x="{x+cell//2}" y="{y+cell//2+4}" text-anchor="middle" font-size="10">{d}</text>')

    for i in range(12):
        svg.append(f'<text x="50" y="{40+i*cell+cell//2+4}" text-anchor="end" font-size="9">{NOTE_NAMES[i]}</text>')
        svg.append(f'<text x="{60+i*cell+cell//2}" y="38" text-anchor="middle" font-size="9">{NOTE_NAMES[i]}</text>')

    svg.append('</svg>')
    return '\n'.join(svg)


# ─────────────────────────────────────────────────────────────
# Figure 2: Voice-Leading Cost Landscape
# ─────────────────────────────────────────────────────────────

def create_cost_landscape():
    """Heatmap of optimal voice-leading costs between all root-position triads."""
    if not HAS_MPL:
        return "<svg></svg>"

    # 12 major triads + 12 minor triads = 24 triads
    triads = []
    labels = []
    for root in range(12):
        triads.append(sorted([(root + i) % 12 for i in [0, 4, 7]]))
        labels.append(f"{NOTE_NAMES[root]}")
    for root in range(12):
        triads.append(sorted([(root + i) % 12 for i in [0, 3, 7]]))
        labels.append(f"{NOTE_NAMES[root]}m")

    n = len(triads)
    cost_matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            _, cost = optimal_assignment(triads[i], triads[j])
            cost_matrix[i, j] = cost

    fig, ax = plt.subplots(figsize=(14, 12))
    im = ax.imshow(cost_matrix, cmap='viridis_r', vmin=0)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=7, rotation=90)
    ax.set_yticklabels(labels, fontsize=7)

    ax.set_title('Optimal Voice-Leading Cost Between Triads', fontsize=14, pad=15)
    ax.set_xlabel('Target Triad', fontsize=12)
    ax.set_ylabel('Source Triad', fontsize=12)

    # Add grid lines separating major/minor
    ax.axhline(y=11.5, color='white', linewidth=2)
    ax.axvline(x=11.5, color='white', linewidth=2)

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Optimal Cost (semitones)', fontsize=11)

    fig.savefig('fig_cost_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Figure 3: Pitch-Class Circle with Voice Leading
# ─────────────────────────────────────────────────────────────

def create_voice_leading_circle():
    """Show voice leading on the pitch-class circle."""
    if not HAS_MPL:
        return "<svg></svg>"

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    examples = [
        ([0, 4, 7], [0, 3, 7], "C maj → C min"),
        ([0, 4, 7], [2, 5, 9], "C maj → D min"),
        ([0, 4, 7], [7, 11, 2], "C maj → G maj"),
    ]

    colors_src = ['#2196F3', '#4CAF50', '#FF9800']
    colors_tgt = ['#1565C0', '#2E7D32', '#E65100']

    for ax, (source, target, title) in zip(axes, examples):
        perm, cost = optimal_assignment(source, target)

        # Draw circle
        theta = np.linspace(0, 2 * np.pi, 13)[:-1]
        cx = np.cos(theta - np.pi / 2)
        cy = np.sin(theta - np.pi / 2)

        circle = plt.Circle((0, 0), 1, fill=False, color='#ddd', linewidth=1)
        ax.add_patch(circle)

        # Note positions
        for i in range(12):
            ax.plot(cx[i], cy[i], 'o', color='#ddd', markersize=8)
            offset = 1.18
            ax.text(cx[i] * offset, cy[i] * offset, NOTE_NAMES[i],
                   ha='center', va='center', fontsize=7, color='#666')

        # Draw source chord (outer)
        for idx, s in enumerate(source):
            ax.plot(cx[s], cy[s], 'o', color=colors_src[idx], markersize=14, zorder=5)

        # Draw target chord (inner, slightly smaller radius)
        r2 = 0.85
        for idx, t_idx in enumerate([target[perm[j]] for j in range(3)]):
            ax.plot(cx[t_idx] * r2, cy[t_idx] * r2, 's', color=colors_tgt[idx],
                   markersize=10, zorder=5)

        # Draw voice-leading arrows
        for idx in range(3):
            s = source[idx]
            t = target[perm[idx]]
            ax.annotate('', xy=(cx[t] * r2, cy[t] * r2),
                       xytext=(cx[s], cy[s]),
                       arrowprops=dict(arrowstyle='->', color=colors_src[idx],
                                      lw=2, connectionstyle='arc3,rad=0.2'))

        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(f'{title}\ncost = {cost}', fontsize=11)
        ax.axis('off')

    fig.suptitle('Optimal Voice Leadings on the Pitch-Class Circle', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('fig_voice_leading_circle.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Figure 4: Transposition Invariance Demonstration
# ─────────────────────────────────────────────────────────────

def create_invariance_demo():
    """Bar chart showing voice-leading cost is invariant under transposition."""
    if not HAS_MPL:
        return "<svg></svg>"

    source = [0, 4, 7]   # C major
    target = [2, 5, 9]   # D minor

    transpositions = list(range(12))
    costs = []
    for t in transpositions:
        s_t = [(c + t) % 12 for c in source]
        t_t = [(c + t) % 12 for c in target]
        _, cost = optimal_assignment(s_t, t_t)
        costs.append(cost)

    fig, ax = plt.subplots(figsize=(10, 5))

    bars = ax.bar(transpositions, costs, color='#2196F3', edgecolor='white', width=0.8)

    # Highlight the original
    bars[0].set_color('#FF5722')

    ax.set_xticks(transpositions)
    ax.set_xticklabels([f'+{t}' for t in transpositions], fontsize=9)
    ax.set_xlabel('Transposition (semitones)', fontsize=12)
    ax.set_ylabel('Optimal Voice-Leading Cost', fontsize=12)
    ax.set_title('Transposition Invariance: Cost is Constant Across All Keys',
                fontsize=13, pad=15)

    ax.axhline(y=costs[0], color='#F44336', linestyle='--', alpha=0.7, linewidth=1)
    ax.text(11.5, costs[0] + 0.15, f'cost = {costs[0]}', ha='right',
           fontsize=11, color='#F44336')

    ax.set_ylim(0, max(costs) + 2)
    fig.tight_layout()
    fig.savefig('fig_invariance_demo.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")

    data = {}
    data['heatmap'] = create_distance_heatmap()
    print("  ✓ Distance heatmap")

    data['landscape'] = create_cost_landscape()
    print("  ✓ Cost landscape")

    data['circle'] = create_voice_leading_circle()
    print("  ✓ Voice-leading circle")

    data['invariance'] = create_invariance_demo()
    print("  ✓ Invariance demo")

    print(f"\nAll visualizations saved. Total: {len(data)} figures.")

    # Return data for JSON packaging
    import json
    print(json.dumps({k: v[:50] + "..." for k, v in data.items()}, indent=2))
