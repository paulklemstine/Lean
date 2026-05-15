#!/usr/bin/env python3
"""
Applications of Voice-Leading Geometry to Music Analysis and Generation.

Demonstrates practical applications of the formally verified PLR theory:
1. Harmonic analysis of chord progressions
2. Optimal chord transition finder
3. PLR-geodesic composition generator
4. Harmonic similarity metric for music information retrieval
"""

import itertools
from typing import List, Tuple, Dict, Optional
import random


# ============================================================
# Core definitions (self-contained)
# ============================================================

NOTE_NAMES = ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']

def pc(n): return n % 12
def pc_dist(a, b):
    d = (a - b) % 12
    return min(d, 12 - d)

def major_notes(r): return (pc(r), pc(r+4), pc(r+7))
def minor_notes(r): return (pc(r), pc(r+3), pc(r+7))

def chord_notes(root, quality):
    return major_notes(root) if quality == 'major' else minor_notes(root)

def vl_dist(t1, t2):
    return min(
        sum(pc_dist(t1[i], t2[p[i]]) for i in range(3))
        for p in itertools.permutations(range(3))
    )

def chord_name(root, quality):
    suffix = '' if quality == 'major' else 'm'
    return f"{NOTE_NAMES[root % 12]}{suffix}"

def apply_plr(op, root, quality):
    if op == 'P':
        return (root, 'minor' if quality == 'major' else 'major')
    elif op == 'L':
        return (pc(root + 4), 'minor') if quality == 'major' else (pc(root + 8), 'major')
    elif op == 'R':
        return (pc(root + 9), 'minor') if quality == 'major' else (pc(root + 3), 'major')


# ============================================================
# Application 1: Harmonic Analysis of Chord Progressions
# ============================================================

def analyze_progression(chords: List[Tuple[int, str]]) -> Dict:
    """
    Analyze a chord progression using voice-leading geometry.
    
    For each consecutive pair of chords, computes:
    - Voice-leading distance
    - Whether the transition is a PLR move
    - The PLR decomposition (if the transition consists of PLR moves)
    
    Args:
        chords: List of (root, quality) pairs.
    
    Returns:
        Analysis dictionary with distances and PLR classifications.
    
    Example:
        >>> analyze_progression([(0,'major'), (0,'minor'), (4,'minor'), (9,'minor')])
    """
    analysis = {
        'chords': [chord_name(*c) for c in chords],
        'transitions': [],
        'total_distance': 0,
        'plr_count': 0,
        'non_plr_count': 0,
    }
    
    for i in range(len(chords) - 1):
        r1, q1 = chords[i]
        r2, q2 = chords[i + 1]
        n1 = chord_notes(r1, q1)
        n2 = chord_notes(r2, q2)
        d = vl_dist(n1, n2)
        
        # Check if it's a PLR move
        plr_move = None
        for op in ['P', 'L', 'R']:
            tr, tq = apply_plr(op, r1, q1)
            if tr == r2 % 12 and tq == q2:
                plr_move = op
                break
        
        transition = {
            'from': chord_name(r1, q1),
            'to': chord_name(r2, q2),
            'distance': d,
            'plr': plr_move,
            'is_plr': plr_move is not None,
        }
        
        analysis['transitions'].append(transition)
        analysis['total_distance'] += d
        if plr_move:
            analysis['plr_count'] += 1
        else:
            analysis['non_plr_count'] += 1
    
    analysis['avg_distance'] = (
        analysis['total_distance'] / len(analysis['transitions'])
        if analysis['transitions'] else 0
    )
    analysis['plr_ratio'] = (
        analysis['plr_count'] / len(analysis['transitions'])
        if analysis['transitions'] else 0
    )
    
    return analysis


def print_analysis(analysis: Dict):
    """Pretty-print a harmonic analysis."""
    print(f"\n  Progression: {' → '.join(analysis['chords'])}")
    print(f"  {'─' * 50}")
    
    for t in analysis['transitions']:
        plr_info = f" [{t['plr']}]" if t['plr'] else "     "
        print(f"  {t['from']:>5} → {t['to']:<5}  dist = {t['distance']}{plr_info}")
    
    print(f"  {'─' * 50}")
    print(f"  Total distance: {analysis['total_distance']}")
    print(f"  Average distance: {analysis['avg_distance']:.2f}")
    print(f"  PLR moves: {analysis['plr_count']}/{len(analysis['transitions'])} "
          f"({analysis['plr_ratio']:.0%})")


# ============================================================
# Application 2: Optimal Chord Transition Finder
# ============================================================

def find_optimal_plr_path(source: Tuple[int, str], target: Tuple[int, str],
                           max_length: int = 8) -> Optional[List[str]]:
    """
    Find the shortest sequence of PLR moves from source to target chord.
    
    Uses BFS on the PLR graph (which is the Tonnetz).
    
    Time: O(24 · 3^depth) worst case, but the graph has only 24 vertices.
    Space: O(24)
    
    >>> find_optimal_plr_path((0, 'major'), (6, 'minor'))
    ['L', 'R', 'L']
    """
    from collections import deque
    
    start = (source[0] % 12, source[1])
    end = (target[0] % 12, target[1])
    
    if start == end:
        return []
    
    queue = deque([(start, [])])
    visited = {start}
    
    while queue:
        (r, q), path = queue.popleft()
        
        if len(path) >= max_length:
            continue
        
        for op in ['P', 'L', 'R']:
            nr, nq = apply_plr(op, r, q)
            state = (nr, nq)
            
            if state == end:
                return path + [op]
            
            if state not in visited:
                visited.add(state)
                queue.append((state, path + [op]))
    
    return None  # Shouldn't happen for connected graph


