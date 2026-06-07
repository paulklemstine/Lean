#!/usr/bin/env python3
"""
Algorithms for EML Network Construction and Approximation

Type-hinted implementations of the core algorithms from the
Stone-Weierstrass EML density theorem.
"""

from typing import List, Tuple, Callable
import numpy as np
from dataclasses import dataclass
from enum import Enum


class EMLOpType(Enum):
    """Elementary operation types in an EML chain."""
    EXP = "exp"
    LOG = "log"
    ADD = "add"
    MUL = "mul"


@dataclass
class EMLOp:
    """A single EML operation with optional parameter."""
    op_type: EMLOpType
    param: float = 0.0

    def eval(self, x: float) -> float:
        """Evaluate this operation at x."""
        if self.op_type == EMLOpType.EXP:
            return np.exp(x)
        elif self.op_type == EMLOpType.LOG:
            return np.log(x) if x > 0 else float('-inf')
        elif self.op_type == EMLOpType.ADD:
            return x + self.param
        elif self.op_type == EMLOpType.MUL:
            return x * self.param
        raise ValueError(f"Unknown op type: {self.op_type}")


@dataclass
class EMLChain:
    """
    An EML chain: a sequence of elementary operations.
    Evaluated right-to-left (last op applied first to input).
    """
    ops: List[EMLOp]

    def eval(self, x: float) -> float:
        """Evaluate the chain at x."""
        result = x
        for op in reversed(self.ops):
            result = op.eval(result)
        return result

    def depth(self) -> int:
        """Transcendental depth: count of exp and log operations."""
        return sum(1 for op in self.ops
                   if op.op_type in (EMLOpType.EXP, EMLOpType.LOG))

    def compose(self, other: 'EMLChain') -> 'EMLChain':
        """Compose two chains: self ∘ other."""
        return EMLChain(self.ops + other.ops)


def make_affine_exp(a: float, b: float) -> EMLChain:
    """
    Build chain computing exp(a*x + b).
    Depth: 1 (one transcendental operation).

    Algorithm:
    1. Multiply by a
    2. Add b
    3. Apply exp
    """
    return EMLChain([
        EMLOp(EMLOpType.EXP),
        EMLOp(EMLOpType.ADD, b),
        EMLOp(EMLOpType.MUL, a),
    ])


def make_power(n: int) -> EMLChain:
    """
    Build chain computing x^n for x > 0.
    Uses: x^n = exp(n * log(x))
    Depth: 2 (one exp + one log).

    Algorithm:
    1. Apply log
    2. Multiply by n
    3. Apply exp
    """
    return EMLChain([
        EMLOp(EMLOpType.EXP),
        EMLOp(EMLOpType.MUL, float(n)),
        EMLOp(EMLOpType.LOG),
    ])


def eml_least_squares_approx(
    target: Callable[[np.ndarray], np.ndarray],
    interval: Tuple[float, float],
    n_terms: int,
    n_samples: int = 500
) -> Tuple[List[float], List[EMLChain]]:
    """
    Approximate target function using n_terms EML basis functions.

    Returns coefficients and the basis chains.
    The approximation is: f(x) ≈ Σ c_k * exp(k * x)

    Algorithm (Stone-Weierstrass constructive approximation):
    1. Sample target at n_samples points
    2. Build EML basis {exp(k*x) : k = 0, ..., n_terms-1}
    3. Solve least-squares for optimal coefficients
    4. Return coefficients and chains

    Complexity: O(n_samples * n_terms) for matrix construction,
                O(n_terms^2 * n_samples) for least-squares solve.
    """
    a, b = interval
    x_samples = np.linspace(a, b, n_samples)
    y_samples = target(x_samples)

    # Build basis matrix
    basis = np.column_stack([np.exp(k * x_samples) for k in range(n_terms)])

    # Solve least squares
    coeffs, _, _, _ = np.linalg.lstsq(basis, y_samples, rcond=None)

    # Build chains
    chains = [make_affine_exp(float(k), 0.0) for k in range(n_terms)]

    return coeffs.tolist(), chains


def separation_witness(x: float, y: float) -> Tuple[float, float]:
    """
    Given x ≠ y, find parameters (a, b) such that
    exp(a*x + b) ≠ exp(a*y + b).

    By injectivity of exp, we just need a*x + b ≠ a*y + b,
    i.e., a ≠ 0 and x ≠ y. So a=1, b=0 always works.

    Returns: (a, b) such that exp(ax+b) separates x from y.
    """
    assert x != y, "Points must be distinct"
    return (1.0, 0.0)


def lipschitz_width_bound(
    lipschitz_const: float,
    interval_length: float,
    epsilon: float
) -> int:
    """
    Compute the number of EML basis functions needed to
    epsilon-approximate an L-Lipschitz function on an interval of given length.

    Width bound: N = ⌈L * |b-a| / (2ε)⌉

    This is the Jackson-type rate for EML networks.
    """
    assert lipschitz_const > 0
    assert interval_length > 0
    assert epsilon > 0
    return int(np.ceil(lipschitz_const * interval_length / (2 * epsilon)))


def multivariate_separation_witness(
    x: np.ndarray,
    y: np.ndarray
) -> int:
    """
    Given x ≠ y in R^n, find coordinate i such that
    exp(x_i) ≠ exp(y_i).

    Since x ≠ y, there exists i with x_i ≠ y_i.
    Since exp is injective, exp(x_i) ≠ exp(y_i).

    Returns: index i of a separating coordinate.
    """
    diffs = np.abs(x - y)
    return int(np.argmax(diffs))


if __name__ == "__main__":
    # Quick test
    chain = make_power(3)
    print(f"x^3 chain depth: {chain.depth()}")
    print(f"2^3 = {chain.eval(2.0)} (expected: 8.0)")

    chain2 = make_affine_exp(1.0, 0.0)
    print(f"exp(x) chain depth: {chain2.depth()}")
    print(f"exp(1) = {chain2.eval(1.0)} (expected: {np.e})")

    # Separation
    a, b = separation_witness(1.0, 2.0)
    print(f"Separation witness for (1, 2): a={a}, b={b}")
    print(f"  exp({a}*1 + {b}) = {np.exp(a*1+b):.4f}")
    print(f"  exp({a}*2 + {b}) = {np.exp(a*2+b):.4f}")

    # Width bound
    N = lipschitz_width_bound(1.0, 2.0, 0.01)
    print(f"Width for L=1, length=2, eps=0.01: {N}")
