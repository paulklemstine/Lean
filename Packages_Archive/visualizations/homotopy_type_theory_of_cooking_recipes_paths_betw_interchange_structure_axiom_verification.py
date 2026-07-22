from itertools import product
from typing import Callable, List

BinOp = Callable[[int, int], int]

def verify_interchange_structure(
    vcomp: BinOp, hcomp: BinOp, elems: List[int], unit: int
) -> bool:
    """Return True iff (vcomp, hcomp, unit) is an interchange structure.
    Unit checks are O(|elems|); the interchange check is O(|elems|^4)."""
    for a in elems:
        if vcomp(unit, a) != a or vcomp(a, unit) != a:
            return False
        if hcomp(unit, a) != a or hcomp(a, unit) != a:
            return False
    for a, b, c, d in product(elems, repeat=4):
        if vcomp(hcomp(a, b), hcomp(c, d)) != hcomp(vcomp(a, c), vcomp(b, d)):
            return False
    return True
