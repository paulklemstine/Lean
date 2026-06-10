#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Voice-Leading Transport Theory

Demonstrates:
1. Automatic species counterpoint generation
2. Chord progression optimization
3. Robustness analysis of musical arrangements
4. Comparison with traditional voice-leading rules
"""

import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Musical Constants
# ============================================================

NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']


def midi_to_name(midi: int) -> str:
    """Convert MIDI pitch to note name."""
    octave = midi // 12 - 1
    note = NOTE_NAMES[midi % 12]
    return f"{note}{octave}"


def ordered_vl(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    return abs(p[0] - q[0]) + abs(p[1] - q[1])


def crossing_vl(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    return abs(p[0] - q[1]) + abs(p[1] - q[0])


def w1_two_point(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    return min(ordered_vl(p, q), crossing_vl(p, q))


# ============================================================
# Application 1: Species Counterpoint Generation
# ============================================================

def generate_first_species(
    cantus: List[int],
    mode: str = "major"
) -> Tuple[List[int], int]:
    """
    Generate first-species counterpoint using transport optimization.

    Rules implemented:
    - Consonant intervals only (3, 4, 5, 7, 8, 9, 12 semitones)
    - No parallel fifths or octaves
    - Begin and end on perfect consonance (unison, 5th, or octave)
    - Minimize total W1 transport cost (= voice-leading cost)

    This demonstrates how optimal transport provides a principled
    objective for counterpoint that subsumes traditional smoothness rules.
    """
    n = len(cantus)
    consonances = [3, 4, 5, 7, 8, 9, 12]
    perfect = [0, 7, 12]  # unison, fifth, octave

    # Build admissible pitches
    possible = []
    for t, c in enumerate(cantus):
        if t == 0 or t == n - 1:
            # Begin/end on perfect consonance
            possible.append([c + iv for iv in perfect])
        else:
            possible.append([c + iv for iv in consonances])

    # DP with parallel-motion constraint
    INF = float('inf')
    cost = [dict() for _ in range(n)]
    parent = [dict() for _ in range(n)]

    for p in possible[0]:
        cost[0][p] = 0
        parent[0][p] = None

    for t in range(1, n):
        for p in possible[t]:
            best_cost = INF
            best_prev = None

            for prev_p in possible[t - 1]:
                # Check no parallel fifths/octaves
                prev_iv = prev_p - cantus[t - 1]
                curr_iv = p - cantus[t]
                if prev_iv == curr_iv and prev_iv in [7, 12]:
                    if (p - prev_p) * (cantus[t] - cantus[t - 1]) > 0:
                        continue  # parallel motion to perfect interval

                # Max leap of an octave
                if abs(p - prev_p) > 12:
                    continue

                tc = ordered_vl((cantus[t - 1], prev_p), (cantus[t], p))
                total = cost[t - 1].get(prev_p, INF) + tc

                if total < best_cost:
                    best_cost = total
                    best_prev = prev_p

            if best_cost < INF:
                cost[t][p] = best_cost
                parent[t][p] = best_prev

    if not cost[n - 1]:
        return [], -1

    best_final = min(cost[n - 1], key=cost[n - 1].get)
    cp = [0] * n
    cp[n - 1] = best_final
    for t in range(n - 2, -1, -1):
        cp[t] = parent[t + 1][cp[t + 1]]

    return cp, cost[n - 1][best_final]


# ============================================================
# Application 2: Chord Progression Voice Leading
# ============================================================

def optimal_chord_voicing(
    chord_roots: List[int],
    chord_types: List[str],
    initial_voicing: List[int]
) -> Tuple[List[List[int]], int]:
    """
    Find optimal voice leading through a chord progression.

    Uses k-voice sorted matching to minimize total transport cost.
    Each chord must contain the required pitch classes.

    This applies the sorted_matching_optimal theorem to find
    the smoothest realization of a harmonic progression.
    """
    CHORD_INTERVALS = {
        'major': [0, 4, 7],
        'minor': [0, 3, 7],
        'dim': [0, 3, 6],
        'aug': [0, 4, 8],
        'dom7': [0, 4, 7, 10],
    }

    k = len(initial_voicing)
    voicings = [initial_voicing[:]]
    total_cost = 0

    for t in range(1, len(chord_roots)):
        root = chord_roots[t]
        intervals = CHORD_INTERVALS[chord_types[t]]

        # Generate candidate pitches (within octave of current voicing)
        prev = np.array(voicings[-1])
        center = np.mean(prev)

        candidates = []
        for iv in intervals:
            pc = (root + iv) % 12
            # Find closest octave placement to center
            for octave in range(-1, 9):
                pitch = pc + octave * 12
                if abs(pitch - center) <= 12:
                    candidates.append(pitch)

        # Find best assignment of k voices to k pitches
        # Use sorted matching: sort both and pair
        best_cost = float('inf')
        best_voicing = None

        from itertools import combinations
        for combo in combinations(candidates, k):
            combo_sorted = sorted(combo)
            prev_sorted = sorted(voicings[-1])
            cost = sum(abs(a - b) for a, b in zip(prev_sorted, combo_sorted))
            if cost < best_cost:
                best_cost = cost
                best_voicing = list(combo_sorted)

        if best_voicing is not None:
            voicings.append(best_voicing)
            total_cost += best_cost

    return voicings, total_cost


# ============================================================
# Application 3: Robustness Analysis
# ============================================================

def robustness_analysis(
    cantus: List[int],
    cp: List[int],
    perturbation_range: int = 3
) -> Dict[str, float]:
    """
    Analyze how robust a counterpoint is to cantus perturbation.

    Uses the Lipschitz stability theorem to provide certified bounds
    and compares with empirical perturbation statistics.
    """
    n = len(cantus) - 1
    original_cost = sum(
        ordered_vl((cantus[i], cp[i]), (cantus[i + 1], cp[i + 1]))
        for i in range(n)
    )

    # Sample random perturbations
    np.random.seed(42)
    n_samples = 1000
    perturbed_costs = []

    for _ in range(n_samples):
        delta = np.random.randint(-perturbation_range, perturbation_range + 1,
                                  size=len(cantus))
        cf_pert = [c + d for c, d in zip(cantus, delta)]
        cost = sum(
            ordered_vl((cf_pert[i], cp[i]), (cf_pert[i + 1], cp[i + 1]))
            for i in range(n)
        )
        perturbed_costs.append(cost)

    perturbed_costs = np.array(perturbed_costs)
    diffs = np.abs(perturbed_costs - original_cost)

    # Theoretical bound
    lip_bound = 2 * n * perturbation_range

    return {
        'original_cost': original_cost,
        'mean_perturbed_cost': float(np.mean(perturbed_costs)),
        'max_actual_diff': int(np.max(diffs)),
        'lipschitz_bound': lip_bound,
        'bound_tight': float(np.max(diffs) / lip_bound) if lip_bound > 0 else 0,
        'mean_diff': float(np.mean(diffs)),
        'std_diff': float(np.std(diffs)),
    }


# ============================================================
# Application 4: Transport-Based Similarity Metric
# ============================================================

def melody_similarity(melody1: List[int], melody2: List[int]) -> float:
    """
    Compute similarity between two melodies using W1 transport.

    Treats each melody as a sequence of atomic measures and
    computes the average pairwise W1 distance.
    """
    n = min(len(melody1), len(melody2))
    if n == 0:
        return 0.0
    total = sum(abs(melody1[i] - melody2[i]) for i in range(n))
    return total / n


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: First-Species Counterpoint Generation")
    print("=" * 60)
    print()

    # Fux's famous cantus firmus in D Dorian
    # D4=62, E4=64, F4=65, D4=62, E4=64, F4=65, G4=67, F4=65, E4=64, D4=62
    fux_cantus = [62, 64, 65, 62, 64, 65, 67, 65, 64, 62]

    cp, cost = generate_first_species(fux_cantus)
    print(f"  Cantus:       {[midi_to_name(m) for m in fux_cantus]}")
    print(f"  Counterpoint: {[midi_to_name(m) for m in cp]}")
    print(f"  Intervals:    {[c - f for f, c in zip(fux_cantus, cp)]}")
    print(f"  Transport cost: {cost}")
    print()

    # Another cantus firmus
    simple_cantus = [60, 62, 64, 65, 67, 65, 64, 62, 60]
    cp2, cost2 = generate_first_species(simple_cantus)
    print(f"  Cantus:       {[midi_to_name(m) for m in simple_cantus]}")
    print(f"  Counterpoint: {[midi_to_name(m) for m in cp2]}")
    print(f"  Intervals:    {[c - f for f, c in zip(simple_cantus, cp2)]}")
    print(f"  Transport cost: {cost2}")
    print()

    print("=" * 60)
    print("APPLICATION 2: Chord Progression Voice Leading")
    print("=" * 60)
    print()

    # I-IV-V-I in C major
    roots = [60, 65, 67, 60]  # C, F, G, C
    types = ['major', 'major', 'major', 'major']
    init = [60, 64, 67]  # C major triad, root position

    voicings, total = optimal_chord_voicing(roots, types, init)
    print("  Progression: I - IV - V - I")
    for i, v in enumerate(voicings):
        print(f"    Chord {i}: {[midi_to_name(p) for p in v]} = {v}")
    print(f"  Total voice-leading cost: {total}")
    print()

    print("=" * 60)
    print("APPLICATION 3: Robustness Analysis")
    print("=" * 60)
    print()

    cantus = [60, 62, 64, 65, 67, 65, 64, 62, 60]
    cp_fixed = [64, 65, 67, 69, 71, 69, 67, 65, 64]

    for delta in [1, 2, 3]:
        results = robustness_analysis(cantus, cp_fixed, delta)
        print(f"  Perturbation range δ = {delta}:")
        print(f"    Original cost: {results['original_cost']}")
        print(f"    Max actual |ΔJ|: {results['max_actual_diff']}")
        print(f"    Lipschitz bound: {results['lipschitz_bound']}")
        print(f"    Tightness ratio: {results['bound_tight']:.3f}")
        print(f"    Mean |ΔJ|: {results['mean_diff']:.1f} ± {results['std_diff']:.1f}")
        print()

    print("=" * 60)
    print("APPLICATION 4: Transport-Based Melody Similarity")
    print("=" * 60)
    print()

    # Compare variations of a melody
    original = [60, 62, 64, 65, 67, 65, 64, 62, 60]
    transposed = [m + 7 for m in original]  # transposed up a fifth
    varied = [60, 63, 64, 66, 67, 66, 64, 63, 60]  # chromatic variation
    different = [67, 65, 64, 62, 60, 62, 64, 65, 67]  # inverted

    print(f"  Original:    {original}")
    print(f"  Transposed:  {transposed}")
    print(f"  Varied:      {varied}")
    print(f"  Inverted:    {different}")
    print()
    print(f"  Similarity(original, transposed): {melody_similarity(original, transposed):.1f}")
    print(f"  Similarity(original, varied):     {melody_similarity(original, varied):.1f}")
    print(f"  Similarity(original, inverted):   {melody_similarity(original, different):.1f}")


#!/usr/bin/env python3
"""
demo.py — Demonstrations of Voice-Leading as Discrete Optimal Transport

