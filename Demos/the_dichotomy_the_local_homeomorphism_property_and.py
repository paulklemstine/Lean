"""
Sheet numbers and relative trivialisations: numerical demonstrations.
=====================================================================

This self-contained script illustrates, on concrete computable examples, the
results of the accompanying paper:

  * the SHEET NUMBER  sh_f(x) = #f^{-1}(x)  of a map f : E -> X;
  * its LOCAL CONSTANCY and CONSTANCY on connected pieces of the locus where
    f is a covering map;
  * the two-sided SEMICONTINUITY package (the count can neither jump up nor
    drop down on the covering locus), and the failure of one side across a
    critical value;
  * the DICHOTOMY: over a connected covering locus either every fibre is
    empty or every fibre is nonempty;
  * SHEET SYSTEMS: explicit families of disjoint open sheets, each mapped
    homeomorphically onto a common base V by f, exhausting f^{-1}(V);
  * the RESTRICTION theorem: a sheet system over V restricts along any open
    W to a sheet system over W n V, WITH THE SAME INDEX SET;
  * the RELATIVE TRIVIALISATION theorem: given an open region U on which f
    is a covering map and a point x in U, one can produce a sheet system over
    an open V with x in V, V contained in U, indexed by the fibre over x.

The running model is the piecewise-affine (tropical / polyhedral) one: maps
R -> R that are affine with nonzero slope on each of finitely many pieces.
For such maps every object above is exactly computable in rational arithmetic.
A second model, the n-fold covering of the circle by itself, illustrates the
compact case.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Dict, List, Optional, Sequence, Tuple

Num = Fraction

NEG_INF = None  # sentinel for -infinity
POS_INF = None  # sentinel for +infinity


# ---------------------------------------------------------------------------
# Open intervals of the real line (endpoints may be infinite)
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Interval:
    """The open interval (lo, hi); `None` denotes an infinite endpoint."""

    lo: Optional[Num]
    hi: Optional[Num]

    def contains(self, t: Num) -> bool:
        if self.lo is not None and t <= self.lo:
            return False
        if self.hi is not None and t >= self.hi:
            return False
        return True

    def is_empty(self) -> bool:
        return self.lo is not None and self.hi is not None and self.lo >= self.hi

    def intersect(self, other: "Interval") -> "Interval":
        lo = _max_opt(self.lo, other.lo)
        hi = _min_opt(self.hi, other.hi)
        return Interval(lo, hi)

    def sample(self, k: int = 5) -> List[Num]:
        """A handful of interior points, for numerical sanity checks."""
        lo, hi = self.lo, self.hi
        if self.is_empty():
            return []
        if lo is None and hi is None:
            return [Fraction(j) for j in range(-k, k + 1)]
        if lo is None:
            return [hi - Fraction(j + 1) for j in range(k)]
        if hi is None:
            return [lo + Fraction(j + 1) for j in range(k)]
        return [lo + (hi - lo) * Fraction(j + 1, k + 1) for j in range(k)]

    def __str__(self) -> str:
        lo = "-oo" if self.lo is None else str(self.lo)
        hi = "+oo" if self.hi is None else str(self.hi)
        return f"({lo}, {hi})"


def _max_opt(a: Optional[Num], b: Optional[Num]) -> Optional[Num]:
    if a is None:
        return b
    if b is None:
        return a
    return max(a, b)


def _min_opt(a: Optional[Num], b: Optional[Num]) -> Optional[Num]:
    if a is None:
        return b
    if b is None:
        return a
    return min(a, b)


# ---------------------------------------------------------------------------
# Piecewise-affine maps of the line
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class AffinePiece:
    """The affine map t |-> slope * t + intercept, on the open domain `dom`."""

    dom: Interval
    slope: Num
    intercept: Num

    def value(self, t: Num) -> Num:
        return self.slope * t + self.intercept

    def image(self) -> Interval:
        """Image of the open domain: an open interval (slope is nonzero)."""
        assert self.slope != 0
        ends = [
            None if self.dom.lo is None else self.value(self.dom.lo),
            None if self.dom.hi is None else self.value(self.dom.hi),
        ]
        if self.slope > 0:
            return Interval(ends[0], ends[1])
        return Interval(ends[1], ends[0])

    def solve(self, y: Num) -> Optional[Num]:
        """The unique t with value(t) = y, if it lies in the open domain."""
        t = (y - self.intercept) / self.slope
        return t if self.dom.contains(t) else None


class PLMap:
    """A continuous piecewise-affine map R -> R with nonvanishing slopes.

    Constructed from breakpoints b_1 < ... < b_m, the slopes s_0, ..., s_m of
    the m+1 open pieces, and the value f(b_1).  With m = 0 the map is affine.
    """

    def __init__(self, breakpoints: Sequence[Num], slopes: Sequence[Num],
                 value_at_first: Num) -> None:
        bs = [Fraction(b) for b in breakpoints]
        ss = [Fraction(s) for s in slopes]
        if len(ss) != len(bs) + 1:
            raise ValueError("need exactly one more slope than breakpoints")
        if any(s == 0 for s in ss):
            raise ValueError("slopes must be nonzero for a local homeomorphism")
        if any(bs[i] >= bs[i + 1] for i in range(len(bs) - 1)):
            raise ValueError("breakpoints must be strictly increasing")
        self.breakpoints: List[Num] = bs
        self.slopes: List[Num] = ss
        # Values at the breakpoints, propagated by continuity.
        vals: List[Num] = []
        if bs:
            vals.append(Fraction(value_at_first))
            for i in range(1, len(bs)):
                vals.append(vals[-1] + ss[i] * (bs[i] - bs[i - 1]))
        self.values: List[Num] = vals
        # The affine pieces.
        pieces: List[AffinePiece] = []
        for k, s in enumerate(ss):
            lo = bs[k - 1] if k >= 1 else None
            hi = bs[k] if k < len(bs) else None
            if bs:
                anchor_t = lo if lo is not None else hi
                anchor_v = vals[k - 1] if k >= 1 else vals[0]
                intercept = anchor_v - s * anchor_t  # type: ignore[operator]
            else:
                intercept = Fraction(value_at_first)
            pieces.append(AffinePiece(Interval(lo, hi), s, intercept))
        self.pieces: List[AffinePiece] = pieces

    # -- evaluation ---------------------------------------------------------

    def __call__(self, t: Num) -> Num:
        t = Fraction(t)
        for i, b in enumerate(self.breakpoints):
            if t == b:
                return self.values[i]
        for p in self.pieces:
            if p.dom.contains(t):
                return p.value(t)
        raise RuntimeError("unreachable: pieces cover the line")

    # -- fibres -------------------------------------------------------------

    def fiber(self, y: Num) -> List[Num]:
        """All solutions of f(t) = y, sorted.  Exact rational arithmetic."""
        y = Fraction(y)
        out: List[Num] = []
        for p in self.pieces:
            t = p.solve(y)
            if t is not None:
                out.append(t)
        for i, b in enumerate(self.breakpoints):
            if self.values[i] == y:
                out.append(b)
        return sorted(set(out))

    def sheet_number(self, y: Num) -> int:
        """sh_f(y) = #f^{-1}(y)."""
        return len(self.fiber(y))

    def critical_values(self) -> List[Num]:
        """Images of the breakpoints: the only places where sh_f can change."""
        return sorted(set(self.values))

    def covering_components(self) -> List[Interval]:
        """Connected components of the complement of the critical values.

        On each of these open intervals f is a covering map, so by the paper's
        constancy theorem the sheet number is constant there.
        """
        cvs = self.critical_values()
        if not cvs:
            return [Interval(None, None)]
        comps = [Interval(None, cvs[0])]
        for a, b in zip(cvs, cvs[1:]):
            comps.append(Interval(a, b))
        comps.append(Interval(cvs[-1], None))
        return comps


