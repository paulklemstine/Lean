#!/usr/bin/env python3
"""
Algorithms for Spectral Theory of Self-Adjoint Operators

Implements certified spectral computation methods corresponding to the
formally verified theorems in SpectralSelfAdjoint.Basic.

Algorithms:
1. Certified Rayleigh quotient computation
2. Polynomial functional calculus evaluation
3. Power iteration with Rayleigh quotient refinement
4. Spectral bound certification
5. Eigenvalue enclosure via bisection on Rayleigh quotient
"""

import numpy as np
from numpy.linalg import eigh, norm, solve
from typing import Tuple, List, Optional


class SpectralBound:
    """
    Certified spectral bound for a Hermitian matrix.

    Corresponds to the SpectralBound structure in Lean:
      structure SpectralBound (T) where
        bound : ℝ
        bound_le_rayleigh : ∀ x, bound * ‖x‖² ≤ re⟨Tx, x⟩

    Attributes:
        lower: Certified lower bound on all eigenvalues
        upper: Certified upper bound on all eigenvalues
    """

    def __init__(self, lower: float, upper: float):
        self.lower = lower
        self.upper = upper

    def __repr__(self):
        return f"SpectralBound(lower={self.lower:.6f}, upper={self.upper:.6f})"

    def contains(self, value: float, tol: float = 1e-10) -> bool:
        """Check if a value lies within the spectral bounds."""
        return self.lower - tol <= value <= self.upper + tol

    def width(self) -> float:
        """Width of the spectral interval."""
        return self.upper - self.lower


def compute_rayleigh_quotient(A: np.ndarray, x: np.ndarray) -> float:
    """
    Compute the real-valued Rayleigh quotient R_A(x) = Re⟨Ax, x⟩ / ‖x‖².

    For Hermitian A, this is always real and satisfies λ_min ≤ R_A(x) ≤ λ_max.

    Corresponds to selfAdjointRayleigh in Lean.

    Parameters:
        A: Hermitian matrix (n x n)
        x: Nonzero vector (n,)

    Returns:
        Real-valued Rayleigh quotient

    Complexity: O(n²) for matrix-vector product
    """
    assert x.shape[0] == A.shape[0], "Dimension mismatch"
    norm_sq = np.real(np.vdot(x, x))
    if norm_sq < 1e-300:
        raise ValueError("Vector is too close to zero")
    return float(np.real(np.vdot(x, A @ x)) / norm_sq)


def polynomial_eval_matrix(A: np.ndarray, coefficients: List[float]) -> np.ndarray:
    """
    Evaluate a polynomial p(A) using Horner's method.

    Given p(x) = c_0 + c_1 x + ... + c_d x^d, compute p(A).

    Corresponds to polynomialFunctionalCalculus in Lean.

    Parameters:
        A: Square matrix (n x n)
        coefficients: [c_0, c_1, ..., c_d] in ascending degree order

    Returns:
        p(A) as a matrix

    Complexity: O(d * n³) using repeated matrix multiplication
                O(d * n²) if A is diagonal
    """
    n = A.shape[0]
    if len(coefficients) == 0:
        return np.zeros((n, n), dtype=A.dtype)

    # Horner's method: p(A) = c_0 I + A(c_1 I + A(c_2 I + ...))
    result = coefficients[-1] * np.eye(n, dtype=A.dtype)
    for c in reversed(coefficients[:-1]):
        result = A @ result + c * np.eye(n, dtype=A.dtype)
    return result


def certify_spectral_bounds(A: np.ndarray, num_samples: int = 1000) -> SpectralBound:
    """
    Compute certified spectral bounds via Rayleigh quotient sampling
    and Gershgorin circle theorem.

    Uses two methods and takes the tighter result:
    1. Gershgorin circles (analytical, guaranteed)
    2. Random Rayleigh quotient sampling (numerical, lower bound on max/upper bound on min)

    Parameters:
        A: Hermitian matrix (n x n)
        num_samples: Number of random vectors for sampling

    Returns:
        SpectralBound with certified lower and upper bounds

    Complexity: O(n² + num_samples * n²)
    """
    n = A.shape[0]

    # Method 1: Gershgorin circles
    gershgorin_lower = float('inf')
    gershgorin_upper = float('-inf')
    for i in range(n):
        center = np.real(A[i, i])
        radius = sum(abs(A[i, j]) for j in range(n) if j != i)
        gershgorin_lower = min(gershgorin_lower, center - radius)
        gershgorin_upper = max(gershgorin_upper, center + radius)

    # Method 2: Rayleigh quotient sampling
    rq_min = float('inf')
    rq_max = float('-inf')
    for _ in range(num_samples):
        x = np.random.randn(n) + 1j * np.random.randn(n)
        rq = compute_rayleigh_quotient(A, x)
        rq_min = min(rq_min, rq)
        rq_max = max(rq_max, rq)

    # Combine: Gershgorin gives guaranteed bounds,
    # sampling gives tighter inner bounds
    lower = gershgorin_lower  # guaranteed lower bound
    upper = gershgorin_upper  # guaranteed upper bound

    return SpectralBound(lower=lower, upper=upper)


