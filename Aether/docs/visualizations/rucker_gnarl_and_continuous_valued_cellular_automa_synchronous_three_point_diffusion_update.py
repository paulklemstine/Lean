from typing import Dict

Config = Dict[int, float]

def step(a: float, c: Config) -> Config:
    """One synchronous update of step_a on a finitely supported configuration."""
    out: Config = {}
    if not c:
        return out
    lo, hi = min(c), max(c)
    for x in range(lo - 1, hi + 2):
        val = (a * c.get(x - 1, 0.0)
               + (1.0 - 2.0 * a) * c.get(x, 0.0)
               + a * c.get(x + 1, 0.0))
        if val != 0.0:
            out[x] = val
    return out

def iterate(a: float, n: int, c: Config) -> Config:
    for _ in range(n):
        c = step(a, c)
    return c
