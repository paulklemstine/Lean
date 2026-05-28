"""
Algorithms for Tropical Symmetric Margin computation.

Implements the core mathematical objects from the formal Lean development:
- Pair slack computation
- Tropical symmetric margin (minimum pair slack)
- Pair replacement distance
- Lipschitz stability verification
- Telescoping replacement bounds
"""

import numpy as np
from typing import Tuple, List, Optional


def pair_slack(W: np.ndarray, i: int, j: int) -> float:
    """Compute the pair slack (edge defect) for indices i, j.

    pair_slack(W, i, j) = W[i,i] + W[j,j] - 2*W[i,j]

    This is the fundamental 3-coordinate observable governing tropical
    diagonal dominance. For Gram matrices, it equals ||x_i - x_j||^2.

    Args:
        W: Square matrix (n x n)
        i, j: Row/column indices

    Returns:
        The pair slack value

    Example:
        >>> W = np.array([[3.0, 1.0], [1.0, 2.0]])
        >>> pair_slack(W, 0, 1)
        3.0
    """
    return W[i, i] + W[j, j] - 2 * W[i, j]


def trop_sym_margin(W: np.ndarray) -> float:
    """Compute the tropical symmetric margin of a matrix.

    tropSymMargin(W) = min_{i<j} (W[i,i] + W[j,j] - 2*W[i,j])

    Time complexity: O(n^2)
    Space complexity: O(1) beyond input

    Args:
        W: Square matrix (n x n), typically symmetric

    Returns:
        The tropical symmetric margin (minimum pair slack)

    Example:
        >>> W = np.array([[3.0, 1.0], [1.0, 2.0]])
        >>> trop_sym_margin(W)
        3.0
    """
    n = W.shape[0]
    if n < 2:
        return 0.0
    margin = float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            slack = W[i, i] + W[j, j] - 2 * W[i, j]
            margin = min(margin, slack)
    return margin


def trop_sym_margin_with_witness(W: np.ndarray) -> Tuple[float, int, int]:
    """Compute tropical symmetric margin and return the minimizing pair.

    Args:
        W: Square matrix (n x n)

    Returns:
        (margin_value, i_min, j_min) where i_min < j_min

    Example:
        >>> W = np.array([[3.0, 1.0, 0.5], [1.0, 2.0, 0.0], [0.5, 0.0, 1.0]])
        >>> val, i, j = trop_sym_margin_with_witness(W)
    """
    n = W.shape[0]
    if n < 2:
        return 0.0, 0, 0
    margin = float('inf')
    i_min, j_min = 0, 1
    for i in range(n):
        for j in range(i + 1, n):
            slack = W[i, i] + W[j, j] - 2 * W[i, j]
            if slack < margin:
                margin = slack
                i_min, j_min = i, j
    return margin, i_min, j_min


def pair_replacement_dist(W: np.ndarray, W_prime: np.ndarray) -> float:
    """Compute the pair replacement distance (entrywise sup-norm).

    d_pair(W, W') = max_{i,j} |W[i,j] - W'[i,j]|

    Args:
        W, W_prime: Square matrices of the same size

    Returns:
        The pair replacement distance

    Example:
        >>> W = np.eye(3)
        >>> W2 = np.eye(3) + 0.1
        >>> pair_replacement_dist(W, W2)
        0.1
    """
    return np.max(np.abs(W - W_prime))


def verify_lipschitz_bound(W: np.ndarray, W_prime: np.ndarray) -> dict:
    """Verify the 4-Lipschitz bound for tropical symmetric margin.

    Checks: |tropSymMargin(W) - tropSymMargin(W')| <= 4 * d_pair(W, W')

    This is the computational counterpart of the formally verified theorem
    `tropSymMargin_lipschitz`.

    Args:
        W, W_prime: Square matrices of the same size

    Returns:
        Dictionary with margin values, distance, bound, and verification status
    """
    m1 = trop_sym_margin(W)
    m2 = trop_sym_margin(W_prime)
    d = pair_replacement_dist(W, W_prime)
    margin_diff = abs(m1 - m2)
    bound = 4 * d

    return {
        'margin_W': m1,
        'margin_W_prime': m2,
        'margin_diff': margin_diff,
        'pair_dist': d,
        'lipschitz_bound': bound,
        'bound_satisfied': margin_diff <= bound + 1e-12,
        'tightness_ratio': margin_diff / bound if bound > 0 else 0.0
    }


