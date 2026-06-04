#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for ECA algebraic geometry over GF(2).

Type-hinted implementations of the mathematical constructions
formalized in Lean 4.
"""

from typing import List, Tuple, Dict, Optional, Set
from functools import lru_cache
import itertools


# ====================================================================
# Algorithm 1: Algebraic Normal Form (ANF) Computation
# ====================================================================

def compute_anf(rule_num: int) -> Dict[str, int]:
    """
    Compute the Algebraic Normal Form of an ECA rule via Möbius inversion
    on the Boolean lattice {0,1}^3.

    The ANF is the unique representation:
        g(a,b,c) = a₀ ⊕ a_a·a ⊕ a_b·b ⊕ a_c·c ⊕ a_{ab}·ab ⊕ a_{ac}·ac ⊕ a_{bc}·bc ⊕ a_{abc}·abc

    Time: O(1) — fixed 8 truth table evaluations, 8 XOR operations.
    """
    # Evaluate truth table
    tt: Dict[Tuple[int, int, int], int] = {}
    for a, b, c in itertools.product([0, 1], repeat=3):
        tt[(a, b, c)] = (rule_num >> (4 * a + 2 * b + c)) & 1

    # Möbius inversion on the Boolean lattice
    return {
        '1':   tt[(0, 0, 0)],
        'c':   tt[(0, 0, 0)] ^ tt[(0, 0, 1)],
        'b':   tt[(0, 0, 0)] ^ tt[(0, 1, 0)],
        'bc':  tt[(0, 0, 0)] ^ tt[(0, 0, 1)] ^ tt[(0, 1, 0)] ^ tt[(0, 1, 1)],
        'a':   tt[(0, 0, 0)] ^ tt[(1, 0, 0)],
        'ac':  tt[(0, 0, 0)] ^ tt[(0, 0, 1)] ^ tt[(1, 0, 0)] ^ tt[(1, 0, 1)],
        'ab':  tt[(0, 0, 0)] ^ tt[(0, 1, 0)] ^ tt[(1, 0, 0)] ^ tt[(1, 1, 0)],
        'abc': (tt[(0, 0, 0)] ^ tt[(0, 0, 1)] ^ tt[(0, 1, 0)] ^ tt[(0, 1, 1)] ^
                tt[(1, 0, 0)] ^ tt[(1, 0, 1)] ^ tt[(1, 1, 0)] ^ tt[(1, 1, 1)]),
    }


def anf_degree(rule_num: int) -> int:
    """Algebraic degree of the rule's ANF. Returns -1 for the zero rule."""
    c = compute_anf(rule_num)
    if c['abc']: return 3
    if c['ab'] or c['ac'] or c['bc']: return 2
    if c['a'] or c['b'] or c['c']: return 1
    if c['1']: return 0
    return -1


def anf_to_string(rule_num: int) -> str:
    """Human-readable ANF polynomial string."""
    c = compute_anf(rule_num)
    terms = []
    for name in ['1', 'a', 'b', 'c', 'ab', 'ac', 'bc', 'abc']:
        if c[name]:
            terms.append(name)
    return ' + '.join(terms) if terms else '0'


# ====================================================================
# Algorithm 2: Fixed-Point Variety Computation
# ====================================================================

def eca_update(rule_num: int, state: Tuple[int, ...]) -> Tuple[int, ...]:
    """Apply ECA rule to cyclic state vector. O(n) per update."""
    n = len(state)
    return tuple(
        (rule_num >> (4 * state[(i - 1) % n] + 2 * state[i] + state[(i + 1) % n])) & 1
        for i in range(n)
    )


