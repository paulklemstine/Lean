"""
Algorithms for the Jacobian Conjecture: Drużkowski Maps, Keller Certification,
and Nilpotency Testing.

Implements computational methods for:
1. Constructing Drużkowski maps Φ(x) = x + (Ax)^[3]
2. Computing Jacobian matrices of polynomial maps
3. Certifying the Keller condition (det(JΦ) = constant)
4. Testing matrix nilpotency
5. Computing the Hessian nilpotency index

All algorithms work over exact arithmetic (rational numbers) to avoid
floating-point artifacts.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
from itertools import product
import copy


# Type aliases
Matrix = List[List[Fraction]]
Vector = List[Fraction]


def zero_matrix(n: int) -> Matrix:
    """Create an n×n zero matrix."""
    return [[Fraction(0)] * n for _ in range(n)]


def identity_matrix(n: int) -> Matrix:
    """Create an n×n identity matrix."""
    m = zero_matrix(n)
    for i in range(n):
        m[i][i] = Fraction(1)
    return m


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Multiply two matrices over Q."""
    n = len(A)
    C = zero_matrix(n)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    return C


def mat_add(A: Matrix, B: Matrix) -> Matrix:
    """Add two matrices."""
    n = len(A)
    return [[A[i][j] + B[i][j] for j in range(n)] for i in range(n)]


def mat_scale(c: Fraction, A: Matrix) -> Matrix:
    """Scale a matrix by a scalar."""
    n = len(A)
    return [[c * A[i][j] for j in range(n)] for i in range(n)]


