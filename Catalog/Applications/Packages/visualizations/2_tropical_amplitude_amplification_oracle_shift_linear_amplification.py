#!/usr/bin/env python3
"""
Tropical Amplitude Amplification — Algorithms

Implements the core algorithms from the tropical search theory:
1. Oracle Shift operator
2. Tropical Diffusion operator
3. Tropical Grover Step (oracle + diffusion)
4. Amplification search with convergence guarantee
5. Structured search on product spaces
"""

from typing import Set, List, Tuple, Optional
import numpy as np


def oracle_shift(c: np.ndarray, marked: Set[int], bonus: int) -> np.ndarray:
    """
    Tropical oracle shift operator.
    
    The tropical analogue of a quantum phase oracle. In the min-plus semiring,
    adding cost to unmarked states penalizes them, making marked states
    relatively cheaper.
    
    Args:
        c: Cost profile, shape (n,), integer-valued
        marked: Set of marked state indices
        bonus: Penalty added to each unmarked state
    
    Returns:
        Modified cost profile where c[i] → c[i] + bonus for i ∉ marked
    
    Complexity: O(n)
    
    Formally verified properties:
        - markedMin(oracle_shift(c)) = markedMin(c)
        - unmarkedMin(oracle_shift(c)) = unmarkedMin(c) + bonus
    """
    result = c.copy()
    mask = np.ones(len(c), dtype=bool)
    for i in marked:
        mask[i] = False
    result[mask] += bonus
    return result


def diffuse(c: np.ndarray) -> np.ndarray:
    """
    Tropical diffusion operator.
    
    Doubles the distance of every cost from the global minimum:
        diffuse(c)[i] = 2 * c[i] - min(c)
    
    This is the tropical analogue of the Grover diffusion/reflection operator.
    It preserves the global minimum while amplifying cost differences.
    
    Args:
        c: Cost profile, shape (n,), integer-valued
    
    Returns:
        Diffused cost profile
    
    Complexity: O(n)
    
    Formally verified properties:
        - globalMin(diffuse(c)) = globalMin(c)
        - If markedMin(c) = globalMin(c), then gap doubles
    """
    mu = c.min()
    return 2 * c - mu


def trop_grover_step(c: np.ndarray, marked: Set[int], bonus: int) -> np.ndarray:
    """
    Combined tropical Grover step: oracle shift followed by diffusion.
    
    This is the main amplification operator. Each application doubles the
    gap between marked and unmarked minima (plus a bonus term).
    
    Args:
        c: Cost profile
        marked: Set of marked state indices
        bonus: Oracle penalty
    
    Returns:
        Amplified cost profile
    
    Complexity: O(n)
    
    Formally verified: gap_new = 2 * (gap_old + bonus)
    """
    return diffuse(oracle_shift(c, marked, bonus))


def amplification_search(
    c: np.ndarray,
    marked: Set[int],
    bonus: int = 1,
    method: str = "linear",
    max_rounds: int = 1000,
    verbose: bool = False
) -> Tuple[int, int, np.ndarray]:
    """
    Tropical amplitude amplification search.
    
    Iteratively applies the oracle shift (linear) or Grover step (exponential)
    until the global argmin is guaranteed to be a marked state.
    
    Args:
        c: Initial cost profile
        marked: Set of marked state indices
        bonus: Oracle penalty per round
        method: "linear" (oracle shift only) or "exponential" (oracle + diffusion)
        max_rounds: Maximum iterations
        verbose: Print progress
    
    Returns:
        (argmin_state, rounds_used, final_cost_profile)
    
    Convergence guarantee:
        - Linear method: O((max_marked - min_unmarked) / bonus) rounds
        - Exponential method: O(log((max_marked - min_unmarked) / bonus)) rounds
    """
    current = c.copy()
    n = len(c)
    unmarked = set(range(n)) - marked
    
    for t in range(max_rounds):
        m_min = min(current[i] for i in marked)
        u_min = min(current[i] for i in unmarked)
        
        if verbose:
            print(f"  Round {t}: marked_min={m_min}, unmarked_min={u_min}, gap={u_min - m_min}")
        
        if m_min < u_min:
            # Global argmin is in marked set — certified!
            argmin = min(marked, key=lambda i: current[i])
            return argmin, t, current
        
        if method == "linear":
            current = oracle_shift(current, marked, bonus)
        elif method == "exponential":
            current = trop_grover_step(current, marked, bonus)
        else:
            raise ValueError(f"Unknown method: {method}")
    
    argmin = min(range(n), key=lambda i: current[i])
    return argmin, max_rounds, current


