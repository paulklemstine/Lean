from typing import FrozenSet, List

def ring_add(r: int, s: int, n: int) -> int:
    return (r ^ s) & ((1 << n) - 1)

def ring_mul(r: int, s: int) -> int:
    return r & s

def basic_open(r: int, n: int) -> FrozenSet[int]:
    return frozenset(i for i in range(n) if (r >> i) & 1)

def clopen_to_basic_open(cover: List[int], n: int) -> int:
    # Fold a finite cover of basic opens into one basic open D(s).
    s = 0
    for r in cover:
        s = ring_add(ring_add(s, r, n), ring_mul(s, r), n)
    return s
