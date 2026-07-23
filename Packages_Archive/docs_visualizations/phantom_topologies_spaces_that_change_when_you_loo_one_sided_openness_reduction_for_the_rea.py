from typing import Tuple

Interval = Tuple[str, str]  # (left_kind, right_kind), each "open" or "closed"

def lower_limit_open(iv: Interval) -> bool:
    """Basic opens [x, b): right endpoint must be excluded (open)."""
    return iv[1] == "open"

def upper_limit_open(iv: Interval) -> bool:
    """Basic opens (a, x]: left endpoint must be excluded (open)."""
    return iv[0] == "open"

def consensus_open(iv: Interval) -> bool:
    """Open for both one-sided observers == Euclidean open (both endpoints open)."""
    return lower_limit_open(iv) and upper_limit_open(iv)
