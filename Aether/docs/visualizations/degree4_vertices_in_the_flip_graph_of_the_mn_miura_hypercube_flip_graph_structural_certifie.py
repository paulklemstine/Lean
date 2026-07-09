from itertools import product
from typing import List, Tuple

Config = Tuple[bool, ...]

def flip(a: Config, i: int) -> Config:
    return a[:i] + (not a[i],) + a[i + 1:]

def certify_hypercube(d: int) -> bool:
    V: List[Config] = [tuple(b) for b in product([False, True], repeat=d)]
    assert len(V) == 2 ** d
    for a in V:
        assert len({flip(a, i) for i in range(d)}) == d
    E = sum(d for _ in V) // 2
    assert E == d * 2 ** (d - 1)
    start = tuple([True] * d)
    seen = {start}; frontier = [start]
    while frontier:
        nxt = []
        for a in frontier:
            for i in range(d):
                b = flip(a, i)
                if b not in seen:
                    seen.add(b); nxt.append(b)
        frontier = nxt
    assert len(seen) == 2 ** d
    return True

if __name__ == '__main__':
    for d in range(1, 7):
        print(d, certify_hypercube(d))
