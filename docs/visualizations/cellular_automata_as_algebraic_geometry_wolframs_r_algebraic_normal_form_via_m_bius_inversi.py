#!/usr/bin/env python3
"""
Algorithms for Cellular Automata as Algebraic Geometry over GF(2)
=================================================================
Type-hinted implementations of the core algorithms.
"""

import itertools
from typing import List, Tuple, Set, Optional


def gf2_add(a: int, b: int) -> int:
    """Addition in GF(2)."""
    return (a + b) % 2


def gf2_mul(a: int, b: int) -> int:
    """Multiplication in GF(2)."""
    return (a * b) % 2


def eca_truth_table(rule_num: int) -> List[int]:
    """Extract the 8-entry truth table from a rule number.
    
    Index i = 4*a + 2*b + c maps to g(a,b,c).
    """
    return [(rule_num >> i) & 1 for i in range(8)]


def mobius_inversion_3d(truth_table: List[int]) -> List[int]:
    """Compute ANF coefficients from truth table via Möbius inversion
    on the Boolean lattice {0,1}^3.
    
    Algorithm: For each subset S ⊆ {a,b,c}, the ANF coefficient for
    the monomial ∏_{x∈S} x equals the sum (in GF(2)) of f(v) over
    all v ≤ S in the Boolean lattice.
    
    Complexity: O(2^k) for k variables, here k=3.
    """
    # Subsets of {0,1,2} encoded as bitmasks
    # Bit 0 = variable a, bit 1 = variable b, bit 2 = variable c
    coeffs = [0] * 8
    for mask in range(8):
        # Sum over all subsets of mask
        total = 0
        submask = mask
        while True:
            # Convert submask to truth table index
            a = (submask >> 0) & 1
            b = (submask >> 1) & 1
            c = (submask >> 2) & 1
            idx = a * 4 + b * 2 + c
            total = gf2_add(total, truth_table[idx])
            if submask == 0:
                break
            submask = (submask - 1) & mask
        # Reorder: mask bits {a,b,c} -> coefficient index
        # mask=0->c0, mask=1(a)->c1, mask=2(b)->c2, mask=4(c)->c3,
        # mask=3(ab)->c4, mask=5(ac)->c5, mask=6(bc)->c6, mask=7(abc)->c7
        reorder = {0: 0, 1: 1, 2: 2, 4: 3, 3: 4, 5: 5, 6: 6, 7: 7}
        coeffs[reorder[mask]] = total
    return coeffs


def evaluate_anf(coeffs: List[int], a: int, b: int, c: int) -> int:
    """Evaluate ANF polynomial at a point."""
    return gf2_add(
        gf2_add(
            gf2_add(coeffs[0], gf2_mul(coeffs[1], a)),
            gf2_add(gf2_mul(coeffs[2], b), gf2_mul(coeffs[3], c))
        ),
        gf2_add(
            gf2_add(gf2_mul(coeffs[4], gf2_mul(a, b)), gf2_mul(coeffs[5], gf2_mul(a, c))),
            gf2_add(gf2_mul(coeffs[6], gf2_mul(b, c)), gf2_mul(coeffs[7], gf2_mul(a, gf2_mul(b, c))))
        )
    )


def anf_degree(coeffs: List[int]) -> int:
    """Compute the algebraic degree from ANF coefficients."""
    if coeffs[7]:
        return 3
    if any(coeffs[i] for i in [4, 5, 6]):
        return 2
    if any(coeffs[i] for i in [1, 2, 3]):
        return 1
    if coeffs[0]:
        return 0
    return -1


def complement_conjugate(rule_num: int) -> int:
    """Compute the complement-conjugate rule number.
    
    g̃(a,b,c) = 1 + g(1+a, 1+b, 1+c) over GF(2).
    This implements the involution on the 256-element rule space.
    """
    g_table = eca_truth_table(rule_num)
    new_rule = 0
    for a, b, c in itertools.product([0, 1], repeat=3):
        idx = a * 4 + b * 2 + c
        val = gf2_add(1, g_table[gf2_add(1, a) * 4 + gf2_add(1, b) * 2 + gf2_add(1, c)])
        new_rule |= (val << idx)
    return new_rule


