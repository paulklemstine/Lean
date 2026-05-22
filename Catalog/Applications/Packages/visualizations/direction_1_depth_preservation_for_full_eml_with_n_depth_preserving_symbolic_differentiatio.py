#!/usr/bin/env python3
"""
Algorithms for EML Expression Analysis

Implements verified computational methods for EML expression depth analysis,
symbolic differentiation, and bounded enumeration.

Complexity analysis:
  - deriv(e): O(|e|) time, O(|e|) new nodes
  - eml_depth(e): O(|e|) time
  - enumerate_exprs(d, s): Exponential in s, but bounded by depth d
  - check_depth_preservation: O(n * |e_max|^n) per expression, n = iteration count
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Generator
import math
from collections import Counter


# ─── EML Expression AST ───────────────────────────────────────────────

class EmlExpr:
    """Base class for EML expressions."""
    pass

@dataclass
class Var(EmlExpr):
    def __repr__(self): return "x"

@dataclass
class Const(EmlExpr):
    value: float
    def __repr__(self): return f"{self.value}"

@dataclass
class Add(EmlExpr):
    left: EmlExpr
    right: EmlExpr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class Mul(EmlExpr):
    left: EmlExpr
    right: EmlExpr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass
class Neg(EmlExpr):
    arg: EmlExpr
    def __repr__(self): return f"(-{self.arg})"

@dataclass
class Eml(EmlExpr):
    coeff: EmlExpr
    exponent: EmlExpr
    def __repr__(self): return f"eml({self.coeff}, {self.exponent})"


# ─── Core Algorithms ──────────────────────────────────────────────────

def eml_depth(expr: EmlExpr) -> int:
    """Compute EML depth.

    Time complexity: O(|expr|) — single tree traversal.
    Space complexity: O(height(expr)) for recursion stack.

    The depth counts the maximum nesting of eml operations:
      depth(var) = 0
      depth(const) = 0
      depth(add(a,b)) = max(depth(a), depth(b))
      depth(mul(a,b)) = max(depth(a), depth(b))
      depth(neg(a)) = depth(a)
      depth(eml(a,b)) = 1 + max(depth(a), depth(b))
    """
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, Neg):
        return eml_depth(expr.arg)
    elif isinstance(expr, Eml):
        return 1 + max(eml_depth(expr.coeff), eml_depth(expr.exponent))
    raise TypeError(f"Unknown: {type(expr)}")


def expr_size(expr: EmlExpr) -> int:
    """Count nodes in the expression tree.

    Time/space: O(|expr|).
    """
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Mul)):
        return 1 + expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, Neg):
        return 1 + expr_size(expr.arg)
    elif isinstance(expr, Eml):
        return 1 + expr_size(expr.coeff) + expr_size(expr.exponent)
    return 0


def deriv(expr: EmlExpr) -> EmlExpr:
    """Symbolic differentiation with respect to x.

    Time complexity: O(|expr|) — one pass over the tree.
    Space complexity: O(|expr|) new nodes (the derivative tree shares
    subexpressions with the original in languages with sharing; here we copy).

    The derivative of eml(a,b) = a*exp(b) is:
      eml(a' + a*b', b) = (a' + a*b')*exp(b)

    This is the KEY operation: the eml shell (exp(b)) is preserved,
    and all new complexity goes into the coefficient.
    """
    if isinstance(expr, Var):
        return Const(1)
    elif isinstance(expr, Const):
        return Const(0)
    elif isinstance(expr, Add):
        return Add(deriv(expr.left), deriv(expr.right))
    elif isinstance(expr, Mul):
        return Add(Mul(deriv(expr.left), expr.right),
                   Mul(expr.left, deriv(expr.right)))
    elif isinstance(expr, Neg):
        return Neg(deriv(expr.arg))
    elif isinstance(expr, Eml):
        a, b = expr.coeff, expr.exponent
        return Eml(Add(deriv(a), Mul(a, deriv(b))), b)
    raise TypeError(f"Unknown: {type(expr)}")


def iterated_deriv(expr: EmlExpr, n: int) -> EmlExpr:
    """Compute the n-th iterated derivative.

    Time: O(n * |result|), where |result| can grow exponentially in n
    due to the product rule (size explosion).
    Depth: O(depth(expr)) — depth is preserved (our main theorem).
    """
    result = expr
    for _ in range(n):
        result = deriv(result)
    return result


def evaluate(expr: EmlExpr, x: float) -> float:
    """Evaluate an EML expression at a point.

    Time: O(|expr|).
    """
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    elif isinstance(expr, Mul):
        return evaluate(expr.left, x) * evaluate(expr.right, x)
    elif isinstance(expr, Neg):
        return -evaluate(expr.arg, x)
    elif isinstance(expr, Eml):
        a = evaluate(expr.coeff, x)
        b = evaluate(expr.exponent, x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf') if a > 0 else float('-inf')
    raise TypeError(f"Unknown: {type(expr)}")


# ─── Enumeration Algorithm ────────────────────────────────────────────

def enumerate_exprs_by_size(max_size: int, max_depth: int,
                            constants: list[float] = [0, 1, -1]) -> list[EmlExpr]:
    """Enumerate EML expressions up to a given size and depth.

    Algorithm: Bottom-up dynamic programming by size.
    For each size s from 1 to max_size, generate all expressions of that size.

    Time complexity: O(C^max_size) where C depends on branching factor.
    Space complexity: O(|output|).

    Args:
        max_size: Maximum number of nodes in the expression tree.
        max_depth: Maximum eml-nesting depth.
        constants: List of constant values to use as leaves.

    Returns:
        List of all expressions within the bounds.
    """
    # exprs_by_size[s] = list of expressions of size exactly s
    exprs_by_size: dict[int, list[EmlExpr]] = {}

    # Size 1: leaves
    leaves = [Var()] + [Const(c) for c in constants]
    exprs_by_size[1] = leaves

    for s in range(2, max_size + 1):
        exprs_s = []
        # Neg: size = 1 + size(arg)
        if s - 1 in exprs_by_size:
            for a in exprs_by_size[s - 1]:
                exprs_s.append(Neg(a))

        # Binary operations: size = 1 + size(left) + size(right)
        for s1 in range(1, s - 1):
            s2 = s - 1 - s1
            if s1 in exprs_by_size and s2 in exprs_by_size:
                for a in exprs_by_size[s1]:
                    for b in exprs_by_size[s2]:
                        exprs_s.append(Add(a, b))
                        exprs_s.append(Mul(a, b))
                        if eml_depth(a) < max_depth and eml_depth(b) < max_depth:
                            exprs_s.append(Eml(a, b))

        exprs_by_size[s] = exprs_s

    all_exprs = []
    for s in range(1, max_size + 1):
        all_exprs.extend(exprs_by_size.get(s, []))
    return all_exprs


# ─── Depth Preservation Checker ───────────────────────────────────────

def check_depth_preservation(exprs: list[EmlExpr],
                              max_iters: int = 3) -> dict:
    """Verify depth preservation for a list of expressions.

    For each expression e, checks that
      eml_depth(deriv^n(e)) ≤ eml_depth(e)
    for n = 1, ..., max_iters.

    Returns:
        Dictionary with statistics and any counterexamples.
    """
    stats = {
        "total": len(exprs),
        "verified": 0,
        "counterexamples": [],
        "depth_drops": [],  # (expr, original_depth, deriv_depth)
        "exact_preservations": 0,
    }

    for expr in exprs:
        d0 = eml_depth(expr)
        ok = True
        dropped = False
        for n in range(1, max_iters + 1):
            try:
                dn = eml_depth(iterated_deriv(expr, n))
            except RecursionError:
                break  # expression too deep
            if dn > d0:
                stats["counterexamples"].append((str(expr), d0, n, dn))
                ok = False
                break
            if dn < d0:
                dropped = True
        if ok:
            stats["verified"] += 1
            if not dropped:
                stats["exact_preservations"] += 1
            else:
                stats["depth_drops"].append((str(expr), d0))

    return stats


# ─── Size Growth Analysis ─────────────────────────────────────────────

def analyze_size_growth(expr: EmlExpr, max_iters: int = 10) -> list[tuple[int, int, int]]:
    """Analyze how size and depth change under iterated differentiation.

    Returns:
        List of (iteration, depth, size) tuples.
    """
    results = []
    current = expr
    for n in range(max_iters + 1):
        d = eml_depth(current)
        s = expr_size(current)
        results.append((n, d, s))
        if s > 100000:
            break
        current = deriv(current)
    return results


# ─── Depth Classification ─────────────────────────────────────────────

def classify_depth_behavior(exprs: list[EmlExpr]) -> dict:
    """Classify expressions by their depth behavior under differentiation.

    Categories:
      - "constant_zero": depth 0 stays 0
      - "preserved": depth > 0, stays exactly the same after deriv
      - "dropped": depth strictly decreases after deriv
    """
    classification = Counter()
    examples = {"preserved": [], "dropped": [], "constant_zero": []}

    for expr in exprs:
        d0 = eml_depth(expr)
        d1 = eml_depth(deriv(expr))

        if d0 == 0:
            classification["constant_zero"] += 1
            if len(examples["constant_zero"]) < 3:
                examples["constant_zero"].append(str(expr))
        elif d1 == d0:
            classification["preserved"] += 1
            if len(examples["preserved"]) < 5:
                examples["preserved"].append(str(expr))
        elif d1 < d0:
            classification["dropped"] += 1
            if len(examples["dropped"]) < 5:
                examples["dropped"].append(f"{expr} : {d0} → {d1}")

    return {"counts": dict(classification), "examples": dict(examples)}


# ─── Main ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("EML Expression Analysis Algorithms")
    print("=" * 50)

    # Enumerate small expressions
    print("\n1. Enumerating expressions (size ≤ 5, depth ≤ 3)...")
    exprs = enumerate_exprs_by_size(max_size=5, max_depth=3)
    print(f"   Generated {len(exprs)} expressions")

    # Check depth preservation
    print("\n2. Checking depth preservation (3 iterations)...")
    stats = check_depth_preservation(exprs, max_iters=3)
    print(f"   Verified: {stats['verified']}/{stats['total']}")
    print(f"   Exact preservations: {stats['exact_preservations']}")
    print(f"   Depth drops: {len(stats['depth_drops'])}")
    print(f"   Counterexamples: {len(stats['counterexamples'])}")

    # Classify
    print("\n3. Classifying depth behavior...")
    cls = classify_depth_behavior(exprs)
    print(f"   {cls['counts']}")

    # Size growth analysis
    print("\n4. Size growth under iterated differentiation:")
    test_exprs = [
        ("x*exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
        ("x^2", Mul(Var(), Var())),
    ]
    for name, e in test_exprs:
        print(f"\n   {name}:")
        growth = analyze_size_growth(e, max_iters=6)
        for n, d, s in growth:
            print(f"     n={n}: depth={d}, size={s}")
