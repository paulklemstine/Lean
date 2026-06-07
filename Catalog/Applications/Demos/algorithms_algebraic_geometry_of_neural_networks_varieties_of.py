#!/usr/bin/env python3
"""
Algorithms for Tropical Geometry of Neural Network Decision Boundaries

Type-hinted implementations of the key algorithms from the research.
"""

from typing import List, Tuple, Callable, Optional
import numpy as np


def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(0, x)."""
    return np.maximum(x, 0)


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)


def tropical_multiply(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical addition)."""
    return a + b


def tropical_polynomial_eval(coeffs: List[float], x: float) -> float:
    """
    Evaluate a tropical polynomial: max_i(coeffs[i] + i * x).
    
    A tropical polynomial of degree d has d+1 coefficients.
    The value is the maximum of d+1 affine functions.
    """
    return max(c + i * x for i, c in enumerate(coeffs))


def tropical_degree(coeffs: List[float], x_range: Tuple[float, float],
                    n_samples: int = 10000) -> int:
    """
    Compute the tropical degree (number of bends) of a tropical polynomial.
    
    The tropical degree equals the number of points where the maximizing
    monomial changes, which is the number of "bends" in the PWL function.
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    
    # Find which monomial achieves the maximum at each point
    active = []
    for x in xs:
        values = [c + i * x for i, c in enumerate(coeffs)]
        active.append(int(np.argmax(values)))
    
    # Count changes in active monomial
    bends = sum(1 for i in range(1, len(active)) if active[i] != active[i-1])
    return bends


def count_linear_regions(
    f: Callable[[float], float],
    x_range: Tuple[float, float],
    n_samples: int = 100000
) -> int:
    """
    Count the number of linear regions of a 1D piecewise linear function.
    
    Algorithm: Sample densely, compute finite differences (slopes),
    count points where the slope changes beyond numerical tolerance.
    
    Returns: Number of linear regions.
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    ys = np.array([f(x) for x in xs])
    slopes = np.diff(ys) / np.diff(xs)
    slope_changes = np.sum(np.abs(np.diff(slopes)) > 1e-6)
    return int(slope_changes + 1)


def count_zero_crossings(
    f: Callable[[float], float],
    x_range: Tuple[float, float],
    n_samples: int = 100000
) -> int:
    """
    Count zero crossings of f (decision boundary points in 1D).
    
    The number of zero crossings is bounded by (number of regions - 1).
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    ys = np.array([f(x) for x in xs])
    return int(np.sum(np.diff(np.sign(ys)) != 0))


def region_bound(widths: List[int]) -> int:
    """
    Compute the Montúfar et al. upper bound on linear regions.
    
    For a network with layer widths w_1, ..., w_L (not counting input/output),
    the bound is prod_i (w_i + 1).
    """
    result = 1
    for w in widths:
        result *= (w + 1)
    return result


def exponential_bound(widths: List[int]) -> int:
    """
    Compute the exponential upper bound: 2^(sum of widths).
    """
    return 2 ** sum(widths)


def tropical_degree_bound(widths: List[int]) -> int:
    """
    Tropical degree bound: prod(w_i + 1) - 1.
    
    This bounds the number of "bends" (non-differentiable points)
    of the network's output function.
    """
    return region_bound(widths) - 1


def depth_width_tradeoff(
    target_regions: int,
    max_params: Optional[int] = None
) -> List[Tuple[int, int, int]]:
    """
    Find (depth, width) configurations achieving the target region count.
    
    Returns list of (depth, width, actual_regions) tuples.
    """
    results = []
    for L in range(1, 20):
        for w in range(1, 100):
            regions = (w + 1) ** L
            params = w * (L + 1) + L
            if regions >= target_regions:
                if max_params is None or params <= max_params:
                    results.append((L, w, regions))
                break
    return results


def parameter_efficiency(L: int, w: int) -> float:
    """
    Compute the parameter efficiency: log2(regions) / parameters.
    
    Higher efficiency means more expressive power per parameter.
    """
    regions = (w + 1) ** L
    params = w * (L + 1) + L  # weights + biases
    if params == 0:
        return 0.0
    return np.log2(regions) / params


def tropical_fiber_size(N: int) -> int:
    """
    The dimension of the tropical fiber: how many distinct networks
    share the same decision boundary.
    
    For N linear regions, each region has an independent slope,
    so the fiber has dimension N.
    """
    return N


class ReLUNetwork1D:
    """A 1D ReLU neural network for studying tropical geometry."""
    
    def __init__(self, widths: List[int], seed: int = 42):
        """
        Initialize with random weights.
        
        widths: list of hidden layer widths (e.g., [3, 3] for depth-2, width-3)
        """
        self.widths = widths
        self.depth = len(widths)
        rng = np.random.RandomState(seed)
        
        self.weights: List[np.ndarray] = []
        self.biases: List[np.ndarray] = []
        
        in_dim = 1
        for w in widths:
            self.weights.append(rng.randn(w, in_dim))
            self.biases.append(rng.randn(w))
            in_dim = w
        # Output layer
        self.weights.append(rng.randn(1, in_dim))
        self.biases.append(rng.randn(1))
    
    def __call__(self, x: float) -> float:
        """Evaluate network at x."""
        h = np.array([x])
        for W, b in zip(self.weights[:-1], self.biases[:-1]):
            h = relu(W @ h + b)
        return float(self.weights[-1] @ h + self.biases[-1])
    
    def region_bound(self) -> int:
        """Theoretical upper bound on linear regions."""
        return region_bound(self.widths)
    
    def tropical_degree_bound(self) -> int:
        """Theoretical upper bound on tropical degree."""
        return tropical_degree_bound(self.widths)
    
    def count_regions(self, x_range: Tuple[float, float] = (-10, 10)) -> int:
        """Count actual linear regions."""
        return count_linear_regions(self, x_range)
    
    def count_boundary_points(self, x_range: Tuple[float, float] = (-10, 10)) -> int:
        """Count decision boundary points (zero crossings)."""
        return count_zero_crossings(self, x_range)


if __name__ == "__main__":
    # Example usage
    print("Tropical Geometry of Neural Networks - Algorithm Demo")
    print("=" * 55)
    
    # Tropical polynomial
    coeffs = [0.0, 1.0, -0.5, 2.0]
    print(f"\nTropical polynomial with coefficients {coeffs}:")
    print(f"  Degree: {len(coeffs) - 1}")
    print(f"  Tropical degree (bends): {tropical_degree(coeffs, (-5, 5))}")
    print(f"  Value at x=1: {tropical_polynomial_eval(coeffs, 1.0):.2f}")
    
    # Compare architectures
    print("\nArchitecture comparison:")
    configs = [
        ([4], "Shallow: 1 layer, width 4"),
        ([2, 2], "Medium: 2 layers, width 2"),
        ([2, 2, 2], "Deep: 3 layers, width 2"),
    ]
    
    for widths, desc in configs:
        net = ReLUNetwork1D(widths)
        print(f"\n  {desc}:")
        print(f"    Region bound: {net.region_bound()}")
        print(f"    Tropical degree bound: {net.tropical_degree_bound()}")
        print(f"    Observed regions: {net.count_regions()}")
        print(f"    Decision boundary points: {net.count_boundary_points()}")
    
    # Parameter efficiency
    print("\nParameter efficiency (bits per parameter):")
    for L in [1, 2, 3, 5, 10]:
        for w in [2, 4, 8]:
            eff = parameter_efficiency(L, w)
            print(f"  L={L}, w={w}: {eff:.3f}")
