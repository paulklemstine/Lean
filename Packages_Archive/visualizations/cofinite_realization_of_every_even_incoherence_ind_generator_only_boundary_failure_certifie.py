from itertools import combinations
from math import gcd
from typing import Iterable
# requires incoherence_index from Algorithm 1

def is_maximal(frame: Iterable[int], N: int) -> bool:
    g = N
    for a in frame:
        g = gcd(g, a % N)
    return g == 1

def is_generator(a: int, N: int) -> bool:
    a %= N
    return a != 0 and (N // gcd(a, N)) == N

def boundary_failure_certifier(N: int) -> dict[str, object]:
    """Certify that target index t = N/2 + 1 is unattainable by maximal frames
    on the even electorate N. Enumerates generator-only maximal frames and
    confirms none attains t (the computational form of Theorem A)."""
    assert N % 2 == 0, "electorate must be even"
    t = N // 2 + 1
    gens = [a for a in range(N) if is_generator(a, N)]
    witnesses = []
    for size in range(1, len(gens) + 1):
        for frame in combinations(gens, size):
            if is_maximal(frame, N) and incoherence_index(frame, N) == t:
                witnesses.append(frame)
    return {"N": N, "target": t, "unattainable": len(witnesses) == 0,
            "generators": gens, "violating_frames": witnesses}
