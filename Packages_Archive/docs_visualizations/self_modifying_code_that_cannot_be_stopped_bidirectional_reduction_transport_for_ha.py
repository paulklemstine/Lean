from __future__ import annotations
from typing import Callable, Tuple, TypeVar

P = TypeVar("P"); S = TypeVar("S"); X = TypeVar("X")

def reduce_selfmod_to_std(cfg: Tuple[P, S]) -> Tuple[P, S]:
    """cfg = (prog, state) already IS the simulation's state."""
    return (cfg[0], cfg[1])

def reduce_std_to_selfmod(s: S) -> Tuple[None, S]:
    """Embed a fixed-program instance with the trivial one-point program ()."""
    return (None, s)

def transfer_decider(D_source: Callable[[X], bool],
                     reduce: Callable[[object], X]) -> Callable[[object], bool]:
    """Turn a decider for the target problem into one for the source problem."""
    return lambda x: D_source(reduce(x))
