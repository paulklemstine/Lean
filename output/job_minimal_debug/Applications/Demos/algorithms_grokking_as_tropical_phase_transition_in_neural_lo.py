#!/usr/bin/env python3
"""
Algorithms for Tropical Phase Transition Detection in Neural Networks

Implements the core algorithms derived from the mathematical framework:
1. Tropical score computation (max-plus polynomial evaluation)
2. Tropical boundary gap computation
3. Corner-locus detection
4. Order parameter tracking along training trajectories
5. Phase transition detection (grokking onset)
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class TropParams:
    """
    Parameters for a tropical (max-plus) neural classifier.
    
    Attributes:
        W: Weight tensor of shape (k, m, n) — k classes, m pieces, n input dims
        b: Bias matrix of shape (k, m)
    """
    W: np.ndarray  # shape (k, m, n)
    b: np.ndarray  # shape (k, m)
    
    @property
    def n_classes(self) -> int:
        return self.W.shape[0]
    
    @property
    def n_pieces(self) -> int:
        return self.W.shape[1]
    
    @property
    def n_input(self) -> int:
        return self.W.shape[2]


def compute_class_score(params: TropParams, c: int, x: np.ndarray) -> float:
    """
    Compute the max-plus tropical class score for class c at input x.
    
    Algorithm:
        score_c(x) = max_{j=1..m} (b[c,j] + sum_i W[c,j,i] * x[i])
    
    Time complexity: O(m * n)
    Space complexity: O(m)
    
    Args:
        params: Tropical classifier parameters
        c: Class index (0-indexed)
        x: Input vector of shape (n,)
    
    Returns:
        The tropical score for class c at x
    """
    affine_values = params.b[c, :] + params.W[c, :, :] @ x
    return float(np.max(affine_values))


def compute_all_scores(params: TropParams, x: np.ndarray) -> np.ndarray:
    """
    Compute tropical scores for all classes at input x.
    
    Time complexity: O(k * m * n)
    
    Returns:
        Array of shape (k,) with scores for each class
    """
    k = params.n_classes
    return np.array([compute_class_score(params, c, x) for c in range(k)])


def compute_tropical_boundary_gap(params: TropParams, x: np.ndarray) -> float:
    """
    Compute the tropical boundary gap at input x.
    
    Definition:
        gap(x) = min_{c ≠ c'} |score_c(x) - score_{c'}(x)|
    
    This measures the minimum "distance" to the tropical decision boundary.
    Returns 0 iff x lies on the corner locus.
    
    Time complexity: O(k² * m * n)
    
    Args:
        params: Tropical classifier parameters
        x: Input vector
    
    Returns:
        The tropical boundary gap (always ≥ 0)
    """
    scores = compute_all_scores(params, x)
    k = len(scores)
    min_gap = float('inf')
    for c in range(k):
        for c_prime in range(k):
            if c != c_prime:
                min_gap = min(min_gap, abs(scores[c] - scores[c_prime]))
    return min_gap


def detect_corner_locus(params: TropParams, x: np.ndarray,
                         tol: float = 1e-10) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Detect whether x lies on the corner locus (decision boundary).
    
    Returns:
        (is_on_boundary, witness_pair) where witness_pair is (c, c') with
        equal scores, or None if not on boundary.
    
    Time complexity: O(k² * m * n)
    """
    scores = compute_all_scores(params, x)
    k = len(scores)
    for c in range(k):
        for c_prime in range(c + 1, k):
            if abs(scores[c] - scores[c_prime]) < tol:
                return True, (c, c_prime)
    return False, None


def compute_tropical_order_sum(params: TropParams, 
                                dataset: List[np.ndarray]) -> float:
    """
    Compute the tropical order sum (unnormalized order parameter).
    
    Definition:
        Φ(params, S) = Σ_{x ∈ S} gap(params, x)
    
    Time complexity: O(|S| * k² * m * n)
    """
    return sum(compute_tropical_boundary_gap(params, x) for x in dataset)


