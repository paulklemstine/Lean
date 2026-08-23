"""
Finite prefixes determine no asymptotic digit law
=================================================

Numerical demonstration of the constructions and theorems.

Everything below is exact integer / rational arithmetic (no floating point in the
mathematical core), so the printed numbers are certified, not approximate.

Contents
--------
1. The lacunary position set  Lambda = {m : m+1 is a power of two} = {0,1,3,7,15,...}
2. The three designed digit sequences:
       sparse       1 on Lambda, 0 elsewhere              value S
       dense        2 on Lambda, 1 elsewhere              value D = S + 1/9
       alternating  base 1,2,1,2,... bumped by 1 on Lambda value A = S + 4/33
3. Digit recovery: the digits of val(d) are d, when no digit is 9.
4. Nonzero-digit counts against the certified bound log2(M) + 1.
5. Lag-r agreement counts (autocorrelation) for all three witnesses.
6. Grafting a designed tail onto the prefix of sqrt(2), pi or e, and checking that
   the prefix is preserved exactly while the statistics are anything we like.
7. Continuum-many witnesses: distinct bit streams give distinct numbers.

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

DigitRule = Callable[[int], int]


# ----------------------------------------------------------------------------------
# 1. Lacunary positions
# ----------------------------------------------------------------------------------

def is_lacunary(m: int) -> bool:
    """True iff m + 1 is a power of two, i.e. m in {0, 1, 3, 7, 15, 31, ...}."""
    k = m + 1
    return k > 0 and (k & (k - 1)) == 0


def lacunary_positions_below(bound: int) -> List[int]:
    """All lacunary positions m with 0 <= m < bound."""
    out: List[int] = []
    i = 0
    while (2 ** i) - 1 < bound:
        out.append((2 ** i) - 1)
        i += 1
    return out


def int_log2(n: int) -> int:
    """Integer logarithm base two: the largest k with 2^k <= n (and 0 for n = 0)."""
    if n <= 0:
        return 0
    return n.bit_length() - 1


# ----------------------------------------------------------------------------------
# 2. The designed digit sequences
# ----------------------------------------------------------------------------------

def sparse_digit(m: int) -> int:
    """1 at lacunary positions, 0 elsewhere:  S = 0.11010001000000010000...."""
    return 1 if is_lacunary(m) else 0


def dense_digit(m: int) -> int:
    """2 at lacunary positions, 1 elsewhere:  D = S + 1/9 = 0.22121112111111121...."""
    return 2 if is_lacunary(m) else 1


def alt_base_digit(m: int) -> int:
    """The period-two pattern 1, 2, 1, 2, ...  with value 0.121212... = 4/33."""
    return 1 if m % 2 == 0 else 2


def alt_digit(m: int) -> int:
    """Alternating pattern bumped by one on the lacunary positions:  A = S + 4/33."""
    return alt_base_digit(m) + (1 if is_lacunary(m) else 0)


def bit_stream_digit(bits: Sequence[int]) -> DigitRule:
    """Digit rule carrying a bit stream on the lacunary positions (1 or 2), 0 elsewhere."""

    def rule(m: int) -> int:
        if not is_lacunary(m):
            return 0
        i = int_log2(m + 1)
        bit = bits[i] if i < len(bits) else 0
        return 1 if bit else 2

    return rule


def digit_string(rule: DigitRule, count: int) -> str:
    """The first `count` digits of a digit rule, as a string."""
    return "".join(str(rule(m)) for m in range(count))


# ----------------------------------------------------------------------------------
# 3. Values, exactly
# ----------------------------------------------------------------------------------

def truncated_value(rule: DigitRule, count: int) -> Fraction:
    """The exact rational sum_{m<count} d_m 10^{-(m+1)}: a truncation of val(d)."""
    numerator = 0
    for m in range(count):
        numerator = numerator * 10 + rule(m)
    return Fraction(numerator, 10 ** count)


def digits_of_fraction(x: Fraction, count: int) -> List[int]:
    """The first `count` decimal digits of x >= 0, computed by exact integer arithmetic:
       d_m = floor(x * 10^{m+1}) mod 10."""
    assert x >= 0
    out: List[int] = []
    num, den = x.numerator, x.denominator
    for m in range(count):
        num *= 10
        out.append((num // den) % 10)
        num -= (num // den) * den
    return out


def check_digit_recovery(rule: DigitRule, count: int) -> bool:
    """Verify the Digit Recovery Theorem numerically: prescribing digits <= 8 and summing
       the series returns a number whose digits are exactly the prescribed ones.
       We test with a truncation long enough that the tail cannot disturb the first
       `count` digits (the tail is < 10^{-count-10})."""
    approx = truncated_value(rule, count + 10)
    got = digits_of_fraction(approx, count)
    want = [rule(m) for m in range(count)]
    return got == want


# ----------------------------------------------------------------------------------
# 4. Statistics
# ----------------------------------------------------------------------------------

def nonzero_count(rule: DigitRule, bound: int) -> int:
    """#{m < bound : d_m != 0}."""
    return sum(1 for m in range(bound) if rule(m) != 0)


