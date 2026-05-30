"""
EML-Kolmogorov-Arnold Representation: Algorithms

This module implements the core algorithms for constructing and evaluating
EML-KA (Kolmogorov-Arnold) decompositions of multivariate functions.

The key insight: many fundamental operations (multiplication, powers,
geometric means, division) can be decomposed into sums of univariate
EML-composed functions, achieving the Kolmogorov-Arnold representation
with far fewer terms than the general theorem requires.
"""

import numpy as np
from typing import List, Callable, Tuple, Optional
from dataclasses import dataclass


@dataclass
class KADecomp2:
    """A Kolmogorov-Arnold decomposition for a bivariate function.

    Represents f(x,y) = Σ_q w_q * Φ_q(φ1_q(x) + φ2_q(y))

    Attributes:
        Q: Number of terms in the decomposition
        phi1: List of Q inner functions for the first variable
        phi2: List of Q inner functions for the second variable
        Phi: List of Q outer functions
        weights: List of Q scalar weights (default: all 1.0)
    """
    Q: int
    phi1: List[Callable[[float], float]]
    phi2: List[Callable[[float], float]]
    Phi: List[Callable[[float], float]]
    weights: Optional[List[float]] = None

    def __post_init__(self):
        if self.weights is None:
            self.weights = [1.0] * self.Q

    def eval(self, x: float, y: float) -> float:
        """Evaluate the KA decomposition at (x, y).

        Time complexity: O(Q * T) where T is the cost of evaluating each component.
        Space complexity: O(1) additional space.
        """
        result = 0.0
        for q in range(self.Q):
            inner = self.phi1[q](x) + self.phi2[q](y)
            result += self.weights[q] * self.Phi[q](inner)
        return result

    def eval_vectorized(self, xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
        """Evaluate the KA decomposition on arrays of inputs.

        Args:
            xs: Array of x values, shape (N,)
            ys: Array of y values, shape (N,)

        Returns:
            Array of f(x,y) values, shape (N,)

        Time complexity: O(Q * N)
        Space complexity: O(N)
        """
        result = np.zeros_like(xs)
        for q in range(self.Q):
            inner = np.vectorize(self.phi1[q])(xs) + np.vectorize(self.phi2[q])(ys)
            result += self.weights[q] * np.vectorize(self.Phi[q])(inner)
        return result


def mul_ka_decomp() -> KADecomp2:
    """Construct the EML-KA decomposition for multiplication.

    x * y = exp(log(x) + log(y)) for x, y > 0.

    Returns:
        A 1-term KA decomposition with inner=log, outer=exp.

    Example:
        >>> d = mul_ka_decomp()
        >>> d.eval(3.0, 4.0)  # Should be 12.0
        12.000000000000002
    """
    return KADecomp2(
        Q=1,
        phi1=[np.log],
        phi2=[np.log],
        Phi=[np.exp],
    )


def pow_ka_decomp(n: int) -> KADecomp2:
    """Construct the EML-KA decomposition for x^n.

    x^n = exp(n * log(x)) for x > 0.

    Args:
        n: The exponent (non-negative integer).

    Returns:
        A 1-term KA decomposition.

    Example:
        >>> d = pow_ka_decomp(3)
        >>> d.eval(2.0, 1.0)  # Should be 8.0
        8.000000000000002
    """
    return KADecomp2(
        Q=1,
        phi1=[lambda x, n=n: n * np.log(x)],
        phi2=[lambda y: 0.0],
        Phi=[np.exp],
    )


def geom_mean_ka_decomp() -> KADecomp2:
    """Construct the EML-KA decomposition for the geometric mean.

    sqrt(x*y) = exp(0.5*log(x) + 0.5*log(y)) for x, y > 0.

    Returns:
        A 1-term KA decomposition.

    Example:
        >>> d = geom_mean_ka_decomp()
        >>> d.eval(4.0, 9.0)  # Should be 6.0
        6.000000000000001
    """
    return KADecomp2(
        Q=1,
        phi1=[lambda x: 0.5 * np.log(x)],
        phi2=[lambda y: 0.5 * np.log(y)],
        Phi=[np.exp],
    )


def div_ka_decomp() -> KADecomp2:
    """Construct the EML-KA decomposition for division.

    x/y = exp(log(x) - log(y)) for x, y > 0.

    Returns:
        A 1-term KA decomposition.

    Example:
        >>> d = div_ka_decomp()
        >>> d.eval(6.0, 3.0)  # Should be 2.0
        2.0000000000000004
    """
    return KADecomp2(
        Q=1,
        phi1=[np.log],
        phi2=[lambda y: -np.log(y)],
        Phi=[np.exp],
    )


def ka_decomp_add(d1: KADecomp2, d2: KADecomp2) -> KADecomp2:
    """Add two KA decompositions: (d1 + d2)(x,y) = d1(x,y) + d2(x,y).

    The result has Q1 + Q2 terms.

    Time complexity: O(1) for construction, O(Q1+Q2) for evaluation.

    Args:
        d1: First KA decomposition with Q1 terms.
        d2: Second KA decomposition with Q2 terms.

    Returns:
        Combined KA decomposition with Q1+Q2 terms.
    """
    return KADecomp2(
        Q=d1.Q + d2.Q,
        phi1=d1.phi1 + d2.phi1,
        phi2=d1.phi2 + d2.phi2,
        Phi=d1.Phi + d2.Phi,
        weights=d1.weights + d2.weights,
    )


def eml(x: float, y: float) -> float:
    """The EML operation: eml(x, y) = exp(x) - log(y).

    This is the fundamental building block. Key special cases:
    - eml(x, 1) = exp(x)        (recovers exponential)
    - eml(0, y) = 1 - log(y)    (recovers logarithm)
    - eml(log(a), exp(b)) = a - b for a > 0  (recovers subtraction)

    Args:
        x: First argument (any real number).
        y: Second argument (must be positive for log to be defined).

    Returns:
        exp(x) - log(y)
    """
    return np.exp(x) - np.log(y)


def kl_divergence_integrand(p: float, q: float) -> float:
    """KL divergence integrand: p * log(p/q).

    Decomposition via EML:
        p * log(p/q) = p * log(p) - p * (1 - eml(0, q))

    Args:
        p: First probability (positive).
        q: Second probability (positive).

    Returns:
        p * log(p/q)
    """
    return p * np.log(p) - p * (1 - eml(0, q))


def fenchel_young_gap(x: float, s: float) -> float:
    """Compute the Fenchel-Young gap: exp(x) + s*log(s) - s - x*s.

    This is always >= 0, with equality at x = log(s).
    The gap measures how far (x, s) is from the optimal dual pair.

    Args:
        x: Primal variable.
        s: Dual variable (positive).

    Returns:
        The non-negative duality gap.
    """
    return np.exp(x) + s * np.log(s) - s - x * s


def ka_approximation_error(
    decomp: KADecomp2,
    target: Callable[[float, float], float],
    x_range: Tuple[float, float],
    y_range: Tuple[float, float],
    n_samples: int = 100
) -> dict:
    """Compute approximation error statistics for a KA decomposition.

    Args:
        decomp: The KA decomposition to evaluate.
        target: The target function f(x,y).
        x_range: (x_min, x_max) range for x.
        y_range: (y_min, y_max) range for y.
        n_samples: Number of sample points per dimension.

    Returns:
        Dictionary with max_error, mean_error, rmse statistics.

    Time complexity: O(n_samples^2 * Q)
    Space complexity: O(n_samples^2)
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    ys = np.linspace(y_range[0], y_range[1], n_samples)
    XX, YY = np.meshgrid(xs, ys)

    errors = []
    for i in range(n_samples):
        for j in range(n_samples):
            ka_val = decomp.eval(XX[i, j], YY[i, j])
            target_val = target(XX[i, j], YY[i, j])
            errors.append(abs(ka_val - target_val))

    errors = np.array(errors)
    return {
        "max_error": float(np.max(errors)),
        "mean_error": float(np.mean(errors)),
        "rmse": float(np.sqrt(np.mean(errors**2))),
        "n_samples": n_samples**2,
    }


if __name__ == "__main__":
    # Test all decompositions
    print("Testing EML-KA decompositions...")

    d_mul = mul_ka_decomp()
    assert abs(d_mul.eval(3.0, 4.0) - 12.0) < 1e-10
    print(f"  mul(3,4) = {d_mul.eval(3.0, 4.0):.10f} (expected 12)")

    d_pow = pow_ka_decomp(3)
    assert abs(d_pow.eval(2.0, 1.0) - 8.0) < 1e-10
    print(f"  pow(2,3) = {d_pow.eval(2.0, 1.0):.10f} (expected 8)")

    d_geom = geom_mean_ka_decomp()
    assert abs(d_geom.eval(4.0, 9.0) - 6.0) < 1e-10
    print(f"  geom(4,9) = {d_geom.eval(4.0, 9.0):.10f} (expected 6)")

    d_div = div_ka_decomp()
    assert abs(d_div.eval(6.0, 3.0) - 2.0) < 1e-10
    print(f"  div(6,3) = {d_div.eval(6.0, 3.0):.10f} (expected 2)")

    # Test composition
    d_sum = ka_decomp_add(d_mul, d_mul)
    assert abs(d_sum.eval(3.0, 4.0) - 24.0) < 1e-10
    print(f"  2*mul(3,4) = {d_sum.eval(3.0, 4.0):.10f} (expected 24)")

    # Test error analysis
    stats = ka_approximation_error(
        d_mul,
        lambda x, y: x * y,
        (0.1, 10.0), (0.1, 10.0),
        n_samples=50
    )
    print(f"\n  Multiplication error stats:")
    print(f"    Max error:  {stats['max_error']:.2e}")
    print(f"    Mean error: {stats['mean_error']:.2e}")
    print(f"    RMSE:       {stats['rmse']:.2e}")

    print("\nAll tests passed!")