Concrete numerical examples showing:
1. The ordered matching optimality (Monge inequality)
2. W1 two-point cost computation
3. Path cost = sum of W1 costs for a counterpoint sequence
4. k-voice sorted matching optimality
5. Lipschitz stability under cantus perturbation
"""

import numpy as np
from itertools import permutations


def ordered_vl(p, q):
    """Ordered voice-leading cost: |p1-q1| + |p2-q2|."""
    return abs(p[0] - q[0]) + abs(p[1] - q[1])


def crossing_vl(p, q):
    """Crossing voice-leading cost: |p1-q2| + |p2-q1|."""
    return abs(p[0] - q[1]) + abs(p[1] - q[0])


def w1_two_point(p, q):
    """1-Wasserstein cost between two 2-atom measures."""
    return min(ordered_vl(p, q), crossing_vl(p, q))


def path_cost(cf, cp):
    """Total melodic path cost over a sequence of sonorities."""
    n = len(cf) - 1
    total = 0
    for i in range(n):
        total += ordered_vl((cf[i], cp[i]), (cf[i + 1], cp[i + 1]))
    return total


def sup_norm(f, g):
    """Sup-norm distance between two integer sequences."""
    return max(abs(a - b) for a, b in zip(f, g))


# ============================================================
# Demo 1: Ordered matching optimality (Monge inequality)
# ============================================================
print("=" * 60)
print("DEMO 1: Ordered Matching Optimality (Monge Inequality)")
print("=" * 60)
print()

test_cases = [
    (0, 4, 1, 5),   # close pairs
    (0, 7, 3, 10),   # wider intervals
    (-3, 2, -1, 6),  # negative pitches
    (0, 0, 0, 0),    # degenerate: unisons
    (5, 5, 3, 3),    # degenerate: both unisons
    (0, 12, 0, 12),  # octave to octave
]

for a1, b1, a2, b2 in test_cases:
    assert a1 <= b1 and a2 <= b2, "Order constraint violated"
    ov = ordered_vl((a1, b1), (a2, b2))
    cv = crossing_vl((a1, b1), (a2, b2))
    w1 = w1_two_point((a1, b1), (a2, b2))
    savings = cv - ov
    print(f"  ({a1},{b1}) → ({a2},{b2}):  ordered={ov}, crossing={cv}, "
          f"W1={w1}, savings={savings}")
    assert ov <= cv, "Monge inequality failed!"

print("\n✓ All cases satisfy ordered ≤ crossing (Monge inequality verified)\n")


# ============================================================
# Demo 2: Path Cost = Sum of W1 Costs
# ============================================================
print("=" * 60)
print("DEMO 2: Path Cost = Sum of W1 Costs")
print("=" * 60)
print()

# A simple counterpoint: C major cantus with parallel thirds
# MIDI-like pitch numbers: C4=60, D4=62, E4=64, F4=65, G4=67
cf = [60, 62, 64, 65, 67]  # cantus firmus
cp = [64, 65, 67, 69, 71]  # counterpoint (thirds above)

print(f"  Cantus firmus: {cf}")
print(f"  Counterpoint:  {cp}")
print()

# Verify ordering constraint
for i in range(len(cf)):
    assert cf[i] <= cp[i], f"Order violated at position {i}"

pc = path_cost(cf, cp)
w1_sum = sum(w1_two_point((cf[i], cp[i]), (cf[i + 1], cp[i + 1]))
             for i in range(len(cf) - 1))

print(f"  Path cost (ordered VL sum): {pc}")
print(f"  Sum of W1 costs:            {w1_sum}")
assert pc == w1_sum, "Path cost ≠ sum of W1!"
print("  ✓ They are equal!\n")

# Show step-by-step
for i in range(len(cf) - 1):
    s1 = (cf[i], cp[i])
    s2 = (cf[i + 1], cp[i + 1])
    print(f"  Step {i}→{i+1}: {s1} → {s2}, "
          f"orderedVL={ordered_vl(s1, s2)}, W1={w1_two_point(s1, s2)}")
print()


# ============================================================
# Demo 3: k-Voice Sorted Matching Optimality
# ============================================================
print("=" * 60)
print("DEMO 3: k-Voice Sorted Matching Optimality")
print("=" * 60)
print()

# 4-voice chord: SATB voicing
x = np.array([48, 55, 60, 64])  # C3, G3, C4, E4 (sorted)
y = np.array([47, 55, 59, 62])  # B2, G3, B3, D4 (sorted)

identity_cost = sum(abs(x[i] - y[i]) for i in range(4))
print(f"  Chord X (sorted): {list(x)}")
print(f"  Chord Y (sorted): {list(y)}")
print(f"  Identity matching cost: {identity_cost}")
print()

# Check all 4! = 24 permutations
min_cost = float('inf')
min_perm = None
all_costs = []

for perm in permutations(range(4)):
    cost = sum(abs(x[i] - y[perm[i]]) for i in range(4))
    all_costs.append((perm, cost))
    if cost < min_cost:
        min_cost = cost
        min_perm = perm

print(f"  Minimum cost over all {len(all_costs)} permutations: {min_cost}")
print(f"  Achieved by permutation: {min_perm}")
print(f"  Identity is optimal: {min_cost == identity_cost}")
assert identity_cost <= min_cost
print("  ✓ Sorted matching is optimal!\n")

# Show top 5 permutations by cost
all_costs.sort(key=lambda x: x[1])
print("  Top 5 matchings by cost:")
for perm, cost in all_costs[:5]:
    label = " ← IDENTITY" if perm == (0, 1, 2, 3) else ""
    print(f"    σ={perm}, cost={cost}{label}")
print()


# ============================================================
# Demo 4: Lipschitz Stability Under Cantus Perturbation
# ============================================================
print("=" * 60)
print("DEMO 4: Lipschitz Stability Under Cantus Perturbation")
print("=" * 60)
print()

cf1 = [60, 62, 64, 65, 67, 69, 71, 72]
cf2 = [61, 63, 64, 66, 67, 70, 71, 73]  # perturbed cantus
cp_fixed = [64, 65, 67, 69, 71, 72, 74, 76]

n = len(cf1) - 1  # number of transitions
delta = sup_norm(cf1, cf2)
bound = 2 * n * delta

pc1 = path_cost(cf1, cp_fixed)
pc2 = path_cost(cf2, cp_fixed)
actual_diff = abs(pc1 - pc2)

print(f"  Cantus 1: {cf1}")
print(f"  Cantus 2: {cf2}")
print(f"  Fixed CP: {cp_fixed}")
print(f"  n = {n} transitions")
print(f"  ‖cf₁ - cf₂‖∞ = {delta}")
print(f"  Path cost (cf₁): {pc1}")
print(f"  Path cost (cf₂): {pc2}")
print(f"  |pathCost(cf₁) - pathCost(cf₂)| = {actual_diff}")
print(f"  Lipschitz bound (2n·δ): {bound}")
print(f"  Bound holds: {actual_diff <= bound}")
assert actual_diff <= bound
print("  ✓ Lipschitz stability verified!\n")


# ============================================================
# Demo 5: Musical Application — Optimal Voice Leading Search
# ============================================================
print("=" * 60)
print("DEMO 5: Musical Application — Optimal Voice Leading")
print("=" * 60)
print()

# Given a cantus firmus, find the counterpoint that minimizes
# total transport cost while staying within a consonant interval set
cf_melody = [60, 62, 64, 65, 67, 65, 64, 62, 60]
consonant_intervals = [3, 4, 5, 7, 8, 9, 12]  # thirds, fourths, fifths, etc.

print(f"  Cantus firmus: {cf_melody}")
print(f"  Consonant intervals: {consonant_intervals}")
print()

# Dynamic programming to find optimal counterpoint
n_steps = len(cf_melody)


def find_optimal_cp(cf, intervals):
    """Find counterpoint minimizing total voice-leading cost."""
    # For each time step, possible CP notes
    possible = []
    for c in cf:
        possible.append([c + iv for iv in intervals])

    # DP: cost[t][j] = min cost to reach possible[t][j]
    n = len(cf)
    cost = [{} for _ in range(n)]
    parent = [{} for _ in range(n)]

    # Initialize
    for j, p in enumerate(possible[0]):
        cost[0][p] = 0
        parent[0][p] = None

    # Fill DP table
    for t in range(1, n):
        for j, p in enumerate(possible[t]):
            best_cost = float('inf')
            best_prev = None
            for prev_p in possible[t - 1]:
                c = cost[t - 1][prev_p] + ordered_vl(
                    (cf[t - 1], prev_p), (cf[t], p))
                if c < best_cost:
                    best_cost = c
                    best_prev = prev_p
            cost[t][p] = best_cost
            parent[t][p] = best_prev

    # Backtrack
    best_final = min(cost[n - 1], key=cost[n - 1].get)
    cp_opt = [0] * n
    cp_opt[n - 1] = best_final
    for t in range(n - 2, -1, -1):
        cp_opt[t] = parent[t + 1][cp_opt[t + 1]]

    return cp_opt, cost[n - 1][best_final]


optimal_cp, optimal_cost = find_optimal_cp(cf_melody, consonant_intervals)
print(f"  Optimal counterpoint: {optimal_cp}")
print(f"  Intervals:            {[cp - cf for cf, cp in zip(cf_melody, optimal_cp)]}")
print(f"  Total transport cost: {optimal_cost}")
print(f"  = Sum of W1 costs:    {sum(w1_two_point((cf_melody[i], optimal_cp[i]), (cf_melody[i+1], optimal_cp[i+1])) for i in range(len(cf_melody)-1))}")
print()

# Verify W1 = orderedVL for all steps
for i in range(len(cf_melody) - 1):
    s1 = (cf_melody[i], optimal_cp[i])
    s2 = (cf_melody[i + 1], optimal_cp[i + 1])
    assert cf_melody[i] <= optimal_cp[i] and cf_melody[i + 1] <= optimal_cp[i + 1]
    assert w1_two_point(s1, s2) == ordered_vl(s1, s2)
print("  ✓ W1 = orderedVL at every step (order-preserving matching is optimal)")
print()

print("=" * 60)
print("ALL DEMOS PASSED SUCCESSFULLY")
print("=" * 60)


#!/usr/bin/env python3
"""
visualizations.py — Generate figures for Voice-Leading Transport Theory