# ---------------------------------------------------------------------------
# Sheet systems
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Sheet:
    """One sheet: an open source interval, plus the affine chart on it.

    The chart is the restriction of f; its inverse (the *section*) is
    y |-> (y - intercept) / slope.
    """

    label: int
    source: Interval
    slope: Num
    intercept: Num

    def chart(self, t: Num) -> Num:
        return self.slope * t + self.intercept

    def section(self, y: Num) -> Num:
        return (y - self.intercept) / self.slope


@dataclass(frozen=True)
class SheetSystem:
    """A sheet system for `f` over the open interval `base`.

    Axioms, in the notation of the paper:
      (S1) every chart has target exactly `base`;
      (S2) every chart is a restriction of f;
      (S3) the sources are pairwise disjoint;
      (S4) the sources exhaust f^{-1}(base).
    """

    base: Interval
    sheets: Tuple[Sheet, ...]

    @property
    def index_set(self) -> Tuple[int, ...]:
        return tuple(s.label for s in self.sheets)

    def cardinality(self) -> int:
        return len(self.sheets)


def extract_sheet_system(f: PLMap, base: Interval) -> SheetSystem:
    """Build the sheet system of a piecewise-affine map over an open interval.

    Precondition: `base` contains no critical value of f.  The sheets are the
    nonempty sets  P_k n f^{-1}(base),  one for each affine piece P_k.
    Complexity: O(#pieces).
    """
    sheets: List[Sheet] = []
    for k, p in enumerate(f.pieces):
        img = p.image()
        window = img.intersect(base)
        if window.is_empty():
            continue
        # Pull the window back through the affine chart.
        ends = [
            None if window.lo is None else (window.lo - p.intercept) / p.slope,
            None if window.hi is None else (window.hi - p.intercept) / p.slope,
        ]
        src = (Interval(ends[0], ends[1]) if p.slope > 0
               else Interval(ends[1], ends[0]))
        src = src.intersect(p.dom)
        if src.is_empty():
            continue
        sheets.append(Sheet(len(sheets), src, p.slope, p.intercept))
    return SheetSystem(base, tuple(sheets))


