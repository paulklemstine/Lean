#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Voice-Leading Metric

Demonstrates applications of the sorted voice-leading metric to:
1. Music analysis: measuring harmonic similarity
2. Optimal transport: Wasserstein-1 computation
3. Data matching: minimum-cost assignment problems
4. Clustering: grouping chords by voice-leading proximity
"""

from typing import List, Tuple, Dict
from collections import defaultdict
import random
import math

from algorithms import voice_leading_cost, canonical_representative, chord_distance_matrix


# ═══════════════════════════════════════════════════════════
# APPLICATION 1: Music Analysis — Harmonic Progression Analysis
# ═══════════════════════════════════════════════════════════

def analyze_progression(progression: List[List[int]], names: List[str]) -> Dict:
    """Analyze a chord progression by voice-leading costs."""
    costs = []
    for i in range(len(progression) - 1):
        c = voice_leading_cost(progression[i], progression[i + 1])
        costs.append(c)

    return {
        "chords": names,
        "step_costs": costs,
        "total_cost": sum(costs),
        "average_cost": sum(costs) / len(costs) if costs else 0,
        "max_step": max(costs) if costs else 0,
        "smoothness": 1.0 / (1.0 + sum(costs) / len(costs)) if costs else 1.0,
    }


# ═══════════════════════════════════════════════════════════
# APPLICATION 2: Discrete Optimal Transport
# ═══════════════════════════════════════════════════════════

def wasserstein_1d(source_points: List[int], target_points: List[int]) -> int:
    """
    Compute the discrete 1D Wasserstein-1 distance between two
    equal-mass atomic measures.

    By the rearrangement theorem, this equals the sum of sorted
    coordinatewise differences.
    """
    return voice_leading_cost(source_points, target_points)


def earth_mover_demo():
    """Demonstrate earth mover's distance computation."""
    print("\n  Earth Mover's Distance Examples:")

    examples = [
        ("Identical distributions", [1, 2, 3], [1, 2, 3]),
        ("Uniform shift right", [0, 1, 2], [1, 2, 3]),
        ("Spread out", [5, 5, 5], [0, 5, 10]),
        ("Concentrate", [0, 5, 10], [5, 5, 5]),
    ]

    for name, src, tgt in examples:
        w1 = wasserstein_1d(src, tgt)
        print(f"    {name}")
        print(f"      Source: {src}  Target: {tgt}  W₁ = {w1}")


# ═══════════════════════════════════════════════════════════
# APPLICATION 3: Chord Classification
# ═══════════════════════════════════════════════════════════

def classify_chords(chords: List[List[int]]) -> Dict[Tuple[int, ...], List[int]]:
    """
    Classify chords into equivalence classes under voice permutation.

    Two chords are equivalent iff they have the same canonical (sorted) form.
    This is formally verified:
        sortChord_eq_iff_same_orbit
    """
    classes = defaultdict(list)
    for i, chord in enumerate(chords):
        canon = canonical_representative(chord)
        # Normalize to intervals from lowest note
        intervals = tuple(c - canon[0] for c in canon)
        classes[intervals].append(i)
    return dict(classes)


# ═══════════════════════════════════════════════════════════
# APPLICATION 4: Nearest-Chord Search
# ═══════════════════════════════════════════════════════════

def find_nearest_chords(
    query: List[int],
    database: List[List[int]],
    k: int = 5
) -> List[Tuple[int, int]]:
    """
    Find the k nearest chords to a query chord by voice-leading cost.

    Uses the sorting-based metric, so each distance computation is O(n log n).
    """
    distances = [(voice_leading_cost(query, chord), i) for i, chord in enumerate(database)]
    distances.sort()
    return distances[:k]


# ═══════════════════════════════════════════════════════════
# APPLICATION 5: Random Walk Analysis on Chord Space
# ═══════════════════════════════════════════════════════════

