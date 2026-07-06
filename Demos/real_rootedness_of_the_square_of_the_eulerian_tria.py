"""
Real-rootedness of the square of the Eulerian triangle
======================================================

Self-contained numerical companion to the article and research paper.

This script demonstrates, with *exact* rational arithmetic, the central facts
about the square of the Eulerian triangle:

  * the Eulerian numbers A(n, k) and their triangular recurrence;
  * the row-sum identity  sum_k A(n, k) = n!;
  * the squared triangle  T(n, k) = sum_j A(n, j) A(j, k)  and its row
    generating polynomial  S_n(x) = sum_k T(n, k) x^k = sum_j A(n, j) A_j(x);
  * the constant term  S_n(0) = n!  and the degree  deg S_n = n - 2  (n >= 2);
  * a Sturm-sequence certificate that every root of S_n is real and negative;
  * the interlacing of the roots of S_n and S_{n+1}.

No third-party libraries are required: all root counting is done with exact
Sturm sequences over the rationals, and root locations are isolated by exact
bisection, so every printed conclusion is rigorous.
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from math import factorial
from typing import List, Tuple

# --------------------------------------------------------------------------- #
#  Eulerian numbers                                                           #
# --------------------------------------------------------------------------- #


@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    """Eulerian number A(n, k): permutations of {1, ..., n} with k ascents.

    Triangular recurrence:
        A(0, 0) = 1,  A(n, 0) = 1,
        A(n, k) = (k + 1) * A(n - 1, k) + (n - k) * A(n - 1, k - 1).
    """
    if k < 0 or k >= max(n, 1):
        return 0
    if n == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)


def eulerian_row(n: int) -> List[int]:
    """The n-th Eulerian row [A(n, 0), ..., A(n, n-1)]."""
    return [eulerian(n, k) for k in range(max(n, 1))]


# --------------------------------------------------------------------------- #
#  Squared triangle and its row polynomials                                   #
# --------------------------------------------------------------------------- #


def squared_row_coeffs(n: int) -> List[int]:
    """Coefficients of S_n(x) = sum_k (sum_j A(n, j) A(j, k)) x^k.

    Trailing zeros are trimmed, so the returned list has length deg(S_n) + 1.
    """
    top = max(n, 1)
    coeffs = [
        sum(eulerian(n, j) * eulerian(j, k) for j in range(top))
        for k in range(top)
    ]
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs


# --------------------------------------------------------------------------- #
#  Exact polynomial arithmetic (coefficients low-degree first)               #
# --------------------------------------------------------------------------- #

Poly = List[Fraction]


def _trim(p: Poly) -> Poly:
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def _derivative(p: Poly) -> Poly:
    if len(p) <= 1:
        return [Fraction(0)]
    return _trim([p[i] * i for i in range(1, len(p))])


def _remainder(a: Poly, b: Poly) -> Poly:
    """Polynomial remainder of a divided by b (exact)."""
    a = [Fraction(x) for x in _trim(a)]
    b = _trim(b)
    while len(a) >= len(b) and not (len(a) == 1 and a[0] == 0):
        if a[-1] == 0:
            a.pop()
            continue
        c = a[-1] / b[-1]
        shift = len(a) - len(b)
        for i in range(len(b)):
            a[i + shift] -= c * b[i]
        a = _trim(a)
        if len(a) < len(b):
            break
    return _trim(a)


def _sturm_sequence(p: Poly) -> List[Poly]:
    """Canonical Sturm sequence p_0 = p, p_1 = p', p_{i+1} = -rem(p_{i-1}, p_i)."""
    p = [Fraction(x) for x in _trim(p)]
    seq = [p, _derivative(p)]
    while not (len(_trim(seq[-1])) == 1 and _trim(seq[-1])[0] == 0):
        r = _remainder(seq[-2], seq[-1])
        if len(_trim(r)) == 1 and _trim(r)[0] == 0:
            break
        seq.append([-x for x in r])
    return seq


def _eval(p: Poly, x: Fraction) -> Fraction:
    acc = Fraction(0)
    for c in reversed(p):
        acc = acc * x + c
    return acc


