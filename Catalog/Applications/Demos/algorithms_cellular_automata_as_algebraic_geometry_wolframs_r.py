"""
Cellular Automata as Algebraic Geometry over GF(2)
===================================================
Type-hinted implementations of ECA analysis algorithms.
"""

from typing import List, Tuple, Dict, Set, Optional
import numpy as np


def gf2_add(a: int, b: int) -> int:
    """Addition in GF(2) = XOR."""
    return a ^ b


def gf2_mul(a: int, b: int) -> int:
    """Multiplication in GF(2) = AND."""
    return a & b


def eca_local_rule(rule_number: int, a: int, b: int, c: int) -> int:
    """
    Extract the local rule output for an elementary cellular automaton.

    Given rule number r and 3-bit input (a, b, c), returns the output bit.
    The rule number encodes the truth table: bit (4a + 2b + c) of r.

    Args:
        rule_number: Rule number 0-255
        a: Left neighbor (0 or 1)
        b: Center cell (0 or 1)
        c: Right neighbor (0 or 1)

    Returns:
        Output bit (0 or 1)
    """
    idx = 4 * a + 2 * b + c
    return (rule_number >> idx) & 1


def eca_update(rule_number: int, state: List[int]) -> List[int]:
    """
    Apply one step of an ECA with cyclic boundary conditions.

    Args:
        rule_number: Rule number 0-255
        state: Current state as list of 0s and 1s

    Returns:
        Updated state
    """
    n = len(state)
    return [
        eca_local_rule(rule_number, state[(i - 1) % n], state[i], state[(i + 1) % n])
        for i in range(n)
    ]


def find_fixed_points(rule_number: int, n: int) -> List[Tuple[int, ...]]:
    """
    Find all fixed points of an ECA rule on n cells by exhaustive search.

    Args:
        rule_number: Rule number 0-255
        n: Number of cells

    Returns:
        List of fixed-point states (as tuples of 0s and 1s)
    """
    fixed = []
    for state_int in range(2**n):
        state = [(state_int >> i) & 1 for i in range(n)]
        updated = eca_update(rule_number, state)
        if state == updated:
            fixed.append(tuple(state))
    return fixed


def fixed_point_dimension(rule_number: int, n: int) -> float:
    """
    Compute the fixed-point dimension = log2(|Fix(f)|).

    For linear rules, this is always an integer (the solution space is a
    GF(2)-vector space). For nonlinear rules, it may be non-integer.

    Args:
        rule_number: Rule number 0-255
        n: Number of cells

    Returns:
        log2 of the number of fixed points, or -inf if no fixed points
    """
    count = len(find_fixed_points(rule_number, n))
    if count == 0:
        return float('-inf')
    return np.log2(count)


def zhegalkin_coefficients(rule_number: int) -> Dict[str, int]:
    """
    Compute the Zhegalkin (multilinear polynomial) coefficients of an ECA rule.

    Every function GF(2)^3 -> GF(2) has a unique representation as:
      g(a,b,c) = c0 + c1*a + c2*b + c3*c + c4*a*b + c5*a*c + c6*b*c + c7*a*b*c

    Uses Möbius inversion over the Boolean lattice.

    Args:
        rule_number: Rule number 0-255

    Returns:
        Dictionary mapping monomial names to GF(2) coefficients
    """
    g = lambda a, b, c: eca_local_rule(rule_number, a, b, c)

    c0 = g(0, 0, 0)
    c1 = (g(1, 0, 0) + g(0, 0, 0)) % 2
    c2 = (g(0, 1, 0) + g(0, 0, 0)) % 2
    c3 = (g(0, 0, 1) + g(0, 0, 0)) % 2
    c4 = (g(1, 1, 0) + g(1, 0, 0) + g(0, 1, 0) + g(0, 0, 0)) % 2
    c5 = (g(1, 0, 1) + g(1, 0, 0) + g(0, 0, 1) + g(0, 0, 0)) % 2
    c6 = (g(0, 1, 1) + g(0, 1, 0) + g(0, 0, 1) + g(0, 0, 0)) % 2
    c7 = (g(1, 1, 1) + g(1, 1, 0) + g(1, 0, 1) + g(0, 1, 1)
          + g(1, 0, 0) + g(0, 1, 0) + g(0, 0, 1) + g(0, 0, 0)) % 2

    return {
        '1': c0, 'a': c1, 'b': c2, 'c': c3,
        'ab': c4, 'ac': c5, 'bc': c6, 'abc': c7
    }


