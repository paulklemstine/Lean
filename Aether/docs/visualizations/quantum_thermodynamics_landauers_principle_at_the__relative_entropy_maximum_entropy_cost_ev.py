from __future__ import annotations
import math
from typing import Dict, Hashable

def relative_entropy(p: Dict[Hashable, float], q: Dict[Hashable, float]) -> float:
    """KL divergence D(p||q) = sum_omega p(omega) ln(p(omega)/q(omega)).

    Zero-probability outcomes contribute nothing (the convention 0 ln 0 = 0),
    so only the support of p is summed. By Gibbs' inequality the result is >= 0
    whenever q has full support; equality holds iff p = q.
    """
    total = 0.0
    for omega, pp in p.items():
        if pp > 0.0:
            total += pp * math.log(pp / q[omega])
    return total

def shannon_entropy(p: Dict[Hashable, float]) -> float:
    """H(p) = -sum_omega p(omega) ln p(omega)  (in nats)."""
    return -sum(v * math.log(v) for v in p.values() if v > 0.0)

def max_entropy_gap(p: Dict[Hashable, float], n_states: int) -> float:
    """Slack ln N - H(p) >= 0 in the maximum-entropy bound, equal to D(p||uniform)."""
    return math.log(n_states) - shannon_entropy(p)
