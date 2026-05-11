"""
Algorithms for Oracle-Trace Cobham Invariance

Implements the core computational algorithms from the research paper:
1. LCVP depth computation (O(min(|x|,|y|)) time)
2. Trace ball enumeration (O(|Σ|^n) time for alphabet Σ, max length n)
3. Admissible simulation verification (O(|T|^2 * min_len) time)
4. Trace complexity profiling (O(|S| * n) time)
5. Cobham invariance ball containment check

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Set, Callable, Optional, Dict
import itertools
from dataclasses import dataclass


# ============================================================
# Algorithm 1: LCVP Depth (O(min(|x|,|y|)))
# ============================================================

def lcvp_depth(x: List[int], y: List[int]) -> int:
    """
    Compute the Longest Common Valued Prefix depth.

    Time complexity: O(min(|x|, |y|))
    Space complexity: O(1)

    Parameters
    ----------
    x : List[int]
        First oracle trace
    y : List[int]
        Second oracle trace

    Returns
    -------
    int
        Length of the longest common prefix

    Examples
    --------
    >>> lcvp_depth([1, 2, 3, 4], [1, 2, 5, 6])
    2
    >>> lcvp_depth([1, 2, 3], [1, 2, 3])
    3
    >>> lcvp_depth([], [1, 2])
    0
    """
    depth = 0
    for a, b in zip(x, y):
        if a != b:
            break
        depth += 1
    return depth


# ============================================================
# Algorithm 2: Trace Ball Enumeration
# ============================================================

def enumerate_trace_ball(center: List[int], radius: int,
                          alphabet: List[int], max_length: int) -> List[List[int]]:
    """
    Enumerate all traces in traceBall(center, radius) up to a given max length.

    Time complexity: O(|Σ|^max_length * min(max_length, |center|))
    Space complexity: O(|result|)

    A trace x is in traceBall(center, radius) iff the first `radius` symbols
    of x match the first `radius` symbols of center. Thus we can enumerate
    efficiently by fixing the prefix.

    Parameters
    ----------
    center : List[int]
        Center of the ball
    radius : int
        Minimum prefix agreement depth
    alphabet : List[int]
        Available symbols
    max_length : int
        Maximum trace length to enumerate

    Returns
    -------
    List[List[int]]
        All traces in the ball with length ≤ max_length
    """
    if radius > len(center) or radius > max_length:
        return []

    # The required prefix is center[:radius]
    required_prefix = center[:radius]
    result = []

    # If the trace length is less than radius, lcvpDepth can't reach radius
    # unless radius == 0
    if radius == 0:
        # All traces are in the ball
        for length in range(max_length + 1):
            for trace in itertools.product(alphabet, repeat=length):
                result.append(list(trace))
        return result

    # Traces must start with required_prefix and have length >= radius
    for extra_length in range(max_length - radius + 1):
        for suffix in itertools.product(alphabet, repeat=extra_length):
            result.append(required_prefix + list(suffix))

    return result


# ============================================================
# Algorithm 3: Admissible Simulation Verification
# ============================================================

@dataclass
class AdmissibleSimulationResult:
    """Result of admissibility verification."""
    is_admissible: bool
    max_depth_loss: int
    claimed_depth_loss: int
    worst_case_pair: Optional[Tuple[List[int], List[int]]]
    num_pairs_checked: int


def verify_admissibility(transducer_fn: Callable[[List[int]], List[int]],
                          claimed_depth_loss: int,
                          trace_set: List[List[int]]) -> AdmissibleSimulationResult:
    """
    Verify that a transducer function is admissible with the claimed depth loss.

    Checks: lcvp_depth(f(x), f(y)) + d >= lcvp_depth(x, y) for all pairs.

    Time complexity: O(|T|^2 * max_trace_length)
    Space complexity: O(1) beyond input

    Parameters
    ----------
    transducer_fn : Callable
        The transducer's trace mapping function
    claimed_depth_loss : int
        The claimed depth loss bound d
    trace_set : List[List[int]]
        Set of traces to check (should be representative)

    Returns
    -------
    AdmissibleSimulationResult
        Verification result with details
    """
    max_loss = 0
    worst_pair = None
    n_checked = 0

    for x in trace_set:
        for y in trace_set:
            n_checked += 1
            orig_depth = lcvp_depth(x, y)
            trans_depth = lcvp_depth(transducer_fn(x), transducer_fn(y))
            loss = orig_depth - trans_depth

            if loss > max_loss:
                max_loss = loss
                worst_pair = (x.copy(), y.copy())

    return AdmissibleSimulationResult(
        is_admissible=(max_loss <= claimed_depth_loss),
        max_depth_loss=max_loss,
        claimed_depth_loss=claimed_depth_loss,
        worst_case_pair=worst_pair,
        num_pairs_checked=n_checked
    )


# ============================================================
# Algorithm 4: Trace Complexity Profiling
# ============================================================

def trace_complexity_profile(trace_set: Set[Tuple[int, ...]],
                              max_n: int) -> List[int]:
    """
    Compute the trace complexity profile: traceComplexity(S, n) for n = 0..max_n.

    Time complexity: O(|S| * max_n)
    Space complexity: O(max_n)

    Parameters
    ----------
    trace_set : Set[Tuple[int, ...]]
        The set of traces
    max_n : int
        Maximum length parameter

    Returns
    -------
    List[int]
        Profile[n] = |{x ∈ S : |x| ≤ n}|
    """
    profile = [0] * (max_n + 1)
    for trace in trace_set:
        for n in range(len(trace), max_n + 1):
            profile[n] += 1
    return profile


def capacity_upper_profile(trace_set: Set[Tuple[int, ...]],
                            max_n: int) -> List[float]:
    """
    Compute the capacity upper profile: traceComplexity(S, n) / (n + 1).

    Time complexity: O(|S| * max_n)
    Space complexity: O(max_n)
    """
    tc = trace_complexity_profile(trace_set, max_n)
    return [tc[n] / (n + 1) for n in range(max_n + 1)]


# ============================================================
# Algorithm 5: Cobham Invariance Ball Containment Check
# ============================================================

def check_cobham_ball_containment(
    forward_fn: Callable[[List[int]], List[int]],
    backward_fn: Callable[[List[int]], List[int]],
    forward_depth_loss: int,
    backward_depth_loss: int,
    center: List[int],
    radius: int,
    alphabet: List[int],
    max_length: int
) -> Dict[str, bool]:
    """
    Check the Cobham invariance ball containment property.

    Verifies:
    1. forward(traceBall(c, r + d_fwd)) ⊆ traceBall(forward(c), r)
    2. backward(traceBall(forward(c), r + d_bwd)) ⊆ traceBall(backward(forward(c)), r)

    Time complexity: O(|Σ|^max_length * max_length)

    Parameters
    ----------
    forward_fn, backward_fn : Callable
        Forward and backward transducer functions
    forward_depth_loss, backward_depth_loss : int
        Depth loss bounds
    center : List[int]
        Center trace for the ball
    radius : int
        Ball radius
    alphabet : List[int]
        Trace alphabet
    max_length : int
        Max trace length for enumeration

    Returns
    -------
    Dict[str, bool]
        Results of forward and backward containment checks
    """
    # Forward check
    input_ball = enumerate_trace_ball(center, radius + forward_depth_loss,
                                       alphabet, max_length)
    fwd_center = forward_fn(center)
    output_ball_set = {tuple(t) for t in
                       enumerate_trace_ball(fwd_center, radius, alphabet, max_length + 10)}

    fwd_ok = all(tuple(forward_fn(t)) in output_ball_set for t in input_ball)

    # Backward check
    bwd_input_ball = enumerate_trace_ball(fwd_center, radius + backward_depth_loss,
                                           alphabet, max_length)
    bwd_center = backward_fn(fwd_center)
    bwd_output_ball_set = {tuple(t) for t in
                           enumerate_trace_ball(bwd_center, radius, alphabet, max_length + 10)}

    bwd_ok = all(tuple(backward_fn(t)) in bwd_output_ball_set for t in bwd_input_ball)

    return {
        "forward_containment": fwd_ok,
        "backward_containment": bwd_ok,
        "input_ball_size": len(input_ball),
        "output_ball_size": len(output_ball_set),
    }


# ============================================================
# Concrete Transducer Implementations
# ============================================================

def make_drop_prefix(k: int) -> Callable[[List[int]], List[int]]:
    """Create a drop-prefix transducer function."""
    return lambda x: x[k:]


def make_append_suffix(suffix: List[int]) -> Callable[[List[int]], List[int]]:
    """Create an append-suffix transducer function."""
    return lambda x: x + suffix


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Generate test traces
    alphabet = [0, 1]
    test_traces = []
    for length in range(5):
        for t in itertools.product(alphabet, repeat=length):
            test_traces.append(list(t))

    # Algorithm 3: Verify drop-prefix admissibility
    print("--- Drop-Prefix Admissibility ---")
    for k in [1, 2, 3]:
        result = verify_admissibility(make_drop_prefix(k), k, test_traces)
        print(f"  k={k}: admissible={result.is_admissible}, "
              f"max_loss={result.max_depth_loss}, "
              f"pairs_checked={result.num_pairs_checked}")

    # Algorithm 4: Complexity profiles
    print("\n--- Complexity Profiles ---")
    all_set = {tuple(t) for t in test_traces}
    profile = trace_complexity_profile(all_set, 5)
    cap_profile = capacity_upper_profile(all_set, 5)
    for n in range(6):
        print(f"  n={n}: complexity={profile[n]}, capacity={cap_profile[n]:.2f}")

    # Algorithm 5: Cobham ball containment
    print("\n--- Cobham Ball Containment ---")
    result = check_cobham_ball_containment(
        forward_fn=make_drop_prefix(1),
        backward_fn=make_append_suffix([0]),
        forward_depth_loss=1,
        backward_depth_loss=0,
        center=[0, 1, 0],
        radius=1,
        alphabet=[0, 1],
        max_length=4
    )
    print(f"  Forward containment: {result['forward_containment']}")
    print(f"  Backward containment: {result['backward_containment']}")


"""
Applications of Oracle-Trace Cobham Invariance

Real-world applications demonstrating the practical utility of the framework:
1. Neural sequence model robustness certification
2. Post-quantum complexity surrogate analysis
3. Thermodynamic entropy bounds for trace systems
"""

from typing import List, Callable, Tuple, Dict
import random
import math