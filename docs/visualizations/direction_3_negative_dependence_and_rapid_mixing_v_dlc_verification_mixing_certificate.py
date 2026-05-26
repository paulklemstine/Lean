"""
Algorithms for Directional Log-Concavity and Negative Dependence

Implements the core computational pipeline:
1. Two-site marginal computation
2. Pairwise DLC verification
3. Influence and Dobrushin constant computation
4. Mixing time certification
5. Glauber dynamics simulation
"""

import numpy as np
from itertools import combinations
from typing import Dict, Tuple, List, Optional, Callable


def subsets_of(n: int):
    """Generate all subsets of {0, 1, ..., n-1} as frozensets."""
    for i in range(1 << n):
        yield frozenset(j for j in range(n) if i & (1 << j))


def two_site_marginals(
    w: Dict[frozenset, float], n: int, i: int, j: int
) -> Tuple[float, float, float, float]:
    """
    Compute the four two-site marginals for coordinates i and j.

    Returns:
        (w11, w10, w01, w00) where:
        - w11 = sum of w(S) for S containing both i and j
        - w10 = sum of w(S) for S containing i but not j
        - w01 = sum of w(S) for S containing j but not i
        - w00 = sum of w(S) for S containing neither i nor j
    """
    w11 = w10 = w01 = w00 = 0.0
    for S in subsets_of(n):
        ws = w.get(S, 0.0)
        has_i = i in S
        has_j = j in S
        if has_i and has_j:
            w11 += ws
        elif has_i:
            w10 += ws
        elif has_j:
            w01 += ws
        else:
            w00 += ws
    return w11, w10, w01, w00


def check_dlc_pair(
    w: Dict[frozenset, float], n: int, i: int, j: int
) -> Tuple[bool, float]:
    """
    Check the DLC condition for a single pair (i, j).

    Returns:
        (is_dlc, gap) where gap = w10*w01 - w11*w00 (>= 0 iff DLC holds)
    """
    w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
    gap = w10 * w01 - w11 * w00
    return gap >= -1e-12, gap  # small tolerance for floating point


def check_pairwise_dlc(
    w: Dict[frozenset, float], n: int
) -> Tuple[bool, Dict[Tuple[int, int], float]]:
    """
    Check pairwise DLC for all pairs.

    Returns:
        (is_dlc, gaps) where gaps maps (i,j) to the DLC gap w10*w01 - w11*w00
    """
    gaps = {}
    is_dlc = True
    for i, j in combinations(range(n), 2):
        ok, gap = check_dlc_pair(w, n, i, j)
        gaps[(i, j)] = gap
        if not ok:
            is_dlc = False
    return is_dlc, gaps


def compute_inclusion_prob(w: Dict[frozenset, float], n: int, i: int) -> float:
    """Compute Pr[i ∈ X] = (sum of w(S) for i in S) / Z."""
    num = sum(ws for S, ws in w.items() if i in S)
    Z = sum(w.values())
    return num / Z if Z > 0 else 0.0


def compute_pair_inclusion_prob(
    w: Dict[frozenset, float], n: int, i: int, j: int
) -> float:
    """Compute Pr[i ∈ X ∧ j ∈ X]."""
    num = sum(ws for S, ws in w.items() if i in S and j in S)
    Z = sum(w.values())
    return num / Z if Z > 0 else 0.0


def compute_conditional_prob(
    w: Dict[frozenset, float], n: int, i: int, j: int, bj: bool
) -> float:
    """Compute Pr[X_i=1 | X_j=bj]."""
    w11, w10, w01, w00 = two_site_marginals(w, n, i, j)
    if bj:
        denom = w11 + w01
        return w11 / denom if denom > 0 else 0.0
    else:
        denom = w10 + w00
        return w10 / denom if denom > 0 else 0.0