def fixed_points_bruteforce(rule_num: int, n: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all fixed points of ECA rule on cycle of length n.
    Time: O(2^n · n) — exhaustive search.
    """
    return [s for s in itertools.product([0, 1], repeat=n)
            if eca_update(rule_num, s) == s]


def fixed_point_dimension(rule_num: int, n: int) -> float:
    """
    Compute log₂|Fix(rule, n)|. Returns -inf if no fixed points.
    For linear rules, this is always an integer (the vector space dimension).
    """
    import math
    count = len(fixed_points_bruteforce(rule_num, n))
    return math.log2(count) if count > 0 else float('-inf')


# ====================================================================
# Algorithm 3: Complement Involution
# ====================================================================

def complement_rule(rule_num: int) -> int:
    """
    Compute the complement rule: negate all inputs and the output.
    The complement involution partitions 256 rules into 128 pairs
    (plus fixed points for self-complementary rules).
    """
    result = 0
    for a, b, c in itertools.product([0, 1], repeat=3):
        idx = 4 * a + 2 * b + c
        comp_val = 1 ^ ((rule_num >> (4 * (1 ^ a) + 2 * (1 ^ b) + (1 ^ c))) & 1)
        result |= (comp_val << idx)
    return result


def complement_state(state: Tuple[int, ...]) -> Tuple[int, ...]:
    """Bitwise complement of a state vector."""
    return tuple(1 ^ x for x in state)


def is_self_complementary(rule_num: int) -> bool:
    """Check if a rule equals its own complement."""
    return complement_rule(rule_num) == rule_num


# ====================================================================
# Algorithm 4: Linearity Classification
# ====================================================================

def is_linear(rule_num: int) -> bool:
    """
    Check GF(2)-linearity of an ECA rule.
    A rule is linear iff its ANF has degree ≤ 1 with zero constant term.
    """
    c = compute_anf(rule_num)
    return (c['1'] == 0 and c['ab'] == 0 and c['ac'] == 0 and
            c['bc'] == 0 and c['abc'] == 0)


def classify_all_rules() -> Dict[str, List[int]]:
    """
    Classify all 256 ECA rules by their algebraic properties.

    Returns dict with keys:
    - 'linear': GF(2)-linear rules (ANF degree ≤ 1, constant term 0)
    - 'affine': affine rules (ANF degree ≤ 1)
    - 'quadratic': rules with ANF degree exactly 2
    - 'cubic': rules with ANF degree exactly 3
    - 'self_complementary': rules equal to their complement
    """
    result: Dict[str, List[int]] = {
        'linear': [], 'affine': [], 'quadratic': [],
        'cubic': [], 'self_complementary': []
    }
    for r in range(256):
        deg = anf_degree(r)
        c = compute_anf(r)

        if is_linear(r):
            result['linear'].append(r)
        if deg <= 1:
            result['affine'].append(r)
        if deg == 2:
            result['quadratic'].append(r)
        if deg == 3:
            result['cubic'].append(r)
        if is_self_complementary(r):
            result['self_complementary'].append(r)

    return result


# ====================================================================
# Algorithm 5: Circulant Matrix Rank over GF(2)
# ====================================================================

def circulant_matrix_gf2(first_row: List[int], n: int) -> List[List[int]]:
    """Build an n×n circulant matrix over GF(2) from its first row."""
    row = (first_row + [0] * n)[:n]
    return [row[-i:] + row[:-i] for i in range(n)]


def gf2_rank(matrix: List[List[int]]) -> int:
    """
    Compute rank of a matrix over GF(2) via Gaussian elimination.
    Time: O(n²m) where n = rows, m = cols.
    """
    m = [row[:] for row in matrix]  # copy
    rows, cols = len(m), len(m[0]) if m else 0
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if m[row][col]:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        m[rank], m[pivot] = m[pivot], m[rank]
        # Eliminate
        for row in range(rows):
            if row != rank and m[row][col]:
                m[row] = [m[row][j] ^ m[rank][j] for j in range(cols)]
        rank += 1
    return rank


def linear_rule_fp_dimension(alpha: int, beta: int, gamma: int, n: int) -> int:
    """
    For a linear ECA g(a,b,c) = α·a + β·b + γ·c, compute the dimension
    of the fixed-point variety on a cycle of length n.

    The fixed-point equation is: α·s_{i-1} + (β⊕1)·s_i + γ·s_{i+1} = 0
    This is a circulant system; dimension = n - rank(circulant).
    """
    # Build first row of the circulant
    first_row = [0] * n
    if n >= 1:
        first_row[0] = beta ^ 1  # coefficient of s_i (β - 1 = β + 1 in GF(2))
    if n >= 2:
        first_row[1] = gamma     # coefficient of s_{i+1}
        first_row[n - 1] = alpha # coefficient of s_{i-1}
    elif n == 1:
        first_row[0] = alpha ^ (beta ^ 1) ^ gamma  # all coefficients collapse

    mat = circulant_matrix_gf2(first_row, n)
    return n - gf2_rank(mat)


if __name__ == '__main__':
    print("=== ECA Algebraic Classification ===\n")
    cls = classify_all_rules()
    for key, rules in cls.items():
        print(f"{key}: {len(rules)} rules — {rules}")

    print("\n=== Linear Rule Fixed-Point Dimensions ===\n")
    for r in cls['linear']:
        c = compute_anf(r)
        alpha, beta, gamma = c['a'], c['b'], c['c']
        print(f"Rule {r:3d} (ANF: {anf_to_string(r):10s}): ", end="")
        dims = []
        for n in range(1, 13):
            d = linear_rule_fp_dimension(alpha, beta, gamma, n)
            dims.append(f"n={n}:dim={d}")
        print(", ".join(dims))
