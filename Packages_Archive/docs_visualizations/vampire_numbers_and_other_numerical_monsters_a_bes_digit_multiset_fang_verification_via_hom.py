from collections import Counter
from typing import Tuple
def verify_fang(v: int, x: int, y: int) -> Tuple[bool, bool, bool]:
    if x * y != v:
        return (False, False, False)
    Mv, Mx, My = Counter(str(v)), Counter(str(x)), Counter(str(y))
    is_fang: bool = (Mv == Mx + My)
    len_ok: bool = (sum(Mv.values()) == sum(Mx.values()) + sum(My.values()))
    sum_total = lambda C: sum(int(d) * k for d, k in C.items())
    sum_ok: bool = (sum_total(Mv) == sum_total(Mx) + sum_total(My))
    return (is_fang, len_ok, sum_ok)
