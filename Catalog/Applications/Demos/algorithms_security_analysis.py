#!/usr/bin/env python3
"""
Algorithms for Tropical Matrix Factorization and Recovery

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication (O(nmk))
2. Gauge shift generation (O(nk + km))
3. Gauge orbit sampling
4. Brute-force factorization search (for small instances)
5. Greedy tropical factorization heuristic
"""

import numpy as np
from typing import Optional, Tuple, List


def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.

    Computes (A ⊗ B)[i,j] = min_t (A[i,t] + B[t,j]).

    Time complexity: O(n * m * k)
    Space complexity: O(n * m)

    Args:
        A: Matrix of shape (n, k)
        B: Matrix of shape (k, m)

    Returns:
        Tropical product of shape (n, m)
    """
    n, k1 = A.shape
    k2, m = B.shape
    assert k1 == k2, f"Inner dimensions must match: {k1} != {k2}"

    # Vectorized: for each (i,j), compute min over t of A[i,t] + B[t,j]
    # A[:, :, None] has shape (n, k, 1), B[None, :, :] has shape (1, k, m)
    return np.min(A[:, :, np.newaxis] + B[np.newaxis, :, :], axis=1)


def gauge_shift(
    A: np.ndarray, B: np.ndarray, c: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """Generate a gauge-equivalent factorization.

    Given (A, B) with M = tropMul(A, B), returns (A', B') such that
    tropMul(A', B') = M, where A'[i,t] = A[i,t] + c[t] and B'[t,j] = B[t,j] - c[t].

    Time complexity: O(nk + km)

    Args:
        A: Matrix of shape (n, k)
        B: Matrix of shape (k, m)
        c: Shift vector of length k

    Returns:
        Tuple (A_shifted, B_shifted)
    """
    A_shifted = A + c[np.newaxis, :]
    B_shifted = B - c[:, np.newaxis]
    return A_shifted, B_shifted


def sample_gauge_orbit(
    A: np.ndarray, B: np.ndarray, num_samples: int = 100, radius: float = 10.0
) -> List[Tuple[np.ndarray, np.ndarray]]:
    """Sample random points from the gauge orbit of a factorization.

    Args:
        A: Matrix of shape (n, k)
        B: Matrix of shape (k, m)
        num_samples: Number of random gauge shifts to sample
        radius: Maximum absolute value of shift components

    Returns:
        List of (A', B') pairs, all producing the same tropical product
    """
    k = A.shape[1]
    orbit = []
    for _ in range(num_samples):
        c = np.random.uniform(-radius, radius, size=k)
        orbit.append(gauge_shift(A, B, c))
    return orbit


def verify_factorization(
    M: np.ndarray, A: np.ndarray, B: np.ndarray, tol: float = 1e-10
) -> bool:
    """Verify that tropMul(A, B) = M.

    Args:
        M: Target matrix
        A: Left factor
        B: Right factor
        tol: Tolerance for floating-point comparison

    Returns:
        True if the factorization is valid
    """
    return np.allclose(trop_mul(A, B), M, atol=tol)


def greedy_tropical_factorization(
    M: np.ndarray, k: int, max_iter: int = 1000, lr: float = 0.01
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """Greedy heuristic for approximate tropical factorization.

    Uses gradient-free optimization to find A, B such that tropMul(A, B) ≈ M.
    This is NOT guaranteed to find exact factorizations.

    Args:
        M: Target matrix of shape (n, m)
        k: Inner dimension
        max_iter: Maximum iterations
        lr: Learning rate for perturbations

    Returns:
        (A, B) if a good approximation is found, None otherwise
    """
    n, m = M.shape
    A = np.random.randn(n, k)
    B = np.random.randn(k, m)

    best_loss = np.inf
    best_A, best_B = A.copy(), B.copy()

    for iteration in range(max_iter):
        M_approx = trop_mul(A, B)
        loss = np.sum((M_approx - M) ** 2)

        if loss < best_loss:
            best_loss = loss
            best_A, best_B = A.copy(), B.copy()

        if loss < 1e-10:
            return A, B

        # Random perturbation search
        dA = np.random.randn(n, k) * lr
        dB = np.random.randn(k, m) * lr

        for sign_a in [1, -1]:
            for sign_b in [1, -1]:
                A_trial = A + sign_a * dA
                B_trial = B + sign_b * dB
                M_trial = trop_mul(A_trial, B_trial)
                trial_loss = np.sum((M_trial - M) ** 2)
                if trial_loss < loss:
                    A, B = A_trial, B_trial
                    loss = trial_loss
                    break

    if best_loss < 1e-6:
        return best_A, best_B
    return None


def gauge_orbit_diversity(
    A: np.ndarray, B: np.ndarray, num_samples: int = 100, radius: float = 5.0
) -> dict:
    """Measure the diversity of factorizations in a gauge orbit.

    Args:
        A: Matrix of shape (n, k)
        B: Matrix of shape (k, m)
        num_samples: Number of samples
        radius: Shift radius

    Returns:
        Dictionary with diversity statistics
    """
    orbit = sample_gauge_orbit(A, B, num_samples, radius)
    M = trop_mul(A, B)

    # Measure diversity of A-factors
    A_dists = []
    product_diffs = []
    for A_s, B_s in orbit:
        A_dists.append(np.linalg.norm(A_s - A, 'fro'))
        product_diffs.append(np.max(np.abs(trop_mul(A_s, B_s) - M)))

    return {
        "num_samples": num_samples,
        "shift_radius": radius,
        "mean_A_distance": np.mean(A_dists),
        "max_A_distance": np.max(A_dists),
        "max_product_difference": np.max(product_diffs),
        "all_products_identical": np.max(product_diffs) < 1e-10,
    }


def collision_entropy(k: int, R: float) -> float:
    """Compute the tropical collision entropy.

    H = k * log(2R), representing the log-volume of the gauge orbit
    in the box [-R, R]^k.

    Args:
        k: Inner dimension (= dimension of gauge group)
        R: Radius of bounding box

    Returns:
        Collision entropy in nats
    """
    return k * np.log(2 * R)


# --- Example usage ---

if __name__ == "__main__":
    print("Tropical Matrix Factorization Algorithms")
    print("=" * 50)

    # Create a factorable matrix
    n, k, m = 4, 3, 5
    A = np.random.randn(n, k)
    B = np.random.randn(k, m)
    M = trop_mul(A, B)

    print(f"\nMatrix dimensions: {n}×{k} · {k}×{m} → {n}×{m}")
    print(f"Product M:\n{M.round(3)}")

    # Gauge orbit diversity
    stats = gauge_orbit_diversity(A, B)
    print(f"\nGauge orbit statistics:")
    for key, val in stats.items():
        print(f"  {key}: {val}")

    # Collision entropy
    for R in [1, 10, 100]:
        H = collision_entropy(k, R)
        print(f"\nCollision entropy (k={k}, R={R}): H = {H:.3f} nats")
        print(f"  Equivalent key pairs in [-{R},{R}]^{k}: (2·{R})^{k} = {(2*R)**k:.0f}")
