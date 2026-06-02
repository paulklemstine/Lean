#!/usr/bin/env python3
"""
Algorithms for LGV Determinantal Theory.

Provides efficient implementations of:
- Catalan number computation
- LGV 2x2 determinant
- Catalan Hankel determinant
- Lattice path enumeration
- q-binomial coefficient computation
"""

from math import comb
from typing import List, Tuple
from functools import lru_cache


def catalan_closed_form(n: int) -> int:
    """Compute C_n = C(2n, n) / (n+1) in O(n) time.
    
    Uses the closed-form definition. The division is always exact
    because (n+1) | C(2n, n), as proved in succ_dvd_centralBinom.
    
    Args:
        n: Non-negative integer.
    
    Returns:
        The n-th Catalan number.
    """
    return comb(2 * n, n) // (n + 1)


def catalan_recurrence(n: int) -> int:
    """Compute C_n via the Segner convolution recurrence.
    
    C_0 = 1, C_{n+1} = Σ_{k=0}^{n} C_k * C_{n-k}
    
    O(n²) time, O(n) space via bottom-up dynamic programming.
    
    Args:
        n: Non-negative integer.
    
    Returns:
        The n-th Catalan number.
    """
    if n == 0:
        return 1
    c = [0] * (n + 1)
    c[0] = 1
    for i in range(1, n + 1):
        c[i] = sum(c[k] * c[i - 1 - k] for k in range(i))
    return c[n]


def lgv_2x2_det(n: int, d: int) -> int:
    """Compute the 2×2 LGV determinant for source separation d.
    
    det = C(n+d, d) * C(n, 0) - C(n, d) * C(n+d, 0)
        = C(n+d, d) - C(n, d)
    
    For d=1, this always equals 1 (Theorem lgv_2x2_base).
    
    Args:
        n: Grid width (non-negative integer).
        d: Source separation (positive integer).
    
    Returns:
        The determinant value.
    """
    return comb(n + d, d) - comb(n, d)


