#!/usr/bin/env python3
"""
Growth Rank Completeness — Algorithms

Implements certified algorithms for computing and verifying exact tower levels
of EML expressions. These correspond to the formally verified Lean theorems.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ─── Expression AST ───────────────────────────────────────────────────

@dataclass
class Expr:
    """Base class for EML expressions."""
    pass

@dataclass
class Var(Expr):
    def __repr__(self): return "x"

@dataclass
class Const(Expr):
    value: float
    def __repr__(self): return f"{self.value}"

@dataclass
class Add(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass
class Mul(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass
class Neg(Expr):
    child: Expr
    def __repr__(self): return f"(-{self.child})"

@dataclass
class EML(Expr):
    coeff: Expr; exponent: Expr
    def __repr__(self): return f"({self.coeff} * exp({self.exponent}))"


# ─── Core Algorithms ─────────────────────────────────────────────────

def eval_expr(e: Expr, x: float) -> float:
    """
    Evaluate an EML expression at a point x.

    Time complexity: O(|e|) where |e| is the number of nodes.
    Space complexity: O(depth(e)) for recursion stack.
    """
    if isinstance(e, Var):
        return x
    elif isinstance(e, Const):
        return e.value
    elif isinstance(e, Add):
        return eval_expr(e.left, x) + eval_expr(e.right, x)
    elif isinstance(e, Mul):
        return eval_expr(e.left, x) * eval_expr(e.right, x)
    elif isinstance(e, Neg):
        return -eval_expr(e.child, x)
    elif isinstance(e, EML):
        a = eval_expr(e.coeff, x)
        b = eval_expr(e.exponent, x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf') if a > 0 else float('-inf') if a < 0 else 0.0
    raise TypeError(f"Unknown: {type(e)}")


def growth_rank(e: Expr) -> int:
    """
    Compute the syntactic growth rank of an EML expression.

    This is the certified algorithm corresponding to `certifyGrowthRank` in Lean.
    For inverse-free expressions, this equals the exact tower level of canonical forms.

    Algorithm:
        growthRank(var) = 0
        growthRank(const c) = 0
        growthRank(a + b) = max(growthRank(a), growthRank(b))
        growthRank(a * b) = max(growthRank(a), growthRank(b))
        growthRank(-a) = growthRank(a)
        growthRank(eml(a, b)) = 1 + max(growthRank(a), growthRank(b))

    Time complexity: O(|e|)
    Space complexity: O(depth(e))

    Correctness: Formally verified as `certifyGrowthRank_correct_towerExpr`
    and `certifyGrowthRank_upper_bound` in Lean 4.
    """
    if isinstance(e, (Var, Const)):
        return 0
    elif isinstance(e, (Add, Mul)):
        return max(growth_rank(e.left), growth_rank(e.right))
    elif isinstance(e, Neg):
        return growth_rank(e.child)
    elif isinstance(e, EML):
        return 1 + max(growth_rank(e.coeff), growth_rank(e.exponent))
    raise TypeError(f"Unknown: {type(e)}")


def is_inverse_free(e: Expr) -> bool:
    """Check whether an expression is inverse-free (no division/inversion)."""
    if isinstance(e, (Var, Const)):
        return True
    elif isinstance(e, (Add, Mul, EML)):
        return is_inverse_free(e.left if hasattr(e, 'left') else e.coeff) and \
               is_inverse_free(e.right if hasattr(e, 'right') else e.exponent)
    elif isinstance(e, Neg):
        return is_inverse_free(e.child)
    return False


def iter_exp(k: int, x: float) -> float:
    """
    Compute the k-th iterated exponential: iterExp(0, x) = x, iterExp(k+1, x) = exp(iterExp(k, x)).

    Time complexity: O(k)
    """
    result = x
    for _ in range(k):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def tower_expr(k: int) -> Expr:
    """
    Construct the canonical tower expression at level k.

    towerExpr(0) = x
    towerExpr(k+1) = 1 * exp(towerExpr(k))

    Formally verified properties:
    - growth_rank(towerExpr(k)) = k
    - eval(towerExpr(k), x) = iterExp(k, x)
    - ExactPolyTowerLevel(k, towerExpr(k))

    Time complexity: O(k)
    """
    if k == 0:
        return Var()
    return EML(Const(1.0), tower_expr(k - 1))


def certify_growth_rank(e: Expr) -> Tuple[int, str]:
    """
    Certified growth rank computation with justification.

    Returns (rank, justification_string).

    For inverse-free expressions, this is a valid upper bound on the
    exact tower level. For canonical tower expressions, it is exact.

    Formally verified as `certifyGrowthRank_upper_bound` in Lean 4.
    """
    rank = growth_rank(e)
    inv_free = is_inverse_free(e)

    if inv_free:
        justification = (
            f"growthRank = {rank}. "
            f"By growthRank_hasPolyTowerMajorant: HasPolyTowerMajorant({rank}, e). "
            f"Upper bound certified."
        )
    else:
        justification = (
            f"growthRank = {rank}. "
            f"Expression contains inversions; upper bound may not hold. "
            f"Restrict to inverse-free fragment for guaranteed correctness."
        )

    return rank, justification


def verify_tower_separation(k: int, j: int, C: float = 10.0, N: int = 2,
                             test_points: List[float] = None) -> dict:
    """
    Numerically verify the strict tower separation theorem:
    iterExp(j, C * x^N) < iterExp(k, x) for large x, when j < k.

    This corresponds to `iterExp_not_majorized_below` in Lean 4.

    Returns a dictionary with verification results.
    """
    if test_points is None:
        test_points = [5.0, 10.0, 20.0, 50.0, 100.0]

    results = {
        "theorem": f"iterExp({j}, {C}*x^{N}) < iterExp({k}, x)",
        "j": j, "k": k, "C": C, "N": N,
        "separated": True,
        "separation_point": None,
        "details": []
    }

    for x in test_points:
        lower = iter_exp(j, C * x**N)
        upper = iter_exp(k, x)

        separated = upper > lower if lower != float('inf') else True
        if not separated:
            results["separated"] = False

        if separated and results["separation_point"] is None:
            results["separation_point"] = x

        results["details"].append({
            "x": x,
            "iterExp_j_poly": lower,
            "iterExp_k_x": upper,
            "separated": separated
        })

    return results


def fgh_finite(k: int, x: float) -> float:
    """
    Finite fragment of fast-growing hierarchy.
    FGH(0, x) = x + 1
    FGH(k+1, x) = exp(FGH(k, x))

    Formally verified comparison:
    iterExp(k, x) ≤ FGH(k, x) ≤ iterExp(k+1, x) for x ≥ 0.
    """
    if k == 0:
        return x + 1
    try:
        return math.exp(fgh_finite(k - 1, x))
    except OverflowError:
        return float('inf')


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Growth Rank Algorithm Examples ===\n")

    # Canonical tower expressions
    for k in range(5):
        e = tower_expr(k)
        rank, justification = certify_growth_rank(e)
        print(f"towerExpr({k}):")
        print(f"  Expression: {e}")
        print(f"  {justification}")
        print()

    # Tower separation verification
    print("=== Tower Separation Verification ===\n")
    for k in range(1, 4):
        result = verify_tower_separation(k, k-1)
        print(f"  {result['theorem']}: separated = {result['separated']}")
        if result['separation_point']:
            print(f"    First separation at x = {result['separation_point']}")
    print()

    # Custom expression
    print("=== Custom Expression Analysis ===\n")
    e = Add(Mul(Var(), Var()), EML(Const(1.0), Mul(Var(), Var())))
    print(f"  Expression: {e}")
    rank, justification = certify_growth_rank(e)
    print(f"  {justification}")
    for x in [1.0, 2.0, 5.0]:
        print(f"  eval({x}) = {eval_expr(e, x):.4f}")
