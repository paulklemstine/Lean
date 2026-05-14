#!/usr/bin/env python3
"""
Applications of Voice-Leading Geometry

Real-world applications demonstrating how the verified mathematical framework
enables practical tools for music analysis and composition.

Applications:
1. Optimal voice leading between any two chords
2. Smooth harmonic progression planning (shortest path)
3. Chord similarity clustering
4. Harmonic tension analysis via cost gradients
"""

from itertools import permutations
from typing import List, Tuple, Dict
from collections import defaultdict
import heapq


def sorted_vl_cost(x: List[int], y: List[int]) -> Tuple[int, List[int]]:
    """Optimal voice-leading cost via sorted matching (O(n log n))."""
    n = len(x)
    x_idx = sorted(enumerate(x), key=lambda p: p[1])
    y_idx = sorted(enumerate(y), key=lambda p: p[1])
    cost = sum(abs(x_idx[i][1] - y_idx[i][1]) for i in range(n))
    perm = [0] * n
    for i in range(n):
        perm[x_idx[i][0]] = y_idx[i][0]
    return cost, perm


# ═══════════════════════════════════════════════════════════════════════════════
# Application 1: Optimal Voice Leading
# ═══════════════════════════════════════════════════════════════════════════════

def optimal_voice_leading(source: Dict[str, int], target: Dict[str, int]) -> None:
    """
    Given two chords with named voices, find the smoothest voice leading.

    This directly applies the sorted matching optimality theorem: after sorting
    pitches, the identity matching minimizes total motion.
    """
    print("\n  APPLICATION 1: Optimal Voice Leading")
    print("  " + "─" * 50)

    voice_names = list(source.keys())
    x = list(source.values())
    y = list(target.values())
    target_names = list(target.keys())

    cost, perm = sorted_vl_cost(x, y)

    print(f"\n  Source chord: {source}")
    print(f"  Target chord: {target}")
    print(f"\n  Optimal total motion: {cost} semitones")
    print(f"\n  Voice assignments:")
    for i, vn in enumerate(voice_names):
        target_voice = target_names[perm[i]]
        motion = y[perm[i]] - x[i]
        direction = "↑" if motion > 0 else ("↓" if motion < 0 else "—")
        print(f"    {vn} ({x[i]}) → {target_voice} ({y[perm[i]]})  "
              f"{direction} {abs(motion)} semitones")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 2: Smooth Harmonic Progression Planning
# ═══════════════════════════════════════════════════════════════════════════════

def plan_progression(corpus: Dict[str, List[int]],
                     start: str, end: str,
                     max_step_cost: int = 15) -> None:
    """
    Find the smoothest harmonic path from start to end chord,
    using only transitions with cost ≤ max_step_cost.

    Uses Dijkstra's algorithm on the chord graph. The triangle inequality
    guarantees that the direct cost is always ≤ the path cost, so this
    finds genuinely useful intermediate harmonies.
    """
    print(f"\n  APPLICATION 2: Harmonic Path Planning")
    print("  " + "─" * 50)
    print(f"\n  Finding smoothest path: {start} → {end}")
    print(f"  Maximum step cost: {max_step_cost} semitones")

    names = list(corpus.keys())

    # Dijkstra
    dist = {n: float('inf') for n in names}
    prev = {n: None for n in names}
    dist[start] = 0
    pq = [(0, start)]

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist[u]:
            continue
        for v in names:
            if v != u:
                step_cost = sorted_vl_cost(corpus[u], corpus[v])[0]
                if step_cost <= max_step_cost:
                    new_dist = d + step_cost
                    if new_dist < dist[v]:
                        dist[v] = new_dist
                        prev[v] = u
                        heapq.heappush(pq, (new_dist, v))

    if dist[end] == float('inf'):
        print(f"\n  No path found with step cost ≤ {max_step_cost}!")
        return

    # Reconstruct path
    path = []
    current = end
    while current:
        path.append(current)
        current = prev[current]
    path.reverse()

    direct_cost = sorted_vl_cost(corpus[start], corpus[end])[0]

    print(f"\n  Direct cost: {direct_cost} semitones")
    print(f"  Path cost:   {dist[end]} semitones")
    print(f"\n  Optimal progression ({len(path)} chords):")
    for i, chord in enumerate(path):
        if i > 0:
            step = sorted_vl_cost(corpus[path[i-1]], corpus[path[i]])[0]
            print(f"    {'':>4}  ↓  (cost: {step})")
        print(f"    [{i+1}] {chord:>10}: {corpus[chord]}")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 3: Chord Similarity Clustering
