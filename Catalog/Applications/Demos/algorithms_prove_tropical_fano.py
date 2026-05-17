#!/usr/bin/env python3
"""
Tropical Fano Incidence Geometry — Algorithms

Implements the core algorithms from the tropical incidence rigidity theory:
1. Tropical defect computation
2. Incidence reconstruction from defect profiles
3. Fano axiom verification
4. Certified separation margin computation
"""

import numpy as np
from typing import List, Tuple, Optional
import itertools


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Defect Computation
# ──────────────────────────────────────────────────────────────────

def tropical_eval(line: np.ndarray, point: np.ndarray) -> np.ndarray:
    """
    Compute the tropical evaluation vector.

    In min-plus geometry, the evaluation of line ℓ at point p
    produces the vector (ℓ₀ + p₀, ℓ₁ + p₁, ℓ₂ + p₂).

    Parameters:
        line: array of shape (3,), tropical line coefficients
        point: array of shape (3,), tropical point coordinates

    Returns:
        array of shape (3,), coordinate-wise sums

    Time complexity: O(d) where d = dimension (3 here)
    Space complexity: O(d)
    """
    return line + point


def tropical_defect(line: np.ndarray, point: np.ndarray) -> float:
    """
    Compute the tropical defect of a line-point pair.

    The defect is the gap between the second-smallest and smallest
    values of the evaluation vector. Zero defect = incidence.

    Parameters:
        line: array of shape (3,)
        point: array of shape (3,)

    Returns:
        Non-negative float. Zero iff point is incident to line.

    Time complexity: O(d log d) for sorting; O(d) with selection
    Space complexity: O(d)
    """
    vals = np.sort(tropical_eval(line, point))
    return float(vals[1] - vals[0])


def tropical_defect_matrix(
    lines: List[np.ndarray],
    points: List[np.ndarray]
) -> np.ndarray:
    """
    Compute the full defect matrix D[i,j] = defect(lines[j], points[i]).

    Parameters:
        lines: list of L line arrays, each shape (3,)
        points: list of P point arrays, each shape (3,)

    Returns:
        array of shape (P, L)

    Time complexity: O(P * L * d)
    Space complexity: O(P * L)
    """
    P, L = len(points), len(lines)
    D = np.zeros((P, L))
    for i, p in enumerate(points):
        for j, l in enumerate(lines):
            D[i, j] = tropical_defect(l, p)
    return D


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Incidence Reconstruction
# ──────────────────────────────────────────────────────────────────

def reconstruct_incidence(
    defect_matrix: np.ndarray,
    tol: float = 1e-12
) -> np.ndarray:
    """
    Reconstruct incidence relation from a defect matrix.

    By the tropical rigidity theorem, the incidence relation is
    uniquely determined by the zero-pattern of the defect matrix:
        Inc(p, ℓ) ↔ D[p, ℓ] = 0

    Parameters:
        defect_matrix: array of shape (P, L), nonneg entries
        tol: tolerance for zero detection

    Returns:
        boolean array of shape (P, L)

    Time complexity: O(P * L)
    Space complexity: O(P * L)
    """
    return defect_matrix < tol


def certified_separation_margin(
    defect_matrix: np.ndarray,
    incidence: np.ndarray
) -> float:
    """
    Compute the certified separation margin γ.

    γ = min { D[p,ℓ] : ¬Inc(p,ℓ) }

    A positive margin guarantees that non-incidence is robust:
    small perturbations of coordinates cannot create false incidences.

    Parameters:
        defect_matrix: array of shape (P, L)
        incidence: boolean array of shape (P, L)

    Returns:
        The minimum defect among non-incident pairs

    Time complexity: O(P * L)
    """
    non_inc_defects = defect_matrix[~incidence]
    if len(non_inc_defects) == 0:
        return float('inf')
    return float(np.min(non_inc_defects))


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Fano Axiom Verification
# ──────────────────────────────────────────────────────────────────