def polynomial_degree(rule_number: int) -> int:
    """
    Compute the degree of the Zhegalkin polynomial for an ECA rule.

    The degree measures the algebraic complexity of the rule:
    - Degree 0: constant rule (rules 0 and 255)
    - Degree 1: linear/affine rule (e.g., rule 150 = XOR)
    - Degree 2: quadratic rule
    - Degree 3: cubic rule (maximally nonlinear)

    Args:
        rule_number: Rule number 0-255

    Returns:
        Polynomial degree (0-3)
    """
    coeffs = zhegalkin_coefficients(rule_number)
    if coeffs['abc']:
        return 3
    if coeffs['ab'] or coeffs['ac'] or coeffs['bc']:
        return 2
    if coeffs['a'] or coeffs['b'] or coeffs['c']:
        return 1
    return 0


def is_linear_rule(rule_number: int) -> bool:
    """Check if an ECA rule is linear (additive) over GF(2)."""
    coeffs = zhegalkin_coefficients(rule_number)
    return coeffs['1'] == 0 and coeffs['ab'] == 0 and coeffs['ac'] == 0 \
        and coeffs['bc'] == 0 and coeffs['abc'] == 0


def is_affine_rule(rule_number: int) -> bool:
    """Check if an ECA rule is affine over GF(2) (linear + constant)."""
    coeffs = zhegalkin_coefficients(rule_number)
    return coeffs['ab'] == 0 and coeffs['ac'] == 0 \
        and coeffs['bc'] == 0 and coeffs['abc'] == 0


def fixed_point_matrix(rule_number: int, n: int) -> np.ndarray:
    """
    Construct the matrix M such that Fix(f) = ker(M) for affine rules.

    For an affine rule g(a,b,c) = c0 + c1*a + c2*b + c3*c, the fixed-point
    equation g(s_{i-1}, s_i, s_{i+1}) = s_i becomes:
      c1*s_{i-1} + (c2-1)*s_i + c3*s_{i+1} = -c0   (mod 2)

    This is a circulant linear system over GF(2).

    Args:
        rule_number: Rule number 0-255
        n: Number of cells

    Returns:
        n×n matrix over GF(2) (as numpy array of ints mod 2)
    """
    coeffs = zhegalkin_coefficients(rule_number)
    c1, c2, c3 = coeffs['a'], coeffs['b'], coeffs['c']

    M = np.zeros((n, n), dtype=int)
    for i in range(n):
        M[i, (i - 1) % n] = c1
        M[i, i] = (c2 + 1) % 2  # c2 - 1 = c2 + 1 mod 2
        M[i, (i + 1) % n] = (M[i, (i + 1) % n] + c3) % 2
    return M % 2