def digit_frequencies(rule: DigitRule, bound: int) -> Dict[int, float]:
    """Empirical frequency of each digit 0..9 among the first `bound` digits."""
    counts = {c: 0 for c in range(10)}
    for m in range(bound):
        counts[rule(m)] += 1
    return {c: counts[c] / bound for c in range(10)}


def agree_count(rule: DigitRule, lag: int, bound: int) -> int:
    """The lag-r agreement count A_r(M) = #{m < M : d_m = d_{m+r}}."""
    return sum(1 for m in range(bound) if rule(m) == rule(m + lag))


# ----------------------------------------------------------------------------------
# 5. Grafting
# ----------------------------------------------------------------------------------

def graft_digits(prefix_digits: Sequence[int], tail_rule: DigitRule) -> DigitRule:
    """Digit rule of the graft: the given prefix, then the designed tail."""
    n = len(prefix_digits)

    def rule(m: int) -> int:
        return prefix_digits[m] if m < n else tail_rule(m - n)

    return rule


def graft_value(x: Fraction, n: int, tail_rule: DigitRule, tail_digits: int) -> Fraction:
    """G(x, n, t) = (floor(x * 10^n) + t) / 10^n, with t truncated at `tail_digits` places.
       Exact rational output; the truncation error is below 10^{-(n + tail_digits)}."""
    head = (x.numerator * 10 ** n) // x.denominator
    tail = truncated_value(tail_rule, tail_digits)
    return Fraction(head) / Fraction(10 ** n) + tail / Fraction(10 ** n)


def decimal_digits_of_constant(name: str, count: int) -> List[int]:
    """The first `count` decimal digits after the point of sqrt(2), pi or e, computed to
       high precision with the decimal module."""
    getcontext().prec = count + 30
    if name == "sqrt2":
        value = Decimal(2).sqrt()
    elif name == "pi":
        # Chudnovsky-free: high-precision arctan (Machin) formula, plenty for a demo.
        value = 4 * (4 * _arctan_inv(5, count + 25) - _arctan_inv(239, count + 25))
    elif name == "e":
        value = _exp_one(count + 25)
    else:
        raise ValueError(f"unknown constant {name}")
    frac = value - int(value)
    out: List[int] = []
    for _ in range(count):
        frac *= 10
        d = int(frac)
        out.append(d)
        frac -= d
    return out


def _arctan_inv(k: int, prec: int) -> Decimal:
    """arctan(1/k) to `prec` digits, by the alternating series."""
    getcontext().prec = prec + 10
    total = Decimal(0)
    term = Decimal(1) / Decimal(k)
    ksq = Decimal(k) * Decimal(k)
    n = 0
    while term != 0:
        total += term / (2 * n + 1) if n % 2 == 0 else -term / (2 * n + 1)
        term /= ksq
        n += 1
        if n > 10 * prec:
            break
    return total


def _exp_one(prec: int) -> Decimal:
    """e to `prec` digits, by the exponential series."""
    getcontext().prec = prec + 10
    total = Decimal(0)
    term = Decimal(1)
    n = 1
    while term != 0:
        total += term
        term /= n
        n += 1
        if n > 10 * prec:
            break
    return total


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------

def demo_witnesses() -> None:
    print("=" * 78)
    print("1. THE THREE DESIGNED WITNESSES (first 48 decimal digits)")
    print("=" * 78)
    print(f"  lacunary positions below 128 : {lacunary_positions_below(128)}")
    print(f"  sparse       S = 0.{digit_string(sparse_digit, 48)}...")
    print(f"  dense        D = 0.{digit_string(dense_digit, 48)}...")
    print(f"  alternating  A = 0.{digit_string(alt_digit, 48)}...")
    print()
    print("  Exact identities (checked to 200 digits of truncation):")
    s200 = truncated_value(sparse_digit, 200)
    d200 = truncated_value(dense_digit, 200)
    a200 = truncated_value(alt_digit, 200)
    one_ninth_200 = truncated_value(lambda m: 1, 200)
    base_200 = truncated_value(alt_base_digit, 200)
    print(f"    D - S = 1/9  (as truncations)   : {d200 - s200 == one_ninth_200}")
    print(f"    A - S = 0.121212... = 4/33      : {a200 - s200 == base_200}")
    print(f"    0.1212... truncation vs 4/33    : "
          f"{abs(base_200 - Fraction(4, 33)) < Fraction(1, 10 ** 199)}")
    print()


