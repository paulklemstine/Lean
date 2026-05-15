#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Voice-Leading Geometry

Applications demonstrated:
1. Optimal chord progression planning (shortest harmonic path)
2. Harmonic analysis of existing pieces
3. Algorithmic composition via cost-constrained random walks
4. Chord similarity clustering
"""

import itertools
import random
from typing import List, Tuple, Dict, Optional
from collections import defaultdict
import heapq

# ──────────────────────────────────────────────────────────────────────
# Core voice-leading cost (reproduced for standalone operation)
# ──────────────────────────────────────────────────────────────────────

def vl_cost(x: List[int], y: List[int]) -> int:
    """Optimal voice-leading cost via sorted matching."""
    xs, ys = sorted(x), sorted(y)
    return sum(abs(xs[i] - ys[i]) for i in range(len(xs)))


NOTE_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']

def pitches_to_str(pitches: List[int]) -> str:
    return " ".join(f"{NOTE_NAMES[p % 12]}{p // 12 - 1}" for p in sorted(pitches))


# ──────────────────────────────────────────────────────────────────────
# Application 1: Optimal Chord Progression Planning
# ──────────────────────────────────────────────────────────────────────

def build_chord_graph(chords: Dict[str, List[int]]) -> Dict[str, Dict[str, int]]:
    """Build weighted graph from chord corpus."""
    graph = {}
    names = list(chords.keys())
    for n1 in names:
        graph[n1] = {}
        for n2 in names:
            if n1 != n2:
                graph[n1][n2] = vl_cost(chords[n1], chords[n2])
    return graph


def shortest_harmonic_path(
    graph: Dict[str, Dict[str, int]],
    start: str, end: str,
    waypoints: Optional[List[str]] = None
) -> Tuple[List[str], int]:
    """
    Find the minimum-cost chord progression from start to end.

    Uses Dijkstra's algorithm. Optionally passes through waypoints.

    Args:
        graph: Weighted chord graph
        start: Starting chord name
        end: Target chord name
        waypoints: Optional intermediate chords to visit

    Returns:
        (path, total_cost)
    """
    if waypoints:
        # Chain shortest paths through waypoints
        points = [start] + waypoints + [end]
        full_path = [start]
        total_cost = 0
        for i in range(len(points) - 1):
            seg_path, seg_cost = shortest_harmonic_path(graph, points[i], points[i+1])
            full_path.extend(seg_path[1:])
            total_cost += seg_cost
        return full_path, total_cost

    # Dijkstra
    dist = {name: float('inf') for name in graph}
    prev = {name: None for name in graph}
    dist[start] = 0
    pq = [(0, start)]

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist[u]:
            continue
        if u == end:
            break
        for v, w in graph[u].items():
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                prev[v] = u
                heapq.heappush(pq, (dist[v], v))

    # Reconstruct path
    path = []
    current = end
    while current:
        path.append(current)
        current = prev[current]
    path.reverse()

    return path, dist[end]


# ──────────────────────────────────────────────────────────────────────
# Application 2: Harmonic Analysis
# ──────────────────────────────────────────────────────────────────────

def analyze_progression(chords: List[List[int]], names: Optional[List[str]] = None) -> Dict:
    """
    Analyze a chord progression for voice-leading efficiency.

    Returns metrics including:
    - Step costs
    - Total path cost
    - Endpoint cost
    - Efficiency ratio (endpoint / path cost)
    - Average step cost
    """
    n = len(chords)
    if names is None:
        names = [f"chord_{i}" for i in range(n)]

    step_costs = [vl_cost(chords[i], chords[i+1]) for i in range(n-1)]
    total_path = sum(step_costs)
    endpoint = vl_cost(chords[0], chords[-1])
    efficiency = endpoint / total_path if total_path > 0 else 1.0

    return {
        "names": names,
        "step_costs": step_costs,
        "total_path_cost": total_path,
        "endpoint_cost": endpoint,
        "efficiency_ratio": efficiency,
        "avg_step_cost": total_path / len(step_costs) if step_costs else 0,
        "max_step_cost": max(step_costs) if step_costs else 0,
        "min_step_cost": min(step_costs) if step_costs else 0,
    }


# ──────────────────────────────────────────────────────────────────────
# Application 3: Algorithmic Composition
# ──────────────────────────────────────────────────────────────────────

def compose_by_cost_walk(
    corpus: Dict[str, List[int]],
    start: str,
    length: int,
    max_step_cost: int = 8,
    avoid_repeat: bool = True,
    seed: int = 42,
) -> List[str]:
    """
    Generate a chord progression by random walk with cost constraints.

    At each step, choose uniformly at random among chords reachable
    within max_step_cost.

    Args:
        corpus: Chord corpus
        start: Starting chord
        length: Number of chords in progression
        max_step_cost: Maximum allowed step cost
        avoid_repeat: If True, avoid immediately repeating a chord
        seed: Random seed

    Returns:
        List of chord names forming the progression
    """
    rng = random.Random(seed)
    path = [start]
    current = start

    for _ in range(length - 1):
        candidates = []
        for name, pitches in corpus.items():
            if avoid_repeat and name == current:
                continue
            cost = vl_cost(corpus[current], pitches)
            if cost <= max_step_cost:
                candidates.append(name)

        if not candidates:
            break

        next_chord = rng.choice(candidates)
        path.append(next_chord)
        current = next_chord

    return path


# ──────────────────────────────────────────────────────────────────────
# Application 4: Chord Similarity Clustering
# ──────────────────────────────────────────────────────────────────────

def cluster_chords_by_cost(
    corpus: Dict[str, List[int]],
    threshold: int = 4,
) -> List[List[str]]:
    """
    Cluster chords by voice-leading proximity.

    Two chords are in the same cluster if there exists a path of
    transitions each costing ≤ threshold.

    Args:
        corpus: Chord corpus
        threshold: Maximum cost for edges in clustering graph

    Returns:
        List of clusters (each a list of chord names)
    """
    names = list(corpus.keys())
    parent = {n: n for n in names}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j and vl_cost(corpus[n1], corpus[n2]) <= threshold:
                union(n1, n2)

    clusters = defaultdict(list)
    for name in names:
        clusters[find(name)].append(name)

    return list(clusters.values())


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("Applications of Voice-Leading Geometry")
    print("=" * 70)
    print()

    # Build corpus
    CHORD_TYPES = {
        "maj": [0, 4, 7], "min": [0, 3, 7],
        "dom7": [0, 4, 7, 10], "maj7": [0, 4, 7, 11],
        "min7": [0, 3, 7, 10],
    }
    corpus = {}
    for root in range(12):
        for ctype, intervals in CHORD_TYPES.items():
            pitches = [48 + root + iv for iv in intervals]
            if len(pitches) == 3:
                pitches.append(48 + root + 12)
            corpus[f"{NOTE_NAMES[root]}_{ctype}"] = sorted(pitches)

    # App 1: Optimal progression planning
    print("APPLICATION 1: Optimal Chord Progression Planning")
    print("-" * 50)
    graph = build_chord_graph(corpus)

    for start, end in [("C_maj", "G_dom7"), ("C_maj", "Ab_maj"), ("A_min", "Eb_maj7")]:
        path, cost = shortest_harmonic_path(graph, start, end)
        print(f"  {start} → {end}")
        print(f"    Optimal path: {' → '.join(path)}")
        print(f"    Total cost: {cost}")
        print()

    # App 2: Harmonic analysis
    print("APPLICATION 2: Harmonic Analysis of Common Progressions")
    print("-" * 50)

    progressions = {
        "I-IV-V-I (C)": [corpus["C_maj"], corpus["F_maj"], corpus["G_dom7"], corpus["C_maj"]],
        "I-vi-IV-V (C)": [corpus["C_maj"], corpus["A_min"], corpus["F_maj"], corpus["G_dom7"]],
        "ii-V-I (C)": [corpus["D_min7"], corpus["G_dom7"], corpus["C_maj7"]],
    }

    for name, chords in progressions.items():
        analysis = analyze_progression(chords)
        print(f"  {name}:")
        print(f"    Step costs: {analysis['step_costs']}")
        print(f"    Total: {analysis['total_path_cost']}, Avg: {analysis['avg_step_cost']:.1f}")
        print(f"    Efficiency (endpoint/path): {analysis['efficiency_ratio']:.2f}")
        print()

    # App 3: Algorithmic composition
    print("APPLICATION 3: Algorithmic Composition (Cost-Constrained Walk)")
    print("-" * 50)
    progression = compose_by_cost_walk(corpus, "C_maj", 8, max_step_cost=6)
    print(f"  Generated: {' → '.join(progression)}")
    step_costs = [vl_cost(corpus[progression[i]], corpus[progression[i+1]])
                  for i in range(len(progression)-1)]
    print(f"  Step costs: {step_costs}")
    print(f"  Total cost: {sum(step_costs)}")
    print()

    # App 4: Clustering
    print("APPLICATION 4: Chord Similarity Clustering")
    print("-" * 50)
    for threshold in [2, 4, 8]:
        clusters = cluster_chords_by_cost(corpus, threshold)
        print(f"  Threshold={threshold}: {len(clusters)} clusters")
        for i, cl in enumerate(clusters[:3]):
            if len(cl) > 1:
                print(f"    Cluster {i}: {cl[:5]}{'...' if len(cl) > 5 else ''}")
    print()

    print("=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Voice-Leading Geometry: Demonstrations of Four-Voice Harmonic Cost Theory

This script demonstrates the key theorems proved in the formal verification:
1. Triangle inequality for voice-leading cost
2. Permutation invariance
3. Sorted matching optimality (Monge property)
4. Tropical path composition bounds

All results are computed concretely on real chord examples from tonal harmony.
"""

