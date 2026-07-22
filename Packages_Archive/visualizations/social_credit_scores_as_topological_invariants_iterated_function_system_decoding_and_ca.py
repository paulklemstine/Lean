from __future__ import annotations
from typing import List, Optional

def decode(x: float, depth: int) -> Optional[List[bool]]:
    """Recover a verdict history from a score by inverting the IFS.

    Returns the list of verdicts, or None if x leaves the Cantor set
    (i.e. falls into an open middle-third gap), certifying non-membership.
    """
    out: List[bool] = []
    for _ in range(depth):
        if x < 1.0 / 3.0:
            out.append(False)
            x = 3.0 * x
        elif x >= 2.0 / 3.0:
            out.append(True)
            x = 3.0 * x - 2.0
        else:
            return None
    return out
