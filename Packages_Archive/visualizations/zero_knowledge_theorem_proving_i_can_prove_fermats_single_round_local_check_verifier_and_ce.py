from fractions import Fraction
from typing import Callable, Hashable, List, Sequence

Challenge = Hashable


def single_round_accepting_fraction(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> Fraction:
    """Exact single-round accepting probability |P| / |Omega|.

    Implements the single-round GMW-style verifier: sample e uniformly from
    omega, accept iff check(e) is True. Returns the exact fraction of passing
    challenges as a rational number.
    """
    if len(omega) == 0:
        raise ValueError("challenge space must be nonempty")
    passing: List[Challenge] = [e for e in omega if check(e)]
    return Fraction(len(passing), len(omega))


def is_invalid(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> bool:
    """A certificate is invalid iff at least one challenge fails."""
    return any(not check(e) for e in omega)


def certified_soundness_gap(
    omega: Sequence[Challenge], check: Callable[[Challenge], bool]
) -> Fraction:
    """Return the guaranteed rejection probability (soundness gap).

    If the certificate is invalid, this is >= 1/|Omega| by the Single-Round
    Soundness Theorem; if valid it is 0.
    """
    return 1 - single_round_accepting_fraction(omega, check)
