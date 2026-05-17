#!/usr/bin/env python3
"""
Algorithms for Threshold Phase Transition in Finite Optimization

Implements:
1. Exact threshold computation via brute-force minimization
2. Binary search for threshold approximation
3. Multi-predicate threshold lattice computation
"""

from typing import List, Callable, Tuple, Optional
import numpy as np


def compute_exact_threshold(
    cost: np.ndarray,
    marked: List[bool],
) -> Tuple[float, int, int]:
    """
    Compute the exact threshold Δ = markedMin - globalMin.
    
    Args:
        cost: Array of costs for each option.
        marked: Boolean list indicating which options are marked.
    
    Returns:
        (delta, global_min_idx, marked_min_idx): The threshold value
        and the indices of the global and marked minimizers.
    
    Time complexity: O(n)
    Space complexity: O(1)
    """
    n = len(cost)
    assert n > 0, "Need at least one option"
    assert any(marked), "Need at least one marked option"
    assert any(not m for m in marked), "Need at least one unmarked option"
    
    global_min_idx = int(np.argmin(cost))
    marked_min_idx = min(
        (i for i in range(n) if marked[i]),
        key=lambda i: cost[i]
    )
    delta = cost[marked_min_idx] - cost[global_min_idx]
    return delta, global_min_idx, marked_min_idx


def bonus_objective(
    cost: np.ndarray,
    marked: List[bool],
    beta: float,
) -> np.ndarray:
    """
    Compute F_β(x) = cost(x) - β · 𝟙_{marked(x)} for all x.
    
    Time complexity: O(n)
    """
    bonus = np.array([beta if m else 0.0 for m in marked])
    return cost - bonus


def find_all_minimizers(
    cost: np.ndarray,
    marked: List[bool],
    beta: float,
    tol: float = 1e-12,
) -> List[int]:
    """
    Find all global minimizers of F_β.
    
    Time complexity: O(n)
    """
    values = bonus_objective(cost, marked, beta)
    min_val = np.min(values)
    return [i for i in range(len(cost)) if abs(values[i] - min_val) < tol]


def binary_search_threshold(
    cost: np.ndarray,
    marked: List[bool],
    lo: float = 0.0,
    hi: Optional[float] = None,
    max_iterations: int = 100,
    tolerance: float = 1e-12,
) -> Tuple[float, List[Tuple[float, float, str]]]:
    """
    Binary search for the threshold Δ.
    
    At each step, evaluate F_mid and check whether minimizers are marked.
    - If all minimizers are marked: threshold < mid, so hi ← mid
    - If all minimizers are unmarked: threshold > mid, so lo ← mid  
    - If mixed: we found the threshold exactly (up to floating point)
    
    Args:
        cost: Array of costs.
        marked: Boolean marking.
        lo: Initial lower bound.
        hi: Initial upper bound (default: max(cost) - min(cost)).
        max_iterations: Maximum number of bisection steps.
        tolerance: Stop when hi - lo < tolerance.
    
    Returns:
        (threshold_estimate, history): The estimated threshold and
        a list of (lo, hi, decision) at each step.
    
    Time complexity: O(n · max_iterations)
    Space complexity: O(n + max_iterations)
    
    Convergence: The bracket width halves each iteration, so after k steps
    the error is at most (hi₀ - lo₀) / 2^k. With default tolerance 1e-12
    and typical initial bracket ~10, this converges in ~40 iterations.
    """
    if hi is None:
        hi = float(np.max(cost) - np.min(cost) + 1)
    
    history = []
    
    for _ in range(max_iterations):
        if hi - lo < tolerance:
            break
        
        mid = (lo + hi) / 2
        minimizers = find_all_minimizers(cost, marked, mid)
        
        all_marked = all(marked[i] for i in minimizers)
        any_marked = any(marked[i] for i in minimizers)
        
        if all_marked:
            decision = "marked → hi ← mid"
            hi = mid
        elif not any_marked:
            decision = "unmarked → lo ← mid"
            lo = mid
        else:
            decision = "TIE → found threshold"
            lo = hi = mid
            history.append((lo, hi, decision))
            break
        
        history.append((lo, hi, decision))
    
    return (lo + hi) / 2, history


def tropical_value_function(
    global_min: float,
    marked_min: float,
    beta: float,
) -> float:
    """
    Compute V(β) = min(globalMin, markedMin - β).
    
    This is the tropical normal form of the perturbed value function.
    It is piecewise linear with a single breakpoint at Δ = markedMin - globalMin.
    
    Time complexity: O(1)
    """
    return min(global_min, marked_min - beta)


def classify_phase(
    cost: np.ndarray,
    marked: List[bool],
    beta: float,
) -> str:
    """
    Classify which phase the system is in at parameter β.
    
    Returns:
        'unmarked': all minimizers are unmarked (β < Δ)
        'marked': all minimizers are marked (β > Δ)
        'critical': both types coexist (β = Δ)
    
    Time complexity: O(n)
    """
    minimizers = find_all_minimizers(cost, marked, beta)
    has_marked = any(marked[i] for i in minimizers)
    has_unmarked = any(not marked[i] for i in minimizers)
    
    if has_marked and has_unmarked:
        return "critical"
    elif has_marked:
        return "marked"
    else:
        return "unmarked"


def multi_predicate_thresholds(
    cost: np.ndarray,
    predicates: List[List[bool]],
) -> List[float]:
    """
    Compute independent thresholds for multiple predicates.
    
    For k predicates, each gets its own threshold Δ_i = min_{p_i(x)} cost(x) - min cost(x).
    
    Args:
        cost: Array of costs.
        predicates: List of k boolean markings.
    
    Returns:
        List of k thresholds.
    
    Time complexity: O(n · k)
    """
    global_min = float(np.min(cost))
    thresholds = []
    for pred in predicates:
        marked_costs = [cost[i] for i in range(len(cost)) if pred[i]]
        if marked_costs:
            thresholds.append(min(marked_costs) - global_min)
        else:
            thresholds.append(float('inf'))
    return thresholds


# Example usage and verification
if __name__ == "__main__":
    # Verify against exact computation
    np.random.seed(42)
    cost = np.random.uniform(0, 10, 50)
    marked = [np.random.random() < 0.3 for _ in range(50)]
    marked[0] = False  # ensure unmarked exists
    marked[1] = True   # ensure marked exists
    
    # Exact threshold
    delta_exact, g_idx, m_idx = compute_exact_threshold(cost, marked)
    print(f"Exact threshold: Δ = {delta_exact:.10f}")
    print(f"  Global min at index {g_idx}, cost = {cost[g_idx]:.6f}")
    print(f"  Marked min at index {m_idx}, cost = {cost[m_idx]:.6f}")
    
    # Binary search
    delta_search, history = binary_search_threshold(cost, marked)
    print(f"\nBinary search: Δ ≈ {delta_search:.10f}")
    print(f"  Steps: {len(history)}")
    print(f"  Error: {abs(delta_search - delta_exact):.2e}")
    
    # Phase classification
    print("\nPhase classification:")
    for beta in [0, delta_exact/2, delta_exact, delta_exact*1.5, delta_exact*2]:
        phase = classify_phase(cost, marked, beta)
        print(f"  β = {beta:.4f}: {phase}")
    
    # Multi-predicate
    pred2 = [np.random.random() < 0.5 for _ in range(50)]
    pred2[0] = False; pred2[2] = True
    thresholds = multi_predicate_thresholds(cost, [marked, pred2])
    print(f"\nMulti-predicate thresholds: {[f'{t:.4f}' for t in thresholds]}")