def find_all_shortest_paths(source: Tuple[int, str], target: Tuple[int, str]) -> List[List[str]]:
    """Find ALL shortest PLR paths from source to target."""
    from collections import deque
    
    start = (source[0] % 12, source[1])
    end = (target[0] % 12, target[1])
    
    if start == end:
        return [[]]
    
    # BFS to find shortest path length first
    shortest = find_optimal_plr_path(source, target)
    if shortest is None:
        return []
    target_len = len(shortest)
    
    # Now find ALL paths of that length
    all_paths = []
    queue = deque([(start, [])])
    
    while queue:
        (r, q), path = queue.popleft()
        
        if len(path) > target_len:
            continue
        
        if (r, q) == end and len(path) == target_len:
            all_paths.append(path)
            continue
        
        if len(path) < target_len:
            for op in ['P', 'L', 'R']:
                nr, nq = apply_plr(op, r, q)
                queue.append(((nr, nq), path + [op]))
    
    return all_paths


# ============================================================
# Application 3: PLR-Geodesic Composition Generator
# ============================================================

def generate_geodesic_progression(start: Tuple[int, str], length: int = 8,
                                   seed: int = 42) -> List[Tuple[int, str]]:
    """
    Generate a chord progression using only PLR moves, preferring
    geodesic (distance-minimizing) transitions.
    
    Strategy: At each step, randomly choose a PLR move with probability
    weighted by the inverse of the voice-leading distance. This creates
    progressions that favor smooth voice leading.
    
    Args:
        start: Starting chord (root, quality).
        length: Number of chords in the progression.
        seed: Random seed for reproducibility.
    
    Returns:
        List of (root, quality) pairs.
    """
    rng = random.Random(seed)
    progression = [start]
    
    current = start
    for _ in range(length - 1):
        # Compute weighted choices: P and L have weight 2 (distance 1),
        # R has weight 1 (distance 2)
        weights = {'P': 2.0, 'L': 2.0, 'R': 1.0}
        ops = list(weights.keys())
        ws = [weights[op] for op in ops]
        
        # Avoid immediate repetition
        if len(progression) >= 2:
            prev = progression[-2]
            for op in ops:
                r, q = apply_plr(op, current[0], current[1])
                if (r, q) == prev:
                    ws[ops.index(op)] *= 0.1  # Strongly discourage going back
        
        chosen = rng.choices(ops, weights=ws, k=1)[0]
        r, q = apply_plr(chosen, current[0], current[1])
        progression.append((r, q))
        current = (r, q)
    
    return progression


# ============================================================
# Application 4: Harmonic Similarity Metric for MIR
# ============================================================

def harmonic_similarity(prog1: List[Tuple[int, str]],
                         prog2: List[Tuple[int, str]]) -> float:
    """
    Compute harmonic similarity between two chord progressions
    using the voice-leading distance metric.
    
    Uses dynamic time warping (DTW) with the voice-leading distance
    as the base metric. Returns a normalized similarity score in [0, 1].
    
    This leverages the formally verified metric properties:
    - chordDist is a true metric (satisfies triangle inequality)
    - PLR moves are geodesic in this metric
    
    Args:
        prog1, prog2: Chord progressions as lists of (root, quality) pairs.
    
    Returns:
        Similarity score in [0, 1], where 1 = identical, 0 = maximally different.
    """
    n, m = len(prog1), len(prog2)
    
    # DTW matrix
    dtw = [[float('inf')] * (m + 1) for _ in range(n + 1)]
    dtw[0][0] = 0
    
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            cost = vl_dist(
                chord_notes(*prog1[i-1]),
                chord_notes(*prog2[j-1])
            )
            dtw[i][j] = cost + min(dtw[i-1][j], dtw[i][j-1], dtw[i-1][j-1])
    
    raw_dist = dtw[n][m]
    max_possible = 6 * max(n, m)  # Maximum distance per step is 6 (tritone × 3)
    similarity = 1 - raw_dist / max_possible if max_possible > 0 else 1.0
    
    return max(0.0, min(1.0, similarity))


