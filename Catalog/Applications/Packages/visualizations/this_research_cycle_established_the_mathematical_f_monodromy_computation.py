"""
Algorithms for Impossible Figures: Height Cocycles and Monodromy

Implements the core computational tools for analyzing impossible figures
through the lens of discrete cohomology on cycle graphs.
"""

from typing import List, Tuple, Optional
import math


def compute_monodromy(edge_weights: List[float]) -> float:
    """
    Compute the monodromy of a height cocycle on a cycle graph.
    
    The monodromy is the sum of all edge weights around the cycle.
    Returns 0 for realizable figures, nonzero for impossible ones.
    
    Args:
        edge_weights: List of height differences for each edge.
        
    Returns:
        The monodromy (total height discrepancy).
    """
    return sum(edge_weights)


def is_coboundary(edge_weights: List[float], tol: float = 1e-10) -> bool:
    """
    Check if a cocycle is a coboundary (realizable figure).
    
    By the Monodromy Classification Theorem, a cocycle is a coboundary
    if and only if the monodromy is zero.
    
    Args:
        edge_weights: Height differences for each edge.
        tol: Numerical tolerance for zero comparison.
        
    Returns:
        True if the figure is realizable.
    """
    return abs(compute_monodromy(edge_weights)) < tol


def reconstruct_heights(edge_weights: List[float]) -> Optional[List[float]]:
    """
    Reconstruct height function from a coboundary cocycle.
    
    If the monodromy is zero, constructs h(k) = sum of first k edge weights.
    Returns None if the cocycle is not a coboundary.
    
    Args:
        edge_weights: Height differences for each edge.
        
    Returns:
        List of vertex heights, or None if impossible.
    """
    if not is_coboundary(edge_weights):
        return None
    
    n = len(edge_weights)
    heights = [0.0] * n
    for k in range(1, n):
        heights[k] = heights[k-1] + edge_weights[k-1]
    return heights


def impossibility_index(edge_weights: List[float]) -> float:
    """
    Compute the impossibility index = |monodromy|.
    
    Measures "how impossible" a figure is.
    Zero means realizable, positive means impossible.
    
    Args:
        edge_weights: Height differences for each edge.
        
    Returns:
        The impossibility index (non-negative).
    """
    return abs(compute_monodromy(edge_weights))


def orientation_monodromy(orientations: List[int]) -> int:
    """
    Compute the orientation monodromy (product of ±1 values).
    
    +1 means orientable (cylinder-like), -1 means non-orientable (Möbius-like).
    
    Args:
        orientations: List of ±1 values for each edge.
        
    Returns:
        +1 or -1.
    """
    result = 1
    for o in orientations:
        assert o in (1, -1), f"Orientation must be ±1, got {o}"
        result *= o
    return result


def classify_cocycle(edge_weights: List[float]) -> dict:
    """
    Complete classification of a cycle cocycle.
    
    Returns a dictionary with monodromy, impossibility index,
    realizability status, and (if realizable) the height function.
    
    Args:
        edge_weights: Height differences for each edge.
        
    Returns:
        Classification dictionary.
    """
    m = compute_monodromy(edge_weights)
    idx = abs(m)
    realizable = is_coboundary(edge_weights)
    heights = reconstruct_heights(edge_weights) if realizable else None
    
    return {
        "num_edges": len(edge_weights),
        "edge_weights": edge_weights,
        "monodromy": m,
        "impossibility_index": idx,
        "is_realizable": realizable,
        "heights": heights,
        "cohomology_class": m,  # H¹(Cₙ; ℝ) ≅ ℝ via monodromy
    }


def perturbation_bound(edge_weights: List[float]) -> float:
    """
    Compute the perturbation stability radius.
    
    Any perturbation with monodromy smaller than this value
    preserves the impossibility/realizability status.
    
    Args:
        edge_weights: Height differences for each edge.
        
    Returns:
        Maximum tolerable perturbation monodromy.
    """
    return impossibility_index(edge_weights)


def decompose_cocycle(edge_weights: List[float]) -> Tuple[List[float], List[float]]:
    """
    Decompose a cocycle into coboundary + harmonic parts.
    
    For a cycle graph Cₙ, the harmonic representative of a cohomology
    class with monodromy m is the constant cocycle (m/n, m/n, ..., m/n).
    
    ω = δf + ω_harm where:
    - ω_harm = (m/n, ..., m/n) is the harmonic representative
    - δf = ω - ω_harm is the exact (coboundary) part
    
    This is the Hodge decomposition for cycle graphs.
    
    Args:
        edge_weights: Height differences for each edge.
        
    Returns:
        Tuple of (coboundary_part, harmonic_part).
    """
    n = len(edge_weights)
    m = compute_monodromy(edge_weights)
    harmonic = [m / n] * n
    coboundary = [edge_weights[i] - harmonic[i] for i in range(n)]
    return coboundary, harmonic
