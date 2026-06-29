"""
Tropical Entropy Algorithms
============================

Implements the key algorithms from the tropical entropy research:

1. TropicalEntropyEstimator — O(m) entropy lower bound from spectrum
2. TropicalNewtonProfiler — Builds tropical Newton polygon from coefficients
3. AreaLawDetector — Tests whether a spectrum satisfies area-law scaling

All algorithms are based on formally verified bounds from Lean 4.

Time complexity:
    - Tropical entropy estimation: O(m) from spectrum, O(m²) from coefficient data
    - Newton profile construction: O(m²) from spectrum
    - Area-law detection: O(m) from spectrum
"""

import numpy as np
from typing import List, Tuple, Optional, NamedTuple
from dataclasses import dataclass


class EntropyBounds(NamedTuple):
    """Result of entropy estimation."""
    lower_bound: float  # tropical entropy surrogate (certified lower bound)
    exact: float        # exact fermion entropy
    upper_bound: float  # m · log(2)
    relative_gap: float # (exact - lower_bound) / exact


@dataclass
class TropicalNewtonProfile:
    """The tropical Newton polygon of a DPP generating polynomial.

    Attributes:
        log_coeffs: log(eₖ) for k = 0, ..., m
        slopes: Differences log(eₖ₊₁) - log(eₖ) (tropical roots)
        is_concave: Whether the log-coefficient sequence is concave
        concavity_deficits: 2·log(eₖ) - log(eₖ₋₁) - log(eₖ₊₁) for each k
    """
    log_coeffs: np.ndarray
    slopes: np.ndarray
    is_concave: bool
    concavity_deficits: np.ndarray

    @property
    def tropical_roots(self) -> np.ndarray:
        """Negated slopes give tropical roots in non-decreasing order."""
        return -self.slopes


def binary_entropy(x: float) -> float:
    """Binary Shannon entropy h(x) = -x·log(x) - (1-x)·log(1-x).

    >>> abs(binary_entropy(0.5) - np.log(2)) < 1e-12
    True
    >>> binary_entropy(0.0)
    0.0
    """
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def trop_min_entropy(x: float) -> float:
    """Tropical binary entropy surrogate: 2·min(x, 1-x)·log(2).

    Formally verified to satisfy:
        0 ≤ trop_min_entropy(x) ≤ binary_entropy(x) ≤ log(2)
    for all x ∈ [0, 1].

    >>> abs(trop_min_entropy(0.5) - np.log(2)) < 1e-12
    True
    >>> trop_min_entropy(0.0)
    0.0
    """
    return 2 * min(x, 1 - x) * np.log(2)


def elementary_symmetric_all(spectrum: np.ndarray) -> np.ndarray:
    """Compute all elementary symmetric polynomials e₀, e₁, ..., eₘ.

    Uses O(m²) dynamic programming.

    Args:
        spectrum: Array of m eigenvalues

    Returns:
        Array of m+1 coefficients [e₀, e₁, ..., eₘ]

    >>> es = elementary_symmetric_all(np.array([0.5, 0.3]))
    >>> abs(es[0] - 1.0) < 1e-12
    True
    >>> abs(es[1] - 0.8) < 1e-12
    True
    >>> abs(es[2] - 0.15) < 1e-12
    True
    """
    m = len(spectrum)
    dp = np.zeros(m + 1)
    dp[0] = 1.0
    for mu in spectrum:
        for j in range(min(m, len(spectrum)), 0, -1):
            dp[j] += mu * dp[j - 1]
    return dp


