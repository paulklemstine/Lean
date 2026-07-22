from __future__ import annotations
from typing import Iterable

LexWeight = tuple[float, int]


def aggregate_standard_mass(weights: Iterable[LexWeight]) -> tuple[LexWeight, float]:
    """Add lexicographic weights and return the total with its standard part."""
    ordinary = 0.0
    infinitesimal = 0
    for real_part, infinitesimal_part in weights:
        ordinary += real_part
        infinitesimal += infinitesimal_part
    total = (ordinary, infinitesimal)
    return total, ordinary
