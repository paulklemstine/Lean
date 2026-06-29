"""
Central Gaussian coefficient maximizes binary 2-binomial class size
===================================================================

Numerical demonstrations of the results formalized in
`Catalog/Probability/BinaryTwoBinomial.lean`.

For a binary word of length ``n`` with ``k`` ones, its *inversion number* is the
number of scattered occurrences of the factor ``10`` -- i.e. the number of ordered
pairs ``(i, j)`` with ``i < j`` such that position ``i`` carries a one and position
``j`` carries a zero.

Two binary words are **2-binomially equivalent** exactly when they share the same
length ``n``, the same number of ones ``k`` and the same inversion number ``i``.
The size of such an equivalence class, ``classSize(n, k, i)``, equals the
coefficient of ``q**i`` in the Gaussian (q-)binomial coefficient ``[n choose k]_q``
(MacMahon's theorem).

This script demonstrates, by direct enumeration:

  * ``classSize`` reproduces the Gaussian binomial rows               (H1)
  * the class sizes sum to the ordinary binomial C(n, k)              (total_eq_choose)
  * the distribution is palindromic about the central index k(n-k)/2  (classSize_symm)
  * the central inversion number gives the largest class              (central_max_*)
  * the mean inversion number is exactly the central index            (inv_weighted_sum)

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
#  Core combinatorics
# --------------------------------------------------------------------------- #
def inversion_number(positions: Tuple[int, ...], n: int) -> int:
    """Inversion number of the word of length ``n`` whose ones sit at ``positions``.

    Counts ordered pairs (i, j), i < j, with i a one and j a zero (factor ``10``).
    """
    ones = set(positions)
    return sum(
        1
        for i in range(n)
        for j in range(i + 1, n)
        if i in ones and j not in ones
    )


def class_size(n: int, k: int, i: int) -> int:
    """Size of the 2-binomial class (n, k, i): #words of length n, k ones, inv = i."""
    return sum(
        1
        for positions in combinations(range(n), k)
        if inversion_number(positions, n) == i
    )


def gaussian_row(n: int, k: int) -> List[int]:
    """The full coefficient vector of [n choose k]_q, i.e. classSize(n, k, .)."""
    max_inv = k * (n - k)
    return [class_size(n, k, i) for i in range(max_inv + 1)]


def central_index(n: int, k: int) -> int:
    """The central inversion number k(n-k)//2 (integer division, as in Lean)."""
    return k * (n - k) // 2


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_gaussian_rows() -> None:
    """H1: classSize reproduces the known Gaussian binomial coefficient rows."""
    print("=" * 70)
    print("Gaussian binomial rows  classSize(n, k, .)")
    print("=" * 70)
    expected = {
        (4, 2): [1, 1, 2, 1, 1],
        (5, 2): [1, 1, 2, 2, 2, 1, 1],
        (6, 3): [1, 1, 2, 3, 3, 3, 3, 2, 1, 1],
    }
    for (n, k), exp in expected.items():
        row = gaussian_row(n, k)
        ok = "OK" if row == exp else "MISMATCH"
        print(f"  [n={n}, k={k}]_q  ->  {row}   [{ok}]")


def demo_total_eq_choose() -> None:
    """total_eq_choose: the class sizes sum to the ordinary binomial C(n, k)."""
    print("=" * 70)
    print("Row sums equal C(n, k)")
    print("=" * 70)
    for n in range(1, 9):
        for k in range(n + 1):
            s = sum(gaussian_row(n, k))
            c = comb(n, k)
            assert s == c, (n, k, s, c)
            if k <= n // 2:
                print(f"  sum classSize({n}, {k}, .) = {s:>3}  =  C({n},{k}) = {c}")


def demo_symmetry() -> None:
    """classSize_symm: palindromic symmetry about the central index k(n-k)/2."""
    print("=" * 70)
    print("Palindromic symmetry: classSize(n,k,i) = classSize(n,k, k(n-k)-i)")
    print("=" * 70)
    for (n, k) in [(6, 3), (7, 3), (8, 4)]:
        row = gaussian_row(n, k)
        palindrome = row == row[::-1]
        print(f"  [n={n}, k={k}]  row={row}  palindrome={palindrome}")
        assert palindrome


def demo_central_max() -> None:
    """central_max_*: the central inversion number gives the global maximum."""
    print("=" * 70)
    print("Central coefficient is the maximum (verified for n <= 8)")
    print("=" * 70)
    for n in range(1, 9):
        for k in range(n + 1):
            row = gaussian_row(n, k)
            if not row:
                continue
            c = central_index(n, k)
            mx = max(row)
            assert row[c] == mx, (n, k, c, row)
        print(f"  n={n}: every k has its maximum at the central index  [OK]")


def demo_mean_inversion() -> None:
    """inv_weighted_sum: the mean inversion number equals the central index."""
    print("=" * 70)
    print("Mean inversion number equals k(n-k)/2")
    print("=" * 70)
    for (n, k) in [(6, 3), (7, 3), (8, 4), (8, 3)]:
        row = gaussian_row(n, k)
        total = sum(row)
        mean = sum(i * c for i, c in enumerate(row)) / total
        print(f"  [n={n}, k={k}]  mean inv = {mean:.3f},  k(n-k)/2 = {k*(n-k)/2:.3f}")
        assert abs(mean - k * (n - k) / 2) < 1e-9


def main() -> None:
    demo_gaussian_rows()
    demo_total_eq_choose()
    demo_symmetry()
    demo_central_max()
    demo_mean_inversion()
    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
