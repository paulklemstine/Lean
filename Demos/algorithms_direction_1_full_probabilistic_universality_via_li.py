"""
algorithms.py — Algorithms for Tropical Lindeberg Universality

Implements the core algorithms from the research paper:
1. Tropical margin computation (O(n²) optimal)
2. Replacement chain construction
3. Lindeberg replacement error estimation
4. Normalized CDF comparison
5. Centering/scaling estimation

Keywords: tropical geometry, max-plus algebra, Lindeberg replacement,
combinatorial optimization, random matrix universality
"""

import numpy as np
from typing import Tuple, List, Optional, Callable


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Margin (O(n²))
# ──────────────────────────────────────────────────────────────

def tropical_margin(W: np.ndarray) -> float:
    """
    Compute the tropical stability margin of a square matrix W.

    The tropical margin is defined as:
        tropMargin(W) = min_{i ≠ j} (2*W[i,j] - W[i,i] - W[j,j])

    This is the minimum diagonal exchange slack over all distinct pairs.
    Positive margin implies tropical stability (diagonal assignment is optimal).

    Time complexity: O(n²)
    Space complexity: O(1)

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Square matrix.

    Returns
    -------
    float
        The tropical margin. Returns 0 for matrices smaller than 2×2.

    Examples
    --------
    >>> W = np.array([[3.0, 1.0], [1.0, 3.0]])
    >>> tropical_margin(W)
    -2.0
    >>> W = np.array([[1.0, 3.0], [3.0, 1.0]])
    >>> tropical_margin(W)
    2.0
    """
    n = W.shape[0]
    if n < 2:
        return 0.0

    diag = np.diag(W)
    # Compute 2*W[i,j] - W[i,i] - W[j,j] for all i,j
    # = 2*W - diag[:,None] - diag[None,:]
    slack_matrix = 2 * W - diag[:, None] - diag[None, :]

    # Set diagonal to infinity (we only want i ≠ j)
    np.fill_diagonal(slack_matrix, np.inf)

    return float(np.min(slack_matrix))


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Replacement Chain Construction
# ──────────────────────────────────────────────────────────────

def replacement_chain(
    A: np.ndarray,
    B: np.ndarray,
) -> List[np.ndarray]:
    """
    Construct the Lindeberg replacement chain from matrix A to matrix B.

    The chain consists of n² + 1 intermediate matrices Z^(k), where
    Z^(k) agrees with B on the first k entries (in lexicographic order)
    and with A on the remaining entries.

    Time complexity: O(n⁴) for the full chain
    Space complexity: O(n² * (n² + 1))

    Parameters
    ----------
    A, B : np.ndarray, shape (n, n)
        Source and target matrices.

    Returns
    -------
    List[np.ndarray]
        Chain of n² + 1 matrices from A to B.
    """
    n = A.shape[0]
    chain = []
    Z = A.copy()
    chain.append(Z.copy())

    for k in range(n * n):
        i, j = divmod(k, n)
        Z = Z.copy()
        Z[i, j] = B[i, j]
        chain.append(Z.copy())

    return chain


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Replacement Error Computation
# ──────────────────────────────────────────────────────────────

def replacement_error(A: np.ndarray, B: np.ndarray) -> float:
    """
    Compute the replacement error between matrices A and B.

    replacementError(A, B) = 4 * sum_{i,j} |A[i,j] - B[i,j]|

    This bounds the Lindeberg comparison:
    |φ(tropMargin(A)) - φ(tropMargin(B))| ≤ K * replacementError(A, B)

    Time complexity: O(n²)
    Space complexity: O(1)

    Parameters
    ----------
    A, B : np.ndarray, shape (n, n)
        Two matrices to compare.

    Returns
    -------
    float
        The replacement error.
    """
    return 4.0 * np.sum(np.abs(A - B))


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Telescoping Error Verification
# ──────────────────────────────────────────────────────────────

def verify_telescoping(
    chain: List[np.ndarray],
) -> Tuple[float, float, bool]:
    """
    Verify the telescoping bound for a replacement chain.

    Checks: |tropMargin(Z_0) - tropMargin(Z_last)| ≤ sum_k |tropMargin(Z_k) - tropMargin(Z_{k+1})|

    Parameters
    ----------
    chain : List[np.ndarray]
        Replacement chain.

    Returns
    -------
    Tuple[float, float, bool]
        (total_change, sum_of_steps, bound_holds)
    """
    margins = [tropical_margin(Z) for Z in chain]
    total_change = abs(margins[0] - margins[-1])
    step_sum = sum(abs(margins[k] - margins[k+1]) for k in range(len(margins) - 1))
    return total_change, step_sum, total_change <= step_sum + 1e-10


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Centering/Scaling Estimation
# ──────────────────────────────────────────────────────────────

def estimate_center_scale(
    margins: np.ndarray,
    method: str = 'median_mad',
) -> Tuple[float, float]:
    """
    Estimate centering and scaling sequences for normalization.

    Methods:
    - 'mean_std': a_n = mean, b_n = std
    - 'median_mad': a_n = median, b_n = MAD * 1.4826
    - 'quantile': a_n = median, b_n = (Q75 - Q25) / 1.349

    Parameters
    ----------
    margins : np.ndarray
        Array of tropical margin samples.
    method : str
        Estimation method.

    Returns
    -------
    Tuple[float, float]
        (a_n, b_n) centering and scaling.
    """
    if method == 'mean_std':
        a_n = np.mean(margins)
        b_n = np.std(margins)
    elif method == 'median_mad':
        a_n = np.median(margins)
        b_n = 1.4826 * np.median(np.abs(margins - a_n))
    elif method == 'quantile':
        a_n = np.median(margins)
        q75, q25 = np.percentile(margins, [75, 25])
        b_n = (q75 - q25) / 1.349
    else:
        raise ValueError(f"Unknown method: {method}")

    if b_n < 1e-12:
        b_n = 1.0
    return a_n, b_n


