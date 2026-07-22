from __future__ import annotations


def dimension_by_recurrence(g: int) -> int:
    """Compute dim M_g by the atomic recurrence R(0) = -3, R(k+1) = R(k) + 3,
    certifying the closed form 3g - 3 for g >= 0."""
    if g < 0:
        raise ValueError("genus must be nonnegative")
    value = -3
    for _ in range(g):
        value += 3
    return value


def enumerate_dimensions(max_g: int) -> list[int]:
    """Return the list [dim M_g for g in 0..max_g], an arithmetic progression
    with common difference 3."""
    return [dimension_by_recurrence(g) for g in range(max_g + 1)]
