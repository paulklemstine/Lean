from __future__ import annotations
from collections import defaultdict
from typing import Hashable, Iterable


def finite_born_measurement(
    branches: Iterable[tuple[Hashable, complex]],
) -> dict[Hashable, float]:
    """Combine coincident labels and normalize coefficient magnitudes."""
    amplitudes: dict[Hashable, complex] = defaultdict(complex)
    for label, amplitude in branches:
        amplitudes[label] += amplitude
    norm_sq = sum(abs(amplitude) ** 2 for amplitude in amplitudes.values())
    if norm_sq == 0.0:
        raise ValueError("zero states cannot be normalized")
    return {label: abs(amplitude) ** 2 / norm_sq
            for label, amplitude in amplitudes.items()}