def chord_random_walk(
    start: List[int],
    steps: int,
    max_displacement: int = 3,
    n_voices: int = 3
) -> List[List[int]]:
    """Generate a random walk on chord space with bounded voice-leading cost."""
    path = [start[:]]
    current = start[:]
    for _ in range(steps):
        # Random perturbation bounded by max_displacement per voice
        perturbation = [random.randint(-max_displacement, max_displacement)
                        for _ in range(n_voices)]
        next_chord = [current[i] + perturbation[i] for i in range(n_voices)]
        path.append(next_chord)
        current = next_chord
    return path


# ═══════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Harmonic Progression Analysis")
    print("=" * 70)

    # Pachelbel Canon progression (simplified, 3 voices)
    pachelbel = [
        [57, 61, 64],  # A3 C#4 E4 (A major)
        [52, 56, 59],  # E3 G#3 B3 (E major)
        [54, 57, 61],  # F#3 A3 C#4 (F# minor)
        [49, 52, 56],  # C#3 E3 G#3 (C# minor)
        [50, 54, 57],  # D3 F#3 A3 (D major)
        [57, 61, 64],  # A3 C#4 E4 (A major)
        [50, 54, 57],  # D3 F#3 A3 (D major)
        [52, 56, 59],  # E3 G#3 B3 (E major)
    ]
    names = ["A", "E", "F#m", "C#m", "D", "A'", "D'", "E'"]

    result = analyze_progression(pachelbel, names)
    print(f"\n  Pachelbel Canon progression:")
    print(f"  Chords: {' → '.join(result['chords'])}")
    print(f"  Step costs: {result['step_costs']}")
    print(f"  Total cost: {result['total_cost']}")
    print(f"  Average step: {result['average_cost']:.1f}")
    print(f"  Smoothness: {result['smoothness']:.3f}")

    # Compare with a "bad" progression (large jumps)
    bad_prog = [
        [48, 52, 55],  # C3 E3 G3
        [72, 76, 79],  # C5 E5 G5
        [36, 40, 43],  # C2 E2 G2
        [84, 88, 91],  # C6 E6 G6
    ]
    bad_names = ["C3", "C5", "C2", "C6"]
    bad_result = analyze_progression(bad_prog, bad_names)
    print(f"\n  'Bad' progression (large jumps):")
    print(f"  Chords: {' → '.join(bad_result['chords'])}")
    print(f"  Step costs: {bad_result['step_costs']}")
    print(f"  Total cost: {bad_result['total_cost']}")
    print(f"  Smoothness: {bad_result['smoothness']:.3f}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Discrete Optimal Transport")
    print("=" * 70)
    earth_mover_demo()

    print()
    print("=" * 70)
    print("APPLICATION 3: Chord Classification by Orbit")
    print("=" * 70)

    # Various voicings of common chord types
    chords = [
        [60, 64, 67],  # C E G (root position)
        [64, 67, 72],  # E G C (1st inversion, different octave)
        [67, 60, 64],  # G C E (2nd inversion)
        [60, 63, 67],  # C Eb G (minor)
        [63, 67, 72],  # Eb G C (minor 1st inv)
        [60, 64, 67, 70],  # C E G Bb (dom7)
    ]
    chord_names = ["C(root)", "C(1st)", "C(2nd)", "Cm(root)", "Cm(1st)", "C7"]

    classes = classify_chords(chords)
    print(f"\n  {len(chords)} chords classified into {len(classes)} orbit classes:")
    for intervals, members in classes.items():
        member_names = [chord_names[i] for i in members]
        print(f"    Intervals {intervals}: {member_names}")

    print()
    print("=" * 70)
    print("APPLICATION 4: Nearest Chord Search")
    print("=" * 70)

    # Build a database of chords
    random.seed(123)
    database = [[random.randint(48, 72) for _ in range(3)] for _ in range(20)]
    query = [60, 64, 67]

    nearest = find_nearest_chords(query, database, k=5)
    print(f"\n  Query chord: {query}")
    print(f"  5 nearest chords in database:")
    for dist, idx in nearest:
        print(f"    [{idx:2d}] {database[idx]}  cost = {dist}")

    print()
    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrations of the Sorted Voice-Leading Metric

