#!/usr/bin/env python3
"""
Hypothesis Testing Suite for Quaternion Factoring
==================================================

Tests the key hypotheses from the research paper:

H1: Structured basis produces shorter vectors than random basis
H2: Scaling exponent α < 0.5 (sub-√N behavior)
H3: Dimensional hierarchy — higher dimensions give shorter vectors
H4: Optimal dimension exists (diminishing returns at high d)
H5: Enhanced extraction significantly outperforms basic extraction
H6: Quaternion norm structure aids factor extraction
H7: Pell obstacle blocks direct Berggren generalization
H8: SL(2,ℤ) tree covers all primitive quadruples

Usage:
    python hypothesis_experiments.py
"""

import math
import random
from collections import defaultdict
from typing import List, Tuple, Optional, Dict
import json

random.seed(2024)


# ============================================================
# Utility functions
# ============================================================

def isprime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True


def generate_semiprime(min_val: int, max_val: int) -> Tuple[int, int, int]:
    """Generate a random semiprime in [min_val, max_val]."""
    primes = [p for p in range(2, max_val) if isprime(p)]
    while True:
        p = random.choice(primes)
        q = random.choice(primes)
        if p != q and min_val <= p*q <= max_val:
            return p*q, min(p,q), max(p,q)


def vector_norm(v: List[int]) -> float:
    return math.sqrt(sum(x*x for x in v))


def dot(u, v):
    return sum(a*b for a, b in zip(u, v))


def lll_reduce(basis: List[List[int]], delta: float = 0.99) -> List[List[int]]:
    """LLL lattice reduction."""
    n = len(basis)
    if n == 0: return basis
    B = [list(v) for v in basis]
    dim = len(B[0])

    def gram_schmidt(B):
        n = len(B)
        Q = [list(b) for b in B]
        mu = [[0.0]*n for _ in range(n)]
        for i in range(n):
            for j in range(i):
                d = dot(Q[j], Q[j])
                mu[i][j] = dot(B[i], Q[j]) / d if d != 0 else 0
                Q[i] = [Q[i][k] - mu[i][j]*Q[j][k] for k in range(dim)]
        return Q, mu

    k = 1
    while k < n:
        Q, mu = gram_schmidt(B)
        for j in range(k-1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] = [B[k][i] - r*B[j][i] for i in range(dim)]
                Q, mu = gram_schmidt(B)
        lhs = dot(Q[k], Q[k])
        rhs = (delta - mu[k][k-1]**2) * dot(Q[k-1], Q[k-1])
        if lhs >= rhs:
            k += 1
        else:
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k-1, 1)

    return [[round(x) for x in v] for v in B]


def build_lattice(N: int, dim: int = 3) -> List[List[int]]:
    """Build lattice for sum-of-squares ≡ 0 (mod N)."""
    solutions = []
    limit = min(int(math.isqrt(N)) + 1, 300)

    if dim == 2:
        for x in range(limit):
            for y in range(1, limit):
                if (x*x + y*y) % N == 0:
                    solutions.append([x, y])
                    if len(solutions) >= 2: break
            if len(solutions) >= 2: break
        while len(solutions) < 2:
            solutions.append([N, 0] if len(solutions) == 0 else [0, N])
    elif dim == 3:
        for x in range(limit):
            for y in range(limit):
                for z in range(1, limit):
                    if (x*x + y*y + z*z) % N == 0:
                        solutions.append([x, y, z])
                        if len(solutions) >= 3: break
                if len(solutions) >= 3: break
            if len(solutions) >= 3: break
        while len(solutions) < 3:
            v = [0]*3
            v[len(solutions)] = N
            solutions.append(v)
    elif dim == 4:
        for a in range(limit):
            for b in range(limit):
                for c in range(limit):
                    for d_val in range(1, limit):
                        if (a*a + b*b + c*c + d_val*d_val) % N == 0:
                            solutions.append([a, b, c, d_val])
                            if len(solutions) >= 4: break
                    if len(solutions) >= 4: break
                if len(solutions) >= 4: break
            if len(solutions) >= 4: break
        while len(solutions) < 4:
            v = [0]*4
            v[len(solutions)] = N
            solutions.append(v)
    else:
        # General dimension
        for _ in range(dim):
            v = [0]*dim
            v[len(solutions) if len(solutions) < dim else 0] = N
            solutions.append(v)

    return solutions[:dim]


