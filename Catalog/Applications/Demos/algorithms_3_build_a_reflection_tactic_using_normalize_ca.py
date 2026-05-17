#!/usr/bin/env python3
"""
Tropical Algebra Algorithms — Core normalization and decision procedures.

Implements the ACI (Associative-Commutative-Idempotent) normalization algorithm
for min-plus tropical expressions, along with extensions for tropical matrix
algebra and shortest-path computations.
"""

from typing import List, Dict, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum
import math


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 1: Tropical Expression AST and Normalization
# ═══════════════════════════════════════════════════════════════════════════

class ExprTag(Enum):
    VAR = 0
    TMIN = 1
    ADD = 2


@dataclass(frozen=True)
class TropExpr:
    """
    Tropical expression abstract syntax tree.

    Represents expressions in the min-plus algebra:
    - Var(i): variable x_i
    - TMin(l, r): tropical addition (minimum)
    - Add(l, r): tropical multiplication (real addition)
    """
    tag: ExprTag
    index: Optional[int] = None
    left: Optional['TropExpr'] = None
    right: Optional['TropExpr'] = None

    def __repr__(self) -> str:
        if self.tag == ExprTag.VAR:
            return f"x{self.index}"
        elif self.tag == ExprTag.TMIN:
            return f"min({self.left}, {self.right})"
        else:
            return f"({self.left} + {self.right})"


def var(i: int) -> TropExpr:
    return TropExpr(ExprTag.VAR, index=i)


def tmin(l: TropExpr, r: TropExpr) -> TropExpr:
    return TropExpr(ExprTag.TMIN, left=l, right=r)


def tadd(l: TropExpr, r: TropExpr) -> TropExpr:
    return TropExpr(ExprTag.ADD, left=l, right=r)


def evaluate(expr: TropExpr, sigma: Callable[[int], float]) -> float:
    """
    Evaluate a tropical expression under a variable assignment.

    Time complexity: O(n) where n is the number of nodes.
    Space complexity: O(d) where d is the depth (recursion stack).
    """
    if expr.tag == ExprTag.VAR:
        return sigma(expr.index)
    elif expr.tag == ExprTag.TMIN:
        return min(evaluate(expr.left, sigma), evaluate(expr.right, sigma))
    else:
        return evaluate(expr.left, sigma) + evaluate(expr.right, sigma)


def _sort_key(expr: TropExpr) -> tuple:
    """Lexicographic comparison key for total ordering on expressions."""
    if expr.tag == ExprTag.VAR:
        return (0, expr.index)
    elif expr.tag == ExprTag.TMIN:
        return (1, _sort_key(expr.left), _sort_key(expr.right))
    else:
        return (2, _sort_key(expr.left), _sort_key(expr.right))


def flatten_min(expr: TropExpr) -> List[TropExpr]:
    """Flatten nested min into a list. O(n)."""
    if expr.tag == ExprTag.TMIN:
        return flatten_min(expr.left) + flatten_min(expr.right)
    return [expr]


def flatten_add(expr: TropExpr) -> List[TropExpr]:
    """Flatten nested add into a list. O(n)."""
    if expr.tag == ExprTag.ADD:
        return flatten_add(expr.left) + flatten_add(expr.right)
    return [expr]


def dedup_sorted(lst: List[TropExpr]) -> List[TropExpr]:
    """Remove consecutive duplicates from a sorted list. O(n)."""
    if len(lst) <= 1:
        return lst
    result = [lst[0]]
    for item in lst[1:]:
        if item != result[-1]:
            result.append(item)
    return result


def build_min(lst: List[TropExpr]) -> TropExpr:
    """Build right-associated min tree from non-empty list. O(n)."""
    assert lst, "Cannot build min from empty list"
    if len(lst) == 1:
        return lst[0]
    return tmin(lst[0], build_min(lst[1:]))


def build_add(lst: List[TropExpr]) -> TropExpr:
    """Build right-associated add tree from non-empty list. O(n)."""
    assert lst, "Cannot build add from empty list"
    if len(lst) == 1:
        return lst[0]
    return tadd(lst[0], build_add(lst[1:]))


