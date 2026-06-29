from itertools import product
from typing import List, Tuple

def hamming_distance(x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    return sum(1 for a, b in zip(x, y) if a != b)

def greedy_maximal_code(n: int, q: int, d: int) -> List[Tuple[int, ...]]:
    """
    Gilbert-Varshamov greedy construction: enumerate the q^n words in fixed
    order, accepting each word at distance >= d from all accepted codewords.
    The result is a d-separated MAXIMAL code, attaining q^n <= |C|*V(d-1).
    """
    code: List[Tuple[int, ...]] = []
    for w in product(range(q), repeat=n):
        if all(hamming_distance(w, c) >= d for c in code):
            code.append(w)
    return code
