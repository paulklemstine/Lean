"""
Multiplicities in Pascal's Triangle — numerical demonstration
=============================================================

For an integer t >= 2 let

    N(t) = #{ (n, k) : 0 <= k <= n and C(n, k) = t }

be the multiplicity of t in Pascal's triangle.  This script demonstrates,
numerically, every result of the accompanying paper:

  1. Localisation: every occurrence of t >= 2 lies in a row n <= t, so N(t) is
     computable by a finite search.
  2. Exact small multiplicities: N(2)=1, N(3)=N(4)=N(5)=2, N(6)=3, N(10)=4.
  3. Odd primes occur exactly twice.
  4. The logarithmic upper bound N(t) <= 2 * log2(t).
  5. At most two occurrences per row; hence N(t) <= 2 * #rows(t).
  6. The Fibonacci family solving C(n,k) = C(n-1,k+1), giving infinitely many
     numbers of multiplicity >= 6 (3003 = C(15,5) = C(14,6) is the first).
  7. The Parity Criterion: N(t) is odd  <=>  t is a central binomial C(2m,m).
  8. The Sandwich Theorem: C(2m,m) strictly dominates the truncated triangle.
  9. The effective criterion, with column collapse and triangular obstruction,
     verifying N(C(2m,m)) = 3 for 2 <= m <= 20 -- hence no number below
     C(42,21) = 538,257,874,440 has multiplicity exactly 5 or exactly 7.
 10. Exact multiplicities: N(3003) = 8, N(120) = ... = N(24310) = 6, and the
     maximum of N below 10^6 is 8, attained only at 3003.

Pure standard library; no dependencies.  Run:  python demo.py
"""

from __future__ import annotations

from math import comb, isqrt, factorial, log2
from typing import Dict, Iterable, List, Set, Tuple

Position = Tuple[int, int]


# ---------------------------------------------------------------------------
# 1. Basic occurrence machinery
# ---------------------------------------------------------------------------


def descending_factorial(n: int, k: int) -> int:
    """n^{underline k} = n (n-1) ... (n-k+1); equals k! * C(n,k)."""
    result = 1
    for i in range(k):
        result *= n - i
    return result


def choose_equals(n: int, k: int, t: int) -> bool:
    """Test C(n,k) == t via descending factorials: k multiplications, no big adds."""
    if k > n:
        return t == 0
    return descending_factorial(n, k) == factorial(k) * t


def occurrences(t: int) -> List[Position]:
    """All (n,k) with k <= n and C(n,k) = t, for t >= 2.

    Correctness rests on two facts proved in the paper:
      * every interior entry of row n is at least n, so n <= t;
      * an interior entry with 2 <= k <= n-2 is at least C(n,2), so n < N
        whenever t < C(N,2), which caps the row index at about sqrt(2t).
    """
    if t < 2:
        raise ValueError("multiplicity is only defined (and finite) for t >= 2")
    out: List[Position] = [(t, 1), (t, t - 1)]
    # interior occurrences: 2 <= k <= n-2, row capped by C(n,2) <= t
    n = 4
    while comb(n, 2) <= t:
        for k in range(2, n // 2 + 1):
            if k <= n - 2 and comb(n, k) == t:
                out.append((n, k))
                if k != n - k:
                    out.append((n, n - k))
        n += 1
    return sorted(set(out))


def multiplicity(t: int) -> int:
    """N(t)."""
    return len(occurrences(t))


def rows_of(t: int) -> Set[int]:
    """The set of rows containing t."""
    return {n for n, _ in occurrences(t)}


# ---------------------------------------------------------------------------
# 2. Demonstrations
# ---------------------------------------------------------------------------


def demo_small_values() -> None:
    print("=" * 74)
    print("1.  SMALL MULTIPLICITIES")
    print("=" * 74)
    expected: Dict[int, int] = {2: 1, 3: 2, 4: 2, 5: 2, 6: 3, 10: 4, 120: 6,
                               210: 6, 1540: 6, 3003: 8, 7140: 6, 11628: 6,
                               24310: 6}
    for t, want in expected.items():
        pos = occurrences(t)
        got = len(pos)
        status = "OK " if got == want else "!! "
        shown = ", ".join(f"C({n},{k})" for n, k in pos[:8])
        print(f" {status} N({t:6d}) = {got}   {shown}")
        assert got == want, (t, got, want)
    print()
    print("  2 is the unique number of multiplicity one (every t >= 3 occurs")
    print("  at least twice, as C(t,1) and C(t,t-1)).")
    print()


def demo_primes() -> None:
    print("=" * 74)
    print("2.  ODD PRIMES OCCUR EXACTLY TWICE")
    print("=" * 74)
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59]
    for p in primes:
        m = multiplicity(p)
        assert m == 2, (p, m)
    print(f"  Verified N(p) = 2 for the {len(primes)} odd primes "
          f"{primes[0]}..{primes[-1]}.")
    print("  Reason: C(n,k) = p forces p | n!, hence p <= n; and n <= p always,")
    print("  so n = p; then any interior k gives C(p,2) = p(p-1)/2 > p.")
    print()


