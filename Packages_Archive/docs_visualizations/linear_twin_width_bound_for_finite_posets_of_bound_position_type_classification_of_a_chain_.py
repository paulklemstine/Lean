from typing import Callable, List, Sequence

Leq = Callable[[int, int], bool]
ABOVE, INCOMP, BELOW, EQ = "Above", "Incomp", "Below", "Eq"


def pos_type(leq: Leq, x: int, c: int) -> str:
    """Position type of chain element c relative to observer x (Definition 2.7)."""
    if x == c:
        return EQ
    if c != x and leq(c, x):
        return ABOVE
    if x != c and leq(x, c):
        return BELOW
    return INCOMP


def pos_type_sequence(leq: Leq, x: int, sorted_chain: Sequence[int]) -> List[str]:
    """Position types of x along a chain already sorted bottom -> top."""
    return [pos_type(leq, x, c) for c in sorted_chain]