def restrict_sheet_system(S: SheetSystem, W: Interval) -> SheetSystem:
    """RESTRICTION THEOREM in code.

    Cut every sheet down by f^{-1}(W) and every target down by W.  The new
    base is W n V, and — the key point — the INDEX SET IS UNCHANGED, except
    that sheets whose trimmed source is empty simply have empty source.
    Complexity: O(#sheets); no chart is recomputed.
    """
    new_base = W.intersect(S.base)
    new_sheets: List[Sheet] = []
    for sh in S.sheets:
        ends = [
            None if new_base.lo is None else sh.section(new_base.lo),
            None if new_base.hi is None else sh.section(new_base.hi),
        ]
        src = (Interval(ends[0], ends[1]) if sh.slope > 0
               else Interval(ends[1], ends[0]))
        new_sheets.append(
            Sheet(sh.label, src.intersect(sh.source), sh.slope, sh.intercept)
        )
    return SheetSystem(new_base, tuple(new_sheets))


def verify_sheet_system(f: PLMap, S: SheetSystem, samples: int = 7
                        ) -> Dict[str, bool]:
    """Check axioms (S1)-(S4) on a sample of points; returns a report."""
    report: Dict[str, bool] = {}

    # (S1) every chart maps its source ONTO the base, bijectively.
    onto = True
    for sh in S.sheets:
        if sh.source.is_empty():
            continue
        for y in S.base.sample(samples):
            t = sh.section(y)
            if not sh.source.contains(t) or sh.chart(t) != y:
                onto = False
    report["(S1) charts have target exactly the base"] = onto

    # (S2) every chart agrees with f on its source.
    agrees = True
    for sh in S.sheets:
        for t in sh.source.sample(samples):
            if sh.chart(t) != f(t):
                agrees = False
    report["(S2) charts are restrictions of f"] = agrees

    # (S3) sources are pairwise disjoint.
    disjoint = True
    for i, a in enumerate(S.sheets):
        for b in S.sheets[i + 1:]:
            if not a.source.intersect(b.source).is_empty():
                disjoint = False
    report["(S3) sheets are pairwise disjoint"] = disjoint

    # (S4) sources exhaust f^{-1}(base): every preimage of a sampled base
    #      point lies in exactly one sheet.
    exhaust = True
    for y in S.base.sample(samples):
        pre = f.fiber(y)
        hits = [sum(1 for sh in S.sheets if sh.source.contains(t)) for t in pre]
        if any(h != 1 for h in hits) or len(pre) != S.cardinality():
            exhaust = False
    report["(S4) sheets exhaust the preimage of the base"] = exhaust

    return report


def relative_trivialisation(f: PLMap, U: Interval, x: Num
                            ) -> Tuple[Interval, SheetSystem]:
    """RELATIVE TRIVIALISATION in code.

    Given an open region U on which f is a covering map (i.e. U avoids the
    critical values) and a point x of U, produce an open V with x in V,
    V contained in U, together with a sheet system over V whose sheets
    correspond one-to-one with the points of the fibre over x.

    The construction is exactly the proof: extract a sheet system over the
    critical-value-free component containing x, then RESTRICT it to U.
    """
    x = Fraction(x)
    assert U.contains(x), "x must lie in U"
    comp = next(c for c in f.covering_components() if c.contains(x))
    S0 = extract_sheet_system(f, comp)
    S = restrict_sheet_system(S0, U)
    return S.base, S


# ---------------------------------------------------------------------------
# A compact example: the n-fold covering of the circle by itself
# ---------------------------------------------------------------------------


