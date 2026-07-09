from typing import List, Optional, Sequence, Tuple
from fractions import Fraction

def discriminant(a: Sequence[Fraction]) -> List[Fraction]:
    return [a[n + 1] ** 2 - a[n] * a[n + 2] for n in range(len(a) - 2)]

def infinite_log_concavity_test(
    a: Sequence[Fraction], depth: int
) -> Optional[Tuple[int, int, Fraction]]:
    """Test infinite log-concavity to a given iteration depth.

    Repeatedly applies the discriminant operator, each pass shrinking the
    window by two. Returns the first (k, n, value) with (L^k a)(n) < 0, or
    None if no violation is found within the available window. Complexity
    O(depth * N).
    """
    cur = list(a)
    for k in range(depth + 1):
        for n, v in enumerate(cur):
            if v < 0:
                return (k, n, v)
        if len(cur) < 3:
            break
        cur = discriminant(cur)
    return None
