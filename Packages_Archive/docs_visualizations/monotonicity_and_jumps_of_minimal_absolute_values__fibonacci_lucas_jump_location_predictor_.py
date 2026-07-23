from __future__ import annotations

def _fib(m: int) -> int:
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a

def _lucas(m: int) -> int:
    a, b = 2, 1
    for _ in range(m):
        a, b = b, a + b
    return a

def predicted_jumps(N: int) -> set[int]:
    family: set[int] = set()
    m: int = 1
    while True:
        fm, lm = _fib(m), _lucas(m)
        for v in (5 * fm, lm, 2 * lm):
            if v <= N:
                family.add(v)
        if min(5 * fm, lm) > N:
            break
        m += 1
    return {v - 5 for v in family if v - 5 >= 1}
