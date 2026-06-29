from collections import Counter
from typing import Callable, Dict, List, Optional, Tuple
Pos = Tuple[int, int]
PartialDB = Dict[Pos, Optional[int]]

def column_mode_estimator(p: Pos, observed: PartialDB) -> int:
    col = p[1]
    vals = [v for (r, c), v in observed.items() if c == col and v is not None]
    return Counter(vals).most_common(1)[0][0] if vals else 0

def nearest_global_section_impute(
    observed: PartialDB,
    positions: List[Pos],
    estimator: Callable[[Pos, PartialDB], int] = column_mode_estimator,
) -> Dict[Pos, int]:
    candidate: Dict[Pos, int] = {}
    for p in positions:
        v = observed.get(p)
        candidate[p] = v if v is not None else estimator(p, observed)
    return candidate
