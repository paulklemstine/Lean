"""
Dream Logic: numerical demonstrations of the interlaced bilattice FOUR,
the paraconsistent consequence relation, and the topology of coexisting
contradictions.

Self-contained. Run with:  python demo.py

The four truth values:
    'tt'      -- true only
    'ff'      -- false only
    'both'    -- a GLUT: true and false at once (an impossible object)
    'neither' -- a GAP: undetermined
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Set, Tuple, Union

FV = str  # one of 'tt', 'ff', 'both', 'neither'
VALUES: Tuple[FV, ...] = ("tt", "ff", "both", "neither")


# ---------------------------------------------------------------------------
# 1. The two orders
# ---------------------------------------------------------------------------
def tle(a: FV, b: FV) -> bool:
    """Truth order: bottom ff, top tt, both/neither incomparable in the middle."""
    return a == "ff" or b == "tt" or a == b


def kle(a: FV, b: FV) -> bool:
    """Knowledge order: bottom neither, top both, tt/ff incomparable."""
    return a == "neither" or b == "both" or a == b


# ---------------------------------------------------------------------------
# 2. The four operations, negation, and conflation
# ---------------------------------------------------------------------------
def _glb(values: Tuple[FV, ...], leq: Callable[[FV, FV], bool], a: FV, b: FV) -> FV:
    """Greatest lower bound of a, b under the order `leq`."""
    lowers = [x for x in values if leq(x, a) and leq(x, b)]
    # the glb is the unique lower bound above all other lower bounds
    for x in lowers:
        if all(leq(y, x) for y in lowers):
            return x
    raise ValueError("no glb")


def _lub(values: Tuple[FV, ...], leq: Callable[[FV, FV], bool], a: FV, b: FV) -> FV:
    uppers = [x for x in values if leq(a, x) and leq(b, x)]
    for x in uppers:
        if all(leq(x, y) for y in uppers):
            return x
    raise ValueError("no lub")


def tmeet(a: FV, b: FV) -> FV:
    """Conjunction (truth meet)."""
    return _glb(VALUES, tle, a, b)


def tjoin(a: FV, b: FV) -> FV:
    """Disjunction (truth join)."""
    return _lub(VALUES, tle, a, b)


def kmeet(a: FV, b: FV) -> FV:
    """Consensus (knowledge meet): keep only what both agree on."""
    return _glb(VALUES, kle, a, b)


def kjoin(a: FV, b: FV) -> FV:
    """Gullibility (knowledge join): accept information from either side."""
    return _lub(VALUES, kle, a, b)


def neg(a: FV) -> FV:
    """Paraconsistent negation: swap tt/ff, fix both/neither."""
    return {"tt": "ff", "ff": "tt", "both": "both", "neither": "neither"}[a]


def conf(a: FV) -> FV:
    """Conflation: swap both/neither, fix tt/ff."""
    return {"tt": "tt", "ff": "ff", "both": "neither", "neither": "both"}[a]


def designated(a: FV) -> bool:
    """Accepted as at-least-true: tt or both."""
    return a in ("tt", "both")


# ---------------------------------------------------------------------------
# 3. Verifying the algebraic laws (all decidable by exhaustion)
# ---------------------------------------------------------------------------
def verify_bilattice_laws() -> Dict[str, bool]:
    """Check the partial-order, lattice, interlacing, and negation laws."""
    results: Dict[str, bool] = {}

    results["tle partial order"] = (
        all(tle(a, a) for a in VALUES)
        and all(
            (not (tle(a, b) and tle(b, c))) or tle(a, c)
            for a in VALUES for b in VALUES for c in VALUES
        )
        and all(
            (not (tle(a, b) and tle(b, a))) or a == b
            for a in VALUES for b in VALUES
        )
    )
    results["kle partial order"] = (
        all(kle(a, a) for a in VALUES)
        and all(
            (not (kle(a, b) and kle(b, c))) or kle(a, c)
            for a in VALUES for b in VALUES for c in VALUES
        )
        and all(
            (not (kle(a, b) and kle(b, a))) or a == b
            for a in VALUES for b in VALUES
        )
    )
    results["tmeet/tjoin commutative"] = all(
        tmeet(a, b) == tmeet(b, a) and tjoin(a, b) == tjoin(b, a)
        for a in VALUES for b in VALUES
    )
    results["absorption (truth)"] = all(
        tmeet(a, tjoin(a, b)) == a and tjoin(a, tmeet(a, b)) == a
        for a in VALUES for b in VALUES
    )
    # Interlacing: truth meet is monotone in the knowledge order
    results["interlace tmeet in kle"] = all(
        (not (kle(a, b) and kle(c, d))) or kle(tmeet(a, c), tmeet(b, d))
        for a in VALUES for b in VALUES for c in VALUES for d in VALUES
    )
    results["interlace kmeet in tle"] = all(
        (not (tle(a, b) and tle(c, d))) or tle(kmeet(a, c), kmeet(b, d))
        for a in VALUES for b in VALUES for c in VALUES for d in VALUES
    )
    results["neg reverses tle"] = all(
        tle(a, b) == tle(neg(b), neg(a)) for a in VALUES for b in VALUES
    )
    results["neg preserves kle"] = all(
        kle(a, b) == kle(neg(a), neg(b)) for a in VALUES for b in VALUES
    )
    results["De Morgan"] = all(
        neg(tmeet(a, b)) == tjoin(neg(a), neg(b)) for a in VALUES for b in VALUES
    )
    results["conf reverses kle"] = all(
        kle(a, b) == kle(conf(b), conf(a)) for a in VALUES for b in VALUES
    )
    return results


# ---------------------------------------------------------------------------
# 4. The consequence relation over formulas
# ---------------------------------------------------------------------------
# A formula is a nested tuple:
#   ('atom', name) | ('neg', f) | ('and', f, g) | ('or', f, g)
Formula = Tuple  # type: ignore


def atom(name: str) -> Formula:
    return ("atom", name)


def Neg(f: Formula) -> Formula:
    return ("neg", f)


def And(f: Formula, g: Formula) -> Formula:
    return ("and", f, g)


def Or(f: Formula, g: Formula) -> Formula:
    return ("or", f, g)


def evaluate(f: Formula, v: Dict[str, FV]) -> FV:
    tag = f[0]
    if tag == "atom":
        return v[f[1]]
    if tag == "neg":
        return neg(evaluate(f[1], v))
    if tag == "and":
        return tmeet(evaluate(f[1], v), evaluate(f[2], v))
    if tag == "or":
        return tjoin(evaluate(f[1], v), evaluate(f[2], v))
    raise ValueError(f"bad formula {f}")


def atoms_of(f: Formula) -> Set[str]:
    tag = f[0]
    if tag == "atom":
        return {f[1]}
    if tag == "neg":
        return atoms_of(f[1])
    return atoms_of(f[1]) | atoms_of(f[2])


def entails(gamma: List[Formula], phi: Formula) -> bool:
    """Decide Gamma |= phi by enumerating all 4^n valuations."""
    names = sorted(set().union(*(atoms_of(f) for f in gamma + [phi])))
    for assignment in product(VALUES, repeat=len(names)):
        v = dict(zip(names, assignment))
        if all(designated(evaluate(g, v)) for g in gamma):
            if not designated(evaluate(phi, v)):
                return False
    return True


# ---------------------------------------------------------------------------
# 5. Topological semantics over a finite space
# ---------------------------------------------------------------------------
Point = int
Region = FrozenSet[Point]


class FiniteTopology:
    """A finite topological space given by its collection of open sets."""

    def __init__(self, points: Set[Point], opens: Set[Region]) -> None:
        self.points: Region = frozenset(points)
        self.opens: Set[Region] = set(opens)

    def closure(self, a: Region) -> Region:
        """Smallest closed set containing A (intersection of closed supersets)."""
        closed = [self.points - o for o in self.opens]
        supers = [c for c in closed if a <= c]
        result = self.points
        for c in supers:
            result = result & c
        return result

    def pneg(self, a: Region) -> Region:
        """Paraconsistent negation: closure of the complement."""
        return self.closure(self.points - a)

    def is_closed(self, a: Region) -> bool:
        return (self.points - a) in self.opens

    def is_open(self, a: Region) -> bool:
        return a in self.opens

    def glut(self, a: Region) -> Region:
        """Coexistence points A cap neg A (= frontier when A is closed)."""
        return a & self.pneg(a)


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("DREAM LOGIC  --  numerical demonstrations")
    print("=" * 68)

    print("\n[1] Operation tables")
    print("     tmeet(both, neither) =", tmeet("both", "neither"), " (= ff)")
    print("     tjoin(both, neither) =", tjoin("both", "neither"), " (= tt)")
    print("     kmeet(tt, ff)        =", kmeet("tt", "ff"), " (= neither, consensus)")
    print("     kjoin(tt, ff)        =", kjoin("tt", "ff"), " (= both, gullibility)")

    print("\n[2] Algebraic laws (all should be True)")
    for name, ok in verify_bilattice_laws().items():
        print(f"     {name:28s}: {ok}")

    print("\n[3] Paraconsistency at the value level")
    a = "both"
    print(f"     a = both:  a AND neg a = {tmeet(a, neg(a))}  (designated: "
          f"{designated(tmeet(a, neg(a)))})")
    print(f"     yet  (a AND neg a) <=_t ff ?  {tle(tmeet(a, neg(a)), 'ff')}"
          f"   -- contradiction does NOT reach an arbitrary conclusion")
    print(f"     excluded middle on gap: neither OR neg neither = "
          f"{tjoin('neither', neg('neither'))}  (designated: "
          f"{designated(tjoin('neither', neg('neither')))})")

    print("\n[4] Consequence relation")
    p, q = atom("p"), atom("q")
    print("     {p} |= p                       :", entails([p], p), "(reflexivity)")
    print("     {p} |= p OR q                  :", entails([p], Or(p, q)),
          "(or-introduction)")
    print("     {p, q} |= p AND q              :", entails([p, q], And(p, q)),
          "(and-introduction)")
    print("     {p, neg p} |= q  (EXPLOSION)   :", entails([p, Neg(p)], q),
          "(FALSE = paraconsistent!)")
    print("     |= p OR neg p    (LEM)         :", entails([], Or(p, Neg(p))),
          "(FALSE = paracomplete)")
    print("     |= neg(p AND neg p)  (LNC)     :", entails([], Neg(And(p, Neg(p)))),
          "(FALSE = tolerates gluts)")
    print("     neg(p AND q) |= neg p OR neg q :",
          entails([Neg(And(p, q))], Or(Neg(p), Neg(q))), "(De Morgan)")

    print("\n[5] Topology: gluts are boundary points")
    # Sierpinski-like space on {0,1,2}: opens generated so that {0,1} is closed
    # but not open -> it should harbour a glut on its boundary.
    pts = {0, 1, 2}
    # Opens: empty, whole, {2}, {1,2}, {0,2}? build a genuine topology:
    opens = {
        frozenset(),
        frozenset({2}),
        frozenset({1, 2}),
        frozenset({0, 1, 2}),
    }
    topo = FiniteTopology(pts, opens)
    A = frozenset({0, 1})
    print(f"     space points = {sorted(pts)},  A = {sorted(A)}")
    print(f"     A closed? {topo.is_closed(A)}   A open? {topo.is_open(A)}")
    print(f"     neg A = closure(complement) = {sorted(topo.pneg(A))}")
    print(f"     A cap neg A (glut / frontier) = {sorted(topo.glut(A))}")
    print("     -> nonempty glut  <=>  A is closed but not open  (Thm 5.6)")

    print("\n[6] Non-monotonicity: union of closed singletons need not be closed")
    print("     Model the reals near 0 with points x_n = 1/n -> 0.")
    print("     Each {x_n} is closed (an established fact).")
    print("     The union {1, 1/2, 1/3, ...} omits its limit 0, so it is NOT")
    print("     closed: gathering settled facts can yield an unsettled totality,")
    print("     i.e. a conclusion is withdrawn as premises grow (Thm 5.8).")

    print("\nDone.")


if __name__ == "__main__":
    main()
