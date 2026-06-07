"""
Algorithms for Categorical Surprise Theory

Type-hinted implementations of the core algorithms from the research.
"""

from typing import List, Tuple, Callable, Optional
import math


def compute_humor_value(expected: float, actual: float) -> float:
    """
    Compute the humor value of a joke.

    The humor value is the metric distance between the expected resolution
    and the actual punchline.

    Args:
        expected: The expected resolution point
        actual: The actual punchline point

    Returns:
        The humor value (non-negative real number)
    """
    return abs(expected - actual)


def find_funniest_joke(expected: float, candidates: List[float]) -> Tuple[float, float]:
    """
    Find the funniest joke (maximum surprise) from a set of candidates.

    In a compact finite set, the maximum is always attained
    (Fundamental Theorem of Comedy).

    Args:
        expected: The expected resolution
        candidates: List of candidate punchlines

    Returns:
        Tuple of (funniest punchline, its humor value)
    """
    if not candidates:
        raise ValueError("Need at least one candidate")

    best = candidates[0]
    best_humor = compute_humor_value(expected, best)

    for candidate in candidates[1:]:
        humor = compute_humor_value(expected, candidate)
        if humor > best_humor:
            best = candidate
            best_humor = humor

    return best, best_humor


def find_humor_duality(
    expected: float, candidates: List[float]
) -> Tuple[Tuple[float, float], Tuple[float, float]]:
    """
    Find both the funniest and most boring jokes (Humor Duality Theorem).

    Args:
        expected: The expected resolution
        candidates: List of candidate punchlines

    Returns:
        Tuple of ((funniest, its humor), (most_boring, its humor))
    """
    if not candidates:
        raise ValueError("Need at least one candidate")

    funniest = candidates[0]
    boring = candidates[0]
    max_h = compute_humor_value(expected, funniest)
    min_h = max_h

    for c in candidates[1:]:
        h = compute_humor_value(expected, c)
        if h > max_h:
            funniest, max_h = c, h
        if h < min_h:
            boring, min_h = c, h

    return (funniest, max_h), (boring, min_h)


def compute_chain_humor(chain: List[float]) -> Tuple[float, float]:
    """
    Compute end-to-end and total humor of a joke chain.

    The Humor Chain Inequality guarantees:
        end_to_end_humor <= total_humor

    Args:
        chain: Sequence of points forming the joke chain

    Returns:
        Tuple of (end_to_end_humor, total_humor)
    """
    if len(chain) < 2:
        return 0.0, 0.0

    end_to_end = compute_humor_value(chain[0], chain[-1])
    total = sum(compute_humor_value(chain[i], chain[i + 1]) for i in range(len(chain) - 1))

    return end_to_end, total


def iterate_subversion(
    f: Callable[[float], float],
    x0: float,
    n_iterations: int = 100,
    tolerance: float = 1e-10,
) -> Tuple[float, List[float]]:
    """
    Iterate a subversion map to find its fixed point.

    For contractive maps (amplification < 1), this converges to the
    unique self-referential fixed point (Humor Convergence Theorem).

    Args:
        f: The subversion map
        x0: Starting point
        n_iterations: Maximum iterations
        tolerance: Convergence tolerance

    Returns:
        Tuple of (approximate fixed point, trajectory)
    """
    trajectory = [x0]
    x = x0

    for _ in range(n_iterations):
        x_new = f(x)
        trajectory.append(x_new)
        if abs(x_new - x) < tolerance:
            break
        x = x_new

    return trajectory[-1], trajectory


def compute_surprise_entropy(
    expected: float,
    punchlines: List[float],
    weights: List[float],
) -> float:
    """
    Compute the surprise entropy of a weighted joke distribution.

    H(w, p) = sum_i w_i * d(p_i, expected)

    Satisfies:
    - Nonnegativity: H >= 0 when weights are nonneg
    - Bound: H <= max(d(p_i, expected)) when sum(w_i) = 1

    Args:
        expected: The expected resolution
        punchlines: List of punchline positions
        weights: Probability weights (should sum to 1)

    Returns:
        The surprise entropy value
    """
    return sum(
        w * compute_humor_value(expected, p) for w, p in zip(weights, punchlines)
    )


def compute_cone_diameter_bound(
    vertex: float, legs: List[float]
) -> Tuple[float, float, float]:
    """
    Compute the surprise cone's radius and diameter bound.

    Theorem: max pairwise distance between legs <= 2 * radius

    Args:
        vertex: The cone vertex
        legs: The cone legs

    Returns:
        Tuple of (radius, max_pairwise_distance, theoretical_bound)
    """
    radius = max(abs(leg - vertex) for leg in legs)
    max_pairwise = 0.0

    for i in range(len(legs)):
        for j in range(i + 1, len(legs)):
            d = abs(legs[i] - legs[j])
            max_pairwise = max(max_pairwise, d)

    return radius, max_pairwise, 2 * radius


def iterated_amplification_bound(
    amplification: float, initial_distance: float, n: int
) -> float:
    """
    Compute the sharp bound on distance after n iterations.

    d(f^n(x), f^n(y)) <= C^n * d(x, y)

    Args:
        amplification: The Lipschitz constant C
        initial_distance: d(x, y)
        n: Number of iterations

    Returns:
        The bound C^n * d(x, y)
    """
    return amplification**n * initial_distance


if __name__ == "__main__":
    # Quick verification
    print("Algorithms verification:")

    # Funniest joke
    f, h = find_funniest_joke(5.0, [1.0, 3.0, 7.0, 12.0, 4.0])
    print(f"  Funniest from [1,3,7,12,4] with expected=5: punchline={f}, humor={h}")

    # Chain humor
    e2e, total = compute_chain_humor([0, 3, 1, 7, 2, 10])
    print(f"  Chain [0,3,1,7,2,10]: e2e={e2e}, total={total}, holds={e2e <= total}")

    # Fixed point
    fp, traj = iterate_subversion(lambda x: 0.5 * x + 1.0, 10.0)
    print(f"  Fixed point of 0.5x+1: {fp:.6f} (theoretical: 2.0)")

    # Entropy
    ent = compute_surprise_entropy(0.0, [1, 3, 5, 10], [0.4, 0.3, 0.2, 0.1])
    print(f"  Surprise entropy: {ent:.2f}")

    # Cone
    r, mp, bound = compute_cone_diameter_bound(5.0, [3.0, 4.5, 6.0, 7.0, 2.0])
    print(f"  Cone: radius={r}, max_pairwise={mp}, bound={bound}, holds={mp <= bound}")
