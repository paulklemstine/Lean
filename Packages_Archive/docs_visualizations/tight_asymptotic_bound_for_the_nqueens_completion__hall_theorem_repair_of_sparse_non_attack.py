from math import gcd
from typing import Dict, List, Optional, Set, Tuple

Cell = Tuple[int, int]

def _augment(row: int, adj: Dict[int, List[int]],
             match_col: Dict[int, int], seen: Set[int]) -> bool:
    for col in adj[row]:
        if col in seen:
            continue
        seen.add(col)
        if col not in match_col or _augment(match_col[col], adj, match_col, seen):
            match_col[col] = row
            return True
    return False

def hall_repair(n: int, q: Set[Cell]) -> Optional[Set[Cell]]:
    used_rows = {r for (r, _) in q}
    used_cols = {c for (_, c) in q}
    f_anti = {r + c for (r, c) in q}
    f_main = {r - c for (r, c) in q}
    empty_rows = [r for r in range(n) if r not in used_rows]
    empty_cols = [c for c in range(n) if c not in used_cols]
    adj = {r: [c for c in empty_cols
               if (r + c) not in f_anti and (r - c) not in f_main]
           for r in empty_rows}
    match_col: Dict[int, int] = {}
    for r in empty_rows:
        if not _augment(r, adj, match_col, set()):
            return None
    placement = set(q)
    for c, r in match_col.items():
        placement.add((r, c))
    return placement