def compute_site_influence(
    w: Dict[frozenset, float], n: int, i: int, j: int
) -> float:
    """
    Compute the site influence I(i,j) = Pr[Xi=1|Xj=1] - Pr[Xi=1|Xj=0].

    Under DLC, this is always ≤ 0.
    """
    return (compute_conditional_prob(w, n, i, j, True) -
            compute_conditional_prob(w, n, i, j, False))


def compute_total_influence(w: Dict[frozenset, float], n: int, i: int) -> float:
    """Compute total influence at site i: sum_{j≠i} |I(i,j)|."""
    return sum(abs(compute_site_influence(w, n, i, j))
               for j in range(n) if j != i)


def compute_dobrushin_constant(w: Dict[frozenset, float], n: int) -> float:
    """Compute the Dobrushin constant: max_i totalInfluenceAt(i)."""
    if n == 0:
        return 0.0
    return max(compute_total_influence(w, n, i) for i in range(n))


def mixing_time_bound(n: int, c: float, eps: float = 0.01) -> float:
    """
    Compute the mixing time upper bound: n/(1-c) * ln(n/eps).

    Args:
        n: Number of sites
        c: Dobrushin constant (must be < 1)
        eps: Target accuracy

    Returns:
        Upper bound on mixing time
    """
    if c >= 1:
        return float('inf')
    return (n / (1 - c)) * np.log(n / eps)


def dlc_certificate(
    w: Dict[frozenset, float], n: int, eps: float = 0.01
) -> Dict:
    """
    Full DLC verification and mixing time certification pipeline.

    Returns a dictionary with:
    - is_dlc: whether pairwise DLC holds
    - dobrushin_constant: the Dobrushin constant c
    - mixing_time: upper bound on mixing time (if c < 1)
    - influence_matrix: matrix of site influences
    - negative_correlations: dict of pair covariances
    """
    is_dlc, gaps = check_pairwise_dlc(w, n)

    # Compute influence matrix
    influence_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                influence_matrix[i, j] = compute_site_influence(w, n, i, j)

    # Dobrushin constant
    c = compute_dobrushin_constant(w, n)

    # Negative correlations
    neg_corr = {}
    Z = sum(w.values())
    for i, j in combinations(range(n), 2):
        pi = compute_inclusion_prob(w, n, i)
        pj = compute_inclusion_prob(w, n, j)
        pij = compute_pair_inclusion_prob(w, n, i, j)
        neg_corr[(i, j)] = pij - pi * pj

    # Mixing time
    tmix = mixing_time_bound(n, c, eps) if c < 1 else float('inf')

    return {
        'is_dlc': is_dlc,
        'dlc_gaps': gaps,
        'dobrushin_constant': c,
        'mixing_time': tmix,
        'influence_matrix': influence_matrix,
        'negative_correlations': neg_corr,
        'partition_function': Z,
    }


def glauber_step(
    w: Dict[frozenset, float], n: int, x: np.ndarray, rng: np.random.Generator
) -> np.ndarray:
    """
    Perform one step of single-site Glauber dynamics.

    Args:
        w: Weight function
        n: Number of sites
        x: Current configuration (binary array of length n)
        rng: Random number generator

    Returns:
        Updated configuration
    """
    x = x.copy()
    i = rng.integers(0, n)  # Pick random site

    # Compute conditional probability Pr[Xi=1 | X_{-i} = x_{-i}]
    # Sum weights over configurations agreeing with x on all sites except i
    w_with_i = 0.0
    w_without_i = 0.0
    for S in subsets_of(n):
        # Check if S agrees with x on all sites except possibly i
        agrees = all(((j in S) == bool(x[j])) for j in range(n) if j != i)
        if agrees:
            ws = w.get(S, 0.0)
            if i in S:
                w_with_i += ws
            else:
                w_without_i += ws

    total = w_with_i + w_without_i
    if total > 0:
        prob_i = w_with_i / total
        x[i] = 1 if rng.random() < prob_i else 0
    return x


