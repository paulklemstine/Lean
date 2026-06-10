#!/usr/bin/env python3
"""
Applications of Berggren Tree Extremal Geodesic Theory

Demonstrates practical applications of the formally verified theorems:
1. Certified exhaustive enumeration of Pythagorean triples
2. Optimal search strategies for number-theoretic computations
3. Modular dynamics and residue patterns
4. Cryptographic and engineering applications
"""

import math
from typing import List, Tuple, Dict, Set
from collections import Counter, defaultdict

Triple = Tuple[int, int, int]
BASE = (3, 4, 5)


def child_a(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def child_b(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def child_c(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

CHILDREN = {'A': child_a, 'B': child_b, 'C': child_c}


def min_hyp(d: int) -> int:
    """Exact minimum hypotenuse at depth d: 2d² + 6d + 5."""
    return 2*d*d + 6*d + 5


def max_depth(N: int) -> int:
    """Exact maximum depth for hypotenuse ≤ N."""
    d = 0
    while min_hyp(d + 1) <= N:
        d += 1
    return d


# ============================================================
# Application 1: Certified Exhaustive Enumeration
# ============================================================

def certified_enumerate(N: int) -> List[Triple]:
    """
    Enumerate ALL primitive Pythagorean triples with hypotenuse ≤ N.

    Uses the formally verified depth cutoff theorem (C1) as a certified
    stopping rule: no triples are missed, and no unnecessary computation
    is performed beyond the proven depth bound.

    This replaces heuristic search depth estimates with a theorem.

    Args:
        N: Maximum hypotenuse.

    Returns:
        Complete list of primitive Pythagorean triples with c ≤ N.
    """
    D = max_depth(N)
    if D < 0:
        return []

    result = []
    stack = [(BASE, 0)]

    while stack:
        triple, depth = stack.pop()
        if triple[2] <= N:
            result.append(triple)
        if depth < D:
            for gen_fn in [child_a, child_b, child_c]:
                child = gen_fn(triple)
                if child[2] <= N:
                    stack.append((child, depth + 1))

    return sorted(result, key=lambda t: (t[2], t[0]))


def verify_enumeration(N: int) -> bool:
    """
    Verify that certified enumeration finds all primitive Pythagorean triples.

    Cross-checks against brute-force generation using Euclid's parametrization.
    """
    # Euclid parametrization: a = m²-n², b = 2mn, c = m²+n² for m > n > 0, gcd(m,n)=1, m-n odd
    brute_force = set()
    for m in range(2, int(math.sqrt(N)) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if math.gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c <= N:
                brute_force.add((min(a,b), max(a,b), c))

    berggren = set()
    for t in certified_enumerate(N):
        a, b, c = t
        berggren.add((min(a,b), max(a,b), c))

    return brute_force == berggren


# ============================================================
# Application 2: Optimal Rectangle Search
# ============================================================

def find_pythagorean_rectangles(max_hyp: int) -> List[dict]:
    """
    Find right triangles suitable for engineering applications.

    In construction, manufacturing, and surveying, right triangles with
    integer side lengths are used to create precise right angles. This
    function finds all such triangles up to a given hypotenuse limit,
    using the certified Berggren enumeration.

    Returns triangles sorted by hypotenuse, with additional metadata
    about aspect ratio and area.
    """
    triples = certified_enumerate(max_hyp)
    results = []
    for a, b, c in triples:
        short, long = min(a, b), max(a, b)
        results.append({
            'sides': (short, long, c),
            'area': short * long / 2,
            'aspect_ratio': long / short,
            'perimeter': short + long + c,
        })
    return sorted(results, key=lambda r: r['sides'][2])


# ============================================================
# Application 3: Modular Residue Analysis
# ============================================================

def analyze_residues(N: int, modulus: int) -> Dict:
    """
    Analyze the distribution of hypotenuse residues modulo m.

    This connects to the congruence dynamics of the Berggren tree
    and the question of equidistribution of primitive triples in
    arithmetic progressions.

    Args:
        N: Maximum hypotenuse for enumeration.
        modulus: Modulus for residue analysis.

    Returns:
        Dictionary with residue distribution and uniformity metrics.
    """
    triples = certified_enumerate(N)
    residue_counts = Counter()
    for _, _, c in triples:
        residue_counts[c % modulus] += 1

    total = len(triples)
    expected = total / modulus if modulus > 0 else 0

    # Chi-squared statistic for uniformity
    chi_sq = sum((count - expected)**2 / expected
                 for count in residue_counts.values()) if expected > 0 else float('inf')

    return {
        'modulus': modulus,
        'total_triples': total,
        'residue_counts': dict(sorted(residue_counts.items())),
        'expected_uniform': expected,
        'chi_squared': chi_sq,
        'num_occupied_residues': len(residue_counts),
    }


# ============================================================
# Application 4: Berggren Tree Modular Graph
# ============================================================

def berggren_residue_graph(m: int) -> Dict:
    """
    Construct the Berggren residue graph modulo m.

    Vertices are residue classes of triples (a mod m, b mod m, c mod m).
    Edges are given by the three Berggren generators.

    Analyzes strong connectivity and component structure.
    """
    # Start from base triple modulo m
    start = (3 % m, 4 % m, 5 % m)
    visited = set()
    queue = [start]
    edges = defaultdict(set)

    while queue:
        state = queue.pop(0)
        if state in visited:
            continue
        visited.add(state)

        a, b, c = state
        children = [
            ((a - 2*b + 2*c) % m, (2*a - b + 2*c) % m, (2*a - 2*b + 3*c) % m),
            ((a + 2*b + 2*c) % m, (2*a + b + 2*c) % m, (2*a + 2*b + 3*c) % m),
            ((-a + 2*b + 2*c) % m, (-2*a + b + 2*c) % m, (-2*a + 2*b + 3*c) % m),
        ]

        for child in children:
            edges[state].add(child)
            if child not in visited:
                queue.append(child)

    # Check strong connectivity via BFS from each vertex
    def can_reach_all(source, graph, vertices):
        reached = set()
        q = [source]
        while q:
            v = q.pop(0)
            if v in reached:
                continue
            reached.add(v)
            for neighbor in graph.get(v, set()):
                if neighbor not in reached:
                    q.append(neighbor)
        return reached == vertices

    is_strongly_connected = all(
        can_reach_all(v, edges, visited) for v in visited
    )

    return {
        'modulus': m,
        'num_states': len(visited),
        'num_edges': sum(len(e) for e in edges.values()),
        'strongly_connected': is_strongly_connected,
        'states': visited,
    }


# ============================================================
# Application 5: Complexity Certification
# ============================================================

def enumeration_complexity_table(max_N: int) -> List[dict]:
    """
    Generate a table of certified enumeration complexities.

    For each power of 10 up to max_N, shows:
    - The exact search depth D(N) from Theorem C1
    - The number of tree nodes explored (3^D)
    - The actual number of triples found
    - The ratio (efficiency measure)
    """
    results = []
    N = 10
    while N <= max_N:
        D = max_depth(N)
        tree_size = sum(3**d for d in range(D + 1))  # Total nodes up to depth D
        count = count_triples(N)
        results.append({
            'N': N,
            'depth': D,
            'tree_nodes': tree_size,
            'triples_found': count,
            'efficiency': count / tree_size if tree_size > 0 else 0,
        })
        N *= 10
    return results


def count_triples(N: int) -> int:
    """Count primitive triples with hypotenuse ≤ N."""
    return len(certified_enumerate(N))


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATION 1: Certified Exhaustive Enumeration")
    print("=" * 70)
    for N in [50, 100]:
        triples = certified_enumerate(N)
        print(f"\n  All primitive Pythagorean triples with c ≤ {N}:")
        for t in triples:
            a, b, c = t
            print(f"    ({a:>3}, {b:>3}, {c:>3})  "
                  f"check: {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2}")
    print(f"\n  Verification against Euclid's parametrization:")
    for N in [50, 100, 500]:
        ok = verify_enumeration(N)
        count = count_triples(N)
        print(f"    N={N}: {count} triples, verified = {ok}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Engineering Right Triangles")
    print("=" * 70)
    rects = find_pythagorean_rectangles(100)
    print(f"\n  Right triangles with c ≤ 100 (sorted by hypotenuse):")
    for r in rects[:10]:
        s = r['sides']
        print(f"    ({s[0]:>3}, {s[1]:>3}, {s[2]:>3})  "
              f"area={r['area']:>8.0f}  aspect={r['aspect_ratio']:.2f}  "
              f"perimeter={r['perimeter']}")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Modular Residue Analysis")
    print("=" * 70)
    for m in [3, 5, 7, 12]:
        res = analyze_residues(1000, m)
        print(f"\n  Mod {m}: {res['num_occupied_residues']}/{m} residues occupied, "
              f"χ² = {res['chi_squared']:.2f}")
        print(f"    Distribution: {res['residue_counts']}")

    print("\n" + "=" * 70)
    print("APPLICATION 4: Berggren Residue Graph")
    print("=" * 70)
    for m in [3, 5, 7, 11, 13]:
        graph = berggren_residue_graph(m)
        print(f"  Mod {m}: {graph['num_states']} states, "
              f"{graph['num_edges']} edges, "
              f"strongly connected = {graph['strongly_connected']}")

    print("\n" + "=" * 70)
    print("APPLICATION 5: Enumeration Complexity")
    print("=" * 70)
    table = enumeration_complexity_table(10000)
    print(f"\n  {'N':>10} {'Depth':>8} {'Tree nodes':>12} {'Triples':>10} {'Efficiency':>12}")
    print("  " + "-" * 54)
    for row in table:
        print(f"  {row['N']:>10} {row['depth']:>8} {row['tree_nodes']:>12} "
              f"{row['triples_found']:>10} {row['efficiency']:>12.4f}")


#!/usr/bin/env python3
"""
Demo: Berggren Tree Extremal Geodesic Theory

Demonstrates the formally verified theorems about the Berggren tree:
1. The all-A branch produces triples with hypotenuse 2d² + 6d + 5
2. This is the unique minimum hypotenuse at each depth
3. The exact enumeration depth law for hypotenuse cutoffs
"""

import numpy as np
from typing import Tuple, List

Triple = Tuple[int, int, int]

# Berggren generators as matrices
MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
MAT_B = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
GENERATORS = {'A': MAT_A, 'B': MAT_B, 'C': MAT_C}
BASE = np.array([3, 4, 5])


def apply_word(word: str, triple: np.ndarray = BASE) -> np.ndarray:
    """Apply a Berggren word (e.g., 'AABCA') to a triple."""
    result = triple.copy()
    for letter in word:
        result = GENERATORS[letter] @ result
    return result


def all_words(d: int) -> List[str]:
    """Generate all Berggren words of length d."""
    if d == 0:
        return ['']
    shorter = all_words(d - 1)
    return [w + g for w in shorter for g in 'ABC']


def min_hyp_formula(d: int) -> int:
    """The exact minimum hypotenuse at depth d: 2d² + 6d + 5."""
    return 2 * d**2 + 6 * d + 5


def demo_closed_form():
    """Demonstrate Theorem A2: closed form for the all-A branch."""
    print("=" * 70)
    print("THEOREM A2: Closed Form for the All-A Branch")
    print("=" * 70)
    print(f"{'Depth d':<10} {'A^d triple':<30} {'Formula (2d+3, 2d²+6d+4, 2d²+6d+5)':<40}")
    print("-" * 70)
    for d in range(8):
        word = 'A' * d
        triple = apply_word(word)
        formula_a = 2*d + 3
        formula_b = 2*d**2 + 6*d + 4
        formula_c = 2*d**2 + 6*d + 5
        match = "✓" if (triple == [formula_a, formula_b, formula_c]).all() else "✗"
        print(f"  d={d:<5} ({triple[0]}, {triple[1]}, {triple[2]})  "
              f"= ({formula_a}, {formula_b}, {formula_c})  {match}")
    print()


def demo_minimum_hypotenuse():
    """Demonstrate Theorem A1: minimum hypotenuse = 2d² + 6d + 5."""
    print("=" * 70)
    print("THEOREM A1: Minimum Hypotenuse at Each Depth")
    print("=" * 70)
    print(f"{'Depth':<8} {'# Words':<10} {'Min hyp':<10} {'Formula':<10} {'Match':<8} {'Min word'}")
    print("-" * 70)
    for d in range(7):
        words = all_words(d)
        hyps = [(w, apply_word(w)[2]) for w in words]
        min_hyp = min(h for _, h in hyps)
        min_word = [w for w, h in hyps if h == min_hyp][0]
        formula = min_hyp_formula(d)
        match = "✓" if min_hyp == formula else "✗"
        print(f"  d={d:<4} {len(words):<10} {min_hyp:<10} {formula:<10} {match:<8} "
              f"{'(root)' if d == 0 else min_word}")
    print()


def demo_uniqueness():
    """Demonstrate Theorem B1: A^d is the unique minimizer."""
    print("=" * 70)
    print("THEOREM B1: Uniqueness of the All-A Minimizer")
    print("=" * 70)
    for d in range(1, 7):
        words = all_words(d)
        min_hyp = min_hyp_formula(d)
        minimizers = [w for w in words if apply_word(w)[2] == min_hyp]
        is_unique = len(minimizers) == 1 and minimizers[0] == 'A' * d
        print(f"  Depth {d}: minimizers = {minimizers}  "
              f"unique = {is_unique}  ✓" if is_unique else f"  ✗ FAILED at depth {d}")
    print()


def demo_child_comparison():
    """Demonstrate Theorem B2: A-child strictly best on A-branch."""
    print("=" * 70)
    print("THEOREM B2: A-child Strictly Optimal on the A-Branch")
    print("=" * 70)
    print(f"{'Depth':<8} {'A-child hyp':<15} {'B-child hyp':<15} {'C-child hyp':<15} {'A < B,C'}")
    print("-" * 70)
    for d in range(8):
        t = apply_word('A' * d)
        hyp_a = (MAT_A @ t)[2]
        hyp_b = (MAT_B @ t)[2]
        hyp_c = (MAT_C @ t)[2]
        check = "✓" if hyp_a < hyp_b and hyp_a < hyp_c else "✗"
        print(f"  d={d:<4} {hyp_a:<15} {hyp_b:<15} {hyp_c:<15} {check}")
    print()


def demo_depth_cutoff():
    """Demonstrate Theorem C1: exact enumeration depth law."""
    print("=" * 70)
    print("THEOREM C1: Exact Enumeration Depth Law")
    print("=" * 70)
    print("  For hypotenuse bound N, max search depth D(N) satisfies:")
    print("  2D²+6D+5 ≤ N < 2(D+1)²+6(D+1)+5")
    print()
    print(f"{'N':<10} {'D(N)':<8} {'2D²+6D+5':<12} {'2(D+1)²+6(D+1)+5':<20} {'Valid'}")
    print("-" * 60)
    for N in [5, 13, 25, 50, 100, 500, 1000, 10000]:
        # Find D(N) by formula
        D = 0
        while min_hyp_formula(D + 1) <= N:
            D += 1
        lower = min_hyp_formula(D)
        upper = min_hyp_formula(D + 1)
        valid = lower <= N < upper
        print(f"  {N:<10} {D:<8} {lower:<12} {upper:<20} {'✓' if valid else '✗'}")
    print()


def demo_hypotenuse_distribution():
    """Show the distribution of hypotenuses at each depth."""
    print("=" * 70)
    print("HYPOTENUSE DISTRIBUTION BY DEPTH")
    print("=" * 70)
    for d in range(1, 6):
        words = all_words(d)
        hyps = sorted(set(apply_word(w)[2] for w in words))
        min_h = hyps[0]
        max_h = hyps[-1]
        print(f"  Depth {d} ({3**d} words): hyp range [{min_h}, {max_h}], "
              f"min = 2·{d}²+6·{d}+5 = {min_hyp_formula(d)}")
        if d <= 3:
            print(f"    All hypotenuses: {hyps}")
    print()


def demo_growth_analysis():
    """Analyze the growth rate along different paths."""
    print("=" * 70)
    print("GROWTH ANALYSIS: Hypotenuse Growth Along Different Paths")
    print("=" * 70)
    paths = {
        'All-A (extremal geodesic)': 'A' * 8,
        'All-B (maximum growth)': 'B' * 8,
        'All-C': 'C' * 8,
        'Alternating AB': 'AB' * 4,
        'Alternating AC': 'AC' * 4,
    }
    for name, word in paths.items():
        hyps = []
        t = BASE.copy()
        hyps.append(t[2])
        for letter in word:
            t = GENERATORS[letter] @ t
            hyps.append(t[2])
        print(f"\n  {name}: {word}")
        print(f"    Hypotenuses: {hyps}")
        print(f"    Growth rates: {[hyps[i+1] - hyps[i] for i in range(len(hyps)-1)]}")
    print()


if __name__ == '__main__':
    print("\n" + "=" * 70)
    print("  BERGGREN TREE EXTREMAL GEODESIC: Formal Verification Demos")
    print("=" * 70 + "\n")

    demo_closed_form()
    demo_minimum_hypotenuse()
    demo_uniqueness()
    demo_child_comparison()
    demo_depth_cutoff()
    demo_hypotenuse_distribution()
    demo_growth_analysis()

    print("All demonstrations complete. Every result above has been")
    print("formally verified in the accompanying proof files.")