class TropicalEntropyEstimator:
    """Polynomial-time entropy lower bound estimator.

    Given a free-fermion spectrum μ₁, ..., μₘ ∈ [0,1], computes:
    - The exact fermion entropy S(μ) = Σᵢ h(μᵢ)
    - The tropical lower bound S_trop(μ) = Σᵢ 2·min(μᵢ, 1-μᵢ)·log(2)
    - The trivial upper bound m·log(2)

    Time complexity: O(m) from spectrum data.

    The tropical bound is formally verified (Lean 4) to satisfy:
        S_trop ≤ S ≤ m·log(2)
    with equality S_trop = S = m·log(2) at μᵢ = 1/2 for all i.
    """

    def estimate(self, spectrum: np.ndarray) -> EntropyBounds:
        """Compute entropy bounds for a given spectrum.

        Args:
            spectrum: Array of eigenvalues in [0, 1]

        Returns:
            EntropyBounds with certified lower and upper bounds

        >>> est = TropicalEntropyEstimator()
        >>> bounds = est.estimate(np.array([0.5, 0.5, 0.5]))
        >>> abs(bounds.relative_gap) < 1e-12
        True
        """
        m = len(spectrum)
        s_exact = sum(binary_entropy(mu) for mu in spectrum)
        s_trop = sum(trop_min_entropy(mu) for mu in spectrum)
        s_upper = m * np.log(2)
        rel_gap = (s_exact - s_trop) / s_exact if s_exact > 1e-15 else 0.0
        return EntropyBounds(
            lower_bound=s_trop,
            exact=s_exact,
            upper_bound=s_upper,
            relative_gap=rel_gap,
        )


class TropicalNewtonProfiler:
    """Constructs the tropical Newton polygon from spectrum data.

    Given eigenvalues μ₁, ..., μₘ, computes:
    1. Elementary symmetric polynomials e₀, ..., eₘ (O(m²))
    2. Log-coefficients log(eₖ)
    3. Slopes (tropical roots)
    4. Concavity verification

    The concavity property is equivalent to Newton's inequality
    eₖ² ≥ eₖ₋₁·eₖ₊₁, which is formally verified in Lean.
    """

    def build_profile(self, spectrum: np.ndarray) -> TropicalNewtonProfile:
        """Build the tropical Newton profile from a spectrum.

        Args:
            spectrum: Array of eigenvalues (all must be positive for
                     well-defined log-coefficients)

        Returns:
            TropicalNewtonProfile with log-coefficients and concavity data

        >>> profiler = TropicalNewtonProfiler()
        >>> profile = profiler.build_profile(np.array([0.5, 0.3, 0.2]))
        >>> profile.is_concave
        True
        """
        coeffs = elementary_symmetric_all(spectrum)
        m = len(spectrum)

        # Compute log-coefficients (handle zeros)
        log_coeffs = np.full(m + 1, -np.inf)
        for k in range(m + 1):
            if coeffs[k] > 0:
                log_coeffs[k] = np.log(coeffs[k])

        # Compute slopes
        slopes = np.diff(log_coeffs)

        # Verify concavity
        deficits = np.zeros(max(0, m - 1))
        is_concave = True
        for k in range(1, m):
            if np.isfinite(log_coeffs[k-1]) and np.isfinite(log_coeffs[k]) and np.isfinite(log_coeffs[k+1]):
                deficit = 2 * log_coeffs[k] - log_coeffs[k-1] - log_coeffs[k+1]
                deficits[k-1] = deficit
                if deficit < -1e-10:
                    is_concave = False

        return TropicalNewtonProfile(
            log_coeffs=log_coeffs,
            slopes=slopes,
            is_concave=is_concave,
            concavity_deficits=deficits,
        )


