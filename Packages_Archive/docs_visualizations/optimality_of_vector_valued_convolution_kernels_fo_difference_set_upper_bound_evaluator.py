import math
from typing import List

def sidon_upper_bound(n: int) -> float:
    """Difference-set ceiling F(N) <= sqrt(2N) + 1, obtained by solving the
    counting inequality |S|(|S|-1) <= 2(N-1) for |S|. O(1) time."""
    return math.sqrt(2 * n) + 1.0

def counting_bound_holds(s: List[int], n: int) -> bool:
    """Check |S|(|S|-1) <= 2(N-1) for a candidate Sidon set S in {1,...,N}."""
    m = len(s)
    return m * (m - 1) <= 2 * (n - 1)
