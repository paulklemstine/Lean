from typing import Dict, Callable

TropVec = Dict[int, int]

def recover_secret_exponent(v: TropVec, w: TropVec, coord: int) -> int:
    """Eigenline attack: with eigenvalue lam = 1, k = w[coord] - v[coord]."""
    return w[coord] - v[coord]

def iterate_tropical_map(f: Callable[[TropVec], TropVec],
                         v: TropVec, k: int) -> TropVec:
    w = dict(v)
    for _ in range(k):
        w = f(w)
    return w
