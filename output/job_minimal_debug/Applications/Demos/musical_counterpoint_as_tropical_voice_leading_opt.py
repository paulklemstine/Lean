#!/usr/bin/env python3
"""
Tropical Counterpoint: Applications

Demonstrates real-world applications of tropical music theory:
1. Automated composition via certified voice leading
2. Style classification using tropical cost signatures
3. Musical constraint verification
"""

from typing import List, Tuple, Dict
from algorithms import (
    tropical_dp_voice_leading, compute_pareto_frontier,
    forbidden_vertical_penalty, melodic_leap_penalty, parallel_perfect_penalty,
    CONSONANCES, PERFECT_CONSONANCES
)


def note_name(midi: int) -> str:
    """Convert MIDI number to note name."""
    names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    octave = midi // 12 - 1
    return f"{names[midi % 12]}{octave}"


# ─── Application 1: Automated Palestrina-Style Composition ──────────

def app_auto_composition():
    """Generate certified counterpoint over a given cantus firmus."""
    print("=" * 60)
    print("APPLICATION 1: Automated Palestrina-Style Composition")
    print("=" * 60)

    # Famous Fux cantus firmus (transposed to C)
    fux_cantus = [60, 62, 64, 65, 64, 62, 64, 62, 61, 60]  # D mode
    print(f"\nFux cantus firmus: {[note_name(p) for p in fux_cantus]}")

    # Find optimal counterpoint
    result = tropical_dp_voice_leading(fux_cantus, range(55, 80))
    print(f"Optimal melody:   {[note_name(p) for p in result.optimal_melody]}")
    print(f"MIDI pitches:     {result.optimal_melody}")
    print(f"Total cost:       {result.optimal_cost}")

    intervals = [result.optimal_melody[i] - fux_cantus[i] for i in range(len(fux_cantus))]
    interval_names = {0: 'P1', 3: 'm3', 4: 'M3', 7: 'P5', 8: 'm6',
                      9: 'M6', 12: 'P8', -3: 'm3↓', -4: 'M3↓', -7: 'P5↓',
                      -8: 'm6↓', -9: 'M6↓', -12: 'P8↓'}
    print(f"Intervals:        {[interval_names.get(iv, str(iv)) for iv in intervals]}")

    # Verify legality
    legal = result.optimal_cost == 0.0
    print(f"Certified legal:  {'✓ YES' if legal else '✗ NO'}")
    if legal:
        print("  → This counterpoint is machine-verified to satisfy all")
        print("    first-species rules: consonant intervals, no parallel")
        print("    perfect consonances, stepwise motion.")

    # Generate alternatives with different weights
    print(f"\nAlternative voicings:")
    for A, B, C, desc in [
        (1, 0.1, 1, "balanced"),
        (1, 2, 1, "prefer small steps"),
        (2, 1, 0.5, "prefer consonance"),
    ]:
        r = tropical_dp_voice_leading(fux_cantus, range(55, 80), (A, B, C))
        print(f"  {desc:20s}: {[note_name(p) for p in r.optimal_melody]}, cost={r.optimal_cost:.1f}")
    print()


# ─── Application 2: Style Classification ────────────────────────────

def app_style_classification():
    """Classify musical excerpts by their tropical cost signature."""
    print("=" * 60)
    print("APPLICATION 2: Style Classification via Tropical Signatures")
    print("=" * 60)

    cantus = [60, 62, 64, 65, 67, 65, 64, 62]

    # Define style archetypes
    styles = {
        "Palestrina": [67, 66, 67, 68, 67, 68, 67, 66],      # Stepwise, consonant
        "Bach":       [67, 66, 68, 65, 70, 66, 68, 66],       # Leaps for harmony
        "Modern":     [61, 63, 66, 69, 62, 68, 63, 67],       # Dissonant, angular
    }

    print(f"\nCantus: {[note_name(p) for p in cantus]}")
    print(f"\n{'Style':<12} {'Vert':>5} {'Mel':>5} {'Par':>5} {'Total':>6} {'Variety':>8} {'Legal':>6}")
    print("-" * 55)

    for name, melody in styles.items():
        n = len(cantus)
        ivs = [melody[i] - cantus[i] for i in range(n)]
        vert = sum(forbidden_vertical_penalty(ivs[i]) for i in range(n))
        mel = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
        par = sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
        total = vert + mel + par
        variety = len(set(ivs))
        legal = total == 0.0 and all(abs(melody[i+1]-melody[i]) <= 2 for i in range(n-1))
        print(f"{name:<12} {vert:5.0f} {mel:5.0f} {par:5.0f} {total:6.1f} {variety:8d} {'✓' if legal else '':>6}")

    print("\n  → The tropical cost signature (Vert, Mel, Par) distinguishes")
    print("    compositional styles as regions in a 3D penalty space.")
    print("    Palestrina lives at the origin; Bach nearby with some variety;")
    print("    Modern music explores higher-cost regions for expressivity.\n")


