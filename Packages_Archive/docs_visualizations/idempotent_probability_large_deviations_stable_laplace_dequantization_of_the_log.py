import math
from typing import Sequence

def scaled_log_partition(g: Sequence[float], n: float) -> float:
    """Numerically stable (1/n) log sum_x exp(n g(x)) (Maslov dequantization).

    Subtracts the peak before exponentiating to avoid overflow. As n -> inf the
    value converges to max_x g(x) with certified error at most log(len(g))/n.
    """
    peak = max(g)
    s = 0.0
    for gx in g:
        s += math.exp(n * (gx - peak))
    return peak + math.log(s) / n
