from itertools import product
from typing import List, Tuple

BinVec = Tuple[int, ...]

HAMMING_GEN: List[BinVec] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def vec_add(x: BinVec, y: BinVec) -> BinVec:
    return tuple((a + b) % 2 for a, b in zip(x, y))


def encode(a: Tuple[int, int, int, int]) -> BinVec:
    """Encode a 4-bit message into an 8-bit Hamming codeword over GF(2)."""
    out: BinVec = (0,) * 8
    for coeff, row in zip(a, HAMMING_GEN):
        if coeff == 1:
            out = vec_add(out, row)
    return out


def hamming_code() -> List[BinVec]:
    """Enumerate all 16 codewords of the extended Hamming code [8,4,4]."""
    return [encode(a) for a in product((0, 1), repeat=4)]
