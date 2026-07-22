from __future__ import annotations
import math
from typing import Sequence, Tuple

def jarzynski_check(p: Sequence[float], work: Sequence[float],
                    alpha: float) -> Tuple[float, float, float, bool]:
    """Return (E[W], correction, dF, saturated)."""
    mean_w: float = sum(px * wx for px, wx in zip(p, work))
    z: float = sum(px * math.exp(-alpha * (wx - mean_w))
                   for px, wx in zip(p, work))
    corr: float = math.log(z) / alpha
    df: float = mean_w - corr
    return mean_w, corr, df, abs(corr) < 1e-18 * max(1.0, abs(mean_w))
