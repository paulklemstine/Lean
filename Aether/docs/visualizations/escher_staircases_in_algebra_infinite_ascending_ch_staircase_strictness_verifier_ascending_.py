from typing import Callable, Tuple, TypeVar

T = TypeVar("T")

def verify_staircase(
    member: Callable[[T, int], bool],
    witness: Callable[[int], T],
    depth: int,
) -> Tuple[bool, int]:
    """Certify I_0 < I_1 < ... < I_depth via separating witnesses.

    member(w, n): True iff element w lies in rung n.
    witness(n):   an element expected in rung n+1 but not rung n.
    Returns (True, depth) if strict throughout, else (False, failing_level).
    """
    for n in range(depth):
        w = witness(n)
        in_lower = member(w, n)
        in_upper = member(w, n + 1)
        if not (in_upper and not in_lower):
            return (False, n)
    return (True, depth)
