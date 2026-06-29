from __future__ import annotations
from typing import Callable, FrozenSet, List, Tuple

Elem = FrozenSet[int]

def descending_iteration(
    top: Elem, g: Callable[[Elem], Elem]
) -> Tuple[Elem, List[Elem]]:
    """Compute a fixed point of a monotone map g by iterating from the top
    element until two consecutive iterates agree.

    On a finite (descending-chain-condition) order the sequence
        top >= g(top) >= g(g(top)) >= ...
    is strictly descending until it stabilises, so the loop terminates in at
    most |order| steps and returns a value a with g(a) = a.
    """
    x: Elem = top
    trace: List[Elem] = [x]
    while True:
        x_next = g(x)
        trace.append(x_next)
        if x_next == x:
            return x, trace
        x = x_next
