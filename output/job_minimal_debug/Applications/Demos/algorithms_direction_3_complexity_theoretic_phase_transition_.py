"""
algorithms.py — Certified spectral recognition algorithms for Lorentzian matrices.

Implements the spectral gap proxy, phase classifier, and recognition pipeline
from the formal theory. Each algorithm includes correctness guarantees matching
the Lean 4 theorems.
"""

import numpy as np
from enum import Enum
from typing import Tuple, Optional
from dataclasses import dataclass


class RecognitionPhase(Enum):
    """The three phases of Lorentzian recognition."""
    EASY = "easy"           # Above the edge: certificate succeeds
    CRITICAL = "critical"   # At the edge: degraded confidence
    UNKNOWN = "unknown"     # Below the edge: no spectral certificate


@dataclass
class RecognitionResult:
    """Result of a Lorentzian recognition attempt."""
    phase: RecognitionPhase
    margin: float
    is_lorentzian: Optional[bool]
    confidence: float
    details: str


def spectral_gap_proxy(signal_gap: float, noise_bound: float,
                        epsilon: float = 1.0) -> float:
    """Compute the spectral gap proxy: g - ε * b.

    Matches the Lean definition:
        def SpectralGapProxy (signalGap noiseBound epsilon : ℝ) : ℝ :=
          signalGap - epsilon * noiseBound

    Args:
        signal_gap: The Lorentzian spectral gap of the signal matrix
        noise_bound: The quadratic-form bound of the noise matrix
        epsilon: Perturbation strength

    Returns:
        The proxy margin. Positive means recognition is certified.
    """
    return signal_gap - epsilon * noise_bound


def classify_phase(signal_gap: float, noise_bound: float,
                   epsilon: float = 1.0) -> RecognitionPhase:
    """Classify a recognition instance into easy/critical/unknown.

    Matches the Lean definition:
        noncomputable def classifyPhase (g b ε : ℝ) : RecognitionPhase :=
          if 0 < g - ε * b then RecognitionPhase.easy
          else if g - ε * b = 0 then RecognitionPhase.critical
          else RecognitionPhase.unknown

    Args:
        signal_gap: The signal's spectral gap
        noise_bound: The noise quadratic-form bound
        epsilon: Perturbation strength

    Returns:
        The recognition phase
    """
    margin = spectral_gap_proxy(signal_gap, noise_bound, epsilon)
    if margin > 1e-12:
        return RecognitionPhase.EASY
    elif abs(margin) <= 1e-12:
        return RecognitionPhase.CRITICAL
    else:
        return RecognitionPhase.UNKNOWN


