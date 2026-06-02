"""
Algorithms for computing and analyzing the fractal dimension of proof search.

This module implements the core mathematical machinery from the research:
- Search dimension computation
- Box-counting dimension estimation
- Monte Carlo dimension estimation for proof search trees
- Proof complexity landscape analysis
"""

import math
from typing import List, Tuple, Optional


def search_dimension(b: int, k: int) -> float:
    """Compute the search dimension D = log(k) / log(b).
    
    Args:
        b: Branching factor (number of applicable tactics), must be >= 2
        k: Surviving branches per node (leading to proofs), must be >= 1
    
    Returns:
        The search dimension D in [0, 1]
    
    Raises:
        ValueError: If b < 2 or k < 1 or k > b
    
    Examples:
        >>> search_dimension(10, 10)  # trivial theorem
        1.0
        >>> search_dimension(10, 1)   # deterministic proof
        0.0
        >>> round(search_dimension(10, 3), 4)  # intermediate
        0.4771
    """
    if b < 2:
        raise ValueError(f"Branching factor must be >= 2, got {b}")
    if k < 1:
        raise ValueError(f"Survival count must be >= 1, got {k}")
    if k > b:
        raise ValueError(f"Survival count ({k}) cannot exceed branching factor ({b})")
    
    return math.log(k) / math.log(b)


def difficulty_ratio(b: int, k: int, d: int) -> float:
    """Compute the difficulty ratio b^d / k^d = (b/k)^d.
    
    This is the expected number of random paths to try before finding
    a successful proof.
    
    Args:
        b: Branching factor
        k: Surviving branches
        d: Search depth (proof length)
    
    Returns:
        The difficulty ratio (b/k)^d
    """
    if k == b:
        return 1.0
    return (b / k) ** d


def information_rate(b: int, k: int) -> float:
    """Compute the information rate per proof step: log(b) * (1 - D).
    
    This is the number of bits of genuine information each proof step
    encodes. Higher means the proof is more "surprising" at each step.
    
    Args:
        b: Branching factor
        k: Surviving branches
    
    Returns:
        Information rate in bits per step
    """
    D = search_dimension(b, k)
    return math.log2(b) * (1 - D)


def proof_complexity_landscape(b: int, k: int, d: int) -> float:
    """Compute the proof complexity landscape value: d * (1 - D).
    
    This is the total information content of the proof in units of log(b).
    
    Args:
        b: Branching factor
        k: Surviving branches
        d: Search depth
    
    Returns:
        Landscape value d * (1 - D)
    """
    D = search_dimension(b, k)
    return d * (1 - D)


def composed_search_dimension(
    b1: int, k1: int, d1: int,
    b2: int, k2: int, d2: int
) -> float:
    """Compute the effective dimension of a composed search.
    
    When proving T₁ then T₂, the total successful paths are
    k₁^d₁ * k₂^d₂ out of b₁^d₁ * b₂^d₂ total paths.
    The composed dimension is the weighted average of individual dimensions.
    
    Args:
        b1, k1, d1: Parameters of first search
        b2, k2, d2: Parameters of second search
    
    Returns:
        Effective dimension of the composed search
    """
    log_successful = d1 * math.log(k1) + d2 * math.log(k2)
    log_total = d1 * math.log(b1) + d2 * math.log(b2)
    
    if log_total == 0:
        return 1.0
    
    return log_successful / log_total


def box_counting_dimension(
    successful_at_depth: List[int],
    total_at_depth: List[int]
) -> float:
    """Estimate box-counting dimension from depth-wise counts.
    
    Uses linear regression of log(successful) vs log(total) across
    multiple depth levels to estimate the fractal dimension.
    
    Args:
        successful_at_depth: Number of successful leaves at each depth
        total_at_depth: Total number of leaves at each depth
    
    Returns:
        Estimated box-counting dimension
    """
    if len(successful_at_depth) != len(total_at_depth):
        raise ValueError("Lists must have the same length")
    
    # Filter out zeros
    log_s = []
    log_t = []
    for s, t in zip(successful_at_depth, total_at_depth):
        if s > 0 and t > 0:
            log_s.append(math.log(s))
            log_t.append(math.log(t))
    
    if len(log_s) < 2:
        raise ValueError("Need at least 2 non-zero data points")
    
    # Linear regression: log(s) = D * log(t) + c
    n = len(log_s)
    sum_x = sum(log_t)
    sum_y = sum(log_s)
    sum_xy = sum(x * y for x, y in zip(log_t, log_s))
    sum_x2 = sum(x * x for x in log_t)
    
    denom = n * sum_x2 - sum_x * sum_x
    if abs(denom) < 1e-15:
        return 1.0
    
    D = (n * sum_xy - sum_x * sum_y) / denom
    return max(0.0, min(1.0, D))


def monte_carlo_dimension(
    branching_factors: List[int],
    success_counts: List[int]
) -> float:
    """Estimate search dimension via Monte Carlo sampling.
    
    Given a sequence of (branching_factor, success_count) pairs
    observed during a proof search, estimates the average dimension.
    
    Args:
        branching_factors: b_i at each proof step
        success_counts: k_i at each proof step
    
    Returns:
        Estimated search dimension (average of log(k_i)/log(b_i))
    """
    if len(branching_factors) != len(success_counts):
        raise ValueError("Lists must have the same length")
    
    dims = []
    for b, k in zip(branching_factors, success_counts):
        if b >= 2 and k >= 1:
            dims.append(math.log(k) / math.log(b))
    
    if not dims:
        raise ValueError("No valid data points")
    
    return sum(dims) / len(dims)


def universality_test(
    statement_lengths: List[int],
    estimated_dimensions: List[float]
) -> Tuple[float, float, float]:
    """Test the universality conjecture D(T) = 1 - c/n.
    
    Fits the model D = 1 - c/n to empirical data and returns
    the estimated constant c, R² goodness of fit, and residual std.
    
    Args:
        statement_lengths: n values (statement lengths)
        estimated_dimensions: D values (estimated dimensions)
    
    Returns:
        Tuple of (c_estimate, r_squared, residual_std)
    """
    if len(statement_lengths) != len(estimated_dimensions):
        raise ValueError("Lists must have the same length")
    
    # Fit (1 - D) = c / n, i.e., (1 - D) * n = c
    products = [(1 - d) * n for n, d in zip(statement_lengths, estimated_dimensions)
                if n > 0]
    
    if not products:
        raise ValueError("No valid data points")
    
    c_estimate = sum(products) / len(products)
    
    # Compute R²
    mean_d = sum(estimated_dimensions) / len(estimated_dimensions)
    ss_tot = sum((d - mean_d) ** 2 for d in estimated_dimensions)
    ss_res = sum((d - (1 - c_estimate / n)) ** 2 
                 for n, d in zip(statement_lengths, estimated_dimensions) if n > 0)
    
    r_squared = 1 - ss_res / ss_tot if ss_tot > 0 else 0.0
    residual_std = math.sqrt(ss_res / len(products)) if products else 0.0
    
    return c_estimate, r_squared, residual_std


def phase_diagram(b: int) -> List[Tuple[int, float, str]]:
    """Generate the phase diagram for a given branching factor.
    
    Args:
        b: Branching factor
    
    Returns:
        List of (k, dimension, phase_label) tuples
    """
    results = []
    for k in range(1, b + 1):
        D = search_dimension(b, k)
        if k == 1:
            phase = "deterministic"
        elif k == b:
            phase = "trivial"
        elif D < 0.3:
            phase = "hard"
        elif D < 0.7:
            phase = "moderate"
        else:
            phase = "easy"
        results.append((k, D, phase))
    return results