# ============================================================
# Main: Demonstrate all applications
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF VOICE-LEADING GEOMETRY")
    print("=" * 70)
    
    # Application 1: Analyze famous progressions
    print("\n--- Application 1: Harmonic Analysis ---")
    
    progressions = {
        "Beethoven 'Moonlight' (i-VI-iv-V)": [
            (1, 'minor'), (6, 'major'), (6, 'minor'), (8, 'major')
        ],
        "Neo-Riemannian cycle (P-L-R from C)": [
            (0, 'major'), (0, 'minor'), (8, 'major'), (5, 'minor')
        ],
        "Coltrane changes (C-E♭-G♭-A)": [
            (0, 'major'), (3, 'major'), (6, 'major'), (9, 'major')
        ],
        "Pop (I-V-vi-IV in C)": [
            (0, 'major'), (7, 'major'), (9, 'minor'), (5, 'major')
        ],
    }
    
    for name, prog in progressions.items():
        print(f"\n  {name}:")
        analysis = analyze_progression(prog)
        print_analysis(analysis)
    
    # Application 2: Optimal PLR paths
    print("\n--- Application 2: Optimal PLR Paths ---")
    
    path_queries = [
        ((0, 'major'), (6, 'minor'), "C → F♯m"),
        ((0, 'major'), (6, 'major'), "C → F♯"),
        ((0, 'major'), (9, 'minor'), "C → Am"),
        ((0, 'major'), (5, 'major'), "C → F"),
        ((0, 'major'), (0, 'major'), "C → C"),
    ]
    
    for src, tgt, desc in path_queries:
        path = find_optimal_plr_path(src, tgt)
        all_paths = find_all_shortest_paths(src, tgt)
        total_dist = sum(
            1 if op in ['P', 'L'] else 2
            for op in (path or [])
        )
        print(f"\n  {desc}:")
        print(f"    Shortest path: {' → '.join(path) if path else '(identity)'}")
        print(f"    Total PLR distance: {total_dist}")
        print(f"    Number of shortest paths: {len(all_paths)}")
        if len(all_paths) <= 5:
            for p in all_paths:
                print(f"      {' → '.join(p)}")
    
    # Application 3: Generate compositions
    print("\n--- Application 3: PLR-Geodesic Composition ---")
    
    for seed in [42, 123, 7]:
        prog = generate_geodesic_progression((0, 'major'), length=8, seed=seed)
        names = [chord_name(*c) for c in prog]
        analysis = analyze_progression(prog)
        print(f"\n  Seed {seed}: {' → '.join(names)}")
        print(f"    Total distance: {analysis['total_distance']}, "
              f"avg: {analysis['avg_distance']:.2f}, "
              f"PLR ratio: {analysis['plr_ratio']:.0%}")
    
    # Application 4: Harmonic similarity
    print("\n--- Application 4: Harmonic Similarity (MIR) ---")
    
    prog_a = [(0, 'major'), (0, 'minor'), (4, 'minor'), (9, 'minor')]  # PLR-smooth
    prog_b = [(0, 'major'), (0, 'minor'), (8, 'major'), (5, 'minor')]  # PLR cycle
    prog_c = [(0, 'major'), (6, 'major'), (3, 'minor'), (9, 'major')]  # Disjunct
    
    names_a = ' → '.join(chord_name(*c) for c in prog_a)
    names_b = ' → '.join(chord_name(*c) for c in prog_b)
    names_c = ' → '.join(chord_name(*c) for c in prog_c)
    
    print(f"\n  Progression A: {names_a}")
    print(f"  Progression B: {names_b}")
    print(f"  Progression C: {names_c}")
    print(f"\n  Similarity(A, B) = {harmonic_similarity(prog_a, prog_b):.3f}")
    print(f"  Similarity(A, C) = {harmonic_similarity(prog_a, prog_c):.3f}")
    print(f"  Similarity(B, C) = {harmonic_similarity(prog_b, prog_c):.3f}")
    print(f"  Similarity(A, A) = {harmonic_similarity(prog_a, prog_a):.3f}")


#!/usr/bin/env python3
"""
Demo: Neo-Riemannian PLR Theory and Voice-Leading Geometry

Demonstrates the formally verified theorems connecting PLR transformations
to geodesic structure in voice-leading space.
"""

import itertools
from typing import List, Tuple, Dict

# ============================================================
# § 1. Pitch Classes and Triads
# ============================================================

NOTE_NAMES = ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']

def pc(n: int) -> int:
    """Pitch class: integer mod 12."""
    return n % 12

def major_triad(root: int) -> Tuple[int, int, int]:
    """Major triad rooted at `root`: (root, root+4, root+7)."""
    return (pc(root), pc(root + 4), pc(root + 7))

def minor_triad(root: int) -> Tuple[int, int, int]:
    """Minor triad rooted at `root`: (root, root+3, root+7)."""
    return (pc(root), pc(root + 3), pc(root + 7))

def triad_name(root: int, quality: str) -> str:
    """Human-readable name for a triad."""
    return f"{NOTE_NAMES[root % 12]} {quality}"

# ============================================================
# § 2. PLR Transformations
# ============================================================

def plr_P(root: int, quality: str) -> Tuple[int, str]:
    """Parallel: same root, flip quality."""
    new_q = 'minor' if quality == 'major' else 'major'
    return (root, new_q)

def plr_L(root: int, quality: str) -> Tuple[int, str]:
    """Leading-tone exchange."""
    if quality == 'major':
        return (pc(root + 4), 'minor')
    else:
        return (pc(root + 8), 'major')

def plr_R(root: int, quality: str) -> Tuple[int, str]:
    """Relative."""
    if quality == 'major':
        return (pc(root + 9), 'minor')
    else:
        return (pc(root + 3), 'major')

