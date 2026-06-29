from typing import Callable, Hashable, Optional, List, Set

def occurs(k: int, q0: Hashable,
           step: Callable[[Hashable, int], Hashable],
           out: Callable[[Hashable], Hashable],
           target: Hashable) -> bool:
    """Decide whether some input word produces output `target`.

    Reduces the infinite word search to a finite reachable-state search.
    """
    from_reach = {q0}
    while True:
        nxt = set(from_reach)
        for q in from_reach:
            for c in range(k):
                nxt.add(step(q, c))
        if nxt == from_reach:
            break
        from_reach = nxt
    return any(out(q) == target for q in from_reach)

def zero_in_sequence(k: int, q0: Hashable,
                     step: Callable[[Hashable, int], Hashable],
                     out: Callable[[Hashable], Hashable]) -> bool:
    """Decide the zero-in-sequence problem: does the DFAO ever output 0?"""
    return occurs(k, q0, step, out, 0)
