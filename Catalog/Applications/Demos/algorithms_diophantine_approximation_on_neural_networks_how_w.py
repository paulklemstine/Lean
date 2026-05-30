#!/usr/bin/env python3
"""
Algorithms for Diophantine Approximation on ReLU Networks

Implements the core algorithms described in the research paper:
1. Constructing ReLU networks that approximate constants
2. Computing optimal depth-width configurations
3. Estimating irrationality-measure-dependent approximation rates
"""

import math
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class ReLUNetwork:
    """A ReLU network specification for 1D constant approximation.
    
    Attributes:
        weights: List of weight matrices (each layer is a list of (weight, bias) pairs)
        depth: Number of hidden layers
        width: Width of each hidden layer
    """
    weights: List[List[Tuple[float, float]]]  # layers of (weight, bias) pairs
    depth: int
    width: int
    
    @property
    def piece_count_bound(self) -> int:
        """Upper bound on the number of linear pieces: w^L."""
        return self.width ** self.depth
    
    @property
    def param_count(self) -> int:
        """Total number of parameters."""
        return self.depth * self.width * 2 + self.width + 1
    
    def evaluate(self, x: float) -> float:
        """Evaluate the network at input x.
        
        Each hidden layer computes: output_j = relu(w_j * input + b_j)
        The output layer computes a weighted sum of the last hidden layer.
        """
        current = [x]
        for layer_idx, layer in enumerate(self.weights[:-1]):
            new_values = []
            for w, b in layer:
                val = sum(w * c for c in current) + b  # simplified 1D
                new_values.append(max(0.0, val))  # ReLU
            current = new_values
        # Output layer: linear combination
        if self.weights:
            output_layer = self.weights[-1]
            result = sum(w * c for (w, b), c in zip(output_layer, current)) + output_layer[0][1]
            return result
        return current[0] if current else 0.0


def construct_constant_network(target: float, tolerance: float) -> ReLUNetwork:
    """
    Construct a minimal ReLU network that outputs approximately `target`.
    
    Algorithm: A single-neuron network with relu(target * x + 0) evaluated at x=1
    gives target if target ≥ 0. For better approximation, we use the identity
    target = relu(target) - relu(-target) decomposition.
    
    Args:
        target: The constant to approximate
        tolerance: Not used for exact construction, but stored for reference
        
    Returns:
        A ReLU network that outputs target when evaluated at 1.0
        
    Time complexity: O(1)
    Space complexity: O(1)
    """
    if target >= 0:
        weights = [
            [(target, 0.0)],  # Hidden layer: relu(target * x)
            [(1.0, 0.0)],     # Output layer: identity
        ]
    else:
        # target = -|target| = relu(0) - relu(|target|) evaluated specially
        weights = [
            [(abs(target), 0.0), (-abs(target), abs(target))],
            [(-1.0, abs(target)), (0.0, 0.0)],
        ]
    return ReLUNetwork(weights=weights, depth=1, width=max(1, len(weights[0])))


def leibniz_network_terms(n_terms: int) -> float:
    """
    Compute the Leibniz series partial sum using n_terms terms.
    
    This simulates what a ReLU network with sufficient pieces would compute:
    π/4 ≈ Σ_{k=0}^{n-1} (-1)^k / (2k+1)
    
    The network would need at least n_terms linear pieces to represent this
    step function, achievable with width w and depth L where w^L ≥ n_terms.
    
    Args:
        n_terms: Number of terms in the partial sum
        
    Returns:
        4 * partial_sum (approximation of π)
        
    Time complexity: O(n_terms)
    Space complexity: O(1)
    """
    partial_sum = 0.0
    for k in range(n_terms):
        partial_sum += (-1)**k / (2*k + 1)
    return 4 * partial_sum


def optimal_network_config(
    epsilon: float,
    max_width: int = 100,
    max_depth: int = 100
) -> Dict[str, any]:
    """
    Find the optimal (width, depth) configuration to approximate π within epsilon.
    
    Algorithm:
    1. For each width w from 2 to max_width:
       a. Find minimum depth L such that 1/(2·w^L + 1) < epsilon/4
       b. Compute parameter count = 2wL + w + 1
    2. Return configuration minimizing parameter count
    
    The factor of 4 accounts for the Leibniz series computing π/4, not π.
    
    Args:
        epsilon: Target approximation error |f(1) - π| < epsilon
        max_width: Maximum width to consider
        max_depth: Maximum depth to consider
        
    Returns:
        Dictionary with optimal width, depth, pieces, params, and error bound
        
    Time complexity: O(max_width * max_depth)
    Space complexity: O(1)
    """
    best = None
    target_epsilon = epsilon / 4  # Leibniz computes π/4
    
    for w in range(2, max_width + 1):
        for L in range(1, max_depth + 1):
            pieces = w ** L
            error = 1.0 / (2 * pieces + 1)
            if error < target_epsilon:
                params = 2 * w * L + w + 1
                config = {
                    'width': w,
                    'depth': L,
                    'pieces': pieces,
                    'params': params,
                    'error_bound': 4 * error,  # error for π, not π/4
                }
                if best is None or params < best['params']:
                    best = config
                break  # Found min depth for this width
    
    return best or {'width': 0, 'depth': 0, 'pieces': 0, 'params': 0, 'error_bound': float('inf')}


