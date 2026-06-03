"""
Algorithms for Cellular Automata as Algebraic Geometry over GF(2).

Implements:
1. Algebraic Normal Form (ANF) computation for ECA rules
2. Fixed-point variety computation
3. Fixed-point dimension calculation via rank-nullity
4. Wolfram complexity classification
"""

from typing import List, Tuple, Dict, Optional
from itertools import product


def gf2_add(a: int, b: int) -> int:
    """Addition in GF(2) = XOR."""
    return (a + b) % 2


def gf2_mul(a: int, b: int) -> int:
    """Multiplication in GF(2) = AND."""
    return a & b


def rule_truth_table(rule_number: int) -> Dict[Tuple[int, int, int], int]:
    """
    Compute the truth table of a Wolfram ECA rule.
    
    Args:
        rule_number: Integer 0-255 encoding the rule.
        
    Returns:
        Dictionary mapping (left, center, right) -> output.
    """
    table = {}
    for a, b, c in product([0, 1], repeat=3):
        idx = 4 * a + 2 * b + c
        table[(a, b, c)] = (rule_number >> idx) & 1
    return table


def compute_anf(rule_number: int) -> List[int]:
    """
    Compute the Algebraic Normal Form (ANF) coefficients of an ECA rule
    via Möbius inversion over GF(2).
    
    The ANF is: f(a,b,c) = c0 + c1*a + c2*b + c3*c + c4*ab + c5*ac + c6*bc + c7*abc
    
    Args:
        rule_number: Integer 0-255 encoding the rule.
        
    Returns:
        List [c0, c1, c2, c3, c4, c5, c6, c7] of GF(2) coefficients.
    """
    g = rule_truth_table(rule_number)
    
    c0 = g[(0, 0, 0)]
    c1 = gf2_add(g[(1, 0, 0)], g[(0, 0, 0)])
    c2 = gf2_add(g[(0, 1, 0)], g[(0, 0, 0)])
    c3 = gf2_add(g[(0, 0, 1)], g[(0, 0, 0)])
    c4 = gf2_add(gf2_add(gf2_add(g[(1, 1, 0)], g[(1, 0, 0)]), g[(0, 1, 0)]), g[(0, 0, 0)])
    c5 = gf2_add(gf2_add(gf2_add(g[(1, 0, 1)], g[(1, 0, 0)]), g[(0, 0, 1)]), g[(0, 0, 0)])
    c6 = gf2_add(gf2_add(gf2_add(g[(0, 1, 1)], g[(0, 1, 0)]), g[(0, 0, 1)]), g[(0, 0, 0)])
    c7 = gf2_add(
        gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(gf2_add(
            g[(1, 1, 1)], g[(1, 1, 0)]), g[(1, 0, 1)]), g[(0, 1, 1)]),
            g[(1, 0, 0)]), g[(0, 1, 0)]), g[(0, 0, 1)]), g[(0, 0, 0)])
    
    return [c0, c1, c2, c3, c4, c5, c6, c7]


def anf_degree(coeffs: List[int]) -> int:
    """
    Compute the degree of an ANF polynomial.
    
    Args:
        coeffs: List of 8 GF(2) coefficients [c0..c7].
        
    Returns:
        Degree 0-3.
    """
    if coeffs[7] != 0:
        return 3
    if any(coeffs[i] != 0 for i in [4, 5, 6]):
        return 2
    if any(coeffs[i] != 0 for i in [1, 2, 3]):
        return 1
    return 0


def anf_to_string(coeffs: List[int]) -> str:
    """Convert ANF coefficients to a human-readable polynomial string."""
    terms = []
    labels = ["1", "a", "b", "c", "ab", "ac", "bc", "abc"]
    for i, (c, label) in enumerate(zip(coeffs, labels)):
        if c != 0:
            terms.append(label)
    if not terms:
        return "0"
    return " + ".join(terms)


def is_additive(rule_number: int) -> bool:
    """Check if a rule is additive (linear), i.e., ANF degree <= 1."""
    return anf_degree(compute_anf(rule_number)) <= 1


def eca_update(state: List[int], rule_number: int) -> List[int]:
    """
    Apply one step of an ECA rule to a cyclic state.
    
    Args:
        state: List of 0s and 1s.
        rule_number: Integer 0-255.
        
    Returns:
        Updated state.
    """
    n = len(state)
    table = rule_truth_table(rule_number)
    return [table[(state[(i - 1) % n], state[i], state[(i + 1) % n])] for i in range(n)]


def find_fixed_points(rule_number: int, n: int) -> List[Tuple[int, ...]]:
    """
    Find all fixed points of an ECA rule on a cyclic array of length n.
    Brute-force enumeration over GF(2)^n.
    
    Args:
        rule_number: Integer 0-255.
        n: Length of the cyclic array.
        
    Returns:
        List of fixed-point states (as tuples).
    """
    fixed = []
    for state in product([0, 1], repeat=n):
        s = list(state)
        if eca_update(s, rule_number) == s:
            fixed.append(state)
    return fixed


