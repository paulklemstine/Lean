"""
demo.py — Numerical demonstrations for "The Tight Depth Hierarchy".

This script is fully self-contained (standard library only). It reproduces,
numerically, the core phenomena behind the EML tight depth hierarchy and its
computational-oracle companion toolkit:

  1. The expression language EML, its evaluator, eml-depth and growth rank.
  2. The canonical tower expression emlExprIterExp n has eml-depth exactly n.
  3. growthRank e <= emlDepth e  (the structural majorization bound).
  4. The polynomial-argument tower majorant: an inverse-free expression of
     growth rank k is bounded by iterExp k (C * x^N).
  5. The tight separation: iterExp n eventually dwarfs iterExp k (C * x^N)
     for every k < n, so no depth-(n-1) expression can represent iterExp n.
  6. Companion oracle facts: idempotent one-step convergence, Mobius
     composition, binary entropy, inverse stereographic projection on Sⁿ.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, List, Tuple, Union


def safe_exp(t: float) -> float:
    """exp that returns +inf on overflow instead of raising (towers grow fast)."""
    try:
        return math.exp(t)
    except OverflowError:
        return math.inf


# ----------------------------------------------------------------------------
# 1. The EML expression language
# ----------------------------------------------------------------------------
# We model EMLExpr as a small algebraic data type. Transcendence enters ONLY
# through `eml(a, b) = a * exp(b)`; everything else is field arithmetic.

@dataclass(frozen=True)
class Var:
    pass


@dataclass(frozen=True)
class Const:
    c: float


@dataclass(frozen=True)
class Add:
    a: "EMLExpr"
    b: "EMLExpr"


@dataclass(frozen=True)
class Mul:
    a: "EMLExpr"
    b: "EMLExpr"


@dataclass(frozen=True)
class Neg:
    a: "EMLExpr"


@dataclass(frozen=True)
class Inv:
    a: "EMLExpr"


@dataclass(frozen=True)
class Eml:
    a: "EMLExpr"  # multiplicative coefficient
    b: "EMLExpr"  # exponent


EMLExpr = Union[Var, Const, Add, Mul, Neg, Inv, Eml]


def eval_expr(e: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at the point x (matches `EMLExpr.eval`)."""
    if isinstance(e, Var):
        return x
    if isinstance(e, Const):
        return e.c
    if isinstance(e, Add):
        return eval_expr(e.a, x) + eval_expr(e.b, x)
    if isinstance(e, Mul):
        return eval_expr(e.a, x) * eval_expr(e.b, x)
    if isinstance(e, Neg):
        return -eval_expr(e.a, x)
    if isinstance(e, Inv):
        return 1.0 / eval_expr(e.a, x)
    if isinstance(e, Eml):
        return eval_expr(e.a, x) * safe_exp(eval_expr(e.b, x))
    raise TypeError(f"unknown node {e!r}")


def eml_depth(e: EMLExpr) -> int:
    """Maximum nesting of `eml` operations (matches `EMLExpr.emlDepth`)."""
    if isinstance(e, (Var, Const)):
        return 0
    if isinstance(e, Add):
        return max(eml_depth(e.a), eml_depth(e.b))
    if isinstance(e, Mul):
        return max(eml_depth(e.a), eml_depth(e.b))
    if isinstance(e, Neg):
        return eml_depth(e.a)
    if isinstance(e, Inv):
        return eml_depth(e.a)
    if isinstance(e, Eml):
        return 1 + max(eml_depth(e.a), eml_depth(e.b))
    raise TypeError(f"unknown node {e!r}")


def growth_rank(e: EMLExpr) -> int:
    """Structural growth complexity (matches `EMLExpr.growthRank`)."""
    if isinstance(e, (Var, Const)):
        return 0
    if isinstance(e, Add):
        return max(growth_rank(e.a), growth_rank(e.b))
    if isinstance(e, Mul):
        return max(growth_rank(e.a), growth_rank(e.b))
    if isinstance(e, Neg):
        return growth_rank(e.a)
    if isinstance(e, Inv):
        return growth_rank(e.a)
    if isinstance(e, Eml):
        return 1 + max(growth_rank(e.a), growth_rank(e.b))
    raise TypeError(f"unknown node {e!r}")


