from typing import Set

Degree = int

def join(f: Degree, g: Degree) -> Degree:
    """Least upper bound of two degrees: computes both, dominated by every common bound."""
    return max(f, g)

def is_least_upper_bound(j: Degree, f: Degree, g: Degree, candidates: Set[Degree]) -> bool:
    upper = f <= j and g <= j
    least = all(j <= h for h in candidates if f <= h and g <= h)
    return upper and least