def demo_log_bound() -> None:
    print("=" * 74)
    print("3.  THE LOGARITHMIC BOUND   N(t) <= 2 log2(t)")
    print("=" * 74)
    print(f"  {'t':>7} {'N(t)':>5} {'2 log2 t':>10} {'#rows':>6} "
          f"{'2*#rows':>8}   slack")
    worst = 0.0
    for t in range(2, 4000):
        n_t = multiplicity(t)
        bound = 2 * log2(t)
        assert n_t <= bound + 1e-9, (t, n_t, bound)
        ratio = n_t / bound
        worst = max(worst, ratio)
        if n_t >= 6 or t in (2, 3, 6, 10):
            r = len(rows_of(t))
            assert n_t <= 2 * r
            print(f"  {t:>7} {n_t:>5} {bound:>10.2f} {r:>6} {2 * r:>8}"
                  f"   {bound - n_t:>6.2f}")
    print(f"\n  Worst ratio N(t) / (2 log2 t) for t < 4000:  {worst:.3f}")
    print("  (Singmaster's conjecture asks to replace the bound by a constant.)")
    print()


def demo_row_bound() -> None:
    print("=" * 74)
    print("4.  AT MOST TWO OCCURRENCES PER ROW")
    print("=" * 74)
    worst_row = 0
    for n in range(0, 120):
        counts: Dict[int, int] = {}
        for k in range(n + 1):
            v = comb(n, k)
            if v > 1:
                counts[v] = counts.get(v, 0) + 1
        if counts:
            worst_row = max(worst_row, max(counts.values()))
    print(f"  Maximum number of equal entries (> 1) in a single row, rows 0..119:"
          f"  {worst_row}")
    print("  Consequence:  N(t) <= 2 * #{rows meeting t}.  Singmaster's")
    print("  conjecture is therefore EQUIVALENT to bounding the number of rows.")
    print()


# ---------------------------------------------------------------------------
# 3. The Fibonacci family behind the sixes
# ---------------------------------------------------------------------------


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def demo_fibonacci_family() -> None:
    print("=" * 74)
    print("5.  THE FIBONACCI FAMILY:  C(n,k) = C(n-1,k+1)")
    print("=" * 74)
    print("  Clearing factorials, C(n,k) = C(n-1,k+1)  <=>  n(k+1) = (n-k)(n-k-1).")
    print("  Cassini's identity F_{2i+3}^2 = F_{2i+2} F_{2i+4} + 1 supplies")
    print("  the solutions  n = F_{2i+4} F_{2i+5},  k = F_{2i+2} F_{2i+5}.\n")
    for i in range(4):
        n = fib(2 * i + 4) * fib(2 * i + 5)
        k = fib(2 * i + 2) * fib(2 * i + 5)
        assert n * (k + 1) == (n - k) * (n - k - 1)
        assert comb(n, k) == comb(n - 1, k + 1)
        t = comb(n, k)
        digits = len(str(t))
        print(f"  i = {i}:  n = {n:6d},  k = {k:6d}   "
              f"C({n},{k}) = C({n-1},{k+1})   ({digits} digits)")
        if digits <= 12:
            print(f"           value = {t}")
    print("\n  Each such value occupies at least six positions:")
    print("    (n,k), (n,n-k), (n-1,k+1), (n-1,n-k-2), (t,1), (t,t-1).")
    print("  For i = 0 this is 3003 = C(15,5) = C(14,6); 3003 is ALSO the")
    print("  triangular number C(78,2), which supplies the seventh and eighth")
    print("  positions and makes N(3003) = 8.")
    print()


