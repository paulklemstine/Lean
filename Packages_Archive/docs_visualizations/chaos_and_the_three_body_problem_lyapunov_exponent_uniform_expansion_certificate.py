from __future__ import annotations
import math
from typing import Callable, List, Optional, Tuple

def uniform_expansion_certificate(df: Callable[[float], float],
                                  samples: List[float]
                                  ) -> Tuple[bool, Optional[float]]:
    """Verify uniform expansion |f'(y)| >= c > 1 on a sample set and return a
    certified positive lower bound log c for every finite-time Lyapunov exponent
    (Theorem ftle_ge_log). Returns (is_chaotic, log_c).

    For a rigorous (not just sampled) certificate, replace `df(y)` evaluation by
    interval arithmetic over each subinterval. Complexity: O(|samples|)."""
    if not samples:
        return (False, None)
    c: float = min(abs(df(y)) for y in samples)
    if c > 1.0:
        return (True, math.log(c))
    return (False, None)
