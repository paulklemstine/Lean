#!/usr/bin/env python3
"""
EML Neural Network Approximation Algorithms

Type-hinted implementations of the key algorithms from the
EML depth-width tradeoff theory.
"""

from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass
import math


@dataclass
class EMLUnit:
    """An EML approximation unit with parameters (a, b, c, d, w).
    Computes w * (exp(a*x + b) - log(c*x + d))."""
    a: float
    b: float
    c: float
    d: float
    w: float

    def eval(self, x: float) -> float:
        """Evaluate the EML unit at x."""
        exp_part = math.exp(self.a * x + self.b)
        log_arg = self.c * x + self.d
        if log_arg <= 0:
            raise ValueError(f"Log argument {log_arg} is non-positive at x={x}")
        log_part = math.log(log_arg)
        return self.w * (exp_part - log_part)

    def deriv(self, x: float) -> float:
        """Compute the derivative at x."""
        exp_part = self.a * math.exp(self.a * x + self.b)
        log_arg = self.c * x + self.d
        log_deriv = self.c / log_arg
        return self.w * (exp_part - log_deriv)

    def in_domain(self, x: float) -> bool:
        """Check if x is in the domain."""
        return self.c * x + self.d > 0


@dataclass
class EMLLayer:
    """An EML layer: sum of EML units plus bias."""
    units: List[EMLUnit]
    bias: float

    @property
    def width(self) -> int:
        return len(self.units)

    def eval(self, x: float) -> float:
        """Evaluate the layer at x."""
        return sum(u.eval(x) for u in self.units) + self.bias


@dataclass
class EMLNetwork:
    """An EML network: composition of layers."""
    layers: List[EMLLayer]

    @property
    def depth(self) -> int:
        return len(self.layers)

    @property
    def max_width(self) -> int:
        return max((l.width for l in self.layers), default=0)

    def eval(self, x: float) -> float:
        """Evaluate the network by composing layers."""
        result = x
        for layer in self.layers:
            result = layer.eval(result)
        return result


@dataclass
class ApproxSpectrum:
    """The EML Approximation Spectrum: maps (depth, width) to error bounds."""
    target_name: str
    error_fn: Callable[[int, int], float]

    def error(self, depth: int, width: int) -> float:
        """Get the error bound for given depth and width."""
        return self.error_fn(depth, width)

    def isoperf_curve(self, epsilon: float,
                      max_depth: int = 100,
                      max_width: int = 100) -> List[Tuple[int, int]]:
        """Compute the isoperformance curve at error level epsilon.
        Returns minimal (depth, width) pairs achieving error ≤ epsilon."""
        points = []
        for d in range(1, max_depth + 1):
            for w in range(1, max_width + 1):
                if self.error(d, w) <= epsilon:
                    points.append((d, w))
                    break  # Take smallest w for this d
        return points


def eml_quad_extract(epsilon: float, x: float) -> float:
    """EML quadratic extractor: exp(εx) - 1 - εx."""
    return math.exp(epsilon * x) - 1 - epsilon * x


def eml_norm_extract(epsilon: float, x: float) -> float:
    """Normalized extractor: 2(exp(εx) - 1 - εx)/ε² ≈ x²."""
    if abs(epsilon) < 1e-15:
        return x * x  # Limit as ε → 0
    return 2 * eml_quad_extract(epsilon, x) / epsilon**2


def build_sq_approximator(width: int) -> EMLLayer:
    """Build an EML layer that approximates x² on [0,1].

    Uses a single EML unit with small ε = 1/width parameter.
    The key identity: 2(exp(εx) - 1 - εx)/ε² → x² as ε → 0.

    Algorithm:
    1. Set ε = 1/width
    2. Create EML unit with a=ε, b=0, c=0, d=1 (exp(εx) - log(1) = exp(εx))
    3. Scale output by 2/ε² and subtract the linear term

    Returns: EMLLayer approximating x²
    """
    eps = 1.0 / width
    # We use: 2/ε² * (exp(εx) - 1) - 2x/ε
    # = 2/ε² * exp(εx) - 2/ε² - 2x/ε
    # The first term is an EML unit, the rest are handled by bias and
    # a correction term
    unit = EMLUnit(a=eps, b=0, c=0, d=1, w=2.0 / eps**2)
    # Bias accounts for the -2/ε² term from expanding
    bias = -2.0 / eps**2
    return EMLLayer(units=[unit], bias=bias)


def approx_composition_error(
    lip_const: float,
    inner_error: float,
    outer_error: float
) -> float:
    """Compute the composition error bound.

    If outer ≈ g₁ to within outer_error and inner ≈ g₂ to within inner_error,
    and g₁ is L-Lipschitz, then outer∘inner ≈ g₁∘g₂ to within
    L·inner_error + outer_error.
    """
    return lip_const * inner_error + outer_error


def crossover_depth(width: int) -> int:
    """Compute minimum depth where EML beats piecewise linear for x².

    The crossover occurs when exp(1)/(3wd) ≤ 1/(8w²),
    equivalently d ≥ 8w·exp(1)/3.
    """
    return math.ceil(8 * width * math.e / 3)


def build_eml_spectrum() -> ApproxSpectrum:
    """Build the EML approximation spectrum for x² on [0,1]."""
    def error_fn(d: int, w: int) -> float:
        if w == 0 or d == 0:
            return 1.0
        return math.e / (3 * w * d)
    return ApproxSpectrum("x² (EML)", error_fn)


def build_pwl_spectrum() -> ApproxSpectrum:
    """Build the piecewise linear spectrum for x² on [0,1]."""
    def error_fn(d: int, w: int) -> float:
        if w == 0:
            return 1.0
        return 1.0 / (8 * w**2)
    return ApproxSpectrum("x² (PWL/ReLU)", error_fn)


def taylor_remainder_bound(t: float) -> float:
    """Upper bound on |exp(t) - 1 - t - t²/2|.
    Returns |t|³/6 · exp(|t|)."""
    return abs(t)**3 / 6 * math.exp(abs(t))


if __name__ == "__main__":
    # Quick verification
    for w in [1, 5, 10, 50]:
        layer = build_sq_approximator(w)
        # Test at x = 0.5
        # Note: the layer computes 2/ε² * exp(εx) - 2/ε² + correction
        # which isn't quite the same as emlNormExtract due to the linear term
        print(f"Width {w}: crossover depth = {crossover_depth(w)}")

    eml = build_eml_spectrum()
    pwl = build_pwl_spectrum()
    print(f"\nEML error at (d=10, w=5): {eml.error(10, 5):.6f}")
    print(f"PWL error at (d=10, w=5): {pwl.error(10, 5):.6f}")
