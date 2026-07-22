from __future__ import annotations
import itertools, math
from typing import Iterator, Tuple

def sp(b: bool) -> float:
    """Spin value: True -> +1, False -> -1."""
    return 1.0 if b else -1.0

def all_configs(n: int) -> Iterator[Tuple[bool, ...]]:
    """All 2^(n+1) configurations of an n-bond chain."""
    return itertools.product([False, True], repeat=n + 1)

def weight(beta: float, J: float, n: int, s: Tuple[bool, ...]) -> float:
    """Boltzmann weight: product of edge factors exp(beta J s_i s_{i+1})."""
    w = 1.0
    for i in range(n):
        w *= math.exp(beta * J * sp(s[i]) * sp(s[i + 1]))
    return w

def brute_force_correlation(beta: float, J: float, n: int) -> float:
    """Exact <s0 sn> by enumerating all configurations."""
    Z = 0.0
    corr_num = 0.0
    for s in all_configs(n):
        w = weight(beta, J, n, s)
        Z += w
        corr_num += sp(s[0]) * sp(s[n]) * w
    return corr_num / Z
