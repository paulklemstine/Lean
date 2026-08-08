"""
Numerical demonstration of sharp two-sided summand asymptotics for the
Euler-Mascheroni constant gamma, the midpoint-accelerated approximants, the
certified rational enclosure 0.5771692 < gamma < 0.5772158, the resulting
small-denominator obstruction (gamma is not p/q with q <= 148), and the
symmetrized-divergence identity D(a||b) + D(b||a) = (a-b)^2/(ab).

Everything is self-contained: only the standard library is used, and all
high-precision arithmetic is done with `fractions.Fraction` and `decimal`.

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from math import log
from typing import Iterator, List, Tuple

getcontext().prec = 60

# Reference value of gamma to 50 digits (used only for display / sanity checks).
GAMMA = Decimal(
    "0.57721566490153286060651209008240243104215933593992"
)

# ----------------------------------------------------------------------
# 1. The basic objects
# ----------------------------------------------------------------------


def harmonic(n: int) -> Fraction:
    """H_n = 1 + 1/2 + ... + 1/n as an exact rational."""
    return sum((Fraction(1, k) for k in range(1, n + 1)), Fraction(0))


def euler_mascheroni_seq(n: int) -> float:
    """g_n = H_n - log(n+1), the lower approximants of gamma."""
    return float(harmonic(n)) - log(n + 1)


def gamma_term(k: int) -> float:
    """t_k = 1/(k+1) - log((k+2)/(k+1)) = D(Exp(k+1) || Exp(k+2)) >= 0."""
    return 1.0 / (k + 1) - log((k + 2) / (k + 1))


def accelerated(n: int) -> float:
    """a_n = g_n + 1/(2(n+1)), the midpoint-corrected approximant."""
    return euler_mascheroni_seq(n) + 1.0 / (2 * (n + 1))


def exponential_kl(a: float, b: float) -> float:
    """Kullback-Leibler divergence D(Exp(a) || Exp(b)) = log(a/b) + b/a - 1."""
    return log(a / b) + b / a - 1.0


def sym_kl(a: float, b: float) -> float:
    """Symmetrized (Jeffreys) divergence D(a||b) + D(b||a)."""
    return exponential_kl(a, b) + exponential_kl(b, a)


# ----------------------------------------------------------------------
# 2. The rational squeeze of every summand
# ----------------------------------------------------------------------


def summand_squeeze_table(kmax: int = 8) -> None:
    print("=" * 78)
    print("1.  Rational squeeze of the summands:")
    print("      1/(2(k+2)^2)  <=  1/(2(k+1)(k+2))  <=  t_k  <=  1/(2(k+1)^2)")
    print("=" * 78)
    print(f"{'k':>3} {'1/(2(k+2)^2)':>16} {'1/(2(k+1)(k+2))':>18} "
          f"{'t_k':>16} {'1/(2(k+1)^2)':>16}")
    for k in range(kmax + 1):
        lo_weak = 1.0 / (2 * (k + 2) ** 2)
        lo_sharp = 1.0 / (2 * (k + 1) * (k + 2))
        val = gamma_term(k)
        hi = 1.0 / (2 * (k + 1) ** 2)
        assert lo_weak <= lo_sharp <= val <= hi + 1e-15, k
        print(f"{k:>3} {lo_weak:>16.10f} {lo_sharp:>18.10f} "
              f"{val:>16.10f} {hi:>16.10f}")
    print("all inequalities verified for k = 0 ..", kmax)
    print()


# ----------------------------------------------------------------------
# 3. Two-sided tail bounds and the Theta(n^-2) acceleration
# ----------------------------------------------------------------------


def tail_bounds(n: int) -> Tuple[float, float]:
    """(lower, upper) bounds for gamma - g_n."""
    m = n + 1.0
    return (1.0 / (2 * m) + 1.0 / (14 * m * m),
            1.0 / (2 * m) + 1.0 / (12 * m * m))


def tail_table(values: List[int]) -> None:
    print("=" * 78)
    print("2.  Two-sided tail bound  1/(2(n+1)) + 1/(14(n+1)^2)")
    print("        <= gamma - g_n <= 1/(2(n+1)) + 1/(12(n+1)^2)")
    print("=" * 78)
    g = float(GAMMA)
    print(f"{'n':>5} {'lower':>15} {'gamma - g_n':>15} {'upper':>15} {'ok':>4}")
    for n in values:
        lo, hi = tail_bounds(n)
        rem = g - euler_mascheroni_seq(n)
        ok = lo - 1e-12 <= rem <= hi + 1e-12
        print(f"{n:>5} {lo:>15.10f} {rem:>15.10f} {hi:>15.10f} {str(ok):>4}")
    print()


def acceleration_table(values: List[int]) -> None:
    print("=" * 78)
    print("3.  Midpoint acceleration a_n = g_n + 1/(2(n+1)):")
    print("      1/14 <= (n+1)^2 (gamma - a_n) <= 1/12   (error is exactly n^-2)")
    print("=" * 78)
    g = float(GAMMA)
    print(f"{'n':>6} {'gamma - g_n':>14} {'gamma - a_n':>14} "
          f"{'(n+1)^2 err':>14} {'in [1/14,1/12]':>16}")
    for n in values:
        raw = g - euler_mascheroni_seq(n)
        err = g - accelerated(n)
        scaled = (n + 1.0) ** 2 * err
        inside = 1.0 / 14 - 1e-12 <= scaled <= 1.0 / 12 + 1e-12
        print(f"{n:>6} {raw:>14.10f} {err:>14.3e} {scaled:>14.10f} "
              f"{str(inside):>16}")
    print("  1/14 = %.10f, 1/12 = %.10f" % (1 / 14, 1 / 12))
    print("  -> the scaled error does NOT tend to 0: no Apery-style linear")
    print("     forms can be built from this family.")
    print()


# ----------------------------------------------------------------------
# 4. The certified enclosure at n = 15
# ----------------------------------------------------------------------


def certified_enclosure() -> Tuple[Fraction, Fraction]:
    """Reproduce 0.5771692 < gamma < 0.5772158 from the tail bound at n = 15.

    g_15 = H_15 - 4 log 2 with H_15 = 1195757/360360, and log 2 is enclosed by
    the rational bounds 0.6931471803 < log 2 < 0.6931471808.
    """
    h15 = harmonic(15)
    assert h15 == Fraction(1195757, 360360), h15
    log2_lo = Fraction(6931471803, 10 ** 10)
    log2_hi = Fraction(6931471808, 10 ** 10)
    m = Fraction(16)
    tail_lo = Fraction(1, 2) / m + Fraction(1, 14) / (m * m)
    tail_hi = Fraction(1, 2) / m + Fraction(1, 12) / (m * m)
    # g_15 = H_15 - 4 log 2  is minimal when log 2 is maximal.
    gamma_lo = h15 - 4 * log2_hi + tail_lo
    gamma_hi = h15 - 4 * log2_lo + tail_hi
    return gamma_lo, gamma_hi


def enclosure_report() -> None:
    print("=" * 78)
    print("4.  Certified enclosure of gamma from the tail bound at n = 15")
    print("=" * 78)
    lo, hi = certified_enclosure()
    print(f"  H_15                = {harmonic(15)}")
    print(f"  g_15 = H_15 - 4log2 = {euler_mascheroni_seq(15):.12f}")
    print(f"  raw lower bound     = {float(lo):.12f}")
    print(f"  raw upper bound     = {float(hi):.12f}")
    print(f"  rounded certificate : 0.5771692 < gamma < 0.5772158")
    print(f"  true gamma          = {GAMMA}")
    assert Fraction(5771692, 10 ** 7) <= lo
    assert hi <= Fraction(5772158, 10 ** 7)
    width = Fraction(5772158 - 5771692, 10 ** 7)
    print(f"  width               = {float(width):.3e}")
    print("  (upper bound accurate to 7 decimals: 1/12 is the exact")
    print("   Euler-Maclaurin coefficient, 1/14 is merely a certified proxy)")
    print()


# ----------------------------------------------------------------------
# 5. The small-denominator obstruction
# ----------------------------------------------------------------------


def excluded_denominators(lo: Fraction, hi: Fraction, qmax: int = 200
                          ) -> Iterator[Tuple[int, bool, str]]:
    """For each q, decide whether (lo*q, hi*q) contains an integer."""
    for q in range(1, qmax + 1):
        a, b = lo * q, hi * q
        # smallest integer strictly greater than a
        p = a.numerator // a.denominator + 1
        hit = p < b
        yield q, not hit, (f"{p}/{q}" if hit else "")


def obstruction_report() -> None:
    print("=" * 78)
    print("5.  Small-denominator obstruction: gamma != p/q for 1 <= q <= 148")
    print("=" * 78)
    lo = Fraction(5771692, 10 ** 7)
    hi = Fraction(5772158, 10 ** 7)
    first_hit = None
    for q, excluded, witness in excluded_denominators(lo, hi, 200):
        if not excluded and first_hit is None:
            first_hit = (q, witness)
    assert first_hit is not None
    q0, w0 = first_hit
    print(f"  every denominator 1 <= q <= {q0 - 1} is excluded")
    print(f"  first surviving denominator: q = {q0}, witness {w0} = "
          f"{float(Fraction(w0)):.9f}")
    print(f"  interval = ({float(lo):.7f}, {float(hi):.7f})")
    print(f"  -> the threshold {q0 - 1} is optimal for this enclosure.")
    print()


# ----------------------------------------------------------------------
# 6. Symmetrized divergence identity and its two test chains
# ----------------------------------------------------------------------


def symmetrization_report() -> None:
    print("=" * 78)
    print("6.  Symmetrized divergence: D(a||b) + D(b||a) = (a-b)^2/(ab)")
    print("=" * 78)
    print(f"{'a':>8} {'b':>8} {'D(a||b)+D(b||a)':>20} {'(a-b)^2/(ab)':>16}")
    for a, b in [(1.0, 2.0), (2.0, 5.0), (0.3, 0.7), (10.0, 9.5), (1.0, 1.0)]:
        lhs = sym_kl(a, b)
        rhs = (a - b) ** 2 / (a * b)
        assert abs(lhs - rhs) < 1e-12
        print(f"{a:>8.3f} {b:>8.3f} {lhs:>20.12f} {rhs:>16.12f}")
    print()

    print("  Chain of linear rates 1, 2, 3, ... : partial sums -> 1 exactly")
    total = 0.0
    for n in range(6):
        total += sym_kl(n + 1.0, n + 2.0)
        print(f"    N = {n:>2}:  partial sum = {total:.10f}  "
              f"(closed form 1 - 1/{n + 2} = {1 - 1 / (n + 2):.10f})")
    print()

    print("  Chain of geometric rates 1, r, r^2, ... : terms are constant")
    for r in (0.5, 2.0, 1.1):
        terms = [sym_kl(r ** n, r ** (n + 1)) for n in range(4)]
        print(f"    r = {r:>4}: terms = "
              + ", ".join(f"{t:.8f}" for t in terms)
              + f"   ((1-r)^2/r = {(1 - r) ** 2 / r:.8f})")
    print("  -> constant nonzero terms: the geometric chain always diverges.")
    print()


# ----------------------------------------------------------------------
# 7. The derivative certificates for the logarithmic ratio
# ----------------------------------------------------------------------


def log_ratio_certificates() -> None:
    print("=" * 78)
    print("7.  Certificates for L(z) = log((1+z)/(1-z)) on [0,1):")
    print("      2z + 2z^3/3  <=  L(z)  <=  min(2z/(1-z^2),")
    print("                                     2z + 2z^3/3 + 2z^5/(5(1-z^2)))")
    print("=" * 78)
    print(f"{'z':>8} {'lower':>16} {'L(z)':>16} {'Pade upper':>16} "
          f"{'crude upper':>16}")
    for z in (0.05, 0.1, 0.2, 0.333, 0.5, 0.8):
        lo = 2 * z + 2 * z ** 3 / 3
        val = log((1 + z) / (1 - z))
        pade = lo + 2 * z ** 5 / (5 * (1 - z * z))
        crude = 2 * z / (1 - z * z)
        assert lo <= val <= pade + 1e-14 and val <= crude + 1e-14
        print(f"{z:>8.3f} {lo:>16.10f} {val:>16.10f} {pade:>16.10f} "
              f"{crude:>16.10f}")
    print("  Substituting z = 1/(2m+1) gives the rational sandwich for")
    print("  log((m+1)/m) that drives every bound above.")
    print()


def main() -> None:
    print()
    print("SHARP TWO-SIDED ASYMPTOTICS FOR THE EULER-MASCHERONI CONSTANT")
    print()
    summand_squeeze_table(8)
    tail_table([0, 1, 2, 5, 10, 15, 100, 1000])
    acceleration_table([0, 1, 5, 15, 50, 200, 1000])
    enclosure_report()
    obstruction_report()
    symmetrization_report()
    log_ratio_certificates()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
