from itertools import combinations
from typing import Sequence, Tuple

Perm = Tuple[int, ...]

PATTERN_3412: Perm = (2, 3, 0, 1)
PATTERN_4231: Perm = (3, 1, 2, 0)


def _relative_order(values: Sequence[int]) -> Perm:
    """Standardize distinct numbers to their relative-order (pattern) word."""
    ranks = {v: r for r, v in enumerate(sorted(values))}
    return tuple(ranks[v] for v in values)


def contains_pattern(sigma: Perm, pattern: Perm) -> bool:
    """True iff sigma contains the length-k `pattern` (Definition: Contains).

    Searches all increasing position-tuples; for fixed k this is O(n^k).
    """
    k: int = len(pattern)
    for positions in combinations(range(len(sigma)), k):
        if _relative_order([sigma[p] for p in positions]) == pattern:
            return True
    return False


def is_smooth(sigma: Perm) -> bool:
    """Lakshmibai-Sandhya smoothness: avoid both 3412 and 4231 (IsSmooth)."""
    return (not contains_pattern(sigma, PATTERN_3412)
            and not contains_pattern(sigma, PATTERN_4231))
