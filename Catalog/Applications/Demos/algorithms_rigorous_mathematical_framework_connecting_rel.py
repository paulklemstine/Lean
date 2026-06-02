"""
Algorithms for Neural Decision Surface Topology

Type-hinted implementations of the key mathematical constructions and
computational tools from the framework.
"""

from typing import List, Tuple, Dict, Set, Optional
from math import comb, prod
import numpy as np


def zaslavsky_bound(m: int, n: int) -> int:
    """Compute the Zaslavsky bound Z(m, n) = sum_{k=0}^{n} C(m, k).

    This gives the maximum number of regions created by m hyperplanes
    in R^n (Zaslavsky 1975).

    Args:
        m: Number of hyperplanes.
        n: Dimension of the ambient space.

    Returns:
        The Zaslavsky bound.

    Examples:
        >>> zaslavsky_bound(3, 2)  # 3 lines in the plane
        7
        >>> zaslavsky_bound(4, 3)  # 4 planes in 3-space
        15
    """
    return sum(comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim: int, layer_widths: List[int]) -> int:
    """Compute the upper bound on linear regions for a ReLU network.

    The bound is prod_i Z(w_i, n) where w_i are layer widths and n is
    the input dimension.

    Args:
        input_dim: Dimension of the input space.
        layer_widths: List of hidden layer widths.

    Returns:
        Upper bound on the number of linear regions.

    Examples:
        >>> network_region_bound(2, [3, 3])
        49
        >>> network_region_bound(2, [6])
        22
    """
    return prod(zaslavsky_bound(w, input_dim) for w in layer_widths)


def exponential_bound(layer_widths: List[int]) -> int:
    """Compute the exponential bound 2^N where N = sum of layer widths.

    This is the universal upper bound on linear regions.

    Args:
        layer_widths: List of hidden layer widths.

    Returns:
        2^N where N is the total neuron count.
    """
    return 2 ** sum(layer_widths)


def tropical_monomial_count(layer_widths: List[int]) -> int:
    """Compute the number of tropical monomials for a ReLU network.

    Each layer of width w contributes 2^w monomials, and composition
    multiplies: total = prod 2^(w_i) = 2^(sum w_i).

    Args:
        layer_widths: List of hidden layer widths.

    Returns:
        Number of tropical monomials.
    """
    return prod(2 ** w for w in layer_widths)


def depth_width_comparison(
    input_dim: int, width: int, depth: int
) -> Dict[str, int]:
    """Compare deep vs shallow network region bounds.

    For a deep network with `depth` layers of `width`, and a shallow
    network with a single layer of width `width * depth`.

    Args:
        input_dim: Input dimension.
        width: Width of each hidden layer (deep network).
        depth: Number of hidden layers.

    Returns:
        Dictionary with 'deep_bound', 'shallow_bound', 'ratio'.
    """
    deep = network_region_bound(input_dim, [width] * depth)
    shallow = network_region_bound(input_dim, [width * depth])
    ratio = deep // shallow if shallow > 0 else float("inf")
    return {
        "deep_bound": deep,
        "shallow_bound": shallow,
        "ratio": ratio,
        "deep_exponential_bound": exponential_bound([width] * depth),
    }


def count_linear_regions(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    num_samples: int = 10000,
    input_range: Tuple[float, float] = (-5.0, 5.0),
) -> int:
    """Estimate the number of linear regions by sampling activation patterns.

    Forward-propagates random inputs through the network and records
    distinct activation patterns (which neurons are active).

    Args:
        weights: List of weight matrices, one per layer.
        biases: List of bias vectors, one per layer.
        num_samples: Number of random inputs to sample.
        input_range: Range for uniform random input sampling.

    Returns:
        Number of distinct activation patterns observed.
    """
    input_dim = weights[0].shape[1]
    patterns: Set[Tuple[bool, ...]] = set()

    for _ in range(num_samples):
        x = np.random.uniform(input_range[0], input_range[1], size=input_dim)

        pattern = []
        h = x
        for W, b in zip(weights, biases):
            pre_activation = W @ h + b
            pattern.extend(pre_activation > 0)
            h = np.maximum(pre_activation, 0)  # ReLU

        patterns.add(tuple(pattern))

    return len(patterns)


