from __future__ import annotations
from math import log
from itertools import combinations
from dataclasses import dataclass


@dataclass(frozen=True)
class CharacterDatum:
    conductor: int
    real_zero: float


def is_valid(chi: CharacterDatum, eps: float, q0: int, m: int) -> bool:
    """In-window and eps-exceptional: Q0 <= q <= M and beta >= 1 - q^(-eps)."""
    return q0 <= chi.conductor <= m and chi.real_zero >= 1.0 - float(chi.conductor) ** (-eps)


def certify_uniqueness(
    data: list[CharacterDatum], eps: float, c: float, q0: int, m: int
) -> tuple[str, object]:
    """Certified pairwise checker for the repulsion-to-uniqueness principle.

    Filters to valid data, then checks every distinct pair against the repulsion
    ceiling 1 - C/log(q q'). Returns ('unique', V) if at most one valid datum,
    ('coexisting pair', (a, b)) if a distinct valid pair violates repulsion, or
    ('consistent', V) otherwise. Complexity O(n^2)."""
    valid = [chi for chi in data if is_valid(chi, eps, q0, m)]
    if len(valid) <= 1:
        return "unique", valid
    for a, b in combinations(valid, 2):
        ceiling = 1.0 - c / log(float(a.conductor) * float(b.conductor))
        if min(a.real_zero, b.real_zero) > ceiling:
            return "coexisting pair", (a, b)
    return "consistent", valid
