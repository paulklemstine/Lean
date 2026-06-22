from __future__ import annotations
import itertools
import math
from typing import Callable

BOLTZMANN_K: float = 1.380649e-23
Proof = tuple

def expected_landauer_heat(
    n: int, f: Callable[[Proof], object], k: float = BOLTZMANN_K, T: float = 300.0
) -> float:
    """Heat of running f on the uniform distribution over Proof n:
        k * T * (H(uniform) - H(f_* uniform)).
    Returns 0 iff f is injective (reversible); >= 0 otherwise.
    Complexity: O(2^n).
    """
    states = list(itertools.product((0, 1), repeat=n))
    w = 1.0 / len(states)
    fibers: dict[object, float] = {}
    for x in states:
        y = f(x)
        fibers[y] = fibers.get(y, 0.0) + w
    h_src = -len(states) * (w * math.log(w))
    h_dst = -sum(p * math.log(p) for p in fibers.values() if p > 0.0)
    return k * T * (h_src - h_dst)

def is_reversible(n: int, f: Callable[[Proof], object]) -> bool:
    """True iff f is injective on Proof n (thermodynamically free)."""
    states = list(itertools.product((0, 1), repeat=n))
    return len({f(x) for x in states}) == len(states)