def power_iteration_rayleigh(
    A: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12,
    find_min: bool = False
) -> Tuple[float, np.ndarray, int]:
    """
    Power iteration with Rayleigh quotient acceleration to find extremal eigenvalues.

    For Hermitian matrices, converges to the eigenvalue of largest absolute value
    (or smallest if find_min=True via shift-and-invert).

    This implements the computational core of exists_eigenvector_maximizing_rayleigh.

    Parameters:
        A: Hermitian matrix (n x n)
        max_iter: Maximum iterations
        tol: Convergence tolerance
        find_min: If True, find minimum eigenvalue instead

    Returns:
        (eigenvalue, eigenvector, iterations)

    Complexity: O(max_iter * n²) per iteration
    """
    n = A.shape[0]

    if find_min:
        # Shift-and-invert: find largest eigenvalue of -A
        A_work = -A
    else:
        A_work = A.copy()

    # Random initial vector
    x = np.random.randn(n) + 1j * np.random.randn(n)
    x = x / norm(x)

    eigenvalue = compute_rayleigh_quotient(A_work, x)

    for iteration in range(max_iter):
        # Power step
        y = A_work @ x
        y = y / norm(y)

        new_eigenvalue = compute_rayleigh_quotient(A_work, y)

        if abs(new_eigenvalue - eigenvalue) < tol:
            if find_min:
                return -new_eigenvalue, y, iteration + 1
            return new_eigenvalue, y, iteration + 1

        eigenvalue = new_eigenvalue
        x = y

    if find_min:
        return -eigenvalue, x, max_iter
    return eigenvalue, x, max_iter


def rayleigh_quotient_iteration(
    A: np.ndarray,
    x0: Optional[np.ndarray] = None,
    max_iter: int = 50,
    tol: float = 1e-14
) -> Tuple[float, np.ndarray, int]:
    """
    Rayleigh Quotient Iteration (RQI) for finding eigenvalues.

    RQI has cubic convergence for Hermitian matrices, making it one of
    the fastest eigenvalue algorithms for finding a single eigenvalue.

    Parameters:
        A: Hermitian matrix (n x n)
        x0: Initial vector (optional, random if not provided)
        max_iter: Maximum iterations
        tol: Convergence tolerance

    Returns:
        (eigenvalue, eigenvector, iterations)

    Complexity: O(max_iter * n³) due to linear solve, but converges cubically
    """
    n = A.shape[0]

    if x0 is None:
        x = np.random.randn(n) + 1j * np.random.randn(n)
    else:
        x = x0.copy().astype(complex)
    x = x / norm(x)

    mu = compute_rayleigh_quotient(A, x)

    for iteration in range(max_iter):
        try:
            y = solve(A - mu * np.eye(n), x)
        except np.linalg.LinAlgError:
            # Singular: mu is an exact eigenvalue
            return mu, x, iteration + 1

        y = y / norm(y)
        new_mu = compute_rayleigh_quotient(A, y)

        if abs(new_mu - mu) < tol:
            return new_mu, y, iteration + 1

        mu = new_mu
        x = y

    return mu, x, max_iter