# ---------------------------------------------------------------------------
# 4. The parity criterion
# ---------------------------------------------------------------------------


def central_binomials_upto(limit: int) -> List[int]:
    out, m = [], 1
    while comb(2 * m, m) <= limit:
        out.append(comb(2 * m, m))
        m += 1
    return out


def demo_parity() -> None:
    print("=" * 74)
    print("6.  THE PARITY CRITERION:  N(t) odd  <=>  t = C(2m,m)")
    print("=" * 74)
    limit = 3000
    centrals = set(central_binomials_upto(limit))
    odd_ts = [t for t in range(2, limit + 1) if multiplicity(t) % 2 == 1]
    print(f"  Numbers 2..{limit} with ODD multiplicity: {odd_ts}")
    print(f"  Central binomial coefficients in range:   {sorted(centrals)}")
    assert set(odd_ts) == centrals, (odd_ts, centrals)
    print("  -> the two sets coincide exactly.\n")
    print("  Reason: the reflection (n,k) -> (n,n-k) is an involution of the")
    print("  occurrence set whose only fixed points are central entries (2m,m),")
    print("  so  N(t) = 2 * #(left occurrences) + #(central occurrences),")
    print("  and there is at most one central occurrence because m -> C(2m,m)")
    print("  is strictly increasing.\n")
    print("  CONSEQUENCE: a number of multiplicity 5 or 7 must be a central")
    print("  binomial coefficient -- a density-zero sequence.")
    print()


def demo_sandwich() -> None:
    print("=" * 74)
    print("7.  THE SANDWICH THEOREM")
    print("=" * 74)
    print("  For m >= 1, C(2m,m) strictly exceeds every other entry C(n,k) with")
    print("  k <= n <= 2m.  Hence a repetition can only occur BELOW row 2m.\n")
    for m in range(1, 9):
        t = comb(2 * m, m)
        worst = max(comb(n, k)
                    for n in range(0, 2 * m + 1)
                    for k in range(0, n + 1)
                    if (n, k) != (2 * m, m))
        assert worst < t
        print(f"  m = {m:2d}:  C({2*m},{m}) = {t:7d}   "
              f"largest other entry in rows 0..{2*m} = {worst:7d}")
    print()


# ---------------------------------------------------------------------------
# 5. The effective criterion for N(C(2m,m)) = 3
# ---------------------------------------------------------------------------


def is_perfect_square(x: int) -> bool:
    r = isqrt(x)
    return r * r == x


