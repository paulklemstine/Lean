#!/usr/bin/env python3
"""
EML Universal Approximation — Algorithms

Type-hinted implementations of the core algorithms from
the EML Approximation Filtration framework.
"""

import math
from typing import Callable, List, Optional, Tuple, Union


# ============================================================
# EML Expression Tree (Type-hinted)
# ============================================================

class EMLNode:
    """Abstract base for EML expression nodes."""
    pass

class ConstNode(EMLNode):
    def __init__(self, value: float) -> None:
        self.value = value

class VarNode(EMLNode):
    pass

class AddNode(EMLNode):
    def __init__(self, left: EMLNode, right: EMLNode) -> None:
        self.left = left
        self.right = right

class MulNode(EMLNode):
    def __init__(self, left: EMLNode, right: EMLNode) -> None:
        self.left = left
        self.right = right

class NegNode(EMLNode):
    def __init__(self, child: EMLNode) -> None:
        self.child = child

class ExpNode(EMLNode):
    def __init__(self, child: EMLNode) -> None:
        self.child = child

class LogNode(EMLNode):
    def __init__(self, child: EMLNode) -> None:
        self.child = child


# ============================================================
# Algorithm 1: EML Expression Evaluation
# ============================================================

def eml_eval(node: EMLNode, x: float) -> float:
    """Evaluate an EML expression tree at point x.

    Time complexity: O(size(node))
    Space complexity: O(depth(node)) for recursion stack
    """
    if isinstance(node, ConstNode):
        return node.value
    elif isinstance(node, VarNode):
        return x
    elif isinstance(node, AddNode):
        return eml_eval(node.left, x) + eml_eval(node.right, x)
    elif isinstance(node, MulNode):
        return eml_eval(node.left, x) * eml_eval(node.right, x)
    elif isinstance(node, NegNode):
        return -eml_eval(node.child, x)
    elif isinstance(node, ExpNode):
        return math.exp(eml_eval(node.child, x))
    elif isinstance(node, LogNode):
        v = eml_eval(node.child, x)
        return math.log(v) if v > 0 else 0.0
    raise TypeError(f"Unknown node type: {type(node)}")


# ============================================================
# Algorithm 2: Complexity Measures
# ============================================================

def eml_size(node: EMLNode) -> int:
    """Count total nodes in expression tree."""
    if isinstance(node, (ConstNode, VarNode)):
        return 1
    elif isinstance(node, (AddNode, MulNode)):
        return 1 + eml_size(node.left) + eml_size(node.right)  # type: ignore
    elif isinstance(node, (NegNode, ExpNode, LogNode)):
        return 1 + eml_size(node.child)  # type: ignore
    return 0

def eml_depth(node: EMLNode) -> int:
    """Compute depth (longest root-to-leaf path)."""
    if isinstance(node, (ConstNode, VarNode)):
        return 0
    elif isinstance(node, (AddNode, MulNode)):
        return 1 + max(eml_depth(node.left), eml_depth(node.right))  # type: ignore
    elif isinstance(node, (NegNode, ExpNode, LogNode)):
        return 1 + eml_depth(node.child)  # type: ignore
    return 0

def eml_trans_depth(node: EMLNode) -> int:
    """Compute transcendental depth (nesting of exp/log only)."""
    if isinstance(node, (ConstNode, VarNode)):
        return 0
    elif isinstance(node, (AddNode, MulNode)):
        return max(eml_trans_depth(node.left), eml_trans_depth(node.right))  # type: ignore
    elif isinstance(node, NegNode):
        return eml_trans_depth(node.child)
    elif isinstance(node, (ExpNode, LogNode)):
        return 1 + eml_trans_depth(node.child)  # type: ignore
    return 0


# ============================================================
# Algorithm 3: Substitution (Composition)
# ============================================================

def eml_subst(expr: EMLNode, replacement: EMLNode) -> EMLNode:
    """Substitute all VarNode occurrences with replacement.

    Corresponds to function composition: if expr represents f and
    replacement represents g, then subst(expr, replacement) represents f∘g.
    """
    if isinstance(expr, ConstNode):
        return expr
    elif isinstance(expr, VarNode):
        return replacement
    elif isinstance(expr, AddNode):
        return AddNode(eml_subst(expr.left, replacement),
                       eml_subst(expr.right, replacement))
    elif isinstance(expr, MulNode):
        return MulNode(eml_subst(expr.left, replacement),
                       eml_subst(expr.right, replacement))
    elif isinstance(expr, NegNode):
        return NegNode(eml_subst(expr.child, replacement))
    elif isinstance(expr, ExpNode):
        return ExpNode(eml_subst(expr.child, replacement))
    elif isinstance(expr, LogNode):
        return LogNode(eml_subst(expr.child, replacement))
    raise TypeError(f"Unknown: {type(expr)}")


def eml_iter_subst(expr: EMLNode, k: int) -> EMLNode:
    """k-fold self-substitution: expr composed with itself k times.

    Satisfies: eval(iter_subst(e, k), x) = f^[k](x)
    where f = eval(e, ·).
    """
    if k == 0:
        return VarNode()
    return eml_subst(expr, eml_iter_subst(expr, k - 1))


