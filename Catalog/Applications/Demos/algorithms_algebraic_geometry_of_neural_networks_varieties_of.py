"""
Algorithms for Tropical Geometry of Neural Network Decision Boundaries

Type-hinted implementations of the core algorithms.
"""

from typing import List, Tuple, Callable
import numpy as np
from numpy.typing import NDArray


def relu(x: NDArray[np.float64]) -> NDArray[np.float64]:
    """ReLU activation: max(x, 0)"""
    return np.maximum(x, 0)


def tropical_polynomial_eval(
    slopes: List[float],
    intercepts: List[float],
    x: float
) -> float:
    """Evaluate a 1D tropical polynomial: max_i(slope_i * x + intercept_i)
    
    A tropical polynomial is the pointwise maximum of affine functions.
    In tropical geometry, this replaces classical polynomial evaluation
    where 'addition' becomes 'max' and 'multiplication' becomes '+'.
    """
    return max(s * x + b for s, b in zip(slopes, intercepts))


def tropical_rational_eval(
    num_slopes: List[float],
    num_intercepts: List[float],
    den_slopes: List[float],
    den_intercepts: List[float],
    x: float
) -> float:
    """Evaluate a tropical rational function: num(x) - den(x)
    
    Every ReLU network function is a tropical rational function
    (Zhang-Naitzat-Lim, 2018).
    """
    num = tropical_polynomial_eval(num_slopes, num_intercepts, x)
    den = tropical_polynomial_eval(den_slopes, den_intercepts, x)
    return num - den


def count_linear_regions(widths: List[int]) -> int:
    """Upper bound on linear regions for a ReLU network with given layer widths.
    
    Returns prod_i (w_i + 1), which bounds the number of distinct
    activation patterns that can be realized.
    """
    result = 1
    for w in widths:
        result *= (w + 1)
    return result


def count_activation_patterns(widths: List[int]) -> int:
    """Total number of possible activation patterns: prod_i 2^w_i = 2^(sum w_i)"""
    return 2 ** sum(widths)


def tropical_degree(widths: List[int]) -> int:
    """Tropical degree of a ReLU network: product of layer widths.
    
    This bounds the number of 'bends' in the piecewise linear function,
    which equals the degree of the tropical hypersurface.
    """
    result = 1
    for w in widths:
        result *= w
    return result


def width_depth_ratio(w: int, L: int) -> float:
    """Ratio of deep network complexity to shallow: w^L / (w*L)
    
    This quantifies the exponential advantage of depth over width.
    For w >= 2, L >= 2, this ratio is always >= 1.
    """
    return (w ** L) / (w * L)


def softmax_to_max(x: NDArray[np.float64], beta: float) -> float:
    """Scaled log-sum-exp: (1/β) * log(∑ exp(β*x_i))
    
    Converges to max(x) as β → ∞ (tropical limit).
    Always >= max(x) for any β > 0.
    """
    # Numerically stable computation
    x_max = np.max(x)
    return x_max + (1.0 / beta) * np.log(np.sum(np.exp(beta * (x - x_max))))


def find_decision_boundary_1d(
    network_fn: Callable[[float], float],
    x_range: Tuple[float, float],
    n_points: int = 10000
) -> List[float]:
    """Find approximate zero crossings of a 1D function.
    
    Returns x-values where the function changes sign.
    For a ReLU network, these are points on the decision boundary.
    """
    x_vals = np.linspace(x_range[0], x_range[1], n_points)
    y_vals = np.array([network_fn(x) for x in x_vals])
    
    crossings = []
    for i in range(len(y_vals) - 1):
        if y_vals[i] * y_vals[i+1] < 0:
            # Linear interpolation to find crossing
            t = y_vals[i] / (y_vals[i] - y_vals[i+1])
            crossings.append(x_vals[i] + t * (x_vals[i+1] - x_vals[i]))
    
    return crossings


def relu_network_1d(
    weights: List[List[float]],
    biases: List[List[float]],
    final_weight: List[float],
    final_bias: float,
    x: float
) -> float:
    """Evaluate a 1D-input ReLU network.
    
    weights[l][j] = weight of neuron j in layer l
    biases[l][j] = bias of neuron j in layer l
    """
    h = np.array([x])
    for w_layer, b_layer in zip(weights, biases):
        W = np.array(w_layer).reshape(-1, len(h))
        b = np.array(b_layer)
        h = relu(W @ h + b)
    return float(np.dot(final_weight, h) + final_bias)


def compute_tropical_representation(
    weights: List[List[float]],
    biases: List[List[float]]
) -> Tuple[List[Tuple[float, float]], List[Tuple[float, float]]]:
    """Compute the tropical rational representation of a 1-layer 1D ReLU network.
    
    Returns (numerator_terms, denominator_terms) where each term is (slope, intercept).
    
    For a single layer: relu(wx + b) = max(wx + b, 0) - 0
    Numerator has terms (w, b) and (0, 0).
    Denominator has term (0, 0).
    """
    num_terms = []
    den_terms = [(0.0, 0.0)]
    
    for w, b in zip(weights[0], biases[0]):
        num_terms.append((w, b))
        num_terms.append((0.0, 0.0))
    
    return num_terms, den_terms


if __name__ == "__main__":
    # Example: 3-layer network with width 4
    widths = [4, 4, 4]
    
    print("Network architecture:", widths)
    print(f"  Linear regions (upper bound): {count_linear_regions(widths)}")
    print(f"  Activation patterns: {count_activation_patterns(widths)}")
    print(f"  Tropical degree: {tropical_degree(widths)}")
    print(f"  Width-depth ratio: {width_depth_ratio(4, 3):.1f}x")
    
    # Tropical limit demo
    x = np.array([1.0, 3.0, 2.0])
    for beta in [1, 10, 100]:
        approx = softmax_to_max(x, beta)
        print(f"  β={beta}: softmax→max = {approx:.6f} (true max = {max(x)})")
