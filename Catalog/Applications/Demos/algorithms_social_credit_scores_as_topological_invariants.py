"""
Algorithms for Social Credit Scoring Dynamics.

Type-hinted implementations of scoring dynamics, phase transition detection,
and Cantor IFS attractor approximation.
"""

from typing import Callable, List, Tuple, Dict, Set
import numpy as np


def iterate_scoring(
    update: Callable[[np.ndarray], np.ndarray],
    init: np.ndarray,
    steps: int
) -> List[np.ndarray]:
    """Iterate a scoring update rule from initial scores.

    Args:
        update: Function mapping score vector to updated score vector.
        init: Initial score vector of shape (n,).
        steps: Number of iterations.

    Returns:
        List of score vectors at each step (length steps+1).
    """
    trajectory: List[np.ndarray] = [init.copy()]
    current = init.copy()
    for _ in range(steps):
        current = update(current)
        trajectory.append(current.copy())
    return trajectory


def find_fixed_point(
    update: Callable[[np.ndarray], np.ndarray],
    init: np.ndarray,
    tol: float = 1e-10,
    max_iter: int = 10000
) -> Tuple[np.ndarray, int]:
    """Find fixed point of a scoring dynamics via iteration.

    Args:
        update: Scoring update rule.
        init: Initial score vector.
        tol: Convergence tolerance (sup-norm).
        max_iter: Maximum iterations.

    Returns:
        Tuple of (fixed_point, iterations_used).
    """
    current = init.copy()
    for step in range(max_iter):
        next_scores = update(current)
        if np.max(np.abs(next_scores - current)) < tol:
            return next_scores, step + 1
        current = next_scores
    return current, max_iter


def assign_tier(thresholds: np.ndarray, score: float) -> int:
    """Assign a tier to a score based on sorted thresholds.

    The tier is the count of thresholds that the score exceeds or equals.

    Args:
        thresholds: Sorted array of threshold values.
        score: The score to classify.

    Returns:
        Integer tier in {0, 1, ..., len(thresholds)}.
    """
    return int(np.sum(thresholds <= score))


def detect_phase_transitions(
    thresholds: np.ndarray,
    scores: np.ndarray,
    epsilon: float
) -> List[Dict[str, object]]:
    """Detect phase transitions caused by threshold perturbation.

    For each threshold, shifts it by epsilon and checks which
    individuals change tier.

    Args:
        thresholds: Current threshold values.
        scores: Score vector for the population.
        epsilon: Perturbation magnitude.

    Returns:
        List of dicts with keys: threshold_index, individual,
        old_tier, new_tier.
    """
    transitions: List[Dict[str, object]] = []
    for t_idx in range(len(thresholds)):
        perturbed = thresholds.copy()
        perturbed[t_idx] += epsilon
        for i, s in enumerate(scores):
            old_tier = assign_tier(thresholds, s)
            new_tier = assign_tier(perturbed, s)
            if old_tier != new_tier:
                transitions.append({
                    'threshold_index': t_idx,
                    'individual': i,
                    'old_tier': old_tier,
                    'new_tier': new_tier,
                })
    return transitions


def cantor_ifs_iterate(
    c: float = 1/3,
    depth: int = 8
) -> List[Tuple[float, float]]:
    """Approximate the Cantor IFS attractor by iterating interval removal.

    Uses the IFS {x -> cx, x -> cx + (1-c)} with contraction ratio c.

    Args:
        c: Contraction ratio (must be < 0.5 for Cantor set).
        depth: Number of iteration levels.

    Returns:
        List of (left, right) intervals approximating the attractor.
    """
    intervals: List[Tuple[float, float]] = [(0.0, 1.0)]
    for _ in range(depth):
        new_intervals: List[Tuple[float, float]] = []
        for a, b in intervals:
            new_intervals.append((c * a, c * b))
            new_intervals.append((c * a + (1 - c), c * b + (1 - c)))
        intervals = new_intervals
    return intervals


def compute_box_counting_dimension(
    c: float,
    depths: List[int]
) -> float:
    """Estimate box-counting dimension of the IFS attractor.

    Args:
        c: Contraction ratio.
        depths: List of depths to compute at.

    Returns:
        Estimated dimension via linear regression on log-log plot.
    """
    log_counts = []
    log_scales = []
    for k in depths:
        n_boxes = 2 ** k
        scale = c ** k
        log_counts.append(np.log(n_boxes))
        log_scales.append(-np.log(scale))

    # Linear regression: dim = slope of log(N) vs log(1/scale)
    coeffs = np.polyfit(log_scales, log_counts, 1)
    return float(coeffs[0])


def contractive_update(
    scores: np.ndarray,
    c: float = 0.5,
    target: float = 0.5
) -> np.ndarray:
    """A simple contractive scoring update: pull toward a target.

    update(s) = c * s + (1-c) * target

    This is c-contractive with the unique fixed point at target.

    Args:
        scores: Current score vector.
        c: Contraction factor (0 <= c < 1).
        target: Target score (the fixed point).

    Returns:
        Updated score vector.
    """
    return c * scores + (1 - c) * target


def monotone_scoring_example(
    n: int = 10,
    steps: int = 50
) -> Tuple[List[np.ndarray], int]:
    """Run a monotone scoring example and find convergence step.

    Uses a rank-preserving mean-regression update.

    Args:
        n: Population size.
        steps: Number of iterations.

    Returns:
        Tuple of (trajectory, convergence_step).
    """
    rng = np.random.default_rng(42)
    init = rng.random(n)

    def update(s: np.ndarray) -> np.ndarray:
        mean = np.mean(s)
        return 0.8 * s + 0.2 * mean

    trajectory = iterate_scoring(update, init, steps)

    # Find convergence step
    for step in range(1, len(trajectory)):
        if np.max(np.abs(trajectory[step] - trajectory[step-1])) < 1e-12:
            return trajectory, step
    return trajectory, steps
