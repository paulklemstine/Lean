"""
Numerical demonstrations for the Generalized Giampietro-Darmon Factorization.

This self-contained script illustrates, on explicit rational data, the three
pillars of the theory:

  1. The genus-0 cross-ratio valuation factorization
         v_p((a,b;c,d)) = m(a,c) + m(b,d) - m(a,d) - m(b,c),
     where m(x,y) = v_p(x - y) is the local intersection multiplicity.

  2. The local law: chain-additivity of m FAILS, but the ultrametric
     (strong triangle) inequality holds, with an isosceles-equality
     refinement when the two inner multiplicities differ.

  3. The global obstruction Obs(D,E) = <D,D><E,E> - <D,E>^2 (Gram determinant
     of the Neron-Tate height pairing): always nonnegative, symmetric, and
     vanishing for torsion (zero) or proportional divisors.

Only the Python standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence


# ---------------------------------------------------------------------------
# p-adic valuation and local intersection multiplicity
# ---------------------------------------------------------------------------

def padic_valuation(p: int, x: Fraction) -> float:
    """The p-adic valuation v_p(x) of a rational number x.

    Returns +inf for x == 0 (by convention v_p(0) = +inf).
    """
    if x == 0:
        return float("inf")
    num, den = x.numerator, x.denominator
    val = 0
    while num % p == 0:
        num //= p
        val += 1
    while den % p == 0:
        den //= p
        val -= 1
    return float(val)


def local_mult(p: int, x: Fraction, y: Fraction) -> float:
    """Local intersection multiplicity m(x,y) = v_p(x - y)."""
    return padic_valuation(p, x - y)


def cross_ratio(a: Fraction, b: Fraction, c: Fraction, d: Fraction) -> Fraction:
    """The cross-ratio (a,b;c,d) = ((a-c)(b-d)) / ((a-d)(b-c))."""
    return ((a - c) * (b - d)) / ((a - d) * (b - c))


# ---------------------------------------------------------------------------
# 1. Genus-0 factorization
# ---------------------------------------------------------------------------

def demo_factorization() -> None:
    print("=" * 70)
    print("1. Genus-0 cross-ratio valuation factorization")
    print("=" * 70)
    p = 5
    quads = [
        (Fraction(0), Fraction(25), Fraction(5), Fraction(1)),
        (Fraction(1, 5), Fraction(10), Fraction(3), Fraction(2)),
        (Fraction(50), Fraction(0), Fraction(2), Fraction(7)),
    ]
    for (a, b, c, d) in quads:
        lam = cross_ratio(a, b, c, d)
        lhs = padic_valuation(p, lam)
        rhs = (local_mult(p, a, c) + local_mult(p, b, d)
               - local_mult(p, a, d) - local_mult(p, b, c))
        print(f"  (a,b;c,d) = ({a},{b};{c},{d}),  lambda = {lam}")
        print(f"    v_{p}(lambda)            = {lhs}")
        print(f"    m(a,c)+m(b,d)-m(a,d)-m(b,c) = {rhs}")
        assert lhs == rhs, "factorization failed!"
        print("    match: OK")
    print()


# ---------------------------------------------------------------------------
# 2. Local law: additivity fails; ultrametric + isosceles hold
# ---------------------------------------------------------------------------

def demo_local_law() -> None:
    print("=" * 70)
    print("2. Local law: additivity FAILS, ultrametric/isosceles HOLD")
    print("=" * 70)

    # Counterexample to chain-additivity at p = 2 with (0,1,2).
    p = 2
    x, y, z = Fraction(0), Fraction(1), Fraction(2)
    mxy, myz, mxz = local_mult(p, x, y), local_mult(p, y, z), local_mult(p, x, z)
    print(f"  p={p}, (x,y,z)=({x},{y},{z})")
    print(f"    m(x,y)={mxy}, m(y,z)={myz}, m(x,z)={mxz}")
    print(f"    additive prediction m(x,y)+m(y,z) = {mxy + myz}")
    print(f"    additivity holds? {mxz == mxy + myz}   (expected False)")
    assert mxz != mxy + myz
    print()

    # Ultrametric and isosceles over a range of triples.
    triples = [
        (Fraction(0), Fraction(1), Fraction(2)),
        (Fraction(0), Fraction(4), Fraction(8)),
        (Fraction(0), Fraction(2), Fraction(6)),
        (Fraction(1), Fraction(3), Fraction(11)),
    ]
    for (x, y, z) in triples:
        if x == z:
            continue
        mxy, myz, mxz = local_mult(p, x, y), local_mult(p, y, z), local_mult(p, x, z)
        lo = min(mxy, myz)
        ultra_ok = mxz >= lo
        iso_note = ""
        if mxy != myz:
            iso_note = f"  isosceles: m(x,z)==min? {mxz == lo}"
            assert mxz == lo
        print(f"  ({x},{y},{z}): m(x,z)={mxz} >= min({mxy},{myz})={lo}? "
              f"{ultra_ok}{iso_note}")
        assert ultra_ok
    print()


# ---------------------------------------------------------------------------
# 3. Global obstruction: Gram determinant of the height pairing
# ---------------------------------------------------------------------------

def inner(u: Sequence[float], v: Sequence[float]) -> float:
    """Standard real inner product modelling the Neron-Tate height pairing."""
    return sum(ui * vi for ui, vi in zip(u, v))


def obstruction(D: Sequence[float], E: Sequence[float]) -> float:
    """Obs(D,E) = <D,D><E,E> - <D,E>^2, the Gram determinant."""
    return inner(D, D) * inner(E, E) - inner(D, E) ** 2


def demo_obstruction() -> None:
    print("=" * 70)
    print("3. Global obstruction Obs(D,E) = <D,D><E,E> - <D,E>^2")
    print("=" * 70)

    pairs = [
        ([1.0, 2.0, 0.0], [2.0, -1.0, 3.0]),   # independent: Obs > 0
        ([3.0, 0.0, 0.0], [3.0, 0.0, 0.0]),     # equal: Obs = 0
        ([1.0, 1.0, 1.0], [2.0, 2.0, 2.0]),     # proportional (t=2): Obs = 0
        ([0.0, 0.0, 0.0], [5.0, 1.0, 2.0]),     # torsion/zero D: Obs = 0
    ]
    for D, E in pairs:
        obs = obstruction(D, E)
        obs_swapped = obstruction(E, D)
        print(f"  D={D}, E={E}")
        print(f"    Obs(D,E) = {obs:.6g}   (nonnegative: {obs >= -1e-12})")
        print(f"    symmetric? Obs(E,D) = {obs_swapped:.6g}  "
              f"({abs(obs - obs_swapped) < 1e-12})")
        assert obs >= -1e-12
        assert abs(obs - obs_swapped) < 1e-12
        print()

    # Explicit proportional-vanishing check for several scalars t.
    E = [1.0, 2.0, -2.0]
    print("  Proportional vanishing Obs(t*E, E) = 0 for varying t:")
    for t in (-2.0, 0.0, 0.5, 3.0):
        D = [t * e for e in E]
        obs = obstruction(D, E)
        print(f"    t={t:>4}:  Obs = {obs:.6g}")
        assert abs(obs) < 1e-9
    print()


def main() -> None:
    demo_factorization()
    demo_local_law()
    demo_obstruction()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