# ═══════════════════════════════════════════════════════════════════════════════

def cluster_chords(corpus: Dict[str, List[int]], threshold: int = 10) -> None:
    """
    Cluster chords by proximity in voice-leading cost space.

    Uses single-linkage clustering: two clusters merge if any pair
    of their members has cost ≤ threshold.
    """
    print(f"\n  APPLICATION 3: Chord Similarity Clustering")
    print("  " + "─" * 50)
    print(f"\n  Clustering threshold: {threshold} semitones")

    names = list(corpus.keys())

    # Union-Find
    parent = {n: n for n in names}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(a, b):
        parent[find(a)] = find(b)

    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                cost = sorted_vl_cost(corpus[n1], corpus[n2])[0]
                if cost <= threshold:
                    union(n1, n2)

    clusters = defaultdict(list)
    for n in names:
        clusters[find(n)].append(n)

    print(f"\n  Found {len(clusters)} cluster(s):")
    for i, (_, members) in enumerate(clusters.items()):
        print(f"\n    Cluster {i+1}: {members}")
        if len(members) > 1:
            for a in members:
                for b in members:
                    if a < b:
                        c = sorted_vl_cost(corpus[a], corpus[b])[0]
                        print(f"      {a} ↔ {b}: cost {c}")


# ═══════════════════════════════════════════════════════════════════════════════
# Application 4: Harmonic Tension Analysis
# ═══════════════════════════════════════════════════════════════════════════════

def analyze_tension(progression: List[Tuple[str, List[int]]]) -> None:
    """
    Analyze the harmonic tension profile of a chord progression.

    Uses voice-leading cost as a proxy for perceived harmonic "distance"
    or tension. Higher costs = more dramatic harmonic motion.
    """
    print(f"\n  APPLICATION 4: Harmonic Tension Analysis")
    print("  " + "─" * 50)

    print(f"\n  Progression: {' → '.join(name for name, _ in progression)}")
    print()

    total_cost = 0
    costs = []
    for i in range(len(progression) - 1):
        n1, c1 = progression[i]
        n2, c2 = progression[i + 1]
        cost = sorted_vl_cost(c1, c2)[0]
        costs.append(cost)
        total_cost += cost

    max_cost = max(costs) if costs else 1
    for i, (cost) in enumerate(costs):
        n1, _ = progression[i]
        n2, _ = progression[i + 1]
        bar_len = int(40 * cost / max_cost) if max_cost > 0 else 0
        bar = "█" * bar_len
        print(f"  {n1:>10} → {n2:<10} cost={cost:>3}  {bar}")

    print(f"\n  Total harmonic motion: {total_cost} semitones")
    print(f"  Average step cost:    {total_cost / len(costs):.1f} semitones")
    print(f"  Peak tension:         {max(costs)} semitones "
          f"(step {costs.index(max(costs)) + 1})")


# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "━" * 60)
    print("  VOICE-LEADING GEOMETRY: Real-World Applications")
    print("━" * 60)

    # Corpus of common chords
    corpus = {
        "C maj":   [48, 52, 55, 60],
        "C min":   [48, 51, 55, 60],
        "Dm7":     [50, 53, 57, 60],
        "Em":      [52, 55, 59, 64],
        "F maj":   [53, 57, 60, 65],
        "G7":      [55, 59, 62, 65],
        "Am":      [45, 48, 52, 57],
        "Bdim":    [47, 50, 53, 59],
        "Eb maj":  [51, 55, 58, 63],
        "Ab maj":  [44, 48, 51, 56],
    }

    # App 1: Optimal voice leading
    optimal_voice_leading(
        {"Soprano": 60, "Alto": 55, "Tenor": 52, "Bass": 48},
        {"Soprano": 65, "Alto": 60, "Tenor": 57, "Bass": 53}
    )

    # App 2: Path planning
    plan_progression(corpus, "C maj", "Ab maj", max_step_cost=12)

    # App 3: Clustering
    cluster_chords(corpus, threshold=8)

    # App 4: Tension analysis (I-vi-IV-V-I in C major)
    analyze_tension([
        ("C maj", [48, 52, 55, 60]),
        ("Am",    [45, 48, 52, 57]),
        ("F maj", [53, 57, 60, 65]),
        ("G7",    [55, 59, 62, 65]),
        ("C maj", [48, 52, 55, 60]),
    ])

    print("\n" + "━" * 60)
    print("  All applications completed successfully.")
    print("━" * 60)


