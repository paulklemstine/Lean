import random
from typing import Callable, List, Tuple

Table = List[List[int]]


def metropolis_fiber_sampler(u0: Table,
                             log_target: Callable[[Table], float],
                             steps: int,
                             seed: int = 0) -> Table:
    """Metropolis MCMC on a fiber of fixed margins using symmetric basic-move
    proposals. Because the proposal is symmetric (the inverse of a basic move
    is a basic move), the acceptance ratio is exp(log_target(w)-log_target(u))."""
    random.seed(seed)
    m, n = len(u0), len(u0[0])
    u = [row[:] for row in u0]
    cur_lp = log_target(u)
    for _ in range(steps):
        i, ip = random.sample(range(m), 2)
        j, jp = random.sample(range(n), 2)
        sgn = random.choice((1, -1))
        w = [row[:] for row in u]
        w[i][jp] += sgn; w[ip][j] += sgn; w[i][j] -= sgn; w[ip][jp] -= sgn
        if any(x < 0 for row in w for x in row):
            continue
        wp = log_target(w)
        if wp >= cur_lp or random.random() < pow(2.718281828, wp - cur_lp):
            u, cur_lp = w, wp
    return u
