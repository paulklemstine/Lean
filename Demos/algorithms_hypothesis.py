"""
Tropical Residuation Algorithms

Complete implementations of the core algorithms arising from the
tropical residuation theorems, with docstrings, type hints, and
complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_matmul(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical matrix-vector product (max-plus).

    Computes y_j = max_i (x_i + W_{i,j}) for each output index j.

    This is the forward pass of a single tropical (max-plus affine) layer.
    Equivalent to standard matrix-vector multiplication where addition
    is replaced by max and multiplication is replaced by addition.

    Args:
        W: Weight matrix of shape (m, n).
        x: Input vector of shape (m,).

    Returns:
        Output vector of shape (n,).

    Time complexity: O(m * n)
    Space complexity: O(n)
    """
    m, n = W.shape
    assert x.shape == (m,), f"Expected x of shape ({m},), got {x.shape}"
    # Broadcasting: x[:, None] + W gives (m, n), then max over axis 0
    return np.max(x[:, None] + W, axis=0)


def tropical_backward(W: np.ndarray, y: np.ndarray) -> np.ndarray:
    """
    Tropical residual (backward map).

    Computes x_i = min_j (y_j - W_{i,j}) for each input index i.

    This is the exact backward certificate computation: given an output
    threshold y, it returns the tightest input bound x such that
    tropical_matmul(W, x') <= y implies x' <= x componentwise.

    The residual satisfies the Galois connection:
        tropical_matmul(W, x) <= y  ⟺  x <= tropical_backward(W, y)

    Args:
        W: Weight matrix of shape (m, n).
        y: Output threshold vector of shape (n,).

    Returns:
        Input bound vector of shape (m,).

    Time complexity: O(m * n)
    Space complexity: O(m)
    """
    m, n = W.shape
    assert y.shape == (n,), f"Expected y of shape ({n},), got {y.shape}"
    # Broadcasting: y[None, :] - W gives (m, n), then min over axis 1
    return np.min(y[None, :] - W, axis=1)


def tropical_multilayer_forward(
    weights: List[np.ndarray], x: np.ndarray
) -> Tuple[np.ndarray, List[np.ndarray]]:
    """
    Forward pass through a multi-layer tropical network.

    Computes F_{W_L} ∘ ... ∘ F_{W_1}(x), returning both the final output
    and all intermediate activations (for debugging/visualization).

    Args:
        weights: List of weight matrices [W_1, W_2, ..., W_L].
        x: Input vector.

    Returns:
        Tuple of (final_output, [x, h_1, h_2, ..., h_L]).

    Time complexity: O(sum_l m_l * n_l)
    Space complexity: O(sum_l n_l) for storing intermediates
    """
    activations = [x.copy()]
    current = x
    for W in weights:
        current = tropical_matmul(W, current)
        activations.append(current.copy())
    return current, activations


def tropical_multilayer_backward(
    weights: List[np.ndarray], z: np.ndarray
) -> Tuple[np.ndarray, List[np.ndarray]]:
    """
    Backward residual pass through a multi-layer tropical network.

    Computes B_{W_1} ∘ B_{W_2} ∘ ... ∘ B_{W_L}(z), which is the
    exact compositional residual (tropical cut-elimination).

    The result satisfies:
        F_{W_L}(...(F_{W_1}(x))...) ≤ z  ⟺  x ≤ result

    Args:
        weights: List of weight matrices [W_1, W_2, ..., W_L].
        z: Output threshold vector.

    Returns:
        Tuple of (input_bound, list of intermediate backward bounds).

    Time complexity: O(sum_l m_l * n_l)
    Space complexity: O(sum_l m_l) for storing intermediates
    """
    bounds = [z.copy()]
    current = z
    for W in reversed(weights):
        current = tropical_backward(W, current)
        bounds.append(current.copy())
    bounds.reverse()
    return current, bounds


def verify_galois_connection(
    W: np.ndarray, x: np.ndarray, y: np.ndarray, tol: float = 1e-12
) -> dict:
    """
    Verify the Galois connection for a given W, x, y.

    Checks that tropical_matmul(W, x) <= y iff x <= tropical_backward(W, y).

    Args:
        W: Weight matrix.
        x: Input vector.
        y: Output threshold.
        tol: Numerical tolerance.

    Returns:
        Dictionary with verification results.
    """
    forward = tropical_matmul(W, x)
    backward = tropical_backward(W, y)

    forward_satisfied = np.all(forward <= y + tol)
    backward_satisfied = np.all(x <= backward + tol)

    return {
        "forward_value": forward,
        "backward_value": backward,
        "forward_satisfied": forward_satisfied,
        "backward_satisfied": backward_satisfied,
        "galois_consistent": forward_satisfied == backward_satisfied,
        "margin_forward": np.min(y - forward),
        "margin_backward": np.min(backward - x),
    }


