from typing import List, Sequence


def ones(s: Sequence[bool]) -> int:
    """Number of True readouts."""
    return sum(1 for x in s if x is True)


def errors(s: Sequence[bool], b: bool) -> int:
    """Hamming weight of corruption relative to true bit b."""
    return sum(1 for x in s if x != b)


def majority_decode(s: Sequence[bool]) -> bool:
    """Majority-vote decoder for the repetition code.

    Returns True iff strictly more than half of the readouts are True.
    By the correctness theorem, this recovers the true logical bit b
    whenever 2 * errors(s, b) < len(s).
    """
    n = len(s)
    return 2 * ones(s) > n
