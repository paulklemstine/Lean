#!/usr/bin/env python3
"""
Inverse Pythagorean Tree Factoring — Core Implementation

Demonstrates the factoring algorithm that descends the Berggren tree
from a trivial Pythagorean triple to extract factors via GCD.

Usage:
    python inverse_tree_factoring.py [N]
    python inverse_tree_factoring.py          # runs demo on several semiprimes
"""

import math
import sys
from typing import Tuple, Optional, List

# ============================================================================
# Berggren Matrices (Inverse)
# ============================================================================

def inv_B1(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren matrix B₁⁻¹."""
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def inv_B2(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren matrix B₂⁻¹."""
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def inv_B3(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren matrix B₃⁻¹."""
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

# ============================================================================
# Forward Berggren Matrices
# ============================================================================

def fwd_B1(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren matrix B₁."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def fwd_B2(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren matrix B₂."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def fwd_B3(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren matrix B₃."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# ============================================================================
# Parent Operation
# ============================================================================

def parent(a: int, b: int, c: int) -> Tuple[Tuple[int, int, int], int]:
    """
    Compute the parent triple in the Berggren tree.
    Returns (parent_triple, branch_index) where branch_index ∈ {1, 2, 3}.
    
    Exactly one of the three inverse matrices produces all-positive components.
    """
    candidates = [
        (inv_B1(a, b, c), 1),
        (inv_B2(a, b, c), 2),
        (inv_B3(a, b, c), 3),
    ]
    
    for (a2, b2, c2), branch in candidates:
        if a2 > 0 and b2 > 0 and c2 > 0:
            return (a2, b2, c2), branch
    
    # Fallback: normalize by taking absolute values
    # (this handles the convention where a or b might be swapped)
    for (a2, b2, c2), branch in candidates:
        aa, bb, cc = abs(a2), abs(b2), abs(c2)
        if aa > 0 and bb > 0 and cc > 0 and aa*aa + bb*bb == cc*cc:
            return (aa, bb, cc), branch
    
    raise ValueError(f"No valid parent found for ({a}, {b}, {c})")

# ============================================================================
# Trivial Triple Construction
# ============================================================================

def trivial_triple(N: int) -> Tuple[int, int, int]:
    """
    Construct the trivial Pythagorean triple for odd N:
    (N, (N²-1)/2, (N²+1)/2)
    
    Satisfies: N² + ((N²-1)/2)² = ((N²+1)/2)²
    """
    assert N % 2 == 1 and N > 1, f"N must be odd and > 1, got {N}"
    b = (N * N - 1) // 2
    c = (N * N + 1) // 2
    assert N*N + b*b == c*c, "Pythagorean property check failed"
    return (N, b, c)

# ============================================================================
# Main Factoring Algorithm
# ============================================================================

def factor_by_descent(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Factor odd composite N by descending the Berggren tree.
    
    Returns:
        (p, q) such that N = p * q, or None if N is prime.
    """
    if N % 2 == 0:
        return (2, N // 2)
    if N <= 1:
        return None
    
    a, b, c = trivial_triple(N)
    
    if verbose:
        print(f"\nFactoring N = {N}")
        print(f"Trivial triple: ({a}, {b}, {c})")
        print(f"{'Step':>6} {'a':>12} {'b':>12} {'c':>12} {'Branch':>8} {'gcd(a,N)':>10} {'gcd(b,N)':>10}")
        print("-" * 80)
    
    depth = 0
    branch_sequence = []
    
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        # Check GCD at current level
        for component_name, component in [('a', a), ('b', b)]:
            g = math.gcd(abs(component), N)
            if 1 < g < N:
                if verbose:
                    print(f"  >>> FACTOR FOUND at depth {depth}: "
                          f"gcd({component_name}={component}, N={N}) = {g}")
                    print(f"  >>> N = {g} × {N // g}")
                    print(f"  >>> Branch sequence: {branch_sequence}")
                return (g, N // g)
        
        # Descend one level
        try:
            (a, b, c), branch = parent(a, b, c)
        except ValueError:
            if verbose:
                print(f"  Descent failed at depth {depth}")
            break
        
        branch_sequence.append(branch)
        depth += 1
        
        if verbose and depth <= 50:
            ga = math.gcd(abs(a), N)
            gb = math.gcd(abs(b), N)
            print(f"{depth:6d} {a:12d} {b:12d} {c:12d} {branch:8d} {ga:10d} {gb:10d}")
    
    # Final check at root
    for component in [a, b]:
        g = math.gcd(abs(component), N)
        if 1 < g < N:
            if verbose:
                print(f"  >>> FACTOR FOUND at root: gcd({component}, N={N}) = {g}")
            return (g, N // g)
    
    if verbose:
        print(f"  Reached root without finding factor (N={N} may be prime)")
    return None

# ============================================================================
# Jump-Ahead: Matrix Composition
# ============================================================================

def matrix_mult_3x3(A, B):
    """Multiply two 3x3 integer matrices (as lists of lists)."""
    result = [[0]*3 for _ in range(3)]
    for i in range(3):
        for j in range(3):
            for k in range(3):
                result[i][j] += A[i][k] * B[k][j]
    return result

def matrix_pow_3x3(M, n):
    """Compute M^n for a 3x3 integer matrix using repeated squaring."""
    if n == 0:
        return [[1,0,0],[0,1,0],[0,0,1]]  # Identity
    if n == 1:
        return [row[:] for row in M]
    if n % 2 == 0:
        half = matrix_pow_3x3(M, n // 2)
        return matrix_mult_3x3(half, half)
    else:
        return matrix_mult_3x3(M, matrix_pow_3x3(M, n - 1))

def apply_matrix(M, triple):
    """Apply 3x3 matrix to a triple (a,b,c)."""
    a, b, c = triple
    v = [a, b, c]
    result = [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]
    return tuple(result)

# Inverse Berggren matrices as 3x3 arrays
INV_B1_MAT = [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]]
INV_B2_MAT = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]
INV_B3_MAT = [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]]

def jump_ahead(triple, branch_sequence):
    """
    Apply a sequence of inverse Berggren matrices as a single composed matrix.
    
    This is the 'jump-ahead' optimization: instead of applying matrices one
    at a time, we compose them first (O(k) multiplications) then apply once.
    
    For runs of identical branches, we can use matrix exponentiation for O(log k).
    """
    branch_to_matrix = {1: INV_B1_MAT, 2: INV_B2_MAT, 3: INV_B3_MAT}
    
    # Compose all matrices (rightmost applied first)
    composed = [[1,0,0],[0,1,0],[0,0,1]]  # Identity
    for branch in branch_sequence:
        composed = matrix_mult_3x3(branch_to_matrix[branch], composed)
    
    return apply_matrix(composed, triple)

def jump_ahead_run(triple, branch: int, count: int):
    """
    Jump ahead by applying the same branch matrix `count` times.
    Uses O(log count) matrix multiplications via repeated squaring.
    """
    branch_to_matrix = {1: INV_B1_MAT, 2: INV_B2_MAT, 3: INV_B3_MAT}
    M_power = matrix_pow_3x3(branch_to_matrix[branch], count)
    return apply_matrix(M_power, triple)

# ============================================================================
# Descent Path Analysis
# ============================================================================

def full_descent(N: int) -> List[Tuple[Tuple[int,int,int], int]]:
    """
    Compute the full descent path from trivial triple to (3,4,5).
    Returns list of (triple, branch) pairs.
    """
    a, b, c = trivial_triple(N)
    path = [((a, b, c), 0)]  # 0 = starting node
    
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        try:
            (a, b, c), branch = parent(a, b, c)
            path.append(((a, b, c), branch))
        except ValueError:
            break
    
    return path

def analyze_branch_runs(path: List[Tuple[Tuple[int,int,int], int]]) -> List[Tuple[int, int]]:
    """
    Analyze consecutive runs of identical branches in a descent path.
    Returns list of (branch, run_length) pairs.
    """
    runs = []
    if len(path) <= 1:
        return runs
    
    current_branch = path[1][1]
    current_count = 1
    
    for i in range(2, len(path)):
        branch = path[i][1]
        if branch == current_branch:
            current_count += 1
        else:
            runs.append((current_branch, current_count))
            current_branch = branch
            current_count = 1
    
    runs.append((current_branch, current_count))
    return runs

# ============================================================================
# Continued Fraction Utilities
# ============================================================================

def continued_fraction(p: int, q: int, max_terms: int = 50) -> List[int]:
    """Compute the continued fraction expansion of p/q."""
    terms = []
    while q != 0 and len(terms) < max_terms:
        a = p // q
        terms.append(a)
        p, q = q, p - a * q
    return terms

def convergents(cf: List[int]) -> List[Tuple[int, int]]:
    """Compute convergents p_k/q_k from continued fraction coefficients."""
    if not cf:
        return []
    
    convs = []
    h_prev, h_curr = 0, 1
    k_prev, k_curr = 1, 0
    
    for a in cf:
        h_prev, h_curr = h_curr, a * h_curr + h_prev
        k_prev, k_curr = k_curr, a * k_curr + k_prev
        convs.append((h_curr, k_curr))
    
    return convs

# ============================================================================
# Demo
# ============================================================================

def demo():
    """Run demonstration on several semiprimes."""
    print("=" * 80)
    print("INVERSE PYTHAGOREAN TREE FACTORING — DEMONSTRATION")
    print("=" * 80)
    
    test_cases = [
        77,      # 7 × 11
        91,      # 7 × 13
        143,     # 11 × 13
        221,     # 13 × 17
        2537,    # 43 × 59
        10403,   # 101 × 103
        1000003, # 127 × 7874 (imbalanced — but actually 1000003 = ?)
    ]
    
    # Correct the last one
    test_cases[-1] = 7 * 142857  # 999999 — let's use a real semiprime
    test_cases[-1] = 1001  # 7 × 11 × 13
    
    print("\n" + "-" * 80)
    print(f"{'N':>10} {'Factors':>20} {'Depth':>8} {'Branch Sequence':>30}")
    print("-" * 80)
    
    for N in test_cases:
        if N % 2 == 0:
            continue
        
        path = full_descent(N)
        result = factor_by_descent(N)
        branches = [p[1] for p in path[1:]]
        branch_str = ''.join(str(b) for b in branches[:25])
        if len(branches) > 25:
            branch_str += '...'
        
        if result:
            p, q = result
            factor_str = f"{p} × {q}"
        else:
            factor_str = "prime"
        
        print(f"{N:10d} {factor_str:>20} {len(path)-1:8d} {branch_str:>30}")
    
    # Detailed trace for N = 77
    print("\n" + "=" * 80)
    print("DETAILED TRACE: N = 77")
    print("=" * 80)
    factor_by_descent(77, verbose=True)
    
    # Jump-ahead demonstration
    print("\n" + "=" * 80)
    print("JUMP-AHEAD DEMONSTRATION: N = 221")
    print("=" * 80)
    
    N = 221
    path = full_descent(N)
    branches = [p[1] for p in path[1:]]
    runs = analyze_branch_runs(path)
    
    print(f"\nBranch sequence: {''.join(str(b) for b in branches)}")
    print(f"Run-length encoding: {runs}")
    print(f"Total depth: {len(branches)}")
    
    # Verify jump-ahead
    triple0 = path[0][0]
    result_sequential = path[-1][0]
    result_jump = jump_ahead(triple0, branches)
    print(f"\nSequential result: {result_sequential}")
    print(f"Jump-ahead result: {result_jump}")
    print(f"Match: {result_sequential == result_jump or (result_jump[1], result_jump[0], result_jump[2]) == result_sequential}")
    
    # Continued fraction analysis
    print("\n" + "=" * 80)
    print("CONTINUED FRACTION ANALYSIS")
    print("=" * 80)
    
    for N in [77, 143, 221]:
        m = (N + 1) // 2
        n = (N - 1) // 2
        cf = continued_fraction(m, n)
        convs = convergents(cf)
        path = full_descent(N)
        branches = [p[1] for p in path[1:]]
        
        print(f"\nN = {N}, m/n = {m}/{n}")
        print(f"  Continued fraction of m/n: {cf}")
        print(f"  Convergents: {convs[:5]}")
        print(f"  Branch sequence: {''.join(str(b) for b in branches)}")
        
        # Also check sqrt(N)
        # Approximate continued fraction of sqrt(N)
        from math import isqrt
        s = isqrt(N)
        if s * s != N:
            # Compute periodic CF of sqrt(N)
            cf_sqrt = []
            m0, d0, a0 = 0, 1, s
            cf_sqrt.append(a0)
            mi, di, ai = m0, d0, a0
            for _ in range(20):
                mi = ai * di - mi
                di = (N - mi * mi) // di
                if di == 0:
                    break
                ai = (s + mi) // di
                cf_sqrt.append(ai)
                if ai == 2 * s:
                    break
            print(f"  Continued fraction of √{N}: {cf_sqrt}")


if __name__ == '__main__':
    if len(sys.argv) > 1:
        N = int(sys.argv[1])
        result = factor_by_descent(N, verbose=True)
        if result:
            p, q = result
            print(f"\n✓ N = {N} = {p} × {q}")
        else:
            print(f"\nN = {N} appears to be prime")
    else:
        demo()
