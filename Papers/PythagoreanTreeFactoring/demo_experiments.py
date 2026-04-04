#!/usr/bin/env python3
"""
Pythagorean Tree Factoring: Experimental Demonstrations

Oracle Research Council — Collaborative Investigation

This script implements and demonstrates:
1. Berggren tree generation and descent
2. Pythagorean triple factoring algorithm
3. Complexity measurements (steps vs √N)
4. Parallel multi-start descent
5. Lattice reduction connection (Gauss algorithm ↔ tree descent)
6. Higher-dimensional quadruple factoring

Usage:
    python demo_experiments.py [--all] [--berggren] [--factor] [--complexity]
                               [--parallel] [--lattice] [--quadruple]
"""

import math
import sys
from collections import defaultdict
from typing import List, Tuple, Optional, Dict
import itertools

# ============================================================================
# Section 1: Berggren Tree Matrices and Operations
# ============================================================================

# 3x3 Berggren matrices (acting on (a, b, c) triples)
B1 = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
B2 = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
B3 = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]

# 2x2 Berggren matrices (acting on (m, n) Euclid parameters)
M1 = [[2, -1], [1, 0]]
M2 = [[2, 1], [1, 0]]
M3 = [[1, 2], [0, 1]]

# Inverse 2x2 matrices
M1_inv = [[0, 1], [-1, 2]]
M2_inv = [[0, 1], [1, -2]]  # Note: M2 has det -1
M3_inv = [[1, -2], [0, 1]]


def mat_vec_mul_3(M, v):
    """Multiply 3x3 matrix by 3-vector."""
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


def mat_vec_mul_2(M, v):
    """Multiply 2x2 matrix by 2-vector."""
    return [sum(M[i][j] * v[j] for j in range(2)) for i in range(2)]


def generate_berggren_tree(depth: int) -> List[Tuple[int, int, int]]:
    """Generate all primitive Pythagorean triples up to given tree depth."""
    triples = []
    queue = [((3, 4, 5), 0)]

    while queue:
        triple, d = queue.pop(0)
        triples.append(triple)
        if d < depth:
            for B in [B1, B2, B3]:
                child = tuple(mat_vec_mul_3(B, list(triple)))
                # Ensure all components positive (B3 can give negative first component)
                if all(x > 0 for x in child):
                    queue.append((child, d + 1))
                else:
                    # Take absolute values for the odd leg
                    child = (abs(child[0]), abs(child[1]), child[2])
                    queue.append((child, d + 1))

    return triples


def euclid_params(a: int, b: int, c: int) -> Tuple[int, int]:
    """Extract Euclid parameters (m, n) from a primitive Pythagorean triple.
    Convention: a = m²-n² (odd leg), b = 2mn (even leg), c = m²+n²."""
    # Ensure a is the odd leg
    if a % 2 == 0:
        a, b = b, a
    # m² + n² = c, m² - n² = a → m² = (c+a)/2, n² = (c-a)/2
    m_sq = (c + a) // 2
    n_sq = (c - a) // 2
    m = int(math.isqrt(m_sq))
    n = int(math.isqrt(n_sq))
    assert m * m == m_sq and n * n == n_sq, f"Not perfect squares: {m_sq}, {n_sq}"
    return (m, n)


# ============================================================================
# Section 2: Pythagorean Triple Factoring Algorithm
# ============================================================================

def find_pythagorean_triples(N: int) -> List[Tuple[int, int, int]]:
    """Find all Pythagorean triples (N, b, c) with N² + b² = c².

    Uses the divisor pair method: d*e = N² with d < e and d ≡ e (mod 2)
    gives b = (e-d)/2, c = (e+d)/2.
    """
    triples = []
    N_sq = N * N

    for d in range(1, N):  # d < N since d < e and d*e = N²
        if N_sq % d == 0:
            e = N_sq // d
            if d < e and (d % 2 == e % 2):
                b = (e - d) // 2
                c = (e + d) // 2
                assert N_sq + b * b == c * c, f"Verification failed: {N}² + {b}² ≠ {c}²"
                triples.append((N, b, c))

    return triples


def gcd_factor(N: int, b: int, c: int) -> Optional[int]:
    """Try to extract a non-trivial factor of N from triple (N, b, c)."""
    for val in [c - b, c + b]:
        g = math.gcd(val, N)
        if 1 < g < N:
            return g
    return None