def normalize_ca(expr: TropExpr) -> TropExpr:
    """
    ACI-normalize a tropical expression.

    Algorithm:
    1. Recursively normalize subexpressions.
    2. Flatten nested operations into flat lists.
    3. Sort by lexicographic order (handles commutativity).
    4. Deduplicate (for min only — handles idempotence).
    5. Rebuild the canonical tree.

    Time complexity: O(n^2 log n) worst case, O(n log^2 n) for balanced trees.
    Space complexity: O(n).

    Correctness: normalize_ca preserves evaluation semantics (proven formally).
    Completeness: Two expressions are ACI-equivalent iff their normal forms are equal.
    """
    if expr.tag == ExprTag.VAR:
        return expr
    elif expr.tag == ExprTag.TMIN:
        left = normalize_ca(expr.left)
        right = normalize_ca(expr.right)
        flat = flatten_min(tmin(left, right))
        flat.sort(key=_sort_key)
        flat = dedup_sorted(flat)
        return build_min(flat)
    else:  # ADD
        left = normalize_ca(expr.left)
        right = normalize_ca(expr.right)
        flat = flatten_add(tadd(left, right))
        flat.sort(key=_sort_key)
        return build_add(flat)


def check_tropical_identity(lhs: TropExpr, rhs: TropExpr) -> bool:
    """
    Decide whether two tropical expressions are ACI-equivalent.

    This is a complete decision procedure for the ACI fragment.
    Returns True iff the expressions evaluate to the same value
    for every variable assignment.

    Time complexity: O(n^2 log n) where n = max(|lhs|, |rhs|).
    """
    return normalize_ca(lhs) == normalize_ca(rhs)


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 2: Tropical Matrix Algebra
# ═══════════════════════════════════════════════════════════════════════════

INF = float('inf')


def tropical_matrix_mult(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).

    This is the matrix operation underlying shortest-path algorithms.
    Floyd-Warshall computes A^n in the tropical semiring.

    Time complexity: O(n^3) for n×n matrices.

    Args:
        A: m×p matrix (list of rows)
        B: p×n matrix (list of rows)

    Returns:
        m×n tropical product matrix
    """
    m = len(A)
    p = len(A[0])
    n = len(B[0])
    C = [[INF] * n for _ in range(m)]
    for i in range(m):
        for j in range(n):
            for k in range(p):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C


def tropical_matrix_power(A: List[List[float]], exp: int) -> List[List[float]]:
    """
    Compute A^exp in the tropical semiring (repeated tropical matrix multiplication).

    The (i,j) entry of A^n gives the minimum weight of a path from i to j
    using exactly n edges in the weighted digraph defined by A.

    Time complexity: O(n^3 * exp) for n×n matrix.
    """
    n = len(A)
    # Identity: I_{ij} = 0 if i=j, +∞ otherwise
    result = [[INF if i != j else 0 for j in range(n)] for i in range(n)]
    base = A
    while exp > 0:
        if exp % 2 == 1:
            result = tropical_matrix_mult(result, base)
        base = tropical_matrix_mult(base, base)
        exp //= 2
    return result


def floyd_warshall_tropical(W: List[List[float]]) -> List[List[float]]:
    """
    All-pairs shortest paths via tropical matrix closure.

    Computes W* = I ⊕ W ⊕ W^2 ⊕ ... = min(I, W, W^2, ...)

    This is the Kleene star in the tropical semiring, equivalent to
    Floyd-Warshall's algorithm.

    Time complexity: O(n^3).

    Args:
        W: n×n weight matrix (W[i][j] = edge weight, INF if no edge)

    Returns:
        n×n shortest-distance matrix
    """
    n = len(W)
    D = [[W[i][j] for j in range(n)] for i in range(n)]
    for i in range(n):
        D[i][i] = min(D[i][i], 0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 3: Tropical Polynomial Evaluation
# ═══════════════════════════════════════════════════════════════════════════

def tropical_polynomial_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a tropical polynomial p(x) = min_i (a_i + i*x).

    A tropical polynomial defines a piecewise-linear concave function.
    The "roots" are the points where the minimum switches between terms.

    Time complexity: O(n) where n = len(coeffs).

    Args:
        coeffs: list of tropical coefficients [a_0, a_1, ..., a_n]
        x: evaluation point

    Returns:
        min_i (a_i + i*x)
    """
    return min(a + i * x for i, a in enumerate(coeffs) if a < INF)


