"""
Algorithms for Impossible Figure Analysis via Monodromy Theory.

This module implements the key algorithms from the cocycle obstruction
framework for impossible figures:
- Monodromy computation
- Realizability testing
- Height function construction
- Orientation cocycle analysis
- Euler characteristic computation
"""

from typing import List, Optional, Tuple
from fractions import Fraction
import math


def compute_monodromy(weights: List[float]) -> float:
    """Compute the monodromy of a weight function on a cycle graph.
    
    The monodromy is the sum of all edge weights, measuring the total
    height gain after traversing the full cycle.
    
    Args:
        weights: Edge weights w(i) for i = 0, ..., n-1.
        
    Returns:
        The monodromy μ(w) = Σ w(i).
        
    Time complexity: O(n)
    
    >>> compute_monodromy([1.0, 1.0, 1.0])
    3.0
    >>> compute_monodromy([1.0, -1.0, 0.5, -0.5])
    0.0
    """
    return sum(weights)


def is_realizable(weights: List[float], tol: float = 1e-12) -> bool:
    """Test whether a weight function is realizable (monodromy ≈ 0).
    
    A weight function is realizable iff its monodromy vanishes.
    We use a tolerance for floating-point comparison.
    
    Args:
        weights: Edge weights on the cycle.
        tol: Tolerance for zero-testing.
        
    Returns:
        True if |μ(w)| < tol.
        
    >>> is_realizable([1.0, -0.5, -0.5])
    True
    >>> is_realizable([1.0, 1.0, 1.0])
    False
    """
    return abs(compute_monodromy(weights)) < tol


def construct_height_function(weights: List[float]) -> Optional[List[float]]:
    """Construct a height realization if one exists.
    
    If the monodromy is zero, constructs h(i) = Σ_{j<i} w(j).
    
    Args:
        weights: Edge weights on the cycle.
        
    Returns:
        Height function h : [0, ..., n-1] → ℝ if realizable, None otherwise.
        
    >>> construct_height_function([1.0, -0.5, -0.5])
    [0.0, 1.0, 0.5]
    >>> construct_height_function([1.0, 1.0, 1.0]) is None
    True
    """
    if not is_realizable(weights):
        return None
    
    n = len(weights)
    h = [0.0] * n
    for i in range(1, n):
        h[i] = h[i-1] + weights[i-1]
    return h


def verify_realization(weights: List[float], heights: List[float], 
                       tol: float = 1e-10) -> bool:
    """Verify that a height function is a valid realization.
    
    Checks that h(succ(i)) - h(i) = w(i) for all i.
    
    Args:
        weights: Edge weights.
        heights: Proposed height function.
        tol: Tolerance for comparison.
        
    Returns:
        True if the heights are consistent with the weights.
    """
    n = len(weights)
    if len(heights) != n:
        return False
    for i in range(n):
        succ_i = (i + 1) % n
        if abs(heights[succ_i] - heights[i] - weights[i]) > tol:
            return False
    return True


def is_escher_staircase(weights: List[float]) -> bool:
    """Test whether a weight function is an Escher staircase (all positive).
    
    >>> is_escher_staircase([1.0, 2.0, 0.5])
    True
    >>> is_escher_staircase([1.0, -1.0, 0.5])
    False
    """
    return all(w > 0 for w in weights)


def is_descending_escher(weights: List[float]) -> bool:
    """Test whether a weight function is a descending Escher staircase.
    
    >>> is_descending_escher([-1.0, -2.0, -0.5])
    True
    """
    return all(w < 0 for w in weights)


def penrose_weights(delta: float, n: int = 3) -> List[float]:
    """Generate Penrose triangle weights with step size delta.
    
    Args:
        delta: The height increment at each edge.
        n: Number of edges (default 3 for the triangle).
        
    Returns:
        Constant weight function [delta, delta, ..., delta].
        
    >>> penrose_weights(1.0)
    [1.0, 1.0, 1.0]
    """
    return [delta] * n


def orientation_holonomy(signs: List[int]) -> int:
    """Compute the holonomy of an orientation cocycle.
    
    Each sign should be +1 or -1.
    
    Args:
        signs: List of ±1 values assigned to edges.
        
    Returns:
        Product of all signs (always ±1).
        
    >>> orientation_holonomy([1, 1, -1, -1])
    1
    >>> orientation_holonomy([1, -1, 1])
    -1
    """
    result = 1
    for s in signs:
        assert s in (1, -1), f"Sign must be ±1, got {s}"
        result *= s
    return result