class AreaLawDetector:
    """Detects whether a spectrum satisfies area-law entropy scaling.

    A spectrum satisfies an area law if the entropy scales as O(√m)
    rather than O(m). For area-law spectra, the tropical entropy
    surrogate provides a particularly good approximation.

    Formally: S(μ) ≤ C·√m for some constant C.
    """

    def __init__(self, constant: float = 2.0):
        """Initialize with area-law constant C.

        Args:
            constant: The threshold constant C in S ≤ C·√m
        """
        self.constant = constant

    def is_area_law(self, spectrum: np.ndarray) -> Tuple[bool, float, float]:
        """Test whether the spectrum satisfies the area law.

        Args:
            spectrum: Array of eigenvalues in [0, 1]

        Returns:
            Tuple of (satisfies_area_law, entropy, threshold)

        >>> det = AreaLawDetector(constant=2.0)
        >>> # Spectrum with most eigenvalues near 0 → area law
        >>> spec = np.concatenate([np.full(97, 0.01), np.full(3, 0.5)])
        >>> satisfies, _, _ = det.is_area_law(spec)
        """
        m = len(spectrum)
        entropy = sum(binary_entropy(mu) for mu in spectrum)
        threshold = self.constant * np.sqrt(m)
        return (entropy <= threshold, entropy, threshold)

    def approximation_quality(self, spectrum: np.ndarray) -> dict:
        """Measure how well the tropical surrogate approximates entropy.

        Returns a dictionary with error metrics.
        """
        m = len(spectrum)
        s_exact = sum(binary_entropy(mu) for mu in spectrum)
        s_trop = sum(trop_min_entropy(mu) for mu in spectrum)
        is_al, _, threshold = self.is_area_law(spectrum)

        return {
            "m": m,
            "entropy": s_exact,
            "tropical_entropy": s_trop,
            "absolute_error": s_exact - s_trop,
            "relative_error": (s_exact - s_trop) / s_exact if s_exact > 1e-15 else 0,
            "satisfies_area_law": is_al,
            "area_law_threshold": threshold,
            "error_over_m": (s_exact - s_trop) / m if m > 0 else 0,
        }


def run_conjecture_test(
    sizes: List[int] = [10, 20, 50, 100],
    n_trials: int = 100,
    area_law_constant: float = 2.0,
    seed: int = 42,
) -> dict:
    """Test the tropical entropy approximation conjecture.

    Conjecture: For area-law spectra, |S - S_trop|/S = O(1/m).

    Args:
        sizes: List of spectrum sizes to test
        n_trials: Number of random trials per size
        area_law_constant: Threshold constant C
        seed: Random seed for reproducibility

    Returns:
        Dictionary mapping m → average relative error for area-law spectra
    """
    rng = np.random.RandomState(seed)
    detector = AreaLawDetector(constant=area_law_constant)
    results = {}

    for m in sizes:
        errors = []
        for _ in range(n_trials):
            # Generate area-law spectrum: most eigenvalues near 0 or 1
            n_boundary = max(1, int(np.sqrt(m)))
            spectrum = np.concatenate([
                rng.uniform(0, 0.05, m - n_boundary),
                rng.uniform(0.3, 0.7, n_boundary),
            ])
            rng.shuffle(spectrum)

            quality = detector.approximation_quality(spectrum)
            if quality["satisfies_area_law"] and quality["entropy"] > 0.01:
                errors.append(quality["relative_error"])

        results[m] = {
            "mean_relative_error": np.mean(errors) if errors else None,
            "std_relative_error": np.std(errors) if errors else None,
            "n_area_law": len(errors),
            "expected_scaling": 1.0 / m,
        }

    return results


if __name__ == "__main__":
    print("Testing tropical entropy algorithms...")

    # Test estimator
    est = TropicalEntropyEstimator()
    spec = np.array([0.5, 0.3, 0.7, 0.1, 0.9])
    bounds = est.estimate(spec)
    print(f"\nSpectrum: {spec}")
    print(f"Bounds: {bounds.lower_bound:.4f} ≤ {bounds.exact:.4f} ≤ {bounds.upper_bound:.4f}")
    print(f"Relative gap: {bounds.relative_gap:.4f}")

    # Test profiler
    profiler = TropicalNewtonProfiler()
    profile = profiler.build_profile(spec)
    print(f"\nTropical Newton profile concave: {profile.is_concave}")
    print(f"Slopes (tropical roots): {profile.slopes}")

    # Test conjecture
    print("\nConjecture test (|S - S_trop|/S vs 1/m):")
    results = run_conjecture_test()
    for m, data in results.items():
        if data["mean_relative_error"] is not None:
            print(f"  m={m:3d}: mean_rel_err={data['mean_relative_error']:.6f}, "
                  f"1/m={data['expected_scaling']:.6f}, "
                  f"ratio={data['mean_relative_error']/data['expected_scaling']:.2f}")
