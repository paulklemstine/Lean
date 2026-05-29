"""
Benford Renormalization: Core Algorithms

Implements the computational pipeline for analyzing Benford behavior
of integer dynamical systems. Provides certified leading-digit extraction,
empirical frequency computation, and spectral obstruction detection.

All algorithms are mathematically connected to the formally verified
definitions in the Lean development.
"""

import math
from typing import Callable, Dict, List, Tuple, Optional
from collections import Counter


def leading_digit_base(b: int, n: int) -> int:
    """
    Extract the leading (most significant) digit of n in base b.

    Matches the formal definition `BenfordRenormalization.leadingDigitBase`.
    For b >= 2 and n >= 1, returns a value in {1, ..., b-1}.

    Parameters
    ----------
    b : int
        The base (must be >= 2).
    n : int
        The number (must be >= 1 for meaningful output).

    Returns
    -------
    int
        The leading digit.

    Examples
    --------
    >>> leading_digit_base(10, 314)
    3
    >>> leading_digit_base(10, 1000)
    1
    >>> leading_digit_base(2, 7)
    1
    """
    if b <= 1:
        return n
    while n >= b:
        n = n // b
    return n


def benford_theoretical(b: int, d: int) -> float:
    """
    The Benford-law predicted frequency for digit d in base b.

    Returns log_b(1 + 1/d) = log(1 + 1/d) / log(b).

    Matches the formal definition `BenfordRenormalization.benfordTheoretical`.

    Parameters
    ----------
    b : int
        The base (>= 2).
    d : int
        The digit (1 <= d < b).

    Returns
    -------
    float
        The predicted frequency.
    """
    return math.log(1 + 1 / d) / math.log(b)


def benford_freq_up_to(b: int, d: int, sequence: List[int], N: int) -> float:
    """
    Empirical leading-digit frequency for digit d over the first N terms.

    Matches the formal definition `BenfordRenormalization.benfordFreqUpTo`.

    Parameters
    ----------
    b : int
        The base.
    d : int
        The target digit.
    sequence : list of int
        The sequence values.
    N : int
        Number of terms to consider.

    Returns
    -------
    float
        The fraction of terms with leading digit d.
    """
    if N == 0:
        return 0.0
    count = sum(1 for k in range(min(N, len(sequence)))
                if leading_digit_base(b, sequence[k]) == d)
    return count / N


def frac_log_base(b: int, x: float) -> float:
    """
    Fractional part of log_b(x).

    Matches the formal definition `BenfordRenormalization.fracLogBase`.

    Parameters
    ----------
    b : int
        The base.
    x : float
        A positive real number.

    Returns
    -------
    float
        The fractional part of log_b(x), in [0, 1).
    """
    if x <= 0:
        return 0.0
    val = math.log(x) / math.log(b)
    return val - math.floor(val)


def generate_orbit(T: Callable[[int], int], seed: int, steps: int) -> List[int]:
    """
    Generate an orbit of the map T starting from seed.

    Parameters
    ----------
    T : callable
        The dynamical map.
    seed : int
        The initial value.
    steps : int
        Number of iterations.

    Returns
    -------
    list of int
        The orbit [seed, T(seed), T(T(seed)), ...].
    """
    orbit = [seed]
    x = seed
    for _ in range(steps):
        x = T(x)
        if x <= 0:
            break
        orbit.append(x)
    return orbit


def digit_frequency_profile(sequence: List[int], base: int = 10) -> Dict[int, float]:
    """
    Compute empirical leading-digit frequencies for all digits.

    Parameters
    ----------
    sequence : list of int
        The sequence of positive integers.
    base : int
        The base for digit extraction.

    Returns
    -------
    dict
        Maps digit d to its empirical frequency.
    """
    N = len(sequence)
    if N == 0:
        return {}
    counts = Counter(leading_digit_base(base, n) for n in sequence if n >= 1)
    return {d: counts.get(d, 0) / N for d in range(1, base)}


def benford_discrepancy(sequence: List[int], base: int = 10) -> float:
    """
    Compute the total discrepancy from Benford's law.

    Returns the sum of |empirical(d) - theoretical(d)| over all digits.

    Parameters
    ----------
    sequence : list of int
        The sequence.
    base : int
        The base.

    Returns
    -------
    float
        Total absolute discrepancy.
    """
    profile = digit_frequency_profile(sequence, base)
    return sum(abs(profile.get(d, 0) - benford_theoretical(base, d))
               for d in range(1, base))


def fourier_mode_estimate(sequence: List[int], m: int, base: int = 10) -> complex:
    """
    Estimate the m-th Fourier mode of the fractional log sequence.

    Computes (1/N) * sum_{k=0}^{N-1} exp(2πi·m·frac(log_b(u_k))).
    For equidistributed sequences, this should converge to 0 for m ≠ 0.
    Non-zero modes indicate spectral obstruction.

    Parameters
    ----------
    sequence : list of int
        The sequence.
    m : int
        The Fourier mode index (nonzero for obstruction detection).
    base : int
        The base.

    Returns
    -------
    complex
        The estimated Fourier coefficient.
    """
    N = len(sequence)
    if N == 0:
        return 0j
    total = sum(
        complex(math.cos(2 * math.pi * m * frac_log_base(base, x)),
                math.sin(2 * math.pi * m * frac_log_base(base, x)))
        for x in sequence if x >= 1
    )
    return total / N


