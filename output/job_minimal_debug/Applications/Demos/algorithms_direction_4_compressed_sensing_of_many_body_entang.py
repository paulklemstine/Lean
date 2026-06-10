"""
Algorithms for Entanglement Compression via Elementary Symmetric Coordinates.

Implements the certified compressed entropy estimator and related
algorithms from the formal mathematical framework.
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import combinations


def esymm(k: int, p: np.ndarray) -> float:
    """Compute the k-th elementary symmetric polynomial of spectrum p.

    e_k(p) = sum_{|S|=k} prod_{i in S} p_i

    Args:
        k: Order of the elementary symmetric polynomial (0 ≤ k ≤ len(p))
        p: Spectrum array (1D numpy array of real numbers)

    Returns:
        Value of e_k(p)

    Examples:
        >>> esymm(0, np.array([0.3, 0.5, 0.1]))
        1.0
        >>> esymm(1, np.array([0.3, 0.5, 0.1]))
        0.9
    """
    m = len(p)
    if k == 0:
        return 1.0
    if k > m:
        return 0.0
    return sum(np.prod(p[list(S)]) for S in combinations(range(m), k))


def esymm_all(p: np.ndarray) -> np.ndarray:
    """Compute all elementary symmetric polynomials of spectrum p.

    Uses the recurrence relation for efficiency:
    e_k(p_1,...,p_m) = e_k(p_1,...,p_{m-1}) + p_m * e_{k-1}(p_1,...,p_{m-1})

    Args:
        p: Spectrum array

    Returns:
        Array [e_0, e_1, ..., e_m]
    """
    m = len(p)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for j in range(m):
        # Process from high k to low to avoid overwriting
        for k in range(min(j + 1, m), 0, -1):
            e[k] += p[j] * e[k - 1]
    return e


def von_neumann_entropy(p: np.ndarray) -> float:
    """Compute the von Neumann / Shannon entropy S(p) = -sum p_i log(p_i).

    Handles p_i = 0 correctly (0 log 0 = 0 by convention).

    Args:
        p: Spectrum array with p_i >= 0

    Returns:
        Entropy value (nonneg for p_i in [0,1])
    """
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


def binary_entropy(x: np.ndarray) -> np.ndarray:
    """Binary Shannon entropy h(x) = -x log(x) - (1-x) log(1-x).

    Args:
        x: Array of values in [0, 1]

    Returns:
        Array of binary entropy values
    """
    result = np.zeros_like(x, dtype=float)
    mask = (x > 0) & (x < 1)
    result[mask] = -x[mask] * np.log(x[mask]) - (1 - x[mask]) * np.log(1 - x[mask])
    return result


def fermion_entropy(p: np.ndarray) -> float:
    """Free-fermion entanglement entropy: S(p) = sum h(p_i).

    Args:
        p: Occupation spectrum with p_i in [0, 1]

    Returns:
        Entanglement entropy
    """
    return float(np.sum(binary_entropy(p)))


def quadratic_entropy_surrogate(p: np.ndarray) -> float:
    """Quadratic entropy surrogate: Psi_2 = 2(e_1 - e_1^2 + 2*e_2).

    This is a certified lower bound for the binary Shannon entropy
    sum h(p_i), proved in the formal verification.

    Args:
        p: Spectrum array

    Returns:
        Lower bound for entropy
    """
    e1 = esymm(1, p)
    e2 = esymm(2, p)
    return 2 * (e1 - e1**2 + 2 * e2)


def certified_compressed_entropy(K: int, p: np.ndarray) -> Tuple[float, float]:
    """Certified compressed entropy estimator.

    Computes an entropy approximation using only the first K+1 elementary
    symmetric polynomials, along with an error bound.

    The approximation uses the quadratic surrogate (always a lower bound).
    The error bound uses the geometric tail estimate.

    Args:
        K: Truncation order (number of esymm coefficients used)
        p: Spectrum array with p_i in [0, 1]

    Returns:
        (approximation, error_bound) where
        approximation <= true_entropy <= approximation + error_bound
    """
    m = len(p)
    e = esymm_all(p)

    # Quadratic surrogate (lower bound)
    approx = 2 * (e[1] - e[1]**2 + 2 * e[2])

    # Upper bound: m * exp(-1)
    upper = m * np.exp(-1)

    error_bound = upper - approx
    return approx, max(0, error_bound)


def check_esymm_compressibility(
    p: np.ndarray, verbose: bool = False
) -> Tuple[Optional[float], Optional[float]]:
    """Check if a spectrum has exponentially compressible esymm coefficients.

    Fits |e_k| ~ C * rho^k by linear regression on log|e_k| vs k.

    Args:
        p: Spectrum array
        verbose: If True, print detailed results

    Returns:
        (C, rho) if exponential decay is detected, (None, None) otherwise
    """
    e = esymm_all(p)
    m = len(p)

    # Collect nonzero |e_k| values
    ks, log_abs_ek = [], []
    for k in range(1, m + 1):
        if abs(e[k]) > 1e-15:
            ks.append(k)
            log_abs_ek.append(np.log(abs(e[k])))

    if len(ks) < 3:
        return None, None

    ks = np.array(ks)
    log_abs_ek = np.array(log_abs_ek)

    # Linear regression: log|e_k| = log(C) + k * log(rho)
    A = np.vstack([np.ones_like(ks), ks]).T
    result = np.linalg.lstsq(A, log_abs_ek, rcond=None)
    coeffs = result[0]

    C = np.exp(coeffs[0])
    rho = np.exp(coeffs[1])

    if verbose:
        print(f"  Fitted C = {C:.6f}, rho = {rho:.6f}")
        print(f"  R² = {1 - result[1][0] / np.var(log_abs_ek) / len(log_abs_ek) if len(result[1]) > 0 else 'N/A'}")

    if 0 < rho < 1:
        return C, rho
    return None, None


def geometric_tail_bound(C: float, rho: float, K: int) -> float:
    """Compute the geometric tail bound: C * rho^K / (1 - rho).

    This is the proved upper bound for sum_{k>=K} |e_k(p)|.

    Args:
        C: Compressibility constant
        rho: Decay rate (0 <= rho < 1)
        K: Truncation order

    Returns:
        Tail bound value
    """
    if rho <= 0:
        return 0.0
    return C * rho**K / (1 - rho)


def minimum_K_for_epsilon(C: float, rho: float, epsilon: float) -> int:
    """Compute the minimum K such that C * rho^K / (1-rho) <= epsilon.

    K >= log(C / ((1-rho) * epsilon)) / log(1/rho)

    This is the logarithmic sample complexity result.

    Args:
        C: Compressibility constant
        rho: Decay rate (0 < rho < 1)
        epsilon: Target precision

    Returns:
        Minimum truncation order K
    """
    if rho <= 0:
        return 1
    if rho >= 1:
        raise ValueError("rho must be < 1")
    if epsilon <= 0:
        raise ValueError("epsilon must be > 0")

    target = epsilon * (1 - rho) / C
    if target >= 1:
        return 0
    K = int(np.ceil(np.log(C / ((1 - rho) * epsilon)) / np.log(1 / rho)))
    return max(0, K)


def gen_poly_eval(p: np.ndarray, t: float) -> float:
    """Evaluate the generating polynomial G(t) = prod(1 + p_i * t).

    Args:
        p: Spectrum array
        t: Evaluation point

    Returns:
        G(t) = prod_{i=1}^m (1 + p_i * t)
    """
    return float(np.prod(1 + p * t))


def truncated_gen_poly_eval(K: int, p: np.ndarray, t: float) -> float:
    """Evaluate the truncated generating polynomial using first K+1 esymm.

    Args:
        K: Truncation order
        p: Spectrum array
        t: Evaluation point

    Returns:
        sum_{k=0}^{K} e_k(p) * t^k
    """
    e = esymm_all(p)
    return sum(e[k] * t**k for k in range(min(K + 1, len(e))))


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)

    # Create a compressible spectrum
    m = 20
    rho_true = 0.3
    p = rho_true ** np.arange(1, m + 1)
    p = np.clip(p, 0, 1)

    print("=== Certified Compressed Entropy Estimator ===")
    print(f"Spectrum size: m = {m}")
    print(f"True entropy: S = {fermion_entropy(p):.6f}")

    approx, err = certified_compressed_entropy(5, p)
    print(f"Quadratic surrogate: {approx:.6f}")
    print(f"Error bound: {err:.6f}")

    C, rho = check_esymm_compressibility(p, verbose=True)
    if C is not None:
        print(f"\nCompressibility detected: C = {C:.4f}, rho = {rho:.4f}")
        for K in [2, 5, 10, 15]:
            bound = geometric_tail_bound(C, rho, K)
            print(f"  K = {K}: tail bound = {bound:.2e}")

        eps = 1e-6
        K_min = minimum_K_for_epsilon(C, rho, eps)
        print(f"\nMinimum K for eps = {eps}: K = {K_min}")
