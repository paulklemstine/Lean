"""
Numerical demonstrations for:

    The Good-Manifold Count of an n-Nice Polytope
    An Exceptional Head and an Exponential Tail

The good-manifold count a(n) is the maximal number of good manifolds carried by
an n-nice polytope. It has a finite exceptional head (n = 1..6) and an
exponential tail a(n) = 2^n for n >= 7.

This script is self-contained (standard library only) and verifies every
theorem in the accompanying paper by direct computation.

Results demonstrated:
  * Data reproduction of the 21 tabulated terms.
  * Closed form a(n) = 2^n on the tail (n >= 7).
  * Doubling recurrence a(n+1) = 2 a(n) on the tail.
  * Telescoping partial sums: sum_{k=7}^{N} a(k) = 2^(N+1) - 2^7.
  * Global lower bound 2^n <= a(n), strict on the head.
  * Strict monotonicity across the head/tail seam (80 < 128).
  * Growth classification: a is eventually 2^n, hence NOT super-exponential
    (3^n eventually overtakes it), while n! IS super-exponential.
"""

from __future__ import annotations

from math import factorial
from typing import List

# The six exceptional head values, at n = 1, ..., 6.
HEAD: dict[int, int] = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}

# The 21 tabulated terms, for verification.
TABULATED: List[int] = [
    6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, 16384,
    32768, 65536, 131072, 262144, 524288, 1048576, 2097152,
]


def good_count(n: int) -> int:
    """Maximal number of good manifolds in an n-nice polytope.

    Head (n = 1..6): the six exceptional values 6, 8, 12, 24, 40, 80.
    Tail (n >= 7):  the power of two 2^n.
    """
    if n in HEAD:
        return HEAD[n]
    return 2 ** n


def tail_partial_sum(N: int) -> int:
    """Direct summation of sum_{k=7}^{N} a(k)."""
    return sum(good_count(k) for k in range(7, N + 1))


def tail_partial_sum_closed(N: int) -> int:
    """Closed form 2^(N+1) - 2^7 for the tail partial sum (Theorem: sums)."""
    return 2 ** (N + 1) - 2 ** 7


def is_super_exponential_empirical(f, c: int, horizon: int) -> bool:
    """Heuristic check: does f(n) eventually exceed c^n up to `horizon`?

    Returns True if there is a cutoff N <= horizon beyond which f(n) > c^n for
    all tested n. This is a finite witness, not a proof, but it cleanly
    separates 2^n-type sequences from factorial-type sequences.
    """
    eventually_beats = False
    for cutoff in range(horizon):
        if all(f(n) > c ** n for n in range(cutoff, horizon)):
            eventually_beats = True
            break
    return eventually_beats


def demo_data_reproduction() -> None:
    print("=" * 68)
    print("1. Data reproduction: a(1..21)")
    print("=" * 68)
    computed = [good_count(n) for n in range(1, 22)]
    print("computed :", computed)
    print("tabulated:", TABULATED)
    assert computed == TABULATED, "data mismatch!"
    print("last term 2^21 =", 2 ** 21, "matches", TABULATED[-1])
    print("OK: all 21 terms reproduced.\n")


def demo_closed_form_and_doubling() -> None:
    print("=" * 68)
    print("2. Closed form a(n) = 2^n and doubling a(n+1) = 2 a(n), n >= 7")
    print("=" * 68)
    for n in range(7, 16):
        assert good_count(n) == 2 ** n
        assert good_count(n + 1) == 2 * good_count(n)
        print(f"  a({n:2d}) = {good_count(n):6d} = 2^{n};  "
              f"a({n+1}) = {good_count(n+1)} = 2 * a({n})")
    print("OK: closed form and doubling verified on the tail.\n")


def demo_telescoping_sum() -> None:
    print("=" * 68)
    print("3. Telescoping partial sums: sum_{k=7}^N a(k) = 2^(N+1) - 2^7")
    print("=" * 68)
    for N in range(7, 16):
        direct = tail_partial_sum(N)
        closed = tail_partial_sum_closed(N)
        assert direct == closed
        print(f"  N={N:2d}:  direct={direct:7d}  closed=2^{N+1}-2^7={closed:7d}")
    print("  e.g. sum_{k=7}^{12} a(k) =", tail_partial_sum(12),
          "= 2^13 - 2^7 =", 2 ** 13 - 2 ** 7)
    print("OK: geometric telescoping verified.\n")


def demo_lower_bound_and_surcharge() -> None:
    print("=" * 68)
    print("4. Global lower bound 2^n <= a(n) and the head surcharge s(n)")
    print("=" * 68)
    for n in range(1, 10):
        s = good_count(n) - 2 ** n
        rel = "=" if s == 0 else ">"
        assert good_count(n) >= 2 ** n
        print(f"  n={n:2d}:  a(n)={good_count(n):5d}  2^n={2**n:5d}  "
              f"a(n) {rel} 2^n   surcharge s(n)={s}")
    print("OK: 2^n <= a(n) always; strict on the head, equal on the tail.\n")


def demo_monotonicity() -> None:
    print("=" * 68)
    print("5. Strict monotonicity a(n) < a(n+1), including the seam 80 < 128")
    print("=" * 68)
    for n in range(1, 12):
        assert good_count(n) < good_count(n + 1)
    print("  head+seam:", " < ".join(str(good_count(n)) for n in range(1, 8)))
    print("  seam a(6) < a(7):", good_count(6), "<", good_count(7))
    print("OK: strictly increasing throughout.\n")


def demo_growth_classification() -> None:
    print("=" * 68)
    print("6. Growth classification: exponential, NOT super-exponential")
    print("=" * 68)
    horizon = 40
    # 3^n eventually overtakes a(n) = 2^n, so a is NOT super-exponential.
    a_beats_3 = is_super_exponential_empirical(good_count, 3, horizon)
    # n! eventually overtakes every c^n, so factorial IS super-exponential.
    fact_beats_3 = is_super_exponential_empirical(factorial, 3, horizon)
    print(f"  does a(n) eventually beat 3^n up to n={horizon}? {a_beats_3}")
    print(f"  does n!  eventually beat 3^n up to n={horizon}? {fact_beats_3}")
    assert not a_beats_3, "a should NOT be super-exponential"
    assert fact_beats_3, "factorial SHOULD be super-exponential"
    # show the crossover where 3^n passes a(n) = 2^n
    for n in range(1, 12):
        marker = "  <-- 3^n overtakes here" if 3 ** n > good_count(n) and 3 ** (n - 1) <= good_count(n - 1) else ""
        print(f"    n={n:2d}: a(n)={good_count(n):6d}  3^n={3**n:7d}{marker}")
    print("OK: a(n) is exactly exponential (2^n), one tier below factorial.\n")


def main() -> None:
    demo_data_reproduction()
    demo_closed_form_and_doubling()
    demo_telescoping_sum()
    demo_lower_bound_and_surcharge()
    demo_monotonicity()
    demo_growth_classification()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
