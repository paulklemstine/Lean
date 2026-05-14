#!/usr/bin/env python3
"""
Algorithms for Tropical Fixed-Point Computation

Implements the core algorithms from the tropical incompleteness framework:
1. Knaster-Tarski least fixed point via bottom-up iteration
2. Bellman-Ford style tropical fixed point
3. Diagonal fixed-point construction for closure operators
4. Soundness-completeness checker

All algorithms work over the tropical semiring (ℕ ∪ {∞}, min, +).
"""

import numpy as np
from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass


@dataclass
class FixedPointResult:
    """Result of a fixed-point computation."""
    point: np.ndarray
    iterations: int
    converged: bool
    trajectory: List[np.ndarray]


def knaster_tarski_lfp(
    T: Callable[[np.ndarray], np.ndarray],
    n: int,
    bound: np.ndarray,
    bottom: Optional[np.ndarray] = None
) -> FixedPointResult:
    """
    Compute the least fixed point of a monotone operator T on ℕ^n
    by iterating from the bottom element.

    Algorithm:
        x₀ = bottom (default: 0)
        x_{k+1} = T(x_k)
        Stop when x_{k+1} = x_k

    Complexity:
        Time: O(sum(bound) * cost(T)) — at most sum(bound) iterations
        Space: O(n) for the current iterate

    Args:
        T: Monotone operator on ℕ^n
        n: Dimension
        bound: Coordinatewise upper bound (ensures termination)
        bottom: Starting point (default: zeros)

    Returns:
        FixedPointResult with the least fixed point
    """
    if bottom is None:
        bottom = np.zeros(n, dtype=int)

    x = bottom.copy()
    trajectory = [x.copy()]
    max_iter = int(np.sum(bound)) + 1

    for i in range(max_iter):
        x_next = T(x)
        trajectory.append(x_next.copy())
        if np.array_equal(x_next, x):
            return FixedPointResult(
                point=x,
                iterations=i + 1,
                converged=True,
                trajectory=trajectory
            )
        x = x_next

    return FixedPointResult(
        point=x,
        iterations=max_iter,
        converged=False,
        trajectory=trajectory
    )


def knaster_tarski_gfp(
    T: Callable[[np.ndarray], np.ndarray],
    n: int,
    bound: np.ndarray
) -> FixedPointResult:
    """
    Compute the greatest fixed point of a monotone operator T on ℕ^n
    by iterating from the top element.

    Algorithm:
        x₀ = bound (top element)
        x_{k+1} = T(x_k)
        Stop when x_{k+1} = x_k

    Complexity:
        Time: O(sum(bound) * cost(T))
        Space: O(n)

    Args:
        T: Monotone operator on ℕ^n (must map [0, bound] to [0, bound])
        n: Dimension
        bound: Coordinatewise upper bound (top element)

    Returns:
        FixedPointResult with the greatest fixed point
    """
    return knaster_tarski_lfp(T, n, bound, bottom=bound.copy())


def bellman_tropical_fixpoint(
    M: np.ndarray,
    bound: int = 1000
) -> FixedPointResult:
    """
    Compute the fixed point of the tropical Bellman operator
    T(x)[i] = min_j(M[i,j] + x[j]), capped at `bound`.

    This finds shortest-path distances in the weighted graph
    defined by M, which are tropical Gödel sentences: stable
    cost valuations invariant under their own proof transformation.

    Algorithm:
        Standard Bellman-Ford iteration, capped for convergence in ℕ.

    Complexity:
        Time: O(n² * bound) worst case
        Space: O(n)

    Args:
        M: n×n tropical weight matrix (use large values for ∞)
        bound: Cap value to ensure termination

    Returns:
        FixedPointResult with the fixed point
    """
    n = M.shape[0]
    cap = np.full(n, bound)

    def bellman_op(x: np.ndarray) -> np.ndarray:
        result = np.full(n, bound)
        for i in range(n):
            for j in range(n):
                if M[i, j] < bound:
                    result[i] = min(result[i], M[i, j] + x[j])
        return np.minimum(result, cap)

    return knaster_tarski_lfp(bellman_op, n, cap)


def diagonal_fixed_point(
    C: Callable[[np.ndarray], np.ndarray],
    D: Callable[[np.ndarray], np.ndarray],
    n: int,
    bound: np.ndarray
) -> FixedPointResult:
    """
    Compute the least fixed point of the composition F = C ∘ D,
    producing a tropical Gödel sentence.

    The fixed point g satisfies C(D(g)) = g, meaning g is stable
    under the combined action of the closure operator C and the
    diagonal transformer D.

    Algorithm:
        Apply Knaster-Tarski LFP to F = C ∘ D.

    Complexity:
        Time: O(sum(bound) * (cost(C) + cost(D)))
        Space: O(n)

    Args:
        C: Monotone closure operator
        D: Monotone diagonal transformer
        n: Dimension
        bound: Coordinatewise upper bound for the composition

    Returns:
        FixedPointResult with the diagonal fixed point
    """
    def F(x: np.ndarray) -> np.ndarray:
        return C(D(x))

    return knaster_tarski_lfp(F, n, bound)


