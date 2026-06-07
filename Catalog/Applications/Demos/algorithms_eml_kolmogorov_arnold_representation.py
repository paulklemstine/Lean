#!/usr/bin/env python3
"""
EML Kolmogorov-Arnold Spectral Algebra — Algorithms

Type-hinted implementations of the core EML-KA decomposition algorithms.
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, List, Tuple
import math


class OpType(Enum):
    """Elementary EML operation types."""
    EXP = auto()
    LOG = auto()
    AFFINE = auto()


@dataclass
class EMLOp:
    """An elementary operation in an EML chain."""
    op_type: OpType
    a: float = 1.0  # coefficient (for affine)
    b: float = 0.0  # offset (for affine)

    def eval(self, x: float) -> float:
        """Evaluate this operation at x."""
        if self.op_type == OpType.EXP:
            return math.exp(x)
        elif self.op_type == OpType.LOG:
            return math.log(x)
        else:  # AFFINE
            return self.a * x + self.b

    def depth(self) -> int:
        """Transcendental depth: 1 for exp/log, 0 for affine."""
        return 0 if self.op_type == OpType.AFFINE else 1

    def __repr__(self) -> str:
        if self.op_type == OpType.EXP:
            return "exp"
        elif self.op_type == OpType.LOG:
            return "log"
        else:
            if self.b == 0:
                return f"({self.a}·x)"
            return f"({self.a}·x + {self.b})"


def eval_chain(chain: List[EMLOp], x: float) -> float:
    """Evaluate an EML chain at x (outermost first)."""
    result = x
    for op in reversed(chain):
        result = op.eval(result)
    return result


def chain_depth(chain: List[EMLOp]) -> int:
    """Compute the transcendental depth of an EML chain."""
    return sum(op.depth() for op in chain)


@dataclass
class EMLKA:
    """EML Kolmogorov-Arnold decomposition with Q terms."""
    inner1: List[List[EMLOp]]  # inner chains for x
    inner2: List[List[EMLOp]]  # inner chains for y
    outer: List[List[EMLOp]]   # outer chains

    @property
    def num_terms(self) -> int:
        return len(self.outer)

    def eval(self, x: float, y: float) -> float:
        """Evaluate the decomposition at (x, y)."""
        return sum(
            eval_chain(self.outer[q],
                       eval_chain(self.inner1[q], x) +
                       eval_chain(self.inner2[q], y))
            for q in range(self.num_terms)
        )

    def total_depth(self) -> int:
        """Maximum total depth across all terms."""
        return max(
            chain_depth(self.inner1[q]) +
            chain_depth(self.inner2[q]) +
            chain_depth(self.outer[q])
            for q in range(self.num_terms)
        )

    def spectral_info(self) -> str:
        """Return a summary of the decomposition's spectral properties."""
        return (f"EMLKA(terms={self.num_terms}, "
                f"total_depth={self.total_depth()})")


# === Construction Algorithms ===

def make_multiply() -> EMLKA:
    """Construct the EMLKA for f(x,y) = x·y.

    Algorithm: x·y = exp(log(x) + log(y))
    Inner chains: [log], [log]
    Outer chain: [exp]
    """
    return EMLKA(
        inner1=[[EMLOp(OpType.LOG)]],
        inner2=[[EMLOp(OpType.LOG)]],
        outer=[[EMLOp(OpType.EXP)]]
    )


def make_division() -> EMLKA:
    """Construct the EMLKA for f(x,y) = x/y.

    Algorithm: x/y = exp(log(x) + (-1)·log(y))
    Inner chains: [log], [affine(-1,0), log]
    Outer chain: [exp]
    """
    return EMLKA(
        inner1=[[EMLOp(OpType.LOG)]],
        inner2=[[EMLOp(OpType.AFFINE, -1, 0), EMLOp(OpType.LOG)]],
        outer=[[EMLOp(OpType.EXP)]]
    )


def make_monomial(a: int, b: int) -> EMLKA:
    """Construct the EMLKA for f(x,y) = x^a · y^b.

    Algorithm: x^a·y^b = exp(a·log(x) + b·log(y))
    """
    return EMLKA(
        inner1=[[EMLOp(OpType.AFFINE, a, 0), EMLOp(OpType.LOG)]],
        inner2=[[EMLOp(OpType.AFFINE, b, 0), EMLOp(OpType.LOG)]],
        outer=[[EMLOp(OpType.EXP)]]
    )


def make_rpow(r: float, s: float) -> EMLKA:
    """Construct the EMLKA for f(x,y) = x^r · y^s (real exponents).

    Algorithm: x^r·y^s = exp(r·log(x) + s·log(y))
    """
    return EMLKA(
        inner1=[[EMLOp(OpType.AFFINE, r, 0), EMLOp(OpType.LOG)]],
        inner2=[[EMLOp(OpType.AFFINE, s, 0), EMLOp(OpType.LOG)]],
        outer=[[EMLOp(OpType.EXP)]]
    )