def generate_symmetric_gaussian(n: int, rng=None) -> np.ndarray:
    """Generate a symmetric Gaussian (Wigner-type) random matrix.

    Upper triangle entries are i.i.d. N(0,1), symmetrized.
    Diagonal entries are i.i.d. N(0,1).

    Args:
        n: Matrix dimension
        rng: numpy random generator (optional)

    Returns:
        Symmetric n x n matrix
    """
    if rng is None:
        rng = np.random.default_rng()
    A = rng.standard_normal((n, n))
    return (A + A.T) / np.sqrt(2)


def generate_symmetric_rademacher(n: int, rng=None) -> np.ndarray:
    """Generate a symmetric Rademacher random matrix.

    Upper triangle entries are i.i.d. ±1 uniform, symmetrized.

    Args:
        n: Matrix dimension
        rng: numpy random generator (optional)

    Returns:
        Symmetric n x n matrix with entries ±1
    """
    if rng is None:
        rng = np.random.default_rng()
    A = 2 * rng.integers(0, 2, size=(n, n)) - 1
    A = A.astype(float)
    W = np.triu(A) + np.triu(A, 1).T
    return W


def generate_symmetric_uniform(n: int, rng=None) -> np.ndarray:
    """Generate a symmetric uniform random matrix (variance-matched).

    Upper triangle entries are i.i.d. Uniform(-sqrt(3), sqrt(3)),
    which gives mean 0 and variance 1.

    Args:
        n: Matrix dimension
        rng: numpy random generator (optional)

    Returns:
        Symmetric n x n matrix
    """
    if rng is None:
        rng = np.random.default_rng()
    scale = np.sqrt(3.0)
    A = rng.uniform(-scale, scale, size=(n, n))
    return (A + A.T) / np.sqrt(2)


def empirical_survival_curve(
    n: int,
    ensemble: str,
    num_trials: int = 10000,
    thresholds: Optional[np.ndarray] = None,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray]:
    """Estimate the empirical survival curve P(tropSymMargin >= t).

    Args:
        n: Matrix dimension
        ensemble: One of 'gaussian', 'rademacher', 'uniform'
        num_trials: Number of Monte Carlo samples
        thresholds: Array of threshold values (auto-computed if None)
        seed: Random seed

    Returns:
        (thresholds, survival_probabilities)
    """
    rng = np.random.default_rng(seed)
    generators = {
        'gaussian': generate_symmetric_gaussian,
        'rademacher': generate_symmetric_rademacher,
        'uniform': generate_symmetric_uniform,
    }
    gen = generators[ensemble]

    margins = np.array([trop_sym_margin(gen(n, rng)) for _ in range(num_trials)])

    if thresholds is None:
        thresholds = np.linspace(np.min(margins) - 1, np.max(margins) + 1, 200)

    survival = np.array([np.mean(margins >= t) for t in thresholds])
    return thresholds, survival


def rescaled_survival_curve(
    n: int,
    ensemble: str,
    num_trials: int = 10000,
    a_n: Optional[float] = None,
    b_n: Optional[float] = None,
    rescaled_thresholds: Optional[np.ndarray] = None,
    seed: int = 42
) -> Tuple[np.ndarray, np.ndarray, float, float]:
    """Estimate rescaled survival curve P((tropSymMargin - a_n)/b_n >= t).

    Uses √(log n) scaling as predicted by the universality conjecture.

    Args:
        n: Matrix dimension
        ensemble: One of 'gaussian', 'rademacher', 'uniform'
        num_trials: Number of samples
        a_n: Centering constant (estimated from data if None)
        b_n: Scaling constant (uses sqrt(log n) if None)
        rescaled_thresholds: Threshold values for rescaled variable
        seed: Random seed

    Returns:
        (rescaled_thresholds, survival_probs, a_n_used, b_n_used)
    """
    rng = np.random.default_rng(seed)
    generators = {
        'gaussian': generate_symmetric_gaussian,
        'rademacher': generate_symmetric_rademacher,
        'uniform': generate_symmetric_uniform,
    }
    gen = generators[ensemble]

    margins = np.array([trop_sym_margin(gen(n, rng)) for _ in range(num_trials)])

    if b_n is None:
        b_n = np.sqrt(np.log(n))
    if a_n is None:
        a_n = np.median(margins)

    rescaled = (margins - a_n) / b_n

    if rescaled_thresholds is None:
        rescaled_thresholds = np.linspace(-4, 4, 200)

    survival = np.array([np.mean(rescaled >= t) for t in rescaled_thresholds])
    return rescaled_thresholds, survival, a_n, b_n


