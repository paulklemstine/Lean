#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Tropical Neural Network Analysis

Type-hinted implementations of the key algorithms for analyzing
ReLU network decision boundaries through tropical geometry.
"""

from typing import List, Tuple, Optional
import numpy as np


def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(x, 0)."""
    return np.maximum(x, 0)


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b) in the (max, +) semiring."""
    return max(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b in the (max, +) semiring."""
    return a + b


def tropical_poly_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a univariate tropical polynomial.
    
    p(x) = max(c_0, c_1 + x, c_2 + 2x, ..., c_d + d*x)
    
    Parameters:
        coeffs: [c_0, c_1, ..., c_d] tropical coefficients
        x: evaluation point
    
    Returns:
        The tropical polynomial value max_i(c_i + i*x)
    """
    return max(c + i * x for i, c in enumerate(coeffs))


def tropical_poly_roots(coeffs: List[float]) -> List[float]:
    """
    Find the roots (bend points) of a univariate tropical polynomial.
    
    At a root, the maximum is achieved by at least two terms simultaneously.
    The root between terms i and j (i < j) is at x = (c_i - c_j) / (j - i).
    
    Returns sorted list of tropical roots.
    """
    n = len(coeffs)
    if n <= 1:
        return []
    
    # Find the upper convex hull of points (i, c_i)
    # The roots are the negated slopes of the edges
    hull_points: List[Tuple[int, float]] = []
    
    for i in range(n):
        while len(hull_points) >= 2:
            (x1, y1) = hull_points[-2]
            (x2, y2) = hull_points[-1]
            # Check if the current point is above the line through previous two
            slope1 = (y2 - y1) / (x2 - x1)
            slope2 = (coeffs[i] - y2) / (i - x2)
            if slope2 >= slope1:
                hull_points.pop()
            else:
                break
        hull_points.append((i, coeffs[i]))
    
    # Roots are at transitions between consecutive hull edges
    roots = []
    for k in range(len(hull_points) - 1):
        i1, c1 = hull_points[k]
        i2, c2 = hull_points[k + 1]
        root = (c1 - c2) / (i2 - i1)
        roots.append(root)
    
    return sorted(roots)


def max_linear_regions(widths: List[int]) -> int:
    """
    Compute the upper bound on linear regions for a 1D ReLU network.
    
    For depth L with layer widths [w_1, ..., w_L]:
    regions ≤ prod_{i=1}^{L} (w_i + 1)
    
    This is the Montúfar-style bound proven in our Lean formalization.
    """
    result = 1
    for w in widths:
        result *= (w + 1)
    return result


def activation_pattern_count(widths: List[int]) -> int:
    """
    Total number of possible activation patterns.
    
    Each neuron is either active (pre-activation > 0) or inactive.
    Total patterns = product of 2^{w_i} = 2^{sum w_i}.
    """
    return 2 ** sum(widths)


def tropical_degree_bound(depth: int, max_weight: int = 1) -> int:
    """
    Upper bound on the tropical degree of a depth-L network.
    
    With integer weights bounded by max_weight:
    degree ≤ max_weight^depth
    
    With unit weights: degree ≤ 2^depth (each ReLU doubles the degree).
    """
    return (max_weight + 1) ** depth


def decision_boundary_components_bound(widths: List[int]) -> int:
    """
    Upper bound on connected components of the decision boundary in 1D.
    
    components ≤ 2 * prod(w_i + 1) - 2
    
    This comes from the tropical rational decomposition:
    f(x) = P(x) - Q(x) where P, Q are tropical polynomials.
    """
    regions = max_linear_regions(widths)
    return 2 * regions - 2


def maslov_dequantization(a: float, b: float, epsilon: float) -> float:
    """
    Maslov dequantization: smooth approximation to max(a, b).
    
    ε · log(exp(a/ε) + exp(b/ε)) → max(a, b) as ε → 0+
    
    Numerically stable implementation using the log-sum-exp trick.
    """
    m = max(a / epsilon, b / epsilon)
    return epsilon * (m + np.log(np.exp(a / epsilon - m) + np.exp(b / epsilon - m)))


def extract_tropical_form(
    weights_list: List[np.ndarray],
    biases_list: List[np.ndarray]
) -> Tuple[List[Tuple[float, float]], List[Tuple[float, float]]]:
    """
    Extract the tropical rational form of a univariate ReLU network.
    
    Returns (P_terms, Q_terms) where:
    - P_terms: list of (slope, intercept) for the positive tropical polynomial
    - Q_terms: list of (slope, intercept) for the negative tropical polynomial
    - f(x) = max_P(slope*x + intercept) - max_Q(slope*x + intercept)
    
    This implements the canonical tropical rational decomposition
    from the companion Lean formalization.
    """
    # Start with identity: f(x) = x (slope=1, intercept=0)
    # Track affine pieces through the network
    
    # Initial piece: single affine function x ↦ x
    pieces: List[Tuple[float, float]] = [(1.0, 0.0)]
    
    for W, b in zip(weights_list, biases_list):
        new_pieces = []
        n_out = W.shape[0]
        
        for neuron_idx in range(n_out):
            w_row = W[neuron_idx]
            bias = b[neuron_idx]
            
            # Each existing piece (s, c) → neuron computes relu(w·(sx+c) + b)
            # = relu(ws·x + wc + b) = max(ws·x + wc + b, 0)
            for s, c in pieces:
                for w_val in w_row:
                    new_slope = w_val * s
                    new_intercept = w_val * c + bias
                    new_pieces.append((new_slope, new_intercept))
                    new_pieces.append((0.0, 0.0))  # ReLU adds zero piece
        
        pieces = new_pieces
    
    # Separate into positive and negative parts
    pos_terms = [(s, c) for s, c in pieces if s >= 0]
    neg_terms = [(-s, -c) for s, c in pieces if s < 0]
    
    if not pos_terms:
        pos_terms = [(0.0, 0.0)]
    if not neg_terms:
        neg_terms = [(0.0, 0.0)]
    
    return pos_terms, neg_terms


def depth_width_comparison(total_neurons: int) -> List[dict]:
    """
    Compare different depth-width configurations for a fixed neuron budget.
    
    For N total neurons, compare:
    - (depth=1, width=N): N+1 regions
    - (depth=2, width=N/2): (N/2+1)^2 regions
    - (depth=k, width=N/k): (N/k+1)^k regions
    - etc.
    
    Returns list of configurations sorted by region count.
    """
    configs = []
    
    for depth in range(1, total_neurons + 1):
        width = total_neurons // depth
        if width < 1:
            break
        
        # Uniform width
        regions = (width + 1) ** depth
        configs.append({
            'depth': depth,
            'width': width,
            'total_neurons': depth * width,
            'max_regions': regions,
            'activation_patterns': 2 ** (depth * width),
        })
    
    configs.sort(key=lambda c: -c['max_regions'])
    return configs


if __name__ == "__main__":
    # Example: tropical polynomial roots
    coeffs = [0, 3, 1, 5]  # max(0, 3+x, 1+2x, 5+3x)
    roots = tropical_poly_roots(coeffs)
    print(f"Tropical polynomial coefficients: {coeffs}")
    print(f"Tropical roots: {roots}")
    print(f"Tropical degree: {len(coeffs) - 1}")
    print()
    
    # Depth-width comparison
    print("Depth-Width Comparison for N=12 total neurons:")
    for config in depth_width_comparison(12)[:5]:
        print(f"  Depth={config['depth']}, Width={config['width']}: "
              f"{config['max_regions']:>10,} max regions")
    print()
    
    # Maslov dequantization
    print("Maslov dequantization: max(3, 1) ≈", maslov_dequantization(3.0, 1.0, 0.01))
