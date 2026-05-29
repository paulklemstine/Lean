#!/usr/bin/env python3
"""
algorithms.py — Algorithms from the Category Theory of Jokes

Implements the core algorithms described in the research paper:
1. HumorCompute — O(d) humor value computation
2. UniversalJokeSearch — O(n·d) funniest punchline search
3. TropicalAggregate — O(n) max-plus humor aggregation
4. ComedyPolytopeCheck — O(1) validity check for (tension, humor, arc)
5. ComedyPolytopeRealize — O(1) triangle realization in ℝ²
6. HumorEntropyBound — O(n) expected surprise vs std dev
7. OptimalComedyOrdering — O(n log n) escalating sequence optimization
"""

import numpy as np
from typing import Tuple, List, Optional


def humor_compute(expected: np.ndarray, punchline: np.ndarray) -> float:
    """
    Compute the humor value of a joke.

    Humor = dist(expected, punchline) in Euclidean space.

    Args:
        expected: The expected resolution vector.
        punchline: The actual punchline vector.

    Returns:
        The humor value (non-negative real).

    Complexity: O(d) where d = dimension.

    Example:
        >>> humor_compute(np.array([0, 0]), np.array([3, 4]))
        5.0
    """
    return float(np.linalg.norm(np.asarray(expected) - np.asarray(punchline)))


def universal_joke_search(
    expected: np.ndarray,
    candidates: np.ndarray
) -> Tuple[int, float]:
    """
    Find the punchline that maximizes humor (distance from expected).

    This is the universal joke — the terminal object in the category
    of jokes with fixed setup and expectation.

    Args:
        expected: The expected resolution vector (shape: (d,)).
        candidates: Array of candidate punchlines (shape: (n, d)).

    Returns:
        Tuple of (best_index, max_humor).

    Complexity: O(n·d).

    Example:
        >>> expected = np.array([0, 0])
        >>> candidates = np.array([[1, 0], [3, 4], [2, 2]])
        >>> idx, humor = universal_joke_search(expected, candidates)
        >>> print(f"Best punchline index: {idx}, humor: {humor}")
        Best punchline index: 1, humor: 5.0
    """
    distances = np.linalg.norm(candidates - expected, axis=1)
    best_idx = int(np.argmax(distances))
    return best_idx, float(distances[best_idx])


def tropical_aggregate(humors: np.ndarray) -> float:
    """
    Tropical humor aggregation: max of individual humors.

    In the tropical semiring (max, +), this is the "sum" operation.
    Models the "best joke wins" principle.

    Args:
        humors: Array of humor values.

    Returns:
        Maximum humor value.

    Complexity: O(n).

    Example:
        >>> tropical_aggregate(np.array([1.0, 5.0, 3.0, 2.0]))
        5.0
    """
    if len(humors) == 0:
        return 0.0
    return float(np.max(humors))


def comedy_polytope_check(t: float, h: float, a: float) -> bool:
    """
    Check if (tension, humor, arc) is in the comedy polytope.

    The comedy polytope is the set of valid triangle side-lengths:
    t ≥ 0, h ≥ 0, a ≥ 0, and all three triangle inequalities hold.

    Args:
        t: Tension value.
        h: Humor value.
        a: Arc value.

    Returns:
        True if the triple is achievable as a joke.

    Complexity: O(1).

    Example:
        >>> comedy_polytope_check(3, 4, 5)
        True
        >>> comedy_polytope_check(1, 1, 10)
        False
    """
    return (t >= 0 and h >= 0 and a >= 0 and
            a <= t + h and h <= a + t and t <= a + h)


def comedy_polytope_realize(
    t: float, h: float, a: float
) -> Optional[Tuple[np.ndarray, np.ndarray, np.ndarray]]:
    """
    Realize a valid (tension, humor, arc) triple as a joke in ℝ².

    Given valid triangle side-lengths, constructs three points
    s, e, p ∈ ℝ² such that dist(s,e) = t, dist(e,p) = h, dist(s,p) = a.

    Args:
        t: Tension value.
        h: Humor value.
        a: Arc value.

    Returns:
        Tuple (setup, expected, punchline) as 2D numpy arrays,
        or None if the triple is not in the comedy polytope.

    Complexity: O(1).

    Example:
        >>> s, e, p = comedy_polytope_realize(3, 4, 5)
        >>> np.linalg.norm(s - e)  # ≈ 3.0
        3.0
    """
    if not comedy_polytope_check(t, h, a):
        return None

    s = np.array([0.0, 0.0])
    e = np.array([t, 0.0])

    if a < 1e-15:
        p = np.array([0.0, 0.0])
    elif t < 1e-15:
        p = np.array([a, 0.0])
    else:
        # Law of cosines: cos(angle at s) = (t² + a² - h²) / (2ta)
        cos_theta = (t**2 + a**2 - h**2) / (2 * t * a)
        cos_theta = np.clip(cos_theta, -1.0, 1.0)
        sin_theta = np.sqrt(max(0, 1 - cos_theta**2))
        p = np.array([a * cos_theta, a * sin_theta])

    return s, e, p