def fixed_point_dimension(rule_number: int, n: int) -> Optional[int]:
    """
    Compute the dimension of the fixed-point variety for an ECA rule.
    For additive rules, this is the dimension of the kernel of (f - id).
    For non-additive rules, returns the log2 of the number of fixed points
    (which may not be an integer if the set is not a subspace).
    
    Args:
        rule_number: Integer 0-255.
        n: Length of the cyclic array.
        
    Returns:
        Dimension (integer), or None if the count is not a power of 2.
    """
    import math
    count = len(find_fixed_points(rule_number, n))
    if count == 0:
        return -1  # empty variety
    log2 = math.log2(count)
    if log2 == int(log2):
        return int(log2)
    return None  # not a power of 2 => not a subspace


def gf2_matrix_kernel_dim(matrix: List[List[int]], n: int) -> int:
    """
    Compute the dimension of the kernel of a matrix over GF(2)
    using Gaussian elimination.
    
    Args:
        matrix: m x n matrix over GF(2).
        n: Number of columns.
        
    Returns:
        Dimension of the kernel.
    """
    m = len(matrix)
    mat = [row[:] for row in matrix]
    
    pivot_cols = []
    row = 0
    for col in range(n):
        # Find pivot
        found = False
        for r in range(row, m):
            if mat[r][col] == 1:
                mat[row], mat[r] = mat[r], mat[row]
                found = True
                break
        if not found:
            continue
        pivot_cols.append(col)
        # Eliminate
        for r in range(m):
            if r != row and mat[r][col] == 1:
                mat[r] = [gf2_add(mat[r][j], mat[row][j]) for j in range(n)]
        row += 1
    
    rank = len(pivot_cols)
    return n - rank


def build_update_matrix(rule_number: int, n: int) -> List[List[int]]:
    """
    For an additive ECA rule, build the n×n matrix M over GF(2) such that
    the update is f(s) = M·s. The fixed points are ker(M - I).
    
    Args:
        rule_number: Integer 0-255.
        n: Length of cyclic array.
        
    Returns:
        n×n matrix over GF(2), or raises ValueError if rule is not additive.
    """
    coeffs = compute_anf(rule_number)
    if anf_degree(coeffs) > 1:
        raise ValueError(f"Rule {rule_number} is not additive (degree {anf_degree(coeffs)})")
    
    # coeffs: c0 + c1*a + c2*b + c3*c
    # For additive rule: g(a,b,c) = c1*a + c2*b + c3*c (c0 must be 0 for linearity)
    alpha, beta, gamma = coeffs[1], coeffs[2], coeffs[3]
    
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        M[i][(i - 1) % n] = alpha
        M[i][i] = beta
        M[i][(i + 1) % n] = gf2_add(M[i][(i + 1) % n], gamma)
    
    return M


def fixed_point_dim_linear(rule_number: int, n: int) -> int:
    """
    Compute fixed-point variety dimension for an additive rule using
    the rank-nullity theorem: dim(ker(M-I)) = n - rank(M-I).
    
    Args:
        rule_number: Integer 0-255.
        n: Length of cyclic array.
        
    Returns:
        Dimension of the fixed-point variety.
    """
    M = build_update_matrix(rule_number, n)
    # Compute M - I
    MI = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            MI[i][j] = gf2_add(M[i][j], 1 if i == j else 0)
    return gf2_matrix_kernel_dim(MI, n)


# Wolfram complexity classification (approximate, based on common literature)
WOLFRAM_CLASS: Dict[int, int] = {}
# Class 1: evolves to uniform state
CLASS_1 = [0, 8, 32, 40, 64, 96, 128, 136, 160, 168, 192, 224, 234, 235, 238, 239, 248, 249, 252, 253, 254, 255]
# Class 2: evolves to periodic structures
CLASS_2 = [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 19, 23, 24, 25, 26, 27, 28, 29, 33, 34, 35, 36, 37, 38, 42, 43, 44, 46, 50, 51, 56, 57, 58, 62, 72, 73, 74, 76, 77, 78, 94, 104, 108, 130, 132, 134, 138, 140, 142, 152, 154, 156, 162, 164, 170, 172, 174, 178, 184, 200, 204, 232]
# Class 3: chaotic/random-looking behavior
CLASS_3 = [18, 22, 30, 45, 60, 90, 105, 122, 126, 146, 150, 161]
# Class 4: complex localized structures (edge of chaos)
CLASS_4 = [41, 54, 106, 110]

for r in CLASS_1: WOLFRAM_CLASS[r] = 1
for r in CLASS_2: WOLFRAM_CLASS[r] = 2
for r in CLASS_3: WOLFRAM_CLASS[r] = 3
for r in CLASS_4: WOLFRAM_CLASS[r] = 4


if __name__ == "__main__":
    print("=== Algebraic Normal Forms of Notable Rules ===")
    for rule_num in [0, 90, 110, 150, 204, 255]:
        coeffs = compute_anf(rule_num)
        print(f"Rule {rule_num:3d}: {anf_to_string(coeffs):20s} (degree {anf_degree(coeffs)}, "
              f"additive={is_additive(rule_num)})")
    
    print("\n=== Fixed Points (n=6) ===")
    for rule_num in [0, 90, 110, 150, 204]:
        fps = find_fixed_points(rule_num, 6)
        print(f"Rule {rule_num:3d}: {len(fps)} fixed points")
    
    print("\n=== Fixed-Point Dimensions for Additive Rules (n=3..12) ===")
    for rule_num in [90, 150]:
        dims = []
        for n in range(3, 13):
            dims.append(fixed_point_dim_linear(rule_num, n))
        print(f"Rule {rule_num}: {dims}")
