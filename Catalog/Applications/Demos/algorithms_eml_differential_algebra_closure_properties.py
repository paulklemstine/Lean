#!/usr/bin/env python3
"""
EML Differential Algebra — Algorithms

Type-hinted implementations of:
1. EML expression trees with symbolic differentiation
2. Depth computation
3. EML chain rule evaluation
4. Differential closure verification
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable
import math


# ============================================================
# EML Expression Tree
# ============================================================

@dataclass
class Const:
    """Constant expression."""
    value: float

@dataclass
class Var:
    """Variable expression."""
    pass

@dataclass
class Add:
    """Addition of two expressions."""
    left: Expr
    right: Expr

@dataclass
class Mul:
    """Multiplication of two expressions."""
    left: Expr
    right: Expr

@dataclass
class Sub:
    """Subtraction of two expressions."""
    left: Expr
    right: Expr

@dataclass
class Div:
    """Division of two expressions."""
    left: Expr
    right: Expr

@dataclass
class Neg:
    """Negation of an expression."""
    inner: Expr

@dataclass
class Inv:
    """Multiplicative inverse of an expression."""
    inner: Expr

@dataclass
class Exp:
    """Exponential of an expression."""
    inner: Expr

@dataclass
class Log:
    """Logarithm of an expression."""
    inner: Expr

@dataclass
class EML:
    """EML operator: eml(a, b) = exp(a) - log(b)."""
    first: Expr
    second: Expr

Expr = Union[Const, Var, Add, Mul, Sub, Div, Neg, Inv, Exp, Log, EML]


# ============================================================
# Evaluation
# ============================================================

def evaluate(expr: Expr, x: float) -> float:
    """Evaluate an expression at a point x."""
    match expr:
        case Const(c):
            return c
        case Var():
            return x
        case Add(a, b):
            return evaluate(a, x) + evaluate(b, x)
        case Mul(a, b):
            return evaluate(a, x) * evaluate(b, x)
        case Sub(a, b):
            return evaluate(a, x) - evaluate(b, x)
        case Div(a, b):
            return evaluate(a, x) / evaluate(b, x)
        case Neg(a):
            return -evaluate(a, x)
        case Inv(a):
            return 1.0 / evaluate(a, x)
        case Exp(a):
            return math.exp(evaluate(a, x))
        case Log(a):
            return math.log(evaluate(a, x))
        case EML(a, b):
            return math.exp(evaluate(a, x)) - math.log(evaluate(b, x))
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Symbolic Differentiation
# ============================================================

def differentiate(expr: Expr) -> Expr:
    """
    Symbolically differentiate an EML expression.
    
    Key property: the derivative of an EML expression is always
    another EML expression (or expression built from EML parts).
    This implements the Differential Closure Theorem.
    """
    match expr:
        case Const(_):
            return Const(0)
        case Var():
            return Const(1)
        case Add(a, b):
            return Add(differentiate(a), differentiate(b))
        case Sub(a, b):
            return Sub(differentiate(a), differentiate(b))
        case Neg(a):
            return Neg(differentiate(a))
        case Mul(a, b):
            # Leibniz rule: (a·b)' = a'·b + a·b'
            return Add(Mul(differentiate(a), b), Mul(a, differentiate(b)))
        case Div(a, b):
            # Quotient rule: (a/b)' = (a'·b - a·b') / b²
            return Div(
                Sub(Mul(differentiate(a), b), Mul(a, differentiate(b))),
                Mul(b, b)
            )
        case Inv(a):
            # (1/a)' = -a'/a²
            return Neg(Div(differentiate(a), Mul(a, a)))
        case Exp(a):
            # (exp(a))' = a'·exp(a)
            return Mul(differentiate(a), Exp(a))
        case Log(a):
            # (log(a))' = a'/a
            return Div(differentiate(a), a)
        case EML(a, b):
            # EML chain rule: (eml(a, b))' = a'·exp(a) - b'/b
            # Note: exp(a) = eml(a, 1), so this stays in the EML class!
            return Sub(
                Mul(differentiate(a), EML(a, Const(1))),
                Div(differentiate(b), b)
            )
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Depth Computation
# ============================================================

def transcendence_depth(expr: Expr) -> int:
    """
    Compute the transcendence depth of an EML expression.
    
    Depth measures the maximum nesting level of exp/log operations.
    Key theorem: differentiation preserves depth.
    """
    match expr:
        case Const(_) | Var():
            return 0
        case Add(a, b) | Mul(a, b) | Sub(a, b) | Div(a, b):
            return max(transcendence_depth(a), transcendence_depth(b))
        case Neg(a) | Inv(a):
            return transcendence_depth(a)
        case Exp(a) | Log(a):
            return 1 + transcendence_depth(a)
        case EML(a, b):
            # eml(a, b) = exp(a) - log(b), depth = 1 + max(depth(a), depth(b))
            return 1 + max(transcendence_depth(a), transcendence_depth(b))
    raise TypeError(f"Unknown expression type: {type(expr)}")


def verify_depth_preservation(expr: Expr) -> tuple[int, int, bool]:
    """
    Verify that differentiation preserves transcendence depth.
    Returns (original_depth, derivative_depth, preserved).
    """
    d = transcendence_depth(expr)
    deriv = differentiate(expr)
    d_deriv = transcendence_depth(deriv)
    return d, d_deriv, d_deriv <= d


# ============================================================
# Expression Size
# ============================================================

def expr_size(expr: Expr) -> int:
    """Count nodes in the expression tree."""
    match expr:
        case Const(_) | Var():
            return 1
        case Add(a, b) | Mul(a, b) | Sub(a, b) | Div(a, b) | EML(a, b):
            return 1 + expr_size(a) + expr_size(b)
        case Neg(a) | Inv(a) | Exp(a) | Log(a):
            return 1 + expr_size(a)
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Pretty Printing
# ============================================================

def pretty(expr: Expr) -> str:
    """Pretty-print an EML expression."""
    match expr:
        case Const(c):
            return f"{c}"
        case Var():
            return "x"
        case Add(a, b):
            return f"({pretty(a)} + {pretty(b)})"
        case Sub(a, b):
            return f"({pretty(a)} - {pretty(b)})"
        case Mul(a, b):
            return f"({pretty(a)} * {pretty(b)})"
        case Div(a, b):
            return f"({pretty(a)} / {pretty(b)})"
        case Neg(a):
            return f"(-{pretty(a)})"
        case Inv(a):
            return f"(1/{pretty(a)})"
        case Exp(a):
            return f"exp({pretty(a)})"
        case Log(a):
            return f"log({pretty(a)})"
        case EML(a, b):
            return f"eml({pretty(a)}, {pretty(b)})"
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("EML SYMBOLIC DIFFERENTIATION ENGINE")
    print("=" * 60)
    
    # Example 1: eml(x, exp(x)) = exp(x) - x
    print("\n--- Example 1: eml(x, exp(x)) ---")
    e1 = EML(Var(), Exp(Var()))
    d1 = differentiate(e1)
    print(f"  Expression: {pretty(e1)}")
    print(f"  Derivative: {pretty(d1)}")
    print(f"  Depth: {transcendence_depth(e1)} → {transcendence_depth(d1)}")
    for x in [0, 1, 2]:
        print(f"  f({x}) = {evaluate(e1, x):.4f}, f'({x}) = {evaluate(d1, x):.4f}")
    
    # Example 2: eml(x², 1) = exp(x²)
    print("\n--- Example 2: eml(x², 1) ---")
    e2 = EML(Mul(Var(), Var()), Const(1))
    d2 = differentiate(e2)
    print(f"  Expression: {pretty(e2)}")
    print(f"  Derivative: {pretty(d2)}")
    print(f"  Depth: {transcendence_depth(e2)} → {transcendence_depth(d2)}")
    
    # Example 3: Iterated exp: exp(exp(x))
    print("\n--- Example 3: exp(exp(x)) = eml(eml(x, 1), 1) ---")
    e3 = EML(EML(Var(), Const(1)), Const(1))
    d3 = differentiate(e3)
    print(f"  Expression: {pretty(e3)}")
    print(f"  Derivative: {pretty(d3)}")
    depth_orig, depth_deriv, preserved = verify_depth_preservation(e3)
    print(f"  Depth: {depth_orig} → {depth_deriv}, preserved: {preserved}")
    
    # Example 4: Diagonal eml(x, x) = exp(x) - log(x)
    print("\n--- Example 4: Diagonal eml(x, x) ---")
    e4 = EML(Var(), Var())
    d4 = differentiate(e4)
    d4d = differentiate(d4)
    print(f"  f(x)   = {pretty(e4)}")
    print(f"  f'(x)  = {pretty(d4)}")
    print(f"  f''(x) = {pretty(d4d)}")
    print(f"  Depth: {transcendence_depth(e4)} → {transcendence_depth(d4)} → {transcendence_depth(d4d)}")
    
    # Depth preservation verification
    print("\n--- Depth Preservation Verification ---")
    test_exprs = [
        ("x", Var()),
        ("exp(x)", Exp(Var())),
        ("log(x)", Log(Var())),
        ("exp(exp(x))", Exp(Exp(Var()))),
        ("eml(x, x)", EML(Var(), Var())),
        ("x*exp(x)", Mul(Var(), Exp(Var()))),
    ]
    for name, expr in test_exprs:
        d_orig, d_deriv, ok = verify_depth_preservation(expr)
        print(f"  {name:20s}: depth {d_orig} → {d_deriv}  {'✓' if ok else '✗'}")
    
    print("\n" + "=" * 60)
