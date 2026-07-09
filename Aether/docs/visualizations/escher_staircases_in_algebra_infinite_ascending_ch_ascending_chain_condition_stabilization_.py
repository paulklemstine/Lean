from typing import List, Optional


def acc_stabilization_index(exponents: List[int]) -> Optional[int]:
    """Given an ascending ideal chain in a DVR, encoded by valuation exponents
    (non-increasing), return the first index at which it stabilizes, or None if
    the input is not a valid ascending chain.

    A non-increasing sequence of non-negative integers stabilizes in finitely
    many steps; this certifies the ascending chain condition.  Runs in O(len).
    """
    for i in range(len(exponents) - 1):
        if exponents[i] < exponents[i + 1]:
            return None  # not an ascending ideal chain
    for i in range(len(exponents) - 1):
        if exponents[i] == exponents[i + 1]:
            return i
    return len(exponents) - 1
