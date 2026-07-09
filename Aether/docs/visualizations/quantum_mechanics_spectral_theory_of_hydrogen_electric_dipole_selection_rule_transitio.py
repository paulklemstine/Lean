from __future__ import annotations

from typing import Iterator


def dipole_allowed(l: int, lp: int, m: int, mp: int) -> bool:
    """Electric-dipole rule: |Delta l| = 1 and |Delta m| <= 1."""
    return (lp == l + 1 or l == lp + 1) and abs(m - mp) <= 1


def states(n: int) -> Iterator[tuple[int, int]]:
    """Angular states (l, m) of shell n."""
    for l in range(n):
        for m in range(-l, l + 1):
            yield (l, m)


def allowed_transitions(
    n: int,
) -> list[tuple[tuple[int, int], tuple[int, int]]]:
    """All dipole-allowed ordered transitions among states of shell n."""
    sts = list(states(n))
    return [
        ((l, m), (lp, mp))
        for (l, m) in sts
        for (lp, mp) in sts
        if dipole_allowed(l, lp, m, mp)
    ]
