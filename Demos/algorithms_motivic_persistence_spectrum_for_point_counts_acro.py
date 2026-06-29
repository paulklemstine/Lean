"""
Algorithms for Motivic Persistence Spectrum

Implements spectral reconstruction from power-sum sequences via
Hankel matrix analysis, corresponding to the formally verified
Lean theorems.

Key algorithms:
- Hankel matrix construction and rank computation
- Prony's method for spectral reconstruction
- Persistence profile computation
- Elliptic curve signal analysis
"""

import numpy as np
from numpy.linalg import matrix_rank, svd, det
from typing import List, Tuple, Optional
import itertools


def power_sum_signal(alphas: np.ndarray, r_max: int) -> np.ndarray:
    """
    Compute power-sum signal: a(r) = sum_i alpha_i^r for r = 0, ..., r_max-1.

    This is the fundamental object connecting Frobenius eigenvalues to
    point counts in arithmetic geometry.

    Parameters
    ----------
    alphas : array of spectral values (eigenvalues)
    r_max : number of terms to compute

    Returns
    -------
    Array of power sums [a(0), a(1), ..., a(r_max-1)]

    Complexity: O(m * r_max) where m = len(alphas)
    """
    m = len(alphas)
    signal = np.zeros(r_max, dtype=complex if np.iscomplexobj(alphas) else float)
    for r in range(r_max):
        signal[r] = sum(a**r for a in alphas)
    return signal


def hankel_matrix(seq: np.ndarray, n: int) -> np.ndarray:
    """
    Construct the n x n Hankel matrix H_n(a) = (a_{i+j})_{0 <= i,j < n}.

    The Hankel matrix is the central object of the persistence profile.
    Its rank encodes the spectral complexity of the underlying signal.

    Parameters
    ----------
    seq : sequence a(0), a(1), ...
    n : matrix size

    Returns
    -------
    n x n Hankel matrix

    Complexity: O(n^2)
    """
    H = np.zeros((n, n), dtype=seq.dtype)
    for i in range(n):
        for j in range(n):
            if i + j < len(seq):
                H[i, j] = seq[i + j]
    return H


def vandermonde_matrix(alphas: np.ndarray, n: int) -> np.ndarray:
    """
    Construct the n x m Vandermonde matrix V(i,j) = alpha_j^i.

    The factorization H_n = V * V^T is the algebraic engine behind
    all rank bounds (Theorem 2).

    Parameters
    ----------
    alphas : array of spectral values
    n : number of rows

    Returns
    -------
    n x m Vandermonde matrix
    """
    m = len(alphas)
    V = np.zeros((n, m), dtype=complex if np.iscomplexobj(alphas) else float)
    for i in range(n):
        for j in range(m):
            V[i, j] = alphas[j] ** i
    return V


def hankel_rank_profile(seq: np.ndarray, n_max: int, tol: float = 1e-10) -> List[int]:
    """
    Compute the Hankel rank profile: n -> rank(H_n(a)) for n = 0, ..., n_max.

    This IS the arithmetic persistence profile — the filtered invariant
    that bridges arithmetic geometry and topological data analysis.

    Parameters
    ----------
    seq : input sequence
    n_max : maximum truncation level
    tol : tolerance for numerical rank

    Returns
    -------
    List of ranks [rank(H_0), rank(H_1), ..., rank(H_n_max)]

    Complexity: O(n_max * n_max^2) for SVD at each level
    """
    profile = [0]  # rank of 0x0 matrix is 0
    for n in range(1, n_max + 1):
        H = hankel_matrix(seq, n)
        profile.append(matrix_rank(H, tol=tol))
    return profile


def arithmetic_persistence_profile(seq: np.ndarray, n_max: int,
                                    tol: float = 1e-10) -> List[int]:
    """Alias for hankel_rank_profile — the persistence profile."""
    return hankel_rank_profile(seq, n_max, tol)


