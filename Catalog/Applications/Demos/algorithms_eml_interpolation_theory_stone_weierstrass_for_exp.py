#!/usr/bin/env python3
"""
EML Interpolation Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the EML
Stone-Weierstrass theory.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Union, Callable


# === Core Data Structures ===

@dataclass(frozen=True)
class Const:
    """A constant value."""
    value: float

@dataclass(frozen=True)
class Proj:
    """The identity/projection function x ↦ x."""
    pass

@dataclass(frozen=True)
class Exp:
    """Exponential: exp(child)."""
    child: EMLExpr

@dataclass(frozen=True)
class Log:
    """Logarithm: log(child)."""
    child: EMLExpr

@dataclass(frozen=True)
class Add:
    """Addition: left + right."""
    left: EMLExpr
    right: EMLExpr

@dataclass(frozen=True)
class Mul:
    """Multiplication: left * right."""
    left: EMLExpr
    right: EMLExpr


EMLExpr = Union[Const, Proj, Exp, Log, Add, Mul]


@dataclass(frozen=True)
class EMLComplexity:
    """Complexity pair (depth, size) with invariant depth ≤ size."""
    depth: int
    size: int

    def __post_init__(self) -> None:
        assert self.depth <= self.size, f"Depth {self.depth} > size {self.size}"

    def __le__(self, other: EMLComplexity) -> bool:
        return self.depth <= other.depth and self.size <= other.size


# === Algorithm 1: EML Evaluation ===

def eval_eml(expr: EMLExpr, x: float) -> float:
    """
    Evaluate an EML expression at a point x.

    Time complexity: O(size(expr))
    Space complexity: O(depth(expr)) for recursion stack

    Pseudocode:
        EVAL(const(c), x) = c
        EVAL(proj, x) = x
        EVAL(exp(e), x) = exp(EVAL(e, x))
        EVAL(log(e), x) = log(EVAL(e, x)) if EVAL(e, x) > 0, else 0
        EVAL(add(e1, e2), x) = EVAL(e1, x) + EVAL(e2, x)
        EVAL(mul(e1, e2), x) = EVAL(e1, x) * EVAL(e2, x)
    """
    if isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Proj):
        return x
    elif isinstance(expr, Exp):
        v = eval_eml(expr.child, x)
        return math.exp(min(v, 700))  # overflow protection
    elif isinstance(expr, Log):
        v = eval_eml(expr.child, x)
        return math.log(v) if v > 0 else 0.0
    elif isinstance(expr, Add):
        return eval_eml(expr.left, x) + eval_eml(expr.right, x)
    elif isinstance(expr, Mul):
        return eval_eml(expr.left, x) * eval_eml(expr.right, x)
    raise TypeError(f"Unknown EML expression type: {type(expr)}")


# === Algorithm 2: Complexity Computation ===

def compute_depth(expr: EMLExpr) -> int:
    """Compute the depth of an EML expression. O(size) time."""
    if isinstance(expr, (Const, Proj)):
        return 0
    elif isinstance(expr, (Exp, Log)):
        return compute_depth(expr.child) + 1
    elif isinstance(expr, (Add, Mul)):
        return max(compute_depth(expr.left), compute_depth(expr.right)) + 1
    raise TypeError


def compute_size(expr: EMLExpr) -> int:
    """Compute the size of an EML expression. O(size) time."""
    if isinstance(expr, (Const, Proj)):
        return 1
    elif isinstance(expr, (Exp, Log)):
        return compute_size(expr.child) + 1
    elif isinstance(expr, (Add, Mul)):
        return compute_size(expr.left) + compute_size(expr.right) + 1
    raise TypeError


def complexity(expr: EMLExpr) -> EMLComplexity:
    """Compute the EML complexity of an expression."""
    return EMLComplexity(compute_depth(expr), compute_size(expr))


# === Algorithm 3: EML Substitution (Composition) ===

def subst(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
    """
    Substitute e2 for Proj in e1, computing e1 ∘ e2.

    Postcondition: eval(subst(e1, e2), x) = eval(e1, eval(e2, x))
    Depth bound: depth(subst(e1, e2)) ≤ depth(e1) + depth(e2)

    Pseudocode:
        SUBST(const(c), e2) = const(c)
        SUBST(proj, e2) = e2
        SUBST(exp(e), e2) = exp(SUBST(e, e2))
        SUBST(log(e), e2) = log(SUBST(e, e2))
        SUBST(add(a,b), e2) = add(SUBST(a, e2), SUBST(b, e2))
        SUBST(mul(a,b), e2) = mul(SUBST(a, e2), SUBST(b, e2))
    """
    if isinstance(e1, Const):
        return e1
    elif isinstance(e1, Proj):
        return e2
    elif isinstance(e1, Exp):
        return Exp(subst(e1.child, e2))
    elif isinstance(e1, Log):
        return Log(subst(e1.child, e2))
    elif isinstance(e1, Add):
        return Add(subst(e1.left, e2), subst(e1.right, e2))
    elif isinstance(e1, Mul):
        return Mul(subst(e1.left, e2), subst(e1.right, e2))
    raise TypeError


# === Algorithm 4: Constructing EML Power Functions ===

def eml_pow(r: float) -> EMLExpr:
    """
    Construct the EML expression for x^r: exp(r * log(x)).
    Size: 5 (constant). Depth: 3 (constant).

    For positive x: eval(eml_pow(r), x) = x^r exactly.
    """
    return Exp(Mul(Const(r), Log(Proj())))


# === Algorithm 5: Iterated Exponential ===

def iter_exp(n: int) -> EMLExpr:
    """
    Construct the n-fold iterated exponential exp^n(x).
    Depth: n. Size: n+1.
    """
    if n == 0:
        return Proj()
    return Exp(iter_exp(n - 1))


# === Algorithm 6: Softmax Approximation of Max ===

def softmax_approx(t: float) -> EMLExpr:
    """
    Construct the EML expression for softmax_t(x, 0) = (1/t) * log(exp(t*x) + 1).
    Approximates max(x, 0) = ReLU(x) with error ≤ log(2)/t.
    """
    return Mul(
        Const(1.0 / t),
        Log(Add(Exp(Mul(Const(t), Proj())), Const(1.0)))
    )


# === Algorithm 7: Uniform Approximation Error ===

def uniform_error(expr: EMLExpr, f: Callable[[float], float],
                  a: float, b: float, n_samples: int = 1000) -> float:
    """
    Estimate the uniform approximation error ||f - eval(expr, ·)||_∞
    on [a, b] by sampling n_samples points.
    """
    max_err = 0.0
    for i in range(n_samples + 1):
        x = a + (b - a) * i / n_samples
        err = abs(f(x) - eval_eml(expr, x))
        max_err = max(max_err, err)
    return max_err


# === Algorithm 8: Pretty Printing ===

def pretty_print(expr: EMLExpr) -> str:
    """Human-readable representation of an EML expression."""
    if isinstance(expr, Const):
        if expr.value == int(expr.value):
            return str(int(expr.value))
        return f"{expr.value:.4g}"
    elif isinstance(expr, Proj):
        return "x"
    elif isinstance(expr, Exp):
        return f"exp({pretty_print(expr.child)})"
    elif isinstance(expr, Log):
        return f"log({pretty_print(expr.child)})"
    elif isinstance(expr, Add):
        return f"({pretty_print(expr.left)} + {pretty_print(expr.right)})"
    elif isinstance(expr, Mul):
        return f"({pretty_print(expr.left)} · {pretty_print(expr.right)})"
    raise TypeError


if __name__ == "__main__":
    # Quick self-test
    print("Self-test:")

    # Test x^2
    e = eml_pow(2.0)
    assert abs(eval_eml(e, 3.0) - 9.0) < 1e-10
    print(f"  x^2 at x=3: {eval_eml(e, 3.0)} ✓")

    # Test sqrt
    e = eml_pow(0.5)
    assert abs(eval_eml(e, 4.0) - 2.0) < 1e-10
    print(f"  √x at x=4: {eval_eml(e, 4.0)} ✓")

    # Test substitution
    e1 = Exp(Proj())
    e2 = Exp(Proj())
    composed = subst(e1, e2)
    x = 1.0
    assert abs(eval_eml(composed, x) - math.exp(math.exp(x))) < 1e-10
    print(f"  exp(exp(1)): {eval_eml(composed, x):.6f} ✓")

    # Test depth bound
    c = complexity(composed)
    assert c.depth <= compute_depth(e1) + compute_depth(e2)
    print(f"  Depth bound: {c.depth} ≤ {compute_depth(e1)} + {compute_depth(e2)} ✓")

    # Test softmax
    relu_approx = softmax_approx(100.0)
    err = uniform_error(relu_approx, lambda x: max(x, 0), -1.0, 1.0)
    print(f"  Softmax(100) approx of ReLU, error: {err:.6f}")
    assert err < 0.1, f"Softmax error too large: {err}"
    print("  ✓")

    print("All self-tests passed.")