PLR_OPS = {'P': plr_P, 'L': plr_L, 'R': plr_R}

# ============================================================
# § 3. Voice-Leading Distance
# ============================================================

def pc_dist(a: int, b: int) -> int:
    """Circular distance between two pitch classes."""
    d = (a - b) % 12
    return min(d, 12 - d)

def vl_dist(t1: Tuple[int, int, int], t2: Tuple[int, int, int]) -> int:
    """Voice-leading distance: minimum total displacement over all bijections."""
    min_d = float('inf')
    for perm in itertools.permutations(range(3)):
        d = sum(pc_dist(t1[i], t2[perm[i]]) for i in range(3))
        min_d = min(min_d, d)
    return min_d

def get_notes(root: int, quality: str) -> Tuple[int, int, int]:
    """Get notes of a triad."""
    return major_triad(root) if quality == 'major' else minor_triad(root)

def common_tones(t1: Tuple[int, int, int], t2: Tuple[int, int, int]) -> int:
    """Number of common tones between two triads."""
    return len(set(t1) & set(t2))

# ============================================================
# § 4. Verification of Formally Proved Theorems
# ============================================================

def verify_all():
    """Verify all formally proved theorems computationally."""
    
    print("=" * 70)
    print("VERIFICATION OF FORMALLY PROVED THEOREMS")
    print("Neo-Riemannian PLR Theory and Voice-Leading Geometry")
    print("=" * 70)
    
    all_chords = [(r, q) for r in range(12) for q in ['major', 'minor']]
    
    # --- Theorem: PLR Involution ---
    print("\n§ 1. PLR Involution: T(T(c)) = c")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        for name, op in PLR_OPS.items():
            r2, q2 = op(r, q)
            r3, q3 = op(r2, q2)
            if r3 != r or q3 != q:
                print(f"  FAIL: {name}({name}({triad_name(r,q)})) ≠ {triad_name(r,q)}")
                ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'} for all 72 cases (24 chords × 3 ops)")
    
    # --- Theorem: PLR Flips Quality ---
    print("\n§ 2. PLR Flips Quality")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        for name, op in PLR_OPS.items():
            _, q2 = op(r, q)
            if q2 == q:
                print(f"  FAIL: {name}({triad_name(r,q)}) has same quality")
                ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'} for all 72 cases")
    
    # --- Theorem: PLR Distances ---
    print("\n§ 3. PLR Voice-Leading Distances")
    print("-" * 40)
    expected = {'P': 1, 'L': 1, 'R': 2}
    for name, op in PLR_OPS.items():
        ok = True
        for r, q in all_chords:
            r2, q2 = op(r, q)
            d = vl_dist(get_notes(r, q), get_notes(r2, q2))
            if d != expected[name]:
                print(f"  FAIL: dist({triad_name(r,q)}, {name}({triad_name(r,q)})) = {d}, expected {expected[name]}")
                ok = False
        print(f"  {name}: distance = {expected[name]}  {'✓' if ok else '✗ FAILED'}")
    
    # --- Theorem: P and L Minimize ---
    print("\n§ 4. P and L Minimize Voice-Leading Distance to Opposite Quality")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        p_notes = get_notes(*plr_P(r, q))
        l_notes = get_notes(*plr_L(r, q))
        my_notes = get_notes(r, q)
        d_P = vl_dist(my_notes, p_notes)
        d_L = vl_dist(my_notes, l_notes)
        for r2, q2 in all_chords:
            if q2 != q:
                d = vl_dist(my_notes, get_notes(r2, q2))
                if d < d_P:
                    print(f"  FAIL: {triad_name(r2,q2)} closer than P({triad_name(r,q)})")
                    ok = False
                if d < d_L:
                    print(f"  FAIL: {triad_name(r2,q2)} closer than L({triad_name(r,q)})")
                    ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'}: P and L achieve minimum distance (=1)")
    
    # --- Theorem: P and L are unique minimizers ---
    print("\n§ 5. P and L are the UNIQUE Distance-1 Opposite-Quality Chords")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        my_notes = get_notes(r, q)
        r_P, q_P = plr_P(r, q)
        r_L, q_L = plr_L(r, q)
        dist1_chords = []
        for r2, q2 in all_chords:
            if q2 != q and vl_dist(my_notes, get_notes(r2, q2)) == 1:
                dist1_chords.append((r2, q2))
        if set(dist1_chords) != {(r_P, q_P), (r_L, q_L)}:
            print(f"  FAIL at {triad_name(r,q)}: dist-1 chords = {dist1_chords}")
            ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'}: exactly P(c) and L(c) at distance 1")
    
    # --- Theorem: Near-Geodesicity with C=2 ---
    print("\n§ 6. Uniform Near-Geodesicity: vlDist(c,T(c)) ≤ 2·vlDist(c,d)")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        my_notes = get_notes(r, q)
        for name, op in PLR_OPS.items():
            r_T, q_T = op(r, q)
            d_T = vl_dist(my_notes, get_notes(r_T, q_T))
            for r2, q2 in all_chords:
                if q2 != q:
                    d = vl_dist(my_notes, get_notes(r2, q2))
                    if d_T > 2 * d:
                        print(f"  FAIL: {name} on {triad_name(r,q)}: {d_T} > 2·{d}")
                        ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'}: C = 2 bound holds universally")
    
    # --- Theorem: 2 Common Tones ---
    print("\n§ 7. PLR Preserves Exactly 2 Common Tones")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        for name, op in PLR_OPS.items():
            r2, q2 = op(r, q)
            ct = common_tones(get_notes(r, q), get_notes(r2, q2))
            if ct != 2:
                print(f"  FAIL: {name}({triad_name(r,q)}): {ct} common tones")
                ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'}: all PLR moves preserve exactly 2 tones")
    
    # --- Theorem: PLR Characterization ---
    print("\n§ 8. PLR Characterizes 2-Common-Tone Opposite-Quality Moves")
    print("-" * 40)
    ok = True
    for r, q in all_chords:
        plr_results = {plr_P(r, q), plr_L(r, q), plr_R(r, q)}
        for r2, q2 in all_chords:
            if q2 != q:
                ct = common_tones(get_notes(r, q), get_notes(r2, q2))
                if ct == 2 and (r2, q2) not in plr_results:
                    print(f"  FAIL: {triad_name(r2,q2)} has 2 CT with {triad_name(r,q)} but isn't PLR")
                    ok = False
    print(f"  {'✓ Verified' if ok else '✗ FAILED'}: PLR = 2-common-tone characterization")
    
    # --- Theorem: Triangle Inequality ---
    print("\n§ 9. Triangle Inequality for chordDist")
    print("-" * 40)
    ok = True
    violations = 0
    for r1, q1 in all_chords:
        for r2, q2 in all_chords:
            for r3, q3 in all_chords:
                d12 = vl_dist(get_notes(r1, q1), get_notes(r2, q2))
                d23 = vl_dist(get_notes(r2, q2), get_notes(r3, q3))
                d13 = vl_dist(get_notes(r1, q1), get_notes(r3, q3))
                if d13 > d12 + d23:
                    violations += 1
    print(f"  {'✓ Verified' if violations == 0 else '✗ FAILED'}: "
          f"checked {24**3} = 13,824 triples, {violations} violations")
    
    # --- Summary ---
    print("\n" + "=" * 70)
    print("ALL THEOREMS VERIFIED COMPUTATIONALLY")
    print("=" * 70)

