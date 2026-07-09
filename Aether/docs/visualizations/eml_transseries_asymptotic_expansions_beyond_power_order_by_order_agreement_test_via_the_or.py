from typing import Dict, List, Optional, Tuple

TransMono = Dict[int, float]

def lex_compare(m1: TransMono, m2: TransMono) -> int:
    for h in sorted(set(m1) | set(m2), reverse=True):
        e1, e2 = m1.get(h, 0.0), m2.get(h, 0.0)
        if e1 < e2: return -1
        if e1 > e2: return 1
    return 0

def order_top(series: List[Tuple[TransMono, float]]) -> Optional[TransMono]:
    """Leading (most dominant) transmonomial after collecting like terms;
    None ( = TOP ) iff the series is identically zero."""
    collected: Dict[Tuple, Tuple[TransMono, float]] = {}
    for m, c in series:
        k = tuple(sorted(m.items()))
        m0, c0 = collected.get(k, (m, 0.0))
        nc = c0 + c
        if nc == 0.0:
            collected.pop(k, None)
        else:
            collected[k] = (m0, nc)
    if not collected:
        return None
    best: Optional[TransMono] = None
    for m, _ in collected.values():
        if best is None or lex_compare(m, best) > 0:
            best = m
    return best

def agree_to_all_orders(a: List[Tuple[TransMono, float]],
                        b: List[Tuple[TransMono, float]]) -> bool:
    """AgreeToAllOrders(a, b): order(a - b) exceeds every transmonomial,
    i.e. order_top(a - b) is TOP, i.e. a == b (comparison theorem)."""
    diff = a + [(m, -c) for (m, c) in b]
    return order_top(diff) is None
