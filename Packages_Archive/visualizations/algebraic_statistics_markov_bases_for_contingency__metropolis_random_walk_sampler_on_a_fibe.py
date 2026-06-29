import random
from typing import Callable, List, Tuple

Table = List[List[int]]


def is_nonneg(u: Table) -> bool:
    return all(x >= 0 for r in u for x in r)


def fiber_walk(u0: Table, steps: int,
               statistic: Callable[[Table], float],
               observed: Table, seed: int = 0) -> float:
    """Estimate an exact conditional p-value by a basic-move random walk."""
    rng = random.Random(seed)
    m, n = len(u0), len(u0[0])
    u = [r[:] for r in u0]
    thr = statistic(observed)
    tail = 0
    for _ in range(steps):
        i, ip = rng.sample(range(m), 2)
        j, jp = rng.sample(range(n), 2)
        if rng.random() < 0.5:
            i, ip = ip, i
        w = [r[:] for r in u]
        w[i][jp] += 1; w[ip][j] += 1; w[i][j] -= 1; w[ip][jp] -= 1
        if is_nonneg(w):
            u = w
        if statistic(u) >= thr:
            tail += 1
    return tail / steps