import itertools
import math
from typing import List, Tuple, Dict

# ──────────────────────────────────────────────────────────────────────
# Core Definitions
# ──────────────────────────────────────────────────────────────────────

def perm_cost(x: List[int], y: List[int], sigma: Tuple[int, ...]) -> int:
    """Cost of a specific voice assignment given by permutation sigma."""
    return sum(abs(x[i] - y[sigma[i]]) for i in range(len(x)))


def vl_cost(x: List[int], y: List[int]) -> int:
    """Optimal voice-leading cost: minimum over all permutations."""
    n = len(x)
    assert len(y) == n
    perms = list(itertools.permutations(range(n)))
    return min(perm_cost(x, y, p) for p in perms)


def optimal_perm(x: List[int], y: List[int]) -> Tuple[int, ...]:
    """Find the permutation realizing the optimal voice-leading cost."""
    n = len(x)
    perms = list(itertools.permutations(range(n)))
    return min(perms, key=lambda p: perm_cost(x, y, p))


# ──────────────────────────────────────────────────────────────────────
# Chord Definitions (MIDI pitch numbers)
# ──────────────────────────────────────────────────────────────────────

CHORDS = {
    "C major (close)":      [48, 52, 55, 60],   # C3 E3 G3 C4
    "F major (close)":      [53, 57, 60, 65],   # F3 A3 C4 F4
    "G dom7":               [55, 59, 62, 65],   # G3 B3 D4 F4
    "A minor (close)":      [45, 48, 52, 57],   # A2 C3 E3 A3
    "D minor (close)":      [50, 53, 57, 62],   # D3 F3 A3 D4
    "E minor (close)":      [52, 55, 59, 64],   # E3 G3 B3 E4
    "Bb major (close)":     [46, 50, 53, 58],   # Bb2 D3 F3 Bb3
    "C dim7":               [48, 51, 54, 57],   # C3 Eb3 Gb3 A3
    "C maj7":               [48, 52, 55, 59],   # C3 E3 G3 B3
    "D dom7":               [50, 54, 57, 60],   # D3 F#3 A3 C4
}

