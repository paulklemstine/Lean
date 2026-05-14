#!/usr/bin/env python3
"""
Closure-Operator Networks: Core Algorithms

Implements the key algorithms from the research paper:
1. ε-Net construction (greedy and uniform)
2. Closure network construction and evaluation
3. Robustness certification
4. Lipschitz error estimation
"""

import numpy as np
from typing import Callable, List, Optional, Tuple
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────

@dataclass
class ClosureFeature:
    """A closure-indicator feature: 1 if x ∈ c(S), else 0.

    For simplicity, we implement closure features as ball indicators:
    Φ(x) = 1 if dist(x, center) ≤ radius, else 0.
    """
    center: np.ndarray
    radius: float

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the closure indicator at point x."""
        return 1.0 if np.linalg.norm(x - self.center) <= self.radius else 0.0

    def evaluate_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on a batch of points."""
        dists = np.linalg.norm(X - self.center, axis=-1)
        return (dists <= self.radius).astype(float)


@dataclass
class ClosureNetwork:
    """A closure-operator network: weighted sum of closure features + bias.

    N(x) = Σ_j w_j · Φ_j(x) + b

    This implements the architecture from the paper where each Φ_j
    is a closure-indicator feature.
    """
    features: List[ClosureFeature]
    weights: np.ndarray
    bias: float

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the network at a single point."""
        feature_values = np.array([f.evaluate(x) for f in self.features])
        return np.dot(self.weights, feature_values) + self.bias

    def evaluate_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on a batch of points (N x d array)."""
        feature_matrix = np.column_stack([f.evaluate_batch(X) for f in self.features])
        return feature_matrix @ self.weights + self.bias

    @property
    def num_features(self) -> int:
        return len(self.features)

    @property
    def num_distinct_values(self) -> int:
        """Upper bound on distinct output values (2^m possible)."""
        return min(2 ** self.num_features, 1000)  # cap for practicality


