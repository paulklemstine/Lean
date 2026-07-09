from __future__ import annotations
from fractions import Fraction


def dark_fraction(N: int) -> Fraction:
    """Exact fraction of dark configurations in a family of size N.

    A configuration chooses a top counting-level in {0,...,N-1} and, for
    each of the N candidate witnesses, a provability bit. It is dark iff the
    top level is >= 1 (existence provable) and every witness-bit is false
    (no witness provable). Exactly one witness-pattern (all-false) qualifies,
    so the count of dark configurations is N-1 out of N * 2**N total."""
    total: int = N * (2 ** N)
    dark: int = N - 1
    return Fraction(dark, total)


def limiting_behaviour(Ns: list[int]) -> list[float]:
    """Return the dark densities for a list of family sizes (should -> 0)."""
    return [float(dark_fraction(N)) for N in Ns]