def detect_rational_obstruction(
    sequence: List[int],
    base: int = 10,
    max_q: int = 20,
    threshold: float = 0.1
) -> Optional[Tuple[int, float]]:
    """
    Detect rational eigen-obstruction in the logarithmic cocycle.

    Checks whether q * log_b(u_k) is approximately integer for some
    small q, by examining the q-th Fourier mode.

    Parameters
    ----------
    sequence : list of int
        The sequence.
    base : int
        The base.
    max_q : int
        Maximum q to check.
    threshold : float
        Fourier magnitude threshold for detection.

    Returns
    -------
    tuple or None
        (q, magnitude) if obstruction detected, None otherwise.
    """
    for q in range(1, max_q + 1):
        mode = fourier_mode_estimate(sequence, q, base)
        mag = abs(mode)
        if mag > 1 - threshold:
            return (q, mag)
    return None


def benford_orbit_report(
    T: Callable[[int], int],
    seeds: List[int],
    steps: int,
    base: int = 10
) -> Dict:
    """
    Comprehensive Benford analysis report for orbits of a dynamical map.

    Generates empirical leading-digit frequencies, discrepancy from Benford,
    low Fourier modes, and obstruction flags for each seed.

    Parameters
    ----------
    T : callable
        The dynamical map.
    seeds : list of int
        Starting values.
    steps : int
        Number of iterations per seed.
    base : int
        The base for digit extraction.

    Returns
    -------
    dict
        Report with keys:
        - 'seeds': list of seed reports
        - 'aggregate_discrepancy': average discrepancy across seeds
        - 'benford_predicted': theoretical frequencies
    """
    reports = []
    for seed in seeds:
        orbit = generate_orbit(T, seed, steps)
        profile = digit_frequency_profile(orbit, base)
        disc = benford_discrepancy(orbit, base)

        # Low Fourier modes
        fourier_modes = {}
        for m in range(1, 6):
            mode = fourier_mode_estimate(orbit, m, base)
            fourier_modes[m] = {'real': mode.real, 'imag': mode.imag,
                               'magnitude': abs(mode)}

        # Obstruction detection
        obstruction = detect_rational_obstruction(orbit, base)

        reports.append({
            'seed': seed,
            'orbit_length': len(orbit),
            'digit_frequencies': profile,
            'discrepancy': disc,
            'fourier_modes': fourier_modes,
            'obstruction': obstruction,
        })

    predicted = {d: benford_theoretical(base, d) for d in range(1, base)}
    avg_disc = sum(r['discrepancy'] for r in reports) / len(reports) if reports else 0

    return {
        'seeds': reports,
        'aggregate_discrepancy': avg_disc,
        'benford_predicted': predicted,
    }


# --- Map Families ---

def multiplication_map(r: int) -> Callable[[int], int]:
    """Pure multiplication map T(n) = r·n."""
    return lambda n: r * n


def affine_map(a: int, c: int) -> Callable[[int], int]:
    """Affine map T(n) = a·n + c."""
    return lambda n: a * n + c


def collatz_map(n: int) -> int:
    """Collatz-type map: 3n+1 if odd, n/2 if even."""
    if n % 2 == 0:
        return n // 2
    return 3 * n + 1


def reverse_and_add(n: int) -> int:
    """Reverse-and-add map."""
    s = str(n)
    return n + int(s[::-1])


def polynomial_perturbed_map(r: int, c: int) -> Callable[[int], int]:
    """Polynomially perturbed multiplicative map T(n) = r·n + c."""
    return lambda n: r * n + c


if __name__ == "__main__":
    # Quick test
    print("=== Benford Renormalization: Algorithm Tests ===\n")

    # Test 1: Powers of 2 (should be Benford in base 10)
    powers_of_2 = [2**k for k in range(1, 1001)]
    profile = digit_frequency_profile(powers_of_2, 10)
    disc = benford_discrepancy(powers_of_2, 10)
    print("Powers of 2 (first 1000):")
    for d in range(1, 10):
        pred = benford_theoretical(10, d)
        print(f"  Digit {d}: empirical={profile.get(d, 0):.4f}, "
              f"predicted={pred:.4f}")
    print(f"  Discrepancy: {disc:.6f}\n")

    # Test 2: Powers of 10 (NOT Benford — rational obstruction)
    powers_of_10 = [10**k for k in range(1, 101)]
    profile = digit_frequency_profile(powers_of_10, 10)
    disc = benford_discrepancy(powers_of_10, 10)
    obs = detect_rational_obstruction(powers_of_10, 10)
    print("Powers of 10 (first 100):")
    print(f"  Digit 1 frequency: {profile.get(1, 0):.4f}")
    print(f"  Discrepancy: {disc:.6f}")
    print(f"  Obstruction detected: {obs}\n")

    # Test 3: Multiplication orbit (×3 from seed 1)
    orbit_3x = generate_orbit(multiplication_map(3), 1, 500)
    profile = digit_frequency_profile(orbit_3x, 10)
    disc = benford_discrepancy(orbit_3x, 10)
    print("Orbit of T(n) = 3n, seed=1, 500 steps:")
    for d in range(1, 10):
        pred = benford_theoretical(10, d)
        print(f"  Digit {d}: empirical={profile.get(d, 0):.4f}, "
              f"predicted={pred:.4f}")
    print(f"  Discrepancy: {disc:.6f}")
