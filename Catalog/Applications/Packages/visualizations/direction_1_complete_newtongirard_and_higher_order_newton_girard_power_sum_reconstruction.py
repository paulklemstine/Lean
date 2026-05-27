"""
algorithms.py — Verified Newton–Girard reconstruction and entropy surrogate algorithms.

Implements the algebraic machinery formalized in Lean:
  1. Elementary symmetric polynomial computation
  2. Newton–Girard power-sum reconstruction from symmetric data
  3. Polynomial entropy surrogate evaluation
  4. Spectral invariant profile management

All algorithms correspond to formally verified Lean definitions and theorems.
"""

import numpy as np
from typing import List, Tuple, Optional
from math import comb, factorial
from itertools import combinations


def elementary_symmetric(mu: np.ndarray, k: int) -> float:
    """
    Compute the k-th elementary symmetric polynomial e_k(μ).

    e_k(μ) = ∑_{|S|=k} ∏_{i∈S} μ_i

    Corresponds to `esymm'` in the Lean formalization.

    Args:
        mu: spectrum array of length m
        k: order of the symmetric polynomial (0 ≤ k ≤ m)

    Returns:
        Value of the k-th elementary symmetric polynomial.

    Examples:
        >>> elementary_symmetric(np.array([1.0, 2.0, 3.0]), 0)
        1.0
        >>> elementary_symmetric(np.array([1.0, 2.0, 3.0]), 1)
        6.0
        >>> elementary_symmetric(np.array([1.0, 2.0, 3.0]), 2)
        11.0
    """
    m = len(mu)
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod(mu[list(S)]) for S in combinations(range(m), k))


def elementary_symmetric_all(mu: np.ndarray) -> np.ndarray:
    """
    Compute all elementary symmetric polynomials e_0, e_1, ..., e_m.

    Uses the recurrence relation for efficiency.

    Args:
        mu: spectrum array of length m

    Returns:
        Array of length m+1 with e_k(μ) at index k.
    """
    m = len(mu)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for i in range(m):
        # Process mu[i] into the polynomial
        for k in range(min(i + 1, m), 0, -1):
            e[k] += mu[i] * e[k - 1]
    return e


def power_sum_direct(mu: np.ndarray, k: int) -> float:
    """
    Compute the k-th power sum p_k(μ) = ∑_i μ_i^k directly.

    Corresponds to `psum'` in the Lean formalization.

    Args:
        mu: spectrum array
        k: power sum order

    Returns:
        Value of the k-th power sum.
    """
    return np.sum(mu ** k)


def power_sum_from_esymm(esymm_data: np.ndarray, m: int, N: int) -> np.ndarray:
    """
    Reconstruct power sums p_0, p_1, ..., p_N from elementary symmetric data
    using the Newton–Girard recurrence.

    This is the core verified algorithm: given only the elementary symmetric
    profile (e_0, ..., e_m), reconstruct all power sums up to order N.

    Corresponds to `powerSumFromProfile` in the Lean formalization.
    Correctness proven by `powerSumFromProfile_correct`.

    The recurrence (Newton–Girard identity, `newton_girard_general`):
        p_k = (-1)^{k+1} · k · e_k - ∑_{j=1}^{k-1} (-1)^j · e_j · p_{k-j}

    For k > m, e_k = 0, yielding a finite linear recurrence
    (`powerSum_linear_recurrence_of_gt_card`):
        p_k = ∑_{j=0}^{m-1} (-1)^j · e_{j+1} · p_{k-1-j}

    Args:
        esymm_data: array of elementary symmetric polynomials e_0, ..., e_m
        m: number of variables (= len(esymm_data) - 1)
        N: maximum power sum order to reconstruct

    Returns:
        Array of power sums p_0, p_1, ..., p_N.

    Example:
        >>> mu = np.array([0.3, 0.5, 0.7])
        >>> e = elementary_symmetric_all(mu)
        >>> p_reconstructed = power_sum_from_esymm(e, 3, 10)
        >>> p_direct = np.array([power_sum_direct(mu, k) for k in range(11)])
        >>> np.allclose(p_reconstructed, p_direct)
        True
    """
    p = np.zeros(N + 1)
    p[0] = float(m)  # p_0 = m

    for k in range(1, N + 1):
        # e_k term (zero if k > m)
        ek = esymm_data[k] if k < len(esymm_data) else 0.0
        val = (-1) ** (k + 1) * k * ek

        # Sum over j = 1 to k-1
        for j in range(1, k):
            ej = esymm_data[j] if j < len(esymm_data) else 0.0
            val -= (-1) ** j * ej * p[k - j]

        p[k] = val

    return p


def spectral_poly_eval(coeffs: np.ndarray, mu: np.ndarray) -> float:
    """
    Evaluate a polynomial spectral functional Φ_q(μ) = ∑_i q(μ_i).

    Corresponds to `spectralPolyEval` in the Lean formalization.

    Args:
        coeffs: polynomial coefficients [c_0, c_1, ..., c_d] where q(x) = ∑ c_j x^j
        mu: spectrum array

    Returns:
        ∑_i q(μ_i)
    """
    return sum(np.polyval(coeffs[::-1], x) for x in mu)