def verify_fano_axioms(incidence: np.ndarray) -> dict:
    """
    Verify whether a boolean incidence matrix satisfies Fano axioms.

    Checks:
    1. 7 points, 7 lines
    2. 3 points per line
    3. 3 lines per point
    4. Unique line through any 2 distinct points
    5. Unique point on any 2 distinct lines

    Parameters:
        incidence: boolean array of shape (P, L)

    Returns:
        dict with keys:
          'valid': bool
          'n_points': int
          'n_lines': int
          'points_per_line': list[int]
          'lines_per_point': list[int]
          'two_point_axiom': bool
          'two_line_axiom': bool
          'violations': list[str]

    Time complexity: O(P² * L + P * L²)
    """
    P, L = incidence.shape
    result = {
        'n_points': P,
        'n_lines': L,
        'violations': []
    }

    # Axiom 1: cardinalities
    if P != 7:
        result['violations'].append(f"Expected 7 points, got {P}")
    if L != 7:
        result['violations'].append(f"Expected 7 lines, got {L}")

    # Axiom 2: points per line
    ppl = [int(incidence[:, j].sum()) for j in range(L)]
    result['points_per_line'] = ppl
    for j, count in enumerate(ppl):
        if count != 3:
            result['violations'].append(
                f"Line {j} has {count} points (expected 3)")

    # Axiom 3: lines per point
    lpp = [int(incidence[i, :].sum()) for i in range(P)]
    result['lines_per_point'] = lpp
    for i, count in enumerate(lpp):
        if count != 3:
            result['violations'].append(
                f"Point {i} has {count} lines (expected 3)")

    # Axiom 4: unique line through 2 points
    two_point_ok = True
    for p, q in itertools.combinations(range(P), 2):
        common_lines = [j for j in range(L)
                       if incidence[p, j] and incidence[q, j]]
        if len(common_lines) != 1:
            two_point_ok = False
            result['violations'].append(
                f"Points {p},{q} share {len(common_lines)} lines")
    result['two_point_axiom'] = two_point_ok

    # Axiom 5: unique point on 2 lines
    two_line_ok = True
    for l1, l2 in itertools.combinations(range(L), 2):
        common_points = [i for i in range(P)
                        if incidence[i, l1] and incidence[i, l2]]
        if len(common_points) != 1:
            two_line_ok = False
            result['violations'].append(
                f"Lines {l1},{l2} share {len(common_points)} points")
    result['two_line_axiom'] = two_line_ok

    result['valid'] = len(result['violations']) == 0
    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Rigidity Check
# ──────────────────────────────────────────────────────────────────

def check_rigidity(
    defect1: np.ndarray,
    defect2: np.ndarray,
    tol: float = 1e-12
) -> dict:
    """
    Check whether two defect matrices determine the same incidence.

    By the tropical rigidity theorem: if the defect profiles match,
    the incidence relations are identical.

    Parameters:
        defect1, defect2: arrays of shape (P, L)
        tol: tolerance for defect comparison

    Returns:
        dict with 'profiles_match', 'incidence_match', 'max_defect_diff'

    Time complexity: O(P * L)
    """
    profiles_match = np.allclose(defect1, defect2, atol=tol)
    inc1 = reconstruct_incidence(defect1, tol)
    inc2 = reconstruct_incidence(defect2, tol)
    incidence_match = np.array_equal(inc1, inc2)

    return {
        'profiles_match': bool(profiles_match),
        'incidence_match': bool(incidence_match),
        'max_defect_diff': float(np.max(np.abs(defect1 - defect2))),
        'rigidity_theorem_applies': profiles_match,
    }


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

def main():
    print("Tropical Fano Incidence — Algorithm Examples")
    print("=" * 50)

    # Classical Fano plane
    fano_lines = [
        {0, 1, 3}, {1, 2, 4}, {2, 3, 5},
        {3, 4, 6}, {4, 5, 0}, {5, 6, 1}, {6, 0, 2}
    ]

    Inc = np.zeros((7, 7), dtype=bool)
    for j, ls in enumerate(fano_lines):
        for i in ls:
            Inc[i, j] = True

    # Verify Fano axioms
    result = verify_fano_axioms(Inc)
    print(f"\nFano axiom verification: {'PASS' if result['valid'] else 'FAIL'}")
    print(f"  Points per line: {result['points_per_line']}")
    print(f"  Lines per point: {result['lines_per_point']}")
    print(f"  Two-point axiom: {result['two_point_axiom']}")
    print(f"  Two-line axiom: {result['two_line_axiom']}")

    # Create defect matrix (synthetic)
    margin = 5.0
    D = np.where(Inc, 0.0, margin)

    # Reconstruct incidence
    Inc_recovered = reconstruct_incidence(D)
    print(f"\nIncidence reconstruction: match = {np.array_equal(Inc, Inc_recovered)}")

    # Separation margin
    gamma = certified_separation_margin(D, Inc)
    print(f"Certified separation margin: γ = {gamma}")

    # Rigidity check
    D2 = D.copy()
    rig = check_rigidity(D, D2)
    print(f"\nRigidity check (identical profiles):")
    print(f"  Profiles match: {rig['profiles_match']}")
    print(f"  Incidence match: {rig['incidence_match']}")

    # Perturbed defect matrix
    D3 = D + np.random.randn(7, 7) * 0.1
    D3 = np.maximum(D3, 0)  # keep nonneg
    # Zero out incident entries
    D3[Inc] = 0.0
    rig2 = check_rigidity(D, D3)
    print(f"\nRigidity check (perturbed non-incident defects):")
    print(f"  Profiles match: {rig2['profiles_match']}")
    print(f"  Incidence match: {rig2['incidence_match']}")
    print(f"  Max defect diff: {rig2['max_defect_diff']:.4f}")


if __name__ == "__main__":
    main()
