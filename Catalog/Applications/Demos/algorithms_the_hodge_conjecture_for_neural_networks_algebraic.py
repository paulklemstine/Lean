"""
Algorithms for Neural Hodge Theory: Algebraic Cycles in Decision Surfaces

Implements the core mathematical structures and bounds from the formalization:
- ReLU activation and network evaluation
- Zaslavsky bound computation
- Network region bound estimation
- Polyhedral complex face counting
- Betti number estimation for decision surfaces
"""

from __future__ import annotations
from math import comb, prod, factorial
from typing import List, Tuple, Optional
from dataclasses import dataclass, field
import numpy as np


def relu(x: float) -> float:
    """ReLU activation function: max(x, 0)."""
    return max(x, 0.0)


def relu_vector(v: np.ndarray) -> np.ndarray:
    """Apply ReLU element-wise to a vector."""
    return np.maximum(v, 0.0)


def zaslavsky_bound(m: int, n: int) -> int:
    """
    Zaslavsky bound: maximum number of regions created by m hyperplanes in R^n.

    Returns sum_{k=0}^{n} C(m, k).

    This is an exact upper bound when hyperplanes are in general position.
    """
    return sum(comb(m, k) for k in range(n + 1))


@dataclass
class NetworkArchitecture:
    """Architecture specification for a ReLU neural network.

    Attributes:
        input_dim: Dimension of input space
        hidden_widths: List of hidden layer widths
    """
    input_dim: int
    hidden_widths: List[int]

    @property
    def depth(self) -> int:
        """Number of hidden layers."""
        return len(self.hidden_widths)

    @property
    def total_neurons(self) -> int:
        """Total number of neurons across all hidden layers."""
        return sum(self.hidden_widths)

    def region_bound(self) -> int:
        """
        Upper bound on the number of linear regions.

        For a network with hidden widths w_1, ..., w_L and input dimension n,
        the bound is prod_i zaslavsky_bound(w_i, n).
        """
        return prod(zaslavsky_bound(w, self.input_dim) for w in self.hidden_widths)

    def polynomial_region_bound(self) -> int:
        """
        Polynomial upper bound: prod_i (w_i + 1)^n.

        This is a looser but more interpretable bound.
        """
        n = self.input_dim
        return prod((w + 1) ** n for w in self.hidden_widths)

    def hodge_number_bound(self, p: int, q: int) -> int:
        """
        Conjectured bound on the Hodge number h^{p,q} of the decision surface.

        For a network with >= 2 hidden layers:
        h^{p,q} <= C(w_1, p) * C(w_L, q) * prod_{i=2}^{L-1} w_i
        """
        if self.depth < 2:
            return 1
        w1 = self.hidden_widths[0]
        wL = self.hidden_widths[-1]
        middle_prod = prod(self.hidden_widths[1:-1]) if self.depth > 2 else 1
        return comb(w1, p) * comb(wL, q) * middle_prod


@dataclass
class PLComplex:
    """Polyhedral complex with face vector.

    Attributes:
        dim: Maximum dimension of faces
        f_vec: Face numbers f_0, f_1, ..., f_dim
    """
    dim: int
    f_vec: List[int]

    def __post_init__(self):
        assert len(self.f_vec) == self.dim + 1
        assert self.f_vec[self.dim] > 0

    @property
    def total_faces(self) -> int:
        """Total number of faces across all dimensions."""
        return sum(self.f_vec)

    @property
    def euler_characteristic(self) -> int:
        """Euler characteristic: alternating sum of face numbers."""
        return sum((-1)**k * f for k, f in enumerate(self.f_vec))

    def betti_bound(self, k: int) -> int:
        """Crude upper bound on k-th Betti number: beta_k <= f_k."""
        if 0 <= k <= self.dim:
            return self.f_vec[k]
        return 0


