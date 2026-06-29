from typing import List, Tuple

Vec = Tuple[int, ...]


def support(x: Vec) -> List[int]:
    """Indices of nonzero coordinates of a binary vector."""
    return [i for i, a in enumerate(x) if a != 0]


def tprof(x: Vec) -> int:
    """Weight-threshold profile: 1 + index of the top active coordinate; 0 if x = 0.

    This is the leading-position nonarchimedean valuation. Complexity O(n).
    """
    return max((i + 1 for i in support(x)), default=0)