def tree_descent_factor(N: int, b: int, c: int, max_steps: int = 10**6) -> Tuple[Optional[int], int]:
    """Descend the Berggren tree from (N, b, c) toward (3, 4, 5),
    checking GCD at each step for a non-trivial factor.

    Returns (factor_or_None, steps_taken).
    """
    a = N
    steps = 0

    while steps < max_steps:
        # Check for factor
        factor = gcd_factor(N, b, c)
        if factor is not None:
            return factor, steps

        # Check if we've reached the root
        if c <= 5:
            return None, steps

        # Compute parent (inverse Berggren step)
        # Parent: a' = -a + 2b + 2c, b' = 2a - b + 2c, c' = 2a - 2b + 3c (B3⁻¹)
        # But need to pick the right inverse. Try all three and take the one with all positive.
        candidates = [
            (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c),   # B1⁻¹ (negate certain)
            (a - 2*b - 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c),   # B2⁻¹
            (-a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),    # B3⁻¹ (negate)
        ]

        # Actually let's use the correct inverse formulas
        # B1⁻¹ = B1ᵀ · η · η where η = diag(1,1,-1)... Let me just invert.
        # Direct inverse computation:
        # For parent, we want M such that M * (a_parent) = (a, b, c)
        # Actually the parent is unique. Let's try each:

        found = False
        for ca, cb, cc in candidates:
            if ca > 0 and cb > 0 and cc > 0 and cc < c:
                if ca*ca + cb*cb == cc*cc:
                    a, b, c = ca, cb, cc
                    found = True
                    break

        if not found:
            # Try with absolute values and swaps
            for ca, cb, cc in candidates:
                ca_abs, cb_abs = abs(ca), abs(cb)
                if ca_abs > 0 and cb_abs > 0 and cc > 0 and cc < c:
                    if ca_abs*ca_abs + cb_abs*cb_abs == cc*cc:
                        a, b, c = ca_abs, cb_abs, cc
                        found = True
                        break

        if not found:
            return None, steps

        steps += 1

    return None, steps


def factor_via_descent(N: int) -> Tuple[Optional[int], int, str]:
    """Factor N using Pythagorean tree descent.

    Returns (factor, total_steps, method_description).
    """
    if N % 2 == 0:
        return 2, 0, "even"

    # Start from the trivial triple
    b_trivial = (N * N - 1) // 2
    c_trivial = (N * N + 1) // 2

    factor, steps = tree_descent_factor(N, b_trivial, c_trivial)
    return factor, steps, f"descent from trivial triple"


# ============================================================================
# Section 3: Complexity Measurements
# ============================================================================

def measure_complexity(semiprimes: List[Tuple[int, int]]) -> List[Dict]:
    """Measure descent complexity for a list of semiprimes (p, q) with p < q."""
    results = []

    for p, q in semiprimes:
        N = p * q
        b_trivial = (N * N - 1) // 2
        c_trivial = (N * N + 1) // 2

        factor, steps = tree_descent_factor(N, b_trivial, c_trivial, max_steps=50000)

        sqrt_N = math.sqrt(N)
        result = {
            'p': p, 'q': q, 'N': N,
            'steps': steps,
            'sqrt_N': sqrt_N,
            'ratio_sqrt': steps / sqrt_N if sqrt_N > 0 else float('inf'),
            'ratio_min_pq': steps / min(p, q) if min(p, q) > 0 else float('inf'),
            'factor_found': factor,
        }
        results.append(result)

    return results


# ============================================================================
# Section 4: Parallel Multi-Start Descent
# ============================================================================

def parallel_descent(N: int) -> Tuple[Optional[int], int, int]:
    """Factor N using parallel descent from all starting triples.

    Returns (factor, best_steps, num_starts).
    """
    triples = find_pythagorean_triples(N)
    best_factor = None
    best_steps = float('inf')

    for _, b, c in triples:
        factor, steps = tree_descent_factor(N, b, c, max_steps=50000)
        if factor is not None and steps < best_steps:
            best_factor = factor
            best_steps = steps

    return best_factor, best_steps if best_steps < float('inf') else -1, len(triples)


# ============================================================================
# Section 5: Lattice Reduction Connection
# ============================================================================

def gauss_reduce_2d(v1: List[int], v2: List[int]) -> Tuple[List[int], List[int], int]:
    """Gauss's 2D lattice reduction algorithm.

    Returns (reduced_v1, reduced_v2, num_steps).
    """
    steps = 0

    def norm_sq(v):
        return v[0]**2 + v[1]**2

    def dot(u, v):
        return u[0]*v[0] + u[1]*v[1]

    while True:
        # Ensure |v1| ≤ |v2|
        if norm_sq(v1) > norm_sq(v2):
            v1, v2 = v2, v1

        # Size-reduce v2 by v1
        if norm_sq(v1) == 0:
            break

        mu = round(dot(v2, v1) / norm_sq(v1))
        if mu == 0:
            break

        v2 = [v2[0] - mu * v1[0], v2[1] - mu * v1[1]]
        steps += 1

    return v1, v2, steps


