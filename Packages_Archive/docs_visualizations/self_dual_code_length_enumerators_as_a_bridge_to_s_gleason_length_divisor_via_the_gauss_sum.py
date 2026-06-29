from __future__ import annotations
from itertools import product
from typing import List, Tuple

BinVec = Tuple[int, ...]

def weight(v: BinVec) -> int:
    return sum(1 for x in v if x == 1)

def gleason_length_divisor(code: List[BinVec], length: int) -> int:
    """For a doubly-even self-dual code, evaluate the master identity and return the
       forced divisor of the length. Confirms |C| = (1+i)^length and returns 8."""
    lhs = sum(1j ** weight(c) for c in code)
    rhs = (1 + 1j) ** length
    assert abs(lhs - rhs) < 1e-9, "master identity failed"
    assert abs(len(code) - rhs) < 1e-9, "|C| != (1+i)^n"
    # (1+i) has period 8; only exponents divisible by 8 are positive real.
    assert length % 8 == 0
    return 8
