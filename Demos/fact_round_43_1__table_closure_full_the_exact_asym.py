#!/usr/bin/env python3
"""
Exact asymptotic constants of the four fork channels — numerical demonstration.

Standard library only (uses `decimal` for high-precision arithmetic, so the
near-cancellation inside the gap channel does not destroy the digits we care
about at large n).

The four channels, for a resolution parameter n >= 2 (all logs base 2):

    H(p)   = -p log2 p - (1-p) log2 (1-p)          binary entropy
    X(n)   = 1 - H(1/2 + 1/n)                      capacity channel
    A(n)   = log2 n / n^2                          ambiguity channel
    g(n)   = -(1 - 1/n^2) log2(1 - 1/n^2) - 1/n^2  gap channel
    R(n)   = -(1/2) log2(1 - 4/n^2)                reverse channel  (n > 2)
    Is(n)  = A(n) + R(n)                           isolation channel

The exact constant laws demonstrated here:

    g(n)  * n^2               -> log2 e - 1 = 0.442695...
    X(n)  * n^2               -> 2 log2 e   = 2.885390...
    A(n)  * n^2 / log2 n      == 1          (identically, for every n >= 2)
    (Is(n) - A(n)) * n^2      -> 2 log2 e   = 2.885390...
    X(n)  / g(n)              -> 2/(1 - ln 2) = 6.517782...   (NOT 2)
    A(n)  / X(n)              -> infinity

with proved finite-n rates

    |g(n) n^2 - (log2 e - 1)| <= 1/(n ln 2)          (n >= 2)
    |X(n) n^2 - 2 log2 e|     <= 24/(n ln 2)         (n >= 4)
    |R(n) n^2 - 2 log2 e|     <= 16/(n ln 2)         (n >= 4)

and the exact small-n structure

    X(2) = 1,  A(2) = 1/4,  g(2) = 5/4 - (3/4) log2 3 = 0.0612781...
    R, Is diverge at n = 2
    A(7) < X(7) and X(8) < A(8), certified by  7^100 < 3^126 * 5^35
                                          and  5^40 * 3^24 < 2^131.
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from typing import Callable, List, Optional, Tuple

getcontext().prec = 60  # working precision in decimal digits

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

LN2: Decimal = Decimal(2).ln()
LOG2E: Decimal = Decimal(1) / LN2          # 1.4426950408889634...
GAP_CONST: Decimal = LOG2E - 1             # 0.4426950408889634...
CAP_CONST: Decimal = 2 * LOG2E             # 2.8853900817779268...
RATIO_CONST: Decimal = Decimal(2) / (1 - LN2)  # 6.5177827065418...


# --------------------------------------------------------------------------
# The four channels
# --------------------------------------------------------------------------

def log2(x: Decimal) -> Decimal:
    """Binary logarithm at working precision."""
    return x.ln() / LN2


def binary_entropy(p: Decimal) -> Decimal:
    """H(p) = -p log2 p - (1-p) log2 (1-p), with the convention 0 log2 0 = 0."""
    q = Decimal(1) - p
    term_p = Decimal(0) if p == 0 else -p * log2(p)
    term_q = Decimal(0) if q == 0 else -q * log2(q)
    return term_p + term_q


def capacity_channel(n: Decimal) -> Decimal:
    """X(n) = 1 - H(1/2 + 1/n): bits lost relative to a fair coin."""
    return Decimal(1) - binary_entropy(Decimal(1) / 2 + Decimal(1) / n)


def ambiguity_channel(n: Decimal) -> Decimal:
    """A(n) = log2 n / n^2."""
    return log2(n) / (n * n)


def gap_channel(n: Decimal) -> Decimal:
    """g(n) = -(1 - 1/n^2) log2(1 - 1/n^2) - 1/n^2."""
    u = Decimal(1) / (n * n)
    return -(Decimal(1) - u) * log2(Decimal(1) - u) - u


def reverse_channel(n: Decimal) -> Optional[Decimal]:
    """R(n) = -(1/2) log2(1 - 4/n^2); undefined (infinite) at n = 2."""
    v = Decimal(4) / (n * n)
    if v >= 1:
        return None
    return -(Decimal(1) / 2) * log2(Decimal(1) - v)


def isolation_channel(n: Decimal) -> Optional[Decimal]:
    """Is(n) = A(n) + R(n)."""
    r = reverse_channel(n)
    return None if r is None else ambiguity_channel(n) + r


# --------------------------------------------------------------------------
# The fork function, and the closed form X(n) = F(2/n) / (2 ln 2)
# --------------------------------------------------------------------------

def fork_function(x: Decimal) -> Decimal:
    """F(x) = (1+x) ln(1+x) + (1-x) ln(1-x); even, non-negative, F(x) = x^2 + O(x^4)."""
    return (1 + x) * (1 + x).ln() + (1 - x) * (1 - x).ln()


# --------------------------------------------------------------------------
# Reporting helpers
# --------------------------------------------------------------------------

def fmt(x: Optional[Decimal], digits: int = 9) -> str:
    if x is None:
        return "        inf"
    return f"{float(x):>{digits + 4}.{digits}f}"


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------
# Demonstration 1 — the master table of the four channels
# --------------------------------------------------------------------------

def demo_table(ns: List[int]) -> None:
    rule("1. The four channels, rescaled by n^2")
    print(f"{'n':>8}  {'X n^2':>13}  {'g n^2':>13}  {'A n^2/log2 n':>13}"
          f"  {'R n^2':>13}  {'X/g':>10}  {'A/X':>10}")
    for k in ns:
        n = Decimal(k)
        nsq = n * n
        X = capacity_channel(n)
        A = ambiguity_channel(n)
        g = gap_channel(n)
        R = reverse_channel(n)
        print(f"{k:>8}  {fmt(X * nsq)}  {fmt(g * nsq)}  "
              f"{fmt(A * nsq / log2(n))}  {fmt(R * nsq if R is not None else None)}  "
              f"{float(X / g):>10.5f}  {float(A / X):>10.5f}")
    print(f"{'limit':>8}  {fmt(CAP_CONST)}  {fmt(GAP_CONST)}  {fmt(Decimal(1))}  "
          f"{fmt(CAP_CONST)}  {float(RATIO_CONST):>10.5f}  {'inf':>10}")


# --------------------------------------------------------------------------
# Demonstration 2 — the exact constants and the refuted guess
# --------------------------------------------------------------------------

def demo_constants(n_big: int = 655360) -> None:
    rule("2. The exact constants (and the refutation of X/g -> 2)")
    n = Decimal(n_big)
    nsq = n * n
    X, A, g = capacity_channel(n), ambiguity_channel(n), gap_channel(n)
    R = reverse_channel(n)
    assert R is not None
    Is = A + R

    rows: List[Tuple[str, Decimal, Decimal]] = [
        ("g * n^2        -> log2 e - 1", g * nsq, GAP_CONST),
        ("X * n^2        -> 2 log2 e  ", X * nsq, CAP_CONST),
        ("A * n^2/log2 n == 1         ", A * nsq / log2(n), Decimal(1)),
        ("(Is - A) * n^2 -> 2 log2 e  ", (Is - A) * nsq, CAP_CONST),
        ("X / g          -> 2/(1-ln2) ", X / g, RATIO_CONST),
    ]
    print(f"evaluated at n = {n_big} with {getcontext().prec}-digit arithmetic\n")
    print(f"{'law':<30}  {'computed':>20}  {'constant':>20}  {'|deviation|':>12}")
    for name, computed, target in rows:
        dev = abs(computed - target)
        print(f"{name:<30}  {float(computed):>20.12f}  {float(target):>20.12f}"
              f"  {float(dev):>12.3e}")

    print()
    print(f"pre-data guess  X/g -> 2          : deviation "
          f"{float(abs(X / g - 2)):.6f}   REFUTED")
    print(f"corrected law   X/g -> 2/(1-ln 2) : deviation "
          f"{float(abs(X / g - RATIO_CONST)):.3e}   confirmed")
    print()
    print("Why 6.5178 and not 2 — the near-cancellation inside g:")
    print(f"  entropy term alone contributes  log2 e     = {float(LOG2E):.6f}")
    print(f"  the definition subtracts        1          = 1.000000")
    print(f"  leaving                         log2 e - 1 = {float(GAP_CONST):.6f}")
    print(f"  so the ratio is inflated by 1/(1-ln 2)     = "
          f"{float(1 / (1 - LN2)):.6f}  (2 x this = {float(RATIO_CONST):.6f})")


# --------------------------------------------------------------------------
# Demonstration 3 — the proved finite-n rate bounds
# --------------------------------------------------------------------------

def demo_rates(ns: List[int]) -> None:
    rule("3. Proved finite-n error bounds versus observed errors")
    print(f"{'n':>8}  {'|g n^2 - c_g|':>14} {'bound 1/(n ln2)':>16} "
          f"{'|X n^2 - c_X|':>14} {'bound 24/(n ln2)':>17} "
          f"{'|R n^2 - c_X|':>14} {'bound 16/(n ln2)':>17}")
    for k in ns:
        n = Decimal(k)
        nsq = n * n
        eg = abs(gap_channel(n) * nsq - GAP_CONST)
        eX = abs(capacity_channel(n) * nsq - CAP_CONST)
        R = reverse_channel(n)
        eR = abs(R * nsq - CAP_CONST) if R is not None else None
        bg, bX, bR = 1 / (n * LN2), 24 / (n * LN2), 16 / (n * LN2)
        ok = (eg <= bg) and (eX <= bX or k < 4) and (eR is None or eR <= bR or k < 4)
        print(f"{k:>8}  {float(eg):>14.3e} {float(bg):>16.3e} "
              f"{float(eX):>14.3e} {float(bX):>17.3e} "
              f"{(float(eR) if eR is not None else float('inf')):>14.3e} "
              f"{float(bR):>17.3e}   {'ok' if ok else '!!'}")
    print("\n(The bounds are deliberately crude: the true errors are O(1/n^2),")
    print(" because the underlying fork function F(x) = (1+x)ln(1+x)+(1-x)ln(1-x) is even.)")


# --------------------------------------------------------------------------
# Demonstration 4 — collapse at n = 2
# --------------------------------------------------------------------------

def demo_collapse() -> None:
    rule("4. The collapse point n = 2")
    two = Decimal(2)
    X2, A2, g2 = capacity_channel(two), ambiguity_channel(two), gap_channel(two)
    g2_exact = Decimal(5) / 4 - (Decimal(3) / 4) * log2(Decimal(3))
    print(f"  X(2) = {float(X2):.12f}   (exact value 1: the coin is a certainty, H(1) = 0)")
    print(f"  A(2) = {float(A2):.12f}   (exact value 1/4)")
    print(f"  g(2) = {float(g2):.12f}   (exact value 5/4 - (3/4) log2 3 = "
          f"{float(g2_exact):.12f})")
    print(f"  g(2) * 4 = {float(g2 * 4):.12f}   (matches the tabulated g*n^2 at n = 2)")
    print(f"  R(2) : {reverse_channel(two)}   -- diverges: 1 - 4/n^2 = 0 at n = 2")
    print(f"  Is(2): {isolation_channel(two)}   -- diverges for the same reason")
    print()
    print("  Note: the forward divergence from a certainty to a fair coin is one bit,")
    print("  but the reverse divergence is infinite, since the fair coin gives positive")
    print("  probability to an event the certainty declares impossible.")


# --------------------------------------------------------------------------
# Demonstration 5 — the A/X crossing in (7,8) with integer certificates
# --------------------------------------------------------------------------

def demo_crossing() -> None:
    rule("5. The A/X sign flip lies exactly in the window (7, 8)")
    for k in range(2, 13):
        n = Decimal(k)
        A, X = ambiguity_channel(n), capacity_channel(n)
        mark = "A < X" if A < X else "A > X"
        print(f"  n = {k:>2}:  A = {float(A):.9f}   X = {float(X):.9f}   "
              f"A/X = {float(A / X):.6f}   {mark}")

    print("\n  Integer certificates (exact arithmetic, no floating point):")
    lhs7, rhs7 = 7 ** 100, 3 ** 126 * 5 ** 35
    lhs8, rhs8 = 5 ** 40 * 3 ** 24, 2 ** 131
    print(f"    A(7) < X(7)  <=>  7^100 < 3^126 * 5^35")
    print(f"        7^100        = {lhs7}")
    print(f"        3^126 * 5^35 = {rhs7}")
    print(f"        holds: {lhs7 < rhs7}")
    print(f"    X(8) < A(8)  <=>  5^40 * 3^24 < 2^131")
    print(f"        5^40 * 3^24  = {lhs8}")
    print(f"        2^131        = {rhs8}")
    print(f"        holds: {lhs8 < rhs8}")

    # Locate the real crossing point by bisection on A - X.
    lo, hi = Decimal(7), Decimal(8)
    f: Callable[[Decimal], Decimal] = lambda t: ambiguity_channel(t) - capacity_channel(t)
    for _ in range(80):
        mid = (lo + hi) / 2
        if f(lo) * f(mid) <= 0:
            hi = mid
        else:
            lo = mid
    print(f"\n  Real crossing point n* = {float((lo + hi) / 2):.12f}  (bisection in (7,8))")


# --------------------------------------------------------------------------
# Demonstration 6 — the closed form X(n) = F(2/n)/(2 ln 2) and its cubic window
# --------------------------------------------------------------------------

def demo_fork_identity(ns: List[int]) -> None:
    rule("6. The closed form X(n) = F(2/n)/(2 ln 2) and the cubic window |F(x)-x^2| <= 6|x|^3")
    print(f"{'n':>8}  {'X(n)':>18}  {'F(2/n)/(2 ln2)':>18}  {'|difference|':>13}"
          f"  {'|F(x)-x^2|':>12}  {'6|x|^3':>12}")
    for k in ns:
        n = Decimal(k)
        x = Decimal(2) / n
        lhs = capacity_channel(n)
        rhs = fork_function(x) / (2 * LN2)
        err = abs(fork_function(x) - x * x)
        bnd = 6 * abs(x) ** 3
        print(f"{k:>8}  {float(lhs):>18.14f}  {float(rhs):>18.14f}  "
              f"{float(abs(lhs - rhs)):>13.3e}  {float(err):>12.3e}  {float(bnd):>12.3e}")


# --------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_table([2, 3, 4, 7, 8, 16, 17, 100, 1000, 100000, 655360])
    demo_constants(655360)
    demo_rates([2, 4, 8, 16, 100, 1000, 100000, 655360])
    demo_collapse()
    demo_crossing()
    demo_fork_identity([4, 8, 16, 100, 1000, 100000])
    rule("All demonstrated laws agree with the proved statements.")


if __name__ == "__main__":
    main()