#!/usr/bin/env python3
"""
Voice-Leading Geometry: Computational Demonstrations

This script demonstrates the key theorems about four-voice voice-leading cost:
1. Triangle inequality (metric structure)
2. Permutation invariance (symmetry under voice relabeling)
3. Sorted matching optimality (identity matching is optimal for sorted chords)
4. The atomic uncrossing lemma

All computations mirror the formally verified results.
"""

from itertools import permutations
from typing import List, Tuple
import math


# ─── Core Definitions ────────────────────────────────────────────────────────

def perm_cost(x: List[int], y: List[int], sigma: List[int]) -> int:
    """Cost of a specific voice assignment: sum of |x[i] - y[sigma[i]]|."""
    return sum(abs(x[i] - y[sigma[i]]) for i in range(len(x)))


def vl_cost4(x: List[int], y: List[int]) -> int:
    """Optimal 4-voice voice-leading cost: min over all permutations."""
    return min(perm_cost(x, y, list(p)) for p in permutations(range(4)))


def optimal_perm(x: List[int], y: List[int]) -> Tuple[List[int], int]:
    """Find the optimal permutation and its cost."""
    best_cost = float('inf')
    best_perm = None
    for p in permutations(range(4)):
        c = perm_cost(x, y, list(p))
        if c < best_cost:
            best_cost = c
            best_perm = list(p)
    return best_perm, best_cost


# ─── Demo 1: Triangle Inequality ─────────────────────────────────────────────

def demo_triangle_inequality():
    """Demonstrate vlCost4(x,z) ≤ vlCost4(x,y) + vlCost4(y,z)."""
    print("=" * 70)
    print("DEMO 1: Triangle Inequality for Voice-Leading Cost")
    print("=" * 70)

    # Musical example: C major → F major → G7
    x = [48, 52, 55, 60]  # C major (C3 E3 G3 C4)
    y = [53, 57, 60, 65]  # F major (F3 A3 C4 F4)
    z = [55, 59, 62, 65]  # G7 (G3 B3 D4 F4)

    cost_xy = vl_cost4(x, y)
    cost_yz = vl_cost4(y, z)
    cost_xz = vl_cost4(x, z)

    print(f"\n  x = {x}  (C major)")
    print(f"  y = {y}  (F major)")
    print(f"  z = {z}  (G7)")
    print(f"\n  vlCost4(x, y) = {cost_xy}")
    print(f"  vlCost4(y, z) = {cost_yz}")
    print(f"  vlCost4(x, z) = {cost_xz}")
    print(f"\n  Triangle inequality: {cost_xz} ≤ {cost_xy} + {cost_yz} = {cost_xy + cost_yz}")
    print(f"  Verified: {cost_xz <= cost_xy + cost_yz} ✓")

    # Random stress test
    import random
    random.seed(42)
    violations = 0
    n_tests = 10000
    for _ in range(n_tests):
        x = [random.randint(-20, 80) for _ in range(4)]
        y = [random.randint(-20, 80) for _ in range(4)]
        z = [random.randint(-20, 80) for _ in range(4)]
        if vl_cost4(x, z) > vl_cost4(x, y) + vl_cost4(y, z):
            violations += 1

    print(f"\n  Random stress test ({n_tests} triples): {violations} violations")
    print()


# ─── Demo 2: Permutation Invariance ──────────────────────────────────────────

