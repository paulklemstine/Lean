from typing import List, Optional, Tuple
from fractions import Fraction
from itertools import product

def _mul(a: List[Fraction], b: List[Fraction]) -> List[Fraction]:
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return out

def _add(a: List[Fraction], b: List[Fraction], s: int = 1) -> List[Fraction]:
    n = max(len(a), len(b))
    a = a + [Fraction(0)] * (n - len(a))
    b = b + [Fraction(0)] * (n - len(b))
    return [x + s * y for x, y in zip(a, b)]

def _der(a: List[Fraction]) -> List[Fraction]:
    return [k * a[k] for k in range(1, len(a))] or [Fraction(0)]

def _norm(a: List[Fraction]) -> List[Fraction]:
    while len(a) > 1 and a[-1] == 0:
        a = a[:-1]
    return a

def search_rational_riccati(f: List[Fraction], max_deg: int = 2,
                            R: int = 2) -> Optional[Tuple[List[Fraction], List[Fraction]]]:
    rng = range(-R, R + 1)
    for dp in range(max_deg + 1):
        for dq in range(max_deg + 1):
            for pc in product(rng, repeat=dp + 1):
                p = [Fraction(t) for t in pc]
                for qc in product(rng, repeat=dq + 1):
                    q = [Fraction(t) for t in qc]
                    if _norm(q) == [Fraction(0)]:
                        continue
                    lhs = _add(_add(_mul(_der(p), q), _mul(p, _der(q)), -1), _mul(p, p))
                    rhs = _mul(f, _mul(q, q))
                    if _norm(lhs) == _norm(rhs):
                        return (_norm(p), _norm(q))
    return None