def prony_reconstruct(seq: np.ndarray, m: int) -> np.ndarray:
    """
    Prony's method: reconstruct m spectral values from a power-sum sequence.

    Given a(r) = sum_i alpha_i^r for r = 0, ..., 2m-1, recover the alpha_i.
    This is the algorithmic dual of Theorem 3 (spectral identifiability).

    Algorithm:
    1. Form the m x m Hankel matrix H and the shifted Hankel matrix H'.
    2. Solve H c = -h for the recurrence coefficients.
    3. Find roots of the characteristic polynomial.

    Parameters
    ----------
    seq : power-sum sequence of length >= 2m
    m : number of spectral values to recover

    Returns
    -------
    Array of reconstructed spectral values

    Complexity: O(m^3) for linear solve + O(m^2) for root finding
    """
    if len(seq) < 2 * m:
        raise ValueError(f"Need at least {2*m} samples, got {len(seq)}")

    # Build the Hankel system
    H = np.zeros((m, m), dtype=seq.dtype)
    h = np.zeros(m, dtype=seq.dtype)
    for i in range(m):
        for j in range(m):
            H[i, j] = seq[i + j]
        h[i] = seq[i + m]

    # Solve for recurrence coefficients
    try:
        c = np.linalg.solve(H, -h)
    except np.linalg.LinAlgError:
        # Singular matrix — degenerate case
        c = np.linalg.lstsq(H, -h, rcond=None)[0]

    # Form characteristic polynomial and find roots
    # p(x) = x^m + c_{m-1}*x^{m-1} + ... + c_0
    poly_coeffs = np.zeros(m + 1, dtype=seq.dtype)
    poly_coeffs[m] = 1.0
    for i in range(m):
        poly_coeffs[i] = c[i]

    roots = np.roots(poly_coeffs[::-1])
    return roots


def verify_vandermonde_factorization(alphas: np.ndarray, n: int,
                                      tol: float = 1e-10) -> Tuple[bool, float]:
    """
    Verify the Vandermonde factorization H_n = V * V^T (Theorem 2).

    Parameters
    ----------
    alphas : spectral values
    n : matrix size
    tol : tolerance

    Returns
    -------
    (is_valid, max_error) tuple
    """
    seq = power_sum_signal(alphas, 2 * n)
    H = hankel_matrix(seq, n)
    V = vandermonde_matrix(alphas, n)
    H_reconstructed = V @ V.T
    error = np.max(np.abs(H - H_reconstructed))
    return error < tol, error


def verify_recurrence(alphas: np.ndarray, n_terms: int = 20) -> Tuple[bool, float]:
    """
    Verify that the power-sum signal satisfies the characteristic
    polynomial recurrence (Theorem 1).

    Parameters
    ----------
    alphas : spectral values
    n_terms : number of recurrence instances to check

    Returns
    -------
    (is_valid, max_residual) tuple
    """
    m = len(alphas)
    # Characteristic polynomial coefficients
    poly = np.poly(alphas)  # [1, -e1, e2, ..., (-1)^m * em]
    # np.poly gives [leading, ..., constant], we need reversed
    c = poly[::-1]  # c[k] = coefficient of x^k

    seq = power_sum_signal(alphas, n_terms + m + 1)

    max_residual = 0.0
    for n in range(n_terms):
        residual = sum(c[k] * seq[n + k] for k in range(m + 1))
        max_residual = max(max_residual, abs(residual))

    return max_residual < 1e-8, max_residual


def elliptic_middle_signal(alpha: complex, beta: complex, r_max: int) -> np.ndarray:
    """
    Compute the elliptic middle signal: a(r) = alpha^r + beta^r.

    For an elliptic curve E/F_q with Frobenius eigenvalues alpha, beta
    (satisfying alpha*beta = q), the point count is:
    |E(F_{q^r})| = q^r + 1 - alpha^r - beta^r

    Parameters
    ----------
    alpha, beta : Frobenius eigenvalues
    r_max : number of terms

    Returns
    -------
    Array of middle signal values
    """
    return np.array([alpha**r + beta**r for r in range(r_max)])