def demo_permutation_invariance():
    """Demonstrate vlCost4(x∘τ₁, y∘τ₂) = vlCost4(x, y)."""
    print("=" * 70)
    print("DEMO 2: Permutation Invariance of Voice-Leading Cost")
    print("=" * 70)

    x = [48, 52, 55, 60]
    y = [53, 57, 60, 65]
    base_cost = vl_cost4(x, y)

    print(f"\n  x = {x}")
    print(f"  y = {y}")
    print(f"  vlCost4(x, y) = {base_cost}")

    # Test several permutations
    test_perms = [
        ([1, 0, 2, 3], [0, 1, 2, 3]),
        ([3, 2, 1, 0], [0, 1, 2, 3]),
        ([0, 1, 2, 3], [2, 3, 0, 1]),
        ([1, 2, 3, 0], [3, 0, 1, 2]),
        ([2, 0, 3, 1], [1, 3, 0, 2]),
    ]

    print(f"\n  Applying voice permutations τ₁, τ₂:")
    for tau1, tau2 in test_perms:
        x_perm = [x[tau1[i]] for i in range(4)]
        y_perm = [y[tau2[i]] for i in range(4)]
        cost = vl_cost4(x_perm, y_perm)
        print(f"    τ₁={tau1}, τ₂={tau2} → vlCost4 = {cost}  {'✓' if cost == base_cost else '✗'}")
    print()


# ─── Demo 3: Sorted Matching Optimality ──────────────────────────────────────

def demo_sorted_optimality():
    """Demonstrate that sorted chords have identity matching as optimal."""
    print("=" * 70)
    print("DEMO 3: Sorted Matching Optimality (Discrete Monge Theorem)")
    print("=" * 70)

    examples = [
        ([40, 50, 60, 70], [42, 48, 63, 72]),
        ([0, 10, 20, 30], [5, 15, 25, 35]),
        ([10, 20, 30, 40], [11, 19, 31, 39]),
        ([0, 0, 0, 0], [1, 2, 3, 4]),
    ]

    for x, y in examples:
        opt_p, opt_cost = optimal_perm(x, y)
        id_cost = perm_cost(x, y, [0, 1, 2, 3])
        print(f"\n  x = {x}")
        print(f"  y = {y}")
        print(f"  Identity matching cost:   {id_cost}")
        print(f"  Optimal matching cost:    {opt_cost}  (perm = {opt_p})")
        print(f"  Identity is optimal:      {id_cost == opt_cost} ✓")
    print()


# ─── Demo 4: Uncrossing Lemma ────────────────────────────────────────────────

def demo_uncrossing():
    """Demonstrate the atomic uncrossing inequality."""
    print("=" * 70)
    print("DEMO 4: Atomic Uncrossing Lemma")
    print("=" * 70)
    print("\n  For a ≤ b, c ≤ d:")
    print("  |a-c| + |b-d| ≤ |a-d| + |b-c|  (uncrossed ≤ crossed)")

    examples = [
        (0, 10, 3, 8),
        (-5, 5, -3, 7),
        (0, 0, 0, 0),
        (1, 100, 50, 60),
        (-10, 20, -5, 15),
    ]

    for a, b, c, d in examples:
        uncrossed = abs(a - c) + abs(b - d)
        crossed = abs(a - d) + abs(b - c)
        print(f"\n  a={a:>4}, b={b:>4}, c={c:>4}, d={d:>4}")
        print(f"    uncrossed = |{a}-{c}| + |{b}-{d}| = {uncrossed}")
        print(f"    crossed   = |{a}-{d}| + |{b}-{c}| = {crossed}")
        print(f"    {uncrossed} ≤ {crossed}: {uncrossed <= crossed} ✓")
    print()


# ─── Demo 5: Chord Transition Cost Table ─────────────────────────────────────

def demo_cost_table():
    """Compute pairwise costs for a small corpus of chord types."""
    print("=" * 70)
    print("DEMO 5: Pairwise Voice-Leading Cost Table")
    print("=" * 70)

    chords = {
        "C maj":  [48, 52, 55, 60],
        "C min":  [48, 51, 55, 60],
        "F maj":  [53, 57, 60, 65],
        "G dom7": [55, 59, 62, 65],
        "A min":  [45, 48, 52, 57],
        "D min7": [50, 53, 57, 62],
        "E maj":  [52, 56, 59, 64],
    }

    names = list(chords.keys())
    print(f"\n  {'':>8}", end="")
    for n in names:
        print(f" {n:>7}", end="")
    print()

    for n1 in names:
        print(f"  {n1:>8}", end="")
        for n2 in names:
            cost = vl_cost4(chords[n1], chords[n2])
            print(f" {cost:>7}", end="")
        print()

    # Find minimum nonzero cost
    min_cost = float('inf')
    min_pair = None
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i != j:
                c = vl_cost4(chords[n1], chords[n2])
                if c < min_cost:
                    min_cost = c
                    min_pair = (n1, n2)

    print(f"\n  Closest pair: {min_pair[0]} → {min_pair[1]}, cost = {min_cost}")

    # Diameter
    max_cost = 0
    max_pair = None
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            c = vl_cost4(chords[n1], chords[n2])
            if c > max_cost:
                max_cost = c
                max_pair = (n1, n2)

    print(f"  Most distant pair: {max_pair[0]} → {max_pair[1]}, cost = {max_cost}")
    print()


