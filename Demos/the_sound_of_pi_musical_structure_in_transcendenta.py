"""Numerical demonstrations of cyclic autocorrelation and interval energy."""

from __future__ import annotations

import cmath
import math
from typing import Iterable, Sequence


def cyclic_shift(signal: Sequence[float], lag: int) -> list[float]:
    """Return the cyclic lag shift T_k s with output[i] = signal[(i + lag) mod n]."""
    if not signal:
        raise ValueError("signal must be nonempty")
    n = len(signal)
    return [float(signal[(i + lag) % n]) for i in range(n)]


def signal_energy(signal: Sequence[float]) -> float:
    """Compute the sum of squared amplitudes."""
    return sum(float(x) ** 2 for x in signal)


def autocorrelation(signal: Sequence[float], lag: int) -> float:
    """Compute unnormalized cyclic autocorrelation at a temporal lag."""
    shifted = cyclic_shift(signal, lag)
    return sum(float(x) * y for x, y in zip(signal, shifted))


def interval_energy(signal: Sequence[float], lag: int) -> float:
    """Compute squared Euclidean cost between a signal and its cyclic shift."""
    shifted = cyclic_shift(signal, lag)
    return sum((float(x) - y) ** 2 for x, y in zip(signal, shifted))


def analyze_lags(signal: Sequence[float], lags: Iterable[int]) -> list[dict[str, float | int]]:
    """Calculate correlations, shift costs, and identity residuals for selected lags."""
    energy = signal_energy(signal)
    rows: list[dict[str, float | int]] = []
    for lag in lags:
        corr = autocorrelation(signal, lag)
        cost = interval_energy(signal, lag)
        rows.append({
            "lag": lag,
            "autocorrelation": corr,
            "interval_energy": cost,
            "energy": energy,
            "identity_residual": 2.0 * corr - (2.0 * energy - cost),
        })
    return rows


def dft(signal: Sequence[float]) -> list[complex]:
    """Compute the discrete Fourier transform directly in O(n^2) time."""
    n = len(signal)
    if n == 0:
        raise ValueError("signal must be nonempty")
    return [
        sum(float(signal[j]) * cmath.exp(-2j * math.pi * r * j / n) for j in range(n))
        for r in range(n)
    ]


def idft(coefficients: Sequence[complex]) -> list[complex]:
    """Reconstruct a signal from its complete DFT in O(n^2) time."""
    n = len(coefficients)
    if n == 0:
        raise ValueError("coefficient vector must be nonempty")
    return [
        sum(coefficients[r] * cmath.exp(2j * math.pi * r * j / n) for r in range(n)) / n
        for j in range(n)
    ]


def pitch_interval_histogram(digits: Sequence[int]) -> dict[int, int]:
    """Count all unordered pairs by absolute semitone difference."""
    if any(d < 0 or d > 9 for d in digits):
        raise ValueError("every digit must lie between 0 and 9")
    histogram = {difference: 0 for difference in range(13)}
    for i in range(len(digits)):
        for j in range(i + 1, len(digits)):
            histogram[abs(digits[i] - digits[j])] += 1
    return histogram


def print_analysis(name: str, signal: Sequence[float]) -> None:
    """Print a compact table demonstrating the energy identity."""
    print(f"\n{name}: {list(signal)}")
    print("lag | correlation | interval energy | residual")
    for row in analyze_lags(signal, range(len(signal))):
        print(
            f"{row['lag']:>3} | {row['autocorrelation']:>11.3f} | "
            f"{row['interval_energy']:>15.3f} | {row['identity_residual']:+.2e}"
        )


def main() -> None:
    periodic = [1.0, 2.0, 1.0, 2.0]
    pi_prefix = [3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0]
    print_analysis("Exactly repeating signal", periodic)
    print_analysis("Finite digit block", pi_prefix)

    reconstructed = idft(dft(pi_prefix))
    reconstruction_error = max(abs(complex(x) - y) for x, y in zip(pi_prefix, reconstructed))
    print(f"\nMaximum DFT reconstruction error: {reconstruction_error:.3e}")

    histogram = pitch_interval_histogram([int(x) for x in pi_prefix])
    print(f"Pairs separated by 12 semitones: {histogram[12]}")
    assert histogram[12] == 0
    assert all(abs(float(row["identity_residual"])) < 1e-9 for row in analyze_lags(pi_prefix, range(8)))


if __name__ == "__main__":
    main()
