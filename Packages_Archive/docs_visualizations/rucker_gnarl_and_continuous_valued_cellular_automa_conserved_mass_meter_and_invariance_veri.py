from typing import Dict

Config = Dict[int, float]

def mass(c: Config) -> float:
    """Total conserved mass (heat content) of a finitely supported config."""
    return sum(c.values())

def check_mass_invariance(a: float, c: Config, steps: int) -> bool:
    """Verify mass(iter_a^steps c) == mass(c) (Theorem mass_iter_conserved)."""
    from math import isclose
    m0 = mass(c)
    cur = dict(c)
    for _ in range(steps):
        out: Config = {}
        lo, hi = min(cur), max(cur)
        for x in range(lo - 1, hi + 2):
            v = (a * cur.get(x - 1, 0.0)
                 + (1.0 - 2.0 * a) * cur.get(x, 0.0)
                 + a * cur.get(x + 1, 0.0))
            if v != 0.0:
                out[x] = v
        cur = out
    return isclose(mass(cur), m0, abs_tol=1e-9)