def tropical_robustness_certificate(
    weights: List[np.ndarray],
    x: np.ndarray,
    output_threshold: np.ndarray,
) -> dict:
    """
    Compute a certified robustness certificate for a tropical network.

    Given a multi-layer tropical network and an output threshold,
    computes the exact backward input bound via compositional residuation.
    Any input perturbation within this bound is guaranteed to keep the
    output below the threshold.

    This is the practical application of tropical cut-elimination to
    neural network verification.

    Args:
        weights: List of weight matrices defining the network.
        x: Nominal input vector.
        output_threshold: Maximum allowed output values.

    Returns:
        Dictionary with certificate information including:
        - input_bound: the exact backward bound on inputs
        - is_certified: whether the nominal input satisfies the bound
        - robustness_margin: how much each input can be perturbed
    """
    # Forward pass
    output, fwd_activations = tropical_multilayer_forward(weights, x)

    # Backward residual pass
    input_bound, bwd_bounds = tropical_multilayer_backward(weights, output_threshold)

    # Check certification
    output_ok = np.all(output <= output_threshold)
    input_ok = np.all(x <= input_bound)

    # Robustness margin: how much can each x_i increase before violating?
    robustness_margin = input_bound - x

    return {
        "output": output,
        "output_threshold": output_threshold,
        "output_satisfied": output_ok,
        "input_bound": input_bound,
        "input_satisfied": input_ok,
        "galois_consistent": output_ok == input_ok,
        "robustness_margin": robustness_margin,
        "min_robustness": float(np.min(robustness_margin)),
        "forward_activations": fwd_activations,
        "backward_bounds": bwd_bounds,
    }


# ═══════════════════════════════════════════════════════════════════
# Scheduling / Dynamic Programming Application
# ═══════════════════════════════════════════════════════════════════

def earliest_completion_times(
    processing_times: np.ndarray,
    start_times: np.ndarray,
) -> np.ndarray:
    """
    Compute earliest completion times for a tropical scheduling problem.

    In the tropical (max-plus) interpretation:
    - processing_times[i, j] = time for task i to enable task j
    - start_times[i] = earliest start of task i
    - result[j] = earliest completion of task j = max_i(start_i + proc_{i,j})

    This is exactly tropical_matmul applied to scheduling.

    Args:
        processing_times: Matrix of processing/communication times.
        start_times: Vector of task start times.

    Returns:
        Vector of earliest completion times.
    """
    return tropical_matmul(processing_times, start_times)


def latest_admissible_starts(
    processing_times: np.ndarray,
    deadlines: np.ndarray,
) -> np.ndarray:
    """
    Compute latest admissible start times from deadlines.

    Uses the tropical residual to propagate deadline constraints backward:
    start_i ≤ min_j(deadline_j - proc_{i,j}).

    This is tropical_backward applied to scheduling. The residuation
    theorem guarantees this is exact: these are the tightest bounds.

    Args:
        processing_times: Matrix of processing/communication times.
        deadlines: Vector of task deadlines.

    Returns:
        Vector of latest admissible start times.
    """
    return tropical_backward(processing_times, deadlines)


if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Scheduling Example")
    print("=" * 60)

    # 3 tasks with processing/communication times
    P = np.array([
        [2.0, 5.0, 3.0],
        [4.0, 1.0, 6.0],
        [3.0, 2.0, 1.0],
    ])

    starts = np.array([0.0, 1.0, 2.0])
    deadlines = np.array([10.0, 8.0, 12.0])

    completions = earliest_completion_times(P, starts)
    latest_starts = latest_admissible_starts(P, deadlines)

    print(f"Processing times:\n{P}")
    print(f"Start times: {starts}")
    print(f"Earliest completions: {completions}")
    print(f"Deadlines: {deadlines}")
    print(f"Latest admissible starts: {latest_starts}")
    print(f"Starts feasible: {np.all(starts <= latest_starts)}")

    print("\n" + "=" * 60)
    print("Tropical Neural Network Certification Example")
    print("=" * 60)

    W1 = np.array([[1.0, 2.0, 0.0],
                    [3.0, 0.0, 1.0]])
    W2 = np.array([[0.0, 1.0],
                    [2.0, 0.0],
                    [1.0, 3.0]])

    x = np.array([1.0, 0.5])
    threshold = np.array([10.0, 9.0])

    cert = tropical_robustness_certificate([W1, W2], x, threshold)
    print(f"Input: {x}")
    print(f"Output: {cert['output']}")
    print(f"Threshold: {threshold}")
    print(f"Output OK: {cert['output_satisfied']}")
    print(f"Input bound: {cert['input_bound']}")
    print(f"Galois consistent: {cert['galois_consistent']}")
    print(f"Robustness margin: {cert['robustness_margin']}")
    print(f"Min robustness: {cert['min_robustness']:.4f}")
