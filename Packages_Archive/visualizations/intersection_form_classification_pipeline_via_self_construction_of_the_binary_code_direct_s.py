from itertools import product
from typing import FrozenSet, Tuple

Vector = Tuple[int, ...]
Code = FrozenSet[Vector]


def concat(a: Vector, b: Vector) -> Vector:
    return a + b


def left_part(z: Vector, m: int) -> Vector:
    return z[:m]


def right_part(z: Vector, m: int) -> Vector:
    return z[m:]


def direct_sum(C: Code, D: Code) -> Code:
    '''C (+) D = { a || b : a in C, b in D }, size |C|*|D|.'''
    return frozenset(concat(a, b) for a in C for b in D)


def mem_direct_sum(z: Vector, C: Code, D: Code, m: int) -> bool:
    '''Theorem 3.1: z in C (+) D iff its two blocks lie in C and D.'''
    return left_part(z, m) in C and right_part(z, m) in D