# ─── Demo 6: Self-cost and Symmetry ──────────────────────────────────────────

def demo_metric_properties():
    """Demonstrate metric space properties: self-cost = 0, symmetry."""
    print("=" * 70)
    print("DEMO 6: Metric Space Properties")
    print("=" * 70)

    import random
    random.seed(123)

    print("\n  Self-cost = 0:")
    for _ in range(5):
        x = sorted([random.randint(30, 80) for _ in range(4)])
        print(f"    vlCost4({x}, {x}) = {vl_cost4(x, x)} ✓")

    print("\n  Symmetry:")
    for _ in range(5):
        x = [random.randint(30, 80) for _ in range(4)]
        y = [random.randint(30, 80) for _ in range(4)]
        c1 = vl_cost4(x, y)
        c2 = vl_cost4(y, x)
        print(f"    vlCost4(x, y) = {c1}, vlCost4(y, x) = {c2}  {'✓' if c1 == c2 else '✗'}")
    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 70)
    print("  VOICE-LEADING GEOMETRY: Computational Demonstrations")
    print("━" * 70 + "\n")

    demo_triangle_inequality()
    demo_permutation_invariance()
    demo_sorted_optimality()
    demo_uncrossing()
    demo_cost_table()
    demo_metric_properties()

    print("━" * 70)
    print("  All demonstrations completed successfully.")
    print("━" * 70)


#!/usr/bin/env python3
"""
Generate visualizations for Voice-Leading Geometry.
Produces SVG files for the cost landscape and chord graph.
"""

import base64
import io
import json
import sys

def sorted_vl_cost(x, y):
    n = len(x)
    x_idx = sorted(enumerate(x), key=lambda p: p[1])
    y_idx = sorted(enumerate(y), key=lambda p: p[1])
    cost = sum(abs(x_idx[i][1] - y_idx[i][1]) for i in range(n))
    return cost


