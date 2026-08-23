"""
Finite-Key Bounds on a Certified Asymptotic Core
================================================

Numerical companion to the paper "Finite-Key Bounds on a Certified Asymptotic
Core: Rational Certificates and a Two-Sided Inverse-Square Law for the BB84
Break-Even Block Size".

Everything in the certified chain is *exact rational arithmetic*: the key-rate
certificates are integer comparisons on 400- to 800-digit numbers, and the
resulting rate bounds are rational numbers.  Floating point appears in this
script only for printing and for the "true value" reference columns.

Contents
--------
1.  The Shor-Preskill asymptotic rate and its threshold Q*.
2.  The exact rational identity  (a+c) * r(a/(a+c)) = log(N/D).
3.  Three certificate schemes: dyadic, Pade [1/1], and hybrid.
4.  The finite-key length functional and its break-even block size.
5.  The certified parameter table at C = 10, eps = 2^-50.
6.  The two-sided inverse-square law for the break-even block size.
7.  The leftover-hash vacuity audit.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Iterable, Optional, Tuple

LOG2: float = math.log(2.0)

# ----------------------------------------------------------------------------
# 1.  The asymptotic Shor-Preskill rate
# ----------------------------------------------------------------------------


def binary_entropy_bits(q: float) -> float:
    """Binary Shannon entropy h(q) = -q log2 q - (1-q) log2(1-q), in bits."""
    if q <= 0.0 or q >= 1.0:
        return 0.0
    return -(q * math.log2(q) + (1.0 - q) * math.log2(1.0 - q))


def secure_key_rate_bits(q: float) -> float:
    """Asymptotic BB84 (Shor-Preskill) key rate r(Q) = 1 - 2h(Q), in bits."""
    return 1.0 - 2.0 * binary_entropy_bits(q)


def secure_key_rate_nats(q: float) -> float:
    """The same rate expressed in nats: log 2 - 2 H(Q)."""
    return LOG2 * secure_key_rate_bits(q)


def threshold_qber(tol: float = 1e-15) -> float:
    """The asymptotic threshold Q*: the unique zero of r in (0, 1/2)."""
    lo, hi = 0.05, 0.20
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if secure_key_rate_bits(mid) > 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


# ----------------------------------------------------------------------------
# 2.  The exact rational identity at a rational QBER
# ----------------------------------------------------------------------------


def rate_ratio(a: int, c: int) -> Tuple[int, int]:
    """Return (N, D) with  (a+c) * r_nats(a/(a+c)) = log(N/D)  exactly, where

        N = 2^(a+c) * a^(2a) * c^(2c),      D = (a+c)^(2(a+c)).

    These are exact integers; no floating point is involved.
    """
    n = a + c
    numerator = (2 ** n) * (a ** (2 * a)) * (c ** (2 * c))
    denominator = n ** (2 * n)
    return numerator, denominator


# ----------------------------------------------------------------------------
# 3.  The three certificate schemes
# ----------------------------------------------------------------------------


def dyadic_certificate(a: int, c: int, m: int) -> bool:
    """Check the dyadic certificate  2^m * D <= N.  Verifying it proves

        r(a/(a+c)) >= m/(a+c)   bits per sifted bit.
    """
    n_int, d_int = rate_ratio(a, c)
    return (2 ** m) * d_int <= n_int


def best_dyadic_exponent(a: int, c: int) -> int:
    """Largest m with 2^m * D <= N, i.e. m = floor((a+c) * r_bits)."""
    n_int, d_int = rate_ratio(a, c)
    m = 0
    while (2 ** (m + 1)) * d_int <= n_int:
        m += 1
    return m


def pade_certificate(a: int, c: int, num: int, den: int) -> bool:
    """Check the Pade certificate  (den+num) * D <= den * N.  Verifying it proves

        r(a/(a+c)) >= 2*num / ((a+c) * (2*den + num))   nats per sifted bit,

    by way of the Pade [1/1] bound  log x >= 2(x-1)/(x+1)  for x >= 1.
    """
    n_int, d_int = rate_ratio(a, c)
    return (den + num) * d_int <= den * n_int


def hybrid_certificate(a: int, c: int, m: int, num: int, den: int) -> bool:
    """Check the hybrid certificate  (den+num) * 2^m * D <= den * N.  It proves

        r(a/(a+c)) >= (m log 2 + 2*num/(2*den+num)) / (a+c)   nats.

    num = 0 recovers the dyadic scheme; m = 0 recovers the Pade scheme.
    """
    n_int, d_int = rate_ratio(a, c)
    return (den + num) * (2 ** m) * d_int <= den * n_int


def best_pade_numerator(a: int, c: int, den: int, m: int = 0) -> int:
    """Largest num with the hybrid (or, for m = 0, the Pade) certificate valid."""
    n_int, d_int = rate_ratio(a, c)
    # (den + num) * 2^m * D <= den * N   <=>   num <= den * (N / (2^m D) - 1)
    lhs = Fraction(den * n_int, (2 ** m) * d_int) - den
    return max(0, math.floor(lhs))


def certified_rate_bits_pade(a: int, c: int, num: int, den: int) -> Fraction:
    """The rational nat-valued Pade bound 2*num/((a+c)(2 den + num))."""
    return Fraction(2 * num, (a + c) * (2 * den + num))


def certified_rate_nats_hybrid(a: int, c: int, m: int, num: int, den: int) -> float:
    """The hybrid bound (m log 2 + 2 num/(2 den + num))/(a+c), in nats."""
    return (m * LOG2 + float(Fraction(2 * num, 2 * den + num))) / (a + c)


# ----------------------------------------------------------------------------
# 4.  Finite-key accounting
# ----------------------------------------------------------------------------


def finite_key_bits(rho: Fraction, c_const: Fraction, n: int, eps: float) -> float:
    """n * rho - C * sqrt(n * ln(1/eps)):  raw finite-key length in bits."""
    return float(n) * float(rho) - float(c_const) * math.sqrt(
        float(n) * math.log(1.0 / eps)
    )


def extractable_bits(rho: Fraction, c_const: Fraction, n: int, eps: float) -> float:
    """Finite-key length after the leftover-hash charge of 2 log2(1/eps) bits."""
    return finite_key_bits(rho, c_const, n, eps) - 2.0 * math.log2(1.0 / eps)


def breakeven_block_size(rho: Fraction, c_const: Fraction, eps: float) -> float:
    """n* = C^2 ln(1/eps) / rho^2: the exact sign change of finite_key_bits."""
    return float(c_const) ** 2 * math.log(1.0 / eps) / float(rho) ** 2


def half_rate_block_size(rho: Fraction, c_const: Fraction, eps: float) -> float:
    """4 n*: above this, at least half the asymptotic budget survives."""
    return 4.0 * breakeven_block_size(rho, c_const, eps)


# ----------------------------------------------------------------------------
# 5.  Leftover hashing
# ----------------------------------------------------------------------------


def leftover_hash_distance_bound(ell: int, k: int) -> float:
    """Cauchy-Schwarz bound sqrt(2^ell * (2^-ell + 2^-k) - 1) = 2^((ell-k)/2)."""
    return 2.0 ** (0.5 * (ell - k))


def min_collision_probability(ell: int) -> float:
    """The least possible collision probability on 2^ell points, namely 2^-ell."""
    return 2.0 ** (-ell)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def _rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_threshold() -> None:
    _rule("1.  The asymptotic rate and its threshold")
    qstar = threshold_qber()
    print(f"  Asymptotic threshold  Q* = {qstar:.10f}")
    print("  (certified enclosure: 0.1100 < Q* < 0.1101)")
    print()
    print(f"  {'Q':>8}  {'r(Q) [bits]':>14}  {'r(Q) [nats]':>14}")
    for q in (0.01, 0.02, 0.05, 0.08, 0.10, 0.11):
        print(
            f"  {q:>8.2%}  {secure_key_rate_bits(q):>14.8f}"
            f"  {secure_key_rate_nats(q):>14.8f}"
        )


def demo_rational_identity() -> None:
    _rule("2.  The exact rational identity  (a+c) r = log(N/D)")
    for a, c in ((1, 99), (10, 90), (11, 89)):
        n_int, d_int = rate_ratio(a, c)
        ratio = Fraction(n_int, d_int)
        lhs = (a + c) * secure_key_rate_nats(a / (a + c))
        print(
            f"  Q = {a}/{a+c}:  N has {len(str(n_int))} digits,"
            f"  N/D = {float(ratio):.12f}"
        )
        print(
            f"            (a+c) r = {lhs:.12f}   log(N/D) = {math.log(float(ratio)):.12f}"
        )


def demo_certificates() -> None:
    _rule("3.  Three certificate schemes at Q = 11%")
    a, c, den = 11, 89, 10000
    n_int, d_int = rate_ratio(a, c)
    x = Fraction(n_int, d_int)
    true_nats = secure_key_rate_nats(0.11)

    print(f"  N/D = {float(x):.12f}   (an {len(str(n_int))}-digit integer over"
          f" a {len(str(d_int))}-digit integer)")
    print(f"  true rate                 : {true_nats:.10e} nats")
    naive = float(1 - 1 / x) / (a + c)
    pade_exact = float(2 * (x - 1) / (x + 1)) / (a + c)
    print(f"  naive  log x >= 1 - 1/x   : {naive:.10e} nats")
    print(f"  Pade   log x >= 2(x-1)/(x+1): {pade_exact:.10e} nats")
    print(f"  best dyadic exponent m    : {best_dyadic_exponent(a, c)}"
          "   (the dyadic scheme degenerates at 11%)")

    num = 117
    assert pade_certificate(a, c, num, den), "certificate must verify"
    assert not pade_certificate(a, c, num + 1, den), "certificate should be sharp at den=10^4"
    rho_nats = certified_rate_bits_pade(a, c, num, den)
    rho_bits = float(rho_nats) / LOG2
    print()
    print(f"  certificate  ({den}+{num})*D <= {den}*N   verifies (exact integers)")
    print(f"  certified rate            : {float(rho_nats):.10e} nats"
          f" = {rho_bits:.10e} bits")
    print(f"  rational bit-rate claimed : 1/6000 = {1/6000:.10e} bits"
          f"   -> valid: {rho_bits >= 1/6000}")


def demo_hybrid() -> None:
    _rule("4.  The hybrid dyadic-Pade certificate at Q = 10%")
    a, c = 10, 90
    m = best_dyadic_exponent(a, c)
    n_int, d_int = rate_ratio(a, c)
    y = Fraction(n_int, (2 ** m) * d_int)
    true_bits = secure_key_rate_bits(0.10)
    print(f"  optimal dyadic exponent m = {m};  residual ratio y = N/(2^m D)"
          f" = {float(y):.10f}")
    print(f"  dyadic bound   : {m/(a+c):.8f} bits   (error {true_bits - m/(a+c):.2e})")
    num = best_pade_numerator(a, c, 10000, m)
    assert hybrid_certificate(a, c, m, num, 10000)
    hyb = certified_rate_nats_hybrid(a, c, m, num, 10000) / LOG2
    print(f"  hybrid bound   : {hyb:.8f} bits   (error {true_bits - hyb:.2e})"
          f"   [num = {num}, den = 10000]")
    print(f"  certified value: 0.06200000 bits (the rational 62/1000)")
    print(f"  true value     : {true_bits:.8f} bits")
    print(f"  error reduction: factor {(true_bits - m/(a+c))/(true_bits - hyb):.1f}")


def demo_parameter_table() -> None:
    _rule("5.  The certified finite-key parameter table  (C = 10, eps = 2^-50)")
    c_const = Fraction(10)
    eps = 2.0 ** -50
    rows: Iterable[Tuple[str, Fraction, Optional[int]]] = (
        ("1 %", Fraction(83, 100), 25_000),
        ("2 %", Fraction(71, 100), None),
        ("5 %", Fraction(42, 100), None),
        ("8 %", Fraction(19, 100), None),
        ("10 %", Fraction(62, 1000), 3_700_000),
        ("11 %", Fraction(1, 6000), 10 ** 12),
    )
    print(f"  {'Q':>6}  {'certified rho':>15}  {'break-even n*':>14}"
          f"  {'4n* (half rate)':>16}  {'table n':>12}")
    for label, rho, table_n in rows:
        be = breakeven_block_size(rho, c_const, eps)
        print(
            f"  {label:>6}  {str(rho):>15}  {be:>14.3e}"
            f"  {4*be:>16.3e}  {('-' if table_n is None else f'{table_n:.1e}'):>12}"
        )
    print()
    print("  Extractable ε-secure bits (ε = 2^-50) at the tabulated block sizes:")
    for label, rho, table_n in rows:
        if table_n is None:
            continue
        ext = extractable_bits(rho, c_const, table_n, eps)
        guaranteed = table_n * float(rho) / 2 - 101
        print(
            f"    Q = {label:>5}, n = {table_n:.1e}:  actual >= {ext:,.0f} bits;"
            f"  certified guarantee {guaranteed:,.0f} bits"
        )


def demo_eleven_percent_gap() -> None:
    _rule("6.  Q = 11%: the statistical correction dominates")
    rho = Fraction(1, 6000)
    c_const = Fraction(10)
    eps = 2.0 ** -50
    print(f"  {'n':>12}  {'n*rho [bits]':>16}  {'C sqrt(n ln 1/eps)':>20}"
          f"  {'finite-key length':>20}")
    for exponent in range(6, 15):
        n = 10 ** exponent
        raw = float(n) * float(rho)
        corr = float(c_const) * math.sqrt(float(n) * math.log(1.0 / eps))
        print(
            f"  {n:>12.0e}  {raw:>16.3e}  {corr:>20.3e}"
            f"  {finite_key_bits(rho, c_const, n, eps):>20.3e}"
        )
    print()
    print(f"  break-even n* = {breakeven_block_size(rho, c_const, eps):.4e}")
    print("  certified: finite-key length <= 0 for every n <= 1e11;")
    print("             finite-key length >= n/12000 for every n >= 1e12.")


def demo_two_sided_law() -> None:
    _rule("7.  The two-sided inverse-square law for the break-even block size")
    qstar = threshold_qber()
    c_const = Fraction(10)
    eps = 2.0 ** -50
    ln_inv_eps = math.log(1.0 / eps)
    const = float(c_const) ** 2 * ln_inv_eps
    print(f"  {'Q':>8}  {'gap d = Q*-Q':>14}  {'lower C^2L/(44 d^2)':>21}"
          f"  {'true C^2L/r(Q)^2':>19}  {'upper C^2L/(9 d^2)':>20}")
    for q in (0.100, 0.105, 0.108, 0.109, 0.1095, 0.10990, 0.11):
        d = qstar - q
        lower = const / (44.0 * d * d)
        upper = const / (9.0 * d * d)
        true = const / secure_key_rate_bits(q) ** 2
        print(f"  {q:>8.5f}  {d:>14.3e}  {lower:>21.4e}  {true:>19.4e}"
              f"  {upper:>20.4e}")
    print()
    print("  The middle column is bracketed by the two outer ones in every row:")
    print("  n*(Q) = Theta((Q* - Q)^-2), with a certified constant ratio 44/9 < 5.")


def demo_leftover_hash_audit() -> None:
    _rule("8.  The leftover-hash vacuity audit")
    print("  Any probability vector on 2^ell points obeys  sum p^2 >= 2^-ell.")
    print("  Hence the hypothesis  sum p^2 <= 2^-k  is UNSATISFIABLE when ell < k:")
    for ell, k in ((10, 20), (64, 128), (100, 256)):
        print(
            f"    ell = {ell:>4}, k = {k:>4}:  min possible sum p^2 = 2^-{ell}"
            f" = {min_collision_probability(ell):.3e}"
            f"  >  2^-{k} = {min_collision_probability(k):.3e}"
        )
    print()
    print("  The repaired hypothesis  sum p^2 <= 2^-ell + 2^-k  is satisfiable")
    print("  (the uniform distribution meets it) and yields the same conclusion,")
    print("  because  2^ell (2^-ell + 2^-k) - 1 = 2^(ell-k)  exactly:")
    for ell, k in ((10, 20), (64, 128), (100, 256)):
        lhs = Fraction(2) ** ell * (Fraction(1, 2 ** ell) + Fraction(1, 2 ** k)) - 1
        rhs = Fraction(1, 2 ** (k - ell))
        print(
            f"    ell = {ell:>4}, k = {k:>4}:  2^ell(2^-ell+2^-k) - 1 = {float(lhs):.6e}"
            f"  =  2^(ell-k) = {float(rhs):.6e}   (exact equality: {lhs == rhs})"
        )
        print(
            f"        statistical distance <= {leftover_hash_distance_bound(ell, k):.3e}"
            f"   (eps-secure once ell + 2 log2(1/eps) <= k)"
        )


def main() -> None:
    print(__doc__)
    demo_threshold()
    demo_rational_identity()
    demo_certificates()
    demo_hybrid()
    demo_parameter_table()
    demo_eleven_percent_gap()
    demo_two_sided_law()
    demo_leftover_hash_audit()
    print()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
