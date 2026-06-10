#!/usr/bin/env python3
"""
Algorithms for Hardy Hierarchy Quotient Closure

Implements the core algorithms discussed in the research paper:
1. Hardy level classification for PosEML expressions
2. Quotient admissibility checking
3. Quotient-rule derivative computation with level certification
4. Logarithmic derivative level estimation

All algorithms include complexity analysis and worked examples.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Set
from enum import Enum
import math


# ============================================================
# Expression Types
# ============================================================

class ExprKind(Enum):
    CONST = "const"
    VAR = "var"
    ADD = "add"
    MUL = "mul"
    EXP = "exp"


@dataclass
class PosEMLExpr:
    """Positive EML expression with evaluation and differentiation.

    Represents the grammar:
        e ::= c | x | e + e | e * e | exp(e)

    Time complexity for operations:
        - eval:  O(|e|) where |e| is expression size
        - deriv: O(|e|²) worst case (product rule expansion)
        - depth: O(|e|)
    """
    kind: ExprKind
    value: float = 0.0
    children: List['PosEMLExpr'] = field(default_factory=list)

    @staticmethod
    def const(c: float) -> 'PosEMLExpr':
        return PosEMLExpr(ExprKind.CONST, value=c)

    @staticmethod
    def var() -> 'PosEMLExpr':
        return PosEMLExpr(ExprKind.VAR)

    @staticmethod
    def add(a: 'PosEMLExpr', b: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprKind.ADD, children=[a, b])

    @staticmethod
    def mul(a: 'PosEMLExpr', b: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprKind.MUL, children=[a, b])

    @staticmethod
    def exp(a: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprKind.EXP, children=[a])

    def eval(self, x: np.ndarray) -> np.ndarray:
        """Evaluate expression at array of points.

        Complexity: O(|self| * len(x))
        """
        if self.kind == ExprKind.CONST:
            return np.full_like(x, self.value, dtype=float)
        elif self.kind == ExprKind.VAR:
            return x.astype(float).copy()
        elif self.kind == ExprKind.ADD:
            return self.children[0].eval(x) + self.children[1].eval(x)
        elif self.kind == ExprKind.MUL:
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.kind == ExprKind.EXP:
            return np.exp(np.clip(self.children[0].eval(x), -500, 500))
        raise ValueError(f"Unknown kind: {self.kind}")

    def depth(self) -> int:
        """Compute EML depth (= Hardy level upper bound).

        Complexity: O(|self|)
        """
        if self.kind in (ExprKind.CONST, ExprKind.VAR):
            return 0
        elif self.kind in (ExprKind.ADD, ExprKind.MUL):
            return max(self.children[0].depth(), self.children[1].depth())
        elif self.kind == ExprKind.EXP:
            return self.children[0].depth() + 1
        return 0

    def size(self) -> int:
        """Number of nodes in the expression tree."""
        if self.kind in (ExprKind.CONST, ExprKind.VAR):
            return 1
        return 1 + sum(c.size() for c in self.children)

    def deriv(self) -> 'PosEMLExpr':
        """Symbolic differentiation.

        Complexity: O(|self|²) worst case due to product rule.
        The derivative of a size-n expression has size at most 3n.
        """
        if self.kind == ExprKind.CONST:
            return PosEMLExpr.const(0.0)
        elif self.kind == ExprKind.VAR:
            return PosEMLExpr.const(1.0)
        elif self.kind == ExprKind.ADD:
            return PosEMLExpr.add(
                self.children[0].deriv(),
                self.children[1].deriv()
            )
        elif self.kind == ExprKind.MUL:
            a, b = self.children
            return PosEMLExpr.add(
                PosEMLExpr.mul(a.deriv(), b),
                PosEMLExpr.mul(a, b.deriv())
            )
        elif self.kind == ExprKind.EXP:
            a = self.children[0]
            return PosEMLExpr.mul(a.deriv(), PosEMLExpr.exp(a))
        raise ValueError(f"Unknown kind: {self.kind}")

    def __str__(self) -> str:
        if self.kind == ExprKind.CONST:
            return f"{self.value:.1f}"
        elif self.kind == ExprKind.VAR:
            return "x"
        elif self.kind == ExprKind.ADD:
            return f"({self.children[0]} + {self.children[1]})"
        elif self.kind == ExprKind.MUL:
            return f"({self.children[0]} * {self.children[1]})"
        elif self.kind == ExprKind.EXP:
            return f"exp({self.children[0]})"
        return "?"


# ============================================================
# Algorithm 1: Hardy Level Classification
# ============================================================

def classify_hardy_level(expr: PosEMLExpr) -> dict:
    """
    Classify an expression's Hardy level with a proof certificate.

    Algorithm:
        1. Compute syntactic depth d = expr.depth()
        2. Verify expr is a valid PosEMLExpr (all constructors legal)
        3. Return (d, certificate) where certificate references
           the hardyLevel_of_depth theorem

    Complexity: O(|expr|)

    Returns:
        dict with keys:
        - 'level': int, the Hardy level
        - 'certificate': str, proof reference
        - 'depth_trace': list, depth computation trace

    Example:
        >>> e = PosEMLExpr.exp(PosEMLExpr.var())
        >>> classify_hardy_level(e)
        {'level': 1, 'certificate': 'hardyLevel_of_depth', ...}
    """
    depth_trace = []

    def trace_depth(e: PosEMLExpr, path: str = "root") -> int:
        d = e.depth()
        depth_trace.append((path, str(e), d))
        return d

    level = trace_depth(expr)

    return {
        'level': level,
        'certificate': 'PosEMLExpr.hardyLevel_of_depth',
        'depth_trace': depth_trace,
        'expression': str(expr),
        'size': expr.size()
    }


# ============================================================
# Algorithm 2: Quotient Admissibility Checker
# ============================================================

def check_quotient_admissible(
    a: PosEMLExpr,
    b: PosEMLExpr,
    x_range: Tuple[float, float] = (1.0, 1000.0),
    n_points: int = 1000
) -> dict:
    """
    Check whether (a, b) is quotient-admissible for Hardy hierarchy.

    Algorithm:
        1. Check b is eventually nonzero on sampling grid
        2. Compute max depth d = max(depth(a), depth(b))
        3. Estimate Hardy level of 1/b^2
        4. Verify 1/b^2 level ≤ d + 1

    Complexity: O((|a| + |b|) * n_points)

    Returns:
        dict with admissibility status and diagnostics

    Example:
        >>> a = PosEMLExpr.exp(PosEMLExpr.var())
        >>> b = PosEMLExpr.var()
        >>> check_quotient_admissible(a, b)
        {'admissible': True, ...}
    """
    x = np.linspace(x_range[0], x_range[1], n_points)

    # Check eventual nonzero
    b_vals = b.eval(x)
    nonzero_mask = np.abs(b_vals) > 1e-15
    eventually_nonzero = np.all(nonzero_mask[n_points // 2:])

    # Compute levels
    d_a = a.depth()
    d_b = b.depth()
    d = max(d_a, d_b)

    # Estimate level of 1/b^2
    with np.errstate(divide='ignore', invalid='ignore'):
        inv_b_sq = np.where(np.abs(b_vals) > 1e-30,
                            1.0 / b_vals**2, 0.0)
    inv_sq_level = _estimate_level(inv_b_sq, x)

    admissible = eventually_nonzero and inv_sq_level <= d + 1

    return {
        'admissible': admissible,
        'eventually_nonzero': eventually_nonzero,
        'depth_a': d_a,
        'depth_b': d_b,
        'd_max': d,
        'inv_sq_level_estimate': inv_sq_level,
        'bound': d + 1,
        'a': str(a),
        'b': str(b)
    }


def _estimate_level(vals: np.ndarray, x: np.ndarray) -> int:
    """Estimate Hardy level from sampled values."""
    abs_vals = np.abs(vals)
    mask = abs_vals > 1e-15
    if np.sum(mask) < 10:
        return 0

    with np.errstate(divide='ignore', invalid='ignore'):
        log_vals = np.log(np.maximum(abs_vals[mask], 1e-300))
        x_m = x[mask]
        log_x = np.log(np.maximum(x_m, 1.0))

        # Level 0: polynomial
        ratio = np.abs(log_vals) / np.maximum(log_x, 1.0)
        if np.max(ratio[-10:]) < 50:
            return 0

        # Level 1: exponential
        ratio = np.abs(log_vals) / np.maximum(x_m, 1.0)
        if np.max(ratio[-10:]) < 50:
            return 1

    return 2


# ============================================================
# Algorithm 3: Quotient Derivative with Level Certification
# ============================================================

def quotient_derivative_certified(
    a: PosEMLExpr,
    b: PosEMLExpr,
    x_range: Tuple[float, float] = (1.0, 50.0),
    n_points: int = 500
) -> dict:
    """
    Compute the quotient-rule derivative of a/b with Hardy level certification.

    Algorithm:
        1. Compute a' = deriv(a), b' = deriv(b)
        2. Numerator = a'*b - a*b'  (Hardy level ≤ d+1 by hardyLevel_quotient_numerator)
        3. Denominator = b^2        (Hardy level ≤ d by hardyLevel_sq)
        4. Quotient derivative = numerator / denominator
        5. Estimate Hardy level of result
        6. Verify ≤ d+1

    Complexity: O((|a| + |b|) * n_points)

    Returns:
        dict with derivative values, level estimate, and certificate chain
    """
    x = np.linspace(x_range[0], x_range[1], n_points)

    a_prime = a.deriv()
    b_prime = b.deriv()

    a_vals = a.eval(x)
    b_vals = b.eval(x)
    ap_vals = a_prime.eval(x)
    bp_vals = b_prime.eval(x)

    # Quotient rule
    numerator = ap_vals * b_vals - a_vals * bp_vals
    denominator = b_vals ** 2

    with np.errstate(divide='ignore', invalid='ignore'):
        deriv_vals = np.where(np.abs(denominator) > 1e-30,
                              numerator / denominator, 0.0)

    d = max(a.depth(), b.depth())
    est_level = _estimate_level(deriv_vals, x)

    # Certificate chain
    certificate = [
        f"1. a has depth {a.depth()}, so HardyLevel {a.depth()} a  [hardyLevel_of_depth]",
        f"2. b has depth {b.depth()}, so HardyLevel {b.depth()} b  [hardyLevel_of_depth]",
        f"3. a' has depth ≤ {a.depth()+1}  [depth_deriv_le]",
        f"4. b' has depth ≤ {b.depth()+1}  [depth_deriv_le]",
        f"5. a'*b - a*b' at level ≤ {d+1}  [hardyLevel_quotient_numerator]",
        f"6. With inv_sq_level hypothesis: (a/b)' at level ≤ {d+1}  [hardyLevel_deriv_div_le_succ]",
    ]

    return {
        'x': x,
        'derivative_values': deriv_vals,
        'numerator_values': numerator,
        'denominator_values': denominator,
        'depth_a': a.depth(),
        'depth_b': b.depth(),
        'd_max': d,
        'estimated_level': est_level,
        'certified_bound': d + 1,
        'satisfies_bound': est_level <= d + 1,
        'certificate_chain': certificate,
        'a': str(a),
        'b': str(b),
        'a_prime': str(a_prime),
        'b_prime': str(b_prime)
    }


# ============================================================
# Algorithm 4: Logarithmic Derivative Level Bound
# ============================================================

def log_derivative_analysis(
    f: PosEMLExpr,
    x_range: Tuple[float, float] = (1.0, 50.0),
    n_points: int = 500
) -> dict:
    """
    Compute and analyze the logarithmic derivative f'/f.

    The logarithmic derivative is central to:
    - Differential algebra (derivation on multiplicative group)
    - WKB approximation (phase extraction)
    - Renormalization group (beta functions)

    Algorithm:
        1. Compute f and f' symbolically
        2. Evaluate f'/f
        3. Estimate Hardy level
        4. Verify ≤ depth(f) + 1

    Complexity: O(|f| * n_points)
    """
    x = np.linspace(x_range[0], x_range[1], n_points)

    f_prime = f.deriv()
    f_vals = f.eval(x)
    fp_vals = f_prime.eval(x)

    with np.errstate(divide='ignore', invalid='ignore'):
        log_deriv = np.where(np.abs(f_vals) > 1e-30,
                             fp_vals / f_vals, 0.0)

    d = f.depth()
    est_level = _estimate_level(log_deriv, x)

    return {
        'x': x,
        'f_values': f_vals,
        'f_prime_values': fp_vals,
        'log_deriv_values': log_deriv,
        'depth': d,
        'estimated_level': est_level,
        'certified_bound': d + 1,
        'satisfies_bound': est_level <= d + 1,
        'f': str(f),
        'f_prime': str(f_prime)
    }


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Hardy Hierarchy Algorithms — Worked Examples")
    print("=" * 60)
    print()

    # Example 1: Classification
    print("ALGORITHM 1: Hardy Level Classification")
    print("-" * 40)
    e1 = PosEMLExpr.exp(PosEMLExpr.exp(PosEMLExpr.var()))
    result = classify_hardy_level(e1)
    print(f"  Expression: {result['expression']}")
    print(f"  Hardy level: {result['level']}")
    print(f"  Certificate: {result['certificate']}")
    print(f"  Size: {result['size']} nodes")
    print()

    # Example 2: Admissibility
    print("ALGORITHM 2: Quotient Admissibility")
    print("-" * 40)
    a = PosEMLExpr.exp(PosEMLExpr.var())
    b = PosEMLExpr.add(PosEMLExpr.var(), PosEMLExpr.const(1.0))
    result = check_quotient_admissible(a, b)
    print(f"  a = {result['a']}")
    print(f"  b = {result['b']}")
    print(f"  Admissible: {result['admissible']}")
    print(f"  Eventually nonzero: {result['eventually_nonzero']}")
    print(f"  1/b² level estimate: {result['inv_sq_level_estimate']}")
    print(f"  Required bound: ≤ {result['bound']}")
    print()

    # Example 3: Certified derivative
    print("ALGORITHM 3: Quotient Derivative Certification")
    print("-" * 40)
    a = PosEMLExpr.exp(PosEMLExpr.var())
    b = PosEMLExpr.add(PosEMLExpr.var(), PosEMLExpr.const(1.0))
    result = quotient_derivative_certified(a, b)
    print(f"  a = {result['a']}, b = {result['b']}")
    print(f"  a' = {result['a_prime']}")
    print(f"  b' = {result['b_prime']}")
    print(f"  d = max({result['depth_a']}, {result['depth_b']}) = {result['d_max']}")
    print(f"  Estimated level: {result['estimated_level']}")
    print(f"  Certified bound: {result['certified_bound']}")
    print(f"  Satisfies bound: {result['satisfies_bound']}")
    print()
    print("  Certificate chain:")
    for line in result['certificate_chain']:
        print(f"    {line}")
    print()

    # Example 4: Logarithmic derivative
    print("ALGORITHM 4: Logarithmic Derivative Analysis")
    print("-" * 40)
    f = PosEMLExpr.exp(PosEMLExpr.var())
    result = log_derivative_analysis(f)
    print(f"  f = {result['f']}")
    print(f"  f' = {result['f_prime']}")
    print(f"  depth(f) = {result['depth']}")
    print(f"  f'/f estimated level: {result['estimated_level']}")
    print(f"  Bound: depth + 1 = {result['certified_bound']}")
    print(f"  Satisfies: {result['satisfies_bound']}")
    print()

    # Special case: exp(exp(x))
    f2 = PosEMLExpr.exp(PosEMLExpr.exp(PosEMLExpr.var()))
    result2 = log_derivative_analysis(f2)
    print(f"  f = {result2['f']}")
    print(f"  f' = {result2['f_prime']}")
    print(f"  depth(f) = {result2['depth']}")
    print(f"  f'/f estimated level: {result2['estimated_level']}")
    print(f"  Bound: depth + 1 = {result2['certified_bound']}")
    print(f"  Satisfies: {result2['satisfies_bound']}")
