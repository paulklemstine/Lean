"""
Tropical Proof Thermodynamics — Core Algorithms

Implementations of the main algorithms from the proof thermodynamics framework.
All functions are type-hinted and self-contained.
"""

from typing import List, Tuple, Optional
import math


def step_erasure(h: List[float], i: int) -> float:
    """Compute the erasure at step i: max(0, h[i] - h[i+1]).

    Args:
        h: Entropy sequence of length n+1.
        i: Step index (0 ≤ i < n).

    Returns:
        Non-negative erasure at step i.
    """
    return max(0.0, h[i] - h[i + 1])


def thermodynamic_depth(h: List[float]) -> float:
    """Compute the thermodynamic depth of an entropy trace.

    The total erasure cost: sum of max(0, h[i] - h[i+1]) for all steps.

    Args:
        h: Entropy sequence of length n+1 (n steps).

    Returns:
        Total thermodynamic depth D(T) ≥ 0.
    """
    n = len(h) - 1
    return sum(step_erasure(h, i) for i in range(n))


def boundary_difference(h: List[float]) -> float:
    """Compute the boundary entropy difference h[0] - h[n].

    For monotone traces, this equals the thermodynamic depth (Telescoping Theorem).

    Args:
        h: Entropy sequence.

    Returns:
        h[0] - h[-1].
    """
    return h[0] - h[-1]


def tropical_distance(a: float, b: float) -> float:
    """Compute the tropical distance |a - b|.

    In the min-plus semiring, this measures the transformation cost
    between two entropy levels.

    Args:
        a, b: Entropy values.

    Returns:
        |a - b|.
    """
    return abs(a - b)


def is_monotone(h: List[float]) -> bool:
    """Check if an entropy trace is monotone (non-increasing).

    Args:
        h: Entropy sequence.

    Returns:
        True if h[i+1] ≤ h[i] for all i.
    """
    return all(h[i + 1] <= h[i] for i in range(len(h) - 1))


def find_bottleneck(h: List[float]) -> Tuple[int, float]:
    """Find the thermodynamic bottleneck: the step with maximum erasure.

    By the Erasure Concentration Inequality, this step has erasure ≥ D(T)/n.

    Args:
        h: Entropy sequence of length n+1.

    Returns:
        Tuple of (bottleneck index, erasure value).
    """
    n = len(h) - 1
    if n == 0:
        return (0, 0.0)
    erasures = [step_erasure(h, i) for i in range(n)]
    max_idx = max(range(n), key=lambda i: erasures[i])
    return (max_idx, erasures[max_idx])


def verify_telescoping(h: List[float], tol: float = 1e-10) -> Tuple[bool, float, float]:
    """Verify the Telescoping Theorem for a monotone trace.

    Args:
        h: Entropy sequence (should be monotone).
        tol: Numerical tolerance.

    Returns:
        Tuple of (theorem_holds, depth, boundary_diff).
    """
    depth = thermodynamic_depth(h)
    bd = boundary_difference(h)
    holds = abs(depth - bd) < tol and is_monotone(h)
    return (holds, depth, bd)


def uniform_erasure_trace(n: int, delta: float) -> List[float]:
    """Construct a uniform erasure trace: h[i] = (n - i) * delta.

    Each step erases exactly delta units. Total depth = n * delta.

    Args:
        n: Number of steps.
        delta: Erasure per step (≥ 0).

    Returns:
        Entropy sequence of length n+1.
    """
    return [(n - i) * delta for i in range(n + 1)]


def compose_morphisms(
    s1: float, t1: float, c1: float,
    s2: float, t2: float, c2: float
) -> Tuple[float, float, float]:
    """Compose two proof entropy morphisms.

    Each morphism is (source, target, cost) with target ≤ source and cost ≥ source - target.
    Composition requires t1 = s2.

    Returns:
        (source, target, cost) of composed morphism.
    """
    assert abs(t1 - s2) < 1e-10, f"Morphisms not composable: t1={t1} ≠ s2={s2}"
    return (s1, t2, c1 + c2)


def erasure_vector(h: List[float]) -> List[float]:
    """Compute the erasure vector of a proof trace.

    Args:
        h: Entropy sequence.

    Returns:
        List of erasure values [e_0, e_1, ..., e_{n-1}].
    """
    n = len(h) - 1
    return [step_erasure(h, i) for i in range(n)]


def tropical_norm(h: List[float]) -> float:
    """Compute the tropical norm (sup-norm) of the erasure vector.

    Args:
        h: Entropy sequence.

    Returns:
        max_i e_i.
    """
    ev = erasure_vector(h)
    return max(ev) if ev else 0.0


def proof_certificate_check(
    h: List[float],
    circuit_complexity: int
) -> Tuple[bool, str]:
    """Check whether a proof trace satisfies the depth lower bound.

    Verifies: for monotone traces with h[-1] = 0,
    depth ≥ log(circuit_complexity).

    Args:
        h: Entropy sequence.
        circuit_complexity: Circuit complexity C ≥ 2.

    Returns:
        Tuple of (bound_satisfied, explanation).
    """
    if not is_monotone(h):
        return (False, "Trace is not monotone")
    if circuit_complexity < 2:
        return (False, "Circuit complexity must be ≥ 2")

    depth = thermodynamic_depth(h)
    threshold = math.log(circuit_complexity)

    if h[-1] > 1e-10:
        return (False, f"Terminal entropy {h[-1]} is not zero")

    satisfied = depth >= threshold - 1e-10
    explanation = (
        f"Depth = {depth:.6f}, log(C) = {threshold:.6f}, "
        f"{'SATISFIED' if satisfied else 'VIOLATED'}"
    )
    return (satisfied, explanation)