def spectral_poly_eval_from_esymm(
    coeffs: np.ndarray, esymm_data: np.ndarray, m: int
) -> float:
    """
    Evaluate a polynomial spectral functional from elementary symmetric data alone.

    This is the key computational result: polynomial spectral observables are
    computable from symmetric invariants without diagonalization.

    Corresponds to `spectralPolyEval_from_esymm_data` in the Lean formalization.

    Args:
        coeffs: polynomial coefficients [c_0, c_1, ..., c_d]
        esymm_data: elementary symmetric polynomials e_0, ..., e_m
        m: number of variables

    Returns:
        Φ_q(μ) computed from elementary symmetric data.
    """
    d = len(coeffs) - 1
    p = power_sum_from_esymm(esymm_data, m, d)
    return sum(coeffs[j] * p[j] for j in range(d + 1))


def shannon_entropy(x: float) -> float:
    """Binary Shannon entropy h(x) = -x log(x) - (1-x) log(1-x)."""
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermion_entropy(mu: np.ndarray) -> float:
    """
    Free-fermion entanglement entropy S(μ) = ∑_i h(μ_i).

    Args:
        mu: spectrum in [0, 1]^m

    Returns:
        Total entanglement entropy.
    """
    return sum(shannon_entropy(x) for x in mu)


def chebyshev_approximation(
    f, a: float, b: float, degree: int
) -> np.ndarray:
    """
    Compute a polynomial approximation of f on [a, b] using Chebyshev interpolation.

    Returns coefficients in the monomial basis [c_0, c_1, ..., c_d].

    Args:
        f: function to approximate
        a, b: interval endpoints
        degree: polynomial degree

    Returns:
        Polynomial coefficients array.
    """
    n = degree + 1
    # Chebyshev nodes on [a, b]
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos(
        np.pi * (2 * np.arange(n) + 1) / (2 * n)
    )
    values = np.array([f(x) for x in nodes])

    # Fit polynomial through these points
    coeffs = np.polyfit(nodes, values, degree)
    # Convert from highest-degree-first to lowest-degree-first
    return coeffs[::-1]


def entropy_surrogate_from_esymm(
    esymm_data: np.ndarray, m: int, degree: int, delta: float
) -> float:
    """
    Compute an entropy surrogate from elementary symmetric data.

    This is the culmination of the algebraic pipeline:
    1. Approximate h(x) = -x log(x) - (1-x) log(1-x) by a polynomial on [δ, 1-δ]
    2. Evaluate the polynomial spectral functional from esymm data
    3. The result approximates the true entropy with error ≤ m · ε_N

    Correctness backed by `entropy_surrogate_uniform_error` and
    `entropy_surrogate_converges` in the Lean formalization.

    Args:
        esymm_data: elementary symmetric polynomials e_0, ..., e_m
        m: number of variables
        degree: polynomial approximation degree
        delta: spectral gap parameter (spectrum in [δ, 1-δ])

    Returns:
        Entropy surrogate value.
    """
    # Step 1: Polynomial approximation of entropy on [δ, 1-δ]
    coeffs = chebyshev_approximation(shannon_entropy, delta, 1 - delta, degree)

    # Step 2: Evaluate from esymm data via Newton–Girard
    return spectral_poly_eval_from_esymm(coeffs, esymm_data, m)


class SpectralInvariantProfile:
    """
    A spectral invariant profile: the algebraic fingerprint of a spectrum.

    Bundles elementary symmetric invariants with the vanishing condition.
    Corresponds to `SpectralInvariantProfile` in the Lean formalization.

    Attributes:
        m: number of variables
        esymm_data: array [e_0, e_1, ..., e_m] of elementary symmetric polynomials
    """

    def __init__(self, m: int, esymm_data: np.ndarray):
        assert len(esymm_data) == m + 1
        assert abs(esymm_data[0] - 1.0) < 1e-12, "e_0 must equal 1"
        self.m = m
        self.esymm_data = esymm_data.copy()

    @classmethod
    def from_spectrum(cls, mu: np.ndarray) -> 'SpectralInvariantProfile':
        """Construct from a concrete spectrum."""
        m = len(mu)
        e = elementary_symmetric_all(mu)
        return cls(m, e)

    def power_sums(self, N: int) -> np.ndarray:
        """Reconstruct power sums up to order N via Newton–Girard."""
        return power_sum_from_esymm(self.esymm_data, self.m, N)

    def entropy_surrogate(self, degree: int, delta: float) -> float:
        """Compute entropy surrogate at given polynomial degree."""
        return entropy_surrogate_from_esymm(
            self.esymm_data, self.m, degree, delta
        )


if __name__ == "__main__":
    # Demonstration
    np.random.seed(42)
    m = 5
    delta = 0.1
    mu = np.random.uniform(delta, 1 - delta, m)

    print(f"Spectrum μ = {mu}")
    print(f"True entropy S(μ) = {fermion_entropy(mu):.10f}")

    profile = SpectralInvariantProfile.from_spectrum(mu)
    print(f"\nElementary symmetric data: {profile.esymm_data}")

    # Verify power sum reconstruction
    print("\nPower sum verification:")
    for k in range(8):
        direct = power_sum_direct(mu, k)
        reconstructed = profile.power_sums(k)[k]
        print(f"  p_{k}: direct={direct:.10f}, reconstructed={reconstructed:.10f}, "
              f"error={abs(direct - reconstructed):.2e}")

    # Entropy surrogate convergence
    print("\nEntropy surrogate convergence:")
    true_entropy = fermion_entropy(mu)
    for deg in [2, 4, 6, 8, 10, 15, 20, 30]:
        surr = profile.entropy_surrogate(deg, delta)
        err = abs(surr - true_entropy)
        print(f"  degree {deg:3d}: surrogate={surr:.10f}, error={err:.2e}")
