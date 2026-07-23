import math
from typing import Sequence

def kl_divergence(p: Sequence[float], q: Sequence[float]) -> float:
    """Kullback-Leibler divergence KL(p||q) = sum_x p[x]*log(p[x]/q[x]).

    Returns 0 when p == q (KL_self_zero) and is always >= 0 for probability
    vectors (Gibbs' inequality, KL_nonneg). Complexity: O(n).
    """
    return sum(px*math.log(px/qx) for px, qx in zip(p, q))