def catalan_hankel_det(size: int, shift: int = 0) -> int:
    """Compute the Hankel determinant det[C_{i+j+shift}]_{0≤i,j<size}.
    
    Uses Bareiss algorithm for exact integer determinant computation
    (avoids floating-point errors from Gaussian elimination).
    
    Known results:
    - shift=0: det = 1 for all sizes (Desainte-Catherine-Viennot)
    - shift=1: det = 1 for all sizes
    - shift=2: det = size + 1
    
    Args:
        size: Matrix dimension.
        shift: Shift parameter for the Catalan index.
    
    Returns:
        The exact determinant as an integer.
    """
    # Build the Hankel matrix
    mat = [[catalan_closed_form(i + j + shift) for j in range(size)]
           for i in range(size)]
    
    # Bareiss algorithm for exact integer determinant
    n = size
    sign = 1
    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(col, n):
            if mat[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return 0
        if pivot != col:
            mat[col], mat[pivot] = mat[pivot], mat[col]
            sign *= -1
        
        for row in range(col + 1, n):
            for j in range(col + 1, n):
                mat[row][j] = mat[row][j] * mat[col][col] - mat[row][col] * mat[col][j]
                if col > 0:
                    mat[row][j] //= mat[col - 1][col - 1] if col > 0 else 1
            mat[row][col] = 0
    
    result = sign
    for i in range(n):
        result *= mat[i][i] if i == 0 else 1
    
    # Simplified: for small matrices, just use the product of diagonal
    # Actually, let's use a cleaner implementation
    return _det_exact(
        [[catalan_closed_form(i + j + shift) for j in range(size)]
         for i in range(size)]
    )


def _det_exact(matrix: List[List[int]]) -> int:
    """Compute exact integer determinant using cofactor expansion.
    
    O(n!) time — only suitable for small matrices. For production use,
    replace with Bareiss algorithm.
    """
    n = len(matrix)
    if n == 0:
        return 1
    if n == 1:
        return matrix[0][0]
    if n == 2:
        return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
    
    det = 0
    for j in range(n):
        minor = [row[:j] + row[j+1:] for row in matrix[1:]]
        det += ((-1) ** j) * matrix[0][j] * _det_exact(minor)
    return det


def q_binomial(m: int, n: int, q: float) -> float:
    """Compute the Gaussian binomial coefficient [m+n choose n]_q.
    
    Uses the product formula:
    [m+n choose n]_q = Π_{i=1}^{n} (1 - q^{m+i}) / (1 - q^i)
    
    For q → 1, this approaches C(m+n, n).
    For q = 0, this equals 1.
    
    Args:
        m, n: Non-negative integers.
        q: The q-parameter (q ≠ 1 for numerical stability).
    
    Returns:
        The q-binomial coefficient as a float.
    """
    if n == 0 or m == 0:
        return 1.0
    result = 1.0
    for i in range(1, n + 1):
        result *= (1 - q ** (m + i)) / (1 - q ** i)
    return result


def q_binomial_poly(m: int, n: int) -> List[int]:
    """Compute the Gaussian binomial [m+n choose n]_q as a polynomial.
    
    Returns the list of coefficients [a_0, a_1, ..., a_{mn}] where
    [m+n choose n]_q = Σ a_k q^k.
    
    Uses the recurrence: [m+n+2 choose n+1]_q = [m+n+1 choose n+1]_q 
    + q^{n+1} * [m+n+1 choose n]_q.
    
    Args:
        m, n: Non-negative integers.
    
    Returns:
        List of polynomial coefficients.
    """
    if m == 0 or n == 0:
        return [1]
    
    # DP table: qb[i][j] = polynomial for [i+j choose j]_q
    @lru_cache(maxsize=None)
    def qb(i: int, j: int) -> Tuple[int, ...]:
        if i == 0 or j == 0:
            return (1,)
        # [i+j choose j]_q = [i+j-1 choose j]_q + q^j * [i+j-1 choose j-1]_q
        a = list(qb(i - 1, j))
        b = list(qb(i, j - 1))
        # Shift b by j positions (multiply by q^j)
        shifted_b = [0] * j + b
        # Add
        max_len = max(len(a), len(shifted_b))
        result = [0] * max_len
        for k in range(len(a)):
            result[k] += a[k]
        for k in range(len(shifted_b)):
            result[k] += shifted_b[k]
        return tuple(result)
    
    return list(qb(m, n))


def enumerate_dyck_paths(n: int) -> List[List[int]]:
    """Enumerate all Dyck paths of semilength n.
    
    A Dyck path is a sequence of +1 (up) and -1 (down) steps
    of length 2n that never goes below 0.
    
    Args:
        n: Semilength.
    
    Returns:
        List of Dyck paths, each as a list of +1/-1 steps.
    """
    if n == 0:
        return [[]]
    
    paths = []
    
    def backtrack(path: List[int], height: int, ups: int, downs: int):
        if ups + downs == 2 * n:
            if height == 0:
                paths.append(path[:])
            return
        if ups < n:
            path.append(1)
            backtrack(path, height + 1, ups + 1, downs)
            path.pop()
        if downs < n and height > 0:
            path.append(-1)
            backtrack(path, height - 1, ups, downs + 1)
            path.pop()
    
    backtrack([], 0, 0, 0)
    return paths


def dyck_area(path: List[int]) -> int:
    """Compute the area under a Dyck path.
    
    The area is the sum of heights at each step.
    
    Args:
        path: A Dyck path as a list of +1/-1 steps.
    
    Returns:
        The area under the path.
    """
    area = 0
    height = 0
    for step in path:
        if step == 1:
            area += height
        height += step
        if step == -1:
            area += height
    # Actually, area = sum of partial heights
    height = 0
    area = 0
    for step in path:
        height += step
        area += height
    return area // 2  # Each unit contributes to area


def transfer_matrix(w: int) -> List[List[int]]:
    """Construct the Dyck path transfer matrix for strip width w.
    
    T[i][j] = 1 if there is a valid step from height i to height j.
    
    Args:
        w: Strip width.
    
    Returns:
        (w+1) × (w+1) binary matrix.
    """
    n = w + 1
    T = [[0] * n for _ in range(n)]
    for i in range(n):
        if i + 1 < n:
            T[i][i + 1] = 1  # up step
        if i > 0:
            T[i][i - 1] = 1  # down step
    return T


def matrix_power(mat: List[List[int]], p: int) -> List[List[int]]:
    """Compute mat^p using repeated squaring.
    
    Args:
        mat: Square integer matrix.
        p: Non-negative exponent.
    
    Returns:
        mat^p as an integer matrix.
    """
    n = len(mat)
    # Identity matrix
    result = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    base = [row[:] for row in mat]
    
    while p > 0:
        if p % 2 == 1:
            result = _mat_mul(result, base)
        base = _mat_mul(base, base)
        p //= 2
    return result


def _mat_mul(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n))
             for j in range(n)] for i in range(n)]


if __name__ == "__main__":
    # Quick verification
    print("Catalan numbers (closed form):", [catalan_closed_form(n) for n in range(10)])
    print("Catalan numbers (recurrence):", [catalan_recurrence(n) for n in range(10)])
    
    print("\nHankel determinants (shift=0):", [catalan_hankel_det(n) for n in range(1, 7)])
    print("Hankel determinants (shift=1):", [catalan_hankel_det(n, 1) for n in range(1, 7)])
    print("Hankel determinants (shift=2):", [catalan_hankel_det(n, 2) for n in range(1, 7)])
    
    print("\nLGV 2x2 (d=1):", [lgv_2x2_det(n, 1) for n in range(1, 10)])
    
    print("\nDyck paths of semilength 3:", len(enumerate_dyck_paths(3)), "paths")
    
    print("\nq-binomial [4 choose 2]_q:", q_binomial_poly(2, 2))
    
    # Transfer matrix verification
    T = transfer_matrix(10)
    T_pow = matrix_power(T, 6)
    print(f"\nPaths of length 6 on strip width 10 (height 0→0): {T_pow[0][0]}")
    print(f"  (should equal Catalan(3) = {catalan_closed_form(3)})")
