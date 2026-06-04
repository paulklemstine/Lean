#!/usr/bin/env python3
"""
Tropical Linear Programming: Algorithms
========================================
Type-hinted implementations of tropical LP algorithms.
"""

from typing import Tuple, List, Optional
import numpy as np
from numpy.typing import NDArray


# Type aliases
Vector = NDArray[np.float64]
Matrix = NDArray[np.float64]


def maxplus_add(a: float, b: float) -> float:
    """Max-plus addition: a ⊕ b = max(a, b)."""
    return max(a, b)


def maxplus_mul(a: float, b: float) -> float:
    """Max-plus multiplication: a ⊗ b = a + b."""
    return a + b


def maxplus_dot(c: Vector, x: Vector) -> float:
    """Max-plus inner product: c^T ⊗ x = max_j(c_j + x_j)."""
    return float(np.max(c + x))


def maxplus_matvec(A: Matrix, x: Vector) -> Vector:
    """Max-plus matrix-vector product: (A ⊗ x)_i = max_j(a_{ij} + x_j)."""
    m, n = A.shape
    result = np.empty(m)
    for i in range(m):
        result[i] = np.max(A[i, :] + x)
    return result


def residuate(A: Matrix, b: Vector) -> Vector:
    """
    Residuation: (b ⊘ A)_j = min_i(b_i - a_{ij}).

    This is the right adjoint of max-plus matrix multiplication:
      A ⊗ x ≤ b  ⟺  x ≤ b ⊘ A  (componentwise)

    Complexity: O(mn) — strongly polynomial.
    """
    m, n = A.shape
    result = np.empty(n)
    for j in range(n):
        result[j] = np.min(b - A[:, j])
    return result


def solve_tropical_lp(
    A: Matrix, b: Vector, c: Vector
) -> Tuple[Vector, float, Vector]:
    """
    Solve a tropical LP in closed form via residuation.

    Problem:  maximize  max_j(c_j + x_j)
              subject to  max_j(a_{ij} + x_j) ≤ b_i  for all i

    Returns:
        x_star: Optimal solution (the residuated solution)
        obj: Optimal objective value
        slack: Constraint slack (b - A⊗x*)

    Complexity: O(mn) — strongly polynomial.
    This is in stark contrast to classical LP which requires
    polynomial but not strongly polynomial time in general.
    """
    x_star = residuate(A, b)
    obj = maxplus_dot(c, x_star)
    Ax = maxplus_matvec(A, x_star)
    slack = b - Ax
    return x_star, obj, slack


def tropical_dual_bound(A: Matrix, b: Vector, c: Vector) -> float:
    """
    Compute the minimax dual bound:
      min_i(b_i + max_j(c_j - a_{ij}))

    This is always ≥ the primal optimal (weak duality).
    """
    m, n = A.shape
    bounds = np.empty(m)
    for i in range(m):
        bounds[i] = b[i] + np.max(c - A[i, :])
    return float(np.min(bounds))


def find_witness_pair(
    A: Matrix, b: Vector, c: Vector
) -> Tuple[int, int, float]:
    """
    Find the witness pair (j*, i*) such that:
      optimal = c_{j*} + b_{i*} - a_{i*,j*}

    The existence of this pair is guaranteed by the
    tropical_witness_pair theorem.
    """
    x_star = residuate(A, b)
    j_star = int(np.argmax(c + x_star))
    i_star = int(np.argmin(b - A[:, j_star]))
    witness_value = c[j_star] + b[i_star] - A[i_star, j_star]
    return j_star, i_star, witness_value


def tropical_sensitivity(
    A: Matrix, b: Vector, c: Vector, i0: int, delta: float
) -> Tuple[float, float]:
    """
    Sensitivity analysis: how does the optimum change when b_{i0} → b_{i0} + δ?

    By the translation property, shifting ALL of b by s shifts the optimum by s.
    But shifting a single b_i has a more nuanced effect bounded by max(δ, 0).

    Returns:
        original_opt: Original optimal value
        perturbed_opt: Perturbed optimal value
    """
    _, orig_obj, _ = solve_tropical_lp(A, b, c)
    b_new = b.copy()
    b_new[i0] += delta
    _, new_obj, _ = solve_tropical_lp(A, b_new, c)
    return orig_obj, new_obj


def log_transform_to_tropical(
    A_classical: Matrix, b_classical: Vector, c_classical: Vector
) -> Tuple[Matrix, Vector, Vector]:
    """
    Transform a classical LP with positive data to tropical form via logarithm.

    Classical: maximize c^T x subject to Ax ≤ b (with A, b, c, x > 0)
    Tropical:  maximize max_j(log(c_j) + x_j) subject to max_j(log(a_{ij}) + x_j) ≤ log(b_i)

    The classical optimal x corresponds to exp(x*_tropical).
    """
    assert np.all(A_classical > 0), "Classical matrix must be positive"
    assert np.all(b_classical > 0), "Classical RHS must be positive"
    assert np.all(c_classical > 0), "Classical objective must be positive"

    return np.log(A_classical), np.log(b_classical), np.log(c_classical)


def tropical_simplex_path(
    A: Matrix, b: Vector, c: Vector
) -> List[Tuple[int, int]]:
    """
    Compute the 'tropical simplex path': the sequence of (j, i) pairs
    that contribute to building the optimal solution.

    Unlike classical simplex which may take exponentially many steps,
    the tropical simplex visits at most n vertices (one per variable),
    each requiring O(m) work — total O(mn), strongly polynomial.
    """
    m, n = A.shape
    path: List[Tuple[int, int]] = []

    x_star = residuate(A, b)
    contributions = c + x_star
    order = np.argsort(-contributions)  # Process variables by contribution

    for j in order:
        i_binding = int(np.argmin(b - A[:, j]))
        path.append((int(j), i_binding))

    return path


if __name__ == "__main__":
    # Quick test
    A = np.array([[1.0, 2.0], [3.0, 1.0]])
    b = np.array([5.0, 7.0])
    c = np.array([2.0, 1.0])

    x, obj, slack = solve_tropical_lp(A, b, c)
    print(f"Solution: {x}")
    print(f"Objective: {obj}")
    print(f"Slack: {slack}")
    print(f"Dual bound: {tropical_dual_bound(A, b, c)}")
    print(f"Witness: {find_witness_pair(A, b, c)}")
    print(f"Simplex path: {tropical_simplex_path(A, b, c)}")
