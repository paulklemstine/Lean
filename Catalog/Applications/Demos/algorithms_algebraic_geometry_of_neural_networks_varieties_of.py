#!/usr/bin/env python3
"""
Algorithms for Tropical Decision Boundary Analysis

Type-hinted implementations of algorithms from the research paper:
1. Activation pattern enumeration
2. Decision boundary extraction
3. Tropical degree computation
4. LogSumExp dequantization
5. Zaslavsky region counting
"""

import numpy as np
from typing import List, Tuple, Optional, Set, FrozenSet
from dataclasses import dataclass


@dataclass
class AffineFunction:
    """An affine function f(x) = slope * x + intercept."""
    slope: float
    intercept: float
    
    def __call__(self, x: float) -> float:
        return self.slope * x + self.intercept


@dataclass
class PiecewiseLinear:
    """A piecewise linear function as max of affine functions (tropical polynomial)."""
    pieces: List[AffineFunction]
    
    def __call__(self, x: float) -> float:
        return max(piece(x) for piece in self.pieces)
    
    @property
    def tropical_degree(self) -> int:
        """Number of distinct slopes (tropical degree + 1)."""
        return len(set(p.slope for p in self.pieces))
    
    def bend_points(self) -> List[float]:
        """Find all bend points (where adjacent pieces meet)."""
        bends = []
        for i, p1 in enumerate(self.pieces):
            for p2 in self.pieces[i+1:]:
                if abs(p1.slope - p2.slope) > 1e-10:
                    x_bend = (p2.intercept - p1.intercept) / (p1.slope - p2.slope)
                    # Check if this is actually a bend (both pieces achieve max here)
                    val = self(x_bend)
                    if abs(p1(x_bend) - val) < 1e-10 and abs(p2(x_bend) - val) < 1e-10:
                        bends.append(x_bend)
        return sorted(set(round(b, 10) for b in bends))
    
    def decision_boundary(self, x_min: float = -10, x_max: float = 10, 
                          n_points: int = 10000) -> List[float]:
        """Find approximate zeros of the piecewise linear function."""
        xs = np.linspace(x_min, x_max, n_points)
        ys = [self(x) for x in xs]
        zeros = []
        for i in range(len(ys) - 1):
            if ys[i] * ys[i+1] < 0:
                # Linear interpolation to find zero
                x0 = xs[i] - ys[i] * (xs[i+1] - xs[i]) / (ys[i+1] - ys[i])
                zeros.append(x0)
            elif abs(ys[i]) < 1e-12:
                zeros.append(xs[i])
        return zeros


@dataclass 
class ReluLayer:
    """A ReLU layer: x -> max(Wx + b, 0)."""
    weights: np.ndarray  # shape (m, n)
    biases: np.ndarray   # shape (m,)
    
    @property
    def input_dim(self) -> int:
        return self.weights.shape[1]
    
    @property
    def output_dim(self) -> int:
        return self.weights.shape[0]
    
    def apply(self, x: np.ndarray) -> np.ndarray:
        """Apply the ReLU layer."""
        return np.maximum(self.weights @ x + self.biases, 0)
    
    def activation_pattern(self, x: np.ndarray) -> Tuple[bool, ...]:
        """Get the activation pattern (which neurons fire)."""
        pre_activation = self.weights @ x + self.biases
        return tuple(bool(v > 0) for v in pre_activation)


@dataclass
class ReluNetwork:
    """A multi-layer ReLU network."""
    layers: List[ReluLayer]
    
    def apply(self, x: np.ndarray) -> np.ndarray:
        """Forward pass through the network."""
        for layer in self.layers:
            x = layer.apply(x)
        return x
    
    def full_activation_pattern(self, x: np.ndarray) -> List[Tuple[bool, ...]]:
        """Get activation patterns for all layers."""
        patterns = []
        current = x
        for layer in self.layers:
            patterns.append(layer.activation_pattern(current))
            current = layer.apply(current)
        return patterns
    
    @property
    def widths(self) -> List[int]:
        """Layer widths."""
        return [layer.output_dim for layer in self.layers]
    
    @property
    def depth(self) -> int:
        """Number of layers."""
        return len(self.layers)
    
    def max_activation_patterns(self) -> int:
        """Upper bound on activation patterns: prod(2^w_i)."""
        result = 1
        for w in self.widths:
            result *= 2**w
        return result
    
    def max_bend_points(self) -> int:
        """Upper bound on bend points: prod(2^w_i - 1)."""
        result = 1
        for w in self.widths:
            result *= (2**w - 1)
        return result


def activation_pattern_count(widths: List[int]) -> int:
    """
    Compute the upper bound on activation patterns for a network with given widths.
    
    Theorem: prod(2^w_i) = 2^(sum(w_i))
    
    Args:
        widths: List of layer widths [w_1, w_2, ..., w_L]
    
    Returns:
        2^(sum of widths) = product of 2^w_i
    """
    return 2 ** sum(widths)


def depth_width_gap(L: int, w: int) -> Tuple[int, int, float]:
    """
    Compute the depth-width exponential gap.
    
    Theorem: L * 2^w <= 2^(L*w) for L >= 2, w >= 2
    
    Args:
        L: Number of layers (depth)
        w: Width per layer
    
    Returns:
        (sum_bound, product_bound, ratio) where
        sum_bound = L * 2^w (additive contribution)
        product_bound = 2^(L*w) (multiplicative composition)
        ratio = product_bound / sum_bound
    """
    sum_bound = L * (2**w)
    product_bound = 2**(L*w)
    ratio = product_bound / sum_bound
    return sum_bound, product_bound, ratio


