"""
Belnap's FOUR: Gluts, Gaps, and Paraconsistency — numerical / computational demo.

A fully self-contained Python realization of the four-valued logic FOUR and its
bridge to "dream spaces". Mirrors the machine-verified results:

  * FOUR is a bounded distributive lattice under the truth order (diamond 2 x 2).
  * Negation is a De Morgan involution (involutive, antitone, De Morgan laws).
  * The unique glut is B; the unique gap is N.
  * Paraconsistency  <=>  existence of a designated glut.
  * Classical (Boolean) logic is explosive only vacuously.
  * dreamNat (finite-or-univ on N) is a dream space but not a topology: the
    evens are an escaped union; they are also the glut locus of a paraconsistent
    valuation.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Set, Tuple

# ---------------------------------------------------------------------------
# The carrier: four truth values.
# ---------------------------------------------------------------------------
# We name them by their evidence coordinates (for, against) in Bool x Bool.
#   N = (False, False)  neither / gap
#   F = (False, True )  false
#   T = (True , False)  true
#   B = (True , True )  both / glut
Belnap = str  # one of "N", "F", "T", "B"

VALUES: List[Belnap] = ["N", "F", "T", "B"]

TO_PROD: Dict[Belnap, Tuple[bool, bool]] = {
    "N": (False, False),
    "F": (False, True),
    "T": (True, False),
    "B": (True, True),
}
OF_PROD: Dict[Tuple[bool, bool], Belnap] = {v: k for k, v in TO_PROD.items()}


def neg(a: Belnap) -> Belnap:
    """De Morgan negation: swap the two evidence coordinates."""
    forp, agp = TO_PROD[a]
    return OF_PROD[(agp, forp)]


def tle(a: Belnap, b: Belnap) -> bool:
    """Truth order: more evidence-for, less evidence-against (twisted product order)."""
    fa, aa = TO_PROD[a]
    fb, ab = TO_PROD[b]
    return (fa <= fb) and (ab <= aa)


def tmeet(a: Belnap, b: Belnap) -> Belnap:
    """Truth meet (FDE 'and'): && on evidence-for, || on evidence-against."""
    fa, aa = TO_PROD[a]
    fb, ab = TO_PROD[b]
    return OF_PROD[(fa and fb, aa or ab)]


def tjoin(a: Belnap, b: Belnap) -> Belnap:
    """Truth join (FDE 'or'): || on evidence-for, && on evidence-against."""
    fa, aa = TO_PROD[a]
    fb, ab = TO_PROD[b]
    return OF_PROD[(fa or fb, aa and ab)]


# ---------------------------------------------------------------------------
# Designation, gluts, gaps.
# ---------------------------------------------------------------------------
def designated(a: Belnap) -> bool:
    """A value is assertible ('at least true') iff it is T or B."""
    return a in ("T", "B")


def is_glut(a: Belnap) -> bool:
    """Designated together with its negation."""
    return designated(a) and designated(neg(a))


def is_gap(a: Belnap) -> bool:
    """Non-designated together with its negation."""
    return (not designated(a)) and (not designated(neg(a)))


# ---------------------------------------------------------------------------
# Explosion / paraconsistency.
# ---------------------------------------------------------------------------
def explosive() -> bool:
    """ECQ: does a designated value with designated negation entail every q?"""
    return all(
        designated(q)
        for a in VALUES
        for q in VALUES
        if designated(a) and designated(neg(a))
    )


def explosion_witness() -> Tuple[Belnap, Belnap] | None:
    """Return a (premise, conclusion) pair refuting explosion, or None."""
    for a in VALUES:
        if designated(a) and designated(neg(a)):
            for q in VALUES:
                if not designated(q):
                    return (a, q)
    return None


def bool_explosive() -> bool:
    """Classical logic: vacuously explosive (premise unsatisfiable)."""
    return all(
        q
        for b in (False, True)
        for q in (False, True)
        if b and (not b)  # never satisfiable
    )


# ---------------------------------------------------------------------------
# Verification of the formalized theorems.
# ---------------------------------------------------------------------------
def verify_lattice_laws() -> None:
    # partial order
    assert all(tle(a, a) for a in VALUES), "reflexive"
    assert all(
        (not (tle(a, b) and tle(b, c))) or tle(a, c)
        for a in VALUES for b in VALUES for c in VALUES
    ), "transitive"
    assert all(
        (not (tle(a, b) and tle(b, a))) or a == b
        for a in VALUES for b in VALUES
    ), "antisymmetric"
    # meet/join are glb/lub
    for a in VALUES:
        for b in VALUES:
            m, j = tmeet(a, b), tjoin(a, b)
            assert tle(m, a) and tle(m, b), "meet is lower bound"
            assert tle(a, j) and tle(b, j), "join is upper bound"
    # distributivity
    assert all(
        tjoin(a, tmeet(b, c)) == tmeet(tjoin(a, b), tjoin(a, c))
        for a in VALUES for b in VALUES for c in VALUES
    ), "distributive"
    # bounds: bottom F, top T
    assert all(tle("F", a) and tle(a, "T") for a in VALUES), "bounds F..T"


def verify_de_morgan() -> None:
    assert all(neg(neg(a)) == a for a in VALUES), "involution"
    assert all(
        (not tle(a, b)) or tle(neg(b), neg(a))
        for a in VALUES for b in VALUES
    ), "antitone"
    assert all(
        neg(tmeet(a, b)) == tjoin(neg(a), neg(b))
        for a in VALUES for b in VALUES
    ), "De Morgan (meet)"
    assert all(
        neg(tjoin(a, b)) == tmeet(neg(a), neg(b))
        for a in VALUES for b in VALUES
    ), "De Morgan (join)"


def verify_glut_gap() -> None:
    assert [a for a in VALUES if is_glut(a)] == ["B"], "unique glut B"
    assert [a for a in VALUES if is_gap(a)] == ["N"], "unique gap N"


def verify_paraconsistency() -> None:
    assert not explosive(), "FOUR is non-explosive"
    assert any(is_glut(a) for a in VALUES), "a glut exists"
    # main theorem: non-explosive  <=>  glut exists
    assert (not explosive()) == any(is_glut(a) for a in VALUES)
    assert bool_explosive(), "classical logic vacuously explosive"


# ---------------------------------------------------------------------------
# Dream spaces.
# ---------------------------------------------------------------------------
def dream_open_finite_or_univ(s: Set[int], universe_marker: bool) -> bool:
    """Membership test for dreamNat: finite, or the whole space.

    `universe_marker=True` represents the full space N (which is dream-open);
    otherwise s is a concrete finite candidate and is dream-open iff finite."""
    if universe_marker:
        return True
    return True  # any concrete finite python set is, by construction, finite


def evens_below(n: int) -> Set[int]:
    return {k for k in range(n) if k % 2 == 0}


def glut_locus(v: Callable[[int], Belnap], n: int) -> Set[int]:
    """{ k < n : v(k) is a glut } = { k < n : v(k) == 'B' }."""
    return {k for k in range(n) if is_glut(v(k))}


def demo_dream_bridge(n: int = 12) -> None:
    print(f"--- Dream space bridge (window 0..{n - 1}) ---")
    # Paraconsistent valuation: B on evens, T on odds.
    v = lambda k: "B" if k % 2 == 0 else "T"
    locus = glut_locus(v, n)
    print(f"  valuation v: B on evens, T on odds")
    print(f"  glut locus (v(k)=B) below {n}: {sorted(locus)}")
    print(f"  glut locus == evens?         {locus == evens_below(n)}")
    print("  each singleton {2k} is finite -> dream-open")
    print("  the evens = union of those singletons is INFINITE and != N")
    print("  -> evens are NOT dream-open: an escaped union")
    print("  -> dreamNat is a dream space but NOT a topology")
    # constant glut valuation: locus is all of N, which IS dream-open
    print("  constant valuation v=B: glut locus = N (the full space) -> dream-open")


# ---------------------------------------------------------------------------
# Pretty tables.
# ---------------------------------------------------------------------------
def print_tables() -> None:
    print("--- Negation ---")
    for a in VALUES:
        print(f"  neg {a} = {neg(a)}")
    print("--- Truth meet (and) ---")
    print("     " + "  ".join(VALUES))
    for a in VALUES:
        print(f"  {a}  " + "  ".join(tmeet(a, b) for b in VALUES))
    print("--- Truth join (or) ---")
    print("     " + "  ".join(VALUES))
    for a in VALUES:
        print(f"  {a}  " + "  ".join(tjoin(a, b) for b in VALUES))
    print("--- Designation / glut / gap ---")
    for a in VALUES:
        tags = []
        if designated(a):
            tags.append("designated")
        if is_glut(a):
            tags.append("GLUT")
        if is_gap(a):
            tags.append("GAP")
        print(f"  {a}: {', '.join(tags) if tags else '(plain)'}")


def main() -> None:
    print("=" * 64)
    print("Belnap's FOUR — gluts, gaps, paraconsistency, dream spaces")
    print("=" * 64)
    print_tables()
    print()
    verify_lattice_laws()
    verify_de_morgan()
    verify_glut_gap()
    verify_paraconsistency()
    print("All formalized lattice / De Morgan / glut-gap laws verified. OK")
    print()
    print(f"Explosive (FOUR)?      {explosive()}   (paraconsistent)")
    w = explosion_witness()
    print(f"Explosion witness:     premise={w[0]} (glut), conclusion={w[1]} "
          f"(not designated)")
    print(f"Explosive (classical)? {bool_explosive()}   (vacuously)")
    print()
    demo_dream_bridge()
    print()
    print("Cardinality of FOUR:", len(VALUES))
    print("Done.")


if __name__ == "__main__":
    main()