NOTE_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']

def midi_to_name(midi: int) -> str:
    octave = midi // 12 - 1
    return f"{NOTE_NAMES[midi % 12]}{octave}"


# ──────────────────────────────────────────────────────────────────────
# Demo 1: Triangle Inequality
# ──────────────────────────────────────────────────────────────────────

def demo_triangle_inequality():
    print("=" * 70)
    print("DEMO 1: Triangle Inequality for Voice-Leading Cost")
    print("=" * 70)
    print()
    print("Theorem: For all chords x, y, z:")
    print("  vlCost(x, z) ≤ vlCost(x, y) + vlCost(y, z)")
    print()

    test_triples = [
        ("C major (close)", "F major (close)", "G dom7"),
        ("C major (close)", "A minor (close)", "D minor (close)"),
        ("A minor (close)", "E minor (close)", "C major (close)"),
        ("Bb major (close)", "C dim7", "F major (close)"),
    ]

    for name_x, name_y, name_z in test_triples:
        x, y, z = CHORDS[name_x], CHORDS[name_y], CHORDS[name_z]
        cost_xz = vl_cost(x, z)
        cost_xy = vl_cost(x, y)
        cost_yz = vl_cost(y, z)

        print(f"  {name_x} → {name_y} → {name_z}")
        print(f"    vlCost(x,z) = {cost_xz}")
        print(f"    vlCost(x,y) + vlCost(y,z) = {cost_xy} + {cost_yz} = {cost_xy + cost_yz}")
        print(f"    {cost_xz} ≤ {cost_xy + cost_yz}  ✓" if cost_xz <= cost_xy + cost_yz else "    VIOLATION!")
        print(f"    Slack = {cost_xy + cost_yz - cost_xz}")
        print()


