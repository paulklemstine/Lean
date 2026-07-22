from typing import Sequence

def certify_strict_valley(profile: Sequence[float], v: int) -> tuple[bool, float]:
    if len(profile) < 2 or not 0 <= v < len(profile):
        raise ValueError("invalid input")
    shape = (all(profile[k+1] < profile[k] for k in range(v)) and
             all(profile[k] < profile[k+1] for k in range(v, len(profile)-1)))
    delta = min(x-profile[v] for i,x in enumerate(profile) if i != v)
    return shape, delta
