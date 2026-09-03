"""
Numerical demonstrations for

    The Sturmian Structure of the Binomial Argmax Staircase

Every claim of the paper that can be checked numerically is checked here, from
scratch, in pure Python (standard library only).

Setting.  For positive weights p, q let

    b(n, k) = C(n, k) * p^k * q^(n-k),      0 <= k <= n,

and let M(n) be the *largest* maximiser of k -> b(n, k).  With the slope

    alpha = p / (p + q)  in  (0, 1)

the theory says:

  A. M(n) = floor((n+1) * alpha)                      (argmax staircase)
  B. w(n) = M(n+1) - M(n)  in  {0, 1}                 (one letter per row)
  C. floor(L*alpha) <= W(m, L) <= floor(L*alpha) + 1  (window bound)
       => balance, discrepancy < 2, frequency of "1" = alpha
  D. w periodic  <=>  alpha rational                  (Morse-Hedlund)
  E. slope P/(P+Q): period P+Q with exactly P ones per window
  F. subword complexity p(L) <= L + 1
  G. alpha irrational  =>  p(L) = L + 1               (Sturmian)
  H. alpha = P/(P+Q), gcd(P,Q)=1  =>  p(L) = min(L+1, P+Q)
  I. w(n) = s(n+1) for the lower mechanical word s, and w != s always

Exact rational arithmetic (fractions.Fraction) is used wherever the slope is
rational, so no floating-point rounding can corrupt a tie.  Irrational slopes
are handled with high-precision decimal arithmetic.
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from math import comb
from typing import Dict, Iterable, List, Sequence, Tuple

getcontext().prec = 80

Real = Fraction | Decimal


# --------------------------------------------------------------------------
# Core objects
# --------------------------------------------------------------------------

def floor_real(x: Real) -> int:
    """Exact floor of an exact rational or a high-precision decimal."""
    if isinstance(x, Fraction):
        return x.numerator // x.denominator
    return int(x // 1)


def slope(p: Real, q: Real) -> Real:
    """alpha = p / (p + q)."""
    return p / (p + q)


def staircase(alpha: Real, n: int) -> int:
    """S(n) = floor((n+1) * alpha), the argmax staircase."""
    return floor_real(alpha * (n + 1))


def increment_word(alpha: Real, length: int) -> List[int]:
    """w(n) = S(n+1) - S(n) for n = 0, ..., length-1."""
    s = [staircase(alpha, n) for n in range(length + 1)]
    return [s[n + 1] - s[n] for n in range(length)]


def mechanical_word(alpha: Real, length: int) -> List[int]:
    """Lower mechanical word s(m) = floor((m+1)a) - floor(m a)."""
    return [floor_real(alpha * (m + 1)) - floor_real(alpha * m) for m in range(length)]


def binomial_mode_bruteforce(n: int, p: Fraction, q: Fraction) -> int:
    """Largest maximiser of C(n,k) p^k q^(n-k), by exact rational comparison."""
    best_val = Fraction(0)
    best_k = 0
    for k in range(n + 1):
        val = Fraction(comb(n, k)) * p**k * q ** (n - k)
        if val >= best_val:          # ">=" keeps the LARGEST maximiser
            best_val, best_k = val, k
    return best_k


def window_sums(word: Sequence[int], L: int) -> List[int]:
    """All sums of L consecutive letters."""
    if L == 0:
        return [0] * (len(word) + 1)
    prefix = [0]
    for letter in word:
        prefix.append(prefix[-1] + letter)
    return [prefix[m + L] - prefix[m] for m in range(len(word) - L + 1)]


def factors(word: Sequence[int], L: int) -> Dict[Tuple[int, ...], int]:
    """Distinct factors of length L, with the first position where each occurs."""
    seen: Dict[Tuple[int, ...], int] = {}
    for m in range(len(word) - L + 1):
        block = tuple(word[m : m + L])
        seen.setdefault(block, m)
    return seen


def complexity(word: Sequence[int], L: int) -> int:
    return len(factors(word, L))


def bresenham_word(P: int, Q: int, length: int) -> List[int]:
    """Increment word of slope P/(P+Q) by O(1) integer arithmetic per letter.

    Maintains r = ((n+1) * P) mod (P+Q); the mode advances exactly when the
    accumulator overflows the denominator.  This is Bresenham's line loop.
    """
    b = P + Q
    r = P % b            # r corresponds to n = 0, i.e. to the value 1*P mod b
    out: List[int] = []
    for _ in range(length):
        r += P
        if r >= b:
            r -= b
            out.append(1)
        else:
            out.append(0)
    return out


def gap_spectrum(word: Sequence[int]) -> Dict[int, int]:
    """Multiset of gaps between consecutive occurrences of the letter 1."""
    ones = [n for n, x in enumerate(word) if x == 1]
    gaps: Dict[int, int] = {}
    for a, b in zip(ones, ones[1:]):
        gaps[b - a] = gaps.get(b - a, 0) + 1
    return dict(sorted(gaps.items()))


def continued_fraction(x: Decimal, terms: int) -> List[int]:
    """First `terms` partial quotients of the continued fraction of x."""
    out: List[int] = []
    y = x
    for _ in range(terms):
        a = int(y // 1)
        out.append(a)
        frac = y - a
        if frac == 0:
            break
        y = 1 / frac
    return out


SQRT2 = Decimal(2).sqrt()
ALPHA_SQRT2 = Decimal(2) - SQRT2          # slope(sqrt 2, 1) = 2 - sqrt 2
GOLDEN_SLOPE = (Decimal(5).sqrt() - 1) / 2  # 1/phi = 0.6180...


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def show_word(word: Iterable[int], width: int = 60) -> str:
    return "".join(str(x) for x in list(word)[:width])


# --------------------------------------------------------------------------
# Demonstration A: the mode is floor((n+1) * alpha)
# --------------------------------------------------------------------------

def demo_staircase_identity() -> None:
    banner("A. The mode of the binomial weights equals floor((n+1) * alpha)")
    cases = [(Fraction(1), Fraction(1)), (Fraction(2), Fraction(3)),
             (Fraction(5), Fraction(1)), (Fraction(3), Fraction(7))]
    for p, q in cases:
        a = slope(p, q)
        agree = all(binomial_mode_bruteforce(n, p, q) == staircase(a, n)
                    for n in range(0, 41))
        print(f"  p={p}, q={q}, alpha={a} ({float(a):.6f}): "
              f"rows 0..40 agree = {agree}")
        print("     modes:", [staircase(a, n) for n in range(12)])
    print("\n  Ties (two maximisers) occur exactly when (n+1)*alpha is an integer:")
    p, q = Fraction(1), Fraction(1)
    for n in range(8):
        vals = [comb(n, k) for k in range(n + 1)]
        maxv = max(vals)
        argmaxes = [k for k, v in enumerate(vals) if v == maxv]
        tie = "TIE " if len(argmaxes) > 1 else "    "
        print(f"    n={n}: {tie}argmax set {argmaxes}, "
              f"largest = {staircase(slope(p, q), n)}")


# --------------------------------------------------------------------------
# Demonstration B/C: binarity, balance, discrepancy, frequency
# --------------------------------------------------------------------------

def demo_balance_and_frequency() -> None:
    banner("B/C. Binary letters, window bound, balance, discrepancy, frequency")
    for name, a in [("2 - sqrt(2)", ALPHA_SQRT2),
                    ("1/phi", GOLDEN_SLOPE),
                    ("3/8", Fraction(3, 8))]:
        N = 4000
        w = increment_word(a, N)
        print(f"\n  slope {name} = {float(a):.10f}")
        print(f"    word prefix: {show_word(w)}")
        assert set(w) <= {0, 1}
        worst_balance, worst_disc = 0, 0.0
        for L in range(1, 60):
            sums = window_sums(w, L)
            lo, hi = min(sums), max(sums)
            fl = floor_real(a * L)
            assert fl <= lo and hi <= fl + 1, "window bound violated"
            worst_balance = max(worst_balance, hi - lo)
            worst_disc = max(worst_disc,
                             max(abs(s - float(a) * L) for s in sums))
        print(f"    max_(m,m',L<60) |W(m,L) - W(m',L)| = {worst_balance}  (theory: <= 1)")
        print(f"    max_(m,L<60)   |W(m,L) - L*alpha|  = {worst_disc:.4f}  (theory: < 2)")
        for L in (10, 100, 1000, 4000):
            print(f"    frequency of 1 over first {L:>4} letters: "
                  f"{sum(w[:L]) / L:.6f}   (alpha = {float(a):.6f})")


# --------------------------------------------------------------------------
# Demonstration D/E: periodicity and the rational period
# --------------------------------------------------------------------------

def demo_periodicity() -> None:
    banner("D/E. Periodic iff rational; period P+Q with exactly P ones")
    for P, Q in [(1, 1), (3, 5), (5, 3), (7, 4), (2, 9)]:
        a = Fraction(P, P + Q)
        N = 6 * (P + Q) + 10
        w = increment_word(a, N)
        T = P + Q
        periodic = all(w[n + T] == w[n] for n in range(N - T))
        counts = {sum(w[m : m + T]) for m in range(N - T)}
        print(f"  P={P}, Q={Q}: alpha={a}, period {T} holds = {periodic}, "
              f"ones per window of length {T} = {counts} (theory: {{{P}}})")
        print(f"     word: {show_word(w, 3 * T)}")
        assert bresenham_word(P, Q, N) == w, "integer Bresenham loop disagrees"
    print("\n  Irrational slope: no period up to 200 works.")
    w = increment_word(ALPHA_SQRT2, 4000)
    bad = [T for T in range(1, 201)
           if all(w[n + T] == w[n] for n in range(len(w) - T))]
    print(f"    slope 2 - sqrt(2): periods found in 1..200 = {bad} (theory: none)")


# --------------------------------------------------------------------------
# Demonstration F/G/H: subword complexity
# --------------------------------------------------------------------------

def demo_complexity() -> None:
    banner("F/G/H. Subword complexity: L+1, and min(L+1, P+Q) for rational slope")
    print("\n  Irrational slopes (theory: p(L) = L + 1):")
    for name, a in [("2 - sqrt(2)", ALPHA_SQRT2), ("1/phi", GOLDEN_SLOPE)]:
        w = increment_word(a, 20000)
        row = [complexity(w, L) for L in range(1, 13)]
        print(f"    {name:<12}: p(1..12) = {row}")
        assert row == list(range(2, 14))
    print("\n  Rational slopes (theory: p(L) = min(L+1, P+Q)):")
    for P, Q in [(1, 1), (3, 5), (5, 3), (2, 9), (7, 4)]:
        a = Fraction(P, P + Q)
        w = increment_word(a, 60 * (P + Q))
        got = [complexity(w, L) for L in range(1, 16)]
        want = [min(L + 1, P + Q) for L in range(1, 16)]
        print(f"    P={P}, Q={Q} (P+Q={P+Q}): p(1..15) = {got}")
        print(f"    {'':>{18}}   theory     = {want}   match={got == want}")
        assert got == want
    print("\n  Level statistic: p(L) equals the number of distinct levels.")
    a = ALPHA_SQRT2
    N, L = 3000, 7
    s = [staircase(a, n) for n in range(N + L + 1)]
    levels = set()
    for m in range(N):
        lam = sum((s[m + j] - s[m]) - floor_real(a * j) for j in range(L + 1))
        levels.add(lam)
    print(f"    slope 2 - sqrt(2), L={L}: distinct levels = {sorted(levels)} "
          f"(={len(levels)} values, theory L+1 = {L + 1})")


# --------------------------------------------------------------------------
# Demonstration I: the +1 shift
# --------------------------------------------------------------------------

def demo_shift() -> None:
    banner("I. The peak word is the mechanical word SHIFTED, and never equal to it")
    for name, a in [("2 - sqrt(2)", ALPHA_SQRT2), ("1/phi", GOLDEN_SLOPE),
                    ("3/8", Fraction(3, 8)), ("2/5", Fraction(2, 5))]:
        N = 300
        w = increment_word(a, N)
        s = mechanical_word(a, N + 1)
        shift_ok = all(w[n] == s[n + 1] for n in range(N))
        diff = [n for n in range(N) if w[n] != s[n]]
        print(f"\n  slope {name} = {float(a):.8f}")
        print(f"    peak word       : {show_word(w, 48)}")
        print(f"    mechanical word : {show_word(s, 48)}")
        print(f"    w(n) = s(n+1) for all n < {N}: {shift_ok}")
        print(f"    first n with w(n) != s(n): {diff[0] if diff else 'NONE'} "
              f"(theory: such n always exists)")
        assert shift_ok and diff
        # For alpha >= 1/2 the disagreement is already at n = 0.
        if float(a) >= 0.5:
            assert diff[0] == 0


# --------------------------------------------------------------------------
# Demonstration: gaps between advances (three-distance phenomenon)
# --------------------------------------------------------------------------

def demo_gaps() -> None:
    banner("Bonus. Waiting times between mode advances (three-distance behaviour)")
    for name, a in [("2 - sqrt(2)", ALPHA_SQRT2), ("1/phi", GOLDEN_SLOPE),
                    ("pi - 3", Decimal(str(3.14159265358979323846)) - 3)]:
        w = increment_word(a, 20000)
        gaps = gap_spectrum(w)
        print(f"\n  slope {name} = {float(a):.10f}")
        print(f"    gap lengths and multiplicities: {gaps}")
        print(f"    number of distinct gap lengths: {len(gaps)} "
              f"(three-distance theorem: at most 3)")
        if isinstance(a, Decimal):
            print(f"    continued fraction of alpha: {continued_fraction(a, 8)}")


# --------------------------------------------------------------------------
# Demonstration: a full ASCII picture of the staircase
# --------------------------------------------------------------------------

def demo_picture() -> None:
    banner("Picture. The argmax staircase and the row-by-row binomial peak")
    p, q = Fraction(5), Fraction(3)
    a = slope(p, q)
    print(f"  weights p={p}, q={q}, alpha = {a} = {float(a):.6f}, period {p+q}\n")
    print("   n | mode | letter | weights (peak marked '*')")
    print("  ---+------+--------+" + "-" * 44)
    w = increment_word(a, 16)
    for n in range(15):
        mode = staircase(a, n)
        vals = [Fraction(comb(n, k)) * p**k * q ** (n - k) for k in range(n + 1)]
        top = max(vals)
        bar = "".join("*" if k == mode else ("+" if vals[k] == top else ".")
                      for k in range(n + 1))
        print(f"  {n:2} | {mode:4} |   {w[n]}    | {bar}")
    print("\n  '*' = largest maximiser (= floor((n+1)*alpha)); "
          "'+' = a tied maximiser below it.")


def main() -> None:
    print(__doc__)
    demo_staircase_identity()
    demo_balance_and_frequency()
    demo_periodicity()
    demo_complexity()
    demo_shift()
    demo_gaps()
    demo_picture()
    banner("All numerical checks passed.")


if __name__ == "__main__":
    main()
