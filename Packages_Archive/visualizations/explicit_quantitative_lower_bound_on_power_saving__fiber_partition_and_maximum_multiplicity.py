from collections import Counter
from typing import Dict, List, Sequence


def fiber_partition(coeffs: Sequence[int], A: Sequence[int],
                    k: int) -> Dict[int, int]:
    buckets: Counter = Counter()
    for a in set(A):
        v: int = 0
        for c in coeffs:
            v = v * a + c
        buckets[v] += 1
    sizes: List[int] = list(buckets.values())
    assert max(sizes) <= k, "fiber exceeds degree -- impossible"
    assert sum(sizes) == len(set(A)), "fiber sizes must sum to |A|"
    return dict(buckets)