Shows concrete numerical examples of how sorting both chords and summing
coordinatewise absolute differences exactly computes the optimal voice-leading
cost (which normally requires searching over n! permutations).
"""

import itertools
import time
from typing import List, Tuple


def vl_cost_brute(x: List[int], y: List[int]) -> Tuple[int, list]:
    """Compute voice-leading cost by brute force over all n! permutations.
    Returns (cost, optimal_permutation)."""
    n = len(x)
    assert len(y) == n
    best_cost = float('inf')
    best_perm = None
    for perm in itertools.permutations(range(n)):
        cost = sum(abs(x[i] - y[perm[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)
    return best_cost, best_perm


def vl_cost_sorted(x: List[int], y: List[int]) -> int:
    """Compute voice-leading cost via sorting (O(n log n))."""
    sx = sorted(x)
    sy = sorted(y)
    return sum(abs(a - b) for a, b in zip(sx, sy))


def midi_to_note(midi: int) -> str:
    """Convert MIDI number to note name."""
    notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    octave = midi // 12 - 1
    note = notes[midi % 12]
    return f"{note}{octave}"


def chord_to_str(chord: List[int]) -> str:
    """Convert chord (MIDI numbers) to readable string."""
    return "[" + ", ".join(f"{midi_to_note(m)}({m})" for m in chord) + "]"


# ═══════════════════════════════════════════════════════════
# DEMO 1: Basic voice-leading cost computation
# ═══════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 1: Voice-Leading Cost — Brute Force vs Sorted Algorithm")
print("=" * 70)
print()

# Musical examples
examples = [
    ("C major → F major (triads)",
     [48, 52, 55],  # C3 E3 G3
     [53, 57, 60]), # F3 A3 C4

    ("C major → G7 (4 voices)",
     [48, 52, 55, 60],  # C3 E3 G3 C4
     [55, 59, 62, 65]), # G3 B3 D4 F4

    ("Close voicing → Spread voicing",
     [60, 64, 67],  # C4 E4 G4
     [48, 64, 79]), # C3 E4 G5

    ("Chromatic cluster → Spread chord",
     [60, 61, 62, 63],
     [48, 55, 67, 72]),
]

for name, x, y in examples:
    brute_cost, brute_perm = vl_cost_brute(x, y)
    sorted_cost = vl_cost_sorted(x, y)
    print(f"  {name}")
    print(f"    Source: {chord_to_str(x)}")
    print(f"    Target: {chord_to_str(y)}")
    print(f"    Brute-force cost: {brute_cost}  (optimal perm: {brute_perm})")
    print(f"    Sorted cost:      {sorted_cost}")
    print(f"    Match: {'✓' if brute_cost == sorted_cost else '✗ MISMATCH!'}")
    print()


# ═══════════════════════════════════════════════════════════
# DEMO 2: The Monge / Uncrossing Inequality
# ═══════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 2: The Monge Inequality (Uncrossing Lemma)")
print("=" * 70)
print()
print("  For a ≤ b and c ≤ d:")
print("  |a-c| + |b-d| ≤ |a-d| + |b-c|")
print()
print("  'Uncrossed pairing always beats crossed pairing.'")
print()

test_cases = [
    (1, 5, 2, 8),
    (0, 10, 3, 7),
    (-3, 4, -1, 6),
    (10, 10, 5, 5),  # edge case: a=b, c=d
]

for a, b, c, d in test_cases:
    uncrossed = abs(a - c) + abs(b - d)
    crossed = abs(a - d) + abs(b - c)
    print(f"  a={a:3d}, b={b:3d}, c={c:3d}, d={d:3d}  →  "
          f"uncrossed={uncrossed:3d}  crossed={crossed:3d}  "
          f"{'✓ uncrossed ≤ crossed' if uncrossed <= crossed else '✗ VIOLATION!'}")
print()


# ═══════════════════════════════════════════════════════════
# DEMO 3: Sorting is the canonical representative
# ═══════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 3: Canonical Representatives via Sorting")
print("=" * 70)
print()
print("  All permutations of a chord sort to the same canonical form.")
print()

chord = [67, 60, 64]  # G4 C4 E4

perms_seen = set()
for perm in itertools.permutations(chord):
    canon = tuple(sorted(perm))
    perms_seen.add(canon)
    print(f"    {str(list(perm)):20s}  →  sorted = {list(canon)}")

print(f"\n  All {len(list(itertools.permutations(chord)))} permutations map "
      f"to {'the same' if len(perms_seen) == 1 else 'DIFFERENT'} canonical form: "
      f"{list(perms_seen.pop())}")
print()


# ═══════════════════════════════════════════════════════════
# DEMO 4: Performance comparison
# ═══════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 4: Performance — O(n!) vs O(n log n)")
print("=" * 70)
print()

import random
random.seed(42)

for n in [4, 6, 8, 10]:
    x = [random.randint(40, 80) for _ in range(n)]
    y = [random.randint(40, 80) for _ in range(n)]

    if n <= 10:
        t0 = time.perf_counter()
        brute = vl_cost_brute(x, y)[0]
        t_brute = time.perf_counter() - t0
    else:
        brute = None
        t_brute = float('inf')

    t0 = time.perf_counter()
    fast = vl_cost_sorted(x, y)
    t_fast = time.perf_counter() - t0

    brute_str = f"{brute}" if brute is not None else "skipped (too slow)"
    match_str = "✓" if brute == fast else ("—" if brute is None else "✗")

    print(f"  n={n:2d}:  brute={brute_str:>10s} ({t_brute:.6f}s)  "
          f"sorted={fast:>6d} ({t_fast:.6f}s)  {match_str}")

# Now show the sorted algorithm on much larger inputs
print()
for n in [100, 1000, 10000, 100000]:
    x = [random.randint(0, 1000) for _ in range(n)]
    y = [random.randint(0, 1000) for _ in range(n)]
    t0 = time.perf_counter()
    cost = vl_cost_sorted(x, y)
    t_fast = time.perf_counter() - t0
    print(f"  n={n:6d}:  sorted_cost={cost:>10d}  time={t_fast:.6f}s")

print()


# ═══════════════════════════════════════════════════════════
# DEMO 5: Voice-leading as discrete optimal transport
# ═══════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 5: Connection to Discrete Optimal Transport (Wasserstein-1)")
print("=" * 70)
print()
print("  The voice-leading cost between two equal-size collections of pitches")
print("  is exactly the discrete Wasserstein-1 (earth mover's) distance")
print("  between the corresponding empirical measures on ℤ.")
print()

# Example: moving 4 'units of mass' from positions to positions
source = [2, 5, 8, 11]
target = [3, 6, 9, 12]

print(f"  Source positions: {source}")
print(f"  Target positions: {target}")
print(f"  Sorted cost (= W₁ distance): {vl_cost_sorted(source, target)}")
print(f"  Each unit moves 1 step right → total cost = {len(source)}")
print()

# Non-trivial example
source2 = [1, 1, 10, 10]
target2 = [2, 9, 3, 8]

brute2, perm2 = vl_cost_brute(source2, target2)
sorted2 = vl_cost_sorted(source2, target2)
print(f"  Source: {source2}  →  Target: {target2}")
print(f"  Sorted source: {sorted(source2)}  Sorted target: {sorted(target2)}")
print(f"  Optimal transport cost: {sorted2}")
print(f"  Brute force confirms:   {brute2}")
print()

print("=" * 70)
print("All demos complete. The sorting theorem is verified in all cases.")
print("=" * 70)


#!/usr/bin/env python3
"""
visualizations.py — Visualizations for Voice-Leading Geometry

