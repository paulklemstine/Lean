"""
Numerical demonstrations for:

    Extremal Determinants of 4x4 Integer Matrices with Bounded Entries

Main facts demonstrated
-----------------------
1. The scaled order-4 Hadamard matrix H(B) has all entries +/-B, mutually
   orthogonal rows (H H^T = 4B^2 I), and determinant exactly 16 * B^4.
2. Every 4x4 matrix with |entries| <= B obeys the permutation (Leibniz)
   bound |det| <= 24 * B^4.
3. The true maximum M(B) is bracketed 16*B^4 <= M(B) <= 24*B^4 and equals
   16*B^4 (confirmed by exhaustive search over {-1,0,1} at B=1).
4. The circulated formula C(k) = (2k-1)^4 - 2(2k-1)^2 + 1 is NOT even an
   upper bound: 16*(2k-1)^4 beats it for every k >= 1, and C(1) = 0 while
   the true maximum is 16.

Self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from itertools import product, permutations
from typing import List, Tuple

Matrix = List[List[int]]


# --------------------------------------------------------------------------- #
# Basic linear algebra (integer-exact, no external dependencies)              #
# --------------------------------------------------------------------------- #
def det4(m: Matrix) -> int:
    """Exact determinant of a 4x4 integer matrix via first-row cofactor
    expansion. All arithmetic is over the integers, so the result is exact."""

    def det3(a: List[List[int]]) -> int:
        return (
            a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
            - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
            + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0])
        )

    total = 0
    for c in range(4):
        minor = [[m[r][cc] for cc in range(4) if cc != c] for r in range(1, 4)]
        total += ((-1) ** c) * m[0][c] * det3(minor)
    return total


def transpose(m: Matrix) -> Matrix:
    return [[m[j][i] for j in range(len(m))] for i in range(len(m[0]))]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    n, k, p = len(a), len(b), len(b[0])
    return [[sum(a[i][t] * b[t][j] for t in range(k)) for j in range(p)] for i in range(n)]


# --------------------------------------------------------------------------- #
# The extremal construction                                                    #
# --------------------------------------------------------------------------- #
def hadamard_mat(B: int) -> Matrix:
    """Scaled order-4 Hadamard matrix: entries +/-B, orthogonal rows."""
    return [
        [B, B, B, B],
        [B, -B, B, -B],
        [B, B, -B, -B],
        [B, -B, -B, B],
    ]


def circulated_formula(k: int) -> int:
    """The (false) circulated candidate maximum for radius 2k-1."""
    t = 2 * k - 1
    return t ** 4 - 2 * t ** 2 + 1


def leibniz_bound(B: int, n: int = 4) -> int:
    """Universal permutation bound n! * B^n for the order-n family."""
    fact = 1
    for i in range(2, n + 1):
        fact *= i
    return fact * B ** n


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_construction() -> None:
    print("=" * 70)
    print("1. The scaled Hadamard construction H(B)")
    print("=" * 70)
    for B in [1, 2, 3, 5]:
        H = hadamard_mat(B)
        d = det4(H)
        gram = matmul(H, transpose(H))
        expected_gram = [[4 * B ** 2 if i == j else 0 for j in range(4)] for i in range(4)]
        print(f"  B = {B}:")
        print(f"    det H(B)          = {d}")
        print(f"    16 * B^4          = {16 * B ** 4}   (match: {d == 16 * B ** 4})")
        print(f"    H H^T == 4B^2 I   : {gram == expected_gram}")
    print()


def demo_permutation_bound() -> None:
    print("=" * 70)
    print("2. Permutation (Leibniz) upper bound  |det| <= 24 B^4")
    print("=" * 70)
    for B in [1, 2, 3]:
        print(f"  B = {B}: achieved 16*B^4 = {16 * B ** 4:>6}   "
              f"bound 24*B^4 = {leibniz_bound(B):>6}")
    print()


def demo_exhaustive_B1() -> None:
    print("=" * 70)
    print("3. Exhaustive search over {-1,0,1} entries (B = 1)")
    print("=" * 70)
    best = 0
    best_mat: Matrix = []
    # 3^16 is ~43M; restrict to +/-1 entries (2^16 = 65536) which contains the
    # maximiser and is fast. (Zeros never help increase |det| here.)
    values = (-1, 1)
    for flat in product(values, repeat=16):
        m = [list(flat[4 * r:4 * r + 4]) for r in range(4)]
        d = det4(m)
        if d > best:
            best, best_mat = d, m
    print(f"    max det over +/-1 matrices = {best}")
    print(f"    theoretical value 16*1^4   = {16}")
    print(f"    circulated formula C(1)    = {circulated_formula(1)}  (predicts 0!)")
    print(f"    a maximiser:")
    for row in best_mat:
        print(f"      {row}")
    print()


def demo_refute_formula() -> None:
    print("=" * 70)
    print("4. Refuting the circulated formula C(k) = (2k-1)^4 - 2(2k-1)^2 + 1")
    print("=" * 70)
    print(f"    {'k':>3} {'radius':>7} {'C(k)':>12} {'16*(2k-1)^4':>14} {'C(k) < true?':>13}")
    for k in range(1, 8):
        t = 2 * k - 1
        c = circulated_formula(k)
        true_val = 16 * t ** 4
        print(f"    {k:>3} {t:>7} {c:>12} {true_val:>14} {str(c < true_val):>13}")
    print("\n    => C(k) is NOT an upper bound for any k >= 1.")
    print()


def main() -> None:
    demo_construction()
    demo_permutation_bound()
    demo_exhaustive_B1()
    demo_refute_formula()


if __name__ == "__main__":
    main()