def no_inv(e: EMLExpr) -> bool:
    """True iff the expression contains no `inv` node (matches `EMLExpr.noInv`)."""
    if isinstance(e, (Var, Const)):
        return True
    if isinstance(e, Add):
        return no_inv(e.a) and no_inv(e.b)
    if isinstance(e, Mul):
        return no_inv(e.a) and no_inv(e.b)
    if isinstance(e, Neg):
        return no_inv(e.a)
    if isinstance(e, Inv):
        return False
    if isinstance(e, Eml):
        return no_inv(e.a) and no_inv(e.b)
    raise TypeError(f"unknown node {e!r}")


# ----------------------------------------------------------------------------
# 2. The iterated exponential and the canonical tower expression
# ----------------------------------------------------------------------------

def iter_exp(n: int, x: float) -> float:
    """iterExp 0 x = x ; iterExp (n+1) x = exp(iterExp n x)."""
    val = x
    for _ in range(n):
        val = safe_exp(val)
    return val


def eml_expr_iter_exp(n: int) -> EMLExpr:
    """Canonical EML expression representing iterExp n (matches `emlExprIterExp`)."""
    if n == 0:
        return Var()
    return Eml(Const(1.0), eml_expr_iter_exp(n - 1))


# ----------------------------------------------------------------------------
# 3. Demonstrations
# ----------------------------------------------------------------------------

def demo_depth_equals_n() -> None:
    print("== Canonical tower has eml-depth exactly n ==")
    for n in range(0, 7):
        e = eml_expr_iter_exp(n)
        d = eml_depth(e)
        # Check the expression really computes iterExp n at a safe point.
        x = 0.3
        lhs = eval_expr(e, x)
        rhs = iter_exp(n, x)
        ok = (lhs == rhs) or math.isclose(lhs, rhs, rel_tol=1e-9)
        print(f"  n={n}: emlDepth = {d:2d}  | eval==iterExp? {ok}")
    print()


def demo_growth_rank_le_depth() -> None:
    print("== growthRank e <= emlDepth e  (sampled expressions) ==")
    samples: List[Tuple[str, EMLExpr]] = [
        ("x", Var()),
        ("x^2 + 3", Add(Mul(Var(), Var()), Const(3.0))),
        ("eml(1, x) = e^x", Eml(Const(1.0), Var())),
        ("e^x + x^5", Add(Eml(Const(1.0), Var()), Mul(Var(), Mul(Var(), Mul(Var(), Mul(Var(), Var())))))),
        ("e^(e^x)", eml_expr_iter_exp(2)),
        ("x*e^x + e^(x^2)", Add(Mul(Var(), Eml(Const(1.0), Var())),
                                 Eml(Const(1.0), Mul(Var(), Var())))),
    ]
    for name, e in samples:
        print(f"  {name:18s}: growthRank={growth_rank(e)}  emlDepth={eml_depth(e)}  "
              f"holds={growth_rank(e) <= eml_depth(e)}")
    print()


def demo_poly_tower_majorant() -> None:
    print("== Polynomial-argument tower majorant: |eval(e,x)| <= iterExp k (C*x^N) ==")
    # e = x*e^x + e^(x^2), inverse-free, growth rank 2.
    e = Add(Mul(Var(), Eml(Const(1.0), Var())), Eml(Const(1.0), Mul(Var(), Var())))
    k = growth_rank(e)
    C, N = 2.0, 2  # witnessing constants
    print(f"  expression: x*e^x + e^(x^2),  growthRank k = {k},  C={C}, N={N}")
    for x in [1.5, 2.0, 2.5, 3.0]:
        lhs = abs(eval_expr(e, x))
        rhs = iter_exp(k, C * x ** N)
        print(f"   x={x:4.1f}:  |eval| = {lhs:.6e}   <=   iterExp {k} (C*x^{N}) = {rhs:.6e}   "
              f"[{lhs <= rhs}]")
    print()


