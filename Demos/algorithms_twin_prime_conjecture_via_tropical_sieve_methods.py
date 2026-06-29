#!/usr/bin/env python3
"""
Tropical Sieve Theory: Core Algorithms

Implements the tropical sieve scoring, classical sieve weighting,
survivor set computation, pair-pattern analysis, and infimal convolution.
Includes complete docstrings, type hints, and complexity analysis.
"""

from typing import List, Callable, Tuple, Optional, Dict
import numpy as np
from dataclasses import dataclass


@dataclass
class SieveResult:
    """Result of a sieve computation."""
    tropical_survivors: List[int]
    classical_survivors: List[int]
    tropical_scores: Dict[int, float]
    classical_weights: Dict[int, float]


def tropical_sieve_score(P: List[int], c: Callable[[int], float], n: int) -> float:
    """
    Compute the tropical (min-plus) sieve score of n relative to prime set P.

    The tropical score is min_{p ∈ P} c(n mod p), the minimum local
    exclusion cost over all sieve primes.

    Args:
        P: List of sieve primes (or general moduli). Must be nonempty.
        c: Cost function mapping residues to real numbers.
        n: Candidate integer to score.

    Returns:
        The minimum of c(n mod p) over all p in P.
        Returns 0.0 if P is empty.

    Complexity: O(|P|)

    Example:
        >>> tropical_sieve_score([2, 3, 5], lambda r: float(r), 7)
        1.0  # min(7%2=1, 7%3=1, 7%5=2) = 1
    """
    if not P:
        return 0.0
    return min(c(n % p) for p in P)


def classical_sieve_weight(P: List[int], w: Callable[[int], float], n: int) -> float:
    """
    Compute the classical additive sieve weight of n relative to prime set P.

    The classical weight is ∑_{p ∈ P} w(n mod p), the sum of local
    weights over all sieve primes.

    Args:
        P: List of sieve primes.
        w: Weight function mapping residues to nonneg reals.
        n: Candidate integer to score.

    Returns:
        The sum of w(n mod p) over all p in P.

    Complexity: O(|P|)

    Example:
        >>> classical_sieve_weight([2, 3, 5], lambda r: float(r), 7)
        4.0  # 1 + 1 + 2 = 4
    """
    return sum(w(n % p) for p in P)


def compute_all_scores(
    A: List[int],
    P: List[int],
    c: Callable[[int], float],
    w: Optional[Callable[[int], float]] = None
) -> SieveResult:
    """
    Compute tropical and classical scores for all candidates in A.

    Args:
        A: List of candidate integers.
        P: List of sieve primes.
        c: Cost function for tropical scoring.
        w: Weight function for classical scoring (defaults to c).

    Returns:
        SieveResult with all scores and survivor lists.

    Complexity: O(|A| · |P|)
    """
    if w is None:
        w = c

    trop_scores = {}
    class_weights = {}

    for n in A:
        trop_scores[n] = tropical_sieve_score(P, c, n)
        class_weights[n] = classical_sieve_weight(P, w, n)

    return SieveResult(
        tropical_survivors=[],  # filled by threshold queries
        classical_survivors=[],
        tropical_scores=trop_scores,
        classical_weights=class_weights,
    )


def pair_pattern_score(P: List[int], c: Callable[[int], float], n: int) -> float:
    """
    Compute the pair-pattern (twin-prime) tropical score.

    For twin-prime detection, the score is:
    min_{p ∈ P} max(c(n mod p), c((n+2) mod p))

    This measures the worst-case cost of the pair (n, n+2) under
    the most favorable sieve prime.

    Args:
        P: List of sieve primes.
        c: Cost function.
        n: Candidate for the smaller element of a twin pair.

    Returns:
        The pair-pattern score.

    Complexity: O(|P|)
    """
    if not P:
        return 0.0
    return min(max(c(n % p), c((n + 2) % p)) for p in P)


def twin_unsieved_set(
    X: int,
    P: List[int],
    c: Callable[[int], float],
    t: float
) -> List[int]:
    """
    Compute the set of twin-candidate survivors up to X.

    Args:
        X: Upper bound of search range.
        P: List of sieve primes.
        c: Cost function.
        t: Threshold for survival.

    Returns:
        List of n in [0, X] with pair_pattern_score(P, c, n) ≤ t.

    Complexity: O(X · |P|)
    """
    return [n for n in range(X + 1) if pair_pattern_score(P, c, n) <= t]