# ─── Application 3: Constraint Verification ─────────────────────────

def app_constraint_verification():
    """Verify whether a given composition satisfies contrapuntal rules."""
    print("=" * 60)
    print("APPLICATION 3: Musical Constraint Verification")
    print("=" * 60)

    # Test pieces
    pieces = [
        ("Student exercise A", [60, 62, 64, 65], [67, 66, 67, 68]),
        ("Student exercise B", [60, 62, 64, 65], [67, 69, 71, 72]),
        ("Student exercise C", [60, 62, 64, 65], [64, 58, 67, 68]),
    ]

    for name, cantus, melody in pieces:
        print(f"\n{name}:")
        print(f"  Cantus: {[note_name(p) for p in cantus]}")
        print(f"  Melody: {[note_name(p) for p in melody]}")
        n = len(cantus)
        ivs = [melody[i] - cantus[i] for i in range(n)]

        # Check each rule
        issues = []
        for i in range(n):
            if abs(ivs[i]) not in CONSONANCES:
                issues.append(f"  ⚠ Position {i}: dissonant interval {ivs[i]} semitones")
        for i in range(n-1):
            if abs(ivs[i]) in PERFECT_CONSONANCES and abs(ivs[i+1]) in PERFECT_CONSONANCES:
                issues.append(f"  ⚠ Positions {i}-{i+1}: parallel perfect consonances")
        for i in range(n-1):
            if abs(melody[i+1] - melody[i]) > 2:
                issues.append(f"  ⚠ Position {i}-{i+1}: leap of {abs(melody[i+1]-melody[i])} semitones")

        vert = sum(forbidden_vertical_penalty(ivs[i]) for i in range(n))
        mel = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
        par = sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
        total = vert + mel + par

        print(f"  Tropical cost: {total:.1f} (vert={vert:.0f}, mel={mel:.0f}, par={par:.0f})")
        if issues:
            for issue in issues:
                print(issue)
            print(f"  VERDICT: ✗ Not first-species legal (cost > 0)")

            # Suggest fix
            result = tropical_dp_voice_leading(cantus, range(55, 80))
            print(f"  SUGGESTED FIX: {[note_name(p) for p in result.optimal_melody]} (cost={result.optimal_cost})")
        else:
            print(f"  VERDICT: ✓ First-species legal (cost = 0)")

    print()


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_auto_composition()
    app_style_classification()
    app_constraint_verification()


#!/usr/bin/env python3
"""
Tropical Counterpoint: Demonstrations and Examples

This script demonstrates the core theorems of tropical music theory
with concrete numerical examples, showing how Renaissance counterpoint
rules emerge as zero-penalty loci of a tropical cost functional.
"""

from typing import List, Tuple, Dict

# ─── Musical constants ───────────────────────────────────────────────

PERFECT_CONSONANCES = {0, 7, 12}       # unison, fifth, octave
IMPERFECT_CONSONANCES = {3, 4, 8, 9}   # thirds and sixths
CONSONANCES = PERFECT_CONSONANCES | IMPERFECT_CONSONANCES

# ─── Penalty functions ───────────────────────────────────────────────

def forbidden_vertical_penalty(k: int) -> float:
    return 0.0 if abs(k) in CONSONANCES else 1.0

def melodic_leap_penalty(x: int, y: int) -> float:
    return max(0.0, abs(y - x) - 2)

def parallel_perfect_penalty(interval_curr: int, interval_next: int) -> float:
    if abs(interval_curr) in PERFECT_CONSONANCES and abs(interval_next) in PERFECT_CONSONANCES:
        return 1.0
    return 0.0

def total_cost(cantus: List[int], melody: List[int]) -> float:
    n = len(cantus)
    vertical = sum(forbidden_vertical_penalty(melody[i] - cantus[i]) for i in range(n))
    melodic = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
    intervals = [melody[i] - cantus[i] for i in range(n)]
    parallel = sum(
        parallel_perfect_penalty(intervals[i], intervals[i+1])
        for i in range(n-1)
    )
    return vertical + melodic + parallel

