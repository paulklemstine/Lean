from __future__ import annotations
from itertools import product
from typing import List, Tuple

BinVec = Tuple[int, ...]

def encode(message: BinVec, generator: List[BinVec]) -> BinVec:
    """Encode a message a as c_j = sum_i a_i * G_ij  (mod 2)."""
    n = len(generator[0])
    return tuple(sum(message[i] * generator[i][j] for i in range(len(generator))) % 2
                 for j in range(n))

def generate_code(generator: List[BinVec]) -> List[BinVec]:
    """Enumerate all 2^k codewords spanned by the k generator rows."""
    k = len(generator)
    seen, code = set(), []
    for message in product((0, 1), repeat=k):
        c = encode(message, generator)
        if c not in seen:
            seen.add(c); code.append(c)
    return code