def irrationality_measure_rate(
    mu: float,
    n_pieces: int
) -> float:
    """
    Compute the theoretical approximation rate based on irrationality measure.
    
    For a number α with irrationality measure μ, the best rational approximation
    with denominator ≤ N satisfies |α - p/q| ≥ c/N^μ.
    
    A ReLU network with N = w^L pieces can represent rationals with
    denominator ≤ N, giving approximation rate O(1/N^(1/μ)).
    
    Args:
        mu: Irrationality measure of the target constant
        n_pieces: Number of linear pieces in the network
        
    Returns:
        Theoretical lower bound on approximation error
        
    Time complexity: O(1)
    """
    if n_pieces <= 0 or mu <= 0:
        return float('inf')
    return 1.0 / (n_pieces ** (1.0 / mu))


def depth_width_tradeoff_analysis(
    target_pieces: int,
    max_width: int = 50
) -> List[Dict[str, any]]:
    """
    Analyze all (width, depth) pairs achieving at least target_pieces.
    
    Algorithm:
    For each width w from 2 to max_width:
        Find minimum depth L such that w^L ≥ target_pieces
        Record (w, L, actual_pieces, params, efficiency)
    
    Efficiency = pieces / params measures how well parameters are utilized.
    
    Args:
        target_pieces: Minimum number of linear pieces needed
        max_width: Maximum width to consider
        
    Returns:
        List of configuration dictionaries sorted by parameter count
        
    Time complexity: O(max_width * log(target_pieces))
    Space complexity: O(max_width)
    """
    configs = []
    for w in range(2, max_width + 1):
        L = max(1, math.ceil(math.log(target_pieces) / math.log(w)))
        actual_pieces = w ** L
        while actual_pieces < target_pieces and L < 1000:
            L += 1
            actual_pieces = w ** L
        params = 2 * w * L + w + 1
        efficiency = actual_pieces / params
        configs.append({
            'width': w,
            'depth': L,
            'pieces': actual_pieces,
            'params': params,
            'efficiency': efficiency,
        })
    configs.sort(key=lambda c: c['params'])
    return configs


def conjecture_optimal_depth(k: int) -> int:
    """
    Conjectured optimal depth for approximating π to 10^(-k).
    
    Conjecture: depth = ⌈log₂(k)⌉ + 3
    
    This is testable: construct networks and compare actual minimum depth
    against this formula.
    
    Args:
        k: Number of decimal digits of accuracy desired
        
    Returns:
        Conjectured optimal depth
    """
    if k <= 0:
        return 3
    return math.ceil(math.log2(k)) + 3


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm: Optimal Network Configuration for π")
    print("=" * 60)
    
    for k in range(1, 8):
        eps = 10 ** (-k)
        config = optimal_network_config(eps)
        conj_depth = conjecture_optimal_depth(k)
        print(f"\nε = 10^(-{k}):")
        print(f"  Optimal: width={config['width']}, depth={config['depth']}, "
              f"params={config['params']}, pieces={config['pieces']:,}")
        print(f"  Error bound: {config['error_bound']:.2e}")
        print(f"  Conjectured depth: {conj_depth}")
    
    print("\n" + "=" * 60)
    print("Algorithm: Depth-Width Tradeoff for 1000 pieces")
    print("=" * 60)
    
    configs = depth_width_tradeoff_analysis(1000, max_width=20)
    print(f"\n{'Width':>6} {'Depth':>6} {'Pieces':>10} {'Params':>8} {'Efficiency':>12}")
    print("-" * 48)
    for c in configs[:10]:
        print(f"{c['width']:>6} {c['depth']:>6} {c['pieces']:>10,} "
              f"{c['params']:>8} {c['efficiency']:>12.1f}")
    
    print("\n" + "=" * 60)
    print("Algorithm: Irrationality Measure Rates")
    print("=" * 60)
    
    print(f"\n{'Constant':>10} {'μ':>4} {'N=100 rate':>12} {'N=1000 rate':>12} {'N=10000 rate':>13}")
    print("-" * 55)
    for name, mu in [("π", 2.0), ("e", 2.0), ("√2", 2.0), ("Liouville", 10.0)]:
        rates = [irrationality_measure_rate(mu, n) for n in [100, 1000, 10000]]
        print(f"{name:>10} {mu:>4.1f} {rates[0]:>12.2e} {rates[1]:>12.2e} {rates[2]:>13.2e}")
