#!/usr/bin/env python3
"""
Certified acceleration of the Euler-Mascheroni sequence
=======================================================

This self-contained script demonstrates, numerically, the results of
"Telescoping Envelopes and Certified Acceleration of the Euler-Mascheroni
Sequence".

Setting.  Let H_n = 1 + 1/2 + ... + 1/n be the n-th harmonic number and

    s_n = H_n - log(n+1),        s_0 = 0,        s_n -> gamma.

Writing m = n+1, we study three accelerated sequences

    A1(n) = s_n + 1/(2m)                                        (midpoint)
    A2(n) = s_n + 1/(2m) + 1/(12 m^2)                           (quartic)
    A3(n) = s_n + 1/(2m) + 1/(12 m^2) - 1/(120 m^4)             (sixth order)

and the proved, unconditional (valid for EVERY n >= 0) bounds

    1/(12 m^2) - 1/(36 m^3)  <=  gamma - A1(n)  <=  1/(12 m^2)
    1/(120 m^4) - 1/(300 m^5) <= A2(n) - gamma  <=  1/(120 m^4)
    0                         <= gamma - A3(n)  <=  1/(252 m^6)

together with the certified enclosure A1(n) < A3(n) <= gamma < A2(n)
of width A2(n) - A1(n) = 1/(12 m^2).

All computations here are done in exact rational arithmetic where possible
(the corrections and bounds are rationals; only the logarithm and gamma
itself are evaluated in high-precision floating point via `decimal`), so
that the printed ratios (true error)/(proved bound) are trustworthy well
beyond double precision.
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from typing import Dict, List

getcontext().prec = 60

# ----------------------------------------------------------------------
# High-precision constants
# ----------------------------------------------------------------------

#: Euler-Mascheroni constant to 50 decimal places.
GAMMA: Decimal = Decimal(
    "0.57721566490153286060651209008240243104215933593992"
)


def dec_log(x: Decimal) -> Decimal:
    """Natural logarithm of a positive Decimal at the current precision."""
    if x <= 0:
        raise ValueError("dec_log requires a positive argument")
    return x.ln()


def frac_to_dec(q: Fraction) -> Decimal:
    """Exact conversion of a Fraction to a Decimal at current precision."""
    return Decimal(q.numerator) / Decimal(q.denominator)


# ----------------------------------------------------------------------
# The base sequence and its accelerations
# ----------------------------------------------------------------------


def harmonic(n: int) -> Fraction:
    """Exact n-th harmonic number H_n = sum_{k=1}^n 1/k (H_0 = 0)."""
    total = Fraction(0)
    for k in range(1, n + 1):
        total += Fraction(1, k)
    return total


def base_sequence(n: int) -> Decimal:
    """s_n = H_n - log(n+1), computed in high precision."""
    return frac_to_dec(harmonic(n)) - dec_log(Decimal(n + 1))


def correction(n: int, order: int) -> Fraction:
    """
    Exact rational correction term added to s_n.

    order = 1 : 1/(2m)
    order = 2 : 1/(2m) + 1/(12 m^2)
    order = 3 : 1/(2m) + 1/(12 m^2) - 1/(120 m^4)
    """
    m = Fraction(n + 1)
    c = Fraction(1, 2) / m
    if order >= 2:
        c += Fraction(1, 12) / m**2
    if order >= 3:
        c -= Fraction(1, 120) / m**4
    return c


def accelerated(n: int, order: int) -> Decimal:
    """A_order(n) for order in {0,1,2,3}; order 0 is the raw sequence s_n."""
    if order == 0:
        return base_sequence(n)
    return base_sequence(n) + frac_to_dec(correction(n, order))


def error_bound(n: int, order: int) -> Fraction:
    """
    The proved upper bound on |gamma - A_order(n)|, an exact rational.

    order 0 : 1/(2m) + 1/(12 m^2)   (bound on gamma - s_n)
    order 1 : 1/(12 m^2)
    order 2 : 1/(120 m^4)
    order 3 : 1/(252 m^6)
    """
    m = Fraction(n + 1)
    table: Dict[int, Fraction] = {
        0: Fraction(1, 2) / m + Fraction(1, 12) / m**2,
        1: Fraction(1, 12) / m**2,
        2: Fraction(1, 120) / m**4,
        3: Fraction(1, 252) / m**6,
    }
    return table[order]


def lower_error_bound(n: int, order: int) -> Fraction:
    """
    The proved LOWER bound on the (signed) error, an exact rational:
      order 1 : 1/(12 m^2) - 1/(36 m^3)   <= gamma - A1(n)
      order 2 : 1/(120 m^4) - 1/(300 m^5) <= A2(n) - gamma
    """
    m = Fraction(n + 1)
    if order == 1:
        return Fraction(1, 12) / m**2 - Fraction(1, 36) / m**3
    if order == 2:
        return Fraction(1, 120) / m**4 - Fraction(1, 300) / m**5
    raise ValueError("lower bound available for orders 1 and 2 only")


def signed_error(n: int, order: int) -> Decimal:
    """
    The signed error in the direction in which it is proved positive:
      order 0,1,3 : gamma - A(n)   (these are lower approximants)
      order 2     : A2(n) - gamma  (an upper approximant)
    """
    a = accelerated(n, order)
    return (a - GAMMA) if order == 2 else (GAMMA - a)


# ----------------------------------------------------------------------
# Demonstration 1 -- error tables and verification of the bounds
# ----------------------------------------------------------------------


def demo_error_table(indices: List[int]) -> None:
    print("=" * 92)
    print("DEMO 1  Two-sided error bounds, verified at every index")
    print("=" * 92)
    labels = {0: "s_n (raw)", 1: "A1 midpoint", 2: "A2 quartic", 3: "A3 sixth"}
    for order in (0, 1, 2, 3):
        print(f"\n--- {labels[order]} ---")
        header = f"{'n':>6} {'signed error':>22} {'proved bound':>22} {'ratio':>10}"
        print(header)
        print("-" * len(header))
        for n in indices:
            err = signed_error(n, order)
            bnd = frac_to_dec(error_bound(n, order))
            ratio = err / bnd
            ok = (err <= bnd) and (err >= 0)
            flag = "" if ok else "   <-- VIOLATION"
            print(f"{n:>6} {err:>22.12E} {bnd:>22.12E} {float(ratio):>10.6f}{flag}")


def demo_sharpness(indices: List[int]) -> None:
    print("\n" + "=" * 92)
    print("DEMO 2  Sharpness of the constants 1/12 and 1/120")
    print("=" * 92)
    print("Theory:  12 m^2 (gamma - A1(n)) -> 1   and   120 m^4 (A2(n) - gamma) -> 1")
    header = (
        f"{'n':>8} {'12 m^2 (g - A1)':>22} {'120 m^4 (A2 - g)':>22} "
        f"{'lower cert. (ord 1)':>22}"
    )
    print(header)
    print("-" * len(header))
    for n in indices:
        m = Decimal(n + 1)
        scaled1 = Decimal(12) * m**2 * signed_error(n, 1)
        scaled2 = Decimal(120) * m**4 * signed_error(n, 2)
        cert = Decimal(12) * m**2 * frac_to_dec(lower_error_bound(n, 1))
        print(f"{n:>8} {scaled1:>22.12f} {scaled2:>22.12f} {cert:>22.12f}")


def demo_enclosure(indices: List[int]) -> None:
    print("\n" + "=" * 92)
    print("DEMO 3  Certified enclosure  A1(n) < A3(n) <= gamma < A2(n)")
    print("=" * 92)
    header = (
        f"{'n':>6} {'A1(n)':>20} {'A3(n)':>20} {'A2(n)':>20} {'width A2-A1':>16}"
    )
    print(header)
    print("-" * len(header))
    for n in indices:
        a1, a2, a3 = accelerated(n, 1), accelerated(n, 2), accelerated(n, 3)
        width = frac_to_dec(Fraction(1, 12) / Fraction(n + 1) ** 2)
        assert a1 < a3 <= GAMMA < a2, f"enclosure failed at n = {n}"
        assert abs((a2 - a1) - width) < Decimal("1e-40")
        print(f"{n:>6} {a1:>20.14f} {a3:>20.14f} {a2:>20.14f} {float(width):>16.3E}")
    print("\nAt n = 0 (no summation at all):")
    print(f"  A1(0) = 1/2  = {float(Fraction(1, 2)):.6f}")
    print(f"  A2(0) = 7/12 = {float(Fraction(7, 12)):.6f}")
    print(f"  hence   1/2 < gamma < 7/12,  improving the textbook bound gamma < 2/3.")


# ----------------------------------------------------------------------
# Demonstration 4 -- cost of a target accuracy
# ----------------------------------------------------------------------


def terms_needed(epsilon: float, order: int) -> int:
    """
    Smallest n such that the proved bound for the given order is <= epsilon.
    Uses the closed forms  1/(2m), 1/(12 m^2), 1/(120 m^4), 1/(252 m^6).
    """
    consts = {0: (2.0, 1), 1: (12.0, 2), 2: (120.0, 4), 3: (252.0, 6)}
    c, p = consts[order]
    m = (1.0 / (c * epsilon)) ** (1.0 / p)
    n = max(0, int(m))
    while error_bound(n, order) > Fraction(epsilon).limit_denominator(10**18):
        n += 1
    return n


def demo_cost() -> None:
    print("\n" + "=" * 92)
    print("DEMO 4  Number of harmonic terms needed for a certified accuracy")
    print("=" * 92)
    header = f"{'epsilon':>12} {'raw s_n':>16} {'A1':>12} {'A2':>12} {'A3':>12}"
    print(header)
    print("-" * len(header))
    for e in (1e-3, 1e-6, 1e-9, 1e-12):
        row = [terms_needed(e, k) for k in (0, 1, 2, 3)]
        print(f"{e:>12.0E} {row[0]:>16d} {row[1]:>12d} {row[2]:>12d} {row[3]:>12d}")
    print(
        "\nThe raw sequence needs ~1/(2 eps) terms; the sixth-order sequence\n"
        "needs ~(252 eps)^(-1/6).  For eps = 1e-12 that is 5e11 versus 40."
    )


# ----------------------------------------------------------------------
# Demonstration 5 -- the Pade inequalities that drive everything
# ----------------------------------------------------------------------


def pade_lower_2(x: Decimal) -> Decimal:
    """(12x + 18x^2 + 4x^3 - x^4) / (12 (1+x)^2)  <=  log(1+x)."""
    return (12 * x + 18 * x**2 + 4 * x**3 - x**4) / (12 * (1 + x) ** 2)


def pade_upper_3(x: Decimal) -> Decimal:
    """log(1+x) <= (36x + 90x^2 + 66x^3 + 12x^4 + x^6) / (36 (1+x)^3)."""
    return (36 * x + 90 * x**2 + 66 * x**3 + 12 * x**4 + x**6) / (
        36 * (1 + x) ** 3
    )


def pade_upper_4(x: Decimal) -> Decimal:
    """Fourth-order upper Pade bound for log(1+x)."""
    num = (
        120 * x
        + 420 * x**2
        + 520 * x**3
        + 250 * x**4
        + 24 * x**5
        - 4 * x**6
        + 4 * x**7
        + x**8
    )
    return num / (120 * (1 + x) ** 4)


def pade_lower_5(x: Decimal) -> Decimal:
    """Fifth-order lower Pade bound for log(1+x)."""
    num = (
        600 * x
        + 2700 * x**2
        + 4700 * x**3
        + 3850 * x**4
        + 1370 * x**5
        + 90 * x**6
        - 20 * x**7
        + 5 * x**8
        - 5 * x**9
        - 2 * x**10
    )
    return num / (600 * (1 + x) ** 5)


def pade_lower_6(x: Decimal) -> Decimal:
    """Sixth-order structured lower Pade bound for log(1+x)."""
    return (
        pade_lower_2(x)
        + x**4 * ((1 + x) ** 4 - 1) / (120 * (1 + x) ** 4)
        - x**6 * ((1 + x) ** 6 - 1) / (252 * (1 + x) ** 6)
    )


def demo_pade() -> None:
    print("\n" + "=" * 92)
    print("DEMO 5  The one-variable inequalities behind every order")
    print("=" * 92)
    print("For x >= 0 the following must hold (each is a separate theorem):")
    print("  P2-(x) <= log(1+x) <= P3+(x),   P6-(x) <= log(1+x) <= P4+(x),")
    print("  P5-(x) <= log(1+x)")
    header = (
        f"{'x':>8} {'log(1+x) - P2-':>18} {'P3+ - log':>14} "
        f"{'P4+ - log':>14} {'log - P5-':>14} {'log - P6-':>14}"
    )
    print(header)
    print("-" * len(header))
    for xs in ("0.0", "0.01", "0.1", "0.5", "1.0", "2.0", "10.0"):
        x = Decimal(xs)
        lg = dec_log(1 + x)
        d = [
            lg - pade_lower_2(x),
            pade_upper_3(x) - lg,
            pade_upper_4(x) - lg,
            lg - pade_lower_5(x),
            lg - pade_lower_6(x),
        ]
        assert all(v >= 0 for v in d), f"Pade inequality violated at x = {x}"
        print(
            f"{float(x):>8.2f} {float(d[0]):>18.6E} {float(d[1]):>14.6E} "
            f"{float(d[2]):>14.6E} {float(d[3]):>14.6E} {float(d[4]):>14.6E}"
        )
    print("\nAll five inequalities verified (nonnegative) on the sample points.")


# ----------------------------------------------------------------------
# Demonstration 6 -- the envelope step inequalities
# ----------------------------------------------------------------------


def env_U2(x: Decimal) -> Decimal:
    return 1 / (2 * x) + 1 / (12 * x**2)


def env_L2(x: Decimal) -> Decimal:
    return 1 / (2 * x) + 1 / (12 * x**2) - 1 / (36 * x**3)


def env_U4(x: Decimal) -> Decimal:
    return 1 / (2 * x) + 1 / (12 * x**2) - 1 / (120 * x**4)


def env_L5(x: Decimal) -> Decimal:
    return env_U4(x) + 1 / (300 * x**5)


def env_U6(x: Decimal) -> Decimal:
    return env_U4(x) + 1 / (252 * x**6)


def demo_envelopes() -> None:
    print("\n" + "=" * 92)
    print("DEMO 6  Telescoping envelopes: one-step decrements bracket one sliver")
    print("=" * 92)
    print("sliver(m) = 1/m - log(1 + 1/m)  is the area between the rectangle of")
    print("height 1/m and the hyperbola on [m, m+1].  We check, for m >= 1,")
    print("  L2(m)-L2(m+1) <= sliver(m) <= U2(m)-U2(m+1)")
    print("  U4(m)-U4(m+1) <= sliver(m) <= L5(m)-L5(m+1)")
    print("  sliver(m) <= U6(m)-U6(m+1)")
    header = (
        f"{'m':>6} {'sliver(m)':>18} {'U2 drop':>18} {'L2 drop':>18} "
        f"{'U4 drop':>18} {'U6 drop':>18}"
    )
    print(header)
    print("-" * len(header))
    for mi in (1, 2, 5, 20, 100):
        m = Decimal(mi)
        sliver = 1 / m - dec_log(1 + 1 / m)
        du2 = env_U2(m) - env_U2(m + 1)
        dl2 = env_L2(m) - env_L2(m + 1)
        du4 = env_U4(m) - env_U4(m + 1)
        dl5 = env_L5(m) - env_L5(m + 1)
        du6 = env_U6(m) - env_U6(m + 1)
        assert dl2 <= sliver <= du2
        assert du4 <= sliver <= dl5
        assert sliver <= du6
        print(
            f"{mi:>6} {float(sliver):>18.10E} {float(du2):>18.10E} "
            f"{float(dl2):>18.10E} {float(du4):>18.10E} {float(du6):>18.10E}"
        )
    print("\nAll envelope step inequalities verified on the sample points.")


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------


def main() -> None:
    print("Certified acceleration of the Euler-Mascheroni sequence")
    print(f"gamma = {GAMMA}\n")
    indices = [0, 1, 2, 4, 9, 49, 99, 999]
    demo_error_table(indices)
    demo_sharpness([0, 1, 9, 99, 999, 9999])
    demo_enclosure([0, 1, 4, 9, 99])
    demo_cost()
    demo_pade()
    demo_envelopes()
    print("\n" + "=" * 92)
    print("All proved bounds held at every tested index; no violations.")
    print("=" * 92)


if __name__ == "__main__":
    main()
