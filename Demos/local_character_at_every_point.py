"""
Numerical demonstrations for "The Local Character of the Surreal Order Topology".

Everything in this file is exact rational arithmetic; nothing is approximated.

We cannot compute inside the whole class of surreal numbers, but every argument in
the paper only ever manipulates *finitely many* elements at a time, and each of
those manipulations lives inside a small computable ordered subfield.  We use the
field of finite Levi-Civita-style formal sums

        x  =  sum_k  a_k * eps^{q_k},        a_k in Q,  q_k in Q,

where `eps` is a positive infinitesimal.  This is an ordered field containing the
rationals (the terms with exponent 0), infinitely large elements (negative
exponents) and infinitely small ones (positive exponents), and it embeds into the
surreals as an ordered field, with `eps` mapping to a surreal infinitesimal.  Every
witness constructed below is therefore a genuine witness for the corresponding
surreal statement.

The demonstrations are:

  1. Coinitiality failure          -- squeeze a positive element under a whole family.
  2. Basis-defeating witness       -- defeat any finite family of neighbourhoods of 0.
  3. Transfer by translation       -- do the same at an arbitrary point c.
  4. Sequential discreteness       -- expose a "convergent" sequence as non-convergent.
  5. Archimedean monads            -- clopen basis, and the partition at a fixed scale.
  6. Upper monads have no supremum -- the obstruction to local compactness.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1.  A computable ordered field of "surreal-like" numbers
# ---------------------------------------------------------------------------

Exponent = Fraction
Coeff = Fraction


class LC:
    """A finite formal sum  sum_k a_k * eps^{q_k}  with rational a_k, q_k.

    Smaller exponent = larger order of magnitude.  eps^0 = 1 is the real scale,
    eps^1 is infinitesimal, eps^{-1} is infinite.
    """

    __slots__ = ("terms",)

    def __init__(self, terms: Optional[Dict[Exponent, Coeff]] = None) -> None:
        cleaned: Dict[Exponent, Coeff] = {}
        if terms:
            for q, a in terms.items():
                a = Fraction(a)
                if a != 0:
                    cleaned[Fraction(q)] = a
        self.terms: Dict[Exponent, Coeff] = cleaned

    # -- constructors --------------------------------------------------------

    @staticmethod
    def rational(a: Fraction | int) -> "LC":
        """The element `a` (a real/rational scale-0 element)."""
        return LC({Fraction(0): Fraction(a)})

    @staticmethod
    def eps(power: Fraction | int = 1, coeff: Fraction | int = 1) -> "LC":
        """The element  coeff * eps^power."""
        return LC({Fraction(power): Fraction(coeff)})

    @staticmethod
    def zero() -> "LC":
        return LC()

    # -- arithmetic ----------------------------------------------------------

    def __add__(self, other: "LC") -> "LC":
        out = dict(self.terms)
        for q, a in other.terms.items():
            out[q] = out.get(q, Fraction(0)) + a
        return LC(out)

    def __neg__(self) -> "LC":
        return LC({q: -a for q, a in self.terms.items()})

    def __sub__(self, other: "LC") -> "LC":
        return self + (-other)

    def __mul__(self, other: "LC") -> "LC":
        out: Dict[Exponent, Coeff] = {}
        for q1, a1 in self.terms.items():
            for q2, a2 in other.terms.items():
                q = q1 + q2
                out[q] = out.get(q, Fraction(0)) + a1 * a2
        return LC(out)

    def scale(self, c: Fraction | int) -> "LC":
        return self * LC.rational(c)

    # -- order ---------------------------------------------------------------

    def leading(self) -> Optional[Tuple[Exponent, Coeff]]:
        """The term of smallest exponent (largest magnitude), or None if zero."""
        if not self.terms:
            return None
        q = min(self.terms)
        return (q, self.terms[q])

    def sign(self) -> int:
        lead = self.leading()
        if lead is None:
            return 0
        return 1 if lead[1] > 0 else -1

    def __lt__(self, other: "LC") -> bool:
        return (self - other).sign() < 0

    def __le__(self, other: "LC") -> bool:
        return (self - other).sign() <= 0

    def __gt__(self, other: "LC") -> bool:
        return (self - other).sign() > 0

    def __ge__(self, other: "LC") -> bool:
        return (self - other).sign() >= 0

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, LC):
            return NotImplemented
        return self.terms == other.terms

    def __hash__(self) -> int:
        return hash(tuple(sorted(self.terms.items())))

    def abs(self) -> "LC":
        return self if self.sign() >= 0 else -self

    # -- display -------------------------------------------------------------

    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        pieces: List[str] = []
        for q in sorted(self.terms):
            a = self.terms[q]
            if q == 0:
                pieces.append(f"{a}")
            elif q == 1:
                pieces.append(f"{a}*eps")
            else:
                pieces.append(f"{a}*eps^{q}")
        return " + ".join(pieces).replace("+ -", "- ")


ONE = LC.rational(1)
ZERO = LC.zero()


def powhalf(n: int) -> LC:
    """The dyadic scale ph(n) = 2^{-n}, exactly as in the paper."""
    return LC.rational(Fraction(1, 2 ** n))


# ---------------------------------------------------------------------------
# 2.  The engine: coinitiality failure
# ---------------------------------------------------------------------------


def cut_below_family(family: Sequence[LC]) -> LC:
    """Given positive x_1, ..., x_N, return y with 0 < y < x_i for every i.

    This is the computational shadow of the Conway cut  y = {0 | x_1, ..., x_N}.
    Concretely: if q* is the largest leading exponent occurring (i.e. the smallest
    element's order of magnitude), then eps^{q*+1} is smaller than all of them.
    Cost: O(N).
    """
    for x in family:
        if x.sign() <= 0:
            raise ValueError(f"family must be strictly positive, got {x}")
    if not family:
        return ONE
    q_star = max(x.leading()[0] for x in family)  # type: ignore[index]
    return LC.eps(q_star + 1)


def demo_coinitiality() -> None:
    print("=" * 78)
    print("1.  COINITIALITY FAILURE")
    print("=" * 78)
    print("Theorem: for ANY family (r_i) of positive surreals there is y > 0 with")
    print("         y < r_i for all i.  Witness: the Conway cut y = {0 | (r_i)}.")
    print()

    # A family that IS coinitial in the positive reals: 1, 1/2, 1/4, ...
    family = [powhalf(n) for n in range(8)]
    y = cut_below_family(family)
    print(f"  family      : 1, 1/2, 1/4, ..., 2^-7   (coinitial in the POSITIVE REALS)")
    print(f"  witness y   : {y}")
    print(f"  0 < y       : {ZERO < y}")
    print(f"  y < r_n all : {all(y < r for r in family)}")
    print()

    # Now a family already containing infinitesimals of several orders.
    family2 = [LC.eps(1), LC.eps(2), LC.eps(Fraction(5, 2)), LC.eps(3, 7)]
    y2 = cut_below_family(family2)
    print(f"  family      : {[str(f) for f in family2]}")
    print(f"  witness y   : {y2}")
    print(f"  0 < y < all : {ZERO < y2 and all(y2 < r for r in family2)}")
    print()
    print("  Note there is no cardinality restriction in the theorem: the same one-step")
    print("  cut works for a family of ANY size.  Here we can only exhibit finite ones.")
    print()


# ---------------------------------------------------------------------------
# 3.  Defeating a neighbourhood basis at 0, and at an arbitrary point
# ---------------------------------------------------------------------------

Interval = Tuple[LC, LC]


def defeat_basis_at_zero(intervals: Sequence[Interval]) -> LC:
    """Given intervals (l_i, r_i) with l_i < 0 < r_i, return y > 0 such that the
    neighbourhood (-y, y) of 0 contains NONE of them.

    Proof content of Theorem "no small family of neighbourhoods of 0 is a basis":
    take y strictly below every r_i; then y lies in each (l_i, r_i) but not in (-y, y).
    """
    rights = [r for (_, r) in intervals]
    return cut_below_family(rights)


def defeat_basis_at_point(c: LC, intervals: Sequence[Interval]) -> LC:
    """The same at an arbitrary point c, by translating to 0 and back.

    Given intervals (l_i, r_i) with l_i < c < r_i, return y > 0 such that
    (c - y, c + y) contains none of them.
    """
    translated = [(l - c, r - c) for (l, r) in intervals]
    return defeat_basis_at_zero(translated)


def demo_basis_defeat() -> None:
    print("=" * 78)
    print("2.  NO SMALL FAMILY OF NEIGHBOURHOODS IS A BASIS (at 0)")
    print("=" * 78)
    intervals: List[Interval] = [
        (LC.rational(-1), LC.rational(1)),
        (LC.rational(Fraction(-1, 10)), LC.rational(Fraction(1, 10))),
        (-LC.eps(1), LC.eps(1)),
        (-LC.eps(2, 3), LC.eps(2, 5)),
        (-LC.eps(Fraction(7, 2)), LC.eps(Fraction(7, 2))),
    ]
    y = defeat_basis_at_zero(intervals)
    s_lo, s_hi = -y, y
    print(f"  candidate basis B_i = (l_i, r_i):")
    for (l, r) in intervals:
        print(f"      ({l}, {r})")
    print(f"  defeating neighbourhood s = (-y, y) with y = {y}")
    print()
    ok = True
    for (l, r) in intervals:
        inside_Bi = (l < y) and (y < r)          # y belongs to B_i
        inside_s = (s_lo < y) and (y < s_hi)     # ... but not to s
        good = inside_Bi and not inside_s
        ok = ok and good
        print(f"      y in ({l}, {r}) : {inside_Bi};  y in s : {inside_s}  -> B_i not subset of s : {good}")
    print(f"  every B_i escapes s : {ok}")
    print()

    print("=" * 78)
    print("3.  TRANSFER BY TRANSLATION (same statement at an arbitrary point c)")
    print("=" * 78)
    c = LC({Fraction(-1): Fraction(3), Fraction(0): Fraction(7, 2)})  # 3*eps^-1 + 7/2, an infinite surreal
    print(f"  base point c = {c}   (an infinitely large element)")
    intervals_c: List[Interval] = [(c + l, c + r) for (l, r) in intervals]
    yc = defeat_basis_at_point(c, intervals_c)
    print(f"  defeating neighbourhood (c - y, c + y) with y = {yc}")
    ok = True
    for (l, r) in intervals_c:
        witness = c + yc
        inside_Bi = (l < witness) and (witness < r)
        inside_s = (c - yc < witness) and (witness < c + yc)
        good = inside_Bi and not inside_s
        ok = ok and good
    print(f"  every B_i escapes the new neighbourhood : {ok}")
    print("  (the witness is literally the translate c + y of the witness at 0)")
    print()


# ---------------------------------------------------------------------------
# 4.  Sequential discreteness
# ---------------------------------------------------------------------------


def sequential_discreteness_witness(seq: Sequence[LC], c: LC) -> Optional[LC]:
    """If seq is not eventually equal to c (on the finite window given), return a
    positive y such that |seq[n] - c| > y for every n with seq[n] != c.

    Then (c - y, c + y) is a neighbourhood of c that the sequence never enters
    except at indices where it already equals c -- so convergence to c would force
    the sequence to be eventually constant.  Returns None if seq is constantly c.
    """
    distances = [(x - c).abs() for x in seq if x != c]
    if not distances:
        return None
    return cut_below_family(distances)


def demo_sequential_discreteness() -> None:
    print("=" * 78)
    print("4.  SEQUENTIAL DISCRETENESS")
    print("=" * 78)
    print("Theorem: a sequence converges iff it is eventually constant.")
    print()
    c = LC.rational(0)

    # A sequence that would converge to 0 in the reals.
    seq_real = [powhalf(n) for n in range(1, 9)]
    y = sequential_discreteness_witness(seq_real, c)
    print(f"  sequence  : 1/2, 1/4, ..., 2^-8      ('converges to 0' in R)")
    print(f"  witness y : {y}")
    print(f"  all terms stay OUTSIDE (-y, y): "
          f"{all(not (-y < x and x < y) for x in seq_real)}")
    print("  -> the sequence never enters this neighbourhood of 0, so it does not converge.")
    print()

    # Even a sequence of ever-smaller infinitesimals fails.
    seq_inf = [LC.eps(n) for n in range(1, 9)]
    y2 = sequential_discreteness_witness(seq_inf, c)
    print(f"  sequence  : eps, eps^2, ..., eps^8   (each infinitely smaller than the last)")
    print(f"  witness y : {y2}")
    print(f"  all terms stay OUTSIDE (-y, y): "
          f"{all(not (-y2 < x and x < y2) for x in seq_inf)}")
    print()

    # An eventually-constant sequence DOES converge.
    seq_const = [LC.rational(5)] * 3 + [c] * 6
    y3 = sequential_discreteness_witness(seq_const, c)
    print(f"  sequence  : 5, 5, 5, 0, 0, 0, 0, 0, 0   (eventually constant)")
    print(f"  witness y : {y3}  -- but only finitely many terms differ from c,")
    print("              so the sequence is eventually inside EVERY neighbourhood: it converges.")
    print()


# ---------------------------------------------------------------------------
# 5.  Archimedean monads
# ---------------------------------------------------------------------------


def in_monad(z: LC, c: LC, d: LC) -> bool:
    """Decide  z in monad(c, d) = { z : |z - c| < d * 2^{-n} for all n }.

    In the Levi-Civita model this is an O(1) comparison of leading exponents:
    z is in the monad iff z = c, or the leading exponent of z - c strictly exceeds
    the leading exponent of d (bigger exponent = smaller order of magnitude).
    """
    if d.sign() <= 0:
        raise ValueError("scale d must be positive")
    diff = z - c
    if diff == ZERO:
        return True
    return diff.leading()[0] > d.leading()[0]  # type: ignore[index]


def monad_representative_scale(c: LC, d: LC) -> Fraction:
    """The archimedean class label of the monad of c at scale d."""
    return d.leading()[0]  # type: ignore[index]


def demo_monads() -> None:
    print("=" * 78)
    print("5.  ARCHIMEDEAN MONADS: A CLOPEN BASIS THAT PARTITIONS EACH SCALE")
    print("=" * 78)
    c = LC.rational(0)
    d = ONE  # the real scale
    print(f"  scale d = {d}; monad(0, 1) = the infinitesimals.")
    tests = [
        (LC.eps(1), True),
        (LC.eps(5, 100), True),
        (LC.rational(Fraction(1, 10 ** 6)), False),
        (LC.rational(0), True),
        (ONE, False),
    ]
    for z, expected in tests:
        got = in_monad(z, c, d)
        mark = "in " if got else "out"
        print(f"      {str(z):>22}  ->  {mark} monad(0, 1)   [expected {'in ' if expected else 'out'}]")
        assert got == expected
    print()
    print("  Containment in an interval:  monad(c, d) subset (c - d, c + d).")
    z = LC.eps(1, 999)
    print(f"      z = {z} lies in monad(0,1) and in (-1, 1): "
          f"{in_monad(z, c, d) and (-ONE < z and z < ONE)}")
    print()

    print("  Partition property: at a fixed scale, monads are equal or disjoint.")
    centres = [LC.rational(0), LC.eps(1), LC.rational(1), LC.rational(1) + LC.eps(2)]
    n = len(centres)
    for i in range(n):
        row = []
        for j in range(n):
            row.append("=" if in_monad(centres[j], centres[i], d) else ".")
        print(f"      centre {str(centres[i]):>14} : {' '.join(row)}")
    print("      ('=' means the two centres share a monad at scale 1)")
    print()

    print("  Changing scale refines the partition:")
    d2 = LC.eps(2)
    print(f"      at scale d = {d2}, is eps in monad(0, d)?  {in_monad(LC.eps(1), c, d2)}")
    print(f"      at scale d = {d2}, is eps^3 in monad(0, d)? {in_monad(LC.eps(3), c, d2)}")
    print("      -> shrinking the scale means passing to a finer archimedean class.")
    print("      Since the scales form a proper class, no SET of monads can be a basis.")
    print()


# ---------------------------------------------------------------------------
# 6.  The upper monad has no supremum
# ---------------------------------------------------------------------------


def upper_monad_beat(candidate: LC, c: LC, d: LC) -> Tuple[str, LC]:
    """Show that `candidate` is not the least upper bound of the upper monad
    U(c, d) = monad(c, d) cap (c, infinity).

    Returns ("not an upper bound", w)  with w in U(c,d) and w > candidate; or
            ("not least",          x') with x' a strictly smaller upper bound.
    """
    if candidate <= c:
        # anything in the monad above c beats it
        return ("not an upper bound", c + LC.eps(monad_representative_scale(c, d) + 1))
    if in_monad(candidate, c, d):
        w = c + (candidate - c).scale(2)   # doubling stays inside the monad
        return ("not an upper bound", w)
    # candidate is outside: find n with candidate - c >= d * 2^{-n}, then
    # c + d*2^{-(n+1)} is a strictly smaller upper bound.
    n = 0
    while not (d * powhalf(n) <= candidate - c):
        n += 1
        if n > 4096:
            raise RuntimeError("unexpected: no finite dyadic level found")
    return ("not least", c + d * powhalf(n + 1))


def demo_no_supremum() -> None:
    print("=" * 78)
    print("6.  UPPER MONADS HAVE NO SUPREMUM  =>  NOWHERE LOCAL COMPACTNESS")
    print("=" * 78)
    c = LC.rational(0)
    d = ONE
    print("  U(0, 1) = the positive infinitesimals.  We try candidate suprema:")
    candidates = [LC.eps(1), LC.eps(1, 1000), LC.eps(5), LC.rational(Fraction(1, 1000)), ONE]
    for x in candidates:
        reason, wit = upper_monad_beat(x, c, d)
        if reason == "not an upper bound":
            check = in_monad(wit, c, d) and (c < wit) and (x < wit)
        else:
            check = (wit < x) and all(
                z < wit for z in [LC.eps(1), LC.eps(2), LC.eps(1, 10 ** 9)]
            )
        print(f"      candidate {str(x):>22} : {reason:<20} witness {str(wit):>22}  verified={check}")
        assert check
    print()
    print("  Every candidate fails, so U(0,1) has no least upper bound.  A compact set in a")
    print("  linear order must contain suprema of its nonempty closed subsets, and U(0,1)")
    print("  sits inside every small neighbourhood of 0; hence no neighbourhood is compact.")
    print()


# ---------------------------------------------------------------------------
# 7.  Summary table
# ---------------------------------------------------------------------------


def demo_summary() -> None:
    print("=" * 78)
    print("SUMMARY: the local dichotomy of the surreal line")
    print("=" * 78)
    rows: List[Tuple[str, str]] = [
        ("countable neighbourhood basis", "fails at every point"),
        ("small (set-sized) basis", "fails at every point"),
        ("metric inducing the topology", "does not exist"),
        ("nontrivial sequential convergence", "does not exist"),
        ("discreteness", "fails (the order is dense)"),
        ("connectedness", "fails (totally separated)"),
        ("compact neighbourhood", "fails at every point"),
        ("clopen neighbourhood basis", "HOLDS at every point (archimedean monads)"),
    ]
    width = max(len(a) for a, _ in rows)
    for a, b in rows:
        print(f"  {a.ljust(width)}  :  {b}")
    print()


def main() -> None:
    demo_coinitiality()
    demo_basis_defeat()
    demo_sequential_discreteness()
    demo_monads()
    demo_no_supremum()
    demo_summary()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