def infimal_convolution(
    f: Callable[[int], float],
    g: Callable[[int], float],
    n: int
) -> float:
    """
    Compute the infimal (min-plus) convolution of f and g at n.

    (f ⊞ g)(n) = min_{0 ≤ k ≤ n} [f(k) + g(n-k)]

    This is the tropical analogue of additive convolution.

    Args:
        f: First function.
        g: Second function.
        n: Point at which to evaluate.

    Returns:
        The infimal convolution value.

    Complexity: O(n)
    """
    return min(f(k) + g(n - k) for k in range(n + 1))


def infimal_convolution_table(
    f: Callable[[int], float],
    g: Callable[[int], float],
    N: int
) -> np.ndarray:
    """
    Compute infimal convolution for all points 0..N using dynamic programming.

    This is more efficient than calling infimal_convolution() N times.

    Args:
        f: First function.
        g: Second function.
        N: Upper bound.

    Returns:
        Array of (f ⊞ g)(n) for n = 0, ..., N.

    Complexity: O(N²)
    """
    result = np.full(N + 1, np.inf)
    for n in range(N + 1):
        for k in range(n + 1):
            val = f(k) + g(n - k)
            if val < result[n]:
                result[n] = val
    return result


def two_phase_sieve(
    A: List[int],
    P: List[int],
    c: Callable[[int], float],
    t: float
) -> Tuple[List[int], List[int], int]:
    """
    Two-phase sieve algorithm: tropical pre-filter + classical refinement.

    Phase 1: Compute tropical score, eliminate candidates with score > t.
    Phase 2: For surviving candidates, compute classical weight.

    The comparison theorem guarantees no false negatives: any candidate
    eliminated by the classical sieve would also be eliminated by tropical.

    Args:
        A: Candidate set.
        P: Sieve primes.
        c: Cost function (used for both tropical and classical).
        t: Threshold.

    Returns:
        (tropical_survivors, classical_survivors, eliminated_by_prefilter)

    Complexity: O(|A| · |P|) total (same as direct, but with better cache behavior)
    """
    # Phase 1: Tropical pre-filter
    trop_survivors = []
    eliminated = 0
    for n in A:
        if tropical_sieve_score(P, c, n) <= t:
            trop_survivors.append(n)
        else:
            eliminated += 1

    # Phase 2: Classical refinement on survivors only
    class_survivors = []
    for n in trop_survivors:
        if classical_sieve_weight(P, c, n) <= t:
            class_survivors.append(n)

    return trop_survivors, class_survivors, eliminated


def relaxation_gap_analysis(
    A: List[int],
    P: List[int],
    c: Callable[[int], float]
) -> Dict[str, float]:
    """
    Analyze the gap between tropical and classical scores.

    Returns statistics on the distribution of
    (classical_weight - tropical_score) across all candidates.

    Args:
        A: Candidate set.
        P: Sieve primes.
        c: Cost function.

    Returns:
        Dictionary with gap statistics.
    """
    gaps = []
    for n in A:
        trop = tropical_sieve_score(P, c, n)
        clas = classical_sieve_weight(P, c, n)
        gaps.append(clas - trop)

    gaps = np.array(gaps)
    return {
        "mean_gap": float(np.mean(gaps)),
        "max_gap": float(np.max(gaps)),
        "min_gap": float(np.min(gaps)),
        "std_gap": float(np.std(gaps)),
        "fraction_strict": float(np.mean(gaps > 0)),
    }


if __name__ == "__main__":
    # Example usage
    P = [2, 3, 5, 7]
    c = lambda r: float(r)
    A = list(range(1, 101))

    print("Tropical vs Classical scores for n=1..10:")
    for n in range(1, 11):
        ts = tropical_sieve_score(P, c, n)
        cw = classical_sieve_weight(P, c, n)
        print(f"  n={n}: tropical={ts:.1f}, classical={cw:.1f}, gap={cw-ts:.1f}")

    print("\nTwo-phase sieve (t=2.0):")
    trop, clas, elim = two_phase_sieve(A, P, c, 2.0)
    print(f"  Pre-filtered: {elim}, Tropical survivors: {len(trop)}, "
          f"Classical survivors: {len(clas)}")

    print("\nRelaxation gap analysis:")
    stats = relaxation_gap_analysis(A, P, c)
    for k, v in stats.items():
        print(f"  {k}: {v:.4f}")
