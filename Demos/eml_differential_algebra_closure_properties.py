"""
Numerical demonstration of the log-free EML differential algebra.

EML (exponential-multiplication-linear) functions are the smallest class of
real functions containing constants and the identity x, closed under:
    +   (add)
    *   (mul)
    -   (neg)
    exp (exponential)

They are exactly the *exponential polynomials*. This module mirrors the
formalized term algebra in pure Python and empirically verifies the main
results:

    * eval        -- interpret a term as a function R -> R          (Term.eval)
    * D           -- syntactic derivative (product + chain rules)   (Term.D)
    * comp        -- syntactic composition (substitution)           (Term.comp)
    * closure under +, *, neg, exp, composition, differentiation
    * correctness of D vs. a central finite difference (deriv_eval)
    * correctness of comp vs. real function composition  (eval_comp)
    * a witness that integration escapes the class: exp(x^2)        (Section 4.2)

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isclose
from typing import Callable, List, Tuple, Union


# --------------------------------------------------------------------------
# Syntax: the inductive Term type, as a tagged dataclass tree.
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class Const:
    c: float


@dataclass(frozen=True)
class X:
    pass


@dataclass(frozen=True)
class Add:
    a: "Term"
    b: "Term"


@dataclass(frozen=True)
class Mul:
    a: "Term"
    b: "Term"


@dataclass(frozen=True)
class Neg:
    a: "Term"


@dataclass(frozen=True)
class Exp:
    a: "Term"


Term = Union[Const, X, Add, Mul, Neg, Exp]


# --------------------------------------------------------------------------
# Semantics: Term.eval
# --------------------------------------------------------------------------
def eval_term(t: Term, x: float) -> float:
    """Interpret a term as a real number at the point x (mirrors Term.eval)."""
    if isinstance(t, Const):
        return t.c
    if isinstance(t, X):
        return x
    if isinstance(t, Add):
        return eval_term(t.a, x) + eval_term(t.b, x)
    if isinstance(t, Mul):
        return eval_term(t.a, x) * eval_term(t.b, x)
    if isinstance(t, Neg):
        return -eval_term(t.a, x)
    if isinstance(t, Exp):
        return exp(eval_term(t.a, x))
    raise TypeError(f"unknown term: {t!r}")


def as_function(t: Term) -> Callable[[float], float]:
    """Turn a term into a Python callable R -> R."""
    return lambda x: eval_term(t, x)


# --------------------------------------------------------------------------
# Syntactic derivative: Term.D  (product rule + exponential chain rule)
# --------------------------------------------------------------------------
def D(t: Term) -> Term:
    """Syntactic derivative of a term (mirrors Term.D)."""
    if isinstance(t, Const):
        return Const(0.0)
    if isinstance(t, X):
        return Const(1.0)
    if isinstance(t, Add):
        return Add(D(t.a), D(t.b))
    if isinstance(t, Mul):
        # (a*b)' = a'*b + a*b'
        return Add(Mul(D(t.a), t.b), Mul(t.a, D(t.b)))
    if isinstance(t, Neg):
        return Neg(D(t.a))
    if isinstance(t, Exp):
        # (exp a)' = a' * exp a
        return Mul(D(t.a), Exp(t.a))
    raise TypeError(f"unknown term: {t!r}")


# --------------------------------------------------------------------------
# Syntactic composition: Term.comp  (substitute t for X in s)
# --------------------------------------------------------------------------
def comp(s: Term, t: Term) -> Term:
    """Substitute t for every X-leaf in s (mirrors Term.comp)."""
    if isinstance(s, Const):
        return s
    if isinstance(s, X):
        return t
    if isinstance(s, Add):
        return Add(comp(s.a, t), comp(s.b, t))
    if isinstance(s, Mul):
        return Mul(comp(s.a, t), comp(s.b, t))
    if isinstance(s, Neg):
        return Neg(comp(s.a, t))
    if isinstance(s, Exp):
        return Exp(comp(s.a, t))
    raise TypeError(f"unknown term: {s!r}")


def pretty(t: Term) -> str:
    """Human-readable rendering of a term."""
    if isinstance(t, Const):
        return f"{t.c:g}"
    if isinstance(t, X):
        return "x"
    if isinstance(t, Add):
        return f"({pretty(t.a)} + {pretty(t.b)})"
    if isinstance(t, Mul):
        return f"({pretty(t.a)} * {pretty(t.b)})"
    if isinstance(t, Neg):
        return f"-({pretty(t.a)})"
    if isinstance(t, Exp):
        return f"exp({pretty(t.a)})"
    raise TypeError(f"unknown term: {t!r}")


def central_diff(f: Callable[[float], float], x: float, h: float = 1e-6) -> float:
    """Numerical derivative by central finite difference."""
    return (f(x + h) - f(x - h)) / (2.0 * h)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_derivative_correctness() -> None:
    """Verify deriv_eval: eval(D t)(x) == d/dx eval(t)(x) numerically."""
    print("=" * 70)
    print("1. Correctness of the syntactic derivative D  (Theorem deriv_eval)")
    print("=" * 70)

    # t = x * exp(x) + 7   ->   t' = exp(x) + x*exp(x)
    t: Term = Add(Mul(X(), Exp(X())), Const(7.0))
    dt = D(t)
    print(f"  t   = {pretty(t)}")
    print(f"  D t = {pretty(dt)}")
    f = as_function(t)
    df_sym = as_function(dt)
    print(f"  {'x':>6} | {'eval(D t)':>14} | {'central diff':>14} | match")
    for x in (-1.0, 0.0, 0.5, 1.0, 2.0):
        symbolic = df_sym(x)
        numeric = central_diff(f, x)
        ok = isclose(symbolic, numeric, rel_tol=1e-5, abs_tol=1e-5)
        print(f"  {x:6.2f} | {symbolic:14.8f} | {numeric:14.8f} | {ok}")
    print()


def demo_exp_x_squared() -> None:
    """exp(x^2) is EML; its derivative 2x*exp(x^2) is again EML."""
    print("=" * 70)
    print("2. exp(x^2) is EML and its derivative is again EML")
    print("=" * 70)
    t: Term = Exp(Mul(X(), X()))           # exp(x*x)
    dt = D(t)                               # 2x * exp(x^2) up to the product form
    print(f"  t   = {pretty(t)}")
    print(f"  D t = {pretty(dt)}        (closure under differentiation)")
    f = as_function(t)
    df = as_function(dt)
    for x in (-1.0, 0.0, 0.7, 1.3):
        print(f"   x={x:5.2f}:  exp(x^2)={f(x):12.6f}   (exp(x^2))'={df(x):12.6f}"
              f"   2x*exp(x^2)={2*x*exp(x*x):12.6f}")
    print("  Note: the *antiderivative* of exp(x^2) (the error function) is NOT")
    print("  EML -- integration escapes the class (the Liouville boundary).")
    print()


def demo_composition_correctness() -> None:
    """Verify eval_comp: eval(comp(s,t))(x) == eval(s)(eval(t)(x))."""
    print("=" * 70)
    print("3. Correctness of syntactic composition  (Theorem eval_comp)")
    print("=" * 70)
    s: Term = Exp(X())                      # s = exp(x)
    t: Term = Add(Mul(X(), X()), Const(1))  # t = x^2 + 1
    st = comp(s, t)                         # exp(x^2 + 1)
    print(f"  s = {pretty(s)},  t = {pretty(t)}")
    print(f"  comp(s,t) = {pretty(st)}")
    f_st = as_function(st)
    f_s = as_function(s)
    f_t = as_function(t)
    for x in (-1.0, 0.0, 1.0, 1.5):
        lhs = f_st(x)
        rhs = f_s(f_t(x))
        print(f"   x={x:5.2f}:  eval(comp)={lhs:14.6f}   s(t(x))={rhs:14.6f}"
              f"   match={isclose(lhs, rhs, rel_tol=1e-9)}")
    print()


def demo_closure_algebra() -> None:
    """Show the ring closure: build f+g, f*g, -f, exp(f) as EML terms."""
    print("=" * 70)
    print("4. Closure under +, *, neg, exp  (IsEML.add/mul/neg/exp)")
    print("=" * 70)
    f: Term = X()                       # x
    g: Term = Exp(X())                  # exp(x)
    combos: List[Tuple[str, Term]] = [
        ("f + g", Add(f, g)),
        ("f * g", Mul(f, g)),
        ("-f", Neg(f)),
        ("exp(f)", Exp(f)),
    ]
    for name, term in combos:
        print(f"  {name:10s} -> EML term {pretty(term)};  value at x=1: "
              f"{eval_term(term, 1.0):.6f}")
    print()


def demo_cube_no_inverse() -> None:
    """The cube map is EML but its inverse (cube root) is not (Section 4.3)."""
    print("=" * 70)
    print("5. Composition closure vs. failure of functional inverse")
    print("=" * 70)
    cube: Term = Mul(X(), Mul(X(), X()))     # x^3, an EML bijection of R
    print(f"  cube = {pretty(cube)}  (EML, bijective on R)")
    print(f"   cube(2) = {eval_term(cube, 2.0):g}")
    print("  Its inverse x^(1/3) is NOT EML: it is not differentiable at 0,")
    print("  while every EML function is smooth everywhere. The obstruction is")
    print("  the vanishing of the derivative 3x^2 at the origin:")
    print(f"   (cube)'(0) = {eval_term(D(cube), 0.0):g}")
    print()


def main() -> None:
    print("Log-free EML differential algebra -- numerical demonstrations\n")
    demo_derivative_correctness()
    demo_exp_x_squared()
    demo_composition_correctness()
    demo_closure_algebra()
    demo_cube_no_inverse()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
