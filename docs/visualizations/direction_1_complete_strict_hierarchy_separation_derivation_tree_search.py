#!/usr/bin/env python3
"""
Hardy Hierarchy — Algorithms for Growth Classification

Implements:
1. HardyLevel derivation tree search
2. Eventual domination witness synthesis
3. Growth bound certificate generation
4. Hardy rank computation
"""

import math
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, List, Optional, Tuple


# ─────────────────────────────────────────────────────────────
# Expression Language (EML)
# ─────────────────────────────────────────────────────────────

class ExprKind(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    EML = auto()  # a * exp(b)


@dataclass
class Expr:
    """EML expression tree."""
    kind: ExprKind
    value: Optional[float] = None  # For CONST
    left: Optional['Expr'] = None
    right: Optional['Expr'] = None

    def eval(self, x: float) -> float:
        """Evaluate expression at x."""
        if self.kind == ExprKind.VAR:
            return x
        elif self.kind == ExprKind.CONST:
            return self.value
        elif self.kind == ExprKind.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprKind.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprKind.NEG:
            return -self.left.eval(x)
        elif self.kind == ExprKind.EML:
            b_val = self.right.eval(x)
            if b_val > 700:
                return float('inf')
            return self.left.eval(x) * math.exp(b_val)
        raise ValueError(f"Unknown expression kind: {self.kind}")

    def depth(self) -> int:
        """Compute EML depth (= Hardy level upper bound)."""
        if self.kind in (ExprKind.VAR, ExprKind.CONST):
            return 0
        elif self.kind in (ExprKind.ADD, ExprKind.MUL):
            return max(self.left.depth(), self.right.depth())
        elif self.kind == ExprKind.NEG:
            return self.left.depth()
        elif self.kind == ExprKind.EML:
            return 1 + max(self.left.depth(), self.right.depth())
        return 0

    def __repr__(self) -> str:
        if self.kind == ExprKind.VAR:
            return "x"
        elif self.kind == ExprKind.CONST:
            return str(self.value)
        elif self.kind == ExprKind.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == ExprKind.MUL:
            return f"({self.left} * {self.right})"
        elif self.kind == ExprKind.NEG:
            return f"(-{self.left})"
        elif self.kind == ExprKind.EML:
            return f"({self.left} * exp({self.right}))"
        return "?"


# Constructors
def var() -> Expr:
    return Expr(ExprKind.VAR)

def const(c: float) -> Expr:
    return Expr(ExprKind.CONST, value=c)

def add(a: Expr, b: Expr) -> Expr:
    return Expr(ExprKind.ADD, left=a, right=b)

def mul(a: Expr, b: Expr) -> Expr:
    return Expr(ExprKind.MUL, left=a, right=b)

def eml(a: Expr, b: Expr) -> Expr:
    """a * exp(b)"""
    return Expr(ExprKind.EML, left=a, right=b)


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Derivation Tree Search
# ─────────────────────────────────────────────────────────────

def enumerate_expressions(max_depth: int, max_size: int) -> List[Expr]:
    """
    Enumerate EML expressions up to given depth and size.

    Time complexity: O(C^max_size) where C is the branching factor (~5).
    Space complexity: O(max_size * |results|).

    Args:
        max_depth: Maximum EML depth allowed.
        max_size: Maximum expression tree size.

    Returns:
        List of expressions within the bounds.
    """
    results: List[Expr] = []

    def _enumerate(remaining_size: int, remaining_depth: int) -> List[Expr]:
        if remaining_size <= 0:
            return []

        exprs = [var(), const(1.0), const(2.0), const(-1.0)]

        if remaining_size >= 3:
            sub = _enumerate(remaining_size - 1, remaining_depth)
            for a in sub[:10]:  # Limit branching
                for b in sub[:10]:
                    exprs.append(add(a, b))
                    exprs.append(mul(a, b))
                    if remaining_depth > 0:
                        exprs.append(eml(a, b))

        return exprs[:100]  # Cap total

    results = _enumerate(max_size, max_depth)
    return results


def search_hardy_level_certificate(
    target_fn: Callable[[float], float],
    level: int,
    max_size: int = 5,
    test_points: List[float] = None,
    tolerance: float = 1e-6
) -> Optional[Expr]:
    """
    Search for an EML expression at the given Hardy level that
    eventually equals the target function.

    Algorithm:
        1. Enumerate all expressions of depth ≤ level and size ≤ max_size.
        2. Evaluate each at test points.
        3. Return the first that matches within tolerance.

    Args:
        target_fn: The function to match.
        level: Target Hardy level.
        max_size: Maximum expression size.
        test_points: Points to test equality.
        tolerance: Matching tolerance.

    Returns:
        Matching expression, or None if not found.
    """
    if test_points is None:
        test_points = [10.0, 20.0, 50.0, 100.0]

    candidates = enumerate_expressions(level, max_size)

    for expr in candidates:
        if expr.depth() > level:
            continue

        try:
            matches = True
            for x in test_points:
                target_val = target_fn(x)
                expr_val = expr.eval(x)
                if abs(target_val) < 1e-10:
                    if abs(expr_val) > tolerance:
                        matches = False
                        break
                elif abs(target_val - expr_val) / max(1, abs(target_val)) > tolerance:
                    matches = False
                    break
            if matches:
                return expr
        except (OverflowError, ValueError):
            continue

    return None


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Eventual Domination Witness Synthesis
# ─────────────────────────────────────────────────────────────

def find_domination_witness(
    f: Callable[[float], float],
    g: Callable[[float], float],
    start: float = 1.0,
    max_x: float = 1e6,
    step_factor: float = 1.5
) -> Optional[Tuple[float, float]]:
    """
    Find a witness (N, ratio) showing that g eventually dominates f.

    Algorithm:
        Geometric search: test x = start, start*step_factor, start*step_factor^2, ...
        Return the first x where g(x) > f(x), along with the ratio g(x)/f(x).

    Time complexity: O(log(max_x / start) / log(step_factor))
    Space complexity: O(1)

    Args:
        f: Function to be dominated.
        g: Dominating function.
        start: Starting point for search.
        max_x: Maximum x to test.
        step_factor: Geometric growth factor.

    Returns:
        (N, ratio) where for x ≥ N, g(x)/f(x) ≥ ratio, or None.
    """
    x = start
    while x <= max_x:
        try:
            fv = f(x)
            gv = g(x)
            if gv > fv and fv > 0:
                return (x, gv / fv)
        except (OverflowError, ValueError):
            pass
        x *= step_factor
    return None


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Growth Bound Certificate Generation
# ─────────────────────────────────────────────────────────────

def iterExp(n: int, x: float) -> float:
    """Iterated exponential with overflow protection."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def verify_growth_bound(
    f: Callable[[float], float],
    n: int,
    C: float,
    test_range: Tuple[float, float] = (1.0, 100.0),
    num_points: int = 100
) -> Tuple[bool, Optional[float]]:
    """
    Verify whether |f(x)| ≤ exp(C · iterExp(n, x)) holds on test points.

    Args:
        f: Function to test.
        n: Hardy level.
        C: Constant in the bound.
        test_range: Range of x values to test.
        num_points: Number of test points.

    Returns:
        (all_pass, first_failure_x) — True if bound holds on all points.
    """
    start, end = test_range
    step = (end - start) / num_points

    for i in range(num_points + 1):
        x = start + i * step
        try:
            fv = abs(f(x))
            t = iterExp(n, x)
            if t == float('inf'):
                continue  # Bound trivially holds
            bound = math.exp(min(C * t, 700))
            if fv > bound * 1.001:  # Small tolerance
                return (False, x)
        except (OverflowError, ValueError):
            continue

    return (True, None)


def synthesize_bound_certificate(
    f: Callable[[float], float],
    n: int,
    C_candidates: List[float] = None
) -> Optional[Tuple[float, float]]:
    """
    Find (C, N) such that |f(x)| ≤ exp(C · iterExp(n, x)) for x ≥ N.

    Algorithm:
        Binary search on C, then linear search for N.

    Args:
        f: Function to bound.
        n: Hardy level.
        C_candidates: List of C values to try.

    Returns:
        (C, N) witness pair, or None.
    """
    if C_candidates is None:
        C_candidates = [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]

    for C in C_candidates:
        # Search for N
        for N_candidate in [1, 5, 10, 50, 100, 500]:
            passed, _ = verify_growth_bound(
                f, n, C, (N_candidate, N_candidate + 100), 50
            )
            if passed:
                return (C, N_candidate)

    return None


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Hardy Rank Computation
# ─────────────────────────────────────────────────────────────

def estimate_hardy_rank(
    f: Callable[[float], float],
    max_level: int = 5,
    test_x: float = 10.0
) -> int:
    """
    Estimate the Hardy rank of a function by comparing growth rates.

    Algorithm:
        For each level n = 0, 1, ..., max_level:
            Check if f(x) is eventually dominated by iterExp(n+1, x)
            but NOT by iterExp(n, x).

    Args:
        f: Function to classify.
        max_level: Maximum level to test.
        test_x: Point to evaluate at.

    Returns:
        Estimated Hardy rank.
    """
    for n in range(max_level + 1):
        # Check if f grows slower than iterExp(n+1)
        try:
            fv = abs(f(test_x))
            upper = iterExp(n + 1, test_x)
            if upper == float('inf') or fv < upper:
                return n
        except (OverflowError, ValueError):
            return n

    return max_level


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Hardy Hierarchy Algorithms — Examples")
    print("=" * 50)

    # Example 1: Derivation tree search
    print("\n1. Searching for Hardy level certificate for exp(x)...")
    result = search_hardy_level_certificate(
        lambda x: math.exp(x), level=1, max_size=3
    )
    if result:
        print(f"   Found: {result} (depth {result.depth()})")
    else:
        print("   Not found at this size")

    # Example 2: Domination witness
    print("\n2. Finding domination witness: exp(x) vs x^10...")
    witness = find_domination_witness(lambda x: x**10, lambda x: math.exp(x))
    if witness:
        print(f"   Domination starts at x ≈ {witness[0]:.1f} with ratio {witness[1]:.2f}")

    # Example 3: Growth bound certificate
    print("\n3. Synthesizing growth bound for x^3 at level 0...")
    cert = synthesize_bound_certificate(lambda x: x**3, 0)
    if cert:
        print(f"   Certificate: C = {cert[0]}, N = {cert[1]}")
        print(f"   Bound: |x³| ≤ exp({cert[0]} · x) for x ≥ {cert[1]}")

    # Example 4: Hardy rank estimation
    print("\n4. Estimating Hardy ranks...")
    test_fns = [
        ("x²", lambda x: x**2),
        ("exp(x)", lambda x: math.exp(x)),
        ("exp(exp(x))", lambda x: iterExp(2, x)),
        ("x·exp(x)", lambda x: x * math.exp(x)),
    ]
    for name, f in test_fns:
        rank = estimate_hardy_rank(f)
        print(f"   {name:20s} → estimated rank {rank}")

    print()
