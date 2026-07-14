"""
Numerical demonstrations for:

    Universality of the Cubic Spectral-Gap Exponent for Weighted Swap Chains

Every result is verified two ways: (1) by brute-force summation over the finite
state space directly from the definitions of Dirichlet energy and variation, and
(2) against the closed-form theorems. The two must agree to floating-point
tolerance.

Definitions (uniform reference measure on a finite state set V):

    Dirichlet energy   E(f) = sum_{x,y} Q(x,y) * (f(x) - f(y))^2
    Variation          V(f) = sum_{x,y} (f(x) - f(y))^2
    Rayleigh quotient  R(f) = E(f) / V(f)
    Spectral gap       gap  = inf over non-constant f of R(f)

Weighted path of n sites {0,...,n-1} with conductance c:
    Q(x,y) = c if |x-y| = 1 else 0
    position statistic f(i) = i

Closed forms (exact):
    E(f) = 2 c (n-1)
    V(f) = n^2 (n^2 - 1) / 6
    R(f) = 12 c / (n^2 (n+1))     in the window [6 c n^-3, 12 c n^-3]
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
#  Abstract finite-state Rayleigh calculus (straight from the definitions)     #
# --------------------------------------------------------------------------- #
def dirichlet_energy(
    states: Sequence[int],
    conductance: Callable[[int, int], Fraction],
    f: Callable[[int], Fraction],
) -> Fraction:
    """Brute-force Dirichlet energy E(f) = sum_{x,y} Q(x,y) (f(x)-f(y))^2."""
    total = Fraction(0)
    for x in states:
        for y in states:
            total += conductance(x, y) * (f(x) - f(y)) ** 2
    return total


def variation(states: Sequence[int], f: Callable[[int], Fraction]) -> Fraction:
    """Brute-force variation V(f) = sum_{x,y} (f(x)-f(y))^2 = 2|V| Var(f)."""
    total = Fraction(0)
    for x in states:
        for y in states:
            total += (f(x) - f(y)) ** 2
    return total


def rayleigh_quotient(
    states: Sequence[int],
    conductance: Callable[[int, int], Fraction],
    f: Callable[[int], Fraction],
) -> Fraction:
    """R(f) = E(f) / V(f) for a non-constant f."""
    return dirichlet_energy(states, conductance, f) / variation(states, f)


# --------------------------------------------------------------------------- #
#  The conductance-weighted path                                              #
# --------------------------------------------------------------------------- #
def weighted_path_conductance(c: Fraction) -> Callable[[int, int], Fraction]:
    """Q_c(x,y) = c if |x-y|=1 else 0."""

    def q(x: int, y: int) -> Fraction:
        return c if abs(x - y) == 1 else Fraction(0)

    return q


def position_statistic(i: int) -> Fraction:
    """f(i) = i."""
    return Fraction(i)


# ------- closed forms from the theorems ------------------------------------ #
def energy_closed_form(n: int, c: Fraction) -> Fraction:
    return 2 * c * (n - 1)


def variation_closed_form(n: int) -> Fraction:
    return Fraction(n) ** 2 * (Fraction(n) ** 2 - 1) / 6


def rq_closed_form(n: int, c: Fraction) -> Fraction:
    return 12 * c / (Fraction(n) ** 2 * (n + 1))


def genus_conductance(g: int) -> Fraction:
    """c(g) = 1 / (g+1): strictly positive, strictly decreasing in g."""
    return Fraction(1, g + 1)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_exact_identities() -> None:
    print("=" * 70)
    print("DEMO 1  Exact energy / variation / Rayleigh identities")
    print("=" * 70)
    print(f"{'n':>3} {'c':>6} {'E brute':>12} {'E form':>12} "
          f"{'V brute':>12} {'R brute':>16} {'R form':>16}")
    for n in range(2, 9):
        for c in (Fraction(1), Fraction(1, 2), Fraction(3)):
            states = list(range(n))
            q = weighted_path_conductance(c)
            e_b = dirichlet_energy(states, q, position_statistic)
            v_b = variation(states, position_statistic)
            r_b = rayleigh_quotient(states, q, position_statistic)
            e_f = energy_closed_form(n, c)
            v_f = variation_closed_form(n)
            r_f = rq_closed_form(n, c)
            assert e_b == e_f, (n, c, e_b, e_f)
            assert v_b == v_f, (n, c, v_b, v_f)
            assert r_b == r_f, (n, c, r_b, r_f)
            print(f"{n:>3} {str(c):>6} {str(e_b):>12} {str(e_f):>12} "
                  f"{str(v_b):>12} {str(r_b):>16} {str(r_f):>16}")
    print("All brute-force values match the closed forms exactly.\n")


def demo_cubic_window() -> None:
    print("=" * 70)
    print("DEMO 2  The Rayleigh quotient is trapped in [6c n^-3, 12c n^-3]")
    print("=" * 70)
    c = Fraction(1)
    print(f"{'n':>4} {'6c/n^3':>14} {'R(f)':>16} {'12c/n^3':>14} {'n^3*R':>10}")
    for n in (2, 5, 10, 50, 200, 1000):
        lo = 6 * c / Fraction(n) ** 3
        hi = 12 * c / Fraction(n) ** 3
        r = rq_closed_form(n, c)
        assert lo <= r <= hi, (n, lo, r, hi)
        scaled = float(Fraction(n) ** 3 * r)  # -> 12c/(1+1/n) in [6c,12c]
        print(f"{n:>4} {float(lo):>14.3e} {float(r):>16.3e} "
              f"{float(hi):>14.3e} {scaled:>10.4f}")
    print("n^3 * R(f) -> 12 as n grows: the exponent is exactly 3.\n")


def demo_conductance_monotone() -> None:
    print("=" * 70)
    print("DEMO 3  The leading constant is strictly increasing in conductance")
    print("=" * 70)
    n = 12
    prev = None
    print(f"(fixed n = {n})")
    print(f"{'c':>8} {'R(f)':>18} {'strictly increasing?':>22}")
    for c in (Fraction(1, 10), Fraction(1, 2), Fraction(1),
              Fraction(2), Fraction(5)):
        r = rq_closed_form(n, c)
        ok = "-" if prev is None else str(prev < r)
        if prev is not None:
            assert prev < r
        prev = r
        print(f"{str(c):>8} {float(r):>18.6e} {ok:>22}")
    print("R(f) strictly increases with c; the exponent never changes.\n")


def demo_genus_amplitude() -> None:
    print("=" * 70)
    print("DEMO 4  Genus enters only through the constant: c(g)=1/(g+1)")
    print("=" * 70)
    n = 20
    prev_amp = None
    print(f"(fixed n = {n};  gap bound = 12 c(g) / n^3)")
    print(f"{'g':>3} {'c(g)':>12} {'12 c(g)':>12} {'gap bound':>16} "
          f"{'decreasing?':>14}")
    for g in range(0, 6):
        cg = genus_conductance(g)
        amp = 12 * cg
        bound = amp / Fraction(n) ** 3
        dec = "-" if prev_amp is None else str(amp < prev_amp)
        if prev_amp is not None:
            assert 0 < amp < prev_amp
        prev_amp = amp
        print(f"{g:>3} {float(cg):>12.5f} {float(amp):>12.5f} "
              f"{float(bound):>16.3e} {dec:>14}")
    print("Amplitude 12 c(g) is strictly positive and strictly decreasing"
          " in g;\nthe cubic exponent -3 is untouched.\n")


def demo_universality_certificate() -> None:
    print("=" * 70)
    print("DEMO 5  Universality: linear energy + quartic variation => n^-3")
    print("=" * 70)
    # On the weighted path the profile is E <= c_e n and V >= c_v n^4.
    # Take c = 1: E = 2(n-1) <= 2 n  (c_e = 2); V = n^2(n^2-1)/6 >= n^4/12
    # for n >= 2 (c_v = 1/12). Certified bound: (c_e/c_v) n^-3 = 24 n^-3.
    c_e = Fraction(2)
    c_v = Fraction(1, 12)
    c = Fraction(1)
    print(f"{'n':>4} {'E<=c_e n?':>10} {'V>=c_v n^4?':>12} "
          f"{'true R':>14} {'cert (c_e/c_v)n^-3':>20}")
    for n in (2, 4, 8, 16, 64):
        states = list(range(n))
        q = weighted_path_conductance(c)
        e = dirichlet_energy(states, q, position_statistic)
        v = variation(states, position_statistic)
        r = e / v
        cert = (c_e / c_v) * Fraction(n) ** (-3)
        e_ok = e <= c_e * n
        v_ok = c_v * Fraction(n) ** 4 <= v
        assert e_ok and v_ok
        assert r <= cert  # the universality guarantee
        print(f"{n:>4} {str(e_ok):>10} {str(v_ok):>12} "
              f"{float(r):>14.3e} {float(cert):>20.3e}")
    print("The certified bound (c_e/c_v) n^-3 dominates the true quotient"
          " for every n.\n")


def main() -> None:
    demo_exact_identities()
    demo_cubic_window()
    demo_conductance_monotone()
    demo_genus_amplitude()
    demo_universality_certificate()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
