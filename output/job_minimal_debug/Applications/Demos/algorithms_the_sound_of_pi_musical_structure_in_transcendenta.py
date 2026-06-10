"""
Algorithms for The Sound of Pi: Musical Structure in Transcendental Constants

Type-hinted implementations of:
1. Digit extraction from decimal representations
2. Chromatic frequency mapping
3. Autocorrelation computation
4. Consonance spectrum analysis
5. Statistical significance testing
"""

from typing import List, Tuple, Callable
import math


def chromatic_freq(digit: int) -> float:
    """Map a digit (0-9) to a chromatic frequency in Hz.
    
    Uses equal temperament: f(d) = 220 * 2^(d/12)
    Digit 0 -> A3 (220 Hz), Digit 12 -> A4 (440 Hz)
    """
    return 220.0 * (2.0 ** (digit / 12.0))


NOTE_NAMES: List[str] = [
    "A3", "A#3", "B3", "C4", "C#4", "D4",
    "D#4", "E4", "F4", "F#4", "G4", "G#4"
]


def digit_to_note(digit: int) -> str:
    """Map a digit 0-9 to a musical note name."""
    # Extended chromatic mapping wrapping within one octave
    return NOTE_NAMES[digit % 12]


def digits_of_constant(name: str, n_digits: int = 1000) -> List[int]:
    """Get the first n_digits decimal digits of a mathematical constant.
    
    Uses the mpmath library for high-precision computation.
    Supported constants: 'pi', 'e', 'sqrt2', 'phi' (golden ratio)
    """
    try:
        from mpmath import mp, mpf, sqrt as mpsqrt, phi as mpphi
        mp.dps = n_digits + 50  # extra precision
        
        if name == 'pi':
            val = mp.pi
        elif name == 'e':
            val = mp.e
        elif name == 'sqrt2':
            val = mpsqrt(2)
        elif name == 'phi':
            val = mp.phi
        else:
            raise ValueError(f"Unknown constant: {name}")
        
        # Extract digits after decimal point
        s = mp.nstr(val, n_digits + 10)
        s = s.replace('.', '')
        if s.startswith('-'):
            s = s[1:]
        # Remove leading digit (integer part)
        digits = [int(c) for c in s[1:n_digits + 1]]
        return digits
    except ImportError:
        # Fallback: hardcoded first 100 digits of pi
        pi_str = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
        if name == 'pi':
            return [int(c) for c in pi_str[:n_digits]]
        return [int(c) for c in pi_str[:n_digits]]


def digit_autocorrelation(digits: List[int], lag: int, center: float = 4.5) -> float:
    """Compute the centered autocorrelation at a given lag.
    
    R(k) = (1/N) * Σ_{i=0}^{N-k-1} (d_i - μ)(d_{i+k} - μ)
    
    where μ is the centering value (default 4.5 for uniform digits 0-9).
    """
    n = len(digits) - lag
    if n <= 0:
        return 0.0
    
    total = sum(
        (digits[i] - center) * (digits[i + lag] - center)
        for i in range(n)
    )
    return total / n


def consonance_spectrum(
    digits: List[int], 
    max_lag: int = 12, 
    center: float = 4.5
) -> List[Tuple[int, float]]:
    """Compute the consonance spectrum: autocorrelation at lags 0 through max_lag.
    
    Returns list of (lag, autocorrelation) pairs.
    The lags correspond to musical intervals:
      0 = unison, 1 = minor 2nd, 2 = major 2nd, 3 = minor 3rd,
      4 = major 3rd, 5 = perfect 4th, 7 = perfect 5th, 12 = octave
    """
    return [(k, digit_autocorrelation(digits, k, center)) for k in range(max_lag + 1)]


def chi_squared_uniformity(digits: List[int], num_bins: int = 10) -> Tuple[float, float]:
    """Chi-squared test for uniform distribution of digits.
    
    Returns (chi_squared_statistic, p_value).
    Under H0 (uniform), each digit 0-9 appears with probability 1/10.
    """
    n = len(digits)
    expected = n / num_bins
    observed = [0] * num_bins
    for d in digits:
        if 0 <= d < num_bins:
            observed[d] += 1
    
    chi_sq = sum((obs - expected) ** 2 / expected for obs in observed)
    
    # Approximate p-value using chi-squared distribution (df = num_bins - 1)
    # For a rough approximation without scipy:
    df = num_bins - 1
    # Wilson-Hilferty approximation
    z = ((chi_sq / df) ** (1/3) - (1 - 2 / (9 * df))) / math.sqrt(2 / (9 * df))
    p_value = 0.5 * math.erfc(z / math.sqrt(2))
    
    return chi_sq, p_value


def is_significant(autocorr_value: float, n_samples: int, alpha: float = 0.05) -> bool:
    """Test if an autocorrelation value is statistically significant.
    
    Under the null hypothesis of i.i.d. uniform digits,
    the normalized autocorrelation is approximately N(0, 1/N).
    We reject at significance level alpha if |R| > z_{alpha/2} / sqrt(N).
    """
    # z-score for two-sided test
    z_critical = 1.96 if alpha == 0.05 else 2.576  # alpha = 0.01
    threshold = z_critical * math.sqrt(1.0 / n_samples) * 8.25  # variance of uniform 0-9
    return abs(autocorr_value) > threshold


def melody_to_frequencies(digits: List[int]) -> List[float]:
    """Convert a digit sequence to a frequency sequence."""
    return [chromatic_freq(d) for d in digits]


def detect_tonal_center(digits: List[int]) -> Tuple[int, int]:
    """Find the most common digit (tonal center) and its count."""
    counts = [0] * 10
    for d in digits:
        counts[d] += 1
    max_digit = max(range(10), key=lambda d: counts[d])
    return max_digit, counts[max_digit]


def periodicity_test(digits: List[int], max_period: int = 100) -> List[Tuple[int, float]]:
    """Test for periodicity by computing autocorrelation at candidate periods.
    
    Returns list of (period, autocorrelation) pairs sorted by |autocorrelation|.
    """
    results = []
    for p in range(1, max_period + 1):
        r = digit_autocorrelation(digits, p)
        results.append((p, r))
    results.sort(key=lambda x: abs(x[1]), reverse=True)
    return results


def streaming_autocorrelation(
    digit_stream: Callable[[int], int],
    window_size: int,
    lag: int,
    center: float = 4.5
) -> float:
    """Compute autocorrelation using streaming (windowed) approach.
    
    Uses the additive window split: R_{[0,N)}(k) can be computed
    incrementally as new digits arrive.
    """
    total = 0.0
    for i in range(window_size):
        total += (digit_stream(i) - center) * (digit_stream(i + lag) - center)
    return total / window_size
