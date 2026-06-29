"""
algorithms.py — Core algorithms for random matrix edge universality.

Implements Catalan number computation, Wigner semicircle density,
Tracy-Widom CDF approximation, and moment method spectral bounds.
"""

import numpy as np
from typing import Tuple, List


def catalan_number(n: int) -> int:
    """Compute the n-th Catalan number using the recurrence (n+2)*C_{n+1} = (4n+2)*C_n.

    Args:
        n: Non-negative integer index.

    Returns:
        The n-th Catalan number C_n.

    Examples:
        >>> [catalan_number(k) for k in range(8)]
        [1, 1, 2, 5, 14, 42, 132, 429]
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    if n == 0:
        return 1
    c = 1
    for k in range(n):
        c = c * (4 * k + 2) // (k + 2)
    return c


def catalan_ratio(n: int) -> float:
    """Compute the ratio C_{n+1}/C_n = (4n+2)/(n+2).

    This ratio converges to 4 as n → ∞, establishing the exponential
    growth rate of Catalan numbers.

    Args:
        n: Positive integer.

    Returns:
        The ratio C_{n+1}/C_n.
    """
    return (4 * n + 2) / (n + 2)


def wigner_density(x: float) -> float:
    """Evaluate the Wigner semicircle density ρ(x) = (2/π)√(1-x²).

    Args:
        x: Real number.

    Returns:
        The semicircle density at x. Zero if |x| > 1.
    """
    if abs(x) > 1:
        return 0.0
    return (2 / np.pi) * np.sqrt(1 - x**2)


def semicircle_moment(k: int) -> float:
    """Compute the k-th moment of the semicircle distribution.

    Odd moments are zero (by symmetry). Even moments equal Catalan numbers:
    m_{2k} = C_k.

    Args:
        k: Non-negative integer.

    Returns:
        The k-th moment of the semicircle distribution.
    """
    if k % 2 == 1:
        return 0.0
    return float(catalan_number(k // 2))


def generate_wigner_matrix(n: int, distribution: str = "gaussian") -> np.ndarray:
    """Generate an n×n Wigner matrix (symmetric, random entries).

    Args:
        n: Matrix dimension.
        distribution: One of "gaussian", "bernoulli", "uniform".

    Returns:
        An n×n symmetric matrix with entries scaled to have unit variance.
    """
    if distribution == "gaussian":
        A = np.random.randn(n, n) / np.sqrt(n)
    elif distribution == "bernoulli":
        A = np.random.choice([-1, 1], size=(n, n)) / np.sqrt(n)
    elif distribution == "uniform":
        A = (np.random.rand(n, n) - 0.5) * np.sqrt(12) / np.sqrt(n)
    else:
        raise ValueError(f"Unknown distribution: {distribution}")

    # Symmetrize
    return (A + A.T) / np.sqrt(2)


def largest_eigenvalue_scaled(W: np.ndarray) -> float:
    """Compute the scaled largest eigenvalue n^{2/3}(λ_max/√n - 2).

    This is the quantity that converges to the Tracy-Widom distribution.

    Args:
        W: An n×n symmetric matrix (Wigner matrix).

    Returns:
        The Tracy-Widom-scaled largest eigenvalue.
    """
    n = W.shape[0]
    eigenvalues = np.linalg.eigvalsh(W)
    lambda_max = eigenvalues[-1]
    return n**(2/3) * (lambda_max * np.sqrt(n) - 2)


def tracy_widom_cdf_approx(s: float, grid_size: int = 200,
                            grid_range: float = 10.0) -> float:
    """Approximate the Tracy-Widom CDF F₂(s) using Fredholm determinant.

    Uses a discretization of the Airy kernel on [s, s + grid_range].

    Args:
        s: The point at which to evaluate F₂.
        grid_size: Number of grid points for discretization.
        grid_range: Range of integration beyond s.

    Returns:
        Approximate value of F₂(s).
    """
    from scipy.special import airy as airy_func

    # Discretize the interval [s, s + grid_range]
    x = np.linspace(s, s + grid_range, grid_size)
    dx = x[1] - x[0]

    # Compute Airy function values
    ai_vals = np.array([airy_func(xi)[0] for xi in x])
    aip_vals = np.array([airy_func(xi)[1] for xi in x])

    # Build the Airy kernel matrix K(x_i, x_j)
    K = np.zeros((grid_size, grid_size))
    for i in range(grid_size):
        for j in range(grid_size):
            if i == j:
                K[i, j] = (aip_vals[i]**2 - x[i] * ai_vals[i]**2)
            else:
                K[i, j] = (ai_vals[i] * aip_vals[j] - aip_vals[i] * ai_vals[j]) / (x[i] - x[j])

    # Scale by grid spacing
    K *= dx

    # Fredholm determinant: det(I - K)
    return np.linalg.det(np.eye(grid_size) - K)


def moment_method_spectral_bound(A: np.ndarray, k: int = 4) -> float:
    """Upper bound on spectral radius using the moment method.

    For symmetric A: ρ(A) ≤ (tr(A^{2k}))^{1/(2k)}.

    Args:
        A: An n×n symmetric matrix.
        k: Power parameter (higher k gives tighter bound).

    Returns:
        Upper bound on the spectral radius.
    """
    Ak = np.linalg.matrix_power(A, 2 * k)
    trace_val = np.trace(Ak)
    return trace_val ** (1.0 / (2 * k))


def trace_shift_optimal(A: np.ndarray) -> Tuple[float, float]:
    """Find the optimal centering constant c that minimizes tr((A-cI)²).

    The optimal c = tr(A)/n, and the minimum value is tr(A²) - tr(A)²/n.

    Args:
        A: An n×n symmetric matrix.

    Returns:
        Tuple (optimal_c, minimum_trace_squared).
    """
    n = A.shape[0]
    trace_A = np.trace(A)
    trace_A2 = np.trace(A @ A)
    optimal_c = trace_A / n
    min_trace_sq = trace_A2 - trace_A**2 / n
    return optimal_c, min_trace_sq


def verify_catalan_ratio_bound(max_n: int = 100) -> List[Tuple[int, float, bool]]:
    """Verify that C_{n+1}/C_n < 4 for n = 1, ..., max_n.

    This is the falsifiable conjecture from the formalization.

    Args:
        max_n: Maximum n to check.

    Returns:
        List of (n, ratio, ratio < 4) tuples.
    """
    results = []
    for n in range(1, max_n + 1):
        c_n = catalan_number(n)
        c_n1 = catalan_number(n + 1)
        ratio = c_n1 / c_n
        results.append((n, ratio, ratio < 4))
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Catalan numbers:", [catalan_number(k) for k in range(10)])
    print("Catalan ratios:", [f"{catalan_ratio(k):.4f}" for k in range(1, 11)])
    print("Semicircle moments:", [semicircle_moment(k) for k in range(10)])

    # Verify recurrence
    for n in range(20):
        cn = catalan_number(n)
        cn1 = catalan_number(n + 1)
        assert (n + 2) * cn1 == (4 * n + 2) * cn, f"Recurrence failed at n={n}"
    print("Catalan recurrence verified for n = 0..19")
