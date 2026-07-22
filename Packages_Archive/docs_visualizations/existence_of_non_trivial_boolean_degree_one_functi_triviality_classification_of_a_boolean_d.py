from typing import Callable, FrozenSet, List, Tuple


def is_trivial_bdo(
    points: List[int],
    lines: List[FrozenSet[int]],
    f: Callable[[FrozenSet[int]], float],
) -> Tuple[bool, str]:
    """Decide whether a Boolean degree one function f is trivial, returning a
    (verdict, label) pair.  Trivial = constant, point-pencil, or a complement.
    """
    def vals(g: Callable[[FrozenSet[int]], float]) -> Tuple[float, ...]:
        return tuple(round(g(l), 9) for l in lines)

    fv = vals(f)
    # constants
    if fv == tuple(0.0 for _ in lines):
        return True, "constant 0"
    if fv == tuple(1.0 for _ in lines):
        return True, "constant 1"
    # point-pencils and their complements
    for p in points:
        pencil = vals(lambda l, p=p: 1.0 if p in l else 0.0)
        if fv == pencil:
            return True, f"pencil(p={p})"
        comp = tuple(1.0 - x for x in pencil)
        if fv == comp:
            return True, f"complement of pencil(p={p})"
    return False, "non-trivial (or dual hyperplane family)"
