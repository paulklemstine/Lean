from typing import Callable, Dict, List

def diagonal_witness(e: Dict[object, Dict[object, bool]],
                     domain: List[object],
                     flip: Callable[[bool], bool]) -> Dict[object, bool]:
    """
    Construct the escaping diagonal function for a Boolean evaluation map.

    For e : A -> (A -> Bool) and a fixed-point-free flip (e.g. logical NOT),
    return d(x) = flip(e[x][x]).  By Lawvere's contrapositive, d differs from
    every named function e[a] at the point a, so e cannot be surjective.
    """
    return {x: flip(e[x][x]) for x in domain}

def is_named(d: Dict[object, bool],
             e: Dict[object, Dict[object, bool]],
             domain: List[object]) -> bool:
    """True iff some name a has e[a] == d (it never does for the diagonal)."""
    return any(all(e[a][x] == d[x] for x in domain) for a in domain)