def verify_elliptic_recurrence(alpha: complex, beta: complex,
                                n_terms: int = 20) -> Tuple[bool, float]:
    """
    Verify the elliptic recurrence (Theorem 5):
    a(n+2) - (alpha+beta)*a(n+1) + alpha*beta*a(n) = 0

    Parameters
    ----------
    alpha, beta : Frobenius eigenvalues
    n_terms : number of terms to check

    Returns
    -------
    (is_valid, max_residual) tuple
    """
    s = alpha + beta
    q = alpha * beta
    sig = elliptic_middle_signal(alpha, beta, n_terms + 2)

    max_residual = 0.0
    for n in range(n_terms):
        residual = sig[n + 2] - s * sig[n + 1] + q * sig[n]
        max_residual = max(max_residual, abs(residual))

    return max_residual < 1e-8, max_residual


def spectral_identifiability_test(alpha1: np.ndarray, alpha2: np.ndarray,
                                   n_sums: int = None) -> dict:
    """
    Test spectral identifiability (Theorem 3): do matching power sums
    imply matching spectra?

    Parameters
    ----------
    alpha1, alpha2 : two spectral families
    n_sums : number of power sums to compare (default: 2*max(m1,m2))

    Returns
    -------
    Dictionary with comparison results
    """
    m1, m2 = len(alpha1), len(alpha2)
    if n_sums is None:
        n_sums = 2 * max(m1, m2)

    s1 = power_sum_signal(alpha1, n_sums)
    s2 = power_sum_signal(alpha2, n_sums)

    matching = np.allclose(s1, s2, atol=1e-10)

    # Compare characteristic polynomials
    p1 = np.sort(np.poly(alpha1))
    p2 = np.sort(np.poly(alpha2))
    same_poly = np.allclose(p1, p2, atol=1e-10) if len(p1) == len(p2) else False

    return {
        "power_sums_match": matching,
        "char_polys_match": same_poly,
        "power_sum_diffs": np.abs(s1 - s2) if len(s1) == len(s2) else None,
        "identifiability_holds": matching == same_poly
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Motivic Persistence Spectrum — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Power sum signal and Vandermonde factorization
    alphas = np.array([1.0, 2.0, 3.0])
    print("\n--- Vandermonde Factorization (Theorem 2) ---")
    print(f"Spectral values: {alphas}")
    valid, err = verify_vandermonde_factorization(alphas, 5)
    print(f"H_5 = V * V^T: valid={valid}, max_error={err:.2e}")

    # Example 2: Recurrence verification
    print("\n--- Characteristic Polynomial Recurrence (Theorem 1) ---")
    valid, res = verify_recurrence(alphas)
    print(f"Recurrence satisfied: {valid}, max_residual={res:.2e}")

    # Example 3: Prony reconstruction
    print("\n--- Prony Spectral Reconstruction ---")
    seq = power_sum_signal(alphas, 10)
    recovered = prony_reconstruct(seq, 3)
    print(f"Original: {sorted(alphas)}")
    print(f"Recovered: {sorted(np.real(recovered))}")

    # Example 4: Elliptic curve
    print("\n--- Elliptic Curve Signal (Theorem 5) ---")
    q = 7
    alpha_ec = 1 + 2j  # Example with alpha*beta = q
    beta_ec = q / alpha_ec
    valid, res = verify_elliptic_recurrence(alpha_ec, beta_ec)
    print(f"alpha*beta = {alpha_ec * beta_ec:.1f} (should be {q})")
    print(f"Recurrence valid: {valid}, residual: {res:.2e}")

    # Example 5: Persistence profile
    print("\n--- Persistence Profile ---")
    profile = hankel_rank_profile(seq, 8)
    print(f"Hankel rank profile: {profile}")
    print(f"Stabilizes at: {max(profile)} (= number of spectral values)")