def demo_digit_recovery() -> None:
    print("=" * 78)
    print("2. DIGIT RECOVERY:  prescribed digits (all <= 8) are the digits you get")
    print("=" * 78)
    for name, rule in (("sparse", sparse_digit), ("dense", dense_digit),
                       ("alternating", alt_digit)):
        ok = check_digit_recovery(rule, 60)
        print(f"  {name:12s}: recovered first 60 digits exactly -> {ok}")
    print()
    print("  Necessity of excluding the digit 9:")
    nines = truncated_value(lambda m: 9, 40)
    gap = Fraction(1) - nines
    print("    val(9,9,9,...) = 1 exactly, whose digits are all 0.")
    print(f"    the truncation to 40 nines falls short of 1 by exactly {gap} = 10^-40,")
    print("    and the limit is 1, so digit recovery fails for the all-nines sequence:")
    print("    0.999... = 1.000...  This is why the hypothesis 'no digit equals 9' is needed.")
    print()


def demo_frequency() -> None:
    print("=" * 78)
    print("3. NONZERO-DIGIT COUNTS vs THE CERTIFIED BOUND  log2(M) + 1")
    print("=" * 78)
    print(f"  {'M':>8} {'sparse nonzero':>16} {'bound':>8} {'dense zeros':>13}")
    for M in (10, 100, 1000, 10000, 100000):
        print(f"  {M:>8} {nonzero_count(sparse_digit, M):>16} "
              f"{int_log2(M) + 1:>8} {M - nonzero_count(dense_digit, M):>13}")
    print()
    print("  The bound is attained exactly: the sparse witness is extremal.")
    print("  Densities: sparse nonzero-density -> 0, dense nonzero-density -> 1.")
    print()
    print("  Digit frequencies at M = 10000 (simple normality would give 0.1 for each):")
    for name, rule in (("sparse", sparse_digit), ("dense", dense_digit)):
        freq = digit_frequencies(rule, 10000)
        shown = ", ".join(f"{c}:{freq[c]:.4f}" for c in range(4))
        print(f"    {name:8s} {shown}, others 0.0000")
    print("  Neither is simply normal, yet both are irrational.")
    print()


def demo_autocorrelation() -> None:
    print("=" * 78)
    print("4. AUTOCORRELATION:  A_r(M) / M  for the witnesses")
    print("=" * 78)
    lags = (1, 2, 3, 7)
    for name, rule in (("sparse", sparse_digit), ("dense", dense_digit),
                       ("alternating", alt_digit)):
        print(f"  {name}:")
        for M in (100, 1000, 10000):
            row = "  ".join(
                f"r={r}: {agree_count(rule, r, M) / M:.4f}" for r in lags)
            print(f"    M = {M:>6}   {row}")
    print()
    print("  Alternating witness: lag-1 density -> 0, lag-2 density -> 1.")
    print("  Dense witness      : density -> 1 at EVERY lag.")
    print("  A 'random' sequence would give 0.1 at every lag; none of these does.")
    print()
    print("  Certified disagreement bound for the dense witness, n = 0:")
    print(f"  {'M':>8} {'r':>3} {'disagreements':>15} {'bound n+r+3+2log2 M':>22}")
    for M in (1000, 10000):
        for r in (1, 3, 7):
            dis = M - agree_count(dense_digit, r, M)
            bound = 0 + r + 3 + 2 * int_log2(M)
            print(f"  {M:>8} {r:>3} {dis:>15} {bound:>22}")
    print()


