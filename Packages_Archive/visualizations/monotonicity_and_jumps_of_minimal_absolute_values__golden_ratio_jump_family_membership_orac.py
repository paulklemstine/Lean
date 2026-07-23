from __future__ import annotations
from typing import Dict, List

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def lucas(n: int) -> int:
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def jump_family(upper: int) -> Dict[int, List[str]]:
    """All jump positions N <= upper in {5F_m, L_m, 2L_m : m>=1}, tagged by type.

    Fibonacci and Lucas terms grow like phi^m, so only O(log upper) indices are
    generated; membership testing is O(log upper) per query.
    """
    fam: Dict[int, List[str]] = {}
    m = 1
    while True:
        vals = {5 * fib(m): f"5F_{m}", lucas(m): f"L_{m}", 2 * lucas(m): f"2L_{m}"}
        if min(vals) > upper and 5 * fib(m) > upper:
            break
        for v, tag in vals.items():
            if 1 <= v <= upper:
                fam.setdefault(v, []).append(tag)
        m += 1
    return fam