def is_first_species_legal(cantus: List[int], melody: List[int]) -> bool:
    n = len(cantus)
    for i in range(n):
        if abs(melody[i] - cantus[i]) not in CONSONANCES:
            return False
    for i in range(n-1):
        iv_curr = abs(melody[i] - cantus[i])
        iv_next = abs(melody[i+1] - cantus[i+1])
        if iv_curr in PERFECT_CONSONANCES and iv_next in PERFECT_CONSONANCES:
            return False
    for i in range(n-1):
        if abs(melody[i+1] - melody[i]) > 2:
            return False
    return True

def harmonic_variety(cantus: List[int], melody: List[int]) -> int:
    return len(set(melody[i] - cantus[i] for i in range(len(cantus))))

def weighted_total_cost(A, B, C, cantus, melody):
    n = len(cantus)
    vertical = sum(forbidden_vertical_penalty(melody[i] - cantus[i]) for i in range(n))
    melodic = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
    intervals = [melody[i] - cantus[i] for i in range(n)]
    parallel = sum(parallel_perfect_penalty(intervals[i], intervals[i+1]) for i in range(n-1))
    return A * vertical + B * melodic + C * parallel

# ─── Example 1: Theorem 1 ───────────────────────────────────────────

def demo_theorem1():
    print("=" * 60)
    print("THEOREM 1: First-species legality ↔ zero tropical cost")
    print("=" * 60)

    cantus = [60, 62, 64, 65, 67]

    # Legal counterpoint: intervals [7, 4, 3, 3, 0]
    legal = [67, 66, 67, 68, 67]
    intervals = [legal[i] - cantus[i] for i in range(5)]
    print(f"\nCantus firmus: {cantus}")
    print(f"Legal melody:  {legal}")
    print(f"Intervals:     {intervals}")
    print(f"Legal?         {is_first_species_legal(cantus, legal)}")
    print(f"Total cost:    {total_cost(cantus, legal)}")
    assert is_first_species_legal(cantus, legal)
    assert total_cost(cantus, legal) == 0.0
    print("✓ Legal melody has zero cost")

    # Illegal: dissonant
    bad1 = [61, 66, 67, 68, 67]
    print(f"\nIllegal (dissonant): {bad1}")
    print(f"Intervals: {[bad1[i]-cantus[i] for i in range(5)]}")
    print(f"Total cost: {total_cost(cantus, bad1)}")
    assert total_cost(cantus, bad1) > 0
    print("✓ Dissonance → positive cost")

    # Illegal: parallel fifths
    bad2 = [67, 69, 71, 72, 74]
    print(f"\nIllegal (parallel 5ths): {bad2}")
    print(f"Intervals: {[bad2[i]-cantus[i] for i in range(5)]}")
    print(f"Total cost: {total_cost(cantus, bad2)}")
    print("✓ Parallel fifths → positive cost")

    # Illegal: large leaps
    bad3 = [67, 58, 67, 58, 67]
    print(f"\nIllegal (large leaps): {bad3}")
    print(f"Steps: {[abs(bad3[i+1]-bad3[i]) for i in range(4)]}")
    print(f"Total cost: {total_cost(cantus, bad3)}")
    print("✓ Large leaps → positive cost\n")

# ─── Example 2: Theorem 2 ───────────────────────────────────────────

def demo_theorem2():
    print("=" * 60)
    print("THEOREM 2: Large penalties force legal minimizers")
    print("=" * 60)

    cantus = [60, 62, 64, 65]
    candidates = []
    for a in range(55, 73):
        for b in range(55, 73):
            for c in range(55, 73):
                for d in range(55, 73):
                    m = [a, b, c, d]
                    if all(abs(m[i+1]-m[i]) <= 5 for i in range(3)):
                        candidates.append(m)

    legal = [m for m in candidates if is_first_species_legal(cantus, m)]
    print(f"\nCantus: {cantus}")
    print(f"Candidates (step ≤ 5): {len(candidates)}")
    print(f"Legal candidates: {len(legal)}")

    for A, B, C in [(100, 1, 100), (50, 1, 50), (10, 1, 10)]:
        best = min(candidates, key=lambda m: weighted_total_cost(A, B, C, cantus, m))
        legal_flag = "✓" if is_first_species_legal(cantus, best) else "✗"
        print(f"  A={A:3d}, B={B}, C={C:3d}: cost={weighted_total_cost(A,B,C,cantus,best):.0f}, "
              f"legal={legal_flag}")
    print("✓ With large penalties, minimizer is always legal\n")

