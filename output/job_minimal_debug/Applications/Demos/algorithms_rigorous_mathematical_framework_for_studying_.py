"""
Algorithms for analyzing musical structure in digit sequences.

Implements the digit autocorrelation, transition spectrum, and consonance
spectrum computations described in the research paper.
"""

from typing import List, Dict, Tuple
import math


def digit_autocorrelation(digits: List[int], N: int, k: int) -> int:
    """Compute the unnormalized autocorrelation R_N(k) = Σ d(i)·d(i+k).

    Args:
        digits: The digit sequence (must have length >= N + k).
        N: Window size.
        k: Lag value.

    Returns:
        The integer autocorrelation value.
    """
    return sum(digits[i] * digits[i + k] for i in range(N))


def centered_autocorrelation(digits: List[int], N: int, k: int, center: float) -> float:
    """Compute the centered autocorrelation C_N(k, c) = Σ (d(i)-c)(d(i+k)-c).

    Args:
        digits: The digit sequence.
        N: Window size.
        k: Lag value.
        center: Center value (typically the mean, e.g., 4.5 for base-10 digits).

    Returns:
        The centered autocorrelation value.
    """
    return sum((digits[i] - center) * (digits[i + k] - center) for i in range(N))


def consonance_spectrum(digits: List[int], N: int, center: float = 4.5) -> List[float]:
    """Compute the consonance spectrum: centered autocorrelation at lags 0-12.

    The 13 lags correspond to the chromatic musical intervals:
        0 = unison, 1 = minor second, 2 = major second, 3 = minor third,
        4 = major third, 5 = perfect fourth, 6 = tritone, 7 = perfect fifth,
        8 = minor sixth, 9 = major sixth, 10 = minor seventh,
        11 = major seventh, 12 = octave.

    Args:
        digits: The digit sequence.
        N: Window size.
        center: Center value (default 4.5 for base-10 digits).

    Returns:
        List of 13 centered autocorrelation values.
    """
    return [centered_autocorrelation(digits, N, k, center) for k in range(13)]


def transition_spectrum(digits: List[int], N: int, k: int) -> Dict[int, int]:
    """Compute the digit transition spectrum at lag k.

    Returns the count of each transition value t = d(i+k) - d(i).

    Args:
        digits: The digit sequence.
        N: Window size.
        k: Lag value.

    Returns:
        Dictionary mapping transition value t -> count.
    """
    counts: Dict[int, int] = {}
    for i in range(N):
        t = digits[i + k] - digits[i]
        counts[t] = counts.get(t, 0) + 1
    return counts


def normalized_consonance_spectrum(
    digits: List[int], N: int, center: float = 4.5
) -> List[float]:
    """Compute the normalized consonance spectrum (divided by N).

    Args:
        digits: The digit sequence.
        N: Window size.
        center: Center value.

    Returns:
        List of 13 normalized centered autocorrelation values.
    """
    cs = consonance_spectrum(digits, N, center)
    return [c / N for c in cs]


def spectral_concentration(
    digits: List[int], N: int, S: List[int], K: int
) -> float:
    """Compute spectral concentration: fraction of autocorrelation energy at lags in S.

    Args:
        digits: The digit sequence.
        N: Window size.
        S: Set of lags to measure concentration at.
        K: Total number of lags to consider.

    Returns:
        Spectral concentration ratio in [0, 1].
    """
    numerator = sum(digit_autocorrelation(digits, N, k) ** 2 for k in S)
    denominator = sum(digit_autocorrelation(digits, N, k) ** 2 for k in range(K))
    return numerator / denominator if denominator > 0 else 0.0


def spectral_flatness_test(
    digits: List[int], N: int, max_lag: int = 12
) -> Tuple[float, int, int]:
    """Test the Spectral Flatness Conjecture.

    Computes the maximum deviation of transition spectra between different lags.

    Args:
        digits: The digit sequence.
        N: Window size.
        max_lag: Maximum lag to test (default 12 = octave).

    Returns:
        Tuple of (max_deviation, lag1, lag2) where the maximum deviation occurs.
    """
    spectra = {}
    for k in range(1, max_lag + 1):
        ts = transition_spectrum(digits, N, k)
        spectra[k] = {t: count / N for t, count in ts.items()}

    max_dev = 0.0
    max_k1, max_k2 = 1, 2
    for k1 in range(1, max_lag + 1):
        for k2 in range(k1 + 1, max_lag + 1):
            all_t = set(spectra[k1].keys()) | set(spectra[k2].keys())
            for t in all_t:
                dev = abs(spectra[k1].get(t, 0) - spectra[k2].get(t, 0))
                if dev > max_dev:
                    max_dev = dev
                    max_k1, max_k2 = k1, k2

    return max_dev, max_k1, max_k2


def chromatic_frequency(digit: int) -> float:
    """Map a digit to a chromatic frequency: f(d) = 220 · 2^(d/12).

    Args:
        digit: Integer digit value.

    Returns:
        Frequency in Hz.
    """
    return 220.0 * (2.0 ** (digit / 12.0))


def semitone_approximation(ratio: float) -> float:
    """Convert a frequency ratio to semitones: 12 · log₂(r).

    Args:
        ratio: Frequency ratio (must be positive).

    Returns:
        Number of semitones.
    """
    return 12.0 * math.log2(ratio)


def pythagorean_intervals(a: int, b: int, c: int) -> Dict[str, float]:
    """Extract musical intervals from a Pythagorean triple.

    Args:
        a, b, c: Pythagorean triple with a² + b² = c².

    Returns:
        Dictionary of interval names to semitone values.
    """
    assert a ** 2 + b ** 2 == c ** 2, f"({a}, {b}, {c}) is not Pythagorean"
    if a > b:
        a, b = b, a

    intervals = {
        "leg_ratio (b/a)": semitone_approximation(b / a),
        "hyp_leg_ratio (c/b)": semitone_approximation(c / b),
        "hyp_min_leg_ratio (c/a)": semitone_approximation(c / a),
    }
    return intervals