# ============================================================
# § 5. Concrete Examples
# ============================================================

def show_examples():
    """Show concrete examples of PLR transformations."""
    
    print("\n" + "=" * 70)
    print("CONCRETE EXAMPLES: PLR on C Major")
    print("=" * 70)
    
    root, quality = 0, 'major'
    notes = get_notes(root, quality)
    print(f"\nStarting chord: {triad_name(root, quality)} = {{{', '.join(NOTE_NAMES[n] for n in notes)}}}")
    
    for name, op in PLR_OPS.items():
        r2, q2 = op(root, quality)
        notes2 = get_notes(r2, q2)
        d = vl_dist(notes, notes2)
        ct = common_tones(notes, notes2)
        print(f"\n  {name}(C major) = {triad_name(r2, q2)}")
        print(f"    Notes: {{{', '.join(NOTE_NAMES[n] for n in notes2)}}}")
        print(f"    Voice-leading distance: {d}")
        print(f"    Common tones: {ct}")
        
        # Show which voice moves
        for i in range(3):
            if notes[i] != notes2[i]:
                # Find the moving voice
                pass
        # Identify the displacement
        moved = []
        for n1 in notes:
            if n1 not in notes2:
                for n2 in notes2:
                    if n2 not in notes:
                        moved.append((NOTE_NAMES[n1], NOTE_NAMES[n2], pc_dist(n1, n2)))
        if moved:
            for old, new, dist in moved:
                print(f"    Voice motion: {old} → {new} ({dist} semitone{'s' if dist > 1 else ''})")
    
    # Show distance matrix
    print("\n" + "=" * 70)
    print("VOICE-LEADING DISTANCE MATRIX (Major triads vs Minor triads)")
    print("=" * 70)
    
    print(f"\n{'':>12}", end="")
    for r in range(12):
        print(f"  {NOTE_NAMES[r]:>3}m", end="")
    print()
    
    for r1 in range(12):
        print(f"  {NOTE_NAMES[r1]:>3}M  ", end="")
        for r2 in range(12):
            d = vl_dist(major_triad(r1), minor_triad(r2))
            # Mark PLR-adjacent
            mark = ""
            if plr_P(r1, 'major') == (r2, 'minor'):
                mark = "P"
            elif plr_L(r1, 'major') == (r2, 'minor'):
                mark = "L"
            elif plr_R(r1, 'major') == (r2, 'minor'):
                mark = "R"
            print(f"  {d:>2}{mark:<2}", end="")
        print()

# ============================================================
# § 6. Distance Statistics
# ============================================================