def humor_entropy_bound(
    points: np.ndarray,
    weights: np.ndarray
) -> Tuple[float, float, bool]:
    """
    Compute expected surprise and √variance, verify the bound.

    The Humor-Entropy Theorem states: E[|X - μ|] ≤ √Var(X).

    Args:
        points: Array of point values.
        weights: Probability weights (must sum to 1, non-negative).

    Returns:
        Tuple of (expected_surprise, sqrt_variance, bound_satisfied).

    Complexity: O(n).

    Example:
        >>> pts = np.array([0, 1, 2, 3, 4])
        >>> wts = np.array([0.2, 0.2, 0.2, 0.2, 0.2])
        >>> es, sv, ok = humor_entropy_bound(pts, wts)
        >>> print(f"E[|X-μ|]={es:.4f} ≤ √Var={sv:.4f}: {ok}")
    """
    mean = np.sum(weights * points)
    expected_surprise = np.sum(weights * np.abs(points - mean))
    variance = np.sum(weights * (points - mean)**2)
    sqrt_var = np.sqrt(variance)
    return float(expected_surprise), float(sqrt_var), expected_surprise <= sqrt_var + 1e-12


def optimal_comedy_ordering(humors: np.ndarray) -> np.ndarray:
    """
    Find the optimal ordering of jokes for escalating comedy.

    The Escalating Sum Lower Bound theorem guarantees that monotonically
    increasing humor sequences maximize the lower bound on total humor.
    This function returns the indices that sort jokes by increasing humor.

    Args:
        humors: Array of humor values.

    Returns:
        Array of indices giving the optimal escalating order.

    Complexity: O(n log n).

    Example:
        >>> humors = np.array([5.0, 1.0, 3.0, 2.0, 4.0])
        >>> order = optimal_comedy_ordering(humors)
        >>> print(humors[order])
        [1. 2. 3. 4. 5.]
    """
    return np.argsort(humors)


def surprise_lipschitz_bound(
    surprise_original: float,
    lipschitz_constant: float
) -> float:
    """
    Compute the upper bound on surprise after a K-Lipschitz translation.

    By the Surprise Lipschitz Bound theorem, if f is K-Lipschitz and
    preserves expectations, then surprise(f(x)) ≤ K · surprise(x).

    Args:
        surprise_original: Surprise value in the original space.
        lipschitz_constant: The Lipschitz constant K of the translation.

    Returns:
        Upper bound on the translated surprise.

    Complexity: O(1).

    Example:
        >>> surprise_lipschitz_bound(5.0, 2.0)
        10.0
    """
    return lipschitz_constant * surprise_original


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("Algorithm Examples:")
    print()

    # Humor computation
    h = humor_compute(np.array([0, 0]), np.array([3, 4]))
    print(f"1. Humor of joke (expected=[0,0], punchline=[3,4]): {h}")

    # Universal joke search
    expected = np.array([0.0, 0.0])
    candidates = np.array([[1, 0], [3, 4], [2, 2], [0, 1]])
    idx, max_h = universal_joke_search(expected, candidates)
    print(f"2. Universal joke: index={idx}, punchline={candidates[idx]}, humor={max_h}")

    # Tropical aggregation
    humors = np.array([1.0, 5.0, 3.0, 2.0])
    print(f"3. Tropical humor of {humors}: {tropical_aggregate(humors)}")

    # Comedy polytope
    print(f"4. (3,4,5) in polytope: {comedy_polytope_check(3, 4, 5)}")
    print(f"   (1,1,10) in polytope: {comedy_polytope_check(1, 1, 10)}")

    # Realization
    result = comedy_polytope_realize(3, 4, 5)
    if result:
        s, e, p = result
        print(f"5. Realized (3,4,5): s={s}, e={e}, p={p}")
        print(f"   Verification: t={np.linalg.norm(s-e):.4f}, "
              f"h={np.linalg.norm(e-p):.4f}, a={np.linalg.norm(s-p):.4f}")

    # Humor-entropy bound
    pts = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
    wts = np.array([0.2, 0.2, 0.2, 0.2, 0.2])
    es, sv, ok = humor_entropy_bound(pts, wts)
    print(f"6. Humor-Entropy: E[|X-μ|]={es:.4f} ≤ √Var={sv:.4f}: {ok}")

    # Optimal ordering
    humors = np.array([5.0, 1.0, 3.0, 2.0, 4.0])
    order = optimal_comedy_ordering(humors)
    print(f"7. Optimal order for {humors}: indices={order}, escalating={humors[order]}")
