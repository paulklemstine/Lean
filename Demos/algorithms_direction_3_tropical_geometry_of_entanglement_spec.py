"""
algorithms.py — Core algorithms for tropical entanglement geometry.

Implements:
  1. Elementary symmetric polynomial computation via dynamic programming.
  2. Tropical profile and slope computation.
  3. Block envelope via greedy optimization.
  4. Log-sum-exp sandwich bounds.
"""

import numpy as np
from math import comb, log, exp
from typing import List, Tuple, Optional


def elementary_symmetric_polynomials(weights: np.ndarray) -> np.ndarray:
    """Compute all e_k(w) for k = 0, ..., m using O(m^2) dynamic programming.

    Algorithm: The recurrence e_k^{n+1} = e_k^n + w_{n+1} * e_{k-1}^n.
    Starting from e_0 = 1, e_k = 0 for k >= 1, we incorporate one weight at a time.

    Args:
        weights: Array of m nonneg weights [w_1, ..., w_m].

    Returns:
        Array of length m+1 with e_k(w) for k = 0, 1, ..., m.

    Time complexity: O(m^2).
    Space complexity: O(m).

    Example:
        >>> elementary_symmetric_polynomials(np.array([2.0, 3.0, 5.0]))
        array([ 1., 10., 31., 30.])
    """
    m = len(weights)
    e = np.zeros(m + 1)
    e[0] = 1.0

    for i in range(m):
        # Process weight w_i: update e_k in reverse to avoid overwriting
        for k in range(min(i + 1, m), 0, -1):
            e[k] += weights[i] * e[k - 1]

    return e


def tropical_profile(weights: np.ndarray) -> np.ndarray:
    """Compute the tropical profile: k -> log(e_k(w)).

    Uses log(0) = -inf convention for zero coefficients.

    Args:
        weights: Array of nonneg weights.

    Returns:
        Array of log(e_k) for k = 0, ..., m.
    """
    e = elementary_symmetric_polynomials(weights)
    with np.errstate(divide='ignore'):
        return np.log(e)


def tropical_slopes(weights: np.ndarray) -> np.ndarray:
    """Compute the discrete slope sequence of the tropical profile.

    slope_k = tropicalProfile(k+1) - tropicalProfile(k)

    Args:
        weights: Array of nonneg weights.

    Returns:
        Array of slopes for k = 0, ..., m-1.
    """
    profile = tropical_profile(weights)
    return np.diff(profile)


def two_block_envelope(a: float, b: float, p: int, q: int) -> np.ndarray:
    """Compute the two-block tropical envelope.

    For a two-block spectrum with weights a >= b > 0 and multiplicities p, q,
    the envelope at index k is:
        log(a) * min(k, p) + log(b) * max(k - p, 0)

    This is the max-plus variational optimum: fill the higher block first.

    Args:
        a: Weight of first block (larger).
        b: Weight of second block (smaller).
        p: Multiplicity of first block.
        q: Multiplicity of second block.

    Returns:
        Array of envelope values for k = 0, ..., p+q.
    """
    N = p + q
    envelope = np.zeros(N + 1)
    log_a, log_b = log(a), log(b)
    for k in range(N + 1):
        r1 = min(k, p)
        r2 = k - r1
        envelope[k] = log_a * r1 + log_b * r2
    return envelope


def log_sum_exp_sandwich(values: np.ndarray) -> Tuple[float, float]:
    """Compute the log-sum-exp sandwich bounds.

    For values a_1, ..., a_n:
        max(a_i) <= log(sum(exp(a_i))) <= max(a_i) + log(n)

    This is the statistical-mechanical interpretation:
    the free energy is sandwiched between ground state energy and
    ground state energy + entropy.

    Args:
        values: Array of real values.

    Returns:
        Tuple (lower_bound, upper_bound) = (max, max + log(n)).
    """
    max_val = np.max(values)
    n = len(values)
    return max_val, max_val + log(n)


def log_sum_exp(values: np.ndarray) -> float:
    """Numerically stable log-sum-exp computation.

    Uses the shift trick: log(sum(exp(a_i))) = max + log(sum(exp(a_i - max))).

    Args:
        values: Array of real values.

    Returns:
        log(sum(exp(a_i))).
    """
    max_val = np.max(values)
    return max_val + log(np.sum(np.exp(values - max_val)))