Generates figures showing:
1. The Monge uncrossing principle
2. Performance scaling: brute force vs sorting
3. Voice-leading distance matrix heatmap
4. Chord space structure (2D projection)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools
import time
import random
import base64
import io

from algorithms import voice_leading_cost, optimal_voice_assignment, chord_distance_matrix


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ═══════════════════════════════════════════════════════════
# FIGURE 1: The Monge Uncrossing Principle
# ═══════════════════════════════════════════════════════════

def create_uncrossing_figure():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Crossed assignment
    source = [1, 4]
    target = [2, 5]

    ax1.set_title("Crossed Assignment\n|1−5| + |4−2| = 6", fontsize=14, fontweight='bold')
    for i, s in enumerate(source):
        ax1.plot(0, s, 'o', color='#2196F3', markersize=15, zorder=5)
        ax1.annotate(f'a={s}' if i == 0 else f'b={s}',
                     (0, s), textcoords="offset points", xytext=(-30, 0),
                     fontsize=12, ha='right')
    for i, t in enumerate(target):
        ax1.plot(1, t, 's', color='#FF5722', markersize=15, zorder=5)
        ax1.annotate(f'c={t}' if i == 1 else f'd={t}',
                     (1, t), textcoords="offset points", xytext=(15, 0),
                     fontsize=12)

    # Crossed lines
    ax1.plot([0, 1], [source[0], target[1]], 'r-', linewidth=2, alpha=0.7)
    ax1.plot([0, 1], [source[1], target[0]], 'r-', linewidth=2, alpha=0.7)
    ax1.set_xlim(-0.5, 1.5)
    ax1.set_ylim(0, 6)
    ax1.set_xticks([0, 1])
    ax1.set_xticklabels(['Source', 'Target'], fontsize=12)
    ax1.set_ylabel('Pitch', fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Uncrossed assignment
    ax2.set_title("Uncrossed Assignment\n|1−2| + |4−5| = 2", fontsize=14, fontweight='bold')
    for i, s in enumerate(source):
        ax2.plot(0, s, 'o', color='#2196F3', markersize=15, zorder=5)
        ax2.annotate(f'a={s}' if i == 0 else f'b={s}',
                     (0, s), textcoords="offset points", xytext=(-30, 0),
                     fontsize=12, ha='right')
    for i, t in enumerate(target):
        ax2.plot(1, t, 's', color='#FF5722', markersize=15, zorder=5)
        ax2.annotate(f'c={t}' if i == 0 else f'd={t}',
                     (1, t), textcoords="offset points", xytext=(15, 0),
                     fontsize=12)

    # Uncrossed lines
    ax2.plot([0, 1], [source[0], target[0]], 'g-', linewidth=2, alpha=0.7)
    ax2.plot([0, 1], [source[1], target[1]], 'g-', linewidth=2, alpha=0.7)
    ax2.set_xlim(-0.5, 1.5)
    ax2.set_ylim(0, 6)
    ax2.set_xticks([0, 1])
    ax2.set_xticklabels(['Source', 'Target'], fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("The Monge Uncrossing Principle", fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('fig_uncrossing.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════
# FIGURE 2: Performance Scaling
# ═══════════════════════════════════════════════════════════

def create_performance_figure():
    fig, ax = plt.subplots(figsize=(10, 6))

    ns_brute = list(range(2, 11))
    ns_sorted = list(range(2, 16))

    random.seed(42)

    times_brute = []
    for n in ns_brute:
        x = [random.randint(40, 80) for _ in range(n)]
        y = [random.randint(40, 80) for _ in range(n)]
        t0 = time.perf_counter()
        for _ in range(max(1, 100 // max(1, n))):
            _ = sum(min(sum(abs(x[i] - y[p[i]]) for i in range(n))
                        for p in itertools.permutations(range(n)))
                    for _ in range(1))
        t1 = time.perf_counter()
        times_brute.append((t1 - t0) / max(1, 100 // max(1, n)))

    times_sorted = []
    for n in ns_sorted:
        x = [random.randint(40, 80) for _ in range(n)]
        y = [random.randint(40, 80) for _ in range(n)]
        t0 = time.perf_counter()
        for _ in range(10000):
            _ = voice_leading_cost(x, y)
        t1 = time.perf_counter()
        times_sorted.append((t1 - t0) / 10000)

    ax.semilogy(ns_brute, times_brute, 'ro-', linewidth=2, markersize=8,
                label='Brute force O(n!)', zorder=5)
    ax.semilogy(ns_sorted, times_sorted, 'g^-', linewidth=2, markersize=8,
                label='Sorting O(n log n)', zorder=5)

    ax.set_xlabel('Number of voices (n)', fontsize=14)
    ax.set_ylabel('Time per computation (seconds)', fontsize=14)
    ax.set_title('Performance: Brute Force vs Sorting Algorithm', fontsize=16, fontweight='bold')
    ax.legend(fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(2, 16))

    fig.tight_layout()
    fig.savefig('fig_performance.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════
# FIGURE 3: Voice-Leading Distance Matrix
# ═══════════════════════════════════════════════════════════

def create_distance_matrix_figure():
    # Common chords
    chords = {
        'C': [60, 64, 67],
        'Dm': [62, 65, 69],
        'Em': [64, 67, 71],
        'F': [65, 69, 72],
        'G': [67, 71, 74],
        'Am': [69, 72, 76],
        'Bdim': [71, 74, 77],
    }

    names = list(chords.keys())
    chord_list = list(chords.values())
    matrix = chord_distance_matrix(chord_list)

    fig, ax = plt.subplots(figsize=(8, 7))

    im = ax.imshow(matrix, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(len(names)))
    ax.set_yticks(range(len(names)))
    ax.set_xticklabels(names, fontsize=12, fontweight='bold')
    ax.set_yticklabels(names, fontsize=12, fontweight='bold')

    # Add text annotations
    for i in range(len(names)):
        for j in range(len(names)):
            color = 'white' if matrix[i][j] > max(max(r) for r in matrix) * 0.6 else 'black'
            ax.text(j, i, str(matrix[i][j]),
                    ha='center', va='center', fontsize=14, color=color, fontweight='bold')

    ax.set_title('Voice-Leading Distance Matrix\n(C major scale triads)', fontsize=16, fontweight='bold')
    plt.colorbar(im, label='Voice-leading cost (semitones)', shrink=0.8)

    fig.tight_layout()
    fig.savefig('fig_distance_matrix.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════
# FIGURE 4: Optimal Assignment Visualization
# ═══════════════════════════════════════════════════════════

def create_assignment_figure():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    examples = [
        ("Close voicing → Close", [60, 64, 67], [65, 69, 72]),
        ("Close → Spread", [60, 64, 67], [48, 64, 79]),
        ("Random voicings", [55, 70, 62], [68, 50, 75]),
    ]

    for ax, (title, source, target) in zip(axes, examples):
        assignment = optimal_voice_assignment(source, target)
        cost = voice_leading_cost(source, target)

        ax.set_title(f"{title}\nCost = {cost}", fontsize=12, fontweight='bold')

        for i in range(len(source)):
            j = assignment[i]
            color = plt.cm.Set2(i / len(source))
            ax.plot([0, 1], [source[i], target[j]], '-', color=color, linewidth=2.5, alpha=0.7)
            ax.plot(0, source[i], 'o', color=color, markersize=14, zorder=5)
            ax.plot(1, target[j], 's', color=color, markersize=14, zorder=5)
            ax.annotate(f'{source[i]}', (0, source[i]),
                        textcoords="offset points", xytext=(-20, 0),
                        fontsize=10, ha='right', color=color, fontweight='bold')
            ax.annotate(f'{target[j]}', (1, target[j]),
                        textcoords="offset points", xytext=(10, 0),
                        fontsize=10, color=color, fontweight='bold')

        ax.set_xticks([0, 1])
        ax.set_xticklabels(['Source', 'Target'], fontsize=11)
        ax.set_ylabel('MIDI pitch', fontsize=11)
        ax.grid(True, alpha=0.2)

    fig.suptitle('Optimal Voice Assignments', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('fig_assignments.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════
# Generate all figures
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    b64_uncrossing = create_uncrossing_figure()
    print("  ✓ Uncrossing figure saved to fig_uncrossing.png")

    b64_performance = create_performance_figure()
    print("  ✓ Performance figure saved to fig_performance.png")

    b64_matrix = create_distance_matrix_figure()
    print("  ✓ Distance matrix figure saved to fig_distance_matrix.png")

    b64_assignment = create_assignment_figure()
    print("  ✓ Assignment figure saved to fig_assignments.png")

    print("\nAll visualizations generated successfully.")
