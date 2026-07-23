from typing import List, Optional

def central_weight(weights: List[int], c: int) -> Optional[int]:
    """Return the weight a with 2a = c (center of symmetry) if present, else None.

    For odd, regular, polarized input this weight is guaranteed to exist and be
    unique. Complexity: O(n).
    """
    found: Optional[int] = None
    for a in weights:
        if 2 * a == c:
            if found is not None and found != a:
                return None  # not regular around the center
            found = a
    return found
