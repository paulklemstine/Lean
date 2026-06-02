"""
Quantum Group Casimir Spectrum Algorithms

Type-hinted implementations of q-integer and q-Casimir spectrum computations.
"""

from typing import List, Tuple
import math


def q_integer(q: float, n: int) -> float:
    """Compute the q-integer [n]_q = 1 + q + q^2 + ... + q^{n-1}.

    For q != 1, uses the geometric sum formula (q^n - 1)/(q - 1).
    For q == 1, returns n.

    Args:
        q: Deformation parameter (positive real).
        n: Non-negative integer.

    Returns:
        The q-integer [n]_q.
    """
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def q_integer_recursive(q: float, n: int) -> float:
    """Compute [n]_q using the recurrence [n+1]_q = 1 + q * [n]_q.

    More numerically stable for large n with q close to 1.
    """
    result = 0.0
    for _ in range(n):
        result = 1.0 + q * result
    return result


def q_casimir(q: float, n: int) -> float:
    """Compute the q-Casimir eigenvalue lambda_n = [n]_q * [n+1]_q.

    Args:
        q: Deformation parameter.
        n: Representation label.

    Returns:
        The q-Casimir eigenvalue.
    """
    return q_integer(q, n) * q_integer(q, n + 1)


def q_casimir_spectrum(q: float, N: int) -> List[float]:
    """Compute the first N q-Casimir eigenvalues using O(N) recurrence.

    Uses [n+1]_q = 1 + q * [n]_q to avoid recomputation.

    Args:
        q: Deformation parameter.
        N: Number of eigenvalues to compute.

    Returns:
        List [lambda_0, lambda_1, ..., lambda_{N-1}].
    """
    spectrum: List[float] = []
    q_int_prev = 0.0  # [0]_q
    q_int_curr = 1.0  # [1]_q
    for n in range(N):
        spectrum.append(q_int_prev * q_int_curr)
        q_int_prev = q_int_curr
        q_int_curr = 1.0 + q * q_int_curr
    return spectrum


def spectral_gaps(q: float, N: int) -> List[float]:
    """Compute spectral gaps using the recurrence Delta_{n+1} = q^2 * Delta_n + q^{n+1} * (1+q).

    Args:
        q: Deformation parameter.
        N: Number of gaps to compute.

    Returns:
        List [Delta_0, Delta_1, ..., Delta_{N-1}].
    """
    gaps: List[float] = []
    delta = 1.0 + q  # Delta_0 = lambda_1 - lambda_0 = (1+q) - 0
    q_power = q       # q^{n+1} starting at n=0
    q_sq = q * q
    for _ in range(N):
        gaps.append(delta)
        delta = q_sq * delta + q_power * (1.0 + q)
        q_power *= q
    return gaps


def spectral_gaps_from_formula(q: float, N: int) -> List[float]:
    """Compute gaps using explicit formula: Delta_n = [n+1]_q * q^n * (1+q)."""
    gaps: List[float] = []
    q_int = 1.0  # [1]_q
    q_power = 1.0  # q^0
    for n in range(N):
        gaps.append(q_int * q_power * (1.0 + q))
        q_int = 1.0 + q * q_int  # [n+2]_q
        q_power *= q
    return gaps


def spectral_zeta(q: float, s: float, N: int) -> float:
    """Compute the finite spectral zeta function zeta_C(s, N) = sum_{n=1}^{N} lambda_n^{-s}.

    Args:
        q: Deformation parameter.
        s: Complex exponent (real part).
        N: Truncation.

    Returns:
        Partial sum of the spectral zeta function.
    """
    spectrum = q_casimir_spectrum(q, N + 1)
    total = 0.0
    for n in range(1, N + 1):
        if spectrum[n] > 0:
            total += spectrum[n] ** (-s)
    return total


