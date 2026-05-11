#!/usr/bin/env python3
"""
Algorithms for Ruelle Transfer Operator Computations

Implements the core algorithms from the research paper with full documentation,
type hints, and complexity analysis.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from fractions import Fraction


def build_correspondence_matrix(
    f: Callable[[int], int], d: int
) -> np.ndarray:
    """Build the deterministic correspondence matrix for f.

    Given a map f : {0, ..., d-1} → {0, ..., d-1}, constructs the d×d matrix M
    where M[i][j] = 1 if f(i) = j, else 0.

    Complexity: O(d) time, O(d²) space.

    Args:
        f: Transition function on {0, ..., d-1}
        d: State space size

    Returns:
        d×d numpy integer array (the correspondence matrix)
    """
    M = np.zeros((d, d), dtype=int)
    for i in range(d):
        j = f(i)
        assert 0 <= j < d, f"f({i}) = {j} out of range [0, {d})"
        M[i, j] = 1
    return M


def periodic_count_via_trace(
    f: Callable[[int], int], d: int, n: int
) -> int:
    """Count periodic points of period n using the trace formula.

    Computes |Fix(f^n)| = tr(M^n) where M is the correspondence matrix.

    Complexity: O(d³ log n) time (matrix exponentiation by squaring), O(d²) space.

    Args:
        f: Transition function
        d: State space size
        n: Period

    Returns:
        Number of periodic points of period n
    """
    M = build_correspondence_matrix(f, d)
    Mn = matrix_power(M, n)
    return int(np.trace(Mn))


def periodic_count_naive(
    f: Callable[[int], int], d: int, n: int
) -> int:
    """Count periodic points naively by iterating f.

    Complexity: O(d · n) time, O(1) extra space.

    Args:
        f: Transition function
        d: State space size
        n: Period

    Returns:
        Number of periodic points of period n
    """
    count = 0
    for x in range(d):
        y = x
        for _ in range(n):
            y = f(y)
        if y == x:
            count += 1
    return count


def matrix_power(M: np.ndarray, n: int) -> np.ndarray:
    """Compute M^n by repeated squaring.

    Complexity: O(d³ log n) where d is the matrix dimension.

    Args:
        M: Square matrix
        n: Non-negative integer exponent

    Returns:
        M^n
    """
    if n == 0:
        return np.eye(M.shape[0], dtype=M.dtype)
    if n == 1:
        return M.copy()
    if n % 2 == 0:
        half = matrix_power(M, n // 2)
        return half @ half
    else:
        return M @ matrix_power(M, n - 1)


def row_sum_norm(M: np.ndarray) -> float:
    """Compute the row-sum (infinity) operator norm.

    rowSumNorm(M) = max_i sum_j |M_ij|

    Complexity: O(d²) time.

    Args:
        M: Square matrix

    Returns:
        The row-sum norm
    """
    return float(np.max(np.sum(np.abs(M), axis=1)))


def sup_norm(v: np.ndarray) -> float:
    """Compute the sup (infinity) norm of a vector.

    supNorm(v) = max_i |v_i|

    Complexity: O(d) time.

    Args:
        v: Vector

    Returns:
        The sup norm
    """
    return float(np.max(np.abs(v)))


def trace_growth_bound(M: np.ndarray, n: int) -> float:
    """Compute the certified upper bound on |tr(M^n)|.

    Returns d · rowSumNorm(M)^n, which is guaranteed to satisfy
    |tr(M^n)| ≤ d · rowSumNorm(M)^n.

    Complexity: O(d² + log n) time.

    Args:
        M: d×d matrix
        n: Exponent

    Returns:
        Upper bound on |tr(M^n)|
    """
    d = M.shape[0]
    rsn = row_sum_norm(M)
    return d * rsn ** n


def artin_mazur_coefficients(
    f: Callable[[int], int], d: int, num_terms: int
) -> List[Fraction]:
    """Compute Artin-Mazur zeta coefficients.

    artinMazurCoeff(f, n) = periodicCount(f, n+1) / (n+1)

    Complexity: O(num_terms · d³ · log(num_terms)) total.

    Args:
        f: Transition function
        d: State space size
        num_terms: Number of coefficients to compute

    Returns:
        List of Artin-Mazur coefficients as exact fractions
    """
    M = build_correspondence_matrix(f, d)
    coeffs = []
    for n in range(num_terms):
        Mn1 = matrix_power(M, n + 1)
        tr = int(np.trace(Mn1))
        coeffs.append(Fraction(tr, n + 1))
    return coeffs


def weighted_loop_sums(
    weight_matrix: np.ndarray, max_n: int
) -> List[float]:
    """Compute weighted loop sums for n = 0, 1, ..., max_n.

    weightedLoopSum(K, n) = tr(M^n) where M is the correspondence matrix.

    Complexity: O(max_n · d³) total (sequential powers).

    Args:
        weight_matrix: d×d weight matrix (entry (i,j) = weight from j to i)
        max_n: Maximum power to compute

    Returns:
        List of weighted loop sums
    """
    d = weight_matrix.shape[0]
    sums = []
    current = np.eye(d)
    for n in range(max_n + 1):
        sums.append(float(np.trace(current)))
        current = current @ weight_matrix
    return sums


def transfer_lipschitz_certificate(
    M: np.ndarray, v: np.ndarray
) -> Tuple[float, float, bool]:
    """Verify the Lipschitz bound ‖Mv‖∞ ≤ ‖M‖∞ · ‖v‖∞.

    Args:
        M: Transfer matrix
        v: Input vector

    Returns:
        Tuple of (‖Mv‖∞, ‖M‖∞ · ‖v‖∞, bound_holds)
    """
    Mv = M @ v
    lhs = sup_norm(Mv)
    rhs = row_sum_norm(M) * sup_norm(v)
    return (lhs, rhs, lhs <= rhs + 1e-12)


def matrix_mul_complexity_bound(d: int, n: int) -> int:
    """Compute the O(n·d³) complexity bound for n matrix multiplications.

    Args:
        d: Matrix dimension
        n: Number of multiplications

    Returns:
        Upper bound on operation count
    """
    return n * d ** 3


# Example usage
if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 40)

    # Example: cyclic shift on 5 elements
    d = 5
    f = lambda x: (x + 1) % d
    M = build_correspondence_matrix(f, d)

    print(f"\n1. Correspondence Matrix for f(x) = (x+1) mod {d}:")
    print(M)

    print(f"\n2. Periodic counts (trace method vs naive):")
    for n in range(1, 11):
        trace_count = periodic_count_via_trace(f, d, n)
        naive_count = periodic_count_naive(f, d, n)
        print(f"  n={n}: trace={trace_count}, naive={naive_count}, match={trace_count == naive_count}")

    print(f"\n3. Artin-Mazur coefficients:")
    coeffs = artin_mazur_coefficients(f, d, 10)
    for i, c in enumerate(coeffs):
        print(f"  a_{i} = {c} = {float(c):.6f}")

    print(f"\n4. Complexity bound for 100 multiplications of {d}×{d} matrices:")
    print(f"  {matrix_mul_complexity_bound(d, 100)} operations")


#!/usr/bin/env python3
"""
Applications of Ruelle Transfer Operator Semantics

Demonstrates real-world applications of the certified transfer operator framework
in cryptography, machine learning robustness, and statistical mechanics.
"""

import numpy as np
from typing import List, Tuple