def telescoping_bound(chain: List[np.ndarray]) -> dict:
    """Compute and verify the telescoping bound for a chain of matrices.

    For W^(0), ..., W^(m), verifies:
    |tropSymMargin(W^0) - tropSymMargin(W^m)| <= sum_k |tropSymMargin(W^k) - tropSymMargin(W^(k+1))|

    Also verifies the Lipschitz-enhanced bound using pairReplacementDist.

    Args:
        chain: List of matrices forming a replacement chain

    Returns:
        Dictionary with bound values and verification
    """
    m = len(chain) - 1
    if m < 1:
        return {'error': 'Need at least 2 matrices'}

    margins = [trop_sym_margin(W) for W in chain]
    total_diff = abs(margins[0] - margins[-1])

    step_diffs = [abs(margins[k] - margins[k+1]) for k in range(m)]
    telescoping_sum = sum(step_diffs)

    step_dists = [pair_replacement_dist(chain[k], chain[k+1]) for k in range(m)]
    lipschitz_sum = sum(4 * d for d in step_dists)

    return {
        'total_margin_diff': total_diff,
        'telescoping_sum': telescoping_sum,
        'lipschitz_sum': lipschitz_sum,
        'telescoping_holds': total_diff <= telescoping_sum + 1e-12,
        'lipschitz_holds': total_diff <= lipschitz_sum + 1e-12,
        'num_steps': m,
        'margins': margins,
    }


if __name__ == '__main__':
    print("=== Tropical Symmetric Margin Algorithms ===\n")

    # Example 1: Basic computation
    W = np.array([[3.0, 1.0, 0.5],
                   [1.0, 2.0, 0.0],
                   [0.5, 0.0, 1.0]])
    margin, i, j = trop_sym_margin_with_witness(W)
    print(f"Matrix W:\n{W}")
    print(f"Tropical symmetric margin: {margin}")
    print(f"Minimizing pair: ({i}, {j})")
    print(f"Pair slack at ({i},{j}): {pair_slack(W, i, j)}\n")

    # Example 2: Lipschitz verification
    rng = np.random.default_rng(42)
    n = 5
    W1 = generate_symmetric_gaussian(n, rng)
    W2 = W1 + 0.1 * generate_symmetric_gaussian(n, rng)
    result = verify_lipschitz_bound(W1, W2)
    print(f"Lipschitz verification (n={n}):")
    print(f"  |margin diff| = {result['margin_diff']:.6f}")
    print(f"  4 * d_pair = {result['lipschitz_bound']:.6f}")
    print(f"  Bound satisfied: {result['bound_satisfied']}")
    print(f"  Tightness ratio: {result['tightness_ratio']:.4f}\n")

    # Example 3: Telescoping
    chain = [generate_symmetric_gaussian(4, rng) for _ in range(6)]
    tel = telescoping_bound(chain)
    print(f"Telescoping bound ({tel['num_steps']} steps):")
    print(f"  Total diff: {tel['total_margin_diff']:.6f}")
    print(f"  Telescoping sum: {tel['telescoping_sum']:.6f}")
    print(f"  Lipschitz sum: {tel['lipschitz_sum']:.6f}")
    print(f"  Telescoping holds: {tel['telescoping_holds']}")
    print(f"  Lipschitz holds: {tel['lipschitz_holds']}")