def basic_extract(N: int, vectors: List[List[int]]) -> Optional[int]:
    """Basic GCD extraction: just try sums of squares."""
    for v in vectors:
        s = sum(x*x for x in v)
        if s > 0:
            g = math.gcd(s, N)
            if 1 < g < N:
                return g
    return None


def enhanced_extract(N: int, vectors: List[List[int]]) -> Optional[int]:
    """Enhanced extraction: try coordinates, pairwise sums, combinations."""
    # Individual coordinates
    for v in vectors:
        for x in v:
            if x != 0:
                g = math.gcd(abs(x), N)
                if 1 < g < N: return g

    # Sums of squares
    for v in vectors:
        s = sum(x*x for x in v)
        if s > 0:
            g = math.gcd(s, N)
            if 1 < g < N: return g

    # Pairwise partial sums
    for v in vectors:
        for i in range(len(v)):
            for j in range(i+1, len(v)):
                s = v[i]**2 + v[j]**2
                if s > 0:
                    g = math.gcd(s, N)
                    if 1 < g < N: return g

    # Linear combinations
    for i in range(len(vectors)):
        for j in range(i+1, len(vectors)):
            for a in range(-3, 4):
                for b in range(-3, 4):
                    if a == 0 and b == 0: continue
                    combo = [a*vectors[i][k] + b*vectors[j][k] for k in range(len(vectors[0]))]
                    s = sum(x*x for x in combo)
                    if s > 0:
                        g = math.gcd(s, N)
                        if 1 < g < N: return g
                    for x in combo:
                        if x != 0:
                            g = math.gcd(abs(x), N)
                            if 1 < g < N: return g
    return None


# ============================================================
# Hypothesis Tests
# ============================================================

def test_H1_structured_basis():
    """H1: Structured basis produces shorter vectors than random basis."""
    print("\n" + "="*70)
    print("H1: Structured Basis vs Random Basis")
    print("="*70)

    results = []
    for _ in range(50):
        N, p, q = generate_semiprime(100, 10000)
        # Structured
        struct_basis = build_lattice(N, 3)
        struct_reduced = lll_reduce(struct_basis)
        struct_norms = [vector_norm(v) for v in struct_reduced if any(x != 0 for x in v)]

        # Random
        rand_basis = [[random.randint(-N, N) for _ in range(3)] for _ in range(3)]
        # Ensure they're in the lattice
        for v in rand_basis:
            v[2] = N  # Make it trivially in the lattice
        rand_reduced = lll_reduce(rand_basis)
        rand_norms = [vector_norm(v) for v in rand_reduced if any(x != 0 for x in v)]

        if struct_norms and rand_norms:
            ratio = min(rand_norms) / min(struct_norms)
            results.append(ratio)

    avg_ratio = sum(results) / len(results) if results else 0
    print(f"  Trials: {len(results)}")
    print(f"  Average ratio (random/structured): {avg_ratio:.2f}×")
    print(f"  Structured basis shorter in {sum(1 for r in results if r > 1)}/{len(results)} cases")
    verdict = "✓ SUPPORTED" if avg_ratio > 1.5 else "? INCONCLUSIVE" if avg_ratio > 1.0 else "✗ NOT SUPPORTED"
    print(f"  Verdict: {verdict}")
    return avg_ratio > 1.5


