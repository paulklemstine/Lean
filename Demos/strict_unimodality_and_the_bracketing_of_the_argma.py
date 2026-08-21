"""
Numerical demonstrations of the two bracketing degrees of a strictly
log-concave window, and of the exact location of the binomial mode.

The mathematics demonstrated here:

  * A positive sequence a_0, ..., a_n is strictly log-concave when
        a_k * a_{k+2} < a_{k+1}^2      for all k with k + 2 <= n.
    Its lower bracketing degree d- is the first index where the strict rise
    stops; its upper bracketing degree d+ is the first index where the strict
    fall begins.  Then  d- <= d+ <= d- + 1, the maximisers are exactly the
    indices in [d-, d+], and d+ = d- + 1 exactly when a_{d-} = a_{d-+1}.

  * A threshold window (rise criterion  a_k < a_{k+1}  <=>  k + 1 < theta,
    weak criterion  a_k <= a_{k+1}  <=>  k + 1 <= theta) has
        d- = ceil(theta) - 1,    d+ = floor(theta),
    so the gap is 1 exactly when theta is an integer.

  * Binomial weights  w_k = C(n,k) p^k q^(n-k)  are a threshold window with
        theta = (n + 1) p / (p + q)          (the "mode parameter").
    For integer weights P, Q the tie criterion is (P + Q) | (n + 1) P;
    for p = q = 1 it is "n is odd", with d- = n // 2 and d+ = (n + 1) // 2.

  * Peak value bracket:  (p+q)^n / (n+1)  <=  max_k w_k  <=  (p+q)^n.

  * Vertex sweep: every degree d <= n is the unique maximiser of
    k -> C(n,k) p^k  for  p = (2d + 1) / (2n - 2d + 1).

  * Poisson weights  u_k = lam^k / k!  form a threshold window with
    theta = lam; under the scaling p = lam/n, q = 1 - lam/n the binomial
    upper bracket exceeds the Poisson one by 0 or 1.

Everything is computed exactly with Fraction arithmetic wherever possible,
so the reported ties are genuine equalities, not floating-point accidents.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import List, Sequence, Tuple

Number = Fraction


# ----------------------------------------------------------------------
# Core sequence utilities
# ----------------------------------------------------------------------

def binomial_weights(n: int, p: Number, q: Number) -> List[Number]:
    """The terms w_k = C(n,k) p^k q^(n-k) of the expansion of (p+q)^n."""
    return [Fraction(comb(n, k)) * p**k * q ** (n - k) for k in range(n + 1)]


def poisson_weights(n: int, lam: Number) -> List[Number]:
    """The terms u_k = lam^k / k! for k = 0, ..., n."""
    return [lam**k / Fraction(factorial(k)) for k in range(n + 1)]


def is_strictly_log_concave(a: Sequence[Number]) -> bool:
    """Check positivity and a_k a_{k+2} < a_{k+1}^2 on the whole window."""
    if any(x <= 0 for x in a):
        return False
    return all(a[k] * a[k + 2] < a[k + 1] ** 2 for k in range(len(a) - 2))


def first_argmax(a: Sequence[Number]) -> int:
    """Lower bracketing degree: first k with k = n or a_{k+1} <= a_k."""
    n = len(a) - 1
    for k in range(n):
        if a[k + 1] <= a[k]:
            return k
    return n


def last_argmax(a: Sequence[Number]) -> int:
    """Upper bracketing degree: first k with k = n or a_{k+1} < a_k."""
    n = len(a) - 1
    for k in range(n):
        if a[k + 1] < a[k]:
            return k
    return n


def maximiser_set(a: Sequence[Number]) -> List[int]:
    """All indices attaining the maximum, found by brute force."""
    m = max(a)
    return [k for k, x in enumerate(a) if x == m]


# ----------------------------------------------------------------------
# Closed-form predictions
# ----------------------------------------------------------------------

def frac_floor(x: Fraction) -> int:
    return x.numerator // x.denominator


def frac_ceil(x: Fraction) -> int:
    return -((-x.numerator) // x.denominator)


def mode_parameter(n: int, p: Number, q: Number) -> Fraction:
    """theta = (n + 1) p / (p + q)."""
    return Fraction(n + 1) * p / (p + q)


def predicted_brackets(theta: Fraction) -> Tuple[int, int]:
    """(d-, d+) = (ceil(theta) - 1, floor(theta))."""
    return frac_ceil(theta) - 1, frac_floor(theta)


def tie_predicted(theta: Fraction) -> bool:
    """The gap is 1 exactly when theta is an integer."""
    return theta.denominator == 1


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_abstract_bracketing() -> None:
    print("=" * 72)
    print("1.  The two bracketing degrees of a strictly log-concave window")
    print("=" * 72)
    examples = [
        ("binomial C(6,k)", binomial_weights(6, Fraction(1), Fraction(1))),
        ("binomial C(7,k)", binomial_weights(7, Fraction(1), Fraction(1))),
        ("weighted C(5,k) 2^(5-k)", binomial_weights(5, Fraction(1), Fraction(2))),
        ("Poisson lam = 7/2, n = 10", poisson_weights(10, Fraction(7, 2))),
        ("Poisson lam = 4, n = 10", poisson_weights(10, Fraction(4))),
    ]
    for name, a in examples:
        slc = is_strictly_log_concave(a)
        dminus, dplus = first_argmax(a), last_argmax(a)
        argmax = maximiser_set(a)
        print(f"\n  {name}")
        print(f"    strictly log-concave : {slc}")
        print(f"    d- = {dminus},  d+ = {dplus},  gap = {dplus - dminus}")
        print(f"    maximiser set (brute force) : {argmax}")
        assert slc
        assert dminus <= dplus <= dminus + 1, "gap must be 0 or 1"
        assert argmax == list(range(dminus, dplus + 1)), "argmax = [d-, d+]"
        tie = dplus == dminus + 1
        assert tie == (dminus < len(a) - 1 and a[dminus] == a[dminus + 1])
        print(f"    two-term plateau at the top : {tie}   (verified)")


def demo_binomial_mode_formula() -> None:
    print()
    print("=" * 72)
    print("2.  The binomial mode from theta = (n+1)p/(p+q), checked exhaustively")
    print("=" * 72)
    weights = [
        (Fraction(1), Fraction(1)),
        (Fraction(1), Fraction(2)),
        (Fraction(2), Fraction(3)),
        (Fraction(3, 7), Fraction(4, 7)),
        (Fraction(5), Fraction(1)),
    ]
    checked = 0
    for p, q in weights:
        for n in range(1, 41):
            a = binomial_weights(n, p, q)
            theta = mode_parameter(n, p, q)
            pred = predicted_brackets(theta)
            actual = (first_argmax(a), last_argmax(a))
            assert pred == actual, (n, p, q, pred, actual)
            assert tie_predicted(theta) == (actual[1] == actual[0] + 1)
            checked += 1
    print(f"\n  Verified d- = ceil(theta) - 1 and d+ = floor(theta) in {checked} cases")
    print("  (5 weight pairs x n = 1..40), together with the tie criterion")
    print("  'gap = 1 <=> theta is an integer'.\n")

    print("  A closer look at p = 1, q = 2  (weights C(n,k) 2^(n-k)):")
    print("    n   theta        d-   d+   tie   3 | (n+1) ?")
    for n in range(1, 12):
        theta = mode_parameter(n, Fraction(1), Fraction(2))
        dminus, dplus = predicted_brackets(theta)
        tie = dplus == dminus + 1
        div = (n + 1) % 3 == 0
        assert tie == div, "arithmetic tie criterion (P+Q) | (n+1)P"
        print(f"   {n:2d}   {str(theta):10s}  {dminus:3d}  {dplus:3d}   "
              f"{str(tie):5s} {div}")


def demo_classical_row() -> None:
    print()
    print("=" * 72)
    print("3.  Pascal's triangle: d- = n//2, d+ = (n+1)//2, tie iff n is odd")
    print("=" * 72)
    print("\n    n   d-   d+   tie   largest entry C(n, d-)")
    for n in range(1, 15):
        a = binomial_weights(n, Fraction(1), Fraction(1))
        dminus, dplus = first_argmax(a), last_argmax(a)
        assert (dminus, dplus) == (n // 2, (n + 1) // 2)
        tie = dplus == dminus + 1
        assert tie == (n % 2 == 1)
        print(f"   {n:3d}  {dminus:3d}  {dplus:3d}   {str(tie):5s} "
              f"{comb(n, dminus)}")

    print("\n  Strict log-concavity of Pascal rows, C(n,k)C(n,k+2) < C(n,k+1)^2:")
    worst = None
    for n in range(2, 60):
        for k in range(n - 1):
            lhs = comb(n, k) * comb(n, k + 2)
            rhs = comb(n, k + 1) ** 2
            assert lhs < rhs
            ratio = Fraction(lhs, rhs)
            if worst is None or ratio > worst[0]:
                worst = (ratio, n, k)
    ratio, n, k = worst
    print(f"    checked all 2 <= n < 60; the ratio LHS/RHS is largest at "
          f"n = {n}, k = {k},")
    print(f"    where it equals {float(ratio):.6f} < 1.")


def demo_peak_value_bracket() -> None:
    print()
    print("=" * 72)
    print("4.  The peak value bracket  (p+q)^n/(n+1) <= max_k w_k <= (p+q)^n")
    print("=" * 72)
    print("\n     n    p    q     max term / (p+q)^n    lower bound 1/(n+1)")
    for (n, p, q) in [(10, Fraction(1), Fraction(1)),
                      (20, Fraction(1), Fraction(1)),
                      (40, Fraction(1), Fraction(1)),
                      (25, Fraction(1), Fraction(3)),
                      (25, Fraction(7), Fraction(2))]:
        a = binomial_weights(n, p, q)
        peak = max(a)
        total = (p + q) ** n
        share = Fraction(peak, total)
        assert Fraction(1, n + 1) <= share <= 1
        print(f"   {n:3d}  {str(p):4s} {str(q):4s}   {float(share):.8f}"
              f"            {float(Fraction(1, n + 1)):.8f}")


def demo_vertex_sweep() -> None:
    print()
    print("=" * 72)
    print("5.  Vertex sweep: every degree is the unique mode for some weight")
    print("=" * 72)
    n = 8
    print(f"\n  n = {n};  choosing p = (2d+1)/(2n-2d+1) makes d the unique mode.")
    print("     d     p           theta        argmax of C(n,k) p^k")
    for d in range(n + 1):
        p = Fraction(2 * d + 1, 2 * n - 2 * d + 1)
        q = Fraction(1)
        theta = mode_parameter(n, p, q)
        a = binomial_weights(n, p, q)
        argmax = maximiser_set(a)
        assert argmax == [d], (d, argmax)
        assert theta == Fraction(2 * d + 1, 2)
        print(f"   {d:3d}   {str(p):10s}  {str(theta):10s}   {argmax}")
    print("\n  Every point (k, log C(n,k)) is therefore a vertex of the upper hull.")


def demo_staircase() -> None:
    print()
    print("=" * 72)
    print("6.  The mode is a monotone unit staircase in n")
    print("=" * 72)
    p, q = Fraction(2), Fraction(5)
    print(f"\n  p = {p}, q = {q}:  theta increases by p/(p+q) = {p/(p+q)} per trial.")
    print("     n   theta          d+   increment")
    prev = None
    for n in range(0, 21):
        theta = mode_parameter(n, p, q)
        dplus = frac_floor(theta)
        inc = "-" if prev is None else str(dplus - prev)
        if prev is not None:
            assert dplus - prev in (0, 1)
        print(f"   {n:3d}   {str(theta):12s}  {dplus:3d}   {inc}")
        prev = dplus

    print("\n  Monotonicity in p (n = 12, q = 1):")
    print("     p        theta          d-   d+")
    for num in range(1, 9):
        p2 = Fraction(num, 4)
        theta = mode_parameter(12, p2, Fraction(1))
        dminus, dplus = predicted_brackets(theta)
        print(f"   {str(p2):7s}  {str(theta):12s}  {dminus:3d}  {dplus:3d}")


def demo_poisson_and_comparison() -> None:
    print()
    print("=" * 72)
    print("7.  Poisson window (theta = lam) and the binomial/Poisson comparison")
    print("=" * 72)
    print("\n   lam     d-   d+   tie      (brute force on n = 30)")
    for lam in [Fraction(1, 2), Fraction(3, 2), Fraction(3), Fraction(7, 2),
                Fraction(5), Fraction(29, 4)]:
        u = poisson_weights(30, lam)
        dminus, dplus = first_argmax(u), last_argmax(u)
        assert (dminus, dplus) == (frac_ceil(lam) - 1, frac_floor(lam))
        tie = dplus == dminus + 1
        assert tie == (lam.denominator == 1)
        print(f"   {str(lam):6s}  {dminus:3d}  {dplus:3d}   {tie}")

    print("\n  Poisson scaling p = lam/n, q = 1 - lam/n:")
    print("  binomial theta = lam + lam/n, so the binomial mode exceeds the")
    print("  Poisson mode by 0 or 1 -- exactly, for every finite n.")
    print("\n     n    lam    Poisson d+   binomial d+   difference")
    for n in [10, 20, 50, 100, 500]:
        for lam in [Fraction(5, 2), Fraction(4), Fraction(39, 10)]:
            p = lam / Fraction(n)
            q = Fraction(1) - p
            theta_bin = mode_parameter(n, p, q)
            d_pois = frac_floor(lam)
            d_bin = frac_floor(theta_bin)
            diff = d_bin - d_pois
            assert diff in (0, 1)
            assert theta_bin == lam + lam / Fraction(n)
            print(f"   {n:4d}   {str(lam):5s}   {d_pois:9d}   {d_bin:11d}"
                  f"   {diff:9d}")
    print("\n  (The difference is 1 exactly when the extra lam/n pushes the")
    print("   threshold past an integer, e.g. lam = 39/10 with n = 10.)")


def demo_exhaustive_consistency() -> None:
    print()
    print("=" * 72)
    print("8.  Exhaustive consistency check of the whole theory")
    print("=" * 72)
    tested = 0
    ties = 0
    for n in range(1, 26):
        for pn in range(1, 6):
            for qn in range(1, 6):
                p, q = Fraction(pn), Fraction(qn)
                a = binomial_weights(n, p, q)
                assert is_strictly_log_concave(a)
                theta = mode_parameter(n, p, q)
                dminus, dplus = first_argmax(a), last_argmax(a)
                # closed forms
                assert (dminus, dplus) == predicted_brackets(theta)
                # maximiser set is exactly the bracket interval
                assert maximiser_set(a) == list(range(dminus, dplus + 1))
                # tie criteria: analytic and arithmetic
                tie = dplus == dminus + 1
                assert tie == tie_predicted(theta)
                assert tie == (((n + 1) * pn) % (pn + qn) == 0)
                # peak value bracket
                peak = max(a)
                assert (p + q) ** n <= (n + 1) * peak <= (n + 1) * (p + q) ** n
                tested += 1
                ties += int(tie)
    print(f"\n  {tested} binomial windows tested (n = 1..25, p,q in 1..5).")
    print(f"  All closed forms, maximiser sets, tie criteria and peak-value")
    print(f"  brackets agree with brute force.  {ties} of them exhibit a")
    print(f"  two-term plateau, in every case exactly when (p+q) | (n+1)p.")


def main() -> None:
    print()
    print("THE TWO BRACKETING DEGREES OF A STRICTLY LOG-CONCAVE WINDOW")
    print("Numerical demonstrations (exact rational arithmetic throughout)")
    print()
    demo_abstract_bracketing()
    demo_binomial_mode_formula()
    demo_classical_row()
    demo_peak_value_bracket()
    demo_vertex_sweep()
    demo_staircase()
    demo_poisson_and_comparison()
    demo_exhaustive_consistency()
    print()
    print("All assertions passed.")
    print()


if __name__ == "__main__":
    main()
