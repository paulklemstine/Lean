"""
Categorical Humor Theory: Core Algorithms

Type-hinted implementations of the mathematical algorithms from the formal theory.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import math


@dataclass
class Joke:
    """A joke in a metric space: (setup, expected, punchline)."""
    setup: np.ndarray
    expected: np.ndarray
    punchline: np.ndarray

    def humor(self) -> float:
        """Humor = dist(expected, punchline)."""
        return float(np.linalg.norm(self.expected - self.punchline))

    def tension(self) -> float:
        """Tension = dist(setup, expected)."""
        return float(np.linalg.norm(self.setup - self.expected))

    def arc(self) -> float:
        """Arc = dist(setup, punchline)."""
        return float(np.linalg.norm(self.setup - self.punchline))

    def is_geodesic(self, tol: float = 1e-10) -> bool:
        """Check if joke is geodesic: tension + humor = arc."""
        return abs(self.tension() + self.humor() - self.arc()) < tol


def operator_surprise(T: np.ndarray, x: np.ndarray) -> float:
    """Surprise of linear operator T at point x: ||Tx - x||."""
    return float(np.linalg.norm(T @ x - x))


def operator_surprise_bound(T: np.ndarray, x: np.ndarray) -> float:
    """Upper bound: ||T - I|| * ||x||."""
    I = np.eye(T.shape[0])
    return float(np.linalg.norm(T - I, ord=2) * np.linalg.norm(x))


def optimal_joke_search(
    expected: np.ndarray,
    candidates: np.ndarray,
) -> Tuple[np.ndarray, float]:
    """
    Find the punchline maximizing humor from a set of candidates.

    Algorithm: O(n) scan over candidates.
    Theorem: optimal_joke_exists guarantees existence in compact spaces.

    Args:
        expected: The expected resolution point.
        candidates: Array of shape (n, d) of candidate punchlines.

    Returns:
        (best_punchline, max_humor)
    """
    dists = np.linalg.norm(candidates - expected, axis=1)
    best_idx = np.argmax(dists)
    return candidates[best_idx], float(dists[best_idx])


def joke_refiner_iterate(
    refine: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    n_iters: int,
    contractivity: float,
) -> List[Tuple[np.ndarray, float]]:
    """
    Iterate a joke refiner and track humor decay.

    Theorem: refiner_geometric_bound guarantees
    dist(x_n, x_{n+1}) ≤ c^n * dist(x_0, x_1).

    Args:
        refine: Contraction mapping on punchlines.
        x0: Initial punchline.
        n_iters: Number of iterations.
        contractivity: Contraction factor c ∈ [0, 1).

    Returns:
        List of (point, distance_to_next) pairs.
    """
    trajectory = []
    x = x0.copy()
    for i in range(n_iters):
        x_next = refine(x)
        d = float(np.linalg.norm(x - x_next))
        trajectory.append((x.copy(), d))
        bound = contractivity**i * float(np.linalg.norm(x0 - refine(x0)))
        assert d <= bound + 1e-10, f"Bound violated at step {i}: {d} > {bound}"
        x = x_next
    return trajectory


def comedy_cauchy_schwarz_check(humors: np.ndarray) -> Tuple[float, float, bool]:
    """
    Verify Comedy Cauchy-Schwarz: (Σ hᵢ)² ≤ n · Σ hᵢ².

    Args:
        humors: Array of humor values.

    Returns:
        (lhs, rhs, satisfied)
    """
    n = len(humors)
    lhs = float(np.sum(humors))**2
    rhs = n * float(np.sum(humors**2))
    return lhs, rhs, lhs <= rhs + 1e-10


def humor_convex_combination(
    expected: np.ndarray,
    p1: np.ndarray,
    p2: np.ndarray,
    t: float,
) -> Tuple[float, float]:
    """
    Compute humor of convex combination and its bound.

    Theorem: humor_convex_combination guarantees
    dist(e, (1-t)p₁ + tp₂) ≤ (1-t)*dist(e,p₁) + t*dist(e,p₂).

    Returns:
        (actual_humor, bound)
    """
    p_blend = (1 - t) * p1 + t * p2
    actual = float(np.linalg.norm(expected - p_blend))
    bound = (1 - t) * float(np.linalg.norm(expected - p1)) + \
            t * float(np.linalg.norm(expected - p2))
    return actual, bound


def humor_half_life(h0: float, r: float, epsilon: float) -> int:
    """
    Compute the humor half-life: smallest n such that r^n * h0 < epsilon.

    Theorem: humor_half_life_exists guarantees this exists for 0 < r < 1.

    Args:
        h0: Initial humor (positive).
        r: Decay rate (0 < r < 1).
        epsilon: Threshold.

    Returns:
        n: Number of retellings until humor drops below epsilon.
    """
    if h0 <= 0 or r <= 0 or r >= 1 or epsilon <= 0:
        raise ValueError("Need h0 > 0, 0 < r < 1, epsilon > 0")
    # r^n * h0 < epsilon  =>  n > log(epsilon/h0) / log(r)
    n = math.ceil(math.log(epsilon / h0) / math.log(r))
    return max(0, n)


def compose_jokes(j1: Joke, j2: Joke) -> Joke:
    """
    Compose two jokes (j1's punchline = j2's setup).

    Theorem: compose_humor_bound gives
    humor(j1∘j2) ≤ humor(j1) + tension(j2) + humor(j2).

    Returns:
        Composed joke.
    """
    return Joke(
        setup=j1.setup,
        expected=j1.expected,
        punchline=j2.punchline,
    )


def midpoint_factorize(expected: np.ndarray, punchline: np.ndarray) -> np.ndarray:
    """
    Compute the comedic midpoint: (e + p) / 2.

    Theorem: midpoint_humor_half shows dist(e, mid) = dist(e, p) / 2.
    Theorem: midpoint_equidistant shows dist(e, mid) = dist(mid, p).

    Returns:
        Midpoint vector.
    """
    return (expected + punchline) / 2


def humor_spectrum(jokes: List[Joke]) -> np.ndarray:
    """
    Compute the humor spectrum of a joke collection.

    Returns sorted humor values (descending).
    """
    humors = np.array([j.humor() for j in jokes])
    return np.sort(humors)[::-1]


if __name__ == "__main__":
    # Quick self-test
    j = Joke(
        setup=np.array([0.0, 0.0]),
        expected=np.array([1.0, 0.0]),
        punchline=np.array([0.0, 2.0]),
    )
    print(f"Joke humor: {j.humor():.3f}")
    print(f"Joke tension: {j.tension():.3f}")
    print(f"Joke arc: {j.arc():.3f}")
    print(f"Is geodesic: {j.is_geodesic()}")

    # Cauchy-Schwarz test
    humors = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    lhs, rhs, ok = comedy_cauchy_schwarz_check(humors)
    print(f"Cauchy-Schwarz: {lhs:.1f} ≤ {rhs:.1f} : {ok}")

    # Half-life
    n = humor_half_life(100.0, 0.9, 1.0)
    print(f"Half-life (h0=100, r=0.9, ε=1): {n} retellings")
