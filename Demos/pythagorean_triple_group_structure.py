#!/usr/bin/env python3
"""
Applications of the Berggren Tree Structure

Real-world applications of the formally verified Berggren tree properties:
1. Certified generation of right triangles for exact geometry
2. Collision-free enumeration for computational benchmarks
3. Hypotenuse analysis for number-theoretic investigations
4. Symbolic dynamics and coding theory connections
"""

from math import gcd, sqrt, log2
from typing import List, Tuple, Dict, Set
from collections import defaultdict

Triple = Tuple[int, int, int]
ROOT = (3, 4, 5)

def berg_A(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berg_B(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berg_C(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
def inv_A(a, b, c): return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
def inv_B(a, b, c): return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
def inv_C(a, b, c): return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

GENS = [('A', berg_A), ('B', berg_B), ('C', berg_C)]
INVS = [('A', inv_A), ('B', inv_B), ('C', inv_C)]


# ─── Application 1: Exact Geometry Engine ────────────────────────────────────

def exact_right_triangles(max_c: int) -> List[Triple]:
    """
    Generate all primitive right triangles with integer sides and hypotenuse ≤ max_c.

    Application: CAD systems, CNC machining, and tiling where exact integer
    coordinates are needed (no floating-point error).

    The Berggren tree guarantees:
    - Completeness: every primitive triple is generated
    - No duplicates: each triple appears exactly once
    - Correctness: a² + b² = c² is formally verified

    Example: Generate tiles for a wall using only exact right-angle triangles.
    """
    import heapq
    result = []
    pq = [(5, ROOT)]

    while pq:
        c, t = heapq.heappop(pq)
        if c > max_c:
            break
        result.append(t)
        for _, gen in GENS:
            child = gen(*t)
            if child[2] <= max_c:
                heapq.heappush(pq, (child[2], child))
    return result


# ─── Application 2: Primitive Triple Counter ────────────────────────────────

def count_primitives_up_to(N: int) -> int:
    """
    Count primitive Pythagorean triples with hypotenuse ≤ N.

    Uses Berggren tree with early termination (guaranteed by monotonicity).
    The asymptotic count is N/(2π) + O(√N).

    Application: Validating number-theoretic density predictions.
    """
    import heapq
    count = 0
    pq = [(5, ROOT)]
    while pq:
        c, t = heapq.heappop(pq)
        if c > N:
            break
        count += 1
        for _, gen in GENS:
            child = gen(*t)
            if child[2] <= N:
                heapq.heappush(pq, (child[2], child))
    return count


# ─── Application 3: Address System for Triples ──────────────────────────────

def triple_address(a: int, b: int, c: int) -> str:
    """
    Compute the unique ternary address of a primitive Pythagorean triple.

    Each primitive triple has a unique path from root (3,4,5) in the
    Berggren tree. This gives a canonical naming/addressing scheme.

    Application: Database indexing, content addressing, compression.
    The address length is O(log c), giving logarithmic-size identifiers.
    """
    word = []
    current = (a, b, c)
    while current != ROOT:
        for name, inv in INVS:
            parent = inv(*current)
            if all(x > 0 for x in parent):
                word.append(name)
                current = parent
                break
        else:
            raise ValueError(f"Invalid triple: {(a, b, c)}")
    return ''.join(reversed(word))


def address_to_triple(address: str) -> Triple:
    """Recover a triple from its Berggren address."""
    gen_map = {'A': berg_A, 'B': berg_B, 'C': berg_C}
    t = ROOT
    for ch in address:
        t = gen_map[ch](*t)
    return t


# ─── Application 4: Congruence Class Analysis ───────────────────────────────

def congruence_distribution(max_depth: int, modulus: int) -> Dict[int, List[int]]:
    """
    Analyze the distribution of hypotenuse values modulo a given modulus
    at each depth of the Berggren tree.

    Application: Testing equidistribution conjectures for Berggren dynamics.
    Congruence patterns reveal deep connections to quadratic residues and
    the distribution of primes ≡ 1 (mod 4).
    """
    distribution: Dict[int, List[int]] = {}
    triples = [ROOT]

    for depth in range(max_depth + 1):
        residues = [t[2] % modulus for t in triples]
        counts = [0] * modulus
        for r in residues:
            counts[r] += 1
        distribution[depth] = counts
        next_triples = []
        for t in triples:
            for _, gen in GENS:
                next_triples.append(gen(*t))
        triples = next_triples

    return distribution


# ─── Application 5: Pythagorean Network ─────────────────────────────────────

def shared_hypotenuse_graph(max_c: int) -> Dict[int, List[Triple]]:
    """
    Build a graph where nodes are primitive triples and edges connect
    triples sharing the same hypotenuse.

    Application: Network analysis of Pythagorean structure.
    The multiplicity of shared hypotenuses is controlled by the number
    of prime factors ≡ 1 (mod 4).
    """
    triples = exact_right_triangles(max_c)
    by_hyp: Dict[int, List[Triple]] = defaultdict(list)
    for t in triples:
        a, b, c = t
        # Normalize so a < b
        if a > b:
            a, b = b, a
        by_hyp[c].append((a, b, c))
    return {c: ts for c, ts in by_hyp.items() if len(ts) > 1}


# ─── Application 6: Entropy of Berggren Paths ───────────────────────────────

def path_entropy_analysis(max_c: int) -> Dict[str, float]:
    """
    Analyze the frequency of generators A, B, C in Berggren word codes.

    If generators were equally likely, each would appear with probability 1/3,
    giving entropy H = log₂(3) ≈ 1.585 bits per step. Deviations indicate
    structure in the symbolic dynamics.

    Application: Data compression of Pythagorean triple databases.
    """
    triples = exact_right_triangles(max_c)
    gen_counts = {'A': 0, 'B': 0, 'C': 0}
    total_steps = 0

    for t in triples:
        if t == ROOT:
            continue
        code = triple_address(*t)
        for ch in code:
            gen_counts[ch] += 1
            total_steps += 1

    if total_steps == 0:
        return {'entropy': 0.0, 'A_freq': 0.0, 'B_freq': 0.0, 'C_freq': 0.0}

    freqs = {k: v / total_steps for k, v in gen_counts.items()}
    entropy = -sum(f * log2(f) for f in freqs.values() if f > 0)

    return {
        'entropy': round(entropy, 6),
        'max_entropy': round(log2(3), 6),
        'A_freq': round(freqs['A'], 6),
        'B_freq': round(freqs['B'], 6),
        'C_freq': round(freqs['C'], 6),
        'total_steps': total_steps,
        'num_triples': len(triples),
    }


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("  Applications of the Berggren Tree Structure")
    print("=" * 65)

    # App 1: Exact geometry
    print("\n--- Application 1: Exact Right Triangles (c ≤ 50) ---")
    triangles = exact_right_triangles(50)
    for t in triangles:
        addr = triple_address(*t)
        print(f"  {t[0]:>3}² + {t[1]:>3}² = {t[2]:>3}²  address={addr}")

    # App 2: Counting
    print("\n--- Application 2: Primitive Triple Counts ---")
    for N in [100, 1000, 10000, 100000]:
        count = count_primitives_up_to(N)
        density = count / N
        predicted = N / (2 * 3.14159265)
        print(f"  N={N:>7}: count={count:>5}, density={density:.4f}, "
              f"predicted≈{predicted:.1f}, ratio={count/predicted:.4f}")

    # App 3: Address round-trip
    print("\n--- Application 3: Address System (Round-Trip Test) ---")
    test_triples = [(3,4,5), (5,12,13), (15,8,17), (7,24,25), (119,120,169)]
    for t in test_triples:
        addr = triple_address(*t)
        recovered = address_to_triple(addr)
        ok = recovered == t
        print(f"  {t} → \"{addr}\" → {recovered}  {'✓' if ok else '✗'}")

    # App 4: Congruence analysis
    print("\n--- Application 4: Hypotenuse Distribution mod 12 ---")
    dist = congruence_distribution(6, 12)
    print(f"  {'Depth':>5} | " + " ".join(f"{r:>4}" for r in range(12)))
    print("  " + "-" * 60)
    for d in range(7):
        print(f"  {d:>5} | " + " ".join(f"{c:>4}" for c in dist[d]))

    # App 5: Shared hypotenuses
    print("\n--- Application 5: Shared Hypotenuse Network (c ≤ 500) ---")
    network = shared_hypotenuse_graph(500)
    for c in sorted(network.keys())[:10]:
        print(f"  c={c}: {network[c]}")

    # App 6: Entropy
    print("\n--- Application 6: Path Entropy Analysis ---")
    for max_c in [100, 500, 2000, 10000]:
        stats = path_entropy_analysis(max_c)
        print(f"  c≤{max_c:>5}: H={stats['entropy']:.4f} bits "
              f"(max={stats['max_entropy']:.4f}), "
              f"A={stats['A_freq']:.3f} B={stats['B_freq']:.3f} C={stats['C_freq']:.3f}")

    print("\n" + "=" * 65)
    print("  All applications completed.")
    print("=" * 65)


#!/usr/bin/env python3
"""
Berggren Tree: Demonstrating the Arithmetic Dynamical System on Pythagorean Triples

This script demonstrates the key theorems proved in our formal verification:
1. The three Berggren generators preserve Pythagorean triples
2. Primitivity is preserved under all generators
3. Hypotenuse strictly increases at each step
4. The Lorentz form Q(a,b,c) = a² + b² - c² is invariant
5. Generator matrices have determinant ±1
6. The tree enumerates triples without collision
"""

import numpy as np
from math import gcd
from typing import Tuple, List

Triple = Tuple[int, int, int]

# ─── Berggren Matrices ───────────────────────────────────────────────────────

MAT_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
MAT_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
MAT_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

LORENTZ_Q = np.array([[1, 0, 0], [0, 1, 0], [0, 0, -1]], dtype=int)

ROOT = (3, 4, 5)

# ─── Core Functions ──────────────────────────────────────────────────────────

def bergA(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def is_pythagorean(a: int, b: int, c: int) -> bool:
    return a**2 + b**2 == c**2

def is_primitive(a: int, b: int, c: int) -> bool:
    return gcd(gcd(a, b), c) == 1

def lorentz_form(a: int, b: int, c: int) -> int:
    return a**2 + b**2 - c**2

GENERATORS = {'A': bergA, 'B': bergB, 'C': bergC}

# ─── Demo 1: Pythagorean Preservation ────────────────────────────────────────

def demo_pythagorean_preservation():
    """Show that each generator maps Pythagorean triples to Pythagorean triples."""
    print("=" * 70)
    print("DEMO 1: Pythagorean Preservation")
    print("=" * 70)
    print(f"\nRoot triple: {ROOT}")
    print(f"  Is Pythagorean: {is_pythagorean(*ROOT)} (3² + 4² = {3**2 + 4**2} = 5² = {5**2})")
    print()

    for name, gen in GENERATORS.items():
        child = gen(*ROOT)
        a, b, c = child
        print(f"  Generator {name}: {ROOT} → {child}")
        print(f"    Check: {a}² + {b}² = {a**2 + b**2}, {c}² = {c**2}")
        print(f"    Is Pythagorean: {is_pythagorean(*child)}")
        print(f"    Is Primitive: {is_primitive(*child)}")
    print()

# ─── Demo 2: Tree Generation ────────────────────────────────────────────────

def demo_tree_generation():
    """Generate the first few levels of the Berggren tree."""
    print("=" * 70)
    print("DEMO 2: Berggren Tree (First 3 Levels)")
    print("=" * 70)

    levels = {0: [ROOT]}
    for depth in range(3):
        next_level = []
        for triple in levels[depth]:
            for name, gen in GENERATORS.items():
                child = gen(*triple)
                next_level.append(child)
        levels[depth + 1] = next_level

    for depth, triples in levels.items():
        print(f"\n  Depth {depth}: ({len(triples)} triple(s))")
        for t in sorted(triples, key=lambda x: x[2]):
            a, b, c = t
            print(f"    ({a:>4}, {b:>4}, {c:>4})  "
                  f"Pyth={is_pythagorean(*t)}  Prim={is_primitive(*t)}  Q={lorentz_form(*t)}")
    print()

# ─── Demo 3: Lorentz Form Invariance ────────────────────────────────────────

def demo_lorentz_invariance():
    """Show Q(a,b,c) = a² + b² - c² = 0 is preserved by all generators."""
    print("=" * 70)
    print("DEMO 3: Lorentz Form Invariance (Q = a² + b² - c²)")
    print("=" * 70)
    print(f"\n  Q(3, 4, 5) = {lorentz_form(*ROOT)}")

    # Check preservation through 3 levels
    triples = [ROOT]
    for depth in range(4):
        next_triples = []
        for t in triples:
            for name, gen in GENERATORS.items():
                child = gen(*t)
                q = lorentz_form(*child)
                if q != 0:
                    print(f"  ERROR: Q ≠ 0 for {child}!")
                next_triples.append(child)
        triples = next_triples

    total = 1 + 3 + 9 + 27 + 81  # levels 0-4
    print(f"  Verified Q = 0 for all {total} triples through depth 4 ✓")

    # Matrix verification
    print("\n  Matrix Lorentz verification (MᵀQM = Q):")
    for name, mat in [('A', MAT_A), ('B', MAT_B), ('C', MAT_C)]:
        check = mat.T @ LORENTZ_Q @ mat
        matches = np.array_equal(check, LORENTZ_Q)
        print(f"    {name}ᵀ · Q · {name} = Q: {matches}")
    print()

# ─── Demo 4: Determinant Structure ──────────────────────────────────────────

def demo_determinants():
    """Show generators have determinant ±1."""
    print("=" * 70)
    print("DEMO 4: Determinant Structure (Theorem D)")
    print("=" * 70)
    for name, mat in [('A', MAT_A), ('B', MAT_B), ('C', MAT_C)]:
        d = int(round(np.linalg.det(mat)))
        print(f"  det({name}) = {d:+d}")
    print(f"\n  Generators A, C ∈ SL(3,ℤ), Generator B ∈ GL(3,ℤ) \\ SL(3,ℤ)")

    # Word determinants
    print("\n  Determinants of sample word matrices:")
    words = [
        ("AB", MAT_A @ MAT_B),
        ("ABC", MAT_A @ MAT_B @ MAT_C),
        ("AAA", MAT_A @ MAT_A @ MAT_A),
        ("BBB", MAT_B @ MAT_B @ MAT_B),
        ("ABCABC", MAT_A @ MAT_B @ MAT_C @ MAT_A @ MAT_B @ MAT_C),
    ]
    for name, mat in words:
        d = int(round(np.linalg.det(mat)))
        print(f"    det({name}) = {d:+d}")
    print()

# ─── Demo 5: Hypotenuse Growth ──────────────────────────────────────────────

def demo_hypotenuse_growth():
    """Show hypotenuse strictly increases at each step."""
    print("=" * 70)
    print("DEMO 5: Hypotenuse Strict Growth (Theorem E)")
    print("=" * 70)

    # Track minimum hypotenuse at each depth
    min_hyp = {}
    max_hyp = {}
    triples = [ROOT]
    for depth in range(8):
        hyps = [t[2] for t in triples]
        min_hyp[depth] = min(hyps)
        max_hyp[depth] = max(hyps)
        next_triples = []
        for t in triples:
            for gen in GENERATORS.values():
                next_triples.append(gen(*t))
        triples = next_triples

    print(f"\n  {'Depth':>5}  {'Min hyp':>10}  {'Max hyp':>12}  {'# triples':>10}  {'depth+5 ≤ min':>14}")
    for depth in range(8):
        count = 3**depth
        bound_check = "✓" if depth + 5 <= min_hyp[depth] else "✗"
        print(f"  {depth:>5}  {min_hyp[depth]:>10}  {max_hyp[depth]:>12}  {count:>10}  {bound_check:>14}")

    # Growth ratios
    print(f"\n  Min hypotenuse growth ratios:")
    for depth in range(1, 8):
        ratio = min_hyp[depth] / min_hyp[depth - 1]
        print(f"    Depth {depth-1}→{depth}: {min_hyp[depth-1]:>8} → {min_hyp[depth]:>8} (×{ratio:.4f})")
    print()

# ─── Demo 6: No Collisions ──────────────────────────────────────────────────

def demo_no_collisions():
    """Verify that distinct words produce distinct triples through several levels."""
    print("=" * 70)
    print("DEMO 6: No Collisions (Injectivity of Word Coding)")
    print("=" * 70)

    seen = set()
    collisions = 0
    total = 0
    triples = [ROOT]
    seen.add(ROOT)
    total += 1

    for depth in range(7):
        next_triples = []
        for t in triples:
            for gen in GENERATORS.values():
                child = gen(*t)
                total += 1
                if child in seen:
                    collisions += 1
                    print(f"  COLLISION at depth {depth+1}: {child}")
                seen.add(child)
                next_triples.append(child)
        triples = next_triples

    print(f"\n  Checked {total} triples through depth 7")
    print(f"  Unique triples: {len(seen)}")
    print(f"  Collisions: {collisions}")
    print(f"  All distinct: {'✓' if collisions == 0 else '✗'}")
    print()

# ─── Demo 7: Inverse Maps ───────────────────────────────────────────────────

def demo_inverse_maps():
    """Demonstrate that each generator has an explicit inverse."""
    print("=" * 70)
    print("DEMO 7: Inverse Maps (Round-Trip Verification)")
    print("=" * 70)

    def invA(a, b, c): return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
    def invB(a, b, c): return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
    def invC(a, b, c): return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

    test_triples = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
        (20, 21, 29), (9, 40, 41), (28, 45, 53),
    ]
    inverses = {'A': (bergA, invA), 'B': (bergB, invB), 'C': (bergC, invC)}

    all_ok = True
    for name, (fwd, inv) in inverses.items():
        print(f"\n  Generator {name}:")
        for t in test_triples[:3]:
            child = fwd(*t)
            recovered = inv(*child)
            ok = recovered == t
            all_ok = all_ok and ok
            print(f"    {t} →{name}→ {child} →{name}⁻¹→ {recovered}  {'✓' if ok else '✗'}")

    print(f"\n  All round-trips successful: {'✓' if all_ok else '✗'}")
    print()

# ─── Demo 8: Hypotenuse Multiplicity ────────────────────────────────────────

def demo_hypotenuse_multiplicity():
    """Show that some hypotenuse values correspond to multiple primitive triples."""
    print("=" * 70)
    print("DEMO 8: Fixed-Hypotenuse Multiplicity")
    print("=" * 70)

    # Enumerate primitive triples up to hypotenuse N
    N = 1000
    triples_by_hyp = {}
    for m in range(2, int(N**0.5) + 2):
        for n in range(1, m):
            if gcd(m, n) != 1 or (m - n) % 2 == 0:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > N:
                break
            if a > b:
                a, b = b, a
            triples_by_hyp.setdefault(c, []).append((a, b, c))

    multi = {c: ts for c, ts in triples_by_hyp.items() if len(ts) > 1}
    print(f"\n  Primitive triples with c ≤ {N}: {sum(len(v) for v in triples_by_hyp.values())}")
    print(f"  Hypotenuse values with multiple triples: {len(multi)}")
    print(f"\n  First examples of shared hypotenuse:")
    for c in sorted(multi.keys())[:8]:
        print(f"    c = {c}: {multi[c]}")
    print()

# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "▶" * 70)
    print("  BERGGREN TREE: Arithmetic Dynamical System on Pythagorean Triples")
    print("▶" * 70 + "\n")

    demo_pythagorean_preservation()
    demo_tree_generation()
    demo_lorentz_invariance()
    demo_determinants()
    demo_hypotenuse_growth()
    demo_no_collisions()
    demo_inverse_maps()
    demo_hypotenuse_multiplicity()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