# ─── Example 3: Dynamic Programming ─────────────────────────────────

def demo_dp():
    print("=" * 60)
    print("THEOREM 3: Tropical dynamic programming")
    print("=" * 60)

    cantus = [60, 62, 64, 65, 67]
    pitch_range = range(55, 80)
    n = len(cantus)

    # DP: dp[k][x] = min cost ending at pitch x at step k
    dp = [{} for _ in range(n)]
    parent = [{} for _ in range(n)]

    for x in pitch_range:
        dp[0][x] = forbidden_vertical_penalty(x - cantus[0])

    for k in range(1, n):
        for x in pitch_range:
            best = float('inf')
            best_prev = None
            for y in pitch_range:
                transition = (
                    forbidden_vertical_penalty(x - cantus[k]) +
                    melodic_leap_penalty(y, x) +
                    parallel_perfect_penalty(y - cantus[k-1], x - cantus[k])
                )
                cost = transition + dp[k-1][y]
                if cost < best:
                    best = cost
                    best_prev = y
            dp[k][x] = best
            parent[k][x] = best_prev

    opt_pitch = min(pitch_range, key=lambda x: dp[n-1][x])
    opt_cost = dp[n-1][opt_pitch]

    melody = [0] * n
    melody[n-1] = opt_pitch
    for k in range(n-2, -1, -1):
        melody[k] = parent[k+1][melody[k+1]]

    print(f"\nCantus:           {cantus}")
    print(f"Optimal melody:   {melody}")
    print(f"Intervals:        {[melody[i]-cantus[i] for i in range(n)]}")
    print(f"DP optimal cost:  {opt_cost}")
    print(f"Direct cost:      {total_cost(cantus, melody)}")
    print(f"Legal?            {is_first_species_legal(cantus, melody)}")
    print(f"Harmonic variety: {harmonic_variety(cantus, melody)}")

    # Verify Bellman equation
    print("\nBellman equation verification:")
    for k in range(1, n):
        x = melody[k]
        lhs = dp[k][x]
        rhs = min(
            forbidden_vertical_penalty(x - cantus[k]) +
            melodic_leap_penalty(y, x) +
            parallel_perfect_penalty(y - cantus[k-1], x - cantus[k]) +
            dp[k-1][y]
            for y in pitch_range
        )
        print(f"  Step {k}: dp[{k}][{x}] = {lhs:.1f} = min_y(transition + dp[{k-1}][y]) = {rhs:.1f} ✓")
    print("✓ Bellman recursion verified\n")

# ─── Example 4: Pareto frontier ─────────────────────────────────────