Produces PNG files for inclusion in the research paper and JSON package.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_monge_inequality():
    """Visualize the Monge inequality: ordered vs crossing matchings."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Example: (0, 7) → (3, 10)
    a1, b1 = 0, 7
    a2, b2 = 3, 10

    # Left: Ordered matching
    ax = axes[0]
    ax.set_title("Ordered Matching (Cost = 6)", fontsize=14, fontweight='bold')

    # Draw pitch lines
    for y in range(0, 12):
        ax.axhline(y=y, color='lightgray', linewidth=0.3)

    # Draw sonorities
    ax.plot([0, 0], [a1, b1], 'o-', color='steelblue', markersize=12, linewidth=2)
    ax.plot([1, 1], [a2, b2], 'o-', color='coral', markersize=12, linewidth=2)

    # Draw matching arrows
    ax.annotate('', xy=(1, a2), xytext=(0, a1),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.annotate('', xy=(1, b2), xytext=(0, b1),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))

    ax.text(0.5, (a1 + a2) / 2 - 0.5, f"|{a1}-{a2}|={abs(a1-a2)}",
            ha='center', fontsize=11, color='green')
    ax.text(0.5, (b1 + b2) / 2 + 0.5, f"|{b1}-{b2}|={abs(b1-b2)}",
            ha='center', fontsize=11, color='green')

    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-1, 11)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['Time t', 'Time t+1'])
    ax.set_ylabel('Pitch', fontsize=12)

    # Right: Crossing matching
    ax = axes[1]
    ax.set_title("Crossing Matching (Cost = 14)", fontsize=14, fontweight='bold')

    for y in range(0, 12):
        ax.axhline(y=y, color='lightgray', linewidth=0.3)

    ax.plot([0, 0], [a1, b1], 'o-', color='steelblue', markersize=12, linewidth=2)
    ax.plot([1, 1], [a2, b2], 'o-', color='coral', markersize=12, linewidth=2)

    ax.annotate('', xy=(1, b2), xytext=(0, a1),
                arrowprops=dict(arrowstyle='->', color='red', lw=2, linestyle='dashed'))
    ax.annotate('', xy=(1, a2), xytext=(0, b1),
                arrowprops=dict(arrowstyle='->', color='red', lw=2, linestyle='dashed'))

    ax.text(0.5, 5.5, f"|{a1}-{b2}|={abs(a1-b2)}",
            ha='center', fontsize=11, color='red')
    ax.text(0.5, 4, f"|{b1}-{a2}|={abs(b1-a2)}",
            ha='center', fontsize=11, color='red')

    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-1, 11)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['Time t', 'Time t+1'])

    fig.suptitle("Monge Inequality: Ordered Matching Is Always Optimal",
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_counterpoint_transport():
    """Visualize a counterpoint path as a sequence of transport steps."""
    cf = [60, 62, 64, 65, 67, 65, 64, 62, 60]
    cp = [64, 65, 67, 69, 71, 69, 67, 65, 64]

    fig, ax = plt.subplots(figsize=(14, 6))

    times = range(len(cf))

    # Plot voices
    ax.plot(times, cf, 'o-', color='steelblue', markersize=10,
            linewidth=2.5, label='Cantus Firmus', zorder=5)
    ax.plot(times, cp, 's-', color='coral', markersize=10,
            linewidth=2.5, label='Counterpoint', zorder=5)

    # Draw transport arrows between consecutive sonorities
    for i in range(len(cf) - 1):
        vl_cost = abs(cf[i+1] - cf[i]) + abs(cp[i+1] - cp[i])
        mid_y = (cf[i] + cf[i+1] + cp[i] + cp[i+1]) / 4
        ax.text(i + 0.5, mid_y - 2, f'W₁={vl_cost}',
                ha='center', fontsize=9, color='purple',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='lavender', alpha=0.8))

    # Shade intervals
    for i in times:
        ax.fill_between([i - 0.1, i + 0.1], cf[i], cp[i],
                       alpha=0.15, color='gold')

    ax.set_xlabel('Time Step', fontsize=13)
    ax.set_ylabel('MIDI Pitch', fontsize=13)
    ax.set_title('Counterpoint as Dynamic Optimal Transport',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Add total cost annotation
    total = sum(abs(cf[i+1] - cf[i]) + abs(cp[i+1] - cp[i])
                for i in range(len(cf) - 1))
    ax.text(0.98, 0.02, f'Total Transport Action = {total}',
            transform=ax.transAxes, ha='right', va='bottom',
            fontsize=13, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='lightyellow',
                     edgecolor='orange'))

    fig.tight_layout()
    return fig


def plot_lipschitz_stability():
    """Visualize Lipschitz stability under cantus perturbation."""
    np.random.seed(42)

    cf_orig = np.array([60, 62, 64, 65, 67, 65, 64, 62, 60])
    cp_fixed = np.array([64, 65, 67, 69, 71, 69, 67, 65, 64])

    def path_cost_np(cf, cp):
        return sum(abs(cf[i+1] - cf[i]) + abs(cp[i+1] - cp[i])
                   for i in range(len(cf) - 1))

    deltas = range(0, 6)
    n = len(cf_orig) - 1

    fig, ax = plt.subplots(figsize=(10, 6))

    for delta in deltas:
        if delta == 0:
            continue
        costs = []
        for _ in range(500):
            perturbation = np.random.randint(-delta, delta + 1, size=len(cf_orig))
            cf_pert = cf_orig + perturbation
            costs.append(path_cost_np(cf_pert, cp_fixed))

        orig_cost = path_cost_np(cf_orig, cp_fixed)
        diffs = np.abs(np.array(costs) - orig_cost)

        parts = ax.violinplot([diffs], positions=[delta], showmeans=True,
                             showextrema=True, widths=0.6)
        for pc in parts['bodies']:
            pc.set_facecolor('steelblue')
            pc.set_alpha(0.5)

    # Theoretical bound
    bound_x = np.array(range(0, 6))
    bound_y = 2 * n * bound_x
    ax.plot(bound_x, bound_y, 'r--', linewidth=2.5, label='Lipschitz bound: 2n·δ',
            zorder=10)

    ax.set_xlabel('Perturbation magnitude δ (sup-norm)', fontsize=13)
    ax.set_ylabel('|ΔJ| = |pathCost(cf₁,cp) - pathCost(cf₂,cp)|', fontsize=12)
    ax.set_title('Lipschitz Stability of Transport Action',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 5.5)

    fig.tight_layout()
    return fig


def plot_sorted_matching_k_voices():
    """Visualize k-voice sorted matching optimality."""
    from itertools import permutations

    x = np.array([48, 55, 60, 64])  # sorted chord 1
    y = np.array([47, 55, 59, 62])  # sorted chord 2

    # Compute all permutation costs
    all_costs = []
    for perm in permutations(range(4)):
        cost = sum(abs(x[i] - y[perm[i]]) for i in range(4))
        all_costs.append(cost)

    identity_cost = sum(abs(x[i] - y[i]) for i in range(4))

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: histogram of permutation costs
    ax = axes[0]
    bins = range(min(all_costs), max(all_costs) + 2)
    ax.hist(all_costs, bins=bins, color='steelblue', alpha=0.7,
            edgecolor='navy', align='left')
    ax.axvline(x=identity_cost, color='red', linewidth=2.5,
               linestyle='--', label=f'Sorted matching = {identity_cost}')
    ax.set_xlabel('Transport Cost', fontsize=13)
    ax.set_ylabel('Number of Permutations', fontsize=13)
    ax.set_title('Cost Distribution Over All 4! Matchings',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: the optimal matching visualization
    ax = axes[1]
    voice_labels = ['Bass', 'Tenor', 'Alto', 'Soprano']
    colors = ['#2c3e50', '#e74c3c', '#27ae60', '#f39c12']

    for i in range(4):
        ax.plot([0, 1], [x[i], y[i]], 'o-', color=colors[i],
                markersize=12, linewidth=2.5, label=f'{voice_labels[i]}')
        ax.text(-0.15, x[i], f'{x[i]}', ha='right', va='center', fontsize=11)
        ax.text(1.15, y[i], f'{y[i]}', ha='left', va='center', fontsize=11)

    ax.set_xlim(-0.3, 1.3)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['Chord 1', 'Chord 2'], fontsize=12)
    ax.set_ylabel('MIDI Pitch', fontsize=13)
    ax.set_title('Optimal (Sorted) Voice Leading',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    fig.suptitle('k-Voice Sorted Matching Optimality',
                 fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_monge_inequality()
    fig1.savefig('viz_monge_inequality.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_monge_inequality.png")

    fig2 = plot_counterpoint_transport()
    fig2.savefig('viz_counterpoint_transport.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_counterpoint_transport.png")

    fig3 = plot_lipschitz_stability()
    fig3.savefig('viz_lipschitz_stability.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_lipschitz_stability.png")

    fig4 = plot_sorted_matching_k_voices()
    fig4.savefig('viz_sorted_matching.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_sorted_matching.png")

    print("Done!")
