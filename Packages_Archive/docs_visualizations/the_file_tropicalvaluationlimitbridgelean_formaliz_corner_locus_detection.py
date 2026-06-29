from typing import List, Sequence

def attained_at_least_twice(weights: Sequence[float], tol: float = 1e-9) -> bool:
    """Return True iff the minimum of `weights` is attained by at least two indices.

    Implements the corner-locus predicate AttainedAtLeastTwice: a tropical
    polynomial has a corner at the point producing these monomial values exactly
    when at least two monomials are tied for the minimum.
    Time O(n), space O(1).
    """
    if not weights:
        return False
    m = min(weights)
    count = 0
    for w in weights:
        if abs(w - m) <= tol:
            count += 1
            if count >= 2:
                return True
    return False
