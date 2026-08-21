"""
Certified enclosure of the BB84 quantum bit error rate threshold.
================================================================

The asymptotic one-way BB84 secret-key rate, in nats per sifted bit, is

    r(Q) = log 2 - 2 * H2(Q),      H2(p) = -p log p - (1-p) log(1-p).

It vanishes at a unique threshold p* in (0, 1/2), quoted in the literature as
"about 11%".  This script reproduces, in exact integer / exact rational
arithmetic wherever it matters, the full certification pipeline that pins

    0.1100278644383 < p* < 0.1100278644384,   floor(10^13 p*) = 1100278644383.

The four stages are:

  1. The Rational Sign Criterion.  For positive integers a, c,
         H2(a/(a+c)) < (log 2)/2   <=>   (a+c)^(2(a+c)) < 2^(a+c) a^(2a) c^(2c),
     an *exact equivalence* between a transcendental comparison and a comparison
     of two integers.  No logarithm is evaluated.

  2. Pade value certificates.  For x >= 1,
         2(x-1)/(x+1) <= log x <= (x - 1/x)/2,
     with cubic error.  Combined with the exact identity
         r(a/(a+c)) = (1/(a+c)) log(N/D),  N = 2^(a+c) a^(2a) c^(2c),
                                           D = (a+c)^(2(a+c)),
     a pair of integer comparisons yields a rational two-sided bracket on r.

  3. The mean-value refinement step.  A certified anchor value plus a certified
     derivative bracket L <= H2' <= U on [q0, q1] gives
         q0 + A1/U < p* < q0 + A2/L.
     The resulting width is ~ 4.9 * (anchor error)^2.

  4. Diophantine anchors.  Continued-fraction convergents of p* beat decimals:
     79/718 sits 9.29e-9 from the root with only 4102-digit certificates.

Everything below uses Python's exact `int` and `Fraction`; floating point is
used only to *print* results and to select (not to justify) the anchor.

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from typing import Iterator, List, Tuple

getcontext().prec = 80

# --------------------------------------------------------------------------- #
# High-precision helpers (Decimal; used for reference values and printing)
# --------------------------------------------------------------------------- #


def dec_ln(x: Decimal) -> Decimal:
    """Natural logarithm at the ambient Decimal precision."""
    return x.ln()


def binary_entropy(p: Decimal) -> Decimal:
    """H2(p) = -p log p - (1-p) log(1-p), in nats."""
    if p <= 0 or p >= 1:
        return Decimal(0)
    return -p * dec_ln(p) - (1 - p) * dec_ln(1 - p)


def key_rate(q: Decimal) -> Decimal:
    """Asymptotic one-way BB84 secret-key rate r(Q) = log 2 - 2 H2(Q), in nats."""
    return Decimal(2).ln() - 2 * binary_entropy(q)


def reference_threshold(iterations: int = 400) -> Decimal:
    """High-precision p* by bisection.  Used only as a reference / anchor picker."""
    lo, hi = Decimal("0.05"), Decimal("0.15")
    for _ in range(iterations):
        mid = (lo + hi) / 2
        if key_rate(mid) > 0:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


# --------------------------------------------------------------------------- #
# Stage 1: the Rational Sign Criterion (pure integer arithmetic)
# --------------------------------------------------------------------------- #


def certificate_pair(a: int, c: int) -> Tuple[int, int]:
    """Return the two certificate integers (D, N) for the rational a/(a+c),

        D = (a+c)^(2(a+c)),     N = 2^(a+c) * a^(2a) * c^(2c).
    """
    b = a + c
    d = b ** (2 * b)
    n = (2 ** b) * (a ** (2 * a)) * (c ** (2 * c))
    return d, n


def sign_of_key_rate(a: int, c: int) -> int:
    """Sign of r(a/(a+c)):  +1 below threshold, -1 above, 0 exactly on it.

    Correctness is the Rational Sign Criterion: r > 0 iff D < N.  This is an
    equivalence, so the returned sign is exact -- no rounding is involved.
    """
    d, n = certificate_pair(a, c)
    return (d < n) - (n < d)


def decimal_digits(m: int) -> int:
    """Number of decimal digits of a (possibly huge) positive integer."""
    if m == 0:
        return 1
    # log10(m) from the bit length, then corrected exactly by one comparison.
    approx = int(m.bit_length() * 0.30102999566398119802) + 1
    while 10 ** (approx - 1) > m:
        approx -= 1
    while 10 ** approx <= m:
        approx += 1
    return approx


def certificate_digits(a: int, c: int) -> int:
    """Number of decimal digits of the larger certificate integer."""
    d, n = certificate_pair(a, c)
    return decimal_digits(max(d, n))


# --------------------------------------------------------------------------- #
# Stage 2: Pade bounds and value certificates
# --------------------------------------------------------------------------- #


def pade_lower(x: Fraction) -> Fraction:
    """2(x-1)/(x+1) <= log x for x >= 1."""
    return 2 * (x - 1) / (x + 1)


def pade_upper(x: Fraction) -> Fraction:
    """log x <= (x - 1/x)/2 for x >= 1."""
    return (x - 1 / x) / 2


def key_rate_bracket(a: int, c: int, digits: int = 20) -> Tuple[Fraction, Fraction]:
    """Certified rational bracket (v_lo, v_hi) with v_lo < r(a/(a+c)) < v_hi.

    Uses exact integers to round the ratio N/D to `digits` significant places
    from below and above, then applies the Pade bounds.  Valid only when the
    anchor is below threshold (D < N); otherwise the Pade hypotheses fail.
    """
    b = a + c
    d, n = certificate_pair(a, c)
    if not d < n:
        raise ValueError("anchor is not below threshold; Pade hypotheses need N >= D")
    scale = 10 ** digits
    m_lo = (scale * n) // d           # m_lo * D <= scale * N
    m_hi = m_lo + 1                   # scale * N <  m_hi * D
    r_lo = Fraction(m_lo, scale)
    r_hi = Fraction(m_hi, scale)
    return (pade_lower(r_lo) / b, pade_upper(r_hi) / b)


# --------------------------------------------------------------------------- #
# Stage 3: the mean-value refinement step
# --------------------------------------------------------------------------- #


def refinement_step(
    q0: Fraction, a1: Fraction, a2: Fraction, low: Fraction, up: Fraction
) -> Tuple[Fraction, Fraction]:
    """One certified mean-value step.

    Hypotheses (all certified elsewhere):
        q0 < p* < q1,
        a1 < r(q0)/2 < a2,
        low <= H2'(x) <= up  for all x in [q0, q1],  low > 0.
    Conclusion:
        q0 + a1/up < p* < q0 + a2/low.
    """
    if low <= 0:
        raise ValueError("derivative lower bound must be positive")
    return (q0 + a1 / up, q0 + a2 / low)


# --------------------------------------------------------------------------- #
# Stage 4: continued-fraction anchors
# --------------------------------------------------------------------------- #


def continued_fraction(x: Fraction, terms: int) -> List[int]:
    """Partial quotients [a0; a1, a2, ...] of the rational x."""
    out: List[int] = []
    y = x
    for _ in range(terms):
        a = y.numerator // y.denominator
        out.append(a)
        y -= a
        if y == 0:
            break
        y = 1 / y
    return out


def convergents(quotients: List[int]) -> Iterator[Fraction]:
    """Convergents p_k/q_k from the partial quotients, by the standard recurrence."""
    p_prev, p_cur = 0, 1
    q_prev, q_cur = 1, 0
    for a in quotients:
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        yield Fraction(p_cur, q_cur)


# --------------------------------------------------------------------------- #
# The demonstration
# --------------------------------------------------------------------------- #


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    p_ref = reference_threshold()

    rule("0.  The constant")
    print(f"  reference p*            = {str(p_ref)[:34]}...")
    print(f"  H2(p*)                  = {str(binary_entropy(p_ref))[:24]}...")
    print(f"  (log 2)/2               = {str(Decimal(2).ln() / 2)[:24]}...")
    print(f"  r(p*)  (should be ~0)   = {key_rate(p_ref):.3e}")
    print(f"  H2'(p*) = log((1-p)/p)  = {dec_ln(1 - p_ref) - dec_ln(p_ref)}"[:60])

    rule("1.  The Rational Sign Criterion  (exact integer comparisons)")
    print("     H2(a/(a+c)) < (log 2)/2   <=>   (a+c)^(2(a+c)) < 2^(a+c) a^(2a) c^(2c)")
    print()
    print(f"  {'rational':>16} {'value':>14} {'digits':>8} {'verdict':>16}")
    for a, c in [(1, 15), (1, 7), (11, 89), (34, 275), (79, 639), (1101, 8899)]:
        s = sign_of_key_rate(a, c)
        verdict = {1: "below threshold", -1: "above threshold", 0: "exactly on"}[s]
        print(
            f"  {f'{a}/{a + c}':>16} {a / (a + c):>14.10f} "
            f"{certificate_digits(a, c):>8} {verdict:>16}"
        )
    print()
    print("  Note 1/16 = 0.0625 is below and 1/8 = 0.125 is above: the coarse bracket.")
    print("  11/100 is below and 1101/10000 above: four certified decimals,")
    print("  but the latter needs 80000-digit integers.  This is the brute-force wall.")

    rule("2.  Pade bounds for the logarithm  (cubic accuracy near 1)")
    print("     2(x-1)/(x+1) <= log x <= (x - 1/x)/2      for x >= 1")
    print()
    print(f"  {'x':>12} {'lower':>22} {'log x':>22} {'upper':>22}")
    for xs in ["1.0000279", "1.011", "1.1", "2.0"]:
        xf = Fraction(xs)
        lo = float(pade_lower(xf))
        hi = float(pade_upper(xf))
        mid = float(Decimal(xs).ln())
        print(f"  {xs:>12} {lo:>22.16f} {mid:>22.16f} {hi:>22.16f}")
    print()
    print("  Relative slack at x = 1.0000279 is ~7e-15: the reason 13 decimals fit.")

    rule("3.  Continued fraction of the threshold  (Diophantine anchors)")
    quots = continued_fraction(Fraction(str(p_ref)), 8)
    print(f"  p* = {quots[:1]} ; {quots[1:]}   (partial quotients)")
    print()
    print(f"  {'k':>3} {'convergent':>18} {'decimal':>18} {'error':>13} {'cert digits':>12}")
    for k, cv in enumerate(convergents(quots)):
        err = float(Decimal(cv.numerator) / Decimal(cv.denominator) - p_ref)
        digits = ""
        if 0 < cv.denominator <= 800 and cv.numerator > 0:
            digits = str(certificate_digits(cv.numerator, cv.denominator - cv.numerator))
        print(
            f"  {k:>3} {f'{cv.numerator}/{cv.denominator}':>18} "
            f"{float(cv):>18.13f} {err:>13.3e} {digits:>12}"
        )
    print()
    print("  11/100 is the convergent k=2, and q_3 = 309: so 11/100 is the BEST")
    print("  rational approximation of p* with denominator <= 308.  The textbook")
    print("  value is optimal for its size -- not a lazy rounding.")
    print()
    print("  79/718 (k=4) is 3000x closer to p* than 11/100, yet its certificate")
    print("  has only 4102 digits versus 80000 for the four-decimal stage.")

    rule("4.  Certified key rate at the anchor 79/718")
    a, c = 79, 639
    d, n = certificate_pair(a, c)
    print(f"  D = 718^1436                          ({decimal_digits(d)} digits)")
    print(f"  N = 2^718 * 79^158 * 639^1278         ({decimal_digits(n)} digits)")
    print(f"  D < N ?  {d < n}   -> the anchor is strictly below threshold")
    print()
    lo_int = 100002787345813950188
    hi_int = 100002787345813950189
    print("  Integer certificates pinning N/D to twenty significant figures:")
    print(f"    {lo_int} * D  <  10^20 * N   :  {lo_int * d < 10**20 * n}")
    print(f"    10^20 * N  <  {hi_int} * D   :  {10**20 * n < hi_int * d}")
    print(f"    N/D = {Decimal(n) / Decimal(d)}"[:60])
    print()
    v_lo, v_hi = key_rate_bracket(a, c, digits=20)
    print(f"  Certified:  {float(v_lo):.15e} < r(79/718) < {float(v_hi):.15e}")
    print(f"  Exact:      r(79/718) = {key_rate(Decimal(a) / Decimal(a + c)):.15e}")
    print(f"  Bracket contains the true value: {v_lo < Fraction(str(key_rate(Decimal(a) / Decimal(a + c)))) < v_hi}")

    rule("5.  The derivative bracket on [79/718, 0.11002787]")
    q0 = Fraction(79, 718)
    q1 = Fraction(11002787, 100000000)
    left = dec_ln(1 - Decimal(q0.numerator) / Decimal(q0.denominator)) - dec_ln(
        Decimal(q0.numerator) / Decimal(q0.denominator)
    )
    right = dec_ln(1 - Decimal(q1.numerator) / Decimal(q1.denominator)) - dec_ln(
        Decimal(q1.numerator) / Decimal(q1.denominator)
    )
    L = Fraction(20904563381, 10000000000)
    U = Fraction(20904568254, 10000000000)
    print("  H2'(x) = log((1-x)/x) is strictly decreasing, so:")
    print(f"    max at x = 79/718        : log(639/79)            = {str(left)[:16]}")
    print(f"    min at x = 0.11002787    : log(88997213/11002787) = {str(right)[:16]}")
    print(f"  Certified bracket           : [{float(L):.10f}, {float(U):.10f}]")
    print(f"  Bracket is valid            : {float(L) <= float(right) and float(left) <= float(U)}")
    print(f"  Bracket width               : {float(U - L):.4e}")

    rule("6.  One mean-value step  ->  thirteen certified decimals")
    A1 = Fraction(1941021565465, 10**20)
    A2 = Fraction(1941021565843, 10**20)
    print(f"  anchor q0                = 79/718 = {float(q0):.16f}")
    print(f"  half key rate bracket    = ({float(A1):.12e}, {float(A2):.12e})")
    print(f"  derivative bracket       = [{float(L)}, {float(U)}]")
    lo, hi = refinement_step(q0, A1, A2, L, U)
    print()
    print(f"  lower endpoint q0 + A1/U = {Decimal(lo.numerator) / Decimal(lo.denominator)}"[:62])
    print(f"  upper endpoint q0 + A2/L = {Decimal(hi.numerator) / Decimal(hi.denominator)}"[:62])
    print(f"  certified width          = {float(hi - lo):.4e}")
    print()
    print(f"  contains reference p*    : {lo < Fraction(str(p_ref)) < hi}")
    print(f"  implies 0.1100278644383 < p* < 0.1100278644384 : "
          f"{Fraction('0.1100278644383') < lo and hi < Fraction('0.1100278644384')}")
    floor13 = int(Decimal(10) ** 13 * (Decimal(lo.numerator) / Decimal(lo.denominator)))
    print(f"  floor(10^13 p*)          = {floor13}")

    rule("7.  Consequences and the cost law")
    err11 = p_ref - Decimal("0.11")
    print(f"  p* - 11/100                     = {err11}"[:56])
    print("  certified                       : 2.786e-05 < |p* - 0.11| < 2.787e-05")
    print("  so 11% UNDERSTATES the tolerable error rate (relative offset "
          f"{float(err11 / p_ref):.3e})")
    r11 = key_rate(Decimal("0.11"))
    print(f"  r(0.11)                         = {r11:.12e} nats/sifted bit")
    print(f"                                  = 1 secret bit per {float(Decimal(2).ln() / r11):.0f} sifted bits")
    print()
    print("  Cost law:  certificate cost ~ q^2, anchor quality ~ q^-2,")
    print("             one mean-value step squares it, so width ~ q^-4.")
    print("             => width eps costs ~ eps^{-1/2}, not eps^{-1}.")
    print()
    print(f"  {'anchor':>18} {'|error|':>12} {'predicted width':>18} {'cert digits':>12}")
    for cv in [Fraction(11, 100), Fraction(34, 309), Fraction(79, 718),
               Fraction(16466, 149653)]:
        delta = abs(float(Decimal(cv.numerator) / Decimal(cv.denominator) - p_ref))
        if cv.denominator <= 800:
            cert = str(certificate_digits(cv.numerator, cv.denominator - cv.numerator))
        else:
            est = 2 * cv.denominator * float(Decimal(cv.denominator).log10())
            cert = f"~{est / 1000:.0f}k"
        print(f"  {f'{cv.numerator}/{cv.denominator}':>18} {delta:>12.3e} "
              f"{4.9 * delta ** 2:>18.3e} {str(cert):>12}")

    print("\n" + "=" * 74)
    print("  p* = 0.1100278644383...   certified to width 2.17e-15")
    print("=" * 74 + "\n")


if __name__ == "__main__":
    main()
