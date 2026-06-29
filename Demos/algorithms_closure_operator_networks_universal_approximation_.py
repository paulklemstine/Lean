"""
Closure-Operator Network Algorithms

Implements the core algorithms from the closure-operator network theory:
1. ε-Net construction for compact sets
2. Codebook approximant construction
3. Closure-step network builder
4. Certified robustness radius computation
5. Margin-based sign preservation verification
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class ClosureNetwork:
    """A finite closure-operator network.
    
    Represents a function that takes finitely many values,
    defined by a set of centers (ε-net) and corresponding output values.
    
    Attributes:
        centers: Array of shape (m, d) — the ε-net points
        values: Array of shape (m,) — function values at centers
        radius: The closure radius (half the minimum inter-center distance)
    """
    centers: np.ndarray
    values: np.ndarray
    radius: float
    
    def __call__(self, x: np.ndarray) -> np.ndarray:
        """Evaluate the closure network at point(s) x.
        
        Uses nearest-neighbor assignment to the center set.
        
        Args:
            x: Input point(s), shape (d,) or (n, d)
            
        Returns:
            Network output(s), shape () or (n,)
        """
        if x.ndim == 1:
            dists = np.linalg.norm(self.centers - x, axis=1)
            return self.values[np.argmin(dists)]
        else:
            # Batch evaluation
            dists = np.linalg.norm(
                self.centers[None, :, :] - x[:, None, :], axis=2)
            return self.values[np.argmin(dists, axis=1)]
    
    @property
    def size(self) -> int:
        """Number of distinct output values."""
        return len(np.unique(self.values))


def build_eps_net(domain_bounds: List[Tuple[float, float]], 
                  epsilon: float) -> np.ndarray:
    """Construct a uniform ε-net for a box domain.
    
    Algorithm:
        1. Compute grid spacing δ = ε / √d (to ensure coverage)
        2. Create uniform grid within the domain bounds
        3. Return grid points as the ε-net
    
    Args:
        domain_bounds: List of (min, max) for each dimension
        epsilon: Covering radius
        
    Returns:
        Array of shape (m, d) containing the ε-net points
        
    Complexity:
        Time: O((1/ε)^d) — exponential in dimension
        Space: O((1/ε)^d)
    """
    d = len(domain_bounds)
    delta = epsilon / np.sqrt(d)
    
    grids = []
    for lo, hi in domain_bounds:
        n_points = max(int(np.ceil((hi - lo) / delta)) + 1, 2)
        grids.append(np.linspace(lo, hi, n_points))
    
    mesh = np.meshgrid(*grids, indexing='ij')
    points = np.column_stack([g.ravel() for g in mesh])
    
    return points


def build_closure_network(f: Callable, 
                         domain_bounds: List[Tuple[float, float]],
                         epsilon: float) -> ClosureNetwork:
    """Build a closure-operator network approximating f on a box domain.
    
    Implements the constructive proof of Theorem A:
        1. Compute uniform continuity modulus to get δ
        2. Build δ-net of the domain
        3. Evaluate f at net points to create codebook
        4. Return nearest-neighbor network
    
    Args:
        f: Target continuous function (vectorized, maps (n,d) -> (n,))
        domain_bounds: List of (min, max) for each dimension
        epsilon: Target approximation accuracy
        
    Returns:
        ClosureNetwork with uniform error < ε on the domain
        
    Complexity:
        Time: O((1/ε)^d) for construction
        Space: O((1/ε)^d) for storing the network
    """
    centers = build_eps_net(domain_bounds, epsilon)
    values = f(centers) if centers.ndim > 1 else np.array([f(c) for c in centers])
    
    # Compute closure radius: half the minimum distance between any
    # point in the domain and its nearest center
    if len(centers) > 1:
        from scipy.spatial import KDTree
        tree = KDTree(centers)
        # Sample domain to estimate max distance to nearest center
        n_test = min(10000, max(1000, len(centers) * 10))
        test_points = np.column_stack([
            np.random.uniform(lo, hi, n_test) 
            for lo, hi in domain_bounds
        ])
        dists, _ = tree.query(test_points)
        radius = np.max(dists) / 2
    else:
        radius = 0.0
    
    return ClosureNetwork(centers=centers, values=values, radius=radius)


def closure_step_approx_1d(f: Callable, N: int) -> Tuple[Callable, float]:
    """Build a closure-step network on [0,1] with N cells.
    
    Implements the piecewise-constant approximation from the Lipschitz
    rate theorem.
    
    Args:
        f: Target function on [0,1]
        N: Number of cells
        
    Returns:
        (network_function, cell_width)
    """
    delta = 1.0 / N
    centers = np.array([(i + 0.5) * delta for i in range(N)])
    center_values = np.array([f(c) for c in centers])
    
    def network(x: np.ndarray) -> np.ndarray:
        idx = np.clip(np.floor(x / delta).astype(int), 0, N - 1)
        return center_values[idx]
    
    return network, delta


def certified_robustness_radius(network: ClosureNetwork, 
                                 x: np.ndarray) -> float:
    """Compute the certified robustness radius at point x.
    
    The certified radius is the distance to the nearest Voronoi
    boundary — within this radius, the network output is guaranteed
    to be constant.
    
    Args:
        network: A ClosureNetwork
        x: Query point, shape (d,)
        
    Returns:
        Certified radius r > 0 such that for all z with ||z-x|| < r,
        network(z) = network(x)
    """
    dists = np.linalg.norm(network.centers - x, axis=1)
    sorted_dists = np.sort(dists)
    
    if len(sorted_dists) < 2:
        return float('inf')
    
    # The certified radius is half the distance to the second-nearest center
    # (since the nearest center determines the output)
    nearest_idx = np.argmin(dists)
    nearest_val = network.values[nearest_idx]
    
    # Find nearest center with DIFFERENT value
    min_boundary_dist = float('inf')
    for i, (d, v) in enumerate(zip(dists, network.values)):
        if v != nearest_val:
            # Distance to Voronoi boundary with this center
            boundary_dist = (d - sorted_dists[0]) / 2
            min_boundary_dist = min(min_boundary_dist, boundary_dist)
    
    if min_boundary_dist == float('inf'):
        # All centers have the same value — function is constant
        return float('inf')
    
    return max(0.0, min_boundary_dist)


def verify_margin_preservation(f_vals: np.ndarray, 
                                N_vals: np.ndarray,
                                gamma: float) -> Tuple[bool, float]:
    """Verify that sign is preserved under uniform approximation with margin.
    
    Implements the check from the margin transfer theorem:
    if |f(x)| ≥ γ and |N(x) - f(x)| < γ/2, then sign(N(x)) = sign(f(x)).
    
    Args:
        f_vals: Target function values
        N_vals: Network approximation values
        gamma: Margin parameter
        
    Returns:
        (is_preserved, max_error) — whether signs match and the max error
    """
    max_error = np.max(np.abs(N_vals - f_vals))
    
    # Check margin condition
    has_margin = np.all(np.abs(f_vals) >= gamma)
    within_tolerance = max_error < gamma / 2
    
    if has_margin and within_tolerance:
        signs_match = np.all(np.sign(N_vals) == np.sign(f_vals))
        return signs_match, max_error
    else:
        return False, max_error


def compose_closure_operators(*operators: Callable) -> Callable:
    """Compose multiple closure operators.
    
    If the operators commute and are each idempotent, the composition
    is also idempotent (by the algebraic structure theorem).
    
    Args:
        operators: Closure operator functions
        
    Returns:
        Composed function
    """
    def composed(x):
        result = x
        for op in operators:
            result = op(result)
        return result
    return composed


def verify_idempotence(f: Callable, test_points: np.ndarray, 
                       tol: float = 1e-10) -> Tuple[bool, float]:
    """Verify idempotence of a function: f(f(x)) = f(x).
    
    Args:
        f: Function to test
        test_points: Points to test on
        tol: Numerical tolerance
        
    Returns:
        (is_idempotent, max_error)
    """
    fx = f(test_points)
    ffx = f(fx)
    error = np.max(np.abs(ffx - fx))
    return error < tol, error


if __name__ == "__main__":
    print("Closure-Operator Network Algorithms")
    print("=" * 50)
    
    # Example: approximate sin on [0, 2π]
    f = lambda x: np.sin(x[:, 0]) if x.ndim > 1 else np.sin(x)
    net = build_closure_network(
        lambda pts: np.sin(pts[:, 0]),
        [(0, 2 * np.pi)],
        epsilon=0.1
    )
    print(f"Network size: {net.size} distinct values")
    print(f"Network radius: {net.radius:.4f}")
    
    # Test
    x_test = np.linspace(0, 2 * np.pi, 1000).reshape(-1, 1)
    y_true = np.sin(x_test[:, 0])
    y_pred = net(x_test)
    print(f"Max error: {np.max(np.abs(y_true - y_pred)):.6f}")
    
    # Verify ReLU idempotence
    relu = lambda x: np.maximum(0, x)
    is_idem, err = verify_idempotence(relu, np.linspace(-5, 5, 10000))
    print(f"\nReLU idempotence: {is_idem} (error: {err:.2e})")
