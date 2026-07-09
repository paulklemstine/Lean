from __future__ import annotations
from typing import List, Set, Tuple

def con_status(worlds: List[int], R: Set[Tuple[int, int]]) -> str:
    """Classify the consistency sentence on a finite GL frame."""
    con_true = 0
    con_false = 0
    for w in worlds:
        terminal = not any((w, v) in R for v in worlds)
        # box bot is true iff w is terminal; Con = box bot -> bot.
        if terminal:
            con_false += 1
        else:
            con_true += 1
    if con_false == 0:
        return 'PROVABLE'
    if con_true == 0:
        return 'REFUTABLE'
    return 'INDEPENDENT'

if __name__ == '__main__':
    # standard frame: 1 -> 0, world 0 terminal, world 1 internal
    print(con_status([0, 1], {(1, 0)}))   # INDEPENDENT
