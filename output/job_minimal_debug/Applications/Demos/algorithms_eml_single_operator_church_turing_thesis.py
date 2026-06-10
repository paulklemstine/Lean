#!/usr/bin/env python3
"""
EML Closure Algebra — Algorithms

Type-hinted implementations of key algorithms from the EML theory:
1. EML expression evaluation
2. Transcendental depth computation
3. Compilation from exp/log expressions to EML-only form
4. EML diagonal iteration and fixed-point search
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Tuple, Union
import math


# ============================================================
# §1. EML Expression AST
# ============================================================

@dataclass(frozen=True)
class Const:
    """A constant value."""
    value: float

@dataclass(frozen=True)
class Var:
    """A variable reference."""
    index: int

@dataclass(frozen=True)
class Add:
    """Addition of two expressions."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass(frozen=True)
class Mul:
    """Multiplication of two expressions."""
    left: 'EMLExpr'
    right: 'EMLExpr'

@dataclass(frozen=True)
class Neg:
    """Negation of an expression."""
    operand: 'EMLExpr'

@dataclass(frozen=True)
class Inv:
    """Multiplicative inverse of an expression."""
    operand: 'EMLExpr'

@dataclass(frozen=True)
class App:
    """Application of the EML operator: eml(left, right) = exp(left) - log(right)."""
    left: 'EMLExpr'
    right: 'EMLExpr'

# Union type for all expression nodes
EMLExpr = Union[Const, Var, Add, Mul, Neg, Inv, App]


# ============================================================
# §2. Traditional Expression AST (with separate exp/log)
# ============================================================

@dataclass(frozen=True)
class TConst:
    value: float

@dataclass(frozen=True)
class TVar:
    index: int

@dataclass(frozen=True)
class TAdd:
    left: 'TradExpr'
    right: 'TradExpr'

@dataclass(frozen=True)
class TMul:
    left: 'TradExpr'
    right: 'TradExpr'

@dataclass(frozen=True)
class TNeg:
    operand: 'TradExpr'

@dataclass(frozen=True)
class TInv:
    operand: 'TradExpr'

@dataclass(frozen=True)
class TExp:
    """Exponential: exp(operand)."""
    operand: 'TradExpr'

@dataclass(frozen=True)
class TLog:
    """Logarithm: log(operand)."""
    operand: 'TradExpr'

TradExpr = Union[TConst, TVar, TAdd, TMul, TNeg, TInv, TExp, TLog]


# ============================================================
# §3. Evaluation
# ============================================================

def eml_op(a: float, b: float) -> float:
    """The EML operator: eml(a, b) = exp(a) - log(b)."""
    return math.exp(a) - math.log(b)


def eval_eml(expr: EMLExpr, env: Dict[int, float]) -> float:
    """Evaluate an EML expression given a variable environment."""
    if isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Var):
        return env.get(expr.index, 0.0)
    elif isinstance(expr, Add):
        return eval_eml(expr.left, env) + eval_eml(expr.right, env)
    elif isinstance(expr, Mul):
        return eval_eml(expr.left, env) * eval_eml(expr.right, env)
    elif isinstance(expr, Neg):
        return -eval_eml(expr.operand, env)
    elif isinstance(expr, Inv):
        val = eval_eml(expr.operand, env)
        return 1.0 / val if val != 0 else float('inf')
    elif isinstance(expr, App):
        a = eval_eml(expr.left, env)
        b = eval_eml(expr.right, env)
        return eml_op(a, b)
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


def eval_trad(expr: TradExpr, env: Dict[int, float]) -> float:
    """Evaluate a traditional expression."""
    if isinstance(expr, TConst):
        return expr.value
    elif isinstance(expr, TVar):
        return env.get(expr.index, 0.0)
    elif isinstance(expr, TAdd):
        return eval_trad(expr.left, env) + eval_trad(expr.right, env)
    elif isinstance(expr, TMul):
        return eval_trad(expr.left, env) * eval_trad(expr.right, env)
    elif isinstance(expr, TNeg):
        return -eval_trad(expr.operand, env)
    elif isinstance(expr, TInv):
        val = eval_trad(expr.operand, env)
        return 1.0 / val if val != 0 else float('inf')
    elif isinstance(expr, TExp):
        return math.exp(eval_trad(expr.operand, env))
    elif isinstance(expr, TLog):
        return math.log(eval_trad(expr.operand, env))
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# §4. Transcendental Depth
# ============================================================