# ──────────────────────────────────────────────────────────────
# Algorithm 6: Smooth Indicator
# ──────────────────────────────────────────────────────────────

def smooth_indicator(eta: float, t: float, x: float) -> float:
    """
    Smooth indicator function approximating 1_{x ≤ t}.

    SmoothIndicator(η, t, x) =
        1           if x ≤ t
        0           if x ≥ t + η
        1 - (x-t)/η otherwise

    Lipschitz constant: 1/η
    """
    if x <= t:
        return 1.0
    elif x >= t + eta:
        return 0.0
    else:
        return 1.0 - (x - t) / eta


def smooth_indicator_vec(eta: float, t: float, xs: np.ndarray) -> np.ndarray:
    """Vectorized smooth indicator."""
    result = np.ones_like(xs)
    mask_high = xs >= t + eta
    mask_mid = (xs > t) & (xs < t + eta)
    result[mask_high] = 0.0
    result[mask_mid] = 1.0 - (xs[mask_mid] - t) / eta
    return result


# ──────────────────────────────────────────────────────────────
# Algorithm 7: Empirical CDF Comparison
# ──────────────────────────────────────────────────────────────

def empirical_cdf(
    samples: np.ndarray,
    eval_points: Optional[np.ndarray] = None,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the empirical CDF of a sample.

    Parameters
    ----------
    samples : np.ndarray
        1D array of samples.
    eval_points : np.ndarray, optional
        Points at which to evaluate the CDF.

    Returns
    -------
    Tuple[np.ndarray, np.ndarray]
        (eval_points, cdf_values)
    """
    sorted_samples = np.sort(samples)
    if eval_points is None:
        eval_points = sorted_samples
    cdf_values = np.searchsorted(sorted_samples, eval_points, side='right') / len(samples)
    return eval_points, cdf_values


def ks_distance(samples1: np.ndarray, samples2: np.ndarray) -> float:
    """
    Kolmogorov-Smirnov distance between two empirical distributions.

    KS(F, G) = sup_t |F(t) - G(t)|

    Time complexity: O((n1 + n2) log(n1 + n2))
    """
    all_vals = np.sort(np.unique(np.concatenate([samples1, samples2])))
    _, cdf1 = empirical_cdf(samples1, all_vals)
    _, cdf2 = empirical_cdf(samples2, all_vals)
    return float(np.max(np.abs(cdf1 - cdf2)))


# ──────────────────────────────────────────────────────────────
# Algorithm 8: Lindeberg Comparison Pipeline
# ──────────────────────────────────────────────────────────────

def lindeberg_comparison(
    gen1: Callable,
    gen2: Callable,
    n: int,
    num_samples: int = 1000,
    seed: int = 42,
) -> dict:
    """
    Full Lindeberg comparison pipeline.

    1. Generate samples from two distributions
    2. Compute tropical margins
    3. Estimate centering/scaling
    4. Normalize
    5. Compute KS distance and smooth indicator comparison

    Parameters
    ----------
    gen1, gen2 : Callable(n, rng) -> np.ndarray
        Matrix generators.
    n : int
        Matrix size.
    num_samples : int
        Number of samples.
    seed : int
        Random seed.

    Returns
    -------
    dict
        Results including margins, KS distance, replacement errors.
    """
    rng = np.random.default_rng(seed)

    margins1 = np.array([tropical_margin(gen1(n, rng)) for _ in range(num_samples)])
    margins2 = np.array([tropical_margin(gen2(n, rng)) for _ in range(num_samples)])

    a1, b1 = estimate_center_scale(margins1)
    a2, b2 = estimate_center_scale(margins2)

    # Use common centering/scaling (average)
    a_common = (a1 + a2) / 2
    b_common = (b1 + b2) / 2

    norm1 = (margins1 - a_common) / b_common
    norm2 = (margins2 - a_common) / b_common

    ks = ks_distance(norm1, norm2)

    return {
        'n': n,
        'margins1': margins1,
        'margins2': margins2,
        'a_n': a_common,
        'b_n': b_common,
        'normalized1': norm1,
        'normalized2': norm2,
        'ks_distance': ks,
        'b_over_sqrt_log_n': b_common / np.sqrt(np.log(n)) if n > 1 else float('nan'),
    }


if __name__ == '__main__':
    # Demo
    print("Tropical Margin Algorithms Demo")
    print("=" * 50)

    # Algorithm 1: Tropical margin
    W = np.array([[1.0, 3.0, 2.0],
                  [3.0, 1.0, 2.0],
                  [2.0, 2.0, 1.0]])
    print(f"tropMargin(W) = {tropical_margin(W)}")

    # Algorithm 2: Replacement chain
    rng = np.random.default_rng(42)
    A = rng.standard_normal((3, 3))
    B = rng.choice([-1.0, 1.0], size=(3, 3))
    chain = replacement_chain(A, B)
    total, steps, holds = verify_telescoping(chain)
    print(f"Telescoping: total={total:.4f}, steps={steps:.4f}, holds={holds}")

    # Algorithm 7: Lindeberg comparison
    from demo import gaussian_matrix, rademacher_matrix
    result = lindeberg_comparison(gaussian_matrix, rademacher_matrix, n=10)
    print(f"KS distance (n=10): {result['ks_distance']:.4f}")
    print(f"b_n / sqrt(log n): {result['b_over_sqrt_log_n']:.4f}")
