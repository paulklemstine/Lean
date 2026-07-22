from itertools import product
from typing import Callable, Dict, Tuple, List

Val = str
VALUES: Tuple[str, ...] = ("T", "F", "B", "N")

def neg(v: Val) -> Val:
    return {"T": "F", "F": "T", "B": "B", "N": "N"}[v]

def _pair(v: Val) -> Tuple[int, int]:
    return {"T": (1, 0), "F": (0, 1), "B": (1, 1), "N": (0, 0)}[v]

def _unpair(tt: int, tf: int) -> Val:
    return {(1, 0): "T", (0, 1): "F", (1, 1): "B", (0, 0): "N"}[(tt, tf)]

def conj(x: Val, y: Val) -> Val:
    (a, b), (c, d) = _pair(x), _pair(y)
    return _unpair(min(a, c), max(b, d))

def disj(x: Val, y: Val) -> Val:
    (a, b), (c, d) = _pair(x), _pair(y)
    return _unpair(max(a, c), min(b, d))

def verify_de_morgan_algebra() -> Dict[str, bool]:
    """Exhaustively verify the distributive De Morgan-algebra laws."""
    laws: Dict[str, Callable[[], bool]] = {
        "involution": lambda: all(neg(neg(v)) == v for v in VALUES),
        "deMorgan_conj": lambda: all(neg(conj(x, y)) == disj(neg(x), neg(y))
                                     for x in VALUES for y in VALUES),
        "deMorgan_disj": lambda: all(neg(disj(x, y)) == conj(neg(x), neg(y))
                                     for x in VALUES for y in VALUES),
        "distributivity": lambda: all(
            conj(x, disj(y, z)) == disj(conj(x, y), conj(x, z))
            for x, y, z in product(VALUES, repeat=3)),
    }
    return {name: check() for name, check in laws.items()}
