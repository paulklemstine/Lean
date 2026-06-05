#!/usr/bin/env python3
"""
EML Differential Algebra — Core Algorithms

Type-hinted implementations of the EML Derivation Calculus operations:
symbolic differentiation, evaluation, simplification, and derivation tower analysis.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union
import math


# ============================================================
# Expression AST
# ============================================================

@dataclass(frozen=True)
class Cnst:
    """Constant expression."""
    c: float

@dataclass(frozen=True)
class Var:
    """Variable x."""
    pass

@dataclass(frozen=True)
class Add:
    """Pointwise addition."""
    e1: Expr
    e2: Expr

@dataclass(frozen=True)
class Mul:
    """Pointwise multiplication."""
    e1: Expr
    e2: Expr

@dataclass(frozen=True)
class Neg:
    """Pointwise negation."""
    e: Expr

@dataclass(frozen=True)
class Inv:
    """Pointwise reciprocal."""
    e: Expr

@dataclass(frozen=True)
class Eexp:
    """Exponential composition."""
    e: Expr

@dataclass(frozen=True)
class Elog:
    """Logarithmic composition."""
    e: Expr

Expr = Union[Cnst, Var, Add, Mul, Neg, Inv, Eexp, Elog]


# ============================================================
# Algorithm 1: Symbolic Differentiation
# ============================================================

def symbolic_differentiate(e: Expr) -> Expr:
    """
    Compute the symbolic derivative of an EML expression.

    Implements the standard differentiation rules:
    - d/dx[c] = 0
    - d/dx[x] = 1
    - d/dx[f+g] = f' + g'  (sum rule)
    - d/dx[f*g] = f'*g + f*g'  (product rule)
    - d/dx[-f] = -f'
    - d/dx[1/f] = -f'/f²  (reciprocal rule)
    - d/dx[exp(f)] = f'*exp(f)  (chain rule)
    - d/dx[log(f)] = f'/f  (chain rule)

    Returns a new Expr representing the derivative.
    Time complexity: O(size(e))
    Space complexity: O(size(e)) for the output (which may be larger)
    """
    match e:
        case Cnst(_):
            return Cnst(0.0)
        case Var():
            return Cnst(1.0)
        case Add(e1, e2):
            return Add(symbolic_differentiate(e1), symbolic_differentiate(e2))
        case Mul(e1, e2):
            return Add(
                Mul(symbolic_differentiate(e1), e2),
                Mul(e1, symbolic_differentiate(e2))
            )
        case Neg(inner):
            return Neg(symbolic_differentiate(inner))
        case Inv(inner):
            # d/dx[1/f] = -f' * (1/f)² = -f'/(f²)
            return Neg(Mul(
                symbolic_differentiate(inner),
                Mul(Inv(inner), Inv(inner))
            ))
        case Eexp(inner):
            # d/dx[exp(f)] = f' * exp(f)
            return Mul(symbolic_differentiate(inner), Eexp(inner))
        case Elog(inner):
            # d/dx[log(f)] = f'/f
            return Mul(symbolic_differentiate(inner), Inv(inner))
        case _:
            raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Algorithm 2: Semantic Evaluation
# ============================================================

def evaluate(e: Expr, x: float) -> float:
    """
    Evaluate an EML expression at a given point.

    Time complexity: O(size(e))
    Raises ValueError for invalid operations (log of non-positive, division by zero).
    """
    match e:
        case Cnst(c):
            return c
        case Var():
            return x
        case Add(e1, e2):
            return evaluate(e1, x) + evaluate(e2, x)
        case Mul(e1, e2):
            return evaluate(e1, x) * evaluate(e2, x)
        case Neg(inner):
            return -evaluate(inner, x)
        case Inv(inner):
            val = evaluate(inner, x)
            if val == 0:
                raise ValueError("Division by zero in Inv")
            return 1.0 / val
        case Eexp(inner):
            return math.exp(evaluate(inner, x))
        case Elog(inner):
            val = evaluate(inner, x)
            if val <= 0:
                raise ValueError(f"Log of non-positive value: {val}")
            return math.log(val)
        case _:
            raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Algorithm 3: Expression Simplification
# ============================================================

def simplify(e: Expr) -> Expr:
    """
    Simplify an EML expression by applying algebraic identities:
    - 0 + e → e, e + 0 → e
    - 0 * e → 0, e * 0 → 0
    - 1 * e → e, e * 1 → e
    - -(-e) → e
    - neg(0) → 0

    This is a single-pass bottom-up simplification.
    Time complexity: O(size(e))
    """
    match e:
        case Cnst(_) | Var():
            return e
        case Add(e1, e2):
            s1, s2 = simplify(e1), simplify(e2)
            if isinstance(s1, Cnst) and s1.c == 0: return s2
            if isinstance(s2, Cnst) and s2.c == 0: return s1
            if isinstance(s1, Cnst) and isinstance(s2, Cnst):
                return Cnst(s1.c + s2.c)
            return Add(s1, s2)
        case Mul(e1, e2):
            s1, s2 = simplify(e1), simplify(e2)
            if isinstance(s1, Cnst) and s1.c == 0: return Cnst(0.0)
            if isinstance(s2, Cnst) and s2.c == 0: return Cnst(0.0)
            if isinstance(s1, Cnst) and s1.c == 1: return s2
            if isinstance(s2, Cnst) and s2.c == 1: return s1
            if isinstance(s1, Cnst) and isinstance(s2, Cnst):
                return Cnst(s1.c * s2.c)
            return Mul(s1, s2)
        case Neg(inner):
            s = simplify(inner)
            if isinstance(s, Cnst): return Cnst(-s.c)
            if isinstance(s, Neg): return s.e
            return Neg(s)
        case Inv(inner):
            s = simplify(inner)
            if isinstance(s, Cnst) and s.c != 0:
                return Cnst(1.0 / s.c)
            return Inv(s)
        case Eexp(inner):
            return Eexp(simplify(inner))
        case Elog(inner):
            return Elog(simplify(inner))
        case _:
            return e


# ============================================================
# Algorithm 4: Expression Size Analysis
# ============================================================

def expr_size(e: Expr) -> int:
    """Count nodes in an expression tree."""
    match e:
        case Cnst(_) | Var():
            return 1
        case Add(e1, e2) | Mul(e1, e2):
            return 1 + expr_size(e1) + expr_size(e2)
        case Neg(inner) | Inv(inner) | Eexp(inner) | Elog(inner):
            return 1 + expr_size(inner)
        case _:
            raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Algorithm 5: Derivation Tower
# ============================================================

def derivation_tower(e: Expr, depth: int, simplify_each: bool = False) -> list[Expr]:
    """
    Compute the derivation tower of an expression to a given depth.

    The derivation tower is the sequence [e, sdiff(e), sdiff²(e), ...].

    Args:
        e: The base expression
        depth: Number of derivatives to compute
        simplify_each: If True, simplify after each differentiation step

    Returns:
        List of expressions [e, sdiff(e), ..., sdiff^depth(e)]
    """
    tower: list[Expr] = [e]
    current = e
    for _ in range(depth):
        current = symbolic_differentiate(current)
        if simplify_each:
            current = simplify(current)
        tower.append(current)
    return tower


def tower_size_profile(e: Expr, depth: int, simplify_each: bool = False) -> list[int]:
    """
    Compute the size profile of a derivation tower.

    Returns list of sizes [size(e), size(sdiff(e)), ...].
    """
    tower = derivation_tower(e, depth, simplify_each)
    return [expr_size(t) for t in tower]


# ============================================================
# Algorithm 6: Validity Checker
# ============================================================

def is_valid_at(e: Expr, x: float) -> bool:
    """
    Check if an expression is valid at a given point.

    An expression is valid if all Inv and Elog subexpressions
    have nonzero arguments at x.
    """
    match e:
        case Cnst(_) | Var():
            return True
        case Add(e1, e2) | Mul(e1, e2):
            return is_valid_at(e1, x) and is_valid_at(e2, x)
        case Neg(inner) | Eexp(inner):
            return is_valid_at(inner, x)
        case Inv(inner):
            return is_valid_at(inner, x) and evaluate(inner, x) != 0
        case Elog(inner):
            return is_valid_at(inner, x) and evaluate(inner, x) != 0
        case _:
            raise TypeError(f"Unknown expression type: {type(e)}")


def has_no_inv_log(e: Expr) -> bool:
    """Check if an expression is in the inv/log-free fragment."""
    match e:
        case Cnst(_) | Var():
            return True
        case Add(e1, e2) | Mul(e1, e2):
            return has_no_inv_log(e1) and has_no_inv_log(e2)
        case Neg(inner) | Eexp(inner):
            return has_no_inv_log(inner)
        case Inv(_) | Elog(_):
            return False
        case _:
            raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Example: Verify the exponential fixed point
    exp_x = Eexp(Var())
    tower = derivation_tower(exp_x, 5)
    print("Derivation tower of exp(x) at x=1:")
    for i, e in enumerate(tower):
        val = evaluate(e, 1.0)
        sz = expr_size(e)
        print(f"  n={i}: eval={val:.6f} (e={math.e:.6f}), size={sz}")

    # Example: Size growth analysis
    print("\nSize growth profiles:")
    for name, expr in [("exp(x)", Eexp(Var())),
                        ("x*x", Mul(Var(), Var())),
                        ("1/x", Inv(Var()))]:
        sizes = tower_size_profile(expr, 5)
        print(f"  {name}: {sizes}")

    # Example: Simplification impact
    print("\nSimplification impact on exp(x) tower:")
    raw_sizes = tower_size_profile(Eexp(Var()), 5, simplify_each=False)
    simp_sizes = tower_size_profile(Eexp(Var()), 5, simplify_each=True)
    print(f"  Raw:        {raw_sizes}")
    print(f"  Simplified: {simp_sizes}")
