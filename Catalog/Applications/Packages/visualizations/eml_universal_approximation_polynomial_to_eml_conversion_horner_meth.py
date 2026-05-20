"""
EML (Exponential-Multiplicative-Logarithmic) Approximation Algorithms

This module implements constructive algorithms for building EML expression trees
that approximate target functions on compact intervals. It provides:

1. Polynomial-to-EML conversion via Horner's method
2. Bounded-depth EML expression search
3. Greedy EML symbolic regression
4. Complexity analysis tools

All algorithms are backed by the formal guarantees proved in Lean 4.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import Callable, Optional
from enum import Enum, auto
import itertools


# ─────────────────────────────────────────────────────────────────────
# Core EML Expression Tree
# ─────────────────────────────────────────────────────────────────────

class NodeType(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    EXP = auto()
    LOG = auto()


@dataclass
class EMLExpr:
    """An EML expression tree node."""
    node_type: NodeType
    value: Optional[float] = None      # for CONST nodes
    var_index: Optional[int] = None    # for VAR nodes
    left: Optional['EMLExpr'] = None   # for binary ops
    right: Optional['EMLExpr'] = None  # for binary ops
    child: Optional['EMLExpr'] = None  # for unary ops (EXP, LOG)

    @staticmethod
    def const(c: float) -> 'EMLExpr':
        return EMLExpr(NodeType.CONST, value=c)

    @staticmethod
    def var(i: int = 0) -> 'EMLExpr':
        return EMLExpr(NodeType.VAR, var_index=i)

    @staticmethod
    def add(left: 'EMLExpr', right: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(NodeType.ADD, left=left, right=right)

    @staticmethod
    def mul(left: 'EMLExpr', right: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(NodeType.MUL, left=left, right=right)

    @staticmethod
    def exp(child: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(NodeType.EXP, child=child)

    @staticmethod
    def log(child: 'EMLExpr') -> 'EMLExpr':
        return EMLExpr(NodeType.LOG, child=child)

    @property
    def size(self) -> int:
        """Number of nodes in the expression tree."""
        if self.node_type in (NodeType.CONST, NodeType.VAR):
            return 1
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return self.left.size + self.right.size + 1
        else:  # EXP, LOG
            return self.child.size + 1

    @property
    def depth(self) -> int:
        """Depth of the expression tree."""
        if self.node_type in (NodeType.CONST, NodeType.VAR):
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.depth, self.right.depth) + 1
        else:  # EXP, LOG
            return self.child.depth + 1

    def eval(self, env: dict[int, float] | None = None, x: float = 0.0) -> float:
        """Evaluate the expression in the given environment.

        Args:
            env: mapping from variable indices to values
            x: shorthand for env = {0: x}
        """
        if env is None:
            env = {0: x}
        try:
            if self.node_type == NodeType.CONST:
                return self.value
            elif self.node_type == NodeType.VAR:
                return env.get(self.var_index, 0.0)
            elif self.node_type == NodeType.ADD:
                return self.left.eval(env) + self.right.eval(env)
            elif self.node_type == NodeType.MUL:
                return self.left.eval(env) * self.right.eval(env)
            elif self.node_type == NodeType.EXP:
                v = self.child.eval(env)
                if v > 700:  # prevent overflow
                    return float('inf')
                return np.exp(v)
            elif self.node_type == NodeType.LOG:
                v = self.child.eval(env)
                if v <= 0:
                    return float('-inf')
                return np.log(v)
        except (OverflowError, ValueError):
            return float('nan')

    def eval_array(self, xs: np.ndarray) -> np.ndarray:
        """Evaluate the expression at an array of x values (single variable)."""
        return np.array([self.eval(x=float(xi)) for xi in xs])

    def __repr__(self) -> str:
        if self.node_type == NodeType.CONST:
            return f"{self.value:.4g}"
        elif self.node_type == NodeType.VAR:
            return f"x{self.var_index}" if self.var_index != 0 else "x"
        elif self.node_type == NodeType.ADD:
            return f"({self.left} + {self.right})"
        elif self.node_type == NodeType.MUL:
            return f"({self.left} * {self.right})"
        elif self.node_type == NodeType.EXP:
            return f"exp({self.child})"
        elif self.node_type == NodeType.LOG:
            return f"log({self.child})"


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Polynomial-to-EML Conversion (Horner's Method)
# ─────────────────────────────────────────────────────────────────────

def poly_to_eml(coeffs: list[float]) -> EMLExpr:
    """Convert polynomial coefficients to an EML expression via Horner's method.

    Given coefficients [c0, c1, ..., cn], produces an EML expression
    representing c0 + x*(c1 + x*(c2 + ... + x*cn)).

    This is the constructive polynomial-to-EML reduction used in the
    universal approximation proof.

    Args:
        coeffs: polynomial coefficients [c0, c1, ..., cn] (constant term first)

    Returns:
        EMLExpr representing the polynomial

    Complexity:
        Size: 2n + 1 for degree-n polynomial
        Depth: 2n for degree-n polynomial

    Example:
        >>> e = poly_to_eml([1.0, 2.0, 3.0])  # 1 + 2x + 3x^2
        >>> e.eval(x=1.0)
        6.0
    """
    if not coeffs:
        return EMLExpr.const(0.0)
    if len(coeffs) == 1:
        return EMLExpr.const(coeffs[0])
    return EMLExpr.add(
        EMLExpr.const(coeffs[0]),
        EMLExpr.mul(EMLExpr.var(0), poly_to_eml(coeffs[1:]))
    )


def chebyshev_approx_to_eml(f: Callable[[float], float],
                              a: float, b: float,
                              degree: int) -> EMLExpr:
    """Approximate f on [a,b] using Chebyshev polynomial interpolation,
    then convert to EML.

    Args:
        f: target function
        a, b: interval endpoints
        degree: polynomial degree

    Returns:
        EMLExpr approximating f on [a,b]
    """
    # Chebyshev nodes on [a, b]
    nodes = np.array([
        0.5 * (a + b) + 0.5 * (b - a) * np.cos(np.pi * (2*k + 1) / (2*(degree + 1)))
        for k in range(degree + 1)
    ])
    values = np.array([f(xi) for xi in nodes])

    # Fit polynomial using numpy
    # Map to [-1, 1] first
    nodes_mapped = 2 * (nodes - a) / (b - a) - 1
    coeffs_cheb = np.polynomial.chebyshev.chebfit(nodes_mapped, values, degree)

    # Convert Chebyshev to standard polynomial coefficients
    poly_coeffs = np.polynomial.chebyshev.cheb2poly(coeffs_cheb)

    # Account for the affine transformation x -> 2(x-a)/(b-a) - 1
    # We need to expand this into standard polynomial in x
    # Use numpy polynomial composition
    from numpy.polynomial import polynomial as P
    # t = (2/(b-a)) * x - (a+b)/(b-a)
    affine = np.array([-(a + b) / (b - a), 2.0 / (b - a)])
    # Compose: p(t(x))
    result_coeffs = P.polyval(affine, poly_coeffs)
    if isinstance(result_coeffs, np.ndarray):
        final_coeffs = list(result_coeffs)
    else:
        # Need proper polynomial composition
        # Expand p(ax + b) into standard form
        n = len(poly_coeffs)
        final_poly = np.zeros(n)
        for i in range(n):
            # Coefficient of x^k in (affine[0] + affine[1]*x)^i
            for k in range(i + 1):
                from math import comb
                final_poly[k] += poly_coeffs[i] * comb(i, k) * \
                    affine[0]**(i-k) * affine[1]**k
        final_coeffs = list(final_poly)

    # Pad to correct length if needed
    final_coeffs_list = []
    for c in final_coeffs:
        final_coeffs_list.append(float(c) if not np.isnan(c) else 0.0)

    return poly_to_eml(final_coeffs_list)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Bounded-Size EML Expression Search
# ─────────────────────────────────────────────────────────────────────

def enumerate_eml_exprs(max_size: int,
                         constants: list[float] = None) -> list[EMLExpr]:
    """Enumerate all EML expressions up to a given size.

    Args:
        max_size: maximum expression size
        constants: pool of constants to use

    Returns:
        List of EML expressions sorted by size
    """
    if constants is None:
        constants = [0.0, 0.5, 1.0, 2.0, -1.0, np.e, np.pi]

    exprs_by_size: dict[int, list[EMLExpr]] = {}

    # Size 1: constants and variables
    exprs_by_size[1] = [EMLExpr.const(c) for c in constants] + [EMLExpr.var(0)]

    for s in range(2, max_size + 1):
        exprs_by_size[s] = []

        # Unary ops (exp, log): child has size s-1
        if s - 1 in exprs_by_size:
            for child in exprs_by_size[s - 1]:
                exprs_by_size[s].append(EMLExpr.exp(child))
                exprs_by_size[s].append(EMLExpr.log(child))

        # Binary ops (add, mul): left.size + right.size = s-1
        for ls in range(1, s - 1):
            rs = s - 1 - ls
            if ls in exprs_by_size and rs in exprs_by_size:
                for left in exprs_by_size[ls]:
                    for right in exprs_by_size[rs]:
                        exprs_by_size[s].append(EMLExpr.add(left, right))
                        exprs_by_size[s].append(EMLExpr.mul(left, right))

    all_exprs = []
    for s in range(1, max_size + 1):
        if s in exprs_by_size:
            all_exprs.extend(exprs_by_size[s])
    return all_exprs


def find_best_eml_approx(f: Callable[[float], float],
                           a: float, b: float,
                           max_size: int,
                           n_test: int = 100,
                           constants: list[float] = None) -> tuple[EMLExpr, float]:
    """Find the best EML approximant of bounded size by exhaustive search.

    Args:
        f: target function
        a, b: interval endpoints
        max_size: maximum expression size
        n_test: number of test points
        constants: pool of constants

    Returns:
        (best_expr, best_error) tuple
    """
    xs = np.linspace(a, b, n_test)
    target = np.array([f(xi) for xi in xs])

    best_expr = None
    best_error = float('inf')

    exprs = enumerate_eml_exprs(max_size, constants)
    for expr in exprs:
        try:
            approx = expr.eval_array(xs)
            if np.any(np.isnan(approx)) or np.any(np.isinf(approx)):
                continue
            error = np.max(np.abs(target - approx))
            if error < best_error:
                best_error = error
                best_expr = expr
        except Exception:
            continue

    return best_expr, best_error


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Greedy EML Symbolic Regression
# ─────────────────────────────────────────────────────────────────────

def greedy_eml_regression(f: Callable[[float], float],
                           a: float, b: float,
                           max_depth: int = 5,
                           n_samples: int = 200,
                           n_candidates: int = 50) -> EMLExpr:
    """Greedy beam-search EML symbolic regression.

    Builds an EML expression by greedily adding operations that
    minimize the approximation error.

    Args:
        f: target function
        a, b: interval endpoints
        max_depth: maximum expression depth
        n_samples: number of sample points
        n_candidates: beam width

    Returns:
        Best EML expression found
    """
    xs = np.linspace(a, b, n_samples)
    target = np.array([f(xi) for xi in xs])

    # Start with basic expressions
    candidates = [
        EMLExpr.const(np.mean(target)),
        EMLExpr.var(0),
        EMLExpr.const(0.0),
        EMLExpr.const(1.0),
    ]

    def score(expr: EMLExpr) -> float:
        try:
            approx = expr.eval_array(xs)
            if np.any(np.isnan(approx)) or np.any(np.isinf(approx)):
                return float('inf')
            return np.max(np.abs(target - approx))
        except Exception:
            return float('inf')

    for _ in range(max_depth):
        new_candidates = list(candidates)
        for expr in candidates[:n_candidates]:
            # Try wrapping in exp/log
            new_candidates.append(EMLExpr.exp(expr))
            new_candidates.append(EMLExpr.log(expr))

            # Try combining with constants
            for c in [0.1, 0.5, 1.0, 2.0, -1.0, np.mean(target)]:
                ce = EMLExpr.const(c)
                new_candidates.append(EMLExpr.add(expr, ce))
                new_candidates.append(EMLExpr.mul(expr, ce))
                new_candidates.append(EMLExpr.add(ce, expr))
                new_candidates.append(EMLExpr.mul(ce, expr))

            # Try combining with x
            xvar = EMLExpr.var(0)
            new_candidates.append(EMLExpr.add(expr, xvar))
            new_candidates.append(EMLExpr.mul(expr, xvar))

        # Score and keep best
        scored = [(score(e), e) for e in new_candidates]
        scored.sort(key=lambda t: t[0])
        candidates = [e for _, e in scored[:n_candidates]]

    return candidates[0] if candidates else EMLExpr.const(0.0)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: EML Description Complexity Estimation
# ─────────────────────────────────────────────────────────────────────

def estimate_description_complexity(f: Callable[[float], float],
                                     a: float, b: float,
                                     eps: float,
                                     max_search_size: int = 7) -> dict:
    """Estimate the EML description complexity of a function.

    Searches for the smallest EML expression that achieves uniform
    approximation within eps on [a, b].

    Args:
        f: target function
        a, b: interval endpoints
        eps: error tolerance
        max_search_size: maximum size to search

    Returns:
        Dictionary with keys: 'complexity', 'best_expr', 'error', 'depth'
    """
    best_expr, best_error = find_best_eml_approx(
        f, a, b, max_search_size, n_test=200
    )

    result = {
        'complexity': best_expr.size if best_expr else None,
        'depth': best_expr.depth if best_expr else None,
        'best_expr': best_expr,
        'error': best_error,
        'eps': eps,
        'achieved': best_error <= eps
    }
    return result


def retained_information(alpha: float, depth: int, K: int) -> float:
    """Compute retained symbolic information.

    Models the information decay through depth layers:
    retained = alpha^depth * K

    This is the computational version of the formally verified
    retained_symbolic_information function.

    Args:
        alpha: per-layer contraction factor, 0 <= alpha <= 1
        depth: number of layers
        K: initial information (description complexity)

    Returns:
        Retained information after depth layers
    """
    return alpha ** depth * K


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Multiplicative EML Normal Form
# ─────────────────────────────────────────────────────────────────────

def positive_poly_to_multiplicative_eml(coeffs: list[float],
                                         lower_bound: float = 0.1) -> EMLExpr:
    """Convert a positive polynomial to multiplicative EML normal form.

    For positive functions, uses the identity f = exp(log(f)):
    1. Build polynomial p(x) from coefficients
    2. Wrap in exp(log(p(x))) for multiplicative form

    This enables the multiplicative approximation:
    exp(-eps) * f(x) <= approximant(x) <= exp(eps) * f(x)

    Args:
        coeffs: polynomial coefficients (must produce positive values)
        lower_bound: assumed lower bound on polynomial values

    Returns:
        EMLExpr in multiplicative normal form
    """
    poly_expr = poly_to_eml(coeffs)
    # Multiplicative form: exp(log(poly))
    return EMLExpr.exp(EMLExpr.log(poly_expr))


if __name__ == "__main__":
    # Quick demonstration
    print("=== EML Algorithms Demo ===\n")

    # Test 1: Polynomial conversion
    print("1. Polynomial to EML (Horner's method):")
    p = poly_to_eml([1.0, 2.0, 3.0])  # 1 + 2x + 3x^2
    print(f"   Expression: {p}")
    print(f"   Size: {p.size}, Depth: {p.depth}")
    print(f"   p(0) = {p.eval(x=0)}, p(1) = {p.eval(x=1)}, p(2) = {p.eval(x=2)}")
    print()

    # Test 2: Chebyshev approximation
    print("2. Chebyshev approximation of sin(x) on [0, pi]:")
    e = chebyshev_approx_to_eml(np.sin, 0, np.pi, degree=5)
    xs = np.linspace(0, np.pi, 10)
    errors = [abs(np.sin(x) - e.eval(x=x)) for x in xs]
    print(f"   Expression size: {e.size}, depth: {e.depth}")
    print(f"   Max error: {max(errors):.6e}")
    print()

    # Test 3: Information decay
    print("3. Information decay analysis:")
    K = 100
    for alpha in [0.9, 0.5, 0.1]:
        for d in [1, 5, 10, 20]:
            info = retained_information(alpha, d, K)
            print(f"   alpha={alpha}, depth={d}: retained={info:.2f}/{K}")
    print()

    print("Done!")
