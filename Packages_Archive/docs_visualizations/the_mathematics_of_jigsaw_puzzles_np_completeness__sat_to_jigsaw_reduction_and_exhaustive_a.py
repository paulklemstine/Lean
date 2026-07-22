from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

Literal = Tuple[int, bool]
Clause = List[Literal]
Formula = List[Clause]
Assignment = Callable[[int], bool]

def variables_of(F: Formula) -> List[int]:
    return sorted({v for c in F for (v, _) in c})

def piece_count(n_vars: int, F: Formula) -> int:
    """Number of pieces the reduction emits: 2 corners, 2 per variable, 1 per clause."""
    return 2 * n_vars + len(F) + 2

def solve(F: Formula) -> Optional[Dict[int, bool]]:
    """Search all assignments; return a satisfying one iff the puzzle is solvable."""
    variables = variables_of(F)
    for bits in product([False, True], repeat=len(variables)):
        table = dict(zip(variables, bits))
        if all(any(table.get(v, False) == p for (v, p) in c) for c in F):
            return table
    return None