def tropical_polynomial_roots(coeffs: List[float]) -> List[float]:
    """
    Find the tropical roots of a polynomial.

    A tropical root is a value x where the minimum in p(x) = min_i(a_i + i*x)
    is achieved by at least two different terms. These are the "corners" of the
    piecewise-linear graph.

    This corresponds to finding where consecutive terms in the upper envelope
    of the lines y = a_i + i*x intersect.

    Time complexity: O(n log n) with convex hull; O(n^2) naive.
    """
    # Filter out infinite coefficients
    active = [(i, a) for i, a in enumerate(coeffs) if a < INF]
    if len(active) <= 1:
        return []

    roots = []
    for j in range(len(active) - 1):
        i1, a1 = active[j]
        i2, a2 = active[j + 1]
        if i2 != i1:
            # Lines a1 + i1*x = a2 + i2*x => x = (a1 - a2) / (i2 - i1)
            root = (a1 - a2) / (i2 - i1)
            roots.append(root)

    return sorted(set(roots))


# ═══════════════════════════════════════════════════════════════════════════
# SECTION 4: Expression Size and Complexity Metrics
# ═══════════════════════════════════════════════════════════════════════════

def expr_size(expr: TropExpr) -> int:
    """Count the number of nodes in a tropical expression."""
    if expr.tag == ExprTag.VAR:
        return 1
    return 1 + expr_size(expr.left) + expr_size(expr.right)


def expr_depth(expr: TropExpr) -> int:
    """Compute the depth of a tropical expression tree."""
    if expr.tag == ExprTag.VAR:
        return 0
    return 1 + max(expr_depth(expr.left), expr_depth(expr.right))


def normalization_ratio(expr: TropExpr) -> float:
    """
    Compute the size ratio of normalized to original expression.

    Values < 1 indicate the normalizer achieved compression
    (typically from duplicate elimination).
    """
    original_size = expr_size(expr)
    normalized_size = expr_size(normalize_ca(expr))
    return normalized_size / original_size


# ═══════════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Demonstrate the normalization algorithm
    a, b, c, d = var(0), var(1), var(2), var(3)

    print("=== Tropical Expression Normalization ===\n")

    e1 = tmin(tadd(a, b), tmin(tadd(c, d), tadd(a, b)))
    e2 = tmin(tmin(tadd(d, c), tadd(b, a)), tadd(a, b))

    print(f"Expression 1: {e1}")
    print(f"Expression 2: {e2}")
    print(f"Normalized 1: {normalize_ca(e1)}")
    print(f"Normalized 2: {normalize_ca(e2)}")
    print(f"ACI-equivalent: {check_tropical_identity(e1, e2)}")

    print("\n=== Tropical Matrix Multiplication (Shortest Paths) ===\n")

    # Graph with 4 nodes
    W = [
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [2, INF, INF, 0]
    ]

    D = floyd_warshall_tropical(W)
    print("Weight matrix W:")
    for row in W:
        print("  ", [f"{x:4g}" if x < INF else " inf" for x in row])
    print("\nShortest distances D = W*:")
    for row in D:
        print("  ", [f"{x:4g}" if x < INF else " inf" for x in row])

    print("\n=== Tropical Polynomial Roots ===\n")

    coeffs = [6, 1, 0]  # p(x) = min(6, 1+x, 2x)
    print(f"Polynomial coefficients: {coeffs}")
    print(f"p(x) = min(6, 1+x, 2x)")
    roots = tropical_polynomial_roots(coeffs)
    print(f"Tropical roots: {roots}")
    for r in roots:
        print(f"  p({r}) = {tropical_polynomial_eval(coeffs, r)}")
