from __future__ import annotations
from typing import Tuple

Matrix = Tuple[int, int, int, int]

def operator_order(m: int) -> int:
    """Order of M=[[1,1],[1,0]] in GL_2(Z/mZ), i.e. the Pisano period pi(m)."""
    if m == 1:
        return 1
    ident: Matrix = (1 % m, 0, 0, 1 % m)
    M: Matrix = (1, 1, 1, 0)
    power: Matrix = M
    steps = 1
    while power != ident:
        a, b, c, d = power
        power = ((a + c) % m, a % m, (c + d) % m, c % m)  # power * M
        steps += 1
    return steps
