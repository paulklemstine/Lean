#!/usr/bin/env python3
"""
EML Universal Approximation: Core Algorithms

Type-hinted implementations of the key algorithms from the EML
universal approximation theory.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple
import math


# ── EML Expression ADT ───────────────────────────────────────────────────────

@dataclass
class EMLNode:
    """Abstract base for EML expression nodes."""
    pass

@dataclass
class ConstNode(EMLNode):
    value: float

@dataclass
class VarNode(EMLNode):
    pass

@dataclass
class AddNode(EMLNode):
    left: EMLNode
    right: EMLNode

@dataclass
class MulNode(EMLNode):
    left: EMLNode
    right: EMLNode

@dataclass
class ExpNode(EMLNode):
    child: EMLNode

@dataclass
class LogNode(EMLNode):
    child: EMLNode


# ── Core algorithms ──────────────────────────────────────────────────────────

def evaluate(node: EMLNode, x: float) -> float:
    """Evaluate an EML expression at point x.

    Time complexity: O(size(node))
    Space complexity: O(depth(node)) for the recursion stack
    """
    if isinstance(node, ConstNode):
        return node.value
    elif isinstance(node, VarNode):
        return x
    elif isinstance(node, AddNode):
        return evaluate(node.left, x) + evaluate(node.right, x)
    elif isinstance(node, MulNode):
        return evaluate(node.left, x) * evaluate(node.right, x)
    elif isinstance(node, ExpNode):
        v = evaluate(node.child, x)
        return math.exp(min(v, 700))
    elif isinstance(node, LogNode):
        v = evaluate(node.child, x)
        return math.log(v) if v > 0 else 0.0
    raise TypeError(f"Unknown node type: {type(node)}")


def depth(node: EMLNode) -> int:
    """Compute the depth of an EML expression tree.

    Theorem (depth_lt_size): depth(e) < size(e) for all e.
    """
    if isinstance(node, (ConstNode, VarNode)):
        return 0
    elif isinstance(node, (AddNode, MulNode)):
        return max(depth(node.left), depth(node.right)) + 1
    elif isinstance(node, (ExpNode, LogNode)):
        return depth(node.child) + 1
    raise TypeError


def size(node: EMLNode) -> int:
    """Compute the size (number of nodes) of an EML expression tree.

    Theorem (size_pos): size(e) ≥ 1 for all e.
    """
    if isinstance(node, (ConstNode, VarNode)):
        return 1
    elif isinstance(node, (AddNode, MulNode)):
        return size(node.left) + size(node.right) + 1
    elif isinstance(node, (ExpNode, LogNode)):
        return size(node.child) + 1
    raise TypeError


def symbolic_derivative(node: EMLNode) -> EMLNode:
    """Compute the symbolic derivative d/dx of an EML expression.

    Theorem (deriv_depth_le_two_size): depth(d/dx[e]) ≤ 2 * size(e)
    Theorem (eml_closed_under_deriv): d/dx[EML] ⊆ EML

    Uses:
    - d/dx[c] = 0
    - d/dx[x] = 1
    - d/dx[f+g] = f' + g'
    - d/dx[f*g] = f'g + fg'    (product rule)
    - d/dx[exp(f)] = exp(f)*f'  (chain rule)
    - d/dx[log(f)] = f'/f        (chain rule, represented as f'*exp(-log(f)))
    """
    if isinstance(node, ConstNode):
        return ConstNode(0.0)
    elif isinstance(node, VarNode):
        return ConstNode(1.0)
    elif isinstance(node, AddNode):
        return AddNode(symbolic_derivative(node.left),
                       symbolic_derivative(node.right))
    elif isinstance(node, MulNode):
        return AddNode(
            MulNode(symbolic_derivative(node.left), node.right),
            MulNode(node.left, symbolic_derivative(node.right))
        )
    elif isinstance(node, ExpNode):
        return MulNode(ExpNode(node.child), symbolic_derivative(node.child))
    elif isinstance(node, LogNode):
        # f'/f = f' * exp(-log(f))
        return MulNode(
            symbolic_derivative(node.child),
            ExpNode(MulNode(ConstNode(-1.0), LogNode(node.child)))
        )
    raise TypeError


def compose(outer: EMLNode, inner: EMLNode) -> EMLNode:
    """Compose two EML expressions: outer(inner(x)).

    Theorem (depth_compose): depth(compose(g, h)) ≤ depth(g) + depth(h)
    """
    if isinstance(outer, ConstNode):
        return outer
    elif isinstance(outer, VarNode):
        return inner
    elif isinstance(outer, AddNode):
        return AddNode(compose(outer.left, inner), compose(outer.right, inner))
    elif isinstance(outer, MulNode):
        return MulNode(compose(outer.left, inner), compose(outer.right, inner))
    elif isinstance(outer, ExpNode):
        return ExpNode(compose(outer.child, inner))
    elif isinstance(outer, LogNode):
        return LogNode(compose(outer.child, inner))
    raise TypeError


def exp_log_power_expr(n: int) -> EMLNode:
    """Build x^(2^n) as exp(2^n * log(x)).

    Theorem (depth_expLogPower): depth = 3, independent of n.
    Theorem (eval_expLogPower_pos): evaluates to x^(2^n) for x > 0.

    Compare with repeated squaring which has depth n.
    """
    return ExpNode(MulNode(ConstNode(float(2**n)), LogNode(VarNode())))


def repeated_square_expr(n: int) -> EMLNode:
    """Build x^(2^n) via repeated squaring.

    Theorem (depth_repeatedSquare): depth = n.
    Theorem (size_repeatedSquare): size = 2^(n+1) - 1.
    """
    if n == 0:
        return VarNode()
    sub = repeated_square_expr(n - 1)
    return MulNode(sub, sub)


def polynomial_to_eml(coeffs: List[float]) -> EMLNode:
    """Convert polynomial coefficients [a_0, a_1, ..., a_n] to EML.

    The resulting expression evaluates to a_0 + a_1*x + ... + a_n*x^n.
    This demonstrates that EML contains all polynomials, which is the
    key lemma for the Stone-Weierstrass universal approximation argument.
    """
    result: EMLNode = ConstNode(0.0)
    for i, coeff in enumerate(coeffs):
        if coeff == 0.0:
            continue
        # Build x^i
        power: EMLNode = ConstNode(1.0)
        for _ in range(i):
            power = MulNode(power, VarNode())
        term = MulNode(ConstNode(coeff), power)
        result = AddNode(result, term)
    return result


def approximate_function(
    f: Callable[[float], float],
    a: float, b: float,
    n_terms: int
) -> Tuple[EMLNode, float]:
    """Approximate f on [a,b] using Chebyshev interpolation.

    Returns (eml_expr, max_error) where eml_expr is a polynomial
    EML expression and max_error is the estimated uniform error.

    Theorem (eml_uniform_approximation): For any continuous f on
    compact S and ε > 0, there exists g in the EML subalgebra with
    dist(f, g) < ε.
    """
    import numpy as np

    # Chebyshev nodes on [a, b]
    nodes = [(a + b) / 2 + (b - a) / 2 * math.cos(math.pi * (2*k + 1) / (2*n_terms))
             for k in range(n_terms)]
    values = [f(x) for x in nodes]

    # Lagrange interpolation coefficients (converted to monomial form)
    # Using numpy for numerical stability
    coeffs_np = np.polynomial.polynomial.polyfit(
        np.array(nodes), np.array(values), n_terms - 1
    )
    coeffs = coeffs_np.tolist()

    expr = polynomial_to_eml(coeffs)

    # Estimate max error on a fine grid
    test_points = [a + (b - a) * i / 1000 for i in range(1001)]
    max_error = max(abs(evaluate(expr, x) - f(x)) for x in test_points)

    return expr, max_error


if __name__ == "__main__":
    # Quick test
    print("Testing EML algorithms...")

    # Test exp-log power
    for n in range(1, 6):
        elp = exp_log_power_expr(n)
        rs = repeated_square_expr(n)
        x = 1.5
        print(f"  x^(2^{n}): exp-log={evaluate(elp, x):.4f}, "
              f"repeat={evaluate(rs, x):.4f}, "
              f"actual={x**(2**n):.4f}")

    # Test derivative
    print("\nDerivative test:")
    e = ExpNode(VarNode())
    de = symbolic_derivative(e)
    print(f"  d/dx[exp(x)] at x=1: {evaluate(de, 1.0):.6f} (expected {math.exp(1):.6f})")

    # Test approximation
    print("\nApproximation test (sin on [0, π]):")
    for n in [3, 5, 7, 10, 15]:
        expr, err = approximate_function(math.sin, 0, math.pi, n)
        print(f"  {n} terms: depth={depth(expr)}, size={size(expr)}, max_err={err:.2e}")