def depth(expr: EMLExpr) -> int:
    """Compute the transcendental depth of an EML expression.
    
    Depth 0: rational functions (no eml applications)
    Depth k: at most k nested eml applications
    
    Time complexity: O(size(expr))
    """
    if isinstance(expr, (Const, Var)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(depth(expr.left), depth(expr.right))
    elif isinstance(expr, (Neg, Inv)):
        return depth(expr.operand)
    elif isinstance(expr, App):
        return max(depth(expr.left), depth(expr.right)) + 1
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


def size(expr: EMLExpr) -> int:
    """Compute the size (number of nodes) of an EML expression."""
    if isinstance(expr, (Const, Var)):
        return 1
    elif isinstance(expr, (Add, Mul, App)):
        return 1 + size(expr.left) + size(expr.right)
    elif isinstance(expr, (Neg, Inv)):
        return 1 + size(expr.operand)
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# §5. Compilation: Traditional → EML-Only
# ============================================================

def compile_to_eml(expr: TradExpr) -> EMLExpr:
    """Compile a traditional expression (with exp/log) to an EML-only expression.
    
    Key translations:
    - exp(e) → eml(compile(e), 1)        [since eml(x, 1) = exp(x)]
    - log(e) → 1 + neg(eml(0, compile(e)))  [since 1 - eml(0, y) = log(y)]
    
    Preserves semantics: eval_eml(compile(e), env) = eval_trad(e, env)
    Size increase: at most factor 5
    """
    if isinstance(expr, TConst):
        return Const(expr.value)
    elif isinstance(expr, TVar):
        return Var(expr.index)
    elif isinstance(expr, TAdd):
        return Add(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, TMul):
        return Mul(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, TNeg):
        return Neg(compile_to_eml(expr.operand))
    elif isinstance(expr, TInv):
        return Inv(compile_to_eml(expr.operand))
    elif isinstance(expr, TExp):
        # exp(e) = eml(e, 1) since log(1) = 0
        return App(compile_to_eml(expr.operand), Const(1.0))
    elif isinstance(expr, TLog):
        # log(e) = 1 - eml(0, e) = 1 + neg(eml(0, e))
        return Add(Const(1.0), Neg(App(Const(0.0), compile_to_eml(expr.operand))))
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# §6. EML Diagonal Iteration
# ============================================================

def eml_diagonal(z: float) -> float:
    """The EML diagonal: d(z) = eml(z, z) = exp(z) - log(z)."""
    return math.exp(z) - math.log(z)


def eml_diagonal_iterate(z0: float, n: int) -> List[float]:
    """Iterate the EML diagonal n times starting from z0.
    
    Returns the full orbit [z0, d(z0), d²(z0), ..., dⁿ(z0)].
    
    Property (proved): d(z) - z ≥ 1 for z > 0, so the orbit
    diverges at least linearly.
    """
    orbit: List[float] = [z0]
    z = z0
    for _ in range(n):
        z = eml_diagonal(z)
        orbit.append(z)
    return orbit


def find_diagonal_critical_point(tol: float = 1e-15, max_iter: int = 100) -> float:
    """Find the critical point z₀ of exp(z) - log(z) using Newton's method.
    
    z₀ satisfies exp(z₀) = 1/z₀, equivalently z₀·exp(z₀) = 1.
    Therefore z₀ = W(1) where W is the Lambert W function.
    
    Returns z₀ ≈ 0.5671432904...
    """
    z = 0.5  # initial guess
    for _ in range(max_iter):
        # f(z) = exp(z) - 1/z (derivative of diagonal)
        # f'(z) = exp(z) + 1/z²
        f = math.exp(z) - 1.0 / z
        fp = math.exp(z) + 1.0 / z**2
        delta = f / fp
        z -= delta
        if abs(delta) < tol:
            break
    return z


# ============================================================
# §7. Pretty Printing
# ============================================================

def pretty_eml(expr: EMLExpr) -> str:
    """Pretty-print an EML expression."""
    if isinstance(expr, Const):
        return str(expr.value)
    elif isinstance(expr, Var):
        return f"x{expr.index}"
    elif isinstance(expr, Add):
        return f"({pretty_eml(expr.left)} + {pretty_eml(expr.right)})"
    elif isinstance(expr, Mul):
        return f"({pretty_eml(expr.left)} × {pretty_eml(expr.right)})"
    elif isinstance(expr, Neg):
        return f"(-{pretty_eml(expr.operand)})"
    elif isinstance(expr, Inv):
        return f"(1/{pretty_eml(expr.operand)})"
    elif isinstance(expr, App):
        return f"eml({pretty_eml(expr.left)}, {pretty_eml(expr.right)})"
    else:
        return "?"


# ============================================================
# §8. Example Usage
# ============================================================

if __name__ == "__main__":
    # Build exp(x) in traditional form
    trad_exp = TExp(TVar(0))
    # Compile to EML-only
    eml_exp = compile_to_eml(trad_exp)
    print(f"Traditional: exp(x0)")
    print(f"EML-only:    {pretty_eml(eml_exp)}")
    print(f"Depth: {depth(eml_exp)}, Size: {size(eml_exp)}")
    
    env = {0: 2.0}
    print(f"eval_trad(exp(x0), x0=2) = {eval_trad(trad_exp, env):.10f}")
    print(f"eval_eml(compiled, x0=2)  = {eval_eml(eml_exp, env):.10f}")
    
    print()
    
    # Build log(x) in traditional form
    trad_log = TLog(TVar(0))
    eml_log = compile_to_eml(trad_log)
    print(f"Traditional: log(x0)")
    print(f"EML-only:    {pretty_eml(eml_log)}")
    print(f"Depth: {depth(eml_log)}, Size: {size(eml_log)}")
    
    env = {0: 2.0}
    print(f"eval_trad(log(x0), x0=2) = {eval_trad(trad_log, env):.10f}")
    print(f"eval_eml(compiled, x0=2)  = {eval_eml(eml_log, env):.10f}")
    
    print()
    
    # Build sinh(x) = (exp(x) - exp(-x)) / 2
    trad_sinh = TMul(
        TAdd(TExp(TVar(0)), TNeg(TExp(TNeg(TVar(0))))),
        TInv(TConst(2.0))
    )
    eml_sinh = compile_to_eml(trad_sinh)
    print(f"Traditional: sinh(x0) = (exp(x0) - exp(-x0)) * (1/2)")
    print(f"EML-only:    {pretty_eml(eml_sinh)}")
    print(f"Depth: {depth(eml_sinh)}, Size: {size(eml_sinh)}")
    
    env = {0: 1.0}
    print(f"eval_trad(sinh(x0), x0=1)  = {eval_trad(trad_sinh, env):.10f}")
    print(f"eval_eml(compiled, x0=1)   = {eval_eml(eml_sinh, env):.10f}")
    print(f"math.sinh(1)               = {math.sinh(1.0):.10f}")
    
    print()
    
    # Diagonal critical point
    z0 = find_diagonal_critical_point()
    print(f"Lambert W(1) = z₀ ≈ {z0:.15f}")
    print(f"z₀·exp(z₀) = {z0 * math.exp(z0):.15f}")
    
    print()
    
    # Diagonal orbit (small starting point to avoid overflow)
    print("Diagonal orbit from z=0.1:")
    orbit = eml_diagonal_iterate(0.1, 3)
    for i, z in enumerate(orbit):
        gap = z - orbit[i-1] if i > 0 else 0
        print(f"  d^{i}(0.1) = {z:.6f}" + (f"  (gap = {gap:.6f})" if i > 0 else ""))
