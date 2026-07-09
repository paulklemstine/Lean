from typing import List, Optional

def polarization_center(weights: List[int]) -> Optional[int]:
    """Return the similitude weight c if `weights` is polarized, else None.

    Complexity: O(n log n) dominated by the sort.
    """
    if not weights:
        return None
    w = sorted(weights)
    n = len(w)
    c = w[0] + w[-1]
    for i in range(n):
        if w[i] + w[n - 1 - i] != c:
            return None
    return c