def detect_phase_transition(
    trajectory: List[TropParams],
    dataset: List[np.ndarray],
    window_size: int = 5
) -> Dict:
    """
    Detect grokking-as-phase-transition along a training trajectory.
    
    Algorithm:
    1. Compute the tropical order parameter at each step
    2. Detect the first step where any sample hits the corner locus
    3. Detect monotone decrease regions
    4. Report the phase transition point and statistics
    
    Time complexity: O(T * |S| * k² * m * n)
    
    Args:
        trajectory: List of TropParams at each training step
        dataset: Training dataset
        window_size: Size of smoothing window for transition detection
    
    Returns:
        Dictionary with:
        - 'order_parameters': list of Φ values
        - 'transition_step': step where phase transition occurs (or None)
        - 'corner_locus_events': list of (step, sample_idx, class_pair) tuples
        - 'is_phase_transition': whether a clear transition was detected
    """
    T = len(trajectory)
    order_params = []
    corner_events = []
    
    for t, params in enumerate(trajectory):
        # Compute order parameter
        op = compute_tropical_order_sum(params, dataset)
        order_params.append(op)
        
        # Check for corner-locus events
        for i, x in enumerate(dataset):
            is_on, pair = detect_corner_locus(params, x)
            if is_on:
                corner_events.append((t, i, pair))
    
    # Detect transition: first time order parameter drops significantly
    transition_step = None
    if len(order_params) > window_size:
        for t in range(window_size, T):
            before = np.mean(order_params[t - window_size:t])
            after = order_params[t]
            if before > 0 and after / before < 0.5:
                transition_step = t
                break
    
    return {
        'order_parameters': order_params,
        'transition_step': transition_step,
        'corner_locus_events': corner_events,
        'is_phase_transition': transition_step is not None,
        'first_corner_event': corner_events[0] if corner_events else None
    }


def find_discrete_sign_change(gap_values: np.ndarray) -> Optional[int]:
    """
    Find the first discrete sign change in a sequence of gap values.
    
    Implements the Discrete Sign-Change Theorem (Theorem C):
    If gap[0] < 0 and gap[-1] > 0, returns index i such that
    gap[i] ≤ 0 and gap[i+1] ≥ 0.
    
    Time complexity: O(T)
    
    Args:
        gap_values: Array of pairwise score differences along trajectory
    
    Returns:
        Index of the sign change, or None if no sign change found
    """
    for i in range(len(gap_values) - 1):
        if gap_values[i] <= 0 and gap_values[i + 1] >= 0:
            return i
    return None


def interpolate_params(P: TropParams, Q: TropParams, alpha: float) -> TropParams:
    """
    Linear interpolation between two parameter configurations.
    
    Creates a "discrete geodesic" in parameter space.
    
    Args:
        P, Q: Endpoint parameters
        alpha: Interpolation parameter in [0, 1]
    
    Returns:
        Interpolated TropParams at (1-α)P + αQ
    """
    return TropParams(
        W=(1 - alpha) * P.W + alpha * Q.W,
        b=(1 - alpha) * P.b + alpha * Q.b
    )


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Phase Transition Detection Algorithm")
    print("=" * 50)
    
    # Create a simple example
    rng = np.random.RandomState(42)
    n, k, m = 3, 3, 2
    
    # Start parameters (memorizing regime)
    P_start = TropParams(
        W=rng.randn(k, m, n),
        b=rng.randn(k, m) * 2
    )
    
    # End parameters (generalizing regime — engineered corner crossing)
    P_end = TropParams(
        W=P_start.W.copy(),
        b=P_start.b.copy()
    )
    
    dataset = [rng.randn(n) for _ in range(5)]
    
    # Engineer corner crossing at dataset[0]
    s0 = compute_class_score(P_end, 0, dataset[0])
    s1 = compute_class_score(P_end, 1, dataset[0])
    P_end.b[1, 0] += (s0 - s1)
    
    # Create trajectory
    T = 50
    trajectory = [interpolate_params(P_start, P_end, t / T) for t in range(T + 1)]
    
    # Run detection
    result = detect_phase_transition(trajectory, dataset)
    
    print(f"Phase transition detected: {result['is_phase_transition']}")
    if result['transition_step'] is not None:
        print(f"Transition step: {result['transition_step']}")
    if result['first_corner_event'] is not None:
        step, sample, pair = result['first_corner_event']
        print(f"First corner-locus event: step {step}, sample {sample}, classes {pair}")
    
    # Verify sign change theorem
    gap_01 = [compute_class_score(trajectory[t], 0, dataset[0]) - 
              compute_class_score(trajectory[t], 1, dataset[0]) 
              for t in range(T + 1)]
    gap_arr = np.array(gap_01)
    sign_change = find_discrete_sign_change(gap_arr)
    if sign_change is not None:
        print(f"\nDiscrete sign change (Theorem C): step {sign_change}")
        print(f"  gap[{sign_change}] = {gap_arr[sign_change]:.6f}")
        print(f"  gap[{sign_change+1}] = {gap_arr[sign_change+1]:.6f}")