def random_relu_network(
    input_dim: int, layer_widths: List[int], output_dim: int = 1
) -> Tuple[List[np.ndarray], List[np.ndarray]]:
    """Generate a random ReLU network with given architecture.

    Weights are sampled from N(0, 1/sqrt(fan_in)) (He initialization).

    Args:
        input_dim: Input dimension.
        layer_widths: List of hidden layer widths.
        output_dim: Output dimension.

    Returns:
        Tuple of (weights, biases) lists.
    """
    dims = [input_dim] + layer_widths + [output_dim]
    weights = []
    biases = []

    for i in range(len(dims) - 1):
        fan_in = dims[i]
        W = np.random.randn(dims[i + 1], dims[i]) / np.sqrt(fan_in)
        b = np.random.randn(dims[i + 1]) * 0.1
        weights.append(W)
        biases.append(b)

    return weights, biases


def euler_characteristic_bound(
    input_dim: int, layer_widths: List[int]
) -> int:
    """Upper bound on |chi| of the decision surface complex.

    The bound is prod_i Z(w_i, n), same as the region bound.

    Args:
        input_dim: Input dimension n.
        layer_widths: List of hidden layer widths.

    Returns:
        Upper bound on |Euler characteristic|.
    """
    return network_region_bound(input_dim, layer_widths)


def zaslavsky_recurrence_verify(m: int, n: int) -> bool:
    """Verify the Zaslavsky recurrence Z(m+1,n) = Z(m,n) + Z(m,n-1).

    Args:
        m: Number of hyperplanes.
        n: Dimension (must be >= 1).

    Returns:
        True if the recurrence holds.
    """
    if n < 1:
        return False
    lhs = zaslavsky_bound(m + 1, n)
    rhs = zaslavsky_bound(m, n) + zaslavsky_bound(m, n - 1)
    return lhs == rhs


def tropical_relu_identity(a: float, b: float) -> Tuple[float, float]:
    """Verify max(a,b) = a + ReLU(b-a).

    Returns:
        Tuple of (max(a,b), a + ReLU(b-a)) — should be equal.
    """
    lhs = max(a, b)
    rhs = a + max(b - a, 0)
    return (lhs, rhs)


if __name__ == "__main__":
    # Example computations
    print("=== Zaslavsky Bounds ===")
    for m in range(1, 8):
        for n in [1, 2, 3]:
            z = zaslavsky_bound(m, n)
            print(f"  Z({m}, {n}) = {z}  (≤ 2^{m} = {2**m})")
    
    print("\n=== Depth-Width Tradeoff ===")
    for depth in [1, 2, 5, 10]:
        result = depth_width_comparison(2, 3, depth)
        print(f"  Depth {depth}, width 3: deep={result['deep_bound']}, "
              f"shallow={result['shallow_bound']}, ratio={result['ratio']}")
    
    print("\n=== Zaslavsky Recurrence Verification ===")
    for m in range(10):
        for n in range(1, 8):
            assert zaslavsky_recurrence_verify(m, n), f"Failed at m={m}, n={n}"
    print("  All recurrence checks passed!")
    
    print("\n=== Tropical-ReLU Identity ===")
    for a, b in [(1, 3), (-2, 5), (7, 7), (0, -1)]:
        lhs, rhs = tropical_relu_identity(a, b)
        print(f"  max({a},{b}) = {lhs}, {a} + ReLU({b}-{a}) = {rhs}, match={lhs==rhs}")
    
    print("\n=== Region Counting (Sampling) ===")
    np.random.seed(42)
    arch = [3, 3]
    W, b = random_relu_network(2, arch)
    regions = count_linear_regions(W[:-1], b[:-1], num_samples=50000)
    bound = network_region_bound(2, arch)
    print(f"  Architecture 2→3→3→1: observed {regions} regions, bound = {bound}")