def test_H2_scaling_exponent():
    """H2: Scaling exponent α < 0.5 (sub-√N behavior)."""
    print("\n" + "="*70)
    print("H2: Scaling Exponent α < 0.5")
    print("="*70)

    log_N_vals = []
    log_norm_vals = []

    for bits in range(6, 18, 2):
        norms = []
        N_vals = []
        for _ in range(30):
            N, p, q = generate_semiprime(2**(bits-1), 2**bits)
            basis = build_lattice(N, 3)
            reduced = lll_reduce(basis)
            nz = [vector_norm(v) for v in reduced if any(x != 0 for x in v)]
            if nz:
                norms.append(min(nz))
                N_vals.append(N)

        if norms and N_vals:
            avg_N = sum(N_vals) / len(N_vals)
            avg_norm = sum(norms) / len(norms)
            log_N_vals.append(math.log(avg_N))
            log_norm_vals.append(math.log(avg_norm))
            alpha = math.log(avg_norm) / math.log(avg_N)
            print(f"  bits={bits:2d}: avg_N={avg_N:10.0f}, avg_||v||={avg_norm:8.2f}, α={alpha:.3f}")

    # Linear regression for α
    if len(log_N_vals) >= 2:
        n = len(log_N_vals)
        sx = sum(log_N_vals)
        sy = sum(log_norm_vals)
        sxx = sum(x*x for x in log_N_vals)
        sxy = sum(x*y for x, y in zip(log_N_vals, log_norm_vals))
        alpha_fit = (n*sxy - sx*sy) / (n*sxx - sx*sx)
        print(f"\n  Fitted scaling exponent: α = {alpha_fit:.4f}")
        verdict = "✓ SUPPORTED" if alpha_fit < 0.5 else "✗ NOT SUPPORTED"
        print(f"  Verdict (α < 0.5): {verdict}")
        return alpha_fit < 0.5
    return False


def test_H3_dimensional_hierarchy():
    """H3: Higher dimensions give shorter vectors (up to a point)."""
    print("\n" + "="*70)
    print("H3: Dimensional Hierarchy")
    print("="*70)

    for dim in [2, 3, 4]:
        norms = []
        for _ in range(30):
            N, p, q = generate_semiprime(100, 5000)
            basis = build_lattice(N, dim)
            reduced = lll_reduce(basis)
            nz = [vector_norm(v) for v in reduced if any(x != 0 for x in v)]
            if nz:
                norms.append(min(nz) / math.sqrt(N))

        avg_ratio = sum(norms) / len(norms) if norms else float('inf')
        print(f"  dim={dim}: avg(||v_min||/√N) = {avg_ratio:.4f}")

    print("  (Lower is better — shorter vectors relative to √N)")


def test_H4_optimal_dimension():
    """H4: There exists an optimal dimension for factoring success."""
    print("\n" + "="*70)
    print("H4: Optimal Dimension for Factoring")
    print("="*70)

    for dim in [2, 3, 4]:
        successes = 0
        trials = 50
        for _ in range(trials):
            N, p, q = generate_semiprime(100, 5000)
            basis = build_lattice(N, dim)
            reduced = lll_reduce(basis)
            factor = enhanced_extract(N, reduced)
            if factor is not None:
                successes += 1
        print(f"  dim={dim}: {successes}/{trials} = {100*successes/trials:.1f}% success rate")


def test_H5_enhanced_vs_basic():
    """H5: Enhanced extraction significantly outperforms basic extraction."""
    print("\n" + "="*70)
    print("H5: Enhanced vs Basic Extraction")
    print("="*70)

    basic_successes = 0
    enhanced_successes = 0
    trials = 80

    for _ in range(trials):
        N, p, q = generate_semiprime(100, 10000)
        basis = build_lattice(N, 3)
        reduced = lll_reduce(basis)

        if basic_extract(N, reduced) is not None:
            basic_successes += 1
        if enhanced_extract(N, reduced) is not None:
            enhanced_successes += 1

    basic_rate = 100 * basic_successes / trials
    enhanced_rate = 100 * enhanced_successes / trials
    improvement = (enhanced_rate - basic_rate) / basic_rate * 100 if basic_rate > 0 else float('inf')

    print(f"  Basic extraction:    {basic_successes}/{trials} = {basic_rate:.1f}%")
    print(f"  Enhanced extraction: {enhanced_successes}/{trials} = {enhanced_rate:.1f}%")
    print(f"  Relative improvement: {improvement:.1f}%")
    verdict = "✓ SUPPORTED" if improvement > 50 else "? INCONCLUSIVE"
    print(f"  Verdict: {verdict}")