def demo_tight_separation() -> None:
    print("== Tight separation: iterExp n outgrows iterExp (n-1)(C*x^N) for any C,N ==")
    # To avoid astronomical magnitudes we apply log to both sides (n-1) times.
    # That reduces  iterExp n (x)         -> exp(x)         (one exponential left)
    # and           iterExp (n-1)(C*x^N)  -> C * x^N        (polynomial)
    # The whole hierarchy theorem boils down to: exp(x) eventually beats C*x^N.
    n = 4
    C, N = 5.0, 3
    print(f"  After taking log {n-1} times:  target -> exp(x),  rival -> C*x^{N} (C={C})")
    for x in [10.0, 20.0, 30.0, 40.0, 50.0]:
        hi = math.exp(x)         # reduced target  (one exp survives)
        lo = C * x ** N          # reduced rival   (polynomial)
        ratio = hi / lo
        print(f"   x={x:5.1f}:  exp(x) = {hi:.4e}   C*x^{N} = {lo:.4e}   "
              f"ratio = {ratio:.4e}  (-> infinity)")
    print("  -> exp dominates every polynomial, so iterExp n strictly outgrows any\n"
          "     depth-(n-1) expression. Hence depth (n-1) cannot represent iterExp n.\n")


# ----------------------------------------------------------------------------
# 4. Companion oracle toolkit (Catalog/Bridges/Advanced.lean)
# ----------------------------------------------------------------------------

def oracle_refines(o1: Callable[[float], float], o2: Callable[[float], float],
                   samples: List[float]) -> bool:
    """O1 refines O2 iff every fixed point of O1 is a fixed point of O2."""
    for x in samples:
        if math.isclose(o1(x), x, rel_tol=1e-12) and not math.isclose(o2(x), x, rel_tol=1e-9):
            return False
    return True


def idem_one_step(f: Callable[[float], float], x: float) -> bool:
    """Idempotent maps converge in a single step: f x = f (f x)."""
    return math.isclose(f(x), f(f(x)), rel_tol=1e-9)


def binary_entropy(p: float) -> float:
    """H(p) = -p log2 p - (1-p) log2(1-p), with H(0)=H(1)=0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def mobius(a: float, b: float, c: float, d: float, x: float) -> float:
    """Mobius transform (a x + b)/(c x + d)."""
    return (a * x + b) / (c * x + d)


def inv_stereo_n(x: List[float]) -> List[float]:
    """Inverse stereographic projection ℝⁿ -> Sⁿ ⊂ ℝⁿ⁺¹."""
    s = sum(xi ** 2 for xi in x)
    out = [2 * xi / (1 + s) for xi in x]
    out.append((s - 1) / (1 + s))
    return out


def demo_oracles() -> None:
    print("== Companion oracle toolkit ==")
    clamp = lambda t: max(0.0, min(1.0, t))   # idempotent
    pts = [-0.5, 0.3, 0.7, 1.5]
    print(f"  idempotent one-step (clamp): {all(idem_one_step(clamp, x) for x in pts)}")
    print(f"  H(1/2) = {binary_entropy(0.5):.6f}  (expected 1.0)")
    print(f"  H nonneg on (0,1): {all(binary_entropy(p) >= 0 for p in [0.1,0.25,0.5,0.9])}")

    # Mobius composition identity.
    a1, b1, c1, d1 = 2, 1, 1, 3
    a2, b2, c2, d2 = 1, 4, 2, 1
    x = 0.7
    lhs = mobius(a1, b1, c1, d1, mobius(a2, b2, c2, d2, x))
    rhs = ((a1 * (a2 * x + b2) + b1 * (c2 * x + d2)) /
           (c1 * (a2 * x + b2) + d1 * (c2 * x + d2)))
    print(f"  Mobius composition matches matrix product: {math.isclose(lhs, rhs)}")

    for v in ([0.0], [1.0, 2.0], [0.3, -0.4, 1.1]):
        img = inv_stereo_n(v)
        norm2 = sum(c ** 2 for c in img)
        print(f"  inv_stereo {v} -> ||.||^2 = {norm2:.12f} (on unit sphere)")
    print()


def main() -> None:
    print("=" * 72)
    print("THE TIGHT DEPTH HIERARCHY — numerical demonstrations")
    print("=" * 72 + "\n")
    demo_depth_equals_n()
    demo_growth_rank_le_depth()
    demo_poly_tower_majorant()
    demo_tight_separation()
    demo_oracles()
    print("Done.")


if __name__ == "__main__":
    main()
