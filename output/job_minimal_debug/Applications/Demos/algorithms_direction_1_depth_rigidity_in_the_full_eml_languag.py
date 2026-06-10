#!/usr/bin/env python3
"""
Algorithms for Depth Rigidity Analysis

Implements the certified depth analyzer and growth rank computer
for positive-real EML expressions with inversions.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ─────────────────────────────────────────────────────────────
# Expression Representation
# ─────────────────────────────────────────────────────────────

@dataclass
class PosExpr:
    """Expression in the positive-real EML language.

    Attributes:
        kind: One of 'var', 'const', 'mul', 'inv', 'exp'
        children: List of sub-expressions
        value: Constant value (for 'const' nodes)
    """
    kind: str
    children: list
    value: float = 0.0

    def eval(self, x: float) -> float:
        """Evaluate the expression at input x > 0.

        Args:
            x: A positive real number

        Returns:
            The value of the expression at x

        Raises:
            ValueError: If x <= 0
        """
        if x <= 0:
            raise ValueError(f"Input must be positive, got {x}")

        if self.kind == 'var':
            return x
        elif self.kind == 'const':
            return self.value
        elif self.kind == 'mul':
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.kind == 'inv':
            v = self.children[0].eval(x)
            if v <= 0:
                raise ValueError("Inversion of non-positive value")
            return 1.0 / v
        elif self.kind == 'exp':
            v = self.children[0].eval(x)
            if v > 700:
                return float('inf')
            return math.exp(v)
        raise ValueError(f"Unknown kind: {self.kind}")


def compute_depth(expr: PosExpr) -> int:
    """Compute the exponential nesting depth.

    Only `exp` nodes increment depth. Other operations preserve
    or take the max of children's depths.

    Time complexity: O(n) where n = number of nodes
    Space complexity: O(h) where h = tree height (recursion stack)

    Args:
        expr: A PosExpr expression tree

    Returns:
        The depth (number of nested exp operations on any path)

    Examples:
        >>> compute_depth(PosExpr('var', []))
        0
        >>> compute_depth(PosExpr('exp', [PosExpr('var', [])]))
        1
        >>> compute_depth(PosExpr('exp', [PosExpr('exp', [PosExpr('var', [])])]))
        2
    """
    if expr.kind in ('var', 'const'):
        return 0
    elif expr.kind == 'mul':
        return max(compute_depth(expr.children[0]),
                   compute_depth(expr.children[1]))
    elif expr.kind == 'inv':
        return compute_depth(expr.children[0])
    elif expr.kind == 'exp':
        return 1 + compute_depth(expr.children[0])
    return 0


def compute_growth_rank(expr: PosExpr) -> int:
    """Compute the growth rank of an expression.

    For expression trees, growth_rank = depth. The distinction is
    conceptual: growth rank measures semantic growth potential while
    depth measures syntactic nesting.

    The key property: inv preserves growth rank, reflecting that
    inversion cannot create new exponential tower levels.

    Time complexity: O(n)
    Space complexity: O(h)

    Args:
        expr: A PosExpr expression tree

    Returns:
        The growth rank (equals depth for trees)
    """
    return compute_depth(expr)


def compute_log_tame_index(expr: PosExpr) -> int:
    """Compute the logarithmic tameness index.

    The minimum number of iterated logarithms needed to reduce
    the function to eventually polynomial growth.

    Connects to differential algebra (Liouvillian tower height).

    Time complexity: O(n)
    Space complexity: O(h)
    """
    return compute_depth(expr)


# ─────────────────────────────────────────────────────────────
# Reciprocal Envelope Checker
# ─────────────────────────────────────────────────────────────

def iterExp(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp^n(x)."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def check_reciprocal_envelope(
    expr: PosExpr,
    d: int,
    C: float,
    N: int,
    x_values: List[float]
) -> Tuple[bool, Optional[float]]:
    """Check if an expression satisfies a reciprocal envelope at given parameters.

    Tests whether both f(x) ≤ iterExp(d, C·x^N) and 1/f(x) ≤ iterExp(d, C·x^N)
    hold at all given test points.

    Args:
        expr: Expression to check
        d: Tower level
        C: Coefficient (must be > 0)
        N: Polynomial degree
        x_values: Test points (must be positive)

    Returns:
        (passes, first_violation_x) where passes is True if all tests pass
    """
    for x in x_values:
        try:
            fx = expr.eval(x)
            bound = iterExp(d, C * x**N)

            if math.isinf(bound):
                continue  # infinite bound always satisfied

            if fx > bound:
                return False, x
            if fx > 0 and 1.0/fx > bound:
                return False, x
        except (ValueError, ZeroDivisionError, OverflowError):
            return False, x

    return True, None


def find_envelope_parameters(
    expr: PosExpr,
    x_values: List[float],
    max_C: float = 100.0,
    max_N: int = 10
) -> Optional[Tuple[int, float, int]]:
    """Find the tightest reciprocal envelope parameters for an expression.

    Searches for the smallest d such that some C, N give a valid envelope.

    Args:
        expr: Expression to analyze
        x_values: Test points
        max_C: Maximum coefficient to try
        max_N: Maximum polynomial degree to try

    Returns:
        (d, C, N) if found, None if no envelope found within bounds
    """
    d = compute_depth(expr)

    for C_try in [1.0, 2.0, 5.0, 10.0, 50.0, max_C]:
        for N_try in range(max_N + 1):
            passes, _ = check_reciprocal_envelope(expr, d, C_try, N_try, x_values)
            if passes:
                return d, C_try, N_try

    return None


# ─────────────────────────────────────────────────────────────
# Certified Depth Analyzer
# ─────────────────────────────────────────────────────────────

def certified_depth_analysis(expr: PosExpr) -> dict:
    """Perform a complete depth analysis of an expression.

    Returns a dictionary with:
    - depth: exponential nesting depth
    - growth_rank: semantic growth complexity
    - log_tame_index: logarithmic tameness index
    - has_inversions: whether the expression uses inv
    - node_count: total number of nodes
    - exp_count: number of exp nodes

    Time complexity: O(n)
    Space complexity: O(h)
    """
    def count_nodes(e: PosExpr) -> Tuple[int, int, bool]:
        """Returns (total_nodes, exp_nodes, has_inv)."""
        if e.kind in ('var', 'const'):
            return 1, 0, False
        elif e.kind == 'mul':
            n1, e1, i1 = count_nodes(e.children[0])
            n2, e2, i2 = count_nodes(e.children[1])
            return 1 + n1 + n2, e1 + e2, i1 or i2
        elif e.kind == 'inv':
            n1, e1, i1 = count_nodes(e.children[0])
            return 1 + n1, e1, True
        elif e.kind == 'exp':
            n1, e1, i1 = count_nodes(e.children[0])
            return 1 + n1, 1 + e1, i1
        return 1, 0, False

    total, exp_count, has_inv = count_nodes(expr)

    return {
        'depth': compute_depth(expr),
        'growth_rank': compute_growth_rank(expr),
        'log_tame_index': compute_log_tame_index(expr),
        'has_inversions': has_inv,
        'node_count': total,
        'exp_count': exp_count,
    }


# ─────────────────────────────────────────────────────────────
# Expression Enumeration with Depth Constraint
# ─────────────────────────────────────────────────────────────

def enumerate_depth_bounded(
    max_depth: int,
    max_size: int,
    constants: List[float] = [1.0]
) -> List[PosExpr]:
    """Enumerate all expressions with depth ≤ max_depth and size ≤ max_size.

    This is the key search procedure for finding potential counterexamples
    to the depth rigidity conjecture.

    Args:
        max_depth: Maximum allowed depth
        max_size: Maximum number of nodes
        constants: Positive constants to include

    Returns:
        List of all matching expressions

    Time complexity: Exponential in max_size (unavoidable for enumeration)
    """
    results = []

    def generate(remaining_size: int, depth_budget: int) -> List[PosExpr]:
        if remaining_size <= 0:
            return []

        exprs = []

        # Leaves
        if remaining_size >= 1:
            exprs.append(PosExpr('var', []))
            for c in constants:
                exprs.append(PosExpr('const', [], c))

        if remaining_size >= 2:
            # Unary: inv (doesn't increase depth)
            for child in generate(remaining_size - 1, depth_budget):
                exprs.append(PosExpr('inv', [child]))

            # Unary: exp (increases depth by 1)
            if depth_budget >= 1:
                for child in generate(remaining_size - 1, depth_budget - 1):
                    exprs.append(PosExpr('exp', [child]))

        if remaining_size >= 3:
            # Binary: mul (max of children depths)
            for left_size in range(1, remaining_size - 1):
                right_size = remaining_size - 1 - left_size
                for left in generate(left_size, depth_budget):
                    for right in generate(right_size, depth_budget):
                        exprs.append(PosExpr('mul', [left, right]))

        return exprs

    return generate(max_size, max_depth)


# ─────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────

if __name__ == '__main__':
    # Example 1: Analyze canonical iterExp expressions
    print("=== Certified Depth Analysis ===")
    print()

    var = PosExpr('var', [])
    e1 = PosExpr('exp', [var])  # exp(x)
    e2 = PosExpr('exp', [e1])   # exp(exp(x))
    e3 = PosExpr('exp', [e2])   # exp(exp(exp(x)))

    # With inversion: exp(exp(x)) * 1/1 = exp(exp(x))
    inv_attempt = PosExpr('mul', [e2, PosExpr('inv', [PosExpr('inv', [PosExpr('const', [], 1.0)])])])

    for name, expr in [("exp(x)", e1), ("exp(exp(x))", e2),
                        ("exp(exp(exp(x)))", e3),
                        ("exp(exp(x)) * 1/(1/1)", inv_attempt)]:
        analysis = certified_depth_analysis(expr)
        print(f"{name}:")
        for k, v in analysis.items():
            print(f"  {k}: {v}")
        print()

    # Example 2: Find envelope parameters
    print("=== Envelope Parameter Search ===")
    print()
    test_points = [1.0, 2.0, 3.0, 4.0, 5.0]

    for name, expr in [("exp(x)", e1), ("1/exp(x)", PosExpr('inv', [e1])),
                        ("exp(exp(x))", e2)]:
        result = find_envelope_parameters(expr, test_points)
        if result:
            d, C, N = result
            print(f"{name}: envelope at level {d} with C={C}, N={N}")
        else:
            print(f"{name}: no envelope found")

    # Example 3: Enumerate and search
    print()
    print("=== Exhaustive Search for Counterexamples ===")
    print()

    for target_n in [1, 2, 3]:
        exprs = enumerate_depth_bounded(target_n - 1, 5)
        print(f"Expressions with depth < {target_n} and size ≤ 5: {len(exprs)}")

        matches = 0
        for expr in exprs:
            if all(abs(expr.eval(x) - iterExp(target_n, x)) < 1e-6 * max(1, iterExp(target_n, x))
                   for x in [0.5, 1.0, 1.5, 2.0]):
                matches += 1
                print(f"  Potential match (depth={compute_depth(expr)}): checking...")

        if matches == 0:
            print(f"  No depth-{target_n-1} expression computes iterExp({target_n}).")
            print(f"  (Consistent with the depth rigidity theorem)")
        print()
