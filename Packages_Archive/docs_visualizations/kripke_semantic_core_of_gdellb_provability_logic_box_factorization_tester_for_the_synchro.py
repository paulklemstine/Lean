from __future__ import annotations
from itertools import product as iproduct
from typing import Callable, Hashable, List, Set, Tuple

World = Hashable

def box_factor_tester(
    FW: List[World], FR: Callable[[World, World], bool],
    GW: List[World], GR: Callable[[World, World], bool],
    A: Set[World], B: Set[World]
) -> Tuple[bool, bool, Set[Tuple[World, World]]]:
    """Decide whether the box factors over the synchronized product.

    Builds the product frame (pairs; a step advances BOTH coordinates), then
    compares  □(A×B)  with  (□A)×(□B).  Returns
        (subset_holds, equality_holds, witnesses)
    where `witnesses` is the strict gap □(A×B) \ (□A×□B).  By the theory the
    subset always holds; equality holds iff both factors are edgeless.
    Complexity O(|FW|*|GW| * (|FW|+|GW|)).
    """
    PW: List[Tuple[World, World]] = list(iproduct(FW, GW))
    def PR(p: Tuple[World, World], q: Tuple[World, World]) -> bool:
        return FR(p[0], q[0]) and GR(p[1], q[1])

    def box(W, R, S):
        return {w for w in W if all(v in S for v in W if R(w, v))}

    rect = {(a, b) for a in A for b in B}
    box_rect = box(PW, PR, rect)
    boxA, boxB = box(FW, FR, A), box(GW, GR, B)
    rect_box = {(a, b) for a in boxA for b in boxB}
    return rect_box.issubset(box_rect), rect_box == box_rect, box_rect - rect_box