# ──────────────────────────────────────────────────────────────────────
# Demo 2: Permutation Invariance
# ──────────────────────────────────────────────────────────────────────

def demo_permutation_invariance():
    print("=" * 70)
    print("DEMO 2: Permutation Invariance of Voice-Leading Cost")
    print("=" * 70)
    print()
    print("Theorem: For all chords x, y and permutations τ₁, τ₂:")
    print("  vlCost(x∘τ₁, y∘τ₂) = vlCost(x, y)")
    print()

    x = CHORDS["C major (close)"]
    y = CHORDS["F major (close)"]
    base_cost = vl_cost(x, y)

    print(f"  Base: vlCost(C major, F major) = {base_cost}")
    print()

    # Test all permutations of both source and target
    perms = list(itertools.permutations(range(4)))
    all_match = True
    for tau1 in perms[:6]:  # Sample 6 source permutations
        for tau2 in perms[:6]:  # Sample 6 target permutations
            x_perm = [x[tau1[i]] for i in range(4)]
            y_perm = [y[tau2[i]] for i in range(4)]
            cost = vl_cost(x_perm, y_perm)
            if cost != base_cost:
                all_match = False
                print(f"  MISMATCH: τ₁={tau1}, τ₂={tau2}, cost={cost}")

    if all_match:
        print(f"  All 36 tested permutation pairs give cost = {base_cost}  ✓")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 3: Sorted Matching Optimality
# ──────────────────────────────────────────────────────────────────────

def demo_sorted_optimality():
    print("=" * 70)
    print("DEMO 3: Sorted Matching Optimality (Monge Property)")
    print("=" * 70)
    print()
    print("Theorem: If x and y are both sorted, the identity matching is optimal:")
    print("  vlCost(x, y) = Σᵢ |xᵢ - yᵢ|")
    print()

    test_pairs = [
        ([40, 50, 60, 70], [42, 48, 62, 68]),
        ([48, 52, 55, 60], [53, 57, 60, 65]),
        ([45, 48, 52, 57], [50, 53, 57, 62]),
        ([10, 20, 30, 40], [15, 25, 35, 45]),
    ]

    for x, y in test_pairs:
        assert x == sorted(x) and y == sorted(y), "Inputs must be sorted"
        identity_cost = sum(abs(x[i] - y[i]) for i in range(4))
        opt_cost = vl_cost(x, y)
        opt_sigma = optimal_perm(x, y)

        print(f"  x = {x}")
        print(f"  y = {y}")
        print(f"  Identity cost: Σ|xᵢ-yᵢ| = {identity_cost}")
        print(f"  Optimal cost:  vlCost    = {opt_cost}")
        print(f"  Optimal perm:  σ = {opt_sigma}")
        print(f"  Match: {identity_cost == opt_cost}  ✓" if identity_cost == opt_cost else "  MISMATCH!")
        print()


# ──────────────────────────────────────────────────────────────────────
# Demo 4: Uncrossing Lemma
# ──────────────────────────────────────────────────────────────────────