def glauber_sample(
    w: Dict[frozenset, float], n: int, T: int,
    x0: Optional[np.ndarray] = None, seed: int = 42
) -> np.ndarray:
    """
    Run T steps of Glauber dynamics and return final configuration.

    Args:
        w: Weight function
        n: Number of sites
        T: Number of steps
        x0: Initial configuration (default: all zeros)
        seed: Random seed

    Returns:
        Final configuration
    """
    rng = np.random.default_rng(seed)
    x = x0 if x0 is not None else np.zeros(n, dtype=int)
    for _ in range(T):
        x = glauber_step(w, n, x, rng)
    return x


def glauber_trajectory(
    w: Dict[frozenset, float], n: int, T: int,
    x0: Optional[np.ndarray] = None, seed: int = 42
) -> List[np.ndarray]:
    """Run Glauber dynamics and return full trajectory."""
    rng = np.random.default_rng(seed)
    x = x0 if x0 is not None else np.zeros(n, dtype=int)
    trajectory = [x.copy()]
    for _ in range(T):
        x = glauber_step(w, n, x, rng)
        trajectory.append(x.copy())
    return trajectory


# --- Example weight system constructors ---

def uniform_weights(n: int) -> Dict[frozenset, float]:
    """Uniform weight w(S) = 1 for all S."""
    return {S: 1.0 for S in subsets_of(n)}


def bernoulli_weights(n: int, p: float = 0.5) -> Dict[frozenset, float]:
    """Independent Bernoulli(p) weights: w(S) = p^|S| * (1-p)^(n-|S|)."""
    return {S: p ** len(S) * (1 - p) ** (n - len(S)) for S in subsets_of(n)}


def exclusion_weights(n: int, k: int) -> Dict[frozenset, float]:
    """Uniform distribution on subsets of size k (exclusion process)."""
    return {S: (1.0 if len(S) == k else 0.0) for S in subsets_of(n)}


def repulsive_weights(n: int, beta: float = 1.0) -> Dict[frozenset, float]:
    """
    Repulsive weights: w(S) = exp(-beta * number of adjacent pairs in S).

    Models antiferromagnetic Ising on a path graph.
    """
    def count_adjacent(S):
        return sum(1 for x in S if x + 1 in S)

    return {S: np.exp(-beta * count_adjacent(S)) for S in subsets_of(n)}


def dpp_weights(n: int, L: np.ndarray) -> Dict[frozenset, float]:
    """
    Determinantal point process weights: w(S) = det(L_S).

    Args:
        n: Ground set size
        L: n×n positive semidefinite kernel matrix
    """
    weights = {}
    for S in subsets_of(n):
        idx = sorted(S)
        if len(idx) == 0:
            weights[S] = 1.0
        else:
            submatrix = L[np.ix_(idx, idx)]
            weights[S] = max(0.0, np.linalg.det(submatrix))
    return weights


if __name__ == '__main__':
    # Example usage
    n = 4

    print("=" * 60)
    print("DLC Certificate for Uniform Weights (n=4)")
    print("=" * 60)
    w = uniform_weights(n)
    cert = dlc_certificate(w, n)
    print(f"Is DLC: {cert['is_dlc']}")
    print(f"Dobrushin constant: {cert['dobrushin_constant']:.6f}")
    print(f"Mixing time bound: {cert['mixing_time']:.1f}")
    print(f"Negative correlations: {cert['negative_correlations']}")

    print("\n" + "=" * 60)
    print("DLC Certificate for Repulsive Weights (n=4, beta=1)")
    print("=" * 60)
    w = repulsive_weights(n, beta=1.0)
    cert = dlc_certificate(w, n)
    print(f"Is DLC: {cert['is_dlc']}")
    print(f"Dobrushin constant: {cert['dobrushin_constant']:.6f}")
    print(f"Mixing time bound: {cert['mixing_time']:.1f}")
    print(f"Influence matrix:\n{cert['influence_matrix']}")