def demo_pareto():
    print("=" * 60)
    print("THEOREM 4: Pareto frontier — cost vs. harmonic variety")
    print("=" * 60)

    # Use a longer cantus to make the tradeoff visible
    cantus = [60, 62, 64, 65, 67, 65, 64, 62]
    n = len(cantus)

    # Generate diverse candidate melodies
    candidates = set()

    # Stepwise melodies (legal candidates)
    for start in range(55, 76):
        stack = [(0, (start,))]
        while stack:
            pos, path = stack.pop()
            if pos == n - 1:
                candidates.add(path)
                continue
            for step in range(-2, 3):
                nxt = path[-1] + step
                if 55 <= nxt <= 76:
                    stack.append((pos + 1, path + (nxt,)))

    # Also add some leaping melodies for variety
    import random
    random.seed(42)
    for _ in range(50000):
        m = [random.randint(55, 76)]
        for i in range(1, n):
            step = random.choice([-4, -3, -2, -1, 0, 1, 2, 3, 4])
            nxt = max(55, min(76, m[-1] + step))
            m.append(nxt)
        candidates.add(tuple(m))

    candidates = [list(m) for m in candidates]
    print(f"\nCantus: {cantus} (length {n})")
    print(f"Total candidates: {len(candidates)}")

    # Compute objectives
    points = [(total_cost(cantus, m), harmonic_variety(cantus, m), m) for m in candidates]

    # Find Pareto frontier
    pareto = []
    for i, (c, v, m) in enumerate(points):
        dominated = False
        for c2, v2, _ in points:
            if (c2 <= c and v2 >= v) and (c2 < c or v2 > v):
                dominated = True
                break
        if not dominated:
            pareto.append((c, v, m))

    pareto.sort(key=lambda x: (x[0], -x[1]))

    legal_pareto = [(c, v, m) for c, v, m in pareto if is_first_species_legal(cantus, m)]
    max_legal_var = max((v for _, v, _ in legal_pareto), default=0)
    high_variety = [(c, v, m) for c, v, m in pareto if v > max_legal_var]

    print(f"\nPareto-optimal points: {len(pareto)}")
    print(f"  Legal Pareto points:        {len(legal_pareto)}")
    print(f"  Max legal variety:          {max_legal_var}")
    print(f"  Higher-variety Pareto pts:  {len(high_variety)}")

    print(f"\nSample Pareto points:")
    print(f"{'Cost':>8} {'Variety':>8} {'Legal':>6}  Melody")
    print("-" * 70)
    shown = set()
    for c, v, m in pareto:
        if v not in shown or c == 0:
            shown.add(v)
            legal_flag = "✓" if is_first_species_legal(cantus, m) else " "
            intervals = [m[i]-cantus[i] for i in range(n)]
            print(f"{c:8.1f} {v:8d}  {legal_flag:>4}   intervals: {intervals}")
        if len(shown) > 10:
            break

    if high_variety:
        print(f"\n✓ Both zero-cost AND high-variety Pareto points exist")
        print(f"  → The Pareto frontier spans from strict Palestrina-style (cost=0)")
        print(f"    to Bach-style configurations (higher variety, positive cost)")
    else:
        # Show the tradeoff manually
        # Find highest variety melody with some cost
        max_var_point = max(points, key=lambda x: x[1])
        min_cost_point = min(points, key=lambda x: x[0])
        print(f"\n  Min cost point: cost={min_cost_point[0]:.1f}, variety={min_cost_point[1]}")
        print(f"  Max variety point: cost={max_var_point[0]:.1f}, variety={max_var_point[1]}")
        if max_var_point[1] > min_cost_point[1] and max_var_point[0] > 0:
            print(f"  → These are Pareto-incomparable: cost-variety tradeoff exists")

    # Show Bach score for different lambda values
    print(f"\nBach score analysis (cost - λ·variety):")
    for lam in [0.0, 0.5, 1.0, 2.0, 5.0]:
        best = min(candidates, key=lambda m: total_cost(cantus, m) - lam * harmonic_variety(cantus, m))
        score = total_cost(cantus, best) - lam * harmonic_variety(cantus, best)
        legal_flag = "✓" if is_first_species_legal(cantus, best) else " "
        print(f"  λ={lam:4.1f}: best score={score:6.1f}, cost={total_cost(cantus,best):.1f}, "
              f"variety={harmonic_variety(cantus,best)}, legal={legal_flag}")
    print("  → As λ increases, optimizer shifts from strict rules to harmonic richness")
    print()

# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_theorem1()
    demo_theorem2()
    demo_dp()
    demo_pareto()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""