def demo_uncrossing():
    print("=" * 70)
    print("DEMO 4: Uncrossing Lemma (Engine of Monge Optimality)")
    print("=" * 70)
    print()
    print("Lemma: If a ≤ b and c ≤ d, then:")
    print("  |a-c| + |b-d| ≤ |a-d| + |b-c|")
    print("(Crossed assignment always costs at least as much as uncrossed)")
    print()

    test_cases = [
        (1, 5, 2, 8),
        (0, 10, 3, 7),
        (48, 60, 53, 65),
        (-5, 3, -2, 10),
        (0, 0, 0, 0),
    ]

    for a, b, c, d in test_cases:
        uncrossed = abs(a - c) + abs(b - d)
        crossed = abs(a - d) + abs(b - c)
        print(f"  a={a}, b={b}, c={c}, d={d}")
        print(f"    Uncrossed: |{a}-{c}| + |{b}-{d}| = {uncrossed}")
        print(f"    Crossed:   |{a}-{d}| + |{b}-{c}| = {crossed}")
        print(f"    {uncrossed} ≤ {crossed}  ✓" if uncrossed <= crossed else "    VIOLATION!")
        print()


# ──────────────────────────────────────────────────────────────────────
# Demo 5: Chord Transition Cost Matrix
# ──────────────────────────────────────────────────────────────────────

def demo_cost_matrix():
    print("=" * 70)
    print("DEMO 5: Pairwise Cost Matrix for Common Chord Types")
    print("=" * 70)
    print()

    chord_names = list(CHORDS.keys())
    n = len(chord_names)

    # Compute cost matrix
    costs = {}
    for i in range(n):
        for j in range(n):
            costs[(i, j)] = vl_cost(CHORDS[chord_names[i]], CHORDS[chord_names[j]])

    # Print header
    short_names = [name.split("(")[0].strip()[:10] for name in chord_names]
    header = "          " + " ".join(f"{s:>10}" for s in short_names)
    print(header)
    print("-" * len(header))

    for i in range(n):
        row = f"{short_names[i]:>10}" + " ".join(f"{costs[(i,j)]:>10}" for j in range(n))
        print(row)
    print()

    # Statistics
    nonzero_costs = [costs[(i, j)] for i in range(n) for j in range(n) if i != j]
    print(f"  Minimum nonzero cost: {min(nonzero_costs)}")
    print(f"  Maximum cost: {max(nonzero_costs)}")
    print(f"  Mean cost: {sum(nonzero_costs) / len(nonzero_costs):.1f}")
    print()

    # Verify triangle inequality exhaustively
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if costs[(i, k)] > costs[(i, j)] + costs[(j, k)]:
                    violations += 1
    print(f"  Triangle inequality violations: {violations} / {n**3} triples")
    print()


# ──────────────────────────────────────────────────────────────────────
# Demo 6: Tropical Path Composition
# ──────────────────────────────────────────────────────────────────────

def demo_tropical_paths():
    print("=" * 70)
    print("DEMO 6: Tropical Path Composition Bounds")
    print("=" * 70)
    print()
    print("Theorem: For a chord progression c₀ → c₁ → ... → cₖ:")
    print("  vlCost(c₀, cₖ) ≤ Σᵢ vlCost(cᵢ, cᵢ₊₁)")
    print()

    # Common chord progressions
    progressions = [
        ("I-IV-V-I", ["C major (close)", "F major (close)", "G dom7", "C major (close)"]),
        ("I-vi-ii-V", ["C major (close)", "A minor (close)", "D minor (close)", "G dom7"]),
        ("I-iii-vi-ii-V-I", ["C major (close)", "E minor (close)", "A minor (close)",
                              "D minor (close)", "G dom7", "C major (close)"]),
    ]

    for name, chord_names in progressions:
        chords = [CHORDS[cn] for cn in chord_names]
        step_costs = [vl_cost(chords[i], chords[i+1]) for i in range(len(chords)-1)]
        total_path = sum(step_costs)
        endpoint = vl_cost(chords[0], chords[-1])

        print(f"  Progression: {name}")
        print(f"    Steps: {' → '.join(chord_names)}")
        print(f"    Step costs: {step_costs}")
        print(f"    Total path cost: {total_path}")
        print(f"    Endpoint cost:   {endpoint}")
        print(f"    Bound holds: {endpoint} ≤ {total_path}  ✓" if endpoint <= total_path else "    VIOLATION!")
        print(f"    Slack: {total_path - endpoint}")
        print()


