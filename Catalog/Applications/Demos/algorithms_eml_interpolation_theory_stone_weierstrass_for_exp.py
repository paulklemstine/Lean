"""
EML Interpolation Theory: Algorithms for Exp-Log Network Approximation

Type-hinted implementations of the core EML expression evaluation,
complexity analysis, and approximation algorithms.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable
import math


class EMLOp(Enum):
    """EML expression node types."""
    CONST = auto()
    VAR = auto()
    EXP = auto()
    LOG = auto()
    ADD = auto()
    MUL = auto()


@dataclass
class EMLExpr:
    """
    An EML (Exponential-Multiplicative-Logarithmic) expression tree.

    This is the Python analogue of the Lean `EMLExpr` inductive type.
    Each node has an operation type and up to two children.
    """
    op: EMLOp
    value: float | None = None  # For CONST nodes
    left: EMLExpr | None = None
    right: EMLExpr | None = None

    @staticmethod
    def const(c: float) -> EMLExpr:
        return EMLExpr(op=EMLOp.CONST, value=c)

    @staticmethod
    def var() -> EMLExpr:
        return EMLExpr(op=EMLOp.VAR)

    @staticmethod
    def exp(e: EMLExpr) -> EMLExpr:
        return EMLExpr(op=EMLOp.EXP, left=e)

    @staticmethod
    def log(e: EMLExpr) -> EMLExpr:
        return EMLExpr(op=EMLOp.LOG, left=e)

    @staticmethod
    def add(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
        return EMLExpr(op=EMLOp.ADD, left=e1, right=e2)

    @staticmethod
    def mul(e1: EMLExpr, e2: EMLExpr) -> EMLExpr:
        return EMLExpr(op=EMLOp.MUL, left=e1, right=e2)

    def eval(self, x: float) -> float:
        """Evaluate the EML expression at point x."""
        if self.op == EMLOp.CONST:
            return self.value if self.value is not None else 0.0
        elif self.op == EMLOp.VAR:
            return x
        elif self.op == EMLOp.EXP:
            assert self.left is not None
            inner = self.left.eval(x)
            try:
                return math.exp(inner)
            except OverflowError:
                return float('inf')
        elif self.op == EMLOp.LOG:
            assert self.left is not None
            val = self.left.eval(x)
            return math.log(val) if val > 0 else 0.0
        elif self.op == EMLOp.ADD:
            assert self.left is not None and self.right is not None
            return self.left.eval(x) + self.right.eval(x)
        elif self.op == EMLOp.MUL:
            assert self.left is not None and self.right is not None
            return self.left.eval(x) * self.right.eval(x)
        raise ValueError(f"Unknown op: {self.op}")

    def depth(self) -> int:
        """Compositional depth of the expression tree."""
        if self.op in (EMLOp.CONST, EMLOp.VAR):
            return 0
        elif self.op in (EMLOp.EXP, EMLOp.LOG):
            assert self.left is not None
            return self.left.depth() + 1
        else:
            assert self.left is not None and self.right is not None
            return max(self.left.depth(), self.right.depth()) + 1

    def width(self) -> int:
        """Width (number of leaf nodes)."""
        if self.op in (EMLOp.CONST, EMLOp.VAR):
            return 1
        elif self.op in (EMLOp.EXP, EMLOp.LOG):
            assert self.left is not None
            return self.left.width()
        else:
            assert self.left is not None and self.right is not None
            return self.left.width() + self.right.width()

    def node_count(self) -> int:
        """Total number of nodes."""
        if self.op in (EMLOp.CONST, EMLOp.VAR):
            return 1
        elif self.op in (EMLOp.EXP, EMLOp.LOG):
            assert self.left is not None
            return self.left.node_count() + 1
        else:
            assert self.left is not None and self.right is not None
            return self.left.node_count() + self.right.node_count() + 1

    def compose(self, inner: EMLExpr) -> EMLExpr:
        """Substitute `inner` for every VAR in self."""
        if self.op == EMLOp.CONST:
            return EMLExpr.const(self.value if self.value is not None else 0.0)
        elif self.op == EMLOp.VAR:
            return inner
        elif self.op == EMLOp.EXP:
            assert self.left is not None
            return EMLExpr.exp(self.left.compose(inner))
        elif self.op == EMLOp.LOG:
            assert self.left is not None
            return EMLExpr.log(self.left.compose(inner))
        elif self.op == EMLOp.ADD:
            assert self.left is not None and self.right is not None
            return EMLExpr.add(self.left.compose(inner), self.right.compose(inner))
        elif self.op == EMLOp.MUL:
            assert self.left is not None and self.right is not None
            return EMLExpr.mul(self.left.compose(inner), self.right.compose(inner))
        raise ValueError(f"Unknown op: {self.op}")


def power_expr(n: int) -> EMLExpr:
    """
    Build the EML expression exp(n * log(var)) computing x^n on (0,∞).

    Algorithm (from Theorem 5.1):
        exp(n · log(x)) = x^n for x > 0

    Pseudocode:
        1. Create leaf: var
        2. Apply log: log(var)
        3. Create constant: const(n)
        4. Multiply: mul(const(n), log(var))
        5. Apply exp: exp(mul(const(n), log(var)))

    Returns an EMLExpr of depth 3 and width 1.
    """
    return EMLExpr.exp(EMLExpr.mul(EMLExpr.const(float(n)), EMLExpr.log(EMLExpr.var())))


@dataclass
class EMLApproxWitness:
    """
    An approximation witness: bundles an EML expression with its
    target function, domain, and error bound.

    The witness is valid if:
        for all x in [lo, hi]: |expr.eval(x) - target(x)| <= error_bound
    """
    expr: EMLExpr
    target: Callable[[float], float]
    lo: float
    hi: float
    error_bound: float

    def check_validity(self, num_samples: int = 1000) -> tuple[bool, float]:
        """
        Empirically check validity by sampling points in [lo, hi].
        Returns (is_valid, max_error_found).
        """
        max_error = 0.0
        for i in range(num_samples + 1):
            x = self.lo + (self.hi - self.lo) * i / num_samples
            try:
                error = abs(self.expr.eval(x) - self.target(x))
                max_error = max(max_error, error)
            except (ValueError, OverflowError):
                return False, float('inf')
        return max_error <= self.error_bound + 1e-12, max_error


def verify_width_depth_bound(expr: EMLExpr) -> bool:
    """Verify that width <= 2^depth (Theorem 3.1)."""
    return expr.width() <= 2 ** expr.depth()


def verify_node_leaf_bound(expr: EMLExpr) -> bool:
    """Verify that 2*width - 1 <= nodeCount (Theorem 3.2)."""
    return 2 * expr.width() - 1 <= expr.node_count()


def soft_max(a: float, b: float, t: float = 1.0) -> float:
    """
    Soft maximum: (1/t) * log(exp(t*a) + exp(t*b))
    Converges to max(a, b) as t -> infinity.

    This is the EML approximation of the tropical max operation,
    bridging classical and tropical approximation theory.
    """
    # Numerically stable implementation
    m = max(t * a, t * b)
    return (m + math.log(math.exp(t * a - m) + math.exp(t * b - m))) / t


def eml_piecewise_linear_approx(
    breakpoints: list[float],
    values: list[float],
    temperature: float = 10.0
) -> EMLExpr:
    """
    Approximate a piecewise-linear function using EML via log-sum-exp.

    The function is specified by breakpoints x_0 < x_1 < ... < x_n
    and values y_0, y_1, ..., y_n.

    Strategy: represent max/min operations using log-sum-exp,
    then compose with affine functions for each linear segment.

    This is an O(n) width construction, supporting the Jackson-type
    conjecture for Lipschitz functions.
    """
    assert len(breakpoints) == len(values)
    n = len(breakpoints)

    if n == 0:
        return EMLExpr.const(0.0)
    if n == 1:
        return EMLExpr.const(values[0])

    # Build piecewise linear as sum of ReLU-like segments
    # f(x) = y_0 + sum_{i=1}^{n-1} s_i * softplus(t * (x - x_i))
    # where s_i are the slope changes
    result = EMLExpr.const(values[0])
    slopes = [(values[i + 1] - values[i]) / (breakpoints[i + 1] - breakpoints[i])
              for i in range(n - 1)]

    prev_slope = slopes[0]
    # Add initial linear term: slopes[0] * (x - breakpoints[0])
    result = EMLExpr.add(
        result,
        EMLExpr.mul(
            EMLExpr.const(slopes[0]),
            EMLExpr.add(EMLExpr.var(), EMLExpr.const(-breakpoints[0]))
        )
    )

    for i in range(1, n - 1):
        slope_change = slopes[i] - prev_slope
        if abs(slope_change) > 1e-12:
            # Add slope_change * softplus(temperature * (x - breakpoints[i]))
            # softplus(z) = log(1 + exp(z))
            inner = EMLExpr.mul(
                EMLExpr.const(temperature),
                EMLExpr.add(EMLExpr.var(), EMLExpr.const(-breakpoints[i]))
            )
            softplus = EMLExpr.log(
                EMLExpr.add(EMLExpr.const(1.0), EMLExpr.exp(inner))
            )
            term = EMLExpr.mul(
                EMLExpr.const(slope_change / temperature),
                softplus
            )
            result = EMLExpr.add(result, term)
        prev_slope = slopes[i]

    return result


if __name__ == "__main__":
    # Quick self-test
    print("=== EML Algorithms Self-Test ===\n")

    # Test power expression
    p2 = power_expr(2)
    print(f"powerExpr(2).depth = {p2.depth()} (expected: 3)")
    print(f"powerExpr(2).width = {p2.width()} (expected: 1)")
    print(f"powerExpr(2).eval(3.0) = {p2.eval(3.0)} (expected: 9.0)")

    # Verify structural bounds
    print(f"\nWidth-Depth bound holds: {verify_width_depth_bound(p2)}")
    print(f"Node-Leaf bound holds: {verify_node_leaf_bound(p2)}")

    # Test approximation witness
    identity_witness = EMLApproxWitness(
        expr=EMLExpr.var(),
        target=lambda x: x,
        lo=0.0, hi=1.0,
        error_bound=0.0
    )
    valid, max_err = identity_witness.check_validity()
    print(f"\nIdentity witness valid: {valid}, max error: {max_err:.2e}")

    square_witness = EMLApproxWitness(
        expr=power_expr(2),
        target=lambda x: x ** 2,
        lo=0.5, hi=1.0,
        error_bound=1e-10
    )
    valid, max_err = square_witness.check_validity()
    print(f"Square witness valid: {valid}, max error: {max_err:.2e}")

    # Test soft max
    print(f"\nsoft_max(3, 5, t=1) = {soft_max(3, 5, 1):.4f} (exact max: 5)")
    print(f"soft_max(3, 5, t=10) = {soft_max(3, 5, 10):.4f}")
    print(f"soft_max(3, 5, t=100) = {soft_max(3, 5, 100):.6f}")