def make_polynomial(coeffs: List[float], exp_a: List[int],
                     exp_b: List[int]) -> EMLKA:
    """Construct the EMLKA for a polynomial Σ c_i · x^{a_i} · y^{b_i}.

    Algorithm: Each term c_i · x^{a_i} · y^{b_i} gets its own KA term:
      inner1[i] = [affine(a_i, 0), log]
      inner2[i] = [affine(b_i, 0), log]
      outer[i]  = [affine(c_i, 0), exp]
    """
    M = len(coeffs)
    assert len(exp_a) == M and len(exp_b) == M
    return EMLKA(
        inner1=[[EMLOp(OpType.AFFINE, a, 0), EMLOp(OpType.LOG)] for a in exp_a],
        inner2=[[EMLOp(OpType.AFFINE, b, 0), EMLOp(OpType.LOG)] for b in exp_b],
        outer=[[EMLOp(OpType.AFFINE, c, 0), EMLOp(OpType.EXP)] for c in coeffs]
    )


def make_constant(c: float) -> EMLKA:
    """Construct the EMLKA for f(x,y) = c."""
    return EMLKA(
        inner1=[[]],
        inner2=[[]],
        outer=[[EMLOp(OpType.AFFINE, 0, c)]]
    )


def merge(d1: EMLKA, d2: EMLKA) -> EMLKA:
    """Merge two EMLKAs (addition closure): (d1 + d2)(x,y) = d1(x,y) + d2(x,y)."""
    return EMLKA(
        inner1=d1.inner1 + d2.inner1,
        inner2=d1.inner2 + d2.inner2,
        outer=d1.outer + d2.outer
    )


def scale(d: EMLKA, c: float) -> EMLKA:
    """Scale an EMLKA: (c * d)(x,y) = c * d(x,y)."""
    return EMLKA(
        inner1=d.inner1,
        inner2=d.inner2,
        outer=[[EMLOp(OpType.AFFINE, c, 0)] + chain for chain in d.outer]
    )


def fenchel_young(x: float, s: float) -> Tuple[float, float, float]:
    """Compute Fenchel-Young bound: returns (lhs, rhs, gap).

    Inequality: x·s ≤ exp(x) + s·log(s) - s
    Gap = rhs - lhs ≥ 0 with equality at x = log(s).
    """
    lhs = x * s
    rhs = math.exp(x) + s * math.log(s) - s
    return lhs, rhs, rhs - lhs


def spectral_depth_lower_bound_test(
    target: Callable[[float, float], float],
    test_points: List[Tuple[float, float]],
    max_depth: int = 0,
    num_trials: int = 1000
) -> float:
    """Test whether a function can be represented at a given spectral depth.

    For depth 0, tests affine inner functions with arbitrary outer functions.
    Returns the best approximation error found.
    """
    import random
    best_error = float('inf')

    for _ in range(num_trials):
        a1 = random.uniform(-5, 5)
        b1 = random.uniform(-5, 5)
        a2 = random.uniform(-5, 5)
        b2 = random.uniform(-5, 5)

        # Compute encoded values
        t_vals = [a1 * x + b1 + a2 * y + b2 for x, y in test_points]
        targets = [target(x, y) for x, y in test_points]

        # Best polynomial fit of degree (max_depth + 1)
        if len(set(round(t, 8) for t in t_vals)) < len(t_vals):
            import numpy as np
            try:
                c = np.polyfit(t_vals, targets, min(max_depth + 1, len(t_vals) - 1))
                predicted = np.polyval(c, t_vals)
                error = max(abs(p - t) for p, t in zip(predicted, targets))
                best_error = min(best_error, error)
            except Exception:
                pass

    return best_error


if __name__ == "__main__":
    # Quick verification
    mul_ka = make_multiply()
    print(f"Multiplication: {mul_ka.spectral_info()}")
    print(f"  2.5 * 3.7 = {mul_ka.eval(2.5, 3.7):.10f} (exact: {2.5 * 3.7:.10f})")

    mono_ka = make_monomial(3, 2)
    print(f"\nMonomial x³y²: {mono_ka.spectral_info()}")
    print(f"  2³ · 3² = {mono_ka.eval(2, 3):.10f} (exact: {2**3 * 3**2:.10f})")

    poly_ka = make_polynomial([1, -2, 3], [2, 1, 0], [0, 1, 3])
    print(f"\nPolynomial x² - 2xy + 3y³: {poly_ka.spectral_info()}")
    x, y = 1.5, 2.0
    exact = 1.5**2 - 2*1.5*2.0 + 3*2.0**3
    print(f"  f(1.5, 2.0) = {poly_ka.eval(x, y):.10f} (exact: {exact:.10f})")

    # Fenchel-Young
    print("\nFenchel-Young at tightness point x=log(2), s=2:")
    lhs, rhs, gap = fenchel_young(math.log(2), 2.0)
    print(f"  lhs={lhs:.6f}, rhs={rhs:.6f}, gap={gap:.2e}")