def circle_fiber(n: int, y: Fraction) -> List[Fraction]:
    """Preimages under the n-fold cover  t |-> n t (mod 1)  of R/Z."""
    y = Fraction(y) % 1
    return sorted((y + k) / n % 1 for k in range(n))


def circle_sheet_sources(n: int, arc_lo: Fraction, arc_hi: Fraction
                         ) -> List[Tuple[Fraction, Fraction]]:
    """The n disjoint sheets of the n-fold cover over the arc (arc_lo, arc_hi).

    Requires the arc to be proper, i.e. arc_hi - arc_lo < 1.
    """
    assert 0 <= arc_lo < arc_hi <= 1 and arc_hi - arc_lo < 1
    return [((arc_lo + k) / n, (arc_hi + k) / n) for k in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_sheet_number_is_locally_constant() -> None:
    banner("1.  The sheet number of a piecewise-affine map, region by region")

    # A 'tent-plus-ramp': slopes  1, -1, 2  with breakpoints at 0 and 1,
    # value 0 at the first breakpoint.  So f(0) = 0, f(1) = -1.
    f = PLMap(breakpoints=[0, 1], slopes=[1, -1, 2], value_at_first=0)
    print("breakpoints :", f.breakpoints)
    print("values there:", f.values)
    print("critical values (the only places sh_f can change):",
          f.critical_values())

    for comp in f.covering_components():
        pts = comp.sample(6)
        counts = {f.sheet_number(y) for y in pts}
        print(f"  region {str(comp):>16}   sheet numbers on samples: {counts}"
              f"   -> constant: {len(counts) == 1}")

    print("\nAt the critical values themselves the count genuinely differs:")
    for c in f.critical_values():
        print(f"  sh_f({c}) = {f.sheet_number(c)}   fibre = {f.fiber(c)}")


def demo_semicontinuity() -> None:
    banner("2.  Semicontinuity: both sides hold on the covering locus,\n"
           "    and the two-sided estimate fails at a critical value")

    f = PLMap(breakpoints=[0, 1], slopes=[1, -1, 2], value_at_first=0)

    def two_sided_ok(y0: Fraction, eps: Fraction) -> Tuple[bool, bool]:
        base = f.sheet_number(y0)
        nearby = [f.sheet_number(y0 - eps), f.sheet_number(y0 + eps)]
        lower = all(m >= base for m in nearby)   # count cannot drop
        upper = all(m <= base for m in nearby)   # count cannot jump
        return lower, upper

    eps = Fraction(1, 100)
    print("point y        lower s.c.   upper s.c.   sh_f(y)")
    for y in [Fraction(-3), Fraction(-1, 2), Fraction(1, 2), Fraction(3)]:
        lo, up = two_sided_ok(y, eps)
        print(f"  {str(y):<12} {str(lo):<12} {str(up):<12} {f.sheet_number(y)}"
              "     (covering locus: both hold)")
    for c in f.critical_values():
        lo, up = two_sided_ok(Fraction(c), eps)
        print(f"  {str(c):<12} {str(lo):<12} {str(up):<12} {f.sheet_number(c)}"
              "     (critical value: the estimate fails)")


def demo_dichotomy() -> None:
    banner("3.  The dichotomy: over a connected covering region, either every\n"
           "    fibre is empty or every fibre is nonempty")

    # A map whose image misses an entire region: slopes 1, -1 with a single
    # breakpoint at 0 and f(0) = 0, so f(t) = -|t| <= 0 and every y > 0 is
    # missed.
    g = PLMap(breakpoints=[0], slopes=[1, -1], value_at_first=0)
    print("g(t) = -|t| :   critical values", g.critical_values())
    for comp in g.covering_components():
        pts = comp.sample(6)
        nonempty = {bool(g.fiber(y)) for y in pts}
        verdict = ("ALL fibres nonempty" if nonempty == {True}
                   else "ALL fibres empty" if nonempty == {False}
                   else "MIXED (would contradict the dichotomy!)")
        print(f"  region {str(comp):>14}: {verdict}")

    f = PLMap(breakpoints=[0, 1], slopes=[1, -1, 2], value_at_first=0)
    print("\nthe tent-plus-ramp:")
    for comp in f.covering_components():
        nonempty = {bool(f.fiber(y)) for y in comp.sample(6)}
        print(f"  region {str(comp):>16}: "
              f"{'ALL nonempty' if nonempty == {True} else 'ALL empty'}")


def demo_sheet_system() -> None:
    banner("4.  Explicit sheet systems, and verification of axioms (S1)-(S4)")

    f = PLMap(breakpoints=[0, 1], slopes=[1, -1, 2], value_at_first=0)
    V = Interval(Fraction(-1, 2), Fraction(0))   # a critical-value-free window
    S = extract_sheet_system(f, V)
    print(f"base V = {V},  number of sheets = {S.cardinality()}")
    for sh in S.sheets:
        print(f"  sheet {sh.label}: source {str(sh.source):>22}"
              f"   chart t |-> {sh.slope}*t + {sh.intercept}")
    for k, v in verify_sheet_system(f, S).items():
        print(f"   {k}: {v}")
    y = Fraction(-1, 4)
    print(f"\n  sh_f({y}) = {f.sheet_number(y)} = number of sheets"
          f" = {S.cardinality()}  (the paper's corollary)")
    print("  sections evaluated at y :",
          [str(sh.section(y)) for sh in S.sheets])
    print("  fibre computed directly  :", [str(t) for t in f.fiber(y)])


def demo_restriction_and_relative_trivialisation() -> None:
    banner("5.  Restriction, and the relative trivialisation theorem")

    f = PLMap(breakpoints=[0, 1], slopes=[1, -1, 2], value_at_first=0)
    V = Interval(Fraction(-1, 2), Fraction(0))
    S = extract_sheet_system(f, V)
    W = Interval(Fraction(-3, 10), Fraction(1))     # an open region to cut by
    SR = restrict_sheet_system(S, W)

    print(f"original base {V} with index set {S.index_set}")
    print(f"restricted to W = {W}")
    print(f"new base      {SR.base} with index set {SR.index_set}")
    print(f"  index set unchanged: {S.index_set == SR.index_set}")
    for k, v in verify_sheet_system(f, SR).items():
        print(f"   {k}: {v}")

    print("\nRelative trivialisation: prescribe the region U in advance.")
    U = Interval(Fraction(-2, 5), Fraction(-1, 10))
    x = Fraction(-1, 4)
    base, S2 = relative_trivialisation(f, U, x)
    inside = ((U.lo is None or (base.lo is not None and base.lo >= U.lo)) and
              (U.hi is None or (base.hi is not None and base.hi <= U.hi)))
    print(f"  U = {U},  x = {x}")
    print(f"  produced V = {base};   x in V: {base.contains(x)};"
          f"   V inside U: {inside}")
    print(f"  sheets indexed by the fibre over x = {[str(t) for t in f.fiber(x)]}")
    print(f"  number of sheets = {S2.cardinality()} = #fibre over x"
          f" = {f.sheet_number(x)}")
    for k, v in verify_sheet_system(f, S2).items():
        print(f"   {k}: {v}")


def demo_circle_cover() -> None:
    banner("6.  A compact example: the n-fold covering of the circle")

    for n in (1, 2, 3, 5):
        y = Fraction(1, 7)
        fib = circle_fiber(n, y)
        sheets = circle_sheet_sources(n, Fraction(1, 10), Fraction(4, 10))
        widths = {b - a for a, b in sheets}
        print(f"  n = {n}:  fibre over {y} has {len(fib)} points"
              f"  -> sheet number {len(fib)}")
        print(f"          {n} disjoint sheets over the arc (1/10, 4/10),"
              f" each of length {widths.pop()} = (arc length)/n")
    print("\n  The sheet number is the constant n on the whole (connected)")
    print("  circle, and every fibre is nonempty — the dichotomy's second")
    print("  alternative, whence surjectivity.")


def demo_disconnected_counterexample() -> None:
    banner("7.  Why connectedness is needed: a two-point base")

    # X = {0, 1} discrete, E = {*}, f(*) = 0.  Modelled combinatorially.
    base_points = [0, 1]
    fibres: Dict[int, List[str]] = {0: ["*"], 1: []}
    print("  base {0, 1} (discrete), single point upstairs mapping to 0")
    for p in base_points:
        print(f"    sh_f({p}) = {len(fibres[p])}")
    print("  Both points are evenly covered (fibres of size 1 and 0), yet the")
    print("  sheet number is not constant and the dichotomy fails on the whole")
    print("  base.  Each connected component satisfies both statements — the")
    print("  hypothesis of (pre)connectedness is exactly what is needed.")


def main() -> None:
    demo_sheet_number_is_locally_constant()
    demo_semicontinuity()
    demo_dichotomy()
    demo_sheet_system()
    demo_restriction_and_relative_trivialisation()
    demo_circle_cover()
    demo_disconnected_counterexample()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