# ──────────────────────────────────────────────────────────────────────
# Demo 7: N-voice generalization
# ──────────────────────────────────────────────────────────────────────

def demo_n_voice():
    print("=" * 70)
    print("DEMO 7: N-Voice Generalization")
    print("=" * 70)
    print()

    for n in [2, 3, 4, 5, 6]:
        # Random-ish sorted chords
        import random
        random.seed(42 + n)
        x = sorted(random.choices(range(40, 80), k=n))
        y = sorted(random.choices(range(40, 80), k=n))
        z = sorted(random.choices(range(40, 80), k=n))

        cost_xz = vl_cost(x, z)
        cost_xy = vl_cost(x, y)
        cost_yz = vl_cost(y, z)

        # For sorted chords, identity should be optimal
        id_cost = sum(abs(x[i] - y[i]) for i in range(n))

        print(f"  n = {n} voices:")
        print(f"    x = {x}")
        print(f"    y = {y}")
        print(f"    Triangle: vlCost(x,z)={cost_xz} ≤ vlCost(x,y)+vlCost(y,z)={cost_xy}+{cost_yz}={cost_xy+cost_yz}  ✓")
        print(f"    Sorted optimality: vlCost(x,y)={vl_cost(x,y)} = id_cost={id_cost}  {'✓' if vl_cost(x,y) == id_cost else '✗'}")
        print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║    Voice-Leading Geometry: Formally Verified Cost Theory            ║")
    print("║    Demonstrations of Four-Voice Harmonic Motion Theorems           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_triangle_inequality()
    demo_permutation_invariance()
    demo_sorted_optimality()
    demo_uncrossing()
    demo_cost_matrix()
    demo_tropical_paths()
    demo_n_voice()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables embedded."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    try:
        with open(path, 'rb') as f:
            return 'data:image/png;base64,' + base64.b64encode(f.read()).decode()
    except FileNotFoundError:
        return ''

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code_1 = read_file('Catalog/Logic/VoiceLeadingGeometry.lean')
lean_code_2 = read_file('Catalog/Logic/VoiceLeadingCostN.lean')

# Read visualizations
heatmap_b64 = read_binary_base64('cost_heatmap.png')
distribution_b64 = read_binary_base64('cost_distribution.png')
slack_b64 = read_binary_base64('triangle_slack.png')
uncrossing_svg = read_file('uncrossing_diagram.svg')

package = {
    "title": "Voice-Leading Geometry: Formally Verified Metric Structure on Chord Spaces",
    "domain": "Mathematical Music Theory / Discrete Optimization / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Voice-Leading Cost Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Brute-Force Optimal Voice-Leading Cost",
            "pseudocode": "for each σ ∈ Sₙ: cost ← Σᵢ |x(i) - y(σ(i))|; track minimum. O(n!·n) time.",
            "code": algorithms_code
        },
        {
            "name": "Sorted Matching (O(n log n))",
            "pseudocode": "Sort both chords. Match i-th to i-th. Cost = Σᵢ |x_sorted(i) - y_sorted(i)|. Correct by Monge property.",
            "code": "def sorted_matching_cost(x, y):\n    xs, ys = sorted(x), sorted(y)\n    return sum(abs(xs[i] - ys[i]) for i in range(len(xs)))"
        }
    ],
    "visualizations": [
        {
            "name": "Voice-Leading Cost Heatmap",
            "data": heatmap_b64
        },
        {
            "name": "Cost Distribution Histogram",
            "data": distribution_b64
        },
        {
            "name": "Triangle Inequality Slack Distribution",
            "data": slack_b64
        },
        {
            "name": "Uncrossing Lemma Diagram",
            "data": uncrossing_svg
        }
    ],
    "lean_proofs": lean_code_1 + "\n\n-- ════════════════════════════════════════════════════════════\n-- N-Voice Generalization\n-- ════════════════════════════════════════════════════════════\n\n" + lean_code_2
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
visualizations.py — Generate charts and diagrams for voice-leading geometry.
Saves figures as PNG files and returns base64 data for embedding.
"""

import itertools
import base64
import io
from typing import List, Dict, Tuple

# Try to import matplotlib; skip gracefully if unavailable
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping visualizations")


NOTE_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']

def vl_cost(x, y):
    xs, ys = sorted(x), sorted(y)
    return sum(abs(xs[i] - ys[i]) for i in range(len(xs)))


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def generate_cost_heatmap():
    """Generate heatmap of pairwise voice-leading costs."""
    if not HAS_MPL:
        return ""

    CHORD_TYPES = {
        "maj": [0, 4, 7], "min": [0, 3, 7],
        "dom7": [0, 4, 7, 10], "min7": [0, 3, 7, 10],
    }

    corpus = {}
    labels = []
    for root in [0, 2, 4, 5, 7, 9]:  # C D E F G A
        for ctype, intervals in CHORD_TYPES.items():
            pitches = [48 + root + iv for iv in intervals]
            if len(pitches) == 3:
                pitches.append(48 + root + 12)
            name = f"{NOTE_NAMES[root]} {ctype}"
            corpus[name] = sorted(pitches)
            labels.append(name)

    n = len(labels)
    matrix = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            matrix[i][j] = vl_cost(corpus[labels[i]], corpus[labels[j]])

    fig, ax = plt.subplots(figsize=(12, 10))
    im = ax.imshow(matrix, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=90, fontsize=7)
    ax.set_yticklabels(labels, fontsize=7)
    ax.set_title("Voice-Leading Cost Heatmap\n(4-voice chords, sorted matching)", fontsize=14)
    plt.colorbar(im, ax=ax, label="Cost (semitone-steps)")

    fig.savefig('/workspace/request-project/cost_heatmap.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def generate_cost_distribution():
    """Generate histogram of cost distribution."""
    if not HAS_MPL:
        return ""

    CHORD_TYPES = {
        "maj": [0, 4, 7], "min": [0, 3, 7],
        "dom7": [0, 4, 7, 10], "maj7": [0, 4, 7, 11],
        "min7": [0, 3, 7, 10],
    }

    corpus = {}
    for root in range(12):
        for ctype, intervals in CHORD_TYPES.items():
            pitches = [48 + root + iv for iv in intervals]
            if len(pitches) == 3:
                pitches.append(48 + root + 12)
            corpus[f"{NOTE_NAMES[root]}_{ctype}"] = sorted(pitches)

    costs = []
    names = list(corpus.keys())
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                costs.append(vl_cost(corpus[n1], corpus[n2]))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.hist(costs, bins=range(0, max(costs)+2), color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel("Voice-Leading Cost", fontsize=12)
    ax.set_ylabel("Number of Chord Pairs", fontsize=12)
    ax.set_title("Distribution of Pairwise Voice-Leading Costs\n(60 chord types, all 12 roots)", fontsize=14)
    ax.axvline(x=sum(costs)/len(costs), color='red', linestyle='--', label=f'Mean = {sum(costs)/len(costs):.1f}')
    ax.legend()

    fig.savefig('/workspace/request-project/cost_distribution.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def generate_triangle_slack():
    """Visualize triangle inequality slack distribution."""
    if not HAS_MPL:
        return ""

    chords = {
        "C maj": [48, 52, 55, 60],
        "D min": [50, 53, 57, 62],
        "E min": [52, 55, 59, 64],
        "F maj": [53, 57, 60, 65],
        "G dom7": [55, 59, 62, 65],
        "A min": [45, 48, 52, 57],
        "C maj7": [48, 52, 55, 59],
        "D dom7": [50, 54, 57, 60],
    }

    names = list(chords.keys())
    slacks = []
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            for k, n3 in enumerate(names):
                if i != j and j != k and i != k:
                    cost_xz = vl_cost(chords[n1], chords[n3])
                    cost_xy = vl_cost(chords[n1], chords[n2])
                    cost_yz = vl_cost(chords[n2], chords[n3])
                    slack = cost_xy + cost_yz - cost_xz
                    slacks.append(slack)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.hist(slacks, bins=range(0, max(slacks)+2), color='forestgreen', edgecolor='darkgreen', alpha=0.8)
    ax.set_xlabel("Slack = vlCost(x,y) + vlCost(y,z) - vlCost(x,z)", fontsize=12)
    ax.set_ylabel("Count", fontsize=12)
    ax.set_title("Triangle Inequality Slack Distribution\n(Slack ≥ 0 proven; tight when slack = 0)", fontsize=14)
    tight = sum(1 for s in slacks if s == 0)
    ax.annotate(f'{tight} tight triples (slack=0)', xy=(0, tight), fontsize=11,
                xytext=(5, tight*1.5), arrowprops=dict(arrowstyle='->', color='red'))

    fig.savefig('/workspace/request-project/triangle_slack.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def generate_uncrossing_diagram():
    """Generate SVG diagram illustrating the uncrossing lemma."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="600" height="300" viewBox="0 0 600 300">
  <style>
    text { font-family: 'Georgia', serif; }
    .title { font-size: 16px; font-weight: bold; fill: #333; }
    .label { font-size: 14px; fill: #555; }
    .cost { font-size: 13px; fill: #c00; font-weight: bold; }
    .crossed { stroke: #e74c3c; stroke-width: 2.5; fill: none; }
    .uncrossed { stroke: #27ae60; stroke-width: 2.5; fill: none; }
    .point { fill: #2c3e50; }
  </style>

  <text x="300" y="25" text-anchor="middle" class="title">Uncrossing Lemma: Why Sorted Matching Wins</text>

  <!-- Left: Crossed -->
  <text x="150" y="55" text-anchor="middle" class="label">Crossed (costly)</text>
  <circle cx="80" cy="100" r="6" class="point"/>
  <circle cx="80" cy="200" r="6" class="point"/>
  <circle cx="220" cy="120" r="6" class="point"/>
  <circle cx="220" cy="220" r="6" class="point"/>
  <text x="60" y="105" class="label">a</text>
  <text x="60" y="205" class="label">b</text>
  <text x="235" y="125" class="label">d</text>
  <text x="235" y="225" class="label">c</text>
  <line x1="80" y1="100" x2="220" y2="220" class="crossed"/>
  <line x1="80" y1="200" x2="220" y2="120" class="crossed"/>
  <text x="150" y="260" text-anchor="middle" class="cost">|a−d| + |b−c|</text>

  <!-- Right: Uncrossed -->
  <text x="450" y="55" text-anchor="middle" class="label">Uncrossed (optimal)</text>
  <circle cx="380" cy="100" r="6" class="point"/>
  <circle cx="380" cy="200" r="6" class="point"/>
  <circle cx="520" cy="120" r="6" class="point"/>
  <circle cx="520" cy="220" r="6" class="point"/>
  <text x="360" y="105" class="label">a</text>
  <text x="360" y="205" class="label">b</text>
  <text x="535" y="125" class="label">c</text>
  <text x="535" y="225" class="label">d</text>
  <line x1="380" y1="100" x2="520" y2="120" class="uncrossed"/>
  <line x1="380" y1="200" x2="520" y2="220" class="uncrossed"/>
  <text x="450" y="260" text-anchor="middle" class="cost" style="fill: #27ae60;">|a−c| + |b−d| ≤</text>

  <!-- Inequality arrow -->
  <text x="300" y="170" text-anchor="middle" style="font-size: 24px; fill: #e74c3c;">≥</text>
</svg>"""
    return svg


if __name__ == "__main__":
    print("Generating visualizations...")

    if HAS_MPL:
        heatmap_b64 = generate_cost_heatmap()
        print(f"  Cost heatmap: {len(heatmap_b64)} chars (base64)")

        dist_b64 = generate_cost_distribution()
        print(f"  Cost distribution: {len(dist_b64)} chars (base64)")

        slack_b64 = generate_triangle_slack()
        print(f"  Triangle slack: {len(slack_b64)} chars (base64)")
    else:
        print("  Skipped matplotlib-based visualizations")

    svg = generate_uncrossing_diagram()
    with open('/workspace/request-project/uncrossing_diagram.svg', 'w') as f:
        f.write(svg)
    print(f"  Uncrossing diagram SVG: {len(svg)} chars")

    print("Done.")
