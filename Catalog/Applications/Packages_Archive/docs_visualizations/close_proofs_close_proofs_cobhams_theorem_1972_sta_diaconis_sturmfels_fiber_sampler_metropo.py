import random
from itertools import product
from typing import Dict, List, Tuple, Callable

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def add_scaled(u: Table, scale: int) -> Table:
    return {c: u[c] + scale * M3(*c) for c in CELLS}


def is_nonneg(u: Table) -> bool:
    return all(v >= 0 for v in u.values())


def ds_sample(u0: Table, n_steps: int,
              weight: Callable[[Table], float] = lambda _t: 1.0) -> List[Table]:
    """
    Diaconis-Sturmfels random walk on a fiber using the single move M3.
    Irreducibility is guaranteed by the Fundamental Theorem of Markov Bases:
    {M3} connects every fiber. The optional weight gives a Metropolis target.
    """
    u: Table = dict(u0)
    samples: List[Table] = []
    for _ in range(n_steps):
        eps: int = random.choice((1, -1))
        w: Table = add_scaled(u, eps)
        if is_nonneg(w):
            ratio: float = weight(w) / max(weight(u), 1e-300)
            if random.random() < min(1.0, ratio):
                u = w
        samples.append(dict(u))
    return samples
