"""
Algorithms for Quantum Group Casimir Spectra and Spectral Statistics.

Implements q-numbers, q-Casimir eigenvalues, spectral counting functions,
and GUE statistics tests for the zeta quantum group conjecture.
"""

import math
from typing import List, Tuple, Optional


def q_number(q: float, n: int) -> float:
    """Compute the q-number [n]_q = (q^n - q^{-n}) / (q - q^{-1}).

    Args:
        q: Deformation parameter (q > 0, q != 1).
        n: Non-negative integer.

    Returns:
        The q-analog of n.
    """
    if q == 1.0:
        return float(n)
    if q <= 0.0:
        return 0.0
    qn = q ** n
    qinv_n = q ** (-n)
    return (qn - qinv_n) / (q - 1.0 / q)


def q_number_complex(q: complex, n: int) -> complex:
    """Compute the q-number [n]_q for complex q.

    Args:
        q: Complex deformation parameter (q != 0, q != 1).
        n: Non-negative integer.

    Returns:
        The complex q-analog of n.
    """
    if abs(q - 1.0) < 1e-15:
        return complex(n)
    if abs(q) < 1e-15:
        return complex(0)
    qn = q ** n
    qinv_n = (1.0 / q) ** n
    return (qn - qinv_n) / (q - 1.0 / q)


def classical_casimir(n: int) -> int:
    """Compute the classical Casimir eigenvalue C(n) = n(n+1).

    Args:
        n: Non-negative integer (representation label).

    Returns:
        n * (n + 1)
    """
    return n * (n + 1)


def q_casimir(q: float, n: int) -> float:
    """Compute the q-Casimir eigenvalue C_q(n) = [n]_q * [n+1]_q.

    Args:
        q: Deformation parameter.
        n: Representation label.

    Returns:
        The q-deformed Casimir eigenvalue.
    """
    return q_number(q, n) * q_number(q, n + 1)


def q_casimir_complex(q: complex, n: int) -> complex:
    """Compute the q-Casimir eigenvalue for complex q.

    Args:
        q: Complex deformation parameter.
        n: Representation label.

    Returns:
        The complex q-Casimir eigenvalue.
    """
    return q_number_complex(q, n) * q_number_complex(q, n + 1)


def spectral_count(T: int) -> int:
    """Count Casimir eigenvalues <= T.

    Args:
        T: Upper bound.

    Returns:
        Number of n with n(n+1) <= T.
    """
    count = 0
    n = 0
    while n * (n + 1) <= T:
        count += 1
        n += 1
    return count


def spectral_gap(n: int) -> int:
    """Compute the spectral gap at level n: C(n+1) - C(n) = 2(n+1).

    Args:
        n: Level index.

    Returns:
        2 * (n + 1)
    """
    return 2 * (n + 1)


def normalized_spacings(eigenvalues: List[float]) -> List[float]:
    """Compute normalized nearest-neighbor spacings.

    Args:
        eigenvalues: Sorted list of eigenvalues.

    Returns:
        List of normalized spacings (mean = 1).
    """
    if len(eigenvalues) < 2:
        return []
    spacings = [eigenvalues[i + 1] - eigenvalues[i]
                for i in range(len(eigenvalues) - 1)]
    mean_spacing = sum(spacings) / len(spacings)
    if mean_spacing == 0:
        return spacings
    return [s / mean_spacing for s in spacings]


def spacing_variance(eigenvalues: List[float]) -> float:
    """Compute variance of normalized spacings.

    GUE prediction: ~0.286
    Poisson prediction: 1.0
    Rigid prediction: 0.0

    Args:
        eigenvalues: Sorted list of eigenvalues.

    Returns:
        Variance of normalized nearest-neighbor spacings.
    """
    ns = normalized_spacings(eigenvalues)
    if not ns:
        return 0.0
    mean = sum(ns) / len(ns)
    return sum((s - mean) ** 2 for s in ns) / len(ns)


def wigner_surmise(s: float) -> float:
    """GUE Wigner surmise: P(s) = (pi/2) * s * exp(-pi*s^2/4).

    Args:
        s: Normalized spacing.

    Returns:
        GUE probability density at s.
    """
    return (math.pi / 2) * s * math.exp(-math.pi * s ** 2 / 4)


def poisson_spacing(s: float) -> float:
    """Poisson spacing distribution: P(s) = exp(-s).

    Args:
        s: Normalized spacing.

    Returns:
        Poisson probability density at s.
    """
    return math.exp(-s)


def casimir_inverse(v: int) -> int:
    """Recover the representation label from a Casimir value.

    Given v = n(n+1), returns n = floor(sqrt(v)).

    Args:
        v: A Casimir eigenvalue.

    Returns:
        The representation label n.
    """
    return int(math.isqrt(v))


def is_casimir_value(v: int) -> bool:
    """Check if v is a Casimir value n(n+1) for some n.

    Args:
        v: Non-negative integer.

    Returns:
        True if v = n(n+1) for some n >= 0.
    """
    n = int(math.isqrt(v))
    return n * (n + 1) == v


def casimir_interaction(n: int, m: int) -> int:
    """Compute the interaction energy 2nm from the tensor product decomposition.

    C(n+m) = C(n) + C(m) + 2nm

    Args:
        n, m: Representation labels.

    Returns:
        The interaction term 2 * n * m.
    """
    return 2 * n * m


def spectral_zeta_partial(N: int) -> float:
    """Compute the partial spectral zeta sum sum_{k=1}^N 1/(k(k+1)).

    This equals N/(N+1) exactly.

    Args:
        N: Number of terms.

    Returns:
        The partial sum.
    """
    return sum(1.0 / ((k + 1) * (k + 2)) for k in range(N))


def compute_gue_test(q: complex, N: int) -> Tuple[float, List[float]]:
    """Run the GUE statistics test on the q-Casimir spectrum.

    Args:
        q: Complex deformation parameter.
        N: Number of eigenvalues to compute.

    Returns:
        Tuple of (variance, normalized_spacings).
    """
    eigenvalues = sorted([abs(q_casimir_complex(q, n)) for n in range(N)])
    ns = normalized_spacings(eigenvalues)
    var = spacing_variance(eigenvalues)
    return var, ns


def spacing_histogram(spacings: List[float], bins: int = 50) -> Tuple[List[float], List[float]]:
    """Create a histogram of spacings for comparison with theoretical distributions.

    Args:
        spacings: List of normalized spacings.
        bins: Number of histogram bins.

    Returns:
        Tuple of (bin_centers, counts) normalized to unit area.
    """
    if not spacings:
        return [], []
    max_s = max(spacings)
    bin_width = max_s / bins
    if bin_width == 0:
        return [], []

    counts = [0.0] * bins
    for s in spacings:
        idx = min(int(s / bin_width), bins - 1)
        counts[idx] += 1

    # Normalize
    total = sum(counts) * bin_width
    if total > 0:
        counts = [c / total for c in counts]

    centers = [(i + 0.5) * bin_width for i in range(bins)]
    return centers, counts
