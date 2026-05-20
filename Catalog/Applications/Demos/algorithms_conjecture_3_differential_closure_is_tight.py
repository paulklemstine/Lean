#!/usr/bin/env python3
"""
Algorithms for Elementary Differential Closure.

Implements the core algorithms from the formalization:
1. Symbolic differentiation (derivE)
2. Expression simplification / normalization
3. Validity checking
4. Generator analysis (containsExp / containsLog)

Each algorithm mirrors a verified Lean definition and carries a correctness
theorem reference.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional


# ═══════════════════════════════════════════════════════════════════════════════
# 1. Expression AST (mirrors EExpr inductive type)
# ═══════════════════════════════════════════════════════════════════════════════

class EExpr:
    """Elementary expression in one real variable.

    Corresponds to the Lean inductive type:
        inductive EExpr where
          | var | const (c : ℝ) | add | sub | mul | div | exp | log
    """
    pass

@dataclass(frozen=True)
class Var(EExpr):
    """The identity function x ↦ x."""
    def __repr__(self): return "x"

@dataclass(frozen=True)
class Const(EExpr):
    """A real constant c."""
    value: float
    def __repr__(self):
        if self.value == int(self.value): return str(int(self.value))
        return f"{self.value}"

@dataclass(frozen=True)
class Add(EExpr):
    left: EExpr; right: EExpr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class Sub(EExpr):
    left: EExpr; right: EExpr
    def __repr__(self): return f"({self.left} - {self.right})"

@dataclass(frozen=True)
class Mul(EExpr):
    left: EExpr; right: EExpr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class Div(EExpr):
    left: EExpr; right: EExpr
    def __repr__(self): return f"({self.left} / {self.right})"

@dataclass(frozen=True)
class Exp(EExpr):
    arg: EExpr
    def __repr__(self): return f"exp({self.arg})"

@dataclass(frozen=True)
class Log(EExpr):
    arg: EExpr
    def __repr__(self): return f"log({self.arg})"


# ═══════════════════════════════════════════════════════════════════════════════
# 2. Evaluation (mirrors evalE)
# ═══════════════════════════════════════════════════════════════════════════════

def eval_expr(e: EExpr, x: float) -> float:
    """Evaluate expression at x.

    Correctness: corresponds to EExpr.evalE in Lean.
    Uses Python's math functions which match Real.exp, Real.log semantics
    on valid domains.
    """
    match e:
        case Var(): return x
        case Const(c): return c
        case Add(a, b): return eval_expr(a, x) + eval_expr(b, x)
        case Sub(a, b): return eval_expr(a, x) - eval_expr(b, x)
        case Mul(a, b): return eval_expr(a, x) * eval_expr(b, x)
        case Div(a, b): return eval_expr(a, x) / eval_expr(b, x)
        case Exp(a): return math.exp(eval_expr(a, x))
        case Log(a): return math.log(eval_expr(a, x))
    raise TypeError(f"Unknown: {type(e)}")


# ═══════════════════════════════════════════════════════════════════════════════
# 3. Symbolic Differentiation (mirrors derivE)
# ═══════════════════════════════════════════════════════════════════════════════

def symbolic_deriv(e: EExpr) -> EExpr:
    """Symbolic differentiation algorithm.

    Correctness theorem (Lean): EExpr.derivE_sound
        ∀ e x, ValidAt e x → HasDerivAt (evalE e) (evalE (derivE e) x) x

    Time complexity: O(n) where n = size(e)
    Space complexity: O(n) for the output (which can be up to O(n²) in size)
    """
    match e:
        case Var(): return Const(1)
        case Const(_): return Const(0)
        case Add(a, b): return Add(symbolic_deriv(a), symbolic_deriv(b))
        case Sub(a, b): return Sub(symbolic_deriv(a), symbolic_deriv(b))
        case Mul(a, b):
            # Product rule: (fg)' = f'g + fg'
            return Add(Mul(symbolic_deriv(a), b), Mul(a, symbolic_deriv(b)))
        case Div(a, b):
            # Quotient rule: (f/g)' = (f'g - fg') / g²
            return Div(
                Sub(Mul(symbolic_deriv(a), b), Mul(a, symbolic_deriv(b))),
                Mul(b, b)
            )
        case Exp(a):
            # Chain rule: (exp f)' = f' · exp(f)
            return Mul(symbolic_deriv(a), Exp(a))
        case Log(a):
            # Chain rule: (log f)' = f' / f
            return Div(symbolic_deriv(a), a)
    raise TypeError(f"Unknown: {type(e)}")


# ═══════════════════════════════════════════════════════════════════════════════
# 4. Expression Simplification / Normalization
# ═══════════════════════════════════════════════════════════════════════════════

def simplify(e: EExpr) -> EExpr:
    """Basic algebraic simplification.

    Applies constant folding and identity elimination:
    - 0 + x = x, x + 0 = x
    - 0 * x = 0, x * 0 = 0, 1 * x = x, x * 1 = x
    - x - 0 = x
    - x / 1 = x, 0 / x = 0
    - const op const = const(result)

    This is not verified in Lean (would require a normalize_preserves_semantics theorem).
    """
    match e:
        case Var() | Const(_):
            return e
        case Add(a, b):
            a, b = simplify(a), simplify(b)
            if isinstance(a, Const) and a.value == 0: return b
            if isinstance(b, Const) and b.value == 0: return a
            if isinstance(a, Const) and isinstance(b, Const):
                return Const(a.value + b.value)
            return Add(a, b)
        case Sub(a, b):
            a, b = simplify(a), simplify(b)
            if isinstance(b, Const) and b.value == 0: return a
            if isinstance(a, Const) and isinstance(b, Const):
                return Const(a.value - b.value)
            return Sub(a, b)
        case Mul(a, b):
            a, b = simplify(a), simplify(b)
            if isinstance(a, Const) and a.value == 0: return Const(0)
            if isinstance(b, Const) and b.value == 0: return Const(0)
            if isinstance(a, Const) and a.value == 1: return b
            if isinstance(b, Const) and b.value == 1: return a
            if isinstance(a, Const) and isinstance(b, Const):
                return Const(a.value * b.value)
            return Mul(a, b)
        case Div(a, b):
            a, b = simplify(a), simplify(b)
            if isinstance(a, Const) and a.value == 0: return Const(0)
            if isinstance(b, Const) and b.value == 1: return a
            return Div(a, b)
        case Exp(a):
            a = simplify(a)
            if isinstance(a, Const): return Const(math.exp(a.value))
            return Exp(a)
        case Log(a):
            a = simplify(a)
            if isinstance(a, Const) and a.value > 0:
                return Const(math.log(a.value))
            return Log(a)
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════════════
# 5. Validity Checking (mirrors ValidAt)
# ═══════════════════════════════════════════════════════════════════════════════

def is_valid_at(e: EExpr, x: float) -> bool:
    """Check if expression is valid (well-defined) at point x.

    Mirrors EExpr.ValidAt:
    - Division requires nonzero denominator
    - Log requires positive argument

    Lean theorem: EExpr.validAt_derivE shows validity is preserved by derivE.
    """
    match e:
        case Var() | Const(_): return True
        case Add(a, b) | Sub(a, b) | Mul(a, b):
            return is_valid_at(a, x) and is_valid_at(b, x)
        case Div(a, b):
            return is_valid_at(a, x) and is_valid_at(b, x) and eval_expr(b, x) != 0
        case Exp(a): return is_valid_at(a, x)
        case Log(a): return is_valid_at(a, x) and eval_expr(a, x) > 0
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════════════
# 6. Generator Analysis (mirrors containsExp / containsLog)
# ═══════════════════════════════════════════════════════════════════════════════

def contains_exp(e: EExpr) -> bool:
    """Check if expression uses the exp constructor.
    Lean theorem: EExpr.derivE_noexp — if False, remains False after derivE."""
    match e:
        case Var() | Const(_): return False
        case Add(a, b) | Sub(a, b) | Mul(a, b) | Div(a, b):
            return contains_exp(a) or contains_exp(b)
        case Exp(_): return True
        case Log(a): return contains_exp(a)
    raise TypeError

def contains_log(e: EExpr) -> bool:
    """Check if expression uses the log constructor.
    Lean theorem: EExpr.derivE_nolog — if False, remains False after derivE."""
    match e:
        case Var() | Const(_): return False
        case Add(a, b) | Sub(a, b) | Mul(a, b) | Div(a, b):
            return contains_log(a) or contains_log(b)
        case Exp(a): return contains_log(a)
        case Log(_): return True
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════════════
# 7. Size and Complexity (mirrors EExpr.size)
# ═══════════════════════════════════════════════════════════════════════════════

def expr_size(e: EExpr) -> int:
    """AST node count. Lean theorem: EExpr.size_derivE_le bounds derivative size."""
    match e:
        case Var() | Const(_): return 1
        case Add(a, b) | Sub(a, b) | Mul(a, b) | Div(a, b):
            return 1 + expr_size(a) + expr_size(b)
        case Exp(a) | Log(a): return 1 + expr_size(a)
    raise TypeError


# ═══════════════════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    x = Var()

    print("=== Symbolic Differentiation Algorithm ===\n")

    examples = [
        ("x²", Mul(x, x)),
        ("exp(x²)", Exp(Mul(x, x))),
        ("log(x)", Log(x)),
        ("exp(x)/x", Div(Exp(x), x)),
        ("log(exp(x)+1)", Log(Add(Exp(x), Const(1)))),
    ]

    for name, e in examples:
        de = symbolic_deriv(e)
        de_s = simplify(de)
        print(f"  d/dx [{name}]")
        print(f"    raw:        {de}")
        print(f"    simplified: {de_s}")
        print(f"    size: {expr_size(e)} → {expr_size(de)} → {expr_size(de_s)} (simplified)")
        print()

    print("=== Validity Preservation ===\n")
    e = Div(Exp(x), Log(x))
    print(f"  e = {e}")
    for pt in [0.5, 1.0, 2.0, -1.0]:
        v = is_valid_at(e, pt)
        dv = is_valid_at(symbolic_deriv(e), pt) if v else "N/A"
        print(f"  x={pt}: valid(e)={v}, valid(e')={dv}")
