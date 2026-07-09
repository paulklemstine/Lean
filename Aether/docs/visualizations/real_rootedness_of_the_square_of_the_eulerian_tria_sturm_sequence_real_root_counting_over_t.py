from fractions import Fraction
from typing import List

Poly = List[Fraction]

def _trim(p: Poly) -> Poly:
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q

def _deriv(p: Poly) -> Poly:
    return _trim([p[i] * i for i in range(1, len(p))]) if len(p) > 1 else [Fraction(0)]

def _rem(a: Poly, b: Poly) -> Poly:
    a = [Fraction(x) for x in _trim(a)]; b = _trim(b)
    while len(a) >= len(b) and not (len(a) == 1 and a[0] == 0):
        if a[-1] == 0:
            a.pop(); continue
        c = a[-1] / b[-1]; s = len(a) - len(b)
        for i in range(len(b)):
            a[i + s] -= c * b[i]
        a = _trim(a)
        if len(a) < len(b):
            break
    return _trim(a)

def sturm_sequence(p: Poly) -> List[Poly]:
    """Canonical Sturm chain p0=p, p1=p', p_{i+1} = -rem(p_{i-1}, p_i)."""
    p = [Fraction(x) for x in _trim(p)]
    seq = [p, _deriv(p)]
    while not (len(_trim(seq[-1])) == 1 and _trim(seq[-1])[0] == 0):
        r = _rem(seq[-2], seq[-1])
        if len(_trim(r)) == 1 and _trim(r)[0] == 0:
            break
        seq.append([-x for x in r])
    return seq

def _eval(p: Poly, x: Fraction) -> Fraction:
    acc = Fraction(0)
    for c in reversed(p):
        acc = acc * x + c
    return acc

def sign_changes(seq: List[Poly], x: Fraction) -> int:
    s = [1 if _eval(p, x) > 0 else -1 for p in seq if _eval(p, x) != 0]
    return sum(1 for i in range(len(s) - 1) if s[i] * s[i + 1] < 0)

def count_real_roots(coeffs: List[int], a: Fraction, b: Fraction) -> int:
    """Exact number of distinct real roots in (a, b] via Sturm's theorem."""
    seq = sturm_sequence([Fraction(c) for c in coeffs])
    return sign_changes(seq, a) - sign_changes(seq, b)
