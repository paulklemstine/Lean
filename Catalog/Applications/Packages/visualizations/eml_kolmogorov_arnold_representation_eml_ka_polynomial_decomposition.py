#!/usr/bin/env python3
"""
EML Spectral Kolmogorov-Arnold Theory — Algorithms

Type-hinted implementations of the core EML-KA decomposition algorithms.
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple
import numpy as np


@dataclass
class LogAffineMap:
    """A LogAffine map x ↦ α·log(x) + β on (0,∞).

    This is the fundamental inner function type for EML-KA decompositions.
    The 2D parameter space (α, β) is sufficient to separate all points
    in (0,∞) and generate all monomial representations.
    """
    alpha: float  # slope (coefficient of log)
    beta: float   # intercept

    def eval(self, x: float) -> float:
        """Evaluate the LogAffine map at x > 0."""
        assert x > 0, f"LogAffineMap requires positive input, got {x}"
        return self.alpha * np.log(x) + self.beta

    def __add__(self, other: 'LogAffineMap') -> 'LogAffineMap':
        return LogAffineMap(self.alpha + other.alpha, self.beta + other.beta)

    def __mul__(self, scalar: float) -> 'LogAffineMap':
        return LogAffineMap(scalar * self.alpha, scalar * self.beta)

    @staticmethod
    def log_map() -> 'LogAffineMap':
        """The identity LogAffine map (α=1, β=0) = log."""
        return LogAffineMap(1.0, 0.0)

    @staticmethod
    def const(c: float) -> 'LogAffineMap':
        """A constant LogAffine map (α=0, β=c)."""
        return LogAffineMap(0.0, c)

    @staticmethod
    def zero() -> 'LogAffineMap':
        """The zero LogAffine map."""
        return LogAffineMap(0.0, 0.0)


@dataclass
class EMLKADecomposition:
    """An EML-KA decomposition of a bivariate function.

    Represents f(x,y) = Σ_q Φ_q(φ₁_q(x) + φ₂_q(y))
    where each φ₁_q, φ₂_q, Φ_q is a univariate function.

    Algorithm: Construct from explicit inner/outer function specification.
    Complexity: O(Q) evaluation per point, where Q is the number of terms.
    """
    phi1: List[Callable[[float], float]]  # inner functions for x
    phi2: List[Callable[[float], float]]  # inner functions for y
    Phi: List[Callable[[float], float]]   # outer functions
    Q: int  # number of terms

    def eval(self, x: float, y: float) -> float:
        """Evaluate the decomposition at (x, y)."""
        return sum(
            self.Phi[q](self.phi1[q](x) + self.phi2[q](y))
            for q in range(self.Q)
        )

    def is_symmetric(self) -> bool:
        """Check if φ₁_q = φ₂_q for all q (approximately)."""
        test_points = [0.5, 1.0, 2.0, np.e, 10.0]
        for q in range(self.Q):
            for x in test_points:
                if abs(self.phi1[q](x) - self.phi2[q](x)) > 1e-12:
                    return False
        return True

    @staticmethod
    def for_multiplication() -> 'EMLKADecomposition':
        """1-term EML-KA for x * y = exp(log(x) + log(y))."""
        return EMLKADecomposition(
            phi1=[np.log], phi2=[np.log], Phi=[np.exp], Q=1
        )

    @staticmethod
    def for_addition() -> 'EMLKADecomposition':
        """2-term EML-KA for x + y = exp(log(x)) + exp(log(y))."""
        return EMLKADecomposition(
            phi1=[np.log, lambda _: 0.0],
            phi2=[lambda _: 0.0, np.log],
            Phi=[np.exp, np.exp],
            Q=2
        )

    @staticmethod
    def for_division() -> 'EMLKADecomposition':
        """1-term EML-KA for x / y = exp(log(x) + (-log(y)))."""
        return EMLKADecomposition(
            phi1=[np.log],
            phi2=[lambda y: -np.log(y)],
            Phi=[np.exp],
            Q=1
        )

    @staticmethod
    def for_monomial(a: int, b: int) -> 'EMLKADecomposition':
        """1-term EML-KA for x^a * y^b = exp(a*log(x) + b*log(y))."""
        return EMLKADecomposition(
            phi1=[lambda x, a=a: a * np.log(x)],
            phi2=[lambda y, b=b: b * np.log(y)],
            Phi=[np.exp],
            Q=1
        )

    @staticmethod
    def for_geometric_mean() -> 'EMLKADecomposition':
        """Symmetric 1-term EML-KA for √(xy) = exp(½ log(x) + ½ log(y))."""
        return EMLKADecomposition(
            phi1=[lambda x: 0.5 * np.log(x)],
            phi2=[lambda y: 0.5 * np.log(y)],
            Phi=[np.exp],
            Q=1
        )

    @staticmethod
    def for_polynomial(
        coeffs: List[float],
        exps_a: List[int],
        exps_b: List[int]
    ) -> 'EMLKADecomposition':
        """M-term EML-KA for Σ c_i * x^{a_i} * y^{b_i}.

        Algorithm:
        1. For each monomial c * x^a * y^b with c > 0:
           - Inner x: x ↦ a * log(x) + log(c)
           - Inner y: y ↦ b * log(y)
           - Outer: exp
        2. This gives an M-term decomposition where M = #monomials.

        Complexity: O(M) per evaluation.
        """
        M = len(coeffs)
        assert len(exps_a) == M and len(exps_b) == M
        assert all(c > 0 for c in coeffs), "All coefficients must be positive"

        phi1 = [lambda x, a=a, c=c: a * np.log(x) + np.log(c)
                for a, c in zip(exps_a, coeffs)]
        phi2 = [lambda y, b=b: b * np.log(y)
                for b in exps_b]
        Phi = [np.exp] * M

        return EMLKADecomposition(phi1=phi1, phi2=phi2, Phi=Phi, Q=M)


def combine_emlka(
    d1: EMLKADecomposition,
    d2: EMLKADecomposition
) -> EMLKADecomposition:
    """Combine two EML-KA decompositions (closure under addition).

    If d1 represents f with Q1 terms and d2 represents g with Q2 terms,
    returns a decomposition of f + g with Q1 + Q2 terms.

    Algorithm: Simple concatenation of the component lists.
    """
    return EMLKADecomposition(
        phi1=d1.phi1 + d2.phi1,
        phi2=d1.phi2 + d2.phi2,
        Phi=d1.Phi + d2.Phi,
        Q=d1.Q + d2.Q
    )


def scale_emlka(d: EMLKADecomposition, c: float) -> EMLKADecomposition:
    """Scale an EML-KA decomposition by constant c.

    If d represents f with Q terms, returns a decomposition of c*f
    with Q terms.

    Algorithm: Multiply each outer function by c.
    """
    return EMLKADecomposition(
        phi1=d.phi1,
        phi2=d.phi2,
        Phi=[lambda x, phi=phi: c * phi(x) for phi in d.Phi],
        Q=d.Q
    )


def fenchel_young_gap(x: float, s: float) -> float:
    """Compute the Fenchel-Young gap: exp(x) + s*log(s) - s - x*s.

    This gap is always ≥ 0 for s > 0, and equals 0 iff x = log(s).
    It measures the non-linearity cost of the EML exp-log encoding.
    """
    assert s > 0, f"Fenchel-Young requires s > 0, got {s}"
    return np.exp(x) + s * np.log(s) - s - x * s


def log_affine_separates(
    x1: float, x2: float
) -> Tuple[LogAffineMap, float, float]:
    """Find a LogAffine map that separates x1 and x2.

    Returns (f, f(x1), f(x2)) where f is the separating map.
    For distinct positive reals, log itself always separates.
    """
    assert x1 > 0 and x2 > 0
    f = LogAffineMap.log_map()
    return f, f.eval(x1), f.eval(x2)


# ============================================================
# Main demonstration
# ============================================================
if __name__ == "__main__":
    print("EML-KA Algorithm Demonstrations")
    print("=" * 50)

    # Test multiplication
    d_mul = EMLKADecomposition.for_multiplication()
    print(f"\nMultiplication (Q={d_mul.Q}, symmetric={d_mul.is_symmetric()}):")
    for x, y in [(2, 3), (0.5, 4), (np.e, np.pi)]:
        print(f"  {x} * {y} = {d_mul.eval(x, y):.10f} (exact: {x*y:.10f})")

    # Test addition
    d_add = EMLKADecomposition.for_addition()
    print(f"\nAddition (Q={d_add.Q}):")
    for x, y in [(2, 3), (0.5, 4), (np.e, np.pi)]:
        print(f"  {x} + {y} = {d_add.eval(x, y):.10f} (exact: {x+y:.10f})")

    # Test polynomial
    d_poly = EMLKADecomposition.for_polynomial([3.0, 2.0, 5.0], [2, 1, 1], [1, 3, 1])
    print(f"\nPolynomial 3x²y + 2xy³ + 5xy (Q={d_poly.Q}):")
    for x, y in [(2, 3), (1.5, 2.5)]:
        exact = 3*x**2*y + 2*x*y**3 + 5*x*y
        print(f"  f({x},{y}) = {d_poly.eval(x, y):.6f} (exact: {exact:.6f})")

    # Test combination (closure)
    d_combined = combine_emlka(d_mul, d_add)
    print(f"\nCombination x*y + (x+y) (Q={d_combined.Q}):")
    for x, y in [(2, 3), (1.5, 2.5)]:
        print(f"  f({x},{y}) = {d_combined.eval(x, y):.6f} (exact: {x*y + x + y:.6f})")

    # Fenchel-Young gap
    print("\nFenchel-Young gap (should be ≥ 0, zero at x = log(s)):")
    for s in [1.0, np.e, 2.0]:
        for dx in [-1, 0, 1]:
            x = np.log(s) + dx
            gap = fenchel_young_gap(x, s)
            label = "TIGHT" if abs(gap) < 1e-12 else f"gap={gap:.6f}"
            print(f"  s={s:.3f}, x=log(s)+{dx}: {label}")
