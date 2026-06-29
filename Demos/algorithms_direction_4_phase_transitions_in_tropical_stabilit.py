"""
Algorithms for Tropical Phase Transition Analysis.

Implements the core mathematical primitives:
- Exchange slack computation
- Diagonal bias
- Tropical margin (with witness extraction)
- Certified stability estimation
"""

import numpy as np
from typing import Tuple, Optional, List


def ex_slack(W: np.ndarray, i: int, j: int, k: int, l: int) -> float:
    """Exchange slack on a quadruple (i, j, k, l).

    ex_slack(W; i,j,k,l) = W[i,j] + W[k,l] - W[i,k] - W[j,l]

    Args:
        W: Symmetric matrix (n x n).
        i, j, k, l: Index quadruple.

    Returns:
        The exchange slack value.

    Example:
        >>> W = np.array([[0, 1], [1, 0]])
        >>> ex_slack(W, 0, 1, 0, 1)
        2.0
    """
    return float(W[i, j] + W[k, l] - W[i, k] - W[j, l])


def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """Diagonal exchange slack for pair (i, j).

    diag_ex_slack(W, i, j) = 2*W[i,j] - W[i,i] - W[j,j]

    This equals ex_slack(W, i, j, i, j).

    Args:
        W: Symmetric matrix (n x n).
        i, j: Distinct indices.

    Returns:
        The diagonal exchange slack.

    Example:
        >>> W = np.array([[0, 3], [3, 0]])
        >>> diag_ex_slack(W, 0, 1)
        6.0
    """
    return float(2 * W[i, j] - W[i, i] - W[j, j])


def diag_bias(W: np.ndarray) -> float:
    """Diagonal bias: min_{i≠j} (W[i,j] - (W[i,i] + W[j,j])/2).

    This is half the tropical margin.

    Args:
        W: Symmetric matrix (n x n).

    Returns:
        The diagonal bias value.

    Example:
        >>> W = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
        >>> diag_bias(W)
        1.0
    """
    n = W.shape[0]
    assert n >= 2, "Need at least 2x2 matrix"
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = W[i, j] - (W[i, i] + W[j, j]) / 2
                min_val = min(min_val, val)
    return min_val


def trop_margin(W: np.ndarray) -> float:
    """Tropical stability margin: min_{i≠j} (2*W[i,j] - W[i,i] - W[j,j]).

    This is the central order parameter. Equals 2 * diag_bias(W).

    Args:
        W: Symmetric matrix (n x n).

    Returns:
        The tropical margin.

    Example:
        >>> W = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
        >>> trop_margin(W)
        2.0
    """
    n = W.shape[0]
    assert n >= 2, "Need at least 2x2 matrix"
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                min_val = min(min_val, val)
    return min_val


def trop_margin_with_witness(W: np.ndarray) -> Tuple[float, Tuple[int, int]]:
    """Compute tropical margin with witness pair.

    Returns the margin value and the (i, j) pair that achieves it.
    Corresponds to the Lean theorem `tropMargin_witness`.

    Args:
        W: Symmetric matrix (n x n).

    Returns:
        Tuple of (margin_value, (witness_i, witness_j)).

    Example:
        >>> W = np.array([[5, 1, 2], [1, 5, 1], [2, 1, 5]])
        >>> val, (i, j) = trop_margin_with_witness(W)
        >>> val
        -8.0
        >>> 2 * W[i,j] - W[i,i] - W[j,j] == val
        True
    """
    n = W.shape[0]
    assert n >= 2, "Need at least 2x2 matrix"
    min_val = float('inf')
    witness = (0, 1)
    for i in range(n):
        for j in range(n):
            if i != j:
                val = 2 * W[i, j] - W[i, i] - W[j, j]
                if val < min_val:
                    min_val = val
                    witness = (i, j)
    return min_val, witness


def entry_sup_norm(W: np.ndarray) -> float:
    """Entry-wise sup-norm: max_{i,j} |W[i,j]|.

    Args:
        W: Matrix (n x n).

    Returns:
        The entry sup-norm.

    Example:
        >>> W = np.array([[1, -3], [2, 0]])
        >>> entry_sup_norm(W)
        3.0
    """
    return float(np.max(np.abs(W)))


