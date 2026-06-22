from typing import List

def alive_count(deaths: List[int], t: int) -> int:
    """#{ d in D : t < d } -- finite bars still alive at threshold t."""
    return sum(1 for d in deaths if t < d)

def beta0(deaths: List[int], t: int) -> int:
    """Component count: 1 essential class + alive finite bars."""
    return 1 + alive_count(deaths, t)

def total_persistence(deaths: List[int], horizon: int) -> int:
    """Discrete area under (beta0 - 1) up to horizon T.

    By the layer-cake identity this equals sum_d min(d, T); once T dominates
    every death it equals sum_d d, the minimum spanning tree weight.
    """
    return sum(beta0(deaths, t) - 1 for t in range(horizon))