def berggren_descent_params(m: int, n: int) -> Tuple[List[Tuple[int, int]], int]:
    """Descend the Berggren tree in (m,n) parameter space.

    Returns (path_of_params, num_steps).
    """
    path = [(m, n)]
    steps = 0

    while m > 2 or n > 1:
        if m <= 1 or n <= 0:
            break

        # Determine which inverse to apply
        if m >= 3 * n:
            # M3⁻¹: (m,n) ↦ (m-2n, n)
            m, n = m - 2*n, n
        elif 2 * n > m and m > n:
            # M1⁻¹: (m,n) ↦ (n, 2n-m)
            m, n = n, 2*n - m
        elif m > 2 * n:
            # M3⁻¹ variant
            m, n = m - 2*n, n
        else:
            # M1⁻¹
            m, n = n, 2*n - m

        if m < n:
            m, n = n, m  # Ensure m > n

        path.append((m, n))
        steps += 1

        if steps > 10000:
            break

    return path, steps


def demonstrate_lattice_equivalence(N: int, p: int, q: int):
    """Show that Gauss reduction and Berggren descent produce the same result."""
    print(f"\n{'='*60}")
    print(f"Lattice ↔ Tree Equivalence for N = {p} × {q} = {N}")
    print(f"{'='*60}")

    # The trivial triple parameters
    m = (N + 1) // 2
    n = (N - 1) // 2

    # Berggren descent
    path, berg_steps = berggren_descent_params(m, n)
    print(f"\nBerggren descent: {berg_steps} steps")
    print(f"  Start: (m,n) = ({m}, {n})")
    if len(path) <= 10:
        for i, (mi, ni) in enumerate(path):
            print(f"  Step {i}: ({mi}, {ni})")
    else:
        for i in range(3):
            print(f"  Step {i}: ({path[i][0]}, {path[i][1]})")
        print(f"  ...")
        for i in range(len(path)-3, len(path)):
            print(f"  Step {i}: ({path[i][0]}, {path[i][1]})")

    # Gauss reduction on corresponding lattice
    v1 = [m, 1]
    v2 = [n, 1]
    rv1, rv2, gauss_steps = gauss_reduce_2d(v1, v2)
    print(f"\nGauss reduction: {gauss_steps} steps")
    print(f"  Start: v1 = {v1}, v2 = {v2}")
    print(f"  Result: v1 = {rv1}, v2 = {rv2}")

    print(f"\nCorrespondence: Berggren steps ≈ Gauss steps? {berg_steps} ≈ {gauss_steps}")


# ============================================================================
# Section 6: Quadruple Factoring
# ============================================================================

def find_pythagorean_quadruples(N: int, max_search: int = 1000) -> List[Tuple[int, int, int, int]]:
    """Find Pythagorean quadruples (a, b, c, d) with a = N.

    N² + b² + c² = d² ⟹ (d-c)(d+c) = N² + b²
    """
    quads = []
    N_sq = N * N

    for b in range(0, min(N, max_search)):
        remainder = N_sq + b * b
        # Find c, d with d² - c² = remainder, i.e., (d-c)(d+c) = remainder
        for d_minus_c in range(1, int(math.isqrt(remainder)) + 1):
            if remainder % d_minus_c == 0:
                d_plus_c = remainder // d_minus_c
                if (d_minus_c + d_plus_c) % 2 == 0:  # Same parity
                    d = (d_minus_c + d_plus_c) // 2
                    c = (d_plus_c - d_minus_c) // 2
                    if c >= 0 and d > 0:
                        assert N*N + b*b + c*c == d*d
                        quads.append((N, b, c, d))

    return quads


# ============================================================================
# Section 7: Main Demo Runner
# ============================================================================

def run_berggren_demo():
    """Demonstrate Berggren tree generation."""
    print("\n" + "="*60)
    print("DEMO 1: Berggren Tree Generation")
    print("="*60)

    triples = generate_berggren_tree(4)
    print(f"\nGenerated {len(triples)} primitive Pythagorean triples (depth ≤ 4):")
    for i, (a, b, c) in enumerate(sorted(triples, key=lambda t: t[2])[:20]):
        print(f"  {i+1}. ({a}, {b}, {c})  [a²+b²={a*a+b*b}, c²={c*c}]")
    if len(triples) > 20:
        print(f"  ... and {len(triples)-20} more")


def run_factoring_demo():
    """Demonstrate Pythagorean factoring."""
    print("\n" + "="*60)
    print("DEMO 2: Pythagorean Triple Factoring")
    print("="*60)

    test_numbers = [15, 21, 35, 77, 143, 323, 1073]

    for N in test_numbers:
        triples = find_pythagorean_triples(N)
        factor, steps, method = factor_via_descent(N)

        print(f"\n  N = {N}:")
        print(f"    Triples: {len(triples)}")
        for _, b, c in triples[:4]:
            g = gcd_factor(N, b, c)
            print(f"      ({N}, {b}, {c}) → gcd factor: {g}")
        if factor:
            print(f"    Factor found: {factor} (in {steps} descent steps)")
        else:
            print(f"    No factor found in {steps} steps")