def mean_model(n: int, mu_diag: float, mu_off: float) -> np.ndarray:
    """Construct the mean model matrix.

    M[i,j] = mu_diag if i==j, mu_off otherwise.

    Args:
        n: Matrix dimension.
        mu_diag: Diagonal value.
        mu_off: Off-diagonal value.

    Returns:
        n x n mean model matrix.

    Example:
        >>> mean_model(3, 0, 1)
        array([[0., 1., 1.],
               [1., 0., 1.],
               [1., 1., 0.]])
    """
    M = np.full((n, n), mu_off, dtype=float)
    np.fill_diagonal(M, mu_diag)
    return M


def certified_stability_bound(mu_diag: float, mu_off: float, epsilon: float) -> float:
    """Certified lower bound for tropical margin of perturbed mean model.

    Returns 2*(mu_off - mu_diag) - 4*epsilon.
    This is the deterministic bound from `certified_stability_bound` theorem.

    Args:
        mu_diag: Diagonal mean.
        mu_off: Off-diagonal mean.
        epsilon: Noise bound (entrySupNorm(N) ≤ epsilon).

    Returns:
        Certified lower bound on tropMargin(meanModel + N).

    Example:
        >>> certified_stability_bound(0, 1, 0.1)
        1.6
    """
    return 2 * (mu_off - mu_diag) - 4 * epsilon


def generate_symmetric_gaussian(
    n: int, mu_diag: float, mu_off: float, sigma: float,
    rng: Optional[np.random.Generator] = None
) -> np.ndarray:
    """Generate a symmetric Gaussian random matrix.

    Diagonal entries ~ N(mu_diag, sigma^2).
    Off-diagonal entries ~ N(mu_off, sigma^2), symmetrized.

    Args:
        n: Matrix dimension.
        mu_diag: Mean of diagonal entries.
        mu_off: Mean of off-diagonal entries.
        sigma: Standard deviation.
        rng: Random number generator (optional).

    Returns:
        n x n symmetric random matrix.
    """
    if rng is None:
        rng = np.random.default_rng()
    W = rng.normal(0, sigma, (n, n))
    W = (W + W.T) / np.sqrt(2)  # symmetrize, preserving variance
    mean_matrix = mean_model(n, mu_diag, mu_off)
    return mean_matrix + W


def estimate_stability_probability(
    n: int, mu_diag: float, mu_off: float, sigma: float,
    num_samples: int = 1000,
    rng: Optional[np.random.Generator] = None
) -> float:
    """Estimate P(tropMargin(W) ≥ 0) by Monte Carlo.

    Args:
        n: Matrix dimension.
        mu_diag: Diagonal mean.
        mu_off: Off-diagonal mean.
        sigma: Standard deviation.
        num_samples: Number of samples.
        rng: Random number generator (optional).

    Returns:
        Estimated probability of tropical stability.
    """
    if rng is None:
        rng = np.random.default_rng()
    count = 0
    for _ in range(num_samples):
        W = generate_symmetric_gaussian(n, mu_diag, mu_off, sigma, rng)
        if trop_margin(W) >= 0:
            count += 1
    return count / num_samples


if __name__ == "__main__":
    # Quick test
    n = 5
    M = mean_model(n, 0, 1)
    print(f"Mean model margin (n={n}): {trop_margin(M)}")
    print(f"Mean model diagBias: {diag_bias(M)}")
    print(f"2 * diagBias = {2 * diag_bias(M)}")

    val, (wi, wj) = trop_margin_with_witness(M)
    print(f"Witness: ({wi}, {wj}), value = {val}")

    print(f"\nCertified bound (ε=0.1): {certified_stability_bound(0, 1, 0.1)}")

    rng = np.random.default_rng(42)
    p = estimate_stability_probability(5, 0, 1, 0.3, 1000, rng)
    print(f"\nP(tropMargin ≥ 0) for n=5, μ_off=1, σ=0.3: {p}")