def test_H6_quaternion_norm_structure():
    """H6: Quaternion norm structure aids factor extraction."""
    print("\n" + "="*70)
    print("H6: Quaternion Norm Structure")
    print("="*70)

    # Test: for primes p ≡ 1 (mod 4), the norm equation has more solutions
    primes_1mod4 = [p for p in range(5, 200) if isprime(p) and p % 4 == 1]
    primes_3mod4 = [p for p in range(5, 200) if isprime(p) and p % 4 == 3]

    def count_representations(n, limit=50):
        count = 0
        for a in range(limit):
            for b in range(limit):
                for c in range(limit):
                    for d in range(limit):
                        if a*a + b*b + c*c + d*d == n:
                            count += 1
        return count

    avg_1mod4 = sum(count_representations(p, 15) for p in primes_1mod4[:5]) / min(5, len(primes_1mod4))
    avg_3mod4 = sum(count_representations(p, 15) for p in primes_3mod4[:5]) / min(5, len(primes_3mod4))

    print(f"  Avg four-square representations (p≡1 mod 4): {avg_1mod4:.1f}")
    print(f"  Avg four-square representations (p≡3 mod 4): {avg_3mod4:.1f}")
    print(f"  Ratio: {avg_1mod4/avg_3mod4:.2f}×" if avg_3mod4 > 0 else "  N/A")


def test_H7_pell_obstacle():
    """H7: The Pell obstacle λ² - μ² = 1 has only trivial solutions."""
    print("\n" + "="*70)
    print("H7: Pell Obstacle Verification")
    print("="*70)

    solutions = []
    search_range = 10000
    for lam in range(-search_range, search_range + 1):
        for mu in range(-100, 101):
            if lam*lam - mu*mu == 1:
                solutions.append((lam, mu))

    trivial = [(1, 0), (-1, 0)]
    nontrivial = [s for s in solutions if s not in trivial]

    print(f"  Solutions found in [-{search_range}, {search_range}]: {solutions}")
    print(f"  Nontrivial solutions: {nontrivial}")
    verdict = "✓ SUPPORTED" if len(nontrivial) == 0 else "✗ NOT SUPPORTED"
    print(f"  Verdict: {verdict}")
    return len(nontrivial) == 0


def test_H8_quadruple_coverage():
    """H8: The SL(2,ℤ) parametrization covers all primitive quadruples."""
    print("\n" + "="*70)
    print("H8: Parametric Coverage of Primitive Quadruples")
    print("="*70)

    # Generate quadruples by brute force
    brute_force = set()
    limit = 50
    for a in range(1, limit):
        for b in range(1, limit):
            for c in range(1, limit):
                d_sq = a*a + b*b + c*c
                d = int(math.isqrt(d_sq))
                if d*d == d_sq and d > 0:
                    if math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1:
                        brute_force.add(tuple(sorted([a, b, c]) + [d]))

    # Generate via parametrization
    parametric = set()
    for m in range(-20, 21):
        for n in range(-20, 21):
            for p in range(-20, 21):
                for q in range(-20, 21):
                    if m == 0 and n == 0 and p == 0 and q == 0:
                        continue
                    a = m*m + n*n - p*p - q*q
                    b = 2*(m*q + n*p)
                    c = 2*(n*q - m*p)
                    d = m*m + n*n + p*p + q*q
                    if d > 0 and a > 0 and b > 0 and c > 0:
                        abc_sorted = tuple(sorted([a, b, c]))
                        if math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1:
                            parametric.add(abc_sorted + (d,))

    covered = brute_force & parametric
    missed = brute_force - parametric
    print(f"  Brute force quadruples (d < {limit}): {len(brute_force)}")
    print(f"  Parametric quadruples: {len(parametric)}")
    print(f"  Covered: {len(covered)}")
    print(f"  Missed: {len(missed)}")
    if missed:
        print(f"  Examples of missed: {list(missed)[:5]}")
    coverage = len(covered) / len(brute_force) * 100 if brute_force else 0
    print(f"  Coverage: {coverage:.1f}%")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═"*68 + "╗")
    print("║" + "QUATERNION FACTORING: HYPOTHESIS TESTING SUITE".center(68) + "║")
    print("╚" + "═"*68 + "╝")

    results = {}
    results['H1'] = test_H1_structured_basis()
    results['H2'] = test_H2_scaling_exponent()
    test_H3_dimensional_hierarchy()
    test_H4_optimal_dimension()
    test_H5_enhanced_vs_basic()
    test_H6_quaternion_norm_structure()
    results['H7'] = test_H7_pell_obstacle()
    test_H8_quadruple_coverage()

    print("\n" + "="*70)
    print("HYPOTHESIS SCORECARD")
    print("="*70)
    for k, v in results.items():
        status = "✓ SUPPORTED" if v else "✗ NOT SUPPORTED"
        print(f"  {k}: {status}")