def block_spectrum(blocks: List[Tuple[float, int]]) -> np.ndarray:
    """Create a spectrum array from block specifications.

    Args:
        blocks: List of (weight, multiplicity) pairs, sorted by weight descending.

    Returns:
        Array of weights with each block repeated according to multiplicity.

    Example:
        >>> block_spectrum([(3.0, 2), (1.0, 3)])
        array([3., 3., 1., 1., 1.])
    """
    parts = []
    for weight, mult in blocks:
        parts.append(np.full(mult, weight))
    return np.concatenate(parts)


def multi_block_envelope(blocks: List[Tuple[float, int]]) -> np.ndarray:
    """Compute the tropical envelope for a multi-block spectrum.

    Greedy algorithm: fill blocks from highest to lowest weight.
    The optimal occupancy at index k allocates particles to blocks
    in decreasing weight order until k particles are assigned.

    Args:
        blocks: List of (weight, multiplicity) pairs, sorted by weight descending.

    Returns:
        Array of envelope values for k = 0, ..., N.

    Time complexity: O(N * s) where s is the number of blocks.
    """
    N = sum(mult for _, mult in blocks)
    envelope = np.zeros(N + 1)

    for k in range(1, N + 1):
        remaining = k
        val = 0.0
        for weight, mult in blocks:
            alloc = min(remaining, mult)
            if alloc > 0 and weight > 0:
                val += log(weight) * alloc
            remaining -= alloc
            if remaining == 0:
                break
        envelope[k] = val

    return envelope


def admissible_count(p: int, q: int, k: int) -> int:
    """Count admissible occupancy vectors for a two-block model.

    Number of (r1, r2) with r1 + r2 = k, 0 <= r1 <= p, 0 <= r2 <= q.

    Args:
        p: Multiplicity of first block.
        q: Multiplicity of second block.
        k: Total particles to assign.

    Returns:
        Number of valid (r1, r2) pairs.
    """
    r1_min = max(0, k - q)
    r1_max = min(k, p)
    return max(0, r1_max - r1_min + 1)


def verify_newton_inequality(weights: np.ndarray) -> List[Tuple[int, float]]:
    """Verify Newton's inequality e_k^2 >= e_{k-1} * e_{k+1} numerically.

    Args:
        weights: Array of nonneg weights.

    Returns:
        List of (k, defect) pairs where defect = e_k^2 - e_{k-1}*e_{k+1}.
        All defects should be >= 0.
    """
    e = elementary_symmetric_polynomials(weights)
    m = len(weights)
    defects = []
    for k in range(1, m):
        defect = e[k] ** 2 - e[k - 1] * e[k + 1]
        defects.append((k, defect))
    return defects


if __name__ == "__main__":
    # Example: two-block spectrum
    print("=== Two-block spectrum: a=3, b=1, p=3, q=4 ===")
    spectrum = block_spectrum([(3.0, 3), (1.0, 4)])
    print(f"Spectrum: {spectrum}")

    e = elementary_symmetric_polynomials(spectrum)
    print(f"e_k values: {e}")

    profile = tropical_profile(spectrum)
    print(f"Tropical profile: {profile}")

    slopes = tropical_slopes(spectrum)
    print(f"Slopes: {slopes}")

    envelope = two_block_envelope(3.0, 1.0, 3, 4)
    print(f"Block envelope: {envelope}")

    print("\n=== Newton inequality verification ===")
    defects = verify_newton_inequality(spectrum)
    for k, d in defects:
        status = "✓" if d >= -1e-10 else "✗"
        print(f"  k={k}: e_k^2 - e_{{k-1}}*e_{{k+1}} = {d:.6f} {status}")

    print("\n=== Log-sum-exp sandwich ===")
    vals = np.array([1.0, 2.0, 3.0, 0.5])
    lb, ub = log_sum_exp_sandwich(vals)
    actual = log_sum_exp(vals)
    print(f"  max = {lb:.4f}, log-sum-exp = {actual:.4f}, max + log(n) = {ub:.4f}")
    print(f"  Sandwich verified: {lb <= actual + 1e-10 and actual <= ub + 1e-10}")
