#!/usr/bin/env python3
"""
Algorithms for PosEMLExpr Depth Analysis

Implements the core algorithms from the research paper:
1. Symbolic differentiation with depth tracking
2. Expression depth computation
3. Depth-gap analysis
4. Iterative derivative normalizer
5. Branch complexity computation

All algorithms mirror the formally verified Lean definitions.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum, auto
import math


# ─── Core AST ────────────────────────────────────────────────────────────

class Tag(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    EXP = auto()


@dataclass(frozen=True)
class Expr:
    """PosEMLExpr: positive EML expression fragment.

    Grammar:
      e ::= c | x | e + e | e * e | exp(e)

    This exactly mirrors the Lean inductive type PosEMLExpr.
    """
    tag: Tag
    val: float = 0.0
    left: Optional["Expr"] = None
    right: Optional["Expr"] = None

    def __repr__(self):
        if self.tag == Tag.CONST:
            return f"{self.val}"
        if self.tag == Tag.VAR:
            return "x"
        if self.tag == Tag.ADD:
            return f"({self.left} + {self.right})"
        if self.tag == Tag.MUL:
            return f"({self.left} * {self.right})"
        if self.tag == Tag.EXP:
            return f"exp({self.left})"
        return "?"


# Constructors
C = lambda v=1.0: Expr(Tag.CONST, val=v)
X = Expr(Tag.VAR)
Add = lambda a, b: Expr(Tag.ADD, left=a, right=b)
Mul = lambda a, b: Expr(Tag.MUL, left=a, right=b)
Exp = lambda a: Expr(Tag.EXP, left=a)


# ─── Algorithm 1: Depth Computation ─────────────────────────────────────

def depth(e: Expr) -> int:
    """Compute the depth (max exp-nesting) of an expression.

    Time complexity: O(|e|) where |e| is the number of nodes.
    Space complexity: O(h) where h is the tree height (stack depth).

    Mirrors Lean definition:
      def depth : PosEMLExpr → ℕ
        | .const _ => 0
        | .var => 0
        | .add a b => max a.depth b.depth
        | .mul a b => max a.depth b.depth
        | .exp a => a.depth + 1
    """
    if e.tag in (Tag.CONST, Tag.VAR):
        return 0
    if e.tag in (Tag.ADD, Tag.MUL):
        return max(depth(e.left), depth(e.right))
    if e.tag == Tag.EXP:
        return depth(e.left) + 1
    return 0


# ─── Algorithm 2: Symbolic Differentiation ──────────────────────────────

def deriv(e: Expr) -> Expr:
    """Symbolic differentiation with respect to x.

    Time complexity: O(|e|) (each node produces O(1) new nodes).
    Space complexity: The output can be up to O(|e|^2) in size due to
    the product rule duplicating subexpressions, but depth is preserved.

    Mirrors Lean definition:
      def deriv : PosEMLExpr → PosEMLExpr
        | .const _ => .const 0
        | .var => .const 1
        | .add a b => .add a.deriv b.deriv
        | .mul a b => .add (.mul a.deriv b) (.mul a b.deriv)
        | .exp a => .mul a.deriv (.exp a)
    """
    if e.tag == Tag.CONST:
        return C(0)
    if e.tag == Tag.VAR:
        return C(1)
    if e.tag == Tag.ADD:
        return Add(deriv(e.left), deriv(e.right))
    if e.tag == Tag.MUL:
        return Add(Mul(deriv(e.left), e.right), Mul(e.left, deriv(e.right)))
    if e.tag == Tag.EXP:
        return Mul(deriv(e.left), Exp(e.left))
    return C(0)


# ─── Algorithm 3: Evaluation ────────────────────────────────────────────

def evaluate(e: Expr, x: float) -> float:
    """Evaluate expression at a point.

    Time complexity: O(|e|)
    """
    if e.tag == Tag.CONST:
        return e.val
    if e.tag == Tag.VAR:
        return x
    if e.tag == Tag.ADD:
        return evaluate(e.left, x) + evaluate(e.right, x)
    if e.tag == Tag.MUL:
        return evaluate(e.left, x) * evaluate(e.right, x)
    if e.tag == Tag.EXP:
        v = evaluate(e.left, x)
        if v > 700:  # overflow protection
            return float('inf')
        return math.exp(v)
    return 0.0


# ─── Algorithm 4: Branch Complexity ─────────────────────────────────────

def branch_complexity(e: Expr) -> int:
    """Compute the derivative branching complexity.

    Counts mul nodes whose children both have depth equal to the node's depth.
    This was hypothesized to be the source of depth increase under differentiation.
    The theorem shows it is irrelevant: depth never increases regardless.

    Time complexity: O(|e|)
    """
    if e.tag in (Tag.CONST, Tag.VAR):
        return 0
    if e.tag == Tag.ADD:
        return branch_complexity(e.left) + branch_complexity(e.right)
    if e.tag == Tag.MUL:
        base = branch_complexity(e.left) + branch_complexity(e.right)
        dl = depth(e.left)
        dr = depth(e.right)
        m = max(dl, dr)
        if dl == m and dr == m:
            return base + 1
        return base
    if e.tag == Tag.EXP:
        return branch_complexity(e.left)
    return 0


# ─── Algorithm 5: Expression Size ───────────────────────────────────────

def size(e: Expr) -> int:
    """Count the number of nodes in an expression tree.

    Time complexity: O(|e|)
    """
    if e.tag in (Tag.CONST, Tag.VAR):
        return 1
    if e.tag in (Tag.ADD, Tag.MUL):
        return 1 + size(e.left) + size(e.right)
    if e.tag == Tag.EXP:
        return 1 + size(e.left)
    return 1


# ─── Algorithm 6: Iterated Differentiation ──────────────────────────────

def iter_deriv(n: int, e: Expr) -> Expr:
    """Apply symbolic differentiation n times.

    Time complexity: O(|e|^(2^n)) in the worst case for size,
    but depth is bounded by depth(e) for all n.
    """
    result = e
    for _ in range(n):
        result = deriv(result)
    return result


# ─── Algorithm 7: Depth Gap Profiler ────────────────────────────────────

def depth_gap_profile(exprs: list[Expr]) -> dict[int, list[tuple[int, Expr]]]:
    """Profile the depth gap for a collection of expressions.

    Returns: dict mapping depth to list of (gap, expr) pairs.
    """
    profile: dict[int, list[tuple[int, Expr]]] = {}
    for e in exprs:
        d = depth(e)
        gap = depth(deriv(e)) - d
        if d not in profile:
            profile[d] = []
        profile[d].append((gap, e))
    return profile


# ─── Algorithm 8: Depth Preservation Verifier ───────────────────────────

def verify_depth_preservation(e: Expr, num_derivs: int = 5) -> bool:
    """Verify that depth(d^k/dx^k e) ≤ depth(e) for k = 0, ..., num_derivs.

    This is a computational check of the theorem depth_iterDeriv_le.
    Returns True if the property holds for all tested derivatives.
    """
    d0 = depth(e)
    current = e
    for k in range(num_derivs):
        current = deriv(current)
        if depth(current) > d0:
            return False
    return True


# ─── Algorithm 9: Expression Normalizer (Simplifier) ────────────────────

def simplify(e: Expr) -> Expr:
    """Basic expression simplifier.

    Applies rules:
    - 0 + e = e, e + 0 = e
    - 0 * e = 0, e * 0 = 0
    - 1 * e = e, e * 1 = e
    - const + const = const
    - const * const = const

    Note: Even without simplification, depth is preserved.
    Simplification reduces size but does not affect the depth bound.

    Time complexity: O(|e|)
    """
    if e.tag in (Tag.CONST, Tag.VAR):
        return e

    if e.tag == Tag.EXP:
        inner = simplify(e.left)
        return Exp(inner)

    if e.tag == Tag.ADD:
        l = simplify(e.left)
        r = simplify(e.right)
        # 0 + e = e
        if l.tag == Tag.CONST and l.val == 0:
            return r
        # e + 0 = e
        if r.tag == Tag.CONST and r.val == 0:
            return l
        # const + const
        if l.tag == Tag.CONST and r.tag == Tag.CONST:
            return C(l.val + r.val)
        return Add(l, r)

    if e.tag == Tag.MUL:
        l = simplify(e.left)
        r = simplify(e.right)
        # 0 * e = 0
        if l.tag == Tag.CONST and l.val == 0:
            return C(0)
        # e * 0 = 0
        if r.tag == Tag.CONST and r.val == 0:
            return C(0)
        # 1 * e = e
        if l.tag == Tag.CONST and l.val == 1:
            return r
        # e * 1 = e
        if r.tag == Tag.CONST and r.val == 1:
            return l
        # const * const
        if l.tag == Tag.CONST and r.tag == Tag.CONST:
            return C(l.val * r.val)
        return Mul(l, r)

    return e


def simplified_deriv(e: Expr) -> Expr:
    """Differentiate and then simplify."""
    return simplify(deriv(e))


# ─── Demo / Testing ─────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm demonstrations")
    print("=" * 60)

    # Test expressions
    test_exprs = [
        ("x", X),
        ("x*x", Mul(X, X)),
        ("exp(x)", Exp(X)),
        ("exp(exp(x))", Exp(Exp(X))),
        ("exp(x)*exp(x)", Mul(Exp(X), Exp(X))),
        ("exp(exp(exp(x)))", Exp(Exp(Exp(X)))),
    ]

    print("\nDepth and derivative analysis:")
    print(f"{'Expression':<25} {'depth':>6} {'d(deriv)':>8} {'gap':>5} "
          f"{'size':>5} {'d_size':>7} {'branch':>7}")
    print("-" * 75)

    for name, e in test_exprs:
        de = deriv(e)
        sde = simplified_deriv(e)
        print(f"{name:<25} {depth(e):>6} {depth(de):>8} "
              f"{depth(de)-depth(e):>5} {size(e):>5} {size(de):>7} "
              f"{branch_complexity(e):>7}")

    print("\nSimplified derivative sizes:")
    for name, e in test_exprs:
        de = deriv(e)
        sde = simplified_deriv(e)
        print(f"  {name}: raw size {size(de)}, simplified size {size(sde)}, "
              f"depth preserved: {depth(sde) <= depth(e)}")

    print("\nIterated derivative depth preservation:")
    for name, e in test_exprs:
        passed = verify_depth_preservation(e, num_derivs=4)
        print(f"  {name}: {'✓ PASS' if passed else '✗ FAIL'}")

    print("\nAll tests demonstrate depth(deriv(e)) ≤ depth(e).")