def fixed_points_bruteforce(rule_num: int, n: int) -> List[Tuple[int, ...]]:
    """Enumerate all fixed points of an ECA by brute force.
    
    Returns list of states (as tuples of 0/1 values).
    Complexity: O(n * 2^n)
    """
    g_table = eca_truth_table(rule_num)
    fixed = []
    for bits in itertools.product([0, 1], repeat=n):
        is_fixed = True
        for i in range(n):
            left = bits[(i - 1) % n]
            center = bits[i]
            right = bits[(i + 1) % n]
            idx = left * 4 + center * 2 + right
            if g_table[idx] != center:
                is_fixed = False
                break
        if is_fixed:
            fixed.append(bits)
    return fixed


def gf2_matrix_kernel_dim(matrix: List[List[int]], n_cols: int) -> int:
    """Compute the dimension of the kernel of a GF(2) matrix using Gaussian elimination.
    
    Returns dim(ker(A)) = n_cols - rank(A).
    """
    m = [row[:] for row in matrix]  # copy
    n_rows = len(m)
    pivot_cols: List[int] = []
    row_idx = 0
    
    for col in range(n_cols):
        # Find pivot
        found = -1
        for r in range(row_idx, n_rows):
            if m[r][col] == 1:
                found = r
                break
        if found == -1:
            continue
        # Swap
        m[row_idx], m[found] = m[found], m[row_idx]
        pivot_cols.append(col)
        # Eliminate
        for r in range(n_rows):
            if r != row_idx and m[r][col] == 1:
                for c in range(n_cols):
                    m[r][c] = gf2_add(m[r][c], m[row_idx][c])
        row_idx += 1
    
    rank = len(pivot_cols)
    return n_cols - rank


def additive_fixed_point_dimension(rule_num: int, n: int) -> int:
    """For an additive rule, compute the dimension of the fixed-point variety
    as dim(ker(f - id)) using linear algebra over GF(2).
    
    This is the efficient algebraic geometry approach: instead of brute-force
    enumeration (O(2^n)), we solve a linear system (O(n^3)).
    """
    tt = eca_truth_table(rule_num)
    # Extract linear coefficients: g(a,b,c) = alpha*a + beta*b + gamma*c
    alpha = gf2_add(tt[0], tt[4])  # g(1,0,0) - g(0,0,0) mod 2
    beta = gf2_add(tt[0], tt[2])   # g(0,1,0) - g(0,0,0)
    gamma = gf2_add(tt[0], tt[1])  # g(0,0,1) - g(0,0,0)
    
    # Build the matrix (f - id) over GF(2)
    # f(s)_i = alpha * s_{i-1} + beta * s_i + gamma * s_{i+1}
    # (f - id)(s)_i = alpha * s_{i-1} + (beta - 1) * s_i + gamma * s_{i+1}
    # In GF(2), beta - 1 = beta + 1
    matrix = []
    for i in range(n):
        row = [0] * n
        row[(i - 1) % n] = alpha
        row[i] = gf2_add(beta, 1)
        row[(i + 1) % n] = gf2_add(row[(i + 1) % n], gamma)
        matrix.append(row)
    
    return gf2_matrix_kernel_dim(matrix, n)


def classify_all_rules() -> dict:
    """Classify all 256 ECA rules by their algebraic properties."""
    result = {
        'additive': [],
        'affine': [],  # constant + linear
        'quadratic': [],
        'cubic': [],
        'complement_pairs': [],
        'self_conjugate': [],
    }
    
    for r in range(256):
        coeffs = mobius_inversion_3d(eca_truth_table(r))
        deg = anf_degree(coeffs)
        
        if coeffs[0] == 0 and deg <= 1:
            result['additive'].append(r)
        elif deg <= 1:
            result['affine'].append(r)
        elif deg == 2:
            result['quadratic'].append(r)
        else:
            result['cubic'].append(r)
        
        rc = complement_conjugate(r)
        if r == rc:
            result['self_conjugate'].append(r)
        elif r < rc:
            result['complement_pairs'].append((r, rc))
    
    return result


if __name__ == "__main__":
    classification = classify_all_rules()
    print("ECA Algebraic Classification:")
    for key, val in classification.items():
        print(f"  {key}: {len(val)} entries")
    
    print("\nAdditive rules:", classification['additive'])
    print("Self-conjugate rules:", classification['self_conjugate'])
