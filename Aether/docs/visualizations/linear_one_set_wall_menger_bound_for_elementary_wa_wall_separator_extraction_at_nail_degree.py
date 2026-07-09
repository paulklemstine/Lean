from typing import FrozenSet, List

def wall_separator(traces: List[FrozenSet[int]], s: int):
    packing, union = greedy_maximal_packing(traces)
    if len(packing) >= s:
        return ('packing_horn', packing)
    assert all(len(t) <= 4 for t in traces)
    assert len(union) <= 4 * s - 4   # F(s) = 4s - 4
    return ('cover_horn', sorted(union))