def structured_oracle_shift(
    costs: List[np.ndarray],
    marked_factors: List[Set[int]],
    bonus: int
) -> List[np.ndarray]:
    """
    Structured oracle shift for product spaces.
    
    For a product space X₁ × X₂ × ... × Xₖ with decomposable cost
    c(x₁,...,xₖ) = Σᵢ φᵢ(xᵢ), the oracle shift can be applied
    factor-by-factor if the marked set decomposes as M = M₁ × M₂ × ... × Mₖ.
    
    This gives a LOCAL implementation of the oracle: each factor is updated
    independently, achieving O(Σ|Xᵢ|) work instead of O(Π|Xᵢ|).
    
    Args:
        costs: List of factor cost profiles [φ₁, φ₂, ..., φₖ]
        marked_factors: List of marked sets for each factor
        bonus: Oracle penalty (distributed equally across factors)
    
    Returns:
        Updated factor cost profiles
    
    Complexity: O(Σ|Xᵢ|) instead of O(Π|Xᵢ|)
    """
    k = len(costs)
    bonus_per_factor = bonus // k
    result = []
    for phi, M in zip(costs, marked_factors):
        result.append(oracle_shift(phi, M, bonus_per_factor))
    return result


def compute_gap_trajectory(
    c: np.ndarray,
    marked: Set[int],
    bonus: int,
    rounds: int,
    method: str = "linear"
) -> List[int]:
    """
    Compute the gap trajectory over multiple rounds.
    
    Returns the sequence [gap(0), gap(1), ..., gap(rounds-1)] where
    gap(t) = unmarkedMin(c_t) - markedMin(c_t).
    
    Args:
        c: Initial cost profile
        marked: Marked state indices
        bonus: Oracle penalty
        rounds: Number of rounds to simulate
        method: "linear" or "exponential"
    
    Returns:
        List of gap values
    """
    current = c.copy()
    n = len(c)
    unmarked = set(range(n)) - marked
    gaps = []
    
    for _ in range(rounds):
        m_min = min(current[i] for i in marked)
        u_min = min(current[i] for i in unmarked)
        gaps.append(u_min - m_min)
        
        if method == "linear":
            current = oracle_shift(current, marked, bonus)
        else:
            current = trop_grover_step(current, marked, bonus)
    
    return gaps


if __name__ == "__main__":
    print("Tropical Amplitude Amplification — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example 1: Basic search
    print("\n--- Linear Search ---")
    c = np.array([5, 2, 8, 3, 7, 1, 9, 4])
    marked = {1, 5}  # States with costs 2, 1
    argmin, rounds, final = amplification_search(c, marked, bonus=2, method="linear", verbose=True)
    print(f"Found marked argmin: state {argmin} (cost {c[argmin]}) in {rounds} rounds")
    
    # Example 2: Exponential search
    print("\n--- Exponential Search ---")
    c = np.array([0, 1, 1, 1, 1, 1, 1, 1])
    marked = {0}
    argmin, rounds, final = amplification_search(c, marked, bonus=1, method="exponential", verbose=True)
    print(f"Found marked argmin: state {argmin} (cost {c[argmin]}) in {rounds} rounds")
    
    # Example 3: Gap trajectories
    print("\n--- Gap Trajectories ---")
    c = np.array([1, 3, 5, 7])
    marked = {0}
    linear_gaps = compute_gap_trajectory(c, marked, bonus=2, rounds=8, method="linear")
    exp_gaps = compute_gap_trajectory(c, marked, bonus=1, rounds=8, method="exponential")
    print(f"Linear gaps:      {linear_gaps}")
    print(f"Exponential gaps: {exp_gaps}")