def mat_pow(A: Matrix, k: int) -> Matrix:
    """Compute A^k by repeated squaring."""
    n = len(A)
    if k == 0:
        return identity_matrix(n)
    if k == 1:
        return [row[:] for row in A]
    if k % 2 == 0:
        half = mat_pow(A, k // 2)
        return mat_mul(half, half)
    else:
        return mat_mul(A, mat_pow(A, k - 1))


def trace(A: Matrix) -> Fraction:
    """Compute the trace of a matrix."""
    return sum(A[i][i] for i in range(len(A)))


def determinant(A: Matrix) -> Fraction:
    """Compute the determinant using Gaussian elimination (exact arithmetic).

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = len(A)
    if n == 0:
        return Fraction(1)
    # Work on a copy
    M = [row[:] for row in A]
    det = Fraction(1)
    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(col, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            M[col], M[pivot] = M[pivot], M[col]
            det = -det
        det *= M[col][col]
        inv_pivot = Fraction(1, M[col][col].numerator) * Fraction(M[col][col].denominator)
        for row in range(col + 1, n):
            factor = M[row][col] * inv_pivot
            for j in range(col, n):
                M[row][j] -= factor * M[col][j]
    return det


def matrix_rank(A: Matrix) -> int:
    """Compute the rank using row echelon form.

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = len(A)
    if n == 0:
        return 0
    m = len(A[0])
    M = [row[:] for row in A]
    rank = 0
    for col in range(m):
        pivot = None
        for row in range(rank, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            continue
        M[rank], M[pivot] = M[pivot], M[rank]
        inv_pivot = Fraction(1) / M[rank][col]
        for row in range(n):
            if row != rank and M[row][col] != 0:
                factor = M[row][col] * inv_pivot
                for j in range(m):
                    M[row][j] -= factor * M[rank][j]
        rank += 1
    return rank


def is_nilpotent(A: Matrix) -> Tuple[bool, int]:
    """Test if a matrix is nilpotent, return (is_nilpotent, nilpotency_index).

    The nilpotency index is the smallest k such that A^k = 0.
    For an n×n matrix, k ≤ n if nilpotent.

    Time complexity: O(n⁴) (n matrix multiplications of O(n³) each)
    Space complexity: O(n²)
    """
    n = len(A)
    power = identity_matrix(n)
    for k in range(1, n + 1):
        power = mat_mul(power, A)
        if all(power[i][j] == 0 for i in range(n) for j in range(n)):
            return True, k
    return False, -1


def is_strictly_upper_triangular(A: Matrix) -> bool:
    """Check if A is strictly upper triangular (A_{ij} = 0 for j ≤ i)."""
    n = len(A)
    for i in range(n):
        for j in range(i + 1):
            if A[i][j] != 0:
                return False
    return True


def druzkowski_jacobian_symbolic(A: Matrix) -> str:
    """Return a symbolic description of the Drużkowski map's Jacobian.

    For Φ(x) = x + (Ax)^[3], the Jacobian is:
    JΦ(x) = I + 3 · A · diag(ℓ₁(x)², ..., ℓₙ(x)²)
    where ℓᵢ(x) = Σⱼ Aᵢⱼ xⱼ.
    """
    n = len(A)
    lines = [f"Drużkowski Jacobian for {n}×{n} matrix A:"]
    lines.append(f"JΦ(x) = I + 3·A·diag(ℓ₁(x)², ..., ℓₙ(x)²)")
    lines.append("where:")
    for i in range(n):
        terms = []
        for j in range(n):
            if A[i][j] != 0:
                coeff = A[i][j]
                if coeff == 1:
                    terms.append(f"x{j+1}")
                elif coeff == -1:
                    terms.append(f"-x{j+1}")
                else:
                    terms.append(f"{coeff}·x{j+1}")
        if terms:
            lines.append(f"  ℓ{i+1}(x) = {' + '.join(terms)}")
        else:
            lines.append(f"  ℓ{i+1}(x) = 0")
    return "\n".join(lines)


def check_keller_condition_druzkowski(A: Matrix, test_points: int = 20) -> Tuple[bool, str]:
    """Check if a Drużkowski map satisfies the Keller condition.

    For Φ(x) = x + (Ax)^[3], the Jacobian at x is:
    JΦ(x) = I + 3·diag(ℓ₁(x)², ..., ℓₙ(x)²)·(rows of A rearranged)

    Actually, JΦ(x)ᵢⱼ = δᵢⱼ + 3·Aᵢⱼ·ℓᵢ(x)²

    We check det(JΦ(x)) = 1 at several random rational points.

    Returns (is_likely_keller, diagnostic_string).

    Time complexity: O(test_points · n³)
    """
    n = len(A)

    for trial in range(test_points):
        # Generate a test point
        x = [Fraction(trial * (j + 1) - n, max(1, trial + j)) for j in range(n)]

        # Compute linear forms ℓᵢ(x)
        ell = [sum(A[i][j] * x[j] for j in range(n)) for i in range(n)]

        # Build Jacobian at x: J_{ij} = δ_{ij} + 3·A_{ij}·ℓᵢ(x)²
        J = zero_matrix(n)
        for i in range(n):
            for j in range(n):
                J[i][j] = (Fraction(1) if i == j else Fraction(0)) + 3 * A[i][j] * ell[i] ** 2

        d = determinant(J)
        if d != Fraction(1):
            return False, f"det(JΦ(x)) = {d} ≠ 1 at x = {x}"

    return True, f"Passed {test_points} test points"


def hessian_nilpotency_index(A: Matrix) -> int:
    """Compute the Hessian nilpotency index for a Drużkowski map.

    For Φ(x) = x + (Ax)^[3], the Jacobian perturbation has entries
    3·Aᵢⱼ·ℓᵢ(x)². As a matrix family parameterized by x, its
    nilpotency index is related to the nilpotency of A·D² where
    D = diag(ℓ₁(x), ..., ℓₙ(x)).

    We approximate by checking the "generic" nilpotency index of
    3·A·diag(v₁², ..., vₙ²) for random rational vectors v.

    Returns the maximum nilpotency index found, or -1 if not nilpotent.
    """
    n = len(A)
    max_index = 0

    for trial in range(10):
        v = [Fraction(trial + j + 1, trial + 2) for j in range(n)]

        # Build the matrix M = 3·A·diag(v²)
        M = zero_matrix(n)
        for i in range(n):
            for j in range(n):
                M[i][j] = 3 * A[i][j] * v[j] ** 2

        nilp, idx = is_nilpotent(M)
        if not nilp:
            return -1
        max_index = max(max_index, idx)

    return max_index


def enumerate_keller_matrices(n: int, max_entry: int = 1) -> List[Matrix]:
    """Enumerate all n×n matrices with entries in {-max_entry, ..., max_entry}
    that define Keller Drużkowski maps.

    Time complexity: O((2·max_entry+1)^(n²) · n³)
    Warning: Exponential in n² — only feasible for very small n.
    """
    entries = range(-max_entry, max_entry + 1)
    keller_matrices = []

    for flat in product(entries, repeat=n * n):
        A = [[Fraction(flat[i * n + j]) for j in range(n)] for i in range(n)]

        is_keller, _ = check_keller_condition_druzkowski(A, test_points=5)
        if is_keller:
            keller_matrices.append(A)

    return keller_matrices


def test_rank_conjecture(n: int, max_entry: int = 1) -> Tuple[bool, Optional[Matrix]]:
    """Test the cubic linear Keller rank conjecture for dimension n.

    Conjecture: For any Keller Drużkowski map in dim n ≤ 5,
    the matrix A has rank < n.

    Returns (conjecture_holds, counterexample_or_None).

    Time complexity: O((2·max_entry+1)^(n²) · n³)
    """
    keller_matrices = enumerate_keller_matrices(n, max_entry)

    for A in keller_matrices:
        r = matrix_rank(A)
        if r >= n:
            return False, A

    return True, None


if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATION")
    print("=" * 60)

    # Example 1: Nilpotency test
    print("\n--- Nilpotency Test ---")
    A = [[Fraction(0), Fraction(1), Fraction(0)],
         [Fraction(0), Fraction(0), Fraction(1)],
         [Fraction(0), Fraction(0), Fraction(0)]]
    nilp, idx = is_nilpotent(A)
    print(f"A = strictly upper triangular 3×3")
    print(f"  Nilpotent: {nilp}, Index: {idx}")
    print(f"  Trace: {trace(A)}, Det: {determinant(A)}")

    # Example 2: Drużkowski Keller check
    print("\n--- Drużkowski Keller Check ---")
    A2 = [[Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0)]]
    print(druzkowski_jacobian_symbolic(A2))
    is_keller, msg = check_keller_condition_druzkowski(A2)
    print(f"  Keller: {is_keller} ({msg})")

    # Example 3: Hessian nilpotency index
    print("\n--- Hessian Nilpotency Index ---")
    idx = hessian_nilpotency_index(A2)
    print(f"  Index for 2×2 upper triangular: {idx}")

    idx3 = hessian_nilpotency_index(A)
    print(f"  Index for 3×3 upper triangular: {idx3}")
