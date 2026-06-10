#!/usr/bin/env python3
"""
Categorical Humor Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the formalization.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


def euclidean_dist(x: List[float], y: List[float]) -> float:
    """Compute Euclidean distance between two points."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


@dataclass
class Joke:
    """A joke in a metric space: (setup, expected, punchline)."""
    setup: List[float]
    expected: List[float]
    punchline: List[float]

    def humor(self) -> float:
        """Surprise: distance from expected to actual punchline."""
        return euclidean_dist(self.expected, self.punchline)

    def tension(self) -> float:
        """Tension: distance from setup to expected."""
        return euclidean_dist(self.setup, self.expected)

    def arc(self) -> float:
        """Arc: total distance from setup to punchline."""
        return euclidean_dist(self.setup, self.punchline)

    def deficiency(self) -> float:
        """Humor deficiency: tension + humor - arc ≥ 0."""
        return self.tension() + self.humor() - self.arc()

    def is_geodesic(self, tol: float = 1e-10) -> bool:
        """Whether the joke is geodesic (deficiency ≈ 0)."""
        return abs(self.deficiency()) < tol


def pun_component(humor: float, epsilon: float) -> float:
    """Pun component of humor: min(humor, epsilon)."""
    return min(humor, epsilon)


def absurdist_component(humor: float, epsilon: float) -> float:
    """Absurdist component of humor: humor - min(humor, epsilon)."""
    return humor - min(humor, epsilon)


def classify_joke(joke: Joke, epsilon: float) -> str:
    """Classify a joke as 'pun', 'absurdist', or 'mixed'."""
    h = joke.humor()
    pun = pun_component(h, epsilon)
    absurd = absurdist_component(h, epsilon)
    if absurd < 1e-10:
        return "pun"
    elif pun < epsilon * 0.1:
        return "absurdist"
    else:
        return "mixed"


def humor_spectrum(points: List[List[float]]) -> List[float]:
    """Compute the humor spectrum: all pairwise distances, sorted."""
    dists = set()
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            if i != j:
                dists.add(round(euclidean_dist(p, q), 12))
    return sorted(dists)


def spectral_gap(points: List[List[float]]) -> Optional[float]:
    """Compute the spectral gap: minimum positive pairwise distance."""
    spectrum = humor_spectrum(points)
    positive = [d for d in spectrum if d > 0]
    return positive[0] if positive else None


def universal_joke(
    setup: List[float],
    expected: List[float],
    candidates: List[List[float]]
) -> Tuple[List[float], float]:
    """Find the universal joke: punchline maximizing humor.

    Returns (punchline, humor_value).
    """
    best_p = candidates[0]
    best_h = euclidean_dist(expected, candidates[0])
    for p in candidates[1:]:
        h = euclidean_dist(expected, p)
        if h > best_h:
            best_h = h
            best_p = p
    return best_p, best_h


def dual_joke(joke: Joke) -> Joke:
    """Compute the dual joke: swap expected and punchline."""
    return Joke(
        setup=joke.setup,
        expected=joke.punchline,
        punchline=joke.expected
    )


def compose_jokes(j1: Joke, j2: Joke) -> Joke:
    """Compose two jokes: setup₁ → expected₁ → punchline₂."""
    return Joke(
        setup=j1.setup,
        expected=j1.expected,
        punchline=j2.punchline
    )


def humor_convolution(
    humors1: List[float],
    humors2: List[float]
) -> List[List[float]]:
    """Compute humor convolution: all pairwise sums."""
    return [[h1 + h2 for h2 in humors2] for h1 in humors1]


def weighted_humor_stats(
    values: List[float],
    weights: List[float]
) -> Tuple[float, float, float]:
    """Compute weighted mean, E[|X-μ|], and √Var(X).

    Returns (mean, mean_abs_dev, sqrt_variance).
    """
    mu = sum(w * x for w, x in zip(weights, values))
    mad = sum(w * abs(x - mu) for w, x in zip(weights, values))
    var = sum(w * (x - mu) ** 2 for w, x in zip(weights, values))
    return mu, mad, math.sqrt(var)


def chebyshev_bound(
    values: List[float],
    mu: float,
    t: float
) -> Tuple[int, float]:
    """Apply Chebyshev comedy principle.

    Returns (count of deviators, sum of squared deviations).
    """
    deviators = sum(1 for x in values if abs(x - mu) >= t)
    total_sq = sum((x - mu) ** 2 for x in values)
    return deviators, total_sq


def bilipschitz_humor_bounds(
    joke: Joke,
    K: float,
    f: callable
) -> Tuple[float, float, float]:
    """Compute bi-Lipschitz humor bounds.

    Returns (lower_bound, actual_humor, upper_bound).
    """
    transformed = Joke(
        setup=[f(x) for x in joke.setup],
        expected=[f(x) for x in joke.expected],
        punchline=[f(x) for x in joke.punchline],
    )
    original_humor = joke.humor()
    transformed_humor = transformed.humor()
    return original_humor / K, transformed_humor, K * original_humor


def punchline_variance_bound(D: float) -> float:
    """Compute the Popoviciu variance bound: D²/4."""
    return D ** 2 / 4


if __name__ == "__main__":
    # Quick smoke test
    j = Joke([0, 0], [3, 0], [3, 4])
    print(f"Joke: humor={j.humor():.3f}, tension={j.tension():.3f}, "
          f"arc={j.arc():.3f}, deficiency={j.deficiency():.3f}")

    points = [[i, j] for i in range(3) for j in range(3)]
    gap = spectral_gap(points)
    print(f"Spectral gap of 3×3 grid: {gap}")

    p, h = universal_joke([0, 0], [0, 0], points)
    print(f"Universal joke from origin: punchline={p}, humor={h:.3f}")

    print("All smoke tests passed.")