def logsumexp_bounds(x: np.ndarray, beta: float) -> Tuple[float, float, float]:
    """
    Compute LogSumExp and its tropical approximation bounds.
    
    Theorem: max(x_i) <= (1/beta)*log(sum(exp(beta*x_i))) <= max(x_i) + log(n)/beta
    
    Args:
        x: Array of values
        beta: Inverse temperature (positive)
    
    Returns:
        (lower_bound, lse_value, upper_bound)
    """
    n = len(x)
    M = np.max(x)
    
    # Numerically stable LSE
    shifted = beta * (x - M)
    lse = M + (1/beta) * np.log(np.sum(np.exp(shifted)))
    
    lower = M
    upper = M + np.log(n) / beta
    
    return lower, lse, upper


def zaslavsky_bound(n: int, k: int) -> Tuple[int, int]:
    """
    Compute Zaslavsky's bound on hyperplane arrangement regions.
    
    Theorem: sum_{j=0}^{min(n,k)} C(k,j) <= (k+1)^n
    
    Args:
        n: Dimension of space
        k: Number of hyperplanes
    
    Returns:
        (zaslavsky_count, polynomial_bound)
    """
    from math import comb
    
    zaslavsky = sum(comb(k, j) for j in range(min(n, k) + 1))
    poly_bound = (k + 1) ** n
    
    return zaslavsky, poly_bound


def tropical_polynomial_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a tropical polynomial: max_i(c_i + i*x).
    
    In tropical algebra, a polynomial is the max of monomials,
    where each monomial c_i * x^i becomes c_i + i*x.
    
    Args:
        coeffs: Tropical coefficients [c_0, c_1, ..., c_n]
        x: Input value
    
    Returns:
        max_i(c_i + i*x)
    """
    return max(c + i * x for i, c in enumerate(coeffs))


def tropical_polynomial_roots(coeffs: List[float]) -> List[float]:
    """
    Find the roots (bend points) of a tropical polynomial.
    
    The bend points occur where two consecutive monomials are equal:
    c_i + i*x = c_{i+1} + (i+1)*x  =>  x = c_i - c_{i+1}
    
    Args:
        coeffs: Tropical coefficients [c_0, c_1, ..., c_n]
    
    Returns:
        List of bend points (tropical roots)
    """
    roots = []
    for i in range(len(coeffs) - 1):
        # c_i + i*x = c_{i+1} + (i+1)*x
        # x = c_i - c_{i+1}
        root = coeffs[i] - coeffs[i+1]
        roots.append(root)
    return sorted(roots)


def enumerate_activation_patterns(network: ReluNetwork, 
                                   x_samples: np.ndarray) -> Set[Tuple[Tuple[bool, ...], ...]]:
    """
    Enumerate observed activation patterns from a sample of inputs.
    
    Args:
        network: The ReLU network
        x_samples: Array of input samples, shape (num_samples, input_dim)
    
    Returns:
        Set of observed activation patterns
    """
    patterns = set()
    for x in x_samples:
        pattern = tuple(tuple(p) for p in network.full_activation_pattern(x))
        patterns.add(pattern)
    return patterns


def decision_boundary_1d(network: ReluNetwork, 
                          x_min: float = -5.0, 
                          x_max: float = 5.0,
                          n_points: int = 10000) -> List[float]:
    """
    Find the decision boundary of a 1D ReLU network.
    
    The decision boundary is the set {x : f(x) = 0}.
    For a piecewise linear function, this consists of isolated points
    and (rarely) intervals.
    
    Args:
        network: The ReLU network (input_dim=1, output_dim=1)
        x_min, x_max: Search interval
        n_points: Number of sample points
    
    Returns:
        List of approximate boundary points
    """
    xs = np.linspace(x_min, x_max, n_points)
    ys = [float(network.apply(np.array([x]))[0]) for x in xs]
    
    zeros = []
    for i in range(len(ys) - 1):
        if ys[i] * ys[i+1] < 0:
            # Linear interpolation
            x0 = xs[i] - ys[i] * (xs[i+1] - xs[i]) / (ys[i+1] - ys[i])
            zeros.append(x0)
        elif abs(ys[i]) < 1e-12:
            zeros.append(float(xs[i]))
    
    return zeros


if __name__ == "__main__":
    # Quick test
    print("Testing algorithms...")
    
    # Test activation pattern count
    assert activation_pattern_count([3, 4, 2]) == 2**9 == 512
    print("✓ activation_pattern_count")
    
    # Test depth-width gap
    s, p, r = depth_width_gap(3, 4)
    assert s == 48 and p == 4096
    print("✓ depth_width_gap")
    
    # Test LSE bounds
    x = np.array([1.0, 3.0, 2.0])
    lower, lse, upper = logsumexp_bounds(x, beta=10.0)
    assert lower <= lse <= upper + 1e-10
    print("✓ logsumexp_bounds")
    
    # Test Zaslavsky
    z, p = zaslavsky_bound(2, 5)
    assert z <= p
    print("✓ zaslavsky_bound")
    
    # Test tropical polynomial
    val = tropical_polynomial_eval([0, 1, -1], 2.0)
    assert val == max(0, 1+2, -1+4) == 3.0
    print("✓ tropical_polynomial_eval")
    
    print("\nAll tests passed!")