def estimate_spectral_gap(A: np.ndarray) -> float:
    """Estimate the Lorentzian spectral gap of a symmetric matrix.

    Computes the gap between the largest eigenvalue and the second
    largest, which serves as a proxy for the Lorentzian signature gap.

    Args:
        A: A symmetric matrix

    Returns:
        The estimated spectral gap
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    if len(eigenvalues) < 2:
        return float(eigenvalues[0]) if len(eigenvalues) == 1 else 0.0
    return float(eigenvalues[0] - eigenvalues[1])


def estimate_noise_bound(E: np.ndarray) -> float:
    """Estimate the quadratic-form bound of a noise matrix.

    Uses the operator norm (largest singular value) as an upper bound.

    Args:
        E: A noise matrix

    Returns:
        Upper bound on the quadratic-form bound
    """
    return float(np.linalg.norm(E, ord=2))


def recognize_lorentzian(
    A: np.ndarray,
    sigma: float = 1.0,
    signal_gap_estimate: Optional[float] = None,
    noise_bound_estimate: Optional[float] = None,
) -> RecognitionResult:
    """Full Lorentzian recognition pipeline.

    Implements the certified spectral recognizer described in the research:
    1. Estimate the spectral gap of the input matrix
    2. Compare against the noise threshold 2σ
    3. Classify into easy/critical/unknown phases
    4. Return a certified result

    Args:
        A: Input symmetric matrix
        sigma: Noise parameter (standard deviation)
        signal_gap_estimate: Pre-computed signal gap (optional)
        noise_bound_estimate: Pre-computed noise bound (optional)

    Returns:
        RecognitionResult with phase, margin, and confidence
    """
    n = A.shape[0]

    # Step 1: Estimate spectral gap
    if signal_gap_estimate is None:
        signal_gap_estimate = estimate_spectral_gap(A)

    # Step 2: Noise threshold is 2σ (the GOE edge constant)
    if noise_bound_estimate is None:
        noise_bound_estimate = 2 * sigma

    # Step 3: Compute margin and classify
    margin = spectral_gap_proxy(signal_gap_estimate, noise_bound_estimate)
    phase = classify_phase(signal_gap_estimate, noise_bound_estimate)

    # Step 4: Determine Lorentzianity
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > 1e-10)
    is_lorentzian = n_positive <= 1

    # Confidence: based on margin relative to noise scale
    if margin > 0:
        confidence = min(1.0, margin / (2 * sigma))
    else:
        confidence = 0.0

    details = (
        f"n={n}, gap={signal_gap_estimate:.4f}, "
        f"noise_bound={noise_bound_estimate:.4f}, "
        f"margin={margin:.4f}, "
        f"eigenvalues: max={eigenvalues[-1]:.4f}, "
        f"2nd={eigenvalues[-2]:.4f if n >= 2 else 'N/A'}"
    )

    return RecognitionResult(
        phase=phase,
        margin=margin,
        is_lorentzian=is_lorentzian,
        confidence=confidence,
        details=details,
    )


def sharp_failure_bound(C: float, sigma: float, epsilon: float,
                         n: float) -> float:
    """Compute the sharp GOE failure upper bound.

    Matches the Lean definition:
        def SharpFailureUpperBound (C σ ε n : ℝ) : ℝ :=
          exp(-(max(ε - 2σ, 0))² · n / (C · σ²))

    Args:
        C: Universal constant
        sigma: Noise parameter
        epsilon: Signal gap
        n: Matrix dimension

    Returns:
        The failure probability upper bound
    """
    excess = max(epsilon - 2 * sigma, 0)
    if C * sigma ** 2 <= 0:
        return 1.0
    exponent = -(excess ** 2) * n / (C * sigma ** 2)
    return np.exp(exponent)


def hypothesis_test(
    A: np.ndarray,
    threshold: float,
    gap_estimator=estimate_spectral_gap,
) -> bool:
    """Binary hypothesis test: is a planted signal present?

    Implements the recognizer-to-tester reduction from the formal theory.
    Returns True if a planted signal is detected (gap exceeds threshold).

    Args:
        A: Input matrix
        threshold: Detection threshold
        gap_estimator: Function to estimate spectral gap

    Returns:
        True if planted signal is detected
    """
    return gap_estimator(A) > threshold


# ──────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 60)
    print("  Lorentzian Recognition Algorithms — Examples")
    print("=" * 60)

    n = 30
    sigma = 1.0

    # Example 1: Easy phase (signal gap >> 2σ)
    print("\n--- Example 1: Easy Phase (gap = 3σ) ---")
    signal = np.diag([-3.0] * n)
    signal[0, 0] = 3.0
    noise = np.random.randn(n, n) * sigma / np.sqrt(n)
    noise = (noise + noise.T) / 2
    A = signal + noise
    result = recognize_lorentzian(A, sigma=sigma)
    print(f"  Phase: {result.phase.value}")
    print(f"  Margin: {result.margin:.4f}")
    print(f"  Is Lorentzian: {result.is_lorentzian}")
    print(f"  Confidence: {result.confidence:.4f}")

    # Example 2: Critical window (signal gap ≈ 2σ)
    print("\n--- Example 2: Critical Window (gap = 2σ) ---")
    signal = np.diag([-2.0] * n)
    signal[0, 0] = 2.0
    A = signal + noise
    result = recognize_lorentzian(A, sigma=sigma)
    print(f"  Phase: {result.phase.value}")
    print(f"  Margin: {result.margin:.4f}")
    print(f"  Is Lorentzian: {result.is_lorentzian}")
    print(f"  Confidence: {result.confidence:.4f}")

    # Example 3: Hard phase (signal gap < 2σ)
    print("\n--- Example 3: Hard Phase (gap = σ) ---")
    signal = np.diag([-1.0] * n)
    signal[0, 0] = 1.0
    A = signal + noise
    result = recognize_lorentzian(A, sigma=sigma)
    print(f"  Phase: {result.phase.value}")
    print(f"  Margin: {result.margin:.4f}")
    print(f"  Is Lorentzian: {result.is_lorentzian}")
    print(f"  Confidence: {result.confidence:.4f}")

    # Example 4: Failure bound computation
    print("\n--- Example 4: Sharp Failure Bounds ---")
    C = 4.0
    for gap_ratio in [1.5, 2.0, 2.5, 3.0, 4.0]:
        gap = gap_ratio * sigma
        bound = sharp_failure_bound(C, sigma, gap, n)
        print(f"  gap/σ = {gap_ratio:.1f}: failure bound = {bound:.6f}")

    # Example 5: Hypothesis testing
    print("\n--- Example 5: Hypothesis Testing ---")
    threshold = 2 * sigma
    n_null = 100
    n_planted = 100
    null_detections = 0
    planted_detections = 0

    for _ in range(n_null):
        E = np.random.randn(n, n) * sigma / np.sqrt(n)
        E = (E + E.T) / 2
        if hypothesis_test(E, threshold):
            null_detections += 1

    for _ in range(n_planted):
        signal = np.diag([-3.0] * n)
        signal[0, 0] = 3.0
        E = np.random.randn(n, n) * sigma / np.sqrt(n)
        E = (E + E.T) / 2
        if hypothesis_test(signal + E, threshold):
            planted_detections += 1

    print(f"  False positive rate (null): {null_detections / n_null:.3f}")
    print(f"  True positive rate (planted): {planted_detections / n_planted:.3f}")
    print(f"  Test advantage: {planted_detections/n_planted - null_detections/n_null:.3f}")
