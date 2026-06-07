#!/usr/bin/env python3
"""
Tropical Neural Algebra: Algorithms

Type-hinted implementations of the core algorithms for computing
tropical rational representations of ReLU networks, counting linear
regions, and analyzing decision boundaries.
"""

from typing import List, Tuple, Optional, Set
import numpy as np
from dataclasses import dataclass, field


@dataclass
class MaxOfAffine:
    """A tropical polynomial: max of k affine functions on R^n.
    
    Represents f(x) = max_i (a_i · x + b_i) for i = 1, ..., k.
    """
    slopes: np.ndarray  # Shape (k, n): each row is a coefficient vector
    biases: np.ndarray  # Shape (k,): bias for each affine piece
    
    @property
    def num_pieces(self) -> int:
        return self.slopes.shape[0]
    
    @property
    def input_dim(self) -> int:
        return self.slopes.shape[1]
    
    def eval(self, x: np.ndarray) -> float:
        """Evaluate at point x ∈ R^n."""
        return float(np.max(self.slopes @ x + self.biases))
    
    def eval_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate at multiple points. X shape: (m, n)."""
        return np.max(X @ self.slopes.T + self.biases, axis=1)
    
    def active_piece(self, x: np.ndarray) -> int:
        """Return the index of the active piece at x."""
        return int(np.argmax(self.slopes @ x + self.biases))


@dataclass
class TropicalRational:
    """A tropical rational function: difference of two tropical polynomials.
    
    f(x) = p(x) - q(x) where p, q are MaxOfAffine.
    Represents an arbitrary piecewise linear function.
    """
    numerator: MaxOfAffine
    denominator: MaxOfAffine
    
    def eval(self, x: np.ndarray) -> float:
        return self.numerator.eval(x) - self.denominator.eval(x)
    
    def decision_boundary(self, X: np.ndarray, threshold: float = 1e-6) -> np.ndarray:
        """Find approximate decision boundary points from a grid."""
        vals = np.abs(self.numerator.eval_batch(X) - self.denominator.eval_batch(X))
        return X[vals < threshold]


@dataclass 
class ReluNeuron:
    """A single ReLU neuron: x ↦ max(w · x + b, 0)."""
    weights: np.ndarray  # Shape (n,)
    bias: float
    
    def eval(self, x: np.ndarray) -> float:
        return float(max(np.dot(self.weights, x) + self.bias, 0.0))
    
    def to_tropical(self) -> MaxOfAffine:
        """Convert to a 2-piece tropical polynomial."""
        n = len(self.weights)
        slopes = np.vstack([self.weights, np.zeros(n)])
        biases = np.array([self.bias, 0.0])
        return MaxOfAffine(slopes, biases)


@dataclass
class ReluLayer:
    """A ReLU layer: w neurons mapping R^n → R^w."""
    neurons: List[ReluNeuron]
    
    @property
    def width(self) -> int:
        return len(self.neurons)
    
    def eval(self, x: np.ndarray) -> np.ndarray:
        return np.array([n.eval(x) for n in self.neurons])
    
    def activation_pattern(self, x: np.ndarray) -> Tuple[bool, ...]:
        """Return the activation pattern at point x."""
        return tuple(
            np.dot(n.weights, x) + n.bias >= 0 
            for n in self.neurons
        )


@dataclass
class ReluNetwork:
    """A deep ReLU network with linear readout."""
    layers: List[ReluLayer]
    readout_weights: np.ndarray  # Shape (w_L,)
    readout_bias: float
    
    @property
    def depth(self) -> int:
        return len(self.layers)
    
    @property
    def widths(self) -> List[int]:
        return [layer.width for layer in self.layers]
    
    @property
    def total_width(self) -> int:
        return sum(self.widths)
    
    def eval(self, x: np.ndarray) -> float:
        """Forward pass."""
        h = x
        for layer in self.layers:
            h = layer.eval(h)
        return float(np.dot(self.readout_weights, h) + self.readout_bias)
    
    def region_bound(self) -> int:
        """Upper bound on the number of linear regions: 2^(total_width)."""
        return 2 ** self.total_width
    
    def full_activation_pattern(self, x: np.ndarray) -> List[Tuple[bool, ...]]:
        """Return the activation pattern across all layers."""
        patterns = []
        h = x
        for layer in self.layers:
            patterns.append(layer.activation_pattern(h))
            h = layer.eval(h)
        return patterns


def zaslavsky_bound(n: int, w: int) -> int:
    """Zaslavsky's bound: number of regions from w hyperplanes in R^n.
    
    Returns sum_{j=0}^{min(n,w)} C(w, j).
    """
    from math import comb
    return sum(comb(w, j) for j in range(min(n, w) + 1))


def refined_region_bound(input_dim: int, widths: List[int]) -> int:
    """Refined region bound using Zaslavsky at each layer.
    
    For each layer i, the effective dimension is min(input_dim, w_{i-1}).
    The bound is prod_i zaslavsky(n_eff_i, w_i).
    """
    bound = 1
    current_dim = input_dim
    for w in widths:
        bound *= zaslavsky_bound(current_dim, w)
        current_dim = w
    return bound


def count_activation_regions(network: ReluNetwork, 
                             grid_points: np.ndarray) -> int:
    """Count distinct activation patterns by sampling.
    
    Returns a lower bound on the number of linear regions.
    """
    patterns: Set[Tuple] = set()
    for x in grid_points:
        pattern = tuple(
            tuple(p) for p in network.full_activation_pattern(x)
        )
        patterns.add(pattern)
    return len(patterns)


def bend_count_after_depth(L: int) -> int:
    """Number of bends after L layers of single neurons: 2^L - 1."""
    return 2 ** L - 1


def network_to_tropical_rational(network: ReluNetwork) -> Optional[TropicalRational]:
    """Convert a univariate single-layer network to tropical rational form.
    
    Works for networks with input_dim=1 and depth=1.
    """
    if network.depth != 1:
        return None
    
    layer = network.layers[0]
    w = layer.width
    
    # Each neuron gives max(a_i * x + b_i, 0)
    # The output is sum_j readout_j * max(a_j * x + b_j, 0) + readout_bias
    # This is a tropical rational function
    
    pos_slopes = []
    pos_biases = []
    neg_slopes = []
    neg_biases = []
    
    for j, neuron in enumerate(layer.neurons):
        r = network.readout_weights[j]
        if r >= 0:
            pos_slopes.append(r * neuron.weights)
            pos_biases.append(r * neuron.bias)
        else:
            neg_slopes.append(-r * neuron.weights)
            neg_biases.append(-r * neuron.bias)
    
    # Add the constant readout bias to the positive part
    if len(pos_slopes) == 0:
        pos_slopes = [np.zeros(1)]
        pos_biases = [network.readout_bias]
    else:
        pos_biases[0] += network.readout_bias
    
    if len(neg_slopes) == 0:
        neg_slopes = [np.zeros(1)]
        neg_biases = [0.0]
    
    numer = MaxOfAffine(
        np.array(pos_slopes).reshape(-1, network.layers[0].neurons[0].weights.shape[0]),
        np.array(pos_biases)
    )
    denom = MaxOfAffine(
        np.array(neg_slopes).reshape(-1, network.layers[0].neurons[0].weights.shape[0]),
        np.array(neg_biases)
    )
    
    return TropicalRational(numer, denom)


# ============================================================
# Algorithm: Decision Boundary Extraction
# ============================================================

def extract_decision_boundary_2d(
    network: ReluNetwork,
    x_range: Tuple[float, float] = (-3, 3),
    y_range: Tuple[float, float] = (-3, 3),
    resolution: int = 500,
    threshold: float = 0.01
) -> np.ndarray:
    """Extract the decision boundary of a 2D network by grid sampling."""
    x = np.linspace(*x_range, resolution)
    y = np.linspace(*y_range, resolution)
    boundary = []
    
    for xi in x:
        for yi in y:
            val = network.eval(np.array([xi, yi]))
            if abs(val) < threshold:
                boundary.append([xi, yi])
    
    return np.array(boundary) if boundary else np.empty((0, 2))


if __name__ == "__main__":
    # Example: create a 2-layer network and analyze it
    np.random.seed(42)
    
    # Network: R^2 -> 4 hidden -> 3 hidden -> 1 output
    layer1 = ReluLayer([
        ReluNeuron(np.array([1.0, 1.0]), -1.0),
        ReluNeuron(np.array([-1.0, 1.0]), 0.0),
        ReluNeuron(np.array([1.0, -1.0]), 0.5),
        ReluNeuron(np.array([-1.0, -1.0]), 1.0),
    ])
    
    layer2 = ReluLayer([
        ReluNeuron(np.array([1.0, -1.0, 0.5, 0.0]), 0.0),
        ReluNeuron(np.array([0.0, 1.0, -1.0, 1.0]), -0.5),
        ReluNeuron(np.array([-1.0, 0.0, 1.0, -1.0]), 0.3),
    ])
    
    network = ReluNetwork(
        layers=[layer1, layer2],
        readout_weights=np.array([1.0, -1.0, 0.5]),
        readout_bias=-0.2
    )
    
    print("Network architecture:", network.widths)
    print(f"Depth: {network.depth}")
    print(f"Total width: {network.total_width}")
    print(f"Region bound (naive): 2^{network.total_width} = {network.region_bound()}")
    print(f"Region bound (Zaslavsky): {refined_region_bound(2, network.widths)}")
    
    # Count regions by sampling
    grid = np.random.uniform(-3, 3, (10000, 2))
    n_regions = count_activation_regions(network, grid)
    print(f"Observed regions (sampled): {n_regions}")
    print(f"Ratio observed/bound: {n_regions / network.region_bound():.4f}")
