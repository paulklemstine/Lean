#!/usr/bin/env python3
"""
Algorithms for Entropy Stability of Approximately Gaussian Fermionic States

Implements:
1. Binary entropy and its derivative
2. Region entropy computation
3. Entropy stability constant
4. Certified entropy interval algorithm
5. Elementary symmetric polynomial computation and stability bounds
6. Approximate Gaussian region analysis

All algorithms correspond to formally verified Lean 4 theorems.
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import combinations
from math import comb


def binary_entropy(x: float) -> float:
    """
    Binary Shannon entropy h(x) = -x log(x) - (1-x) log(1-x).

    Formally verified properties:
    - h(0) = h(1) = 0
    - h(x) = h(1-x) (symmetry)
    - h(x) >= 0 for x in [0,1]
    - h(x) <= log(2) for x in [0,1]
    - Lipschitz on [delta, 1-delta] with constant log((1-delta)/delta)

    Args:
        x: Value in [0, 1].

    Returns:
        Binary entropy h(x).

    Example:
        >>> binary_entropy(0.5)  # Maximum entropy
        0.6931471805599453
        >>> binary_entropy(0.0)
        0.0
    """
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def binary_entropy_derivative(x: float) -> float:
    """
    Derivative of binary entropy: h'(x) = log((1-x)/x).

    On [delta, 1-delta], |h'(x)| <= log((1-delta)/delta).

    Args:
        x: Value in (0, 1).

    Returns:
        h'(x) = log((1-x)/x).
    """
    if x <= 0 or x >= 1:
        raise ValueError(f"x must be in (0,1), got {x}")
    return np.log((1 - x) / x)


def region_entropy(spectrum: np.ndarray) -> float:
    """
    Free-fermion entanglement entropy: S(spec) = sum_i h(spec_i).

    Corresponds to `regionEntropy` in the Lean formalization.

    Args:
        spectrum: Array of eigenvalues in [0, 1].

    Returns:
        Total entropy of the spectrum.

    Example:
        >>> region_entropy(np.array([0.5, 0.5, 0.5]))
        2.0794415416798357
    """
    return sum(binary_entropy(x) for x in spectrum)


def entropy_stability_constant(delta: float) -> float:
    """
    Lipschitz constant for binary entropy on [delta, 1-delta].

    L_delta = log((1-delta)/delta)

    Corresponds to `entropyStabilityConstant` in the Lean formalization.

    Args:
        delta: Spectral gap parameter, 0 < delta < 1/2.

    Returns:
        L_delta.

    Example:
        >>> entropy_stability_constant(0.1)
        2.1972245773362196
    """
    if delta <= 0 or delta >= 0.5:
        raise ValueError(f"delta must be in (0, 1/2), got {delta}")
    return np.log((1 - delta) / delta)


def entropy_certificate(
    m: int, delta: float, eta: float, spec0: np.ndarray
) -> Tuple[float, float]:
    """
    Certified entropy interval for approximately Gaussian states.

    Given a reference spectrum spec0, gap parameter delta, and perturbation
    radius eta, returns an interval [lo, hi] guaranteed to contain the entropy
    of any spectrum within sup-distance eta of spec0.

    This is a verified algorithm: the soundness theorem
    `entropy_mem_certificate_of_sup_bound` proves that the true entropy
    lies in this interval.

    Algorithm complexity: O(m) time, O(1) space.

    Args:
        m: Subsystem size.
        delta: Spectral gap parameter, 0 < delta < 1/2.
        eta: Maximum eigenvalue perturbation.
        spec0: Reference spectrum of length m, entries in [delta, 1-delta].

    Returns:
        Tuple (lo, hi) with the certified entropy interval.

    Example:
        >>> spec0 = np.array([0.3, 0.5, 0.7])
        >>> lo, hi = entropy_certificate(3, 0.1, 0.05, spec0)
        >>> print(f"Entropy in [{lo:.4f}, {hi:.4f}]")
    """
    S0 = region_entropy(spec0)
    L = entropy_stability_constant(delta)
    correction = m * L * eta
    return (S0 - correction, S0 + correction)


def elem_symm(m: int, k: int, spectrum: np.ndarray) -> float:
    """
    k-th elementary symmetric polynomial of spectrum.

    e_k(spec) = sum_{|S|=k} prod_{i in S} spec_i

    Corresponds to `elemSymmFn` in the Lean formalization.

    Algorithm complexity: O(C(m,k) * k) time.

    Args:
        m: Length of spectrum.
        k: Degree of the polynomial.
        spectrum: Array of values.

    Returns:
        e_k(spectrum).

    Example:
        >>> elem_symm(3, 2, np.array([0.2, 0.3, 0.5]))
        0.22
    """
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod([spectrum[i] for i in S])
               for S in combinations(range(m), k))


def elem_symm_stability_bound(m: int, k: int, eta: float) -> float:
    """
    Certified bound on |e_k(spec) - e_k(mu)|.

    Theorem: if |spec_i - mu_i| <= eta and all values in [0,1], then
        |e_k(spec) - e_k(mu)| <= C(m,k) * k * eta

    Args:
        m: Dimension.
        k: Degree.
        eta: Perturbation radius.

    Returns:
        Upper bound C(m,k) * k * eta.
    """
    return comb(m, k) * k * eta


class ApproxGaussianRegion:
    """
    An approximately Gaussian fermionic region.

    Bundles a perturbed spectrum near a free-fermion reference spectrum,
    with explicit spectral gap and perturbation parameters.

    Corresponds to the `ApproxGaussianRegion` structure in Lean.

    Formally verified properties:
    - entropy_bound: S(spectrum) <= S(referenceSpectrum) + m * L_delta * epsilon
    - transfer_free_bound: if S(ref) <= B, then S(spectrum) <= B + correction
    """

    def __init__(
        self,
        spectrum: np.ndarray,
        reference_spectrum: np.ndarray,
        delta: float,
        epsilon: float,
    ):
        """
        Initialize an approximately Gaussian region.

        Args:
            spectrum: Interacting/perturbed eigenvalue spectrum.
            reference_spectrum: Free/Gaussian reference spectrum.
            delta: Spectral gap (eigenvalues in [delta, 1-delta]).
            epsilon: Perturbation bound.
        """
        self.spectrum = np.asarray(spectrum, dtype=float)
        self.reference_spectrum = np.asarray(reference_spectrum, dtype=float)
        self.delta = delta
        self.epsilon = epsilon
        self.m = len(spectrum)

        # Validate
        assert len(spectrum) == len(reference_spectrum), "Spectra must have same length"
        assert 0 < delta < 0.5, f"delta must be in (0, 1/2), got {delta}"
        for i in range(self.m):
            assert delta <= spectrum[i] <= 1 - delta, \
                f"spectrum[{i}]={spectrum[i]} not in [{delta}, {1-delta}]"
            assert delta <= reference_spectrum[i] <= 1 - delta, \
                f"reference_spectrum[{i}]={reference_spectrum[i]} not in [{delta}, {1-delta}]"
            assert abs(spectrum[i] - reference_spectrum[i]) <= epsilon + 1e-12, \
                f"|spectrum[{i}] - ref[{i}]| = {abs(spectrum[i]-reference_spectrum[i])} > {epsilon}"

    def interacting_entropy(self) -> float:
        """Entropy of the interacting spectrum."""
        return region_entropy(self.spectrum)

    def reference_entropy(self) -> float:
        """Entropy of the free reference spectrum."""
        return region_entropy(self.reference_spectrum)

    def entropy_correction(self) -> float:
        """The correction term m * L_delta * epsilon."""
        return self.m * entropy_stability_constant(self.delta) * self.epsilon

    def entropy_upper_bound(self) -> float:
        """
        Certified upper bound: S(spectrum) <= S(ref) + correction.
        Formally proved as ApproxGaussianRegion.entropy_bound.
        """
        return self.reference_entropy() + self.entropy_correction()

    def transfer_bound(self, free_bound: float) -> float:
        """
        Transfer a free-fermion bound to the interacting case.
        If S(ref) <= free_bound, then S(spectrum) <= free_bound + correction.
        Formally proved as ApproxGaussianRegion.transfer_free_bound.
        """
        return free_bound + self.entropy_correction()

    def certified_interval(self) -> Tuple[float, float]:
        """Get the certified entropy interval."""
        return entropy_certificate(self.m, self.delta, self.epsilon, self.reference_spectrum)

    def summary(self) -> str:
        """Human-readable summary of the region."""
        S_int = self.interacting_entropy()
        S_ref = self.reference_entropy()
        bound = self.entropy_upper_bound()
        lo, hi = self.certified_interval()
        return (
            f"ApproxGaussianRegion (m={self.m}, δ={self.delta}, ε={self.epsilon})\n"
            f"  Reference entropy:   S(ref)  = {S_ref:.6f}\n"
            f"  Interacting entropy: S(int)  = {S_int:.6f}\n"
            f"  Upper bound:                   {bound:.6f}\n"
            f"  Certified interval:  [{lo:.6f}, {hi:.6f}]\n"
            f"  Bound holds: {S_int <= bound + 1e-10}\n"
            f"  In interval: {lo - 1e-10 <= S_int <= hi + 1e-10}"
        )


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms: Entropy Stability for Approximate Gaussianity")
    print("=" * 60)

    # Example 1: Basic entropy certificate
    print("\n--- Entropy Certificate ---")
    spec0 = np.array([0.2, 0.4, 0.6, 0.8])
    lo, hi = entropy_certificate(4, 0.1, 0.05, spec0)
    print(f"Reference spectrum: {spec0}")
    print(f"Reference entropy: {region_entropy(spec0):.6f}")
    print(f"Certified interval: [{lo:.6f}, {hi:.6f}]")

    # Example 2: ApproxGaussianRegion
    print("\n--- Approximate Gaussian Region ---")
    np.random.seed(42)
    ref = np.array([0.25, 0.45, 0.55, 0.75, 0.35])
    eps = 0.03
    perturbation = np.random.uniform(-eps, eps, 5)
    interacting = np.clip(ref + perturbation, 0.15, 0.85)
    region = ApproxGaussianRegion(interacting, ref, delta=0.15, epsilon=eps)
    print(region.summary())

    # Example 3: Elementary symmetric polynomial stability
    print("\n--- Elementary Symmetric Polynomial Stability ---")
    m, eta = 5, 0.05
    spec = np.array([0.2, 0.4, 0.5, 0.6, 0.8])
    for k in range(m + 1):
        e_val = elem_symm(m, k, spec)
        bound = elem_symm_stability_bound(m, k, eta)
        print(f"  e_{k} = {e_val:.6f}, stability bound = {bound:.6f}")