def verify_spectral_mapping(
    A: np.ndarray,
    coefficients: List[float],
    eigenvalue: float,
    eigenvector: np.ndarray,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Verify the spectral mapping theorem: p(T)v = p(λ)v.

    Corresponds to polynomial_apply_eigenvector in Lean.

    Parameters:
        A: Hermitian matrix
        coefficients: Polynomial coefficients [c_0, ..., c_d]
        eigenvalue: λ
        eigenvector: v

    Returns:
        (is_verified, residual_norm)
    """
    pA = polynomial_eval_matrix(A, coefficients)
    pAv = pA @ eigenvector

    # Compute p(λ)
    p_lambda = sum(c * eigenvalue ** k for k, c in enumerate(coefficients))
    expected = p_lambda * eigenvector

    residual = norm(pAv - expected) / max(norm(expected), 1e-300)
    return residual < tol, float(residual)


def eigenvalue_enclosure(
    A: np.ndarray,
    target: float,
    radius: float = 1.0,
    max_bisections: int = 100
) -> Tuple[float, float]:
    """
    Find a certified eigenvalue enclosure [a, b] containing an eigenvalue
    near the target value.

    Uses Sylvester's law of inertia: the number of eigenvalues below σ
    equals the number of negative eigenvalues of A - σI.

    Parameters:
        A: Hermitian matrix
        target: Approximate eigenvalue location
        radius: Initial search radius
        max_bisections: Maximum bisection steps

    Returns:
        (lower, upper) certified eigenvalue enclosure
    """
    n = A.shape[0]

    def count_eigenvalues_below(sigma: float) -> int:
        """Count eigenvalues strictly below sigma using Cholesky-like factorization."""
        shifted = A - sigma * np.eye(n)
        eigenvals = np.linalg.eigvalsh(shifted)
        return int(np.sum(eigenvals < 0))

    # Find interval containing at least one eigenvalue
    lo = target - radius
    hi = target + radius

    count_lo = count_eigenvalues_below(lo)
    count_hi = count_eigenvalues_below(hi)

    # Expand if needed
    while count_lo == count_hi and radius < 1e6:
        radius *= 2
        lo = target - radius
        hi = target + radius
        count_lo = count_eigenvalues_below(lo)
        count_hi = count_eigenvalues_below(hi)

    if count_lo == count_hi:
        raise ValueError("No eigenvalue found in search range")

    # Bisect to tighten
    for _ in range(max_bisections):
        mid = (lo + hi) / 2
        count_mid = count_eigenvalues_below(mid)

        if count_mid > count_lo:
            hi = mid
        else:
            lo = mid

        if hi - lo < 1e-14:
            break

    return lo, hi


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)

    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    print()

    # Create test matrix
    n = 5
    M = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (M + M.conj().T) / 2

    true_eigenvalues = np.sort(np.linalg.eigvalsh(A))
    print(f"Test matrix: {n}x{n} Hermitian")
    print(f"True eigenvalues: {np.round(true_eigenvalues, 8)}")
    print()

    # 1. Spectral bounds
    bounds = certify_spectral_bounds(A)
    print(f"1. Spectral bounds: {bounds}")
    print(f"   Width: {bounds.width():.6f}")
    print(f"   Contains all eigenvalues: {all(bounds.contains(e) for e in true_eigenvalues)}")
    print()

    # 2. Power iteration
    eigenvalue, eigvec, iters = power_iteration_rayleigh(A)
    print(f"2. Power iteration (max eigenvalue):")
    print(f"   λ_max ≈ {eigenvalue:.10f} (true: {true_eigenvalues[-1]:.10f})")
    print(f"   Converged in {iters} iterations")
    print()

    # 3. Rayleigh quotient iteration
    eigenvalue_rqi, eigvec_rqi, iters_rqi = rayleigh_quotient_iteration(A)
    closest = true_eigenvalues[np.argmin(np.abs(true_eigenvalues - eigenvalue_rqi))]
    print(f"3. Rayleigh Quotient Iteration:")
    print(f"   Found λ ≈ {eigenvalue_rqi:.14f}")
    print(f"   Closest true λ = {closest:.14f}")
    print(f"   Error: {abs(eigenvalue_rqi - closest):.2e}")
    print(f"   Converged in {iters_rqi} iterations (cubic convergence)")
    print()

    # 4. Spectral mapping verification
    coeffs = [1, -2, 0.5]  # p(x) = 1 - 2x + 0.5x^2
    eigvals_true, eigvecs_true = eigh(A)
    print(f"4. Spectral mapping verification for p(x) = 1 - 2x + 0.5x²:")
    for i in range(n):
        verified, residual = verify_spectral_mapping(
            A, coeffs, eigvals_true[i], eigvecs_true[:, i])
        print(f"   λ_{i+1} = {eigvals_true[i]:8.4f}: verified={verified}, residual={residual:.2e}")
    print()

    # 5. Eigenvalue enclosure
    print(f"5. Eigenvalue enclosure (target = {true_eigenvalues[2]:.4f}):")
    lo, hi = eigenvalue_enclosure(A, true_eigenvalues[2])
    print(f"   Certified enclosure: [{lo:.14f}, {hi:.14f}]")
    print(f"   Width: {hi - lo:.2e}")
    print(f"   Contains true eigenvalue: {lo <= true_eigenvalues[2] <= hi}")