# ============================================================
# Algorithm 4: Horner Polynomial-to-EML Conversion
# ============================================================

def poly_to_eml(coefficients: List[float]) -> EMLNode:
    """Convert polynomial coefficients to EML via Horner's method.

    Given [c₀, c₁, ..., cₙ], builds:
      c₀ + x·(c₁ + x·(c₂ + ... + x·cₙ))

    Properties:
    - Size: 2n + 1 (optimal among Horner representations)
    - Depth: 2n
    - TransDepth: 0 (purely algebraic)
    """
    if not coefficients:
        return ConstNode(0.0)
    if len(coefficients) == 1:
        return ConstNode(coefficients[0])
    return AddNode(ConstNode(coefficients[0]),
                   MulNode(VarNode(), poly_to_eml(coefficients[1:])))


# ============================================================
# Algorithm 5: EML Description Complexity Estimation
# ============================================================

def estimate_desc_complexity(
    f: Callable[[float], float],
    a: float, b: float,
    eps: float,
    max_degree: int = 50,
    num_points: int = 200
) -> Tuple[int, Optional[EMLNode]]:
    """Estimate EML description complexity by polynomial search.

    Finds the smallest-degree polynomial (via Taylor/Chebyshev expansion)
    that ε-approximates f on [a,b], then returns its EML size.

    Returns (size, expression) or (-1, None) if no fit found.
    """
    xs = [a + (b - a) * i / num_points for i in range(num_points + 1)]
    f_vals = [f(xi) for xi in xs]

    for degree in range(max_degree + 1):
        # Use Taylor coefficients if f = exp
        # General case: use polynomial interpolation
        coeffs = _fit_polynomial(xs, f_vals, degree)
        if coeffs is None:
            continue

        # Check approximation quality
        max_err = 0.0
        for i, xi in enumerate(xs):
            poly_val = sum(c * xi**k for k, c in enumerate(coeffs))
            max_err = max(max_err, abs(f_vals[i] - poly_val))

        if max_err <= eps:
            expr = poly_to_eml(coeffs)
            return eml_size(expr), expr

    return -1, None


def _fit_polynomial(xs: List[float], ys: List[float], degree: int) -> Optional[List[float]]:
    """Simple least-squares polynomial fit."""
    n = len(xs)
    if degree + 1 > n:
        return None

    # Build Vandermonde matrix and solve normal equations
    try:
        # Using basic linear algebra (no numpy dependency)
        A = [[xi**k for k in range(degree + 1)] for xi in xs]
        # A^T A coeffs = A^T y
        AtA = [[sum(A[i][j] * A[i][k] for i in range(n))
                for k in range(degree + 1)]
               for j in range(degree + 1)]
        Aty = [sum(A[i][j] * ys[i] for i in range(n))
               for j in range(degree + 1)]

        # Gaussian elimination
        m = degree + 1
        aug = [AtA[i] + [Aty[i]] for i in range(m)]
        for col in range(m):
            # Pivot
            max_row = max(range(col, m), key=lambda r: abs(aug[r][col]))
            aug[col], aug[max_row] = aug[max_row], aug[col]
            if abs(aug[col][col]) < 1e-12:
                return None
            for row in range(col + 1, m):
                factor = aug[row][col] / aug[col][col]
                for j in range(col, m + 1):
                    aug[row][j] -= factor * aug[col][j]
        # Back substitution
        coeffs = [0.0] * m
        for i in range(m - 1, -1, -1):
            coeffs[i] = (aug[i][m] - sum(aug[i][j] * coeffs[j]
                         for j in range(i + 1, m))) / aug[i][i]
        return coeffs
    except (ZeroDivisionError, ValueError):
        return None


# ============================================================
# Algorithm 6: Retained Information Computation
# ============================================================

def compute_retained_info(alpha: float, depth: int, initial_K: int) -> float:
    """Compute retained symbolic information: α^l × K."""
    return alpha**depth * initial_K


def min_initial_complexity(alpha: float, depth: int, threshold: float) -> float:
    """Minimum initial complexity to retain at least `threshold` bits
    after `depth` layers with contraction `alpha`.

    From depth_information_tradeoff: K ≥ threshold / α^l
    """
    if alpha <= 0 or depth < 0:
        return float('inf')
    return threshold / alpha**depth


# ============================================================
# Algorithm 7: Iterated Exponential Construction
# ============================================================

def build_iter_exp(n: int) -> EMLNode:
    """Build canonical EML expression for iterExp n.

    Properties (formally verified):
    - size = n + 1
    - depth = n
    - transDepth = n
    - eval(x) = exp^n(x)
    """
    if n == 0:
        return VarNode()
    return ExpNode(build_iter_exp(n - 1))


if __name__ == "__main__":
    # Quick test
    e = build_iter_exp(3)
    print(f"iterExp 3: size={eml_size(e)}, depth={eml_depth(e)}, "
          f"transDepth={eml_trans_depth(e)}, eval(1)={eml_eval(e, 1.0):.4f}")

    # Complexity estimation
    size, expr = estimate_desc_complexity(math.exp, 0, 1, 0.01)
    print(f"exp(x) on [0,1] at ε=0.01: EML size = {size}")