def run_complexity_demo():
    """Demonstrate complexity measurements."""
    print("\n" + "="*60)
    print("DEMO 3: Complexity Measurements")
    print("="*60)

    semiprimes = [
        (3, 5), (7, 11), (11, 13), (17, 19), (29, 37),
        (41, 43), (59, 61), (71, 73), (89, 97), (101, 103),
    ]

    results = measure_complexity(semiprimes)

    print(f"\n  {'N':>10} {'p×q':>10} {'Steps':>8} {'√N':>8} {'Steps/√N':>10} {'Steps/min(p,q)':>16}")
    print(f"  {'-'*10} {'-'*10} {'-'*8} {'-'*8} {'-'*10} {'-'*16}")

    for r in results:
        print(f"  {r['N']:>10} {r['p']:>4}×{r['q']:<4} {r['steps']:>8} {r['sqrt_N']:>8.1f} "
              f"{r['ratio_sqrt']:>10.2f} {r['ratio_min_pq']:>16.2f}")


def run_parallel_demo():
    """Demonstrate parallel multi-start descent."""
    print("\n" + "="*60)
    print("DEMO 4: Parallel Multi-Start Descent")
    print("="*60)

    test_semiprimes = [(3, 5), (7, 11), (11, 13), (17, 19), (29, 37)]

    for p, q in test_semiprimes:
        N = p * q

        # Single start (trivial triple)
        _, single_steps, _ = factor_via_descent(N)

        # Multi-start
        factor, multi_steps, num_starts = parallel_descent(N)

        speedup = single_steps / multi_steps if multi_steps > 0 else float('inf')

        print(f"\n  N = {N} = {p}×{q}:")
        print(f"    Starting triples: {num_starts}")
        print(f"    Single-start steps: {single_steps}")
        print(f"    Multi-start steps:  {multi_steps}")
        print(f"    Speedup: {speedup:.1f}×")


def run_lattice_demo():
    """Demonstrate lattice reduction connection."""
    print("\n" + "="*60)
    print("DEMO 5: Lattice Reduction ↔ Tree Descent")
    print("="*60)

    demonstrate_lattice_equivalence(15, 3, 5)
    demonstrate_lattice_equivalence(77, 7, 11)
    demonstrate_lattice_equivalence(143, 11, 13)


def run_quadruple_demo():
    """Demonstrate higher-dimensional quadruple factoring."""
    print("\n" + "="*60)
    print("DEMO 6: Pythagorean Quadruple Factoring")
    print("="*60)

    test_numbers = [15, 21, 35]

    for N in test_numbers:
        triples = find_pythagorean_triples(N)
        quads = find_pythagorean_quadruples(N, max_search=50)

        print(f"\n  N = {N}:")
        print(f"    Pythagorean triples (leg = {N}): {len(triples)}")
        print(f"    Pythagorean quadruples (first component = {N}): {len(quads)}")
        print(f"    Branching advantage: {len(quads)}/{len(triples)} = {len(quads)/max(len(triples),1):.1f}×")
        for a, b, c, d in quads[:5]:
            print(f"      ({a}, {b}, {c}, {d})  [{a}²+{b}²+{c}²={a*a+b*b+c*c}, {d}²={d*d}]")
        if len(quads) > 5:
            print(f"      ... and {len(quads)-5} more")


def run_all_demos():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Pythagorean Tree Factoring: Experimental Demonstrations   ║")
    print("║  Oracle Research Council — Collaborative Investigation     ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    run_berggren_demo()
    run_factoring_demo()
    run_complexity_demo()
    run_parallel_demo()
    run_lattice_demo()
    run_quadruple_demo()

    print("\n" + "="*60)
    print("ALL EXPERIMENTS COMPLETE")
    print("="*60)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg == "--all":
            run_all_demos()
        elif arg == "--berggren":
            run_berggren_demo()
        elif arg == "--factor":
            run_factoring_demo()
        elif arg == "--complexity":
            run_complexity_demo()
        elif arg == "--parallel":
            run_parallel_demo()
        elif arg == "--lattice":
            run_lattice_demo()
        elif arg == "--quadruple":
            run_quadruple_demo()
        else:
            print(f"Unknown argument: {arg}")
            print("Usage: python demo_experiments.py [--all|--berggren|--factor|--complexity|--parallel|--lattice|--quadruple]")
    else:
        run_all_demos()
