from fractions import Fraction
from typing import List, Optional, Sequence

Poly = List[Fraction]


def _int_kth_root(m: int, k: int) -> Optional[int]:
    if m == 0:
        return 0
    r = round(m ** (1.0 / k))
    for cand in (r - 1, r, r + 1):
        if cand >= 0 and cand ** k == m:
            return cand
    return None


def _rational_kth_root(a: Fraction, k: int) -> Optional[Fraction]:
    if a == 0:
        return Fraction(0)
    sign = 1 if a > 0 else -1
    if sign < 0 and k % 2 == 0:
        return None
    num = _int_kth_root(abs(a.numerator), k)
    den = _int_kth_root(abs(a.denominator), k)
    if num is None or den is None:
        return None
    return Fraction(sign * num, den)


def _mul(p: Poly, q: Poly) -> Poly:
    out = [Fraction(0)] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    while len(out) > 1 and out[-1] == 0:
        out.pop()
    return out


def _power(p: Poly, k: int) -> Poly:
    r: Poly = [Fraction(1)]
    for _ in range(k):
        r = _mul(r, p)
    return r


def kth_root(p: Sequence[object], k: int) -> Optional[Poly]:
    """Exact rational polynomial k-th root, or None if p is not a k-th power."""
    q: Poly = [Fraction(c) for c in p]
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    if all(c == 0 for c in q):
        return [Fraction(0)]
    d = len(q) - 1
    if d % k != 0:
        return None
    m = d // k
    lead = _rational_kth_root(q[-1], k)
    if lead is None:
        return None
    c: Poly = [Fraction(0)] * (m + 1)
    c[m] = lead
    denom = k * lead ** (k - 1)
    for j in range(m - 1, -1, -1):
        cur = _power(c, k)
        idx = j + m * (k - 1)
        target = q[idx] if idx < len(q) else Fraction(0)
        have = cur[idx] if idx < len(cur) else Fraction(0)
        c[j] += (target - have) / denom
    return c if _power(c, k) == q else None