def generate_cost_heatmap_svg():
    """Generate an SVG heatmap of pairwise voice-leading costs."""
    chords = {
        "C maj":   [48, 52, 55, 60],
        "C min":   [48, 51, 55, 60],
        "Dm7":     [50, 53, 57, 60],
        "Em":      [52, 55, 59, 64],
        "F maj":   [53, 57, 60, 65],
        "G7":      [55, 59, 62, 65],
        "Am":      [45, 48, 52, 57],
        "Bdim":    [47, 50, 53, 59],
    }

    names = list(chords.keys())
    n = len(names)

    # Compute cost matrix
    costs = [[0]*n for _ in range(n)]
    max_cost = 0
    for i in range(n):
        for j in range(n):
            c = sorted_vl_cost(chords[names[i]], chords[names[j]])
            costs[i][j] = c
            if c > max_cost:
                max_cost = c

    # SVG dimensions
    cell = 60
    margin_left = 80
    margin_top = 80
    w = margin_left + n * cell + 20
    h = margin_top + n * cell + 20

    svg_parts = []
    svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
                     f'viewBox="0 0 {w} {h}">')
    svg_parts.append(f'<rect width="{w}" height="{h}" fill="white"/>')
    svg_parts.append(f'<text x="{w//2}" y="20" text-anchor="middle" font-size="16" '
                     f'font-family="sans-serif" font-weight="bold">Voice-Leading Cost Heatmap</text>')

    # Column headers
    for j, name in enumerate(names):
        x = margin_left + j * cell + cell // 2
        svg_parts.append(f'<text x="{x}" y="{margin_top - 10}" text-anchor="middle" '
                         f'font-size="11" font-family="sans-serif" '
                         f'transform="rotate(-45 {x} {margin_top - 10})">{name}</text>')

    # Row headers and cells
    for i in range(n):
        y = margin_top + i * cell + cell // 2
        svg_parts.append(f'<text x="{margin_left - 8}" y="{y + 4}" text-anchor="end" '
                         f'font-size="11" font-family="sans-serif">{names[i]}</text>')

        for j in range(n):
            x = margin_left + j * cell
            cy = margin_top + i * cell
            c = costs[i][j]

            # Color: green (low cost) → yellow → red (high cost)
            if max_cost > 0:
                t = c / max_cost
            else:
                t = 0
            if t < 0.5:
                r = int(255 * (2 * t))
                g = 200
                b = int(100 * (1 - 2 * t))
            else:
                r = 255
                g = int(200 * (2 * (1 - t)))
                b = 0

            svg_parts.append(f'<rect x="{x}" y="{cy}" width="{cell}" height="{cell}" '
                             f'fill="rgb({r},{g},{b})" stroke="white" stroke-width="2"/>')
            svg_parts.append(f'<text x="{x + cell//2}" y="{cy + cell//2 + 5}" '
                             f'text-anchor="middle" font-size="13" font-family="sans-serif" '
                             f'fill="{"white" if t > 0.7 else "black"}">{c}</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_chord_graph_svg():
    """Generate an SVG showing the chord transition graph."""
    chords = {
        "C maj":   [48, 52, 55, 60],
        "C min":   [48, 51, 55, 60],
        "Dm7":     [50, 53, 57, 60],
        "F maj":   [53, 57, 60, 65],
        "G7":      [55, 59, 62, 65],
        "Am":      [45, 48, 52, 57],
    }

    names = list(chords.keys())
    n = len(names)

    # Layout: circular
    import math
    cx, cy = 300, 250
    radius = 160
    positions = {}
    for i, name in enumerate(names):
        angle = 2 * math.pi * i / n - math.pi / 2
        positions[name] = (cx + radius * math.cos(angle), cy + radius * math.sin(angle))

    # Compute costs
    edges = []
    max_cost = 0
    for i in range(n):
        for j in range(i + 1, n):
            c = sorted_vl_cost(chords[names[i]], chords[names[j]])
            edges.append((names[i], names[j], c))
            max_cost = max(max_cost, c)

    w, h = 600, 500
    svg_parts = []
    svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">')
    svg_parts.append(f'<rect width="{w}" height="{h}" fill="#fafafa"/>')
    svg_parts.append(f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" '
                     f'font-family="sans-serif" font-weight="bold">'
                     f'Chord Transition Graph (edge = vl cost)</text>')

    # Draw edges (thinner = higher cost)
    threshold = 15
    for n1, n2, c in edges:
        if c <= threshold:
            x1, y1 = positions[n1]
            x2, y2 = positions[n2]
            t = c / max_cost if max_cost > 0 else 0
            stroke_width = max(1, 5 * (1 - t))
            opacity = max(0.2, 1 - t * 0.7)
            mx = (x1 + x2) / 2
            my = (y1 + y2) / 2
            svg_parts.append(f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" '
                             f'stroke="#4477aa" stroke-width="{stroke_width:.1f}" '
                             f'opacity="{opacity:.2f}"/>')
            svg_parts.append(f'<text x="{mx:.0f}" y="{my:.0f}" text-anchor="middle" '
                             f'font-size="10" font-family="sans-serif" fill="#666">{c}</text>')

    # Draw nodes
    for name, (x, y) in positions.items():
        svg_parts.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="30" fill="#2255aa" '
                         f'stroke="white" stroke-width="2"/>')
        svg_parts.append(f'<text x="{x:.0f}" y="{y:.0f}" text-anchor="middle" '
                         f'dominant-baseline="central" font-size="11" '
                         f'font-family="sans-serif" fill="white" font-weight="bold">'
                         f'{name}</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


if __name__ == "__main__":
    heatmap = generate_cost_heatmap_svg()
    graph = generate_chord_graph_svg()

    with open("cost_heatmap.svg", "w") as f:
        f.write(heatmap)
    with open("chord_graph.svg", "w") as f:
        f.write(graph)

    print("Generated: cost_heatmap.svg, chord_graph.svg")
    print(f"Heatmap: {len(heatmap)} chars")
    print(f"Graph: {len(graph)} chars")