def is_orientable(signs: List[int]) -> bool:
    """Test orientability of a surface from its orientation cocycle.
    
    >>> is_orientable([1, 1, 1])
    True
    >>> is_orientable([1, -1, 1])
    False
    """
    return orientation_holonomy(signs) == 1


def count_reversals(signs: List[int]) -> int:
    """Count the number of orientation-reversing edges.
    
    >>> count_reversals([1, -1, 1, -1, -1])
    3
    """
    return sum(1 for s in signs if s == -1)


def euler_characteristic(vertices: int, edges: int, faces: int) -> int:
    """Compute the Euler characteristic χ = V - E + F.
    
    >>> euler_characteristic(1, 2, 1)  # Klein bottle / Torus
    0
    >>> euler_characteristic(1, 0, 1)  # Sphere
    2
    >>> euler_characteristic(1, 1, 1)  # RP²
    1
    """
    return vertices - edges + faces


def connected_sum_euler(chi1: int, chi2: int) -> int:
    """Euler characteristic of connected sum: χ(M # N) = χ(M) + χ(N) - 2.
    
    >>> connected_sum_euler(2, 2)  # S² # S² ~ S² (genus 0)
    2
    >>> connected_sum_euler(0, 0)  # T² # T² (genus 2)
    -2
    >>> connected_sum_euler(1, 1)  # RP² # RP² (Klein bottle)
    0
    """
    return chi1 + chi2 - 2


def rational_approximation(weights: List[float], epsilon: float
                           ) -> List[Fraction]:
    """Find rational weights approximating given real weights.
    
    Guarantees |w(i) - w'(i)| < epsilon for all i and
    |μ(w) - μ(w')| < epsilon.
    
    Args:
        weights: Real-valued edge weights.
        epsilon: Approximation tolerance.
        
    Returns:
        Rational weight function close to the original.
    """
    n = len(weights)
    eps_per_edge = epsilon / (n + 1)
    result = []
    for w in weights:
        # Find rational approximation within eps_per_edge
        frac = Fraction(w).limit_denominator(
            int(1 / eps_per_edge) + 1
        )
        result.append(frac)
    return result


def classify_impossible_figure(weights: List[float]) -> dict:
    """Complete classification of an impossible figure.
    
    Returns a dictionary with:
    - monodromy: the monodromy value
    - realizable: whether a height function exists
    - is_escher: whether it's an ascending Escher staircase
    - is_descending: whether it's a descending staircase
    - height_function: the realization if one exists
    
    >>> result = classify_impossible_figure([1.0, 1.0, 1.0])
    >>> result['monodromy']
    3.0
    >>> result['realizable']
    False
    >>> result['is_escher']
    True
    """
    mono = compute_monodromy(weights)
    realizable = is_realizable(weights)
    heights = construct_height_function(weights) if realizable else None
    
    return {
        'monodromy': mono,
        'realizable': realizable,
        'is_escher': is_escher_staircase(weights),
        'is_descending': is_descending_escher(weights),
        'height_function': heights,
        'n_edges': len(weights),
        'classification': 'realizable' if realizable else 'impossible'
    }


def monodromy_bound(weights: List[float]) -> Tuple[float, float]:
    """Compute the monodromy and its theoretical upper bound.
    
    Returns (|μ(w)|, n * max|w(i)|).
    
    >>> monodromy_bound([1.0, -2.0, 0.5])
    (0.5, 6.0)
    """
    n = len(weights)
    B = max(abs(w) for w in weights) if weights else 0.0
    return (abs(compute_monodromy(weights)), n * B)


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    
    # Demo: Penrose triangle
    print("=== Penrose Triangle (δ=1) ===")
    pw = penrose_weights(1.0)
    result = classify_impossible_figure(pw)
    print(f"Weights: {pw}")
    print(f"Monodromy: {result['monodromy']}")
    print(f"Realizable: {result['realizable']}")
    print(f"Classification: {result['classification']}")
    
    print("\n=== Realizable 4-cycle ===")
    rw = [1.0, -0.5, 0.5, -1.0]
    result = classify_impossible_figure(rw)
    print(f"Weights: {rw}")
    print(f"Monodromy: {result['monodromy']}")
    print(f"Realizable: {result['realizable']}")
    print(f"Heights: {result['height_function']}")