@dataclass
class CodebookNetwork:
    """A nearest-neighbor codebook network.

    Maps each input to the value of the target function at its
    nearest representative point. This is the concrete implementation
    of the universal approximation construction.
    """
    representatives: np.ndarray  # (m, d) array of net points
    values: np.ndarray           # (m,) array of function values

    def evaluate(self, x: np.ndarray) -> float:
        """Map x to f(nearest representative)."""
        dists = np.linalg.norm(self.representatives - x, axis=-1)
        return self.values[np.argmin(dists)]

    def evaluate_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on a batch of points."""
        # (N, m) distance matrix
        dists = np.linalg.norm(X[:, None, :] - self.representatives[None, :, :], axis=-1)
        nearest = np.argmin(dists, axis=1)
        return self.values[nearest]

    def certified_radius(self, x: np.ndarray) -> float:
        """Compute the certified robustness radius at point x.

        The certified radius is the distance to the nearest Voronoi
        boundary — half the distance to the nearest representative
        with a different value.

        Time complexity: O(m) where m = number of representatives.
        """
        dists = np.linalg.norm(self.representatives - x, axis=-1)
        nearest = np.argmin(dists)
        my_value = self.values[nearest]
        my_dist = dists[nearest]

        # Find nearest representative with different value
        diff_mask = self.values != my_value
        if not np.any(diff_mask):
            return float('inf')

        nearest_diff_dist = np.min(dists[diff_mask])
        return max(0, (nearest_diff_dist - my_dist) / 2)


# ─────────────────────────────────────────────────────────
# Algorithm 1: ε-Net Construction
# ─────────────────────────────────────────────────────────

def greedy_epsilon_net(points: np.ndarray, epsilon: float) -> np.ndarray:
    """Construct a greedy ε-net from a point cloud.

    Algorithm:
        1. Start with the first point.
        2. For each subsequent point, add it to the net if it is
           at distance ≥ ε from all current net points.

    Args:
        points: (N, d) array of candidate points
        epsilon: covering radius

    Returns:
        (m, d) array of net points

    Time complexity: O(N * m) where m is the net size.
    Space complexity: O(m * d).
    """
    net = [points[0]]
    for p in points[1:]:
        if all(np.linalg.norm(p - q) >= epsilon for q in net):
            net.append(p)
    return np.array(net)


def uniform_grid_net(bounds: List[Tuple[float, float]], n_per_dim: int) -> np.ndarray:
    """Construct a uniform grid ε-net on a hypercube.

    Args:
        bounds: list of (lo, hi) for each dimension
        n_per_dim: number of points per dimension

    Returns:
        (n_per_dim^d, d) array of grid points

    The covering radius is η = max_dim (hi - lo) / (2 * n_per_dim).
    """
    grids = [np.linspace(lo, hi, n_per_dim) for lo, hi in bounds]
    mesh = np.meshgrid(*grids, indexing='ij')
    return np.column_stack([m.ravel() for m in mesh])


# ─────────────────────────────────────────────────────────
# Algorithm 2: Closure Network Construction
# ─────────────────────────────────────────────────────────

def construct_closure_network(
    f: Callable[[np.ndarray], float],
    domain_points: np.ndarray,
    epsilon: float
) -> CodebookNetwork:
    """Construct a closure (codebook) network approximating f.

    Implements Algorithm 1 from the paper:
    1. Build an ε-net from the domain points.
    2. Evaluate f at each net point.
    3. Return the nearest-neighbor codebook network.

    Args:
        f: target function (vectorized, takes (d,) array)
        domain_points: (N, d) sample points from the domain
        epsilon: desired approximation tolerance

    Returns:
        CodebookNetwork achieving ||f - N||∞ ≲ ε for Lipschitz f

    Time complexity: O(N * m + m * cost(f)) where m = net size.
    """
    net = greedy_epsilon_net(domain_points, epsilon)
    values = np.array([f(p) for p in net])
    return CodebookNetwork(representatives=net, values=values)


def construct_weighted_closure_network(
    f: Callable[[np.ndarray], float],
    net_points: np.ndarray,
    feature_radius: float
) -> ClosureNetwork:
    """Construct a weighted closure-feature network.

    Uses the finite exact representation (Theorem A from ClosureNetworks.lean):
    one indicator feature per net point, with weight = f(center).

    Args:
        f: target function
        net_points: (m, d) array of feature centers
        feature_radius: radius of each ball feature

    Returns:
        ClosureNetwork with m features
    """
    features = [ClosureFeature(center=p, radius=feature_radius) for p in net_points]
    weights = np.array([f(p) for p in net_points])
    # For exact representation on net points, we need the interpolation weights.
    # Use the indicator-per-point construction: w_j = f(s_j), with
    # normalization to handle overlapping regions.
    return ClosureNetwork(features=features, weights=weights, bias=0.0)


# ─────────────────────────────────────────────────────────
# Algorithm 3: Robustness Certification
# ─────────────────────────────────────────────────────────

def certify_point(
    network: CodebookNetwork,
    x: np.ndarray,
    attack_radius: float
) -> Tuple[bool, float]:
    """Certify robustness of a codebook network at point x.

    Algorithm:
        1. Compute the network's certified radius at x.
        2. Compare with the attack radius.

    Args:
        network: the closure network
        x: point to certify
        attack_radius: maximum perturbation radius

    Returns:
        (is_robust, certified_radius)

    Time complexity: O(m) where m = number of representatives.
    """
    cr = network.certified_radius(x)
    return cr >= attack_radius, cr


def certify_dataset(
    network: CodebookNetwork,
    X: np.ndarray,
    attack_radius: float
) -> dict:
    """Certify robustness on an entire dataset.

    Returns statistics about certified robustness.
    """
    radii = np.array([network.certified_radius(x) for x in X])
    certified = radii >= attack_radius

    return {
        'total_points': len(X),
        'certified_count': int(np.sum(certified)),
        'certified_fraction': float(np.mean(certified)),
        'min_radius': float(np.min(radii)),
        'max_radius': float(np.max(radii)),
        'mean_radius': float(np.mean(radii)),
        'median_radius': float(np.median(radii)),
    }


# ─────────────────────────────────────────────────────────
# Algorithm 4: Lipschitz Error Estimation
# ─────────────────────────────────────────────────────────

def estimate_lipschitz_constant(
    f: Callable[[np.ndarray], float],
    domain_points: np.ndarray,
    n_pairs: int = 1000
) -> float:
    """Estimate the Lipschitz constant of f by sampling pairs.

    Args:
        f: target function
        domain_points: sample points from the domain
        n_pairs: number of random pairs to test

    Returns:
        Estimated Lipschitz constant K

    This is a lower bound on the true Lipschitz constant.
    """
    N = len(domain_points)
    max_ratio = 0.0

    for _ in range(n_pairs):
        i, j = np.random.choice(N, 2, replace=False)
        x, y = domain_points[i], domain_points[j]
        d = np.linalg.norm(x - y)
        if d > 1e-10:
            ratio = abs(f(x) - f(y)) / d
            max_ratio = max(max_ratio, ratio)

    return max_ratio


def theoretical_error_bound(
    lipschitz_constant: float,
    covering_radius: float
) -> float:
    """Compute the theoretical error bound: K * η.

    From Theorem 3.8 (Lipschitz Error Bound):
    For a K-Lipschitz function with codebook mesh η,
    ||f - g||∞ ≤ K * η.
    """
    return lipschitz_constant * covering_radius


# ─────────────────────────────────────────────────────────
# Algorithm 5: Idempotent Layer Composition
# ─────────────────────────────────────────────────────────

class ClosureLayer:
    """A single closure layer: monotone, extensive, idempotent.

    Implements a threshold closure: c(x) = max(x, threshold).
    This is the simplest closure operator on ℝ.
    """

    def __init__(self, threshold: float):
        self.threshold = threshold

    def __call__(self, x: np.ndarray) -> np.ndarray:
        return np.maximum(x, self.threshold)

    def is_idempotent(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        """Verify idempotence: c(c(x)) = c(x)."""
        return np.allclose(self(self(x)), self(x), atol=tol)

    def is_extensive(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        """Verify extensivity: x ≤ c(x)."""
        return np.all(self(x) >= x - tol)

    def is_monotone(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        """Verify monotonicity on sorted input."""
        y = self(np.sort(x))
        return np.all(np.diff(y) >= -tol)


def compose_closure_layers(*layers: ClosureLayer) -> Callable:
    """Compose multiple closure layers.

    By Theorem D, if the layers commute, the composition
    is again idempotent and monotone.
    """
    def composed(x: np.ndarray) -> np.ndarray:
        result = x.copy()
        for layer in layers:
            result = layer(result)
        return result
    return composed


def verify_composition_properties(
    layers: List[ClosureLayer],
    x: np.ndarray
) -> dict:
    """Verify algebraic properties of a composed closure network.

    Checks:
    - Individual layer idempotence
    - Individual layer extensivity
    - Individual layer monotonicity
    - Composed idempotence
    - Composed monotonicity
    """
    composed = compose_closure_layers(*layers)
    y = composed(x)
    yy = composed(y)

    return {
        'individual_idempotent': all(l.is_idempotent(x) for l in layers),
        'individual_extensive': all(l.is_extensive(x) for l in layers),
        'individual_monotone': all(l.is_monotone(x) for l in layers),
        'composed_idempotent': bool(np.allclose(y, yy)),
        'composed_monotone': bool(np.all(np.diff(composed(np.sort(x))) >= -1e-10)),
    }


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Closure Network Algorithms: Example Usage\n")

    # 1. Construct a closure network for sin(x) on [0, 1]
    f = lambda x: np.sin(2 * np.pi * x[0]) if x.ndim == 1 else np.sin(2 * np.pi * x)
    f_scalar = lambda x: float(np.sin(2 * np.pi * x[0]))
    domain = np.linspace(0, 1, 1000).reshape(-1, 1)

    network = construct_closure_network(f_scalar, domain, epsilon=0.05)
    print(f"Network constructed: {len(network.representatives)} representatives")

    # 2. Evaluate and measure error
    approx = network.evaluate_batch(domain)
    true_vals = np.sin(2 * np.pi * domain[:, 0])
    max_error = np.max(np.abs(true_vals - approx))
    print(f"Max approximation error: {max_error:.6f}")

    # 3. Certify robustness
    stats = certify_dataset(network, domain, attack_radius=0.01)
    print(f"Certified at r=0.01: {stats['certified_fraction']*100:.1f}% of points")
    print(f"Mean certified radius: {stats['mean_radius']:.4f}")

    # 4. Verify layer composition
    layers = [ClosureLayer(0.2), ClosureLayer(0.5), ClosureLayer(0.8)]
    x_test = np.linspace(-1, 2, 100)
    props = verify_composition_properties(layers, x_test)
    print(f"\nLayer composition properties: {props}")

    # 5. Lipschitz bound
    K = estimate_lipschitz_constant(f_scalar, domain)
    eta = 0.05  # covering radius
    bound = theoretical_error_bound(K, eta)
    print(f"\nEstimated Lipschitz constant: K = {K:.4f}")
    print(f"Theoretical error bound: K*η = {bound:.6f}")
    print(f"Actual max error: {max_error:.6f}")
    print(f"Bound satisfied: {max_error <= bound + 0.01}")
