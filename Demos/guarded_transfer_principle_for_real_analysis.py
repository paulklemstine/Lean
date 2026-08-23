"""
Guarded Transfer Principle for Real Analysis over a Total Four-Constructor Arithmetic
=====================================================================================

A self-contained numerical demonstration of the results of the accompanying paper.

We implement the four-constructor carrier

    T  ::=  fin(x : float)  |  +inf  |  -inf  |  null

with *total* arithmetic (every pair of elements has a sum, product and quotient),
and then exhibit, numerically:

  1. Exact conservativity of guarded arithmetic:
         fin x + fin y = fin(x+y),  fin x * fin y = fin(xy),
         fin x / fin y = fin(x/y)   provided y != 0.

  2. The division boundary (sign trichotomy):
         fin x / fin 0 = +inf (x>0), -inf (x<0), null (x=0).

  3. The guard is invertibility: the multiplicative units of T are exactly the
     nonzero finite elements; the additively invertible elements are exactly the
     finite ones.

  4. The guarded transfer principle for an expression syntax with two semantics
     (real and transreal): on guarded expressions the two agree via `fin`, the
     transreal value never leaves the finite fragment, and equality of guarded
     expressions is the same question upstairs and downstairs (faithfulness).

  5. Sharpness: x |-> x/x is discontinuous (value 1 off the origin, null at it),
     and the unique value that WOULD repair it is 1 -- which the arithmetic
     refuses.

  6. Non-repairability of the reciprocal: near 0 the reciprocal takes arbitrarily
     large positive AND arbitrarily large negative values, so no element of T can
     be plugged in at the origin.

  7. The pole trichotomy at an isolated denominator zero:
         regime 1  (0/0)                -> null, discontinuous;
         regime 2  (positive one-signed pole) -> +-inf, CONTINUOUS  (e.g. 1/x^2);
         regime 2' (negative one-signed pole) -> +-inf with the WRONG sign,
                                                 discontinuous (e.g. 1/(-x^2));
         regime 3  (sign change)        -> +-inf, discontinuous (e.g. 1/x).

  8. The price of totality: addition is not jointly continuous at (+inf,-inf),
     multiplication is not jointly continuous at (0,+inf), and distributivity
     fails on the exceptional constructors.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, List, Optional, Sequence, Tuple, Union

# ---------------------------------------------------------------------------
# 1. The four-constructor carrier
# ---------------------------------------------------------------------------

FIN, PINF, NINF, NULL = "fin", "pinf", "ninf", "null"


@dataclass(frozen=True)
class Tr:
    """A transreal: tag in {fin, pinf, ninf, null}; `val` used only when fin."""

    tag: str
    val: float = 0.0

    # -- constructors -------------------------------------------------------
    @staticmethod
    def fin(x: float) -> "Tr":
        return Tr(FIN, float(x))

    # -- predicates ---------------------------------------------------------
    @property
    def is_finite(self) -> bool:
        return self.tag == FIN

    @property
    def is_null(self) -> bool:
        return self.tag == NULL

    def __str__(self) -> str:
        if self.tag == FIN:
            return f"fin {self.val:.6g}"
        return {PINF: "+inf", NINF: "-inf", NULL: "null"}[self.tag]

    __repr__ = __str__


PINF_T = Tr(PINF)
NINF_T = Tr(NINF)
NULL_T = Tr(NULL)
ZERO_T = Tr.fin(0.0)
ONE_T = Tr.fin(1.0)


def tr_neg(a: Tr) -> Tr:
    """Total negation: swaps the infinities, fixes nullity."""
    if a.tag == FIN:
        return Tr.fin(-a.val)
    if a.tag == PINF:
        return NINF_T
    if a.tag == NINF:
        return PINF_T
    return NULL_T


def tr_add(a: Tr, b: Tr) -> Tr:
    """Total addition.  Nullity absorbs; (+inf) + (-inf) = null."""
    if a.is_null or b.is_null:
        return NULL_T
    if a.tag == FIN and b.tag == FIN:
        return Tr.fin(a.val + b.val)
    if a.tag == FIN:
        return b
    if b.tag == FIN:
        return a
    if a.tag == b.tag:
        return a
    return NULL_T  # (+inf) + (-inf)


def _sign(x: float) -> int:
    return (x > 0) - (x < 0)


def tr_mul(a: Tr, b: Tr) -> Tr:
    """Total multiplication.  Nullity absorbs; 0 * inf = null."""
    if a.is_null or b.is_null:
        return NULL_T
    if a.tag == FIN and b.tag == FIN:
        return Tr.fin(a.val * b.val)
    if a.tag == FIN or b.tag == FIN:
        fin_part, inf_part = (a, b) if a.tag == FIN else (b, a)
        s = _sign(fin_part.val)
        if s == 0:
            return NULL_T  # 0 * inf
        pos = (s > 0) == (inf_part.tag == PINF)
        return PINF_T if pos else NINF_T
    return PINF_T if a.tag == b.tag else NINF_T


def tr_recip(a: Tr) -> Tr:
    """Total reciprocal: 1/0 = +inf, 1/(+-inf) = 0, 1/null = null."""
    if a.tag == FIN:
        return PINF_T if a.val == 0.0 else Tr.fin(1.0 / a.val)
    if a.tag in (PINF, NINF):
        return ZERO_T
    return NULL_T


def tr_div(a: Tr, b: Tr) -> Tr:
    """Total division: a / b := a * recip(b)."""
    return tr_mul(a, tr_recip(b))


# ---------------------------------------------------------------------------
# 2. Exact conservativity and the division boundary
# ---------------------------------------------------------------------------

def _close(a: Tr, b: Tr, tol: float = 1e-12) -> bool:
    """Equality of transreals, up to floating-point rounding on the finite part.

    Exact equality holds in the mathematics; in binary floating point the identity
    a / b = a * (1/b) can differ in the last bit, which is a property of the machine
    and not of the arithmetic being modelled.
    """
    if a.tag != b.tag:
        return False
    if a.tag != FIN:
        return True
    return abs(a.val - b.val) <= tol * max(1.0, abs(a.val), abs(b.val))


def check_conservativity(samples: Sequence[float]) -> bool:
    """fin transports +, *, - verbatim and / verbatim when the divisor is nonzero."""
    ok = True
    for x in samples:
        ok &= _close(tr_neg(Tr.fin(x)), Tr.fin(-x))
        for y in samples:
            ok &= _close(tr_add(Tr.fin(x), Tr.fin(y)), Tr.fin(x + y))
            ok &= _close(tr_mul(Tr.fin(x), Tr.fin(y)), Tr.fin(x * y))
            if y != 0.0:
                ok &= _close(tr_div(Tr.fin(x), Tr.fin(y)), Tr.fin(x / y))
    return bool(ok)


def division_boundary(x: float) -> Tr:
    """fin x / fin 0, exhibiting the sign trichotomy."""
    return tr_div(Tr.fin(x), ZERO_T)


# ---------------------------------------------------------------------------
# 3. The guard is invertibility
# ---------------------------------------------------------------------------

def multiplicative_units(candidates: Sequence[Tr], probes: Sequence[Tr]) -> List[Tr]:
    """Elements a with a*b = 1 for some probe b.  Should be exactly nonzero finites."""
    units: List[Tr] = []
    for a in candidates:
        if any(tr_mul(a, b) == ONE_T for b in probes):
            units.append(a)
    return units


def additive_units(candidates: Sequence[Tr], probes: Sequence[Tr]) -> List[Tr]:
    """Elements a with a+b = 0 for some probe b.  Should be exactly the finites."""
    return [a for a in candidates if any(tr_add(a, b) == ZERO_T for b in probes)]


# ---------------------------------------------------------------------------
# 4. Expression syntax with two semantics, and the guarded transfer principle
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Expr:
    """
    Arithmetic expression tree.

    kind in {"atom","const","comp","add","mul","div"}.
      atom  : fn is f : float -> float applied to the parameter
      const : c is a real constant
      comp  : fn composed with the single child
      add / mul / div : two children
    """

    kind: str
    fn: Optional[Callable[[float], float]] = None
    c: float = 0.0
    kids: Tuple["Expr", ...] = ()
    label: str = ""

    def __str__(self) -> str:
        return self.label or self.kind


def atom(fn: Callable[[float], float], label: str = "x") -> Expr:
    return Expr("atom", fn=fn, label=label)


def const(c: float) -> Expr:
    return Expr("const", c=c, label=f"{c:g}")


def comp(fn: Callable[[float], float], e: Expr, label: str = "f") -> Expr:
    return Expr("comp", fn=fn, kids=(e,), label=f"{label}({e})")


def add(a: Expr, b: Expr) -> Expr:
    return Expr("add", kids=(a, b), label=f"({a} + {b})")


def mul(a: Expr, b: Expr) -> Expr:
    return Expr("mul", kids=(a, b), label=f"({a} * {b})")


def div(a: Expr, b: Expr) -> Expr:
    return Expr("div", kids=(a, b), label=f"({a} / {b})")


def real_eval(e: Expr, x: float) -> float:
    """Real semantics (with the junk convention c/0 = 0, never used under a guard)."""
    if e.kind == "atom":
        assert e.fn is not None
        return e.fn(x)
    if e.kind == "const":
        return e.c
    if e.kind == "comp":
        assert e.fn is not None
        return e.fn(real_eval(e.kids[0], x))
    a = real_eval(e.kids[0], x)
    b = real_eval(e.kids[1], x)
    if e.kind == "add":
        return a + b
    if e.kind == "mul":
        return a * b
    return 0.0 if b == 0.0 else a / b


def trans_eval(e: Expr, x: float) -> Tr:
    """Transreal semantics, using the total four-constructor arithmetic."""
    if e.kind == "atom":
        assert e.fn is not None
        return Tr.fin(e.fn(x))
    if e.kind == "const":
        return Tr.fin(e.c)
    if e.kind == "comp":
        assert e.fn is not None
        inner = trans_eval(e.kids[0], x)
        # strict lift: exceptional arguments go to nullity
        return Tr.fin(e.fn(inner.val)) if inner.is_finite else NULL_T
    a = trans_eval(e.kids[0], x)
    b = trans_eval(e.kids[1], x)
    if e.kind == "add":
        return tr_add(a, b)
    if e.kind == "mul":
        return tr_mul(a, b)
    return tr_div(a, b)


def defined_at(e: Expr, x: float) -> bool:
    """Pointwise guard: no denominator subexpression vanishes at x."""
    if e.kind in ("atom", "const"):
        return True
    if e.kind == "comp":
        return defined_at(e.kids[0], x)
    left = defined_at(e.kids[0], x)
    right = defined_at(e.kids[1], x)
    if e.kind == "div":
        return left and right and real_eval(e.kids[1], x) != 0.0
    return left and right


def guarded_on(e: Expr, grid: Sequence[float]) -> bool:
    """Uniform guard, sampled: every denominator subexpression is nonzero on the grid."""
    return all(defined_at(e, x) for x in grid)


def transfer_holds(e: Expr, grid: Sequence[float], tol: float = 1e-12) -> bool:
    """Check trans_eval(e) = fin(real_eval(e)) pointwise on the guarded grid."""
    for x in grid:
        if not defined_at(e, x):
            return False
        t = trans_eval(e, x)
        if not t.is_finite or abs(t.val - real_eval(e, x)) > tol * max(1.0, abs(t.val)):
            return False
    return True


def faithfulness(e1: Expr, e2: Expr, grid: Sequence[float], tol: float = 1e-12) -> Tuple[bool, bool]:
    """Return (equal upstairs, equal downstairs); for guarded expressions these agree."""
    up = all(
        trans_eval(e1, x).is_finite
        and trans_eval(e2, x).is_finite
        and abs(trans_eval(e1, x).val - trans_eval(e2, x).val) <= tol
        for x in grid
    )
    down = all(abs(real_eval(e1, x) - real_eval(e2, x)) <= tol for x in grid)
    return up, down


# ---------------------------------------------------------------------------
# 5. The pole trichotomy
# ---------------------------------------------------------------------------

def classify_pole(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x0: float,
    radii: Iterable[float] = (1e-2, 1e-4, 1e-6, 1e-8),
) -> str:
    """
    Classify the local regime of x |-> fin(f x) / fin(g x) at a zero x0 of g,
    by sampling the sign of g on both sides.

    Returns one of:
        "guarded"                   -- g(x0) != 0, nothing to classify
        "regime 1: 0/0"             -- discontinuous (value null)
        "regime 2: positive pole"   -- CONTINUOUS (value +-inf, sign of the numerator)
        "regime 2': negative pole"  -- discontinuous: the limits carry the OPPOSITE sign,
                                       because the total reciprocal of zero is +inf by
                                       convention, so the assigned value cannot see from
                                       which side the denominator vanished
        "regime 3: sign change"     -- discontinuous (one-sided limits +inf and -inf)
    """
    if g(x0) != 0.0:
        return "guarded"
    if f(x0) == 0.0:
        return "regime 1: 0/0"
    right = {_sign(g(x0 + r)) for r in radii}
    left = {_sign(g(x0 - r)) for r in radii}
    if 0 in right | left or len(right) > 1 or len(left) > 1:
        return "degenerate (non-isolated zero detected)"
    if right != left:
        return "regime 3: sign change"
    return "regime 2: positive pole" if right == {1} else "regime 2': negative pole"


def quotient_values(
    f: Callable[[float], float],
    g: Callable[[float], float],
    x0: float,
    radii: Sequence[float],
) -> List[Tuple[float, Tr, Tr]]:
    """Sample the transreal quotient at x0 +- r for each r, plus its value at x0."""
    rows: List[Tuple[float, Tr, Tr]] = []
    for r in radii:
        rows.append(
            (
                r,
                tr_div(Tr.fin(f(x0 - r)), Tr.fin(g(x0 - r))),
                tr_div(Tr.fin(f(x0 + r)), Tr.fin(g(x0 + r))),
            )
        )
    return rows


# ---------------------------------------------------------------------------
# 6. Reporting
# ---------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    import math

    rule("1. Exact conservativity of guarded arithmetic")
    samples = [-3.0, -1.5, -1.0, -0.25, 0.0, 0.25, 1.0, 2.0, 7.0]
    print(f"  fin transports +, *, - and guarded / verbatim on {len(samples)}^2 pairs:",
          check_conservativity(samples))
    print(f"    fin 3 + fin 4      = {tr_add(Tr.fin(3), Tr.fin(4))}")
    print(f"    fin 3 * fin 4      = {tr_mul(Tr.fin(3), Tr.fin(4))}")
    print(f"    fin 3 / fin 4      = {tr_div(Tr.fin(3), Tr.fin(4))}   (= fin 0.75)")

    rule("2. The division boundary: a sign trichotomy, not an error")
    for x in (2.0, 1e-9, 0.0, -1e-9, -2.0):
        print(f"    fin {x:>10.3g} / fin 0 = {division_boundary(x)}")
    print("  Note: 1e-9/0 and -1e-9/0 land on DIFFERENT points, arbitrarily close inputs.")
    print("  That is the discontinuity, visible in one line.")

    rule("3. The guard is invertibility: units of the total multiplication")
    candidates = [Tr.fin(0.0), Tr.fin(2.0), Tr.fin(-0.5), PINF_T, NINF_T, NULL_T]
    probes = [Tr.fin(v) for v in (-2.0, -0.5, 0.0, 0.5, 2.0, 1.0, -1.0)] + [PINF_T, NINF_T, NULL_T]
    units = multiplicative_units(candidates, probes)
    adds = additive_units(candidates, probes)
    print(f"    multiplicatively invertible : {units}")
    print(f"    additively invertible       : {adds}")
    print("  => guarded denominators = nonzero finite elements = the units. Exactly.")

    rule("4. The guarded transfer principle")
    grid = [(-3.0 + 6.0 * k / 240.0) for k in range(241)]
    ident = atom(lambda x: x, "x")
    logistic = div(comp(math.exp, ident, "exp"), add(const(1.0), comp(math.exp, ident, "exp")))
    print(f"    expression        : {logistic}")
    print(f"    guarded on grid   : {guarded_on(logistic, grid)}   (1 + e^x >= 1 > 0)")
    print(f"    transfer holds    : {transfer_holds(logistic, grid)}")
    print(f"    value at x = 0.5  : {trans_eval(logistic, 0.5)}  vs real {real_eval(logistic, 0.5):.6f}")
    reflected = div(const(1.0), add(const(1.0), comp(math.exp, ident, "exp")))
    sum_expr = add(logistic, reflected)
    up, down = faithfulness(sum_expr, const(1.0), grid)
    print(f"    identity  sigma(x) + 1/(1+e^x) = 1")
    print(f"      holds transreally : {up}")
    print(f"      holds really      : {down}     (faithfulness: the two agree)")

    rule("5. Sharpness: self-division, and the repair value it refuses")
    self_div = div(ident, ident)
    for x in (1.0, 1e-6, 1e-12, 0.0, -1e-12, -1.0):
        print(f"    x = {x:>10.3g} :  x/x = {trans_eval(self_div, x)}")
    print("  Off the origin the value is constantly fin 1; the punctured line is dense,")
    print("  so the ONLY continuous extension has value fin 1 at the origin --")
    print("  and total arithmetic is forced to return null instead.")
    print(f"    unique continuous repair value : {ONE_T}")
    print(f"    value chosen by the arithmetic : {tr_div(ZERO_T, ZERO_T)}")

    rule("6. Non-repairability of the reciprocal: a two-sided blow-up")
    print("    y            1/y")
    for e in (2, 4, 6, 8):
        y = 10.0 ** (-e)
        print(f"    {y:>10.1e}   {tr_div(ONE_T, Tr.fin(y))}")
        print(f"    {-y:>10.1e}   {tr_div(ONE_T, Tr.fin(-y))}")
    print("  Any neighbourhood of a putative value at 0 would have to contain")
    print("  arbitrarily large POSITIVE and NEGATIVE finite values.  No point of the")
    print("  carrier -- finite, infinite or null -- has such a neighbourhood.")

    rule("7. The pole trichotomy at an isolated denominator zero")
    cases: List[Tuple[str, Callable[[float], float], Callable[[float], float]]] = [
        ("x / x        (0/0)          ", lambda x: x, lambda x: x),
        ("sin x / x    (0/0)          ", math.sin, lambda x: x),
        ("1 / x^2      (one-signed +) ", lambda _x: 1.0, lambda x: x * x),
        ("1 / x^4      (one-signed +) ", lambda _x: 1.0, lambda x: x ** 4),
        ("(2+x) / x^2  (one-signed +) ", lambda x: 2.0 + x, lambda x: x * x),
        ("1 / (-x^2)   (one-signed -) ", lambda _x: 1.0, lambda x: -x * x),
        ("(-1) / x^2   (one-signed +) ", lambda _x: -1.0, lambda x: x * x),
        ("1 / x        (sign change)  ", lambda _x: 1.0, lambda x: x),
        ("1 / x^3      (sign change)  ", lambda _x: 1.0, lambda x: x ** 3),
        ("1 / (1+x^2)  (guarded)      ", lambda _x: 1.0, lambda x: 1.0 + x * x),
    ]
    verdict = {
        "guarded": "continuous (guarded)",
        "regime 1: 0/0": "DISCONTINUOUS",
        "regime 2: positive pole": "continuous",
        "regime 2': negative pole": "DISCONTINUOUS",
        "regime 3: sign change": "DISCONTINUOUS",
    }
    for name, f, g in cases:
        reg = classify_pole(f, g, 0.0)
        val = tr_div(Tr.fin(f(0.0)), Tr.fin(g(0.0)))
        print(f"    {name} value at 0 = {str(val):>8}   {reg:<28} -> {verdict.get(reg, '?')}")

    print("\n  One-sided samples for 1/x^2 (regime 2) -- both sides run to +inf:")
    for r, lo, hi in quotient_values(lambda _x: 1.0, lambda x: x * x, 0.0, (1e-1, 1e-2, 1e-3)):
        print(f"    r = {r:<8.0e} left = {str(lo):>14}   right = {str(hi):>14}")
    print("  One-sided samples for 1/x (regime 3) -- the two sides run to DIFFERENT points:")
    for r, lo, hi in quotient_values(lambda _x: 1.0, lambda x: x, 0.0, (1e-1, 1e-2, 1e-3)):
        print(f"    r = {r:<8.0e} left = {str(lo):>14}   right = {str(hi):>14}")

    rule("8. The price of totality")
    print("  Addition is not jointly continuous at (+inf, -inf):")
    for t in (10.0, 1e3, 1e6):
        print(f"    t = {t:>8.0e} :  fin t + fin(-t) = {tr_add(Tr.fin(t), Tr.fin(-t))}")
    print(f"    limit point      :  (+inf) + (-inf) = {tr_add(PINF_T, NINF_T)}   <- jump")
    print("  Multiplication is not jointly continuous at (0, +inf):")
    for t in (10.0, 1e3, 1e6):
        print(f"    t = {t:>8.0e} :  fin(1/t) * fin t = {tr_mul(Tr.fin(1.0 / t), Tr.fin(t))}")
    print(f"    limit point      :  fin 0 * (+inf)  = {tr_mul(ZERO_T, PINF_T)}   <- jump")
    lhs = tr_mul(PINF_T, tr_add(ONE_T, ZERO_T))
    rhs = tr_add(tr_mul(PINF_T, ONE_T), tr_mul(PINF_T, ZERO_T))
    print("  Distributivity fails on the exceptional constructors:")
    print(f"    (+inf)*(1 + 0)          = {lhs}")
    print(f"    (+inf)*1 + (+inf)*0     = {rhs}")
    print("  All three failures live entirely on the exceptional constructors.")
    print("  On the finite fragment -- where the transfer principle lives -- the")
    print("  ordinary field laws hold verbatim and both operations are continuous.")

    rule("Summary")
    print("  Guarded  (denominators nowhere zero): totalisation is INVISIBLE.")
    print("      same values, same equational theory both ways, continuity preserved.")
    print("  Unguarded: 0/0 and sign-changing poles break continuity irreparably;")
    print("      a positive one-signed pole does NOT break: 1/x^2 is continuous.")
    print("      But 1/(-x^2) DOES break: the arithmetic assigns +inf while the limits")
    print("      are -inf, because the total reciprocal of zero is +inf by convention.")
    print("      Past the guard the answer depends on how the formula is written:")
    print("      1/(-x^2) and (-1)/x^2 agree off the origin but not at it.")


if __name__ == "__main__":
    main()