def pair_correlation(eigenvalues: List[float], num_bins: int = 100,
                     max_r: float = 3.0) -> Tuple[List[float], List[float]]:
    """Compute the pair correlation function R_2(r) for a spectrum.

    Normalizes spacings by the mean spacing and computes the histogram
    of all pair differences.

    Args:
        eigenvalues: Sorted list of eigenvalues.
        num_bins: Number of histogram bins.
        max_r: Maximum normalized distance to consider.

    Returns:
        Tuple of (bin_centers, R2_values).
    """
    N = len(eigenvalues)
    if N < 3:
        return [], []

    # Compute mean spacing
    spacings = [eigenvalues[i+1] - eigenvalues[i] for i in range(N-1)]
    mean_spacing = sum(spacings) / len(spacings)

    # Normalize eigenvalues
    normalized = [e / mean_spacing for e in eigenvalues]

    # Compute pair differences
    diffs: List[float] = []
    for i in range(N):
        for j in range(i+1, min(i+50, N)):  # limit to nearby pairs
            d = abs(normalized[j] - normalized[i])
            if d < max_r * N:
                diffs.append(d / N * len(eigenvalues))

    # Histogram
    bin_width = max_r / num_bins
    bins = [0.0] * num_bins
    for d in diffs:
        idx = int(d / bin_width)
        if 0 <= idx < num_bins:
            bins[idx] += 1

    # Normalize
    total_pairs = N * (N - 1) / 2
    bin_centers = [(i + 0.5) * bin_width for i in range(num_bins)]
    r2_values = [b / (total_pairs * bin_width) * N for b in bins]

    return bin_centers, r2_values


def nearest_neighbor_spacing(eigenvalues: List[float]) -> List[float]:
    """Compute normalized nearest-neighbor spacings.

    Args:
        eigenvalues: Sorted list of eigenvalues.

    Returns:
        List of spacings normalized by mean spacing.
    """
    N = len(eigenvalues)
    spacings = [eigenvalues[i+1] - eigenvalues[i] for i in range(N-1)]
    mean_s = sum(spacings) / len(spacings) if spacings else 1.0
    return [s / mean_s for s in spacings]


def gue_wigner_surmise(s: float) -> float:
    """GUE Wigner surmise: P(s) = (32/pi^2) * s^2 * exp(-4s^2/pi).

    Args:
        s: Normalized spacing.

    Returns:
        Probability density.
    """
    return (32.0 / math.pi**2) * s**2 * math.exp(-4.0 * s**2 / math.pi)


def poisson_spacing(s: float) -> float:
    """Poisson spacing distribution: P(s) = exp(-s).

    Args:
        s: Normalized spacing.

    Returns:
        Probability density.
    """
    return math.exp(-s)


def symmetric_q_integer(alpha: float, n: int) -> float:
    """Compute the symmetric q-integer [n]_q = sin(n*pi*alpha)/sin(pi*alpha).

    For q = e^{2*pi*i*alpha} on the unit circle.

    Args:
        alpha: Parameter (related to Riemann zeros by alpha = gamma/(2*pi)).
        n: Non-negative integer.

    Returns:
        The symmetric q-integer.
    """
    denom = math.sin(math.pi * alpha)
    if abs(denom) < 1e-15:
        return float(n)
    return math.sin(n * math.pi * alpha) / denom


def symmetric_q_casimir(alpha: float, n: int) -> float:
    """Compute the symmetric q-Casimir eigenvalue using sin-based q-integers."""
    return symmetric_q_integer(alpha, n) * symmetric_q_integer(alpha, n + 1)


def verify_multiplication_formula(q: float, n: int, m: int) -> Tuple[float, float, float]:
    """Verify the multiplication formula [nm]_q = [n]_q * [m]_{q^n}.

    Returns (lhs, rhs, relative_error).
    """
    lhs = q_integer(q, n * m)
    rhs = q_integer(q, n) * q_integer(q**n, m)
    rel_err = abs(lhs - rhs) / max(abs(lhs), 1e-15)
    return lhs, rhs, rel_err


def verify_gap_recurrence(q: float, n: int) -> Tuple[float, float, float]:
    """Verify the gap recurrence Delta_{n+1} = q^2 * Delta_n + q^{n+1} * (1+q).

    Returns (lhs, rhs, relative_error).
    """
    spectrum = q_casimir_spectrum(q, n + 3)
    delta_n = spectrum[n+1] - spectrum[n]
    delta_n1 = spectrum[n+2] - spectrum[n+1]
    rhs = q**2 * delta_n + q**(n+1) * (1 + q)
    rel_err = abs(delta_n1 - rhs) / max(abs(delta_n1), 1e-15)
    return delta_n1, rhs, rel_err
