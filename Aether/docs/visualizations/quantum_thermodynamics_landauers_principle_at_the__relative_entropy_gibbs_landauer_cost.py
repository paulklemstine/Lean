from __future__ import annotations
import math
from typing import Sequence


def relative_entropy(p: Sequence[float], q: Sequence[float]) -> float:
    """KL divergence D(p || q) = sum p ln(p/q); requires q > 0 on supp p."""
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q) if pi > 0.0)


def landauer_cost_via_gibbs(p: Sequence[float], q: Sequence[float],
                            k: float, T: float) -> float:
    """Relative-entropy form of the Landauer cost: kT * D(p || q) >= 0 (Gibbs)."""
    return k * T * relative_entropy(p, q)