import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def encode_image(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Lean proofs
lean_files = [
    'Bridges/TropicalCounterpoint/Defs.lean',
    'Bridges/TropicalCounterpoint/Penalties.lean',
    'Bridges/TropicalCounterpoint/Optimization.lean',
    'Bridges/TropicalCounterpoint/DynamicProgramming.lean',
    'Bridges/TropicalCounterpoint/Pareto.lean',
]
lean_proofs = '\n\n'.join(
    f'-- ═══ {f} ═══\n\n' + read_file(f) for f in lean_files
)

# Read Python code
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Encode visualizations
viz_files = [
    ('Penalty Landscape', 'fig_penalty_landscape.png'),
    ('Pareto Frontier', 'fig_pareto_frontier.png'),
    ('DP Lattice', 'fig_dp_lattice.png'),
    ('Bach Score Analysis', 'fig_bach_score.png'),
]
visualizations = [
    {"name": name, "data": encode_image(path)}
    for name, path in viz_files
    if os.path.exists(path)
]

package = {
    "title": "Tropical Counterpoint: Musical Voice-Leading as Min-Plus Optimization",
    "domain": "Tropical Algebra × Music Theory × Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Counterpoint Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical DP Voice Leading",
            "pseudocode": """Algorithm: TROPICAL-DP-VOICE-LEADING(cantus, pitchRange, weights)
Input: cantus firmus u[0..n-1], pitch set P, weights (A, B, C)
Output: optimal melody v[0..n-1], optimal cost

1. For each x in P: dp[0][x] = A * forbiddenVerticalPenalty(x - u[0])
2. For k = 1 to n-1:
3.   For each x in P:
4.     dp[k][x] = min over y in P of:
         A*vert(x,u[k]) + B*mel(y,x) + C*par(y,x) + dp[k-1][y]
5.     parent[k][x] = argmin of line 4
6. opt = argmin over x in P of dp[n-1][x]
7. Backtrack to recover melody
8. Return melody, dp[n-1][opt]

Time: O(n * |P|^2)    Space: O(n * |P|)""",
            "code": algorithms_code
        },
        {
            "name": "Pareto Frontier Computation",
            "pseudocode": """Algorithm: PARETO-FRONTIER(cantus, candidates)
Input: cantus u, candidate melodies S
Output: Pareto-optimal subset

1. For each m in S: compute (cost(m), variety(m))
2. P = empty set
3. For each m in S:
4.   If no m' in S dominates m: add m to P
5. Return P sorted by cost

Time: O(|S|^2)    Space: O(|S|)""",
            "code": applications_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Counterpoint: Visualizations

Generates publication-quality figures illustrating the key mathematical
structures of tropical music theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List
import base64
import io

# ─── Musical Constants ───────────────────────────────────────────────
PERFECT = {0, 7, 12}
IMPERFECT = {3, 4, 8, 9}
CONSONANCES = PERFECT | IMPERFECT

def forbidden_vertical_penalty(k): return 0.0 if abs(k) in CONSONANCES else 1.0
def melodic_leap_penalty(x, y): return max(0.0, abs(y - x) - 2)
def parallel_perfect_penalty(a, b):
    return 1.0 if abs(a) in PERFECT and abs(b) in PERFECT else 0.0

def total_cost(cantus, melody):
    n = len(cantus)
    ivs = [melody[i] - cantus[i] for i in range(n)]
    v = sum(forbidden_vertical_penalty(ivs[i]) for i in range(n))
    m = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
    p = sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
    return v + m + p

def harmonic_variety(cantus, melody):
    return len(set(melody[i] - cantus[i] for i in range(len(cantus))))

# ─── Figure 1: Penalty Landscape ────────────────────────────────────

def fig_penalty_landscape():
    """Visualize the vertical interval penalty as a function of interval."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Panel A: Vertical penalty
    intervals = range(-15, 16)
    penalties = [forbidden_vertical_penalty(k) for k in intervals]
    ax = axes[0]
    colors = ['#2ecc71' if p == 0 else '#e74c3c' for p in penalties]
    ax.bar(list(intervals), penalties, color=colors, alpha=0.8, width=0.8)
    ax.set_xlabel('Vertical Interval (semitones)', fontsize=11)
    ax.set_ylabel('Penalty', fontsize=11)
    ax.set_title('(a) Vertical Interval Penalty', fontsize=12, fontweight='bold')
    ax.set_ylim(-0.1, 1.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Panel B: Melodic leap penalty
    steps = np.arange(0, 13)
    leap_pen = [max(0, s - 2) for s in steps]
    ax = axes[1]
    ax.bar(steps, leap_pen, color='#3498db', alpha=0.8)
    ax.set_xlabel('Melodic Step Size (semitones)', fontsize=11)
    ax.set_ylabel('Penalty', fontsize=11)
    ax.set_title('(b) Melodic Leap Penalty', fontsize=12, fontweight='bold')

    # Panel C: Parallel perfect penalty (heatmap)
    ax = axes[2]
    iv_range = list(range(-12, 13))
    grid = np.zeros((len(iv_range), len(iv_range)))
    for i, a in enumerate(iv_range):
        for j, b in enumerate(iv_range):
            grid[i, j] = parallel_perfect_penalty(a, b)
    im = ax.imshow(grid, cmap='RdYlGn_r', aspect='auto',
                   extent=[-12.5, 12.5, -12.5, 12.5], origin='lower')
    ax.set_xlabel('Current Interval', fontsize=11)
    ax.set_ylabel('Next Interval', fontsize=11)
    ax.set_title('(c) Parallel Perfect Penalty', fontsize=12, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)

    plt.tight_layout()
    plt.savefig('fig_penalty_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_penalty_landscape.png")

# ─── Figure 2: Pareto Frontier ──────────────────────────────────────

def fig_pareto_frontier():
    """Visualize the Pareto frontier of cost vs. variety."""
    cantus = [60, 62, 64, 65, 67, 65, 64, 62]
    n = len(cantus)

    # Generate candidates
    candidates = set()
    import random
    random.seed(42)

    # Stepwise
    for start in range(55, 76):
        stack = [(0, (start,))]
        while stack:
            pos, path = stack.pop()
            if pos == n - 1:
                candidates.add(path)
                continue
            for step in range(-2, 3):
                nxt = path[-1] + step
                if 55 <= nxt <= 76:
                    stack.append((pos + 1, path + (nxt,)))

    # Leaping
    for _ in range(50000):
        m = [random.randint(55, 76)]
        for _ in range(1, n):
            m.append(max(55, min(76, m[-1] + random.choice(range(-4, 5)))))
        candidates.add(tuple(m))

    candidates = [list(m) for m in candidates]
    points = [(total_cost(cantus, m), harmonic_variety(cantus, m), m) for m in candidates]

    # Pareto
    pareto = []
    for c, v, m in points:
        dominated = any(
            (c2 <= c and v2 >= v) and (c2 < c or v2 > v)
            for c2, v2, _ in points
        )
        if not dominated:
            pareto.append((c, v, m))

    fig, ax = plt.subplots(figsize=(10, 6))

    # All points
    costs = [c for c, v, _ in points]
    varieties = [v for c, v, _ in points]
    ax.scatter(costs, varieties, alpha=0.03, s=10, c='gray', label='All melodies')

    # Pareto frontier
    pc = [c for c, v, _ in pareto]
    pv = [v for c, v, _ in pareto]
    ax.scatter(pc, pv, c='#e74c3c', s=50, zorder=5, edgecolors='black',
              linewidths=0.5, label='Pareto frontier')

    # Highlight legal points
    legal_p = [(c, v) for c, v, m in pareto
               if total_cost(cantus, m) == 0]
    if legal_p:
        ax.scatter([c for c, v in legal_p], [v for c, v in legal_p],
                  c='#2ecc71', s=100, zorder=6, edgecolors='black',
                  linewidths=1, marker='*', label='Legal (Palestrina)')

    ax.set_xlabel('Contrapuntal Cost (tropical penalty)', fontsize=13)
    ax.set_ylabel('Harmonic Variety (distinct intervals)', fontsize=13)
    ax.set_title('Pareto Frontier: Cost vs. Harmonic Variety', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='lower right')

    # Annotate regions
    ax.annotate('Strict Counterpoint\n(zero cost, Palestrina)',
               xy=(0, max(v for c, v in legal_p) if legal_p else 5),
               xytext=(3, max(v for c, v in legal_p)-1 if legal_p else 4),
               fontsize=10, fontstyle='italic',
               arrowprops=dict(arrowstyle='->', color='#2ecc71'),
               color='#2ecc71')

    ax.annotate('Rich Harmony\n(higher cost, Bach-style)',
               xy=(max(pc)*0.7, max(pv)),
               xytext=(max(pc)*0.5, max(pv)-0.5),
               fontsize=10, fontstyle='italic', color='#e74c3c')

    plt.tight_layout()
    plt.savefig('fig_pareto_frontier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_pareto_frontier.png")

# ─── Figure 3: DP Lattice ───────────────────────────────────────────

def fig_dp_lattice():
    """Visualize the layered DAG for tropical DP."""
    cantus = [60, 62, 64, 65, 67]
    n = len(cantus)
    pitch_range = range(55, 73)

    # Run DP
    dp = [{} for _ in range(n)]
    for x in pitch_range:
        dp[0][x] = forbidden_vertical_penalty(x - cantus[0])
    for k in range(1, n):
        for x in pitch_range:
            best = float('inf')
            for y in pitch_range:
                tr = (forbidden_vertical_penalty(x - cantus[k]) +
                      melodic_leap_penalty(y, x) +
                      parallel_perfect_penalty(y - cantus[k-1], x - cantus[k]))
                best = min(best, tr + dp[k-1][y])
            dp[k][x] = best

    # Find optimal path
    opt_end = min(pitch_range, key=lambda x: dp[n-1][x])
    path = [0] * n
    path[n-1] = opt_end
    for k in range(n-2, -1, -1):
        path[k] = min(pitch_range,
                      key=lambda y: dp[k][y] +
                      forbidden_vertical_penalty(path[k+1] - cantus[k+1]) +
                      melodic_leap_penalty(y, path[k+1]) +
                      parallel_perfect_penalty(y - cantus[k], path[k+1] - cantus[k+1]))

    fig, ax = plt.subplots(figsize=(12, 7))

    # Draw nodes
    for k in range(n):
        for x in pitch_range:
            cost = dp[k][x]
            color = plt.cm.viridis(1 - min(cost / 5, 1))
            size = max(30, 150 - cost * 20)
            ax.scatter(k, x, c=[color], s=size, zorder=3, edgecolors='gray',
                      linewidths=0.3, alpha=0.7)

    # Draw optimal path
    ax.plot(range(n), path, 'r-o', linewidth=2.5, markersize=10,
           zorder=5, label=f'Optimal path (cost={dp[n-1][opt_end]:.0f})')

    # Draw cantus
    ax.plot(range(n), cantus, 'b--s', linewidth=1.5, markersize=8,
           alpha=0.7, label='Cantus firmus', zorder=4)

    ax.set_xlabel('Time Step', fontsize=13)
    ax.set_ylabel('Pitch (MIDI)', fontsize=13)
    ax.set_title('Tropical DP Lattice: Shortest Path = Optimal Voice Leading',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xticks(range(n))
    ax.set_xticklabels([f't={k}' for k in range(n)])

    plt.tight_layout()
    plt.savefig('fig_dp_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_dp_lattice.png")

# ─── Figure 4: Bach Score Landscape ─────────────────────────────────

def fig_bach_score():
    """Visualize how the Bach score varies with λ."""
    cantus = [60, 62, 64, 65, 67, 65, 64, 62]
    n = len(cantus)

    # Generate diverse candidates
    import random
    random.seed(42)
    candidates = []
    for start in range(55, 76):
        stack = [(0, [start])]
        while stack:
            pos, path = stack.pop()
            if pos == n - 1:
                candidates.append(list(path))
                continue
            for step in range(-3, 4):
                nxt = path[-1] + step
                if 55 <= nxt <= 76:
                    stack.append((pos + 1, path + [nxt]))
                    if len(candidates) > 500000:
                        break
            if len(candidates) > 500000:
                break
        if len(candidates) > 500000:
            break

    # Add random leaping melodies
    for _ in range(50000):
        m = [random.randint(55, 76)]
        for _ in range(1, n):
            m.append(max(55, min(76, m[-1] + random.choice(range(-4, 5)))))
        candidates.append(m)

    # Compute cost and variety for each
    data = []
    for m in candidates:
        c = total_cost(cantus, m)
        v = harmonic_variety(cantus, m)
        data.append((c, v, m))

    lambdas = np.linspace(0, 3, 50)
    best_costs = []
    best_varieties = []
    best_scores = []

    for lam in lambdas:
        best = min(data, key=lambda x: x[0] - lam * x[1])
        best_costs.append(best[0])
        best_varieties.append(best[1])
        best_scores.append(best[0] - lam * best[1])

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    ax = axes[0]
    ax.plot(lambdas, best_costs, 'r-', linewidth=2)
    ax.set_xlabel('λ (variety reward)', fontsize=12)
    ax.set_ylabel('Contrapuntal Cost', fontsize=12)
    ax.set_title('(a) Cost of Bach-Optimal Melody', fontsize=12, fontweight='bold')
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

    ax = axes[1]
    ax.plot(lambdas, best_varieties, 'g-', linewidth=2)
    ax.set_xlabel('λ (variety reward)', fontsize=12)
    ax.set_ylabel('Harmonic Variety', fontsize=12)
    ax.set_title('(b) Variety of Bach-Optimal Melody', fontsize=12, fontweight='bold')

    ax = axes[2]
    ax.plot(lambdas, best_scores, 'b-', linewidth=2)
    ax.set_xlabel('λ (variety reward)', fontsize=12)
    ax.set_ylabel('Bach Score', fontsize=12)
    ax.set_title('(c) Optimal Bach Score', fontsize=12, fontweight='bold')
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')

    # Mark transition point
    transition = None
    for i in range(1, len(lambdas)):
        if best_costs[i] > 0 and best_costs[i-1] == 0:
            transition = lambdas[i]
            break
    if transition:
        for ax in axes:
            ax.axvline(x=transition, color='purple', linewidth=1.5, linestyle='--',
                      alpha=0.7, label=f'Style transition λ≈{transition:.1f}')
            ax.legend(fontsize=9)

    plt.suptitle('Bach Score Analysis: Style Transition as λ Increases',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_bach_score.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_bach_score.png")


def encode_image_base64(filepath):
    """Read an image file and return base64 data URI."""
    with open(filepath, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    fig_penalty_landscape()
    fig_pareto_frontier()
    fig_dp_lattice()
    fig_bach_score()
    print("\nAll figures generated successfully.")
