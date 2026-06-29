from __future__ import annotations
from itertools import product
from typing import List, Tuple

BinVec = Tuple[int, ...]

def inner_product(x: BinVec, y: BinVec) -> int:
    """Binary inner product over GF(2)."""
    return sum(a * b for a, b in zip(x, y)) % 2

def is_self_dual(code: List[BinVec], length: int) -> bool:
    """Return True iff the code equals its own orthogonal complement."""
    code_set = set(code)
    for x in product((0, 1), repeat=length):
        orthogonal_to_all = all(inner_product(x, c) == 0 for c in code)
        if (x in code_set) != orthogonal_to_all:
            return False
    return True