@dataclass
class ReLUNetwork:
    """A ReLU neural network f: R^n -> R.

    Weights[i] is the weight matrix for layer i (shape: w_{i+1} x w_i).
    Biases[i] is the bias vector for layer i (shape: w_{i+1}).
    """
    weights: List[np.ndarray]
    biases: List[np.ndarray]

    @property
    def architecture(self) -> NetworkArchitecture:
        input_dim = self.weights[0].shape[1]
        hidden_widths = [w.shape[0] for w in self.weights[:-1]]
        return NetworkArchitecture(input_dim, hidden_widths)

    def forward(self, x: np.ndarray) -> np.ndarray:
        """Evaluate the network at input x."""
        h = x.copy()
        for i, (W, b) in enumerate(zip(self.weights, self.biases)):
            h = W @ h + b
            if i < len(self.weights) - 1:  # ReLU on hidden layers only
                h = relu_vector(h)
        return h

    def decision_surface_sample(
        self, bounds: Tuple[float, float], resolution: int = 100
    ) -> Optional[np.ndarray]:
        """
        Sample points near the decision surface V(f) = {x : f(x) = 0}
        in 2D (only works for input_dim=2).
        """
        if self.weights[0].shape[1] != 2:
            raise ValueError("Only supports 2D input")
        lo, hi = bounds
        xs = np.linspace(lo, hi, resolution)
        ys = np.linspace(lo, hi, resolution)
        X, Y = np.meshgrid(xs, ys)
        Z = np.zeros_like(X)
        for i in range(resolution):
            for j in range(resolution):
                Z[i, j] = self.forward(np.array([X[i, j], Y[i, j]]))[0]
        return X, Y, Z


def estimate_betti_from_grid(
    network: ReLUNetwork,
    bounds: Tuple[float, float] = (-3.0, 3.0),
    resolution: int = 200
) -> int:
    """
    Estimate beta_0 (number of connected components of the positive region)
    using grid sampling. This is a crude but computable estimate.
    """
    if network.weights[0].shape[1] != 2:
        raise ValueError("Only supports 2D")
    lo, hi = bounds
    xs = np.linspace(lo, hi, resolution)
    ys = np.linspace(lo, hi, resolution)

    signs = np.zeros((resolution, resolution), dtype=int)
    for i in range(resolution):
        for j in range(resolution):
            val = network.forward(np.array([xs[j], ys[i]]))[0]
            signs[i, j] = 1 if val > 0 else 0

    # Count connected components using flood fill
    visited = np.zeros_like(signs, dtype=bool)
    components = 0
    for i in range(resolution):
        for j in range(resolution):
            if not visited[i, j] and signs[i, j] == 1:
                # BFS flood fill
                stack = [(i, j)]
                while stack:
                    ci, cj = stack.pop()
                    if visited[ci, cj]:
                        continue
                    visited[ci, cj] = True
                    for di, dj in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        ni, nj = ci + di, cj + dj
                        if 0 <= ni < resolution and 0 <= nj < resolution:
                            if not visited[ni, nj] and signs[ni, nj] == 1:
                                stack.append((ni, nj))
                components += 1
    return components


def verify_hodge_bound(arch: NetworkArchitecture, num_trials: int = 100) -> dict:
    """
    Empirically verify the neural Hodge bound conjecture.

    For random networks with the given architecture, compute beta_0
    (number of positive-region components) and check against the
    Hodge number bound.
    """
    np.random.seed(42)
    results = {
        "architecture": f"{arch.input_dim} -> {' -> '.join(map(str, arch.hidden_widths))} -> 1",
        "region_bound": arch.region_bound(),
        "hodge_bound_01": arch.hodge_number_bound(0, 1),
        "max_beta0": 0,
        "violations": 0,
        "trials": num_trials,
    }

    if arch.input_dim != 2:
        results["note"] = "Skipped: only 2D supported for empirical test"
        return results

    for _ in range(num_trials):
        widths = [arch.input_dim] + arch.hidden_widths + [1]
        weights = [np.random.randn(widths[i+1], widths[i]) * 0.5
                   for i in range(len(widths) - 1)]
        biases = [np.random.randn(widths[i+1]) * 0.3
                  for i in range(len(widths) - 1)]
        net = ReLUNetwork(weights, biases)
        beta0 = estimate_betti_from_grid(net, bounds=(-5, 5), resolution=100)
        results["max_beta0"] = max(results["max_beta0"], beta0)
        if beta0 > results["hodge_bound_01"]:
            results["violations"] += 1

    return results