def central_multiplicity_is_three(m: int, verbose: bool = False) -> bool:
    """Certify N(C(2m,m)) = 3 by the cubic-window criterion.

    Steps (all justified in the paper):
      * Sandwich theorem: any extra occurrence lies in a row n > 2m.
      * Triangular obstruction: the column k = 2 can be excluded outright
        iff 8t+1 is not a perfect square.
      * Column collapse: for n > 2m, 2k <= n and C(n,k) = t we must have k < m.
      * Row window: with k >= 3, C(n,3) <= t caps n by roughly (6t)^{1/3};
        if the column k = 2 survives, we must fall back on n <~ sqrt(2t).
    """
    t = comb(2 * m, m)
    triangular = is_perfect_square(8 * t + 1)
    if triangular:
        # k = 2 must be searched; fall back on the quadratic window.
        n_max = 1
        while comb(n_max, 2) <= t:
            n_max += 1
        k_lo = 2
    else:
        n_max = 3
        while comb(n_max, 3) <= t:
            n_max += 1
        k_lo = 3
    if verbose:
        print(f"    window: rows {2*m+1}..{n_max}, columns {k_lo}..{m-1} "
              f"({'quadratic' if triangular else 'cubic'})")
    for n in range(2 * m + 1, n_max + 1):
        for k in range(k_lo, min(m, n // 2 + 1)):
            if choose_equals(n, k, t):
                return False
    return True


def demo_effective_criterion() -> None:
    print("=" * 74)
    print("8.  EFFECTIVE CRITERION:  N(C(2m,m)) = 3 FOR 2 <= m <= 20")
    print("=" * 74)
    for m in range(2, 21):
        t = comb(2 * m, m)
        ok = central_multiplicity_is_three(m, verbose=(m in (2, 10, 20)))
        assert ok, m
        print(f"  m = {m:2d}:  C({2*m},{m}) = {t:>15d}   N = 3   verified")
    nxt = comb(42, 21)
    print(f"\n  With the parity criterion this gives, UNCONDITIONALLY:")
    print(f"    no t < C(42,21) = {nxt:,} has multiplicity exactly 5 or 7,")
    print(f"    and every odd multiplicity below that bound is 1 or 3.")
    print("  Nineteen finite searches settle half a trillion integers.")
    print()


def demo_box_shrinkage() -> None:
    print("=" * 74)
    print("9.  HOW MUCH THE TWO REDUCTIONS SAVE")
    print("=" * 74)
    print(f"  {'m':>3} {'C(2m,m)':>15} {'naive box':>22} {'reduced box':>16} "
          f"{'saving':>12}")
    for m in (10, 15, 20):
        t = comb(2 * m, m)
        n_quad = 1
        while comb(n_quad, 2) <= t:
            n_quad += 1
        naive = n_quad * (n_quad // 2)
        n_cub = 3
        while comb(n_cub, 3) <= t:
            n_cub += 1
        reduced = max(0, n_cub - 2 * m) * max(0, m - 3)
        print(f"  {m:>3} {t:>15,} {f'{n_quad:,} x {n_quad//2:,}':>22} "
              f"{f'{max(0, n_cub-2*m):,} x {max(0, m-3)}':>16} "
              f"{naive / max(reduced, 1):>11.3g}x")
    print("\n  The column collapse turns a triangle of height ~sqrt(t/2) into a")
    print("  strip of height m; the triangular obstruction removes the column")
    print("  k = 2 with one square test and shrinks the row window from")
    print("  sqrt(2t) to (6t)^{1/3}.")
    print()


# ---------------------------------------------------------------------------
# 6. Maximum below one million
# ---------------------------------------------------------------------------


def demo_max_below_million(limit: int = 100_000) -> None:
    print("=" * 74)
    print(f"10. THE MAXIMUM MULTIPLICITY (scan up to {limit:,})")
    print("=" * 74)
    # Collect all interior entries C(n,k) < limit with 2 <= k <= n/2.
    counts: Dict[int, int] = {}
    n = 4
    while comb(n, 2) < limit:
        for k in range(2, n // 2 + 1):
            v = comb(n, k)
            if v < limit and k <= n - 2:
                counts[v] = counts.get(v, 0) + (1 if 2 * k == n else 2)
        n += 1
    # add the two boundary occurrences for every t >= 3
    best_t, best_n = 0, 0
    histogram: Dict[int, int] = {}
    for t in range(3, limit):
        total = 2 + counts.get(t, 0)
        histogram[total] = histogram.get(total, 0) + 1
        if total > best_n:
            best_t, best_n = t, total
    print("  multiplicity : how many t below the limit attain it")
    for mult_value in sorted(histogram):
        print(f"      {mult_value:>2}        : {histogram[mult_value]:,}")
    print(f"\n  Maximum attained: N({best_t}) = {best_n}.")
    print("  Note the empty rows: NO number attains multiplicity 5 or 7.")
    print("  Proved in the paper: below 10^6 the maximum is 8, attained only")
    print("  at 3003; every other number below 10^6 occurs at most six times.")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  MULTIPLICITIES IN PASCAL'S TRIANGLE  —  NUMERICAL DEMONSTRATION")
    print("#" * 74)
    print()
    demo_small_values()
    demo_primes()
    demo_log_bound()
    demo_row_bound()
    demo_fibonacci_family()
    demo_parity()
    demo_sandwich()
    demo_effective_criterion()
    demo_box_shrinkage()
    demo_max_below_million()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
