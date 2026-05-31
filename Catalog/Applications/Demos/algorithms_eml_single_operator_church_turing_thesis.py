#!/usr/bin/env python3
"""
EML Church-Turing Thesis: Core Algorithms

Type-hinted implementations of EML expression evaluation, compilation,
and approximation algorithms.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Dict, List, Optional, Tuple
import math


# ============================================================
# EML Expression AST
# ============================================================

class EMLNodeType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    SUB = auto()
    DIV = auto()
    EXP = auto()
    LOG = auto()


@dataclass
class EMLExpr:
    """An expression in the EML (Exp-Multiply-Log) language."""
    node_type: EMLNodeType
    value: Optional[float] = None      # For CONST
    var_index: Optional[int] = None    # For VAR
    left: Optional[EMLExpr] = None     # For binary ops
    right: Optional[EMLExpr] = None    # For binary ops
    child: Optional[EMLExpr] = None    # For unary ops (EXP, LOG)

    @staticmethod
    def var(i: int) -> EMLExpr:
        return EMLExpr(EMLNodeType.VAR, var_index=i)

    @staticmethod
    def const(c: float) -> EMLExpr:
        return EMLExpr(EMLNodeType.CONST, value=c)

    @staticmethod
    def add(a: EMLExpr, b: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.ADD, left=a, right=b)

    @staticmethod
    def mul(a: EMLExpr, b: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.MUL, left=a, right=b)

    @staticmethod
    def sub(a: EMLExpr, b: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.SUB, left=a, right=b)

    @staticmethod
    def div(a: EMLExpr, b: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.DIV, left=a, right=b)

    @staticmethod
    def exp(e: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.EXP, child=e)

    @staticmethod
    def log(e: EMLExpr) -> EMLExpr:
        return EMLExpr(EMLNodeType.LOG, child=e)

    def eval(self, sigma: Dict[int, float]) -> float:
        """Evaluate the expression given variable assignment sigma."""
        if self.node_type == EMLNodeType.VAR:
            return sigma.get(self.var_index, 0.0)
        elif self.node_type == EMLNodeType.CONST:
            return self.value
        elif self.node_type == EMLNodeType.ADD:
            return self.left.eval(sigma) + self.right.eval(sigma)
        elif self.node_type == EMLNodeType.MUL:
            return self.left.eval(sigma) * self.right.eval(sigma)
        elif self.node_type == EMLNodeType.SUB:
            return self.left.eval(sigma) - self.right.eval(sigma)
        elif self.node_type == EMLNodeType.DIV:
            r = self.right.eval(sigma)
            return self.left.eval(sigma) / r if r != 0 else float('inf')
        elif self.node_type == EMLNodeType.EXP:
            v = self.child.eval(sigma)
            return math.exp(min(v, 700))  # Prevent overflow
        elif self.node_type == EMLNodeType.LOG:
            v = self.child.eval(sigma)
            return math.log(v) if v > 0 else 0.0  # Lean convention: log(x) = 0 for x ≤ 0
        else:
            raise ValueError(f"Unknown node type: {self.node_type}")

    @property
    def depth(self) -> int:
        """Transcendental nesting depth."""
        if self.node_type in (EMLNodeType.VAR, EMLNodeType.CONST):
            return 0
        elif self.node_type in (EMLNodeType.ADD, EMLNodeType.MUL, EMLNodeType.SUB, EMLNodeType.DIV):
            return max(self.left.depth, self.right.depth)
        elif self.node_type in (EMLNodeType.EXP, EMLNodeType.LOG):
            return self.child.depth + 1
        return 0

    @property
    def size(self) -> int:
        """Total number of nodes."""
        if self.node_type in (EMLNodeType.VAR, EMLNodeType.CONST):
            return 1
        elif self.node_type in (EMLNodeType.ADD, EMLNodeType.MUL, EMLNodeType.SUB, EMLNodeType.DIV):
            return self.left.size + self.right.size + 1
        elif self.node_type in (EMLNodeType.EXP, EMLNodeType.LOG):
            return self.child.size + 1
        return 1

    @property
    def transc_count(self) -> int:
        """Number of exp/log nodes."""
        if self.node_type in (EMLNodeType.VAR, EMLNodeType.CONST):
            return 0
        elif self.node_type in (EMLNodeType.ADD, EMLNodeType.MUL, EMLNodeType.SUB, EMLNodeType.DIV):
            return self.left.transc_count + self.right.transc_count
        elif self.node_type in (EMLNodeType.EXP, EMLNodeType.LOG):
            return self.child.transc_count + 1
        return 0

    def subst(self, i: int, e_prime: EMLExpr) -> EMLExpr:
        """Substitute variable i with expression e_prime."""
        if self.node_type == EMLNodeType.VAR:
            return e_prime if self.var_index == i else self
        elif self.node_type == EMLNodeType.CONST:
            return self
        elif self.node_type in (EMLNodeType.ADD, EMLNodeType.MUL, EMLNodeType.SUB, EMLNodeType.DIV):
            new_left = self.left.subst(i, e_prime)
            new_right = self.right.subst(i, e_prime)
            return EMLExpr(self.node_type, left=new_left, right=new_right)
        elif self.node_type in (EMLNodeType.EXP, EMLNodeType.LOG):
            new_child = self.child.subst(i, e_prime)
            return EMLExpr(self.node_type, child=new_child)
        return self

    def __repr__(self) -> str:
        if self.node_type == EMLNodeType.VAR:
            return f"x{self.var_index}"
        elif self.node_type == EMLNodeType.CONST:
            return f"{self.value}"
        elif self.node_type == EMLNodeType.ADD:
            return f"({self.left} + {self.right})"
        elif self.node_type == EMLNodeType.MUL:
            return f"({self.left} * {self.right})"
        elif self.node_type == EMLNodeType.SUB:
            return f"({self.left} - {self.right})"
        elif self.node_type == EMLNodeType.DIV:
            return f"({self.left} / {self.right})"
        elif self.node_type == EMLNodeType.EXP:
            return f"exp({self.child})"
        elif self.node_type == EMLNodeType.LOG:
            return f"log({self.child})"
        return "?"


# ============================================================
# EML Compilation: Functions → EML Expressions
# ============================================================

def compile_polynomial(coeffs: List[float]) -> EMLExpr:
    """
    Compile a polynomial p(x) = coeffs[0] + coeffs[1]*x + coeffs[2]*x² + ...
    into an EML expression using Horner's method.
    
    Algorithm (Horner's method):
        p(x) = c₀ + x(c₁ + x(c₂ + ... + x·cₙ))
    
    This produces an EML expression of depth 0 (purely algebraic) and
    size O(n) where n is the degree.
    """
    if not coeffs:
        return EMLExpr.const(0.0)
    
    x = EMLExpr.var(0)
    # Horner's method: start from highest degree
    result = EMLExpr.const(coeffs[-1])
    for i in range(len(coeffs) - 2, -1, -1):
        result = EMLExpr.add(EMLExpr.const(coeffs[i]), EMLExpr.mul(x, result))
    
    return result


def compile_power(n: int) -> EMLExpr:
    """
    Compile x^n via exp(n * log(x)).
    Produces an EML expression of depth 2.
    """
    x = EMLExpr.var(0)
    return EMLExpr.exp(EMLExpr.mul(EMLExpr.const(float(n)), EMLExpr.log(x)))


def compile_product() -> EMLExpr:
    """
    Compile x₀ * x₁ via exp(log(x₀) + log(x₁)).
    Produces an EML expression of depth 2.
    """
    return EMLExpr.exp(EMLExpr.add(EMLExpr.log(EMLExpr.var(0)), EMLExpr.log(EMLExpr.var(1))))


def compile_reciprocal() -> EMLExpr:
    """
    Compile 1/x₀ via exp(-log(x₀)).
    Produces an EML expression of depth 2.
    """
    return EMLExpr.exp(EMLExpr.sub(EMLExpr.const(0.0), EMLExpr.log(EMLExpr.var(0))))


def compile_sqrt() -> EMLExpr:
    """
    Compile √x₀ via exp(log(x₀) / 2).
    Produces an EML expression of depth 2.
    """
    return EMLExpr.exp(EMLExpr.div(EMLExpr.log(EMLExpr.var(0)), EMLExpr.const(2.0)))


# ============================================================
# Function Approximation
# ============================================================

def chebyshev_nodes(n: int, a: float, b: float) -> List[float]:
    """Compute n Chebyshev nodes on [a, b]."""
    return [
        (a + b) / 2 + (b - a) / 2 * math.cos((2*k + 1) * math.pi / (2*n))
        for k in range(n)
    ]


def chebyshev_coefficients(f: Callable[[float], float], n: int, a: float, b: float) -> List[float]:
    """
    Compute polynomial coefficients for Chebyshev interpolation of f on [a, b].
    Returns coefficients in monomial basis.
    """
    nodes = chebyshev_nodes(n, a, b)
    values = [f(x) for x in nodes]
    
    # Convert to monomial coefficients via Newton's divided differences
    # (simplified for small n)
    coeffs = list(values)
    for j in range(1, n):
        for i in range(n - 1, j - 1, -1):
            coeffs[i] = (coeffs[i] - coeffs[i-1]) / (nodes[i] - nodes[i-j])
    
    # Convert from Newton form to monomial form
    mono = [0.0] * n
    mono[0] = coeffs[0]
    
    # Build up: each step multiplies by (x - nodes[k])
    running = [0.0] * n
    running[0] = 1.0
    
    for k in range(1, n):
        # Multiply running by (x - nodes[k-1])
        new_running = [0.0] * n
        for i in range(k, 0, -1):
            new_running[i] = running[i-1]
        for i in range(k + 1):
            new_running[i] -= nodes[k-1] * running[i]
        running = new_running
        
        for i in range(n):
            mono[i] += coeffs[k] * running[i]
    
    return mono


def approximate_function(f: Callable[[float], float], a: float, b: float, 
                          degree: int) -> EMLExpr:
    """
    Approximate f on [a, b] by a polynomial EML expression of given degree.
    
    Algorithm:
        1. Compute Chebyshev interpolation nodes.
        2. Evaluate f at these nodes.
        3. Compute polynomial coefficients.
        4. Compile polynomial to EML expression via Horner's method.
    
    The result is an EML expression of depth 0 (purely algebraic)
    with size O(degree).
    """
    coeffs = chebyshev_coefficients(f, degree, a, b)
    return compile_polynomial(coeffs)


# ============================================================
# Complexity Analysis
# ============================================================

def analyze_expression(e: EMLExpr) -> Dict[str, int]:
    """Compute complexity metrics for an EML expression."""
    return {
        "size": e.size,
        "depth": e.depth,
        "transc_count": e.transc_count,
        "depth_le_transc": int(e.depth <= e.transc_count),
        "transc_le_size": int(e.transc_count <= e.size),
    }


if __name__ == "__main__":
    # Demo: compile and evaluate
    print("=== EML Expression Compilation ===\n")
    
    # Polynomial 3x² + 2x + 1
    poly = compile_polynomial([1.0, 2.0, 3.0])
    print(f"Polynomial 3x² + 2x + 1:")
    print(f"  Expression: {poly}")
    print(f"  Metrics: {analyze_expression(poly)}")
    print(f"  eval(x=2): {poly.eval({0: 2.0})} (expected: {3*4 + 2*2 + 1})")
    
    # Power x^5
    power = compile_power(5)
    print(f"\nPower x⁵ (via exp-log):")
    print(f"  Expression: {power}")
    print(f"  Metrics: {analyze_expression(power)}")
    print(f"  eval(x=3): {power.eval({0: 3.0})} (expected: {3**5})")
    
    # Product
    prod = compile_product()
    print(f"\nProduct x₀ × x₁ (via exp-log):")
    print(f"  Expression: {prod}")
    print(f"  Metrics: {analyze_expression(prod)}")
    print(f"  eval(x₀=3, x₁=7): {prod.eval({0: 3.0, 1: 7.0})} (expected: 21)")
    
    # Approximate sin(x) on [-π, π]
    print(f"\n=== Function Approximation ===\n")
    sin_approx = approximate_function(math.sin, -math.pi, math.pi, 15)
    print(f"sin(x) approximation (degree 15):")
    print(f"  Metrics: {analyze_expression(sin_approx)}")
    
    test_points = [0.0, 0.5, 1.0, math.pi/2]
    for x in test_points:
        approx_val = sin_approx.eval({0: x})
        exact_val = math.sin(x)
        print(f"  x={x:.4f}: approx={approx_val:.8f}, exact={exact_val:.8f}, error={abs(approx_val-exact_val):.2e}")
