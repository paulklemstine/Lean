"""Numerical demonstrations for the maximal-determinant problem of 4x4 integer
matrices with bounded entries.

This module is fully self-contained (standard library only) and illustrates:

  1. The base Hadamard matrix H has determinant 16.
  2. The scaled Hadamard matrix c*H is admissible (entries bounded by c) and has
     determinant 16 * c**4  (achievability of the lower bound).
  3. The two-sided bound 16*c**4 <= D(c) <= 24*c**4.
  4. The divisibility law: every 4x4 sign (+/-1) matrix has determinant
     divisible by 8, and the observed spectrum is {-16,-8,0,8,16}.
  5. The refutation of the circulating formula (c^2 - 1)^2, which is strictly
     below the achievable 16*c**4 for every c >= 1.

Everything is computed with exact integer arithmetic.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Iterable, List, Sequence, Tuple

Matrix = Sequence[Sequence[int]]


def det4(a: Matrix) -> int:
    """Exact determinant of a 4x4 integer matrix via the Leibniz sum over S_4."""
    total = 0
    for perm in permutations(range(4)):
        # sign of the permutation
        sign = 1
        for i in range(4):
            for j in range(i + 1, 4):
                if perm[i] > perm[j]:
                    sign = -sign
        prod = 1
        for i in range(4):
            prod *= a[i][perm[i]]
        total += sign * prod
    return total


HADAMARD4: Matrix = (
    (1, 1, 1, 1),
    (1, -1, 1, -1),
    (1, 1, -1, -1),
    (1, -1, -1, 1),
)


def scaled_hadamard(c: int) -> Matrix:
    """Return c * H, the scaled Hadamard construction."""
    return tuple(tuple(c * x for x in row) for row in HADAMARD4)


def max_abs_entry(a: Matrix) -> int:
    return max(abs(x) for row in a for x in row)


def leibniz_upper_bound(c: int) -> int:
    """The permanent/Leibniz upper bound 4! * c^4 = 24 * c^4."""
    return 24 * c ** 4


def achievable_value(c: int) -> int:
    """The achievable determinant 16 * c^4 from the scaled Hadamard matrix."""
    return 16 * c ** 4


def circulating_guess(k: int) -> int:
    """The refuted formula (2k-1)^4 - 2(2k-1)^2 + 1 = (c^2-1)^2 with c=2k-1."""
    c = 2 * k - 1
    return c ** 4 - 2 * c ** 2 + 1


def demo_hadamard_determinant() -> None:
    print("=" * 64)
    print("1. Base Hadamard matrix and its determinant")
    print("=" * 64)
    for row in HADAMARD4:
        print("   ", row)
    print(f"   det(H) = {det4(HADAMARD4)}  (expected 16)")
    print()


def demo_scaling_law() -> None:
    print("=" * 64)
    print("2. Scaling law: det(cH) = 16 c^4, entries bounded by c")
    print("=" * 64)
    print(f"   {'c':>3} | {'max|entry|':>10} | {'det(cH)':>12} | {'16 c^4':>12}")
    print("   " + "-" * 46)
    for c in range(1, 8):
        m = scaled_hadamard(c)
        print(f"   {c:>3} | {max_abs_entry(m):>10} | {det4(m):>12} | {achievable_value(c):>12}")
    print()


def demo_two_sided_bound() -> None:
    print("=" * 64)
    print("3. Two-sided bound  16 c^4 <= D(c) <= 24 c^4")
    print("=" * 64)
    print(f"   {'c':>3} | {'16 c^4 (achieved)':>18} | {'24 c^4 (Leibniz)':>18}")
    print("   " + "-" * 46)
    for c in range(1, 6):
        print(f"   {c:>3} | {achievable_value(c):>18} | {leibniz_upper_bound(c):>18}")
    print()


def all_sign_matrices() -> Iterable[Matrix]:
    """Enumerate all 2^16 = 65536 sign (+/-1) 4x4 matrices."""
    for bits in product((1, -1), repeat=16):
        yield tuple(tuple(bits[4 * i + j] for j in range(4)) for i in range(4))


def demo_divisibility_and_spectrum() -> None:
    print("=" * 64)
    print("4. Divisibility law and spectrum of sign-matrix determinants")
    print("=" * 64)
    spectrum: set[int] = set()
    all_div_by_8 = True
    for m in all_sign_matrices():
        d = det4(m)
        spectrum.add(d)
        if d % 8 != 0:
            all_div_by_8 = False
    print(f"   every determinant divisible by 8 : {all_div_by_8}")
    print(f"   full spectrum of det over all +/-1 matrices : {sorted(spectrum)}")
    print(f"   maximum sign-matrix determinant : {max(spectrum)}  (expected 16)")
    print()


def demo_refutation() -> None:
    print("=" * 64)
    print("5. Refutation of the circulating formula (c^2-1)^2")
    print("=" * 64)
    print(f"   {'k':>3} | {'c=2k-1':>7} | {'guess (c^2-1)^2':>16} | {'achieved 16c^4':>16} | guess < achieved")
    print("   " + "-" * 74)
    for k in range(1, 7):
        c = 2 * k - 1
        guess = circulating_guess(k)
        ach = achievable_value(c)
        print(f"   {k:>3} | {c:>7} | {guess:>16} | {ach:>16} | {str(guess < ach):>5}")
    print()
    print("   Note k=1 (c=1): guess = 0, yet det(H) = 16 -- not even an upper bound.")
    print()


def main() -> None:
    demo_hadamard_determinant()
    demo_scaling_law()
    demo_two_sided_bound()
    demo_divisibility_and_spectrum()
    demo_refutation()


if __name__ == "__main__":
    main()