def demo_grafting() -> None:
    print("=" * 78)
    print("5. GRAFTING ONTO THE PREFIX OF sqrt(2), pi AND e")
    print("=" * 78)
    n = 20
    for name in ("sqrt2", "pi", "e"):
        prefix = decimal_digits_of_constant(name, n)
        pretty = "".join(map(str, prefix))
        print(f"  {name}: first {n} digits = 0.{pretty}")
        for wname, rule in (("sparse graft ", sparse_digit),
                            ("dense graft  ", dense_digit),
                            ("alt graft    ", alt_digit),
                            ("rational graft", lambda m: 0)):
            g = graft_digits(prefix, rule)
            head = "".join(str(g(m)) for m in range(n))
            tail = "".join(str(g(m)) for m in range(n, n + 24))
            assert head == pretty, "prefix must be preserved exactly"
            print(f"    {wname}: 0.{head}|{tail}...")
        print()
    print("  Prefix identical in every case; asymptotics completely different:")
    prefix = decimal_digits_of_constant("pi", n)
    M = 20000
    for wname, rule in (("sparse graft", sparse_digit),
                        ("dense graft ", dense_digit),
                        ("alt graft   ", alt_digit)):
        g = graft_digits(prefix, rule)
        nz = nonzero_count(g, M) / M
        a1 = agree_count(g, 1, M) / M
        a2 = agree_count(g, 2, M) / M
        print(f"    {wname}: nonzero density ~ {nz:.4f}   "
              f"lag-1 ~ {a1:.4f}   lag-2 ~ {a2:.4f}   (M = {M})")
    print()
    print("  Numerically, the grafts sit within 10^-20 of pi's fractional part:")
    pi_frac = Fraction(sum(d * 10 ** (n - 1 - i) for i, d in enumerate(prefix)), 10 ** n)
    for wname, rule in (("sparse graft", sparse_digit), ("dense graft ", dense_digit)):
        g = graft_value(pi_frac, n, rule, 60)
        print(f"    |{wname} - truncated pi| = {float(abs(g - pi_frac)):.3e}  (< 1e-20)")
    print()


def demo_continuum() -> None:
    print("=" * 78)
    print("6. CONTINUUM MANY WITNESSES SHARING ANY PREFIX")
    print("=" * 78)
    prefix = decimal_digits_of_constant("sqrt2", 12)
    pretty = "".join(map(str, prefix))
    print(f"  prefix of sqrt(2): 0.{pretty}")
    streams: List[Tuple[str, List[int]]] = [
        ("0000000000", [0] * 10),
        ("1111111111", [1] * 10),
        ("1010101010", [1, 0] * 5),
        ("1101001000", [1, 1, 0, 1, 0, 0, 1, 0, 0, 0]),
    ]
    seen = set()
    for label, bits in streams:
        rule = graft_digits(prefix, bit_stream_digit(bits))
        head = "".join(str(rule(m)) for m in range(12))
        tail = "".join(str(rule(m)) for m in range(12, 12 + 32))
        val = truncated_value(rule, 80)
        seen.add(val)
        nz = nonzero_count(rule, 20000) / 20000
        print(f"  bits {label}: 0.{head}|{tail}...   nonzero density ~ {nz:.5f}")
    print(f"  distinct values among the four samples: {len(seen)} of 4")
    print("  Each bit stream gives a different irrational, non-simply-normal number")
    print("  with the same 12-digit prefix; there are 2^aleph_0 of them.")
    print()


def demo_periodicity() -> None:
    print("=" * 78)
    print("7. IRRATIONALITY IS EXACTLY APERIODICITY")
    print("=" * 78)
    print("  A rational number's expansion is eventually periodic; an irrational's is not.")
    for frac in (Fraction(1, 7), Fraction(4, 33), Fraction(1, 9)):
        digs = digits_of_fraction(frac, 30)
        print(f"    {frac} = 0.{''.join(map(str, digs))}...  (eventually periodic)")
    print()
    print("  The sparse witness is irrational, so its digits are NOT eventually periodic,")
    print("  even though a density-one proportion of them are zeros:")
    print(f"    S = 0.{digit_string(sparse_digit, 64)}...")
    print("  Aperiodicity is compatible with complete statistical degeneracy: that is")
    print("  exactly why a finite prefix can never certify a digit law.")
    print()


def main() -> None:
    print()
    print("FINITE PREFIXES DETERMINE NO ASYMPTOTIC DIGIT LAW")
    print("numerical demonstration")
    print()
    demo_witnesses()
    demo_digit_recovery()
    demo_frequency()
    demo_autocorrelation()
    demo_grafting()
    demo_continuum()
    demo_periodicity()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  * Prescribed digit sequences avoiding the digit 9 are realised exactly.")
    print("  * Lacunary support (positions 2^i - 1) gives irrationality with density 0.")
    print("  * Adding 1/9 gives irrationality with nonzero-digit density 1.")
    print("  * Adding 4/33 gives an irrational with lag-1 correlation 0, lag-2 correlation 1.")
    print("  * Grafting transplants any of these tails onto any prefix, exactly.")
    print("  * Hence no finite prefix determines rationality, frequency, normality or")
    print("    autocorrelation -- and uncountably many witnesses share every prefix.")
    print()


if __name__ == "__main__":
    main()