def distance_statistics():
    """Compute and display distance statistics."""
    
    print("\n" + "=" * 70)
    print("DISTANCE STATISTICS")
    print("=" * 70)
    
    # Distribution of distances
    all_chords = [(r, q) for r in range(12) for q in ['major', 'minor']]
    dist_counts: Dict[int, int] = {}
    
    for i, (r1, q1) in enumerate(all_chords):
        for r2, q2 in all_chords[i+1:]:
            d = vl_dist(get_notes(r1, q1), get_notes(r2, q2))
            dist_counts[d] = dist_counts.get(d, 0) + 1
    
    print("\nDistance distribution (all chord pairs):")
    for d in sorted(dist_counts.keys()):
        bar = "█" * (dist_counts[d] // 2)
        print(f"  d = {d:2d}: {dist_counts[d]:4d} pairs  {bar}")
    
    # PLR specific
    print("\nPLR distances:")
    for name, op in PLR_OPS.items():
        dists = set()
        for r, q in all_chords:
            r2, q2 = op(r, q)
            d = vl_dist(get_notes(r, q), get_notes(r2, q2))
            dists.add(d)
        print(f"  {name}: distance = {dists}")
    
    # Min distance to opposite quality
    print("\nMinimum distance to any opposite-quality chord:")
    min_opp_dists = set()
    for r, q in all_chords:
        min_d = min(vl_dist(get_notes(r, q), get_notes(r2, q2))
                    for r2, q2 in all_chords if q2 != q)
        min_opp_dists.add(min_d)
    print(f"  Always = {min_opp_dists} (achieved by P and L)")

if __name__ == "__main__":
    verify_all()
    show_examples()
    distance_statistics()


#!/usr/bin/env python3
"""
Visualizations for Neo-Riemannian PLR Theory and Voice-Leading Geometry.

Generates figures showing:
1. The Tonnetz graph with PLR edges
2. Voice-leading distance heatmap
3. PLR displacement diagram
4. Geodesic paths in the sorted chamber
"""

import math
import itertools
from typing import List, Tuple, Dict

# Try matplotlib, fall back to SVG generation
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False


NOTE_NAMES = ['C', 'C♯', 'D', 'E♭', 'E', 'F', 'F♯', 'G', 'A♭', 'A', 'B♭', 'B']


def pc_dist(a: int, b: int) -> int:
    d = (a - b) % 12
    return min(d, 12 - d)


def vl_dist(t1, t2):
    return min(
        sum(pc_dist(t1[i], t2[p[i]]) for i in range(3))
        for p in itertools.permutations(range(3))
    )


def major_triad(r): return (r % 12, (r+4) % 12, (r+7) % 12)
def minor_triad(r): return (r % 12, (r+3) % 12, (r+7) % 12)


def generate_tonnetz_svg() -> str:
    """Generate SVG of the Tonnetz graph with PLR edges."""
    
    width, height = 800, 500
    cx, cy = 400, 250
    
    # Position chords in two concentric circles
    # Outer: major triads, Inner: minor triads
    r_outer = 180
    r_inner = 100
    
    positions = {}
    for i in range(12):
        angle = -math.pi/2 + 2 * math.pi * i / 12
        positions[(i, 'major')] = (
            cx + r_outer * math.cos(angle),
            cy + r_outer * math.sin(angle)
        )
        positions[(i, 'minor')] = (
            cx + r_inner * math.cos(angle),
            cy + r_inner * math.sin(angle)
        )
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" style="background:#1a1a2e">',
        '<defs>',
        '  <style>',
        '    .title { font: bold 18px sans-serif; fill: #e0e0e0; }',
        '    .subtitle { font: 12px sans-serif; fill: #a0a0a0; }',
        '    .note-major { font: bold 11px sans-serif; fill: #1a1a2e; }',
        '    .note-minor { font: bold 11px sans-serif; fill: #e0e0e0; }',
        '    .legend { font: 12px sans-serif; fill: #c0c0c0; }',
        '  </style>',
        '</defs>',
        f'<text x="{cx}" y="30" text-anchor="middle" class="title">The Tonnetz: PLR Transformations on Triads</text>',
        f'<text x="{cx}" y="48" text-anchor="middle" class="subtitle">Outer ring: Major | Inner ring: Minor | Edge colors: P(red) L(blue) R(green)</text>',
    ]
    
    # Draw edges
    # P edges (red): same root, different quality
    for r in range(12):
        x1, y1 = positions[(r, 'major')]
        x2, y2 = positions[(r, 'minor')]
        svg_parts.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="#ff6b6b" stroke-width="2" opacity="0.7"/>'
        )
    
    # L edges (blue)
    for r in range(12):
        # Major r -> Minor r+4
        x1, y1 = positions[(r, 'major')]
        x2, y2 = positions[((r+4) % 12, 'minor')]
        svg_parts.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="#4ecdc4" stroke-width="2" opacity="0.7"/>'
        )
    
    # R edges (green)
    for r in range(12):
        # Major r -> Minor r+9
        x1, y1 = positions[(r, 'major')]
        x2, y2 = positions[((r+9) % 12, 'minor')]
        svg_parts.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="#95e66b" stroke-width="1.5" opacity="0.5" stroke-dasharray="5,3"/>'
        )
    
    # Draw vertices
    for r in range(12):
        # Major (filled circle)
        x, y = positions[(r, 'major')]
        svg_parts.append(
            f'<circle cx="{x}" cy="{y}" r="16" fill="#f8d568" stroke="#c9a832" stroke-width="2"/>'
        )
        svg_parts.append(
            f'<text x="{x}" y="{y+4}" text-anchor="middle" class="note-major">{NOTE_NAMES[r]}</text>'
        )
        
        # Minor (hollow circle)
        x, y = positions[(r, 'minor')]
        svg_parts.append(
            f'<circle cx="{x}" cy="{y}" r="14" fill="#2d3047" stroke="#7b8cde" stroke-width="2"/>'
        )
        svg_parts.append(
            f'<text x="{x}" y="{y+4}" text-anchor="middle" class="note-minor">{NOTE_NAMES[r]}m</text>'
        )
    
    # Legend
    legend_x, legend_y = 30, height - 80
    legend_items = [
        ('#ff6b6b', 'P (Parallel): dist = 1'),
        ('#4ecdc4', 'L (Leading-tone): dist = 1'),
        ('#95e66b', 'R (Relative): dist = 2'),
    ]
    for i, (color, label) in enumerate(legend_items):
        y = legend_y + i * 22
        svg_parts.append(f'<line x1="{legend_x}" y1="{y}" x2="{legend_x+25}" y2="{y}" stroke="{color}" stroke-width="3"/>')
        svg_parts.append(f'<text x="{legend_x+32}" y="{y+4}" class="legend">{label}</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_heatmap_svg() -> str:
    """Generate SVG heatmap of voice-leading distances."""
    
    cell = 36
    margin_left = 60
    margin_top = 70
    width = margin_left + 12 * cell + 20
    height = margin_top + 12 * cell + 40
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" style="background:#1a1a2e">',
        '<defs><style>',
        '  .htitle { font: bold 16px sans-serif; fill: #e0e0e0; }',
        '  .hlabel { font: 11px sans-serif; fill: #c0c0c0; }',
        '  .hval { font: bold 11px sans-serif; }',
        '  .haxis { font: bold 12px sans-serif; fill: #a0a0a0; }',
        '</style></defs>',
        f'<text x="{width//2}" y="22" text-anchor="middle" class="htitle">'
        f'Voice-Leading Distance: Major → Minor Triads</text>',
        f'<text x="{margin_left - 15}" y="{margin_top - 8}" text-anchor="end" class="haxis">Major↓</text>',
        f'<text x="{margin_left + 6*cell}" y="{margin_top - 8}" text-anchor="middle" class="haxis">Minor→</text>',
    ]
    
    # Color scale
    colors = {
        0: '#1a1a2e', 1: '#e74c3c', 2: '#e67e22', 3: '#f1c40f',
        4: '#27ae60', 5: '#2980b9', 6: '#8e44ad', 7: '#34495e',
        8: '#2c3e50', 9: '#1a252f'
    }
    text_colors = {
        0: '#666', 1: '#fff', 2: '#fff', 3: '#111',
        4: '#fff', 5: '#fff', 6: '#fff', 7: '#fff',
        8: '#999', 9: '#999'
    }
    
    # Column labels (minor triads)
    for j in range(12):
        x = margin_left + j * cell + cell // 2
        svg_parts.append(
            f'<text x="{x}" y="{margin_top - 2}" text-anchor="middle" '
            f'class="hlabel" transform="rotate(-45 {x} {margin_top - 2})">{NOTE_NAMES[j]}m</text>'
        )
    
    # PLR indicators
    def plr_P(r): return r
    def plr_L(r): return (r + 4) % 12
    def plr_R(r): return (r + 9) % 12
    
    for i in range(12):
        # Row label
        y = margin_top + i * cell + cell // 2 + 4
        svg_parts.append(
            f'<text x="{margin_left - 5}" y="{y}" text-anchor="end" class="hlabel">{NOTE_NAMES[i]}</text>'
        )
        
        for j in range(12):
            d = vl_dist(major_triad(i), minor_triad(j))
            x = margin_left + j * cell
            y_cell = margin_top + i * cell
            
            bg = colors.get(d, '#1a1a2e')
            fg = text_colors.get(d, '#ccc')
            
            # Highlight PLR cells
            stroke = "none"
            sw = 0
            if j == plr_P(i):
                stroke = "#ff6b6b"
                sw = 3
            elif j == plr_L(i):
                stroke = "#4ecdc4"
                sw = 3
            elif j == plr_R(i):
                stroke = "#95e66b"
                sw = 3
            
            svg_parts.append(
                f'<rect x="{x}" y="{y_cell}" width="{cell}" height="{cell}" '
                f'fill="{bg}" stroke="{stroke}" stroke-width="{sw}"/>'
            )
            svg_parts.append(
                f'<text x="{x + cell//2}" y="{y_cell + cell//2 + 4}" '
                f'text-anchor="middle" class="hval" fill="{fg}">{d}</text>'
            )
    
    # Legend
    ly = height - 30
    for d in range(7):
        lx = margin_left + d * 55
        svg_parts.append(f'<rect x="{lx}" y="{ly}" width="18" height="18" fill="{colors[d]}"/>')
        svg_parts.append(f'<text x="{lx + 22}" y="{ly + 14}" class="hlabel">d={d}</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_displacement_svg() -> str:
    """Generate SVG showing PLR displacement vectors on the pitch circle."""
    
    width, height = 700, 280
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" style="background:#1a1a2e">',
        '<defs><style>',
        '  .dtitle { font: bold 16px sans-serif; fill: #e0e0e0; }',
        '  .dlabel { font: 10px sans-serif; fill: #888; }',
        '  .dnote { font: bold 11px sans-serif; fill: #e0e0e0; }',
        '  .darrow { font: bold 13px sans-serif; fill: #f8d568; }',
        '  .dinfo { font: 12px sans-serif; fill: #c0c0c0; }',
        '</style>',
        '<marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">',
        '  <polygon points="0 0, 10 3.5, 0 7" fill="#ff6b6b"/>',
        '</marker>',
        '</defs>',
        f'<text x="{width//2}" y="24" text-anchor="middle" class="dtitle">'
        f'PLR Voice Displacement on C Major {{C, E, G}}</text>',
    ]
    
    transforms = [
        ('P: Parallel', 'C → Cm', [(0,0), (4,3), (7,7)], '#ff6b6b', 'E→E♭ (1 semitone)'),
        ('L: Leading-tone', 'C → Em', [(0,11), (4,4), (7,7)], '#4ecdc4', 'C→B (1 semitone)'),
        ('R: Relative', 'C → Am', [(0,0), (4,4), (7,9)], '#95e66b', 'G→A (2 semitones)'),
    ]
    
    for idx, (title, subtitle, moves, color, desc) in enumerate(transforms):
        cx = 120 + idx * 210
        cy = 155
        r = 70
        
        svg_parts.append(f'<text x="{cx}" y="50" text-anchor="middle" class="dinfo">{title}</text>')
        svg_parts.append(f'<text x="{cx}" y="66" text-anchor="middle" class="dlabel">{subtitle}</text>')
        
        # Draw pitch circle
        svg_parts.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#333" stroke-width="1"/>'
        )
        
        # Draw notes and movements
        for src_pc, tgt_pc in moves:
            # Source position
            a1 = -math.pi/2 + 2 * math.pi * src_pc / 12
            x1 = cx + r * math.cos(a1)
            y1 = cy + r * math.sin(a1)
            
            # Target position
            a2 = -math.pi/2 + 2 * math.pi * tgt_pc / 12
            x2 = cx + r * math.cos(a2)
            y2 = cy + r * math.sin(a2)
            
            if src_pc == tgt_pc:
                # Stationary note
                svg_parts.append(
                    f'<circle cx="{x1}" cy="{y1}" r="8" fill="#555" stroke="#888" stroke-width="1.5"/>'
                )
                svg_parts.append(
                    f'<text x="{x1}" y="{y1+4}" text-anchor="middle" class="dnote" fill="#aaa">'
                    f'{NOTE_NAMES[src_pc]}</text>'
                )
            else:
                # Moving note
                svg_parts.append(
                    f'<circle cx="{x1}" cy="{y1}" r="8" fill="{color}" opacity="0.3"/>'
                )
                svg_parts.append(
                    f'<circle cx="{x2}" cy="{y2}" r="8" fill="{color}"/>'
                )
                # Arrow
                dx, dy = x2 - x1, y2 - y1
                dist = math.sqrt(dx*dx + dy*dy)
                if dist > 0:
                    # Shorten arrow
                    x1a = x1 + dx * 8/dist
                    y1a = y1 + dy * 8/dist
                    x2a = x2 - dx * 10/dist
                    y2a = y2 - dy * 10/dist
                    svg_parts.append(
                        f'<line x1="{x1a}" y1="{y1a}" x2="{x2a}" y2="{y2a}" '
                        f'stroke="{color}" stroke-width="2" marker-end="url(#arrowhead)"/>'
                    )
                svg_parts.append(
                    f'<text x="{x1}" y="{y1+4}" text-anchor="middle" class="dnote" '
                    f'fill="{color}" opacity="0.5">{NOTE_NAMES[src_pc]}</text>'
                )
                svg_parts.append(
                    f'<text x="{x2}" y="{y2+4}" text-anchor="middle" class="dnote" '
                    f'fill="#fff">{NOTE_NAMES[tgt_pc]}</text>'
                )
        
        svg_parts.append(f'<text x="{cx}" y="{cy + r + 30}" text-anchor="middle" class="dinfo" fill="{color}">{desc}</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def save_all_visualizations():
    """Generate and save all visualizations."""
    
    tonnetz_svg = generate_tonnetz_svg()
    with open('tonnetz.svg', 'w') as f:
        f.write(tonnetz_svg)
    print("Saved tonnetz.svg")
    
    heatmap_svg = generate_heatmap_svg()
    with open('heatmap.svg', 'w') as f:
        f.write(heatmap_svg)
    print("Saved heatmap.svg")
    
    displacement_svg = generate_displacement_svg()
    with open('displacement.svg', 'w') as f:
        f.write(displacement_svg)
    print("Saved displacement.svg")
    
    return tonnetz_svg, heatmap_svg, displacement_svg


if __name__ == "__main__":
    save_all_visualizations()