def check_soundness_completeness(
    provable: set,
    valid: set,
    universe: set
) -> dict:
    """
    Check soundness and completeness of a proof system.

    Soundness: Provable ⊆ Valid
    Completeness: Valid ⊆ Provable

    Also identifies potential diagonal sentences:
    elements g where Valid(g) ↔ ¬Provable(g).

    Args:
        provable: Set of provable sentences
        valid: Set of valid/true sentences
        universe: Set of all sentences

    Returns:
        Dictionary with analysis results
    """
    is_sound = provable.issubset(valid)
    is_complete = valid.issubset(provable)

    # Find diagonal sentences: g where Valid(g) ↔ ¬Provable(g)
    diagonal_sentences = []
    for g in universe:
        valid_g = g in valid
        provable_g = g in provable
        # Valid(g) ↔ ¬Provable(g) means:
        # (Valid(g) → ¬Provable(g)) ∧ (¬Provable(g) → Valid(g))
        if valid_g == (not provable_g):
            diagonal_sentences.append(g)

    # Soundness failures
    unsound = provable - valid

    # Completeness failures
    incomplete = valid - provable

    return {
        "sound": is_sound,
        "complete": is_complete,
        "diagonal_sentences": diagonal_sentences,
        "unsound_sentences": unsound,
        "incomplete_sentences": incomplete,
        "obstruction": len(diagonal_sentences) > 0 and is_sound
    }


def tropical_closure_operator(
    bound: np.ndarray
) -> Callable[[np.ndarray], np.ndarray]:
    """
    Construct a tropical closure operator C(x) = min(x, bound).

    Properties (verified algebraically):
    - Monotone: x ≤ y → C(x) ≤ C(y)
    - Deflationary: C(x) ≤ x
    - Idempotent: C(C(x)) = C(x)

    Args:
        bound: The closure bound

    Returns:
        The closure operator function
    """
    def C(x: np.ndarray) -> np.ndarray:
        return np.minimum(x, bound)
    return C


def tropical_shift_operator(
    additive_cost: np.ndarray,
    cap: np.ndarray
) -> Callable[[np.ndarray], np.ndarray]:
    """
    Construct a tropical shift operator T(x) = min(x + a, b).

    This models a Bellman-style update: each coordinate incurs
    an additive cost, then is capped at a bound.

    Properties:
    - Monotone: x ≤ y → T(x) ≤ T(y)
    - Bounded: T(x) ≤ cap for all x

    Args:
        additive_cost: The additive cost vector a
        cap: The cap vector b

    Returns:
        The shift operator function
    """
    def T(x: np.ndarray) -> np.ndarray:
        return np.minimum(x + additive_cost, cap)
    return T


if __name__ == "__main__":
    print("Tropical Fixed-Point Algorithms — Examples")
    print("=" * 50)

    # Example 1: LFP of a tropical shift
    print("\n1. Least Fixed Point of tropShift([1,2,3], [5,6,7]):")
    a = np.array([1, 2, 3])
    b = np.array([5, 6, 7])
    T = tropical_shift_operator(a, b)
    result = knaster_tarski_lfp(T, 3, b)
    print(f"   Fixed point: {result.point}")
    print(f"   Iterations: {result.iterations}")
    print(f"   Converged: {result.converged}")

    # Example 2: Bellman fixed point
    print("\n2. Bellman Fixed Point (shortest paths):")
    INF = 999
    M = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [1, INF, 0, INF],
        [INF, INF, 4, 0]
    ])
    result = bellman_tropical_fixpoint(M, bound=20)
    print(f"   Fixed point: {result.point}")
    print(f"   Iterations: {result.iterations}")

    # Example 3: Diagonal fixed point
    print("\n3. Diagonal Fixed Point (C ∘ D):")
    cap = np.array([4, 4, 4, 4])
    C = tropical_closure_operator(cap)
    D = lambda x: x + 1
    result = diagonal_fixed_point(C, D, 4, cap)
    print(f"   Tropical Gödel sentence: {result.point}")
    print(f"   Verification: C(D(g)) = {C(D(result.point))}")

    # Example 4: Soundness-completeness check
    print("\n4. Soundness-Completeness Analysis:")
    universe = set(range(10))
    valid = {0, 2, 4, 6, 8}
    provable = {0, 2, 6, 8}  # Missing 4 — incomplete
    analysis = check_soundness_completeness(provable, valid, universe)
    print(f"   Sound: {analysis['sound']}")
    print(f"   Complete: {analysis['complete']}")
    print(f"   Diagonal sentences: {analysis['diagonal_sentences']}")
    print(f"   Incomplete sentences: {analysis['incomplete_sentences']}")
    print(f"   Obstruction (sound + diagonal): {analysis['obstruction']}")
