from __future__ import annotations
import itertools
from typing import List, Tuple

Vector = Tuple[int, ...]

def inner_product(x: Vector, y: Vector) -> int:
    return sum(a * b for a, b in zip(x, y)) % 2

def bchar(x: Vector, c: Vector) -> int:
    """Additive character (-1)^{<x,c>}, returns +1 or -1."""
    return -1 if inner_product(x, c) == 1 else 1

def character_sum(code: List[Vector], x: Vector) -> int:
    """sum_{c in C} (-1)^{<x,c>}; equals |C| if x in C, else 0."""
    return sum(bchar(x, c) for c in code)

def verify_orthogonality(code: List[Vector]) -> bool:
    code_set = set(code)
    n = len(code[0])
    for x in itertools.product((0, 1), repeat=n):
        s = character_sum(code, x)
        expected = len(code) if x in code_set else 0
        if s != expected:
            return False
    return True
