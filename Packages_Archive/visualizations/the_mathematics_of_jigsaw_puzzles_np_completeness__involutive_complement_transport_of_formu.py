from itertools import product
from typing import Sequence, Tuple
Literal = Tuple[int, bool]
Formula = Sequence[Sequence[Literal]]
Assignment = Tuple[bool, ...]

def sat(a: Assignment, f: Formula) -> bool:
    return all(any(a[i] == p for i, p in c) for c in f)

def complement_formula(f: Formula) -> list[list[Literal]]:
    return [[(i, not p) for i, p in c] for c in f]

def complement_assignment(a: Assignment) -> Assignment:
    return tuple(not x for x in a)

if __name__ == "__main__":
    f = [[(0, True), (1, True), (2, False)], [(0, False), (2, True)]]
    cf = complement_formula(f)
    for a in product((False, True), repeat=3):
        assert sat(a, f) == sat(complement_assignment(a), cf)
    print("All eight assignments obey complement symmetry.")
