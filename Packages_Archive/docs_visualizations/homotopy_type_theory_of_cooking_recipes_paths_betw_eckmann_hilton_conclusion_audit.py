from typing import Callable, List

BinOp = Callable[[int, int], int]

def eckmann_hilton_audit(
    vcomp: BinOp, hcomp: BinOp, elems: List[int]
) -> dict:
    """Given a verified interchange structure, confirm the three conclusions.
    Coincidence and commutativity are O(|elems|^2); associativity is O(|elems|^3)."""
    coincide = all(vcomp(a, b) == hcomp(a, b) for a in elems for b in elems)
    commutative = all(vcomp(a, b) == vcomp(b, a) for a in elems for b in elems)
    associative = all(
        vcomp(vcomp(a, b), c) == vcomp(a, vcomp(b, c))
        for a in elems for b in elems for c in elems
    )
    return {"coincide": coincide, "commutative": commutative,
            "associative": associative}