def gf2_rank(matrix: np.ndarray) -> int:
    """
    Compute the rank of a matrix over GF(2) using Gaussian elimination.

    Args:
        matrix: numpy array of 0s and 1s

    Returns:
        Rank over GF(2)
    """
    M = matrix.copy() % 2
    rows, cols = M.shape
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if M[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        M[[rank, pivot]] = M[[pivot, rank]]
        # Eliminate
        for row in range(rows):
            if row != rank and M[row, col] == 1:
                M[row] = (M[row] + M[rank]) % 2
        rank += 1
    return rank


def analyze_all_rules(n: int) -> Dict[int, Dict]:
    """
    Analyze all 256 ECA rules for fixed-point properties on n cells.

    Returns a dictionary mapping rule numbers to their analysis:
    - fixed_point_count: number of fixed points
    - fixed_point_dim: log2 of fixed point count
    - polynomial_degree: degree of Zhegalkin polynomial
    - is_linear: whether the rule is linear
    - zhegalkin: polynomial coefficients

    Args:
        n: Number of cells

    Returns:
        Dictionary of analyses indexed by rule number
    """
    results = {}
    for r in range(256):
        fps = find_fixed_points(r, n)
        count = len(fps)
        dim = np.log2(count) if count > 0 else -1

        results[r] = {
            'fixed_point_count': count,
            'fixed_point_dim': dim,
            'polynomial_degree': polynomial_degree(r),
            'is_linear': is_linear_rule(r),
            'is_affine': is_affine_rule(r),
            'zhegalkin': zhegalkin_coefficients(r),
        }
    return results


def wolfram_class_heuristic(rule_number: int, n: int = 20, steps: int = 100) -> int:
    """
    Heuristic classification of an ECA rule into Wolfram's 4 classes.

    Uses entropy and pattern analysis of the spacetime evolution.
    Classes: 1 (uniform), 2 (periodic), 3 (chaotic), 4 (complex).

    This is approximate — Wolfram's classification is not rigorously defined.

    Args:
        rule_number: Rule number 0-255
        n: Number of cells
        steps: Number of time steps

    Returns:
        Estimated Wolfram class (1-4)
    """
    # Run from random initial condition
    np.random.seed(42)
    state = list(np.random.randint(0, 2, n))

    history = [state[:]]
    for _ in range(steps):
        state = eca_update(rule_number, state)
        history.append(state[:])

    # Check if converged to fixed point (Class 1)
    if history[-1] == history[-2]:
        return 1

    # Check for short period (Class 2)
    for period in range(1, min(20, steps)):
        if history[-1] == history[-1 - period]:
            return 2

    # Compute column entropy to distinguish Class 3 vs 4
    arr = np.array(history[steps//2:])
    col_entropies = []
    for j in range(n):
        p1 = arr[:, j].mean()
        if p1 == 0 or p1 == 1:
            col_entropies.append(0)
        else:
            col_entropies.append(-p1 * np.log2(p1) - (1-p1) * np.log2(1-p1))

    avg_entropy = np.mean(col_entropies)
    # Class 4 has intermediate entropy; Class 3 has high entropy
    if avg_entropy > 0.9:
        return 3
    elif avg_entropy > 0.3:
        return 4
    else:
        return 2


def complement_rule(rule_number: int) -> int:
    """
    Compute the complement of an ECA rule.

    The complement maps input (a,b,c) to 1 + g(1+a, 1+b, 1+c) mod 2.
    This corresponds to flipping all input and output bits.

    Args:
        rule_number: Rule number 0-255

    Returns:
        Complement rule number
    """
    result = 0
    for idx in range(8):
        a, b, c = (idx >> 2) & 1, (idx >> 1) & 1, idx & 1
        # Complement inputs
        a_c, b_c, c_c = 1 - a, 1 - b, 1 - c
        comp_idx = 4 * a_c + 2 * b_c + c_c
        # Complement output
        orig_out = (rule_number >> comp_idx) & 1
        new_out = 1 - orig_out
        result |= (new_out << idx)
    return result


if __name__ == '__main__':
    # Quick demonstration
    print("=== ECA Algebraic Geometry Analysis ===\n")

    # Zhegalkin polynomials for key rules
    for r in [0, 90, 110, 150, 204, 255]:
        coeffs = zhegalkin_coefficients(r)
        deg = polynomial_degree(r)
        terms = []
        names = {'1': '1', 'a': 'a', 'b': 'b', 'c': 'c',
                 'ab': 'ab', 'ac': 'ac', 'bc': 'bc', 'abc': 'abc'}
        for k, v in coeffs.items():
            if v:
                terms.append(names[k])
        poly = ' + '.join(terms) if terms else '0'
        print(f"Rule {r:3d}: g(a,b,c) = {poly}  (degree {deg})")

    print()

    # Fixed-point analysis for small n
    for n in [4, 6, 8]:
        print(f"--- n = {n} ---")
        for r in [0, 90, 150, 204, 255]:
            fps = find_fixed_points(r, n)
            dim = np.log2(len(fps)) if fps else -1
            print(f"  Rule {r:3d}: |Fix| = {len(fps):4d}, dim = {dim:.1f}")
        print()