def _sign_changes(seq: List[Poly], x: Fraction) -> int:
    signs: List[int] = []
    for p in seq:
        v = _eval(p, x)
        if v != 0:
            signs.append(1 if v > 0 else -1)
    return sum(1 for i in range(len(signs) - 1) if signs[i] * signs[i + 1] < 0)


def count_real_roots(coeffs: List[int], a: Fraction, b: Fraction) -> int:
    """Number of distinct real roots of the polynomial in the open interval (a, b]."""
    seq = _sturm_sequence([Fraction(c) for c in coeffs])
    return _sign_changes(seq, a) - _sign_changes(seq, b)


def isolate_roots(coeffs: List[int], precision_bits: int = 60) -> List[float]:
    """Return the real roots of the polynomial, isolated and refined by bisection."""
    seq = _sturm_sequence([Fraction(c) for c in coeffs])

    def sign_at(x: Fraction) -> int:
        return _sign_changes(seq, x)

    lo, hi = Fraction(-1 << 40), Fraction(1 << 40)
    stack: List[Tuple[Fraction, Fraction]] = [(lo, hi)]
    roots: List[float] = []
    while stack:
        a, b = stack.pop()
        c = sign_at(a) - sign_at(b)
        if c == 0:
            continue
        if c == 1:
            for _ in range(precision_bits):
                m = (a + b) / 2
                if sign_at(a) - sign_at(m) >= 1:
                    b = m
                else:
                    a = m
            roots.append(float((a + b) / 2))
        else:
            m = (a + b) / 2
            stack.append((a, m))
            stack.append((m, b))
    return sorted(roots)


def interlaces(small: List[float], big: List[float]) -> bool:
    """True if the sorted list `big` interlaces `small` (big has one extra root)."""
    if len(big) != len(small) + 1:
        return False
    for i, s in enumerate(small):
        if not (big[i] <= s <= big[i + 1]):
            return False
    return True


# --------------------------------------------------------------------------- #
#  Demonstration                                                              #
# --------------------------------------------------------------------------- #


def main() -> None:
    print("=" * 70)
    print("The Eulerian triangle A(n, k)")
    print("=" * 70)
    for n in range(1, 8):
        print(f"row {n}: {eulerian_row(n)}")

    print()
    print("=" * 70)
    print("Row-sum identity:  sum_k A(n, k) = n!")
    print("=" * 70)
    for n in range(1, 9):
        s = sum(eulerian_row(n))
        print(f"n = {n}:  sum = {s:>7}   n! = {factorial(n):>7}   match = {s == factorial(n)}")

    print()
    print("=" * 70)
    print("Squared-triangle row polynomials S_n(x) = sum_j A(n,j) A_j(x)")
    print("=" * 70)
    for n in range(2, 9):
        coeffs = squared_row_coeffs(n)
        print(
            f"n = {n}:  coeffs (low->high) = {coeffs}"
            f"   S_n(0) = {coeffs[0]}  (n! = {factorial(n)})"
            f"   deg = {len(coeffs) - 1}  (n-2 = {n - 2})"
        )

    print()
    print("=" * 70)
    print("Real-rootedness certificate (exact Sturm sequences)")
    print("=" * 70)
    prev: List[float] = []
    for n in range(3, 10):
        coeffs = squared_row_coeffs(n)
        deg = len(coeffs) - 1
        neg = count_real_roots(coeffs, Fraction(-1 << 40), Fraction(0))
        total = count_real_roots(coeffs, Fraction(-1 << 40), Fraction(1 << 40))
        roots = isolate_roots(coeffs)
        all_real = total == deg
        all_neg = neg == deg
        tag = "interlaces previous row: " + str(interlaces(prev, roots)) if prev else ""
        print(
            f"n = {n}:  degree {deg},  real roots {total},  negative roots {neg}"
            f"   all real & negative = {all_real and all_neg}"
        )
        print(f"        roots ~ {[round(r, 4) for r in roots]}   {tag}")
        prev = roots


if __name__ == "__main__":
    main()
